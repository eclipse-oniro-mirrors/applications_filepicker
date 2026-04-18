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
import { CopyCutConst } from '@ohos/common';
import { DialogButton, DialogButtonDivider, DialogTitle } from './DialogComponent';

/**
 * 文件路径异常弹框
 */
@Component
@CustomDialog
export struct PathErrorDialog {
  controller?: CustomDialogController;

  sendConflictChooseResult: Function = () => {};

  /**
   * 是否是多文件
   */
  isMulti: boolean = false;
  /**
   * 是否是文件夹
   */
  isFolder: boolean = false;
  /**
   * 应用到全部
   */
  applyAll: boolean = false;

  /**
   * 拉起进度弹框
   */
  showProgressCall?: Function;

  /**
   * 是否是单文件
   */
  isSingleFile: boolean = false;

  /**
   * 是否在文件初始化的时候发生了异常
   */
  isFileInitError: boolean = false;

  /**
   * 判断是否是深色模式
   */
  @StorageProp('isDarkMode') isDarkMode: boolean = false;
  public fileName: string = '';
  private content: ResourceStr = $r('app.string.no_target_path');

  /**
   * 停止点击事件
   */
  stopClick() {
    this.sendConflictChooseResult(this.applyAll, CopyCutConst.ChooseType.STOP);
    if (this.controller) {
      this.controller.close();
    }
  }

  /**
   * 跳过点击事件
   */
  skipClick() {
    this.sendConflictChooseResult(this.applyAll,
      this.isFolder ? CopyCutConst.ChooseType.SKIP_FOLDER : CopyCutConst.ChooseType.SKIP_FILE);
    if (this.controller) {
      this.controller.close();
    }
    if (this.showProgressCall) {
      this.showProgressCall();
    }
  }

  aboutToAppear(): void {
    if (this.fileName.length !== 0) {
      this.content = $r('app.string.file_not_exist_maybe_removed_renamed_deleted', this.fileName);
    } else {
      this.content = $r('app.string.source_file_not_exist_maybe_removed_renamed_deleted');
    }
  }

  build() {
    Column() {
      DialogTitle({
        title: $r('app.string.note')
      })

      Column() {
        Text(this.content)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.ohos_id_color_foreground'))
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .alignSelf(ItemAlign.Center)
      }
      .width('100%')
      .padding({
        left: $r('sys.float.padding_level4'),
        right: $r('sys.float.padding_level4')
      })

      this.applyAllView();
      this.bottomButton();
    }
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
      bottom: $r('sys.float.padding_level8')
    })
    .outline({width: 0, color: this.isDarkMode ? '#66000000' : '#19000000'})
    .border({width: 0, color: '#33FFFFFF'})
  }

  @Builder
  bottomButton() {
    Row() {
      DialogButton({
        text: $r('app.string.stop'),
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        isDisabled: false,
        click: () => {
          this.stopClick();
        }
      })
      if (!this.isFileInitError && !this.isSingleFile) {
        DialogButtonDivider();
        DialogButton({
          text: $r('app.string.skip'),
          bgColor: $r('sys.color.ohos_id_color_button_normal'),
          isDisabled: false,
          click: () => {
            this.skipClick();
          }
        })
      }
    }
    .padding({
      top: $r('sys.float.padding_level4')
    })
  }

  @Builder
  applyAllView() {
    if (this.isMulti) {
      Row() {
        Checkbox({ name: 'applyAll', group: 'checkboxGroup' })
          .select(false)
          .selectedColor($r('sys.color.ohos_id_color_text_highlight_bg'))
          .onChange((value: boolean) => {
            this.applyAll = value;
          })
        Text($r('app.string.apply_all'))
          .fontSize($r('app.float.common_font_size14'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.ohos_id_color_foreground'))
          .fontFamily('HarmonyHeiTi')
          .width('100%')
          .padding({ left: $r('app.float.common_padding14') })
      }
    }
  }
}