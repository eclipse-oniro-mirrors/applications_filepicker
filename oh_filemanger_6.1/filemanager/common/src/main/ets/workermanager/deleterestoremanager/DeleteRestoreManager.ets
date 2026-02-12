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
import { HiLog } from '../../dfx/HiLog';
import { StorageDeviceManager } from '../../externel/StorageDeviceManager';
import type { FileInfo } from '../../fileoperate/FileInfo';
import { ArrayUtil } from '../../utils/ArrayUtil';
import { ObjectUtil } from '../../utils/ObjectUtil';
import { ResultCode } from '../../worker/ResultCode';
import { TaskObject } from '../../worker/TaskObject';
import WorkerConst from '../../worker/WorkerConst';
import { WorkerPoolManager } from '../../worker/WorkerPoolManager';
import { MessageNotify } from '../MessageNotify';
import { ProgressBarInfo } from '../ProgressBarInfo';
import { ProgressInfo } from '../ProgressInfo';
import { ProgressTipInfo } from '../ProgressTipInfo';
import DeleteRestoreConst from './DeleteRestoreConst';
import type { DeleteRestoreResultParam } from './DeleteRestoreResultParam';
import { DeleteRestoreSendParam } from './DeleteRestoreSendParam';
import { GlobalHolder } from '../../global/GlobalHolder';
import { TraceUtils } from '../../dfx/TraceUtils';
import { HiTraceConst } from '../../const/HiTraceConst';
import { ThreadCommonUtil } from '../../workeroperate/fs/ThreadCommonUtil';
import { DeviceInfoUtil } from '../../utils/DeviceInfoUtil';
import { Callback } from '@ohos.base';
import lazy { promptAction } from '../../../../../indexLazyLoad';

const TAG = 'DeleteRestoreManager';

export class DeleteRestoreManager {
  /**
   * 任务类
   */
  public taskObj: TaskObject | null = null;
  /**
   * 操作类型
   */
  public operateType: WorkerConst.OperateType = WorkerConst.OperateType.CANCEL;

  /**
   * 删除还原文件
   * @param copyCutSendParam 请求参数
   */
  public async deleteRestoreFileTask(deleteRestoreSendParam: DeleteRestoreSendParam,
    callback: (result: DeleteRestoreResultParam) => void): Promise<void> {
    try {
      if (ObjectUtil.isNullOrUndefined(deleteRestoreSendParam)) {
        HiLog.warn(TAG, 'deleteRestoreFileTask list is null');
        return;
      }
      if (deleteRestoreSendParam.operateType === WorkerConst.OperateType.DELETE_FILE) {
        TraceUtils.startTraceWithTaskId(HiTraceConst.FORCE_DELETE,
          ThreadCommonUtil.getTimeByWorkerName(deleteRestoreSendParam.workerName));
      }
      this.operateType = deleteRestoreSendParam.operateType;
      deleteRestoreSendParam.diskInfoList = await StorageDeviceManager.getInstance().getStorageDeviceList();
      let toOperateFiles: FileInfo[] = deleteRestoreSendParam.toOperateFiles;
      if (ArrayUtil.isEmpty(toOperateFiles)) {
        HiLog.warn(TAG, 'deleteRestoreFileTask list is null');
        return;
      }
      this.taskObj = new TaskObject(deleteRestoreSendParam, callback);
      WorkerPoolManager.getInstance().execute(this.taskObj);
    } catch (err) {
      HiLog.error(TAG, 'deleteRestoreFileTask error: ' + JSON.stringify(err));
    }
  }

  public cancelWorker(workerName: string): void {
    if (!this.taskObj) {
      HiLog.error(TAG, 'taskObj is null.');
      return;
    }
    if (!this.taskObj.worker) {
      HiLog.error(TAG, 'worker is null.');
      return;
    }

    let deleteRestoreSendParam = new DeleteRestoreSendParam(
      GlobalHolder.getInstance().getMainAbilityContext(),
      this.operateType,
      workerName,
      [],
      DeleteRestoreConst.SendMsgCode.CANCEL,
      undefined,
      false
    );

    this.taskObj.notifyMsg(deleteRestoreSendParam);
  }
}