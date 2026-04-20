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

import { VirtualUri } from '../const/FolderRecord';
import { HiLog } from '../dfx/HiLog';
import lazy { FsUtil } from './FsUtil';
import { ObjectUtil } from './ObjectUtil';
import { StringUtil } from './StringUtil';
import { ArrayUtil } from './ArrayUtil';
import { FileUriUtil } from '../fileoperate/FileUriUtil';
import { Constant } from '../const/Constant';
import { toast } from './Tools';

const TAG: string = 'AssertExtUtil'
/**
 * 外部数据校验工具类
 */
export class AssertExtUtil {
  /**
   * 路径是否可信，防止路径注入
   * @param uri
   * @param error
   * @returns
   */
  public static checkUriTrusted(uri: string): string {
    let errorRes = '';
    if (!AssertExtUtil.trustedPathExt(uri)) {
      errorRes = ' uri is Untrusted'
    }
    return errorRes;
  }

  /**
   * 路径是否可信，防止跳转进入到不可见路径
   *
   * @param uri 文件路径uri
   * @param sandBoxFlag 是否沙箱路径
   * @returns
   */
  public static checkIsForbiddenUri(uri: string, sandBoxFlag: boolean = false): boolean {
    if (typeof uri !== 'string' || StringUtil.isEmpty(uri)) {
      HiLog.error(TAG, 'param uri is invalid');
      return true;
    }
    if (uri === VirtualUri.GALLERY || uri?.startsWith(VirtualUri.GALLERY_URI)) {
      HiLog.info(TAG, 'is open gallery');
      return false;
    }

    if (FileUriUtil.isForbiddenVisitUri(uri) || !AssertExtUtil.trustedPathExt(uri)) {
      HiLog.warn(TAG, 'forbidden default file path uri.');
      return true;
    }
    return false;
  }

  /**
   * 路径是否可信，防止路径注入-批量
   *
   * @param uri
   * @param error
   * @returns
   */
  public static checkUriTrustedBatch(uris: string[]): string {
    if (ObjectUtil.isNullOrUndefined(uris) || ArrayUtil.isEmpty(uris)) {
      return '';
    }
    let errorStr = '';
    for (let i = 0; i < uris.length; i++) {
      errorStr = AssertExtUtil.checkUriTrusted(uris[i]);
      if (!StringUtil.isEmpty(errorStr)) {
        return errorStr;
      }
    }
    return errorStr;
  }

  /**
   * 校验路径是否存在，前提是路径可信
   * @param uri
   * @param error
   * @returns
   */
  public static checkUriExist(uri: string): string {
    let errorRes = AssertExtUtil.checkUriTrusted(uri);
    if (StringUtil.isEmpty(errorRes) && !FsUtil.isFileExist(uri)) {
      errorRes = ' uri is Not Exist'
    }
    return errorRes;
  }

  /**
   * 校验路径是否可被外部访问、可信
   *
   * @param uri
   * @param error
   * @returns
   */
  public static checkUriAccess(uri: string): string {
    let errorRes = AssertExtUtil.checkUriTrusted(uri);
    if (StringUtil.isEmpty(errorRes) && !AssertExtUtil.allowAccessPathExt(uri)) {
      errorRes = ' uri is No Permission'
    }
    return errorRes;
  }

  /**
   * 校验路径是否可信、有权限、存在
   *
   * @param uri
   * @param error
   * @returns
   */
  public static checkUri(uri: string): string {
    let errorRes = AssertExtUtil.checkUriTrusted(uri);
    if (StringUtil.isEmpty(errorRes) && !AssertExtUtil.allowAccessPathExt(uri)) {
      errorRes = ' uri is No Permission'
    }
    if (StringUtil.isEmpty(errorRes) && !FsUtil.isFileExist(uri)) {
      errorRes = ' uri is Not Exist'
    }
    return errorRes;
  }

  /**
   * 校验路径是否可信、有权限、存在
   *
   * @param uri
   * @param error
   * @returns
   */
  public static checkUriBatch(uris: string[]): string {
    if (ObjectUtil.isNullOrUndefined(uris) || ArrayUtil.isEmpty(uris)) {
      return '';
    }
    let errorStr = '';
    for (let i = 0; i < uris.length; i++) {
      errorStr = AssertExtUtil.checkUri(uris[i]);
      if (!StringUtil.isEmpty(errorStr)) {
        return errorStr;
      }
    }
    return errorStr;
  }

  /**
   * 外部传入路径合法性校验，防止路径注入，日志注入
   *
   * @param values
   * @returns
   */
  public static trustedPathExt(filePath: string): boolean {
    if (filePath == null || filePath.length == 0) {
      return true; // 允许空路径
    }
    if (filePath.includes('./') || filePath.includes('../') ||
      filePath.includes('.\\.\\') || filePath.includes('%00')) {
      HiLog.error(TAG, "file path can't contains ./、../、.\\.\\、%00 !");
      return false;
    }
    return true;
  }

  /**
   * 允许访问路径-权限校验
   * 允许访问的路径：MY_PC、EXTERNAL_DISK；不允许访问的路径：沙箱
   *
   * @param values
   * @returns
   */
  public static allowAccessPathExt(filePath: string): boolean {
    if (StringUtil.isEmpty(filePath)) {
      return true; // 允许空串
    }
    // 允许访问我的电脑、外部存储
    return filePath.startsWith(VirtualUri.MY_PC) || filePath.startsWith(VirtualUri.EXTERNAL_DISK);
  }

  /**
   * 是否异常日志，是则打印
   *
   * @param values
   * @returns
   */
  public static checkIsError(tag: string, errorStr: string): boolean {
    if (!StringUtil.isEmpty(errorStr)) {
      HiLog.info(tag, errorStr);
      return true;
    }
    return false;
  }

  public static coverToString(s: Object | undefined, parameter: string): string {
    if (ObjectUtil.isNullOrUndefined(s)) {
      HiLog.warn(TAG, 'want.parameters not contains ' + parameter);
      return '';
    }
    if (typeof s !== 'string') { // 不是字符串类型 ，返回空
      return '';
    }
    return s as string;
  }
}
