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
  Constant,
  CopyCutConst,
  CopyCutResultParam,
  DiskInfo,
  EventBus,
  HiLog,
  ObjectUtil,
  ResultCode,
  UiUtil,
  WorkerConst,
  TraceUtils,
  GlobalHolder,
  GlobalKey,
  getResourceString,
  DeviceConfig,
  FsUtil
} from '@ohos/common';
import { CopyCutErrorDialog } from './dialog/CopyCutErrorDialog';
import { CopyCutProgressDialog } from './dialog/CopyCutProgressDialog';
import { CopyCutRunningDialog } from './dialog/CopyCutRunningDialog';
import { FileConflictDialog } from './dialog/FileConflictDialog';
import { PathErrorDialog } from './dialog/PathErrorDialog';
import { CopyCutFailResultDialog } from './dialog/CopyCutFailResultDialog';
import { StorageDeviceUnmount } from './dialog/StorageDeviceUnmount';
import { ConfirmTemplateDialog } from './dialog/ConfirmTemplateDialog';

const TAG = 'CopyCutDialogs';

/**
 * 复制移动弹框
 */
@Component
export struct CopyCutDialogs {

  cancelWorker: Function = () => {};
  usbSdChange: Function = () => {};
  getTaskIsRun: Function = () => {};
  hideProgress: Function = () => {};
  sendConflictChooseResult: Function = () => {};
  stopTask: Function = () => {};
  storageRemove: Function = (uuid: string) => {};
  continueToRunWorker: Function = () => {};

  private isShowing: boolean = false;
  private isHidden: boolean = false;

  /**
   * 复制移动路径异常弹框
   */
  filePathErrorDialog: CustomDialogController | undefined = undefined;
  /**
   * 复制移动文件异常弹框
   */
  fileConflictDialog: CustomDialogController | undefined = undefined;
  /**
   * 复制移动失败弹框
   */
  copyCutFailDialog: CustomDialogController | undefined = undefined;
  /**
   * 复制移动进度对话框
   */
  copyCutProgressDialog: CustomDialogController | undefined = undefined;
  /**
   * 复制移动正在进行
   */
  copyCutRunningDialog: CustomDialogController | undefined = undefined;
  /**
   * 粘贴移动失败结果弹窗
   */
  copyCutFailResultDialog: CustomDialogController | undefined = undefined;

  /**
   * 存储设备复制粘贴过程中移除存储设备弹窗
   */
  storageDeviceUnmountDialog: CustomDialogController | undefined = undefined;

  pasteErrorDialog: CustomDialogController | undefined = undefined;

  pasteExceptionDialog: CustomDialogController | undefined = undefined;

  /**
   * 复制移动查看弹窗
   */
  copyCutCheckEndResultDialog: CustomDialogController | undefined = undefined;

  private copyCutStartBind: Function = (selectNum: number, destFolderUri: string, targetName: string,
    taskType?: WorkerConst.OperateType):
    void => this.copyCutStart(selectNum, destFolderUri, targetName, taskType);
  private copyCutConflictBind: Function = (conflictType: ResultCode.Exception, taskType: WorkerConst.OperateType,
    param: CopyCutResultParam, errCode: ResultCode.Error):
    void => this.copyCutConflict(conflictType, taskType, param, errCode);
  private copyCutEndBind: Function = (failCount: number, isCancel: boolean = false, isFromPasteboard: boolean = false,
    isShowCheckDialog: boolean = false):
    void => this.copyCutEnd(failCount, isCancel, isFromPasteboard, isShowCheckDialog);
  private showProgressBind: Function = (visible: boolean): void => this.showCopyCutProgress(visible);
  private closeAllCopyCutDialogBind: Function = (): void => this.closeAllCopyCutDialog();
  private sdUsbChangeBind: Function = (diskInfo: DiskInfo[]) => { this.usbSdChange(diskInfo) };
  private removeInPasteStorageDeviceBind: Function = (uuid: string) => { this.handleStorageDeviceUnmountDialog(uuid) };
  private pasteExceptionBind: Function = (exception: ResultCode.Exception, taskType: WorkerConst.OperateType,
    param: CopyCutResultParam)=> this.pasteException(exception, taskType, param);
  private pasteErrorBind: Function = (errCode: ResultCode.Error, taskType: WorkerConst.OperateType,
    param: CopyCutResultParam)=> this.pasteError(errCode, taskType, param);

