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
  CommonUtil,
  CompId,
  Constant,
  HiLog,
  ResourceUtil,
  UiUtil
} from '@ohos/common';

@Styles function pressStyles () {
  .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
}

@Styles function normalStyles () {
  .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
}

@Styles
function buttonPressedStyles() {
  .backgroundColor($r('sys.color.ohos_id_color_hover'))
}

@Styles
function buttonNormalStyles() {
  .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
}

@Component
export struct DialogTitleWithButton {
  title?: ResourceStr;
  textAlign?: TextAlign = TextAlign.Center;
  // 大字体间距
  @State private bigFontTitleAutoSpace: ResourceStr =
    UiUtil.getFontSize() >= Constant.BIG_MODE.BIG_MODE_1_75x ? $r('app.float.common_size12') :
    $r('app.float.common_mark_x0');
  @Prop isButtonDisabled: boolean = false;
  cancelFunc: Function = () => {};
  confirmFunc: Function = () => {};

  build() {
    Row() {
      Column() {
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontColor([$r('sys.color.ohos_id_color_primary')])
          .fontSize($r('app.float.common_size18'))
          .draggable(false)
          .focusable(true)
          .id(CompId.LEFT_ICON)
      }
      .accessibilityText(ResourceUtil.getStringByResource($r('app.string.cancel')))
      .width($r('app.float.common_size40'))
      .height($r('app.float.common_size40'))
      .alignItems(HorizontalAlign.Center)
      .padding($r('app.float.common_size11'))
      .borderRadius($r('app.float.common_size24'))
      .stateStyles({
        pressed: buttonPressedStyles,
        normal: buttonNormalStyles
      })
      .enabled(true)
      .onClick(() => { this.cancelFunc(); })

      Text(this.title)
        .accessibilityLevel('yes')
        .fontColor($r('sys.color.ohos_id_color_foreground'))
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bold)
        .maxFontScale(2)
        .id(CompId.DIALOG_TITLE)
        .textAlign(this.textAlign)
        .onSizeChange(() => {
          this.bigFontTitleAutoSpace = UiUtil.getFontSize() >= Constant.BIG_MODE.BIG_MODE_1_75x ? $r('app.float.common_size12') :
          $r('app.float.common_mark_x0');
        })
        .margin({ left: $r('app.float.common_size8') })

      Blank()
      Column() {
        SymbolGlyph($r('sys.symbol.checkmark'))
          .fontColor([$r('sys.color.ohos_id_color_primary')])
          .fontSize($r('app.float.common_size18'))
          .draggable(false)
          .focusable(true)
          .id(CompId.DIALOG_CONFIRM)
      }
      .accessibilityText(ResourceUtil.getStringByResource($r('app.string.confirm')))
      .width($r('app.float.common_size40'))
      .height($r('app.float.common_size40'))
      .alignItems(HorizontalAlign.Center)
      .padding($r('app.float.common_size11'))
      .borderRadius($r('app.float.common_size24'))
      .stateStyles({
        pressed: buttonPressedStyles,
        normal: buttonNormalStyles
      })
      .margin({ left: $r('app.float.common_margin8') })
      .enabled(!this.isButtonDisabled)
      .onClick(() => { this.confirmFunc(); })
    }
    .margin({
      top: this.bigFontTitleAutoSpace,
      bottom: this.bigFontTitleAutoSpace,
      left: $r('sys.float.padding_level12'),
      right: $r('sys.float.padding_level12'),
    }) // 大字体布局顶部和标题底部留出12vp
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .constraintSize({
      // 适老化适配，将文本框的高度设置为可调整，当文字变大时文本框会跟随变高。从而解决文字与图片叠加问题
      minHeight: $r('app.float.common_size56')
    })
  }
}

@Component
export struct DialogTitle {
  title?: ResourceStr;
  textAlign?: TextAlign = TextAlign.Center;
  // 大字体间距
  @State private bigFontTitleAutoSpace: ResourceStr =
    UiUtil.getFontSize() >= Constant.BIG_MODE.BIG_MODE_1_75x ? $r('app.float.common_size12') :
    $r('app.float.common_mark_x0');

