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
import { TaskObject, WorkerConst } from '@ohos/common'
import { ResultParams, SendParams } from '@ohos/common/indexDT'
import { describe, expect, it } from '@ohos/hypium'
import { worker } from '@kit.ArkTS'

export default function TaskObjectTest() {
  describe('TaskObjectTest', () => {
    it('TaskObjectTest_updateState', 0, (done: Function) => {
      updateState();
      done();
    })

    it('TaskObjectTest_bindWorker', 0, (done: Function) => {
      bindWorker();
      done();
    })

    it('TaskObjectTest_cancel', 0, (done: Function) => {
      cancel();
      done();
    })

    it('TaskObjectTest_onResult', 0, (done: Function) => {
      onResult();
      done();
    })
    it('TaskObjectTest_notifyMsg', 0, (done: Function) => {
      notifyMsg();
      done();
    })
  })
}

function updateState() {
  const taskObj = new TaskObject({} as SendParams, () => {
  });
  expect(taskObj).not().assertUndefined();
  taskObj.updateState(WorkerConst.WorkerState.FINISH);
  expect(taskObj.state).assertEqual( WorkerConst.WorkerState.IDLE);
  taskObj.updateState(WorkerConst.WorkerState.RUNNING);
  expect(taskObj.state).assertEqual(WorkerConst.WorkerState.RUNNING);
}

function bindWorker() {
  const taskObj = new TaskObject({} as SendParams, () => {
  });
  const param = {} as worker.ThreadWorker;
  taskObj.bindWorker(param);
  expect(taskObj).not().assertUndefined();
  expect(taskObj.worker).assertDeepEquals(param);
}

function notifyMsg() {
  const taskObj = new TaskObject({} as SendParams, () => {
  });
  expect(taskObj).not().assertUndefined();
  taskObj.state = WorkerConst.WorkerState.RUNNING;
  try {
    taskObj.notifyMsg({} as SendParams);
    expect(true).assertTrue();
  } catch (e) {
    expect().assertFail();
  }
}

function cancel() {
  const taskObj = new TaskObject({} as SendParams, () => {
  });
  expect(taskObj).not().assertUndefined();
  taskObj.state = WorkerConst.WorkerState.FINISH;
  taskObj.cancel();
  expect(taskObj.state).assertEqual( WorkerConst.WorkerState.FINISH);
  taskObj.state = WorkerConst.WorkerState.RUNNING;
  taskObj.cancel();
  expect(taskObj.state).assertEqual( WorkerConst.WorkerState.CANCEL);
}

function onResult() {
  const taskObj = new TaskObject({} as SendParams, () => {
  });
  taskObj.state = WorkerConst.WorkerState.FINISH;
  taskObj.fuc = undefined;
  taskObj.onResult({} as ResultParams);
  taskObj.fuc = (param: ResultParams) => {
  };
  taskObj.onResult({} as ResultParams);
  expect(taskObj).not().assertUndefined();
}