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

import { AttributeUpdater } from '@ohos.arkui.modifier';

export class FileTextModifier extends AttributeUpdater<TextAttribute, TextInterface> {
  initializeModifier(instance: TextAttribute) {
  }
}

export class FileNameModifier extends AttributeUpdater<TextAttribute, TextInterface> {
  initializeModifier(instance: TextAttribute) {
    instance.fontSize($r('sys.float.Body_M'))
      .fontColor($r('sys.color.font_primary'))
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .fontWeight(FontWeight.Regular)
      .fontFamily('HarmonyHeiTi')
      .constraintSize({
        // 适老化适配，将文本框的高度设置为最小19vp，当文字变大时文本框会跟随变高。从而解决文字与图片叠加问题
        minHeight: $r('app.float.common_size19')
      })
  }
}

export class CachedImageModifier extends AttributeUpdater<MediaCachedImageAttribute, MediaCachedImageInterface> {
  initializeModifier(instance: MediaCachedImageAttribute) {
  }
}

export class ListItemModifier extends AttributeUpdater<ListItemAttribute, ListItemInterface> {
  initializeModifier(instance: ListItemAttribute) {
  }
}

export class RowModifier extends AttributeUpdater<RowAttribute, RowInterface> {
  initializeModifier(instance: RowAttribute) {
  }
}

export class ColumnModifier extends AttributeUpdater<ColumnAttribute, ColumnInterface> {
  initializeModifier(instance: ColumnAttribute) {
  }
}

export class ImageModifier extends AttributeUpdater<ImageAttribute, ImageInterface> {
  initializeModifier(instance: ImageAttribute) {
  }
}

export class CommonModifier extends AttributeUpdater<CommonAttribute, CommonInterface> {
  initializeModifier(instance: CommonAttribute) {
  }
}