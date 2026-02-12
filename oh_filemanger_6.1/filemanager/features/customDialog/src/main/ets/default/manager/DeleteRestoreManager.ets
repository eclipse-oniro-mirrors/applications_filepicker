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

import {
  Constant,
  DeleteRestoreConst,
  DeviceInfoUtil,
  EventBus,
  HiLog,
  ObjectUtil,
  TaskObject,
  toast,
  VirtualUri,
  WorkerConst,
  DeleteRestoreResultParam,
  FavoriteDbManager,
  FileInfo,
  FileUtil,
  PageUtil,
  ThreadCommonUtil,
  TrashUtil,
  DeviceConfig
} from '@ohos/common';
import { TrashFileUtil } from '@ohos/common/src/main/ets/utils/TrashFileUtil';


const TAG = 'DeleteRestoreManager';

/**
 * 文件删除还原操作管理
 */
export class DeleteRestoreManager {
  /**
   * 当前任务对象
   */
  public taskObj: TaskObject | undefined = undefined;
  /**
   * 当前任务的操作类型
   */
  private operationType: string | undefined = undefined;
  /**
   * 用于实现进度更新的回调
   */
  public updateProgressCallback: Function = () => {
  };
  /**
   * 用于处理错误场景的回调
   */
  public deleteFailCallback: Function = () => {
  };
  /**
   * 用于处理删除取消的回调
   */
  public cancelDeleteCallBack: Function = () => {
  };
  /**
   * 记录回收站内文件新增或减少的个数
   */
  public trashFileChangeCount: number = 0;

  /**
   * 线程池名称
   */
  public workerName: string = '';

  constructor() {
  }

  /**
   * 注册更新进度回调和错误处理回调
   * @param updateProgressCallback 更新进度回调
   * @param errorCallback 错误处理回调
   */
  public registerCallback(updateProgressCallback: Function, deleteFailCallback: Function,
    cancelDeleteCallBack: Function) {
    this.updateProgressCallback = updateProgressCallback;
    this.deleteFailCallback = deleteFailCallback;
    this.cancelDeleteCallBack = cancelDeleteCallBack;
  }

  /**
   * 删除文件
   * @param fileList
   */
  public deleteFiles(fileList: FileInfo[], mediaSearchType: number = -1): void {
    this.startTask(fileList, Constant.OPERATION_TYPE.DELETE, false, mediaSearchType);
  }

  /**
   * 硬删除
   * @param fileList
   */
  public hardDeleteFiles(fileList: FileInfo[], isTrashFile: boolean = false, mediaSearchType: number = -1): void {
    this.startTask(fileList, Constant.OPERATION_TYPE.HARD_DELETE, isTrashFile, mediaSearchType);
  }

  /**
   * 还原
   * @param fileList
   */
  public restoreFiles(fileList: FileInfo[]): void {
    this.startTask(fileList, Constant.OPERATION_TYPE.RESTORE, true);
  }

