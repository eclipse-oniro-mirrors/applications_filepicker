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

import type { ThreadWorkerGlobalScope } from '@ohos.worker';
import { ObjectUtil } from '../../utils/ObjectUtil';
import { HiLog } from '../../dfx/HiLog';
import DeleteRestoreConst from '../../workermanager/deleterestoremanager/DeleteRestoreConst';
import { DeleteRestoreResultParam } from '../../workermanager/deleterestoremanager/DeleteRestoreResultParam';
import WorkerConst from '../../worker/WorkerConst';
import type common from '@ohos.app.ability.common';
import { FileInfo } from '../../fileoperate/FileInfo';
import fs from '@ohos.file.fs';
import fileuri from '@ohos.file.fileuri';
import { ResultCode } from '../../worker/ResultCode';
import type { BusinessError } from '@ohos.base';
import { TimeUtil } from '../../utils/TimeUtil';
import type { DeleteRestoreSendParam } from '../../workermanager/deleterestoremanager/DeleteRestoreSendParam';
import { StringUtil } from '../../utils/StringUtil';
import { DiskInfo } from '../../externel/DiskInfo';
import { ArrayUtil } from '../../utils/ArrayUtil';
import { FsUtil } from '../../utils/FsUtil';
import { FileUtil } from '../../fileoperate/FileUtil';
import { ERROR_CODE } from '../../const/ErrorCode';
import type { FavoriteModel } from '../../model/FavoriteModel';
import { Constant, DataSourceDeviceType } from '../../const/Constant';
import { HiSysEventUtil } from '../../dfx/HiSysEventUtil';
import { HiSysEventName, InterfaceName } from '../../const/HiSysEventConst';
import lazy { filemanager } from '../../model/filetag/FileManager';
import { FileOperation } from '../../fileoperate/FileOperation';
import { AuditLogUtils } from '../../utils/AuditLogUtils';
import lazy { PhotoAccessUtil } from '../../utils/PhotoAccessUtil';
import { VirtualUri } from '../../const/FolderRecord';
import preferences from '@ohos.data.preferences';
import lazy { photoAccessHelper } from '../../../../../indexLazyLoadTs';
import { MyPhoneConstant } from '../../const/MyPhoneConstant';
import { ExternalStorageUtil } from '../../externel/ExternalStorageUtil';
import { dataSharePredicates } from '@kit.ArkData';
import { DataPreferenceUtil } from '../../utils/DataPreferenceUtil';
import lazy TrashNapi from 'libTrash.so';

const TAG = 'FileDeleteUtil';
const PROGRESS_COMPUTE_CONST = 100;
const UPDATE_BACKUP_PATH = '/UpdateBackup/RecycleBin';
/**
 * 刷新间隔时间：500毫秒
 */
const INTERVAL_TIME: number = 500;
const IMAGE_SIZE_FILTER_DEFAULT: number = 30;
const IMAGE_SIZE_FILTER_TRANS: number = 1000;
const BATCH_SEARCH_MAX_COUNT = 200; // 批次查询返回的最大文件数
const BATCH_GALLERY_MAX_COUNT = 200; // 单次删除图库文件的最大数量

export class FileDeleteUtil {
  /**
   * 操作上下文对象
   */
  public context?: common.Context;
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
   * 文件总数量
   */
  public totalCount: number = 0;
  /**
   * 已完成数量
   */
  public completeCount: number = 0;
  /**
   * 当前正在操作的文件名
   */
  public operatingFile: FileInfo = new FileInfo();
  /**
   * 等待用户操作结果
   */
  public waitOperate: boolean = false;
  /**
   * 任务是否取消
   */
  public isCancel: boolean = false;
  /**
   * 任务是否停止
   */
  public isStop: boolean = false;
  /**
   * 是否还原至双升单备份目录：我的手机/升级备份/RecycleBin
   */
  public isToBackupPath: boolean = false;
  /**
   * 删除还原进度比例
   */
  public deleteOrRestoreProgressRate: number = 0;
  /**
   * 定时器,用于刷新进度
   */
  public timer: number = 0;
  /**
   * 冲突选择结果
   */
  public conflictHandleResult?: DeleteRestoreConst.ChooseType;
  /**
   * 是否应用到全部
   */
  public isApplyToAll: boolean = false;
  /**
   * 硬删除外卡uuid集合，用于促发落盘
   */
  public hardDeleteSyncUuidSet: Set<string> = new Set();
  /**
   * 失败文件数量
   */
  public failFileCount: number = 0;
  /**
   * 失败文件名称
   */
  public failFileName: string = '';
  /**
   * 一批成功的文件uris
   */
  public successUris: string[] = [];
  /**
   * 待处理的图库uri列表
   */
  public galleryUris: string[] = [];
  /**
   * 待处理的图库文件总数
   */
  public totalGalleryCount: number = 0;
  /**
   * 图库文件已完成数量
   */
  public completeGalleryCount: number = 0;
  /**
   * 回收站变化的文件数量，用于快速刷新最近删除显示项数
   */
  public trashChangeCount: number = 0;
  /**
   * 收藏缓存
   */
  public favoriteCache?: FavoriteModel[];
  /**
   * 正在还原的文件uri
   */
  public resolverUri: string = '';
  /**
   * 是否聚合视图下删除操作，
   */
  public mediaSearchType: number = -1;

  /**
   * 处理消息
   * @param copyCutSendParam 发送参数
   * @returns
   */
  public async dealMessage(deleteRestoreSendParam: DeleteRestoreSendParam): Promise<void> {
    if (ObjectUtil.isNullOrUndefined(deleteRestoreSendParam)) {
      HiLog.info(TAG, 'dealMessage copyCutSendParam is null');
      return;
    }
    let msgCode = deleteRestoreSendParam.msgCode;
    HiLog.info(TAG, 'msgCode: ' + msgCode);
    switch (msgCode) {
      case DeleteRestoreConst.SendMsgCode.START:
        // 开始任务
        this.startDeleteOrRestoreTask(deleteRestoreSendParam);
        break;
      case DeleteRestoreConst.SendMsgCode.CONFLICT:
        this.conflictHandleResult = deleteRestoreSendParam.conflictHandleResult;
        HiLog.info(TAG, 'isApplyToAll: ' + deleteRestoreSendParam.isApplyToAll);
        this.isApplyToAll = deleteRestoreSendParam.isApplyToAll;
        this.waitOperate = false;
        break;
      case DeleteRestoreConst.SendMsgCode.CANCEL:
        this.isCancel = true;
        this.postCancelMessage();
        break;
      default:
        break;
    }
  }

