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
import { ObjectUtil } from '../../utils/ObjectUtil';
import { CopyCutSendParam } from './CopyCutSendParam';
import { ArrayUtil } from '../../utils/ArrayUtil';
import { WorkerPoolManager } from '../../worker/WorkerPoolManager';
import { TaskObject } from '../../worker/TaskObject';
import type { CopyCutResultParam } from './CopyCutResultParam';
import WorkerConst from '../../worker/WorkerConst';
import { MessageNotify } from '../MessageNotify';
import type { FileInfo } from '../../fileoperate/FileInfo';
import { HiLog } from '../../dfx/HiLog';
import CopyCutConst from './CopyCutConst';
import { GlobalHolder } from '../../global/GlobalHolder';
import { TraceUtils } from '../../dfx/TraceUtils';
import { ThreadCommonUtil } from '../../workeroperate/fs/ThreadCommonUtil';
import { HiSysEventUtil } from '../../dfx/HiSysEventUtil';
import { OperateName, OperateResult } from '../../const/HiSysEventConst';

const TAG = 'CopyCutManager';

export class CopyCutManager {
  /**
   * 任务类
   */
  public taskObj: TaskObject | null = null;

  public isProgressVisible: boolean = false;


  /**
   * 粘贴移动文件
   * @param copyCutSendParam 请求参数
   */
  public startPasteCopyCutTask(copyCutSendParam: CopyCutSendParam,
    callback: (result: CopyCutResultParam) => void): void {
    try {
      if (ObjectUtil.isNullOrUndefined(CopyCutSendParam)) {
        HiLog.warn(TAG, 'startPasteCutTask list is null');
        return;
      }
      TraceUtils.startTraceWithTaskId(MessageNotify.getTraceTaskType(copyCutSendParam.operateType),
        ThreadCommonUtil.getTimeByWorkerName(copyCutSendParam.workerName));
      let toOperateFiles: FileInfo[] = copyCutSendParam.toOperateFiles;
      if (ArrayUtil.isEmpty(toOperateFiles)) {
        HiLog.warn(TAG, 'startPasteCutTask list is null');
        return;
      }
      this.taskObj = new TaskObject(copyCutSendParam, callback);
      WorkerPoolManager.getInstance().execute(this.taskObj);
    } catch (err) {
      HiSysEventUtil.reportFileOperation(OperateName.PASTE, 'files', OperateResult.FAIL);
      HiLog.error(TAG, 'startPasteCutTask error: ' + JSON.stringify(err));
    }
  }

  /**
   * 主线程向worker发送消息
   * @param operateType 操作类型
   * @param workerName 线程名称
   * @param chooseType 弹窗提示处理结果
   */
  public sendMsgToWorker(workerName: string = '', chooseType: CopyCutConst.ChooseType = CopyCutConst.ChooseType.DEFAULT,
    sendMsgCode: CopyCutConst.SendMsgCode, operateType?: WorkerConst.OperateType, isApplyToAll: boolean = false): void {
    if (!this.taskObj) {
      HiLog.error(TAG, 'taskObj is null.');
      return;
    }
    if (!this.taskObj.worker) {
      HiLog.error(TAG, 'worker is null.');
      return;
    }
    HiLog.info(TAG, 'isApplyToAll: ' + isApplyToAll);
    let copyCutSendParam = new CopyCutSendParam(
      GlobalHolder.getInstance().getMainAbilityContext(),
      operateType,
      workerName,
      [],
      '',
      sendMsgCode,
      chooseType,
      isApplyToAll,
      '',
      ''
    );

    this.taskObj.notifyMsg(copyCutSendParam);
  }
}