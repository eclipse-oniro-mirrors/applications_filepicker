/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import { OperateFileResult } from '../const/ErrorCode';
import type { FileInfo } from './FileInfo';
import { HiLog } from '../dfx/HiLog';
import { Constant } from '../const/Constant';

const TAG: string = 'RenameUtil';

export class RenameUtil {

  public static renameFileNameCheck(inputText: string, fileInfo: FileInfo): number {
    HiLog.infoPrivate(TAG, ' renameFunc begin', `inputText ${inputText}, fileInfo.fileName: ${fileInfo.fileName}`);
    // 判断是否为空
    if (inputText.length <= 0) {
      return OperateFileResult.EXIT_RENAME;
    }

    if (RenameUtil.isOneOrTwoDots(inputText)) {
      return OperateFileResult.FILE_EXISTS;
    }

    if (RenameUtil.isAllSpace(inputText)) {
      return OperateFileResult.ALL_IS_SPACE;
    }

    if (RenameUtil.checkSpecialChar(inputText)) {
      HiLog.info(TAG, 'Contains special characters');
      return OperateFileResult.CONTAIN_SPECIAL_CHARACTER;
    }

    HiLog.infoPrivate(TAG,
      `renameFunc end`, `inputText:${inputText}, fileName:${fileInfo.fileName}, lastIndexOfDot:${inputText.lastIndexOf('.')}`);
    if (RenameUtil.checkSameName(inputText, fileInfo.fileName) || RenameUtil.checkOnlyExtension(inputText)) {
      return OperateFileResult.EXIT_RENAME;
    }
    if (RenameUtil.checkFileExtensionChange(inputText, fileInfo)) {
      HiLog.info(TAG, 'FileExtension Changed');
      return OperateFileResult.FILE_EXTENSION_CHANGE;
    }
    return OperateFileResult.NORMAL_RESULT;
  }

  /**
   * 判断文件名是否都是空格
   * @param inputText
   * @returns 判断结果
   */
  public static isAllSpace(inputText: string): boolean {
    for (let i = 0; i < inputText.length; ++i) {
      if (inputText[i] !== ' ') {
        return false;
      }
    }
    return true;
  }

  /**
   * 判断文件名是否都是由.组成
   * @param inputText
   * @returns 判断结果
   */
  public static isAllDots(inputText: string): boolean {
    for (let i = 0; i < inputText.length; ++i) {
      if (inputText[i] !== '.') {
        return false;
      }
    }
    return true;
  }

  /**
   * 判断字符串是否为 . 或 ..
   * @param inputText 判断对象
   * @returns 判断结果
   */
  public static isOneOrTwoDots(inputText: string): boolean {
    return inputText === '.' || inputText === '..';
  }

  /**
   * 移除末尾的 .
   *
   * @param inputText
   * @returns
   */
  public static rmUnExpectDot(inputText: string): string {
    const isAllDots: boolean = RenameUtil.isAllDots(inputText);
    while (!isAllDots && inputText && inputText.lastIndexOf('.') === inputText.length - 1) {
      inputText = inputText.substring(0, inputText.length - 1);
    }
    return inputText;
  }

  /**
   * 检查原文件名称和输入名称是否一致
   * @param inputText
   * @param fileName
   * @returns
   */
  public static checkSameName(inputText: string, fileName: string): boolean {
    if (fileName === inputText) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * 检查是否只有文件后缀
   *
   * @param inputText
   * @returns
   */
  public static checkOnlyExtension(inputText: string, isFile: boolean = true): boolean {
    if (!isFile) {
      return false;
    }
    if (inputText.lastIndexOf('.') === 0) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * 获取替换特殊字符后的文件名
   * @param srcFileName 文件名
   * @returns
   */
  public static getEscapedFileName(srcFileName: string): string {
    const pos = srcFileName.lastIndexOf('.');
    if (pos >= 0) {
      const fileName = srcFileName.substring(0, pos);
      let fileType = srcFileName.substring(pos + 1);
      return fileName.replace(Constant.SPECIAL_CHARACTER_REGEXP, Constant.SPECIAL_CHARACTER_REPLACE_CHARACTER) + '.' +
        fileType.replace(Constant.SPECIAL_CHARACTER_REGEXP, Constant.SPECIAL_CHARACTER_REPLACE_CHARACTER);
    }
    return srcFileName.replace(Constant.SPECIAL_CHARACTER_REGEXP, Constant.SPECIAL_CHARACTER_REPLACE_CHARACTER);
  }

  /**
   * 获取替换特殊字符后的文件夹名
   * @param folderName 文件夹名
   * @returns
   */
  public static getEscapedFolderName(folderName: string): string {
    return folderName.replace(Constant.SPECIAL_CHARACTER_REGEXP, Constant.SPECIAL_CHARACTER_REPLACE_CHARACTER);
  }

  /**
   * 检查特殊字符
   *
   * @param inputText
   * @returns 包含特殊字符
   */
  public static checkSpecialChar(inputText: string): boolean {
    return !Constant.FILENAME_REGEXP.test(inputText);
  }

  /**
   * 检查图库文件特殊字符
   *
   * @param inputText
   * @returns 包含特殊字符
   */
  public static checkGallerySpecialChar(inputText: string): boolean {
    return Constant.GALLERY_FILENAME_REGEXP.test(inputText);
  }

  /**
   * 检查是否更改后缀
   *
   * @param inputText
   * @param fileInfo
   * @returns
   */
  public static checkFileExtensionChange(inputText: string, fileInfo: FileInfo): boolean {
    if (!fileInfo.isFolder) {
      if ((fileInfo.fileName.lastIndexOf('.') !== -1) &&
        (fileInfo.fileName.split('.').pop() !== inputText.split('.').pop())) {
        return true;
      }
    }
    return false;
  }
}