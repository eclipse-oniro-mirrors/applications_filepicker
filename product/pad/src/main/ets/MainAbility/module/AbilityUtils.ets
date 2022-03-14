/*
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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

import display from '@ohos.display'
import featureAbility from '@ohos.ability.featureAbility'
import { LogInfo } from '../../../../../../../common/LogUtils.ets'
import { DisplayInfo } from './DisplayInfo.ets'

var TAG: string = 'AbilityUtils'

export function terminateSelfWithResult(resultCode: number, result: string): void {
  LogInfo(TAG, 'terminateSelfWithResult')
  let startMode: string = AppStorage.Get<string>('startMode')
  var abilityResult = {
    resultCode: resultCode,
    want: {
      parameters: {
        'startMode': startMode,
        'result': result
      }
    }
  }
  globalThis.context.terminateSelfWithResult(abilityResult, (error, data) => {
    if (error) {
      LogInfo(TAG, 'Operation failed. Cause: ' + JSON.stringify(error))
      return
    }
    LogInfo(TAG, 'Operation succeeded')
  })
}

export function initData(): void {
  LogInfo(TAG, 'initData')
  initWindowScale()

  getWantFromHap()
}

function initWindowScale(): void {
  display.getDefaultDisplay().then(dis => {
    LogInfo(TAG, 'width = ' + dis.width + ';height= ' + dis.height)
    let displayInfo: DisplayInfo = new DisplayInfo()

    if (dis.width > dis.height) { // 横屏
      displayInfo.width = dis.width
      displayInfo.height = dis.height * 0.7 // 需要减去信号栏和导航栏的高度
      displayInfo.mainDialogHeight = displayInfo.height - vp2px(64 + 76)
      displayInfo.mainDialogWidth = displayInfo.width

    } else { // 竖屏
      displayInfo.width = dis.width
      displayInfo.height = dis.height * 0.7 // 需要减去信号栏和导航栏的高度
      displayInfo.mainDialogHeight = displayInfo.height - vp2px(64 + 76)
      displayInfo.mainDialogWidth = displayInfo.width
    }

    LogInfo(TAG, 'mainDialogWidth = ' + displayInfo.mainDialogWidth)
    LogInfo(TAG, 'mainDialogHeight = ' + displayInfo.mainDialogHeight)
    AppStorage.SetOrCreate('displayInfo', displayInfo)

  })
}

function getWantFromHap(): void {
  featureAbility.getWant()
    .then((Want) => {
      var mode: string = Want.parameters['startMode']
      if (mode == undefined) {
        AppStorage.SetOrCreate<string>('startMode', 'choose')
      } else {
        AppStorage.SetOrCreate<string>('startMode', mode)
      }
      let save_name: string = Want.parameters['file_name']
      AppStorage.Set<string>('saveName', save_name)
      LogInfo(TAG, 'saveName = ' + save_name)
    }).catch((error) => {
    LogInfo(TAG, 'fail Data: ' + JSON.stringify(error))
  })
}