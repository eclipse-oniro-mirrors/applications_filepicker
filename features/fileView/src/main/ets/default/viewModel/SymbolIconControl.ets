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

import { Callback } from '@kit.BasicServicesKit';

@Component
export struct SymbolIconButton {
  @Prop symbolResource: Resource = $r('sys.symbol.folder_badge_plus');
  @Prop fontColorResource: ResourceColor[] = [$r('sys.color.ohos_id_color_primary')];
  public iconSize: Resource = $r('app.float.common_size24');
  public borderSize: Resource = $r('app.float.common_size40');
  public pressedColor: Resource = $r('sys.color.interactive_pressed');
  public normalColor: Resource = $r('app.color.transparent_color');
  public clickCallback: Callback<void> = () => {};
  public compId: string = '';
  @Prop accessibilityTxt: string = '';

  @Styles
  pressedStyles() {
    .backgroundColor(this.pressedColor)
  }

  @Styles
  normalStyles() {
    .backgroundColor(this.normalColor)
  }

  build() {
    Button() {
      SymbolGlyph(this.symbolResource)
        .fontColor(this.fontColorResource)
        .fontSize($r('app.float.common_size24'))
        .draggable(false)
    }
    .stateEffect(false)
    .type(ButtonType.Circle)
    .accessibilityText(this.accessibilityTxt)
    .size({ width: this.borderSize, height: this.borderSize })
    .borderRadius(8)
    .stateStyles({
      normal: this.normalStyles
    })
    .id(this.compId)
    .onClick(() => {
      if (this.clickCallback) {
        this.clickCallback();
      }
    })
  }
}