  /**
   * 开始执行复制粘贴任务
   * @param copyCutSendParam
   */
  public async startDeleteOrRestoreTask(deleteRestoreSendParam: DeleteRestoreSendParam): Promise<void> {
    try {
      HiLog.info(TAG, 'startDeleteOrRestoreTask');
      if (!this.initAndCheckData(deleteRestoreSendParam)) {
        return;
      }
      let toOperateFiles = deleteRestoreSendParam.toOperateFiles;
      HiLog.info(TAG, 'startDeleteOrRestoreTask file length: ' + toOperateFiles.length);
      // 开启定时刷新
      this.refreshProgress();
      this.startTimer();
      if (this.operateType === WorkerConst.OperateType.DELETE_FILE) {
        await this.doDelete(deleteRestoreSendParam);
      } else if (this.operateType === WorkerConst.OperateType.RESTORE_FILE) {
        await this.doRestore(deleteRestoreSendParam);
      } else if (this.operateType === WorkerConst.OperateType.SOFT_DELETE_FILE) {
        await this.softDelete(deleteRestoreSendParam);
      }
      this.hardSync(deleteRestoreSendParam.diskInfoList);
    } catch (err) {
      HiLog.error(TAG, 'startDeleteOrRestoreTask error: ' + JSON.stringify(err));
    }
    this.refreshProgress();
    this.taskEnd();
  }

  /**
   * 执行删除操作
   * @param deleteRestoreSendParam 删除还原发送参数
   */
  public async doDelete(deleteRestoreSendParam: DeleteRestoreSendParam): Promise<void> {
    HiLog.info(TAG, 'doDelete workerName: ' + this.workerName);
    let toOperateFiles: FileInfo[] = deleteRestoreSendParam.toOperateFiles;
    if (this.mediaSearchType !== -1) {
      toOperateFiles = await this.reBuildFileList(deleteRestoreSendParam);
    }
    let taskType: DeleteRestoreConst.TaskType = deleteRestoreSendParam.taskType;
    this.deleteOrRestoreProgressRate = 0;
    const fileNameList: string[] = [];
    this.galleryUris = [];
    try {
      for (let i = 0; i < toOperateFiles.length; i++) {
        if (this.isCancel) {
          HiLog.info(TAG, 'doDelete is cancel, taskType:' + taskType);
          return;
        }
        const file = toOperateFiles[i];
        let result = false;
        // 区分硬删除的不同场景，直接彻底删除和从回收站彻底删除
        if (taskType === DeleteRestoreConst.TaskType.PERMANENT_DELETE && file.uri.startsWith(VirtualUri.GALLERY_URI) &&
        file.isFolder) {
          // 图库文件不支持收藏，因此不需要返回值去更新收藏列表
          HiLog.info(TAG, 'doDelete : file is Gallery and file is folder');
          await this.deleteAlbumForManager(deleteRestoreSendParam.context, file.uri, this.mediaSearchType, false);
        } else if (taskType === DeleteRestoreConst.TaskType.PERMANENT_DELETE &&
        file.uri.startsWith(VirtualUri.GALLERY_PHOTO_URI) &&
          !file.isFolder) {
          // 图库文件不支持收藏，因此不需要返回值去更新收藏列表
          HiLog.info(TAG, 'doDelete : file is Gallery and file is not folder');
          await this.deleteGalleryFilePermanently(deleteRestoreSendParam.context, file.uri);
        } else if (taskType === DeleteRestoreConst.TaskType.PERMANENT_DELETE) {
          this.operatingFile = file;
          result = this.permanentDelete(file);
        } else if (taskType === DeleteRestoreConst.TaskType.DELETE_FILE_FROM_TRASH) {
          result = await this.deleteFileInTrash(file, deleteRestoreSendParam.context);
        }
        if (i === toOperateFiles.length - 1) {
          // 清空批量删除时不足一批暂存的文件
          await this.deleteGalleryFilePermanently(deleteRestoreSendParam.context, '', true);
        }
        if (result && file.isFolder) {
          let updateFavoriteList = await this.getSubFavoriteListByPath(file.srcPath);
          this.updateFavoriteAfterHardDelete(file.srcPath, updateFavoriteList);
        }
        result && fileNameList.push(file.fileName);
        this.completeCount = i + 1;
        await this.considerRefreshProgress();
      }
      await this.deleteTempTrashList(deleteRestoreSendParam.context);
      AuditLogUtils.getInstance().batchWriteAudit(fileNameList, 'hardDelete');
    } catch (err) {
      HiLog.error(TAG, 'doDelete err: ' + JSON.stringify(err));
    }
  }

  /**
   * 永久删除文件
   * @param filePath 文件path
   */
  public permanentDeleteFile(filePath: string, fileName: string): boolean {
    let res = FsUtil.unlinkSync(filePath);
    if (res instanceof Error) {
      HiLog.error(TAG, 'permanentDeleteFile err: ' + JSON.stringify(res));
      if (res.code !== ERROR_CODE.FILE_ACCESS.FILE_NOT_EXIST) {
        this.failFileCount++;
        this.failFileName = fileName;
        return false;
      }
    }
    return true;
  }

