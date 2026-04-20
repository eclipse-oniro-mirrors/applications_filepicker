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

import media from '@ohos.multimedia.media';
import image from '@ohos.multimedia.image';
import { MediaMetaData } from './MediaMetaData';
import { StringUtil } from '../utils/StringUtil';
import { ObjectUtil } from '../utils/ObjectUtil';
import { HiLog } from '../dfx/HiLog';
import { FileUtil } from '../fileoperate/FileUtil';
import { MimeType } from '../model/MimeType';
import FileMimeTypeUtil from '../utils/FileMimeTypeUtil';
import { HashUtil } from '../utils/HashUtil';
import { Constant } from '../const/Constant';
import { MediaThumbnailCacheUtil } from './MediaThumbnailCacheUtil';
import { MediaThumbnailUtil } from './MediaThumbnailUtil';
import { MediaThumbnailConst } from './MediaThumbnailConst';
import { FsUtil } from '../utils/FsUtil';
import { FileInfo } from '../fileoperate/FileInfo';

const TAG = 'MediaMetaDataUtil';

/**
 * 获取音视频文件的元数据工具类
 */
export class MediaMetaDataUtil {
  /**
   * 获取媒体文件的元数据
   * @param fileUri 文件uri
   * @param fileSize 文件大小
   * @param thumbnailCacheFileName 缩略图缓存文件的文件名
   * @param fileCategory 文件大分类
   * @param storageDeviceUID 存储设备UID
   * @param needVideoThumb 需要获取视频缩略图
   * @param customThumbPath 自定义路径
   * @returns MediaMetaData 元数据及缩略图
   */
  public static async getMetaData(fileUri: string, fileSize: number, thumbnailCacheFileName: string,
    fileCategory: number,
    storageDeviceUID: string, needVideoThumb: boolean = false, customThumbPath: string = ''): Promise<MediaMetaData> {
    let metaData: MediaMetaData = new MediaMetaData();
    HiLog.debugPrivate(TAG, 'getMeteData start, fileUri:', fileUri);
    if (StringUtil.isEmpty(fileUri)) {
      HiLog.warn(TAG, 'getMeteData fail, fileUri is empty.');
      return metaData;
    }
    const thumbnailCacheFileNameSha256 = await HashUtil.getSHA256(thumbnailCacheFileName);
    if (StringUtil.isEmpty(thumbnailCacheFileNameSha256)) {
      HiLog.errorPrivate(TAG, 'cacheFileNameSha256 is empty, fileUri:', fileUri);
      return metaData;
    }
    HiLog.debugPrivate(TAG, 'cacheFileName:', `${thumbnailCacheFileName}, sha256: ${thumbnailCacheFileNameSha256}`);
    const thumbnailCacheFilePath =
      await MediaThumbnailUtil.getThumbnailCacheFilePath(thumbnailCacheFileNameSha256, storageDeviceUID,
        customThumbPath);
    switch (fileCategory) {
      case MimeType.FILE_CATEGORY_IMAGE:
        metaData = await MediaMetaDataUtil.getImageMetaData(fileUri, fileSize, thumbnailCacheFilePath, fileCategory);
        break;
      case MimeType.FILE_CATEGORY_VIDEO:
      case MimeType.FILE_CATEGORY_AUDIO:
        metaData = await MediaMetaDataUtil.getAVMetaData(fileUri, thumbnailCacheFilePath, fileCategory);
        break;
      default:
        break;
    }
    if (!StringUtil.isEmpty(metaData.thumbnailPath)) {
      metaData.thumbnailPath = MediaThumbnailUtil.getFullThumbnailCachePath(metaData.thumbnailPath);
    }
    return metaData;
  }

  /**
   * 获取媒体文件的尺寸、时长数据
   * @param fileUri 文件uri
   * @param fileSize 文件大小
   * @param fileCategory 文件大分类
   * @returns MediaMetaData 元数据,不生成缩略图
   */
  public static async getMediaSizeAndDuration(fileUri: string, fileSize: number,
    fileCategory: number): Promise<MediaMetaData> {
    let metaData: MediaMetaData = new MediaMetaData();
    HiLog.debugPrivate(TAG, 'getMediaSizeAndDuration start, fileUri:', fileUri);
    if (StringUtil.isEmpty(fileUri)) {
      HiLog.warn(TAG, 'getMediaSizeAndDuration fail, fileUri is empty.');
      return metaData;
    }
    switch (fileCategory) {
      case MimeType.FILE_CATEGORY_IMAGE:
        metaData = await MediaMetaDataUtil.getImageSizeData(fileUri, fileSize);
        break;
      case MimeType.FILE_CATEGORY_VIDEO:
      case MimeType.FILE_CATEGORY_AUDIO:
        metaData = await MediaMetaDataUtil.getAVSizeAndDurationData(fileUri);
        break;
      default:
        break;
    }
    return metaData;
  }

