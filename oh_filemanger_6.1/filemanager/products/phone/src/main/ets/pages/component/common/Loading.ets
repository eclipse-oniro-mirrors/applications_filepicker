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
import { Offset } from '@kit.ArkUI';

@Component
export struct Loading {
  @Prop isLoading: boolean = false;
  iconWidth: number = 60;
  iconHeight: number = 60;
  color: Resource = $r('sys.color.ohos_id_color_progress');
  title: Resource = $r('app.string.loading');
  containerHeight: number | string = '100%';
  bgColor?: Resource = undefined;
  justifyContent: FlexAlign = FlexAlign.Center;
  @Prop showOffset: Offset = { x: 0, y: 0 };

  build() {
    Column() {
      LoadingProgress()
        .width('72vp')
        .height('72vp')
        .color($r('sys.color.ohos_id_color_progress'))
        .offset(this.showOffset)

      Text(this.title)
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .margin({ top: 5 })
        .offset(this.showOffset)
    }
    .width('100%')
    .height(this.containerHeight)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(this.justifyContent)
    .visibility(this.isLoading ? Visibility.Visible : Visibility.None)
    .backgroundColor(this.bgColor)
  }
}