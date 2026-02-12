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

import { getResourceString, toast } from '@ohos/common/src/main/ets/utils/Tools';
import { DialogButton, DialogButtonDivider, DialogTitle } from './DialogComponent';
import {
  ArrayUtil,
  Constant,
  ERROR_CODE,
  EventBus,
  FavoriteDbManager,
  FileUtil,
  GlobalHolder,
  GlobalKey,
  HiLog,
  HiSysEventUtil,
  MyPhoneConstant,
  NetworkUtil,
  ObjectUtil,
  OperateName,
  OperateResult,
  RenameUtil,
  ResourceUtil,
  StringUtil,
  VirtualUri,
  CompId
} from '@ohos/common';
import {  } from '@ohos/common/src/main/ets/const/CompId';
import { accessibility } from '@kit.AccessibilityKit';
import inputMethod from '@ohos.inputMethod';
import lazy { photoAccessHelper } from '@ohos/common/indexLazyLoadTs';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'FileMkdirDialog';

@CustomDialog
export struct FileMkdirDialog {
  controller?: CustomDialogController;
  cancel: Function = () => {
  };
  confirm: Function = () => {
  };
  folderNameList: string[] = [];
  parentFolderUri: string = '';
  closeDialogBind: Function = () => this.closeDialog();
  /**
   * 判断是否是深色模式
   */
  @StorageProp('isDarkMode') isDarkMode: boolean = false;

  aboutToAppear() {
    HiLog.infoPrivate(TAG, 'parentFolderUri: ', this.parentFolderUri);
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
      SettingBootPathComp({
        folderNameList: this.folderNameList,
        parentFolderUri: this.parentFolderUri,
        confirm: this.confirm,
        controller: this.controller,
        closeDialog: this.closeDialog
      });
    }
    .borderRadius($r('sys.float.ohos_id_corner_radius_dialog'))
    .alignItems(HorizontalAlign.End)
  }
}

@Component
struct SettingBootPathComp {
  controller?: CustomDialogController;
  @State newFolderName: string = '';
  @State errorText?: Resource = undefined;
  @State isExceedMaxLen: boolean = false;
  /**
   * 光标上次在的位置
   */
  @State lastCaretPosition: number = 0;
  @State repeatClicks: boolean = false;
  folderNameList: string[] = [];
  parentFolderUri: string = '';
  confirm: Function = () => {
  };
  closeDialog: Function = () => {
  };
  inputController: TextInputController = new TextInputController();

  aboutToAppear() {
    this.newFolderName = this.getNewFolderName();
  }

  getNewFolderName(): string {
    const newFolderText =
      getResourceString(this.parentFolderUri === VirtualUri.GALLERY ? $r('app.string.create_new_album') :
      $r('app.string.addFolder'));
    let tempFolderName = newFolderText;
    if (ArrayUtil.isEmpty(this.folderNameList)) {
      return tempFolderName;
    }
    const regExp = new RegExp(`^${newFolderText}([ ]{1}[0-9]+)*$`);
    const tempFolderNameList = this.folderNameList.filter(fileName => regExp.test(fileName));
    let index = 0;
    while (tempFolderNameList.some(folderName => folderName.toLowerCase() === tempFolderName.toLowerCase())) {
      index += 1;
      tempFolderName = newFolderText + ' ' + index.toString();
    }
    return tempFolderName;
  }

