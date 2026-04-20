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

import type { BaseTask } from '../base/BaseTask';
import HashMap from '@ohos.util.HashMap';
import { TaskExecutor } from '../base/TaskExecutor';
import { TaskConst, TaskPoolName } from '../const/TaskConst';
import { HiLog } from '../../dfx/HiLog';
import { StringUtil } from '../../utils/StringUtil';
import taskpool from '@ohos.taskpool';

const TAG = 'TaskManager';

/**
 * 线程池管理类
 */
export class TaskManager {
  /**
   * 实例对象
   */
  static instance: TaskManager;
  /**
   * 最大并发线程
   */
  static readonly maxRunningTask: number = 5;
  /**
   * 线程池执行map
   */
  static executorMap: HashMap<string, TaskExecutor> = new HashMap();

  static getInstance(): TaskManager {
    if (!TaskManager.instance) {
      TaskManager.instance = new TaskManager();
    }
    return TaskManager.instance;
  }

  executeTask<T>(task: BaseTask): void {
    if (!task) {
      HiLog.error(TAG, 'executeTask is null');
      return;
    }
    taskpool.execute(task.task, task.priority).then((result: T) => {
      try {
        if (task.callback) {
          task.callback(result, task.uri);
        }
      } catch (error) {
        HiLog.error(TAG, 'executeTask callback error: ' + error.toString());
      }
    }).catch((error) => {
      HiLog.error(TAG, 'executeTask error: ' + JSON.stringify(error));
    });
  }

  /**
   * 执行方法 T 执行结果回调参数类型
   * @param task 任务
   * @param maxRunningTask 最大并发线程
   * @param idOrder 是否按顺序执行
   * @param maxWaitLimit 线程池里等待执行的最大线程数
   * @param taskMode 启动任务模式，单任务线程池可使用
   */
  execute<T>(task: BaseTask, maxRunningTask: number = TaskManager.maxRunningTask, isOrder: boolean = true,
             maxWaitLimit?: number, taskMode: number = TaskConst.taskExecuteMode.waitToExecute): void {
    if ((!task) || (!task.task)) {
      HiLog.error(TAG, 'execute task is null');
      return;
    }
    let taskName = task.taskPoolName;
    if (StringUtil.isEmpty(taskName)) {
      taskName = TaskPoolName.SINGLE_DEFAULT;
    }
    HiLog.info(TAG, 'execute taskName = ' + taskName + ', taskMode = ' + taskMode + ', maxRunningTask = ' + maxRunningTask);
    let executor = TaskManager.executorMap.get(taskName);
    if (!executor) {
      if (taskName === TaskPoolName.SINGLE_DEFAULT) {
        executor = new TaskExecutor(TaskPoolName.SINGLE_DEFAULT, TaskManager.maxRunningTask);
      } else {
        executor = new TaskExecutor(taskName, maxRunningTask, isOrder, maxWaitLimit);
      }
      executor.freeCallback = this.executorFreeCallback;
      TaskManager.executorMap.set(taskName, executor);
    }
    switch (taskMode) {
      case TaskConst.taskExecuteMode.reject:
        executor.executeReject<T>(task);
        break;
      case TaskConst.taskExecuteMode.waitToExecute:
        executor.execute<T>(task);
        break;
      case TaskConst.taskExecuteMode.executeNow:
        executor.executeNow<T>(task);
        break;
      default:
        HiLog.error(TAG, 'execute taskMode is wrong');
        break;
    }
  }

  /**
   * 从map中移除executor
   * @param taskPoolName 线程池名称
   */
  executorFreeCallback(taskPoolName: string): void {
    HiLog.info(TAG, 'executorFreeCallback ' + taskPoolName);
    TaskManager.executorMap.remove(taskPoolName);
  }

  cancelExecutorTask(poolName: string): void {
    if (StringUtil.isEmpty(poolName)) {
      HiLog.info(TAG, 'cancelExecutorTask poolName is null.');
      return;
    }
    HiLog.info(TAG, 'cancelExecutorTask taskName = ' + poolName);
    let executor = TaskManager.executorMap.get(poolName);
    if (!executor) {
      HiLog.info(TAG, 'cancelExecutorTask executor is null.');
      return;
    }
    executor.cancelAllTask();
  }
}