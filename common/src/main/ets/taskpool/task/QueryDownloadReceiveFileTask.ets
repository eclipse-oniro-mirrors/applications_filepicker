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
import { TaskConst, TaskPoolName, TaskStatus } from '../const/TaskConst';
import { HiLog } from '../../dfx/HiLog';
import { StringUtil } from '../../utils/StringUtil';
import { FileUtil } from '../../fileoperate/FileUtil';
import { FilesQueryUtil } from '../../fileoperate/FilesQueryUtil';
import { FileInfo } from '../../fileoperate/FileInfo';
import { QueryFileParam } from '../queryparam/QueryFileParam';
import { FsUtil } from '../../utils/FsUtil'
import taskpool from '@ohos.taskpool';
import fs, { ListFileOptions } from '@ohos.file.fs';
import { Constant } from '../../const/Constant';
import lazy { PhotoAccessUtil } from '../../utils/PhotoAccessUtil';

/* instrument ignore file */

/**
 * 查询“下载与接收”中的文件夹下的文件
 * 如果需要融合图库数据，可指定融合的应用名
 */
export class QueryDownloadReceiveFileTask extends BaseTask {
  constructor(receiveCallback: Function, data: QueryFileParam, needMerge : boolean, bundleName: string) {
    super(TaskPoolName.FILE_QUERY);
    this.task = new taskpool.Task(startTask, data, needMerge, bundleName);
    this.onReceiveData(receiveCallback);
  }
}

@Concurrent
async function startTask(data: QueryFileParam, needMerge:boolean, bundleName: string): Promise<void> {
  let fileList: FileInfo[] = [];
  let mediaFileList: FileInfo[] = [];
  if (!data) {
    HiLog.error(TaskConst.TAG, 'QueryDownloadReceiveFileTask param is null.');
    taskpool.Task.sendData(fileList, TaskStatus.END, -1);
    return;
  }

  try {
    let dirUri = data.dirUri;
    if (StringUtil.isEmpty(dirUri)) {
      HiLog.error(TaskConst.TAG, 'QueryDownloadReceiveFileTask dirUri is null.');
      taskpool.Task.sendData(fileList, TaskStatus.END, data.queryId);
      return;
    }
    if (data.context && needMerge) {
      mediaFileList =
        await PhotoAccessUtil.getPhotoInSourceAlbum(data.context, bundleName, data.orderBy, data.isDesc);
    }

    const MAX_COUNT = 10000;
    HiLog.infoPrivate(TaskConst.TAG, 'QueryDownloadReceiveFileTask start', dirUri);
    if (dirUri.endsWith('/')) {
      dirUri = dirUri.slice(0, -1);
    }
    const dirPath: string = FileUtil.getPathFromUri(dirUri);
    // 目录不存在需要返回,否则后面list file会报错
    if (!FsUtil.isExistSyncByPath(dirPath)) {
      if (mediaFileList.length === 0) {
        taskpool.Task.sendData([], TaskStatus.END, data.queryId);
      } else {
        FilesQueryUtil.batchSendDataTask(mediaFileList, data, 'QueryDownloadReceiveFileTask cancel', MAX_COUNT);
      }
      return;
    }

    // 查询子文件
    let subFiles: string[] = [];
    let option: ListFileOptions =
      data.showHiddenItem ? { recursion: true } :
        { recursion: true, filter: { displayName: [Constant.HIDDEN_ITEM_FILTER] } };
    subFiles = fs.listFileSync(dirPath, option);
    for (let relativePath of subFiles) {
      if (taskpool.Task.isCanceled()) {
        HiLog.warn(TaskConst.TAG, 'QueryDownloadReceiveFileTask cancel');
        taskpool.Task.sendData([], TaskStatus.CANCEL, data.queryId);
        return;
      }
      const fullUri = dirUri + encodeURIComponent(relativePath).replace(/%2F/g, '/');
      const fileInfo = FileInfo.fromFileUriByPhone(fullUri);
      FileInfo.getThumbnailType(fileInfo);
      fileList.push(fileInfo);
    }

    // 将图库数据与文管数据合并
    fileList = fileList.concat(mediaFileList);

    FilesQueryUtil.batchSendDataTask(fileList, data, 'QueryDownloadReceiveFileTask cancel', MAX_COUNT);
  } catch (error) {
    HiLog.error(TaskConst.TAG, 'QueryDownloadReceiveFileTask fail, error:' + JSON.stringify(error));
    taskpool.Task.sendData([], TaskStatus.END, data.queryId);
  }
}
