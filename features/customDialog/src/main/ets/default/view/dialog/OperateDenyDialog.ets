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
import { HiLog, ObjectUtil } from '@ohos/common';
import { LengthMetrics } from '@kit.ArkUI';

@CustomDialog
export struct OperateDenyDialog {
  private TAG: string = 'OperateDenyDialog';
  controller?: CustomDialogController;
  contentFirstLine: Resource | string = '';
  contentSecondLine: Resource | string = '';
  buttonText: Resource | string = '';
  /**
   * 判断是否是深色模式
   */
  @StorageProp('isDarkMode') isDarkMode: boolean = false;

  aboutToAppear() {
    HiLog.info(this.TAG, 'OperateDenyDialog');
  }

  build() {
    Column() {
      Text(this.contentFirstLine)
        .fontSize($r('app.float.common_font_size20'))
        .fontWeight(FontWeight.Bold)
        .maxFontScale(2)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .padding({ top: LengthMetrics.vp(16), bottom: LengthMetrics.vp(8), start: LengthMetrics.vp(16)})
        .width('100%')
      Text(this.contentSecondLine)
        .fontWeight(FontWeight.Medium)
        .constraintSize({
          minHeight: 24
        })
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .padding({ top: LengthMetrics.vp(8), bottom: LengthMetrics.vp(16), start: LengthMetrics.vp(16) })
        .width('100%')
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
      Row() {
        Button({type: ButtonType.Normal, stateEffect: true}) {
          Text(this.buttonText)
            .textAlign(TextAlign.Center)
            .fontSize($r('sys.float.ohos_id_text_size_button1'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
        }
        .borderRadius($r('sys.float.corner_radius_level4'))
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .width(362)
        .constraintSize({
          minHeight: 40
        })
        .margin({ end: LengthMetrics.vp(16) })
        .onClick(() => {
          if (this.controller) {
            this.controller.close();
          }
          HiLog.info(this.TAG, 'operateDenyDialog close, controller : ' + ObjectUtil.isNullOrUndefined(this.controller));
        })
      }
      .padding({ right: 16, bottom: 16, left: 16 })
    }
    .width(394)
    .borderRadius($r('sys.float.ohos_id_corner_radius_dialog'))
    .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .outline({width: 1, color: this.isDarkMode ? '#66000000' : '#19000000', radius: $r('sys.float.ohos_id_corner_radius_dialog')})
    .border({width: 1, color: '#33FFFFFF'})
  }
}