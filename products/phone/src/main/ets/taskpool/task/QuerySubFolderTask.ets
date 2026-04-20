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
import { FileCommonUtil } from '../../base/utils/FileCommonUtil';
import { BaseTask, FileInfo, HiLog, StringUtil, TaskConst, TaskPoolName, VirtualUri,
  ResourceUtil } from '@ohos/common';
import { FileUtil } from '@ohos/common';
import { FolderData } from '@ohos/common/src/main/ets/fileoperate/FolderData';
import lazy { PhotoAccessUtil } from '@ohos/common/indexLazyLoad';
import lazy { photoAccessHelper } from '@ohos/common/indexLazyLoadTs';

/**
 * 查询文件夹下子文件夹
 */
export class QuerySubFolderTask extends BaseTask {
  constructor(callback: Function, folderUri: string, targetFolderUri: string,
    folderLevel: number, isRootFolder: boolean, selectFileUris: string[], showHiddenItem: boolean, context: Context) {
    super(TaskPoolName.QUERY_PICK_PATH);
    this.task =
      new taskpool.Task(startTask, folderUri, targetFolderUri, folderLevel, isRootFolder, selectFileUris,
        showHiddenItem, context);
    this.onReceiveData(callback);
  }
}


@Concurrent
async function startTask(folderUri: string, targetFolderUri: string,
  folderLevel: number, isRootFolder: boolean, selectFileUris: string[], showHiddenItem: boolean,
  context: Context): Promise<void> {
  HiLog.infoPrivate(TaskConst.TAG, 'getFolderList start',
    `folderUri: ${folderUri}, targetFolderUri: ${targetFolderUri}`);
  try {
    if (StringUtil.isEmpty(folderUri)) {
      taskpool.Task.sendData([], folderUri, targetFolderUri);
      return;
    }
    let folderList: FolderData[] = [];
    if (folderUri === VirtualUri.GALLERY) {
      let albums = await PhotoAccessUtil.getPhotoAlbumsForPath(context, folderUri);
      for (let photoAlbum of albums) {
        const PHOTO_URI_MAP: Map<photoAccessHelper.AlbumSubtype, Resource> = new Map([
          [photoAccessHelper.AlbumSubtype.IMAGE, $r('app.string.image')],
          [photoAccessHelper.AlbumSubtype.VIDEO, $r('app.string.video')]]);
        let galleryFolder = new FolderData();
        galleryFolder.uri = photoAlbum.albumUri;
        galleryFolder.level = 3;
        galleryFolder.parentUri = VirtualUri.GALLERY;
        galleryFolder.fileName = photoAlbum.albumType === photoAccessHelper.AlbumType.SYSTEM ?
        ResourceUtil.getStringByResource(PHOTO_URI_MAP.get(photoAlbum.albumSubtype), context) :
        photoAlbum.albumName;
        folderList.push(galleryFolder);
      }
      taskpool.Task.sendData(folderList, folderUri, targetFolderUri, 0);
      return;
    }
    const folderPath = FileUtil.getPathFromUri(folderUri);
    let selectFilesMaxLevel: number = 0
    const isExist = await FileUtil.isExistByPathWithFs(folderPath);
    if (!isExist) {
      taskpool.Task.sendData([], folderUri, targetFolderUri);
      return;
    }
    showHiddenItem = showHiddenItem;
    folderList =
      await FileCommonUtil.getSubFolderListWithFs(folderUri, isRootFolder, targetFolderUri, folderLevel,
        showHiddenItem);
    HiLog.info(TaskConst.TAG, `getFolderList selectFilesMaxLevel: ${selectFilesMaxLevel}`);
    taskpool.Task.sendData(folderList, folderUri, targetFolderUri, selectFilesMaxLevel);
  } catch (err) {
    HiLog.error(TaskConst.TAG, 'QuerySubFolderTask fail!')
  }
}

