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

import {
  BaseTask,
  Constant,
  FileUtil,
  HiLog,
  TaskPoolName,
  VirtualUri,
  AppInfo,
} from '@ohos/common';
import taskpool from '@ohos.taskpool';
import common from '@ohos.app.ability.common';
import {
  ResultErrorParams,
  SaveFilesResult,
  CheckFileDupWithFolderResult
} from '@ohos/common/src/main/ets/gallery/SaveFilesResult';
import { FileCommonUtil } from '../../base/utils/FileCommonUtil';
import { BusinessError } from '@ohos.base';
import fileUri from '@ohos.file.fileuri';
import fs from '@ohos.file.fs'
import lazy { PhotoAccessUtil } from '@ohos/common/indexLazyLoad';

/**
 * 保存文件
 */
export class SaveFileTask extends BaseTask {
  constructor(context: common.Context, dirPath: string, fileNameArr: string[], bundleName: string, callback: Function,
    appInfo: AppInfo, isDupWithFolder: boolean) {
    super(TaskPoolName.FILE_OPERATE);
    this.task =
      new taskpool.Task(startTask, context, dirPath, fileNameArr, bundleName, appInfo, isDupWithFolder);
    this.callback = callback;
  }
}

/**
 * 查询线程
 * @param uri uri
 * @returns 子文件个数
 */
@Concurrent
async function startTask(context: common.Context, dirUri: string,
  fileNameArr: string[], bundleName: string, appInfo: AppInfo, isDupWithFolder: boolean): Promise<SaveFilesResult> {
  const TAG = 'SaveFileTask';
  let successArr: string[] = [];
  let resultErr: undefined | ResultErrorParams;
  let len: number = fileNameArr.length;
  let fileNameList: string[] = [];
  if (context && appInfo.bundleName) {
    HiLog.info(TAG, 'saveFiles start: copyThirdPhotoToGallery');
    let res = await PhotoAccessUtil.copyThirdPhotoToGallery(context, fileNameArr, dirUri, appInfo);
    return res;
  }

  if (len > 1) {
    fileNameList = FileUtil.getSubFileListByUri(dirUri);
  }
  HiLog.infoPrivate(TAG, 'saveFiles start: ', JSON.stringify(fileNameList));
  for (let i = 0; i < len; i++) {
    const currName = fileNameArr[i];
    let result: string | BusinessError;
    const dirPath: string = FileUtil.getPathFromUri(dirUri);
    const filePath: string = dirPath + "/" + currName;
    const fileExists: boolean = await FileUtil.isExistByPathWithFs(filePath);
    if (len === 1) {
      HiLog.info(TAG, 'fileExists : ' + fileExists);
      const fileUri: string = FileUtil.getUriFromPath(filePath);
      if (fileExists && !isDupWithFolder) {
        result = fileUri;
      } else if (isDupWithFolder) {
        result = await FileCommonUtil.tryRenameFileOperate(currName, dirUri, 1, fileNameList);
      } else {
        HiLog.warn(TAG, 'file not exists.');
        result = FileUtil.createFile(dirUri, currName);
      }
      HiLog.info(TAG, 'Generate fileUri end.');
    } else {
      if (fileExists) {
        HiLog.info(TAG, 'save file task startTask: fileExists, try rename.');
        result = await FileCommonUtil.tryRenameFileOperate(currName, dirUri, 1, fileNameList);
      } else {
        result = FileUtil.createFile(dirUri, currName);
      }
    }
    if (typeof result === 'string') {
      HiLog.infoPrivate(TAG, 'saveFiles createOK: ', result);
      successArr.push(result);
      try {
        const path = new fileUri.FileUri(result).path;
        const inode = fs.statSync(path).ino.toString();
        await Constant.updateUserId();
        const uri = decodeURIComponent(result).replace(VirtualUri.MY_PC, Constant.REAL_LOCAL_COMMON_PATH);
      } catch (error) {
        HiLog.info(TAG, 'error' + JSON.stringify(error));
      }
      continue;
    }
    HiLog.info(TAG, 'saveFiles err: ' + result.code);
    // 失败
    resultErr = { code: result.code, message: '' };
    for (let i = 0; i < successArr.length; i++) {
      await FileUtil.hardDelete(successArr[i]);
    }
    successArr = [];
    break;
  }
  HiLog.warn(TAG, `The length of the successfully saved file: ${successArr.length}`);
  if (bundleName !== Constant.FILE_MANAGER_BUNDLE_NAME) {
    HiLog.info(TAG, 'saveFiles end: add file to recent');
  }
  return new SaveFilesResult(successArr, resultErr);
}

export class CheckFileNameDuplicateTask extends BaseTask {
  constructor(fileUri: string, callback: Function) {
    super(TaskPoolName.FILE_OPERATE);
    this.task =
      new taskpool.Task(checkFileNameDuplicate, fileUri);
    this.callback = callback;
  }
}

@Concurrent
export function checkFileNameDuplicate(fileUri: string): CheckFileDupWithFolderResult {
  let fileUriIsFolder: boolean = false;
  let isExist: boolean = false;
  let checkResult: CheckFileDupWithFolderResult;
  try {
    const filePath: string = FileUtil.getPathFromUri(fileUri);
    isExist = fs.accessSync(filePath);
    if (isExist) {
      let stat: fs.Stat = fs.statSync(filePath);
      fileUriIsFolder = stat.isDirectory();
    }
    checkResult = new CheckFileDupWithFolderResult(isExist, fileUriIsFolder);
  } catch (error) {
    HiLog.error('checkFileNameDuplicate', `check isDirectory failed, code: ${error?.code}, msg: ${error?.message}`);
    checkResult =
      new CheckFileDupWithFolderResult(isExist, fileUriIsFolder, { code: error?.code, message: error?.message });
  }
  return checkResult;
}
