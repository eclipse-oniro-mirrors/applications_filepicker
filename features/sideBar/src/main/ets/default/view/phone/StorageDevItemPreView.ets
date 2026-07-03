/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
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

import { SideBarItemModel } from '../../model/SideBarItemModel';
import { LengthMetrics } from '@ohos.arkui.node';
import fileExtensionInfo from '@ohos.file.fileExtensionInfo';
import { Constant, getResourceString, renderSize } from '@ohos/common';


@Component
export struct StorageDevicePreviewItem {
  private info: SideBarItemModel = {} as SideBarItemModel;
  private usbTotalBytes: number = 0;
  private usbUseBytes: number = 0;

  getUsbSpaceSizeProcess(): number {
    if (this.usbTotalBytes === 0) {
      return 0;
    }
    const percentConversion: number = 100;
    return this.usbUseBytes / this.usbTotalBytes * percentConversion;
  }

  build() {
    Row() {
      if (this.info.icon) {
        Image(this.info.icon as Resource)
          .draggable(false)
          .height($r('app.float.common_size24'))
          .width($r('app.float.common_size24'))
          .margin({ end: LengthMetrics.vp(16) })
      }
      Column() {
        Text(this.info.name)
          .fontSize($r('app.float.common_font_size16'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .fontFamily('HarmonyHeiTi')
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)
        if (this.usbTotalBytes > 0 &&
          (this.info.deviceType === fileExtensionInfo.DeviceType.DEVICE_EXTERNAL_USB ||
            this.info.deviceType === fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK)) {
          Text($r('app.string.device_space_usage', renderSize(this.usbUseBytes, Constant.BYTE.STORAGE_KB, true),
            renderSize(this.usbTotalBytes, Constant.BYTE.STORAGE_KB, true)))
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .opacity($r('app.float.common_opacity6'))
            .margin({ top: $r('app.float.common_margin2') })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .textAlign(TextAlign.End)
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .lineHeight($r('app.float.common_font_size19'))
            .maxLines(1)
            .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)
        }
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
      .padding({
        // 适老化适配，设置文本框高度在字体变大时将Column组件高度撑高
        top: $r('app.float.common_margin8'),
        bottom: $r('app.float.common_margin8')
      })
      Flex({ justifyContent: FlexAlign.End }) {
      }.layoutWeight(1)
      .padding({ left: $r('app.float.common_padding8') })
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .draggable(false)
        .fontSize('24vp')
        .fontColor([$r('sys.color.icon_fourth')])
        .margin({ left: $r('sys.float.ohos_id_text_paragraph_margin_xs') })
    }
    .constraintSize({
      // 适老化适配，将文本框的高度设置为可调整，当文字变大时文本框会跟随变高。从而解决文字与图片叠加问题
      minHeight: $r('app.float.common_size56')
    })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius($r('app.float.common_borderRadius16'))
    .padding({
      left: $r('app.float.common_padding12'),
      right: $r('app.float.common_padding12')
    })
    .width('100%')
  }
}