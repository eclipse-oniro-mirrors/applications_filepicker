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
import { taskpool } from '@kit.ArkTS';
import { TaskPoolUtils } from '../../utils/TaskPoolUtils';
import { FilePickerUtil } from '../../etsexport/utils/FilePickerUtil';

export class BatchGrantUriPermissionTask extends BaseTask {
  constructor(fileUriList: string[], callId: number, receiveCallback: Function) {
    super(TaskPoolName.BATCH_GRANT_URI_PERMISSION_TASK);
    this.task = new taskpool.Task(startTask, fileUriList, callId);
    this.onReceiveData(receiveCallback);
  }
}

@Concurrent
async function startTask(fileUriList: string[], callId: number): Promise<void> {
  let res = await FilePickerUtil.batchGrantUriPermission(fileUriList, callId);
  TaskPoolUtils.sendData(res, TaskStatus.END);
}