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
import { FileUtil } from '../../fileoperate/FileUtil';
import { BaseTask } from '../base/BaseTask';
import { TaskPoolName } from '../const/TaskConst';

/* instrument ignore file */

/**
 * 查询文件夹项数常量
 */
export class QueryFolderSubCountTask extends BaseTask {

  constructor(folderUri: string, showHiddenItem: boolean, callback: Function) {
    super(TaskPoolName.QUERY_FOLDER_SUB_COUNT);
    this.task = new taskpool.Task(startTask, folderUri, showHiddenItem);
    this.callback = callback;
  }
}

/**
 * 查询线程
 * @param uri uri
 * @returns 子文件个数
 */
@Concurrent
async function startTask(uri: string, showHiddenItem: boolean): Promise<number> {
  return await FileUtil.getFolderSubFileCount(uri, false, showHiddenItem);
}