  /**
   * 获取图片缩略图及信息，如尺寸、分辨率
   * @param fileUri 文件uri
   * @param thumbnailCacheFilePath 缓存文件的路径
   * @returns MediaMetaData 图片的元数据及缩略图地址
   */
  public static async getImageMetaData(fileUri: string, fileSize: number, thumbnailCacheFilePath: string,
    fileCategory: number): Promise<MediaMetaData> {
    let metaData: MediaMetaData = new MediaMetaData();
    if (fileSize >= Constant.BYTE.ONE_GB) {
      HiLog.errorPrivate(TAG, 'image file is over 1GB, fileUri:', fileUri);
      return metaData;
    }
    let fileFd: number = 0;
    let imageSource: image.ImageSource | undefined;
    HiLog.debugPrivate(TAG, 'getImageMetaData start, fileUri:', fileUri);
    if (StringUtil.isEmpty(fileUri)) {
      HiLog.warn(TAG, 'getImageMetaData fail, fileUri is empty.');
      return metaData;
    }
    try {
      fileFd = FileUtil.openFile(fileUri);
      imageSource = image.createImageSource(fileFd);
      // 获取原始图片的信息
      const originalImageInfo = await imageSource.getImageInfo();
      if (!ObjectUtil.isNullOrUndefined(originalImageInfo)) {
        metaData.width = originalImageInfo.size.width;
        metaData.height = originalImageInfo.size.height;
      }
      if (StringUtil.isEmpty(thumbnailCacheFilePath)) {
        throw new Error('thumbnailCacheFilePath is empty');
      }
      metaData.thumbnailPath =
        await MediaMetaDataUtil.getThumbnailPath(fileUri, thumbnailCacheFilePath, imageSource, undefined, undefined,
          undefined, fileCategory);
      HiLog.infoPrivate(TAG, `getImageMetaData success`, `metaData: ${JSON.stringify(metaData)},fileUri:${fileUri}`);
    } catch (error) {
      HiLog.errorPrivate(TAG, `getImageMetaData fail, error: ${JSON.stringify(error) + error}`, `fileUri:${fileUri}`);
    } finally {
      MediaMetaDataUtil.releaseSource(imageSource, fileFd);
    }
    return metaData;
  }

  /**
   * 获取图片尺寸信息
   * @param fileUri 文件uri
   * @returns MediaMetaData
   */
  public static async getImageSizeData(fileUri: string, fileSize: number): Promise<MediaMetaData> {
    let metaData: MediaMetaData = new MediaMetaData();
    if (fileSize >= Constant.BYTE.ONE_GB) {
      HiLog.errorPrivate(TAG, 'image file is over 1GB, fileUri:', fileUri);
      return metaData;
    }
    let fileFd: number = 0;
    let imageSource: image.ImageSource | undefined;
    HiLog.infoPrivate(TAG, 'getImageSizeData start, fileUri:', fileUri);
    if (StringUtil.isEmpty(fileUri)) {
      HiLog.warn(TAG, 'getImageSizeData fail, fileUri is empty.');
      return metaData;
    }
    try {
      fileFd = FileUtil.openFile(fileUri);
      imageSource = image.createImageSource(fileFd);
      // 获取原始图片的信息
      const originalImageInfo = await imageSource.getImageInfo();
      if (!ObjectUtil.isNullOrUndefined(originalImageInfo)) {
        metaData.width = originalImageInfo.size.width;
        metaData.height = originalImageInfo.size.height;
      }
      HiLog.infoPrivate(TAG, `getImageSizeData success`, `metaData: ${JSON.stringify(metaData)},fileUri:${fileUri}`);
    } catch (e) {
      HiLog.errorPrivate(TAG, `getImageSizeData fail,code:${e?.code},msg:${e?.message}`, `fileUri:${fileUri}`);
    } finally {
      MediaMetaDataUtil.releaseSource(imageSource, fileFd);
    }
    return metaData;
  }

