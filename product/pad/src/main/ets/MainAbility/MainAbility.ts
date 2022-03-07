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

export default class MainAbility extends Ability {
    onCreate(want, launchParam) {
        console.log(`MainAbility onCreate is called ${want} and ${launchParam}`)
        globalThis.startMode = want.parameters.startMode
        globalThis.saveFile = want.parameters.saveFile
        globalThis.debugMode = want.parameters.debugMode
        console.log('filePicker_MainAbility: startMode = ' + globalThis.startMode)
        console.log('filePicker_MainAbility: file_name = ' + globalThis.saveFile)
        console.log('filePicker_MainAbility: debugMode = ' + globalThis.debugMode)
    }

    onDestroy() {
        console.log("MainAbility onDestroy is called")
    }

    onWindowStageCreate(windowStage) {
        console.log("MainAbility onWindowStageCreate is called")

        globalThis.context = this.context
        windowStage.setUIContent(this.context, 'pages/Main', null)
        windowStage.getMainWindow().then(win => {
            console.log("cjl windowStage.getMainWindow()")
            win.resetSize(vp2px(752), vp2px(446))

            win.moveTo(100, 0)

            win.on('windowSizeChange', () => {
                win.resetSize(vp2px(752), vp2px(446))
            })
        })
    }

    onWindowStageDestroy() {
        console.log("MainAbility onWindowStageDestroy is called")
    }

    onForeground() {
        console.log("MainAbility onForeground is called")
    }

    onBackground() {
        console.log("MainAbility onBackground is called")
    }
}