/*
 * Copyright (c) 2021-2025 Huawei Device Co., Ltd.
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
import { BaseTask } from "../base/BaseTask";
import { TaskpoolName, TaskStatus } from "../const/TaskConst";
import { taskpool } from "@kit.ArkTS";
import { FilePickerUtil } from "../../base/utils/FilePickerUtil";
import { TaskpoolUtils } from "../util/TaskpoolUtils";

export class BatchGrantUriPermissionTask extends BaseTask {
  constructor(fileUris: string[], callerId: number, receiveCallback: Function) {
    super(TaskpoolName.BATCH_AUTH_URI_PERMISSION_TASK);
    this.task = new taskpool.Task(startTask, fileUris, callerId);
    this.onReceiveData(receiveCallback);
  }
}

@Concurrent
async function startTask(fileUris: string[], callerId: number) {
  let udKey: string = await FilePickerUtil.batchGrantUriPermission(fileUris, callerId);
  TaskpoolUtils.sendData(udKey, TaskStatus.END);
}