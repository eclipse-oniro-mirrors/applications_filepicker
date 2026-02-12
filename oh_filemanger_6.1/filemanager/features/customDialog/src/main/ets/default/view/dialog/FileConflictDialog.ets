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

import { Constant, CopyCutConst, FileUtil, UiUtil } from '@ohos/common';
import { DialogButtonDivider, DialogButton, DialogTitle } from './DialogComponent';

/**
 * 文件或者文件夹冲突弹框
 */
@Component
@CustomDialog
export struct FileConflictDialog {
  controller?: CustomDialogController;

  sendConflictChooseResult: Function = () => {};

  title: Resource | undefined = undefined;

  /**
   * 源文件名称
   */
  srcName: string = '';

  /**
   * 是否是文件夹
   */
  isFolder: boolean = false;

  isMulti: boolean = false;

  /**
   * 展示名称
   */
  fileName: string = '';

  /**
   * 是否应用到全部
   */
  applyAll: boolean = false;

  /**
   * 拉起进度弹框
   */
  showProgressCall?: Function;

  /**
   * 判断是否是深色模式
   */
  @StorageProp('isDarkMode') isDarkMode: boolean = false;

  // 是否为大字体
  private isBigMode: Boolean = UiUtil.getFontSize() >= Constant.BIG_MODE.BIG_MODE_3_2x;

  /**
   * 跳过点击事件
   */
  skipClick() {
    let chooseType: CopyCutConst.ChooseType = CopyCutConst.ChooseType.SKIP_FILE;
    if (this.isFolder) {
      chooseType = CopyCutConst.ChooseType.SKIP_FOLDER;
    }
    this.sendConflictChooseResult(this.applyAll, chooseType);
    if (this.showProgressCall) {
      this.showProgressCall();
    }
  }


  /**
   * 替换点击事件
   */
  replaceClick() {
    let chooseType: CopyCutConst.ChooseType = CopyCutConst.ChooseType.REPLACE_FILE;
    if (this.isFolder) {
      chooseType = CopyCutConst.ChooseType.REPLACE_FOLDER;
    }
    this.sendConflictChooseResult(this.applyAll, chooseType);
    if (this.showProgressCall) {
      this.showProgressCall();
    }
  }

  /**
   * 合并点击事件
   */
  mergeKeepClick() {
    let chooseType: CopyCutConst.ChooseType = CopyCutConst.ChooseType.KEEP_BOTH_FILE;
    if (this.isFolder) {
      chooseType = CopyCutConst.ChooseType.MERGE_FOLDER;
    }
    this.sendConflictChooseResult(this.applyAll, chooseType);
    if (this.showProgressCall) {
      this.showProgressCall();
    }
  }

  /**
   * 选择结果
   */
  chooseResult?: Function;

  aboutToAppear() {
    this.fileName = FileUtil.dealCopyCutNameLength(this.srcName);
  }

  build() {
    Scroll() {
      Column() {
        // 冲突文件内容
        this.conflitContent();
        // 文件夹提示
        this.folderConflictTip();
        // 应用到全部
        this.applyAllView();
        // 底部按钮
        this.showButton();
      }
    }
  }

  @Builder
  showButton() {
    Column() {
      if (this.isFolder) {
        this.bottomButton();
      } else {
        this.notFolderButton();
      }
    }
    .margin({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
      bottom: $r('sys.float.padding_level8')
    })
  }

  @Builder
  notFolderButton() {
    Row() {
      DialogButton({
        text: $r('app.string.replace'),
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        isDisabled: false,
        click: () => {
          this.controller?.close();
          this.replaceClick();
        }
      })
    }
    .margin( { bottom: $r('app.float.common_margin4') } )

    Row() {
      DialogButton({
        text: $r('app.string.skip'),
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        isDisabled: false,
        click: () => {
          this.controller?.close();
          this.skipClick();
        }
      })
    }
    .margin( { bottom: $r('app.float.common_margin4') } )

    Row() {
      DialogButton({
        text: $r('app.string.keep'),
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        isDisabled: false,
        click: () => {
          this.controller?.close();
          this.mergeKeepClick();
        }
      })
    }
  }

  @Builder
  bottomButton() {
    Row() {
      DialogButton({
        text: $r('app.string.skip'),
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        isDisabled: false,
        click: () => {
          this.controller?.close();
          this.skipClick();
        }
      })

      DialogButtonDivider();

      DialogButton({
        text: $r('app.string.merge'),
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        isDisabled: false,
        click: () => {
          this.controller?.close();
          this.mergeKeepClick();
        }
      })
    }
  }

  @Builder
  applyAllView() {
    if (this.isMulti) {
      Row() {
        Checkbox({ name: 'applyAll', group: 'checkboxGroup' })
          .select(false)
          .selectedColor($r('sys.color.ohos_id_color_text_primary_activated'))
          .shape(CheckBoxShape.CIRCLE)
          .width($r('app.float.common_size20'))
          .height($r('app.float.common_size20'))
          .margin(0)
          .onChange((value: boolean) => {
            this.applyAll = value
          })
        Text($r('app.string.apply_all'))
          .fontSize($r('app.float.common_font_size14'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontFamily('HarmonyHeiTi')
          .width('100%')
          .margin({ left: $r('app.float.common_margin12') });
      }
      .constraintSize({
        minHeight: $r('app.float.common_size48')
      })
      .padding({
        left: $r('app.float.common_padding24'),
        right: $r('app.float.common_padding24'),
        bottom: this.isBigMode ? $r('app.float.common_size8') : 0
      })
      .margin({
        top: $r('app.float.common_padding4'),
        bottom: $r('app.float.common_padding8')
      })
    }
  }

  @Builder
  folderConflictTip() {
    if (this.isFolder) {
      Text($r('app.string.merge_folder_content'))
        .fontSize($r('app.float.common_font_size14'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontFamily('HarmonyHeiTi')
        .width('100%')
        .opacity($r('app.float.common_opacity6'))
        .padding({
          top: $r('app.float.common_padding4'),
          left: $r('app.float.common_padding24'),
          right: $r('app.float.common_padding24')
        });
    }
  }

  @Builder
  conflitContent() {

    DialogTitle({
      title: this.title
    })

    Text(this.isFolder ? $r('app.string.merge_folder_tip_new', this.fileName)
                               : $r('app.string.the_location_already_contains_this_file', this.fileName))
      .fontSize($r('app.float.common_font_size16'))
      .wordBreak(WordBreak.BREAK_WORD)
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.ohos_id_color_text_primary'))
      .fontFamily('HarmonyHeiTi')
      .width('100%')
      .opacity($r('app.float.common_opacity9'))
      .padding({
        left: $r('sys.float.padding_level12'),
        right: $r('sys.float.padding_level12'),
        bottom: this.isBigMode ? $r('app.float.common_size8') : 0
      });
  }
}
