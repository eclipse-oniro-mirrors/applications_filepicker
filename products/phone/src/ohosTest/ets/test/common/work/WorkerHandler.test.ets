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
import { GlobalHolder, TaskObject, WorkerConst } from '@ohos/common'
import { WorkerHandler } from '@ohos/common/src/main/ets/worker/WorkerHandler'
import { WorkerPool } from '@ohos/common/src/main/ets/worker/WorkerPool'
import { BackgroundTaskManager } from '@ohos/common/src/main/ets/worker/BackgroundTask'
import { describe, expect, it, MockKit, when } from '@ohos/hypium'
import { MessageEvents, worker } from '@kit.ArkTS'
import { TestUtil } from '../../utils/TestUtil'
import { ResultParams, SendParams } from '@ohos/common/indexDT'

export default function WorkerHandlerTest() {
  describe('WorkerHandlerTest', () => {
    it('initParams', 0, () => {
      const sendParams =
        new SendParams(GlobalHolder.getInstance().getMainAbilityContext(), WorkerConst.OperateType.COPY_FILE, '');
      const taskObj = new TaskObject(sendParams, () => {});
      let task = {} as TaskObject;
      const workerHandler = new WorkerHandler(task,
      './FileOperateWorker', '114455', new WorkerPool(7,
      './FileOperateWorker', '114455'));
      TestUtil.setPrivateAttribute(workerHandler, 'mWorker', null);
      let workPool = new WorkerPool(7, './FileOperateWorker', '114455');
      const workerHandler1 = new WorkerHandler(taskObj,
        './FileOperateWorker', '114455', workPool);
      try {
        workerHandler.start();
        expect(task.state).not().assertEqual(1);
        workerHandler1.start();
        expect(taskObj.state).assertEqual(1);
      } catch (e) {
        expect().assertFail();
      }

    })

    it('WorkerHandlerTest_onResult', 0, () => {
      const sendParams =
        new SendParams(GlobalHolder.getInstance().getMainAbilityContext(), WorkerConst.OperateType.COPY_FILE, '');
      const taskObj = new TaskObject(sendParams, () => {});

      const workerHandler = new WorkerHandler(taskObj,
        './FileOperateWorker', '114455', new WorkerPool(7,
          './FileOperateWorker', '114455'));
      let onResult = TestUtil.getPrivateFunction(workerHandler, 'onResult');
      if (onResult) {
        onResult({data: {workerStatus: 1}} as MessageEvents)
        expect(taskObj.state).assertEqual(0);
      } else {
        expect().assertFail();
      }
    })
    it('checkNext', 0, () => {
      const sendParams =
        new SendParams(GlobalHolder.getInstance().getMainAbilityContext(), WorkerConst.OperateType.COPY_FILE, '');
      const taskObj = new TaskObject(sendParams, () => {});
      let workPool = new WorkerPool(7, './FileOperateWorker', '114455');
      const workerHandler = new WorkerHandler(taskObj,
        './FileOperateWorker', '114455', workPool);
      let checkNext = TestUtil.getPrivateFunction(workerHandler, 'checkNext');
      if (checkNext) {
        TestUtil.setPrivateAttribute(workerHandler, 'mWorker', null);
        checkNext();
        expect(taskObj.state).assertEqual(0);

        TestUtil.setPrivateAttribute(workerHandler, 'mWorker', new Object() as worker.ThreadWorker);
        workPool.closeAllWorkers();
        taskObj.state = -2;
        let mocker: MockKit = new MockKit();
        let close = mocker.mockFunc(workerHandler, workerHandler.close);
        when(close)().afterReturnNothing();
        checkNext();
        mocker.verify('close', []).once();

        workPool.closeAllWorkers();
        const taskObj1 = new TaskObject(sendParams, () => {});
        taskObj1.state = 0;
        let getNext = mocker.mockFunc(workPool, workPool.getNextTask);
        let initParams = TestUtil.getPrivateMockFunction(mocker, workerHandler, 'initParams')
        let mockInitParams = mocker.mockFunc(workerHandler, initParams)
        let start = mocker.mockFunc(workerHandler, workerHandler.start)
        when(getNext)().afterReturn(taskObj1);
        when(mockInitParams)().afterReturn(null);
        when(start)().afterReturn(null);
        checkNext();
        mocker.clear(workPool);
        mocker.clear(workerHandler);
        mocker.verify('start', []).once();
      } else {
        expect().assertFail();
      }
    })
    it('onMessageError', 0, () => {
      const sendParams =
        new SendParams(GlobalHolder.getInstance().getMainAbilityContext(), WorkerConst.OperateType.COPY_FILE, '');
      const taskObj = new TaskObject(sendParams, () => {});

      const workerHandler = new WorkerHandler(taskObj,
        './FileOperateWorker', '114455', new WorkerPool(7,
          './FileOperateWorker', '114455'));
      let onMessageError = TestUtil.getPrivateFunction(workerHandler, 'onMessageError');
      if (onMessageError) {
        onMessageError(undefined);
        expect(taskObj.state).assertEqual(0);
        onMessageError(new Object());
        expect(taskObj.state).assertEqual(0);
        let msg = {data: new ResultParams('', 0, WorkerConst.WorkerStatus.FAIL, 6) as ResultParams} as MessageEvents;
        let mTaskObj = TestUtil.getPrivateAttribute<TaskObject>(workerHandler, 'mTaskObj');
        let mocker = new MockKit();
        let onResult = mocker.mockFunc(mTaskObj, mTaskObj.onResult);
        when(onResult)().afterReturn(null);
        onMessageError(msg);
        mocker.clear(mTaskObj);
        expect(taskObj.state).assertEqual(0);
      } else {
        expect().assertFail();
      }
    })

    it('onError', 0, () => {
      const sendParams =
        new SendParams(GlobalHolder.getInstance().getMainAbilityContext(), WorkerConst.OperateType.COPY_FILE, '');
      const taskObj = new TaskObject(sendParams, () => {});
      const workerHandler = new WorkerHandler(taskObj,
        './FileOperateWorker', '114455', new WorkerPool(7,
          './FileOperateWorker', '114455'));
      let onError = TestUtil.getPrivateFunction(workerHandler, 'onError');
      if (onError) {
        onError()
        let mTaskObj = TestUtil.getPrivateAttribute<TaskObject>(workerHandler, 'mTaskObj');
        expect(mTaskObj.params.operateType).assertEqual(1);
      } else {
        expect().assertFail();
      }
    })

    it('onExit', 0, () => {
      const sendParams =
        new SendParams(GlobalHolder.getInstance().getMainAbilityContext(), WorkerConst.OperateType.COPY_FILE, '');
      const taskObj = new TaskObject(sendParams, () => {});
      const workerHandler = new WorkerHandler(taskObj,
        './FileOperateWorker', '114455', new WorkerPool(7,
          './FileOperateWorker', '114455'));
      let onExit = TestUtil.getPrivateFunction(workerHandler, 'onExit');
      if (onExit) {
        onExit();
        let mWorker = TestUtil.getPrivateAttribute<TaskObject>(workerHandler, 'mWorker');
        expect(mWorker).assertNull();
      } else {
        expect().assertFail();
      }
    })

    it('close', 0, () => {
      const sendParams =
        new SendParams(GlobalHolder.getInstance().getMainAbilityContext(), WorkerConst.OperateType.COPY_FILE, '');
      const taskObj = new TaskObject(sendParams, () => {});
      const workerHandler = new WorkerHandler(taskObj,
        './FileOperateWorker', '114455', new WorkerPool(7,
          './FileOperateWorker', '114455'));
      TestUtil.setPrivateAttribute(workerHandler, 'mWorker', null);
      BackgroundTaskManager.applyBackgroundTask('taskName');
      workerHandler.close();
      expect(BackgroundTaskManager.isApplied).assertTrue();
    })
  })
}