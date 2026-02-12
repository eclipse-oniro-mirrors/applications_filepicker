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
import { TaskPoolName, TaskConst } from '../const/TaskConst';
import { HiLog } from '../../dfx/HiLog';
import { FileInfo } from '../../fileoperate/FileInfo';
import lazy { PhotoAccessUtil } from '../../utils/PhotoAccessUtil';
import { common } from '@kit.AbilityKit';

/* instrument ignore file */

/**
 * 查询文件夹项数常量
 */
export class QueryGalleryFolderSizeTask extends BaseTask {

  constructor(context: common.Context, fileInfo: FileInfo, callback: Function) {
    super(TaskPoolName.QUERY_GALLERY_FOLDER_SIZE);
    this.task = new taskpool.Task(startTask, context, fileInfo);
    this.callback = callback;
  }
}

/**
 * 查询线程
 * @param uri uri
 * @returns 文件夹大小
 */
@Concurrent
async function startTask(context: common.Context, fileInfo: FileInfo): Promise<number> {
  try {
    return await PhotoAccessUtil.getAlbumSize(context, fileInfo);
  } catch (error) {
    HiLog.error(TaskConst.TAG, 'QueryGalleryFolderSizeTask  fail, error:' + JSON.stringify(error));
    return 0;
  }
}

