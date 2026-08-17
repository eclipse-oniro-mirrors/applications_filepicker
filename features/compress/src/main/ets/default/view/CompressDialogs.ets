/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { CompressErrorDialog, CompressErrorDialogOptions } from './dialogs/CompressErrorDialog';
import { CompressPasswordDialog, PasswordDialogOptions } from './dialogs/CompressPasswordDialog';
import { CompressProgressDialog, ProgressDialogOptions } from './dialogs/CompressProgressDialog';
import { Constant, EventBus, FileCompressBusiness, HiLog, PrivacyModeManager } from '@ohos/common';
import { DecompressLoadingDialog } from './dialogs/DecompressLoadingDialog';
import { PartDecompressDialogOptions, PartDecompressLoadingDialog } from './dialogs/PartDecompressLoadingDialog';
import lazy { FileCompressConst } from '@ohos/common/indexLazyLoad';
import { StandardErrCode } from '@ohos/common/src/main/ets/workermanager/filecompressmanager/CompressStandardErrCode';
import { CompressDataUtil } from '../utils/CompressDataUtil';


/**
 * 压缩解压对话框 控制方法
 */
export class CompressDialog {
  public static readonly PASSWORD_DIALOG_KEY = 'PASSWORD_DIALOG_KEY';
  public static readonly PENDING_DECOMPRESS_KEY = 'PENDING_DECOMPRESS_KEY';
  public static readonly COMPRESS_ERROR_DIALOG_KEY = 'COMPRESS_ERROR_DIALOG_KEY';
  public static readonly PROGRESS_DIALOG_KEY = 'PROGRESS_DIALOG_KEY';
  public static readonly DECOMPRESS_LOADING_KEY = 'DECOMPRESS_LOADING_KEY';
  public static readonly PART_DECOMPRESS_LOADING_KEY = 'PART_DECOMPRESS_LOADING_KEY';

  // 打开密码框
  public static openPasswordDialog(options: PasswordDialogOptions) {
    PrivacyModeManager.getInstance().setPrivacyMode(true);
    AppStorage.setOrCreate(CompressDialog.PASSWORD_DIALOG_KEY, options);
  }

  // 显示密码错误提示与否（换新对象写入，触发 @Watch，使 CustomDialog 内红字刷新）
  public static showPasswordDialogError(show: boolean = true) {
    const options = AppStorage.get<PasswordDialogOptions>(CompressDialog.PASSWORD_DIALOG_KEY);
    if (!options) {
      return;
    }
    const next = new PasswordDialogOptions();
    next.error = show;
    next.onConfirm = options.onConfirm;
    next.onCancel = options.onCancel;
    AppStorage.setOrCreate(CompressDialog.PASSWORD_DIALOG_KEY, next);
  }

  // 关闭密码框
  public static closePasswordDialog() {
    AppStorage.setOrCreate(CompressDialog.PASSWORD_DIALOG_KEY, undefined);
    const timer = setTimeout(() => {
      PrivacyModeManager.getInstance().setPrivacyMode(false);
      clearTimeout(timer);
    }, 200);
  }

  // 显示错误弹框
  public static showErrorDialog(
    title: ResourceStr,
    message: ResourceStr,
    confirmText: ResourceStr,
    callback: Function = () => {}) {
    const options = new CompressErrorDialogOptions();
    options.title = title;
    options.message = message;
    options.confirmText = confirmText;
    options.onConfirm = () => {
      AppStorage.setOrCreate(CompressDialog.COMPRESS_ERROR_DIALOG_KEY, undefined);
      callback?.();
    };
    AppStorage.setOrCreate(CompressDialog.COMPRESS_ERROR_DIALOG_KEY, options);
  }

