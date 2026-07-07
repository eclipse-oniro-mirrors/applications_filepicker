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
  ItemRestriction,
  SegmentButton,
  SegmentButtonOptions,
  SegmentButtonTextItem,
  TabSegmentButtonConstructionOptions
} from '@ohos.arkui.advanced.SegmentButton';
import { Constant, EventBus } from '@ohos/common';

const TAG = 'TabController';

@Component
export struct TabController {
  @Link currentIndex: number;

  private agendaNames: ItemRestriction<SegmentButtonTextItem> = [
    { text: $r('app.string.recent') },
    { text: $r('app.string.browse') }]

  // tabBars 属性
  private tabSegment: TabSegmentButtonConstructionOptions = {
    buttons: this.agendaNames,
    fontSize: $r('app.float.common_font_size14'),
    selectedFontSize: $r('app.float.common_font_size14'),
    backgroundColor: $r('sys.color.comp_background_tertiary'),
    selectedBackgroundColor: $r('sys.color.comp_background_list_card'),
    fontWeight: FontWeight.Medium,
    selectedFontWeight: FontWeight.Bold,
    fontColor: $r('sys.color.font_secondary'),
    selectedFontColor: $r('sys.color.font_primary'),
    buttonPadding: {
      top: $r('sys.float.padding_level5'),
      bottom: $r('sys.float.padding_level5'),
      left: $r('sys.float.padding_level4'),
      right: $r('sys.float.padding_level4')
    }
  }
  @State @Watch('onSegmentTabsIndexChange') segmentTabsIndex: number[] = [this.currentIndex];
  @State segmentOption: SegmentButtonOptions = SegmentButtonOptions.tab(this.tabSegment);
  @State currentCreateTimeStamp: number = -1;
  private onTabChange: (currentIndex: number) => void = (currentIndex: number): void =>
  EventBus.emit(Constant.EVENTS.UI_EXTENSION_PICKER_INDEX_CHANGE + this.currentCreateTimeStamp, currentIndex);

  build() {
    Row() {
      SegmentButton({ options: this.segmentOption, selectedIndexes: this.segmentTabsIndex })
        .key('SegmentButton')
        .align(Alignment.Center)
        .width('100%')
        .height($r('app.float.common_size40'))
        .defaultFocus(false)
    }
    .focusable(false)
    .alignItems(VerticalAlign.Bottom)
    .justifyContent(FlexAlign.Center)
    .height($r('app.float.common_size56'))
    .width($r('app.float.common_size160'))
  }

  private onSegmentTabsIndexChange() {
    setTimeout(() => {
      this.currentIndex = this.segmentTabsIndex[0];
      this.onTabChange(this.currentIndex);
    }, 20);
  }

}