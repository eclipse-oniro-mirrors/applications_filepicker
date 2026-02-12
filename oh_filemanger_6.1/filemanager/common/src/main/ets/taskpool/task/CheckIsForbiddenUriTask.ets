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
import { AssertExtUtil } from '../../utils/AssertExtUtil';
import { BaseTask } from '../base/BaseTask';
import { TaskPoolName } from '../const/TaskConst';

/**
 * 检查uri是否禁止跳转
 */
export class CheckIsForbiddenUriTask extends BaseTask {

  constructor(uri: string, sandBoxFlag: boolean, callback: Function) {
    super(TaskPoolName.CHECK_IS_FORBIDDEN_URI);
    this.task = new taskpool.Task(checkIsForbiddenUri, uri, sandBoxFlag);
    this.callback = callback;
  }
}

/**
 * 查询线程
 * @param uri 文件路径uri
 * @param sandBoxFlag 是否是沙箱路径
 * @returns Promise<boolean>
 */
@Concurrent
async function checkIsForbiddenUri(uri: string, sandBoxFlag: boolean): Promise<boolean> {
  const res = AssertExtUtil.checkIsForbiddenUri(uri, sandBoxFlag);
  return res;
}