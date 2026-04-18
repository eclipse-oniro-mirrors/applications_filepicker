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
import { FileNameModifier } from '../../../viewModel/CustomedModifier';

@Component
export struct FileNameComp {
  // 文件名
  private fileName: string = '';
  // 最大显示行数
  private maxLines: number = 1;
  // 省略模式，默认尾部省略
  @Prop ellipsisMode: EllipsisMode;
  // 是否为列表视图
  @Consume isListView: boolean;
  // 文件名的前中后三部分
  @State startText: string = '';
  @State centerText: string = '';
  @State endText: string = '';
  @Prop isDropSelected: boolean;
  private customTheme: CustomTheme = FilePickerUtil.getStartOptionsFromStorage().customTheme;
  private fileNameTextModifier: FileNameModifier = new FileNameModifier();

  aboutToAppear(): void {
    // 默认将startText初始化为文件名，方便后续特殊场景的处理
    this.startText = this.fileName;
    this.fileNameTextModifier.updateConstructorParams(this.fileName);
    this.splitFileName();
  }

  aboutToReuse(params: Record<string, Object>): void {
    this.fileName = params?.fileName as string;
    this.maxLines = params?.maxLines as number;
    this.startText = this.fileName;
    this.fileNameTextModifier.updateConstructorParams(this.fileName);
    this.splitFileName();
  }

  build() {
    Text(this.fileName)
      .fontSize($r('sys.float.Body_M'))
      .fontColor($r('sys.color.font_primary'))
      .maxLines(this.maxLines)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .ellipsisMode(this.ellipsisMode)
      .fontWeight(FontWeight.Regular)
      .fontFamily('HarmonyHeiTi')
      .constraintSize({
        // 适老化适配，将文本框的高度设置为最小18vp，当文字变大时文本框会跟随变高。从而解决文字与图片叠加问题
        minHeight: $r('app.float.common_size19')
      })
      .attributeModifier(this.fileNameTextModifier)
  }

  /**
   * 根据需要高亮显示的搜索词将文件名分为前中后三段
   */
  private splitFileName(): void {
    return;
  }
}