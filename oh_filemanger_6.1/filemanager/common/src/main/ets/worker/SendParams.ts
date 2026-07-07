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
import type common from '@ohos.app.ability.common';

/**
 * 和子线程通信传入的消息基本参数，后续如果新增业务，可基于此类扩展
 */
export class SendParams {
  /**
   * 操作上下文对象
   */
  context: common.Context;

  /**
   * 发起操作的消息类型，用于区分worker内的操作
   */
  operateType: WorkerConst.OperateType;

  /**
   * 线程名，以以目标路径_时间戳的格式命名，用来区分多任务操作
   */
  workerName: string;

  constructor(context: common.Context, operateType: WorkerConst.OperateType, workerName: string) {
    this.context = context;
    this.operateType = operateType;
    this.workerName = workerName;
  }
}