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
import { Constant } from '../const/Constant';
import { PAGE_ROUTE_CONST } from '../const/PageRouteConst';
import { GlobalHolder } from '../global/GlobalHolder';
import { GlobalKey } from '../global/GlobalKey';
import { UIExtensionContentSession } from '@kit.AbilityKit';
import { HiLog } from '../dfx/HiLog';

const TAG = 'PrivacyModeManager';

/**
 * 管理文管窗口界面的可截屏状态
 */
export class PrivacyModeManager {
  private static instance: PrivacyModeManager;
  // 不会改变可截屏状态的界面
  private IGNORE_PAGES: Set<string> = new Set([]);

  private lastPrivacyMode: boolean = false;

  public static getInstance(): PrivacyModeManager {
    if (!PrivacyModeManager.instance) {
      PrivacyModeManager.instance = new PrivacyModeManager();
    }
    return PrivacyModeManager.instance;
  }

  /**
   * 设置是否可截屏状态
   * @param isPrivacy 是否是隐私界面
   */
  public setPrivacyMode(isPrivacy: boolean): void {
    if (this.lastPrivacyMode !== isPrivacy) {
      HiLog.info(TAG, 'set privacy mode: ' + isPrivacy);
      GlobalHolder.getInstance()
        .getObject<UIExtensionContentSession>(GlobalKey.WINDOW_CLASS_EXT)?.setWindowPrivacyMode(isPrivacy);
      this.lastPrivacyMode = isPrivacy;
    } else {
      HiLog.info(TAG, 'no need set privacy mode');
    }
  }

  public onFrontPageChange(pageName: string | undefined) {
    HiLog.info(TAG, 'onFrontPageChange: ' + pageName);
    if (pageName !== undefined && this.IGNORE_PAGES.has(pageName)) {
      HiLog.info(TAG, 'ignore page, no need set');
      return;
    }
    HiLog.info(TAG, 'no need set privacy mode');
  }
}