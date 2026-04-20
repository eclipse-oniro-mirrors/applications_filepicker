/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { FileInfo } from './FileInfo';
import { HiLog } from '../dfx/HiLog';
import { DeleteRestoreManager } from '../workermanager/deleterestoremanager/DeleteRestoreManager';
import { GlobalHolder } from '../global/GlobalHolder';
import { ThreadCommonUtil } from '../workeroperate/fs/ThreadCommonUtil';
import WorkerConst from '../worker/WorkerConst';
import DeleteRestoreConst from '../workermanager/deleterestoremanager/DeleteRestoreConst';
import { DeleteRestoreSendParam } from '../workermanager/deleterestoremanager/DeleteRestoreSendParam';
import { StringUtil } from '../utils/StringUtil';
import type { FavoriteModel } from '../model/FavoriteModel';
import { DeleteRestoreResultParam } from '../workermanager/deleterestoremanager/DeleteRestoreResultParam';
import lazy { PhotoAccessUtil } from '../utils/PhotoAccessUtil';
import { Constant } from '../const/Constant';
import lazy TrashNapi from 'libTrash.so';

const TAG = 'TrashUtil';
const DELETE_WORKER_NAME_TAG = 'forceOrTrashDelete';

export class TrashUtil {
  /**
   * 调底层接口获取回收站内所有的文件
   */
  public static getTrashFileList(): Array<TrashNapi.FileInfo> {
    let trashFileList: TrashNapi.FileInfo[] = [];
    try {
      trashFileList = TrashNapi.listTrashFile();
    } catch (error) {
      HiLog.error(TAG, 'getTrashFileList fail, error:' + JSON.stringify(error));
    }
    return trashFileList;
  }

  /**
   * 软删
   * @param toOperateFiles
   * @param workerName
   * @param callback
   */
  public static startSoftDeleteTask(toOperateFiles: FileInfo[], workerName: string = '', mediaSearchType: number = -1,
    callback: (result: DeleteRestoreResultParam) => void,
    favoriteList: FavoriteModel[] = []): void {
    if ((!toOperateFiles) || (toOperateFiles.length <= 0)) {
      HiLog.info(TAG, 'startSoftDeleteTask, toOperateFiles null');
      return;
    }
    HiLog.info(TAG, 'startSoftDeleteTask, filesLen: ' + toOperateFiles.length);
    let context = GlobalHolder.getInstance().getMainAbilityContext() ||
      GlobalHolder.getInstance().getUIExtensionContext();
    if (StringUtil.isEmpty(workerName)) {
      workerName = ThreadCommonUtil.getWorkerName(DELETE_WORKER_NAME_TAG);
    }
    let deleteRestoreSendParam: DeleteRestoreSendParam = new DeleteRestoreSendParam(
      context,
      WorkerConst.OperateType.SOFT_DELETE_FILE,
      workerName,
      toOperateFiles,
      DeleteRestoreConst.SendMsgCode.START,
      undefined,
      false
    );
    const showHiddenItem = AppStorage.get<boolean>(Constant.SHOW_HIDDEN_ITEM_OPTION_NAME) ?? false;
    deleteRestoreSendParam.isShowHiddenItem = showHiddenItem;
    deleteRestoreSendParam.favoriteList = favoriteList;
    deleteRestoreSendParam.mediaSearchType = mediaSearchType;
    let deleteRestoreManager = new DeleteRestoreManager();
    AppStorage.setOrCreate<DeleteRestoreManager>(deleteRestoreSendParam.workerName, deleteRestoreManager);
    deleteRestoreManager.deleteRestoreFileTask(deleteRestoreSendParam, callback);
  }

  /**
   * 硬删除
   * @param toOperateFiles
   * @param workerName
   * @param callback
   */
  public static startHardDeleteTask(toOperateFiles: FileInfo[], workerName: string = '',
    taskType: DeleteRestoreConst.TaskType, callback: (result: DeleteRestoreResultParam) => void,
    favoriteList: FavoriteModel[] = [], mediaSearchType: number = -1): void {
    if ((!toOperateFiles) || (toOperateFiles.length <= 0)) {
      HiLog.info(TAG, 'startHardDeleteTask, toOperateFiles null');
      return;
    }
    HiLog.info(TAG, 'startHardDeleteTask, filesLen: ' + toOperateFiles.length);
    let context = GlobalHolder.getInstance().getMainAbilityContext() ||
      GlobalHolder.getInstance().getUIExtensionContext();
    if (StringUtil.isEmpty(workerName)) {
      workerName = ThreadCommonUtil.getWorkerName(DELETE_WORKER_NAME_TAG);
    }
    let deleteRestoreSendParam: DeleteRestoreSendParam = new DeleteRestoreSendParam(
      context,
      WorkerConst.OperateType.DELETE_FILE,
      workerName,
      toOperateFiles,
      DeleteRestoreConst.SendMsgCode.START,
      undefined,
      false,
      '',
      taskType
    );
    const showHiddenItem = AppStorage.get<boolean>(Constant.SHOW_HIDDEN_ITEM_OPTION_NAME) ?? false;
    deleteRestoreSendParam.isShowHiddenItem = showHiddenItem;
    deleteRestoreSendParam.favoriteList = favoriteList;
    deleteRestoreSendParam.mediaSearchType = mediaSearchType;
    let deleteRestoreManager = new DeleteRestoreManager();
    AppStorage.setOrCreate<DeleteRestoreManager>(deleteRestoreSendParam.workerName, deleteRestoreManager);
    deleteRestoreManager.deleteRestoreFileTask(deleteRestoreSendParam, callback);
  }

  /*
  * 还原回收站中的文件
  * */
  public static startRestoreTask(toOperateFiles: FileInfo[], workerName: string = '',
    callback: (result: DeleteRestoreResultParam) => void, favoriteList: FavoriteModel[] = []): void {
    if ((!toOperateFiles) || (toOperateFiles.length <= 0)) {
      HiLog.info(TAG, 'startRestoreTask, toOperateFiles null');
      return;
    }
    HiLog.info(TAG, 'startRestoreTask, filesLen: ' + toOperateFiles.length);
    let context = GlobalHolder.getInstance().getMainAbilityContext() ||
      GlobalHolder.getInstance().getUIExtensionContext();
    if (StringUtil.isEmpty(workerName)) {
      workerName = ThreadCommonUtil.getWorkerName(DELETE_WORKER_NAME_TAG);
    }
    let deleteRestoreSendParam: DeleteRestoreSendParam = new DeleteRestoreSendParam(
      context,
      WorkerConst.OperateType.RESTORE_FILE,
      workerName,
      toOperateFiles,
      DeleteRestoreConst.SendMsgCode.START,
      undefined,
      false
    );
    deleteRestoreSendParam.favoriteList = favoriteList;
    let deleteRestoreManager = new DeleteRestoreManager();
    AppStorage.setOrCreate<DeleteRestoreManager>(deleteRestoreSendParam.workerName, deleteRestoreManager);
    deleteRestoreManager.deleteRestoreFileTask(deleteRestoreSendParam, callback);
  }

  public static cancelWorker(workerName: string): void {
    let deleteManager = AppStorage.get<DeleteRestoreManager>(workerName);
    if (!deleteManager) {
      HiLog.info(TAG, 'cancel worker manager is null');
      return;
    }
    deleteManager.cancelWorker(workerName);
  }
}