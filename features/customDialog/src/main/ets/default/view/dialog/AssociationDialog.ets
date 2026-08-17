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
import { DialogButton, DialogButtonDivider, DialogTitle } from './DialogComponent';
import { systemParameterEnhance } from '@kit.BasicServicesKit';
import { Constant, HiLog, UiUtil } from '@ohos/common';

const TAG: string = 'AssociationDialog';

@Component
@CustomDialog
export struct AssociationDialog {
  controller?: CustomDialogController;
  cancel: Function = () => {
  };
  confirm: Function = () => {
  };
  title: Resource = $r('app.string.face_recognition_dialog');
  cancelButtonText: Resource = $r('app.string.not_association');
  confirmButtonText: Resource = $r('app.string.association');
  @State contentAlign: ItemAlign = ItemAlign.Start;
  closeDialogBind: Function = () => this.closeDialog();
  isAccount: boolean = false;
  isBigMode: Boolean = UiUtil.getFontSize() >= Constant.BIG_MODE.BIG_MODE_3_2x;
  /**
   * 判断是否是深色模式
   */
  @StorageProp('isDarkMode') isDarkMode: boolean = false;

  closeDialog(): void {
    if (this.controller) {
      this.controller.close();
    }
  }

  build() {
    Scroll() {
      Column() {
        Column() {
          DialogTitle({
            title: this.title
          })

          if (this.isAccount) {
            Text($r('app.string.do_associated_account_tips'))
              .fontWeight(FontWeight.Medium)
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
              .width('100%')
              .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)
              .alignSelf(ItemAlign.Start)
          }
          if (this.isBigMode) {
            this.bigModeDialogButton()
          } else {
            this.dialogButton();
          }

        }
        .borderRadius($r('sys.float.ohos_id_corner_radius_dialog'))
        .alignItems(HorizontalAlign.Center)
      }
      .padding({
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8')
      })
    }
  }

  @Builder
  dialogButton() {
    Row() {
      DialogButton({
        text: this.cancelButtonText,
        color: $r('sys.color.ohos_id_color_text_primary_activated'),
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        isDisabled: false,
        click: () => {
          HiLog.info(TAG, 'click associationDialog cancel button');
          this.cancel();
          this.controller?.close();
        }
      });
      DialogButtonDivider();
      DialogButton({
        text: this.confirmButtonText,
        isDisabled: false,
        color: $r('sys.color.ohos_id_color_warning'),
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        click: () => {
          HiLog.info(TAG, 'click associationDialog confirm button');
          this.confirm();
          this.controller?.close();
        }
      });
    }.width('100%')
    .margin({
      top: $r('app.float.common_margin8'),
      bottom: $r('sys.float.padding_level8')
    })
  }
  @Builder
  bigModeDialogButton() {
    Column() {
      DialogButton({
        text: this.cancelButtonText,
        color: $r('sys.color.ohos_id_color_text_primary_activated'),
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        isDisabled: false,
        click: () => {
          HiLog.info(TAG, 'click associationDialog cancel button');
          this.cancel();
          this.controller?.close();
        }
      });
      DialogButton({
        text: this.confirmButtonText,
        isDisabled: false,
        color: $r('sys.color.ohos_id_color_warning'),
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        click: () => {
          HiLog.info(TAG, 'click associationDialog confirm button');
          this.confirm();
          this.controller?.close();
        }
      }).margin({ top: $r('app.float.common_margin8') });
    }.width('100%')
    .height('20%')
    .margin({
      top: $r('app.float.common_margin8'),
      bottom: $r('sys.float.padding_level8')
    })
  }
}
