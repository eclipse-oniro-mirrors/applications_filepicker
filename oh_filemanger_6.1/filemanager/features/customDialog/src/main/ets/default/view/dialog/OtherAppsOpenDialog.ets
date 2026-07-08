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
import { otherAppOpenData } from '@ohos/common/src/main/ets/model/Common';
import { DialogTitle } from './DialogComponent';
import { EventBus, Constant } from '@ohos/common';
import { LengthMetrics } from '@kit.ArkUI';

@Styles
function pressedStyles() {
  .borderRadius($r('app.float.common_borderRadius12'))
  .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
}

@Styles
function normalStyles() {
  .backgroundColor($r('app.color.transparent_color'))
  .borderRadius($r('app.float.common_borderRadius12'))
}

@CustomDialog
export struct OtherAppsOpenDialog {
  controller?: CustomDialogController;
  cancel: Function = () => {
  };
  confirm: Function = () => {
  };
  private detail: otherAppOpenData[] = [
    {
      title: $r('app.string.text'),
      type: 'text/*'
    },
    {
      title: $r('app.string.audio'),
      type: 'audio/*'
    },
    {
      title: $r('app.string.videos'),
      type: 'video/*'
    },
    {
      title: $r('app.string.images'),
      type: 'image/*'
    },
    {
      title: $r('app.string.other'),
      type: '*/*'
    }];
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
        DialogTitle({
          title: $r('app.string.open_as')
        })
      }.width('100%')
      .padding({ start: LengthMetrics.resource($r('app.float.common_margin20')) })

      Scroll() {
        Column() {
          ForEach(this.detail, (item: otherAppOpenData, index) => {
            Text(item.title)
              .fontSize($r('app.float.common_font_size16'))
              .padding($r('app.float.common_padding12'))
              .width('100%')
              .height($r('app.float.common_size48'))
              .borderColor($r('app.color.transparent_color'))
              .onClick(() => {
                this.closeDialog();
                this.confirm(item.type)
              })
              .stateStyles({
                pressed: pressedStyles,
                normal: normalStyles
              })
            if (index !== (this.detail.length - 1)) {
              Divider()
                .padding({ left: $r('app.float.common_padding12'), right: $r('app.float.common_padding12') })
                .vertical(false)
                .height($r('app.float.divider_strokeWidth1'))
                .color($r('sys.color.ohos_id_color_list_separator'))
            }
          })
        }
        .padding($r('app.float.common_padding8'))
        .borderRadius($r('app.float.common_borderRadius24'))
        .alignItems(HorizontalAlign.Start)
      }
      .scrollBar(BarState.Off)
    }
    .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
    .margin($r('app.float.common_margin12'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_dialog'))
  }
}