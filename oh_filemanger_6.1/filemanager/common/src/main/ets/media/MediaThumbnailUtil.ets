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

import { StringUtil } from '../utils/StringUtil';
import { HiLog } from '../dfx/HiLog';
import { MediaThumbnailConst } from './MediaThumbnailConst';
import { MediaThumbnailCacheUtil } from './MediaThumbnailCacheUtil';
import image from '@ohos.multimedia.image';
import media from '@ohos.multimedia.media';
import type { MediaMetaData } from './MediaMetaData';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'MediaThumbnailUtil';

/**
 * 缩略图工具类
 */
export class MediaThumbnailUtil {
  /**
   * 获取原始文件对应缩略图文件的路径
   * @param fileUri 文件uri
   * @param modifiedTime 文件更新时间
   * @param size 文件大小
   * @param storageDeviceUID 存储设备UID
   * @returns string 完整的缩略图缓存路径
   */
  public static async getThumbnailCacheFilePath(cacheFileName: string,
    storageDeviceUID: string | number,
    customThumbPath: string = ''): Promise<string> {
    const folderPath =
      StringUtil.isEmpty(customThumbPath) ? MediaThumbnailCacheUtil.getCacheFolderPath(storageDeviceUID) :
        customThumbPath;
    if (StringUtil.isEmpty(folderPath)) {
      HiLog.warn(TAG, 'getThumbnailCacheFilePath fail, folderPath is empty');
      return '';
    }
    return folderPath + cacheFileName + MediaThumbnailConst.CURRENT_FILE_SUFFIX;
  }

  /**
   * 获取图片的缩略图并缓存
   * @param imageSource 图片源实例
   * @param cacheFilePath 缩略图缓存路径
   * @returns string 缓存成功的缩略图地址
   */
  public static async getImageThumbnail(imageSource: image.ImageSource, cacheFilePath: string): Promise<string> {
    let cacheFilePathResult = '';
    try {
      const pixelMap = await MediaThumbnailUtil.processPixelMap(imageSource);
      const cacheResult = await MediaThumbnailCacheUtil.cacheThumbnail(pixelMap, cacheFilePath);
      if (cacheResult) {
        cacheFilePathResult = cacheFilePath;
      }
    } catch (error) {
      HiLog.error(TAG, 'getImageThumbnail fail, error:' + JSON.stringify(error) + error);
    }
    return cacheFilePathResult;
  }

  /**
   * 获取音频的封面
   * @param avMetadataExtractor 元数据获取类实例
   * @param cacheFilePath 封面缓存路径
   * @returns string 封面缓存地址
   */
  public static async getAudioCoverThumbnail(avMetadataExtractor: media.AVMetadataExtractor,
                                             cacheFilePath: string): Promise<string> {
    let cacheFilePathResult = '';
    try {
      let pixelMap = await avMetadataExtractor.fetchAlbumCover();
      const imageSource = await MediaThumbnailUtil.convertPixelMap2ImageSource(pixelMap);
      pixelMap = await MediaThumbnailUtil.processPixelMap(imageSource);
      const cacheResult = await MediaThumbnailCacheUtil.cacheThumbnail(pixelMap, cacheFilePath);
      if (cacheResult) {
        cacheFilePathResult = cacheFilePath;
      }
    } catch (error) {
      HiLog.error(TAG, 'getAudioCoverThumbNail fail, error:' + JSON.stringify(error) + error);
    }
    return cacheFilePathResult;
  }

  /**
   * 获取视频的封面
   * @param fdSrc 文件的fd、size等信息
   * @param mediaMetaData 视频的元数据
   * @param cacheFilePath 缩略图的缓存路径
   * @returns string 封面缓存地址
   */
  public static async getVideoCoverThumbnail(fdSrc: media.AVFileDescriptor, mediaMetaData: MediaMetaData,
                                             cacheFilePath: string): Promise<string> {
    let cacheFilePathResult = '';
    let avImageGenerator: media.AVImageGenerator | undefined;
    try {
      avImageGenerator = await media.createAVImageGenerator();
      avImageGenerator.fdSrc = fdSrc;
      // 视频的封面按宽高比1：1展示，colorFormat：media.PixelFormat.RGBA_8888
      const coverParam: media.PixelMapParams = {
        width: mediaMetaData.width,
        height: mediaMetaData.height,
        colorFormat: media.PixelFormat.RGBA_8888
      };
      const timeUs = 0;
      const options = 0;
      // 获取视频的第一帧作为封面
      let pixelMap = await avImageGenerator.fetchFrameByTime(timeUs, options, coverParam);

      const imageSource = await MediaThumbnailUtil.convertPixelMap2ImageSource(pixelMap);
      pixelMap = await MediaThumbnailUtil.processPixelMap(imageSource, true);
      const cacheResult = await MediaThumbnailCacheUtil.cacheThumbnail(pixelMap, cacheFilePath);
      if (cacheResult) {
        cacheFilePathResult = cacheFilePath;
      }
    } catch (error) {
      HiLog.error(TAG, `getVideoCoverThumbNail fail, error: ${(error as BusinessError)?.code}`);
    } finally {
      MediaThumbnailUtil.releaseSource(avImageGenerator);
    }
    return cacheFilePathResult;
  }


