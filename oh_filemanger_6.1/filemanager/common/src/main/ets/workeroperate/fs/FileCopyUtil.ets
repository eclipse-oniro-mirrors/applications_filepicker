/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import fs from '@ohos.file.fs';
import type uri from '@ohos.uri';
import fileuri from '@ohos.file.fileuri';
import { CopyCutSendParam, ProgressBarStatus } from '../../workermanager/copycutmanager/CopyCutSendParam';
import { ThreadCommonUtil } from './ThreadCommonUtil';
import { CopyCutResultParam } from '../../workermanager/copycutmanager/CopyCutResultParam';
import WorkerConst from '../../worker/WorkerConst';
import type { ThreadWorkerGlobalScope } from '@ohos.worker';
import { HiLog } from '../../dfx/HiLog';
import { FileInfo } from '../../fileoperate/FileInfo';
import { StorageUtil } from '../../utils/StorageUtil';
import { TimeUtil } from '../../utils/TimeUtil';
import { ObjectUtil } from '../../utils/ObjectUtil';
import { FsUtil } from '../../utils/FsUtil';
import { ResultCode } from '../../worker/ResultCode';
import CopyCutConst from '../../workermanager/copycutmanager/CopyCutConst';
import type common from '@ohos.app.ability.common';
import type { BusinessError } from '@ohos.base';
import { FileUtil } from '../../fileoperate/FileUtil';
import { MyComputerConstant } from '../../const/MyComputerConstant';
import { ExternalStorageUtil } from '../../externel/ExternalStorageUtil';
import { PasteResult } from '../../workermanager/copycutmanager/PasteResult';
import { ERROR_CODE } from '../../const/ErrorCode';
import { ArrayUtil } from '../../utils/ArrayUtil';
import { StringUtil } from '../../utils/StringUtil';
import { StorageDeviceManager } from '../../externel/StorageDeviceManager';
import { Constant, DataSourceDeviceType, UUID_TYPE } from '../../const/Constant';
import type { FavoriteModel } from '../../model/FavoriteModel';
import { FileAccessUtil } from '../../fileoperate/FileAccessUtil';
import type { DiskInfo } from '../../externel/DiskInfo';
import fileExtensionInfo from '@ohos.file.fileExtensionInfo';
import { HiSysEventUtil } from '../../dfx/HiSysEventUtil';
import { HiSysEventName, InterfaceName, OperateResult } from '../../const/HiSysEventConst';
import { RenameUtil } from '../../fileoperate/RenameUtil';
import { FileAccessError } from '../../error/Error';
import { VirtualUri } from '../../const/FolderRecord';
import { FilePickerUtil } from '../../etsexport/utils/FilePickerUtil';
import lazy { PhotoAccessUtil } from '../../utils/PhotoAccessUtil';
import lazy { photoAccessHelper } from '../../../../../indexLazyLoadTs';
import { FilesQueryUtil } from '../../fileoperate/FilesQueryUtil';
import lazy { PhotoUtil } from '../../gallery/PhotoUtil';

const TAG = 'FileCopyUtil';
/**
 * 传输文件内容的缓存区大小
 */
const PROGRESS_COMPUTE_CONST = 100;

/**
 * 刷新间隔时间
 */
const INTERVAL_TIME: number = 300;
const BREAK_PASTE_CYCLE_THREAD: number = 1;

// 移动模式。若mode为0，移动位置存在同名文件时，强制移动覆盖。若mode为1，移动位置存在同名文件时，抛出异常。默认为0。
const MOVE_FILE_MODE = 1;
// 任务完成之前最大进度, 所有任务完成之后会上报100
const MAX_LIMITED_PROGRESS = 99;
// 完成时进度
const COMPLETE_PROGRESS = 100;

const PASTE_BUFFER = 4194304; // 4M
// 单次移动最大数量
const MOVE_MAX_NUM: number = 200;
// 分组移动最下数量
const MOVE_MIN_NUM: number = 4;
const MIN_GROUPS_COUNT: number = 4;

// 封装错误的文件信息
interface errFileParams {
  code: number,
  fileInfo: FileInfo
}

export class FileCopyUtil {
  /**
   * worker端口
   */
  public workerPort?: ThreadWorkerGlobalScope;
  /**
   * worker名称
   */
  public workerName: string = '';
  /**
   * 发起操作的消息类型，用于区分worker内的操作
   */
  public operateType: WorkerConst.OperateType = WorkerConst.OperateType.CANCEL;
  /**
   * 当前正在操作的文件名
   */
  public operatingFile: FileInfo = new FileInfo();
  /**
   * 存储设备uuid
   */
  public uuid: string = StorageUtil.LOCAL_STORAGE_DEVICE_UUID;
  /**
   * 文件总数量, 包括子文件和文件夹
   */
  public totalCount: number = 0;
  /**
   * 是否是外部：跨设备、跨盘
   */
  public isExternalOperate: boolean = false;
  /**
   * 任务的文件数量，用户层面选中的文件数量
   */
  public taskFileCount: number = 0;
  /**
   * 已完成数量
   */
  public completeCount: number = 0;
  /**
   * 目标文件夹uri
   */
  public destFolderUri: string = '';
  public screenShotUri: string | undefined;
  public screenRecorderUri: string | undefined;
  public destAlbum: photoAccessHelper.Album | undefined;
  /**
   * 原目录uri
   */
  public srcFolderUri?: string;
  /**
   * 操作结果，存储源文件uri与操作后的新uri（PC专用）
   */
  public pasteFilesRes: Array<PasteResult> = [];
  /**
   * 总大小(phone专用)
   */
  private totalSize: number = 0;
  // 图库专用，用于记录图片数量
  private imageCount: number = 0;
  // 图库专用，用于记录视频数量
  private videoCount: number = 0;
  /**
   * 进度大小：不回退(phone专用)，progressSize = completeSize + oneFileHasCompleteSize
   */
  private progressSize: number = 0;
  /**
   * 粘贴进度比例
   */
  public pasteProgressRate: number = 0;
  /**
   * 粘贴进度比例上次发送数据，减少同样比例，频繁发送
   */
  public lastSendPasteProgressRate: number = -1;
  /**
   * 定时器,用于刷新进度
   */
  public timer: number = 0;
  /**
   * 等待用户操作结果
   */
  public waitOperate: boolean = false;
  /**
   * 任务是否取消
   */
  public isCancel: boolean = false;
  /**
   * 冲突文件
   */
  public conflictFile: FileInfo = new FileInfo();
  /**
   * 异常码
   */
  public exceptionCode?: ResultCode.Exception;
  /**
   * 文件是否应用到全部
   */
  public isFileApplyAll: boolean = false;
  /**
   * 文件应用到全部选择
   */
  public fileApplyChoose: number = CopyCutConst.ChooseType.DEFAULT;
  /**
   * 文件夹是否应用到全部
   */
  public isFolderApplyAll: boolean = false;
  /**
   * 文件应用到全部选择
   */
  public folderApplyChoose: number = CopyCutConst.ChooseType.DEFAULT;
  /**
   * 路径异常是否应用到全部
   */
  public isPathApplyAll: boolean = false;
  /**
   * 路径异常应用到全部选择
   */
  public pathApplyChoose: number = CopyCutConst.ChooseType.DEFAULT;
  /**
   * 其他异常是否应用到全部
   */
  public isOtherErrorApplyAll: boolean = false;
  /**
   * 其他异常应用到全部选择
   */
  public otherErrorApplyChoose: number = CopyCutConst.ChooseType.DEFAULT;
  /**
   * 冲突类型
   */
  public conflictType: number = CopyCutConst.ConflictType.FILE_DEFAULT;
  /**
   * 冲突选择结果
   */
  public conflictChooseType: CopyCutConst.ChooseType = CopyCutConst.ChooseType.DEFAULT;
  /**
   * 文件夹重名冲突时，应用到全部时的选择结果
   */
  public conflictFolderChooseType: CopyCutConst.ChooseType = CopyCutConst.ChooseType.DEFAULT;
  /**
   * 文件重名冲突时，应用到全部时的选择结果
   */
  public conflictFileChooseType: CopyCutConst.ChooseType = CopyCutConst.ChooseType.DEFAULT;
  /**
   * 操作上下文对象
   */
  public context?: common.Context;
  /**
   * 本地根目录uri
   */
  public localRootUri: string = '';
  public isOperatingAcrossDisk: boolean = false;
  /**
   * 通知栏成功项数计数(手机独有）:只统计首层文件是否成功
   */
  public notifySuccessCount: number = 0;
  /**
   * 下载目录
   */
  public readonly DOWNLOAD = 'download';
  /**
   * documents目录
   */
  public readonly DOCUMENTS = 'documents';
  /**
   * 通知栏失败项数计数（手机独有）：统计所有失败项数
   */
  public notifyFailCount: number = 0;
  /**
   * 选择的文件数量是否是多个，用于展示石否应用到全部(手机独有）
   */
  public chooseFileMulti: boolean = false;
  /**
   * 选择的文件夹数量是否是多个，用于展示石否应用到全部(手机独有）
   */
  public chooseFolderMulti: boolean = false;
  /**
   * 当前挂载盘信息
   */
  public rootInfoArr: DiskInfo[] = [];
  /**
   * 冲突参数
   */
  public conflictParam?: CopyCutResultParam;
  /**
   * 收藏缓存
   */
  private favoriteCache?: FavoriteModel[];
  /**
   * 是否是本地app文件
   */
  public isLocalAppFile: boolean = false;
  /**
   * 是否显示进度条(pc专用)
   */
  public isShowProgressBar: boolean = false;
  /**
   * copy标志
   */
  public copySignal: fs.TaskSignal = new fs.TaskSignal();
  /**
   * 是否发生初始化异常
   */
  private isFileInitError: boolean = false;
  /**
   * 发生异常的数据
   */
  private errFiles: errFileParams[] = [];
  public destFolderIsGalleryAlbum: boolean = false; // 目标路径是否是图库相册

  public existDirNesting: boolean = false; // 是否存在嵌套文件夹，用于粘贴到根路径弹窗

  private toOperateFiles: FileInfo[] = [];

  /**
   * 处理消息
   * @param copyCutSendParam 发送参数
   * @returns
   */
  public async dealMessage(copyCutSendParam: CopyCutSendParam): Promise<void> {
    let msgCode = copyCutSendParam.msgCode;
    HiLog.info(TAG, `dealMessage msgCode: ${msgCode}`);
    switch (msgCode) {
      case CopyCutConst.SendMsgCode.START:
        // 开始任务
        await this.startTask(copyCutSendParam);
        break;
      case CopyCutConst.SendMsgCode.EXCEPTION_CONTINUE_TO_RUN:
      case CopyCutConst.SendMsgCode.CONFLICT:
        this.dealConflictChoose(copyCutSendParam);
        break;
      case CopyCutConst.SendMsgCode.CANCEL:
        this.cancelWorker();
        break;
      case CopyCutConst.SendMsgCode.QUERY_TASK_STATUS:
        this.queryStatus();
        break;
      case CopyCutConst.SendMsgCode.EXTERNAL_DISK_CHANGE:
        this.dealUsbChange();
        break;
      default:
        break;
    }
  }

  /**
   * 判断是否是图库中截图相册
   * @param albumUri
   * @returns
   */
  private async isScreenShotAlbum(albumUri: string): Promise<boolean> {
    if (StringUtil.isEmpty(this.screenShotUri)) {
      this.screenShotUri =
        await PhotoAccessUtil.getAlbumUriByBundleName(this.context as common.Context, Constant.SCREEN_SHOT_BUNDLE_NAME);
    }

    return albumUri === this.screenShotUri;
  }

  /**
   * 判断是否是图库中屏幕录制相册
   * @param albumUri
   * @returns
   */
  private async isScreenRecorderAlbum(albumUri: string): Promise<boolean> {
    if (StringUtil.isEmpty(this.screenRecorderUri)) {
      this.screenRecorderUri = await PhotoAccessUtil.getAlbumUriByBundleName(this.context as common.Context,
        Constant.SCREEN_RECORDER_BUNDLE_NAME);
    }

    return albumUri === this.screenRecorderUri;
  }

  private handleFileNotExistError(errCode: number, fileInfo: FileInfo): void {
    if (errCode !== ERROR_CODE.FILE_ACCESS.FILE_NOT_EXIST) {
      HiLog.info(TAG, `file exist, errCode: ${errCode}`);
      return;
    }
    // 文件或文件夹不存在，弹窗使用单文件
    this.totalCount = 1;
    // 文件或文件夹不存在，表示不存在文件或文件夹多选，弹窗不显示“应用到全部”
    this.chooseFolderMulti = false;
    this.chooseFileMulti = false;

    this.operatingFile = fileInfo;

    // 图库相册初始化失败，无法获取相册名
    // 此处将相册名设置为空字符串，弹窗提示语不显示具体文件名
    if (fileInfo.uri.startsWith(VirtualUri.GALLERY_URI)) {
      this.operatingFile.fileName = '';
    } else if (fileInfo.uri.startsWith((VirtualUri.GALLERY_PHOTO_URI))) {
      let lastSlashIndex = fileInfo.uri.lastIndexOf('/');
      let oldFileName: string = FileUtil.decodeURIComponent(fileInfo.uri).substring(lastSlashIndex + 1);
      this.operatingFile.fileName = oldFileName;
    }
  }

  /**
   * 开始执行复制粘贴任务
   * @param copyCutSendParam
   */
  public async startTask(copyCutSendParam: CopyCutSendParam): Promise<void> {
    try {
      HiLog.info(TAG, 'startTask');
      if (!await this.initAndCheckData(copyCutSendParam)) {
        return;
      }
      HiLog.info(TAG, 'startTask file length: ' + this.toOperateFiles.length);
      if (this.toOperateFiles.length === 0) {
        HiLog.warn(TAG, 'toOperateFiles is empty');
        return;
      }
      let isInitSuccess: boolean = await this.copyFileInit(copyCutSendParam) && this.errFiles.length === 0;
      if (isInitSuccess) {
        // 显示进度条开启定时刷新
        this.refreshProgress();
        this.startTimer();
        await this.runTask(copyCutSendParam);
      } else {
        if (this.errFiles.length > 0) {
          this.handleFileNotExistError(this.errFiles[0].code, this.errFiles[0].fileInfo);
          await this.onErrorCatch(this.errFiles[0].code, this.errFiles[0].fileInfo);
        }
        HiLog.warn(TAG, 'task end.');
        this.taskEnd();
        return;
      }
    } catch (err) {
      HiLog.error(TAG, 'startTask error: ' + JSON.stringify(err));
    }

    if (this.pasteProgressRate === MAX_LIMITED_PROGRESS) {
      this.pasteProgressRate = COMPLETE_PROGRESS;
    }
    this.refreshProgress();
    this.progressSize = 0;
    this.taskEnd();
  }

