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
import { TaskPoolName, TaskStatus } from '../const/TaskConst';
import taskpool from '@ohos.taskpool';
import { FileInfo } from '../../fileoperate/FileInfo';
import { HiLog } from '../../dfx/HiLog';
import { TaskPoolUtils } from '../../utils/TaskPoolUtils';
import lazy { filemanager } from '../../model/filetag/FileManager';
import { VirtualUri } from '../../const/FolderRecord';

/**
 * 查询系统垃圾文件
 */
export class QuerySystemTrashFilesTask extends BaseTask {
  constructor(receiveCallback: Function, showHiddenItem: boolean) {
    super(TaskPoolName.QUERY_SYSTEM_TRASH_FILES);
    this.task = TaskPoolUtils.createTask(startTask, showHiddenItem);
    this.onReceiveData(receiveCallback);
  }
}

@Concurrent
function startTask(showHiddenItem: boolean): void {
  let pageNum: number = 0; // 分页页数
  const TAG: string = 'QuerySystemTrashFilesTask';
  const BATCH_SEARCH_MAX_COUNT: number = 2000; // 批次查询返回的最大文件数
  const suffixList: string[] = ['log', 'temp', 'tmp', 'bak']; // 查询文件类型

  let fileList: FileInfo[] = [];
  let resultLength: number = 0;
  do {
    if (taskpool.Task.isCanceled()) {
      HiLog.warn(TAG, 'querySystemTrashFilesTask is canceled!');
      TaskPoolUtils.sendData([], TaskStatus.CANCEL);
      return;
    }
    HiLog.warn(TAG, `querySystemTrashFilesTask searchIndex: ${pageNum}`);
    fileList = [];

  } while (resultLength === BATCH_SEARCH_MAX_COUNT);
}