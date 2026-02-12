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
import { Constant, UiUtil } from '@ohos/common';
import { systemParameterEnhance } from '@kit.BasicServicesKit';
import { i18n, intl } from '@kit.LocalizationKit';

const PROGRESS_RATE_100 = 100;

@Component
export struct LineProgress {
  @Prop progress: number = 0;
  @Prop content: Resource;
  @Prop contentShow?: boolean = true;
  private isBigMode: Boolean = UiUtil.getFontSize() >= Constant.BIG_MODE.BIG_MODE_1_15x;
  build() {
    Column() {
      Row() {
        if (this.contentShow) {
          Text(this.content)
            .fontColor($r('sys.color.ohos_id_color_primary'))
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .textAlign(TextAlign.Start)
            .flexShrink(1)
        } else {
          Text(' ')
            .fontColor($r('sys.color.ohos_id_color_primary'))
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .textAlign(TextAlign.Start)
        }
        Blank()
        if (!this.isBigMode) {
          this.progressShow()
        }
      }
      .margin({ top: 12 })
      .constraintSize({ minHeight: 20 })
      .width('100%')
      if (this.isBigMode) {
        this.progressShow()
      }
      Column() {
        Progress({ value: this.progress, style: ProgressStyle.Linear })
          .color($r('sys.color.comp_background_emphasize'))
          .style({ enableSmoothEffect: this.progress !== PROGRESS_RATE_100 })
      }
      .height(24)
      .justifyContent(FlexAlign.Center)
    }
    .constraintSize({
      minHeight: 56
    })
    .alignItems(HorizontalAlign.Start)
    .margin({ left: $r('app.float.common_margin8'), right: $r('app.float.common_margin8') })
  }


  // 百分比展示
  @Builder
  progressShow() {
    Row() {
      Text(this.getPercentage())
        .fontSize($r('app.float.common_font_size16'))
        .fontWeight(FontWeight.Medium)
        .opacity(0.6)
    }
  }

  private getPercentage(): string {
    let percentage = new intl.NumberFormat(i18n.System.getSystemLanguage(), {style: 'percent'});
    return percentage.format(this.progress / 100);
  }
}