  public async initFileListToGallery(toOperateFiles: FileInfo[],
    copyCutSendParam: CopyCutSendParam): Promise<ResultCode.Exception> {
    let fileList: FileInfo[] = []; // 用于去除toOperateFiles里面，无法初始化的文件
    HiLog.warn(TAG, 'initFileListToGallery start.');
    let res: ResultCode.Exception = ResultCode.Exception.EXCEPTION_OK;
    await PhotoAccessUtil.initPhotoSupportedFormats(this.context as common.Context);
    for (let i = 0; i < toOperateFiles.length; i++) {
      if (this.isCancel) {
        HiLog.warn(TAG, 'initFileListToGallery, worker cancel');
        return ResultCode.Exception.EXCEPTION_TASK_CANCEL;
      }
      let file = toOperateFiles[i];
      if (file.uri.startsWith(VirtualUri.GALLERY_URI)) {
        HiLog.warn(TAG, 'folder type is album, get photo start.');
        if (!await this.setPhotoAlbumSizeAndNumInfo(file)) {
          return ResultCode.Exception.EXCEPTION_FILE_INIT_FAIL;
        }
        fileList.push(file);
        this.totalCount++;
        continue;
      }

      // 粘贴的文件是图库文件
      if (file.uri.startsWith(VirtualUri.GALLERY_PHOTO_URI)) {
        // 往图库根路径粘贴文件中，有文件，直接弹异常退出提示
        if (this.destFolderUri === VirtualUri.GALLERY) {
          HiLog.warnPrivate(TAG, 'Files cannot be pasted in the root path of the gallery.', `file uri: ${file.uri}`);
          return ResultCode.Exception.EXCEPTION_PASTE_CONTENT_INCLUDE_FILE;
        }
        // 判断文件FileInfo是否需要进行初始化
        if (file.albumType === -1) {
          let photoAssetInfo = await PhotoAccessUtil.getPhotoAssetInfoByUri(this.context as common.Context, file.uri);
          if (!photoAssetInfo) {
            this.errFiles.push({ code: OperateResult.FILE_NOT_EXIST, fileInfo: file });
            this.isFileInitError = true;
            return ResultCode.Exception.EXCEPTION_FILE_INIT_FAIL;
          }
          file = photoAssetInfo;
        }
        // 图库文件被重命名，需进行弹窗提示，设置为初始化失败
        if (!FileUtil.decodeURIComponent(file.uri).endsWith(file.fileName)) {
          HiLog.warn(TAG, 'file has been renamed');
          this.errFiles.push({ code: OperateResult.FILE_NOT_EXIST, fileInfo: file });
          this.isFileInitError = true;
          return ResultCode.Exception.EXCEPTION_FILE_INIT_FAIL;
        }

        if (!await this.isMediaSupportType(file.fileName)) {
          continue;
        }
        this.totalCount++;
        this.totalSize += file.size;
        fileList.push(file);
        continue;
      }

      let initRes: boolean = this.initUriData(file, true);
      if (!initRes) {
        HiLog.warn(TAG, 'get file info fail.');
        return ResultCode.Exception.EXCEPTION_FILE_INIT_FAIL;
      }
      const initFileRes: ResultCode.Exception = await this.initFileToGallery(file, fileList);
      if (initFileRes === ResultCode.Exception.EXCEPTION_PASTE_CONTENT_INCLUDE_FILE ||
        initFileRes === ResultCode.Exception.EXCEPTION_GALLERY_FILE_NAME_INVALID) {
        return initFileRes;
      }
      // res 记录错误码
      if (initFileRes === ResultCode.Exception.EXCEPTION_EXIST_UNSUPPORTED_TYPE) {
        res = initFileRes;
      }
    }

    HiLog.warn(TAG, `image count: ${this.imageCount}, video count: ${this.videoCount}`);
    this.toOperateFiles = fileList;
    this.chooseFileMulti = false; // 同名弹窗时，用于文件是否显示应用到全部
    this.chooseFolderMulti = this.totalCount > 1; // 同名弹窗时，用于文件夹是否显示应用到全部
    this.isExternalOperate = copyCutSendParam.isExternalOperate;
    return res;
  }

  // 初始化非图库文件
  public async initFileToGallery(file: FileInfo, fileList: FileInfo[]): Promise<ResultCode.Exception> {
    let res: ResultCode.Exception = ResultCode.Exception.EXCEPTION_OK;
    if (file.isFolder) {
      if (RenameUtil.checkGallerySpecialChar(file.fileName)) {
        return ResultCode.Exception.EXCEPTION_GALLERY_FILE_NAME_INVALID;
      }
      fileList.push(file);
      this.totalCount++;
      const fileNameList = FileUtil.getSubFileListByUri(file.uri, true);
      if (fileNameList.length === 0) { // 空文件夹要做计数
        return res;
      }
      HiLog.info(TAG, `file name list length: ${fileNameList.length}`);
      for (let i = 0; i < fileNameList.length; i++) {
        if (this.isCancel) {
          HiLog.warn(TAG, 'get folder Sub fileInfo  cancel');
          return ResultCode.Exception.EXCEPTION_TASK_CANCEL;
        }
        const fileNameValue: string = fileNameList[i];
        if (!this.existDirNesting && fileNameValue.indexOf('/', 1) !== -1) {
          HiLog.warn(TAG, 'Directory nesting exists.');
          this.existDirNesting = true;
        }
        if (!await this.isMediaSupportType(fileNameValue)) {
          // 存在文管不支持类型，做好弹窗准备
          res = ResultCode.Exception.EXCEPTION_EXIST_UNSUPPORTED_TYPE;
          continue;
        }
        const fileUri = file.uri + fileNameValue;
        const fileData = FileInfo.fromFileUriByOpen(fileUri);
        this.totalSize += fileData.size;
        this.totalCount++;
      }
    } else {
      // 往图库根路径粘贴文件中，有文件，直接弹异常退出提示
      if (this.destFolderUri === VirtualUri.GALLERY) {
        HiLog.warn(TAG, 'Files cannot be pasted in the root path of the gallery.');
        return ResultCode.Exception.EXCEPTION_PASTE_CONTENT_INCLUDE_FILE;
      }
      // 文管支持类型，才做大小计数
      if (!await this.isMediaSupportType(file.fileName)) {
        return ResultCode.Exception.EXCEPTION_EXIST_UNSUPPORTED_TYPE;
      }
      this.totalSize += file.size;
      this.totalCount++;
      fileList.push(file);
    }
    return res;
  }

  async initFileListInfo(toOperateFiles: FileInfo[], copyCutSendParam: CopyCutSendParam): Promise<void> {
    let isInitFileInfoByOpen: boolean = true;
    let fileList: FileInfo[] = [];
    HiLog.info(TAG, `isInitFileInfoByOpen: ${isInitFileInfoByOpen}`);
    for (let i = 0; i < toOperateFiles.length; i++) {
      if (this.isCancel) {
        HiLog.warn(TAG, 'initFileListInfo cancel');
        return;
      }
      let file = toOperateFiles[i];
      if (file?.uri.startsWith(VirtualUri.GALLERY_URI)) {
        HiLog.warn(TAG, 'folder type is album, get photo start.');
        if (!await this.setPhotoAlbumSizeAndNumInfo(file)) {
          return;
        }
        fileList.push(file);
        this.totalCount++;
        continue;
      } else if (file?.uri.startsWith(VirtualUri.GALLERY_PHOTO_URI)) {
        isInitFileInfoByOpen = false; // 图库文件使用 fs.statSync 判断文件是否存在
        // 文件没有相册来源信息
        if (file.albumType === -1) {
          let photoAssetInfo = await PhotoAccessUtil.getPhotoAssetInfoByUri(this.context as common.Context, file.uri);
          if (!photoAssetInfo) {
            this.errFiles.push({ code: OperateResult.FILE_NOT_EXIST, fileInfo: file });
            this.isFileInitError = true;
            return;
          }
          file = photoAssetInfo;
        }

        // 图库文件被重命名，需进行弹窗提示，设置为初始化失败
        if (!FileUtil.decodeURIForFileManager(file.uri).endsWith(file.fileName)) {
          HiLog.warn(TAG, 'file has been renamed');
          this.errFiles.push({ code: OperateResult.FILE_NOT_EXIST, fileInfo: file });
          this.isFileInitError = true;
          return;
        }

        fileList.push(file);
        this.totalSize += file.size;
        this.totalCount++;
        continue;
      }

      let res: boolean = this.initUriData(file, isInitFileInfoByOpen);
      if (res) {
        await this.initFileList(file, fileList);
      } else {
        HiLog.error(TAG, `Init file info by uri failed`);
        return;
      }
    }
    this.chooseFileMulti = this.totalCount > 1;
    this.chooseFolderMulti = this.totalCount > 1;
    this.isExternalOperate = copyCutSendParam.isExternalOperate;
    this.toOperateFiles = fileList;
  }

  // 初始化文件列表
  async initFileList(file: FileInfo, fileList: FileInfo[]) {
    fileList.push(file);
    if (file.isFolder) {
      let folderSize: number = FilesQueryUtil.getFolderSize(file.uri);
      this.totalSize += folderSize;
      this.totalCount += await FileUtil.getFolderSubFileCount(file.uri, true, true);
      this.totalCount++;
    } else {
      this.totalSize += file.size;
      this.totalCount++;
    }
  }

  /**
   * 初始化文件信息
   */
  initUriData(data: FileInfo, isInitFileInfoByOpen: boolean): boolean {
    if (!this.checkNeedToInitData(data)) {
      return true;
    }
    if (isInitFileInfoByOpen) {
      return this.initFileInfoByOpen(data);
    } else {
      return this.initFileInfoByPath(data);
    }
  }

  /**
   * 判断是否需要通过fs接口获取其他文件信息，如大小、相对路路径等
   * @param data 部分文件信息
   * @returns 是否需要获取其他信息
   */
  checkNeedToInitData(data: FileInfo): boolean {
    // 检查是否需要重新初始化数据,根据线程需要的参数决定
    if (!data) {
      return false;
    }
    return data.size === Constant.FILE_SIZE_UNKNOWN || StringUtil.isEmpty(data.relativePath);
  }

  fsCloseFile(file: fs.File, needClose: boolean = true): void {
    if ((!needClose) || ObjectUtil.isNullOrUndefined(file)) {
      return;
    }
    FsUtil.closeSync(file);
  }

  async initDiskInfo(): Promise<void> {
    let rootInfoArrTmp: DiskInfo[] = [];
    if (FileAccessUtil.getStorageRootInfo().size === 0) {
      await FileAccessUtil.refreshStorageRootInfo();
    }

    try {
      for (let rootInfo of FileAccessUtil.getStorageRootInfo().values()) {
        if (this.isCancel) {
          return;
        }
        if (ObjectUtil.isNullOrUndefined(rootInfo)) {
          break;
        }
        let rootDiskInfo = await FileUtil.getRootDiskInfo(rootInfo);
        if (rootDiskInfo) {
          rootInfoArrTmp.push(rootDiskInfo);
        }
      }
      this.rootInfoArr = rootInfoArrTmp;
    } catch (error) {
      HiLog.error(TAG, 'initDiskInfo error: ' + JSON.stringify(error));
    }
  }

  async doDrag(copyCutSendParam: CopyCutSendParam): Promise<void> {
    await this.initDiskInfo();
    this.uuid = copyCutSendParam.uuid;
    // 拖拽流程跨介质复制，同介质移动
    let toOperateFiles = this.toOperateFiles;
    let destFolderUri = copyCutSendParam.destFolderUri;
    for (let i = 0; i < toOperateFiles.length; i++) {
      let file = toOperateFiles[i];
      let list = [file];
      // 识别拖拽走的流程
      if (this.checkDragIsCopy(file, copyCutSendParam)) {
        this.operateType = WorkerConst.OperateType.COPY_FILE;
        await this.doCopy(list, destFolderUri, copyCutSendParam.isFromRecent);
      } else {
        this.operateType = WorkerConst.OperateType.CUT_FILE;
        await this.doMove(list, destFolderUri);
      }
    }
  }

  /**
   * 手机检查拖拽走复制还是移动
   * @param file 文件
   * @param copyCutSendParam 发送参数
   * @returns 拖拽是否走复制流程
   */
  checkDragIsCopy(file: FileInfo, copyCutSendParam: CopyCutSendParam): boolean {
    // 跨设备走复制流程
    if (copyCutSendParam.isExternalOperate) {
      return true;
    }
    // 如果目标目录和源目录不是同一个介质走复制流程
    if (this.checkIsSameDisk(file)) {
      return false;
    }
    // 如果是系统目录走复制
    if (this.checkIsSystemFolder(file)) {
      return true;
    }
    return true;
  }

  checkIsSameDisk(file: FileInfo): boolean {
    if (ArrayUtil.isEmpty(this.rootInfoArr)) {
      HiLog.info(TAG, 'checkIsSameDisk rootInfo is null');
      return false;
    }
    for (let i = 0; i < this.rootInfoArr.length; i++) {
      let disk = this.rootInfoArr[i];
      if (file.uri.startsWith(disk.uri)) {
        HiLog.infoPrivate(TAG, 'disk uuid ', disk.uuid + ' ' + this.uuid);
        if (StringUtil.isEmpty(this.uuid) || (this.uuid === 'LOCAL')) {
          return disk.deviceType === fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK;
        }
        return disk.uuid === this.uuid;
      }
    }
    HiLog.info(TAG, 'checkIsSameDisk end');
    return false;
  }

  checkIsSystemFolder(file: FileInfo): boolean {
    if ((this.DOWNLOAD !== file.fileName.toLowerCase()) && (this.DOCUMENTS !== file.fileName.toLowerCase())) {
      return false;
    }
    let index = file.uri.lastIndexOf('/');
    if (index !== -1) {
      let parentUri = file.uri.slice(0, index);
      return parentUri === this.localRootUri;
    }
    return false;
  }

  /**
   * @param 粘贴到图库下，文件夹内容展开弹窗提示
   */
  public async pasteToGalleryException(toOperateFiles: FileInfo[], destFolderUri: string): Promise<void> {
    // 粘贴到根路径，此时已确定复制文件中无文件，仅文件夹，若有文件，会在前面异常弹窗，有嵌套的弹窗
    if (destFolderUri === VirtualUri.GALLERY) {
      if (!this.existDirNesting) {
        return;
      }
      // copy到根路径，如果仅一个文件夹且存在嵌套，进行异常弹窗
      if (toOperateFiles.length === 1) {
        this.operatingFile = toOperateFiles[0];
        this.operatingFile.fileName = toOperateFiles[0].fileName;
        HiLog.warn(TAG, 'Path nesting exists.');
        await this.dealException(ResultCode.Exception.EXCEPTION_GALLERY_ROOT_PASTER_FOLDER);
      } else {
        HiLog.warn(TAG, 'Root Path Paste Folder.');
        // 弹窗提示用户粘贴文件将保存在对应相册
        await this.dealException(ResultCode.Exception.EXCEPTION_GALLERY_ROOT_PASTER_FOLDERS);
      }
    } else { // 往相册下粘贴文件中是否包含文件夹
      let hasFolderInPasteFiles: boolean = (toOperateFiles.find(item => item.isFolder) !== undefined);
      // 弹窗提示用户粘贴文件将保存再对应相册
      if (hasFolderInPasteFiles) {
        HiLog.warn(TAG, 'Paste folder under album.');
        await this.dealException(ResultCode.Exception.EXCEPTION_GALLERY_ALBUM_PASTER_FOLDER);
      }
    }
  }