  build() {
    Scroll() {
      Column() {
        DialogTitle({
          title: this.parentFolderUri === VirtualUri.GALLERY ? $r('app.string.create_new_album') :
          $r('app.string.addFolder')
        })

        TextInput({ text: this.newFolderName, controller: this.inputController })
          .margin({
            left: $r('sys.float.padding_level4'),
            right: $r('sys.float.padding_level4')
          })
          .id(CompId.DIALOG_NEW_DOCUMENT_INPUT)
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .draggable(false)
          .defaultFocus(true)
          .onFocus(() => {
            this.inputController.setTextSelection(0, this.newFolderName.length);
          })
          .onChange((newValue: string) => {
            this.onTextInputChange(newValue);
          })
          .constraintSize({
            minHeight: $r('app.float.common_line_height48')
          })
          .showUnderline(true)
          .showError(
            ObjectUtil.isUndefined(this.errorText) ? undefined : ResourceUtil.getStringByResource(this.errorText)
          )

        Row() {
          DialogButton({
            text: $r('app.string.cancel'),
            bgColor: $r('sys.color.ohos_id_color_button_normal'),
            isDisabled: false,
            click: () => {
              this.closeDialog();
              this.hideKeyboard();
            }
          })
          DialogButtonDivider()
          DialogButton({
            text: $r('app.string.confirm'),
            bgColor: $r('sys.color.ohos_id_color_button_normal'),
            isDisabled: !this.newFolderName,
            click: () => {
              this.clickConfirm();
              this.hideKeyboard();
            }
          })
        }.width('100%')
        .margin({ top: $r('sys.float.padding_level4'), bottom: $r('sys.float.padding_level8') })
      }
      .padding({
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8')
      })
    }
  }

  onTextInputChange(newValue: string): void {
    const folderNameByteLen: number = StringUtil.strSizeUTF8(newValue);
    HiLog.info(TAG, 'newValue byte length:' + folderNameByteLen);
    const maxLength = Constant.MAX_FILENAME_LENGTH;
    if (folderNameByteLen > maxLength) {
      const caretPosition = this.inputController.getCaretOffset().index;
      const afterCaretStr = newValue.substring(caretPosition);
      this.newFolderName = FileUtil.getMaxLengthFileName(newValue, caretPosition, maxLength);
      // 超长截取后会触发输入框刷新所以需要记录光标应该所处的位置
      if (StringUtil.isEmpty(afterCaretStr)) {
        this.lastCaretPosition = this.newFolderName.length;
      } else {
        this.lastCaretPosition = this.newFolderName.lastIndexOf(afterCaretStr);
      }
      this.isExceedMaxLen = true;
      this.errorText = $r('app.string.max_input_length');
    } else if (folderNameByteLen === maxLength && this.isExceedMaxLen) {
      this.errorText = $r('app.string.max_input_length');
      this.formatFileNameTips();
      // 文件名超长截取后需重新设置光标的位置
      this.inputController.caretPosition(this.lastCaretPosition);
    } else {
      this.newFolderName = newValue;
      this.isExceedMaxLen = false;
      this.errorText = undefined;
    }
  }

  async clickConfirm(): Promise<void> {
    this.checkAndCreateDir();
  }

  checkAndCreateDir() {
    const folderName = this.newFolderName.trim();

    if (!folderName) {
      this.errorText = $r('app.string.emptyName');
      HiSysEventUtil.reportFileOperation(OperateName.CREATE, 'folder', OperateResult.FAIL);
      this.formatFileNameTips();
      return;
    }

    if (RenameUtil.checkSpecialChar(folderName)) {
      this.errorText = $r('app.string.not_support_characters_new', Constant.FILENAME_REGEXP_CONTENT);
      HiSysEventUtil.reportFileOperation(OperateName.CREATE, 'folder', OperateResult.FAIL);
      this.formatFileNameTips();
      return;
    }

    if (this.checkSameName()) {
      this.errorText = $r('app.string.sameName');
      HiSysEventUtil.reportFileOperation(OperateName.CREATE, 'folder', OperateResult.FAIL);
      this.formatFileNameTips();
      return;
    }
    if (this.repeatClicks) {
      return;
    }
    this.repeatClicks = true;
    if (this.parentFolderUri === VirtualUri.GALLERY) {
      this.createAlbum(folderName);
    } else {
      this.createDir(folderName);
    }
  }

  checkSameName(): boolean {
    if (ArrayUtil.isEmpty(this.folderNameList)) {
      return false;
    }
    const newFolderNameList = this.folderNameList.map(folderName => folderName.toLowerCase())
    return newFolderNameList.includes(this.newFolderName.trim().toLowerCase());
  }

