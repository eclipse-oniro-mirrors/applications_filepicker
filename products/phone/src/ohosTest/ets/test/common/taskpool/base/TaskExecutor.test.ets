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
import { BaseTask } from '@ohos/common';
import { TaskExecutor } from '@ohos/common/src/main/ets/taskpool/base/TaskExecutor';
import { afterEach, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { TestUtil } from '../../../utils/TestUtil';

class FakeTask {
  task: string;

  constructor(task = '') {
    this.task = task;
  }

  public cancelTask() {
  }
}

export default function TaskExecutorTest() {
  describe('TaskExecutorTest', () => {
    let mocker: MockKit;

    beforeEach(() => {
      mocker = new MockKit();
    });

    afterEach(() => {
      if (mocker) {
        mocker.clearAll();
      }
    });

    it('addTask_undefined', 0, () => {
      const executor = new TaskExecutor('TaskExecutorTest', 2, false);
      const addTask = TestUtil.getPrivateFunction(executor, 'addTask')!!;

      addTask(undefined);
      const result = executor.waitList.filter(item => item === undefined);
      expect(result.length).assertEqual(0);
    });

    it('addTask_maxWaitLimit', 0, () => {
      const executor = new TaskExecutor('TaskExecutorTest', 2, true, 1);
      const addTask = TestUtil.getPrivateFunction(executor, 'addTask')!!;

      addTask(new Object({ task: 'task' }) as BaseTask);
      expect(executor.waitList.length).assertEqual(1);
      addTask(new Object({ task: 'task1' }) as BaseTask);
      expect(executor.waitList.length).assertEqual(1);
      expect(executor.waitList[0].task).assertEqual('task');
    });

    it('addTask_not_isOrderExecutor', 0, () => {
      const executor = new TaskExecutor('TaskExecutorTest', 2, false);
      const addTask = TestUtil.getPrivateFunction(executor, 'addTask')!!;

      addTask(new Object({ task: 'task' }) as BaseTask);
      expect(executor.waitList.length).assertEqual(1);
      addTask(new Object({ task: 'task1' }) as BaseTask);
      expect(executor.waitList.length).assertEqual(2);
      addTask(new Object({ task: 'task2' }) as BaseTask);
      expect(executor.waitList.length).assertEqual(3);
      expect(executor.waitList[2].task).assertEqual('task2');
    });

    it('addTask_not_isOrderExecutor_maxWaitLimit', 0, () => {
      const executor = new TaskExecutor('TaskExecutorTest', 2, false, 2);
      const addTask = TestUtil.getPrivateFunction(executor, 'addTask')!!;

      addTask(new Object({ task: 'task' }) as BaseTask);
      expect(executor.waitList.length).assertEqual(1);
      addTask(new Object({ task: 'task1' }) as BaseTask);
      expect(executor.waitList.length).assertEqual(2);
      addTask(new Object({ task: 'task2' }) as BaseTask);
      expect(executor.waitList.length).assertEqual(2);
      expect(executor.waitList[1].task).assertEqual('task2');
    });

    it('cancelAllTask', 0, () => {
      const executor = new TaskExecutor('TaskExecutorTest', 2);
      const fakeTask = new FakeTask() as object as BaseTask;

      mocker.mockFunc(fakeTask, fakeTask.cancelTask);

      executor.runningList.push(fakeTask);
      executor.cancelAllTask();

      expect(executor.runningList.length).assertEqual(0);
      mocker.clear(fakeTask);
      mocker.verify('cancelTask', []).once();
    });

    it('execute_0_addTask', 0, () => {
      const executor = new TaskExecutor('TaskExecutorTest', 0);

      TestUtil.getPrivateMockFunction(mocker, executor, 'addTask');

      executor.execute(undefined);
      mocker.clear(executor);
      mocker.verify('addTask', [undefined]).never();
    });

    it('execute_1_addTask', 0, () => {
      const executor = new TaskExecutor('TaskExecutorTest', 0);

      TestUtil.getPrivateMockFunction(mocker, executor, 'addTask');

      const task = new FakeTask() as object as BaseTask;
      executor.execute(task);
      mocker.clear(executor);
      mocker.verify('addTask', [task]).never();
    });

    it('execute_2_addTask', 0, () => {
      const executor = new TaskExecutor('TaskExecutorTest', 0);

      TestUtil.getPrivateMockFunction(mocker, executor, 'addTask');
      TestUtil.getPrivateMockFunction(mocker, executor, 'startTask');

      const task = new FakeTask('task') as object as BaseTask;
      executor.execute(task);
      mocker.clear(executor);
      mocker.verify('addTask', [task]).once();
      mocker.verify('startTask', []).once();
    });

    it('executeNow_0_TaskExecutorTest', 0, () => {
      const executor = new TaskExecutor('TaskExecutorTest', 0);

      TestUtil.getPrivateMockFunction(mocker, executor, 'canExecute');

      executor.executeNow(undefined);
      mocker.clear(executor);
      mocker.verify('canExecute', []).never();
    });

    it('executeNow_1_TaskExecutorTest', 0, () => {
      const executor = new TaskExecutor('TaskExecutorTest', 0);

      TestUtil.getPrivateMockFunction(mocker, executor, 'execute');
      TestUtil.getPrivateMockFunction(mocker, executor, 'removeTaskFromRunningList');

      const task = new FakeTask('task') as object as BaseTask;
      executor.executeNow(task);
      mocker.clear(executor);
      mocker.verify('removeTaskFromRunningList', [task]).never();
      mocker.verify('execute', [task]).once();
    });

    it('executeNow_2_TaskExecutorTest', 0, () => {
      const executor = new TaskExecutor('TaskExecutorTest', 0);

      TestUtil.getPrivateMockFunction(mocker, executor, 'execute');
      TestUtil.getPrivateMockFunction(mocker, executor, 'removeTaskFromRunningList');

      const task = new FakeTask('task') as object as BaseTask;
      executor.runningList.push(task);
      executor.executeNow(task);
      mocker.clear(executor);
      mocker.verify('removeTaskFromRunningList', [task]).once();
      mocker.verify('execute', [task]).once();
    });

    it('executeNow_3_TaskExecutorTest', 0, () => {
      const executor = new TaskExecutor('TaskExecutorTest', 1);

      TestUtil.getPrivateMockFunction(mocker, executor, 'execute');

      const task = new FakeTask('task') as object as BaseTask;
      executor.executeNow(task);
      mocker.clear(executor);
      mocker.verify('execute', [task]).once();
    });

    it('executeReject_undefined', 0, () => {
      const executor = new TaskExecutor('TaskExecutorTest', 1);

      TestUtil.getPrivateMockFunction(mocker, executor, 'canExecute');

      executor.executeReject(undefined);
      mocker.clear(executor);
      mocker.verify('canExecute', []).never();
    });

    it('executeReject_not_canExecute', 0, () => {
      const executor = new TaskExecutor('TaskExecutorTest', 0);

      const canExecute = TestUtil.getPrivateMockFunction(mocker, executor, 'canExecute');
      when(canExecute)().afterReturn(false);
      TestUtil.getPrivateMockFunction(mocker, executor, 'execute');

      const task = new FakeTask('task') as object as BaseTask;
      executor.executeReject(task);
      mocker.clear(executor);
      mocker.verify('execute', [task]).never();
    });

    it('executeReject', 0, () => {
      const executor = new TaskExecutor('TaskExecutorTest', 1);

      TestUtil.getPrivateMockFunction(mocker, executor, 'execute');

      const task = new FakeTask('task') as object as BaseTask;
      executor.executeReject(task);
      mocker.clear(executor);
      mocker.verify('execute', [task]).once();
    });

    it('executeTask_undefined', 0, () => {
      const executor = new TaskExecutor('TaskExecutorTest', 1);
      const executeTask = TestUtil.getPrivateFunction(executor, 'executeTask')!!;

      executeTask(undefined);
      expect(executor.runningList.length).assertEqual(0);
    });

    it('getTask_isOrderExecutor', 0, () => {
      const executor = new TaskExecutor('TaskExecutorTest', 1, true);
      const getTask = TestUtil.getPrivateFunction(executor, 'getTask')!!;

      const result: BaseTask = getTask();
      expect(result).assertUndefined();
    });

    it('getTask', 0, () => {
      const executor = new TaskExecutor('TaskExecutorTest', 1, false);
      const getTask = TestUtil.getPrivateFunction(executor, 'getTask')!!;

      const result: BaseTask = getTask();
      expect(result).assertUndefined();
    });

    it('removeTaskFromRunningList_empty', 0, () => {
      const executor = new TaskExecutor('TaskExecutorTest', 1, false);
      const removeTaskFromRunningList = TestUtil.getPrivateFunction(executor, 'removeTaskFromRunningList')!!;

      removeTaskFromRunningList(undefined);
      expect(executor.runningList.length).assertEqual(0);
    });

    it('removeTaskFromRunningList', 0, () => {
      const executor = new TaskExecutor('TaskExecutorTest', 1, false);
      const removeTaskFromRunningList = TestUtil.getPrivateFunction(executor, 'removeTaskFromRunningList')!!;

      const task = new FakeTask() as object as BaseTask;
      executor.runningList.push(task);

      removeTaskFromRunningList(task);
      expect(executor.runningList.length).assertEqual(0);
    });

    it('startTask', 0, () => {
      const executor = new TaskExecutor('TaskExecutorTest', 1, false);
      const startTask = TestUtil.getPrivateFunction(executor, 'startTask')!!;

      const canExecute = TestUtil.getPrivateMockFunction(mocker, executor, 'canExecute');
      when(canExecute)().afterReturn(true);

      TestUtil.getPrivateMockFunction(mocker, executor, 'executeTask');

      const task = new FakeTask() as object as BaseTask;
      executor.waitList.push(task);

      startTask();
      expect(executor.waitList.length).assertEqual(0);
      mocker.clear(executor);
      mocker.verify('executeTask', [task]).once();
    });
  });
}
