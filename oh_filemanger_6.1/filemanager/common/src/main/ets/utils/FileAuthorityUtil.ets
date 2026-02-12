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

import { FileInfo } from '../fileoperate/FileInfo';
import wantConstant from '@ohos.app.ability.wantConstant';
import { HiLog } from '../dfx/HiLog';
import { GlobalHolder } from '../global/GlobalHolder';
import type Want from '@ohos.app.ability.Want';
import uriPermissionManager from '@ohos.application.uriPermissionManager';

export class FileAuthorityUtil {

  private static tag = 'FileAuthorityUtil';

  /**
   * uri授权
   * @param uri 待授权uri
   * @param bundleName 待授权方
   * @param flag 权限
   * @returns true 成功，false 失败
   */
  public static async grantUriPermission(uri: string, bundleName: string, flag: wantConstant.Flags): Promise<boolean> {
    if (!bundleName) {
      HiLog.warn(FileAuthorityUtil.tag, 'grantUriPermission failed, bundleName is null');
      return false;
    }
    try {
      await uriPermissionManager.grantUriPermission(uri, flag, bundleName);
      HiLog.infoPrivate(FileAuthorityUtil.tag, 'grantUriPermission success' + ', flag:' + flag, `uri: ${uri}`);
      return true;
    } catch (err) {
      HiLog.error(FileAuthorityUtil.tag, 'grantUriPermission err: ' + JSON.stringify(err));
      return false;
    }
  }
}