  aboutToAppear() {
    // 复制移动相关订阅
    this.copyCutOn();
  }

  aboutToDisappear() {
    this.copyCutOff();
  }

  copyCutStart(selectNum: number, destFolderUri: string, targetName: string, taskType?: WorkerConst.OperateType): void {
    this.copyCutProgressVisible(true, selectNum, destFolderUri, targetName, taskType);
  }

  pasteException(exception: ResultCode.Exception, taskType: WorkerConst.OperateType, param: CopyCutResultParam): void {
    HiLog.warn(TAG, `pasteException, Error code: ${exception}`);
    if (ObjectUtil.isNullOrUndefined(exception)) {
      HiLog.error(TAG, 'pasteException no code');
      return;
    }

    if (exception === ResultCode.Exception.EXCEPTION_EXIST_UNSUPPORTED_TYPE) {
      this.handleGalleryExceptionDialog(
        $r('app.string.save_other_type_files_to_gallery_path'),
        $r('app.string.continue'),
        () => {
          this.showCopyCutProgress(true);
          this.continueToRunWorker();
        });
    } else if (exception === ResultCode.Exception.EXCEPTION_GALLERY_ROOT_PASTER_FOLDER) {
      HiLog.info(TAG, 'EXCEPTION_GALLERY_ROOT_PASTER_FOLDER ' + param.operatingFileName)
      this.handleGalleryExceptionDialog(
        $r('app.string.nested_folders_save_files_to_gallery', param.operatingFileName),
        $r('app.string.continue'),
        () => {
          this.showCopyCutProgress(true);
          this.continueToRunWorker();
        });
    } else if (exception === ResultCode.Exception.EXCEPTION_GALLERY_ROOT_PASTER_FOLDERS) {
      this.handleGalleryExceptionDialog(
        $r('app.string.mul_nested_folders_save_files_to_gallery_album'),
        $r('app.string.continue'),
        () => {
          this.showCopyCutProgress(true);
          this.continueToRunWorker();
        });
    } else if (exception === ResultCode.Exception.EXCEPTION_GALLERY_ALBUM_PASTER_FOLDER) {
      this.handleGalleryExceptionDialog(
        $r('app.string.nested_folders_save_files_to_gallery_album'),
        $r('app.string.continue'),
        () => {
          this.showCopyCutProgress(true);
          this.continueToRunWorker();
        });
    } else if (exception === ResultCode.Exception.EXCEPTION_SCREENSHOT_ALBUM_PASTER_UNSUPPORT_FOLDER) {
      this.handleGalleryExceptionDialog(
        $r('app.string.save_image_to_gallery_album', param.operatingFileName),
        $r('app.string.continue'),
        () => {
          this.showCopyCutProgress(true);
          this.continueToRunWorker();
        });
    } else if (exception === ResultCode.Exception.EXCEPTION_SCREENRECORD_ALBUM_PASTER_UNSUPPORT_FOLDER) {
      this.handleGalleryExceptionDialog(
        $r('app.string.save_video_to_gallery_album', param.operatingFileName),
        $r('app.string.continue'),
        () => {
          this.showCopyCutProgress(true);
          this.continueToRunWorker();
        });
    } else {
      HiLog.warn(TAG, `pasteException, unkown exception: ${exception}`);
    }
  }

  pasteError(errCode: ResultCode.Error, taskType: WorkerConst.OperateType, param: CopyCutResultParam): void {
    HiLog.warn(TAG, `pasteError, Error code: ${errCode}`);
    if (!ObjectUtil.isNullOrUndefined(errCode)) {
      this.handleErrorDialog(errCode, taskType, param);
    } else {
      HiLog.error(TAG, 'pasteError no code');
    }
  }

  copyCutConflict(conflictType: ResultCode.Exception, taskType: WorkerConst.OperateType, param: CopyCutResultParam,
    errCode: ResultCode.Error): void {
    HiLog.warn(TAG, `copyCutConflict, conflictType: ${conflictType}, errorCode: ${errCode}`);
    if (!ObjectUtil.isNullOrUndefined(conflictType)) {
      this.handleExceptionDialog(conflictType, taskType, param);
    } else if (!ObjectUtil.isNullOrUndefined(errCode)) {
      this.handleErrorDialog(errCode, taskType, param);
    } else {
      HiLog.error(TAG, 'copyCutConflict no code');
    }
  }

