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

import { DialogTitle, DialogButton, DialogButtonDivider } from './DialogComponent';
import { CompId } from '@ohos/common';

@Component
@CustomDialog
export struct ConfirmTemplateDialog {
  controller?: CustomDialogController;
  firstButtonCallback?: Function;
  secondButtonCallback?: Function;
  title?: Resource = undefined;
  firstButtonText: Resource = $r('app.string.cancel');
  secondButtonText: Resource = $r('app.string.continue');
  content: Resource = $r('app.string.cancel');
  @State contentAlign: TextAlign = TextAlign.Start;
  /**
   * 判断是否是深色模式
   */
  @StorageProp('isDarkMode') isDarkMode: boolean = false;

  aboutToAppear() {

  }

  aboutToDisappear() {

  }

  build() {
    Scroll() {
      Column() {
        if (this.title) {
          DialogTitle({
            title: this.title
          })
        }
        this.dialogContent()
        this.dialogButton()
      }
    }
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
      bottom: $r('sys.float.padding_level8')
    })
    .outline({width: 1, color: this.isDarkMode ? '#66000000' : '#19000000'})
  }

  @Builder
  dialogContent() {
    if (this.content) {
      // 删除弹出框存在标题时，文本使用正常格式
      Text(this.content)
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .id(CompId.DIALOG_MIN_TITLE)
        .textAlign(TextAlign.Start)
        .margin({
          left: $r('app.float.common_margin8'),
          right: $r('app.float.common_margin8')
        })
    } else {
      // 删除弹出框不存在标题时，文本使用显示内容字重需要加大。增强显示效果
      Text(this.content)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .margin({
          top: $r('app.float.common_margin24'),
          left: $r('app.float.common_margin8'),
          right: $r('app.float.common_margin8')
        })
        .id(CompId.DIALOG_MIN_TITLE)
        .textAlign(this.contentAlign)
        .onAreaChange((oldValue, newValue) => {
          if ((newValue.height > 20)) {
            this.contentAlign = TextAlign.Start;
          }
        })
    }
  }

  @Builder
  dialogButton() {
    Row() {
      if (this.firstButtonCallback) {
        DialogButton({
          text: this.firstButtonText,
          color: $r('sys.color.ohos_id_color_text_primary_activated'),
          bgColor: $r('sys.color.ohos_id_color_button_normal'),
          isDisabled: false,
          click: () => {
            if (this.firstButtonCallback) {
              this.firstButtonCallback();
            }
            this.controller?.close();
          }
        })
      }
      if (this.secondButtonCallback) {
        DialogButtonDivider()
        DialogButton({
          text: this.secondButtonText,
          isDisabled: false,
          color: $r('sys.color.ohos_id_color_text_primary_activated'),
          bgColor: $r('sys.color.ohos_id_color_button_normal'),
          click: () => {
            if (this.secondButtonCallback) {
              this.secondButtonCallback();
            }
            this.controller?.close();
          }
        })
      }
    }.width('100%')
    .margin({
      top: $r('app.float.common_margin8')
    })
  }
}