  /**
   * 根据imageSource将图片加工成缩略图
   * @param imageSource 图片源实例
   * @param isVideoCover 是否为视频封面
   * @returns PixelMap 缩略图PixelMap
   */
  private static async processPixelMap(imageSource: image.ImageSource,
    isVideoCover: boolean = false): Promise<PixelMap> {
    let resultPixelMap: PixelMap | undefined;
    try {
      const imageInfo = await imageSource.getImageInfo();
      // 目标缩略图的宽高尺寸
      let desiredSizeWidth = MediaThumbnailConst.THUMBNAIL_SIZE;
      let desiredSizeHeight = MediaThumbnailConst.THUMBNAIL_SIZE;
      // 保持原图的宽高比等比缩小
      if (imageInfo.size.width > imageInfo.size.height) {
        desiredSizeWidth = imageInfo.size.width / imageInfo.size.height * desiredSizeHeight;
      } else {
        desiredSizeHeight = imageInfo.size.height / imageInfo.size.width * desiredSizeWidth;
      }
      // 构建图片解码参数
      const decodingOptions: image.DecodingOptions = {
        sampleSize: 1,
        editable: true,
        desiredSize: {
          width: desiredSizeWidth,
          height: desiredSizeHeight
        },
        desiredPixelFormat: image.PixelMapFormat.RGBA_8888
      };
      HiLog.debug(TAG, 'processPixelMap decodingOptions:' + JSON.stringify(decodingOptions));
      resultPixelMap = await imageSource.createPixelMap(decodingOptions);

      // 从缩略图上截取的指定区域的起始点（左上角坐标0，0）
      let cropRegionX = 0;
      let cropRegionY = 0;
      // 从缩略图上截取的指定区域的大小
      let cropRegionWidth = desiredSizeWidth;
      let cropRegionHeight = desiredSizeHeight;
      if (isVideoCover) {
        // 视频封面宽高按照1:1截取中间部分
        if (desiredSizeHeight > desiredSizeWidth) {
          cropRegionHeight = cropRegionWidth;
          cropRegionY = (desiredSizeHeight - cropRegionHeight) / 2;
        } else {
          cropRegionWidth = cropRegionHeight;
          cropRegionX = (desiredSizeWidth - cropRegionWidth) / 2;
        }
      } else {
        // 其他图片保持原始宽高比，当宽高比大于16/9或小于9/16时按照16/9和9/16截取，横图截取中间部分，竖图截取上半部分
        if ((desiredSizeWidth / desiredSizeHeight) > MediaThumbnailConst.MAX_IMAGE_ASPECT_RATIO) {
          // 水平长图
          cropRegionWidth = cropRegionHeight * MediaThumbnailConst.MAX_IMAGE_ASPECT_RATIO;
          cropRegionX = (desiredSizeWidth - cropRegionWidth) / 2;
        } else if ((desiredSizeHeight / desiredSizeWidth) > MediaThumbnailConst.MAX_IMAGE_ASPECT_RATIO) {
          // 垂直长图
          cropRegionHeight = cropRegionWidth * MediaThumbnailConst.MAX_IMAGE_ASPECT_RATIO;
        }
      }
      const cropRegion: image.Region = {
        x: cropRegionX,
        y: cropRegionY,
        size: {
          width: cropRegionWidth,
          height: cropRegionHeight
        }
      };
      HiLog.debug(TAG, 'processPixelMap cropRegion:' + JSON.stringify(cropRegion));
      await resultPixelMap.crop(cropRegion);
      return resultPixelMap;
    } catch (error) {
      HiLog.error(TAG, 'processPixelMap fail, error:' + JSON.stringify(error) + error);
      throw new Error(JSON.stringify(error));
    } finally {
      await MediaThumbnailUtil.releaseSource(imageSource);
    }
  }

  /**
   * 将pixelMap转换成图片源
   * @param pixelMap 通过其他方式获取到的pixelMap
   * @returns ImageSource 图片源
   */
  private static async convertPixelMap2ImageSource(pixelMap: PixelMap): Promise<image.ImageSource> {
    let imageSource: image.ImageSource | undefined;
    let imagePacker: image.ImagePacker | undefined;
    try {
      const imageInfo: image.ImageInfo = await pixelMap.getImageInfo();
      imagePacker = image.createImagePacker();
      const packOpts: image.PackingOption = {
        format: MediaThumbnailConst.CURRENT_MIME_TYPE,
        quality: 100
      };
      const arrayBuffer = await imagePacker.packing(pixelMap, packOpts);
      const sourceOpts: image.SourceOptions = {
        sourceDensity: 0,
        sourcePixelFormat: image.PixelMapFormat.RGBA_8888,
        sourceSize: imageInfo.size
      };
      imageSource = image.createImageSource(arrayBuffer, sourceOpts);
      return imageSource;
    } catch (error) {
      HiLog.error(TAG, 'convertPixelMap2ImageSource fail, error:' + JSON.stringify(error) + error);
      throw new Error(JSON.stringify(error));
    } finally {
      await MediaThumbnailUtil.releaseSource(imagePacker);
    }
  }

  /**
   * 为缩略图的缓存路径添加前缀
   * @param cacheFilePath 缩略图的缓存路径
   * @returns 完整的缩略图缓存地址
   */
  public static getFullThumbnailCachePath(cacheFilePath: string): string {
    if (StringUtil.isEmpty(cacheFilePath)) {
      return '';
    }
    return MediaThumbnailConst.THUMBNAIL_CACHE_PATH_PREFIX + cacheFilePath;
  }


  /**
   * 释放资源
   * @param instance 资源实例
   */
  public static async releaseSource(instance?: media.AVImageGenerator | image.ImageSource |
    image.ImagePacker): Promise<void> {
    // 释放资源
    try {
      if (instance) {
        await instance.release();
      }
    } catch (error) {
      HiLog.error(TAG, 'release source fail, error:' + JSON.stringify(error) + error);
    }
  }
}
