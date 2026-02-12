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
import { LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI';
import { HiLog } from '@ohos/common';

const TAG: string = 'ItemLongPressMenu';

export interface LongPressMenuItem {
  itemName: ResourceStr,
  clickCallBack: () => void,
  symbolEndIcon: SymbolGlyphModifier
}

@Component
export struct ItemLongPressMenu {
  public menuItems: LongPressMenuItem[] = [];

  build() {
    Menu() { 
      ForEach(this.menuItems, (menuItem: LongPressMenuItem, index) => {
        MenuItem({content: menuItem.itemName, symbolEndIcon: menuItem.symbolEndIcon})
          .borderRadius($r('app.float.common_borderRadius16'))
          .onClick(() => {
            HiLog.info(TAG, 'clickCallBack.');
            menuItem.clickCallBack()
          })
      }, (info: LongPressMenuItem) => JSON.stringify(info))
    }
    .width($r('app.float.common_size224'))
    .menuItemDivider({
      strokeWidth: LengthMetrics.px(1),
      color: $r('sys.color.comp_divider'),
      startMargin: LengthMetrics.resource($r('sys.float.padding_level6')),
      endMargin: LengthMetrics.resource($r('sys.float.padding_level6'))
    })
  }
}