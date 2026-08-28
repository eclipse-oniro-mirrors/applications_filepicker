/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { Constant, EventBus } from '@ohos/common';
import { DialogTitle } from '@ohos/customDialog/src/main/ets/default/view/dialog/DialogComponent';
import { CompressDialog } from '../CompressDialogs';

export class CompressErrorDialogOptions {
  public title: ResourceStr = 'Title';
  public message: ResourceStr = 'Message';
  public confirmText: ResourceStr = 'OK';
  public onConfirm = () => {};
}


// 压缩错误弹框
@Component
export struct CompressErrorDialog {
  @StorageProp(CompressDialog.COMPRESS_ERROR_DIALOG_KEY) @Watch('onCompressErrorDialogChange')
    errorDialogOptions?: CompressErrorDialogOptions = undefined;
  private controller?: CustomDialogController;
  private closeDialogBind: () => void = () => this.closeDialog();

  aboutToAppear(): void {
    EventBus.on(Constant.EVENTS.CLOSE_INFO_DISPLAY_DIALOGS, this.closeDialogBind);
  }

  aboutToDisappear(): void {
    EventBus.off(Constant.EVENTS.CLOSE_INFO_DISPLAY_DIALOGS, this.closeDialogBind);
  }

  closeDialog(): void {
    if (this.controller) {
      this.controller.close();
      this.controller = undefined;
    }
  }

  build() {
  }

  @Builder
  confirmButton() {
    Row() {
      Button(this.errorDialogOptions?.confirmText)
        .onClick(() => {
          this.errorDialogOptions?.onConfirm();
        })
        .type(ButtonType.Normal)
        .constraintSize({ minHeight: 40 })
        .width('100%')
        .borderRadius($r('sys.float.corner_radius_level10'))
        .fontColor($r('sys.color.font_emphasize'))
        .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
    }.padding({
      left: $r('app.float.common_padding16'),
      right: $r('app.float.common_padding16'),
      top: $r('app.float.common_padding8'),
      bottom: $r('app.float.common_padding16')
    })
  }

  @Builder
  builder() {
    Column() {
      Column() {
        DialogTitle({ title: this.errorDialogOptions?.title as Resource });
        Text(this.errorDialogOptions?.message)
          .width('100%')
          .textAlign(TextAlign.Center)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }.padding({ left: $r('app.float.common_padding24'), right: $r('app.float.common_padding24') })
      this.confirmButton();
    }
  }

  onCompressErrorDialogChange() {
    if (!this.errorDialogOptions) {
      this.controller?.close();
      this.controller = undefined;
      return;
    }
    this.controller = new CustomDialogController({
      builder: this.builder,
      alignment: DialogAlignment.Center,
      backgroundBlurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
      cancel: () => {
        this.controller = undefined;
      },
      autoCancel: false
    });
    this.controller.open();
  }
}

