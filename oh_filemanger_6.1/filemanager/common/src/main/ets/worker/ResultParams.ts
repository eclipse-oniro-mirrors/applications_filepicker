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

import type WorkerConst from './WorkerConst';

/**
 * 和主线程通信回调的消息基本参数，后续如果新增业务，可基于此类扩展
 */
export class ResultParams {
  /**
   * 线程名，以以目标路径_时间戳的格式命名，用来区分多任务操作
   */
  workerName: string;

  /**
   * 线程状态
   */
  workerStatus: WorkerConst.WorkerStatus;

  /**
   * 结果类型 SUCCESS、ERROR、EXCEPTION、PROGRESS
   */
  resultType: WorkerConst.ResultType;

  /**
   * 操作类型：复制粘贴、剪切粘贴、删除、还原
   */
  operateType: WorkerConst.OperateType;

  /**
   * 信息
   */
  msg?: string = '';

  constructor(
    workerName: string,
    operateType: WorkerConst.OperateType,
    workerStatus: WorkerConst.WorkerStatus,
    resultType: WorkerConst.ResultType,
    msg?: string
  ) {
    this.workerName = workerName;
    this.operateType = operateType;
    this.workerStatus = workerStatus;
    this.resultType = resultType;
    this.msg = msg;
  }
}