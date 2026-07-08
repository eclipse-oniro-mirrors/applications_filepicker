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

import fileuri from '@ohos.file.fileuri';
import fs from '@ohos.file.fs';
import { HiLog } from '../dfx/HiLog';
import { Constant, FileSourceType, LocationType } from '../const/Constant';
import type { MimeType } from '../model/MimeType';
import { FileUtil } from './FileUtil';
import FileMimeTypeUtil from '../utils/FileMimeTypeUtil';
import { ERROR_CODE } from '../const/ErrorCode';
import { ThumbnailUtil } from '../utils/ThumbnailUtil';
import { HighLightData } from './HighLightData';
import lazy TrashNapi from 'libTrash.so';
import { StoragePathUtil } from '../utils/StoragePathUtil';
import { DateUtil } from '../utils/DateUtil';
import { collections } from '@kit.ArkTS';

/**
 * Customized FileInfo class
 */
// instrument ignore next
@Sendable
export class FileInfo {
  /*******   common  ************/
  public fileName: string = ''; // File name and extension
  public uri: string = '';
  public mtime: number = 0; // seconds
  public size: number = 0; // KB
  public mimeType: string = '';
  public relativePath: string = '';
  public locationType: number = 0;
  public isFolder: boolean = false;
  public pdfHighLightPageIndex: number = -1; // pdf预览高亮页码
  public pdfHighLightKeyWords: collections.Array<string> = new collections.Array<string>(); // pdf预览高亮关键字
  /*******   pc  ************/
  public addedDate: number = 0; // seconds
  public ctime: number = 0; // 创建时间
  public useCacheImage: boolean = true; // 是否缓存图片
  public thumbnailType: string = 'unknown';
  public ino: string = ''; // 文件唯一标识符
  public fileSuffix: string = ''
  public deleteTime: number = 0;
  /*******   phone  ************/
  /**
   * 缩略图地址
   * 修改 thumbUri 值
   */
  public thumbUri: string = '';
  /**
   * 相册内容缩略图图库缓存地址参数
   */
  public timesStampApp?: number;
  public thumbnailModifiledMs?: number;
  public path?: string;
  /**
   * 文件来源(仅搜索微信来源时使用)
   */
  public appSourceName: string = '';
  /**
   * 音视频文件的时长
   */
  public duration: number = 0;
  /**
   * 最近里数据的上次访问时间
   */
  public recentTime: number = 0;
  /**
   * 是否为外部存储文件
   */
  public isExternalStorageDeviceFile: boolean = false;
  /**
   * 多选模式下是否选中
   */
  public isChecked: boolean = false;
  /**
   * 文件夹下子文件个数
   */
  public subFileCount: number = Constant.FOLDER_SUB_DEFAULT;
  /**
   * 图片或视频的高
   */
  public picWidth: number = 0;
  /**
   * 图片或视频的高
   */
  public picHeight: number = 0;
  /**
   * 储存设备的名字
   */
  public rootName: string = '';
  public parentPathForDetail: string = '';
  public mimeTypeObj: MimeType = FileMimeTypeUtil.UNKNOWN_MIMETYPE;
  /**
   * 文件所处的存储存储设备的Uid
   */
  public storageDeviceUid: string = '';
  public sourceType: number = FileSourceType.UNKNOWN;
  public isMultiEnable: boolean = true;
  // 相册的封面Uri
  public coverUri: string = '';
  /**
   * 回收站数据的原始路径
   */
  public srcPath: string = '';
  public isSystemFile: boolean = false;
  public highLightContent: collections.Array<HighLightData>  = new collections.Array<HighLightData>();
  public isLoadThumbnailError: boolean = false;
  /**
   * 图库相册类型：相册属性
   */
  public albumType: number = -1;
  public albumSubType: number = -1;

  /**
   * 图片文件属性：所在父相册的信息
   * 父相册uri在parentPathForDetail中记录
   */
  public parentAlbumName?: string;
  public parentAlbumType?: number;
  public parentAlbumSubType?: number;
  public ownerAlbumId: number = -1;  // 所在归属相册Id,可查询到相册信息

  public isFusionAlbum: boolean = false; // 是否是融合相册
  public hasFusionAssets: boolean = false; // 是否含有融合相册

  public isGallery: boolean = false;
  public isVirtualGallery: boolean = false;