  /**
   * 永久删除文件夹
   * @param filePath 文件path
   */
  public permanentDeleteFolder(filePath: string, fileName: string): boolean {
    let res = FsUtil.rmdirSync(filePath);
    if (res instanceof Error) {
      HiLog.error(TAG, 'permanentDeleteFolder err: ' + JSON.stringify(res));
      if (res.code !== ERROR_CODE.FILE_ACCESS.FILE_NOT_EXIST) {
        this.failFileCount++;
        this.failFileName = fileName;
        return false;
      }
    }
    HiLog.infoPrivate(TAG, 'permanentDeleteFolder success, filePath: ', filePath);
    return true;
  }

  // 删除文件相关方法

  public async deleteTempTrashList(context: Context, file?: FileInfo): Promise<boolean> {
    if (file) {
      this.galleryUris.push(file.uri);
      this.successUris.push(file.uri);
      this.trashChangeCount++;
    }
    if (this.galleryUris.length === BATCH_GALLERY_MAX_COUNT || !file && this.galleryUris.length !== 0) {
      try {
        await PhotoAccessUtil.deleteBatchPermanently(context, this.galleryUris);
        // 写审计日志
        AuditLogUtils.getInstance().batchWriteAudit(this.galleryUris, 'hardDelete');
        this.galleryUris = [];
      } catch (err) {
        HiLog.error(TAG, 'batch deleteFileInTrash err: ' + JSON.stringify(err));
        HiSysEventUtil.reportFailureEvent(HiSysEventName.FILE_OPERATE_FAIL, InterfaceName.TRASH_COMPLETELY_DELETE,
          (err as BusinessError).code);
        if (err.code !== ERROR_CODE.FILE_ACCESS.FILE_NOT_EXIST &&
          err.code !== ERROR_CODE.FILE_ACCESS.FILE_NOT_EXIST_SERVER) {
          this.failFileCount += this.galleryUris.length;
        }
      }
    }
    return false;
  }

  /**
   * 删除回收站中的文件
   * @param fileUri 文件uri
   */
  public async deleteFileInTrash(file: FileInfo, context: Context): Promise<boolean> {
    try {
      HiLog.infoPrivate(TAG, 'deleteFileInTrash start, fileUri: ', file.uri);
      if (file.isGallery) {
        return await this.deleteTempTrashList(context, file);
      } else {
        // 确保URI是正确编码的，特别是文件名部分
        let deleteUri: string = file.uri;

        // 修复文件名中含有%字符的问题：如果URI中的文件名部分没有正确编码，重新编码文件名
        if (deleteUri.includes('%')) {
          const fileUri: fileuri.FileUri = new fileuri.FileUri(deleteUri);
          const pathWithoutFilename = deleteUri.substring(0, deleteUri.lastIndexOf('/') + 1);
          const encodedFilename = encodeURIComponent(fileUri.name);
          deleteUri = pathWithoutFilename + encodedFilename;
          HiLog.infoPrivate(TAG, 'Fixed delete URI: ', deleteUri);
        }

        TrashNapi.deleteCompletely(deleteUri);
      }
      HiLog.infoPrivate(TAG, 'deleteFileInTrash end, fileUri: ', file.uri);
      this.addSuccessUris(file.uri, true);
    } catch (err) {
      HiLog.error(TAG, 'deleteFileInTrash err: ' + JSON.stringify(err));
      HiSysEventUtil.reportFailureEvent(HiSysEventName.FILE_OPERATE_FAIL, InterfaceName.TRASH_COMPLETELY_DELETE,
        (err as BusinessError).code);
      if (err.code !== ERROR_CODE.FILE_ACCESS.FILE_NOT_EXIST &&
        err.code !== ERROR_CODE.FILE_ACCESS.FILE_NOT_EXIST_SERVER) {
        this.failFileCount++;
        this.failFileName = file.fileName;
        return false;
      }
    }
    return true;
  }

  /**
   * 执行还原操作
   * @param deleteRestoreSendParam 删除还原发送参数
   */
  public async doRestore(deleteRestoreSendParam: DeleteRestoreSendParam): Promise<void> {
    HiLog.info(TAG, 'doRestore workerName: ' + this.workerName);
    let toOperateFiles: FileInfo[] = deleteRestoreSendParam.toOperateFiles;
    this.deleteOrRestoreProgressRate = 0;
    let specifiedDirUri = deleteRestoreSendParam.specifiedDir; // 目标文件夹uri
    let specifiedDirPath = StringUtil.isEmpty(specifiedDirUri) ? '' : FileUtil.getPathFromUri(specifiedDirUri);
    HiLog.infoPrivate(TAG, 'restoreToPath: ', specifiedDirPath);
    try {
      for (let i = 0; i < toOperateFiles.length; i++) {
        if (this.isStop || this.isCancel) {
          HiLog.info(TAG, 'recover is stop or cancel');
          return;
        }
        let file = toOperateFiles[i];
        this.operatingFile = file;
        // 拼接还原路径；file.relativePath是路径
        let restoreToPath = file.relativePath;
        if (!StringUtil.isEmpty(specifiedDirUri)) { // 注意：file.fileName有可能待时间戳后缀,要从relativePath取
          restoreToPath = specifiedDirPath + '/' + file.relativePath.substring(file.relativePath.indexOf('/'));
        }
        if (fs.accessSync(restoreToPath)) {
          await this.dealException(ResultCode.Exception.RECOVER_EXIST_SAME_NAME_FILE);
          await this.dealChooseResult(file, specifiedDirUri);
          continue;
        }
        // 判断还原备份路径 todo 后面改成equal绝对路径
        if (!this.isToBackupPath && restoreToPath.indexOf(UPDATE_BACKUP_PATH) !== -1) {
          this.isToBackupPath = true;
        }
        // 遗留小问题：当前进度刷新是每隔500ms刷新一次，单个大文件夹发送不出去发布出去
        this.resolverUri = file.uri;
        if (file.isGallery) {
          await this.restoreGalleryFile(deleteRestoreSendParam.context, file.uri);
        } else {
          await this.recoverFile(file, specifiedDirUri);
        }
        if (i === toOperateFiles.length - 1) {
          //批量还原，本地和图库混合场景，用来兜底图库文件还原
          await this.restoreGalleryFile(deleteRestoreSendParam.context, file.uri, true);
        }
        let destination: FileInfo = new FileInfo();
        // 直接使用restoreToPath构造URI，不需要再次encodeURI，避免%字符被重复编码
        destination = FileInfo.fromFileUri('file://docs' + restoreToPath);
        if (file.isFolder) {
          let favoriteList = await this.getSubFavoriteListByPath(file.srcPath, Constant.FILE_RECYCLED.DELETED);
          this.updateFavoriteAfterRestore(favoriteList);
        }
        // 更新进度
        this.completeCount = i + 1;
        await this.considerRefreshProgress();
      }
    } catch (err) {
      HiLog.error(TAG, 'doDelete err: ' + JSON.stringify(err));
    }
  }

