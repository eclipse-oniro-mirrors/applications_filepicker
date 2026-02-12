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
import type worker from '@ohos.worker';
import type { SendParams } from './SendParams';
import WorkerConst from './WorkerConst';
import { ObjectUtil } from '../utils/ObjectUtil';
import { HiLog } from '../dfx/HiLog';

const TAG: string = 'TaskObject';

/**
 * 任务类，支持worker绑定，任务状态更新和任务取消等
 */
export class TaskObject {
  params: SendParams;
  fuc: ((argument1) => void) | undefined;
  state: WorkerConst.WorkerState = WorkerConst.WorkerState.IDLE;
  worker: worker.ThreadWorker;

  constructor(params: SendParams, fuc: (argument1) => void) {
    this.params = params;
    this.fuc = fuc;
  }

  public bindWorker(worker: worker.ThreadWorker): void {
    this.worker = worker;
  }

  public updateState(state: WorkerConst.WorkerState): void {
    if ((state === WorkerConst.WorkerState.FINISH) && (this.state !== WorkerConst.WorkerState.RUNNING)) {
      return;
    }
    this.state = state;
  }

  /**
   * 向子线程发消息
   * @param msg 发送的消息
   */
  public notifyMsg(msg: SendParams): void {
    if (ObjectUtil.isNullOrUndefined(this.worker)) {
      HiLog.error(TAG, 'worker is null or undefined');
      return;
    }
    if (this.state === WorkerConst.WorkerState.RUNNING) {
      this.worker.postMessage(msg);
    }
  }
  /**
   * 取消子线程
   */
  public cancel(): void {
    if (this.state === WorkerConst.WorkerState.FINISH) {
      return;
    }
    this.state = WorkerConst.WorkerState.CANCEL;
  }

  /**
   * 接收和处理子线程的消息并触发回调
   * @param result 接收的消息
   */
  public onResult(result): void {
    if (this.state !== WorkerConst.WorkerState.CANCEL) {
      if (!this.fuc) {
        HiLog.error(TAG, 'call back fun is null');
        return;
      }
      this.fuc(result);
    }
  }
}