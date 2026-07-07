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
import { DialogButton, DialogButtonDivider, DialogTitle } from './DialogComponent'

@Component
@CustomDialog
export struct JumpConfirmDialog {
  // 跳转回调
  callBack: Function = () => {};
  controller?: CustomDialogController

  build() {
    Column () {
      DialogTitle({
        title: $r('app.string.note')
      })
      Text($r('app.string.jump_to_target_note'))
      Row() {
        DialogButton({
          text: $r('app.string.cancel'),
          color: $r('sys.color.ohos_id_color_text_primary_activated'),
          bgColor: $r('sys.color.ohos_id_color_button_normal'),
          isDisabled: false,
          click: () => {
            this.controller?.close();
          }
        });
        DialogButtonDivider();
        DialogButton({
          text: $r('app.string.confirm_jump'),
          isDisabled: false,
          color: $r('sys.color.ohos_id_color_warning'),
          bgColor: $r('sys.color.ohos_id_color_button_normal'),
          click: () => {
            this.callBack();
            this.controller?.close();
          }
        });
      }.width('100%')
      .margin({
        top: $r('app.float.common_margin8')
      })
    }.padding({
      bottom: $r('app.float.common_margin24'),
      left: $r('app.float.common_margin24'),
      right: $r('app.float.common_margin24')
    })
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}