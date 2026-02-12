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

import { DialogButtonDivider, DialogButton } from './DialogComponent';
import {
  Constant,
  CopyCutConst,
  FileUtil,
  HiLog,
  ResultCode,
  WorkerConst
} from '@ohos/common';

const TAG: string = 'CopyCutErrorDialog';

/**
 * 移动复制失败弹框
 */
@Component
@CustomDialog
export struct CopyCutErrorDialog {
  controller?: CustomDialogController;

  sendConflictChooseResult: Function = () => {};

  /**
   * 判断是否是深色模式
   */
  @StorageProp('isDarkMode') isDarkMode: boolean = false;

  /**
   * 源文件名称
   */
  srcName: string = '';
  /**
   * 展示名称
   */
  fileName: string = '';
  /**
   * 是否是多选
   */
  isMulti: boolean = false;
  /**
   * 是否应用到全部
   */
  applyAll: boolean = false;
  /**
   * 内容
   */
  content?: Resource = undefined;
  /**
   * 是否是复制
   */
  isCopy: boolean = false;
  /**
   * 任务类型
   */
  taskType?: WorkerConst.OperateType;
  /**
   * 拉起进度弹框
   */
  showProgressCall?: Function;

  /**
   * 是否是单文件
   */
  isSingleFile: boolean = false;

  isFolder: boolean = false;

  isSpecialCharacters: boolean = false;

  isFileInitError: boolean = false;

  errCode?: ResultCode.Error;

  /**
   * 停止点击事件
   */
  stopClick() {
    this.sendConflictChooseResult(this.applyAll, CopyCutConst.ChooseType.STOP);
    this.controller?.close();
  }

  /**
   * 跳过点击事件
   */
  skipClick() {
    this.sendConflictChooseResult(this.applyAll, this.isFolder ? CopyCutConst.ChooseType.SKIP_FOLDER :
    CopyCutConst.ChooseType.SKIP_FILE);
    this.controller?.close();
    if (this.showProgressCall) {
      this.showProgressCall();
    }
  }

  aboutToAppear() {
    HiLog.warn(TAG, 'CopyCutErrorDialog about to appear.' +
      `isSpecialCharacters: ${this.isSpecialCharacters}, taskType: ${this.taskType}`);
    if (this.isSpecialCharacters) {
      this.content = $r('app.string.not_support_characters_new', Constant.FILENAME_REGEXP_CONTENT);
      return;
    }
    this.fileName = FileUtil.dealCopyCutNameLength(this.srcName);
    if (!this.taskType) {
      this.content = $r('app.string.copy_fail_content_dlg', this.fileName);
      return;
    }

    if (this.errCode && this.errCode === ResultCode.Error.OPERATE_DUP_FOLDER_FROM_CHILD_TO_PARENT) {
      this.content = $r('app.string.operate_dupFolder_from_child_to_parent', this.fileName);
      return;
    }

    switch (this.taskType) {
      case WorkerConst.OperateType.CUT_FILE:
        this.content = $r('app.string.move_fail_content_dlg', this.fileName);
        break;
      case WorkerConst.OperateType.COPY_FILE:
        this.content = $r('app.string.copy_fail_content_dlg', this.fileName);
        break;
      case WorkerConst.OperateType.DRAG_FILE:
        this.content = $r('app.string.drag_fail_content_dlg', this.fileName);
        break;
    }
  }

  build() {
    Column() {
      this.dialogTitle();
      this.dialogContent();
      this.applyAllView();
      this.bottomButton();
    }
  }

  @Builder
  bottomButton() {
    Row() {
      DialogButton({
        text: $r('app.string.discontinue'),
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
    }.padding({
      top: $r('app.float.common_margin8'),
      bottom: $r('sys.float.padding_level8'),
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8')
    })
  }

  @Builder
  applyAllView() {
    if (this.isMulti) {
      Row() {
        Checkbox()
          .select(false)
          .selectedColor($r('sys.color.ohos_id_color_text_primary_activated'))
          .onChange((value: boolean) => {
            this.applyAll = value;
          })
          .shape(CheckBoxShape.ROUNDED_SQUARE)
        Text($r('app.string.apply_all'))
          .fontSize($r('app.float.common_font_size14'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.ohos_id_color_foreground'))
          .fontFamily('HarmonyHeiTi')
          .width('100%')
          .padding({ left: $r('app.float.common_padding14') })
      }.padding({
        top: $r('app.float.common_padding15'),
        left: $r('app.float.common_padding20') })
    }
  }

  @Builder
  dialogContent() {
    Text(this.content)
      .fontSize($r('app.float.common_font_size16'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.ohos_id_color_text_primary'))
      .fontFamily('HarmonyHeiTi')
      .width('100%')
      .opacity($r('app.float.common_opacity9'))
      .padding({
        left: $r('sys.float.padding_level12'),
        right: $r('sys.float.padding_level12')
      })
      .textAlign(TextAlign.Center)
  }

  @Builder
  dialogTitle() {
    Text($r('app.string.note'))
      .fontSize($r('app.float.common_font_size20'))
      .fontWeight(FontWeight.Bold)
      .fontColor($r('sys.color.ohos_id_color_foreground'))
      .fontFamily('HarmonyHeiTi')
      .height($r('app.float.common_size56'))
      .width('100%')
      .padding({
        left: $r('sys.float.padding_level12'),
        right: $r('sys.float.padding_level12')
      })
      .textAlign(TextAlign.Center)
  }
}
