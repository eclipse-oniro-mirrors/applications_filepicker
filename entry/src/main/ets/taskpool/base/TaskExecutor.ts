/*
 * Copyright (c) 2021-2025 Huawei Device Co., Ltd.
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
import Logger from "../../base/log/Logger";
import { ArrayUtil } from "../../base/utils/ArrayUtil";
import { BaseTask } from "./BaseTask";
import taskpool from "@ohos.taskpool";

const TAG = 'TaskExecutor';

/**
 * 线程池任务执行器
 * */
export class TaskExecutor {
  taskpoolName: string = '';

  maxTaskRunningNum: number = 1;

  maxWaitLimit?: number;

  waitList: BaseTask[] = [];

  runningList: BaseTask[] = [];

  isOrderExecutor: boolean = true;

  freeCallback: Function = (taskpoolName: string) => {
  };

  constructor(taskpoolName: string, maxTaskRunningNum: number, isOrderExecutor: boolean = true, maxWaitLimit?: number) {
    this.taskpoolName = taskpoolName;
    this.maxTaskRunningNum = maxTaskRunningNum;
    this.isOrderExecutor = isOrderExecutor;
    this.maxWaitLimit = this.maxWaitLimit;
  }

  execute<T>(task: BaseTask): void {
    if (!task || !task.task) {
      Logger.e(TAG, 'executeNow task null');
      return;
    }
    this.addTask(task);
    this.startTask<T>();
  }

  isFreeState(): boolean {
    return this.waitList.length === 0 && this.runningList.length === 0;
  }

  executeNow<T>(task: BaseTask): void {
    if (!task || !task.task) {
      Logger.e(TAG, 'executeNow task null');
      return;
    }
    if (this.canExecute()) {
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

  executeReject<T>(task: BaseTask): void {
    if (!task || !task.task) {
      Logger.e(TAG, 'executeNow task null');
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

  private startTask<T>(): void {
    Logger.i(TAG,
      `start task, runningList len: ${this.runningList.length}, maxTaskRunning num: ${this.maxTaskRunningNum},
       waitlist len: ${this.waitList.length}, maxWaitLimit: ${this.maxWaitLimit}`);
    while (!ArrayUtil.isEmpty(this.waitList) && this.canExecute()) {
      let task = this.getTask();
      if (task) {
        this.executeTask<T>(task);
      }
    }
  }

  private executeTask<T>(task: BaseTask): void {
    if (!task || !task.task) {
      Logger.e(TAG, 'execute task null');
      return;
    }
    this.runningList.push(task);
    Logger.i(TAG, `executeTask already start: name: ${task.task.name}`);
    taskpool.execute(task.task, task.priority).then((result: T) => {
      try {
        if (task.callback) {
          task.callback(result);
        }
      } catch (e) {
        Logger.e(TAG, `executeTask callback error: ${e?.code}`);
      }
      this.removeTaskFromRunningList(task);
      this.startTask<T>();
      if (this.isFreeState()) {
        this.freeCallback(this.taskpoolName);
      }
    })
  }

  private removeTaskFromRunningList(task: BaseTask): void {
    let index = this.runningList.indexOf(task);
    if (index != -1) {
      this.runningList.splice(index, 1);
    }
  }

  private getTask(): BaseTask | undefined {
    if (this.isOrderExecutor) {
      return this.waitList.shift();
    } else {
      return this.waitList.pop();
    }
  }

  private addTask(task: BaseTask): void {
    if (!task || !task.task) {
      Logger.e(TAG, 'add task null');
      return;
    }
    if (this.isOrderExecutor) {
      if (this.maxWaitLimit && this.waitList.length >= this.maxWaitLimit) {
        return;
      }
      this.waitList.push(task);
    } else {
      this.waitList.push(task);
      if (!this.maxWaitLimit) {
        return;
      }
      let startIndex = this.waitList.length - this.maxWaitLimit;
      if (startIndex > 0) {
        this.waitList = this.waitList.slice(startIndex);
      }
    }
  }

  private canExecute(): boolean {
    return this.runningList.length < this.maxTaskRunningNum;
  }
}