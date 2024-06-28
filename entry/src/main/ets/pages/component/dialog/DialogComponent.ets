/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023. All rights reserved.
 */

@Styles
function pressStyles() {
  .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
}

@Styles
function normalStyles() {
  .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
}

@Component
export struct DialogButton {
  text?: Resource;
  color: Resource | string = $r('sys.color.ohos_id_color_text_primary_activated');
  bgColor: Resource | string = $r('sys.color.ohos_id_color_background_transparent');
  @Prop isDisabled: boolean = false;
  click?: Function;
  compId?: Resource = $r('app.string.confirm');

  build() {
    Row() {
      Row() {
        Text(this.text)
          .fontSize($r('sys.float.ohos_id_text_size_button1'))
          .fontColor(this.color)
          .fontWeight(FontWeight.Medium)
          .textCase(TextCase.UpperCase)
      }.height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        if ((!this.click) || this.isDisabled) {
          return
        }
        this.click()
      })
    }
    .id(this.text === this.compId ? 'dialog_confirm' : 'dialog_cancel')
    .enabled(!this.isDisabled)
    .height(40)
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
      .margin({ left: 8, right: 8 })
      .height($r('app.float.divider_height24'))
      .color($r('sys.color.ohos_id_color_list_separator'))
  }
}

