/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import measure from '@ohos.measure';
import resourceManager from '@ohos.resourceManager';
import { HiLog, ResourceUtil, Constant, UiUtil } from '@ohos/common';
import { systemParameterEnhance } from '@kit.BasicServicesKit';

@CustomDialog
@Component
export struct TitleAndContentAndDoubleButtonDialog {
  private TAG: string = 'TitleAndContentAndDoubleButtonDialog';
  controller?: CustomDialogController;
  title: Resource = $r('app.string.cancel');
  content: Resource = $r('app.string.cancel');
  confirmText: ResourceStr = $r('app.string.delete_tag_no_name');
  cancelText: ResourceStr = $r('app.string.cancel');
  confirmFontColor: Resource = $r('sys.color.ohos_id_color_warning');
  cancelFontColor: Resource = $r('sys.color.ohos_id_text_color_active');
  cancel: () => void = () => {};
  confirm: () => void = () => {};
  /**
   * 判断是否是深色模式
   */
  @StorageProp('isDarkMode') isDarkMode: boolean = false;

  aboutToAppear() {
    HiLog.info(this.TAG, 'TextAndDoubleButtonDialog');
  }

  // 判断是否包含换行符
  hasNewLine(resStr: ResourceStr): boolean {
    let tempStr: string;
    if (typeof (resStr) !== 'string') {
      let resourceManager: resourceManager.ResourceManager = getContext(this).resourceManager;
      tempStr = resourceManager.getStringSync(resStr.id);
    } else {
      tempStr = resStr;
    }
    return tempStr.includes('\n');
  }

  getTextAlign(): TextAlign {
    let textWidth = measure.measureText({
      textContent: ResourceUtil.getStringByResource(this.content),
      fontSize: 16,
      fontWeight: FontWeight.Regular,
    });
    if ((px2vp(textWidth) > 352) || this.hasNewLine(this.content)) { // 获取文字宽度，单行居中，多行居左
      return TextAlign.Start;
    }
    return TextAlign.Center;
  }

  build() {
    Column() {
      Text(this.title)
        .maxLines(2)
        .wordBreak(WordBreak.BREAK_ALL)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center)
        .maxFontSize(20)
        .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)
        .constraintSize({
          minHeight: 26
        })
        .fontWeight(FontWeight.Bold)
        .padding({ top: 15, right: 24, bottom: 15, left: 24 })
        .width('100%')
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
      if (UiUtil.getFontSize() < Constant.BIG_MODE.BIG_MODE_3_2x) {
        Text(this.content)
          .textAlign(this.getTextAlign())
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .lineHeight(21)
          .fontWeight(FontWeight.Medium)
          .padding({ top: 0, right: 24, bottom: 16, left: 24 })
          .width('100%')
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
        Row() {
          Button({ type: ButtonType.Normal, stateEffect: true }) {
            Text(this.cancelText)
              .textAlign(TextAlign.Center)
              .fontWeight(FontWeight.Medium)
              .fontSize($r('sys.float.ohos_id_text_size_button1'))
              .fontColor(this.cancelFontColor)
          }
          .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
          .borderRadius($r('sys.float.ohos_id_corner_radius_default_s'))
          .width(176)
          .constraintSize({
            minHeight: 40
          })
          .margin({ right: 16 })
          .onClick(() => {
            this.cancel();
            if (this.controller) {
              this.controller.close();
            }
          })

          Button({ type: ButtonType.Normal, stateEffect: true }) {
            Text(this.confirmText)
              .textAlign(TextAlign.Center)
              .fontWeight(FontWeight.Medium)
              .fontSize($r('sys.float.ohos_id_text_size_button1'))
              .fontColor(this.confirmFontColor)
          }
          .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
          .borderRadius($r('sys.float.ohos_id_corner_radius_default_s'))
          .width(176)
          .constraintSize({
            minHeight: 40
          })
          .onClick(() => {
            this.confirm();
            if (this.controller) {
              this.controller.close();
            }
          })
        }
        .padding({ right: 16, bottom: 16, left: 16 })
      } else {
        this.ageAppropriateTextAndButton()
      }
    }
    .width(400)
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_dialog'))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .outline({width: 1, color: this.isDarkMode ? '#66000000' : '#19000000', radius: $r('sys.float.ohos_id_corner_radius_dialog')})
    .border({width: 1, color: '#33FFFFFF'})
  }

  @Builder
  ageAppropriateTextAndButton() {
    Text(this.content)
      .textAlign(this.getTextAlign())
      .fontSize(20)
      .constraintSize({
        minHeight: 21
      })
      .textOverflow({ overflow:TextOverflow.MARQUEE })
      .fontWeight(FontWeight.Medium)
      .padding({ top: 0, right: 24, bottom: 16, left: 24 })
      .width('100%')
      .fontColor($r('sys.color.ohos_id_color_text_primary'))
    Column() {
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Text(this.cancelText)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.ohos_id_text_size_button1'))
          .fontColor(this.cancelFontColor)
      }
      .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
      .borderRadius($r('sys.float.ohos_id_corner_radius_default_s'))
      .constraintSize({
        minHeight: 40,
        minWidth: 176
      })
      .margin({ right: 16 })
      .onClick(() => {
        this.cancel();
        if (this.controller) {
          this.controller.close();
        }
      })

      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Text(this.confirmText)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.ohos_id_text_size_button1'))
          .fontColor(this.confirmFontColor)
      }
      .margin({ top: 12})
      .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
      .borderRadius($r('sys.float.ohos_id_corner_radius_default_s'))
      .constraintSize({
        minHeight: 40,
        minWidth: 216
      })
      .onClick(() => {
        this.confirm();
        if (this.controller) {
          this.controller.close();
        }
      })
    }
    .padding({ right: 16, bottom: 16, left: 16 })
  }
}
