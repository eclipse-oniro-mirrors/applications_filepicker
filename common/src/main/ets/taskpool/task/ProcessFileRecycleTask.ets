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

import { BaseTask } from '../base/BaseTask';
import taskpool from '@ohos.taskpool';
import { HiLog } from '../../dfx/HiLog';
import lazy { filemanager } from '../../model/filetag/FileManager';
import { TaskPoolName } from '../const/TaskConst';
import lazy TrashNapi from 'libTrash.so';

/* instrument ignore file */

/**
 * 处理升级备份回收站的文件
 */
export class ProcessFileRecycleTask extends BaseTask {
  constructor() {
    super(TaskPoolName.PROCESS_FILE_RECYCLE_TASK);
    this.task = new taskpool.Task(processTask);
  }

  // 线程池同步等待方法
  public static async executeTask(): Promise<number> {
    return await taskpool.execute(processTask) as number;
  }
}

/**
 * 处理升级备份路径/.File_Recycle文件至回收站
 */
@Concurrent
function processTask(): void {
  try {
    HiLog.info(TaskPoolName.PROCESS_FILE_RECYCLE_TASK, 'ProcessFileRecycleTask start');
    TrashNapi.processOldRecycleBinFiles();
    HiLog.info(TaskPoolName.PROCESS_FILE_RECYCLE_TASK, 'ProcessFileRecycleTask end');
  } catch (e) {
    HiLog.error(TaskPoolName.PROCESS_FILE_RECYCLE_TASK, `ProcessFileRecycleTask error: ${JSON.stringify(e)}`);
  }
}