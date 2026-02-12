/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
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

import { CopyCutModel } from '../../databases/model/CopyCutModel';
import {
  ArrayUtil,
  Constant,
  CopyCutConst,
  CopyCutResultParam,
  CopyCutSendParam,
  DeviceConfig,
  DFX,
  DiskInfo,
  DragManager,
  EventBus,
  ExternalStorageUtil,
  FavoriteDbManager,
  FileInfo,
  FileSourceUri,
  FileUtil,
  FsUtil,
  getResourceString,
  GlobalHolder,
  GlobalKey,
  HiLog,
  ObjectUtil,
  PageUtil,
  PasteBoardUtil,
  PasteUtil,
  ResourceUtil,
  ResultCode,
  StorageDeviceManager,
  StringUtil,
  ThreadCommonUtil,
  toast,
  UdmfUtils,
  UUID_TYPE,
  VirtualUri,
  WorkerConst
} from '@ohos/common';
import fs from '@ohos.file.fs';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import { UIExtSessionManager } from '../extension/UIExtSessionManager';
import lazy { PhotoAccessUtil } from '@ohos/common/indexLazyLoad';
import fileExtensionInfo from '@ohos.file.fileExtensionInfo';
import { pasteboard } from '@kit.BasicServicesKit';
import lazy { photoAccessHelper } from '@ohos/common/indexLazyLoadTs';
import { CopyCutCompleteData, CopyCutProgressData, CopyCutProgressType } from '../extension/model/SendDataModel';
import { CopyCutNotificationUtil } from '../notification/CopyCutNotificationUtil';
import { JSON } from '@kit.ArkTS';

const TAG: string = 'CopyCutManager';
const EXTERNAL_PATH: string = 'file://docs/storage/External/';

/**
 * 本地移动复制manager
 */
export class CopyCutManager {
  /**
   * 实例
   */
  private static instance: CopyCutManager;
  /**
   * 展示最长长度
   */
  public readonly MAX_NAME_LENGTH: number = 12;
  /**
   * 保留长度前后各5个
   */
  public readonly KEEP_NAME_LENGTH: number = 5;
  /**
   * 名称超长连接字符
   */
  public readonly CONNECT_NAME_STR: String = '...';
  /**
   * 任务是否在运行
   */
  public taskIsRun: boolean = false;
  public startTime: number = 0;
  /**
   * 任务data
   */
  public taskData: CopyCutSendParam | undefined = undefined;
  /**
   * 任务种类
   */
  public taskKind?: WorkerConst.OperateType;
  /**
   * 来源
   */
  public isFrom: string = '';
  /**
   * 是否显示查看弹窗
   */
  public isShowCheckDialog = false;
  /**
   * 线程池名称
   */
  public workerName: string = '';
  /**
   * 选择数量
   */
  public selectCount: number = 0;
  /**
   * 是否是停止上次任务
   */
  public isStopLastTask: boolean = false;
  private uuid: string = '';
  // 用于记录当前复制的百分比
  private oldProgressPercent: number = -1;
  // 在回调函数执行标志变量
  private callbackExecuted: boolean = false;
  private listenTimeOut: number = -1;
  private isHidden: boolean = false;
  // 任务是否已完成
  private taskCompleted: boolean = false;

  public static getInstance() {
    if (ObjectUtil.isNullOrUndefined(CopyCutManager.instance)) {
      CopyCutManager.instance = new CopyCutManager();
    }
    return CopyCutManager.instance;
  }

