/*
 * Copyright (c) 2021-2025 Huawei Device Co., Ltd.
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
import { Constant } from "../constants/Constant";
import Logger from "../log/Logger";
import { FileUtil } from "./FileUtil";
import { FsUtil } from "./FsUtil";

const TAG: string = 'FileUriUtil';

export class FileUriUtil {
  public static readonly URI_HEAD: string = 'file://';
  public static readonly DOUBLE_SLASH: string = '//';
  public static readonly URI_SEPARATOR: string = '/';

  private static cleanMultiSlash(uri: string): string {
    if (!uri) {
      Logger.w(TAG, 'null uri, do not clean');
      return '';
    }
    let tempUri: string = uri.substring(FileUriUtil.URI_HEAD.length);
    while(tempUri.indexOf(FileUriUtil.DOUBLE_SLASH) !== -1) {
      tempUri = tempUri.replaceAll(FileUriUtil.DOUBLE_SLASH, FileUriUtil.URI_SEPARATOR);
    }
    return FileUriUtil.URI_HEAD + tempUri;
  }

  public static isForbiddenVisitUri(uri: string): boolean {
    if (!uri) {
      Logger.w(TAG, 'null uri, not forbidden uri');
      return false;
    }
    const isUriExist: boolean = FsUtil.isFileExist(uri);
    if (!isUriExist || !uri.startsWith(FileUriUtil.URI_HEAD)) {
      Logger.w(TAG, 'uri not exist, forbidden visit');
      return true;
    }
    uri = FileUriUtil.cleanMultiSlash(uri);
    const defaultPath: string = FileUtil.getPathFromUri(uri).toLowerCase();
    const isSandBoxPath: boolean = defaultPath.startsWith(Constant.SANDBOX_APPDATA_PATH.toLowerCase());
    if (isSandBoxPath) {
      Logger.w(TAG, 'isSandBoxPath uri, not forbidden uri');
      return true;
    }
    const isRecentDbPath: boolean = defaultPath.startsWith(Constant.RECENT_DB_ROOT_PATH.toLowerCase());
    if (isRecentDbPath) {
      Logger.w(TAG, 'isRecentDbPath uri, not forbidden uri');
      return true;
    }
    const isTrashDbPath: boolean = defaultPath.startsWith(Constant.TRASH_DB_ROOT_PATH.toLowerCase());
    if (isTrashDbPath) {
      Logger.w(TAG, 'isTrashDbPath uri, not forbidden uri');
      return true;
    }
    const isThumbsDbPath: boolean = defaultPath.startsWith(Constant.TRASH_DB_ROOT_PATH.toLowerCase());
    if (isThumbsDbPath) {
      Logger.w(TAG, 'isThumbsDbPath uri, not forbidden uri');
      return true;
    }
    const isDesktopPath: boolean = defaultPath.startsWith(Constant.DESKTOP_ROOT_PATH.toLowerCase());
    if (isDesktopPath) {
      Logger.w(TAG, 'isDesktopPath uri, not forbidden uri');
      return true;
    }
    return false;
  }

  public static trustedUriExt(fileUri: string): boolean {
    if (fileUri == null || fileUri.length === 0) {
      return true; // 允许空路径
    }
    if (fileUri.includes('./') || fileUri.includes('../') || fileUri.includes('.\\.\\') || fileUri.includes('%00')) {
      Logger.e(TAG, 'file path can not contains ./、 ../、 .\\.\\、 %00');
      return false;
    }
    return true;
  }
}