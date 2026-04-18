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
import { FilePickerUtil, HiLog, ToolBarStyle } from '@ohos/common';
import { UserState } from '@ohos/common/src/main/ets/const/Constant';
import { TitleBarAnimation } from '../model/TitleBarAnimation';
import { TitleMenuItem } from '../model/TitleMenuItem';
import { DragManager } from '@ohos/common';
import { CompId } from '@ohos/common/src/main/ets/const/CompId';
import { inputMethod } from '@kit.IMEKit';
import { LengthMetrics } from '@kit.ArkUI';

const TAG = 'LeftIconComp';

@Component
export struct LeftIconComp {
  // 返厂动效是否展示（折叠屏分栏）
  @StorageLink('isAnimationShow') isAnimationShow: boolean = false;
  // 左侧icon
  @Link leftIcon: TitleMenuItem;
  @Prop userState: UserState;
  @State isPress: boolean = false;
  @Prop fontColor: ResourceStr = $r('sys.color.ohos_id_color_primary');
  @Prop isHorizontal: boolean = false;
  private isShowPage: boolean = false;
  private titleAnimation: TitleBarAnimation = new TitleBarAnimation();
  private isPickerFlag: boolean = FilePickerUtil.getStartOptionsFromStorage().pickerFlag;

  @Styles
  pressedStyles() {
    .backgroundColor(this.isHorizontal ? $r('sys.color.ohos_id_color_click_effect_dark') : $r('sys.color.ohos_id_color_click_effect'))
  }

  @Styles
  normalStyles() {
    .backgroundColor(this.isHorizontal ? $r('sys.color.ohos_id_color_button_normal_dark') : $r('sys.color.ohos_id_color_button_normal'))
  }

  build() {
    //  icon1 左边操作icon
    if (this.leftIcon.isShown) {
      Column() {
        SymbolGlyph(this.leftIcon.icon)
          .draggable(false)
          .fontSize($r('app.float.common_size24'))
          .fontColor([this.fontColor])
          .focusable(true)
          .width($r('app.float.common_size24'))
          .height($r('app.float.common_size24'))
      }
      .id(CompId.LEFT_ICON)
      .accessibilityGroup(true)
      .accessibilityText(this.leftIcon.name)
      .accessibilityRole(AccessibilityRoleType.BUTTON)
      .transition(this.titleAnimation.openAnimation(this.titleAnimation.leftIcon))
      .size({ width: $r('app.float.common_size40'), height: $r('app.float.common_size40') })
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .margin({
        top: LengthMetrics.resource(this.isPickerFlag ? $r('sys.float.padding_level8') : $r('sys.float.padding_level0'))
      })
      .borderRadius(ToolBarStyle.ITEM_BORDER_RADIUS)
      .stateStyles({
        pressed: this.pressedStyles,
        normal: this.normalStyles
      })
      .onDrop((event: DragEvent | undefined, extraParams: string | undefined) => {
        HiLog.info(TAG, 'onDrop');
        if (this.leftIcon.dragEnable) {
          DragManager.getInstance().onDropLeaveAnimation(() => {
            this.isPress = false;
          })
        }
      })
      .onDragEnter((event?: DragEvent, extraParams?: string) => {
        HiLog.info(TAG, 'onDragEnter');
        if (this.leftIcon.dragEnable) {
          DragManager.getInstance().onDropEnterAnimation((isSelect: boolean) => {
            this.isPress = isSelect;
          }, () => {
            this.leftIcon.action();
          })
        }
      })
      .onDragLeave((event?: DragEvent, extraParams?: string) => {
        HiLog.info(TAG, 'onDragLeave');
        if (this.leftIcon.dragEnable) {
          DragManager.getInstance().onDropLeaveAnimation(() => {
            this.isPress = false;
          })
        }
      })
      .onClick(() => {
        // 临时方案，搜索页面返回键盘不消失，底座焦点问题
        if (this.isShowPage) {
          inputMethod.getController().hideTextInput();
        }
        this.leftIcon.action();
      })
    }
  }

}