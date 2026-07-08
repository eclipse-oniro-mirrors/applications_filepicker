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
import taskpool from "@ohos.taskpool";
import Logger from "../../base/log/Logger";

const TAG = 'BaseTask';

/**
 * task 基本类型
 * */
export class BaseTask {
  task?: taskpool.Task;

  callback?: Function = () => {
  };

  priority: taskpool.Priority = taskpool.Priority.MEDIUM;

  taskpoolName: string = '';

  isCancel: boolean = false;

  uri: string = '';

  constructor(taskpoolName: string, uri?: string) {
    this.taskpoolName = taskpoolName;
    this.uri = uri;
  }

  cancelTask(): void {
    try {
      Logger.i(TAG, `cancel task`);
      this.isCancel = true;
      if (this.task) {
        taskpool.cancel(this.task);
      }
    } catch (e) {
      Logger.e(TAG, `cancel task err: ${e?.code}`);
    }
  }

  onReceiveData(callback?: Function): void {
    Logger.i(TAG, `set onReceiveData func: ${this.taskpoolName}`);
    try {
      if (this.task && callback) {
        this.task.onReceiveData(callback);
      }
    } catch (e) {
      Logger.e(TAG, `onReceiveData err: ${e?.code}`);
    }
  }
}

