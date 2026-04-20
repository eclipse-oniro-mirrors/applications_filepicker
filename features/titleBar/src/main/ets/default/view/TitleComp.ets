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
import { AccessibilityManager, FilePickerUtil, HiLog, getResourceString, Constant, CommonUtil,
  AccessibilityStorageKey } from '@ohos/common';
import { CompId } from '@ohos/common/src/main/ets/const/CompId';
import { LengthMetrics } from '@kit.ArkUI';

@Extend(Text)
function subtitleStyles(fontSize: Resource) {
  .fontSize(fontSize)
  .fontColor($r('sys.color.font_secondary'))
  .alignSelf(ItemAlign.Start)
}

@Component
export struct TitleComp {
  @Prop @Watch('titleChange') title: ResourceStr = '';
  @Prop subTitle: ResourceStr = '';
  @Prop isLevelOneTitle: boolean = false;
  @Prop titleCompId: string = CompId.TOP_TITLE;
  @Prop isBigTitleAnnounce: boolean = false;
  @Prop fontColor: ResourceStr = $r('sys.color.font_primary');
  @Consume isPreviewMode: boolean;
  @Consume isOutsideFolded: boolean;
  private accessibilityManager: AccessibilityManager = AccessibilityManager.getInstance();
  private isPickerFlag: boolean = FilePickerUtil.getStartOptionsFromStorage().pickerFlag;

  build() {
    this.buildNormalTitle();
  }

  @Builder
  buildNormalTitle() {
    Column() {
      if (this.subTitle === '' && this.isLevelOneTitle && !this.isPreviewMode) {
        Text(this.title)
          .fontSize($r('sys.float.ohos_id_text_size_headline7'))
          .fontColor(this.fontColor)
          .fontWeight(FontWeight.Bold)
          .maxLines(Constant.LINE_COUNT.TWO)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxFontScale(Constant.BIG_MODE.BIG_MODE_1x)
          .id(this.titleCompId)
      } else {
        // 标题
        Text(this.title)
          .fontSize($r('app.float.common_font_size20'))
          .fontColor(this.fontColor)
          .maxFontScale(Constant.BIG_MODE.BIG_MODE_1x)
          .fontWeight(FontWeight.Bold)
          .maxLines(this.subTitle !== '' || ((this.isPickerFlag || this.isOutsideFolded) && this.isPreviewMode) ?
            Constant.LINE_COUNT.ONE : Constant.LINE_COUNT.TWO)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .ellipsisMode(this.isOutsideFolded && this.isPreviewMode ? EllipsisMode.CENTER : EllipsisMode.END)
          .id(this.titleCompId)
          .margin({ top: this.isPickerFlag ? $r('sys.float.padding_level11') : 0 })

        // 副标题
        if (this.subTitle !== '') {
          Text(this.subTitle)
            .subtitleStyles($r('sys.float.ohos_id_text_size_sub_title3'))
            .maxFontScale(Constant.BIG_MODE.BIG_MODE_1x)
        }
      }
    }
  }

  titleChange(): void {
    let timer = setTimeout(() => {
      clearTimeout(timer);
      // 大文件清理中选中项为0时不进行标题播报
      if (this.title !== CompId.TOP_TITLE && this.isBigTitleAnnounce) {
        return;
      }

      if (AppStorage.has(AccessibilityStorageKey.MULTIPLE_CHOICE_KEY)) {
        AppStorage.delete(AccessibilityStorageKey.MULTIPLE_CHOICE_KEY);
        return;
      }

      if (typeof this.title === 'string') {
        this.accessibilityManager.announceForAccessibilityNotInterrupt(this.title);
        return;
      }
      this.accessibilityManager.announceForAccessibilityNotInterrupt(getResourceString(this.title));
    }, 100)
  }
}



