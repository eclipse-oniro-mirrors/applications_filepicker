import Ability from '@ohos.application.Ability'
import display from '@ohos.display'

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
        console.log("[Demo] MainAbility onWindowStageCreate")

        display.getDefaultDisplay().then(dis => {
            displayWidth = dis.width
            displayHeight = dis.height

            globalThis.width = dis.width
            globalThis.height = dis.height
            globalThis.mainDialogWidth = dis.width
            globalThis.mainDialogHeight = dis.height * 0.65

            console.log("cjl displayWidth = " + displayWidth + " displayHeight = " + displayHeight)
        })

        globalThis.context = this.context
        windowStage.setUIContent(this.context, "pages/index", null)

        windowStage.getMainWindow().then(win => {
            console.log("cjl windowStage.getMainWindow()")
            win.resetSize(displayWidth, (displayHeight * 0.65))

            win.moveTo(0, (displayHeight * 0.23))

            win.on('windowSizeChange', () => {
                win.resetSize(displayWidth, (displayHeight * 0.65))
            })
        })
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
};
