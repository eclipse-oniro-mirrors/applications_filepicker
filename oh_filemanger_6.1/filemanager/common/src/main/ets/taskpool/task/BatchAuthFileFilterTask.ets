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
import { TaskPoolUtils } from '../../utils/TaskPoolUtils';
import { BaseTask } from '../base/BaseTask';
import { TaskPoolName } from '../const/TaskConst';
import { HiLog } from '../../dfx/HiLog';
import { FileUriUtil } from '../../fileoperate/FileUriUtil';
import { AssertExtUtil } from '../../utils/AssertExtUtil';
import { Constant, FileSourceType, LocationType } from '../../const/Constant';
import { FilePickerUtil } from '../../etsexport/utils/FilePickerUtil';
import { StringUtil } from '../../utils/StringUtil';
import { DateUtil } from '../../utils/DateUtil';
import { FileInfo } from '../../fileoperate/FileInfo';
import { VirtualUri } from '../../const/FolderRecord';
import { collections } from '@kit.ArkTS';

/* instrument ignore file */

/**
 * 过滤不允许访问的uri
 */
export class BatchAuthUrisFilterTask extends BaseTask {
  constructor(receiveCallback: Function, uris: string[], udkey: string) {
    super(TaskPoolName.FILTER_URIS);
    this.task = TaskPoolUtils.createTask(startTask, uris, udkey);
    this.onReceiveData(receiveCallback);
  }
}

@Concurrent
async function startTask(batchAuthUris: string[], udkey: string): Promise<void> {
  const tag: string = 'FileBatchAuthPickerPage';
  if (!StringUtil.isEmpty(udkey)) {
    batchAuthUris = await FilePickerUtil.getBatchAuthUrisByUdkey(udkey);
  }
  let filteredFiles: collections.Array<FileInfo> = new collections.Array<FileInfo>();
  new Set(batchAuthUris).forEach((uri: string) => {
    if (!uri || !StringUtil.isEmpty(AssertExtUtil.checkUriAccess(uri)) ||
    FileUriUtil.isForbiddenVisitUri(uri)) {
      return;
    }
    if (uri.startsWith(Constant.MediaLibrary_URI_HEAD)) {
      return;
    }
    let fileInfo: FileInfo = FileInfo.fromFileUri(uri);
    // 文件夹不能被授权
    if (fileInfo.isFolder) {
      return;
    }
    fileInfo.isChecked = true;
    fileInfo.recentTime = DateUtil.changeTimeToMills(fileInfo.mtime); // 上次修改该文件的时间
    filteredFiles.push(fileInfo);
  });

  HiLog.info(
    tag, `auth count: ${batchAuthUris.length},filteredFiles length: ${filteredFiles.length}`);
  TaskPoolUtils.sendData(filteredFiles);
}