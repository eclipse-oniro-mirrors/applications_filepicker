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
import { TaskConst, TaskPoolName } from '../const/TaskConst';
import taskpool from '@ohos.taskpool';
import { HiLog } from '../../dfx/HiLog';
import { ResourceCacheUtil } from '../../etsexport/utils/ResourceCachedUtil';
import common from '@ohos.app.ability.common';
import image from '@ohos.multimedia.image';
import { GlobalHolder } from '../../global/GlobalHolder';

/* instrument ignore file */

/**
 * 查询缩略图
 */
export class ResourceCachingTask extends BaseTask {
  constructor(callback: Function) {
    super(TaskPoolName.RESOURCE_CACHED_PIXELMAP);
    this.task = new taskpool.Task(resourceQueryTask, GlobalHolder.getInstance().getCommonContext());
    this.callback = callback;
  }
}

/**
 * 获取指定资源文件缩略图
 */
@Concurrent
async function resourceQueryTask(context: common.Context): Promise<Map<string, image.PixelMap>> {
  HiLog.warn(TaskConst.TAG, 'start Resource Query Task');
  return await ResourceCacheUtil.CreateCacheResource(context);
}