  // 显示压缩解压进度框
  public static showProgressDialog(workerName: string) {
    const options = new ProgressDialogOptions();
    options.workerName = workerName;
    options.taskType = workerName.startsWith(Constant.OPERATION_TYPE.COMPRESSION) ?
      Constant.OPERATION_TYPE.COMPRESSION :
      Constant.OPERATION_TYPE.DECOMPRESSION;
    options.onCancel = () => {
      FileCompressBusiness.fileCompressCancel(workerName);
      AppStorage.setOrCreate(CompressDialog.PROGRESS_DIALOG_KEY, undefined);
    };
    AppStorage.setOrCreate(CompressDialog.PROGRESS_DIALOG_KEY, options);
  }

  public static closeProgressDialog() {
    AppStorage.setOrCreate(CompressDialog.PROGRESS_DIALOG_KEY, undefined);
  }

  public static showNoTitleMessageBox(message: ResourceStr, confirmText: ResourceStr, callback: Function) {
    const options = new CompressErrorDialogOptions();
    options.title = $r('app.string.note');
    options.message = message;
    options.confirmText = confirmText;
    options.onConfirm = () => {
      callback();
      AppStorage.setOrCreate(CompressDialog.COMPRESS_ERROR_DIALOG_KEY, undefined);
    };
    AppStorage.setOrCreate(CompressDialog.COMPRESS_ERROR_DIALOG_KEY, options);
  }

  public static openDecompressProcessingDialog(taskId: number) {
    // 打开文件解压加载弹窗
    AppStorage.setOrCreate<number>(CompressDialog.DECOMPRESS_LOADING_KEY, taskId);
  }

  public static closeDecompressProcessingDialog() {
    // 关闭文件解压加载弹窗
    AppStorage.setOrCreate<number>(CompressDialog.DECOMPRESS_LOADING_KEY, 0);
  }

  public static openPartDecompressProcessingDialog(option: PartDecompressDialogOptions) {
    // 打开部分解压缩加载弹窗
    AppStorage.setOrCreate<PartDecompressDialogOptions>(CompressDialog.PART_DECOMPRESS_LOADING_KEY, option);
  }

  public static closePartDecompressProcessingDialog() {
    // 关闭部分解压缩加载弹窗
    AppStorage.setOrCreate(CompressDialog.PART_DECOMPRESS_LOADING_KEY, undefined);
  }
}


@Component
export struct CompressDialogs {
  private TAG: string = 'CompressDialogs';

  aboutToAppear(): void {
    HiLog.info(this.TAG, 'aboutToAppear');
    EventBus.on(Constant.EVENTS.COMPRESS_OR_DECOMPRESS_FAIL, this.compressFailBind, true);
    EventBus.on(Constant.EVENTS.COMPRESS_TASK_END, this.compressTaskEndBind, true);
  }

  aboutToDisappear(): void {
    HiLog.info(this.TAG, 'aboutToDisappear');
    EventBus.off(Constant.EVENTS.COMPRESS_OR_DECOMPRESS_FAIL, this.compressFailBind);
    EventBus.off(Constant.EVENTS.COMPRESS_TASK_END, this.compressTaskEndBind);
  }

  build() {
    Column() {
      // 解压密码框
      CompressPasswordDialog();
      // 压缩解压错误弹框
      CompressErrorDialog();
      CompressProgressDialog();
      DecompressLoadingDialog();
      PartDecompressLoadingDialog();
    }.width(0).height(0)
  }

  private compressTaskEndBind = () => {
    AppStorage.delete(CompressDialog.PENDING_DECOMPRESS_KEY);
  }

  private compressFailBind = (taskType: FileCompressConst.TaskType, errCode: StandardErrCode) => {
    HiLog.warn(this.TAG, `taskType: ${taskType}, errorCode: ${errCode}`);
    CompressDialog.closeProgressDialog();
    CompressDialog.closePasswordDialog();
    AppStorage.delete(CompressDialog.PENDING_DECOMPRESS_KEY);
    const title = CompressDataUtil.getDialogErrorTitle(taskType);
    const message = CompressDataUtil.getDialogErrorMsg(errCode);
    CompressDialog.showErrorDialog(title, message, $r('app.string.get_it'));
  }
}