  /**
   * @param 粘贴文件到图库
   */
  public async pasteToGallery(toOperateFiles: FileInfo[], copyCutSendParam: CopyCutSendParam): Promise<void> {
    if (toOperateFiles.length === 0) {
      HiLog.warn(TAG, 'copy src file is null.')
      return;
    }
    let tempOperateType: WorkerConst.OperateType = this.operateType;
    if (this.operateType == WorkerConst.OperateType.DRAG_FILE) {
      HiLog.info(TAG, 'is drag change cut.');
      this.operateType = WorkerConst.OperateType.CUT_FILE;
    }

    let destFolderUri: string = copyCutSendParam.destFolderUri;
    await this.pasteToGalleryException(toOperateFiles, destFolderUri);
    let albumInfo: photoAccessHelper.Album | undefined = undefined;
    for (let i = 0; i < toOperateFiles.length; i++) {
      // 如果操作是拖拽，判断是否是能够移动的路径，如果不能移动，使用copy
      if (tempOperateType === WorkerConst.OperateType.DRAG_FILE) {
        let isCanMove = this.checkGalleryCanMove(toOperateFiles[i], copyCutSendParam);
        if (!isCanMove) {
          this.operateType = WorkerConst.OperateType.COPY_FILE;
        } else {
          this.operateType = WorkerConst.OperateType.CUT_FILE;
        }
      }

      if (this.isCancel) {
        HiLog.warn(TAG, 'pasteToGallery cancel.');
        return;
      }
      this.operatingFile = toOperateFiles[i];
      this.operatingFile.fileName = toOperateFiles[i].fileName;

      // 获取粘贴到根路径相册
      if (destFolderUri === VirtualUri.GALLERY) {
        // 相册move到根目录，跳过
        if (this.operateType === WorkerConst.OperateType.CUT_FILE &&
        toOperateFiles[i].uri.startsWith(VirtualUri.GALLERY_URI)) {
          continue;
        }
        HiLog.info(TAG, 'destFolder is gallery.');
        // 获取是否有和源文件夹路径同名相册
        albumInfo = await PhotoAccessUtil.getAlbumByName(this.context as common.Context, toOperateFiles[i].fileName);
        if (albumInfo) {
          HiLog.warnPrivate(TAG, 'An album with the same name exists.', `abulm name: ${albumInfo.albumName}`)
          await this.handleGalleryDupFolder(toOperateFiles[i], albumInfo);
          continue;
        } else {
          // 无同名新建相册
          albumInfo = await PhotoAccessUtil.createAlbum(this.context as common.Context, toOperateFiles[i].fileName);
          if (!albumInfo) {
            HiLog.warn(TAG, 'create album fail.');
            return;
          }
        }
      } else { // 非根路径，获取相册信息
        albumInfo = await PhotoAccessUtil.getAlbumByUri(this.context as common.Context, destFolderUri);
        if (!albumInfo) {
          // todo 目的路径找不到弹窗
          HiLog.warn(TAG, 'album is null.');
          return;
        }
      }
      try {
        await this.pasteToGalleryFolder(toOperateFiles[i], albumInfo);
      } catch (err) {
        HiLog.error(TAG, 'copy Folder to album err：' + JSON.stringify(err));
        if (err.code === ERROR_CODE.FILE_ACCESS.NO_SPACE_LEFT_ON_DEVICE) {
          await this.onErrorCatch(err.code, toOperateFiles[i]);
          return;
        }
      }
    }
  }

  /**
   * 获取是否是当前路径支持类型
   */
  public async isSupportPaste(fileName: string, destUri: string): Promise<boolean> {
    // 0是否是图片格式，1是否是视频格式
    let supportFormats: boolean[] = [false, false];
    supportFormats = await PhotoAccessUtil.getPhotoSupportedFormats(this.context as common.Context, fileName);

    if (this.screenShotUri === destUri) {
      return supportFormats[0];
    } else if (this.screenRecorderUri === destUri) {
      return supportFormats[1];
    }
    return supportFormats[0] || supportFormats[1];
  }

  public async pasteFolderToGallery(srcFileInfo: FileInfo, destAlbumInfo: photoAccessHelper.Album): Promise<void> {
    HiLog.info(TAG, 'paste folder to gallery start.');
    // 粘贴相册
    if (srcFileInfo.uri.startsWith(VirtualUri.GALLERY_URI)) {
      await this.pasteAlbumToGalleryRootPath(srcFileInfo, destAlbumInfo);
    } else { // 非图库文件
      let fileNameList: string[] = FileUtil.getSubFileListByUri(srcFileInfo.uri, true);
      HiLog.info(TAG, `sub file list length: ${fileNameList.length}`);
      let pasteSuccess: boolean = true;
      let isDelete: boolean = true; // 是否全部是图片视频文件
      for (let i = 0; i < fileNameList.length; i++) {
        if (this.isCancel) {
          HiLog.warn(TAG, 'pasteFolderToGallery cancel.');
          return;
        }
        if (!await this.isSupportPaste(fileNameList[i], destAlbumInfo.albumUri)) {
          HiLog.infoPrivate(TAG, 'The type is not supported,', `fileUri: ${fileNameList[i]}`);
          isDelete = false
          continue;
        }
        let fileName = fileNameList[i];
        if (fileNameList[0].indexOf('/') === 0) {
          fileName = fileName.slice(1);
        }
        let fileUri: string = ThreadCommonUtil.getSubFileUri(srcFileInfo.uri, fileName);
        let pasteRes: boolean = await this.createAndPasteToMediaFile(fileUri, fileNameList[i], destAlbumInfo.albumUri);
        if (!pasteRes) {
          pasteSuccess = false;
        } else if (this.operateType === WorkerConst.OperateType.CUT_FILE) {
          HiLog.warnPrivate(TAG, 'pasteFolderToGallery success, delete file.', `file uri: ${fileUri}`);
          const path = FileUtil.getPathFromUri(fileUri);
          FsUtil.unlinkSync(path);
        }
      }
      // 全部粘贴成功后，进行文件夹删除
      if (pasteSuccess && isDelete && this.operateType === WorkerConst.OperateType.CUT_FILE) {
        HiLog.warn(TAG, 'delete src folder.');
        FsUtil.rmdirSync(srcFileInfo.relativePath);
      }
    }
  }

  public async pasteFileToGallery(srcFileInfo: FileInfo, destAlbumInfo: photoAccessHelper.Album): Promise<void> {
    HiLog.info(TAG, 'paste file to gallery start.');
    if (!await this.isSupportPaste(srcFileInfo.fileName, destAlbumInfo.albumUri)) {
      HiLog.warnPrivate(TAG, 'Unsupported Type.', `dest path name : ${destAlbumInfo.albumName}`);
      return;
    }
    // 图库自身文件
    if (srcFileInfo.uri.startsWith(VirtualUri.GALLERY_PHOTO_URI)) {
      // 调用媒体库接口，获取源文件并使用媒体库接口move
      let photoAsset: photoAccessHelper.PhotoAsset | undefined =
        await PhotoAccessUtil.getPhotoAssetByUri(this.context as common.Context, srcFileInfo.uri);
      if (!photoAsset) {
        HiLog.warn(TAG, 'get src file asset fail.')
        return;
      }
      // 移动图库文件，直接使用媒体库move接口
      if (this.operateType === WorkerConst.OperateType.CUT_FILE) {
        await this.movePhotoAssetToAlbum(srcFileInfo, destAlbumInfo);
      } else if (this.operateType === WorkerConst.OperateType.COPY_FILE) {
        await this.copyPhotoToGallery(photoAsset, destAlbumInfo);
      }
    } else { // 文管文件
      let res: boolean = await this.createAndPasteToMediaFile(srcFileInfo.uri,
        srcFileInfo.fileName, destAlbumInfo.albumUri);
      if (res && this.operateType === WorkerConst.OperateType.CUT_FILE) {
        HiLog.warnPrivate(TAG, 'paste success, delete file.', `${srcFileInfo.uri}`);
        const path = FileUtil.getPathFromUri(srcFileInfo.uri);
        FsUtil.unlinkSync(path);
      }
    }
  }

  /**
   * 执行粘贴
   * @param copyCutSendParam 发送参数
   * @returns
   */
  public async doCopy(toOperateFiles: FileInfo[], destFolderUri: string, isFromRecent: boolean): Promise<void> {
    let srcFile: FileInfo = new FileInfo();
    for (let index: number = 0; index < toOperateFiles.length; index++) {
      try {
        if (this.isCancel) {
          HiLog.info(TAG, 'doCopy is cancel');
          return;
        }
        srcFile = toOperateFiles[index];
        let srcFolderUri: string = ThreadCommonUtil.getParentUri(srcFile.uri);
        HiLog.infoPrivate(TAG, 'srcFolderUri: ', srcFolderUri);
        this.operatingFile = srcFile;
        // 特殊场景：复制同名子文件夹到同名父文件夹所在路径，此操作被禁止
        let isOperateDupFolderFromChildToParent: boolean =
          ThreadCommonUtil.isOperateDupFolderFromChildToParent(srcFile, destFolderUri);
        if (isOperateDupFolderFromChildToParent) {
          HiLog.warn(TAG, 'copy dup folder from child to parent');
          await this.dealError(ResultCode.Error.OPERATE_DUP_FOLDER_FROM_CHILD_TO_PARENT);
          await this.dealPasteFileAfterChoose();
          return;
        }
        // 被粘贴文件与固定目录冲突
        let isDupFixedFolderConflict: boolean =
          (!srcFile.isFolder && destFolderUri === VirtualUri.MY_PC &&
          MyComputerConstant.MY_COMPUTER_NAME.includes(srcFile.fileName.toLowerCase())) || (
            destFolderUri === VirtualUri.MY_PHONE &&
            Constant.PHONE_SYSTEM_HIDE_FOLDER_NAME_LOWER_CASE.includes(srcFile.fileName.toLowerCase()));
        if (isDupFixedFolderConflict) {
          HiLog.warn(TAG, 'conflict with Fixed Folder');
          await this.dealError(ResultCode.Error.UNKNOWN_ERROR);
          await this.dealPasteFileAfterChoose();
          return;
        }
        let newUri: string = await this.copyFileOrFolder(srcFile, srcFolderUri, destFolderUri, isFromRecent);
        if (newUri) {
          this.pasteFilesRes.push(new PasteResult(srcFile.uri, newUri));
          this.countNotifySuccessCount();
          HiLog.infoPrivate(TAG, 'create file done: ', newUri);
        }
      } catch (err) {
        HiLog.error(TAG, 'doCopy err：' + JSON.stringify(err));
        let uri = await this.onErrorCatch(err.code, srcFile);
        this.countNotifySuccessCount(!StringUtil.isEmpty(uri));
        if (err.code === ERROR_CODE.FILE_ACCESS.PERMISSION_DENIED ||
          err.code === ERROR_CODE.FILE_ACCESS.NO_SPACE_LEFT_ON_DEVICE) {
          return;
        }
      }
    }
  }

  countNotifySuccessCount(isCount: boolean = true): void {
    if (!isCount) {
      return;
    }
    this.notifySuccessCount++;
  }

  /**
   * 判断是否直接创建副本
   * @param srcPath 源目录uri
   * @param destPath
   * @param pasteSrcIsRecent
   * @returns
   */
  public isCreateDup(srcFileInfo: FileInfo, srcFolderUri: string, destFolderUri: string,
    pasteSrcIsRecent: boolean): boolean {
    if ((destFolderUri === this.localRootUri) &&
    MyComputerConstant.MY_COMPUTER_NAME.includes(srcFileInfo.fileName.toLowerCase())) {
      HiLog.info(TAG, 'create duplicate fixed folder');
      return true;
    }
    // 同路径且非跨设备创建副本
    if ((srcFolderUri === destFolderUri) && (!srcFileInfo.uri.includes('?network'))) {
      return true;
    }
    // 来自浏览器的文件直接生成副本
    if (srcFileInfo.uri.startsWith(Constant.BROWSER_URI_HEAD)) {
      return true;
    }
    return pasteSrcIsRecent;
  }

  /**
   * 创建副本
   * @param srcFile 源文件
   * @param destFolderUri 目标文件夹uri
   * @returns 副本uri
   */
  public async createDup(srcFile: FileInfo, destFolderUri: string): Promise<string> {
    HiLog.info(TAG, 'create duplicate file');
    let newUri = '';
    let tryCreateDupAgain: boolean = false;
    try {
      if (srcFile.isFolder) {
        let dupFileResult = this.renameFile(srcFile.fileName, destFolderUri, true);
        newUri = await this.createFolderAndCopyContent(dupFileResult[0], srcFile, destFolderUri);
      } else {
        let dupFileResult = this.renameFile(srcFile.fileName, destFolderUri, false);
        newUri = await this.createFileAndCopyContent(dupFileResult[0], srcFile, destFolderUri);
      }
    } catch (err) {
      HiLog.warn(TAG, `create dup err:${JSON.stringify(err)}`);
      if (err.code === ERROR_CODE.FILE_ACCESS.FILE_EXISTS) {
        tryCreateDupAgain = true;
      } else {
        throw err as Error;
      }
    } finally {
      if (tryCreateDupAgain) {
        HiLog.info(TAG, 'try to create dup again');
        newUri = await this.createDup(srcFile, destFolderUri);
      }
    }
    return newUri;
  }

  renameFile(srcFileName: string, destFolderUri: string, isFolder: boolean): string[] {
    return ThreadCommonUtil.getDupFileName(srcFileName, destFolderUri, isFolder);
  }

  /**
   * 进行文件粘贴操作
   * @param srcFileName 源文件名
   * @param srcFile 源文件uri
   * @param destFolderUri 目标文件uri
   * @returns 新文件uri
   * @throws FileAccessError(ResultCode.Error.FILE_NAME_INVALID) 文件名非法
   */
  public async createFileAndCopyContent(srcFileName: string, srcFile: FileInfo,
    destFolderUri: string): Promise<string> {
    let newFileUri: string = '';
    this.operatingFile = srcFile;
    this.operatingFile.fileName = srcFileName;
    try {
      if (srcFile.isGallery) {
        HiLog.infoPrivate(TAG, 'createFileAndCopyContent isGallery ', srcFile.uri);
        const isSuccess = await FilePickerUtil.grantPhonePermissionUri(srcFile.uri, Constant.FILE_MANAGER_BUNDLE_NAME);
        if (!isSuccess) {
          HiLog.warn(TAG, 'PhonePermissionUri failed.');
        }
      }
      let destFileUri: string = destFolderUri + '/' +
      FileUtil.encodeURIForFileManager(RenameUtil.getEscapedFileName(srcFileName));
      let res: boolean = false;
      if (srcFile.uri?.startsWith(VirtualUri.GALLERY_PHOTO_URI)) {
        let photoAsset = await PhotoAccessUtil.getPhotoAssetByUri(this.context as common.Context, srcFile.uri);
        if (photoAsset) {
          res = await this.pastePhotoFileToLocal(photoAsset, destFileUri);
        }
      } else if (ExternalStorageUtil.isExternalStorageUri(destFileUri)) {
        res = await this.pasteFileByBuffer(srcFile.uri, destFileUri);
      } else {
        res = await this.copyFileContent(srcFile.uri, destFileUri);
      }
      if (res) {
        newFileUri = destFolderUri + '/' + FileUtil.encodeURIForFileManager(srcFileName);
        HiLog.info(TAG, 'createFileAndCopyContent success');
      }
    } catch (err) {
      HiLog.error(TAG, 'createFileAndCopyContent err：' + JSON.stringify(err));
      if (err.code === ERROR_CODE.FILE_ACCESS.PERMISSION_DENIED) {
        return '';
      }
      if (err.code !== ERROR_CODE.FILE_ACCESS.TRY_AGAIN) {
        throw err as Error;
      }
    }
    return newFileUri;
  }

  /*
   * 复制文件内容
   * srcFileUri：源文件uri
   * destFileUri：目标文件uri
   * */
  public async copyFileContent(srcFileUri: string, destFileUri: string): Promise<boolean> {
    if ((!srcFileUri) || (!destFileUri)) {
      HiLog.warn(TAG, 'copyFileContent, params are err');
      return false;
    }
    let needDelete: boolean = false;
    try {
      HiLog.infoPrivate(TAG, `copyFileContent copy file`, `srcFileUri : ${srcFileUri}, destFileUri : ${destFileUri}`);
      let lastCompletedSize = 0;

      // 取消回调
      this.copySignal.onCancel();

      // 进度监听回调
      let progressListener: fs.ProgressListener = async (progress: fs.Progress) => {
        if (this.isCancel) {
          HiLog.info('copyFileContent', 'cancel copy');
          this.copySignal.cancel(); // 取消拷贝
        } else {
          HiLog.info(TAG, `copyFileContent progressSize: ${progress.processedSize}`);
          // 空文件场景
          if (progress.totalSize === 0) {
            return;
          }
          // 非空文件场景
          await this.computeProgress(progress.processedSize - lastCompletedSize);
          lastCompletedSize = progress.processedSize;
        }
      };

      // 注册取消回调和进度监听回调
      let copyOption: fs.CopyOptions = {
        'progressListener': progressListener,
        'copySignal': this.copySignal
      };

      await fs.copy(srcFileUri, destFileUri, copyOption);

      if (this.operatingFile.size === 0) {
        await this.computeProgress(1);
      }
      HiLog.info(TAG, 'copyFileContent success');
    } catch (err) {
      HiLog.error(TAG, 'copyFileContent err = ' + JSON.stringify(err));
      HiSysEventUtil.reportFailureEvent(HiSysEventName.FILE_OPERATE_FAIL, InterfaceName.COPY_FILE_CONTENT_BY_FD,
        (err as BusinessError).code);
      needDelete = true;
      throw err as Error;
    } finally {
      if (needDelete) {
        HiLog.info(TAG, 'needDelete');
        FsUtil.forceDelete(destFileUri);
      } else {
        this.syncFile(destFileUri);
      }
    }
    return !needDelete;
  }

