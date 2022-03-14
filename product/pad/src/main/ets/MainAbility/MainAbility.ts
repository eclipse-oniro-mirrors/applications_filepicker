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

import Ability from '@ohos.application.Ability'
import display from '@ohos.display'

let displayWidth: number = 0
let displayHeight: number = 0

export default class MainAbility extends Ability {
    onCreate(want, launchParam) {
        console.log(`filePicker_MainAbility:  onCreate is called ${want} and ${launchParam}`)
        globalThis.startMode = want.parameters.startMode
        globalThis.saveFile = want.parameters.saveFile
        globalThis.debugMode = want.parameters.debugMode
        console.log('filePicker_MainAbility: startMode = ' + globalThis.startMode)
        console.log('filePicker_MainAbility: file_name = ' + globalThis.saveFile)
        console.log('filePicker_MainAbility: debugMode = ' + globalThis.debugMode)
    }

    onDestroy() {
        console.log('filePicker_MainAbility: onDestroy is called')
    }

    onWindowStageCreate(windowStage) {
        console.log('filePicker_MainAbility: onWindowStageCreate is called')

        globalThis.context = this.context
        windowStage.setUIContent(this.context, 'pages/Main', null)

        display.getDefaultDisplay().then(dis => {
            displayWidth = dis.width
            displayHeight = dis.height
        })

        windowStage.getMainWindow().then(win => {
            console.log("filePicker_MainAbility: windowStage.getMainWindow()")
            win.resetSize(vp2px(752), vp2px(446))

            let positionX: number = (displayWidth - vp2px(752)) / 2
            let positionY: number = (displayHeight - vp2px(446)) / 2
            win.moveTo(positionX, positionY)

            win.on('windowSizeChange', () => {
                win.resetSize(vp2px(752), vp2px(446))
            })
        })
    }

    onWindowStageDestroy() {
        console.log("filePicker_MainAbility: onWindowStageDestroy is called")
    }

    onForeground() {
        console.log("filePicker_MainAbility: onForeground is called")
    }

    onBackground() {
        console.log("filePicker_MainAbility: onBackground is called")
    }
}