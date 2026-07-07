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
  ArrayUtil,
  Constant,
  ERROR_CODE,
  EventBus,
  HiLog,
  PasteboardDataModel,
  StringUtil,
  WorkerConst,
  CommonPreferenceUtil,
  FileInfo,
  FileMimeTypeUtil,
  FileUtil,
  DFX
} from '@ohos/common';
import { CopyCutManager } from '../../../base/manager/CopyCutManager';
import { PasteboardReminderDialog } from '@ohos/customDialog/indexPhoneOnly';
import CopyCutConst from '../../../base/constants/CopyCutConst';
import { PathSelectParam } from '../pathselect/PathSelectModel';

const TAG = 'GlobalPasteboard';

/**
 * 全局剪切板公共组件
 */
@Component
export struct GlobalPasteboard {
  @State showTree: boolean = true;
  @State selectFilesList: FileInfo[] = [];
  @State isShowPathSelector: boolean = false;
  pasteboardReminderDialog?: CustomDialogController;
  private backPressCallBackBind: Function = (): void => this.backPressCallBack();
  private selectPathCompleteBind: Function = (folderUri: string): void => this.selectPathComplete(folderUri);
  private openPasteboardReminderDialogBind: Function =
    (pasteboardData: PasteboardDataModel): Promise<void> => this.openPasteboardReminderDialog(pasteboardData);
  @State createResultType: number = ERROR_CODE.PICKER.SAVE_SUCCESS

  aboutToAppear() {
    HiLog.info(TAG, 'enter GlobalPasteboard aboutToAppear');
    this.addEventListener();
  }

  aboutToDisappear() {
    HiLog.warn(TAG, 'enter GlobalPasteboard aboutToDisappear');
    this.removeEventListener();
  }

  addEventListener() {
    EventBus.on(Constant.EVENTS.PASTEBOARD_REMAINDER_DIALOG, this.openPasteboardReminderDialogBind, true);
  }

  removeEventListener() {
    EventBus.off(Constant.EVENTS.PASTEBOARD_REMAINDER_DIALOG, this.openPasteboardReminderDialogBind);
  }

  /**
   * 取消处理剪切板上的数据
   * @param pasteboardData 剪切板上的数据
   */
  cancelResolvePasteboardData(pasteboardData: PasteboardDataModel): void {
    HiLog.info(TAG, 'enter cancelResolvePasteboard');
    CommonPreferenceUtil.setLastResolvePasteboardTimestamp(pasteboardData.timestamp);
  }

  /**
   * 处理剪切板上的数据
   * @param data 剪切板上的数据
   */
  async resolvePasteboardData(pasteboardData: PasteboardDataModel): Promise<void> {
    HiLog.info(TAG, 'enter resolvePasteboardData');
    let fileInfoList: FileInfo[] = [];
    for (let i = 0; i < pasteboardData.fileUriList.length; i++) {
      if (!FileUtil.isUriPath(pasteboardData.fileUriList[i])) {
        HiLog.warn(TAG, 'resolvePasteboardData: illegal uri');
        continue;
      }
      const fileName = FileUtil.getFileNameFromUri(pasteboardData.fileUriList[i]);
      let data = new FileInfo();
      data.uri = pasteboardData.fileUriList[i];
      data.fileName = fileName;

      data.mimeTypeObj = FileMimeTypeUtil.getMimeType(data.fileName, false, 0);
      fileInfoList.push(data);
    }
    this.selectFilesList = fileInfoList;
    this.isShowPathSelector = true;
    const pathSelectParam = new PathSelectParam(this.selectFilesList, Constant.OPERATION_TYPE.PASTING)
    EventBus.emit(Constant.EVENTS.SHOW_PATH_PICKER, pathSelectParam);
    EventBus.on(Constant.EVENTS.BACK_PRESS, this.backPressCallBackBind);
    EventBus.on(Constant.EVENTS.PATH_SELECT_END, this.selectPathCompleteBind);
    CommonPreferenceUtil.setLastResolvePasteboardTimestamp(pasteboardData.timestamp);
    AppStorage.setOrCreate<DFX.PasteType>(DFX.StorageKey.OPERATE_TYPE, DFX.PasteType.CROSS_APP_DIALOG);
  }

  /**
   * 系统返回事件回调
   */
  backPressCallBack(): void {
    EventBus.emit(Constant.EVENTS.CLOSE_PATH_PICKER);
  }

  /**
   * 路径选择完成
   * @param folderUri 选择的文件夹uri
   */
  selectPathComplete(folderUri: string): void {
    HiLog.info(TAG, 'enter selectPathComplete.');
    EventBus.off(Constant.EVENTS.PATH_SELECT_END, this.selectPathCompleteBind);
    EventBus.off(Constant.EVENTS.BACK_PRESS, this.backPressCallBackBind);
    this.isShowPathSelector = false;
    if (StringUtil.isEmpty(folderUri)) {
      HiLog.info(TAG, 'selectPathComplete fail, folderUri or folderName is null');
      return;
    }
    const folderName = FileUtil.getFileNameFromUri(folderUri);
    HiLog.info(TAG, 'start paste file, length: ' + this.selectFilesList.length);
    CopyCutManager.getInstance()
      .pasteCutFile(this.selectFilesList, '', folderUri, WorkerConst.OperateType.COPY_FILE, folderName,
        CopyCutConst.OperateFrom.PASTE_BOARD);
  }

  /**
   * 打开粘贴提醒弹框
   */
  async openPasteboardReminderDialog(pasteboardData: PasteboardDataModel): Promise<void> {
    if (this.isShowPathSelector) {
      HiLog.warn(TAG, 'PathSelector is showing, last operation not completed')
      return
    }
    if (this.pasteboardReminderDialog) {
      this.pasteboardReminderDialog.close()
    }
    let dialogContent: Resource = $r('app.string.pasteboard_dialog_content')
    const fileUriList = pasteboardData.fileUriList
    if (ArrayUtil.isEmpty(fileUriList)) {
      HiLog.warn(TAG, 'fileUriList is empty')
      return
    }

    this.pasteboardReminderDialog = new CustomDialogController({
      builder: PasteboardReminderDialog({
        content: dialogContent,
        pasteboardData: pasteboardData,
        cancel: (pasteboardData: PasteboardDataModel): void => this.cancelResolvePasteboardData(pasteboardData),
        confirm: (pasteboardData: PasteboardDataModel): Promise<void> => this.resolvePasteboardData(pasteboardData)
      }),
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        HiLog.info(TAG, 'PasteboardReminderDialog onWillDismiss');
        dismissDialogAction.dismiss();
      },
      cancel: (): void => {
        this.cancelResolvePasteboardData(pasteboardData)
      },
      autoCancel: false,
      alignment: DialogAlignment.Center
    })
    this.pasteboardReminderDialog.open()
  }

  build() {
  }
}