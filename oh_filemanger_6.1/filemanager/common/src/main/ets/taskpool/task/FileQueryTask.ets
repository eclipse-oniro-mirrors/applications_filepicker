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
import { FileInfo } from '../../fileoperate/FileInfo';
import { TrashUtil } from '../../fileoperate/TrashUtil';
import { BaseTask } from '../base/BaseTask';
import { FilesQueryUtil } from '../../fileoperate/FilesQueryUtil';
import { TaskConst, TaskPoolName, TaskStatus } from '../const/TaskConst';
import { HiLog } from '../../dfx/HiLog';
import { VirtualUri } from '../../const/FolderRecord';
import { QueryFileParam, QueryRecentFileParam } from '../queryparam/QueryFileParam';
import { SortUtil } from '../../utils/SortUtil';
import { Constant } from '../../const/Constant';
import { FilePickerUtil } from '../../etsexport/utils/FilePickerUtil';
import lazy { filemanager } from '../../model/filetag/FileManager';
import lazy TrashNapi from 'libTrash.so';
import lazy { PhotoAccessUtil } from '../../utils/PhotoAccessUtil';

/* instrument ignore file */

/**
 * 查询回收站未超期文件总数
 */
export class QueryTrashFileSumTask extends BaseTask {
  constructor(callback: Function) {
    super(TaskPoolName.FILE_QUERY, VirtualUri.RECYCLE_BIN);
    this.task = new taskpool.Task(queryTrashFileSumTask, getContext(this), true);
    this.callback = callback;
  }
}

/**
 * 查询回收站未超期文件数量线程
 */
@Concurrent
async function queryTrashFileSumTask(context: Context, isPhotoCertified: boolean = false): Promise<number> {
  let notDeprecatedFileSum: number = 0;
  try {
    let fileInfoArray: TrashNapi.FileInfo[] = TrashNapi.listTrashFile();
    HiLog.info(TaskConst.TAG, `filemanager listTrashFile length = ${fileInfoArray.length}`);
    const currentTime: number = Date.now();
    for (const trashFileInfo of fileInfoArray) {
      let fileInfo = FileInfo.fromTrashFileInfo(trashFileInfo);
      if (currentTime - fileInfo.deleteTime < Constant.DEFAULT_SAVE_TIME) {
        notDeprecatedFileSum++;
      }
    }
  } catch (error) {
    HiLog.error(TaskConst.TAG, `listTrashFile error : ${JSON.stringify(error)}`);
  }
  HiLog.warn(TaskConst.TAG, `notDeprecatedFileSum = ${notDeprecatedFileSum}`);
  let trashAlbumPictureSum: number = 0;
  const isPhotosLock = false;
  HiLog.info(TaskConst.TAG, `isPhotosLock: ${isPhotosLock}`);
  if (!isPhotosLock) {
    trashAlbumPictureSum = await PhotoAccessUtil.getTrashAlbumPictureSum(context);
  }
  HiLog.warn(TaskConst.TAG, `getTrashAlbumPictureSum result = ${trashAlbumPictureSum}`);
  return notDeprecatedFileSum + trashAlbumPictureSum;
}

/**
 * 查询回收站文件(手机)
 */
export class QueryTrashTaskPhone extends BaseTask {
  public isRunning: boolean = true;

  constructor(callback: Function, data: QueryFileParam) {
    super(TaskPoolName.FILE_QUERY, VirtualUri.RECYCLE_BIN);
    this.task = new taskpool.Task(trashTaskPhone, data, true);
    this.onReceiveData(callback);
  }
}

/**
 * 回收站查询线程(手机)
 */
@Concurrent
async function trashTaskPhone(data: QueryFileParam, isPhotoCertified: boolean = false): Promise<void> {
  const TAG = 'trashTaskPhone';
  HiLog.warn(TAG, 'start FileQueryTask trashTask');
  const MAX_COUNT = 10000;
  const isPhotosLock = false;
  let trashFileArray: FileInfo[] = [];
  try {
    // 文管服务接口获取最近删除文件
    let fileInfoArray: TrashNapi.FileInfo[] = TrashNapi.listTrashFile();
    HiLog.info(TAG, 'getRecentDeletes length = ' + fileInfoArray.length);
    for (let trashFileInfo of fileInfoArray) {
      let fileInfo = FileInfo.fromTrashFileInfo(trashFileInfo);
      trashFileArray.push(fileInfo);
    }
    // 调用媒体库接口获取最近删除文件
    if (data.context && !isPhotosLock) {
      let photoTrashFileArray: FileInfo[] = [];
      let trashFileSum: number = await PhotoAccessUtil.getTrashAlbumPictureSum(data.context);
      let start = 0;
      while (start < trashFileSum) {
        if (taskpool.Task.isCanceled()) {
          HiLog.warn(TAG, 'QueryTrashTaskPhone is canceled');
          taskpool.Task.sendData([], TaskStatus.END);
          return;
        }
        let tempFileArray: FileInfo[] = await PhotoAccessUtil.getTrashAlbumsBatch(data.context, MAX_COUNT, start);
        photoTrashFileArray = photoTrashFileArray.concat(tempFileArray);
        tempFileArray.length = 0;
        start += MAX_COUNT;
      }
      trashFileArray = trashFileArray.concat(photoTrashFileArray);
      photoTrashFileArray.length = 0;
    } else {
      HiLog.error(TAG, `QueryTrashTaskPhone failed context is undefined or isPhotosLock: ${isPhotosLock}`);
    }
    const fileList: FileInfo[] = SortUtil.sortDataByOrder(trashFileArray, data.orderBy, data.isDesc, false, true);
    FilesQueryUtil.batchSendDataTask(fileList, data, 'QueryTrashTaskPhone cancel', MAX_COUNT);
    HiLog.warn(TAG, 'QueryTrashTaskPhone trashTask end');
  } catch (error) {
    HiLog.error(TAG, `QueryTrashTaskPhone fail, error: ${JSON.stringify(error)}`);
    taskpool.Task.sendData([], TaskStatus.END);
  }
}