  async dealUsbChange(): Promise<void> {
    HiLog.info(TAG, 'dealUsbChange');
    if (StringUtil.isEmpty(this.uuid)) {
      return;
    }
    await this.initDiskInfo();
    for (let i = 0; i < this.rootInfoArr.length; i++) {
      let rootInfo = this.rootInfoArr[i];
      if (rootInfo.uuid && (this.uuid === rootInfo.uuid)) {
        return;
      }
    }
    this.cancelWorker();
  }

  /**
   * 取消worker
   */
  public cancelWorker(): void {
    HiLog.info(TAG, 'cancel worker');
    this.isCancel = true;
    this.copySignal.cancel();
    this.stopTimer();
  }

  /**
   * 进行文件夹粘贴操作
   * @param folderName
   * @param srcFolder
   * @param destFolderUri
   * @param deleteSrc
   * @returns 新文件夹uri
   * @throws FileAccessError(ResultCode.Error.FILE_NAME_INVALID) 文件名非法
   */
  public async createFolderAndCopyContent(folderName: string, srcFolder: FileInfo, destFolderUri: string,
    deleteSrc: boolean = false): Promise<string> {
    let subFolderPath = '';
    let subFolderUri = '';
    this.operatingFile = srcFolder;
    this.operatingFile.fileName = folderName;
    try {
      let destFileInfo: uri.URI = new fileuri.FileUri(destFolderUri);
      subFolderPath = destFileInfo.path + '/' + RenameUtil.getEscapedFolderName(folderName);
      FsUtil.mkdirSync(subFolderPath);
      subFolderUri = destFolderUri + '/' +
      FileUtil.encodeURIForFileManager(RenameUtil.getEscapedFolderName(folderName));
      HiLog.infoPrivate(TAG, 'subFolderUri: ', subFolderUri);
      if (this.totalSize === 0) {
        await this.computeProgress(1);
      }
      await this.copyFolderContent(srcFolder, subFolderUri, deleteSrc);
      if (deleteSrc) {
        let srcFolderFiles = this.listFileSync(srcFolder.relativePath);
        if ((!srcFolderFiles) || (srcFolderFiles.length <= 0)) {
          FsUtil.rmdirSync(srcFolder.relativePath);
        }
      }
    } catch (err) {
      this.notifyFailCount++;
      HiLog.error(TAG, 'createFolderAndCopyContent err = ' + JSON.stringify(err));
      throw err as Error;
    }
    let folderUri = destFolderUri + '/' + FileUtil.encodeURIForFileManager(folderName);
    return folderUri;
  }

  // 粘贴相册文件夹内容
  public async pasteAlbumContent(srcFolder: FileInfo, destFolderUri: string,
    deleteSrc: boolean = false): Promise<boolean> {
    HiLog.info(TAG, `paste album to local, delete src: ${deleteSrc}`);
    // 从相册获取文件资产信息
    let srcAlbum: photoAccessHelper.Album | undefined =
      await PhotoAccessUtil.getAlbumByUri(this.context as common.Context, srcFolder.uri);
    if (!srcAlbum) {
      HiLog.error(TAG, 'src album is null.');
      return false;
    }
    let photoAssetList: photoAccessHelper.PhotoAsset[] =
      await PhotoAccessUtil.getPhotoAsset(srcAlbum, -1, PhotoUtil.FETCH_COPY_COLUMNS);
    HiLog.info(TAG, `photoAssetList length: ${photoAssetList.length}`);
    // 相册子文件数量与查询到的非云端文件数量做对比，如果数量相同，删除相册
    let deleteAlbum: boolean = srcAlbum.count === photoAssetList.length;
    for (let photoAsset of photoAssetList) {
      try {
        if (this.isCancel) {
          HiLog.warn(TAG, 'pasteAlbumContent calcel.');
          return false;
        }

        let dupFileResult = ThreadCommonUtil.getDupFileName(photoAsset.displayName, destFolderUri, false);
        let destFileUri: string = destFolderUri + '/' +
        FileUtil.encodeURIForFileManager(RenameUtil.getEscapedFileName(dupFileResult[0]));
        let res: boolean = await this.pastePhotoFileToLocal(photoAsset, destFileUri);
        if (res && deleteSrc) { // move 模式要删除相册对应文件
          await PhotoAccessUtil.deletePermanently(this.context as common.Context, photoAsset.uri);
        } else { // 出现删除异常，表示失败，不删除相册
          deleteAlbum = false;
        }
      } catch (err) {
        deleteAlbum = false;
        this.notifyFailCount++;
        HiLog.error(TAG, 'pasteAlbumContent err：' + JSON.stringify(err));
        if (err?.code === ERROR_CODE.FILE_ACCESS.NO_SPACE_LEFT_ON_DEVICE) {
          throw err as Error;
        } else {
          await this.onErrorCatch(err.code, srcFolder);
        }
      }
    }
    HiLog.warn(TAG, `paste end, deleteAlbum: ${deleteAlbum}`);
    // move成功，删除源相册 todo 增加异常弹窗
    if (deleteAlbum && deleteSrc) {
      HiLog.info(TAG, `pasteSuccess, delete album, album type : ${srcAlbum?.albumType}`);
      if (srcAlbum && srcAlbum.albumType === photoAccessHelper.AlbumType.USER) {
        await PhotoAccessUtil.deleteAlbum(this.context as common.Context, srcAlbum);
      }
    }
    return false;
  }

  /*
   * 复制文件夹内容
   * */
  public async copyFolderContent(srcFolder: FileInfo, destFolderUri: string,
    deleteSrc: boolean = false): Promise<boolean> {
    let copySuccess: boolean = true;
    if ((!srcFolder) || (!destFolderUri)) {
      HiLog.warn(TAG, 'copyFolderContent, params is error');
      return false;
    }
    if (srcFolder.uri.startsWith(VirtualUri.GALLERY_URI)) {
      await this.pasteAlbumContent(srcFolder, destFolderUri, false);
      return copySuccess;
    }
    let newUri: string = '';
    let subFile: FileInfo | undefined;
    let fileList: string [] = [];
    try {
      fileList = this.listFileSync(srcFolder.relativePath);
    } catch (e) {
      HiLog.error(TAG, 'copyFolderContent, listFileSync failed: ' + JSON.stringify(e));
      this.notifyFailCount++;
      return false;
    }
    HiLog.info(TAG, 'copyFolderContent listFileSync length : ' + fileList?.length);
    if ((!fileList) || (fileList.length <= 0)) {
      HiLog.warn(TAG, 'copyFolderContent, fileList is null');
    }
    for (let i = 0; i < fileList.length; i++) {
      try {
        if (this.isCancel) {
          return false;
        }
        let fileName = fileList[i];
        let subUri: string = ThreadCommonUtil.getSubFileUri(srcFolder.uri, fileName);
        subFile = FileInfo.fromFileUri(subUri);
        if (!subFile.isFolder) {
          newUri = await this.createFileAndCopyContent(subFile.fileName, subFile, destFolderUri);
          if (deleteSrc && newUri) {
            fs.unlinkSync(subFile.relativePath);
          }
        } else {
          newUri = await this.createFolderAndCopyContent(subFile.fileName, subFile, destFolderUri, deleteSrc);
        }
        if (!newUri) {
          copySuccess = false;
        }
      } catch (err) {
        this.notifyFailCount++;
        HiLog.error(TAG, 'copyFolderContent err：' + JSON.stringify(err));
        if (err?.code === ERROR_CODE.FILE_ACCESS.NO_SPACE_LEFT_ON_DEVICE) {
          throw err as Error;
        } else {
          await this.onErrorCatch(err.code, subFile);
        }
      }
    }
    return copySuccess;
  }

  /**
   * 重名文件处理：替换文件
   * @param srcFile：源文件
   * @param destFolder：目标文件夹
   * @returns 替换后的新文件uri
   */
  public async replaceFile(srcFile: FileInfo, destFolderUri: string): Promise<string> {
    let dupFileResult: string[] = this.renameFile(srcFile.fileName, destFolderUri, false);
    let dupFileUri = dupFileResult[1];
    let newFileUri: string = '';
    try {
      let dupFileInfo: uri.URI = new fileuri.FileUri(dupFileUri);
      FsUtil.unlinkSync(dupFileInfo.path);
      newFileUri = await this.createFileAndCopyContent(srcFile.fileName, srcFile, destFolderUri);
    } catch (err) {
      HiLog.error(TAG, 'replaceFile err = ' + JSON.stringify(err));
      throw err as Error;
    }
    return newFileUri;
  }

  /**
   * 重名文件夹处理：替换文件夹
   * @param srcFile：源文件
   * @param destFolder：目标文件夹
   * @returns 替换后的新文件夹uri
   */
  public async replaceFolder(srcFile: FileInfo, destFolderUri: string): Promise<string> {
    let dupFileResult: string[] = this.renameFile(srcFile.fileName, destFolderUri, true); // 可考虑直接拼接删除
    let dupFileUri = dupFileResult[1];
    let newFileUri: string = '';
    try {
      let dupFileInfo: uri.URI = new fileuri.FileUri(dupFileUri);
      FsUtil.rmdirSync(dupFileInfo.path);
      newFileUri = await this.handleFolderAfterConflict(srcFile, destFolderUri);
      await this.dealMoveFolderUpdateFavorite(srcFile.relativePath, newFileUri);
    } catch (err) {
      HiLog.error(TAG, 'replaceFolder err = ' + JSON.stringify(err));
      throw err as Error;
    }
    return newFileUri;
  }

  async dealMoveFolderUpdateFavorite(srcPath: string, newUri: string): Promise<void> {
    if (this.operateType !== WorkerConst.OperateType.CUT_FILE) {
      return;
    }
    if (!StringUtil.isEmpty(newUri)) {
      let fileUriObject = FileUtil.getFileUriObjectFromUri(newUri);
      if (fileUriObject) {
        await this.updateFavoriteDataByMove(srcPath, fileUriObject.path, fileUriObject.name, this.uuid);
      }
    }
  }

  /**
   * 移动更新收藏数据库信息
   *
   * @param oldPath 旧的文件路径
   * @param newPath 新的文件路径
   * @param newFileName 新的文件名称
   * @param isNeedSubFolder 是否需要更新子文件夹
   */
  public async updateFavoriteDataByMove(oldPath: string, newPath: string, newFileName: string,
    uuid: string): Promise<boolean> {
    if (!this.checkFavoriteParams(oldPath, newPath, newFileName)) {
      return false;
    }
    HiLog.infoPrivate(TAG, `updateFileInfoByMove:`, oldPath + ' ; ' + newPath + ';' + uuid + ';' + newFileName);

    let favoriteList: FavoriteModel[] = [];
    let deleteLocalPathList = [];
    let deleteCloudPathList = [];
    if ((!this.favoriteCache) || ArrayUtil.isEmpty(this.favoriteCache)) {
      HiLog.warn(TAG, 'favoriteCache is empty');
      return false;
    }
    let index = this.favoriteCache.findIndex(item => item.path === oldPath);
    let newUuid = uuid ? uuid : '';
    let deviceType = this.getDeviceType(newUuid);
    if (index !== -1) {
      let favorite = this.favoriteCache[index];
      if (this.updateFavoriteData(favorite, deviceType, newPath, newFileName, newUuid, deleteLocalPathList,
        deleteCloudPathList)) {
      }
      favoriteList.push(favorite);
    }

    let len = this.favoriteCache.length;
    for (let i = 0; i < len; i++) {
      let subFavorite = this.favoriteCache[i];
      if (!subFavorite.recycled) {
        let subPathStart = FileUtil.getPathWithFileSplit(oldPath);
        let subFolderPath = subFavorite.path;
        if (subFolderPath.startsWith(subPathStart)) {
          let newSubPath = newPath + subFolderPath.substring(oldPath.length);
          if (this.updateFavoriteData(subFavorite, deviceType, newSubPath, subFavorite.name, newUuid,
            deleteLocalPathList, deleteCloudPathList)) {
          }
          favoriteList.push(subFavorite);
          HiLog.infoPrivate(TAG,
            'updateFileInfoByMove:', subFolderPath + ' ; ' + newSubPath + ' ; ' + subFavorite.name + ' ; ' + uuid);
        }
      }
    }
    if (ArrayUtil.isEmpty(favoriteList)) {
      HiLog.info(TAG, 'updateFileInfoByMove:favoriteList is empty');
      return false;
    }

    let copyCutResultParam = new CopyCutResultParam(
      this.workerName,
      WorkerConst.WorkerStatus.RUNNING,
      WorkerConst.CopyCutResultType.UPDATE_FAVORITE_LIST,
      this.operateType,
      this.operatingFile.fileName,
      this.pasteProgressRate
    );

    copyCutResultParam.updateFavoriteList = favoriteList;
    copyCutResultParam.deleteLocalFavoritePath = deleteLocalPathList;
    this.workerPort!!.postMessage(copyCutResultParam);
    return true;
  }

  /**
   * 重名文件夹处理：合并文件夹
   * @param srcFile：源文件
   * @param destFolder：目标文件夹
   * @param pasteFlag：粘贴标志
   * @returns 合并后的文件夹uri
   * @throws Error: 操作文件异常
   */
  public async mergeFolder(srcFile: FileInfo, destFolderUri: string): Promise<string> {
    let dupFileResult: string[] = this.renameFile(srcFile.fileName, destFolderUri, true);
    let dupFileUri = dupFileResult[1];
    try {
      if (srcFile.uri.startsWith(VirtualUri.GALLERY_URI)) {
        await this.pasteAlbumContent(srcFile, dupFileUri, this.operateType === WorkerConst.OperateType.CUT_FILE);
        return dupFileUri;
      }
      let fileList = this.listFileSync(srcFile.relativePath);
      HiLog.info(TAG, 'mergeFolder listFileSync length : ' + fileList?.length);
      if ((!fileList) || (fileList.length <= 0)) {
        HiLog.warn(TAG, 'mergeFolder, fileList is null');
      }
      for (let i = 0; i < fileList.length; i++) {
        if (this.isCancel) {
          break;
        }
        let fileName = fileList[i];
        let subUri: string = ThreadCommonUtil.getSubFileUri(srcFile.uri, fileName);
        let subFile: FileInfo = FileInfo.fromFileUri(subUri);
        this.operatingFile = subFile;
        let newUri = await this.handlerFolderSubFile(subFile, dupFileUri);
      }
      if (this.operateType === WorkerConst.OperateType.CUT_FILE) {
        let srcFolderFiles = this.listFileSync(srcFile.relativePath);
        if ((!srcFolderFiles) || (srcFolderFiles.length <= 0)) {
          fs.rmdirSync(srcFile.relativePath);
          this.dealMoveFolderUpdateFavorite(srcFile.relativePath, dupFileUri);
        }
      }
    } catch (err) {
      HiLog.warn(TAG, 'mergeFolder err = ' + JSON.stringify(err));
      throw err as Error;
    }
    return dupFileUri;
  }

