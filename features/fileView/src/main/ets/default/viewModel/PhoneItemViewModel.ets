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
  FilePickerUtil,
  FileSourceType,
  HiLog,
  LocationType,
  MediaMetaData,
  MediaThumbnailConst,
  ObjectUtil,
  PAGE_ROUTE_CONST,
  StartModeOptions,
  StringUtil,
  TaskManager,
  DragManager,
  FileInfo,
  FileMimeTypeUtil,
  MediaMetaDataUtil,
  QueryFolderSubCountTask,
  QueryMediaSizeAndDurationTask,
  FileUtil,
  FsUtil,
  VirtualUri,
  FileSourceUri,
  MimeType,
  MyPhoneConstant,
  ExternalStorageUtil,
  DeviceConfig,
} from '@ohos/common';
import { BaseViewModel } from './BaseViewModel';

const TAG = 'PhoneItemViewModel';

@Observed
export class PhoneItemViewModel extends BaseViewModel {
  // 拖拽数量
  @Track public dragNum: number = 0;
  @Track public startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();
  // 是否是选择器场景
  @Track public filePickerViewFlag: boolean = this.startModeOptions.pickerFlag;
  @Track public cacheImageAngle: number = 0;
  @Track public isChecked: boolean = false;

  constructor(fileInfo: FileInfo) {
    super(fileInfo, $r('app.color.transparent_color'));
    this.isChecked = this.fileInfo.isChecked;
  }

  resetFileInfo(fileInfo: FileInfo) {
    this.fileInfo = fileInfo;
    this.isChecked = this.fileInfo.isChecked;
  }

  setBackGround(navMode: NavigationMode, currentNavItem: string): void {
    // 分栏搜索
    if ((navMode === NavigationMode.Split) && (currentNavItem === this.fileInfo.uri)) {
      this.bgColor = $r('app.color.split_item_onFocus');
      return;
    }
    this.bgColor = $r('app.color.transparent_color');
  }

  supportDrag(enableDrag: boolean): boolean {
    return DragManager.getInstance().supportDrag(this.startModeOptions) && enableDrag;
  }

  /**
   * 是否可拖拽
   * @param enableDrag  是否拖拽使能
   * @param checkedNum 已选文件数
   * @returns 是否可拖拽
   */
  isDraggable(enableDrag: boolean, checkedNum: number): boolean {
    return this.supportDrag(enableDrag) && this.fileInfo.isMultiEnable &&
      (checkedNum > 1 || !MyPhoneConstant.isSystemFolder(
        ExternalStorageUtil.getParentUri(this.fileInfo.uri ?? ''),
        this.fileInfo.fileName, this.fileInfo.isFolder)) &&
      !FileUtil.isGalleryFolder(this.fileInfo) &&
      !this.fileInfo.isFusionAlbum;
  }

  getSourceType(): string | Resource {
    let source: string | Resource = '';
    switch (this.fileInfo.sourceType) {
      case FileSourceType.LOCAL_DISK:
        source = DeviceConfig.getInstance().config.myDevice;
        break;
      case FileSourceType.EXTERNAL_USB:
        source = this.fileInfo.rootName;
        break;
      case FileSourceType.RECENT_DELETE:
        source = $r('app.string.recentlyDeleted');
        break;
      default:
        break;
    }
    return source;
  }

  /**
   * 获取媒体文件的元数据（大小和时长，不拿缩略图）
   */
  getMediaFileMetaDataWithoutThumb(callback?: (uri: string) => void): void {
    // 图库文件不需要获取
    if (this.fileInfo.isGallery) {
      return;
    }
    // 仅处理视频类型文件
    if (this.fileInfo.isFolder || this.fileInfo.mimeTypeObj.fileCategory !== MimeType.FILE_CATEGORY_VIDEO) {
      return;
    }
    let currentTaskUri: string = this.fileInfo.uri;
    const task: QueryMediaSizeAndDurationTask = new QueryMediaSizeAndDurationTask(
      (metaData: MediaMetaData) => {
        HiLog.infoPrivate(TAG, 'QueryMediaSizeAndDurationTask callback uri ', currentTaskUri);
        if (currentTaskUri === this.fileInfo.uri && this.isNeedUpdateMediaMetaData(metaData) && callback) {
          callback(currentTaskUri);
        }
      }, this.fileInfo);
    TaskManager.getInstance().execute<number>(task, MediaThumbnailConst.MAX_CONCURRENT_TASK_NUM,
      false, MediaThumbnailConst.MAX_LONG_TASK_QUEUES);
  }

  /**
   * 更新媒体文件数据
   * @param metaData 获取到的元数据
   */
  isNeedUpdateMediaMetaData(metaData: MediaMetaData): boolean {
    if (ObjectUtil.isNullOrUndefined(metaData)) {
      return false;
    }
    if (FileMimeTypeUtil.isImage(this.fileInfo.mimeTypeObj)) {
      this.fileInfo.picWidth = metaData.width;
      this.fileInfo.picHeight = metaData.height;
    } else if (FileMimeTypeUtil.isVideo(this.fileInfo.mimeTypeObj)) {
      this.fileInfo.duration = metaData.duration;
      this.fileInfo.picWidth = metaData.width;
      this.fileInfo.picHeight = metaData.height;
    } else {
      this.fileInfo.duration = metaData.duration;
    }
    if (StringUtil.isEmpty(metaData.thumbnailPath) &&
    FileMimeTypeUtil.isImage(this.fileInfo.mimeTypeObj)) {
      if (MediaMetaDataUtil.checkImageByteSize(metaData.width, metaData.height)) {
        this.fileInfo.thumbUri = this.fileInfo.uri;
        this.fileInfo.isLoadThumbnailError = true;
      }
    } else {
      this.fileInfo.thumbUri = metaData.thumbnailPath;
      this.fileInfo.isLoadThumbnailError = false;
    }
    return true;
  }

  /**
   * 获取并展示文件夹里子项的个数
   */
  getFolderSubFileCount(showHiddenItem: boolean, callback: () => void): void {
    if (!this.isShowFolderSubCount()) {
      return;
    }
    if (this.fileInfo.subFileCount !== -1) {
      callback();
      return;
    }
    let task: QueryFolderSubCountTask = new QueryFolderSubCountTask(this.fileInfo.uri, showHiddenItem,
      (subFileCount: number) => {
        HiLog.debugPrivate(TAG,
          `updateFolderSubFileCount, oldCount:${this.fileInfo.subFileCount}, newCount = ${subFileCount}`,
          `uri:${this.fileInfo.uri}`);
        this.fileInfo.subFileCount = subFileCount;
        callback();
      });
    TaskManager.getInstance().execute<number>(task, 1, false, 30);
  }

  isShowFolderSubCount() {
    return this.fileInfo.isFolder && !this.fileInfo.isGallery
  }

  getShowTime(isShowRecentTime: boolean, isShowDeleteTime: boolean): number {
    if (isShowRecentTime) {
      return this.fileInfo.recentTime;
    }
    if (isShowDeleteTime) {
      return this.fileInfo.deleteTime;
    }
    return this.fileInfo.mtime;
  }

  /**
   * 判断是否显示CheckBox
   * 文件选择器场景下，文件夹暂不支持选择
   * @returns
   */
  showCheckBox(): boolean {
    return !this.filePickerViewFlag || !this.fileInfo.isFolder;
  }

  /**
   * 判断文件是否可选设置不同的透明度
   */
  getItemOpacity(): Resource {
    return this.fileInfo.isMultiEnable ? $r('app.float.common_opacity10') : $r('sys.float.ohos_id_alpha_disabled');
  }
}