  /**
   * 粘贴移动文件
   * @param srcFileList 待操作的文件列表
   * @param srcUri 源文件目录uri
   * @param destUri 目标目录uri
   * @param taskType 任务类型
   */
  public async pasteCutFile(srcFileList?: FileInfo[], srcUri?: string, destUri?: string,
    taskType?: WorkerConst.OperateType, destName?: string, isFrom: string = '', isDragFromExternal: boolean = false,
    isShowCheckDialog: boolean = false) {
    HiLog.warn(TAG, 'pasteCutFile start');
    try {
      if (!srcFileList || ArrayUtil.isEmpty(srcFileList as FileInfo[])) {
        HiLog.info(TAG, 'pasteCutFile list is null or empty');
        return;
      }
      if ((destUri === VirtualUri.GALLERY || destUri?.startsWith(VirtualUri.GALLERY_URI)) &&
        !await PhotoAccessUtil.initPhotoSupportedFormats(GlobalHolder.getInstance().getAppContext())) {
        toast($r('app.string.disabled'));
        return;
      }
      destUri = ThreadCommonUtil.getNoSlashUri(destUri);
      // 仅移动单文件时，需拦截判断。多文件的混合情况仍执行拖拽粘贴文件操作
      if (srcFileList.length === 1) {
        let srcUri = srcFileList[0].uri;
        // 判断目标是否为当前文件或子文件夹，拦截移动粘贴任务
        if (destUri && ThreadCommonUtil.isChildFolder(srcUri, destUri)) {
          HiLog.infoPrivate(TAG, 'isChildFolder', `srcUri is = ${srcUri}, destUri is = ${destUri}`);
          toast($r('app.string.not_paste_itself'));
          return;
        }
      }
      if (this.checkTaskIsRun()) {
        HiLog.info(TAG, 'task is running.');
        return;
      }
      // 直接传进去会出错，还未定位出原因
      let list: FileInfo[] = this.createFileInfoList(srcFileList, isFrom, taskType);
      this.selectCount = list.length;
      this.taskKind = taskType || WorkerConst.OperateType.COPY_FILE;
      this.isFrom = isFrom;
      this.isShowCheckDialog = isShowCheckDialog;
      this.workerName = ThreadCommonUtil.getWorkerName(destUri ?? '');
      this.uuid = await this.getUuid(destUri);
      this.taskData = new CopyCutSendParam(GlobalHolder.getInstance().getAppContext(),
        this.taskKind, this.workerName, list || [], destUri || '', CopyCutConst.SendMsgCode.START,
        undefined, false, this.uuid, GlobalHolder.getInstance().getObject<string>(GlobalKey.LOCAL_ROOT_URI)
      )
      this.taskData.isExternalOperate = taskType === WorkerConst.OperateType.DRAG_FILE && isDragFromExternal;
      this.taskData.srcFolderUri = srcUri;
      const destParentUri = ThreadCommonUtil.getParentUri(destUri);
      if (destUri === VirtualUri.GALLERY) {
        this.taskData.destFolderName = getResourceString($r('app.string.pc_gallery'));
      } else if (destUri.startsWith(VirtualUri.GALLERY_URI)) {
        // 通过相册uri，获取相册name
        let album = await PhotoAccessUtil.getAlbumByUri(GlobalHolder.getInstance().getAppContext(), destUri);
        if (!album) {
          this.taskData.destFolderName = getResourceString($r('app.string.pc_gallery'));
        } else {
          this.taskData.destFolderName = album.albumName;
        }
      } else if (destUri === FileUtil.URI_INTERNAL) {
        this.taskData.destFolderName = getResourceString(DeviceConfig.getInstance().config.myDevice);
      } else {
        this.taskData.destFolderName = destName || FileUtil.getFileNameFromUri(destUri);
      }
      this.taskData.favoriteList = FavoriteDbManager.getInstance().getFavoriteFileList(srcFileList, false);
      this.startTask(this.taskKind);
    } catch (err) {
      HiLog.error(TAG, `pasteCutFile error, errCode: ${err?.code}, errMsg: ${err?.message}`);
    }
  }

  sendInitNotification(taskData?: CopyCutSendParam) {
    if (!taskData) {
      return;
    }
    let notifyUri = StringUtil.isEmpty(taskData.srcFolderUri) ? taskData.destFolderUri : taskData.srcFolderUri;
    let notifyName =
      GlobalHolder.getInstance().getAppContext().resourceManager.getStringSync($r('app.string.initialization').id);
    UIExtSessionManager.getInstance().cancelCopyCutCompleteNotification();
    UIExtSessionManager.getInstance().publishCopyCutProgressNotification({
      folderUri: notifyUri || '',
      progress: 0,
      deliveryTime: this.startTime,
      operatingFileName: notifyName,
      operateType: this.getProgressOperateType(taskData.operateType),
      selectCount: this.selectCount,
      destFolderName: taskData.destFolderName
    });
  }

  getProgressOperateType(operateType?: WorkerConst.OperateType): CopyCutProgressType | undefined {
    if (operateType === WorkerConst.OperateType.COPY_FILE) {
      return CopyCutProgressType.COPY;
    } else if (operateType === WorkerConst.OperateType.CUT_FILE) {
      return CopyCutProgressType.MOVE;
    } else {
      return undefined;
    }
  }

  checkTaskIsRun(isBackDesk: boolean = false) {
    if (this.taskIsRun) {
      this.sendTaskRunning(isBackDesk);
    }
    return this.taskIsRun;
  }

  // 存储设备移除时，检查是否有当前设备的复制粘贴任务
  storageDeviceTaskIsRun(uuid: string): boolean {
    if (!this.taskIsRun) { // 无粘贴任务，直接返回
      return false;
    }

    const storageDevicePath: string = EXTERNAL_PATH + uuid;
    // 源路径或目的路径中，是否包含当前的uuid
    if (this.taskData?.destFolderUri.startsWith(storageDevicePath) ||
    this.taskData?.srcFolderUri?.startsWith(storageDevicePath)) {
      return true;
    }
    return false;
  }

  sendTaskRunning(isBackDesk: boolean) {
    if (isBackDesk) {
      EventBus.emit(Constant.EVENTS.CONFLICT_DIALOG, undefined, this.taskKind, undefined,
        ResultCode.Error.BACK_TO_DESK);
    } else {
      EventBus.emit(Constant.EVENTS.CONFLICT_DIALOG, undefined, this.taskKind, undefined, ResultCode.Error.TASK_LIMIT);
    }
  }

