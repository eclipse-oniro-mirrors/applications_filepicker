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
import { GlobalHolder, TaskObject, WorkerConst } from '@ohos/common';
import { WorkerPoolManager, SendParams } from '@ohos/common/indexDT'
import { WorkerPool } from '@ohos/common/src/main/ets/worker/WorkerPool'
import { WorkerHandler } from '@ohos/common/src/main/ets/worker/WorkerHandler'
import { beforeAll, describe, expect, it, MockKit } from '@ohos/hypium'
import { TestUtil } from '../../../test/utils/TestUtil';

export default function WorkerPoolManagerTest() {
  describe('WorkerPoolManagerTest', () => {
    beforeAll(() => {
      const workerPoolManager = WorkerPoolManager.getInstance();
      TestUtil.setPrivateAttribute(workerPoolManager, 'instance', null);
    })
    it('getInstance()', 0, async (done: Function) => {
      getInstance();
      done();
    });

    it('isAddQueue', 0, async (done: Function) => {
      const sendParams =
        new SendParams(GlobalHolder.getInstance().getMainAbilityContext(), WorkerConst.OperateType.COPY_FILE, '');
      const taskObj = new TaskObject(sendParams, () => {});
      const workerPoolManager = WorkerPoolManager.getInstance();
      let isAddQueue = TestUtil.getPrivateFunction(workerPoolManager, 'isAddQueue');
      if (!isAddQueue) {
        expect().assertFail();
      } else {
        let result: boolean = isAddQueue(taskObj);
        expect(result).assertFalse();
        TestUtil.setPrivateAttribute(workerPoolManager, 'fileOperateWorkerNum', WorkerConst.WORKER_LIMIT_SIZE);
        result = isAddQueue(taskObj);
        expect(result).assertTrue();
        done();
      }
    });

    it('execute', 0, async (done: Function) => {
      const sendParams = new SendParams(GlobalHolder.getInstance().getMainAbilityContext(), WorkerConst.OperateType.COPY_FILE, '');
      const taskObj = new TaskObject(sendParams, () => {});
      const workerPoolManager = WorkerPoolManager.getInstance();
      let mocker: MockKit = new MockKit();
      TestUtil.getPrivateMockFunction(mocker, workerPoolManager, 'addFileOperateTask');
      TestUtil.setPrivateAttribute(workerPoolManager, 'fileOperateWorkerNum', WorkerConst.WORKER_LIMIT_SIZE);
      workerPoolManager.execute(taskObj);
      mocker.verify('addFileOperateTask', [taskObj]).never();
      TestUtil.setPrivateAttribute(workerPoolManager, 'fileOperateWorkerNum', 0);
      workerPoolManager.execute(taskObj);
      mocker.verify('addFileOperateTask', [taskObj]).once();
      mocker.clear(workerPoolManager);
      done();
    });

    it('addToTaskQueue', 0, async (done: Function) => {
      const sendParams = new SendParams(GlobalHolder.getInstance().getMainAbilityContext(), WorkerConst.OperateType.COPY_FILE, '');
      const taskObj = new TaskObject(sendParams, () => {});
      const workerPoolManager = WorkerPoolManager.getInstance();
      workerPoolManager.addToTaskQueue(taskObj);
      const taskQueue: Array<TaskObject> = TestUtil.getPrivateAttribute(workerPoolManager, 'taskQueue');
      expect(taskQueue).not().assertNull();
      workerPoolManager.addToTaskQueue(taskObj);
      expect(taskQueue.pop()).assertDeepEquals(taskObj)
      done();
    });

    it('releaseAllWorkerPool', 0, async (done: Function) =>{
      releaseAllWorkerPool();
      done();
    })

    it('removeFromTaskQueue', 0, (done: Function) =>{
      const temp = WorkerPoolManager.getInstance();
      const sendParams = new SendParams(GlobalHolder.getInstance().getMainAbilityContext(), WorkerConst.OperateType.COPY_FILE, '');
      const taskObj = new TaskObject(sendParams, () => {});
      temp.removeFromTaskQueue(taskObj);
      let taskQueue: Array<TaskObject> = TestUtil.getPrivateAttribute(temp, 'taskQueue');
      expect(taskQueue).assertNull();
      temp.addToTaskQueue(taskObj);
      temp.removeFromTaskQueue(taskObj);
      taskQueue = TestUtil.getPrivateAttribute(temp, 'taskQueue');
      expect(taskQueue.length).assertEqual(0);
      done();
    })

    it('addFileOperateTask', 0, (done: Function) =>{
      const temp = WorkerPoolManager.getInstance();
      const sendParams = new SendParams(GlobalHolder.getInstance().getMainAbilityContext(), WorkerConst.OperateType.COPY_FILE, '');
      const taskObj = new TaskObject(sendParams, () => {});
      temp.addFileOperateTask(taskObj);
      let fileOperatePool: WorkerPool = TestUtil.getPrivateAttribute(temp, 'fileOperatePool');
      let array: Array<WorkerHandler> = TestUtil.getPrivateAttribute(fileOperatePool, 'workerHandlers');
      expect(array.length).assertEqual(1);
      done();
    })

    it('increaseWorkerNum', 0, (done: Function) =>{
      const temp = WorkerPoolManager.getInstance();
      let num1: number = TestUtil.getPrivateAttribute(temp, 'fileOperateWorkerNum');
      temp.increaseWorkerNum();
      let num2: number = TestUtil.getPrivateAttribute(temp, 'fileOperateWorkerNum');
      expect(num1).assertEqual(num2 - 1);
      done();
    })

    it('decreaseWorkerNum', 0, (done: Function) =>{
      const temp = WorkerPoolManager.getInstance();
      let num1: number = TestUtil.getPrivateAttribute(temp, 'fileOperateWorkerNum');
      temp.decreaseWorkerNum();
      let num2: number = TestUtil.getPrivateAttribute(temp, 'fileOperateWorkerNum');
      expect(num1).assertEqual(num2 + 1);
      done()
    })

    it('executeQueueTask', 0, (done: Function) =>{
      const temp = WorkerPoolManager.getInstance();
      const sendParams = new SendParams(GlobalHolder.getInstance().getMainAbilityContext(), WorkerConst.OperateType.COPY_FILE, '');
      const taskObj = new TaskObject(sendParams, () => {});
      taskObj.state = WorkerConst.WorkerState.IDLE;
      temp.addToTaskQueue(taskObj);
      temp.decreaseWorkerNum();
      let array: Array<TaskObject> = TestUtil.getPrivateAttribute(temp, 'taskQueue');
      expect(array.length).assertEqual(0);
      taskObj.state = WorkerConst.WorkerState.RUNNING;
      temp.addToTaskQueue(taskObj);
      temp.decreaseWorkerNum();
      let array1: Array<TaskObject> = TestUtil.getPrivateAttribute(temp, 'taskQueue');
      expect(array1.length).assertEqual(0);
      done()
    })
  })
}

function getInstance() {
  const temp = WorkerPoolManager.getInstance();
  expect(temp).not().assertNull();
  const temp2 = WorkerPoolManager.getInstance();
  expect(temp2).not().assertUndefined();
}

function releaseAllWorkerPool() {
  const temp = WorkerPoolManager.getInstance();
  temp.addToTaskQueue({} as TaskObject);
  temp.releaseAllWorkerPool();
  expect(temp).not().assertNull();
  expect(TestUtil.getPrivateAttribute(temp, 'taskQueue')).assertNull();
  expect(TestUtil.getPrivateAttribute(temp, 'fileOperatePool')).assertNull();
}