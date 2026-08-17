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

const TAG = 'ThumbnailConst';

/**
 * 缩略图文件的类型
 */
enum THUMBNAIL_MIME_TYPE {
  JPG = 'image/jpeg',
  PNG = 'image/png',
  WEBP = 'image/webp'
}

/**
 * 缩略图的文件后缀
 */
enum THUMBNAIL_SUFFIX {
  JPG = '.jpg',
  PNG = '.png',
  WEBP = '.webp'
}

/**
 * 缩略图的质量
 */
enum THUMBNAIL_QUALITY {
  HIGH = 98,
  MIDDLE = 90,
  LOW = 80
}

export class MediaThumbnailConst {
  /**
   * 当前缩略图的文件后缀：jpg
   */
  public static readonly CURRENT_FILE_SUFFIX = THUMBNAIL_SUFFIX.JPG;
  /**
   * 当前缩略图的文件类型：jpg
   */
  public static readonly CURRENT_MIME_TYPE = THUMBNAIL_MIME_TYPE.JPG;
  /**
   * 当前缩略图的质量：中
   */
  public static readonly CURRENT_QUALITY = THUMBNAIL_QUALITY.MIDDLE;
  /**
   * 图片的最大宽高比：16:9或9:16
   */
  public static readonly MAX_IMAGE_ASPECT_RATIO: number = 16 / 9;
  /**
   * 缩略图大小：200x200
   */
  public static readonly THUMBNAIL_SIZE: number = 200;
  /**
   * 默认的存储设备UID：本地存储
   */
  public static readonly DEFAULT_STORAGE_DEVICE_UID: string = 'localDevice';
  /**
   * 缩略图缓存的目录名
   */
  public static readonly THUMBNAIL_CACHE_FOLDER_NAME: string = 'thumbnail';
  /**
   * 缩略图缓存地址前缀，image加载缩略图时需要
   */
  public static readonly THUMBNAIL_CACHE_PATH_PREFIX: string = 'file://';
  /**
   * 最大并发任务数（视频缩略图调度器与 AV 抽帧共用此上限）
   */
  public static readonly MAX_CONCURRENT_TASK_NUM: number = 2;
  /**
   * 列表项可见比例阈值：超过后以 HIGH 优先级触发本地视频缩略图加载
   */
  public static readonly THUMBNAIL_VISIBLE_MIN_RATIO: number = 0.01;
  /**
   * 普通视频首次抽帧长边上限（像素）。
   * 不按原片分辨率抽帧，降低解码压力；最终仍裁成 THUMBNAIL_SIZE 展示。
   */
  public static readonly VIDEO_THUMBNAIL_FETCH_MAX_EDGE: number = 400;
  /**
   * HEVC 首次抽帧长边上限（比普清更保守，减少 5400106）
   */
  public static readonly VIDEO_THUMBNAIL_FETCH_HEVC_MAX_EDGE: number = 320;
  /**
   * 抽帧失败（5400106）后重试时的长边上限
   */
  public static readonly VIDEO_THUMBNAIL_FETCH_RETRY_MAX_EDGE: number = 240;
  /**
   * 最长任务队列
   */
  public static readonly MAX_LONG_TASK_QUEUES: number = 50;
  /**
   * 图片最大字节数20M
   */
  public static readonly MAX_IMAGE_BYTE_SIZE: number = 20;
}

