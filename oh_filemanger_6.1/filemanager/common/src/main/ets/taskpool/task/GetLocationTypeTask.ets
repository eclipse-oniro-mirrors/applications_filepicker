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
import { FsUtil } from '../../utils/FsUtil';
import { BaseTask } from '../base/BaseTask';
import { TaskPoolName } from '../const/TaskConst';

/**
 * 查询文件的LocationType
 */
export class GetLocationTypeTask extends BaseTask {

  constructor(relativePath: string, callback: Function) {
    super(TaskPoolName.GET_LOCATION_TYPE);
    this.task = new taskpool.Task(startTask, relativePath);
    this.callback = callback;
  }
}

/**
 * 查询线程
 * @param uri uri
 * @returns 文件LocationType
 */
@Concurrent
async function startTask(relativePath: string): Promise<number> {
  return FsUtil.getLocationType(relativePath);
}