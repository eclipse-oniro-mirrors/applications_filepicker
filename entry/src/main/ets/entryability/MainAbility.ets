/*
 * Copyright (c) 2021-2023 Huawei Device Co., Ltd.
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

import UIAbility from '@ohos.app.ability.UIAbility'
import window from '@ohos.window'
import AbilityCommonUtil from '../base/utils/AbilityCommonUtil'
import Logger from '../base/log/Logger'
import { FilePickerUtil } from '../base/utils/FilePickerUtil'
import { StartModeOptions } from '../base/model/StartModeOptions'
import { PickerWindowType } from '../base/constants/FilePickerItems'
import Want from '@ohos.app.ability.Want'
import { AbilityConstant } from '@kit.AbilityKit'

const TAG = 'MainAbility'

export default class MainAbility extends UIAbility {
  private storage: LocalStorage = new LocalStorage();
  private startModeOptions?: StartModeOptions;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    Logger.i(TAG, 'onCreate')
    globalThis.abilityContext = this.context;
    let options: StartModeOptions = FilePickerUtil.getStartModeOptions(want);
    options.windowType = PickerWindowType.ABILITY;
    options.uiContext = this.context;
    options.context = this.context;
    options.fileSuffixFilters = AbilityCommonUtil.getKeyFileSuffixFilter(options.fileSuffixFilters);
    if (options.isOpenFileMode()) {
      options.fileSuffixFilters = AbilityCommonUtil.getKeyFileSuffixFilter(options.fileSuffixFilters);
      options.phonePickerType = (want.parameters?.key_pick_type as string) || '';
      options.phonePickerTypeList = AbilityCommonUtil.getKeyPickTypeList(want.parameters?.key_picker_type as object,
        want.parameters?.key_picker_type_list as object)
    }
    if (options.isCreateFileMode()) {
      options.PhoneFileSuffixChoices = AbilityCommonUtil.getKeyFileSuffixChoices(options.fileSuffixChoices);
    }
    this.startModeOptions = options;
    this.storage.setOrCreate<StartModeOptions>('startModeOptions', options);
  }

  onDestroy() {
    Logger.i(TAG, 'onDestroy')
    AbilityCommonUtil.releasePhotoManageHelper()
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    Logger.i(TAG, 'onWindowStageCreate')
    AbilityCommonUtil.init().then(() => {
      globalThis.windowClass = windowStage.getMainWindowSync();
      if (this.startModeOptions?.isOpenFileMode()) {
        // 文件选择器
        windowStage.loadContent('pages/browser/storage/MyPhone', this.storage, (err, data) => {
          if (err.code) {
            Logger.e(TAG, 'Failed to load the content: ' + JSON.stringify(err));
            return
          }
          Logger.i(TAG, 'data: ' + JSON.stringify(data));
        })
      } else {
        // 路径选择器
        windowStage.loadContent('pages/PathPicker', this.storage, (err, data) => {
          if (err.code) {
            Logger.e(TAG, 'Failed to load the content. Cause: ' + JSON.stringify(err))
            return;
          }
          Logger.i(TAG, 'Succeeded in loading the content. Data: ' + JSON.stringify(data))
        })
      }
    })

  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    Logger.i(TAG, 'onWindowStageDestroy')
  }

  onForeground() {
    // Ability has brought to foreground
    Logger.i(TAG, 'onForeground')
  }

  onBackground() {
    // Ability has back to background
    Logger.i(TAG, 'onBackground')
  }
}
