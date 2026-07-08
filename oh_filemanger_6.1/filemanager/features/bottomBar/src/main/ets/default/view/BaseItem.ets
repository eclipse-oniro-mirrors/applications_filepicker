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

import { Constant } from '@ohos/common';
import { BottomOptions } from '../model/UiModelData';

@Styles
function pressedStyles() {
  .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
  .borderRadius($r('app.float.common_borderRadius8'))
}

@Styles
function normalStyles() {
  .backgroundColor($r('app.color.transparent_color'))
  .borderRadius($r('app.float.common_borderRadius8'))
}

@Component
export struct BaseItem {
  barItem?: BottomOptions
  filePickerViewFlag ?: boolean;
  getItemColor(): ResourceColor {
    return this.barItem?.disabled ? $r('sys.color.ohos_id_color_tertiary') : $r('sys.color.ohos_id_color_text_primary');
  }

  build() {
    Column() {
      SymbolGlyph(this.barItem?.icon)
        .fontColor([this.getItemColor()])
        .fontSize($r('app.float.common_size24'))
        .margin({ bottom: $r('app.float.common_margin3') })
        .draggable(false)
      Text(this.barItem?.name)
        .fontColor(this.getItemColor())
        .fontSize($r('app.float.common_font_size10'))
        .constraintSize({
          minHeight: $r('app.float.common_line_height13')
        })
        .maxFontScale(Constant.BIG_MODE.BIG_MODE_1x)
    }
    .id(this.barItem?.type)
    .width(this.filePickerViewFlag ? $r('app.float.common_size80') : '100%')
    .padding({
      top: $r('app.float.common_padding8'),
      bottom: $r('app.float.common_padding8')
    })
    .visibility(this.barItem?.display ? Visibility.Visible : Visibility.None)
    .stateStyles({
      pressed: pressedStyles,
      normal: normalStyles
    })
    .enabled(!this.barItem?.disabled)
  }
}