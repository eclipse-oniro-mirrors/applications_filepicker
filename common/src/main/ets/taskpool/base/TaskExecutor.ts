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

import taskpool from '@ohos.taskpool';
import { HiLog } from '../../dfx/HiLog';
import { ArrayUtil } from '../../utils/ArrayUtil';
import type { BaseTask } from './BaseTask';

const TAG = 'TaskExecutor';

/**
 * 线程池执行
 * T 执行结果回调参数类型
 */
export class TaskExecutor {
  /**
   * 线程池名称
   */
  taskPoolName: string = '';
  /**
   * 同时允许执行的任务数
   */
  maxTaskRunningNum: number = 1;
  /**
   * 等待执行的最大项数
   */
  maxWaitLimit?: number;
  /**
   * 等待执行的任务列表
   */
  waitList: BaseTask[] = [];
  /**
   * 正在执行任务列表
   */
  runningList: BaseTask[] = [];
  /**
   * 是否按顺序执行：true: 先添加的先执行，false: 后添加的先执行
   */
  isOrderExecutor: boolean = true;
  /**
   * 线程空闲回调
   */
  freeCallback: Function = (taskPoolName: string) => {
  };

  constructor(taskPoolName: string, maxTaskRunningNum: number, isOrderExecutor: boolean = true, maxWaitLimit?: number) {
    this.taskPoolName = taskPoolName;
    this.maxTaskRunningNum = maxTaskRunningNum;
    this.maxWaitLimit = maxWaitLimit;
    this.isOrderExecutor = isOrderExecutor;
  }

  /**
   * 线程池执行任务的接口
   * @param task 任务
   */
  execute<T>(task: BaseTask): void {
    if (!task) {
      HiLog.error(TAG, 'execute task is null.');
      return;
    }
    if (!task.task) {
      HiLog.error(TAG, 'execute task.task is null.');
      return;
    }
    this.addTask(task);
    this.startTask<T>();
  }

  /**
   * 线程池是否空闲
   * @returns 是否空闲
   */
  isFreeState(): boolean {
    return this.waitList.length === 0 && this.runningList.length === 0;
  }

  /**
   * 立刻执行任务
   * @param task
   */
  executeNow<T>(task: BaseTask): void {
    if ((!task) || (!task.task)) {
      HiLog.error(TAG, 'executeNow task is null.');
      return;
    }
    if (!this.canExecute()) {
      if (this.runningList.length > 0) {
        let runningTask = this.runningList.shift();
        if (runningTask) {
          runningTask.cancelTask();
          this.removeTaskFromRunningList(task);
        }
      }
    }
    this.execute<T>(task);
  }

  /**
   * 如果当前没有空余的线程，则拒绝执行
   * @param task 任务
   */
  executeReject<T>(task: BaseTask): void {
    if ((!task) || (!task.task)) {
      HiLog.error(TAG, 'executeReject task is null.');
      return;
    }
    if (this.canExecute()) {
      this.execute<T>(task);
    }
  }

  cancelAllTask(): void {
    this.waitList = [];
    for (let i = 0; i < this.runningList.length; i++) {
      let task = this.runningList[i];
      task.cancelTask();
    }
    this.runningList = [];
  }

  /**
   * 执行任务
   */
  private startTask<T>(): void {
    HiLog.info(TAG, 'startTask, runningList len is ' + this.runningList.length + ', maxTaskRunningNum = ' +
    this.maxTaskRunningNum + ', waitList len is ' + this.waitList.length + ', maxWaitLimit ' + this.maxWaitLimit);
    while (!ArrayUtil.isEmpty(this.waitList) && this.canExecute()) {
      let task = this.getTask();
      if (task) {
        this.executeTask<T>(task);
      }
    }
  }

  /**
   * 执行具体任务
   * @param task 任务
   */
  private executeTask<T>(task: BaseTask): void {
    if ((!task) || (!task.task)) {
      HiLog.error(TAG, 'executeTask task is null.');
      return;
    }
    this.runningList.push(task);
    HiLog.info(TAG, 'executeTask is really start, task.task name = ' + task.task.name);
    taskpool.execute(task.task, task.priority).then((result: T) => {
      try {
        if (task.callback) {
          task.callback(result);
        }
      } catch (error) {
        HiLog.info(TAG, 'executeTask callback error: ' + error.toString());
      }
      this.removeTaskFromRunningList(task);
      this.startTask<T>();
      if (this.isFreeState()) {
        this.freeCallback(this.taskPoolName);
      }
    });
  }

  /**
   * 从正在执行列表中移除
   * @param task task
   */
  private removeTaskFromRunningList(task: BaseTask): void {
    let index = this.runningList.indexOf(task);
    if (index !== -1) {
      this.runningList.splice(index, 1);
    }
  }

  /**
   * 获取任务
   */
  private getTask(): BaseTask | undefined {
    if (this.isOrderExecutor) {
      return this.waitList.shift();
    } else {
      return this.waitList.pop();
    }
  }

  /**
   * 添加任务
   * @param task task
   */
  private addTask(task: BaseTask): void {
    if ((!task) || (!task.task)) {
      HiLog.error(TAG, 'task or task.task is undefined or null');
      return;
    }
    // 按顺序执行，如果达到上限数，则拒绝
    if (this.isOrderExecutor) {
      if (this.maxWaitLimit && (this.waitList.length >= this.maxWaitLimit)) {
        return;
      }
      this.waitList.push(task);
    } else {
      // 后插入的先执行,如果达到最大数就将前面的舍弃
      this.waitList.push(task);
      if (this.maxWaitLimit === undefined) {
        return;
      }
      let startIndex = this.waitList.length - this.maxWaitLimit;
      if (startIndex > 0) {
        this.waitList = this.waitList.slice(startIndex);
      }
    }
  }

  /**
   * 当前是否能执行
   * @returns
   */
  private canExecute(): boolean {
    return this.runningList.length < this.maxTaskRunningNum;
  }
}