  startTask(taskType?: WorkerConst.OperateType) {
    if ((!this.taskData) || (!this.taskData.toOperateFiles) || (!taskType)) {
      return;
    }
    AppStorage.setOrCreate('copyCutTotalSize', 0);
    AppStorage.setOrCreate('copyCutCompleteSize', -1);
    AppStorage.setOrCreate('copyCutTotalCount', 0);
    AppStorage.setOrCreate('copyCutCompleteCount', -1);
    this.oldProgressPercent = -1;
    // 重置隐藏标志，确保新的操作可以正常显示UI通知
    this.isHidden = false;
    // 重置任务完成标志
    this.taskCompleted = false;
    // 重置通知状态，确保新的操作可以正常发送通知
    CopyCutNotificationUtil.resetState();
    this.emitStart(this.taskData.toOperateFiles.length, this.taskData.destFolderUri,
      this.taskData.destFolderName, taskType);
    this.taskIsRun = true;
    this.isStopLastTask = false;
    this.startTime = new Date().getTime();
    this.sendInitNotification(this.taskData);
    PasteUtil.startCopyCutTask(this.taskData, (result: CopyCutResultParam): void => this.receiveMsgFromWorker(result));
  }

  /**
   * 将fileData转换成复制移动模型
   * @param fileData fileData
   * @returns 模型
   */
  public transFileDataToCopyModel(fileData: FileInfo) {
    if (ObjectUtil.isNullOrUndefined(fileData)) {
      return null;
    }
    let model: CopyCutModel = new CopyCutModel();
    model.uri = fileData.uri;
    model.size = fileData.size;
    model.fileName = fileData.fileName;
    model.isFolder = fileData.isFolder;
    model.relativePath = fileData.relativePath;
    return model;
  }

  /**
   * 接收worker向主线程发送消息
   * @param result 结果
   */
  public receiveMsgFromWorker(result: CopyCutResultParam): void {
    if (ObjectUtil.isNullOrUndefined(result)) {
      HiLog.info(TAG, 'receive msg is null.');
      return;
    }
    HiLog.info(TAG, 'receive msg: ' + result.resultType);
    // 防止上一个线程影响到当前线程
    if (result.workerName != this.workerName) {
      HiLog.errorPrivate(TAG, 'other worker massage', `, worker name: ${result.workerName}`);
      return;
    }
    switch (result.resultType) {
      case WorkerConst.ResultType.SUCCESS:
        // 复制移动结束
        this.dealProcessEnd(result);
        break;
      case WorkerConst.ResultType.PROGRESS:
        // 更新进度
        this.dealProcessRunning(result);
        break;
      case WorkerConst.ResultType.EXCEPTION:
        this.dealException(result);
        break;
      case WorkerConst.ResultType.ERROR:
        // 处理其他异常
        this.dealError(result);
        break;
      case WorkerConst.CopyCutResultType.QUERY_WORKER_STATUS:
        // 处理任务状态，弹弹框
        this.dealQueryTaskStatus(result);
        break;
      case WorkerConst.CopyCutResultType.UPDATE_FAVORITE_LIST:
        // 更新收藏数据
        this.dealFavoriteData(result);
        break;
      default:
        HiLog.info(TAG, 'receive what is wrong');
        break;
    }
  }

  public usbSdChange(diskInfo: DiskInfo[]) {
    HiLog.info(TAG, 'usb change');
    PasteUtil.sendMsg(this.workerName, CopyCutConst.SendMsgCode.EXTERNAL_DISK_CHANGE, this.taskKind);
  }

  /**
   * 取消任务
   */
  public cancelWorker() {
    HiLog.info(TAG, 'cancel worker.');
    this.taskIsRun = false;
    PasteUtil.cancelWorker(this.workerName, this.taskKind);
  }

  public continueToRunWorker(): void {
    HiLog.info(TAG, 'continue run.');
    this.taskIsRun = true;
    PasteUtil.continueToRunWorker(this.workerName, this.taskKind);
  }

  /**
   * 强制移除，调用移除对应uuid设备，同时判断对应设备的复制粘贴是否进行中，进行中停止复制粘贴线程
   */
  public forcedRemoval(uuid: string) {
    HiLog.warn(TAG, 'forced removal.');
    const storageDevicePath: string = EXTERNAL_PATH + uuid;
    if (this.taskIsRun && (this.taskData?.destFolderUri.startsWith(storageDevicePath) ||
    this.taskData?.srcFolderUri?.startsWith(storageDevicePath))) {
      this.stopTask();
    }
    ExternalStorageUtil.unmountStorageDevice(uuid);
  }

  public stopTask() {
    this.cancelWorker();
    this.isStopLastTask = true;
    EventBus.emit(Constant.EVENTS.STOP_COPY_CUT_TASK);
    PageUtil.refreshMyPhonePage();
  }

