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

import { EventBus,
  ResourceUtil,
  SortOrder,
  ToolBarStyle,
  ACCESSIBILITY_LEVEL,
  Constant,
  TopMenuDivider,
  ViewMode,
  CompId,
  UiUtil
} from '@ohos/common';
import { MENU_NAME } from '../constant/MenuConstant';
import { TopMenuItem } from '../model/TopMenuItem';
import { LengthMetrics } from '@kit.ArkUI';

@Styles
function normalStyles() {
  .backgroundColor($r('app.color.transparent_color'))
  .borderRadius(ToolBarStyle.TOOLBAR_PADDING_LEFT_AND_RIGHT)
}

const TAG = 'TopMenu';
// 手机多选点击延时处理， 解决响应时延
const MULTI_CHOICE_HANDLE_DELAY_TIME: number = 10;

@Component
export struct TopMenu {
  @Link topMenu: Array<TopMenuItem>;
  @Prop fileCount: number;
  @Consume isDesc: boolean;
  @Consume order: string;
  @Consume viewMode: string;
  private isBigMode: Boolean = UiUtil.getFontSize() >= Constant.BIG_MODE.BIG_MODE_3_2x;
  private isClick: boolean = false;
  private menuHeight: Resource = $r('app.float.common_size48');
  hideMenu: () => void = () => {
  };

  build() {
    Menu() {
      ForEach(this.topMenu, (item: TopMenuItem, index: number) => {
        MenuItem() {
          Column() {
            if (item.type === SortOrder.ADD) {
              this.AddItem(item);
            } else if ((item.type === ViewMode.LIST) || (item.type === ViewMode.GRID)) {
              this.ListOrGridItem(item);
            } else if ([SortOrder.ABOUT, SortOrder.SET_UP].includes(item.type as SortOrder)) {
              this.AboutItem(item);
            } else if (
              item.type === SortOrder.DEFAULT ||
              item.type === SortOrder.NAME ||
              item.type === SortOrder.TYPE ||
              item.type === SortOrder.SIZE ||
              item.type === SortOrder.TIME) {
              this.DetailItem(item);
            } else {
              this.OtherItem(item);
            }
          }
        }
        .accessibilityLevel(ACCESSIBILITY_LEVEL.NO)
        .margin({ left: $r('sys.float.padding_level2'), right: $r('sys.float.padding_level2') })
        this.AddDivider(index, item);
      });
    }
    .padding({ top: $r('sys.float.padding_level2'), bottom: $r('sys.float.padding_level2') })
    .width($r('app.float.common_size224'))
  }


  @Builder
  SelectedImage() {
    SymbolGlyph($r('sys.symbol.checkmark'))
      .fontSize($r('app.float.common_size24'))
      .fontColor([$r('sys.color.icon_primary')])
      .width($r('app.float.common_size24'))
      .height($r('app.float.common_size24'))
      .draggable(false)
      .opacity($r('app.float.common_opacity8'))
      .margin({ end: LengthMetrics.resource($r('app.float.common_size15')) })
  }

  @Builder
  AddDivider(index: number, item: TopMenuItem) {
    if (index !== (this.topMenu.length - 1)) {
        Divider()
          .vertical(false)
          .strokeWidth(item.dividerType === TopMenuDivider.TYPE_ONE ? 8 : '1px')
          .color(item.dividerType === TopMenuDivider.TYPE_ONE ? $r('sys.color.comp_background_tertiary') :
          $r('sys.color.comp_divider'))
          .width('100%')
          .padding(item.dividerType === TopMenuDivider.TYPE_ONE ? {} : {
            left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8')
          }).accessibilityLevel(ACCESSIBILITY_LEVEL.NO)
    }
  }

