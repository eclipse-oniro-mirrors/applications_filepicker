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

import type { FileInfo } from '../fileoperate/FileInfo';
import type { MediaMetaData } from './MediaMetaData';
import { HiLog } from '../dfx/HiLog';
import { StringUtil } from '../utils/StringUtil';

const TAG = 'VideoThumbnailSupportUtil';

/**
 * 视频缩略图格式预判工具。
 * 在入队抽帧前识别系统 AVImageGenerator 难以稳定支持的容器/编码，
 * 直接保留默认视频图标，避免无效任务占用解码器与调度队列。
 */
export class VideoThumbnailSupportUtil {
  /** 扩展名黑名单：实测抽帧失败或元数据异常（如 FLV height=0） */
  private static readonly UNSUPPORTED_EXTENSIONS: string[] = ['.flv', '.asf', '.wmv', '.webm'];
  /** 容器 mime 异常值 */
  private static readonly UNSUPPORTED_MIME_TYPES: string[] = ['invalid'];
  /** 视频轨编码黑名单：VP9、WMV/ASF 系列等 */
  private static readonly UNSUPPORTED_CODEC_MIMES: string[] = [
    'video/vp9',
    'video/x-vp9',
    'video/wmv3',
    'video/x-ms-wmv',
    'video/x-ms-asf'
  ];

  /**
   * 从文件名解析小写扩展名（含点号，如 .mp4）。
   */
  static getFileExtension(fileName: string): string {
    if (StringUtil.isEmpty(fileName)) {
      return '';
    }
    const dotIndex = fileName.lastIndexOf('.');
    if (dotIndex < 0) {
      return '';
    }
    return fileName.substring(dotIndex).toLowerCase();
  }

  /**
   * 仅按扩展名快速拦截，用于调度器入队前，避免打开文件与创建 AV 实例。
   */
  static shouldSkipByExtension(fileInfo: FileInfo): boolean {
    const extension = VideoThumbnailSupportUtil.getFileExtension(fileInfo?.fileName ?? '');
    return VideoThumbnailSupportUtil.UNSUPPORTED_EXTENSIONS.includes(extension);
  }

  /**
   * 结合元数据做完整预判（扩展名、尺寸、mime、codec）。
   * @param fileInfo 可选，用于扩展名二次校验
   */
  static shouldSkipVideoThumbnail(metaData: MediaMetaData, fileInfo?: FileInfo): boolean {
    if (fileInfo && VideoThumbnailSupportUtil.shouldSkipByExtension(fileInfo)) {
      HiLog.info(TAG, `skip video thumbnail by extension, file=${fileInfo.fileName}`);
      return true;
    }
    if (!metaData || metaData.height <= 0 || metaData.width <= 0) {
      HiLog.info(TAG, `skip video thumbnail by invalid size, height=${metaData?.height}, width=${metaData?.width}`);
      return true;
    }
    const mimeType = (metaData.mimeType ?? '').toLowerCase();
    if (StringUtil.isEmpty(mimeType) || VideoThumbnailSupportUtil.UNSUPPORTED_MIME_TYPES.includes(mimeType)) {
      HiLog.info(TAG, `skip video thumbnail by mimeType=${mimeType}`);
      return true;
    }
    const codecMime = (metaData.codecMime ?? '').toLowerCase();
    if (!StringUtil.isEmpty(codecMime) &&
      VideoThumbnailSupportUtil.UNSUPPORTED_CODEC_MIMES.includes(codecMime)) {
      HiLog.info(TAG, `skip video thumbnail by codecMime=${codecMime}`);
      return true;
    }
    return false;
  }

  /**
   * 是否为 HEVC/H.265，用于选择更保守的抽帧分辨率。
   */
  static isHevcVideo(metaData: MediaMetaData): boolean {
    const codecMime = (metaData.codecMime ?? '').toLowerCase();
    return codecMime === 'video/hevc' || codecMime === 'video/h265';
  }
}
