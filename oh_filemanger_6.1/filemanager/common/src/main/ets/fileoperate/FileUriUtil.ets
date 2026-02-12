/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import { Constant } from '../const/Constant';
import { ShieldUri, VirtualUri } from '../const/FolderRecord';
import { HiLog } from '../dfx/HiLog';
import { FsUtil } from '../utils/FsUtil';
import { ObjectUtil } from '../utils/ObjectUtil';
import { StringUtil } from '../utils/StringUtil';
import { FileUtil } from './FileUtil';

const TAG: string = 'FileUriUtil';

export class FileUriUtil {
  public static readonly URI_HEAD: string = 'file://';
  public static readonly DOUBLE_SLASH: string = '//';
  public static readonly URI_SEPARATOR: string = '/';

  /**
   * 检查uri是否来自桌面
   * @param uri 文件uri
   * @returns 检查结果
   */
  public static isUriFromDesktop(uri: string): boolean {
    if (ObjectUtil.isNullOrUndefined(uri) || StringUtil.isEmpty(uri)) {
      HiLog.warn(TAG, `empty file uri from desktop`);
      return false;
    }
    return uri.startsWith(`${VirtualUri.DESKTOP}/`);
  }

  /**
   * 检查是否为隐藏目录的URI
   * @param uri 参与判断的uri信息
   * @returns 判断结果
   */
  public static isHiddenDirUri(uri: string): boolean {
    if (ObjectUtil.isNullOrUndefined(uri) || StringUtil.isEmpty(uri)) {
      HiLog.warn(TAG, 'isHiddenDirUri, invalid uri');
      return false;
    }
    const isShowAppData = AppStorage.get<boolean>('isShowUserDataCheck');
    const CONVERTED_URI: string = uri.toLowerCase();
    const CONVERTED_RECENT_FOLDER_URI: string = `${VirtualUri.MY_PC}/${Constant.RECENT_FOLDER}`.toLowerCase();
    const CONVERTED_TRASH_FOLDER_URI: string = `${VirtualUri.MY_PC}/${Constant.TRASH_FOLDER}`.toLowerCase();
    const CONVERTED_THUMBS_FOLDER_URI: string = `${VirtualUri.MY_PC}/${Constant.THUMBS_FOLDER}`.toLowerCase();
    const CONVERTED_PC_ENGINE_FOLDER_URI: string = `${VirtualUri.MY_PC}/${Constant.PC_ENGINE_FOLDER}`.toLowerCase();
    const CONVERTED_PC_FILE_MANAGER_URI: string = `${ShieldUri.FILE_MANAGER}`.toLowerCase();
    const CONVERTED_PC_APP_DATA_URI: string = `${ShieldUri.APP_DATA}`.toLowerCase();
    return CONVERTED_URI === CONVERTED_RECENT_FOLDER_URI || CONVERTED_URI === CONVERTED_TRASH_FOLDER_URI ||
      CONVERTED_URI === CONVERTED_THUMBS_FOLDER_URI || CONVERTED_URI === CONVERTED_PC_ENGINE_FOLDER_URI ||
      CONVERTED_URI === CONVERTED_PC_FILE_MANAGER_URI ||
      (!isShowAppData && CONVERTED_URI === CONVERTED_PC_APP_DATA_URI);
  }

  /**
   * 判断是否为禁止访问的uri
   * @param uri 判断对象
   * @returns 判断结果
   */
  public static isForbiddenVisitUri(uri: string): boolean {
    if (!uri) {
      HiLog.warn(TAG, 'null uri, not forbid');
      return false;
    }
    const isUriExist: boolean = FsUtil.isFileExist(uri);
    if (!isUriExist || !uri.startsWith(FileUriUtil.URI_HEAD)) {
      HiLog.warn(TAG, 'uri not exist, forbid visit');
      return true;
    }
    uri = FileUriUtil.cleanMultiSlash(uri);
    const defaultPickerPath: string = FileUtil.getPathFromUri(uri).toLowerCase();
    const isSandBoxPath: boolean = defaultPickerPath.startsWith(Constant.SANDBOX_APPDATA_PATH.toLowerCase());
    const isRecentDbPath: boolean = defaultPickerPath.startsWith(Constant.RECENT_DB_ROOT_PATH.toLowerCase());
    const isTrashDbPath: boolean = defaultPickerPath.startsWith(Constant.TRASH_DB_ROOT_PATH.toLowerCase());
    const isThumbsDbPath: boolean = defaultPickerPath.startsWith(Constant.THUMBS_DB_ROOT_PATH.toLowerCase());
    const isDesktopPath: boolean = defaultPickerPath.startsWith(Constant.DESKTOP_ROOT_PATH.toLowerCase());
    const verifyRes: boolean =
      isSandBoxPath || isRecentDbPath || isTrashDbPath || isThumbsDbPath || isDesktopPath;
    HiLog.info(TAG, `isForbiddenPickerUri verifyRes:${verifyRes}`);
    return verifyRes;
  }

  /**
   * 清理uri中的多余斜杠
   * @param uri 清理对象
   * @returns 清理结果
   */
  private static cleanMultiSlash(uri: string): string {
    if (!uri) {
      HiLog.warn(TAG, 'null uri, not clean slash');
      return '';
    }
    let tmpUri: string = uri.substring(FileUriUtil.URI_HEAD.length);
    while (tmpUri.indexOf(FileUriUtil.DOUBLE_SLASH) !== -1) {
      tmpUri = tmpUri.replaceAll(FileUriUtil.DOUBLE_SLASH, FileUriUtil.URI_SEPARATOR);
    }
    return FileUriUtil.URI_HEAD + tmpUri;
  }
}