  @Builder
  OtherItem(item: TopMenuItem) {
    Row() {
      Text(item.name)
        .constraintSize({
          minHeight: $r('app.float.common_size21')
        })
        .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
        .margin({
          left: $r('sys.float.padding_level6'),
          right: $r('sys.float.padding_level6'),
          top: this.isBigMode ? $r('sys.float.padding_level12') : 0,
          bottom: this.isBigMode ? $r('sys.float.padding_level12') : 0
        })
    }
    .accessibilityText(ResourceUtil.getStringByResource(item.name))
    .id(item.type)
    .width('100%')
    .constraintSize({
      minHeight: this.menuHeight
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .stateStyles({
      normal: normalStyles
    })
    .onClick(() => {
      this.itemClick(item);
    })
  }

  @Builder
  DetailItem(item: TopMenuItem) {
    Row() {
      Row() {
        Text(item.name)
          .constraintSize({
            minHeight: $r('app.float.common_size21')
          })
          .accessibilityText(ResourceUtil.getStringByResource(item.name))
          .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
          .margin({
            start: LengthMetrics.resource($r('sys.float.padding_level6')),
            top: this.isBigMode ? LengthMetrics.resource($r('sys.float.padding_level12')) : LengthMetrics.vp(0),
            bottom: this.isBigMode ? LengthMetrics.resource($r('sys.float.padding_level12')) : LengthMetrics.vp(0)
          })
        if (this.order === item.type && this.order !== SortOrder.DEFAULT) {
          SymbolGlyph(this.isDesc ? $r('sys.symbol.text_and_arrow_down') : $r('sys.symbol.text_and_arrow_up'))
            .fontColor([$r('sys.color.ohos_id_color_primary')])
            .fontWeight(FontWeight.Normal)
            .constraintSize({
              minHeight: $r('app.float.common_size24')
            })
            .width($r('app.float.common_size24'))
            .fontSize($r('app.float.common_size24'))
            .opacity($r('app.float.common_opacity8'))
            .draggable(false)
            .margin({ start: LengthMetrics.resource($r('app.float.common_size8')) })
            .id(this.isDesc ? CompId.MENU_DOWN : CompId.MENU_UP)
            .accessibilityText(this.isDesc ? ResourceUtil.getStringByResource($r('app.string.descending')) :
            ResourceUtil.getStringByResource($r('app.string.ascending')))
        }
      }
      if (this.order === item.type) {
        this.SelectedImage();
      }
    }
    .id(item.type)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .constraintSize({
      minHeight: this.menuHeight
    })
    .stateStyles({
      normal: normalStyles
    })
    .onClick(() => {
      item.action?.();
    })
    .accessibilitySelected(this.order === item.type)
    .accessibilityChecked(undefined)
  }

  @Builder
  AboutItem(item: TopMenuItem) {
    Row() {
      Text(item.name)
        .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
        .fontWeight(FontWeight.Medium)
        .margin({
          left: $r('sys.float.padding_level6'),
          right: $r('sys.float.padding_level6'),
          top: this.isBigMode ? $r('sys.float.padding_level12') : 0,
          bottom: this.isBigMode ? $r('sys.float.padding_level12') : 0
        })
    }
    .id(item.type)
    .width('100%')
    .constraintSize({
      minHeight: this.menuHeight
    })
    .onClick(() => {
      this.itemClick(item);
    })
    .stateStyles({
      normal: normalStyles
    })
  }

  @Builder
  ListOrGridItem(item: TopMenuItem) {
    Row() {
      Text(item.name)
        .constraintSize({
          minHeight: $r('app.float.common_size21')
        })
        .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
        .margin({
          start: LengthMetrics.resource($r('sys.float.padding_level6')),
          top: this.isBigMode ? LengthMetrics.resource($r('sys.float.padding_level12')) : LengthMetrics.vp(0),
          bottom: this.isBigMode ? LengthMetrics.resource($r('sys.float.padding_level12')) : LengthMetrics.vp(0)
        })
      if (this.viewMode === item.type) {
        this.SelectedImage()
      }
    }
    .id(item.type)
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .constraintSize({
      minHeight: this.menuHeight
    })
    .onClick(() => {
      this.itemClick(item);
    })
    .stateStyles({
      normal: normalStyles
    })
  }

  @Builder
  AddItem(item: TopMenuItem) {
    Row() {
      Text(item.name)
        .constraintSize({
          minHeight: $r('app.float.common_size21')
        })
        .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
        .fontColor(item.name === MENU_NAME.multipleChoice && this.fileCount === 0 ?
        $r('sys.color.ohos_id_color_tertiary') : $r('sys.color.ohos_id_color_primary'))
        .margin({
          start: LengthMetrics.resource($r('sys.float.padding_level6')),
          top: this.isBigMode ? LengthMetrics.resource($r('sys.float.padding_level12')) : LengthMetrics.vp(0),
          bottom: this.isBigMode ? LengthMetrics.resource($r('sys.float.padding_level12')) : LengthMetrics.vp(0)
        })
    }
    .accessibilityText(ResourceUtil.getStringByResource(item.name))
    .accessibilityGroup(true)
    .enabled((item.name === MENU_NAME.multipleChoice && this.fileCount !== 0) || item.name === MENU_NAME.add)
    .id(item.type)
    .width('100%')
    .constraintSize({
      minHeight: this.menuHeight
    })
    .stateStyles({
      normal: normalStyles
    })
    .onClick(() => {
      this.itemClick(item);
    })
  }

  itemClick(item: TopMenuItem): void {
    if (this.isClick) {
      return;
    }
    if ([ViewMode.LIST, ViewMode.GRID].includes(item.type as ViewMode)) {
      EventBus.emit(Constant.EVENTS.ACCESSIBILITY_FOCUS_JUMP);
    }
    this.isClick = true;
    if (item.name === MENU_NAME.multipleChoice) {
      const timer = setTimeout(() => {
        item.action?.()
        clearTimeout(timer);
      }, MULTI_CHOICE_HANDLE_DELAY_TIME);
    } else {
      item.action?.();
    }
    this.hideMenu();
  }
}