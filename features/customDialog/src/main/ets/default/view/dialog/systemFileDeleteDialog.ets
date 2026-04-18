/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { HiLog } from '@ohos/common';
import { DialogButton } from './DialogComponent';

@Component
@CustomDialog
export struct systemFileDeleteDialog {
  private TAG: string = 'systemFileDeleteDialog';
  controller?: CustomDialogController;
  content: Resource | string = '';
  buttonText: Resource = $r('app.string.confirm');
  buttonFunc: () => void = () => {
  };
  callback: Function = () => {
  };
  @State textAlign: TextAlign = TextAlign.Center;
  /**
   * 判断是否是深色模式
   */
  @StorageProp('isDarkMode') isDarkMode: boolean = false;

  aboutToAppear() {
    HiLog.info(this.TAG, 'systemFileDeleteDialog');

  }

  build() {
    Column() {
      Text(this.content)
        .maxFontScale(2)
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .margin({
          top: $r('app.float.common_margin24'),
          left: $r('app.float.common_margin8'),
          right: $r('app.float.common_margin8')
        })
        .textAlign(this.textAlign)
      this.systemFileDeleteDialogButton();
    }
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
      bottom: $r('sys.float.padding_level8')
    })
    .outline({width: 1, color: this.isDarkMode ? '#66000000' : '#19000000'})
  }

  @Builder
  systemFileDeleteDialogButton() {
    Row() {
      DialogButton({
        text: this.buttonText,
        color: $r('sys.color.ohos_id_color_text_primary_activated'),
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        isDisabled: false,
        click: () => {
          this.buttonFunc();
          this.callback();
          if (this.controller) {
            this.controller.close();
          }
        }
      });
    }.width('100%')
    .margin({
      top: $r('app.float.common_margin8')
    })
  }
}