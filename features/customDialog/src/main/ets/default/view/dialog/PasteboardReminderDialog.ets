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
import { Constant, PasteboardDataModel, EventBus } from '@ohos/common';

@Preview
@Component
@CustomDialog
export struct PasteboardReminderDialog {
  controller?: CustomDialogController
  content?: Resource
  pasteboardData?: PasteboardDataModel
  cancel?: Function
  confirm?: Function
  closeDialogBind: Function = () => this.closeDialog();
  /**
   * 判断是否是深色模式
   */
  @StorageProp('isDarkMode') isDarkMode: boolean = false;

  aboutToAppear() {
    EventBus.on(Constant.EVENTS.CLOSE_INFO_DISPLAY_DIALOGS, this.closeDialogBind);
  }

  aboutToDisappear() {
    EventBus.off(Constant.EVENTS.CLOSE_INFO_DISPLAY_DIALOGS, this.closeDialogBind);
  }

  closeDialog(): void {
    if (this.controller) {
      this.controller.close();
    }
  }

  build() {
    Column() {
      DialogTitle({
        title: $r('app.string.pasteboard_dialog_title')
      })
      Text(this.content)
        .fontSize($r('app.float.common_font_size16'))
        .margin({ bottom: $r('app.float.common_margin8') })
        .alignSelf(ItemAlign.Center)
      Row() {
        DialogButton({
          text: $r('app.string.cancel'),
          color: $r('sys.color.ohos_id_color_text_primary_activated'),
          bgColor: $r('sys.color.ohos_id_color_button_normal'),
          isDisabled: false,
          click: () => {
            this.closeDialog();
            if (this.cancel) {
              this.cancel(this.pasteboardData)
            }
          }
        })
        DialogButtonDivider()
        DialogButton({
          text: $r('app.string.pasting'),
          color: $r('sys.color.ohos_id_color_text_primary_activated'),
          bgColor: $r('sys.color.ohos_id_color_button_normal'),
          isDisabled: false,
          click: () => {
            EventBus.emit(Constant.EVENTS.CLOSE_INFO_DISPLAY_DIALOGS);
            this.closeDialog();
            if (this.confirm) {
              this.confirm(this.pasteboardData)
            }
          }
        })
      }
      .width('100%')
    }
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
      bottom: $r('sys.float.padding_level8')
    })
    .outline({width: 1, color: this.isDarkMode ? '#66000000' : '#19000000'})
  }
}