  public async softDelete(deleteRestoreSendParam: DeleteRestoreSendParam): Promise<void> {
    HiLog.info(TAG, 'softDelete workerName: ' + this.workerName);
    let toOperateFiles: FileInfo[] = deleteRestoreSendParam.toOperateFiles;
    if (this.mediaSearchType !== -1) {
      toOperateFiles = await this.refreshFileList(deleteRestoreSendParam);
    }
    this.deleteOrRestoreProgressRate = 0;
    for (let i = 0; i < toOperateFiles.length; i++) {
      if (this.isCancel) {
        HiLog.info(TAG, 'delete from trash is cancel');
        return;
      }
      let file = toOperateFiles[i];
      let favoriteList: FavoriteModel[] = [];
      if (file.isFolder || !file.isGallery) {
        favoriteList = await this.getSubFavoriteListByPath(file.srcPath, Constant.FILE_RECYCLED.NORMAL);
      }

      let result = false;
      if (file.uri.startsWith(VirtualUri.EXTERNAL_DISK) || !StringUtil.isEmpty(file.storageDeviceUid)) {
        // 外卡文件直接调fs接口性能
        result = this.permanentDelete(file);
        this.hardDeleteSyncUuidSet.add(file.storageDeviceUid);
      } else if (file.isGallery && !file.isFolder) {
        // 图库文件不支持收藏，因此不需要返回值去更新收藏列表
        await this.deleteGalleryFile(deleteRestoreSendParam.context, file.uri);
      } else if (file.uri.startsWith(VirtualUri.GALLERY_URI) && file.isFolder) {
        // 直接删除图库相册
        HiLog.warn(TAG, 'softDelete : file.isGallery && file.isFolder');
        await this.deleteAlbumForManager(deleteRestoreSendParam.context, file.uri, this.mediaSearchType, true)
      } else {
        result = await this.deleteFileToTrash(file);
        // todo add destination after trash.delete return trash uri
      }
      if (i === toOperateFiles.length - 1) {
        // 清空批量处理暂存文件
        await this.deleteGalleryFile(deleteRestoreSendParam.context, '', true);
      }
      if (result && file.isFolder && (!ArrayUtil.isEmpty(favoriteList))) {
        this.updateFavoriteAfterSoftDelete(favoriteList);
      }
      this.completeCount = i + 1;
      await this.considerRefreshProgress();
    }
  }

  /**
   * 针对外部存储设备同步文件数据
   * @param diskInfoList 存储设备列表
   */
  hardSync(diskInfoList: DiskInfo[]): void {
    const uuidList = Array.from(this.hardDeleteSyncUuidSet);
    if (ArrayUtil.isEmpty(uuidList) || ArrayUtil.isEmpty(diskInfoList)) {
      return;
    }
    HiLog.info(TAG, 'enter hardSync, uuidList length:' + uuidList.length);
    for (let uuid of uuidList) {
      const diskInfo = diskInfoList.find((item: DiskInfo) => item.uuid === uuid);
      if (!diskInfo) {
        continue;
      }
      if (StringUtil.isEmpty(diskInfo.uri)) {
        continue;
      }
      const file = FsUtil.openSync(FileUtil.getPathFromUri(diskInfo.uri)) as fs.File;
      FsUtil.fsyncSync(file.fd);
      FsUtil.closeSync(file);
    }
  }

  /**
   * 还原文件
   * @param uri 待还原文件的uri
   */
  public async recoverFile(file: FileInfo, specifiedDir: string = ''): Promise<boolean> {
    try {
      let res: string = '';
      // 确保URI是正确编码的，特别是文件名部分
      let recoverUri: string = file.uri;

      // 修复文件名中含有%字符的问题：如果URI中的文件名部分没有正确编码，重新编码文件名
      if (recoverUri.includes('%')) {
        const fileUri: fileuri.FileUri = new fileuri.FileUri(recoverUri);
        const pathWithoutFilename = recoverUri.substring(0, recoverUri.lastIndexOf('/') + 1);
        const encodedFilename = encodeURIComponent(fileUri.name);
        recoverUri = pathWithoutFilename + encodedFilename;
        HiLog.infoPrivate(TAG, 'Fixed recover URI: ', recoverUri);
      }

      if (StringUtil.isEmpty(specifiedDir)) {
        res = TrashNapi.recoverFile(recoverUri);
      } else {
        // 同样确保指定目录URI也是正确编码的
        let encodedSpecifiedDir = specifiedDir;
        if (specifiedDir.includes('%')) {
          const dirUri: fileuri.FileUri = new fileuri.FileUri(specifiedDir);
          const pathWithoutFilename = specifiedDir.substring(0, specifiedDir.lastIndexOf('/') + 1);
          const encodedDirName = encodeURIComponent(dirUri.name);
          encodedSpecifiedDir = pathWithoutFilename + encodedDirName;
          HiLog.infoPrivate(TAG, 'Fixed specified dir URI: ', encodedSpecifiedDir);
        }
        HiLog.infoPrivate(TAG, 'recoverFile to specifiedDir: ', encodedSpecifiedDir);
        res = TrashNapi.recoverFileToSpecifiedDir(recoverUri, encodedSpecifiedDir);
      }
      this.addSuccessUris(file.uri, true);
      typeof res === 'string' && this.recordUri(res, file.isFolder, file.uri);
      return true;
    } catch (err) {
      HiLog.error(TAG, 'filemanager.recoverFile err: ' + JSON.stringify(err));
      HiSysEventUtil.reportFailureEvent(HiSysEventName.FILE_OPERATE_FAIL, InterfaceName.TRASH_RECOVER,
        (err as BusinessError).code);
      this.failFileCount += 1;
      this.failFileName = file.fileName;
      this.sendRestoreFail();
    }
    return false;
  }

