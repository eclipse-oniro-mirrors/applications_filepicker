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
import { BundleResourceUtil } from '../../utils/BundleResourceUtil';
import { TaskPoolUtils } from '../../utils/TaskPoolUtils';

/**
 * 创建下载目录uri展示map
 */
export class CreateDownloadUriShowMapTask extends BaseTask {
  constructor(callback: Function) {
    super(TaskPoolName.CREATE_DOWNLOAD_URI_SHOW_MAP);
    this.task = new taskpool.Task(startTask);
    this.onReceiveData(callback);
  }
}

@Concurrent
async function startTask(): Promise<void> {
  HiLog.info(TaskPoolName.CREATE_DOWNLOAD_URI_SHOW_MAP, 'CreateDownloadUriShowMapTask start');
  TaskPoolUtils.sendData(BundleResourceUtil.getDownloadNameMap(), TaskStatus.END);
}