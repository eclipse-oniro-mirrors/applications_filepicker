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

import { FavoriteModel, HiLog, MENU_ICONS } from '@ohos/common';
import { LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI';

const TAG: string = 'FavouriteItemLongPressMenu';

@Component
export struct FavouriteItemLongPressMenu {
  public item: FavoriteModel = new FavoriteModel();
  public callbackFun: Function = (item: FavoriteModel) => {};

  build() {
    Menu() {
      MenuItem({content: $r('app.string.unfavorite'), symbolEndIcon: new SymbolGlyphModifier(MENU_ICONS.unFavourite)})
        .onClick(() => {
          this.callbackFun(this.item);
          HiLog.warn(TAG, 'call delete favourite fun');
        })
        .borderRadius($r('app.float.common_borderRadius16'))
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
