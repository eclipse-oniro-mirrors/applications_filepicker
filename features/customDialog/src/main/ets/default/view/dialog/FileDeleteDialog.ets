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

import { DialogTitle, DialogButton, DialogButtonDivider } from './DialogComponent';
import {
  EventBus,
  ExternalStorageUtil,
  FileInfo,
  FileUtil,
  GlobalHolder,
  HiLog,
  OpenMediaUtil,
  PAGE_ROUTE_CONST,
  Constant,
  CompId
} from '@ohos/common';

const TAG = 'FileDeleteDialog';
// 弹框中提示最近删除保留天数
const RETENTION_DAYS = 30;

@Component
@CustomDialog
export struct FileDeleteDialog {
  controller?: CustomDialogController;
  cancel: Function = () => {
  };
  confirm: Function = () => {
  };
  title?: Resource = undefined;
  cancelButtonText: Resource = $r('app.string.cancel');
  confirmButtonText: Resource = $r('app.string.delete');
  content: Resource = $r('app.string.cancel');
  // 文件是否可进回收站
  public isShowCheckBox: boolean = false;
  // 外部存储文件数量
  private externalStorageFileNum: number = 0;
  // hoData目录文件数量
  private hoDataFileNum: number = 0;
  private fromPage?: string;
  @State contentAlign: TextAlign = TextAlign.Start;
  closeDialogBind: Function = () => this.closeDialog();
  @State isHardDelete: boolean = false;
  operationFileList: FileInfo[] = [];
  /**
   * 判断是否是深色模式
   */
  @StorageProp('isDarkMode') isDarkMode: boolean = false;
  @State isIncludeFusionAlbum: boolean = false;
  noCancelBtn: boolean = false;
  isDeleteFusionAlbum: boolean = false;

  aboutToAppear() {
    this.isShowCheckBox = this.isShowCheckBox && !FileUtil.containTrashFile(this.operationFileList)

    this.externalStorageFileNum =
      this.operationFileList.filter(item => ExternalStorageUtil.isExternalStorageUri(item.uri)).length;
    if (this.externalStorageFileNum === this.operationFileList.length ||
      this.externalStorageFileNum === this.operationFileList.length) {
      this.isShowCheckBox = false;
    }

    this.isIncludeFusionAlbum =
      this.operationFileList.some(item => (item.hasFusionAssets || item.isFusionAlbum) === true);

    EventBus.on(Constant.EVENTS.CLOSE_INFO_DISPLAY_DIALOGS, this.closeDialogBind);
  }

  aboutToDisappear() {
    EventBus.off(Constant.EVENTS.CLOSE_INFO_DISPLAY_DIALOGS, this.closeDialogBind);
  }

  closeDialog(): void {
    if (this.controller) {
      this.controller.close();
    }
    if (GlobalHolder.getInstance().getObject(Constant.EVENTS.EXIT_MULTI_STATE)) {
      EventBus.emit(Constant.EVENTS.EXIT_MULTI_STATE);
      GlobalHolder.getInstance().deleteObject(Constant.EVENTS.EXIT_MULTI_STATE);
    }
  }

