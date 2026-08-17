/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import WorkerConst from './WorkerConst';
import { ObjectUtil } from '../utils/ObjectUtil';
import type { TaskObject } from './TaskObject';
import { WorkerPool } from './WorkerPool';
import { ArrayUtil } from '../utils/ArrayUtil';
import { HiLog } from '../dfx/HiLog';

/**
 * 日志TAG
 */
const TAG = 'WorkerPoolManager';
/**
 * worker文件路径
 */
const FILE_OPERATE_WORKER_PATH = '../workers/FileOperateWorker.ets';

/**
 * worker线程最大数量
 */
const FILE_OPERATE_THREAD_MAX_NUM = 7;

/**
 * workerPool任务池管理
 */
export class WorkerPoolManager {
  private static instance: WorkerPoolManager = null;
  /**
   * 文件操作类的任务池
   */
  private fileOperatePool: WorkerPool = null;

  private fileOperateWorkerNum: number = 0;

  /**
   * 当正在执行的worker数量超过最大限制7时，新增任务先进入等待队列
   */
  private taskQueue: Array<TaskObject> = null;

  private constructor() {

  }

  /**
   * 获取 WorkerPoolManager 实例
   * @returns
   */
  public static getInstance(): WorkerPoolManager {
    if (ObjectUtil.isNull(this.instance)) {
      this.instance = new WorkerPoolManager();
    }
    return this.instance;
  }

  /**
   * 判断线程数，查看任务是否要进队列
   * @param taskObj 任务对象
   */
  private isAddQueue(taskObj: TaskObject): boolean {
    // 复制粘贴线程超过7个进队列
   if (this.fileOperateWorkerNum >= WorkerConst.WORKER_LIMIT_SIZE) {
      this.addToTaskQueue(taskObj);
      return true;
    }
    return false;
  }

  /**
   * 执行任务
   * @param taskObj 任务对象
   */
  public execute(taskObj: TaskObject): void {
    // 超出最大worker数量，任务先加到队列
    HiLog.info(TAG, 'execute worker size: fileOperateWorkerNum : ' + this.fileOperateWorkerNum);
    if (this.isAddQueue(taskObj)) {
      HiLog.info(TAG, 'running worker over limit size, add to queue wait execute');
      return;
    }
    this.addFileOperateTask(taskObj);
  }

  public addToTaskQueue(taskObj: TaskObject): void {
    if (ObjectUtil.isNull(this.taskQueue)) {
      this.taskQueue = [];
    }
    this.taskQueue.push(taskObj);
  }

  public removeFromTaskQueue(taskObj: TaskObject): void {
    if (ObjectUtil.isNull(this.taskQueue)) {
      return;
    }
    let index = this.taskQueue.findIndex(item => {
      return item.params.workerName === taskObj.params.workerName;
    });
    if (index > -1) {
      this.taskQueue.splice(index, 1);
    }
  }

  /**
   * 新增文件操作任务
   *
   * @param taskObj 任务对象
   */
  public addFileOperateTask(taskObj: TaskObject): void {
    HiLog.warn(TAG, 'addFileOperateTask');
    if (ObjectUtil.isNull(this.fileOperatePool)) {
      this.fileOperatePool = new WorkerPool(FILE_OPERATE_THREAD_MAX_NUM, FILE_OPERATE_WORKER_PATH, taskObj.params.workerName);
    }
    this.fileOperatePool.addTask(taskObj);
  }

  public increaseWorkerNum(): void {
    this.fileOperateWorkerNum++;
    HiLog.info(TAG, 'increaseWorkerNum fileOperateWorkerNum : ' + this.fileOperateWorkerNum);
  }

  public decreaseWorkerNum(): void {
    this.fileOperateWorkerNum--;
    HiLog.info(TAG, 'decreaseWorkerNum fileOperateWorkerNum : ' + this.fileOperateWorkerNum);
    this.executeQueueTask();
  }

  /**
   * 检查等待对列任务
   */
  private executeQueueTask(): void {
    if (ArrayUtil.isEmpty(this.taskQueue)) {
      return;
    }

    let nextTask: TaskObject = this.taskQueue.shift();
    if (nextTask.state !== WorkerConst.WorkerState.IDLE) {
      this.executeQueueTask();
      return;
    }
    this.execute(nextTask);
  }

  /**
   * 释放所有线程池
   */
  public releaseAllWorkerPool(): void {
    if (!ObjectUtil.isNull(this.taskQueue)) {
      this.taskQueue = null;
    }
    if (!ObjectUtil.isNull(this.fileOperatePool)) {
      this.fileOperatePool.closeAllWorkers();
      this.fileOperatePool = null;
    }
  }
}