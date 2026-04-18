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

import { FileMimeTypeUtil } from '../utils/FileMimeTypeUtil';
import { FileInfo } from '../fileoperate/FileInfo';
import { HiLog } from '../dfx/HiLog';
import { VirtualUri } from '../const/FolderRecord';
import { UiUtil } from '../utils/UiUtil';
import { ObjectUtil } from '../utils/ObjectUtil';
import lazy { UDC, UTD } from '../../../../indexLazyLoadTs';
import { MimeType } from '../model/MimeType';

const tag = 'UdmfUtil';

export class UdmfInfo {
  public fileUri: string; // 文件Uri
  public isRemote: boolean; // 是否跨端数据

  constructor() {
    this.fileUri = '';
    this.isRemote = false;
  }
}

export class UdmfUtils {
  public static readonly FROM_RECENT: string = 'fromRecent';
  public static readonly FROM_SIDEBAR: string = 'fromSidebar';
  public static readonly FROM_USER_SIDEBAR: string = 'fromUserSidebar';
  public static readonly FROM_FILE_VIEW: string = 'fromFileView';
  public static readonly FROM_TAG_MANAGEMENT: string = 'fromTagManagement';
  public static readonly FROM_RECYCLE_BIN: string = 'fromRecycleBin';
  public static readonly FROM_SCENE_BOARD: string = 'drag_data_type';
  public static readonly TO_ITEM_VIEW_FOLDER: string = 'toItemViewFolder';
  public static readonly RECYCLE_BIN_URI: string = 'file://docs/storage/Users/currentUser/.Trash';
  public static readonly fixedUriSet: Set<string> = new Set([
    VirtualUri.RECENT,
    VirtualUri.RECYCLE_BIN,
    VirtualUri.DESKTOP,
    VirtualUri.DOWNLOAD,
    VirtualUri.MY_PC,
    VirtualUri.GALLERY,
    VirtualUri.DOCUMENT,
    VirtualUri.PCENGINE,
    VirtualUri.IMAGES
  ]);
  public static readonly CROSS_DEVICE_DRAG_FILE_MAX_NUM: number = 2000;
  public static readonly DRAG_IN_THE_APP: string = 'drag_in_the_app';

  /**
   * 根据不同的文件类型，生成对应类型的UnifiedData数据
   * @param fileInfo 源文件
   */
  public static setUnifiedData(fileInfo: FileInfo): UDC.Folder | UDC.Image | UDC.Audio | UDC.Video | UDC.File {
    let resultType: UDC.Folder | UDC.Image | UDC.Audio | UDC.Video | UDC.File;
    let tempFile = new UDC.File();
    tempFile.uri = fileInfo.uri;
    resultType = tempFile;
    let fileMimeCategory: number = FileMimeTypeUtil.getFileMimeType(fileInfo.fileName).fileCategory;
    if (fileInfo.isFolder) {
      let tempFolder = new UDC.Folder();
      tempFolder.folderUri = fileInfo.uri;
      let detail: Record<string, string> = {};
      detail['name'] = UiUtil.translateFileNameByUri(fileInfo.uri, fileInfo.fileName, fileInfo.isFolder);
      tempFolder.details = detail;
      resultType = tempFolder;
    } else if (fileMimeCategory === MimeType.FILE_CATEGORY_IMAGE) {
      let tempImage = new UDC.Image();
      tempImage.imageUri = fileInfo.uri;
      resultType = tempImage;
    } else if (fileMimeCategory === MimeType.FILE_CATEGORY_VIDEO) {
      let tempVideo = new UDC.Video();
      tempVideo.videoUri = fileInfo.uri;
      resultType = tempVideo;
    } else if (fileMimeCategory === MimeType.FILE_CATEGORY_AUDIO) {
      let tempAudio = new UDC.Audio();
      tempAudio.audioUri = fileInfo.uri;
      resultType = tempAudio;
    }
    HiLog.info(tag, 'setUnifiedData finish');
    return resultType;
  }

  /**
   * 从record中获取数据
   * @param record UnifiedData中的单条文件记录
   * @param type 改record数据所属文件类别
   */
  public static getRecordData(record: UDC.UnifiedRecord, type: string): UdmfInfo {
    let recordData = '';
    let isRemote = false;
    switch (type) {
      case UTD.UniformDataType.FILE:
        let file = record as UDC.File;
        recordData = file.uri;
        break;
      case UTD.UniformDataType.IMAGE:
        let image = record as UDC.Image;
        recordData = image.imageUri;
        break;
      case UTD.UniformDataType.VIDEO:
        let video = record as UDC.Video;
        recordData = video.videoUri;
        break;
      case UTD.UniformDataType.AUDIO:
        let audio = record as UDC.Audio;
        recordData = audio.audioUri;
        break;
      case UTD.UniformDataType.FOLDER:
        let folder = record as UDC.Folder;
        recordData = folder.folderUri;
        break;
    }
    if (recordData.includes('resource:///')) { // 当前应用资源文件，拖拽到文管，无法处理，通过此方法屏蔽
      recordData = '';
    }
    HiLog.infoPrivate(tag, 'getRecordData:', recordData);
    return { fileUri: recordData, isRemote: isRemote };
  }

  public static getExtra(extraParams?: string): string {
    let extraInfo: string = '';
    if (extraParams) {
      let tempExtraInfo: string = '';
      try {
        tempExtraInfo = JSON.parse(extraParams).extraInfo;
      } catch (err) {
        HiLog.error(tag, 'Json parse error.')
      }
      if (!ObjectUtil.isNullOrUndefined(tempExtraInfo)) {
        extraInfo = tempExtraInfo;
      }
    }
    return extraInfo;
  }
}