  sendRestoreFail(): void {
    if (!this.workerPort) {
      HiLog.warn(TAG, 'workerPort is null when refreshProgress');
      return;
    }
    if (this.waitOperate) {
      HiLog.warn(TAG, 'waitOperate, stop refreshProgress');
      return;
    }
    HiLog.infoPrivate(TAG, `refreshProgress, workerName: `,
      `${this.workerName}, Progress: ${this.deleteOrRestoreProgressRate}`);
    let data = new DeleteRestoreResultParam(
      this.workerName,
      WorkerConst.DeleteRestoreResultType.RESTORE_FAIL,
      WorkerConst.ResultType.PROGRESS,
      this.operateType,
      this.operatingFile.fileName,
      this.deleteOrRestoreProgressRate,
      this.completeCount,
      this.failFileCount,
      this.failFileName,
      this.successUris
    );
    data.resolveUri = this.resolverUri;
    data.trashChangeCount = this.trashChangeCount;
    this.workerPort.postMessage(data);
    this.clearAfterTransfer();
  }

  /**
   * 处理异常
   * @param exceptionCode 异常码
   */
  public async dealException(exceptionCode: ResultCode.Exception): Promise<void> {
    if (this.isApplyToAll) {
      HiLog.info(TAG, 'applyToAll, stop dealException');
      return;
    }

    this.sendException(exceptionCode);
    while (this.waitOperate && !this.isCancel) {
      await TimeUtil.sleep(INTERVAL_TIME);
      HiLog.info(TAG, 'wait choose, exceptionCode: ' + exceptionCode);
    }
  }

  /**
   * 处理复制文件冲突情况下的选择结果
   * @param srcFile
   * @param destFolderUri
   * @returns
   */
  public async dealChooseResult(srcFile: FileInfo, specifiedDir: string = ''): Promise<void> {
    if (this.isCancel) {
      HiLog.info(TAG, 'dealDeleteFileAfterChoose is cancel');
      return;
    }
    HiLog.info(TAG, 'dealDeleteFileAfterChoose, conflictHandleResult:' + this.conflictHandleResult);
    switch (this.conflictHandleResult) {
      case DeleteRestoreConst.ChooseType.STOP:
        // 停止
        this.stopTimer();
        this.taskEnd();
        this.isStop = true;
        break;
      case DeleteRestoreConst.ChooseType.KEEP_BOTH_FILE:
        // 保留两者
        //todo 接口提供返回值后，增加历史记录
        HiLog.info(TAG, 'dealChooseResult, keep both');
        await this.recoverFile(srcFile, specifiedDir);
        break;
      case DeleteRestoreConst.ChooseType.MERGE_FOLDER:
        // 合并
        HiLog.info(TAG, 'dealChooseResult, merge folder');
        await this.recoverFile(srcFile, specifiedDir);
        break;
      case DeleteRestoreConst.ChooseType.SKIP:
        // 跳过
        HiLog.info(TAG, 'dealChooseResult, skip this file');
        break;
      default:
        break;
    }
  }

  private postCancelMessage(): void {
    if (!this.workerPort) {
      HiLog.warn(TAG, 'workerPort is null when refreshProgress');
      return;
    }
    if (this.waitOperate) {
      HiLog.warn(TAG, 'waitOperate, stop refreshProgress');
      return;
    }
    let data = new DeleteRestoreResultParam(
      this.workerName,
      WorkerConst.WorkerStatus.CANCEL,
      WorkerConst.ResultType.PROGRESS,
      this.operateType,
      this.operatingFile.fileName,
      this.deleteOrRestoreProgressRate,
      this.completeCount,
      this.failFileCount,
      this.failFileName,
      this.successUris
    );
    data.trashChangeCount = this.trashChangeCount;
    this.workerPort.postMessage(data);
    this.clearAfterTransfer();
  }

  /**
   * 初始化相关参数
   * @param msg 消息
   * @returns 是否正常初始化
   */
  private initAndCheckData(deleteRestoreSendParam: DeleteRestoreSendParam): boolean {
    if (ObjectUtil.isNullOrUndefined(deleteRestoreSendParam)) {
      HiLog.error(TAG, 'initAndCheckData copyCutSendParam is null');
      return false;
    }
    if (ObjectUtil.isNullOrUndefined(this.workerPort)) {
      HiLog.error(TAG, 'initAndCheckData workerPort is null');
      return false;
    }
    this.context = deleteRestoreSendParam.context;
    this.workerName = deleteRestoreSendParam.workerName;
    this.totalCount = deleteRestoreSendParam.toOperateFiles.length;
    this.operateType = deleteRestoreSendParam.operateType;
    this.operatingFile = deleteRestoreSendParam.toOperateFiles[0];
    this.favoriteCache = deleteRestoreSendParam.favoriteList;
    this.mediaSearchType = deleteRestoreSendParam.mediaSearchType;
    if ((!this.context) || (!this.workerPort) || (!this.workerName) || (!this.operatingFile)) {
      HiLog.warn(TAG, 'initAndCheckData param is null');
      return false;
    }
    return true;
  }

