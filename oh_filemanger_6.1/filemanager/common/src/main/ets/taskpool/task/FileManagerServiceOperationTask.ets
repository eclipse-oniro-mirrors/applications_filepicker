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
import { TaskPoolName } from '../const/TaskConst';
import { HiLog } from '../../dfx/HiLog';
import lazy { filemanager } from '../../model/filetag/FileManager';

/* instrument ignore file */

/**
 * 调用文件服务操作接口
 */
export class FileManagerServiceOperationTask extends BaseTask {
  constructor(uris: string[], callBack: Function) {
    super(TaskPoolName.FILE_MANAGER_SERVICE_OPERATION);
    this.task = new taskpool.Task(executeFileManagerServiceOperation, uris);
    this.callback = callBack;
  }
}

@Concurrent
async function executeFileManagerServiceOperation(argsArray: string[]): Promise<void> {
  HiLog.info(TaskPoolName.FILE_MANAGER_SERVICE_OPERATION, 'task start');
  for (const args of argsArray) {
    filemanager.handleRemoteRequest(args);
  }
}