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

import { Constant, EventBus } from '@ohos/common'
import { DialogTitle, DialogButton, DialogButtonDivider } from './DialogComponent'

@CustomDialog
@Component
export struct SuffixChangeDialog {
  controller?: CustomDialogController;
  cancel: Function = () => {
  };
  confirm: Function = () => {
  };
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
        title: $r('app.string.note')
      })

      Text($r('app.string.suffixErr'))
        .fontSize($r('app.float.common_font_size16'))
        .margin({ bottom: $r('app.float.common_margin10') })

      Row() {
        DialogButton({
          text: $r('app.string.cancel'),
          bgColor: $r('sys.color.ohos_id_color_button_normal'),
          isDisabled: false,
          click: () => {
            this.cancel();
            this.closeDialog();
          }
        })
        DialogButtonDivider()
        DialogButton({
          text: $r('app.string.confirm'),
          bgColor: $r('sys.color.ohos_id_color_button_normal'),
          isDisabled: false,
          click: () => {
            this.confirm()
            this.closeDialog();
          }
        })
      }.width('100%')
      .margin({ bottom: $r('app.float.common_margin16') })
    }
    .padding({ left: $r('app.float.common_padding16'), right: $r('app.float.common_padding16') })
    .outline({width: 1, color: this.isDarkMode ? '#66000000' : '#19000000'})
  }
}