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

import {
  EventBus,
  ERROR_CODE,
  HiLog,
  StringUtil,
  Constant,
  NetworkUtil,
  ObjectUtil,
  ResourceUtil,
  GlobalHolder,
  HiSysEventUtil,
  OperateName,
  OperateResult,
  DisplayUtil,
  CompId,
  toast,
  AccessibilityManager,
  DeviceConfig,
  VirtualUri,
  FsUtil
} from '@ohos/common';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  DialogTitle,
  DialogButton,
  DialogButtonDivider,
  DialogTitleWithButton
} from './DialogComponent';
import lazy { FavoriteDbManager, FileUtil, RenameUtil } from '@ohos/common';
import { SuffixChangeDialog } from './SuffixChangeDialog';
import { inputMethod } from '@kit.IMEKit';
import { accessibility } from '@kit.AccessibilityKit';
import lazy { PhotoAccessUtil } from '@ohos/common/indexLazyLoad';
import { ConfirmTemplateDialog } from './ConfirmTemplateDialog';

const TAG = 'FileRenameDialog';

@CustomDialog
export struct FileRenameDialog {
  inputController: TextInputController = new TextInputController();
  @State isHidden: boolean = false;
  suffixChangeConfirmDialog: CustomDialogController = new CustomDialogController({
    builder: SuffixChangeDialog({
      confirm: (): void => {
        this.startRename();
        this.isHidden = false;
      },
      cancel: (): void => {
        this.newFileName = this.oldFileName;
        this.inputController.setTextSelection(0, this.selectionEndIndex);
        this.isHidden = false;
      },
    }),
    onWillDismiss: () => {
      HiLog.info(TAG, 'suffixChangeConfirmDialog, onWillDismiss');
    },
    autoCancel: false,
    alignment: DialogAlignment.Center
  });
  /**
   * 若尝试在CustomDialog中传入多个其他的Controller，以实现在CustomDialog中打开另一个或另一些CustomDialog
   * 那么此处需要将指向自己的controller放在所有controller的后面
   */
  controller?: CustomDialogController;
  @Consume('isSetDialogWidth') isSetDialogWidth: boolean;
  confirm: Function = () => {
  };
  closeDialogBind: Function = () => this.closeDialog();
  /**
   * 是否为文件夹
   */
  readonly isFolder: boolean = false;
  /**
   * 原文件名
   */
  readonly oldFileName: string = '';
  /**
   * 原文件后缀
   */
  oldSuffix: string = '';

  /**
   * 是否为图库文件
   */
  private isGallery: boolean = false;

  /**
   * 原文件的uri
   */
  readonly oldFileUri: string = '';
  /**
   * 新文件名
   */
  @State newFileName: string = '';
  /**
   * 要选中文本的末尾下标
   */
  selectionEndIndex: number = 0;
  /**
   * 错误信息
   */
  @State errorText?: Resource = undefined;
  /**
   * 是否已超最大长度
   */
  isExceedMaxLen: boolean = false;
  /**
   * 关标上次在的位置
   */
  lastCaretPosition: number = 0;
  /**
   * 判断是否是深色模式
   */
  @StorageProp('isDarkMode') isDarkMode: boolean = false;
  private newFileUri: string = '';
  @Prop isOutsideFolded: boolean = false;

  // 图库文件修改后缀提示
  private galleryFileSuffixChangeDialog = new CustomDialogController({
    builder: ConfirmTemplateDialog({
      title: $r('app.string.note'),
      content: DeviceConfig.getInstance().config.galleryChangeSuffixTip,
      firstButtonText: $r('app.string.get_it'),
      firstButtonCallback: (): void => {
        this.newFileName = this.oldFileName;
        this.inputController.setTextSelection(0, this.selectionEndIndex);
        this.isHidden = false;
      }
    }),
    onWillDismiss: () => {
      HiLog.info(TAG, 'galleryFileSuffixChangeDialog, onWillDismiss');
    },
    autoCancel: false,
    alignment: DialogAlignment.Center
  });

