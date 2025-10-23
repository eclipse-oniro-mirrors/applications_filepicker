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
import { TaskpoolName } from "../const/TaskConst";
import { TaskpoolUtils } from "../util/TaskpoolUtils";
import { FilesData } from "../../databases/model/FileData";
import FileAccessExec from "../../base/utils/FileAccessExec";
import StringUtil from "../../base/utils/StringUtil";
import { FilePickerUtil } from "../../base/utils/FilePickerUtil";
import Logger from "../../base/log/Logger";
import { VirtualUri } from "../../base/constants/FolderRecord";
import { FileUriUtil } from "../../base/utils/FileUriUtil";
import { Constant } from "../../base/constants/Constant";

export class BatchAuthFilterTask extends BaseTask {
  constructor(uris: string[], udkey: string, callback: Function) {
    super(TaskpoolName.BATCH_AUTH_URI_PERMISSION_TASK);
    this.task = TaskpoolUtils.createTask(startTask, uris, udkey);
    this.onReceiveData(callback);
  }
}

@Concurrent
async function startTask(uris: string[], udkey: string): Promise<void> {
  let filteredFiles: FilesData[] = [];
  let originUris: string[] = uris;
  if (!StringUtil.isEmpty(udkey)) {
    originUris = await FilePickerUtil.getBatchAuthUriByUdKey(udkey);
  }
  for (let i = 0; i < originUris.length; i++) {
    let uri = originUris[i];
    if (!uri || (!uri.startsWith(VirtualUri.MY_PC) && !uri.startsWith(VirtualUri.EXTERNAL_DISK)) ||
    FileUriUtil.isForbiddenVisitUri(uri) || uri.startsWith(Constant.MEDIA_LIBRARY_URI_HEAD) ||
    !FileUriUtil.trustedUriExt(uri)) {
      Logger.w('BatchAuthFilterTask', `${uri} : ${!uri.startsWith(VirtualUri.EXTERNAL_DISK)}`)
      continue;
    }
    let fileData = await FileAccessExec.getFilesDataByUri(uri);
    if (fileData.isFolder) {
      continue;
    }
    filteredFiles.push(fileData);
  }
  Logger.i('BatchAuthFilterTask', `filtered uris: ${filteredFiles.length}`);
  TaskpoolUtils.sendData(filteredFiles);
}