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

import { FileInfo, FileUtil, FsUtil, GlobalHolder, HiLog } from '@ohos/common';
import fs from '@ohos.file.fs';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { PhotoAccessUtil } from '@ohos/common/indexLazyLoad'
import common from '@ohos.app.ability.common';
import type ctx from '@ohos.app.ability.common';

const TAG: string = 'TestFileUtil';

export class TestFileUtil {
  public static readonly TEST_FOLDER_PATH: string = 'storage/Users/currentUser/TestFolder';
  public static readonly TEST_FOLDER_URI: string = 'file://Docs/storage/Users/currentUser/TestFolder';
  public static readonly TEST_FOLDER: string = 'TestFolder';
  public static readonly TEST_FILE_NAME: string = 'Test.txt';
  public static readonly TEST_IMAGE_NAME: string = 'Test.png';

  public static createFile(parentFolder: string, fileName: string): FileInfo {
    let fileFd: fs.File | undefined;
    try {
      if (!fs.accessSync(parentFolder)) {
        fs.mkdirSync(parentFolder);
      }
      let filePath = parentFolder + '/' + fileName;
      fileFd = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    } catch (e) {
      HiLog.info(TAG, 'create file error ' + JSON.stringify(e));
    } finally {
      if (fileFd) {
        fs.closeSync(fileFd);
      }
    }
    return FileInfo.fromFsFile(parentFolder + '/' + fileName, fileName);
  }

  public static async createAlbumFile(albumInfo: photoAccessHelper.Album | undefined, fileName: string):
    Promise<FileInfo | undefined> {
    let context = GlobalHolder.getInstance().getMainAbilityContext() as ctx.UIAbilityContext;
    if (!albumInfo?.albumUri) {
      return undefined;
    }
    let newFileUris: string[] = await PhotoAccessUtil.createFileToAlbum(context as common.Context,
      fileName, albumInfo.albumUri);
    if (newFileUris.length === 0) {
      return undefined;
    }

    let fileFd: fs.File | undefined;
    try {
      let filePath: string = FileUtil.getPathFromUri(newFileUris[0]);
      fileFd = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    } catch (e) {
      HiLog.info(TAG, 'create file error ' + JSON.stringify(e));
    } finally {
      if (fileFd) {
        fs.closeSync(fileFd);
      }
    }

    let fileInfo = await PhotoAccessUtil.getPhotoAssetInfoByUri(context as common.Context, newFileUris[0]);
    return fileInfo;
  }

  public static getFolderInfo(parentFolder: string, folderName: string): FileInfo {
    try {
      if (!fs.accessSync(parentFolder + '/' + folderName)) {
        fs.mkdirSync(parentFolder + '/' + folderName, true);
      }
    } catch (e) {
      HiLog.info(TAG, 'get Folder Info error ' + JSON.stringify(e));
    }
    return FileInfo.fromFsFile(parentFolder + '/' + folderName, folderName);
  }

  public static deleteFile(fileInfo: FileInfo): void {
    if (fileInfo.isFolder) {
      FsUtil.rmdirSync(fileInfo.relativePath);
    } else {
      FsUtil.unlinkSync(fileInfo.relativePath);
    }
  }

  public static async deleteAlbumByUri(context: common.Context, uri: string): Promise<void> {
    await PhotoAccessUtil.deletePermanently(context, uri);
  }

  public static async getAlbum(context: common.Context, albumName: string):
    Promise<photoAccessHelper.Album | undefined> {
    let albumInfo: photoAccessHelper.Album | undefined = undefined;
    albumInfo = await PhotoAccessUtil.getAlbumByName(context, albumName);
    if (albumInfo) {
      return albumInfo;
    }
    // 无同名新建相册
    albumInfo = await PhotoAccessUtil.createAlbum(context, albumName);
    return albumInfo;
  }
}