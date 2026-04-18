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

import { HiLog, TimeUtil, TaskManager, TaskConst } from '@ohos/common';
import { describe, it, expect } from '@ohos/hypium';
import { TestTask } from './TestTask';

const TAG = 'TaskTest';

export default function TaskManagerTest() {
  describe('TaskManagerTest', () => {
    it('execute_undefined', 0, () => {
      TaskManager.getInstance().execute<void>(undefined);
      expect(TaskManager.executorMap.length).assertEqual(0);
    });

    it('execute_1_TestTask', 0, () => {
      let task1: TestTask = new TestTask(() => {
        HiLog.info(TAG, 'execute task1 callback');
      });

      TaskManager.getInstance().execute<void>(task1);
      expect(TaskManager.executorMap.length).assertEqual(1);
    });

    it('execute_2_TestTask', 0, () => {
      let task1: TestTask = new TestTask(() => {
        HiLog.info(TAG, 'execute task1 callback');
      });
      let task2: TestTask = new TestTask(() => {
        HiLog.info(TAG, 'execute task2 callback');
      });

      TaskManager.getInstance().execute<void>(task1);
      TaskManager.getInstance().execute<void>(task2);
      expect(TaskManager.executorMap.length).assertEqual(1);
    });

    it('testReject_1_TestTask', 0, async () => {
      let task1: TestTask = new TestTask(() => {
        HiLog.info(TAG, 'execute task1 callback');
      });
      TaskManager.getInstance().execute<void>(task1, 1, true, undefined, TaskConst.taskExecuteMode.reject);
      expect(TaskManager.executorMap.length).assertEqual(1);
    });

    it('testReject_2_TestTask', 0, async () => {
      let task1: TestTask = new TestTask(() => {
        HiLog.info(TAG, 'execute task1 callback');
      });
      let task2: TestTask = new TestTask(() => {
        HiLog.info(TAG, 'execute task2 callback');
      });
      TaskManager.getInstance().execute<void>(task1, 1, true, undefined, TaskConst.taskExecuteMode.reject);
      await TimeUtil.sleep(1000);
      TaskManager.getInstance().execute<void>(task2, 1, true, undefined, TaskConst.taskExecuteMode.reject);
      expect(TaskManager.executorMap.length).assertEqual(1);
    });

    it('testExecuteNow_1_TestTask', 0, async () => {
      let task1: TestTask = new TestTask(() => {
        HiLog.info(TAG, 'execute task1 callback');
      });

      TaskManager.getInstance().execute<void>(task1, 1, true, undefined, TaskConst.taskExecuteMode.executeNow);
      expect(TaskManager.executorMap.length).assertEqual(1);
    });

    it('testExecuteNow_2_TestTask', 0, async () => {
      let task1: TestTask = new TestTask(() => {
        HiLog.info(TAG, 'execute task1 callback');
      });
      let task2: TestTask = new TestTask(() => {
        HiLog.info(TAG, 'execute task2 callback');
      });
      TaskManager.getInstance().execute<void>(task1, 1, true, undefined, TaskConst.taskExecuteMode.executeNow);
      await TimeUtil.sleep(1000);
      TaskManager.getInstance().execute<void>(task2, 1, true, undefined, TaskConst.taskExecuteMode.executeNow);
      expect(TaskManager.executorMap.length).assertEqual(1);
    });

    it('executorFreeCallback', 0, async () => {
      TaskManager.getInstance().executorFreeCallback('TestTask');
      expect(TaskManager.executorMap.length).assertEqual(0);
    });

    it('cancelExecutorTask_TestTask', 0, async () => {
      TaskManager.getInstance().cancelExecutorTask('TestTask');
      expect(TaskManager.executorMap.length).assertEqual(0);
    });

    it('cancelExecutorTask_empty_string', 0, async () => {
      TaskManager.getInstance().cancelExecutorTask('');
      expect(TaskManager.executorMap.length).assertEqual(0);
    });
  });
}