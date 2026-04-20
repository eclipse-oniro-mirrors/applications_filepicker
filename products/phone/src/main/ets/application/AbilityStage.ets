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

import AbilityStage from '@ohos.app.ability.AbilityStage';
import { GlobalHolder, HiLog, MyPhoneConstant } from '@ohos/common';
import type { Configuration } from '@ohos.app.ability.Configuration';
import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant';

const TAG = 'AbilityStage';

export default class MyAbilityStage extends AbilityStage {
  onCreate(): void {
    HiLog.init(this.context);
    HiLog.info(TAG, 'FileManager Application Start');
    try {
      AppStorage.setOrCreate('isDarkMode', this.context?.config?.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
      GlobalHolder.getInstance().abilityStageContext = this.context;
      MyPhoneConstant.init();
    } catch (e) {
      HiLog.error(TAG, 'FileManager Application Start error: ' + JSON.stringify(e));
    }
  }

  onDestroy(): void {
    HiLog.warn(TAG, 'onDestroy.')
    HiLog.logFlush();
  }

  /**
   * 适配深色主题状态栏
   * @param config config
   */
  onConfigurationUpdate(config: Configuration): void {
    HiLog.debug(TAG, 'onConfigurationUpdate colorMode is: ' + config.colorMode);
    AppStorage.setOrCreate('isDarkMode', config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
  }
}