  aboutToAppear() {
    this.initData();
    EventBus.on(Constant.EVENTS.CLOSE_INFO_DISPLAY_DIALOGS, this.closeDialogBind);
    this.isGallery = this.oldFileUri.startsWith(VirtualUri.GALLERY_URI) ||
      this.oldFileUri.startsWith(VirtualUri.GALLERY_PHOTO_URI);
  }

  aboutToDisappear() {
    DisplayUtil.isExistDuplicateBottomBar = false;
    EventBus.off(Constant.EVENTS.CLOSE_INFO_DISPLAY_DIALOGS, this.closeDialogBind);
    // 关闭时隐藏键盘，概率性键盘不消失
    inputMethod.getController().hideTextInput();
    if (!StringUtil.isEmpty(this.newFileUri)) {
      HiLog.info(TAG, 'rename success');
      this.toNewFileViewFocus();
    }
  }

  initData(): void {
    let tempFileName = this.oldFileName;
    const pos = this.oldFileName.lastIndexOf('.');
    if (!this.isFolder) {
      this.oldSuffix = tempFileName.substring(pos);
    }
    this.newFileName = this.oldFileName;
    // 如果文件名超过最大限制，需要截取最大长度文件名，否则会出现输入框中的文件名都不会带文件后缀且文件名截断到最大长度
    const newFileNameLength = StringUtil.strSizeUTF8(this.newFileName);
    let index = this.newFileName.lastIndexOf('.');
    const maxLength = this.getMaxFileNameLength();
    if (newFileNameLength > maxLength) {
      if (index !== -1) {
        this.newFileName = FileUtil.getMaxLengthFileName(this.newFileName, index, maxLength);
      }
    }
    if (this.isFolder) {
      this.selectionEndIndex = this.oldFileName.length;
    } else {
      index = tempFileName.lastIndexOf('.');
      this.selectionEndIndex = index === -1 ? tempFileName.length : index;
    }
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

  toNewFileViewFocus(): void {
    AccessibilityManager.getInstance().sendCustomIdFocusForAccessibility(CompId.FILE_ITEM +
    this.newFileUri);
  }

  async startRename(): Promise<void> {
    HiLog.infoPrivate(TAG, `startRename old `, `uri : ${this.oldFileUri}`);
    let trimNewFileName = this.newFileName.trim();
    if (StringUtil.isEmpty(this.oldFileUri) || StringUtil.isEmpty(trimNewFileName)) {
      HiLog.warn(TAG, 'oldFileUri or newFileName is empty');
      HiSysEventUtil.reportFileOperation(OperateName.RENAME, 'files', OperateResult.FAIL);
      return;
    }
    let newFileUri = '';
    try {
      if (this.oldFileUri.startsWith(Constant.GALLERY_URI_HEAD)) {
        if (this.isFolder) {
          newFileUri = await PhotoAccessUtil.renameAlbum(getContext(this), this.oldFileUri, trimNewFileName);
        } else {
          newFileUri = await PhotoAccessUtil.renameAssets(getContext(this), this.oldFileUri, trimNewFileName);
        }
      } else {
        newFileUri = FileUtil.renameFileByFs(this.oldFileUri, trimNewFileName);
      }
      this.newFileUri = newFileUri;
    } catch (error) {
      HiLog.error(TAG, 'rename fail:' + JSON.stringify(error));
      HiSysEventUtil.reportFileOperation(OperateName.RENAME, 'files', OperateResult.FAIL);
      if (error?.code === ERROR_CODE.FILE_ACCESS.FILE_EXISTS) {
        this.errorText = $r('app.string.sameName');
      } else {
        this.closeDialog();
        toast($r('app.string.rename_fail'));
      }
      return;
    }
    if (this.isFolder) {
      const newFilePath = FileUtil.getPathFromUri(newFileUri);
      const oldFilePath = FileUtil.getPathFromUri(this.oldFileUri);
      FavoriteDbManager.getInstance()
        .updateFileInfoByReName(oldFilePath, newFilePath, trimNewFileName)
        .then(result => {
          if (result) {
            EventBus.emit(Constant.EVENTS.FAVORITE_REFRESH);
          }
        });
    }
    this.confirm(trimNewFileName, newFileUri);
    this.closeDialog();
  }

  onTextInputChange(newValue: string): void {
    const newFileNameLength: number = StringUtil.strSizeUTF8(newValue);
    HiLog.info(TAG, 'newValue byte length:' + newFileNameLength);
    const maxLength = this.getMaxFileNameLength();
    if (newFileNameLength > maxLength) {
      const caretPosition = this.inputController.getCaretOffset().index;
      const afterCaretStr = newValue.substring(caretPosition);
      this.newFileName = FileUtil.getMaxLengthFileName(newValue, caretPosition, maxLength);
      // 超长截取后会触发输入框刷新所以需要记录光标应该所处的位置
      if (StringUtil.isEmpty(afterCaretStr)) {
        this.lastCaretPosition = this.newFileName.length;
      } else {
        this.lastCaretPosition = this.newFileName.lastIndexOf(afterCaretStr);
      }
      this.isExceedMaxLen = true;
      this.errorText = $r('app.string.max_input_length');
    } else if (newFileNameLength === maxLength && this.isExceedMaxLen) {
      // 避免文件名超长截取后错误信息被刷掉
      this.errorText = $r('app.string.max_input_length');
      // 文件名超长截取后需重新设置光标的位置
      this.inputController.caretPosition(this.lastCaretPosition);
      this.isExceedMaxLen = false;
    } else {
      // 超长自动回退的不重置errorText, 输入后仍未超长则需要重置errorText
      if (this.isExceedMaxLen) {
        this.inputController.caretPosition(this.lastCaretPosition);
      } else {
        this.errorText = undefined;
      }
      this.newFileName = newValue;
      this.isExceedMaxLen = false;
    }
  }

  getMaxFileNameLength(): number {
    return this.isGallery ? Constant.MAX_FILENAME_LENGTH - this.oldSuffix.length : Constant.MAX_FILENAME_LENGTH;
  }

  confirmBtnClick(): void {
    let newFileName = this.newFileName.trim();
    if (StringUtil.isEmpty(newFileName)) {
      this.errorText = $r('app.string.emptyName');
      HiSysEventUtil.reportFileOperation(OperateName.RENAME, 'files', OperateResult.FAIL);
      this.formatAnswerTips();
    } else if (RenameUtil.checkOnlyExtension(newFileName, !this.isFolder)) {
      this.errorText = $r('app.string.completeName');
      HiSysEventUtil.reportFileOperation(OperateName.RENAME, 'files', OperateResult.FAIL);
      this.formatAnswerTips();
    } else if (this.isGallery) {
      this.isFolder ? this.galleryAlbumRenameCheck(newFileName) : this.galleryFileRenameCheck(newFileName);
    } else if (!this.isGallery && RenameUtil.checkSpecialChar(newFileName)) {
      this.errorText = $r('app.string.not_support_characters_new', Constant.FILENAME_REGEXP_CONTENT);
      HiSysEventUtil.reportFileOperation(OperateName.RENAME, 'files', OperateResult.FAIL);
      this.formatAnswerTips();
    } else {
      this.errorText = undefined;
      if (this.isFolder || newFileName.endsWith(this.oldSuffix)) {
        this.startRename();
      } else {
        // 文件且后缀发生变化时显示后缀变更弹窗
        this.suffixChangeConfirmDialog.open();
        this.isHidden = true;
      }
    }
  }

  private galleryFileRenameCheck(newFileName: string): void {
    const pos = newFileName.lastIndexOf('.');
    if (pos < 0) { // 如果文件删除后缀，直接提示不允许修改后缀
      HiLog.warn(TAG, 'file suffix is null.');
      this.galleryFileSuffixChangeDialog.open();
      this.isHidden = true;
      return;
    }
    let prefixFileName: string = newFileName.substring(0, pos);
    let newSuffix = newFileName.substring(pos);
    if (newSuffix !== this.oldSuffix) { // 图库文件如果修改后缀，需要单独进行弹窗
      HiLog.warn(TAG, 'galleryRenameCheck different suffixes.');
      this.galleryFileSuffixChangeDialog.open();
      this.isHidden = true;
    } else if (RenameUtil.checkGallerySpecialChar(prefixFileName)) { // 前缀包含特殊字符进行异常提示
      this.errorText = $r('app.string.not_support_characters_new', Constant.GALLERY_FILENAME_REGEXP_CONTENT);
      HiSysEventUtil.reportFileOperation(OperateName.RENAME, 'files', OperateResult.FAIL);
      HiLog.warn(TAG, 'galleryRenameCheck Contains special characters.');
      this.formatAnswerTips();
    } else {
      this.errorText = undefined;
      this.startRename();
    }
  }

  private galleryAlbumRenameCheck(newAlbumName: string): void {
    HiLog.infoPrivate(TAG, `galleryAlbumRenameCheck `, `newAlbumName:${newAlbumName}`)
    if (RenameUtil.checkGallerySpecialChar(newAlbumName)) { // 相册名包含特殊字符进行异常提示
      this.errorText = $r('app.string.not_support_characters_new', Constant.GALLERY_FILENAME_REGEXP_CONTENT);
      HiSysEventUtil.reportFileOperation(OperateName.RENAME, 'folder', OperateResult.FAIL);
      HiLog.warn(TAG, 'galleryAlbumRenameCheck Contains special characters.');
      this.formatAnswerTips();
    } else {
      this.errorText = undefined;
      this.startRename();
    }
  }

  private formatAnswerTips() {
    let announceEventInfo: accessibility.EventInfo = ({
      type: 'announceForAccessibility',
      bundleName: 'com.ohos.filemanager',
      triggerAction: 'common',
      textAnnouncedForAccessibility: ResourceUtil.getStringByResource(this.errorText),
    });
    accessibility.sendAccessibilityEvent(announceEventInfo).then();
  }


  build() {
    Scroll() {
      Column() {
        Column() {
          if (this.isOutsideFolded) {
            DialogTitleWithButton({
              title: $r('app.string.rename'),
              textAlign: TextAlign.Start,
              isButtonDisabled: !this.newFileName,
              confirmFunc: () => { this.confirmBtnClick() },
              cancelFunc: () => { this.closeDialog() }
            })
          } else {
            DialogTitle({
              title: $r('app.string.rename')
            })
          }
        }
        .constraintSize({
          minHeight: 56
        })

        TextInput({ text: this.newFileName, controller: this.inputController })
          .margin({
            left: $r('app.float.common_margin8'),
            right: $r('app.float.common_margin8')
          })
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .draggable(false)
          .defaultFocus(true)
          .id(CompId.RENAME_DIALOG_INPUT)
          .onFocus(() => {
            this.inputController.setTextSelection(0, this.selectionEndIndex);
          })
          .onChange((newValue: string) => {
            this.onTextInputChange(newValue);
          })
          .showUnderline(true)
          .constraintSize({
            minHeight: $r('app.float.common_line_height48')
          })
          .showError(
            ObjectUtil.isUndefined(this.errorText) ? undefined : ResourceUtil.getStringByResource(this.errorText)
          )

        Row() {
          DialogButton({
            text: $r('app.string.cancel'),
            color: $r('sys.color.ohos_id_color_text_primary_activated'),
            bgColor: $r('sys.color.ohos_id_color_button_normal'),
            isDisabled: false,
            click: () => {
              this.closeDialog();
            }
          })
          DialogButtonDivider()
          DialogButton({
            text: $r('app.string.confirm'),
            color: $r('sys.color.ohos_id_color_text_primary_activated'),
            bgColor: $r('sys.color.ohos_id_color_button_normal'),
            isDisabled: !this.newFileName,
            click: () => {
              this.confirmBtnClick();
            }
          })

        }.width('100%')
        .margin({ top: $r('app.float.common_margin8'), bottom: $r('app.float.common_margin16') })
        .visibility(this.isOutsideFolded ? Visibility.None : Visibility.Visible)
      }.padding({
        left: $r('app.float.common_margin16'),
        right: $r('app.float.common_margin16')
      })
    }
    .borderRadius($r('sys.float.ohos_id_corner_radius_dialog'))
    .visibility(this.isHidden ? Visibility.None : Visibility.Visible)
  }
}
