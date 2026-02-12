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

import { FavoriteModel, HiLog } from '@ohos/common';

const TAG = 'FavDrag';

/**
 * 收藏拖拽视图
 */
@Component
export struct FavoriteDragView {
  favoriteItem: FavoriteModel = new FavoriteModel();

  aboutToAppear() {
    HiLog.info(TAG, 'FavoriteDragView aboutToAppear.');
  }

  build() {
    Column() {
      Row() {
        Row() {
          Image($r('app.media.ic_sc_movelist'))
            .fillColor($r('sys.color.ohos_id_color_primary'))
            .objectFit(ImageFit.Contain)
            .renderMode(ImageRenderMode.Original)
            .aspectRatio(1)
            .width($r('app.float.common_size22'))
            .height($r('app.float.common_size16'))
            .borderRadius($r('app.float.common_size4'))
            .alignSelf(ItemAlign.Center)
            .draggable(false)
            .margin({ right: $r('app.float.common_margin12') })
          Image($r('app.media.hidisk_icon_folder_has_file'))
            .objectFit(ImageFit.Contain)
            .renderMode(ImageRenderMode.Original)
            .aspectRatio(1)
            .width($r('app.float.common_size22'))
            .height($r('app.float.common_size16'))
            .borderRadius($r('app.float.common_size4'))
            .alignSelf(ItemAlign.Center)
            .margin({ right: $r('app.float.common_margin12') })
            .draggable(false)

          Row() {
            Text(this.favoriteItem.name)
              .fontSize($r('app.float.common_font_size16'))
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontWeight(FontWeight.Medium)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .lineHeight($r('app.float.common_size20'))
          }
          .width('70%')
        }

        Row() {
          Image($r('app.media.ic_sc_delete'))
            .fillColor($r('sys.color.ohos_id_color_warning'))
            .objectFit(ImageFit.Contain)
            .renderMode(ImageRenderMode.Original)
            .aspectRatio(1)
            .width($r('app.float.common_size22'))
            .height($r('app.float.common_size16'))
            .draggable(false)
        }
      }
      .backgroundColor($r('app.color.windows_gray'))
      .borderRadius($r('app.float.common_borderRadius12'))
      .width('90%')
      .justifyContent(FlexAlign.SpaceBetween)
      .height($r('app.float.common_size56'))
      .padding({
        left: $r('app.float.common_padding12'),
        right: $r('app.float.common_padding12')
      })
    }
    .justifyContent(FlexAlign.Center)
  }
}