  private async getSubFavoriteListByPath(path: string,
    fileStatus: number = Constant.FILE_RECYCLED.UNKNOWN): Promise<Array<FavoriteModel>> {
    let pathList: string[] = [];
    let favoriteList: FavoriteModel[] = [];
    if (!(this.favoriteCache) || ArrayUtil.isEmpty(this.favoriteCache)) {
      HiLog.info(TAG, 'favoriteCache is empty');
      return favoriteList;
    }

    if (ObjectUtil.isNullOrUndefined(path) || StringUtil.isEmpty(path)) {
      HiLog.info(TAG, 'path is empty');
      return favoriteList;
    }

    let len = this.favoriteCache.length;
    for (let i = 0; i < len; i++) {
      let favorite = this.favoriteCache[i];
      let subPathStart = FileUtil.getPathWithFileSplit(path);
      if ((favorite.path !== path) && (!favorite.path.startsWith(subPathStart))) {
        continue;
      }
      if (fileStatus === Constant.FILE_RECYCLED.DELETED) {
        if (!favorite.recycled) {
          continue;
        }
        if (!pathList.includes(favorite.path)) {
          pathList.push(favorite.path);
          favoriteList.push(favorite);
        }
      } else if (fileStatus === Constant.FILE_RECYCLED.NORMAL) {
        if (!favorite.recycled) {
          favoriteList.push(favorite);
        }
      } else {
        favoriteList.push(favorite);
      }
    }

    HiLog.info(TAG, 'subSize = ' + favoriteList.length);
    return favoriteList;
  }

  /**
   * 分批执行图库硬删除操作
   * @param uri
   * @param isEnd 列表最后一个，表示是在图库相册内进行的删除子文件的操作，而不是删除相册操作
   */
  private async deleteGalleryFilePermanently(context: Context, uri: string, isEnd: boolean = false) {
    if (!isEnd) {
      this.galleryUris.push(uri);
    }
    if (this.galleryUris.length >= BATCH_GALLERY_MAX_COUNT || isEnd) {
      await PhotoAccessUtil.deletePhotoForManager(context, this.galleryUris);
      this.galleryUris.forEach((uri) => {
        this.addSuccessUris(uri);
      })
      this.galleryUris = [];
    }
  }

  private permanentDelete(file: FileInfo): boolean {
    const filePath = FileUtil.getPathFromUri(file.uri);
    let result = false;
    if (file.isFolder) {
      result = this.permanentDeleteFolder(filePath, file.fileName);
    } else {
      result = this.permanentDeleteFile(filePath, file.fileName);
    }
    if (result) {
      this.addSuccessUris(file.uri);
    }
    return result;
  }

  /**
   * 分批执行图库文件软删除操作
   * @param uri
   * @param isEnd 列表最后一个，表示是在图库相册内进行的删除子文件的操作，而不是删除相册操作
   */
  private async deleteGalleryFile(context: Context, uri: string, isEnd: boolean = false) {
    if (!isEnd) {
      this.galleryUris.push(uri);
    }
    if (this.galleryUris.length >= BATCH_GALLERY_MAX_COUNT || isEnd) {
      await PhotoAccessUtil.deleteAssetsList(context, this.galleryUris);
      this.galleryUris.forEach((uri) => {
        this.addSuccessUris(uri, true);
      })
      this.galleryUris = [];
    }
  }

  private async restoreGalleryFile(context: Context, uri: string, isEnd: boolean = false) {
    if (!isEnd) {
      this.galleryUris.push(uri);
    }
    if (this.galleryUris.length >= BATCH_GALLERY_MAX_COUNT || isEnd) {
      await PhotoAccessUtil.recoverFromTrash(context, this.galleryUris);
      this.galleryUris.forEach((uri) => {
        this.addSuccessUris(uri, true);
      })
      this.galleryUris = [];
    }
  }

  private async deleteFileToTrash(file: FileInfo): Promise<boolean> {
    try {
      if (StringUtil.isEmpty(file.uri)) {
        HiLog.warn(TAG, 'deleteFileToTrash param is null');
        return false;
      }

      // 确保URI是正确编码的，特别是文件名部分
      let deleteUri: string = file.uri;

      // 修复文件名中含有%字符的问题：如果URI中的文件名部分没有正确编码，重新编码文件名
      if (deleteUri.includes('%')) {
        const fileUri: fileuri.FileUri = new fileuri.FileUri(deleteUri);
        const pathWithoutFilename = deleteUri.substring(0, deleteUri.lastIndexOf('/') + 1);
        const encodedFilename = encodeURIComponent(fileUri.name);
        deleteUri = pathWithoutFilename + encodedFilename;
        HiLog.infoPrivate(TAG, 'Fixed delete to trash URI: ', deleteUri);
      }

      const res = await FileOperation.delete(deleteUri);
      if (typeof res === 'string') {
        this.recordUri(res, file.isFolder, file.uri);
      }
      this.addSuccessUris(file.uri, true);
    } catch (error) {
      HiLog.error(TAG, 'deleteFileToTrash err: ' + error.toString());
      // 文件删除操作是报文件不存在的错误时当做正常处理
      if (error.code !== ERROR_CODE.FILE_ACCESS.FILE_NOT_EXIST &&
        error.code !== ERROR_CODE.FILE_ACCESS.FILE_NOT_EXIST_SERVER) {
        this.failFileCount++;
        this.failFileName = file.fileName;
        return false;
      }
    }
    return true;
  }

  private recordUri(res: string, isFolder: boolean, uri: string): void {
    if (!res || res.length === 0) {
      return;
    }
  }

