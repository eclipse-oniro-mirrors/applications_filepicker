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

import { EventBus, Constant, renderSize, HiLog } from '@ohos/common';
import { DialogTitle, DialogButton, DialogButtonDivider } from './DialogComponent';
import { CompId } from '@ohos/common/src/main/ets/const/CompId';

const TAG = 'CellularTransmissionDialog';

@CustomDialog
export struct CellularTransmissionDialog {
  @StorageLink('cellularTransmissionFileSize') cellularTransmissionFileSize: number = 0;
  controller?: CustomDialogController;
  cancel: Function = () => {
  };
  confirm: Function = () => {
  };
  title?: ResourceStr = undefined;
  cancelButtonText: ResourceStr = $r('app.string.cancel');
  confirmButtonText: ResourceStr = $r('app.string.confirm');
  content: ResourceStr = $r('app.string.cellular_transmission_content', renderSize(this.cellularTransmissionFileSize));
  @State contentAlign: TextAlign = TextAlign.Start;
  closeDialogBind: Function = () => this.closeDialog();
  /**
   * 判断是否是深色模式
   */
  @StorageProp('isDarkMode') isDarkMode: boolean = false;

  aboutToAppear() {
    HiLog.info(TAG, `CellularTransmissionDialog aboutToAppear`);
    EventBus.on(Constant.EVENTS.CLOSE_INFO_DISPLAY_DIALOGS, this.closeDialogBind);
  }

  aboutToDisappear() {
    HiLog.info(TAG, `CellularTransmissionDialog aboutToDisappear`);
    EventBus.off(Constant.EVENTS.CLOSE_INFO_DISPLAY_DIALOGS, this.closeDialogBind);
    this.cellularTransmissionFileSize = 0;
  }

  closeDialog(): void {
    EventBus.emit(Constant.EVENTS.EXIT_MULTI_STATE);
    if (this.controller) {
      this.controller.close();
    } else {
      HiLog.warn(TAG, `dialog not exist`);
    }
  }

  build() {
    Scroll() {
      Column() {
        if (this.title) {
          DialogTitle({
            title: this.title
          })
        }
        this.cellularDownloadDialogContent()
        this.cellularDownloadDialogButton()
      }
      .accessibilityGroup(true)
      .padding({
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8'),
        bottom: $r('sys.float.padding_level8')
      })
    }
    .scrollBar(BarState.Auto)
    .scrollable(ScrollDirection.Vertical)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  cellularDownloadDialogContent() {
    if (this.title) {
      // 弹出框存在标题时，文本使用正常格式
      Text(this.content)
        .accessibilityLevel('yes')
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .id(CompId.DIALOG_MIN_TITLE)
        .textAlign(TextAlign.Start)
        .margin({
          left: $r('app.float.common_margin8'),
          right: $r('app.float.common_margin8')
        })
    } else {
      // 弹出框不存在标题时，文本使用显示内容字重需要加大。增强显示效果
      Text(this.content)
        .accessibilityLevel('yes')
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
  cellularDownloadDialogButton() {
    Row() {
      DialogButton({
        text: this.cancelButtonText,
        color: $r('sys.color.ohos_id_color_text_primary_activated'),
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        isDisabled: false,
        click: () => {
          HiLog.info(TAG, `CellularTransmissionDialog cancel click`);
          this.cancel();
          this.closeDialog();
        }
      })
      DialogButtonDivider()
      DialogButton({
        text: this.confirmButtonText,
        isDisabled: false,
        color: $r('sys.color.ohos_id_color_text_primary_activated'),
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        click: () => {
          HiLog.info(TAG, `CellularTransmissionDialog confirm click`);
          this.confirm();
          this.closeDialog();
        }
      })
    }.width('100%')
    .margin({
      top: $r('app.float.common_margin8')
    })
  }
}