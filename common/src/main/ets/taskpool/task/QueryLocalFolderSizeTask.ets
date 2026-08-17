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
import { HiLog } from '../../dfx/HiLog';
import { VirtualUri } from '../../const/FolderRecord';
import { FolderSizeCalculateUtil } from '../../utils/FolderSizeCalculateUtil';

/**
 * 查询本地文件夹大小
 */
export class QueryLocalFolderSizeTask extends BaseTask {
  constructor(relativePath: string, folderUri: string, pageFrom: string, callback: Function) {
    super('QueryLocalFolderSizeTask');
    this.task = new taskpool.Task(startTask, relativePath, folderUri, pageFrom);
    this.callback = callback;
  }
}

/**
 * 查询文件夹大小线程
 *
 * @param relativePath 相对路径
 * @param folderUri 文件夹uri
 * @param pageFrom 当前所在页面
 * @returns 文件夹大小
 */
@Concurrent
async function startTask(relativePath: string, folderUri: string, pageFrom: string): Promise<number> {
  HiLog.info('QueryLocalFolderSizeTask', 'QueryLocalFolderSizeTask start.');
  try {
    if (relativePath === VirtualUri.LOCAL_PATH_HEAD) {
      const usedSize = await FolderSizeCalculateUtil.calculateLocalUsedSize();
      return usedSize;
    }

    const folderSize = await FolderSizeCalculateUtil.calculateFolderSize(folderUri, pageFrom);
    return folderSize;
  } catch (error) {
    HiLog.error('QueryLocalFolderSizeTask', 'Query fail, error: ' + JSON.stringify(error));
    return 0;
  }
}
