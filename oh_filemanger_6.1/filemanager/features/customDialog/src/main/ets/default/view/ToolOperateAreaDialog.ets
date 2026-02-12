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

import { Constant, DFX, EventBus, HiLog, PageUtil, UEUtil } from '@ohos/common';
import { FileDeleteDialog } from './dialog/FileDeleteDialog';
import { FileMkdirDialog } from './dialog/FileMkdirDialog';

const TAG = 'ToolOperateAreDialog';

/**
 * toolbar 相关dialog
 */
@Component
export struct ToolOperateAreDialog {
  /**
   * 新建文件夹
   */
  private fileMkdirDialog: CustomDialogController | undefined = undefined;
  private deleteAllDialog: CustomDialogController | undefined = undefined;

  downloadProgressDialogController: CustomDialogController | undefined = undefined;

  aboutToAppear() {
    HiLog.warn(TAG, 'tool operate area about to appear');
    EventBus.on(Constant.EVENTS.SHOW_NEW_FOLDER_DIALOG, (fileNameList: string[], parentFolderUri: string,
      callBack: Callback<string, void>): Promise<void> => this.createFolderDialog(fileNameList, parentFolderUri,
      callBack));
    EventBus.on(Constant.EVENTS.SHOW_CLEAR_ALL_FILES_DIALOG,
      (fileNameList: string[]): void => this.deleteAllFilesDialog(fileNameList));
  }

  aboutToDisappear() {
    HiLog.warn(TAG, 'tool operate area about to disappear');
    EventBus.off(Constant.EVENTS.SHOW_NEW_FOLDER_DIALOG);
    EventBus.off(Constant.EVENTS.SHOW_CLEAR_ALL_FILES_DIALOG);
  }

  async createFolderDialog(fileNameList: string[], parentFolderUri: string, callBack: Callback<string, void>) {
    const freeSize = await PageUtil.getLocalFreeSpace();
    if (PageUtil.isInsufficientSpace(freeSize)) {
      HiLog.error(TAG, 'create folder fail: no space');
      EventBus.emit(Constant.EVENTS.SHOW_INSUFFICIENT_DISK_SPACE_DIALOG, DFX.ReasonType.CREATE);
      return;
    }
    this.fileMkdirDialog = new CustomDialogController({
      builder: FileMkdirDialog({
        folderNameList: fileNameList,
        parentFolderUri: parentFolderUri,
        confirm: (folderName: string): void => callBack(folderName)
      }),
      autoCancel: false,
      alignment: DialogAlignment.Center
    });
    this.fileMkdirDialog?.open();
  }

  deleteAllFilesDialog(fileList: string[]): void {
    HiLog.warn(TAG, `delete all files dialog, file length : ${fileList.length}`);
    this.deleteAllDialog = new CustomDialogController({
      builder: FileDeleteDialog({
        title: $r('app.string.clear_all_content'),
        content: $r('app.string.clear_all_content_two'),
        confirmButtonText: $r('app.string.clear_all'),
        confirm: (): void => {
          HiLog.warn(TAG, 'Confirm to delete all files.');
          UEUtil.reportDeleteFile(DFX.PageName.RECENT_DELETE, DFX.DeleteType.DELETE,
            DFX.OperateSource.CLEAR_BUTTON, fileList.length);
          EventBus.emit(Constant.EVENTS.START_DELETE_RESTORE_FILE_TASK,
            fileList, Constant.OPERATION_TYPE.HARD_DELETE, true);
        }
      }),
      autoCancel: false,
      offset: { dx: $r('app.float.dialog_offset_0'), dy: $r('app.float.dialog_offset_12') },
      alignment: DialogAlignment.Bottom
    });
    this.deleteAllDialog?.open();
  }

  build() {
    Column() {
    }.width(0)
    .height(0)
  }
}