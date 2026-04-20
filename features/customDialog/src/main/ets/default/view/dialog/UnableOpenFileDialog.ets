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

import { Constant, EventBus } from '@ohos/common';
import { DialogButton, DialogTitle } from './DialogComponent';

@Component
@CustomDialog
export default struct UnableOpenFileDialog {
  controller?: CustomDialogController;
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
        title: $r('app.string.unable_open_file_dialog_title')
      })
      Text($r('app.string.unable_open_file_dialog_content'))
        .fontSize($r('app.float.common_font_size16'))
        .fontColor($r('sys.color.ohos_id_color_foreground'))
        .opacity($r('app.float.common_opacity9'))
        .alignSelf(ItemAlign.Start)
        .margin({
          left: $r('app.float.common_margin8'),
          right: $r('app.float.common_margin8'),
          bottom: $r('app.float.common_margin8')
        })
      Row() {
        DialogButton({
          text: $r('app.string.get_it'),
          bgColor: $r('sys.color.ohos_id_color_button_normal'),
          isDisabled: false,
          click: () => {
            this.closeDialog();
          }
        })
      }.width('100%')
    }
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
      bottom: $r('sys.float.padding_level8')
    })
  }
}