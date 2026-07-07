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

@Sendable
export class MimeType {
  /**
   * 文件大分类：图片
   */
  public static FILE_CATEGORY_IMAGE: number = 1;
  /**
   * 文件大分类：视频
   */
  public static FILE_CATEGORY_VIDEO: number = 2;
  /**
   * 文件大分类：音频
   */
  public static FILE_CATEGORY_AUDIO: number = 3;
  /**
   * 文件大分类：文档
   */
  public static FILE_CATEGORY_TXT: number = 4;
  /**
   * 文件大分类：压缩包
   */
  public static FILE_CATEGORY_ZIP: number = 5;
  /**
   * 文件大分类：APK
   */
  public static FILE_CATEGORY_PKG: number = 6;
  /**
   * 文件大分类：未知
   */
  public static FILE_CATEGORY_UNKNOWN: number = 7;
  /**
   * 文件后缀对应的整形定义，用于文件的大分类
   */
  public fileCategory: number;
  /**
   * 文件后缀对应的整形定义，用于文件细分的类型
   */
  public fileTypeSort: number;
  /**
   * 文件细分的类型对应的默认图标
   */
  public fileResType: string;
  /**
   * 文件的mimetype
   */
  public mimeType: string;
  /**
   * 文件后缀
   */
  public extension: string;

  constructor(extension: string, fileCategory: number, fileTypeSort: number, fileResType: string, mimeType: string) {
    this.extension = extension;
    this.fileCategory = fileCategory;
    this.fileTypeSort = fileTypeSort;
    this.fileResType = fileResType;
    this.mimeType = mimeType;
  }
}