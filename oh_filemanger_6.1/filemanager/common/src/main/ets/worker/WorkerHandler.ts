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

import worker from '@ohos.worker';
import type { ErrorEvent, MessageEvents } from '@ohos.worker';
import type { WorkerPool } from './WorkerPool';
import { WorkerPoolManager } from './WorkerPoolManager';
import type { TaskObject } from './TaskObject';
import WorkerConst from './WorkerConst';
import { ObjectUtil } from '../utils/ObjectUtil';
import { ResultParams } from './ResultParams';
import { HiLog } from '../dfx/HiLog';
import { BackgroundTaskManager } from './BackgroundTask';

/**
 * 日志TAG
 */
const TAG = 'WorkerHandler';

/**
 * workerHandler，处理任务
 */
export class WorkerHandler {
  private mWorker: worker.ThreadWorker = null;
  private mTaskObj: TaskObject = null;
  private workerPool: WorkerPool = null;
  private mWorkerPath: string;
  private mWorkerName: string;

  public constructor(taskObj: TaskObject, workerPath: string, workerName: string, pool: WorkerPool) {
    HiLog.infoPrivate(TAG, `workerHandlers workerName: `, `${workerName}, workerPath: ${workerPath}`);
    this.mWorker = new worker.ThreadWorker(workerPath, { name: workerName });
    this.mWorkerPath = workerPath;
    this.mWorkerName = workerName;
    this.workerPool = pool;
    this.initParams(taskObj);
  }

  /**
   * 绑定postMsg和function
   *
   * @param taskObj 传入的任务对象
   */
  private initParams(taskObj: TaskObject): void {
    this.mTaskObj = taskObj;
    this.mWorker.onmessage = this.onResult.bind(this);
    this.mWorker.onmessageerror = this.onMessageError.bind(this);
    this.mWorker.onerror = this.onError.bind(this);
    this.mWorker.onexit = this.onExit.bind(this);
  }

  /**
   * 开始执行新任务
   */
  public start(): void {
    if (ObjectUtil.isNull(this.mWorker)) {
      HiLog.error(TAG, 'mWorker is null');
      return;
    }
    this.mTaskObj.bindWorker(this.mWorker);
    this.mTaskObj.updateState(WorkerConst.WorkerState.RUNNING);
    HiLog.infoPrivate(TAG, `worker start: ${this.mTaskObj.params.operateType}`, JSON.stringify(this.mTaskObj.params));
    this.mWorker.postMessageWithSharedSendable(this.mTaskObj.params);
    BackgroundTaskManager.applyBackgroundTask(this.mWorkerName);
  }

  /**
   * 任务正常回调
   *
   * @param returnMsg 任务通知主线程要处理的消息
   */
  private onResult(returnMsg: MessageEvents): void {
    let resultParams: ResultParams = returnMsg.data;
    HiLog.infoPrivate(TAG, `onResult start: ${this.mTaskObj.params.operateType}`, JSON.stringify(resultParams));
    this.mTaskObj.onResult(resultParams);
    let workerStatus = resultParams.workerStatus;
    if ((workerStatus === WorkerConst.WorkerStatus.SUCCESS) ||
      (workerStatus === WorkerConst.WorkerStatus.FAIL) ||
      (workerStatus === WorkerConst.WorkerStatus.CANCEL)) {

      if (workerStatus === WorkerConst.WorkerStatus.CANCEL && (this.mTaskObj.params.operateType ===
      WorkerConst.OperateType.DELETE_FILE || this.mTaskObj.params.operateType ===
      WorkerConst.OperateType.SOFT_DELETE_FILE || this.mTaskObj.params.operateType ===
      WorkerConst.OperateType.RESTORE_FILE)) { // 针对删除动效，软删除，还原，硬删除 取消的时候不杀进程，由任务结束（取消的时候最终也会
        return;                                // 走任务结束success消息）触发杀线程， 避免界面收到多次删除回调而产生多余动效
      }
      // 任务结束
      this.checkNext();
    }
  }

  /**
   * 检查下个任务
   */
  private checkNext(): void {
    HiLog.info(TAG, 'checkNext');
    this.mTaskObj.updateState(WorkerConst.WorkerState.FINISH);
    if (ObjectUtil.isNull(this.mWorker)) {
      HiLog.error(TAG, 'mWorker is null');
      return;
    }
    let nextTask: TaskObject = this.workerPool.getNextTask();
    if (ObjectUtil.isNullOrUndefined(nextTask)) {
      this.close();
      return;
    }
    // 只有idle状态的任务才能执行
    if (nextTask.state !== WorkerConst.WorkerState.IDLE) {
      this.checkNext();
      return;
    }
    HiLog.info(TAG, 'start next');
    this.initParams(nextTask);
    this.start();
  }

  /**
   * 处理回调消息失败
   * @param error 失败消息
   */
  private onMessageError(error: MessageEvents): void {
    if (ObjectUtil.isNullOrUndefined(error)) {
      HiLog.error(TAG, 'onMessageError no message');
      this.checkNext();
      return;
    }
    if (!(error.data instanceof ResultParams)) {
      HiLog.error(TAG, 'onMessageError not ResultParams');
      this.checkNext();
      return;
    }
    let data: ResultParams = error.data;
    HiLog.error(TAG, `onMessageError: ${JSON.stringify(data)}`);
    this.mTaskObj.onResult(data);
    if (data.workerStatus === WorkerConst.WorkerStatus.FAIL) {
      this.checkNext();
    }
  }

  /**
   * 任务过程中发生异常
   *
   * @param error 异常信息
   */
  private onError(error: ErrorEvent): void {
    HiLog.error(TAG, `onError: ${JSON.stringify(error)}, operateType: ${this.mTaskObj.params.operateType}`);
    // 该异常需要自己组装业务需要的结果，以便处理对应异常
    this.checkNext();
  }

  /**
   * 任务已销毁，后续可以根据需要在回调中补充处理
   *
   * @param code 销毁结果
   */
  private onExit(code: number): void {
    HiLog.info(TAG, `onExit: ${code}, operateType: ${this.mTaskObj.params.operateType}`);
    this.mWorker = null;
    // 检查下个任务，一般走到onExit表示上个任务已经完全结束
    this.checkNextOnExit();
  }

  /**
   * 上一个任务走完onExit后再一次下个任务
   */
  private checkNextOnExit(): void {
    let nextTask: TaskObject = this.workerPool.getNextTask();
    if (ObjectUtil.isNullOrUndefined(nextTask)) {
      // 当前handler没有需要处理的任务，移除
      this.workerPool.removeWorkerHandler(this);
      WorkerPoolManager.getInstance().decreaseWorkerNum();
      return;
    }
    // 只有idle状态的任务才能执行
    if (nextTask.state !== WorkerConst.WorkerState.IDLE) {
      this.checkNextOnExit();
      return;
    }
    HiLog.info(TAG, 'start next onExit');
    this.mWorker = new worker.ThreadWorker(this.mWorkerPath, { name: this.mWorkerName });
    this.initParams(nextTask);
    this.start();
  }

  public close(): void {
    if (ObjectUtil.isNull(this.mWorker)) {
      HiLog.error(TAG, 'close mWorker null');
      return;
    }
    BackgroundTaskManager.resetBackgroundTask(this.mWorkerName);
    this.mWorker.terminate();
  }
}