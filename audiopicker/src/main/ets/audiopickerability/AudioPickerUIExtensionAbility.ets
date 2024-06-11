import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import Want from '@ohos.app.ability.Want';

import { Logger } from '../common/util/HiLogger'
import { MusicApp } from '../common/global/globalmodel/GlobalModel';
import { createOrGet, globalKeys } from '../common/global/GlobalThisHelper'
import { Constants } from '../constant/Constants';
import { common } from '@kit.AbilityKit';

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