  public hideProgress(taskType?: WorkerConst.OperateType) {
    switch (taskType) {
      case WorkerConst.OperateType.CUT_FILE:
        toast($r('app.string.hide_cut_toast'));
        break;
      case WorkerConst.OperateType.COPY_FILE:
        toast($r('app.string.hide_copy_toast'));
        break;
      case WorkerConst.OperateType.DRAG_FILE:
        toast($r('app.string.hide_drag_toast'));
        break;
      default:
        break;
    }
    // 设置隐藏标志
    this.isHidden = true;
  }

  /**
   * 向worker发送冲突弹框结果
   *
   * @param 是否应用到全部
   * @param chooseResult 选择结果
   */
  public sendConflictChooseResult(isApplyAll: boolean, chooseResult: CopyCutConst.ChooseType) {
    HiLog.info(TAG, 'PasteExistDupFile firstButtonClick: keep both');
    if (this.isShowCheckDialog && chooseResult === CopyCutConst.ChooseType.SKIP_FILE) {
      this.isShowCheckDialog = false;
    }
    PasteUtil.sendConflictChooseMessage(this.workerName, chooseResult, isApplyAll, WorkerConst.OperateType.COPY_FILE)
  }

  public dealNotifyToPage(): void {
    HiLog.warn(TAG, `taskIsRun: ${this.taskIsRun}`);
    EventBus.emit(Constant.EVENTS.COPY_CUT_PROGRESS_VISIBLE, this.taskIsRun);
  }

  public async onDragJumpCallback(event: DragEvent, extraParams?: string): Promise<void> {
    HiLog.info(TAG, 'drop callback');
    let dropFileList: FileInfo[] = [];
    let extraInfo: string = UdmfUtils.getExtra(extraParams);
    if (extraInfo === UdmfUtils.DRAG_IN_THE_APP) {
      HiLog.warn(TAG, 'Get data from local sources.');
      dropFileList = DragManager.getInstance().dragFileList;
    } else {
      dropFileList = await DragManager.getInstance().getFileInfoListFromUDMF(event);
    }
    if (dropFileList.length === 0) {
      return;
    }
    try {
      let shareFolderPath = Constant.MY_PHONE_SHARE_PATH;
      let exist = FsUtil.isExistSyncByPath(shareFolderPath);
      if (!exist) {
        fs.mkdirSync(shareFolderPath);
      }
    } catch (error) {
      HiLog.error(TAG, 'onDrop fail, error:' + JSON.stringify(error));
      return;
    }
    CopyCutManager.getInstance()
      .pasteCutFile(dropFileList, '', FileSourceUri.SHARE, WorkerConst.OperateType.DRAG_FILE,
        ResourceUtil.getStringByResource($r('app.string.share_folder_name')), '',
        !DragManager.getInstance().isInternalDrag, true);
  }

  private createFileInfoList(srcFileList: FileInfo[], isFrom: string, taskType?: WorkerConst.OperateType): FileInfo[] {
    let fileInfoList: FileInfo[] = [];
    let isPasteBoard = isFrom === CopyCutConst.OperateFrom.PASTE_BOARD ||
      taskType === WorkerConst.OperateType.DRAG_FILE;
    for (let i = 0; i < srcFileList.length; i++) {
      let fileData = srcFileList[i];
      let tmpData = new FileInfo();
      tmpData.uri = fileData.uri;
      tmpData.size = isPasteBoard ? Constant.FILE_SIZE_UNKNOWN : fileData.size;
      tmpData.fileName = fileData.fileName;
      tmpData.isFolder = fileData.isFolder;
      tmpData.relativePath = fileData.relativePath || '';
      tmpData.isGallery = fileData.uri.startsWith(Constant.GALLERY_URI_HEAD);
      fileInfoList.push(tmpData);
    }
    return fileInfoList;
  }

  // 提前设置uuid， 便于在worker里判断
  private async getUuid(destUri: string | undefined): Promise<string> {
    const storageDeviceList = await StorageDeviceManager.getInstance().getStorageDeviceList();
    let storageDevice: DiskInfo | undefined;
    if (!!destUri) {
      storageDevice = storageDeviceList.find((deviceItem: DiskInfo) => destUri.startsWith(deviceItem.uri));
    }
    if (storageDevice) {
      if (storageDevice.deviceType === fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK) {
        return UUID_TYPE.LOCAL;
      } else {
        return storageDevice.uuid;
      }
    }
    return UUID_TYPE.LOCAL;
  }

  /**
   * 更新收藏数据
   *
   * @param result CopyCutResultParam
   */
  private dealFavoriteData(result: CopyCutResultParam) {
    if (ObjectUtil.isNullOrUndefined(result)) {
      return;
    }
    FavoriteDbManager.getInstance().updateFileInfoByMove(
      result.updateFavoriteList,
      result.deleteLocalFavoritePath)
      .then((updateResult: boolean) => {
        if (updateResult) {
          EventBus.emitDelay(50, Constant.EVENTS.FAVORITE_REFRESH);
        }
      });
  }

