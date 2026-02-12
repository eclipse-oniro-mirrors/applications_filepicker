/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import { CopyCutSendParam } from '../workermanager/copycutmanager/CopyCutSendParam';
import WorkerConst from '../worker/WorkerConst';
import { CopyCutManager } from '../workermanager/copycutmanager/CopyCutManager';
import { HiLog } from '../dfx/HiLog';
import CopyCutConst from '../workermanager/copycutmanager/CopyCutConst';
import { CopyCutResultParam } from '../workermanager/copycutmanager/CopyCutResultParam';

const TAG_PU = 'PasteUtil';

export class PasteUtil {

  public static startCopyCutTask(copyCutSendParam: CopyCutSendParam,
    callback: (result: CopyCutResultParam) => void): void {
    let copyCutManager = new CopyCutManager();
    AppStorage.setOrCreate<CopyCutManager>(copyCutSendParam.workerName, copyCutManager);
    copyCutManager.startPasteCopyCutTask(copyCutSendParam, callback);
  }

  public static sendConflictChooseMessage(workerName: string, chooseType: CopyCutConst.ChooseType,
    isApplyAll: boolean, operateType?: WorkerConst.OperateType): void {
    // 保留两者
    HiLog.info(TAG_PU, 'PasteExistDupFile firstButtonClick: keep both');
    let copyCutManager = AppStorage.get<CopyCutManager>(workerName) as CopyCutManager;
    if (copyCutManager) {
      copyCutManager.sendMsgToWorker(
        workerName,
        chooseType,
        CopyCutConst.SendMsgCode.CONFLICT,
        operateType,
        isApplyAll);
    } else {
      HiLog.info(TAG_PU, 'nocopyCutManager');
    }
  }

  public static sendMsg(workerName: string, sendMsgCode: CopyCutConst.SendMsgCode,
    operateType?: WorkerConst.OperateType): void {
    // 保留两者
    HiLog.info(TAG_PU, 'PasteExistDupFile firstButtonClick: keep both');
    let copyCutManager = AppStorage.get<CopyCutManager>(workerName) as CopyCutManager;
    if (copyCutManager) {
      copyCutManager.sendMsgToWorker(
        workerName,
        undefined,
        sendMsgCode,
        operateType,
        false);
    } else {
      HiLog.info(TAG_PU, 'nocopyCutManager');
    }
  }

  public static cancelWorker(workerName: string, operateType?: WorkerConst.OperateType): void {
    let copyCutManager = AppStorage.get<CopyCutManager>(workerName);
    if (!(copyCutManager)) {
      HiLog.info(TAG_PU, 'cancel worker manager is null');
      return;
    }
    copyCutManager.sendMsgToWorker(
      workerName,
      CopyCutConst.ChooseType.STOP,
      CopyCutConst.SendMsgCode.CANCEL,
      operateType,
    );
  }

  public static continueToRunWorker(workerName: string, operateType?: WorkerConst.OperateType): void {
    let copyCutManager = AppStorage.get<CopyCutManager>(workerName);
    if (!(copyCutManager)) {
      HiLog.info(TAG_PU, 'cancel worker manager is null');
      return;
    }
    copyCutManager.sendMsgToWorker(
      workerName,
      CopyCutConst.ChooseType.CONTINUE_TO_RUN,
      CopyCutConst.SendMsgCode.EXCEPTION_CONTINUE_TO_RUN,
      operateType,
    );
  }
}