  build() {
    Column() {
      Text(this.title)
        .accessibilityLevel('yes')
        .fontColor($r('sys.color.ohos_id_color_foreground'))
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .maxFontScale(2)
        .id(CompId.DIALOG_TITLE)
        .textAlign(this.textAlign)
        .onSizeChange(() => {
          this.bigFontTitleAutoSpace = UiUtil.getFontSize() >= Constant.BIG_MODE.BIG_MODE_1_3x ? $r('app.float.common_size12') :
          $r('app.float.common_mark_x0');
        })
    }
    .padding({
      top: $r('app.float.common_padding12'),
      bottom: $r('app.float.common_padding12')
    })
    .margin({
      top: this.bigFontTitleAutoSpace,
      bottom: this.bigFontTitleAutoSpace,
      left: $r('sys.float.padding_level12'),
      right: $r('sys.float.padding_level12'),
    }) // 大字体布局顶部和标题底部留出12vp
    .justifyContent(FlexAlign.Center)
    .constraintSize({
      // 适老化适配，将文本框的高度设置为可调整，当文字变大时文本框会跟随变高。从而解决文字与图片叠加问题
      minHeight: $r('app.float.common_size56')
    })
  }
}

@Component
export struct DialogButton {
  text?: ResourceStr;
  color: Resource = $r('sys.color.ohos_id_color_text_primary_activated');
  bgColor: Resource = $r('sys.color.ohos_id_color_background_transparent');
  @Prop isDisabled: boolean = false;
  click?: Function;
  compId?: Resource = $r('app.string.confirm');
  // 大字体间距
  @State private bigFontButtonAutoSpace: ResourceStr =
    UiUtil.getFontSize() >= Constant.BIG_MODE.BIG_MODE_1_75x ? $r('app.float.common_size8') :
    $r('app.float.common_mark_x0');

  TAG = 'DialogButton';

  build() {
    Row() {
      Row() {
        Text(this.text)
          .fontSize($r('sys.float.ohos_id_text_size_button1'))
          .fontColor(this.color)
          .maxFontScale(2)
          .fontWeight(FontWeight.Medium)
          .textCase(TextCase.Normal)
          .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)
          .onSizeChange(() => {
            this.bigFontButtonAutoSpace =
              UiUtil.getFontSize() >= Constant.BIG_MODE.BIG_MODE_1_75x ? $r('app.float.common_size8') :
              $r('app.float.common_mark_x0');
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: this.bigFontButtonAutoSpace, bottom: this.bigFontButtonAutoSpace })
    }
    .accessibilityLevel('yes')
    .accessibilityRole(AccessibilityRoleType.BUTTON)
    .onClick(() => {
      HiLog.info(this.TAG, `DialogButton click`);
      if ((!this.click) || this.isDisabled) {
        HiLog.warn(this.TAG, `DialogButton disabled`);
        return;
      }
      // 传入对应按键的名称
      if (CommonUtil.isFastClick(this.text)) {
        return;
      }
      this.click()
    })
    .id(this.text === this.compId ? CompId.DIALOG_CONFIRM : CompId.DIALOG_CANCEL)
    .enabled(!this.isDisabled)
    .constraintSize({
      minHeight: $r('app.float.common_line_height40')
    })
    .layoutWeight(1)
    .backgroundColor(this.bgColor)
    .stateStyles({
      normal: normalStyles,
      pressed: pressStyles
    })
    .opacity(this.isDisabled ? $r('app.float.common_opacity5') : $r('app.float.common_opacity10'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_dialog'))
  }
}

@Component
export struct DialogButtonDivider {
  build() {
    Divider().vertical(true)
      .margin({ left: $r('app.float.common_margin8'), right: $r('app.float.common_margin8')})
      .height($r('app.float.divider_height24'))
      .color($r('sys.color.ohos_id_color_list_separator'))
  }
}
