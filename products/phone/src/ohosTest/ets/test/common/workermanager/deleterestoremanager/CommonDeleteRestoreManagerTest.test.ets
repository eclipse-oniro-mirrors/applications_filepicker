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
  DeleteRestoreConst,
  DeleteRestoreManager,
  DeleteRestoreResultParam,
  DeleteRestoreSendParam,
  FileInfo,
  GlobalHolder,
  HiLog,
  TaskObject,
  WorkerConst
} from "@ohos/common";
import { ArgumentMatchers, describe, it, MockKit, when } from "@ohos/hypium";
import { TestUtil } from "../../../../test/utils/TestUtil";
import { WorkerPoolManager } from '@ohos/common/src/main/ets/worker/WorkerPoolManager';
import { worker } from "@kit.ArkTS";

export default function CommonDeleteRestoreManagerTest() {
  describe('CommonDeleteRestoreManagerTest', () => {
    const TAG: string = 'DeleteRestoreManager';

    it('deleteRestoreFileTask_empty_files', 0, async (done: Function) => {
      const instance = WorkerPoolManager.getInstance();
      let mocker: MockKit = new MockKit();
      let execute = TestUtil.getPrivateMockFunction(mocker, instance, 'execute');
      when(execute)(ArgumentMatchers.any).afterReturnNothing;
      const deleteRestoreManager = new DeleteRestoreManager();
      const param = buildDeleteRestoreSendParam();
      await deleteRestoreManager.deleteRestoreFileTask(param, (result: DeleteRestoreResultParam) => {});
      mocker.clear(instance);
      mocker.verify('execute', [deleteRestoreManager.taskObj]).never();
      done();
    })

    it('deleteRestoreFileTask_execute', 0, async (done: Function) => {
      const instance = WorkerPoolManager.getInstance();
      let mocker: MockKit = new MockKit();
      TestUtil.getPrivateMockFunction(mocker, instance, 'execute');
      const deleteRestoreManager = new DeleteRestoreManager();
      const param = buildDeleteRestoreSendParam();
      param.toOperateFiles = [new FileInfo()];
      await deleteRestoreManager.deleteRestoreFileTask(param, (result: DeleteRestoreResultParam) => {});
      mocker.clear(instance);
      mocker.verify('execute', [deleteRestoreManager.taskObj]).once();
      done();
    })

    it('deleteRestoreManager_cancelWorker_taskObj_null', 0, () => {
      const deleteRestoreManager = new DeleteRestoreManager();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.error);
      deleteRestoreManager.taskObj = null;
      deleteRestoreManager.cancelWorker('');
      mocker.clear(HiLog);
      mocker.verify('error', [TAG, 'taskObj is null.']).once();
    })

    it('deleteRestoreManager_cancelWorker_worker_null', 0, () => {
      const deleteRestoreManager = new DeleteRestoreManager();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.error);
      const param = buildDeleteRestoreSendParam();
      deleteRestoreManager.taskObj = new TaskObject(param, () => {});
      deleteRestoreManager.cancelWorker('');
      mocker.clear(HiLog);
      mocker.verify('error', [TAG, 'worker is null.']).once();
    })

    it('deleteRestoreManager_cancelWorker_notify', 0, () => {
      const deleteRestoreManager = new DeleteRestoreManager();
      let mocker: MockKit = new MockKit();
      const param = buildDeleteRestoreSendParam();
      deleteRestoreManager.taskObj = new TaskObject(param, () => {});
      deleteRestoreManager.taskObj.worker = {} as worker.ThreadWorker;
      let globalInstance = GlobalHolder.getInstance();
      mocker.mockFunc(globalInstance, globalInstance.getMainAbilityContext);
      deleteRestoreManager.cancelWorker('');
      mocker.clear(globalInstance);
      mocker.verify('getMainAbilityContext', []).once();
    })
  })
}

function buildDeleteRestoreSendParam(): DeleteRestoreSendParam {
  return new DeleteRestoreSendParam(
    GlobalHolder.getInstance().getAppContext(),
    WorkerConst.OperateType.DELETE_FILE,
    '',
    [],
    DeleteRestoreConst.SendMsgCode.START,
    undefined,
    false,
  );
}