  /**
   * 开始任务
   * @param fileList 要操作的文件uri数组
   * @param operationType 执行的任务类型
   * @param isTrashFile 是否为最进删除里的文件
   */
  private async startTask(fileList: FileInfo[], operationType: string, isTrashFile: boolean,
    mediaSearchType: number = -1): Promise<void> {
    HiLog.info(TAG, 'startTask operationType:' + operationType);
    this.operationType = operationType;
    let list: FileInfo[] = [];
    for (let i = 0; i < fileList.length; i++) {
      let data = fileList[i];
      let dataTmp = new FileInfo();
      dataTmp.fileName = data.fileName;
      dataTmp.uri = data.uri;
      dataTmp.thumbnailType = data.thumbnailType;
      dataTmp.isFolder = data.isFolder;
      dataTmp.storageDeviceUid = data.storageDeviceUid;
      dataTmp.srcPath = isTrashFile ? data.srcPath : (data.relativePath || '');
      dataTmp.isGallery = data.isGallery;
      dataTmp.albumType = data.albumType;
      dataTmp.albumSubType = data.albumSubType;
      list.push(dataTmp);
    }
    this.workerName = ThreadCommonUtil.getWorkerName(Constant.OPERATION_TYPE.DELETE);
    let favoriteList = FavoriteDbManager.getInstance().getFavoriteFileList(fileList, isTrashFile);
    if (operationType === Constant.OPERATION_TYPE.RESTORE) {
      TrashUtil.startRestoreTask(list, this.workerName,
        (result: DeleteRestoreResultParam): void => this.receiveMsgFromWorker(result), favoriteList);
    } else if (operationType === Constant.OPERATION_TYPE.HARD_DELETE) {
      // 硬删除：如果是回收站的文件就走回收站删除接口，否则走fs的接口
      const taskType = isTrashFile ? DeleteRestoreConst.TaskType.DELETE_FILE_FROM_TRASH :
        DeleteRestoreConst.TaskType.PERMANENT_DELETE;
      TrashUtil.startHardDeleteTask(list, this.workerName, taskType,
        (result: DeleteRestoreResultParam): void => this.receiveMsgFromWorker(result), favoriteList,
        mediaSearchType);
    } else {
      TrashUtil.startSoftDeleteTask(list, this.workerName, mediaSearchType,
        (result: DeleteRestoreResultParam): void => this.receiveMsgFromWorker(result), favoriteList);
    }
  }

  /**
   * 取消当前的任务
   */
  public cancel() {
    TrashUtil.cancelWorker(this.workerName);
  }

  /**
   * 接收和处理来自子线程的消息，实现任务进度的交互
   * @param result
   */
  private receiveMsgFromWorker(result: DeleteRestoreResultParam): void {
    if (ObjectUtil.isNullOrUndefined(result)) {
      HiLog.info(TAG, 'receive msg is null.');
      return;
    }
    HiLog.info(TAG, 'receive msg type is: ' + result.resultType);
    switch (result.resultType) {
      case WorkerConst.ResultType.CANCEL:
        this.dealProcessCancel(result);
        break;
      case WorkerConst.ResultType.SUCCESS:
      // 操作结束
        this.dealProcessEnd(result);
        if (result.completeCount) {
          this.updateTrashFileCount();
        }
        break;
      case WorkerConst.ResultType.EXCEPTION:
      // 处理异常
        break;
      case WorkerConst.ResultType.PROGRESS:
        // 更新进度
        this.dealProcessRunning(result);
        break;
      case WorkerConst.DeleteRestoreResultType.SOFT_DELETE_UPDATE_FAVORITE:
      // 软删除更新收藏表
        this.dealSoftDeleteUpdateFavorite(result);
        break;
      case WorkerConst.DeleteRestoreResultType.HARD_DELETE_UPDATE_FAVORITE:
      // 硬删除更新收藏表
        this.dealHardDeleteUpdateFavorite(result);
        break;
      case WorkerConst.DeleteRestoreResultType.RESTORE_UPDATE_FAVORITE:
      // 还原更新收藏表
        this.dealRestoreUpdateFavorite(result);
        break;
      case WorkerConst.ResultType.ERROR:
      case WorkerConst.DeleteRestoreResultType.RESTORE_FAIL:
        this.dealProcessFail(result);
        break;
      default:
        HiLog.info(TAG, 'receive what is wrong');
        break;
    }
  }

  private async dealSoftDeleteUpdateFavorite(result: DeleteRestoreResultParam) {
    if (ObjectUtil.isNullOrUndefined(result)) {
      HiLog.error(TAG, 'dealProcessEnd data is null');
      return;
    }

    FavoriteDbManager.getInstance().updateFileInfoBySoftDelete(result.updateFavoriteList)
      .then((updateResult: boolean) => {
        if (updateResult) {
          EventBus.emitDelay(50, Constant.EVENTS.FAVORITE_REFRESH);
        }
      });
  }


