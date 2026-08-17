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

import measure from '@ohos.measure';
import { getResourceString, HiLog, ResourceUtil } from '@ohos/common';
import { DialogButton, DialogTitle } from './DialogComponent';

const TAG: string = 'SaveFileConflictDialog';

@CustomDialog
export struct SaveFileConflictDialog {
  private title: ResourceStr = $r('app.string.note');
  private MAX_TEXT_WIDTH: number = 346;
  private MAX_FONT_SCALE: number = 2;
  private controller?: CustomDialogController;
  public content: Resource = $r('app.string.save_have_same_name');
  public confirmText: Resource = $r('app.string.confirm');
  public cancelText: Resource = $r('app.string.cancel');
  public cancel: () => void = () => {
  };
  public confirm: () => void = () => {
  };

  aboutToAppear() {
    HiLog.info(TAG, 'SaveFileConflictDialog');
  }

  // 判断是否包含换行符
  private hasNewLine(resStr: Resource | string): boolean {
    if (!resStr) {
      HiLog.warn(TAG, 'hasNewLine resStr is empty.');
      return false;
    }
    let tempStr: string = '';
    if (typeof (resStr) !== 'string') {
      tempStr = getResourceString(resStr);
    } else {
      tempStr = resStr;
    }
    return tempStr.includes('\n');
  }

  private getTextAlign(): TextAlign {
    let textWidth = measure.measureText({
      textContent: ResourceUtil.getStringByResource(this.content),
      fontSize: $r('app.float.common_font_size16'),
      fontWeight: FontWeight.Regular,
    });
    if ((px2vp(textWidth) > this.MAX_TEXT_WIDTH) || this.hasNewLine(this.content)) { // 获取文字宽度，单行居中，多行居左
      HiLog.warn(TAG, 'getTextAlign start.');
      return TextAlign.Start;
    }
    return TextAlign.Center;
  }

  build() {
    Column() {
      if (this.title) {
        DialogTitle({
          title: this.title
        })
      }
      Text(this.content)
        .textAlign(this.getTextAlign())
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .constraintSize({
          minHeight: $r('app.float.common_height24')
        })
        .maxFontScale(this.MAX_FONT_SCALE)
        .fontWeight(FontWeight.Medium)
        .padding({
          top: 0,
          right: $r('app.float.common_padding24'),
          bottom: $r('app.float.common_padding16'),
          left: $r('app.float.common_padding24')
        })
        .width('100%')
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
      this.bottomButtonBuilder()
    }
    .backgroundColor($r('sys.color.ohos_id_color_background'))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  bottomButtonBuilder() {
    Row() {
      DialogButton({
        text: this.cancelText,
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        isDisabled: false,
        click: () => {
          HiLog.info(TAG, 'Cancel selected.');
          this.cancel();
          this.controller?.close();
        }
      })

      Blank().width($r('app.float.common_padding16'))

      DialogButton({
        text: this.confirmText,
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        isDisabled: false,
        click: () => {
          HiLog.info(TAG, 'Confirm selected.');
          this.confirm();
          this.controller?.close();
        }
      })
    }
    .padding({
      right: $r('app.float.common_padding16'),
      bottom: $r('app.float.common_padding16'),
      left: $r('app.float.common_padding16')
    })
  }
}
