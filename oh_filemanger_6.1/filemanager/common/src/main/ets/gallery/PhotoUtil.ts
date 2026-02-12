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

import lazy { photoAccessHelper } from '../../../../indexLazyLoadTs';
import { common } from '@kit.AbilityKit';

// 媒体库文件来源类型
export enum PhotoFileSourceType {
  // 媒体库的媒体文件
  MEDIA = 0,
  // 文管本地的媒体文件
  FILE_MANAGER = 1,
  // 外设的媒体文件
  PERIPHERAL
}

export class PhotoUtil {
  public static readonly FETCH_COLUMNS: string[] = [
    photoAccessHelper.PhotoKeys.SIZE,
    photoAccessHelper.PhotoKeys.DATE_ADDED,
    photoAccessHelper.PhotoKeys.DATE_MODIFIED,
    photoAccessHelper.PhotoKeys.PHOTO_TYPE,
    photoAccessHelper.PhotoKeys.TITLE,
    photoAccessHelper.PhotoKeys.DATE_MODIFIED_MS,
    photoAccessHelper.PhotoKeys.DURATION,
    photoAccessHelper.PhotoKeys.WIDTH,
    photoAccessHelper.PhotoKeys.HEIGHT,
    photoAccessHelper.PhotoKeys.DATE_TRASHED_MS,
    'thumbnail_ready',
    'data',
    photoAccessHelper.PhotoKeys.POSITION,
    'owner_album_id'];

  public static readonly FETCH_COPY_COLUMNS: string[] = [
    photoAccessHelper.PhotoKeys.SIZE,
    photoAccessHelper.PhotoKeys.PHOTO_SUBTYPE, // 用于获取文件是否是MOVING_PHOTO类型
    'owner_album_id'
  ];

  // 媒体库Photos表文件来源类型字段 代码提交时只上了GLB设备 后续考虑移到FETCH_COLUMNS
  public static readonly FILE_SOURCE_TYPE: string = 'file_source_type';

  // 媒体库Photos表文件文件路径字段 代码提交时只上了GLB设备 后续考虑移到FETCH_COLUMNS
  public static readonly STORAGE_PATH: string = 'storage_path';

  public static async getSupportedPhotoFormats(accessHelper: photoAccessHelper.PhotoAccessHelper,
    photoType: photoAccessHelper.PhotoType): Promise<string[]> {
    return accessHelper.getSupportedPhotoFormats(photoType);
  }

  public static async createAssetsForAppWithAlbum(accessHelper: photoAccessHelper.PhotoAccessHelper,
    isAuthorization: boolean, albumUri: string, photoCreationConfigs: photoAccessHelper.PhotoCreationConfig[],
    bundleName: string = '', appName: string = '', appId: string = '', tokenId: number = 0): Promise<string[]> {

    let photoCreationSource = {
      budleName: bundleName,
      appName: appName,
      appId: appId,
      tokenId: tokenId
    };
    return await accessHelper.createAssetsForAppWithAlbum(photoCreationSource, albumUri,
      isAuthorization, photoCreationConfigs);
  }

  public static async deleteLocalAssetsPermanently(
    context: common.Context, assets: photoAccessHelper.PhotoAsset[]): Promise<string[]> {
    //@ts-ignore
    return await photoAccessHelper.MediaAssetChangeRequest.deleteLocalAssetsPermanently(context, assets);
  }
}