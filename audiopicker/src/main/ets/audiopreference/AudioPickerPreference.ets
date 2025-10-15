/*
 * Copyright (c) 2024-2024 Huawei Device Co., Ltd.
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
import { BusinessError } from '@ohos.base'
import { Logger } from '../common/util/HiLogger'
import { MusicApp } from '../common/global/globalmodel/GlobalModel';
import { createOrGet, globalKeys } from '../common/global/GlobalThisHelper'
import { PreferenceManager } from '../common/preference/PreferenceManager'

const keyPermissionTipLog = 'Key_Permission_TipLog'
const logger: Logger = new Logger('AudioPickerPreference')
const app: MusicApp = createOrGet(MusicApp, globalKeys.app, ['phone']);

export class AudioPickerPreference {
  private preferenceManager: PreferenceManager = createOrGet(PreferenceManager,
    globalKeys.preferenceManager, [app.abilityContext])

  /**
   * 保存安全提示状态
   * @param isFirstStartUp
   */
  public saveSafetyTipStatus(isFirstStartUp: boolean): void {
    this.preferenceManager.put(keyPermissionTipLog, isFirstStartUp, true,
      this.preferenceManager.preferKeys.audioPicker).then((res) => {
      logger.info(`saveSafetyTipStatus Success ? : ${res}`)
    }).catch((err: BusinessError) => {
      logger.error(`saveSafetyTipStatus Fail, err name:${err.name} , err message:${err.message}`)
    })
  }

  /**
   * 获取权限状态
   *
   * @returns boolean
   */
  public getSafetyTipStatus(): Promise<boolean> {
    return new Promise((resolve) => {
      this.preferenceManager.get(keyPermissionTipLog, false,
        this.preferenceManager.preferKeys.audioPicker).then((res) => {
        resolve(res as boolean)
      }).catch((err: BusinessError) => {
        logger.error(`getPrivacyStatus error, err name:${err.name}, err message:${err.message}`)
        resolve(false)
      })
    })
  }
}

