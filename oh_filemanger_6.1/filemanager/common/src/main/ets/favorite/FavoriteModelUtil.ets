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

import { StorageDeviceManager } from '../externel/StorageDeviceManager';
import { Constant, DataSourceDeviceType, FileSourceType } from '../const/Constant';
import { ArrayUtil } from '../utils/ArrayUtil';
import { ObjectUtil } from '../utils/ObjectUtil';
import { StringUtil } from '../utils/StringUtil';
import { HiLog } from '../dfx/HiLog';
import type { FileInfo } from '../fileoperate/FileInfo';
import { FavoriteModel } from '../model/FavoriteModel';

const TAG: string = 'FavUtil';

/**
 * 收藏数据模型操作类
 */
export class FavoriteModelUtil {
  public static isRecycled(recycledStatus: number): boolean {
    if (recycledStatus === Constant.FILE_RECYCLED.DELETED) {
      return true;
    }
    return false;
  }

  public static getRecycledStatus(isRecycled: boolean): number {
    if (isRecycled) {
      return Constant.FILE_RECYCLED.DELETED;
    }
    return Constant.FILE_RECYCLED.NORMAL;
  }

  public static setSortIndex(favoriteItem: FavoriteModel, sortIndex: number): void {
    if (favoriteItem.oldSortIndex === -1) {
      favoriteItem.oldSortIndex = sortIndex;
    }
    favoriteItem.sortIndex = sortIndex;
  }

  public static isNeedUpdateSortIndex(favoriteItem: FavoriteModel): boolean {
    if (favoriteItem.oldSortIndex !== -1) {
      return favoriteItem.oldSortIndex !== favoriteItem.sortIndex;
    }
    return false;
  }

  public static getDeviceTypeByNumber(deviceType: number): DataSourceDeviceType {
    switch (deviceType) {
      case DataSourceDeviceType.DEVICE_EXTERNAL.valueOf():
        return DataSourceDeviceType.DEVICE_EXTERNAL;
      case DataSourceDeviceType.DEVICE_INTERNAL.valueOf():
        return DataSourceDeviceType.DEVICE_INTERNAL;
      default:
        return DataSourceDeviceType.DEVICE_UNKNOWN;
    }
  }

  public static getNumberByDeviceType(deviceType: DataSourceDeviceType): number {
    switch (deviceType) {
      case DataSourceDeviceType.DEVICE_EXTERNAL:
        return DataSourceDeviceType.DEVICE_EXTERNAL.valueOf();
      case DataSourceDeviceType.DEVICE_INTERNAL:
        return DataSourceDeviceType.DEVICE_INTERNAL.valueOf();
      default:
        return DataSourceDeviceType.DEVICE_UNKNOWN.valueOf();
    }
  }

  public static getDeviceTypeBySourceType(sourceType: FileSourceType): DataSourceDeviceType {
    switch (sourceType) {
      case FileSourceType.EXTERNAL_USB:
        return DataSourceDeviceType.DEVICE_EXTERNAL;
      case FileSourceType.LOCAL_DISK:
        return DataSourceDeviceType.DEVICE_INTERNAL;
      default:
        return DataSourceDeviceType.DEVICE_UNKNOWN;
    }
  }

  public static createFavoriteListByFileDataList(
    fileDataList: FileInfo[],
    deviceType: DataSourceDeviceType = DataSourceDeviceType.DEVICE_INTERNAL,
    startIndex: number = 0,
    isNeedSetIndex: boolean = false): FavoriteModel[] {

    let favoriteList: FavoriteModel[] = [];
    if (ArrayUtil.isEmpty(fileDataList)) {
      return favoriteList;
    }
    for (let i = 0; i < fileDataList.length; i++) {
      let item = fileDataList[i];
      if (!item.isFolder) {
        continue;
      }
      let favorite: FavoriteModel = new FavoriteModel();
      favorite.name = item.fileName;
      favorite.path = item.relativePath;
      favorite.modifyTime = item.mtime;
      favorite.setTime = Date.now() + i; // 创建太快，导致setTime都一样，所以加下index
      favorite.deviceType = deviceType;
      if (favorite.deviceType === DataSourceDeviceType.DEVICE_EXTERNAL) {
        favorite.externalStorageUUID = StorageDeviceManager.getInstance().getUuidByPath(item.relativePath);
      }
      favorite.sortIndex = isNeedSetIndex ? startIndex++ : startIndex;
      favoriteList.push(favorite);
    }
    HiLog.info(TAG, `favoriteList.length: ${favoriteList.length}`);
    return favoriteList;
  }
}