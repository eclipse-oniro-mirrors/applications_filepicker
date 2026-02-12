/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import { HoverPopupStyle } from '@ohos/common';

@Component
export struct PopupComp {
  private promptText: Resource | string = '';
  @State needParam: boolean = false;
  @State top: number = 0;
  @State bottom: number = 0;

  build() {
    Row() {
      Text(this.promptText)
        .fontSize(14)
        .padding({
          left: HoverPopupStyle.HOVER_MENU_HORIZON_PADDING,
          right: HoverPopupStyle.HOVER_MENU_HORIZON_PADDING,
          top: this.needParam ? this.top : HoverPopupStyle.HOVER_MENU_VERTICAL_PADDING,
          bottom: this.needParam ? this.bottom : HoverPopupStyle.HOVER_MENU_VERTICAL_PADDING
        })
        .fontColor($r('sys.color.ohos_id_color_foreground'))
        .opacity(HoverPopupStyle.HOVER_MENU_TEXT_OPACITY)
    }
    .borderRadius(HoverPopupStyle.HOVER_MENU_BORDER_RADIUS)
  }
}