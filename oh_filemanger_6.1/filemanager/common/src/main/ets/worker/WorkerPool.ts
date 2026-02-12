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

import { WorkerHandler } from './WorkerHandler';
import WorkerConst from './WorkerConst';
import { WorkerPoolManager } from './WorkerPoolManager';
import type { TaskObject } from './TaskObject';
import { ObjectUtil } from '../utils/ObjectUtil';
import { ArrayUtil } from '../utils/ArrayUtil';
import { HiLog } from '../dfx/HiLog';

/**
 * 日志TAG
 */
const TAG = 'WorkerPool';

/**
 * worker任务池
 * 一个pool中的worker必须是同一个ts文件，方便管理
 */
export class WorkerPool {
  /**
   * 一个任务对应一个WorkerHandler，便于和主线程通信
   */
  private workerHandlers: Array<WorkerHandler> = null;

  /**
   * 当正在执行的worker数量超过自定义最大个数时，新增任务进入等待队列
   */
  private taskQueue: Array<TaskObject> = null;

  private workerPath: string;
  private workerName: string;
  /**
   * 任务池并行执行任务数量最大限制
   */
  private poolSize: number;

  public constructor(poolSize: number, workerPath: string, workerName: string) {
    this.poolSize = poolSize <= WorkerConst.WORKER_LIMIT_SIZE ? poolSize : WorkerConst.WORKER_LIMIT_SIZE;
    this.workerPath = workerPath;
    this.workerName = workerName;
  }

  /**
   * 新增任务
   *
   * @param taskObj 任务对象
   */
  public addTask(taskObj: TaskObject): void {
    if (ObjectUtil.isNull(this.workerHandlers)) {
      this.workerHandlers = [];
    }
    // worker达到上限，新任务进入队列等待
    if (this.workerHandlers.length >= this.poolSize) {
      this.addToQueue(taskObj);
      HiLog.warn(TAG, 'poolSize is limited, workerName:' + this.workerName);
      return;
    }

    // worker未达到上限，新任务可通过新建worker并发执行
    let workerHandler: WorkerHandler = new WorkerHandler(taskObj, this.workerPath, this.workerName, this);
    this.workerHandlers.push(workerHandler);
    WorkerPoolManager.getInstance().increaseWorkerNum();
    HiLog.info(TAG, `workerHandlers size: ${this.workerHandlers.length}`);
    workerHandler.start();
  }

  /**
   * 新增任务至队列
   *
   * @param taskObj 任务对象
   */
  private addToQueue(taskObj: TaskObject): void {
    if (ObjectUtil.isNull(this.taskQueue)) {
      this.taskQueue = [];
    }
    this.taskQueue.push(taskObj);
  }

  /**
   * 返回等待队列第一个元素，并从队列中移出该元素
   */
  public getNextTask(): TaskObject {
    if (ArrayUtil.isEmpty(this.taskQueue)) {
      return null;
    }
    return this.taskQueue.shift();
  }

  /**
   * 移出handler
   *
   * @param handler WorkerHandler
   */
  public removeWorkerHandler(handler: WorkerHandler): void {
    if (ArrayUtil.isEmpty(this.workerHandlers)) {
      HiLog.error(TAG, 'removeWorkerHandler workerHandlers empty');
      return;
    }
    let index = this.workerHandlers.indexOf(handler);
    if (index !== -1) {
      this.workerHandlers.splice(index, 1);
    }
  }

  /**
   * 销毁所有的worker
   */
  public closeAllWorkers(): void {
    HiLog.info(TAG, `this.workerHandlers: ${this.workerHandlers}`);
    // 先清空等待队列
    if (!ObjectUtil.isNull(this.taskQueue)) {
      this.taskQueue = null;
    }
    // 停止执行正在执行的worker
    if (ArrayUtil.isEmpty(this.workerHandlers)) {
      HiLog.error(TAG, 'closeAllWorkerHandler workerHandlers empty');
      return;
    }
    while (this.workerHandlers.length > 0) {
      HiLog.info(TAG, 'handler close');
      this.workerHandlers.shift().close();
    }
  }
}