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

import { DialogButtonDivider, DialogButton } from './DialogComponent';

/**
 * 存储设备移除确认弹窗
 */
@Component
@CustomDialog
export struct StorageDeviceUnmount {
  private controller?: CustomDialogController;
  private uuid: string = '';
  private forcedRemove: Function = (uuid: string) => {};

  build() {
    Column() {
      Text($r('app.string.storage_data_lost_menu'))
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontFamily('HarmonyHeiTi')
        .width('100%')
        .opacity($r('app.float.common_opacity9'))
        .padding({
          left: $r('sys.float.padding_level12'),
          right: $r('sys.float.padding_level12')
        })
        .textAlign(TextAlign.Start)
      this.bottomButton();
    }
    .padding(
      {
        left: $r('sys.float.padding_level8'),
        top: $r('sys.float.padding_level12'),
        right: $r('sys.float.padding_level8'),
        bottom: $r('sys.float.padding_level8')
      }
    )
  }

  @Builder
  bottomButton() {
    Row() {
      DialogButton({
        text: $r('app.string.cancel'),
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        isDisabled: false,
        click: () => {
          this.controller?.close();
        }
      })
      DialogButtonDivider();
      DialogButton({
        text: $r('app.string.storage_force_remove'),
        color: $r('sys.color.ohos_id_color_badge_red'),
        isDisabled: false,
        click: () => {
          this.controller?.close();
          this.forcedRemove(this.uuid);
        }
      })
    }
  }
}