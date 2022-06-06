import Ability from '@ohos.application.Ability'
import display from '@ohos.display'
import { Callback } from 'basic'
import { LogInfo, LogDebug } from '../module/LogUtils'

let displayWidth: number = 0
let displayHeight: number = 0

const TAG = "MainAbility"

export default class MainAbility extends Ability {
    onCreate(want, launchParam) {
        console.log("filePicker_MainAbility: onCreate")
        globalThis.abilityWant = want;

        globalThis.startMode = want.parameters.startMode
        globalThis.saveFile = want.parameters.saveFile
        globalThis.debugMode = want.parameters.debugMode
        console.log('filePicker_MainAbility: startMode = ' + globalThis.startMode)
        console.log('filePicker_MainAbility: file_name = ' + globalThis.saveFile)
        console.log('filePicker_MainAbility: debugMode = ' + globalThis.debugMode)

    }

    onDestroy() {
        console.log("[Demo] MainAbility onDestroy")
    }

    onWindowStageCreate(windowStage) {
        // Main window is created, set main page for this ability
        LogInfo(TAG, "[Demo] MainAbility onWindowStageCreate")

        globalThis.context = this.context

        this.requestPermissions(() => this.displayWindow(windowStage))


    }

    onWindowStageDestroy() {
        // Main window is destroyed, release UI related resources
        console.log("[Demo] MainAbility onWindowStageDestroy")
    }

    onForeground() {
        // Ability has brought to foreground
        console.log("[Demo] MainAbility onForeground")
    }

    onBackground() {
        // Ability has back to background
        console.log("[Demo] MainAbility onBackground")
    }

    private requestPermissions(callback: Callback<void>) {
        let permissionList: Array<string> = [
            "ohos.permission.MEDIA_LOCATION",
            "ohos.permission.READ_MEDIA",
            "ohos.permission.WRITE_MEDIA"
        ]
        globalThis.context.requestPermissionsFromUser(permissionList).then(function (data) {
            LogInfo(TAG, 'filePicker_MainAbility: request permission data result = ' + data.authResults)
            callback()
        }, (error) => {
            LogInfo(TAG, 'filePicker_MainAbility: fail to request permission error code = ' + error.code)
        })
    }

    private displayWindow(windowStage) {
        display.getDefaultDisplay().then(dis => {
            displayWidth = dis.width
            displayHeight = dis.height

            globalThis.width = dis.width
            globalThis.height = dis.height
            globalThis.mainDialogWidth = dis.width
            globalThis.mainDialogHeight = (((displayHeight) - 240) * 0.7)

            LogInfo(TAG, "cjl displayWidth = " + displayWidth + " displayHeight = " + displayHeight)

            windowStage.getMainWindow().then(win => {
                LogInfo(TAG, "cjl windowStage.getMainWindow()")

                win.resetSize(displayWidth - 30, displayHeight - 168)

                win.moveTo(0, 0)

                win.setTransparent(true)

                win.disableWindowDecor((err, data) => {
                    if (err.code) {
                        LogInfo(TAG, 'Failed to set the disableWindowDecor. Data: ' + JSON.stringify(data))
                    } else {
                        LogInfo(TAG, 'Succeeded in setting the disableWindowDecor. Data: ' + JSON.stringify(data))
                    }
                })

                win.setWindowMode(102, (err, data) => {
                    if (err.code) {
                        LogInfo(TAG, 'Failed to set the setWindowMode. Data: ' + JSON.stringify(data))
                    } else {
                        LogInfo(TAG, 'Succeeded in setting the setWindowMode. Data: ' + JSON.stringify(data))
                    }
                })

                windowStage.setUIContent(this.context, "pages/index", null)
            })
        })
    }
};
