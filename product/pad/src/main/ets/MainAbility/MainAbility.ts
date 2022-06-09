import Ability from '@ohos.application.Ability'
import display from '@ohos.display'
import { Callback } from 'basic'

let displayWidth: number = 0
let displayHeight: number = 0

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
        console.log("filePicker_MainAbility: onWindowStageCreate")

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
            console.log('filePicker_MainAbility: request permission data result = ' + data.authResults)
            callback()
        }, (error) => {
            console.log('filePicker_MainAbility: fail to request permission error code = ' + error.code)
        })
    }

    private displayWindow(windowStage) {
        windowStage.setUIContent(this.context, "pages/index", null)

        display.getDefaultDisplay().then(dis => {
            displayWidth = dis.width
            displayHeight = dis.height
        })

        windowStage.getMainWindow().then(win => {
            console.log("filePicker_MainAbility: windowStage.getMainWindow()")
            win.setWindowMode(102, (err, data) => {
            })

            win.resetSize(vp2px(752), vp2px(446))

            let positionX: number = (displayWidth - vp2px(752)) / 2
            let positionY: number = (displayHeight - vp2px(446)) / 2
            win.moveTo(positionX, positionY)

            win.on('windowSizeChange', () => {
                win.resetSize(vp2px(752), vp2px(446))
            })
        })
    }
};