  copyCutEnd(failCount: number, isCancel: boolean = false, isFromPasteboard: boolean = false,
    isShowCheckDialog: boolean = false): void {
    this.copyCutProgressVisible(false);
    if (this.filePathErrorDialog) {
      this.filePathErrorDialog.close();
    }
    if (this.fileConflictDialog) {
      this.fileConflictDialog.close();
    }
    if (this.copyCutFailDialog) {
      this.copyCutFailDialog.close();
    }
    if ((!isCancel) && isFromPasteboard && (failCount !== 0)) {
      this.showCopyCutFailResultDialog(failCount);
    }
    if (!isCancel && failCount === 0 && isShowCheckDialog) {
      this.showCopyCutEndCheckDialog();
    }
  }

  copyCutOn(): void {
    HiLog.info(TAG, 'copyCutOn');
    EventBus.on(Constant.EVENTS.COPY_CUT_START, this.copyCutStartBind, true);
    EventBus.on(Constant.EVENTS.CONFLICT_DIALOG, this.copyCutConflictBind, true);
    EventBus.on(Constant.EVENTS.COPY_CUT_END, this.copyCutEndBind, true);
    EventBus.on(Constant.EVENTS.COPY_CUT_PROGRESS_VISIBLE, this.showProgressBind, true);
    EventBus.on(Constant.EVENTS.CLOSE_COPY_CUT_DIALOG, this.closeAllCopyCutDialogBind, true);
    EventBus.on(Constant.EVENTS.SD_USB_CHANGE, this.sdUsbChangeBind, true);
    EventBus.on(Constant.EVENTS.REMOVE_IN_PASTE_STORAGE_DEVICE, this.removeInPasteStorageDeviceBind, true);

    EventBus.on(Constant.EVENTS.ERROR_PASTE_DIALOG, this.pasteErrorBind, true);
    EventBus.on(Constant.EVENTS.EXCEPTION_PASTE_DIALOG, this.pasteExceptionBind, true);
  }

  copyCutOff(): void {
    HiLog.info(TAG, 'copyCutOff');
    EventBus.off(Constant.EVENTS.COPY_CUT_START, this.copyCutStartBind);
    EventBus.off(Constant.EVENTS.CONFLICT_DIALOG, this.copyCutConflictBind);
    EventBus.off(Constant.EVENTS.COPY_CUT_END, this.copyCutEndBind);
    EventBus.off(Constant.EVENTS.COPY_CUT_PROGRESS_VISIBLE, this.showProgressBind);
    EventBus.off(Constant.EVENTS.CLOSE_COPY_CUT_DIALOG, this.closeAllCopyCutDialogBind);
    EventBus.off(Constant.EVENTS.SD_USB_CHANGE, this.sdUsbChangeBind);
    EventBus.off(Constant.EVENTS.REMOVE_IN_PASTE_STORAGE_DEVICE, this.removeInPasteStorageDeviceBind);
    EventBus.off(Constant.EVENTS.ERROR_PASTE_DIALOG);
    EventBus.off(Constant.EVENTS.EXCEPTION_PASTE_DIALOG);
  }

  build() {
    Column() {
    }.width(0)
    .height(0)
  }

  handleErrorDialog(errCode: ResultCode.Error, taskType: WorkerConst.OperateType, param: CopyCutResultParam) {
    switch (errCode) {
      case ResultCode.Error.SRC_FILE_NOT_EXIST:
        this.handlePathErrorDialog(param);
        break;
      case ResultCode.Error.TASK_LIMIT:
        this.handleTaskRunningDialog(false);
        break;
      case ResultCode.Error.BACK_TO_DESK:
        this.handleTaskRunningDialog(true);
        break;
      case ResultCode.Error.FILE_NAME_INVALID:
        this.handleFileFailDialog(param.operatingFileName, param.isShowApplyAll, taskType, param.totalCount === 1,
          param.operatingFileIsFolder, true, param.isFileInitError);
        break;
      case ResultCode.Error.ERROR_GALLERY_ROOT_PASTER:
        this.handleFileErrorDialog(
          $r('app.string.save_failed'),
          $r('app.string.failed_save_to_gallery_root_path'),
          $r('app.string.get_it'),
          () => {
            this.closeCopyCutProgressDialog();
            this.cancelWorker();
          });
        break;
      case ResultCode.Error.NO_SPACE_LEFT:
        this.handleFileErrorDialog(
          $r('app.string.note'),
          $r('app.string.space_not_enough'),
          $r('app.string.stop'),
          () => {
            this.closeCopyCutProgressDialog();
            this.cancelWorker();
          });
        break;
      case ResultCode.Error.ERROR_GALLERY_FILE_NAME_INVALID:
        this.handleFileErrorDialog(
          $r('app.string.note'),
          $r('app.string.not_support_characters_new', Constant.GALLERY_FILENAME_REGEXP_CONTENT),
          $r('app.string.stop'),
          () => {
            this.closeCopyCutProgressDialog();
            this.cancelWorker();
          });
        break;
      default:
        this.handleFileFailDialog(param.operatingFileName, param.isShowApplyAll, taskType, param.totalCount === 1,
          param.operatingFileIsFolder, false, param.isFileInitError, errCode);
        break;
    }
  }