  private async dealHardDeleteUpdateFavorite(result: DeleteRestoreResultParam) {
    if (ObjectUtil.isNullOrUndefined(result)) {
      HiLog.error(TAG, 'dealProcessEnd data is null');
      return;
    }
    FavoriteDbManager.getInstance().clearHardDeleteFileByPath(result.deleteFavoriteIdList)
      .then((updateResult: boolean) => {
        if (updateResult) {
          EventBus.emitDelay(50, Constant.EVENTS.FAVORITE_REFRESH);
        }
      });
  }

  private async dealRestoreUpdateFavorite(result: DeleteRestoreResultParam) {
    if (ObjectUtil.isNullOrUndefined(result)) {
      HiLog.error(TAG, 'dealProcessEnd data is null');
      return;
    }

    FavoriteDbManager.getInstance().updateFileInfoByRestore(result.updateFavoriteList)
      .then((updateResult: boolean) => {
        if (updateResult) {
          EventBus.emitDelay(50, Constant.EVENTS.FAVORITE_REFRESH);
        }
      });
  }

  private updateTrashFileCount(): void {
    if (this.operationType === Constant.OPERATION_TYPE.DELETE) {
      // 软删回收站文件数量增加
      TrashFileUtil.addTrashFileCount(this.trashFileChangeCount);
    } else {
      // 硬删和还原回收站文件数量减少
      TrashFileUtil.reduceTrashFileCount(this.trashFileChangeCount);
    }
  }

  /**
   * 删除还原任务完成处理
   * @param result 消息
   */
  private async dealProcessEnd(result: DeleteRestoreResultParam) {
    HiLog.infoPrivate(TAG, `dealProcessEndStart,isToBackupPath :`, result.isToBackupPath + '');
    if (ObjectUtil.isNullOrUndefined(result)) {
      HiLog.error(TAG, 'dealProcessEnd data is null');
      return;
    }
    this.dealProcessRunning(result);
    if (result.isToBackupPath) {
      // 弹窗提示 还原至升级备份路径
      toast(DeviceConfig.getInstance().config.restoreToTip);
    }
    EventBus.emit(Constant.EVENTS.DELETE_RESTORE_FILE_TASK_END, result.completeCount, result.failCount,
      result.failFileName);
    if ((this.operationType === Constant.OPERATION_TYPE.DELETE) && (this.trashFileChangeCount !== 0)) {
      // 延迟刷新最近删除页面防止影响其他动画
      setTimeout(() => {
        PageUtil.refreshRecentDelete();
      }, 300);
    }
  }

  /**
   * 删除还原任务进度更新处理
   * @param result 消息
   */
  private dealProcessRunning(result: DeleteRestoreResultParam) {
    if (ObjectUtil.isNullOrUndefined(result)) {
      HiLog.error(TAG, 'dealProcessRunning data is null');
      return;
    }
    if (ObjectUtil.isNullOrUndefined(this.updateProgressCallback)) {
      return;
    }
    this.updateProgressCallback(result.completeCount, result.successUris, false);
    this.trashFileChangeCount += result.trashChangeCount;
  }

  private dealProcessFail(result: DeleteRestoreResultParam): void {
    if (ObjectUtil.isNullOrUndefined(result)) {
      HiLog.error(TAG, 'dealProcessError data is null');
      return;
    }
    this.dealProcessRunning(result);
    if (ObjectUtil.isNullOrUndefined(this.deleteFailCallback)) {
      return;
    }

    HiLog.debug(TAG, 'enter dealProcessError');
    this.deleteFailCallback(result.resolveUri);
  }

  private dealProcessCancel(result: DeleteRestoreResultParam): void {
    if (ObjectUtil.isNullOrUndefined(result)) {
      HiLog.error(TAG, 'dealProcessCancel data is null');
      return;
    }
    this.dealProcessRunning(result);
    if (ObjectUtil.isNullOrUndefined(this.cancelDeleteCallBack)) {
      return;
    }
    HiLog.debug(TAG, 'enter dealProcessCancel');
    this.cancelDeleteCallBack(result.resolveUri);
  }
}