  private dealQueryTaskStatus(result: CopyCutResultParam) {
    if (ObjectUtil.isNullOrUndefined(result)) {
      return;
    }
    // 没有冲突文件，展示进度框
    EventBus.emit(Constant.EVENTS.COPY_CUT_PROGRESS_VISIBLE, this.taskIsRun);
  }

  private dealError(result: CopyCutResultParam) {
    HiLog.warn(TAG, `dealError, error code: ${result.errorCode}`);
    if (result.errorCode === ResultCode.Error.NO_SPACE_LEFT) {
      // 目标路径为本地/图库的时候需要引导弹框，否则消息提示。
      if (result.destFolderUri.startsWith(Constant.MY_PHONE_URI) || result.destFolderUri === VirtualUri.GALLERY ||
      result.destFolderUri.startsWith(VirtualUri.GALLERY_URI)) {
        EventBus.emit(Constant.EVENTS.SHOW_INSUFFICIENT_DISK_SPACE_DIALOG, DFX.ReasonType.ERR_CODE);
        return;
      }
      EventBus.emit(Constant.EVENTS.ERROR_PASTE_DIALOG, result.errorCode, this.taskKind, result);
    } else if (result.errorCode === ResultCode.Error.ERROR_GALLERY_ROOT_PASTER) {
      EventBus.emit(Constant.EVENTS.ERROR_PASTE_DIALOG, result.errorCode, this.taskKind, result);
    } else if (result.errorCode === ResultCode.Error.ERROR_GALLERY_FILE_NAME_INVALID) {
      EventBus.emit(Constant.EVENTS.ERROR_PASTE_DIALOG, result.errorCode, this.taskKind, result);
    } else {
      EventBus.emit(Constant.EVENTS.CONFLICT_DIALOG, undefined, this.taskKind, result, result.errorCode);
    }
  }

  /**
   * 展示冲突弹框
   *
   * @param result CopyCutResultParam
   */
  private dealException(result: CopyCutResultParam) {
    if (ObjectUtil.isNullOrUndefined(result)) {
      return;
    }
    HiLog.warn(TAG, `deal exception, code: ${result.exceptionCode}`);
    switch (result.exceptionCode) {
      case ResultCode.Exception.CANNOT_PASTE_TO_SUB_FOLDER:
        toast($r('app.string.not_paste_itself'));
        PasteUtil.sendConflictChooseMessage(this.workerName, CopyCutConst.ChooseType.SKIP_FOLDER,
          false, this.taskKind);
        break;
      case ResultCode.Exception.EXCEPTION_EXIST_UNSUPPORTED_TYPE:
      case ResultCode.Exception.EXCEPTION_GALLERY_ROOT_PASTER_FOLDER:
      case ResultCode.Exception.EXCEPTION_GALLERY_ROOT_PASTER_FOLDERS:
      case ResultCode.Exception.EXCEPTION_GALLERY_ALBUM_PASTER_FOLDER:
      case ResultCode.Exception.EXCEPTION_SCREENSHOT_ALBUM_PASTER_UNSUPPORT_FOLDER:
      case ResultCode.Exception.EXCEPTION_SCREENRECORD_ALBUM_PASTER_UNSUPPORT_FOLDER:
        EventBus.emit(Constant.EVENTS.EXCEPTION_PASTE_DIALOG, result.exceptionCode, this.taskKind, result);
        break;
      default:
        EventBus.emit(Constant.EVENTS.CONFLICT_DIALOG, result.exceptionCode, this.taskKind, result);
        break;
    }
  }

  /**
   * 发送开始消息
   * @param selectNum selectNum
   * @param targetName targetName
   * @param taskType taskType
   */
  private emitStart(selectNum: number, destFolderUri: string, targetName: string, taskType?: WorkerConst.OperateType) {
    // 更新已完成大小
    AppStorage.setOrCreate('copyCutTotalSize', 0);
    AppStorage.setOrCreate('copyCutCompleteSize', -1);
    EventBus.emit(Constant.EVENTS.COPY_CUT_START, selectNum, destFolderUri, targetName, taskType);
  }

  private emitEnd(result: CopyCutResultParam) {
    if ((!this.taskData) || (!this.taskData.toOperateFiles)) {
      return;
    }
    const isCancel = result.workerStatus === WorkerConst.WorkerStatus.CANCEL;
    let isFromPasteBoard = this.isFrom === CopyCutConst.OperateFrom.PASTE_BOARD;
    EventBus.emit(Constant.EVENTS.COPY_CUT_END, result.failCount, isCancel, isFromPasteBoard, this.isShowCheckDialog);
    EventBus.emit(Constant.EVENTS.COPY_CUT_REFRESH, this.taskKind);
    if (this.taskData?.destFolderUri?.startsWith(VirtualUri.GALLERY_URI) &&
      this.taskKind === WorkerConst.OperateType.COPY_FILE) {
      // 如果是往图库粘贴（排除移动的场景），在监听媒体库变动后再刷新
      this.handlePasteToAlbum(this.taskData);
    } else {
      // 刷新最近我的手机
      PageUtil.refreshMyPhonePage();
    }
  }

