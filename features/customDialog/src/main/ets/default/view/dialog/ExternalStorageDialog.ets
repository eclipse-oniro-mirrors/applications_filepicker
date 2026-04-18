/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import { DialogStyle, HiLog, ObjectUtil } from '@ohos/common';

@CustomDialog
export struct ExternalStorageRemoveDialog {
  private TAG: string = 'ExternalStorageRemoveDialog';
  controller?: CustomDialogController;
  content: Resource = $r('app.string.storage_data_lost_menu');
  cancelText: Resource = $r('app.string.cancel');
  confirmText: Resource = $r('app.string.storage_force_remove');
  cancel: () => void = () => {};
  confirm: () => void = () => {};
  /**
   * 判断是否是深色模式
   */
  @StorageProp('isDarkMode') isDarkMode: boolean = false;

  build() {
    Column() {
      Text(this.content)
        .textAlign(TextAlign.Center)
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .fontWeight(FontWeight.Medium)
        .lineHeight(24)
        .padding({ top: 24, right: 24, bottom: 16, left: 24 })
        .width('100%')
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
      Row() {
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text(this.cancelText)
            .textAlign(TextAlign.Center)
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.ohos_id_text_size_button1'))
            .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
        }
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .borderRadius($r('sys.float.corner_radius_level4'))
        .width(173)
        .height(40)
        .margin({ right: 16 })
        .onClick(() => {
          if (this.controller) {
            this.controller.close();
          }
          HiLog.info(this.TAG, 'externalStorageRemoveDialog close, controller : ' + ObjectUtil.isNullOrUndefined(this.controller));
          this.cancel();
        })

        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text(this.confirmText)
            .textAlign(TextAlign.Center)
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.ohos_id_text_size_button1'))
            .fontColor($r('sys.color.ohos_id_color_warning'))
        }
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .borderRadius($r('sys.float.corner_radius_level4'))
        .width(173)
        .height(40)
        .onClick(() => {
          if (this.controller) {
            this.controller.close();
          }
          HiLog.info(this.TAG, 'externalStorageRemoveDialog close, controller : ' + ObjectUtil.isNullOrUndefined(this.controller));
          this.confirm();
        })
      }
      .padding({ right: 16, bottom: 16, left: 16 })
    }
    .width(394)
    .borderRadius($r('sys.float.ohos_id_corner_radius_dialog'))
    .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .outline({width: 1, color: this.isDarkMode ? '#66000000' : '#19000000', radius: $r('sys.float.ohos_id_corner_radius_dialog')})
    .border({width: 1, color: '#33FFFFFF'})
  }
}

@CustomDialog
export struct FormattingDialog {
  controller?: CustomDialogController;
  private storage = LocalStorage.getShared();

  aboutToAppear() {
    this.storage.setOrCreate<number>('FormattingDialogShowTime', new Date().getTime());
  }

  build() {
    Column() {
      Text($r('app.string.formatting')).fontSize(14).lineHeight(24).padding(24)
    }
    .width(394)
    .borderRadius($r('sys.float.corner_radius_level8'))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('sys.color.ohos_id_color_background'))
  }
}