  /**
   * 执行剪切
   * @param copyCutSendParam 发送参数
   * @returns
   */
  public async doMove(toOperateFiles: FileInfo[], destFolderUri: string): Promise<void> {
    let srcFile: FileInfo = new FileInfo();
    for (let index: number = 0; index < toOperateFiles.length; index++) {
      try {
        if (this.isCancel) {
          HiLog.info(TAG, 'doMove is cancel');
          return;
        }
        srcFile = toOperateFiles[index];
        this.operatingFile = srcFile;
        let srcFolderUri: string = ThreadCommonUtil.getParentUri(srcFile.uri);
        HiLog.infoPrivate(TAG, 'doMove', 'srcFolderUri:' + srcFolderUri + ' destFolderUri: ' + destFolderUri);
        // 被粘贴文件与固定目录冲突
        let isDupFixedFolderConflict: boolean =
          destFolderUri === VirtualUri.MY_PHONE &&
          Constant.PHONE_SYSTEM_HIDE_FOLDER_NAME_LOWER_CASE.includes(srcFile.fileName.toLowerCase());
        if (isDupFixedFolderConflict) {
          HiLog.warn(TAG, 'do move: conflict with Fixed Folder');
          await this.dealError(ResultCode.Error.UNKNOWN_ERROR);
          await this.dealPasteFileAfterChoose();
          return;
        }
        // 同路径下剪切粘贴不执行
        if (srcFolderUri === destFolderUri) {
          HiLog.info(TAG, 'start pasteCutFile, srcPath is equal to destPath when cut');
          this.pasteFilesRes.push(new PasteResult(srcFile.uri, srcFile.uri));
          continue;
        }
        // 特殊场景：剪切同名子文件夹到同名父文件夹所在路径，此操作被禁止
        let isOperateDupFolderFromChildToParent: boolean =
          ThreadCommonUtil.isOperateDupFolderFromChildToParent(srcFile, destFolderUri);
        if (isOperateDupFolderFromChildToParent) {
          HiLog.warn(TAG, 'cut dup folder from child to parent');
          await this.dealError(ResultCode.Error.OPERATE_DUP_FOLDER_FROM_CHILD_TO_PARENT);
          await this.dealPasteFileAfterChoose(this.operatingFile);
          return;
        }
        let newUri: string = await this.handlerFolderSubFile(srcFile, destFolderUri);
        if (newUri) {
          this.countNotifySuccessCount();
          this.pasteFilesRes.push(new PasteResult(srcFile.uri, newUri));
        }
      } catch (err) {
        HiLog.error(TAG, 'doMove err：' + JSON.stringify(err));
        let uri = await this.onErrorCatch(err.code, srcFile);
        this.countNotifySuccessCount(!StringUtil.isEmpty(uri));
        if (err?.code === ERROR_CODE.FILE_ACCESS.NO_SPACE_LEFT_ON_DEVICE) {
          throw err as Error;
        }
      }
    }
  }

  /**
   * 源文件/文件夹重命名后再移到目标路径
   * @param srcFileUri 源文件/文件夹uri
   * @param destUri 目标路径
   */
  public async moveDupFile(srcFile: FileInfo, destFolderUri: string): Promise<string> {
    HiLog.info(TAG, 'moveDupFile start');
    let newUri = '';
    try {
      let dupFileResult = this.renameFile(srcFile.fileName, destFolderUri, false);
      newUri = await this.moveFile(srcFile, dupFileResult[0], destFolderUri);
    } catch (err) {
      HiLog.warn(TAG, `moveDupFile err: ${err?.code}, message: ${err?.message}`);
      throw err as Error;
    }
    return newUri;
  }

  /**
   * 删除目标路径下与源文件/文件夹重名的文件/文件夹，再将源文件移到目标路径
   * @param srcUri 源文件/文件夹uri
   * @param destUri 目标路径uri
   * @param dupNameUri 目标路径下与源文件/文件夹重名的文件/文件夹uri
   */
  public async deleteAndMove(srcFile?: FileInfo, destFolderUri?: string): Promise<string> {
    HiLog.info(TAG, 'delete and move start');
    if ((!srcFile) || (!destFolderUri)) {
      HiLog.error(TAG, 'delete and move fail, cause srcFile or destFolderUri is undefined!');
      return '';
    }
    let newUri = '';
    try {
      let dupFileResult = this.renameFile(srcFile.fileName, destFolderUri, srcFile.isFolder);
      let dupFileUri = dupFileResult[1];
      let dupFileInfo: uri.URI = new fileuri.FileUri(dupFileUri);
      HiLog.infoPrivate(TAG, 'delete duplicate file:', dupFileUri);
      FsUtil.unlinkSync(dupFileInfo.path);
      HiLog.info(TAG, 'move file start');
      newUri = await this.moveFile(srcFile, srcFile.fileName, destFolderUri);
    } catch (err) {
      HiLog.warn(TAG, `delete and move err: ${err?.code}, message: ${err?.message}`);
      throw err as Error;
    }
    return newUri;
  }

  /**
   * 处理异常
   * @param exceptionCode 异常码
   */
  public async dealException(exceptionCode: ResultCode.Exception): Promise<void> {
    if (!this.checkNeedDealException(exceptionCode)) {
      HiLog.info(TAG, 'applyToAll, stop dealException');
      return;
    }
    this.sendException(exceptionCode);
    while (this.waitOperate && !this.isCancel) {
      await TimeUtil.sleep(INTERVAL_TIME);
      HiLog.debug(TAG, 'wait choose, exceptionCode: ' + exceptionCode);
    }
  }

  /**
   * 处理错误
   * @param errorCode
   * @returns
   */
  public async dealError(errorCode: ResultCode.Error): Promise<void> {
    HiSysEventUtil.reportFailureEvent(HiSysEventName.FILE_OPERATE_FAIL, InterfaceName.DO_PASTE, errorCode);
    // 主动拉起进度条窗口
    if (!this.checkNeedDealError(errorCode)) {
      return;
    }

    this.sendError(errorCode);
    while (this.waitOperate && !this.isCancel) {
      await TimeUtil.sleep(INTERVAL_TIME);
      HiLog.debug(TAG, 'wait choose, exceptionCode: ' + errorCode);
    }
  }

  /**
   * 处理复制文件冲突情况下的选择结果
   * @param srcFile
   * @param destFolderUri
   * @returns
   */
  public async dealPasteFileAfterChoose(srcFile?: FileInfo, destFolderUri?: string): Promise<string> {
    let newUri: string = '';
    if (this.isCancel) {
      HiLog.info(TAG, 'dealPasteFileAfterChoose is cancel');
      return newUri;
    }
    HiLog.info(TAG, 'dealCopyFileAfterChoose, conflictHandleResult:' + this.conflictChooseType);
    try {
      let scrFileDup: FileInfo = new FileInfo();
      if (srcFile) {
        scrFileDup = JSON.parse(JSON.stringify(srcFile)); // 提前保存下源文件的值，因为下面流程可能改变其值
      }
      let choose = this.getChooseConflict();
      switch (choose) {
        case CopyCutConst.ChooseType.KEEP_BOTH_FILE:
          // 合并文件，即创建副本
          if (this.operateType === WorkerConst.OperateType.COPY_FILE) {
            newUri = await this.createDup(srcFile!!, destFolderUri!!);
          } else if (this.operateType === WorkerConst.OperateType.CUT_FILE) {
            newUri = await this.moveDupFile(srcFile!!, destFolderUri!!);
          }
          break;
        case CopyCutConst.ChooseType.REPLACE_FILE:
          // 替换文件
          if (this.operateType === WorkerConst.OperateType.COPY_FILE) {
            newUri = await this.replaceFile(srcFile!!, destFolderUri!!);
          } else if (this.operateType === WorkerConst.OperateType.CUT_FILE) {
            newUri = await this.deleteAndMove(srcFile, destFolderUri);
          }
          break;
        case CopyCutConst.ChooseType.STOP:
          this.cancelWorker();
          // 停止
          this.taskEnd();
          break;
        case CopyCutConst.ChooseType.REPLACE_FOLDER:
          // 替换文件夹
          newUri = await this.replaceFolder(srcFile!!, destFolderUri!!);
          break;
        case CopyCutConst.ChooseType.MERGE_FOLDER:
          // 合并文件夹
          newUri = await this.mergeFolder(srcFile!!, destFolderUri!!);
          break;
        case CopyCutConst.ChooseType.SKIP:
        case CopyCutConst.ChooseType.SKIP_FILE:
        case CopyCutConst.ChooseType.SKIP_FOLDER:
          // 跳过
          await this.onFileSkip(srcFile);
          return newUri;
        default:
          break;
      }
      if (newUri) {
        this.pasteFilesRes.push(new PasteResult(srcFile!!.uri, newUri));
      } else {
        this.notifyFailCount++;
      }
    } catch (err) {
      HiLog.warn(TAG, 'dealPasteFileAfterChoose err = ' + JSON.stringify(err));
      throw err as Error;
    }
    return newUri;
  }

  /**
   * 对文件、文件夹进行复制，此处需要判断是直接创建副本还是按照规则生成文件
   * @param srcFile
   * @param srcFolderUri
   * @param destFolderUri
   * @param isFromRecent
   * @returns
   */
  protected async copyFileOrFolder(srcFile: FileInfo, srcFolderUri: string,
    destFolderUri: string, isFromRecent: boolean): Promise<string> {
    let newUri: string = '';
    if (this.isCreateDup(srcFile, srcFolderUri, destFolderUri, isFromRecent)) {
      // 直接生成副本文件
      newUri = await this.createDup(srcFile, destFolderUri);
    } else {
      // 按照规则生成文件
      HiLog.info(TAG, 'create file according to the rules');
      newUri = await this.handlerFolderSubFile(srcFile, destFolderUri);
    }
    return newUri;
  }

  private dealConflictChooseInPhone(msg: CopyCutSendParam) {
    switch (this.conflictType) {
      case CopyCutConst.ConflictType.FILE_CONFLICT:
        this.isFileApplyAll = msg.isApplyToAll;
        this.fileApplyChoose = msg.conflictHandleResult;
        break;
      case CopyCutConst.ConflictType.FOLDER_CONFLICT:
        this.isFolderApplyAll = msg.isApplyToAll;
        this.folderApplyChoose = msg.conflictHandleResult;
        break;
      case CopyCutConst.ConflictType.PATH_CONFLICT:
        this.isPathApplyAll = msg.isApplyToAll;
        this.pathApplyChoose = msg.conflictHandleResult;
        break;
      case CopyCutConst.ConflictType.OTHER_ERROR:
        this.isOtherErrorApplyAll = msg.isApplyToAll;
        this.otherErrorApplyChoose = msg.conflictHandleResult;
        break;
      default:
        HiLog.error(TAG, 'conflict type wrong.');
        break;
    }
  }

  /**
   * 处理冲突选择结果
   * @param msg 消息
   */
  private dealConflictChoose(msg: CopyCutSendParam): void {
    HiLog.info(TAG, 'apply all: ' + msg.isApplyToAll + ' chooseResult: ' + msg.conflictHandleResult);
    this.dealConflictChooseInPhone(msg)
    this.waitOperate = false;
  }

  private queryStatus(): void {
    if (this.waitOperate) {
      this.workerPort!!.postMessage(this.conflictParam);
    } else {
      let sendData = new CopyCutResultParam(
        this.workerName,
        WorkerConst.WorkerStatus.RUNNING,
        WorkerConst.CopyCutResultType.QUERY_WORKER_STATUS,
        this.operateType,
        this.operatingFile.fileName,
        this.pasteProgressRate
      );
      this.workerPort!!.postMessage(sendData);
    }
  }

  private async copyFileInit(copyCutSendParam: CopyCutSendParam): Promise<boolean> {
    HiLog.info(TAG, `startTask, destFolderIsGalleryAlbum: ${this.destFolderIsGalleryAlbum}`);
    // 目的路径是图库
    if (this.destFolderIsGalleryAlbum) {
      if (this.destFolderUri !== VirtualUri.GALLERY) {
        this.destAlbum = await PhotoAccessUtil.getAlbumByUri(this.context as common.Context, this.destFolderUri);
        if (!this.destAlbum) {
          HiLog.warn(TAG, 'dest album is not exist.');
          await this.dealError(ResultCode.Error.SRC_FILE_NOT_EXIST);
          return false;
        }
      }
      // 获取所有要粘贴的文件
      let initRes: ResultCode.Exception = await this.initFileListToGallery(this.toOperateFiles, copyCutSendParam);
      if (initRes === ResultCode.Exception.EXCEPTION_TASK_CANCEL ||
        initRes === ResultCode.Exception.EXCEPTION_FILE_INIT_FAIL) {
        return false;
      }
      if (initRes === ResultCode.Exception.EXCEPTION_PASTE_CONTENT_INCLUDE_FILE) {
        HiLog.warn(TAG, 'Paste the file to the gallery root path.');
        await this.dealError(ResultCode.Error.ERROR_GALLERY_ROOT_PASTER);
        return false;
      } else if (initRes === ResultCode.Exception.EXCEPTION_GALLERY_FILE_NAME_INVALID) {
        HiLog.warn(TAG, 'file name contains invalid character.');
        await this.dealError(ResultCode.Error.ERROR_GALLERY_FILE_NAME_INVALID);
      }

      if (await this.isScreenShotAlbum(this.destFolderUri) && (this.videoCount !== 0 ||
        initRes === ResultCode.Exception.EXCEPTION_EXIST_UNSUPPORTED_TYPE)) {
        HiLog.warn(TAG, 'The screen Recorder path cannot be pasted.');
        await this.dealException(ResultCode.Exception.EXCEPTION_SCREENSHOT_ALBUM_PASTER_UNSUPPORT_FOLDER);
      } else if (await this.isScreenRecorderAlbum(this.destFolderUri) && (this.imageCount !== 0 ||
        initRes === ResultCode.Exception.EXCEPTION_EXIST_UNSUPPORTED_TYPE)) {
        HiLog.warn(TAG, 'The screen recording path cannot be pasted.');
        await this.dealException(ResultCode.Exception.EXCEPTION_SCREENRECORD_ALBUM_PASTER_UNSUPPORT_FOLDER);
      } else if (initRes === ResultCode.Exception.EXCEPTION_EXIST_UNSUPPORTED_TYPE) {
        HiLog.warn(TAG, 'Unsupported types exist in the files.');
        await this.dealException(ResultCode.Exception.EXCEPTION_EXIST_UNSUPPORTED_TYPE);
      }
    } else {
      await this.initFileListInfo(this.toOperateFiles, copyCutSendParam);
      // 初始化失败或者取消，直接返回
      if (this.isFileInitError || this.isCancel) {
        return false;
      }
    }
    HiLog.info(TAG, 'startTask file totalSize: ' + this.totalSize + ', total count: ' + this.totalCount);
    this.isShowProgressBar = (copyCutSendParam.progressBarShowStatus === ProgressBarStatus.NEEDS_TO_BE_PULLED_UP);
    // 检查磁盘空间是否足够
    if ((this.operateType === WorkerConst.OperateType.COPY_FILE) ||
      ((this.operateType === WorkerConst.OperateType.CUT_FILE) && this.isOperatingAcrossDisk)) {
      let hasEnoughFreeSize: boolean = false;
      // 需保障操作完还有最后有500M
      const totalSize = ExternalStorageUtil.isExternalStorageUri(copyCutSendParam.destFolderUri) ? this.totalSize :
        this.totalSize + Constant.MIN_REMAIN_SIZE;
      hasEnoughFreeSize = await StorageUtil.hasEnoughFreeSize(totalSize, this.uuid);

      if (!hasEnoughFreeSize) {
        HiLog.warn(TAG, 'size is not enough');
        await this.dealError(ResultCode.Error.NO_SPACE_LEFT);
        return false;
      }
    }
    return true;
  }