  private async updateFavoriteAfterRestore(favoriteList: FavoriteModel[]): Promise<void> {
    if (!ArrayUtil.isEmpty(favoriteList)) {
      let restoreList: FavoriteModel[] = [];
      for (let i = 0; i < favoriteList.length; i++) {
        let favorite = favoriteList[i];
        favorite.recycled = false;
        let pathItem = favorite.path;
        let isExist = await FileUtil.isExistByPathWithFs(pathItem);
        HiLog.infoPrivate(TAG, 'updateFavoriteAfterRestore', 'pathItem = ' + pathItem + ' ; ' + isExist);
        if (isExist) {
          restoreList.push(favorite);
        }
      }

      let deleteRestoreResultParam = new DeleteRestoreResultParam(
        this.workerName,
        WorkerConst.WorkerStatus.RUNNING,
        WorkerConst.DeleteRestoreResultType.RESTORE_UPDATE_FAVORITE,
        this.operateType,
        this.operatingFile.fileName,
        this.deleteOrRestoreProgressRate,
        this.completeCount,
        this.failFileCount,
        this.failFileName,
        this.successUris
      );
      deleteRestoreResultParam.updateFavoriteList = restoreList;
      deleteRestoreResultParam.deleteFavoriteIdList = [];
      this.workerPort!!.postMessage(deleteRestoreResultParam);
    }
  }

  private async refreshFileList(deleteRestoreSendParam: DeleteRestoreSendParam): Promise<FileInfo[]> {
    let concatList: FileInfo[] = [];
    let fileList: FileInfo[] = deleteRestoreSendParam.toOperateFiles.slice(0);
    let context = deleteRestoreSendParam.context;
    for (let i = 0; i < fileList.length; i++) {
      let tmp: FileInfo[] = [];
      if (FileUtil.isGalleryAddress(fileList[i].uri)) {
        concatList.push(fileList[i]);
      } else {
        const obj: preferences.Preferences | undefined =
          DataPreferenceUtil.getPreferencesSync(context.getApplicationContext(), { name: 'settingImageSizeFilter' });
        if (obj === undefined) {
          HiLog.error(TAG, `refreshFileList getPreferencesSync error!`);
          return concatList;
        }
        const min = obj.getSync('imageSizeFilter', IMAGE_SIZE_FILTER_DEFAULT) as number;
        HiLog.info(TAG, `getPreferencesSync imageSizeMin:${min}`);
        const imageSizeMin = min === 0 ? 1 : min * IMAGE_SIZE_FILTER_TRANS;
      }
      HiLog.info(TAG, `refreshFileList fileList.length: ${concatList.length}`);
    }
    HiLog.info(TAG, `refreshFileList total length: ${concatList.length}, gallery len ${this.totalGalleryCount}}`);
    return concatList;
  }

  // 重新构建文件列表
  private async reBuildFileList(deleteRestoreSendParam: DeleteRestoreSendParam): Promise<FileInfo[]> {
    let concatList: FileInfo[] = [];
    let fileList: FileInfo[] = deleteRestoreSendParam.toOperateFiles.slice(0);
    let context = deleteRestoreSendParam.context;
    const obj: preferences.Preferences | undefined =
      DataPreferenceUtil.getPreferencesSync(context.getApplicationContext(), { name: 'settingImageSizeFilter' });
    if (obj === undefined) {
      HiLog.error(TAG, `reBuildFileList getPreferencesSync error!`);
      return concatList;
    }
    const min = obj.getSync('imageSizeFilter', IMAGE_SIZE_FILTER_DEFAULT) as number;
    HiLog.info(TAG, `getPreferencesSync imageSizeMin:${min}`);
    for (let i = 0; i < fileList.length; i++) {
      if (FileUtil.isGalleryAddress(fileList[i].uri)) {
        concatList.push(fileList[i]);
      }
    }
    HiLog.info(TAG, `reBuildFileList total length: ${concatList.length}, gallery len ${this.totalGalleryCount}`);
    return concatList;
  }

  // 任务交互相关

  private async considerRefreshProgress() {
    const tempProgressRate: number = Math.ceil((this.completeCount / this.totalCount) * PROGRESS_COMPUTE_CONST);
    HiLog.info(TAG, `consider refresh progress: ${this.deleteOrRestoreProgressRate} to ${tempProgressRate}`);
    if (tempProgressRate > this.deleteOrRestoreProgressRate) {
      this.deleteOrRestoreProgressRate = tempProgressRate;
      await TimeUtil.sleep(1);
    }
  }

