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

import { FilePickerUtil } from '@ohos/common';

@Component
export struct CustomBottomButtonComp {
  clickFunc: Function = () => {
  };
  buttonText: ResourceStr = '';

  build() {
    Row() {
      Blank()
      Button(this.buttonText)
        .width('100%')
        .constraintSize({
          minHeight: $r('app.float.common_size40')
        })
        .fontColor(FilePickerUtil.getStartOptionsFromStorage().customTheme.colors?.fontPrimary)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .borderRadius($r('app.float.common_borderRadius20'))
        .padding({
          left: $r('app.float.common_padding8'),
          right: $r('app.float.common_padding8'),
          top: $r('app.float.common_padding8'),
          bottom: $r('app.float.common_padding8')
        })
        .onClick(() => {
          this.clickFunc();
        })
      Blank()
    }.width('100%')
    .margin({ top: $r('app.float.common_margin8'), bottom: $r('app.float.common_margin16') })
    .padding({ left: $r('app.float.common_padding16'), right: $r('app.float.common_padding16') })
  }
}