/*
 * Copyright (c) 2021-2024 Huawei Device Co., Ltd.
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

import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import Want from '@ohos.app.ability.Want';
import common from '@ohos.app.ability.common';

import { Logger } from '../common/util/HiLogger'
import { MusicApp } from '../common/global/globalmodel/GlobalModel';
import { createOrGet, globalKeys } from '../common/global/GlobalThisHelper'

const logger: Logger = new Logger('AudioPickerExtAbility')
const app: MusicApp = createOrGet(MusicApp, globalKeys.app, ['phone']);

/**
 * AudioPicker模态弹框
 */
export default class AudioPickerUIExtensionAbility extends UIExtensionAbility {
  onCreate() {
    Logger.domain = 0xD004722
    logger.info(`UIExtAbility onCreate`)
    app.UIExtensionContext = this.context;
    app.abilityContext = getContext(this) as common.UIAbilityContext
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession) {
    logger.info(`UIExtAbility onSessionCreate, want: ${JSON.stringify(want)}`)
    let param: Record<string, UIExtensionContentSession | Want> = {
      'session': session,
      'want': want
    }
    let storage: LocalStorage = new LocalStorage(param);
    try {
      session.loadContent('pages/card/AudioPickerExtension', storage); // 提供方加载自己界面

    } catch (e) {
      logger.error(` error ${JSON.stringify(e)}`)
    }
  }

  onSessionDestroy(session: UIExtensionContentSession) {
    logger.info(`UIExtAbility onSessionDestroy`)
  }

  onForeground(): void {
  }

  onBackground(): void {
  }

  onDestroy(): void | Promise<void> {
  }
}