  private handlePasteToAlbum(taskData: CopyCutSendParam): void {
    // 重置标志，表示开始新的监听周期
    this.callbackExecuted = false;
    PhotoAccessUtil.registerAlbumChanges(GlobalHolder.getInstance().getAppContext(),
      taskData.destFolderUri, this.albumListenCallback);
    this.listenTimeOut = setTimeout(() => {
      PhotoAccessUtil.unRegisterAlbumChange(GlobalHolder.getInstance().getAppContext(),
        taskData?.destFolderUri, this.albumListenCallback)
      if (!this.callbackExecuted) {
        HiLog.info(TAG, `callback not executed, refresh page.`);
        PageUtil.refreshMyPhonePage();
        this.callbackExecuted = true;
      }
      clearTimeout(this.listenTimeOut);
      this.listenTimeOut = -1;
    }, 1000); // 1000ms之后注销对媒体库资源变动的监听
  }

  private pageRefresh(changeData: photoAccessHelper.ChangeData): void {
    if (changeData.type === photoAccessHelper.NotifyType.NOTIFY_ALBUM_ADD_ASSET) {
      PageUtil.refreshGalleryPage(this.taskData?.destFolderUri as string);
      this.callbackExecuted = true;
      if (this.listenTimeOut !== -1) {
        PhotoAccessUtil.unRegisterAlbumChange(GlobalHolder.getInstance().getAppContext(),
          this.taskData?.destFolderUri, this.albumListenCallback);
        clearTimeout(this.listenTimeOut);
        this.listenTimeOut = -1;
      }
    }
  }

  private albumListenCallback(changeData: photoAccessHelper.ChangeData): void {
    HiLog.info(TAG, ' albumListenCallback ' + changeData.type);
    CopyCutManager.getInstance().pageRefresh(changeData);
  }

  /**
   * 复制移动结束处理
   * @param result 消息
   */
  private async dealProcessEnd(result: CopyCutResultParam) {
    if (ObjectUtil.isNullOrUndefined(result)) {
      HiLog.error(TAG, 'dealEnd data is null');
      return;
    }

    // 立即设置任务状态为结束，防止后续进度消息处理
    this.taskIsRun = false;
    this.taskCompleted = true;
    
    // 禁止后续的进度通知
    CopyCutNotificationUtil.disableProgressNotifications();
    
    // 立即取消所有进度通知，无论是否隐藏
    await CopyCutNotificationUtil.cancelProgressNotification();
    
    // 复制结束
    this.emitEnd(result);
    PasteBoardUtil.removePasteDateFromGlobalPasteDateMap(result.workerName);
    try {
      // resourcemanager暂不支持待单复数多占位符，先规避
      let abilityContext = GlobalHolder.getInstance().getAppContext()
      let title: string = '';
      let text: string = '';
      let isCancel = result.workerStatus === WorkerConst.WorkerStatus.CANCEL;
      if (isCancel) {
        title = abilityContext.resourceManager.getPluralStringValueSync(this.getStopTitle(this.taskKind).id,
          this.selectCount);
        text = this.getStopContent(this.taskKind, result.successCount, abilityContext);
        this.checkIsRunningStop(title, text);
      } else {
        title = abilityContext.resourceManager.getPluralStringValueSync(this.getCompleteTitle(this.taskKind).id,
          this.selectCount);
        text = this.getCompleteContent(this.taskKind, result.successCount, result.failCount, isCancel, abilityContext);
        // 添加操作完成的 toast 提示
        if (result.failCount === 0) {
          const destFolderName = this.taskData?.destFolderName || FileUtil.getFileNameFromUri(result.notifyUri) || '';
          switch (this.taskKind) {
            case WorkerConst.OperateType.COPY_FILE:
              text =
                abilityContext.resourceManager.getStringSync($r('app.string.copy_to_dest_completed').id, destFolderName)
              toast(`${text}`);
              break;
            case WorkerConst.OperateType.CUT_FILE:
              text =
                abilityContext.resourceManager.getStringSync($r('app.string.move_to_dest_completed').id, destFolderName)
              toast(`${text}`);
              break;
            case WorkerConst.OperateType.DRAG_FILE:
              text =
                abilityContext.resourceManager.getStringSync($r('app.string.move_to_dest_completed').id, destFolderName)
              toast(`${text}`);
              break;
            default:
              break;
          }
        }
      }
      let timeoutHandle = setTimeout(async () => {
        if (!this.isHidden) {
          // 未点击隐藏：发送UI完成通知
          UIExtSessionManager.getInstance().cancelCopyCutProgressNotification();
          UIExtSessionManager.getInstance().publishCopyCutCompleteNotification({
            folderUri: result.notifyUri,
            title: title,
            text: text,
            isCancel: isCancel,
            operateType: this.getProgressOperateType(result.operateType),
            destFolderName: this.taskData?.destFolderName,
            selectCount: result.totalCount
          });
        } else {
          // 点击了隐藏：发送通知栏完成通知
          const completeData: CopyCutCompleteData = {
            folderUri: result.notifyUri,
            title: title,
            text: text,
            isCancel: isCancel,
            operateType: this.getProgressOperateType(result.operateType),
            destFolderName: this.taskData?.destFolderName,
            selectCount: result.totalCount
          };
          await CopyCutNotificationUtil.publishCompleteNotification(completeData);
        }

        clearTimeout(timeoutHandle);
      }, 100);
    } catch (error) {
      let businessError = (error as BusinessError);
      HiLog.error(TAG, 'error: ' + businessError.code + ', ' + businessError.message);
    }
  }

