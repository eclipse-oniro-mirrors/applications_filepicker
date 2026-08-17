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
import { HiLog, TimeUtil, BaseTask } from '@ohos/common';
import taskpool from '@ohos.taskpool';

const TAG = 'TestTask';

export class TestTask extends BaseTask {
  constructor(callback: Function) {
    super(TAG)
    this.taskPoolName = 'TestTask';
    this.task = new taskpool.Task(startTask);
    this.callback = callback;
  }
}

@Concurrent
async function startTask() {
  const TAG = 'TestTask';
  try {
    HiLog.info(TAG, 'startTask ')
    let count = 0;
    while(count < 10) {
      await TimeUtil.sleep(1000);
      if (taskpool.Task.isCanceled()) {
        HiLog.info(TAG, 'task is cancel');
        break;
      }
    }
  } catch (error) {
    HiLog.error(TAG, 'recentFileList fail, error:' + JSON.stringify(error));
  }
}