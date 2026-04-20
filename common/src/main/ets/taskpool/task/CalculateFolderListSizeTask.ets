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
import { BaseTask } from '../base/BaseTask';
import { TaskPoolName, TaskStatus } from '../const/TaskConst';
import { HiLog } from '../../dfx/HiLog';
import { FilesQueryUtil } from '../../fileoperate/FilesQueryUtil';
import { TaskPoolUtils } from '../../utils/TaskPoolUtils';

/* instrument ignore file */

/**
 * 计算文件夹的总大小
 */
export class CalculateFolderListSizeTask extends BaseTask {
  constructor(receiveCallback: Function, folderUriList: string[]) {
    super(TaskPoolName.CALCULATE_FOLDER_LIST_SIZE_TASK);
    this.task = new taskpool.Task(startTask, folderUriList);
    this.onReceiveData(receiveCallback);
  }
}

@Concurrent
async function startTask(folderUriList: string[]): Promise<void> {
  HiLog.info(TaskPoolName.CALCULATE_FOLDER_LIST_SIZE_TASK, 'CalculateFolderListSizeTask start');
  let totalSize: number = 0;
  for (const folderUri of folderUriList) {
    totalSize += FilesQueryUtil.getFolderSize(folderUri);
  }
  TaskPoolUtils.sendData(totalSize, TaskStatus.END);
}
