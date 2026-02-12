/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import { HiLog } from '../dfx/HiLog';
import { FileInfo } from './FileInfo';
import { FsUtil } from '../utils/FsUtil';
import { fileUri } from '@kit.CoreFileKit';
import taskpool from '@ohos.taskpool';
import { Constant, LocationType } from '../const/Constant';
import fs from '@ohos.file.fs';
import FileMimeTypeUtil from '../utils/FileMimeTypeUtil';
import { FileUtil } from './FileUtil';
import { QueryFileParam } from '../taskpool/queryparam/QueryFileParam';
import { TaskConst, TaskStatus } from '../taskpool/const/TaskConst';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'FilesQueryUtil';

export class FilesQueryUtil {

  /**
   * 用于task 发送文件列表
   * @param folderPath
   * @param fileNameList
   * @param fileList
   * @param data
   */
  public static batchSendDataTask(fileList: FileInfo[], data: QueryFileParam, message: string, maxCount: number,
    isSendTaskRunning?: boolean): void {
    if (taskpool.Task.isCanceled()) {
      HiLog.warn(TaskConst.TAG, message);
      taskpool.Task.sendData([], TaskStatus.CANCEL, data.queryId);
      return;
    }
    // 分批发送
    const fileListLength = fileList.length;
    let isPostEnd = false;
    for (let i = 0; i <= fileListLength; i += maxCount) {
      if (taskpool.Task.isCanceled()) {
        HiLog.warn(TaskConst.TAG, message);
        taskpool.Task.sendData([], TaskStatus.CANCEL, data.queryId);
        return;
      }
      let end = i + maxCount;
      if (end >= fileListLength) {
        end = fileListLength;
        isPostEnd = true;
      }
      let status = isSendTaskRunning ? TaskStatus.RUNNING : (isPostEnd ? TaskStatus.END : TaskStatus.RUNNING);
      taskpool.Task.sendData(fileList.slice(i, end), status, data.queryId);
      if (isPostEnd) {
        return;
      }
    }
  }

  public static getFileDataByPathWidthFs(path: string, fileName: string, data: QueryFileParam,
    isCheckSystemFile: boolean = true): FileInfo {
    const fileData: FileInfo = new FileInfo();
    try {
      let stat: fs.Stat = FsUtil.statSync(path) as fs.Stat;
      fileData.isFolder = stat.isDirectory();
      fileData.fileName = fileName;
      fileData.size = stat.size;
      fileData.uri = FileUtil.getUriFromPath(path);
      fileData.mtime = stat.mtime * Constant.TIME.ONE_SECOND;
      fileData.relativePath = path;
      fileData.mimeTypeObj = FileMimeTypeUtil.getMimeType(fileData.fileName, fileData.isFolder, fileData.subFileCount);
      fileData.isExternalStorageDeviceFile = data.isExternalStorageDevice;
      fileData.rootName = data.rootName;
      fileData.storageDeviceUid = data.storageDeviceUid;
      fileData.parentPathForDetail = data.currBreadFullPath;
      fileData.locationType = stat.location;
      FileInfo.getThumbnailType(fileData);
      if (isCheckSystemFile) {
        fileData.isSystemFile = Constant.ROOT_DIRECTORY_MEDIA_LIBRARY.includes(fileData.fileName);
      }
    } catch (error) {
      HiLog.error(TAG, 'getFileDataByPathWidthFs fail, error:' + JSON.stringify(error));
    }
    return fileData;
  }

  public static recurseDir(path: string, fileStat: fs.Stat,
    callback: (fileSize: number, isDirectory: boolean) => void) {
    try {
      if (!fileStat.isDirectory()) {
        callback(fileStat.size, false);
        return;
      }
      let fileNameArr = fs.listFileSync(path);
      let fileLength: number = fileNameArr.length;
      let filePath: string = '';
      for (let i = 0; i < fileLength; i++) {
        filePath = `${path}/${fileNameArr[i]}`;
        let stat = fs.statSync(filePath);
        if (stat.isFile()) {
          callback(stat.size, false);
        } else {
          FilesQueryUtil.recurseDir(filePath, stat, callback);
        }
      }
    } catch (error) {
      HiLog.error(TAG, `recurseDir, get file info error, ${JSON.stringify(error)}`)
      callback(fileStat.size, false);
    }
  }

  public static getFolderSize(uri: string): number {
    let fileInfo: fileUri.FileUri = new fileUri.FileUri(uri);
    try {
      if (!fs.accessSync(fileInfo.path)) {
        return 0;
      }
      let fileStat: fs.Stat = fs.statSync(fileInfo.path);

      if (!fileStat.isDirectory()) {
        return fileStat.size;
      }
      let size: number = 0;
      FilesQueryUtil.recurseDir(fileInfo.path, fileStat, (fileSize: number, isDirectory: boolean) => {
        if (!isDirectory) {
          size += fileSize;
        }
      });
      return size;
    } catch (error) {
      HiLog.error(TAG, `getFolderSize err, ${JSON.stringify(error)}`)
    }
    return 0;
  }
}