  async createDir(folderName: string): Promise<void> {
    HiLog.infoPrivate(TAG, 'createDir folderName:', folderName);
    this.errorText = undefined;
    if (StringUtil.isEmpty(this.parentFolderUri)) {
      this.parentFolderUri = GlobalHolder.getInstance().getObject<string>(GlobalKey.LOCAL_ROOT_URI);
    }
    let newFolderUri = '';
    try {
      newFolderUri = await FileUtil.createFolderByFs(this.parentFolderUri, folderName)
      HiLog.infoPrivate(TAG, 'createDir newFolderUri:', newFolderUri);
    } catch (error) {
      HiLog.error(TAG, 'createFolder fail, error: ' + JSON.stringify(error))
      HiSysEventUtil.reportFileOperation(OperateName.CREATE, 'folder', OperateResult.FAIL);
      if (error?.code === ERROR_CODE.FILE_ACCESS.FILE_EXISTS) {
        this.errorText = $r('app.string.sameName');
        this.formatFileNameTips();
      } else {
        this.confirm();
        this.closeDialog();
        toast($r('app.string.addFolder_fail'));
      }
      this.repeatClicks = false;
      return;
    }
    FileUtil.syncFile(newFolderUri);
    FavoriteDbManager.getInstance().updateFileInfoByCreateFolder(newFolderUri)
      .then((result: boolean) => {
        if (result) {
          EventBus.emit(Constant.EVENTS.FAVORITE_REFRESH);
        }
      })
    HiSysEventUtil.reportFileOperation(OperateName.CREATE, 'folder', OperateResult.SUCCESS);
    this.confirm(folderName, newFolderUri);
    this.repeatClicks = false;
    this.closeDialog();
  }

  async createAlbum(folderName: string): Promise<void> {
    HiLog.infoPrivate(TAG, 'createAlbum folderName:', folderName);
    this.errorText = undefined;
    try {
      let albumChangeRequest: photoAccessHelper.MediaAlbumChangeRequest =
        photoAccessHelper.MediaAlbumChangeRequest.createAlbumRequest(getContext(), folderName);
      HiLog.infoPrivate(TAG, 'createAlbum albumChangeRequest:' , albumChangeRequest.getAlbum()?.albumUri);
      await photoAccessHelper.getPhotoAccessHelper(getContext())
        .applyChanges(albumChangeRequest);
      HiLog.infoPrivate(TAG, 'createAlbum albumChangeRequest:', albumChangeRequest.getAlbum()?.albumUri);
      HiLog.info(TAG, 'createAlbum success');
      HiSysEventUtil.reportFileOperation(OperateName.CREATE, 'folder', OperateResult.SUCCESS);
      this.confirm(folderName, albumChangeRequest.getAlbum()?.albumUri);
      this.closeDialog();
    } catch (error) {
      HiLog.error(TAG, 'createAlbum fail, error: ' + JSON.stringify(error))
      HiSysEventUtil.reportFileOperation(OperateName.CREATE, 'folder', OperateResult.FAIL);
      if (error?.code === ERROR_CODE.FILE_ACCESS.FILE_EXISTS) {
        this.errorText = $r('app.string.sameName');
        this.formatFileNameTips();
      } else {
        this.closeDialog();
        toast($r('app.string.addFolder_fail'));
      }
    }
    this.repeatClicks = false;
  }

  private formatFileNameTips() {
    let announceEventInfo: accessibility.EventInfo = ({
      type: 'announceForAccessibility',
      bundleName: 'com.ohos.filemanager',
      triggerAction: 'common',
      textAnnouncedForAccessibility: ResourceUtil.getStringByResource(this.errorText),
    });
    accessibility.sendAccessibilityEvent(announceEventInfo).then();
  }

  //规避键盘
  private hideKeyboard(): void {
    try {
      inputMethod.getController().hideTextInput();
    } catch (err) {
      HiLog.info(TAG, `keyBoardHeight ${err}`);
    }
  }
}