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
import { HiLog } from '../../dfx/HiLog';

const TAG = 'BaseTask';

/**
 * task 基本类型
 */
export class BaseTask {
  /**
   * 任务
   */
  task?: taskpool.Task;

  /**
   * 任务执行完回调
   */
  callback?: Function = () => {
  };

  /**
   * 线程优先级
   */
  priority: taskpool.Priority = taskpool.Priority.MEDIUM;

  /**
   * 线程池名称
   */
  taskPoolName: string = '';

  /**
   * 是否取消
   */
  isCancel: boolean = false;

  /**
   * 文件查询任务中对应的查询地址
   */
  uri: string = '';

  constructor(taskPoolName: string, uri?: string) {
    this.taskPoolName = taskPoolName;
    this.uri = uri;
  }

  /**
   * 取消任务，子类在线程中判断isCancel
   */
  cancelTask(): void {
    try {
      HiLog.info(TAG, 'cancel task.');
      this.isCancel = true;
      if (this.task) {
        taskpool.cancel(this.task);
      }
    } catch (error) {
      HiLog.error(TAG, 'cancel task error: ' + error.toString());
    }
  }

  onReceiveData(callback?: Function): void {
    HiLog.info(TAG, 'set onReceiveData fun  ' + this.taskPoolName);
    try {
      if (this.task && callback) {
        this.task.onReceiveData(callback);
      }
    } catch (error) {
      HiLog.error(TAG, 'cancel task error: ' + error.toString());
    }
  }
}