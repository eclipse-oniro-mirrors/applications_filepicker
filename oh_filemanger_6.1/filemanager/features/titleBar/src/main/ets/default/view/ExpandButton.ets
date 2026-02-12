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
import { AccessibilityManager, CompId, DFX, HiLog, UEUtil } from '@ohos/common';
import { LengthMetrics } from '@kit.ArkUI';

const TAG: string = 'ExpandButton';
const FOCUS_DELAY: number = 700;

@Styles
function pressedStyles() {
  .borderRadius($r('app.float.common_borderRadius20'))
  .backgroundColor($r('app.color.buttonBar_pressStyles'))
}

@Styles
function normalStyles() {
  .borderRadius($r('app.float.common_borderRadius20'))
  .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
}

@Component
export struct ExpandButton {
  @Consume('isExpand') isExpand: boolean;
  @Consume('pageInfos') pageInfos: NavPathStack;
  private changeExpand: () => void = () => {
  };

  build() {
    Column() {
      Row() {
        SymbolGlyph(this.isExpand ? $r('sys.symbol.close_sidebar') : $r('sys.symbol.open_sidebar'))
          .fontSize($r('app.float.common_size24'))
          .fontColor([$r('sys.color.icon_primary')])
          .width($r('app.float.common_size24'))
          .height($r('app.float.common_size24'))
          .draggable(false)
      }
      .accessibilityText(this.isExpand ? $r('app.string.open_navigation') : $r('app.string.close_navigation'))
      .padding($r('app.float.common_padding8'))
      .stateStyles({
        pressed: pressedStyles,
        normal: normalStyles
      })
    }
    .id(CompId.EXPAND_BUTTON)
    .margin({
      top: LengthMetrics.vp(8),
    })
    .accessibilityRole(AccessibilityRoleType.BUTTON)
    .onClick(() => {
      const beforeDrawMode = this.isExpand ? DFX.DrawerMode.COLLAPSE : DFX.DrawerMode.EXPAND;
      const afterDrawMode = !this.isExpand ? DFX.DrawerMode.COLLAPSE : DFX.DrawerMode.EXPAND;
      this.changeExpand();
      const pageName = AppStorage.get<DFX.PageName>(DFX.StorageKey.OPERATE_PAGE) || DFX.PageName.UNKNOWN;
      HiLog.info(TAG, `currentExpand: ${afterDrawMode},page: ${pageName}`);
      UEUtil.reportDrawerModeChange(beforeDrawMode, afterDrawMode, pageName);
      let timer = setTimeout(() => {
        AccessibilityManager.getInstance()
          .sendCustomIdFocusForAccessibility(CompId.EXPAND_BUTTON, TAG);
        clearTimeout(timer);
      }, FOCUS_DELAY);
    })
  }
}