  private async deleteAlbumForManager(context: common.Context, albumUri: string, mediaSearchType: number,
    isSoftDelete: boolean): Promise<void> {
    let srcAlbum: photoAccessHelper.Album | undefined =
      await PhotoAccessUtil.getAlbumByUri(context, albumUri);
    if (!srcAlbum) {
      HiLog.warn(TAG, `deleteAlbumForManager err, when not find srcAlbum:${isSoftDelete}}`);
      return;
    }
    let fileToDel: FileInfo[] =
      await PhotoAccessUtil.getPhotoByUri(context, srcAlbum.albumUri, mediaSearchType, srcAlbum.albumType,
        srcAlbum.albumSubtype);
    let galleryUris = fileToDel.map((file) => {
      return file.uri;
    })
    HiLog.warn(TAG, `deleteAlbumForManager start:${mediaSearchType}_${isSoftDelete}_${fileToDel.length},
    is hard delete: ${!isSoftDelete}`);
    for (let i = 0; i < galleryUris.length; i += BATCH_GALLERY_MAX_COUNT) {
      if (this.isCancel) {
        HiLog.warn(TAG, `deleteAlbumForManager is cancel, when :${isSoftDelete}}`);
        return;
      }
      const tmpGalleryUri = galleryUris.slice(i, i + BATCH_GALLERY_MAX_COUNT);
      await PhotoAccessUtil.deleteAssetsList(context, tmpGalleryUri);
      //判断是否是硬删除
      if (!isSoftDelete) {
        //彻底删除文件
        await PhotoAccessUtil.deleteBatchPermanently(context, tmpGalleryUri);
      }
    }
    let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> | undefined = undefined;
    try {
      //获取相册中剩余文件数量，如果为0则删除相册，如果不为0则不删除
      let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      let fetchOptions: photoAccessHelper.FetchOptions = {
        fetchColumns: [],
        predicates: predicates
      };
      HiLog.warn(TAG, `deleteAlbumForManager start delete album:${mediaSearchType}_${isSoftDelete}`);
      fetchResult = await srcAlbum.getAssets(fetchOptions);
      if (fetchResult.getCount() === 0) {
        HiLog.warn(TAG, 'deleteAlbumForManager delete album ');
        await photoAccessHelper.MediaAlbumChangeRequest.deleteAlbums(context, [srcAlbum]);
      }
      HiLog.warn(TAG, 'deleteAlbumForManager delete album success');
    } catch (err) {
      HiLog.error(TAG, 'deleteAlbumForManager delete album fail.' + JSON.stringify(err));
    } finally {
      fetchResult?.close();
    }
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
      HiLog.warn(TAG, 'waitOperate, stop refreshProgress');
      return;
    }
    HiLog.infoPrivate(TAG, `refreshProgress, workerName: `,
      `${this.workerName}, Progress: ${this.deleteOrRestoreProgressRate}`);
    let data = new DeleteRestoreResultParam(
      this.workerName,
      WorkerConst.WorkerStatus.RUNNING,
      WorkerConst.ResultType.PROGRESS,
      this.operateType,
      this.operatingFile.fileName,
      this.deleteOrRestoreProgressRate,
      this.completeCount,
      this.failFileCount,
      this.failFileName,
      this.successUris
    );
    data.trashChangeCount = this.trashChangeCount;
    data.resolveUri = this.resolverUri;
    this.workerPort.postMessage(data);
    this.clearAfterTransfer();
  }

  private clearAfterTransfer(): void {
    this.successUris = [];
    this.trashChangeCount = 0;
  }

  private addSuccessUris(uri: string, isCount: boolean = false): void {
    if (StringUtil.isEmpty(uri)) {
      return;
    }
    this.successUris.push(uri);
    if (isCount) {
      this.trashChangeCount++;
    }
  }

  /**
   * 任务结束
   */
  private taskEnd(): void {
    try {
      HiLog.info(TAG, 'task end');
      // TODO 添加最近访问数据
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
      let deleteRestoreResultParam = new DeleteRestoreResultParam(
        this.workerName,
        WorkerConst.WorkerStatus.SUCCESS,
        WorkerConst.ResultType.SUCCESS,
        WorkerConst.OperateType.DELETE_FILE,
        this.operatingFile.fileName,
        this.deleteOrRestoreProgressRate,
        this.completeCount,
        this.failFileCount,
        this.failFileName,
        this.successUris
      );
      deleteRestoreResultParam.isToBackupPath = this.isToBackupPath; // 设置弹框提示条件
      this.workerPort!!.postMessage(deleteRestoreResultParam);
      this.successUris = [];
      this.isToBackupPath = false; // 重置弹框条件，默认false
      HiLog.info(TAG, 'sendTaskEnd');
    } catch (error) {
      HiLog.error(TAG, 'sendTaskEnd error: ' + JSON.stringify(error));
    }
  }

  /**
   * 发送异常信息
   * @param exceptionCode 异常码
   */
  private sendException(exceptionCode: ResultCode.Exception): void {
    if (this.isApplyToAll) {
      HiLog.info(TAG, 'applyToAll, stop dealException');
      return;
    }
    HiLog.info(TAG, 'sendException, exceptionCode: ' + exceptionCode);
    this.waitOperate = true;
    let deleteRestoreResultParam = new DeleteRestoreResultParam(
      this.workerName,
      WorkerConst.WorkerStatus.RUNNING,
      WorkerConst.ResultType.EXCEPTION,
      this.operateType,
      this.operatingFile.fileName,
      this.deleteOrRestoreProgressRate,
      this.completeCount,
      this.failFileCount,
      this.failFileName,
      this.successUris
    );
    deleteRestoreResultParam.exceptionCode = exceptionCode;
    deleteRestoreResultParam.exceptionFile = this.operatingFile;
    deleteRestoreResultParam.fileNum = this.totalCount;
    this.workerPort!!.postMessage(deleteRestoreResultParam);
    this.successUris = [];
  }

  private async updateFavoriteAfterSoftDelete(favoriteList: FavoriteModel[]): Promise<void> {
    let deleteRestoreResultParam = new DeleteRestoreResultParam(
      this.workerName,
      WorkerConst.WorkerStatus.RUNNING,
      WorkerConst.DeleteRestoreResultType.SOFT_DELETE_UPDATE_FAVORITE,
      this.operateType,
      this.operatingFile.fileName,
      this.deleteOrRestoreProgressRate,
      this.completeCount,
      this.failFileCount,
      this.failFileName,
      this.successUris
    );
    deleteRestoreResultParam.updateFavoriteList = favoriteList;
    deleteRestoreResultParam.deleteFavoriteIdList = [];
    this.workerPort!!.postMessage(deleteRestoreResultParam);
  }

  private async updateFavoriteAfterHardDelete(path: string, favoriteList: FavoriteModel[]): Promise<void> {
    if (!ArrayUtil.isEmpty(favoriteList)) {
      let deleteIdList: number[] = [];
      for (let i = 0; i < favoriteList.length; i++) {
        let favorite = favoriteList[i];
        let pathItem = favorite.path;
        let isExist = await FileUtil.isExistByPathWithFs(pathItem);
        HiLog.infoPrivate(TAG, 'updateFavoriteAfterHardDelete', pathItem + isExist);
        if (favorite.recycled || ((!favorite.recycled) && (!isExist))) {
          deleteIdList.push(favorite.id);
        }
      }

      let deleteRestoreResultParam = new DeleteRestoreResultParam(
        this.workerName,
        WorkerConst.WorkerStatus.RUNNING,
        WorkerConst.DeleteRestoreResultType.HARD_DELETE_UPDATE_FAVORITE,
        this.operateType,
        this.operatingFile.fileName,
        this.deleteOrRestoreProgressRate,
        this.completeCount,
        this.failFileCount,
        this.failFileName,
        this.successUris
      );
      deleteRestoreResultParam.updateFavoriteList = favoriteList;
      deleteRestoreResultParam.deleteFavoriteIdList = deleteIdList;
      this.workerPort!!.postMessage(deleteRestoreResultParam);
    }
  }
}