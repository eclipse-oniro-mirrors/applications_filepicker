/*
 * Copyright (c) 2021-2023 Huawei Device Co., Ltd.
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

@Component
export struct NoContent {

  build() {
    Column() {
      Image($r('app.media.hidisk_ic_blankpage_document'))
        .objectFit(ImageFit.Contain)
        .height($r('app.float.common_size120'))
        .width($r('app.float.common_size120'))
      Text($r('app.string.noContent'))
        .fontSize($r('app.float.common_font_size14'))
        .opacity($r('app.float.common_opacity6'))
    }.width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}