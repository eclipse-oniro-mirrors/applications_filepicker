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
import { PAGE_ROUTE_CONST } from '@ohos/common';

const RECENT_LOAD_DAYS: number = 30;
const CURRENT_RATIO: number = 0.95;

@Component
export struct NoContent {
  private image: Resource = $r('app.media.hidisk_ic_blankpage_document');
  private content: Resource = $r('app.string.noContent');
  private pageName: string = '';
  // 是否只需要内层的图片文字布局
  @Prop isOnlyContent: boolean = false;

  build() {
    if (this.isOnlyContent) {
      this.NoContentColumn()
    } else {
      Column() {
        Column() {
          this.NoContentColumn()
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
        .width('100%')
      }
    }
  }

  @Builder
  NoContentColumn() {
    Column() {
      Image(this.image)
        .objectFit(ImageFit.Contain)
        .height($r('app.float.common_size120'))
        .width($r('app.float.common_size120'))
        .draggable(false)
        .interpolation(ImageInterpolation.High)
      Text(this.content)
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .opacity($r('sys.float.ohos_id_alpha_content_secondary'))
        .textAlign(TextAlign.Center)
    }
  }
}