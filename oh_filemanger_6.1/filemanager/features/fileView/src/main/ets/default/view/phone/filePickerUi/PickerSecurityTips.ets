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
import {
  AccessibilityManager,
  CompId,
  GlobalHolder,
  HiLog,
  ObjectUtil,
  ResourceUtil,
  SecurityData,
  SecurityWarning
} from '@ohos/common';
import dataPreferences from '@ohos.data.preferences';
import { BusinessError } from '@kit.BasicServicesKit';
// import lazy { PickerSheet, PickerType } from '@hw-hmos/pickersheet';
import { LengthMetrics } from '@kit.ArkUI';

const TAG = 'PickerSecurityTips';

@Component
export struct PickerSecurityTips {
  @Link isShowPickerTips: boolean;
  @State showSafePicker: boolean = false;

  build() {
    Column() {
      Flex() {
        this.PickerSecurityFolderIcon()

        Column() {
          if (this.showSafePicker) {
            // PickerSheet({
            //   appIcon: $r('app.media.app_icon'),
            //   curPickerKey: PickerType.FILES_PICKER,
            //   onClose: () => {
            //     HiLog.warn(TAG, 'onClose SafePicker');
            //     this.showSafePicker = false;
            //   }
            // }).position({ top: 0 })
          }
          Row() {
            Text($r('app.string.security_access_files_tips'))
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .maxFontScale(2)
              .fontColor($r('sys.color.font_primary'))
              .fontFamily('HarmonyHeiTi')
              .margin({ bottom: $r('sys.float.padding_level1') })
            Blank()
            Column() {
              SymbolGlyph($r('sys.symbol.xmark'))
                .fontSize($r('app.float.common_padding18'))
                .draggable(false)
                .fontColor([$r('sys.color.icon_secondary')])
                .onClick(() => {
                  this.clickConfirm();
                })
                .accessibilityText(ResourceUtil.getStringByResource($r('app.string.close')))
                .accessibilityRole(AccessibilityRoleType.BUTTON)
            }
            .alignSelf(ItemAlign.Start)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .alignSelf(ItemAlign.Start)

          Text() {
            Span($r('app.string.security_access_files_details', ''))
            Span($r('app.string.learn_more'))
              .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
              .borderRadius($r('sys.float.ohos_id_corner_radius_dialog'))
              .onClick(() => {

                HiLog.warn(TAG, 'onClick learn_more');
                this.showSafePicker = true;
              })
          }
            .lineHeight('app.float.common_font_size19')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .alignSelf(ItemAlign.Start)
            .fontColor($r('sys.color.font_secondary'))
            .fontFamily('HarmonyHeiTi')
            .maxFontScale(2)
          .constraintSize({
            maxWidth: '90%'
          })
        }
        .margin({
          start: LengthMetrics.resource($r('sys.float.padding_level6'))
        })
        .layoutWeight(1)
      }
      .margin({
        bottom: $r('sys.float.padding_level6'),
        top: $r('sys.float.padding_level6')
      })
    }
    .flexShrink(0) // 让tip不被压缩
    .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
    .borderRadius($r('sys.float.corner_radius_level10'))
    .padding({
      left: $r('sys.float.padding_level6'),
      right: $r('sys.float.padding_level6')
    })
    .margin({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8')
    })
  }

  @Builder
  PickerSecurityFolderIcon() {
    Stack() {
      Stack() {
        Column()
          .width($r('app.float.common_size32'))
          .height($r('app.float.common_size32'))
          .backgroundColor(Color.White)
          .borderRadius(8)
        SymbolGlyph($r('sys.symbol.security_shield'))
          .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
          .fontColor(['#e6000000', '#0A59F7'])
          .fontSize($r('app.float.common_size22'))
      }
      .align(Alignment.Center)
      Image($r('app.media.app_icon'))
        .width($r('app.float.common_size14'))
        .height($r('app.float.common_size14'))
        .borderRadius(3)
    }
    .draggable(false)
    .focusable(true)
    .align(Alignment.BottomEnd)
  }

  private clickConfirm() {
    try {
      HiLog.info(TAG, 'SecurityWarning confirm start');
      const context = GlobalHolder.getInstance().getUIExtensionContext();
      let promise = dataPreferences.getPreferences(context, SecurityData.SecurityWarning);
      if (ObjectUtil.isNullOrUndefined(promise)) {
        HiLog.error(TAG, 'get preferences is null');
        return;
      }
      promise.then(async (securityData) => {
        await securityData.put(SecurityData.SecurityWarning, SecurityWarning.AGREE);
        await securityData.flush();
        this.isShowPickerTips = false;
        HiLog.info(TAG, 'SecurityWarning confirm success');
      }).catch((err: BusinessError) => {
        HiLog.error(TAG, `Failed to get preferences. code = ${err.code} , message = ${err.message}`);
      })
    } catch (err) {
      HiLog.error(TAG, `Failed to closeDialog. code = ${err?.code} , message = ${err?.message}`);
    }
  }
}