  private checkIsRunningStop(title: string, content: string) {
    if (this.isStopLastTask) {
      this.isStopLastTask = false;
      toast($r('app.string.notify_result', title, content));
    }
  }

  private getStopContent(taskType: WorkerConst.OperateType = WorkerConst.OperateType.CUT_FILE, successCount: number,
    context: common.Context) {
    let successStr = '';
    switch (taskType) {
      case WorkerConst.OperateType.CUT_FILE:
        successStr =
          context.resourceManager.getPluralStringValueSync($r('app.plural.notify_result_move_success').id, successCount)
        break;
      case WorkerConst.OperateType.DRAG_FILE:
        successStr =
          context.resourceManager.getPluralStringValueSync($r('app.plural.notify_result_drag_success').id, successCount)
        break;
      default:
        successStr =
          context.resourceManager.getPluralStringValueSync($r('app.plural.notify_result_copy_success').id, successCount)
        break;
    }
    return successStr;
  }

  private getStopTitle(taskType?: WorkerConst.OperateType) {
    let res: Resource = $r('app.plural.copy_stop_notify_title');
    switch (taskType) {
      case WorkerConst.OperateType.CUT_FILE:
        res = $r('app.plural.move_stop_notify_title');
        break;
      case WorkerConst.OperateType.DRAG_FILE:
        res = $r('app.plural.drag_stop_notify_title');
        break;
    }
    return res;
  }

  private getCompleteTitle(taskType?: WorkerConst.OperateType) {
    let res: Resource = $r('app.plural.copy_complete_notify_title');
    switch (taskType) {
      case WorkerConst.OperateType.CUT_FILE:
        res = $r('app.plural.move_complete_notify_title');
        break;
      case WorkerConst.OperateType.DRAG_FILE:
        res = $r('app.plural.drag_complete_notify_title');
        break;
    }
    return res;
  }

  private getCompleteContent(taskType: WorkerConst.OperateType = WorkerConst.OperateType.CUT_FILE, successCount: number,
    failCount: number, isCancel: boolean, context: common.Context): string {
    let containFail = failCount > 0;
    if ((!isCancel) && (!containFail)) {
      return context.resourceManager.getStringSync($r('app.string.click_view_detail').id);
    }
    let successStr = this.getSuccessCountStr(taskType, context, successCount);
    if (isCancel && (!containFail)) {
      return successStr;
    }
    return this.getResultCountStr(taskType, context, successCount, failCount);
  }

  private getResultCountStr(taskType: WorkerConst.OperateType = WorkerConst.OperateType.CUT_FILE,
    context: common.Context, successCount: number, failCount: number): string {
    let successStr = '';
    switch (taskType) {
      case WorkerConst.OperateType.CUT_FILE:
        successStr =
          context.resourceManager.getStringSync($r('app.string.move_notify_result').id, successCount, failCount);
        break;
      case WorkerConst.OperateType.DRAG_FILE:
        successStr =
          context.resourceManager.getStringSync($r('app.string.drag_notify_result').id, successCount, failCount);
        break;
      default:
        successStr =
          context.resourceManager.getStringSync($r('app.string.copy_notify_result').id, successCount, failCount);
        break;
    }
    return successStr;
  }

  private getSuccessCountStr(taskType: WorkerConst.OperateType = WorkerConst.OperateType.CUT_FILE,
    context: common.Context, successCount: number) {
    let successStr = '';
    switch (taskType) {
      case WorkerConst.OperateType.CUT_FILE:
        successStr =
          context.resourceManager.getPluralStringValueSync($r('app.plural.notify_result_move_success').id, successCount)
        break;
      case WorkerConst.OperateType.DRAG_FILE:
        successStr =
          context.resourceManager.getPluralStringValueSync($r('app.plural.notify_result_drag_success').id, successCount)
        break;
      default:
        successStr =
          context.resourceManager.getPluralStringValueSync($r('app.plural.notify_result_copy_success').id, successCount)
        break;
    }
    return successStr;
  }