  private async runTask(copyCutSendParam: CopyCutSendParam): Promise<void> {
    let workerName: string = copyCutSendParam.workerName;
    HiLog.infoPrivate(TAG, 'runTask operateType ' + this.operateType + 'workerName: ', workerName);
    if (this.destFolderIsGalleryAlbum) {
      HiLog.info(TAG, 'dest folder is gallery.');
      await this.pasteToGallery(this.toOperateFiles, copyCutSendParam);
      return;
    }
    if (this.operateType === WorkerConst.OperateType.COPY_FILE) {
      await this.doCopy(this.toOperateFiles, copyCutSendParam.destFolderUri, copyCutSendParam.isFromRecent);
    } else if (this.operateType === WorkerConst.OperateType.CUT_FILE) {
      await this.doMove(this.toOperateFiles, copyCutSendParam.destFolderUri);
    } else if (this.operateType === WorkerConst.OperateType.DRAG_FILE) {
      await this.doDrag(copyCutSendParam);
    }
  }

  // 返回是否是媒体库支持类型
  private async isMediaSupportType(fileName: string): Promise<boolean> {
    // 0是否是图片格式，1是否是视频格式
    let supportFormats: boolean[] = [false, false];
    supportFormats = await PhotoAccessUtil.getPhotoSupportedFormats(this.context as common.Context, fileName);
    if (supportFormats[0]) {
      this.imageCount++;
    }
    if (supportFormats[1]) {
      this.videoCount++;
    }
    if (this.screenShotUri === this.destFolderUri) {
      return supportFormats[0];
    } else if (this.screenRecorderUri === this.destFolderUri) {
      return supportFormats[1];
    }
    return supportFormats[0] || supportFormats[1];
  }

  /**
   * 获取相册下文件大小和数量
   */
  private async setPhotoAlbumSizeAndNumInfo(data: FileInfo): Promise<boolean> {
    let photoAlbum: photoAccessHelper.Album | undefined =
      await PhotoAccessUtil.getAlbumByUri(this.context as common.Context, data.uri);
    if (!photoAlbum) {
      HiLog.warn(TAG, 'album is not exist.');
      this.errFiles.push({ code: OperateResult.FILE_NOT_EXIST, fileInfo: data });
      this.isFileInitError = true;
      return false;
    }
    data.albumSubType = photoAlbum.albumSubtype;
    data.albumType = photoAlbum.albumType;
    data.isFolder = true;
    data.fileName = photoAlbum.albumName;

    // 截图录屏为目的路径时，只过滤单个类型进行粘贴
    let queryType: photoAccessHelper.PhotoType = -1;
    if (this.screenShotUri === photoAlbum.albumUri) {
      queryType = photoAccessHelper.PhotoType.IMAGE;
    } else if (this.screenRecorderUri === photoAlbum.albumUri) {
      queryType = photoAccessHelper.PhotoType.VIDEO;
    }
    let photoAssetArray: photoAccessHelper.PhotoAsset[] =
      await PhotoAccessUtil.getPhotoAsset(photoAlbum, queryType, PhotoUtil.FETCH_COPY_COLUMNS);
    for (let photoAsset of photoAssetArray) {
      this.totalSize += photoAsset.get(photoAccessHelper.PhotoKeys.SIZE) as number;
    }
    if (queryType === photoAccessHelper.PhotoType.IMAGE) {
      this.imageCount += photoAssetArray.length;
    } else if (queryType === photoAccessHelper.PhotoType.VIDEO) {
      this.videoCount += photoAssetArray.length;
    }
    this.totalCount += photoAssetArray.length;
    return true;
  }

  private initFileInfoByPath(data: FileInfo): boolean {
    try {
      let fileUri: fileuri.FileUri = new fileuri.FileUri(data.uri);
      data.fileName = fileUri.name;
      data.relativePath = fileUri.path;
      let stat = fs.statSync(fileUri.path);
      data.size = stat.size;
      data.isFolder = stat.isDirectory();
      return true;
    } catch (error) {
      HiLog.infoPrivate(TAG, 'initUriData, fileName:', data.uri + '-' + data.fileName);
      data.size = 0;
      HiLog.info(TAG, 'initUriData error: ' + error.toString());
      this.errFiles.push({ code: error.code, fileInfo: data });
      this.isFileInitError = true;
      return false;
    }
  }

  private initFileInfoByOpen(data: FileInfo): boolean {
    let fsFile: fs.File | null = null;
    try {
      let fileUri: fileuri.FileUri = new fileuri.FileUri(data.uri);
      data.relativePath = fileUri.path;
      data.fileName = fileUri.name;
      fsFile = fs.openSync(data.uri);
      const fsFileInfo = fs.statSync(fsFile.fd);
      data.size = fsFileInfo.size;
      data.isFolder = fsFileInfo.isDirectory();
      return true;
    } catch (error) {
      HiLog.infoPrivate(TAG, 'initUriData, fileName:', data.uri + '-' + data.fileName);
      data.size = 0;
      let errorCode: number = error?.code ?? OperateResult.FILE_NOT_EXIST;
      HiLog.error(TAG, `initUriData error code: ${errorCode}, message: ${error?.message}`);
      this.errFiles.push({ code: errorCode, fileInfo: data });
      this.isFileInitError = true;
      return false;
    } finally {
      if (fsFile) {
        this.fsCloseFile(fsFile);
      }
    }
  }

  private isExternalOrAcrossDisk(): boolean {
    // 判断是否跨介质或者目标目录是外卡
    return this.isOperatingAcrossDisk ||
      !(StringUtil.isEmpty(this.uuid) || this.uuid === 'LOCAL' || this.uuid === 'cloud');
  }

  /**
   * 初始化相关参数
   * @param msg 消息
   * @returns 是否正常初始化
   */
  private async initAndCheckData(copyCutSendParam: CopyCutSendParam): Promise<boolean> {
    if (ObjectUtil.isNullOrUndefined(this.workerPort)) {
      HiLog.error(TAG, 'initAndCheckData workerPort is null');
      return false;
    }
    this.progressSize = 0;
    this.completeCount = 0;
    this.context = copyCutSendParam.context;
    this.workerName = copyCutSendParam.workerName;
    this.operateType = copyCutSendParam.operateType;
    this.uuid = copyCutSendParam.uuid;
    this.taskFileCount = copyCutSendParam.toOperateFiles.length;
    this.destFolderUri = copyCutSendParam.destFolderUri;
    this.srcFolderUri = copyCutSendParam.srcFolderUri;
    this.isLocalAppFile = copyCutSendParam.isLocalAppFile;
    this.localRootUri = copyCutSendParam.localRootUri;
    this.toOperateFiles = copyCutSendParam.toOperateFiles;
    if ((!this.context) || (!this.workerName) || (!this.operateType)) {
      HiLog.warn(TAG, 'initAndCheckData param is null');
      return false;
    }
    if (this.destFolderUri.startsWith(VirtualUri.GALLERY_URI) || this.destFolderUri === VirtualUri.GALLERY) {
      this.destFolderIsGalleryAlbum = true;
    }
    this.isOperatingAcrossDisk =
      ExternalStorageUtil.isOperateAcrossDisk(copyCutSendParam.toOperateFiles[0]?.uri ?? '', this.destFolderUri);
    this.conflictFolderChooseType = CopyCutConst.ChooseType.DEFAULT;
    this.conflictFileChooseType = CopyCutConst.ChooseType.DEFAULT;
    this.conflictChooseType = CopyCutConst.ChooseType.DEFAULT;
    this.favoriteCache = copyCutSendParam.favoriteList;
    return true;
  }

  private checkGalleryCanMove(fileInfo: FileInfo, copyCutSendParam: CopyCutSendParam): boolean {
    // 跨设备走复制流程
    if (copyCutSendParam.isExternalOperate) {
      return false;
    }
    // 如果是系统目录走复制
    if (this.checkIsSystemFolder(fileInfo)) {
      return false;
    }
    return true;
  }

  /**
   * @param 处理粘贴到根路径有同名相册
   */
  private async handleGalleryDupFolder(srcFileInfo: FileInfo, destAlbumInfo: photoAccessHelper.Album): Promise<void> {
    HiLog.warn(TAG, 'handleGalleryDupFolder.');
    // 文件夹同名弹窗
    await this.dealException(ResultCode.Exception.EXIST_DUPLICATE_FOLDER);
    let choose = this.getChooseConflict();
    HiLog.warn(TAG, `handleGalleryDupFolder, choose is ${choose}`);
    if (choose === CopyCutConst.ChooseType.SKIP_FOLDER) {
      return;
    } else if (choose === CopyCutConst.ChooseType.MERGE_FOLDER) {
      await this.pasteToGalleryFolder(srcFileInfo, destAlbumInfo);
    }
  }

  /**
   * @param 处理相册粘贴到图库根路径
   */
  private async pasteAlbumToGalleryRootPath(srcFileInfo: FileInfo,
    destAlbumInfo: photoAccessHelper.Album): Promise<void> {
    HiLog.info(TAG, 'paste file to gallery root path start.');
    // move，图库相册粘贴到图库或图库相册自身粘到自身
    if (this.operateType === WorkerConst.OperateType.CUT_FILE && srcFileInfo.uri === destAlbumInfo?.albumUri) {
      HiLog.error(TAG, 'The source album is the same as the destination album.');
      return;
    }

    let srcAlbum: photoAccessHelper.Album | undefined =
      await PhotoAccessUtil.getAlbumByUri(this.context as common.Context, srcFileInfo.uri);
    if (!srcAlbum) {
      HiLog.error(TAG, 'src album is null.');
      return;
    }
    // 截图录屏为目的路径时，只过滤单个类型进行粘贴
    let queryType: photoAccessHelper.PhotoType = -1;
    if (this.screenShotUri === destAlbumInfo.albumUri) {
      queryType = photoAccessHelper.PhotoType.IMAGE;
    } else if (this.screenRecorderUri === destAlbumInfo.albumUri) {
      queryType = photoAccessHelper.PhotoType.VIDEO;
    }
    // 源路径时相册时，根据目的路径过滤类型
    let photoAssetList: photoAccessHelper.PhotoAsset[] =
      await PhotoAccessUtil.getPhotoAsset(srcAlbum, queryType, PhotoUtil.FETCH_COPY_COLUMNS);
    HiLog.info(TAG, `photoAssetList length: ${photoAssetList.length}`);

    // 图库相册 移动到其他图库相册，批量move文件
    if (this.operateType === WorkerConst.OperateType.CUT_FILE) {
      await this.movePhotoAlbum(photoAssetList, srcAlbum, destAlbumInfo);
    } else if (this.operateType === WorkerConst.OperateType.COPY_FILE) {
      await this.copyAlbumToGallery(photoAssetList, srcFileInfo, destAlbumInfo);
    }
  }

  private async copyAlbumToGallery(photoAssetList: photoAccessHelper.PhotoAsset[], srcFileInfo: FileInfo,
    destAlbumInfo: photoAccessHelper.Album): Promise<void> {
    // 调用媒体库新接口创建文件
    for (let i = 0; i < photoAssetList.length; i++) {
      if (this.isCancel) {
        HiLog.warn(TAG, 'copyAlbumToGallery cancel.');
        return;
      }
      this.operatingFile = srcFileInfo;
      let photoAsset = photoAssetList[i];
      if (!photoAsset) {
        HiLog.error(TAG, 'photo asset is null.');
        continue;
      }
      await this.copyPhotoToGallery(photoAsset, destAlbumInfo);
    }
  }

  private async copyPhotoToGallery(photoAsset: photoAccessHelper.PhotoAsset,
    destAlbumInfo: photoAccessHelper.Album): Promise<void> {
    if (!photoAsset || !destAlbumInfo) {
      HiLog.warn(TAG, 'copyPhotoToGallery, photoAsse or dest albumInfo is null.');
      return;
    }
    let photoSubType = photoAsset.get(photoAccessHelper.PhotoKeys.PHOTO_SUBTYPE) as photoAccessHelper.PhotoSubtype;
    HiLog.info(TAG, `photoSubType: ${photoSubType}`);
    if (photoSubType === photoAccessHelper.PhotoSubtype.MOVING_PHOTO) {
      let newFileUri: string[] = await PhotoAccessUtil.createFileToAlbum(this.context as common.Context,
        photoAsset.displayName, destAlbumInfo.albumUri);
      if (newFileUri.length === 0) {
        HiLog.warn(TAG, 'copyPhotoToGallery failed.');
        return;
      }
      try {
        let res: boolean = await PhotoAccessUtil.copyMovingImage(photoAsset, newFileUri[0], this.context);
        if (res) {
          let photoSize: number = photoAsset.get(photoAccessHelper.PhotoKeys.SIZE) as number;
          await this.computeProgress(photoSize === 0 ? 1 : photoSize);
        }
      } catch (err) {
        HiLog.warn(TAG, `copyPhotoToGallery failed. message: ${err?.message}`);
      }
    } else {
      await this.createAndPasteToMediaFile(photoAsset.uri, photoAsset.displayName, destAlbumInfo.albumUri);
    }
  }

  /**
   * @param 通过read、write来粘贴文件
   */
  private async pasteFileByFd(srcFileUri: string, destAlbumUri: string): Promise<boolean> {
    if ((!srcFileUri) || (!destAlbumUri)) {
      HiLog.warn(TAG, 'paste FileByFd, params are err');
      return false;
    }
    HiLog.infoPrivate(TAG, 'paste FileByFd start', `src: ${srcFileUri}, destFileUri : ${destAlbumUri}`);
    let needDelete: boolean = false;
    let srcFile: fs.File | undefined;
    let destFile: fs.File | undefined;
    try {
      srcFile = fs.openSync(srcFileUri, fs.OpenMode.READ_ONLY);
      HiLog.info(TAG, 'open src file');
      destFile = fs.openSync(destAlbumUri, fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);

      let isDone = false;
      let completedSize = 0;
      let buf = new ArrayBuffer(PASTE_BUFFER);
      while (!isDone) {
        if (this.isCancel) {
          HiLog.warn(TAG, 'paste FileByFd canceled');
          break;
        }
        let readLen = fs.readSync(srcFile.fd, buf);
        let writeLen = fs.writeSync(destFile.fd, buf, { length: readLen });
        completedSize += writeLen;
        isDone = readLen === 0;
        await this.computeProgress(writeLen);
      }

      // 明确的空文件场景
      if (completedSize === 0 && !this.isCancel) {
        await this.computeProgress(1);
        return true;
      }
      // 如果取消了，并且当前粘贴的文件未完成
      if (this.isCancel && !isDone) {
        needDelete = true;
        return false;
      }
      HiLog.info(TAG, 'paste FileByFd success');
    } catch (err) {
      HiLog.error(TAG, 'paste FileByFd err = ' + JSON.stringify(err));
      HiSysEventUtil.reportFailureEvent(HiSysEventName.FILE_OPERATE_FAIL, InterfaceName.COPY_FILE_CONTENT_BY_FD,
        (err as BusinessError).code);
      needDelete = true;
      throw err as Error;
    } finally {
      if (srcFile) {
        this.fsCloseFile(srcFile);
      }
      if (destFile) {
        this.fsCloseFile(destFile);
      }
      if (needDelete) {
        HiLog.info(TAG, 'needDelete.');
        // todo 待图库补充提供接口
      }
    }
    return true;
  }

  /**
   * @param 创建文件到媒体库并粘贴
   */
  private async createAndPasteToMediaFile(srcFileUri: string,
    srcFileName: string, destAlbumUri: string): Promise<boolean> {
    let res: boolean = true;
    try {
      let newFileUri: string[] = await PhotoAccessUtil.createFileToAlbum(this.context as common.Context,
        srcFileName, destAlbumUri);
      res = await this.pasteFileByFd(srcFileUri, newFileUri[0]);
    } catch (err) {
      // todo 增加文件copy失败记录
      HiLog.errorPrivate(TAG, `create And paste File error: ${JSON.stringify(err)}`, `uri : ${srcFileUri}`);
      if (err?.code === ERROR_CODE.FILE_ACCESS.NO_SPACE_LEFT_ON_DEVICE) {
        throw err as Error;
      }
      res = false;
    }
    return res;
  }

