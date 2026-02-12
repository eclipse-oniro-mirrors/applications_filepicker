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
import { BusinessError } from '@kit.BasicServicesKit';
import { HiLog } from '../dfx/HiLog';

const TAG: string = 'TaskPoolUtils';

export class TaskPoolUtils {
  public static createTask(func: Function, ...args: Object[]): taskpool.Task | undefined {
    try {
      let task = new taskpool.Task(func, ...args);
      return task;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      HiLog.error(TAG, `create task error, code = ${err?.code} , message = ${err?.message}`);
    }
    return undefined;
  }

  public static sendData(...args: Object[]): void {
    try {
      taskpool.Task.sendData(...args);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      HiLog.error(TAG, `sendData error, code = ${err?.code} , message = ${err?.message}`);
    }
  }
}