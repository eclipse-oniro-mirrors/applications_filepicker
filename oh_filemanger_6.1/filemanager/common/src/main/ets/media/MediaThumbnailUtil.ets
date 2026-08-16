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
import { VideoThumbnailSupportUtil } from './VideoThumbnailSupportUtil';

const TAG = 'MediaThumbnailUtil';
/** AVImageGenerator.fetchFrameByTime 抽帧失败（规格不支持或解码过载） */
const FETCH_FRAME_FAILED_CODE = 5400106;

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
   * 获取视频的封面。
   * 优化策略：按长边降分辨率抽帧（减轻 HEVC 等高码率解码压力），
   * 首次失败（5400106）后延迟并以更小尺寸重试一次。
   */
  public static async getVideoCoverThumbnail(fdSrc: media.AVFileDescriptor, mediaMetaData: MediaMetaData,
                                             cacheFilePath: string): Promise<string> {
    let cacheFilePathResult = '';
    let avImageGenerator: media.AVImageGenerator | undefined;
    try {
      avImageGenerator = await media.createAVImageGenerator();
      avImageGenerator.fdSrc = fdSrc;
      const isHevc = VideoThumbnailSupportUtil.isHevcVideo(mediaMetaData);
      const firstMaxEdge = isHevc ?
        MediaThumbnailConst.VIDEO_THUMBNAIL_FETCH_HEVC_MAX_EDGE :
        MediaThumbnailConst.VIDEO_THUMBNAIL_FETCH_MAX_EDGE;
      const coverParam = MediaThumbnailUtil.buildVideoCoverParams(mediaMetaData, firstMaxEdge);
      cacheFilePathResult = await MediaThumbnailUtil.fetchAndCacheVideoCover(
        avImageGenerator, coverParam, cacheFilePath);
      if (!StringUtil.isEmpty(cacheFilePathResult)) {
        return cacheFilePathResult;
      }
      // 首次抽帧失败，等待解码器释放后以更保守的尺寸重试
      await MediaThumbnailUtil.delay(400);
      const retryMaxEdge = isHevc ?
        Math.min(MediaThumbnailConst.VIDEO_THUMBNAIL_FETCH_RETRY_MAX_EDGE, 200) :
        MediaThumbnailConst.VIDEO_THUMBNAIL_FETCH_RETRY_MAX_EDGE;
      const retryParam = MediaThumbnailUtil.buildVideoCoverParams(mediaMetaData, retryMaxEdge);
      cacheFilePathResult = await MediaThumbnailUtil.fetchAndCacheVideoCover(
        avImageGenerator, retryParam, cacheFilePath);
    } catch (error) {
      HiLog.error(TAG, `getVideoCoverThumbNail fail, error: ${(error as BusinessError)?.code}`);
    } finally {
      MediaThumbnailUtil.releaseSource(avImageGenerator);
    }
    return cacheFilePathResult;
  }

  /**
   * 将原片宽高按比例缩放到长边不超过 maxEdge，供 fetchFrameByTime 使用。
   * 最终展示尺寸仍由 processPixelMap 裁成 THUMBNAIL_SIZE。
   */
  private static buildVideoCoverParams(mediaMetaData: MediaMetaData, maxEdge: number): media.PixelMapParams {
    let width = mediaMetaData.width > 0 ? mediaMetaData.width : MediaThumbnailConst.THUMBNAIL_SIZE;
    let height = mediaMetaData.height > 0 ? mediaMetaData.height : MediaThumbnailConst.THUMBNAIL_SIZE;
    const longEdge = Math.max(width, height);
    if (longEdge > maxEdge) {
      const scale = maxEdge / longEdge;
      width = Math.max(16, Math.round(width * scale));
      height = Math.max(16, Math.round(height * scale));
    }
    return {
      width: width,
      height: height,
      colorFormat: media.PixelFormat.RGBA_8888
    };
  }

  /**
   * 抽取单帧并写入缩略图缓存。
   * 5400106 仅记录告警并返回空串，由上层触发重试；其他错误向上抛出。
   */
  private static async fetchAndCacheVideoCover(avImageGenerator: media.AVImageGenerator,
                                               coverParam: media.PixelMapParams,
                                               cacheFilePath: string): Promise<string> {
    const timeUs = 0;
    const options = 0;
    try {
      let pixelMap = await avImageGenerator.fetchFrameByTime(timeUs, options, coverParam);
      const imageSource = await MediaThumbnailUtil.convertPixelMap2ImageSource(pixelMap);
      pixelMap = await MediaThumbnailUtil.processPixelMap(imageSource, true);
      const cacheResult = await MediaThumbnailCacheUtil.cacheThumbnail(pixelMap, cacheFilePath);
      if (cacheResult) {
        return cacheFilePath;
      }
    } catch (error) {
      const errorCode = (error as BusinessError)?.code;
      if (errorCode === FETCH_FRAME_FAILED_CODE) {
        HiLog.warn(TAG, `fetchFrameByTime retry later, size=${coverParam.width}x${coverParam.height}`);
      } else {
        HiLog.error(TAG, `fetchFrameByTime fail, error: ${errorCode}`);
        throw error as Error;
      }
    }
    return '';
  }

  /** 抽帧重试前的短暂等待，避免与元数据任务争抢解码器 */
  private static delay(ms: number): Promise<void> {
    return new Promise((resolve) => {
      setTimeout(resolve, ms);
    });
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
   * 将pixelMap转换成图片源。
   * packing 完成后会释放输入 pixelMap（数据已拷贝到 arrayBuffer）；返回的 ImageSource 由下游 processPixelMap 负责释放。
   * @param pixelMap 通过其他方式获取到的pixelMap（本方法结束后所有权结束，调用方勿再使用）
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
      // packing 已完成（或失败），输入 PixelMap 不再需要，及时释放避免音视频缩略图路径泄漏
      try {
        await pixelMap.release();
      } catch (releaseError) {
        HiLog.error(TAG, 'release input pixelMap fail, error:' + JSON.stringify(releaseError) + releaseError);
      }
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