  /**
   * 获取音视频的元数据及封面
   * @param fileUri 文件uri
   * @param thumbnailCacheFilePath 缓存文件的路径
   * @param isVideo 是否为视频
   * @returns MediaMetaData 音视频的元数据及封面地址
   */
  public static async getAVMetaData(fileUri: string, thumbnailCacheFilePath: string, fileCategory: number
  ): Promise<MediaMetaData> {
    let metaData: MediaMetaData = new MediaMetaData();
    let avMetadataExtractor: media.AVMetadataExtractor | undefined;
    let fileFd: number = 0;
    HiLog.debugPrivate(TAG, 'getAVMetaData start, fileUri:', fileUri);
    try {
      avMetadataExtractor = await media.createAVMetadataExtractor();
      fileFd = FileUtil.openFile(fileUri);
      const stat = await FileUtil.getFileStatByFs(fileFd);
      if (stat?.size === 0) {
        HiLog.error(TAG, 'getAVMetaData FileUtil.getFileStatByFs is undefined!');
        return metaData;
      }
      const fdSrc: media.AVFileDescriptor = {
        fd: fileFd,
        length: stat?.size
      };
      avMetadataExtractor.fdSrc = fdSrc;
      let tempMetadata: media.AVMetadata | undefined;
      try {
        tempMetadata = await avMetadataExtractor.fetchMetadata();
      } catch (error) {
        HiLog.errorPrivate(TAG, `fetchMetadata fail , error: ${JSON.stringify(error) + error}}`, `fileUri:${fileUri}`);
      }
      if ((!tempMetadata) || (!tempMetadata.duration)) {
        HiLog.warnPrivate(TAG, 'tempMetadata is empty object, fileUri:', fileUri);
      } else {
        HiLog.debug(TAG, 'fetchMetadata success, tempMetadata:' + JSON.stringify(tempMetadata));
        metaData.duration = Number(tempMetadata.duration);
        metaData.height = Number(tempMetadata.videoHeight);
        metaData.width = Number(tempMetadata.videoWidth);
        metaData.mimeType = tempMetadata.mimeType ?? '';
      }
      metaData.thumbnailPath =
        await MediaMetaDataUtil.getThumbnailPath(fileUri, thumbnailCacheFilePath, undefined, fdSrc, metaData,
          avMetadataExtractor, fileCategory, false);
           HiLog.infoPrivate(TAG, `getAVMetaData success`, `metaData: ${JSON.stringify(metaData)}, fileUri:${fileUri}`);
    } catch (error) {
      HiLog.errorPrivate(TAG, `getAVMetaData fail, error: ${JSON.stringify(error) + error}`, `fileUri:${fileUri}`);
    } finally {
      MediaMetaDataUtil.releaseSource(avMetadataExtractor, fileFd);
    }
    return metaData;
  }

  /**
   * 获取音视频的尺寸和时长数据
   * @param fileUri 文件uri
   * @returns MediaMetaData 音视频的尺寸和时长数据
   */
  public static async getAVSizeAndDurationData(fileUri: string): Promise<MediaMetaData> {
    let metaData: MediaMetaData = new MediaMetaData();
    let avMetadataExtractor: media.AVMetadataExtractor | undefined;
    let fileFd: number = 0;
    HiLog.debugPrivate(TAG, 'getAVSizeAndDurationData start, fileUri:', fileUri);
    try {
      avMetadataExtractor = await media.createAVMetadataExtractor();
      fileFd = FileUtil.openFile(fileUri);
      const stat = await FileUtil.getFileStatByFs(fileFd);
      if (stat?.size === 0) {
        HiLog.error(TAG, 'getAVSizeAndDurationData FileUtil.getFileStatByFs is undefined!');
        return metaData;
      }
      const fdSrc: media.AVFileDescriptor = {
        fd: fileFd,
        length: stat?.size
      };
      avMetadataExtractor.fdSrc = fdSrc;
      let tempMetadata: media.AVMetadata | undefined;
      try {
        tempMetadata = await avMetadataExtractor.fetchMetadata();
      } catch (error) {
        HiLog.errorPrivate(TAG, `fetchMetadata fail , error: ${JSON.stringify(error) + error}}`, `fileUri:${fileUri}`);
      }
      if ((!tempMetadata) || (!tempMetadata.duration)) {
        HiLog.warnPrivate(TAG, 'tempMetadata is empty object, fileUri:', fileUri);
      } else {
        HiLog.debug(TAG, 'fetchMetadata success, tempMetadata:' + JSON.stringify(tempMetadata));
        metaData.duration = Number(tempMetadata.duration);
        metaData.height = Number(tempMetadata.videoHeight);
        metaData.width = Number(tempMetadata.videoWidth);
        metaData.mimeType = tempMetadata.mimeType ?? '';
      }
      HiLog.infoPrivate(TAG, `getAVSizeAndDurationData success`,
        `metaData: ${JSON.stringify(metaData)}, fileUri:${fileUri}`);
    } catch (error) {
      HiLog.errorPrivate(TAG, `getAVSizeAndDurationData fail, error: ${JSON.stringify(error) + error}`,
        `fileUri:${fileUri}`);
    } finally {
      MediaMetaDataUtil.releaseSource(avMetadataExtractor, fileFd);
    }
    return metaData;
  }