  /**
   *  是否已持久化授权
   */
  public isPersistPermission: boolean = false;

  public static fromRecentOrTrashFileInfo(recentOrTrashFileInfo: FileInfo | TrashNapi.FileInfo): FileInfo {
    let fileInfo = new FileInfo();
    if (recentOrTrashFileInfo === undefined) {
      return fileInfo;
    }
    // 最近删除文件来源字段
    switch (StoragePathUtil.getDiskNameByRelativePath(recentOrTrashFileInfo?.srcPath)) {
      case 'EXTERNAL_DISK':
        fileInfo.sourceType = FileSourceType.EXTERNAL_USB;
        break;
      default:
        fileInfo.sourceType = FileSourceType.LOCAL_DISK;
        break;
    }
    // common
    fileInfo.fileName = recentOrTrashFileInfo.fileName || '';
    fileInfo.uri = recentOrTrashFileInfo.uri || '';
    fileInfo.mtime = recentOrTrashFileInfo.mtime * Constant.TIME.ONE_SECOND || 0;
    fileInfo.deleteTime = recentOrTrashFileInfo.deleteTime ? recentOrTrashFileInfo.deleteTime * 1000 : 0;
    fileInfo.size = recentOrTrashFileInfo.size || 0;
    fileInfo.relativePath = recentOrTrashFileInfo.srcPath || '';
    fileInfo.locationType = LocationType.LOCAL;
    fileInfo.isFolder = FileInfo.fromFileUri(fileInfo.uri).isFolder;
    // phone
    fileInfo.mimeTypeObj = FileMimeTypeUtil.getMimeType(fileInfo.fileName, fileInfo.isFolder, fileInfo.subFileCount);
    FileInfo.getThumbnailType(fileInfo);
    return fileInfo;
  }

  /**
   * create fileInfo by trash.FileInfo
   * note: fileInfo 文件信息
   */
  public static fromTrashFileInfo(fileInfo: TrashNapi.FileInfo): FileInfo {
    let newFileInfo = FileInfo.fromRecentOrTrashFileInfo(fileInfo);
    newFileInfo.addedDate = fileInfo.ctime;
    newFileInfo.mtime = fileInfo.mtime;
    if (fileInfo.deleteTime) {
      newFileInfo.deleteTime = fileInfo.deleteTime;
      newFileInfo.deleteTime *= Constant.TIME.ONE_SECOND;
    } else {
      newFileInfo.deleteTime = fileInfo.mtime;
    }
    newFileInfo.srcPath = fileInfo.srcPath;
    FileInfo.getThumbnailType(newFileInfo);
    return newFileInfo;
  }

  public static getThumbnailType(fileInfo: FileInfo): void {
    // 缩略图类型
    fileInfo.thumbnailType = ThumbnailUtil.getThumbnailType(fileInfo);
    fileInfo.useCacheImage = false;
    // 支持缩略图的，使用cachedImage
    if (fileInfo.uri.startsWith(Constant.MediaLibrary_URI_HEAD) &&
    ThumbnailUtil.THUMBNAIL_SUPPORT_TYPE.has(fileInfo.thumbnailType)) {
      fileInfo.useCacheImage = true;
    }
  }

  /*
   * create fileInfo by uri
   * */
  public static fromFileUri(uri: string): FileInfo {
    let fileInfo = new FileInfo();
    fileInfo.uri = uri;
    try {
      let fileUri: fileuri.FileUri = new fileuri.FileUri(uri);
      fileInfo.fileName = fileUri.name;
      fileInfo.relativePath = fileUri.path;
      let stat = fs.statSync(fileUri.path);
      fileInfo.isFolder = stat.isDirectory();
      fileInfo.size = stat.size;
      fileInfo.ino = '' + stat.ino;
      fileInfo.locationType = stat.location;
      fileInfo.addedDate = stat.atime;
      fileInfo.mtime = stat.mtime;
      fileInfo.ctime = stat.atime;
      FileInfo.getThumbnailType(fileInfo);
    } catch (err) {
      HiLog.errorPrivate('FileInfo', `fromFileUri fail: ${JSON.stringify(err)}, uri:`, uri);
    }
    return fileInfo;
  }