  /**
   * @param
   */
  private async pasteToGalleryFolder(srcFileInfo: FileInfo, destAlbumInfo: photoAccessHelper.Album): Promise<void> {
    HiLog.infoPrivate(TAG, 'pasteToGalleryFolder start.', `src file name: ${srcFileInfo.fileName}`);
    // 源文件夹
    if (srcFileInfo.isFolder) {
      await this.pasteFolderToGallery(srcFileInfo, destAlbumInfo);
    } else { // 处理文件
      await this.pasteFileToGallery(srcFileInfo, destAlbumInfo);
    }
  }

  // 图库内，移动A相册到B相册
  private async movePhotoAlbum(photoAssetList: photoAccessHelper.PhotoAsset[], srcAlbum: photoAccessHelper.Album,
    destAlbumInfo: photoAccessHelper.Album): Promise<void> {
    HiLog.infoPrivate(TAG, 'move photo album start.', `srcAlbum name: ${srcAlbum.albumName}`);
    if (photoAssetList.length === 0 || ObjectUtil.isNullOrUndefined(srcAlbum) ||
    ObjectUtil.isNullOrUndefined(destAlbumInfo)) {
      HiLog.error(TAG, 'movePhotoAlbum Input parameter error.');
      return;
    }
    let photoNum: number = photoAssetList.length;
    let moveNum: number = 1;
    // 数量少时，分四组进行，数量多时，
    if (photoNum > MOVE_MIN_NUM && photoNum <= MOVE_MAX_NUM * MIN_GROUPS_COUNT) {
      moveNum = Math.floor(photoNum / MIN_GROUPS_COUNT);
    } else if (photoNum > MOVE_MAX_NUM * 2) {
      moveNum = MOVE_MAX_NUM;
    }
    HiLog.warn(TAG, `move count: ${moveNum}, total count: ${photoNum}`);
    let deleteSrcAlbum: boolean = (srcAlbum.count === photoAssetList.length &&
      srcAlbum.albumType === photoAccessHelper.AlbumType.USER);
    let handleSize: number = 0;
    for (let i = 0; i < photoNum; ) {
      let fileList: photoAccessHelper.PhotoAsset[] = photoAssetList.slice(i, i + moveNum);
      i = i + moveNum;
      if (this.totalSize !== 0) {
        fileList.forEach((item) => {
          if (!item) {
            HiLog.warn(TAG, 'file item is null.');
            return;
          }
          handleSize += item.get(photoAccessHelper.PhotoKeys.SIZE) as number;
        })
      } else {
        handleSize = 1;
      }
      if (!await PhotoAccessUtil.movePhotoAssetsToAlbum(this.context as common.Context,
        fileList, srcAlbum, destAlbumInfo)) {
        HiLog.error(TAG, 'move failed.');
        deleteSrcAlbum = false;
      }
      await this.computeProgress(handleSize);
      handleSize = 0;
    }

    // 相册子文件数量与查询到的非云端文件数量做对比，如果数量相同，且是用户相册，删除相册
    if (deleteSrcAlbum) {
      HiLog.warn(TAG, 'move end, delete src album.');
      // move完相册文件后，删除相册
      await PhotoAccessUtil.deleteAlbum(this.context as common.Context, srcAlbum);
    }
  }

  // 移动单个图库文件
  private async movePhotoAssetToAlbum(srcFileInfo: FileInfo, destAlbumInfo: photoAccessHelper.Album): Promise<void> {
    // 调用媒体库接口，获取源文件并使用媒体库接口move
    let photoAsset: photoAccessHelper.PhotoAsset | undefined =
      await PhotoAccessUtil.getPhotoAssetByUri(this.context as common.Context, srcFileInfo.uri);
    if (!photoAsset) {
      HiLog.warn(TAG, 'get src file asset fail.')
      return;
    }

    let srcAlbumUri: string = VirtualUri.GALLERY_URI + '/' + photoAsset.get('owner_album_id');
    let srcAlbum: photoAccessHelper.Album | undefined =
      await PhotoAccessUtil.getAlbumByUri(this.context as common.Context, srcAlbumUri);
    if (!srcAlbum) { // todo 源相册找不到处理
      HiLog.error(TAG, 'src album is null.');
      return;
    }
    if (!await PhotoAccessUtil.movePhotoAssetsToAlbum(this.context as common.Context,
      [photoAsset], srcAlbum, destAlbumInfo)) {
      HiLog.warn(TAG, 'Failed to move the file.');
      return;
    }

    // 总大小为0时，更新数量
    await this.computeProgress(this.totalSize === 0 ? 1 : srcFileInfo.size);
  }

  private syncFile(destUri: string): void {
    // 同步落盘,复制到外卡需要触发落盘，复制到本地不需要触发落盘
    if (destUri.startsWith(VirtualUri.MY_PC) || !this.isExternalOrAcrossDisk()) {
      return;
    }
    try {
      let file = fs.openSync(destUri, fs.OpenMode.READ_WRITE);
      if (!file) {
        return;
      }
      FsUtil.fsyncSync(file.fd);
      this.fsCloseFile(file);
    } catch (error) {
      HiLog.error(TAG, 'syncFile failed' + JSON.stringify(error));
    }
  }

  private async onErrorCatch(errorCode: number, srcFile?: FileInfo): Promise<string> {
    let uri = '';
    if (errorCode === ERROR_CODE.FILE_ACCESS.READONLY_FILE_SYSTEM) {
      HiLog.warn(TAG, 'readOnly file system');
      await this.dealError(ResultCode.Error.READONLY_FILE_SYSTEM);
      uri = await this.dealPasteFileAfterChoose();
    } else if (errorCode === ERROR_CODE.FILE_ACCESS.FILE_NOT_EXIST) {
      await this.dealError(ResultCode.Error.SRC_FILE_NOT_EXIST);
      uri = await this.dealPasteFileAfterChoose(srcFile);
    } else if (errorCode === ERROR_CODE.FILE_ACCESS.NO_SPACE_LEFT_ON_DEVICE) {
      HiLog.warn(TAG, 'size is not enough');
      await this.dealError(ResultCode.Error.NO_SPACE_LEFT);
    } else if (errorCode === ERROR_CODE.FILE_ACCESS.FILE_OPERATE_NOT_PERMITTED) {
      HiLog.warn(TAG, 'operate not permitted');
      await this.dealError(ResultCode.Error.FILE_OPERATE_NOT_PERMITTED);
      uri = await this.dealPasteFileAfterChoose(srcFile);
    } else if (errorCode === ERROR_CODE.FILE_ACCESS.FILE_NAME_INVALID) {
      HiLog.warn(TAG, 'file name invalid');
      await this.dealError(ResultCode.Error.FILE_NAME_INVALID);
      uri = await this.dealPasteFileAfterChoose(srcFile);
    } else if (errorCode === ERROR_CODE.FILE_ACCESS.OPERATION_CANCELED) {
      // 过滤取消拷贝错误码
      HiLog.info(TAG, 'operation canceled');
    } else if (errorCode === ResultCode.Error.ERROR_GALLERY_ROOT_PASTER) { // 图库根路径下粘贴内容包含文件
      await this.dealError(ResultCode.Error.ERROR_GALLERY_ROOT_PASTER);
    } else {
      HiLog.warn(TAG, 'operation failed');
      await this.dealError(ResultCode.Error.UNKNOWN_ERROR);
      uri = await this.dealPasteFileAfterChoose();
    }
    return uri;
  }

  private async pasteFileByBuffer(srcFileUri: string, destUri: string): Promise<boolean> {
    if ((!srcFileUri) || (!destUri)) {
      HiLog.warn(TAG, 'paste FileByBuffer, params are err');
      return false;
    }
    HiLog.infoPrivate(TAG, 'paste FileByBuffer start', `src: ${srcFileUri}, destFileUri : ${destUri}`);
    let needDelete: boolean = false;
    let srcFile: fs.File | undefined;
    let destFile: fs.File | undefined;
    try {
      srcFile = fs.openSync(srcFileUri, fs.OpenMode.READ_ONLY);
      HiLog.info(TAG, 'open src file');
      const destPath = FileUtil.getPathFromUri(destUri);
      destFile = fs.openSync(destPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.SYNC);
      HiLog.info(TAG, 'open dest file');

      let isDone = false;
      let completedSize = 0;
      let buf = new ArrayBuffer(PASTE_BUFFER);
      while (!isDone) {
        if (this.isCancel) {
          HiLog.warn(TAG, 'paste FileByBuffer canceled');
          break;
        }
        let readLen = fs.readSync(srcFile.fd, buf);
        let writeLen = fs.writeSync(destFile.fd, buf, { length: readLen });
        completedSize += writeLen;
        isDone = readLen === 0;
        await this.computeProgress(writeLen);
      }

      // 明确的空文件场景
      if (completedSize === 0 && !this.isCancel) {
        await this.computeProgress(1);
        return true;
      }
      // 如果取消了，并且当前粘贴的文件未完成
      if (this.isCancel && !isDone) {
        needDelete = true;
        return false;
      }
      HiLog.info(TAG, 'paste FileByBuffer success');
    } catch (err) {
      HiLog.error(TAG, 'paste FileByBuffer err = ' + JSON.stringify(err));
      needDelete = true;
      throw err as Error;
    } finally {
      if (srcFile) {
        this.fsCloseFile(srcFile);
      }
      if (destFile) {
        this.fsCloseFile(destFile);
      }
      if (needDelete) {
        HiLog.warn(TAG, 'needDelete.');
        FsUtil.forceDelete(destUri);
      }
    }
    return !needDelete;
  }

  private async pastePhotoFileToLocal(photoAsset: photoAccessHelper.PhotoAsset, destFileUri: string): Promise<boolean> {
    let res: boolean = false;
    let photoSubType = photoAsset.get(photoAccessHelper.PhotoKeys.PHOTO_SUBTYPE) as photoAccessHelper.PhotoSubtype;
    if (photoSubType !== photoAccessHelper.PhotoSubtype.MOVING_PHOTO) {
      res = await this.copyFileContent(photoAsset.uri, destFileUri);
    } else {
      try {
        res = await PhotoAccessUtil.copyMovingImage(photoAsset, destFileUri, this.context, true);
        if (res) {
          let photoSize: number = photoAsset.get(photoAccessHelper.PhotoKeys.SIZE) as number;
          await this.computeProgress(photoSize === 0 ? 1 : photoSize);
        }
      } catch (err) {
        HiLog.warn(TAG, `copyMovingImage failed. message: ${err?.message}`);
        throw err as Error;
      }
    }
    return res;
  }

  private checkFavoriteParams(oldPath: string, newPath: string, newFileName: string): boolean {
    let pathUriUndefined: boolean = ObjectUtil.isNullOrUndefined(oldPath) ||
    ObjectUtil.isNullOrUndefined(newPath) || ObjectUtil.isNullOrUndefined(newFileName);
    if (pathUriUndefined) {
      HiLog.warn(TAG, 'oldPath or newFileUri is Undefined');
      return false;
    }
    let pathUriEmpty: boolean =
      StringUtil.isEmpty(oldPath) || StringUtil.isEmpty(newPath) || StringUtil.isEmpty(newFileName);
    if (pathUriEmpty) {
      HiLog.warn(TAG, 'oldPath or newFileUri is empty');
      return false;
    }
    return true;
  }

  private updateFavoriteData(
    favorite: FavoriteModel,
    newDeviceType: DataSourceDeviceType,
    newPath: string,
    newFileName: string,
    newUuid: string,
    deleteLocalPathList: string[],
    deleteCloudPathList: string[]): boolean {
    deleteLocalPathList.push(favorite.path);
    favorite.path = newPath;
    favorite.name = newFileName;
    favorite.deviceType = newDeviceType;
    favorite.externalStorageUUID = newUuid;
    return false;
  }

  private getDeviceType(newUuid: string): DataSourceDeviceType {
    let deviceType = DataSourceDeviceType.DEVICE_EXTERNAL;
    if (StringUtil.isEmpty(newUuid)) {
      deviceType = DataSourceDeviceType.DEVICE_INTERNAL;
    }
    return deviceType;
  }

  private listFileSync(path: string): string[] {
    return fs.listFileSync(path);
  }

  private async handlerFolderSubFile(srcFile: FileInfo, destFolderUri: string): Promise<string> {
    let newUri: string = '';
    if (srcFile.isFolder) {
      newUri = await this.handleSubFolder(srcFile, destFolderUri);
    } else {
      newUri = await this.handlerSubFile(srcFile, destFolderUri);
    }
    return newUri;
  }

  private async handleSubFolder(srcFile: FileInfo, destFolderUri: string): Promise<string> {
    let newUri: string = '';
    if (ThreadCommonUtil.isChildFolder(srcFile.uri, destFolderUri)) {
      HiLog.info(TAG, 'handle paste to child folder');
      await this.dealException(ResultCode.Exception.CANNOT_PASTE_TO_SUB_FOLDER);
      await this.dealPasteFileAfterChoose(srcFile, destFolderUri);
      return newUri;
    }
    if (FsUtil.isExistDupName(destFolderUri, RenameUtil.getEscapedFolderName((srcFile.fileName)))) {
      HiLog.infoPrivate(TAG, 'handleSubFolder, exist duplicate folder, name: ', srcFile.fileName);
      await this.dealException(ResultCode.Exception.EXIST_DUPLICATE_FOLDER);
      await this.dealPasteFileAfterChoose(srcFile, destFolderUri);
    } else {
      newUri = await this.handleFolderAfterConflict(srcFile, destFolderUri);
    }
    return newUri;
  }

  private async handleFolderAfterConflict(srcFile: FileInfo, destFolderUri: string): Promise<string> {
    let newUri: string = '';
    if (this.operateType === WorkerConst.OperateType.CUT_FILE) {
      newUri = await this.moveFolder(srcFile, srcFile.fileName, destFolderUri);
    } else {
      newUri = await this.createFolderAndCopyContent(srcFile.fileName, srcFile, destFolderUri);
    }
    return newUri;
  }

  private async handlerSubFile(srcFile: FileInfo, destFolderUri: string): Promise<string> {
    let newUri: string = '';
    if (FsUtil.isExistDupName(destFolderUri, RenameUtil.getEscapedFileName(srcFile.fileName))) {
      HiLog.infoPrivate(TAG,
        'handlerSubFile, exist duplicate file, name: ', srcFile.fileName + ResultCode.Exception.EXIST_DUPLICATE_FILE);
      await this.dealException(ResultCode.Exception.EXIST_DUPLICATE_FILE);
      await this.dealPasteFileAfterChoose(srcFile, destFolderUri);
    } else {
      newUri = await this.handleFileAfterConflict(srcFile, destFolderUri);
    }
    return newUri;
  }

  private async handleFileAfterConflict(srcFile: FileInfo, destFolderUri: string): Promise<string> {
    let newUri: string = '';
    if (this.operateType === WorkerConst.OperateType.CUT_FILE) {
      newUri = await this.moveFile(srcFile, srcFile.fileName, destFolderUri);
    } else {
      newUri = await this.createFileAndCopyContent(srcFile.fileName, srcFile, destFolderUri);
    }
    return newUri;
  }

  // 任务交互相关

  private getNotifyUri(isEnd: boolean): string {
    if (isEnd) {
      return this.destFolderUri;
    }
    // 过程总先返回源目录uri，空则返回目标目录uri
    if (!this.srcFolderUri) {
      return this.destFolderUri;
    }
    return this.srcFolderUri;
  }