  /**
   * 复制移动进行中处理
   * @param result 消息
   */
  private dealProcessRunning(result: CopyCutResultParam) {
    if (ObjectUtil.isNullOrUndefined(result)) {
      HiLog.error(TAG, 'dealRunning data is null');
      return;
    }
    
    // 检查任务是否已经结束或完成，如果结束则不处理进度消息
    if (!this.taskIsRun || this.taskCompleted) {
      HiLog.info(TAG, 'Task is already ended or completed, skipping progress message');
      return;
    }
    
    HiLog.info(TAG, 'process complete: ' + result.completeSize + ' totalSize: ' + result.totalSize);
    let useSizeCalculated: boolean = (result.totalSize !== 0);
    let percent: number = useSizeCalculated ? this.getPercent(result.totalSize, result.completeSize) :
      this.getPercent(result.totalCount, result.completeCount);
    HiLog.info(TAG, 'process percent: ' + percent);
    // 防止异常，百分比降低，影响显示体验
    if (this.oldProgressPercent > percent) {
      HiLog.error(TAG, `dealProcessRunning Percentage Exception, old : ${this.oldProgressPercent}, new : ${percent}`);
      return;
    }
    if (useSizeCalculated) {
      // 通过size显示百分比更新已完成大小
      AppStorage.setOrCreate('copyCutTotalSize', result.totalSize);
      AppStorage.setOrCreate('copyCutTotalCount', result.totalCount); // 用于改变显示总粘贴文件数量
      AppStorage.setOrCreate('copyCutCompleteSize', result.completeSize);
    } else {
      // 更新已完成大小
      AppStorage.setOrCreate('copyCutTotalCount', result.totalCount);
      AppStorage.setOrCreate('copyCutCompleteCount', result.completeCount);
    }
    // 存储当前正在操作的文件名
    AppStorage.setOrCreate('copyCutOperatingFileName', result.operatingFileName);
    // 存储通知URI
    AppStorage.setOrCreate('copyCutNotifyUri', result.notifyUri);
    this.oldProgressPercent = percent;
    if (this.taskIsRun) {
      let notifyName = result.operatingFileName;
      if (StringUtil.isEmpty(notifyName)) {
        notifyName =
          GlobalHolder.getInstance().getAppContext().resourceManager.getStringSync($r('app.string.initialization').id);
      }

      // 根据隐藏状态决定通知发送策略
      // 未隐藏时：只向UI发送通知，UI弹窗显示
      // 隐藏后：向UI和通知栏都发送通知，UI弹窗隐藏，通知栏通知显示
      UIExtSessionManager.getInstance().publishCopyCutProgressNotification({
        folderUri: result.notifyUri,
        progress: this.oldProgressPercent,
        deliveryTime: this.startTime,
        operatingFileName: notifyName,
        operateType: this.getProgressOperateType(result.operateType),
        selectCount: result.totalCount,
        destFolderName: this.taskData?.destFolderName ?? ''
      });
      
      // 只有隐藏后才向通知栏发送通知
      if (this.isHidden) {
        // 再次检查任务状态，确保任务仍在运行且未完成
        if (!this.taskIsRun || this.taskCompleted) {
          HiLog.info(TAG, 'Task ended before sending notification, skipping');
          return;
        }
        
        const progressData: CopyCutProgressData = {
          folderUri: result.notifyUri,
          progress: this.oldProgressPercent,
          deliveryTime: this.startTime,
          operatingFileName: notifyName,
          operateType: this.getProgressOperateType(result.operateType),
          selectCount: result.totalCount,
          destFolderName: this.taskData?.destFolderName ?? ''
        };
        const title: string = this.taskKind === WorkerConst.OperateType.COPY_FILE ?
          ResourceUtil.getPluralStringValue($r('app.plural.copying_notification_title'), result.totalCount,
            result.totalCount, this.taskData?.destFolderName ?? '') :
          ResourceUtil.getPluralStringValue($r('app.plural.moving_notification_title'), result.totalCount,
            result.totalCount, this.taskData?.destFolderName ?? '');
        
        // 再次检查任务状态，确保任务仍在运行且未完成
        if (!this.taskIsRun || this.taskCompleted) {
          HiLog.info(TAG, 'Task ended before sending notification, skipping');
          return;
        }
        
        CopyCutNotificationUtil.publishProgressNotification(progressData, title);
      }
      HiLog.info(TAG, `dealProcessRunning progress:  ${JSON.stringify(this.oldProgressPercent)}`)
    }
  }

  /**
   * 获取进度(*100)
   * @param totalSize 总大小
   * @param completeSize 已完成大小
   * @returns 结果
   */
  private getPercent(totalSize?: number, completeSize?: number) {
    if ((!totalSize) || (!completeSize) || (totalSize === 0)) {
      return 0;
    }
    let percent = completeSize * 100 / totalSize;
    return percent > 100 ? 100 : percent;
  }
}