  build() {
    Scroll() {
      Column() {
        if (this.title) {
          DialogTitle({
            title: this.title
          })
        }
        // 视频拉起的场景，仅展示标题和两个选项，不展示描述文字和checkbox
        if (!OpenMediaUtil.isOpenMedia()) {
          this.fileDeleteDialogContent();
          if (this.isShowCheckBox) {
            Row() {
              Checkbox()
                .select(true)
                .selectedColor($r('sys.color.comp_background_emphasize'))
                .shape(CheckBoxShape.CIRCLE)
                .onChange((value: boolean) => {
                  this.isHardDelete = !value;
                })
                .width($r('app.float.common_size20'))
                .height($r('app.float.common_size20'))
              Text($r('app.string.recently_deleted_dialog_tip'))
                .fontSize($r('sys.float.Body_M'))
                .padding($r('sys.float.padding_level2'))
                .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)
            }
            .justifyContent(FlexAlign.Start)
            .width('100%')
            .height($r('app.float.common_line_height48'))
            .padding({
              left: $r('sys.float.padding_level2')
            })
            .margin({
              bottom: $r('app.float.common_margin8'),
            })
          }
        }
        this.fileDeleteDialogButton();
      }
      .padding({
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8'),
        bottom: $r('sys.float.padding_level8')
      })
      .outline({ width: 1, color: this.isDarkMode ? '#66000000' : '#19000000' })
    }
  }

  @Builder
  fileDeleteDialogContent() {
    if (!this.isDeleteFusionAlbum && (FileUtil.containTrashFile(this.operationFileList) ||
      this.externalStorageFileNum === this.operationFileList.length ||
      this.hoDataFileNum === this.operationFileList.length ||
      (this.externalStorageFileNum + this.hoDataFileNum) === this.operationFileList.length ||
      (this.hoDataFileNum > 0 && this.hoDataFileNum < this.operationFileList.length && this.isHardDelete)) ) {
      Text($r('app.string.delete_complete_tips'))
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .id(CompId.DIALOG_MIN_TITLE)
        .textAlign(TextAlign.Start)
        .margin({
          left: $r('app.float.common_margin8'),
          right: $r('app.float.common_margin8')
        })
        .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)
    } else if (this.externalStorageFileNum < this.operationFileList.length && this.externalStorageFileNum !== 0) {
      Text($r('app.string.part_external_file_delete_tips'))
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .id(CompId.DIALOG_MIN_TITLE)
        .textAlign(this.contentAlign)
        .margin({
          left: $r('app.float.common_margin8'),
          right: $r('app.float.common_margin8')
        })
        .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)
    } else if (this.isShowCheckBox) {
      if (this.isHardDelete) {
        Text($r('app.string.delete_complete_tips'))
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .id(CompId.DIALOG_MIN_TITLE)
          .textAlign(this.contentAlign)
          .padding({
            left: $r('app.float.common_margin8'),
            right: $r('app.float.common_margin8')
          })
          .width('100%')
          .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)
      } else {
        Text($r('app.string.move_file_to_recycle', RETENTION_DAYS))
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .id(CompId.DIALOG_MIN_TITLE)
          .textAlign(this.contentAlign)
          .padding({
            left: $r('app.float.common_margin8'),
            right: $r('app.float.common_margin8')
          })
          .width('100%')
          .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)
      }

      if (this.isIncludeFusionAlbum) {
        Text($r('app.string.delete_fusion_album_warning'))
          .fontWeight(FontWeight.Regular)
          .fontSize($r('app.float.common_font_size14'))
          .constraintSize({
            minHeight: $r('app.float.common_line_height19')
          })
          .margin({
            top: $r('sys.float.padding_level2'),
          })
          .padding({
            left: $r('app.float.common_margin8'),
            right: $r('app.float.common_margin8')
          })
          .width('100%')
          .fontColor($r('sys.color.ohos_id_color_foreground'))
          .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)
          .opacity(0.6)
      }

    } else if (this.title) {
      // 删除弹出框存在标题时，文本使用正常格式
      Text(this.content)
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .id(CompId.DIALOG_MIN_TITLE)
        .textAlign(this.contentAlign)
        .margin({
          left: $r('app.float.common_margin8'),
          right: $r('app.float.common_margin8')
        })
        .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)
    } else {
      // 删除弹出框不存在标题时，文本使用显示内容字重需要加大。增强显示效果
      Text(this.content)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .margin({
          top: $r('app.float.common_margin24'),
          left: $r('app.float.common_margin8'),
          right: $r('app.float.common_margin8')
        })
        .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)
        .id(CompId.DIALOG_MIN_TITLE)
        .textAlign(this.contentAlign)
        .onAreaChange((oldValue, newValue) => {
          if ((newValue.height > 20)) {
            this.contentAlign = TextAlign.Start;
          }
        })
    }
  }

  @Builder
  fileDeleteDialogButton() {
    Row() {
      if (!this.noCancelBtn) {
        DialogButton({
          text: this.cancelButtonText,
          color: $r('sys.color.ohos_id_color_text_primary_activated'),
          bgColor: $r('sys.color.ohos_id_color_button_normal'),
          isDisabled: false,
          click: () => {
            this.cancel();
            this.closeDialog();
          }
        });
        DialogButtonDivider();
      }
      DialogButton({
        text: this.confirmButtonText,
        isDisabled: false,
        color: this.isDeleteFusionAlbum ? $r('sys.color.comp_background_emphasize') :
          $r('sys.color.ohos_id_color_warning'),
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        click: () => {
          if (this.isHardDelete) {
            HiLog.info(TAG, 'click hard delete in dialog');
          }
          this.confirm(this.isHardDelete || FileUtil.containTrashFile(this.operationFileList));
          this.closeDialog();
        }
      });
    }.width('100%')
    .margin({
      top: this.isShowCheckBox ? 0 : $r('app.float.common_margin8')
    })
  }
}
