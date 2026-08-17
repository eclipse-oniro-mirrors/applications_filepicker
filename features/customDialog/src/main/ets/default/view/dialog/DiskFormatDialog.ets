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
import { HiLog, ObjectUtil } from '@ohos/common';
import { LengthMetrics } from '@kit.ArkUI';

@CustomDialog
export struct DiskFormatDialog {
  private TAG: string = 'DiskFormatDialog';
  private diskName: string = '';
  private diskType: string = 'vFAT';
  storageSize: string = '';
  controller?: CustomDialogController;
  cancel: () => void = () => {};
  confirm: (type: string) => void = () => {};

  /**
   * 判断是否是深色模式
   */
  @StorageProp('isDarkMode') isDarkMode: boolean = false;

  build() {
    Column() {
      Column() {
        Text(this.diskName)
          .wordBreak(WordBreak.BREAK_ALL)
          .height(56)
          .lineHeight(23)
          .maxLines(2)
          .fontSize($r('sys.float.ohos_id_text_size_headline8'))
          .fontWeight(FontWeight.Bold)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .textAlign(TextAlign.Start)
        Row() {
          Text($r('app.string.PC_FILE_DISK_CAPACITY'))
            .maxLines(1)
            .fontColor($r('sys.color.ohos_id_color_focused_content_primary'))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .lineHeight(22)
            .textAlign(TextAlign.Start)
            .flexGrow(1)
          Text(this.storageSize)
            .maxLines(1)
            .constraintSize({ maxWidth: 100 })
            .fontColor($r('sys.color.ohos_id_color_focused_content_second'))
            .fontSize(14)
            .lineHeight(19)
            .fontWeight(FontWeight.Regular)
        }
        .height(48)
        .width('100%')

        Text($r('app.string.PC_FILE_SYS_FORMAT'))
          .height(20)
          .lineHeight(19)
          .maxLines(1)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.ohos_id_color_focused_content_second'))
          .margin({ top: 28, bottom: 9 })
        Row() {
          Text('vFAT')
            .maxLines(1)
            .fontColor($r('sys.color.ohos_id_color_focused_content_primary'))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .lineHeight(22)
            .textAlign(TextAlign.Start)
            .flexGrow(1)
          Radio({ value: 'vFAT', group: 'Disk_Type_group' })
            .checked(true)
            .height(24)
            .width(24)
            .onChange((isChecked: boolean) => {
              HiLog.info(this.TAG, 'vFAT status is : ' + isChecked);
              this.diskType = isChecked ? 'vFAT' : 'exFAT';
            })
        }
        .height(48)
        .width('100%')

        Divider().height(9).width('100%').color($r('sys.color.ohos_id_color_hover'));
        Row() {
          Text('exFAT')
            .maxLines(1)
            .fontColor($r('sys.color.ohos_id_color_focused_content_primary'))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .lineHeight(22)
            .textAlign(TextAlign.Start)
            .flexGrow(1)
          Radio({ value: 'exFAT', group: 'Disk_Type_group' })
            .checked(false)
            .height(24)
            .width(24)
            .onChange((isChecked: boolean) => {
              HiLog.info(this.TAG, 'exFAT status is : ' + isChecked);
            })
        }
        .height(48)
        .width('100%')
      }
      .margin({ right: 24, left: 24, top: 15 })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)

      Row() {
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text($r('app.string.cancel'))
            .textAlign(TextAlign.Center)
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.ohos_id_text_size_button1'))
            .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
        }
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .borderRadius($r('sys.float.corner_radius_level4'))
        .width(173)
        .height(40)
        .margin({ end: LengthMetrics.vp(16) })
        .onClick(() => {
          this.cancel();
          if (this.controller) {
            this.controller.close();
          }
          HiLog.info(this.TAG, 'diskFormatDialog close, controller : ' + ObjectUtil.isNullOrUndefined(this.controller));
        })

        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text($r('app.string.PC_FILE_START_FORMAT'))
            .textAlign(TextAlign.Center)
        }
        .fontSize($r('sys.float.ohos_id_text_size_button1'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.ohos_id_color_text_secondary_contrary'))
        .backgroundColor($r('sys.color.ohos_id_color_emphasize'))
        .borderRadius($r('sys.float.corner_radius_level4'))
        .enabled(true)
        .width(173)
        .height(40)
        .onClick(() => {
          HiLog.info(this.TAG, 'File format type : ' + this.diskType);
          this.confirm(this.diskType);
          if (this.controller) {
            this.controller.close();
          }
        })
      }
      .padding(16)
    }
    .width(394)
    .borderRadius($r('sys.float.ohos_id_corner_radius_dialog'))
    .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
    .outline({width: 1, color: this.isDarkMode ? '#66000000' : '#19000000', radius: $r('sys.float.ohos_id_corner_radius_dialog')})
    .border({width: 1, color: '#33FFFFFF'})
  }
}