  handleFileErrorDialog(title: Resource, content: Resource, firstButtonText: Resource, firstButtonCallback: Function) {
    this.pasteErrorDialog = new CustomDialogController({
      builder: ConfirmTemplateDialog({
        title: title,
        content: content,
        firstButtonText: firstButtonText,
        firstButtonCallback: firstButtonCallback,
      }),
      autoCancel: false,
      alignment: DialogAlignment.Center,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        HiLog.info(TAG, 'handleFileErrorDialog onWillDismiss');
      }
    });
    this.showCopyCutProgress(false);
    this.pasteErrorDialog.open();
  }

  handleGalleryExceptionDialog(content: Resource, buttonText: Resource, buttonCallback: Function) {
    this.pasteExceptionDialog = new CustomDialogController({
      builder: ConfirmTemplateDialog({
        title: $r('app.string.save_file'),
        content: content,
        firstButtonText: $r('app.string.cancel'),
        firstButtonCallback: () => {
          this.closeCopyCutProgressDialog();
          this.cancelWorker(); //待确认
        },
        secondButtonText: buttonText,
        secondButtonCallback: buttonCallback
      }),
      autoCancel: false,
      alignment: DialogAlignment.Center,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        HiLog.info(TAG, 'handleGalleryExceptionDialog onWillDismiss');
      }
    });
    this.showCopyCutProgress(false);
    this.pasteExceptionDialog.open();
  }

  handleStorageDeviceUnmountDialog(uuid: string): void {
    this.storageDeviceUnmountDialog = new CustomDialogController({
      builder: StorageDeviceUnmount({
        uuid: uuid,
        forcedRemove: (uuid: string) => {
          this.storageRemove(uuid);
        }
      }),
      autoCancel: false,
      alignment: DialogAlignment.Center
    });
    this.storageDeviceUnmountDialog.open();
  }

  handleExceptionDialog(conflictType: ResultCode.Exception, taskType: WorkerConst.OperateType,
    param: CopyCutResultParam): void {
    switch (conflictType) {
      case ResultCode.Exception.EXIST_DUPLICATE_FILE:
      case ResultCode.Exception.EXIST_DUPLICATE_FOLDER:
        this.handleFileConflictDialog(param.operatingFileName, param.operatingFileIsFolder, param.isShowApplyAll);
        break;
      default:
        this.handleFileFailDialog(param.operatingFileName, param.isShowApplyAll, taskType, param.totalCount === 1,
          param.operatingFileIsFolder, false, param.isFileInitError);
        break;
    }
  }

  /*
  *  复制移动时，文件不存在弹窗
  */
  handlePathErrorDialog(param: CopyCutResultParam): void {
    HiLog.info(TAG, 'handleFileConflictDialog');
    if (this.filePathErrorDialog) {
      this.filePathErrorDialog.close();
    }
    this.filePathErrorDialog = new CustomDialogController({
      builder: PathErrorDialog({
        isMulti: param.isShowApplyAll,
        isSingleFile: param.totalCount === 1,
        sendConflictChooseResult: (isApplyAll: boolean, chooseResult: CopyCutConst.ChooseType) => {
          this.sendConflictChooseResult(isApplyAll, chooseResult);
        },
        isFolder: param.operatingFileIsFolder,
        isFileInitError: param.isFileInitError,
        fileName: param.operatingFileName,
        showProgressCall: () => {
          this.showCopyCutProgress(true);
        }
      }),
      cancel: () => {
        this.cancelWorker();
      },
      autoCancel: false
    });
    this.showCopyCutProgress(false);
    this.filePathErrorDialog.open();
  }

  /**
   * 复制移动处理文件弹框冲突
   */
  handleFileConflictDialog(item: string, isFolder: boolean, isMulti: boolean ): void {
    HiLog.warn(TAG, 'handleFileConflictDialog');
    if (this.fileConflictDialog) {
      this.fileConflictDialog.close();
    }
    this.showCopyCutProgress(false);
    this.fileConflictDialog = new CustomDialogController({
      builder: FileConflictDialog({
        title: $r('app.string.the_location_already_contains_this_file_title_save_both'),
        srcName: item,
        isFolder: isFolder,
        isMulti: isMulti,
        sendConflictChooseResult: (isApplyAll: boolean, chooseResult: CopyCutConst.ChooseType) => {
          this.sendConflictChooseResult(isApplyAll, chooseResult);
        },
        showProgressCall: () => {
          this.showCopyCutProgress(true);
        }
      }),
      cancel: () => {
        this.cancelWorker();
      },
      autoCancel: false,
      alignment: DialogAlignment.Center
    })
    this.fileConflictDialog.open();
  }

  /**
   * 复制移动处理文件失败
   */
  handleFileFailDialog(srcName: string, isMulti: boolean, taskType: WorkerConst.OperateType, isSingleFile: boolean,
    isFolder: boolean, isSpecialCharacters: boolean, isFileInitError: boolean, errCode?: ResultCode.Error): void {
    HiLog.warn(TAG, `handleFileFailDialog, errorCode: ${errCode}`);
    if (!ObjectUtil.isNullOrUndefined(this.copyCutFailDialog)) {
      this.copyCutFailDialog?.close();
    }
    this.copyCutFailDialog = new CustomDialogController({
      builder: CopyCutErrorDialog({
        srcName: srcName,
        isMulti: isMulti,
        taskType: taskType,
        isSingleFile: isSingleFile,
        isFolder: isFolder,
        isSpecialCharacters: isSpecialCharacters,
        isFileInitError: isFileInitError,
        sendConflictChooseResult: (isApplyAll: boolean, chooseResult: CopyCutConst.ChooseType) => {
          this.sendConflictChooseResult(isApplyAll, chooseResult);
        },
        showProgressCall: () => {
          this.showCopyCutProgress(true);
        },
        errCode: errCode
      }),
      cancel: () => {
        this.cancelWorker();
      },
      autoCancel: false,
      alignment: DialogAlignment.Center
    })
    this.showCopyCutProgress(false);
    this.copyCutFailDialog.open();
  }

  /**
   * 复制移动处理文件失败
   */
  handleTaskRunningDialog(isBackDesk: boolean): void {
    HiLog.debug(TAG, 'handleTaskRunningDialog');
    if (!ObjectUtil.isNullOrUndefined(this.copyCutRunningDialog)) {
      this.copyCutRunningDialog?.close();
    }
    this.copyCutRunningDialog = new CustomDialogController({
      builder: CopyCutRunningDialog({
        isBackToDesk: isBackDesk,
        stopTask: () => {
          this.stopTask();
        },
        showProgressCall: () => {
          this.showCopyCutProgress(true);
        }
      }),
      cancel: () => {
        if (!isBackDesk) {
          this.cancelWorker();
        }
      },
      autoCancel: false,
      alignment: DialogAlignment.Center
    })
    this.copyCutRunningDialog.open();
  }

  showCopyCutProgress(visible: boolean): void {
    HiLog.info(TAG, 'showCopyCutProgress: ' + visible + ', isHidden: ' + this.isHidden);
    if (ObjectUtil.isNullOrUndefined(this.copyCutProgressDialog)) {
      return;
    }
    if (visible && this.copyCutRunningDialog) {
      this.copyCutRunningDialog.close();
    }
    if (!this.isShowing && visible && !this.isHidden) {
      this.openCopyCutProgressDialog();
    }
    if (this.isShowing && !visible) {
      this.closeCopyCutProgressDialog();
    }
  }

  closeCopyCutProgressDialog(): void {
    this.copyCutProgressDialog?.close();
    this.isShowing = false;
  }

  openCopyCutProgressDialog(): void {
    this.copyCutProgressDialog?.open();
    this.isShowing = true;
  }

  copyCutProgressVisible(visible: boolean, selectNum: number = 0, destFolderUri: string = '', targetName: string = '',
    taskType?: WorkerConst.OperateType): void {
    HiLog.info(TAG, 'copyCutProgressVisible： ' + visible);
    if (!ObjectUtil.isNullOrUndefined(this.copyCutProgressDialog) && !visible) {
      TraceUtils.startTrace('copyCutProgressVisible close');
      this.closeCopyCutProgressDialog();
      TraceUtils.finishTrace('copyCutProgressVisible close');
    }
    if (!visible) {
      return;
    }
    // 重置隐藏标志，确保新的操作可以显示弹窗
    this.isHidden = false;
    this.copyCutProgressDialog = new CustomDialogController({
      builder: CopyCutProgressDialog({
        controller: this.copyCutProgressDialog,
        filesNum: selectNum,
        targetName: UiUtil.translateFileNameByUri(destFolderUri, targetName, true),
        taskType: taskType,
        cancelWorker: () => {
          this.cancelWorker();
        },
        hideProgress: (taskType?: WorkerConst.OperateType) => {
          this.hideProgress(taskType);
          this.closeCopyCutProgressDialog();
          this.isHidden = true;
        },
      }),
      cancel: (taskType?: WorkerConst.OperateType) => {
        this.hideProgress(taskType);
        this.isShowing = false;
      },
      autoCancel: false,
      alignment: DialogAlignment.Center
    });
    TraceUtils.startTrace('copyCutProgressVisible open');
    this.openCopyCutProgressDialog();
    TraceUtils.finishTrace('copyCutProgressVisible open');
  }

  showCopyCutFailResultDialog(failCount: number): void {
    if (!ObjectUtil.isNullOrUndefined(this.copyCutFailResultDialog)) {
      this.copyCutFailResultDialog?.close();
    }
    this.copyCutFailResultDialog = new CustomDialogController({
      builder: CopyCutFailResultDialog({
        content: $r('app.plural.copy_fail_result_dialog_content', failCount, failCount)
      }),
      alignment: DialogAlignment.Bottom,
      offset: { dx: $r('app.float.dialog_offset_0'), dy: $r('app.float.dialog_offset_12') }
    });
    this.copyCutFailResultDialog.open();
  }

  showCopyCutEndCheckDialog(): void {
    HiLog.info(TAG, 'showCopyCutEndCheckDialog');
    if (!ObjectUtil.isNullOrUndefined(this.copyCutCheckEndResultDialog)) {
      this.copyCutCheckEndResultDialog?.close();
    }
    this.copyCutCheckEndResultDialog = new CustomDialogController({
      builder: ConfirmTemplateDialog({
        title: $r('app.string.transfer_completed'),
        content: $r('app.string.file_saved_to', getResourceString(DeviceConfig.getInstance().config.myDevice) + '/'
          + getResourceString($r('app.string.share_folder_name'))),
        firstButtonText: $r('app.string.confirm'),
        firstButtonCallback: () => {
          HiLog.info(TAG, 'showCopyCutEndCheckDialog confirm');
          this.copyCutCheckEndResultDialog?.close();
        },
        secondButtonText: $r('app.string.check'),
        secondButtonCallback: () => {
          HiLog.info(TAG, 'showCopyCutEndCheckDialog check');
          EventBus.emit(Constant.EVENTS.DRAG_JUMP);
        }
      })
    });
    this.copyCutCheckEndResultDialog.open();
  }

  closeAllCopyCutDialog(): void {
    if (!ObjectUtil.isNullOrUndefined(this.filePathErrorDialog)) {
      this.filePathErrorDialog?.close();
    }
    if (!ObjectUtil.isNullOrUndefined(this.fileConflictDialog)) {
      this.fileConflictDialog?.close();
    }
    if (!ObjectUtil.isNullOrUndefined(this.copyCutFailDialog)) {
      this.copyCutFailDialog?.close();
    }

    if (!ObjectUtil.isNullOrUndefined(this.pasteErrorDialog)) {
      this.pasteErrorDialog?.close();
    }
    if (!ObjectUtil.isNullOrUndefined(this.copyCutProgressDialog)) {
      this.copyCutProgressDialog?.close();
    }
  }
}