  /**
   *  获取音视频的缩略图
   * @param fileUri 文件uri
   * @param thumbnailCacheFilePath 缩略图缓存路径
   * @param imagerSource 图片源实例
   * @param fdSrc 文件描述信息fd
   * @param metaData 音视频的元数据
   * @param avMetadataExtractor 元数据获取类实例
   * @param fileCategory 文件大分类
   * @param needVideoThumb 需要获取视频缩略图
   * @returns string 缩略图缓存地址
   */
  public static async getThumbnailPath(
    fileUri: string, thumbnailCacheFilePath: string, imageSource: image.ImageSource | undefined,
    fdSrc: media.AVFileDescriptor | undefined, metaData: MediaMetaData | undefined,
    avMetadataExtractor: media.AVMetadataExtractor | undefined, fileCategory: number,
    needVideoThumb: boolean = false): Promise<string> {
    if (await MediaThumbnailCacheUtil.hasCache(thumbnailCacheFilePath)) {
      HiLog.debugPrivate(TAG, `thumbnail has cached, fileUri:`, fileUri);
      return thumbnailCacheFilePath;
    }
    let thumbnailPath = '';
    // 各种文件类型获取缩略图的方式不一样，需区分
    switch (fileCategory) {
      case MimeType.FILE_CATEGORY_IMAGE:
        thumbnailPath = await MediaThumbnailUtil.getImageThumbnail(imageSource!!, thumbnailCacheFilePath);
        break;
      case MimeType.FILE_CATEGORY_VIDEO:
        if ((!!metaData) && (metaData.height !== 0) && needVideoThumb) {
          thumbnailPath = await MediaThumbnailUtil.getVideoCoverThumbnail(fdSrc!!, metaData, thumbnailCacheFilePath);
        }
        break;
      case MimeType.FILE_CATEGORY_AUDIO:
        thumbnailPath = await MediaThumbnailUtil.getAudioCoverThumbnail(avMetadataExtractor!!, thumbnailCacheFilePath);
        break;
      default:
        break;
    }
    return thumbnailPath;
  }

  /**
   * 释放资源
   * @param instance 资源实例
   * @param fileFd 文件fd
   * @returns void
   */
  public static async releaseSource(instance?: image.ImageSource | media.AVMetadataExtractor,
    fileFd?: number): Promise<void> {
    try {
      if (instance) {
        await instance.release();
      }
      if (fileFd) {
        await FsUtil.close(fileFd);
      }
    } catch (error) {
      HiLog.error(TAG, 'release source fail, error:' + JSON.stringify(error) + error);
    }
  }

  /**
   * 校验图片的字节数，超过一定大小则不再使用uri加载原图
   */
  public static checkImageByteSize(imageWidth: number, imageHeight: number): boolean {
    // 图片字节数计算，宽*高*4
    return (imageWidth * imageHeight * 4) < (MediaThumbnailConst.MAX_IMAGE_BYTE_SIZE * Constant.BYTE.ONE_MB);
  }



  /**
   * 设置fileInfo MetaData信息
   * @param fileInfo
   * @param metaData
   */
  public static setMetaDataForFileInfo(fileInfo: FileInfo, metaData: MediaMetaData) {
    if (FileMimeTypeUtil.isImage(fileInfo.mimeTypeObj)) {
      fileInfo.picWidth = metaData.width;
      fileInfo.picHeight = metaData.height;
    } else if (FileMimeTypeUtil.isVideo(fileInfo.mimeTypeObj)) {
      fileInfo.duration = metaData.duration;
      fileInfo.picWidth = metaData.width;
      fileInfo.picHeight = metaData.height;
    } else {
      fileInfo.duration = metaData.duration;
    }
  }
}


