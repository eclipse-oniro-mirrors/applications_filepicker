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

/**
 * 媒体文件的元数据的数据模型
 */
export class MediaMetaData {
  /**
   * 音视频时长
   */
  duration: number = 0;
  /**
   * 文件类型
   */
  mimeType: string = '';
  /**
   * 视频的宽
   */
  height: number = 0;
  /**
   * 视频的高
   */
  width: number = 0;
  /**
   * 缩略图的缓存地址
   */
  thumbnailPath: string = '';

  constructor() {
  }
}