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
import { HiLog } from '@ohos/common/tsIndex';
import uiExtensionHost from '@ohos.uiExtensionHost';


const TAG: string = 'UiExtensionHostUtilTemp';

// todo 底座的hidePrivacyContentForHost修改还未更新归档到最新sdk，在ts文件中使用ts-ignore暂时屏蔽
export class UiExtensionHostUtilTemp {
  // 设置picker隐私模式，防止其他应用截屏
  public static hidePrivacyContentForHost(extensionWindow: uiExtensionHost.UIExtensionHostWindowProxy): void {
    if (!extensionWindow) {
      HiLog.info(TAG, 'hidePrivacyContentForHost extensionWindow is null or undefined');
      return;
    }
    try {
      // @ts-ignore
      extensionWindow.hidePrivacyContentForHost(true);
    } catch (error) {
      HiLog.warn(TAG, 'hidePrivacyContentForHost error ' + JSON.stringify(error));
    }
  }
}