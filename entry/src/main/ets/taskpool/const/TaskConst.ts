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
export class TaskConst {
  public static TAG: string = 'TaskpoolTag';

  public static readonly  taskExecuteMode = {
    reject: 0,
    waitToExecute: 1,
    executeNow: 2
  }
}

export enum TaskStatus {
  IDLE = 0,
  RUNNING,
  CANCEL,
  ERROR,
  END
}

export class TaskpoolName {
  static readonly BATCH_AUTH_URI_PERMISSION_TASK: string = 'batchAuthUriPermissionTask';
  static readonly SINGLE_DEFAULT: string = 'singleDefault';
}