  /*
   * create fileInfo by uri
   * */
  public static fromFileUriByPhone(uri: string): FileInfo {
    let fileInfo = new FileInfo();
    fileInfo.uri = uri;
    try {
      let fileUri: fileuri.FileUri = new fileuri.FileUri(uri);
      fileInfo.fileName = fileUri.name;
      fileInfo.relativePath = fileUri.path;
      let stat = fs.statSync(fileUri.path);
      fileInfo.isFolder = stat.isDirectory();
      fileInfo.size = stat.size;
      fileInfo.mimeTypeObj = FileMimeTypeUtil.getMimeType(fileInfo.fileName, fileInfo.isFolder, fileInfo.subFileCount);
      fileInfo.mtime = DateUtil.changeTimeToMills(stat.mtime);
      fileInfo.ctime = DateUtil.changeTimeToMills(stat.atime);
      fileInfo.addedDate = DateUtil.changeTimeToMills(stat.atime);
      fileInfo.locationType = stat.location;
    } catch (err) {
      HiLog.errorPrivate('FileInfo', `fromFileUri fail: ${JSON.stringify(err)}, uri:`, uri);
    }
    return fileInfo;
  }

  /*
   * 粘贴使用
   * */
  public static fromFileUriByOpen(uri: string): FileInfo {
    let fileInfo = new FileInfo();
    fileInfo.uri = uri;
    let fsFile: fs.File | null = null;
    try {
      let fileUri: fileuri.FileUri = new fileuri.FileUri(fileInfo.uri);
      fileInfo.relativePath = fileUri.path;
      fileInfo.fileName = fileUri.name;
      fsFile = fs.openSync(fileInfo.uri);
      const fsFileInfo = fs.statSync(fsFile.fd);
      fileInfo.size = fsFileInfo.size;
      fileInfo.isFolder = fsFileInfo.isDirectory();
      return fileInfo;
    } catch (error) {
      fileInfo.size = 0;
      HiLog.error('fileInfo', 'fromFileUriByOpen error: ' + JSON.stringify(error));
    } finally {
      if (fsFile) {
        fs.closeSync(fsFile);
      }
    }
    return fileInfo;
  }

  /*
    * create fileInfo by uri
    * */
  public static fromFsFile(path: string, fileName: string): FileInfo {
    let fileInfo = new FileInfo();
    fileInfo.uri = FileUtil.getUriFromPath(path);
    try {
      fileInfo.fileName = fileName;
      fileInfo.relativePath = path;
      let stat = fs.statSync(path);
      fileInfo.isFolder = stat.isDirectory();
      fileInfo.size = stat.isDirectory() ? 0 : stat.size;
      fileInfo.mtime = stat.mtime;
      fileInfo.addedDate = stat.atime;
      fileInfo.ino = '' + stat.ino;
      fileInfo.locationType = stat.location;
      fileInfo.ctime = stat.atime;
      FileInfo.getThumbnailType(fileInfo);
    } catch (err) {
      HiLog.errorPrivate('FileInfo', `fromFsFile fail:${JSON.stringify(err)}, path:`, path);
      if (err.code === ERROR_CODE.FILE_ACCESS.PERMISSION_DENIED) {
        HiLog.error('FileInfo', 'get file info failed, PERMISSION_DENIED');
      }
    }
    return fileInfo;
  }

  /*
    * Obtains the name of a file without a suffix.
    * */
  public static getNameWithoutSuffix(fileInfo: FileInfo): string {
    if (!fileInfo) {
      return '';
    }
    let fileName: string = fileInfo.fileName;
    if (fileInfo.isFolder) {
      return fileName;
    }
    let firstPoint: number = fileName.lastIndexOf('.');
    if (firstPoint !== -1) {
      let firstSuffix = fileName.slice(firstPoint);
      fileName = fileName.slice(0, firstPoint);
    }
    return fileName;
  }

  public static convertMtime(fileInfo: FileInfo): void {
    fileInfo.mtime *= Constant.TIME.ONE_SECOND;
  }

  public static getRefreshMark(fileInfo: FileInfo): string {
    return fileInfo.uri + '_' + fileInfo.mtime + '_' + fileInfo.recentTime + '_' + fileInfo.locationType + '_' + fileInfo.size + '_' +
      (fileInfo.locationType === LocationType.LOCAL ? '' : fileInfo.subFileCount) +
      '_' + JSON.stringify(fileInfo.highLightContent);
  }
}
