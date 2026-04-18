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

import { TitleMenuItem } from '../model/TitleMenuItem';
import { TopMenuItem } from '../model/TopMenuItem';
import { TopMenu } from './TopMenu';
import {
  CompId,
  FilePickerUtil,
  ResourceUtil,
  ToolBarStyle,
  HiLog,
  HoverPopupStyle,
  ObjectUtil,
  CommonPreferenceUtil,
  StringUtil,
  Constant,
  PAGE_ROUTE_CONST,
  FileInfo,
} from '@ohos/common';
import { MENU_NAME } from '../constant/MenuConstant';
import { LengthMetrics } from '@kit.ArkUI';
import { FileDeleteDialog } from '@ohos/customDialog/indexPhoneOnly';
import { JSON } from '@kit.ArkTS';

const TAG = 'RightMenuComp';
const FILE_DELETE_DIALOG_WIDTH: number = 375;
const ARROW_TO_RIGHT_OFFSET: number = 33;
const ITEM_INTERVAL_WIDTH: number = 8;
const PREVIEW_FILE_COUNT: number = 1;

@Component
export struct RightMenuComp {
  @Link iconArr: Array<TitleMenuItem>;
  @Link topMenu: Array<TopMenuItem>;
  @Prop menuAnimation: TransitionEffect = TransitionEffect.IDENTITY;
  @Prop fileCount: number = 0;
  @Prop previewFile: FileInfo = new FileInfo();
  @State showPopoverDialog: boolean = false;
  private previewPageFrom: string = '';
  private confirmDeleteFun: (isHardDelete: boolean) => void = () => {
  };
  private menuType: string = ResourceUtil.getStringByResource($r('app.string.more'));
  private isPickerFlag: boolean = FilePickerUtil.getStartOptionsFromStorage().pickerFlag;
  @Prop isListView: boolean = false;
  @State showTopMenu: boolean = false;
  // Popup当前规格在宿主不可见时，不会自动消失，需要在代码中控制其关闭
  @State isShowPopup: boolean = false;
  @Prop fontColor: ResourceStr = $r('sys.color.ohos_id_color_primary');
  @Prop isHorizontal: boolean = false;

  @Styles
  pressedStyles() {
    .backgroundColor(this.isHorizontal ? $r('sys.color.ohos_id_color_click_effect_dark') :
      $r('sys.color.ohos_id_color_click_effect'))
  }

  @Styles
  normalStyles() {
    .backgroundColor(this.isHorizontal ? $r('sys.color.ohos_id_color_button_normal_dark') :
      $r('sys.color.ohos_id_color_button_normal'))
  }

