/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { Constant, EventBus, StringUtil } from '@ohos/common';
import {
  DialogButton,
  DialogButtonDivider,
  DialogTitle
} from '@ohos/customDialog/src/main/ets/default/view/dialog/DialogComponent';
import { CompressDialog } from '../CompressDialogs';

@Observed
export class PasswordDialogOptions {
  @Track public error: boolean = false;
  public onConfirm = (value: string) => {};
  public onCancel = () => {};
}


// 密码输入对话框
@Component
export struct CompressPasswordDialog {
  @StorageLink(CompressDialog.PASSWORD_DIALOG_KEY) @Watch('onPasswordDialogChange')
    passwordDialogOptions?: PasswordDialogOptions = undefined;
  private controller?: CustomDialogController;
  private value: Uint8Array = new Uint8Array();
  /** CustomDialog 内需用 @State 驱动红字刷新，直接改 options.error 不一定重绘 */
  @State private showPwdError: boolean = false;
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
    this.showPwdError = false;
  }

  build() {
  }

  @Builder
  bottomButton() {
    Row() {
      DialogButton({
        text: $r('app.string.cancel'),
        color: $r('sys.color.comp_background_emphasize'),
        bgColor: $r('sys.color.ohos_id_color_background_transparent'),
        isDisabled: false,
        click: () => { this.passwordDialogOptions?.onCancel(); }
      });
      DialogButtonDivider();
      DialogButton({
        text: $r('app.string.confirm'),
        color: $r('sys.color.comp_background_emphasize'),
        bgColor: $r('sys.color.ohos_id_color_background_transparent'),
        isDisabled: this.showPwdError,
        click: () => { // 底层上报错误码有误，暂时在界面侧规避空密码无错误提示问题
          if (this.value.length === 0 && this.passwordDialogOptions) {
            this.passwordDialogOptions.error = true;
            this.showPwdError = true;
          } else {
            this.passwordDialogOptions?.onConfirm(StringUtil.uint8ArrayToString(this.value));
          }
        }
      });
    }.padding({
      left: $r('app.float.common_padding16'),
      right: $r('app.float.common_padding16'),
      bottom: $r('app.float.common_padding16')
    })
  }

  @Builder
  inputBox() {
    Column() {
      TextInput()
        .type(InputType.Password)
        .showPasswordIcon(true)
        .backgroundColor(Color.Transparent)
        .showPasswordIcon(true)
        .borderRadius(0)
        .defaultFocus(true)
        .onChange(value => {
          this.value = StringUtil.stringToUint8Array(value) ?? new Uint8Array();
          this.showPwdError = false;
          if (this.passwordDialogOptions) {
            this.passwordDialogOptions.error = false;
          }
        })
        .padding({ left: 0, right: 0 })
        .constraintSize({ minHeight: 48 })
        .fontSize($r('app.float.common_font_size16'))
        .lineHeight(21)
      Divider()
        .backgroundColor(this.showPwdError ? $r('sys.color.ohos_id_color_warning') : $r('sys.color.icon_primary'))
        .height(1)
        .width('100%')
      if (this.showPwdError) {
        Text($r('app.string.password_error'))
          .margin({ top: 8 })
          .width('100%')
          .fontSize(12)
          .maxLines(2)
          .fontColor($r('sys.color.ohos_id_color_warning'))
      }
    }
    .margin({ top: 16, bottom: 8, left: 8, right: 8 })
  }

  @Builder
  builder() {
    Column() {
      Column() {
        DialogTitle({ title: $r('app.string.enter_decompress_password') });
        this.inputBox();
      }.padding({ left: $r('app.float.common_padding24'), right: $r('app.float.common_padding24') })
      this.bottomButton();
    }.onAppear(() => this.value = new Uint8Array())
  }

  onPasswordDialogChange() {
    if (!this.passwordDialogOptions) {
      this.controller?.close();
      this.controller = undefined;
      this.showPwdError = false;
      return;
    }
    // 弹窗已打开时（错密），同步 @State 以驱动 CustomDialog 内容重绘
    this.showPwdError = !!this.passwordDialogOptions.error;
    if (!this.controller) {
      this.controller = new CustomDialogController({
        builder: this.builder,
        alignment: DialogAlignment.Center,
        backgroundBlurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
        cancel: () => {
          this.passwordDialogOptions?.onCancel();
          this.controller = undefined;
          this.showPwdError = false;
        },
        autoCancel: false
      });
      this.controller.open();
    }
  }
}
