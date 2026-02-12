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
import { HighLightData } from '@ohos/common';

@Component
export struct FileContentComp {
  // 要高亮显示的文件内容
  @Prop fileContentList: Array<HighLightData>;
  // 是否为列表视图
  @Consume isListView: boolean;
  @Prop isDropSelected: boolean;

  build() {
    Text() {
      ForEach(this.fileContentList, (item: HighLightData) => {
        Span(item.content)
          .fontSize($r('sys.float.ohos_id_text_size_body3'))
          .fontColor(item.isHighLight ? (this.isDropSelected ? $r('sys.color.ohos_id_color_text_secondary') : $r('sys.color.ohos_id_color_text_primary_activated')) : $r('sys.color.ohos_id_color_text_secondary'))
      })
    }
    .fontSize(this.isListView ? $r('sys.float.Body_S') : $r('sys.float.ohos_id_text_size_body3'))
    .fontColor($r('sys.color.font_secondary'))
    .fontWeight(FontWeight.Regular)
    .constraintSize({
      minHeight: $r('app.float.common_size18')
    })
    .maxLines(this.isListView ? 2 : 1)
    .textOverflow({ overflow: TextOverflow.Ellipsis })
    .ellipsisMode(EllipsisMode.END)
  }
}