  build() {
    Row() {
      ForEach(this.iconArr, (item: TitleMenuItem) => {
        if (item.isShown) {
          if (item.isMenu) {
            this.menuShow(item);
          } else {
            if (item.name?.id === MENU_NAME.delete.id) {
              this.deleteIconShow(item);
            } else {
              this.iconShow(item);
            }
          }
        }
      }, (item: TitleMenuItem) => JSON.stringify(item))
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .onVisibleAreaChange([0.0], (isExpand: boolean, radio: number) => {
      // 完全不可见时，不显示绑定的气泡
      if (!isExpand && radio <= 0.0) {
        this.isShowPopup = false;
        return;
      }
      this.isShowPopup = true;
    })
  }

  @Builder
  menuShow(item: TitleMenuItem) {
    Column() {
      SymbolGlyph(item.icon)
        .width(this.isPickerFlag ? $r('app.float.common_size18') : $r('app.float.common_size24'))
        .height(this.isPickerFlag ? $r('app.float.common_size18') : $r('app.float.common_size24'))
        .draggable(false)
        .fontSize($r('app.float.common_size24'))
        .fontColor([$r('sys.color.icon_primary')])
    }
    .accessibilityRole(AccessibilityRoleType.BUTTON)
    .accessibilityText($r('app.string.more'))
    .id(CompId.TOP_MENU)
    .stateStyles({
      pressed: this.pressedStyles,
      normal: this.normalStyles
    })
    .borderRadius(ToolBarStyle.ITEM_BORDER_RADIUS)
    .padding(this.isPickerFlag ? $r('sys.float.padding_level5') : $r('sys.float.padding_level4'))
    .margin({
      start: LengthMetrics.vp(ITEM_INTERVAL_WIDTH),
      top: this.isPickerFlag ? LengthMetrics.vp(19) : LengthMetrics.vp(0)
    })
    .bindMenu(this.showTopMenu, this.TopMenuBuilder(), {
      placement: Placement.BottomLeft,
      offset: { x: -12, y: -8 },
      backgroundBlurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
      onDisappear: () => {
        this.showTopMenu = false;
      }
    })
    .onClick(() => {
      this.showTopMenu = true;
      item.action();
    })
    .opacity(item.clickable ? $r('app.float.common_opacity10') : $r('sys.float.ohos_id_alpha_content_secondary'))
  }

  @Builder
  dialogBuilder() {
    FileDeleteDialog({
      title: $r('app.plural.delete_confirm_dialog_title', PREVIEW_FILE_COUNT, PREVIEW_FILE_COUNT),
      content: $r('app.string.softDelete'),
      confirmButtonText: $r('app.string.delete'),
      operationFileList: [this.previewFile],
      cancel: () => {
        this.showPopoverDialog = false;
      },
      confirm: (isHardDelete: boolean): void => {
        this.confirmDeleteFun(isHardDelete);
        this.showPopoverDialog = false;
      },
      isShowCheckBox: true,
      fromPage: this.previewPageFrom
    })
  }

  @Builder
  iconShow(item: TitleMenuItem) {
    if (item.isText) {
      this.TextButton(item)
    } else {
      Column() {
        SymbolGlyph(item.icon)
          .width(this.isPickerFlag ? $r('app.float.common_size18') : $r('app.float.common_size24'))
          .height(this.isPickerFlag ? $r('app.float.common_size18') : $r('app.float.common_size24'))
          .draggable(false)
          .fontSize(this.isPickerFlag ? $r('app.float.common_size18') : $r('app.float.common_size24'))
          .fontColor([this.fontColor])
      }
      .alignItems(HorizontalAlign.Center)
      .enabled(item.clickable)
      .size({ width: $r('app.float.common_size40'), height: $r('app.float.common_size40') })
      .align(Alignment.Center)
      .justifyContent(FlexAlign.Center)
      .showProperty()
      .accessibilityText(item.name)
      .accessibilityRole(item.accessibilityRoleType)
      .onClick(() => {
        item.action();
      })
      .opacity(item.clickable ? $r('app.float.common_opacity10') : $r('sys.float.ohos_id_alpha_highlight_bg'))
      .stateStyles({
        pressed: this.pressedStyles,
        normal: this.normalStyles
      })
      .opacity(item.clickable ? $r('app.float.common_opacity10') : $r('sys.float.ohos_id_alpha_content_secondary'))
    }
  }

  @Builder
  deleteIconShow(item: TitleMenuItem) {
    Column() {
      SymbolGlyph(item.icon)
        .width($r('app.float.common_size24'))
        .height($r('app.float.common_size24'))
        .draggable(false)
        .fontSize($r('app.float.common_size24'))
        .fontColor([this.fontColor])
    }
    .alignItems(HorizontalAlign.Center)
    .enabled(item.clickable)
    .padding($r('sys.float.padding_level4'))
    .showProperty()
    .accessibilityText(item.name)
    .accessibilityRole(item.accessibilityRoleType)
    .onClick(() => {
      this.showPopoverDialog = true;
      this.confirmDeleteFun = (isHardDelete: boolean) => {
        item.action(isHardDelete);
      }
    })
    .opacity(item.clickable ? $r('app.float.common_opacity10') : $r('sys.float.ohos_id_alpha_highlight_bg'))
    .stateStyles({
      pressed: this.pressedStyles,
      normal: this.normalStyles
    })
    .bindPopup(this.showPopoverDialog, {
      builder: this.dialogBuilder(),
      enableArrow: true,
      offset: { x: -px2vp(ResourceUtil.getResourceNumberById($r('sys.float.margin_right').id)) },
      width: FILE_DELETE_DIALOG_WIDTH,
      arrowOffset: undefined,
    })
    .opacity(item.clickable ? $r('app.float.common_opacity10') : $r('sys.float.ohos_id_alpha_content_secondary'))
  }

  @Builder
  TextButton(item: TitleMenuItem) {
    Column() {
      Text(item.icon)
        .fontSize($r('app.float.common_font_size14'))
        .fontWeight(FontWeight.Medium)
        .height(this.isPickerFlag ? $r('app.float.common_size18') : $r('app.float.common_size24'))
        .draggable(false)
        .textAlign(TextAlign.Center)
        .minFontSize($r('app.float.common_font_size9'))
        .maxFontSize($r('app.float.common_font_size14'))
        .maxLines(Constant.LINE_COUNT.ONE)
        .maxFontScale(Constant.BIG_MODE.BIG_MODE_1x)
    }
    .accessibilityText(item.name)
    .accessibilityRole(item.accessibilityRoleType)
    .id(CompId.TOP_BUTTON)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .padding({
      top: this.isPickerFlag ? $r('sys.float.padding_level5') : $r('sys.float.padding_level4'),
      bottom: this.isPickerFlag ? $r('sys.float.padding_level5') : $r('sys.float.padding_level4'),
      right: $r('sys.float.padding_level8'),
      left: $r('sys.float.padding_level8')
    })
    .borderRadius(ToolBarStyle.ITEM_BORDER_RADIUS)
    // 多选按钮时通过fileCount判断
    .enabled(item.icon.id === $r('app.string.multiple_choices').id ? this.fileCount > 0 : item.clickable)
    .stateStyles({
      pressed: this.pressedStyles,
      normal: this.normalStyles
    })
    .constraintSize({
      maxWidth: $r('app.float.common_size96')
    })
    .margin({
      start: LengthMetrics.vp(ITEM_INTERVAL_WIDTH),
      top: this.isPickerFlag ? LengthMetrics.vp(19) : LengthMetrics.vp(0)
    })
    .onClick(() => {
      item.action();
    })
    .opacity((item.icon.id === $r('app.string.multiple_choices').id ? this.fileCount > 0 : item.clickable) ?
      $r('app.float.common_opacity10') : $r('sys.float.ohos_id_alpha_content_secondary'))
  }

  @Styles
  showProperty() {
    .id(CompId.TOP_MENU)
    .margin({
      start: LengthMetrics.vp(ITEM_INTERVAL_WIDTH),
      top: LengthMetrics.resource(this.isPickerFlag ? $r('sys.float.padding_level8') : $r('sys.float.padding_level0'))
    })
    .borderRadius(ToolBarStyle.ITEM_BORDER_RADIUS)

  }

  @Builder
  TopMenuBuilder() {
    TopMenu({
      topMenu: $topMenu,
      fileCount: this.fileCount,
      hideMenu: () => {
        this.showTopMenu = false;
      }
    })
  }
}