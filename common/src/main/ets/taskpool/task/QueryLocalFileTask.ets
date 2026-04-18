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
import taskpool from '@ohos.taskpool';
import { HiLog } from '../../dfx/HiLog';
import { StringUtil } from '../../utils/StringUtil';
import { FileUtil } from '../../fileoperate/FileUtil';
import { ArrayUtil } from '../../utils/ArrayUtil';
import { FilesQueryUtil } from '../../fileoperate/FilesQueryUtil';
import { FileInfo } from '../../fileoperate/FileInfo';
import { QueryFileParam } from '../queryparam/QueryFileParam';
import { VirtualUri } from '../../const/FolderRecord';
import lazy { PhotoAccessUtil } from '../../utils/PhotoAccessUtil'
import { HiSysEventUtil } from '../../dfx/HiSysEventUtil';
import { Constant } from '../../const/Constant';
import { ResourceUtil } from '../../utils/ResourceUtil';
import { PhotoCondition } from '../queryparam/PhotoCondition';
import { MyPhoneConstant } from '../../const/MyPhoneConstant';
import FileUtilNative from 'libSecurity.so'
import FileMimeTypeUtil from '../../utils/FileMimeTypeUtil';
import { NativeFileInfo } from '../../fileoperate/NativeFileInfo';
import { FsUtil } from '../../utils/FsUtil';
import { GlobalHolder } from '../../global/GlobalHolder';
import { CommonPreferenceUtil } from '../../preference/CommonPreferenceUtil';
import { common } from '@kit.AbilityKit';
import { GlobalKey } from '../../global/GlobalKey';

/* instrument ignore file */

/**
 * 查询本地文件
 */
export class QueryLocalFileTask extends BaseTask {
  constructor(receiveCallback: Function, data: QueryFileParam, filePickerViewFlag: boolean) {
    super(TaskPoolName.FILE_QUERY);
    this.task = new taskpool.Task(startTask, data, filePickerViewFlag,
      GlobalHolder.getInstance().abilityStageContext);
    this.onReceiveData(receiveCallback);
  }
}

@Concurrent
async function startTask(data: QueryFileParam, filePickerViewFlag: boolean, abilityStageContext: common.AbilityStageContext): Promise<void> {
  const startTimeDefault = new Date().getTime();
  let fileList: FileInfo[] = [];
  if (!data) {
    HiLog.error(TaskConst.TAG, 'QueryLocalFileTask param is null.');
    taskpool.Task.sendData(fileList, TaskStatus.END, -1);
    return;
  }
  HiLog.info(TaskConst.TAG, `QueryLocalFileTask `);

  const dirUri = data.dirUri;
  if (StringUtil.isEmpty(dirUri)) {
    HiLog.error(TaskConst.TAG, 'QueryLocalFileTask dirUri is null.');
    taskpool.Task.sendData(fileList, TaskStatus.END, data.queryId);
    return;
  }
  const MAX_COUNT = 10000;
  HiLog.infoPrivate(TaskConst.TAG, 'QueryLocalFileTask start', dirUri);
  try {
    if ((dirUri === VirtualUri.GALLERY || dirUri === VirtualUri.IMAGE || dirUri === VirtualUri.VIDEO) && data.context) {
      HiLog.info(TaskConst.TAG, 'QueryLocalFileTask start for GALLERY');
      fileList = await PhotoAccessUtil.getAllPhotoAlbums(data, dirUri, filePickerViewFlag);
      FilesQueryUtil.batchSendDataTask(fileList, data, 'QueryLocalFileTask getAllAlbum cancel', MAX_COUNT);
      GlobalHolder.getInstance().abilityStageContext = abilityStageContext;
      await CommonPreferenceUtil.cleanAlbumGuideKey(fileList.map((fileInfo: FileInfo) => fileInfo.uri), filePickerViewFlag);
      return;
    }

    // 查询相册文件
    if (dirUri.startsWith(Constant.MediaLibrary_URI_HEAD) && data.context && data.albumType !== undefined && data.albumSubType) {
      HiLog.info(TaskConst.TAG, 'Query for albumType = ' + data.albumType + ', albumSubTyp = ' + data.albumSubType);
      GlobalHolder.getInstance().setObject<boolean>(GlobalKey.PICKER_FLAG, filePickerViewFlag);
      await PhotoAccessUtil.getPhotoIncremental(data);
      return;
    }
    const path = FileUtil.getPathWithFileSplit(FileUtil.getPathFromUri(dirUri));
    HiLog.infoPrivate(TaskConst.TAG, 'QueryLocalFileTask path', path);

    if (dirUri === Constant.MY_PHONE_URI && data.context) {
      const galleryFileInfo = new FileInfo();
      galleryFileInfo.uri = VirtualUri.GALLERY;
      galleryFileInfo.isFolder = true;
      galleryFileInfo.fileName = ResourceUtil.getStringByResource($r('app.string.pc_gallery'), data.context);
      galleryFileInfo.subFileCount = 1; // 先暂时按照图库文件有内容显示
      galleryFileInfo.isChecked = false;
      galleryFileInfo.isSystemFile = true;
      galleryFileInfo.isGallery = true;
      galleryFileInfo.isMultiEnable = filePickerViewFlag;
      fileList.push(galleryFileInfo)
    }

    FileUtilNative.queryFiles(path, MAX_COUNT, (files: NativeFileInfo[], isFinish: boolean): boolean => {
      HiLog.info(TaskConst.TAG, `queryFiles callback. size: ${files.length}` + 'isFinish' + isFinish);
      for (let i = 0; i < files.length; i++) {
        if (taskpool.Task.isCanceled()) {
          HiLog.info(TaskConst.TAG, 'QueryLocalFileTask cancel');
          taskpool.Task.sendData([], TaskStatus.CANCEL, data.queryId);
          return false; // 返回false，停止查询任务
        }
        let nativeFileInfo = files[i];
        if (!data.showHiddenItem && nativeFileInfo.fileName.startsWith('.')) {
          continue;
        }
        let file: FileInfo = NativeFileInfo.getFileInfoFromNative(nativeFileInfo);
        if (dirUri === Constant.MY_PHONE_URI && Constant.PHONE_SYSTEM_FOLDER_NAME.includes(file.fileName)) {
          HiLog.warn(TaskConst.TAG, 'query file list: skip this folder');
          continue;
        }
        const filePath = path + nativeFileInfo.fileName;
        file.mimeTypeObj = FileMimeTypeUtil.getMimeType(file.fileName, file.isFolder, file.subFileCount);
        file.isExternalStorageDeviceFile = data.isExternalStorageDevice;
        file.rootName = data.rootName;
        file.storageDeviceUid = data.storageDeviceUid;
        file.parentPathForDetail = data.currBreadFullPath;
        file.isSystemFile = Constant.ROOT_DIRECTORY_MEDIA_LIBRARY.includes(file.fileName);
        fileList.push(file);
      }
      if (!taskpool.Task.isCanceled()) { // 任务未取消，发送一批文件
        taskpool.Task.sendData(fileList, isFinish ? TaskStatus.END : TaskStatus.RUNNING, data.queryId);
        fileList = []; // 发送完后清空数组
        return true;
      }
      return false;
    })
  } catch (error) {
    HiLog.error(TaskConst.TAG, 'QueryLocalFileTask fail, error:' + JSON.stringify(error));
    taskpool.Task.sendData([], TaskStatus.END, data.queryId);
  }
  let executeTime = new Date().getTime() - startTimeDefault;
  if (data.isExternalStorageDevice) {
    HiSysEventUtil.reportExternalGetFileCost(executeTime, fileList.length);
  }
}