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
import { TaskObject } from '@ohos/common';
import { WorkerHandler } from '@ohos/common/src/main/ets/worker/WorkerHandler';
import { WorkerPool } from '@ohos/common/src/main/ets/worker/WorkerPool';
import { describe, expect, it } from '@ohos/hypium'
import { TestUtil } from '../../../test/utils/TestUtil';

export default function WorkerPoolTest() {
  describe('WorkerPoolTest', () => {
    it('constructor', 0, async (done: Function) => {
      constructor();
      done();
    });

    it('addTask', 0, async (done: Function) => {
      const temp = new WorkerPool(0, '', '');
      temp.removeWorkerHandler({} as WorkerHandler);
      expect(temp).not().assertUndefined();

      temp.addTask({} as TaskObject);
      let re = temp.getNextTask();
      expect(re).not().assertNull();
      done();
    });

    it('getNextTask', 0, async (done: Function) => {
      const temp = new WorkerPool(0, '', '');
      const result = temp.getNextTask();
      expect(result).assertNull();
      const param = {} as TaskObject;
      temp.addTask(param);
      const result2 = temp.getNextTask();
      expect(result2).assertDeepEquals(param);
      done();
    });

    it('removeWorkerHandler', 0, async (done: Function) => {
      const temp = new WorkerPool(0, '', '');
      temp.removeWorkerHandler({} as WorkerHandler);
      expect(temp).not().assertNull();
      done();
    });

    it('closeAllWorkers', 0, async (done: Function) => {
      const temp = new WorkerPool(0, '', '');
      temp.closeAllWorkers();
      temp.addTask({} as TaskObject);
      temp.closeAllWorkers();
      expect(temp).not().assertNull();
      expect(TestUtil.getPrivateAttribute(temp, 'taskQueue')).assertNull();
      expect(TestUtil.getPrivateAttribute(temp, 'workerHandlers')).assertDeepEquals([]);
      done();
    });
  })
}

function constructor() {
  const temp = new WorkerPool(-1, '', '');
  expect(temp).not().assertUndefined();
  const fun: string = TestUtil.getPrivateAttribute(temp, 'workerPath')
  if (fun) {
    expect(fun).assertEqual('');
  }
  const fun2: string = TestUtil.getPrivateAttribute(temp, 'workerName')
  if (fun2) {
    expect(fun2).assertEqual('');
  }
}