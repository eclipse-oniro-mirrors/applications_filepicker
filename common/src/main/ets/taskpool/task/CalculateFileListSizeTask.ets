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
import { FilesQueryUtil } from '../../fileoperate/FilesQueryUtil';
import { FileInfo } from '../../fileoperate/FileInfo';
import { TaskPoolUtils } from '../../utils/TaskPoolUtils';
import { FileUtil } from '../../fileoperate/FileUtil';
import { common } from '@kit.AbilityKit';
import lazy { PhotoAccessUtil } from '../../utils/PhotoAccessUtil';

/* instrument ignore file */

/**
 * 计算文件总大小
 */
export class CalculateFileListSizeTask extends BaseTask {
  constructor(receiveCallback: Function, fileUriList: string[], context: common.UIExtensionContext) {
    super(TaskPoolName.CALCULATE_FILE_LIST_SIZE_TASK);
    this.task = new taskpool.Task(startTask, fileUriList, context);
    this.onReceiveData(receiveCallback);
  }
}

@Concurrent
async function startTask(fileUriList: string[], context: common.UIAbilityContext): Promise<void> {
  HiLog.info(TaskPoolName.CALCULATE_FILE_LIST_SIZE_TASK, 'CalculateFileListSizeTask start');
  let totalSize: number = 0;
  let mediaUriList: string[] = [];
  for (const fileUri of fileUriList) {
    if (FileUtil.isMediaUri(fileUri)) {
      mediaUriList.push(fileUri);
      continue;
    }
    let fileInfo: FileInfo = FileInfo.fromFileUri(fileUri);
    if (fileInfo.isFolder) {
      totalSize += FilesQueryUtil.getFolderSize(fileInfo.uri);
    } else {
      totalSize += fileInfo.size;
    }
  }
  let mediaFileInfoList: FileInfo[] = await PhotoAccessUtil.getFileInfoByUriList(mediaUriList, context, true);
  mediaFileInfoList.forEach((fileInfo) => {
    if (!fileInfo.isFolder) {
      totalSize += fileInfo.size;
    }
  });
  TaskPoolUtils.sendData(totalSize, TaskStatus.END);
}