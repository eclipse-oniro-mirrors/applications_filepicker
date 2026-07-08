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

import { HiLog, GlobalHolder, ERROR_CODE } from '@ohos/common';
import lazy { updateManager } from '@ohos/common/indexLazyLoad';
import PromptUtil from './PromptUtil';

const TAG = 'AppVersionUtil';

export default class AppVersionUtil {
  /**
   * 未知
   */
  public static readonly UNKNOWN_VERSION: number = 0
  /**
   * 已是最新版本
   */
  public static readonly VERSION_IS_LATEST: number = 1
  /**
   * 等待更新版本
   */
  public static readonly WAIT_UPDATE_VERSION: number = 2

  /**
   * 检查应用是否有最新版本
   * @param isSilentCheck 是否为静默检查
   * @returns 是否有最新版本
   */
  public static async checkHasNewVersion(isSilentCheck: boolean = false): Promise<boolean> {
    let result = false
    const context = GlobalHolder.getInstance().getMainAbilityContext();
    !isSilentCheck && PromptUtil.toast($r('app.string.check_update_now'));
    try {
      const checkRes: updateManager.CheckUpdateResult = await updateManager.checkAppUpdate(context);
      HiLog.info(TAG, 'checkHasNewVersion updateAvailable:' + checkRes.updateAvailable);
      if (checkRes.updateAvailable === updateManager.UpdateAvailableCode.LATER_VERSION_EXIST) {
        result = true;
        !isSilentCheck && AppVersionUtil.showUpdateDialog();
      } else {
        !isSilentCheck && PromptUtil.toast($r('app.string.version_is_latest'));
      }
    } catch (error) {
      HiLog.error(TAG, 'checkHasNewVersion fail, error:' + error);
      !isSilentCheck && PromptUtil.toast($r('app.string.version_is_latest'));
    }
    return result;
  }

  /**
   * 显示应用更新弹窗
   */
  private static async showUpdateDialog(): Promise<void> {
    try {
      const context = GlobalHolder.getInstance().getMainAbilityContext();
      const resultCode = await updateManager.showUpdateDialog(context)
      HiLog.info(TAG, 'showUpdateDialog resultCode:' + resultCode);
    } catch (error) {
      if (error.code === ERROR_CODE.NETWORK.NETWORK_ERROR) {
        PromptUtil.toast($r('app.string.net_work_disconnect'));
      }
      HiLog.error(TAG, 'showUpdateDialog fail, error:' + error);
    }
  }
}