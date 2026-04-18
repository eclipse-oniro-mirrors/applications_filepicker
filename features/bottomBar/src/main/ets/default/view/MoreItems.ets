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

import { moreMap } from '@ohos/common/src/main/ets/const/UiConstant';
import { SymbolGlyphModifier } from '@kit.ArkUI';
import { AccessibilityManager, ResourceUtil, Constant, MENU_ICONS } from '@ohos/common';
import { i18n, intl } from '@kit.LocalizationKit';

@Styles
function pressedStyles() {
  .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
  .borderRadius($r('app.float.common_borderRadius12'))
}

@Styles
function normalStyles() {
  .backgroundColor($r('app.color.transparent_color'))
  .borderRadius($r('app.float.common_borderRadius12'))
}

@Component
export struct MoreItems {
  itemClick: Function = () => {
  };
  @Prop moreOptions: string[];
  @State isOutsideFolded: boolean = false;

  build() {
    Menu() {
      // 不同页面 更多显示不同
      ForEach(this.moreOptions, (item: string, index) => {
        MenuItemGroup() {
          MenuItem({
            content: moreMap[item],
            symbolEndIcon: new SymbolGlyphModifier(this.getIcon(item))
              .fontColor([$r('sys.color.font_primary')])
              .fontSize($r('app.float.common_size20'))
          })
            .visibility(item === Constant.OPERATION_TYPE.SET_AS_WALLPAPER && this.isOutsideFolded ?
              Visibility.None : Visibility.Visible)
            .onClick(() => {
              if (item === Constant.OPERATION_TYPE.ROTATE) {
                let numFormat = new intl.NumberFormat(i18n.System.getSystemLanguage());
                // 图片已逆时针旋转90度 语音播报
                AccessibilityManager.getInstance().sendTextAnnouncedForAccessibility(
                  ResourceUtil.getStringByOneParamResource($r('app.string.reverse_rotation'), numFormat.format(90)));
              }
              this.itemClick(item);
            })
        }
      })
    }
    .width($r('app.float.common_size224'))
  }

  getIcon(item: string): Resource | undefined {
    switch (item) {
      case Constant.OPERATION_TYPE.ROTATE:
        return MENU_ICONS.rotateImage;
      case Constant.OPERATION_TYPE.MOVE:
        return MENU_ICONS.move;
      case Constant.OPERATION_TYPE.RENAME:
        return MENU_ICONS.rename;
      case Constant.OPERATION_TYPE.DETAIL:
        return MENU_ICONS.detail;
      case Constant.OPERATION_TYPE.SET_AS_WALLPAPER:
        return MENU_ICONS.setWallpaper;
      case Constant.OPERATION_TYPE.OTHER_APP:
        return MENU_ICONS.otherApp;
      default :
        return undefined
    }
  }

}