  /**
   * 移动文件至目标路径下
   * @param srcFile 源文件FileInfo
   * @param srcFileName 源文件名称
   * @param destFolderUri 目标路径uri
   */
  private async moveFile(srcFile: FileInfo, srcFileName: string, destFolderUri: string): Promise<string> {
    let newFileUri: string = '';
    this.operatingFile.fileName = srcFileName;
    try {
      let srcFileInfo: uri.URI = new fileuri.FileUri(srcFile.uri);
      // 跨盘和图库图片剪切走复制、删除逻辑, fs.moveFileSync接口不支持，先规避
      // 东湖文件move，属于跨盘，先走copy
      if (this.isOperatingAcrossDisk || srcFile.isGallery) {
        newFileUri = await this.createFileAndCopyContent(srcFileName, srcFile, destFolderUri);
        if (newFileUri === '') { // 失败时，newFileUri为空，不继续执行，不删除源文件
          return '';
        }
        if (srcFile.isGallery) {
          await PhotoAccessUtil.deletePermanently(this.context, srcFile.uri)
          HiLog.warn(TAG, 'moveFile is gallery file, src file delete.');
        } else {
          fs.unlinkSync(srcFileInfo.path);
        }
      } else {
        if (RenameUtil.checkSpecialChar(srcFileName)) {
          HiLog.warn(TAG, 'file name invalid');
          throw new FileAccessError(ERROR_CODE.FILE_ACCESS.FILE_NAME_INVALID, 'file name invalid');
        }
        // 移动之前获取
        let progressDiff = await this.getProgressDiff(this.operatingFile);
        let destFolderInfo: uri.URI = new fileuri.FileUri(destFolderUri);
        let destPath = destFolderInfo.path + '/' + RenameUtil.getEscapedFileName(srcFileName);
        fs.moveFileSync(srcFileInfo.path, destPath, MOVE_FILE_MODE);
        // 更新时间
        fs.utimes(destPath, new Date().getTime())
        await this.computeProgress(progressDiff);
        newFileUri = destFolderUri + '/' + FileUtil.encodeURIForFileManager(srcFileName);
      }
    } catch (err) {
      HiLog.error(TAG, 'doMove, moveFile err：' + JSON.stringify(err));
      HiSysEventUtil.reportFailureEvent(HiSysEventName.FILE_OPERATE_FAIL, InterfaceName.MOVE_FILE,
        (err as BusinessError).code);
      throw err as Error;
    }
    return newFileUri;
  }

  /**
   * 移动文件夹至目标路径下
   * @param srcFolder 文件夹FileInfo
   * @param destFolderUri 目标路径uri
   */
  private async moveFolder(srcFolder: FileInfo, srcFolderName: string, destFolderUri: string): Promise<string> {
    let newFileUri: string = '';
    try {
      if (srcFolder.uri.startsWith(VirtualUri.GALLERY_URI)) {
        let destFileInfo: uri.URI = new fileuri.FileUri(destFolderUri);
        let subFolderPath = destFileInfo.path + '/' + RenameUtil.getEscapedFolderName(srcFolder.fileName);
        HiLog.info(TAG, 'moveFolder create folder.');
        FsUtil.mkdirSync(subFolderPath);
        let subFolderUri = destFolderUri + '/' +
        FileUtil.encodeURIForFileManager(RenameUtil.getEscapedFolderName(srcFolder.fileName));
        await this.pasteAlbumContent(srcFolder, subFolderUri, true);
        return destFolderUri;
      }
      if (this.isOperatingAcrossDisk) {
        newFileUri = await this.createFolderAndCopyContent(srcFolderName, srcFolder, destFolderUri, true);
        await this.dealMoveFolderUpdateFavorite(srcFolder.relativePath, newFileUri);
      } else {
        let progressDiff = await this.getProgressDiff(this.operatingFile);
        let srcFolderInfo: uri.URI = new fileuri.FileUri(srcFolder.uri);
        let destFolderInfo: uri.URI = new fileuri.FileUri(destFolderUri);
        fs.moveDirSync(srcFolderInfo.path, destFolderInfo.path, MOVE_FILE_MODE);
        if (RenameUtil.checkSpecialChar(srcFolderName)) {
          const escapedName = RenameUtil.getEscapedFolderName(srcFolderName);
          HiLog.infoPrivate(TAG, `moveFolder `, `escapedName = ${escapedName} destFolderInfo = ${destFolderInfo.path}`);
          fs.renameSync(destFolderInfo.path + '/' + srcFolderName, destFolderInfo.path + '/' + escapedName);
          srcFolderName = escapedName;
        }
        newFileUri = destFolderUri + '/' + FileUtil.encodeURIForFileManager(srcFolderName);
        await this.dealMoveFolderUpdateFavorite(srcFolder.relativePath, newFileUri);
        await this.computeProgress(progressDiff);
      }
    } catch (err) {
      this.notifyFailCount++;
      HiLog.error(TAG, 'doMove, moveFolder err：' + JSON.stringify(err));
      HiSysEventUtil.reportFailureEvent(HiSysEventName.FILE_OPERATE_FAIL, InterfaceName.MOVE_FOLDER,
        (err as BusinessError).code);
      throw err as Error;
    }
    return newFileUri;
  }

  /**
   * 开启定时器，定时更新操作进度
   * @param workerPort 线程端口
   * @param workerName 线程名称
   * @param operateType 操作类型
   */
  private startTimer(): void {
    HiLog.info(TAG, 'start timer');
    this.timer = setInterval(() => {
      this.refreshProgress();
    }, INTERVAL_TIME);
  }

  /**
   * 关闭定时器
   */
  private stopTimer(): void {
    HiLog.info(TAG, 'stop timer');
    if (!ObjectUtil.isNullOrUndefined(this.timer)) {
      clearInterval(this.timer);
    }
  }

  private checkNeedDealException(exceptionCode: ResultCode.Exception): boolean {
    this.conflictType = this.transErrCodeToConflictType(exceptionCode);
    if ((exceptionCode === ResultCode.Exception.EXIST_DUPLICATE_FILE) && this.isFileApplyAll) {
      return false;
    } else if ((exceptionCode === ResultCode.Exception.EXIST_DUPLICATE_FOLDER) && this.isFolderApplyAll) {
      return false;
    } else if (this.isOtherErrorApplyAll) {
      return false;
    } else {
      return true;
    }
  }

  private transErrCodeToConflictType(errCode: CopyCutConst.ConflictType): number {
    let conflictType = CopyCutConst.ConflictType.FILE_DEFAULT;
    switch (errCode) {
      case ResultCode.Exception.EXIST_DUPLICATE_FILE:
        conflictType = CopyCutConst.ConflictType.FILE_CONFLICT;
        break;
      case ResultCode.Exception.EXIST_DUPLICATE_FOLDER:
        conflictType = CopyCutConst.ConflictType.FOLDER_CONFLICT;
        break;
      default:
      // 其余异常认为失败
        conflictType = CopyCutConst.ConflictType.OTHER_ERROR;
        break;
    }
    return conflictType;
  }

  /**
   * 发送异常信息
   * @param exceptionCode 异常码
   */
  private sendException(exceptionCode: ResultCode.Exception): void {
    HiLog.info(TAG, 'sendException, exceptionCode: ' + exceptionCode);
    this.waitOperate = true;
    let copyCutResultParam = new CopyCutResultParam(
      this.workerName,
      WorkerConst.WorkerStatus.RUNNING,
      WorkerConst.ResultType.EXCEPTION,
      this.operateType,
      this.operatingFile.fileName,
      this.pasteProgressRate
    );
    copyCutResultParam.isShowApplyAll = this.operatingFile.isFolder ? this.chooseFolderMulti : this.chooseFileMulti;
    copyCutResultParam.operatingFileIsFolder = this.operatingFile.isFolder;
    copyCutResultParam.exceptionCode = exceptionCode;
    copyCutResultParam.fileNum = this.totalCount;
    copyCutResultParam.destFolderUri = this.destFolderUri;
    copyCutResultParam.operatingFileUri = this.operatingFile.uri;
    copyCutResultParam.isShowProgressBar = this.isShowProgressBar;
    copyCutResultParam.isExternalOperate = this.isExternalOperate;
    copyCutResultParam.totalCount = this.totalCount;
    copyCutResultParam.isFileInitError = this.isFileInitError;
    this.conflictParam = copyCutResultParam;
    this.workerPort!!.postMessage(copyCutResultParam);
  }

  private checkNeedDealError(errorCode: ResultCode.Error): boolean {
    this.conflictType = this.transResultCodeToConflictType(errorCode);
    if ((errorCode === ResultCode.Error.SRC_FILE_NOT_EXIST) && this.isPathApplyAll) {
      return false;
    } else if (this.isOtherErrorApplyAll) {
      return false;
    } else if (errorCode === ResultCode.Error.NO_SPACE_LEFT) {
      this.sendError(errorCode);
      return false;
    } else {
      return true;
    }
  }

  private transResultCodeToConflictType(errorCode: ResultCode.Error): number {
    let conflictType = CopyCutConst.ConflictType.FILE_DEFAULT;
    switch (errorCode) {
      case ResultCode.Error.SRC_FILE_NOT_EXIST:
        conflictType = CopyCutConst.ConflictType.PATH_CONFLICT;
        break;
      default:
      // 其余异常认为失败
        conflictType = CopyCutConst.ConflictType.OTHER_ERROR;
        break;
    }
    return conflictType;
  }

  /**
   * 发送错误信息
   * @param errorCode 错误码
   */
  private sendError(errorCode: ResultCode.Error): void {
    HiLog.info(TAG, 'sendError, errorCode: ' + errorCode);
    this.waitOperate = true;
    let copyCutResultParam = new CopyCutResultParam(
      this.workerName,
      WorkerConst.WorkerStatus.RUNNING,
      WorkerConst.ResultType.ERROR,
      this.operateType,
      this.operatingFile.fileName,
      this.pasteProgressRate
    );
    copyCutResultParam.operatingFileIsFolder = this.operatingFile.isFolder;
    copyCutResultParam.isShowApplyAll = this.operatingFile.isFolder ? this.chooseFolderMulti : this.chooseFileMulti;
    copyCutResultParam.errorCode = errorCode;
    copyCutResultParam.destFolderUri = this.destFolderUri;
    copyCutResultParam.operatingFileUri = this.operatingFile.uri;
    copyCutResultParam.isExternalOperate = this.isExternalOperate;
    copyCutResultParam.totalCount = this.totalCount;
    copyCutResultParam.isShowProgressBar = this.isShowProgressBar;
    copyCutResultParam.isFileInitError = this.isFileInitError;
    this.conflictParam = copyCutResultParam;
    this.workerPort!!.postMessage(copyCutResultParam);
  }

  /**
   * 刷新进度
   * @param workerPort worker端口
   * @param workerName worker名称
   * @param operateType 操作类型
   */
  private refreshProgress(): void {
    if (!this.workerPort) {
      HiLog.warn(TAG, 'workerPort is null when refreshProgress');
      return;
    }
    if (this.waitOperate) {
      return;
    }
    if (this.lastSendPasteProgressRate >= this.pasteProgressRate) {
      HiLog.info(TAG, `last progress : ${this.workerName}, current Progress: ${this.pasteProgressRate}`);
      return;
    }
    HiLog.warnPrivate(TAG, `refreshProgress, workerName: `, `${this.workerName}, Progress: ${this.pasteProgressRate}`);
    let sendData = new CopyCutResultParam(
      this.workerName,
      WorkerConst.WorkerStatus.RUNNING,
      WorkerConst.ResultType.PROGRESS,
      this.operateType,
      this.operatingFile.fileName,
      this.pasteProgressRate
    );
    sendData.completeSize = this.progressSize;
    sendData.totalSize = this.totalSize;
    sendData.notifyUri = this.getNotifyUri(false);
    sendData.isShowProgressBar = this.isShowProgressBar;
    sendData.isExternalOperate = this.isExternalOperate;
    sendData.destFolderUri = this.destFolderUri;
    sendData.completeCount = this.completeCount;
    sendData.totalCount = this.totalCount;
    sendData.isFileInitError = this.isFileInitError;
    this.workerPort.postMessage(sendData);
  }

  /**
   * 任务结束
   */
  private taskEnd(): void {
    try {
      HiLog.info(TAG, 'task end');
      // 关闭定时器
      this.stopTimer();
      // 通知主线程结束
      this.sendTaskEnd();
    } catch (error) {
      HiLog.error(TAG, 'taskEnd error: ' + error.toString());
    }
  }

  /**
   * 通知主线程任务结束
   */
  private sendTaskEnd(): void {
    try {
      let copyCutResultParam = new CopyCutResultParam(
        this.workerName,
        this.isCancel ? WorkerConst.WorkerStatus.CANCEL : WorkerConst.WorkerStatus.SUCCESS,
        WorkerConst.ResultType.SUCCESS,
        this.operateType,
        this.operatingFile.fileName,
        this.pasteProgressRate
      );
      copyCutResultParam.pasteFilesRes = this.pasteFilesRes;
      copyCutResultParam.destFolderUri = this.destFolderUri;
      copyCutResultParam.successCount = this.notifySuccessCount;
      copyCutResultParam.totalCount = this.totalCount;
      copyCutResultParam.failCount = this.notifyFailCount;
      copyCutResultParam.completeCount = this.completeCount;
      copyCutResultParam.notifyUri = this.getNotifyUri(true);
      copyCutResultParam.isShowProgressBar = this.isShowProgressBar;
      this.workerPort!!.postMessage(copyCutResultParam);
      HiLog.info(TAG, 'sendTaskEnd');
    } catch (error) {
      HiLog.error(TAG, 'sendTaskEnd error: ' + JSON.stringify(error));
    }
  }

  private getChooseType(): CopyCutConst.ChooseType {
    let chooseType = CopyCutConst.ChooseType.DEFAULT;
    switch (this.conflictType) {
      case CopyCutConst.ConflictType.FILE_CONFLICT:
        chooseType = this.fileApplyChoose;
        break;
      case CopyCutConst.ConflictType.FOLDER_CONFLICT:
        chooseType = this.folderApplyChoose;
        break;
      case CopyCutConst.ConflictType.PATH_CONFLICT:
        chooseType = this.pathApplyChoose;
        break;
      case CopyCutConst.ConflictType.OTHER_ERROR:
        chooseType = this.otherErrorApplyChoose;
        break;
      default:
        break;
    }
    return chooseType;
  }

  private getChooseConflict(): CopyCutConst.ChooseType {
    return this.getChooseType();
  }

  private async onFileSkip(srcFile?: FileInfo): Promise<void> {
    await this.computeProgress(await this.getProgressDiff(srcFile!!));
  }

  private async getProgressDiff(srcFile: FileInfo): Promise<number> {
    let diff = 0;
    try {
      if (this.totalSize === 0) {
        diff++;
        if (srcFile.isFolder) {
          diff += await FileUtil.getFolderSubFileCount(srcFile.uri, true, true);
        }
      } else {
        diff = await StorageUtil.getFilesSize([srcFile]);
      }
    } catch (error) {
      HiLog.error(TAG, 'getProgressDiff error ' + error.toString());
    }
    return diff;
  }

  private async computeProgress(progressDiff: number): Promise<void> {
    if (progressDiff === 0) {
      return;
    }
    let lastProgress = this.pasteProgressRate;
    // 规格：如果全部为空文件，按文件个数计算进度，否则按照大小。
    if (this.totalSize === 0) {
      this.completeCount += progressDiff;
      this.pasteProgressRate =
        Math.min(Math.ceil((this.completeCount / this.totalCount) * PROGRESS_COMPUTE_CONST), MAX_LIMITED_PROGRESS);
    } else {
      this.progressSize += progressDiff;
      this.pasteProgressRate =
        Math.min(Math.ceil((this.progressSize / this.totalSize) * PROGRESS_COMPUTE_CONST), MAX_LIMITED_PROGRESS);
    }
    if ((this.pasteProgressRate - lastProgress) >= BREAK_PASTE_CYCLE_THREAD) {
      HiLog.info(TAG, `pasteProgressRate: ${this.pasteProgressRate}`);
      await TimeUtil.sleep(1);
    }
  }
}
