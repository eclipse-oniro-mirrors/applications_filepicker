/*
 * Copyright (c) 2021-2024 Huawei Device Co., Ltd.
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
import { DialogButton, DialogButtonDivider } from './DialogComponent';
import { display } from '@kit.ArkUI';
import Logger from '../../../base/log/Logger';

const TAG = 'DownloadDialog';
let storage = LocalStorage.getShared();

@CustomDialog
export struct DownloadDialog {
  controller?: CustomDialogController;
  cancel: Function = () => {
  };
  confirm: Function = () => {
  };
  appName: string | undefined = storage.get<string>('appName');
  appIcon: string | undefined = storage.get<string>('appIcon');
  downloadTips: Resource = $r('app.string.download_tips', this.appName, this.appName);
  cancelButtonText: Resource = $r('app.string.cancel');
  confirmButtonText: Resource = $r('app.string.agree');
  @State contentAlign: ItemAlign = ItemAlign.Start;
  @State dialogWidth: number = 328;
  closeDialogBind: Function = () => this.closeDialog();

  aboutToAppear(): void {
    let px2VpScale: number = px2vp(1);
    let screenWidth: number = display.getDefaultDisplaySync()?.width ?
    px2vp(display.getDefaultDisplaySync()?.width) : px2vp(display.getDefaultDisplaySync()?.width * px2VpScale);
    this.dialogWidth = screenWidth > 432 ? 400 : screenWidth - 32;
  }

  closeDialog(): void {
    if (this.controller) {
      Logger.i(TAG, 'DownloadDialog close.');
      this.controller.close();
    }
  }

  build() {
    Column() {
      Column() {
        this.downloadDialogContent();
      }
      .padding({
        left: $r('app.float.common_padding24'),
        right: $r('app.float.common_padding24')
      })
    }
    .borderRadius($r('sys.float.ohos_id_corner_radius_dialog'))
    .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
    .alignItems(HorizontalAlign.End)
    .margin({ left: $r('app.float.common_margin16'), right: $r('app.float.common_margin16') })
    .width(this.dialogWidth)
  }

  @Builder
  downloadDialogContent() {
    Row() {
      Image(this.appIcon)
        .fillColor($r('sys.color.ohos_id_color_primary'))
        .objectFit(ImageFit.Contain)
        .width($r('app.float.common_size64'))
        .height($r('app.float.common_size64'))
        .interpolation(ImageInterpolation.High)
        .draggable(false)
        .focusable(true)
        .margin({ top: 24 })
        .autoResize(false)
    }

    Row() {
      Text(this.downloadTips)
        .lineHeight(21)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .margin({ top: $r('app.float.common_margin16') })
        .alignSelf(ItemAlign.Center)
    }

    Row() {
      DialogButton({
        text: this.cancelButtonText,
        isDisabled: false,
        color: '#0A56F7',
        bgColor: '#F1F3F5',
        click: () => {
          this.cancel()
          this.closeDialog()
        }
      })
      DialogButtonDivider()
      DialogButton({
        text: this.confirmButtonText,
        isDisabled: false,
        color: '#0A56F7',
        bgColor: '#F1F3F5',
        click: () => {
          this.confirm();
          this.closeDialog();
        }
      })
    }.width('100%')
    .padding({ bottom: $r('app.float.common_margin10'), top: $r('app.float.common_margin10') })
    .margin({
      top: 8,
    })
  }
}