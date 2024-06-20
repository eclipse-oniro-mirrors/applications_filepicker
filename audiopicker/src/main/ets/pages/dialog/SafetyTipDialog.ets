/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */


import { DeviceInfo, DeviceTypes } from '../../common/global/globalmodel/GlobalModel';
import { createOrGet, globalKeys } from '../../common/global/GlobalThisHelper';
import { Logger } from '../../common/util/HiLogger'

const logger: Logger = new Logger('SafetyTipDialog')

/*
 *  安全提示弹窗
 * */
@CustomDialog
export struct SafetyTipDialog {
  // 设备信息
  private globalDeviceInfo: DeviceInfo = createOrGet(DeviceInfo, globalKeys.deviceInfo)
  controller?: CustomDialogController
  know?: () => void

  build() {
    Column() {
      Stack() {
        Image($r('app.media.ic_public_privacy_big'))
          .height(28)
          .fillColor($r('sys.color.ohos_id_color_component_activated'))
        Image($r('app.media.img'))
          .width(24)
          .height(24)
          .zIndex(99)
          .borderRadius(5)
          .position({
            x: 24,
            y: 24
          })
      }
      .width(48)
      .height(48)
      .borderRadius(8)
      .margin({ top: 24, bottom: 16 })

      Text($r('app.string.secure_access_to_audio_library'))
        .width(this.globalDeviceInfo.deviceType === DeviceTypes.PHONE ? 280 : 352)
        .height(26)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontFamily('HarmonyHeiTi')
        .lineHeight(27)
        .textAlign(TextAlign.Center)

      Text($r('app.string.your_audio_will_be_displayed_here'))
        .width(this.globalDeviceInfo.deviceType === DeviceTypes.PHONE ? 280 : 352)
        .height(38)
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
        .lineHeight(19)
        .margin({
          left: 24,
          right: 24,
          top: 8,
          bottom: 16
        })
        .textAlign(TextAlign.Center)

      Text($r('app.string.got_it'))
        .width(this.globalDeviceInfo.deviceType === DeviceTypes.PHONE ? 280 : 352)
        .height(40)
        .margin({ left: 16, right: 16 })
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontFamily('HarmonyHeiTi')
        .lineHeight(21)
        .fontColor($r('sys.color.ohos_id_text_color_active'))
        .textAlign(TextAlign.Center)
        .onClick(() => {
          if (this.know) {
            this.know()
          }
        })
    }
    .width('100%')
    .height(232)
    .borderRadius(32)
    .margin({ left: 16, right: 16 })
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}



