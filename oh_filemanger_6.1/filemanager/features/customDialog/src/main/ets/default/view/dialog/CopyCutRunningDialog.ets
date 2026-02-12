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

import router from '@ohos.router';
import { DialogButtonDivider, DialogButton } from './DialogComponent';
import { EventBus, Constant } from '@ohos/common';

/**
 * 复制任务移动冲突弹框
 */
@Component
@CustomDialog
export struct CopyCutRunningDialog {
  controller?: CustomDialogController;
  isBackToDesk: boolean = false;
  showProgressCall?: Function;
  closeDialogBind: Function = () => this.closeDialog();

  stopTask: Function = () => {};

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

  /**
   * 点击终止事件
   */
  stopClick() {
    this.stopTask();
  }

  build() {
    Scroll() {
      Column() {
        // 标题
        this.dialogTitle();
        // 内容
        this.dialogContent();
        // 底部按钮
        this.bottomButton();
      }
    }
  }

  @Builder
  dialogTitle() {
    Text($r('app.string.note'))
      .fontSize($r('sys.float.Title_S'))
      .maxFontScale(2)
      .fontWeight(FontWeight.Bold)
      .fontColor($r('sys.color.ohos_id_color_foreground'))
      .fontFamily('HarmonyHeiTi')
      .height($r('app.float.common_size56'))
      .width('100%')
      .padding({
        left: $r('sys.float.padding_level12'),
        right: $r('sys.float.padding_level12')
      })
      .textAlign(TextAlign.Center)
  }

  @Builder
  dialogContent() {
    Text(this.isBackToDesk ? $r('app.string.copy_move_abort_alert') : $r('app.string.paste_conflict_diglog_btn_message'))
      .fontSize($r('app.float.common_font_size16'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.ohos_id_color_text_primary'))
      .fontFamily('HarmonyHeiTi')
      .width('100%')
      .opacity($r('app.float.common_opacity9'))
      .padding({
        left: $r('sys.float.padding_level12'),
        right: $r('sys.float.padding_level12')
      })
      .alignSelf(ItemAlign.Center)
  }

  @Builder
  bottomButton() {
    Row() {
      DialogButton({
        text: this.isBackToDesk ? $r('app.string.cancel') : $r('app.string.continue'),
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        isDisabled: false,
        click: () => {
          this.closeDialog();
          if (this.isBackToDesk ) {
            return;
          }
          if (this.showProgressCall) {
            this.showProgressCall();
          }
        }
      })
      DialogButtonDivider();
      DialogButton({
        text: this.isBackToDesk ? $r('app.string.exits') : $r('app.string.discontinue'),
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        isDisabled: false,
        click: () => {
          this.closeDialog();
          this.stopClick();
          if (this.isBackToDesk ) {
            setTimeout(() => {router.back()}, 200);
            return;
          }
        }
      })
    }
    .padding({
      top: $r('app.float.common_margin8'),
      bottom: $r('sys.float.padding_level8'),
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8')
    })
  }
}
