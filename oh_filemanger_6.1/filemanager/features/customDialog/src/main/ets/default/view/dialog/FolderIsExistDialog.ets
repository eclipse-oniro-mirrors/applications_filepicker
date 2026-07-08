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

import { EventBus, Constant } from '@ohos/common';
import { DialogButton } from './DialogComponent';

@Component
@CustomDialog
export struct FolderIsExistDialog {
  controller?: CustomDialogController;
  confirm: Function = () => {};
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
      Row() {
        Text($r('app.string.folder_not_exist'))
          .fontSize($r('app.float.common_font_size16'))
          .maxFontScale(2)
          .fontColor($r('sys.color.ohos_id_color_primary'))
          .margin({
            top: $r('app.float.common_margin24'),
          })
      }

      Row() {
        DialogButton({
          text: $r('app.string.get_it'),
          bgColor: $r('sys.color.ohos_id_color_button_normal'),
          isDisabled: false,
          click: () => {
            this.closeDialog();
            this.confirm();
          }
        })
      }.width('100%')
      .padding({ bottom: $r('app.float.common_margin10'), top: $r('app.float.common_margin10') })
      .margin({
        top: $r('app.float.common_margin8'),
      })
      .justifyContent(FlexAlign.Center)
    }
    .padding({
      left: $r('app.float.common_padding24'),
      right: $r('app.float.common_padding24')
    })
    .borderRadius($r('app.float.common_borderRadius24'))
    .outline({width: 1, color: this.isDarkMode ? '#66000000' : '#19000000', radius: $r('app.float.common_borderRadius24')})
    .border({width: 1, color: '#33FFFFFF'})
  }
}