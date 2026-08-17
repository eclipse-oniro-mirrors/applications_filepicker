/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
import {
  EncryptCheckTask,
  FileCompressBusiness,
  FileInfo,
  FileUtil,
  HiLog,
  ObjectUtil,
  TaskManager
} from '@ohos/common';
import lazy { FileCompressConst } from '@ohos/common/indexLazyLoad';
import { CompressDialog } from '../view/CompressDialogs';
import { PasswordDialogOptions } from '../view/dialogs/CompressPasswordDialog';
import taskpool from '@ohos.taskpool';
import { StandardErrCode } from '@ohos/common/src/main/ets/workermanager/filecompressmanager/CompressStandardErrCode';

const DECOMPRESS_LOADING_DELAY: number = 500; // 解压任务判断压缩文件加密任务的加载弹窗延时
const TAG: string = 'CompressDataUtil';

export class PendingDecompressContext {
  fileInfo: FileInfo;
  workerName: string;
  destDirPath: string;

  constructor(fileInfo: FileInfo, workerName: string, destDirPath: string) {
    this.fileInfo = fileInfo;
    this.workerName = workerName;
    this.destDirPath = destDirPath;
  }
}

export class CompressDataUtil {
  /**
   * 手机解压缩功能入口
   * @param fileInfo: 文件信息
   * @param destDirPath: 解压路径
   */
  public static fileDecompress(fileInfo: FileInfo, workerName: string, destDirPath: string): void {
    const filePath = FileUtil.getPathFromUri(fileInfo.uri) || fileInfo.relativePath;
    const task = new EncryptCheckTask(filePath);
    TaskManager.getInstance().execute<boolean>(task);
    const taskId = (task.task as taskpool.Task).taskId;
    const timer = setTimeout(() => { CompressDialog.openDecompressProcessingDialog(taskId) }, DECOMPRESS_LOADING_DELAY);
    task.onReceiveData((isEncrypted: boolean | undefined) => {
      HiLog.info(TAG, `taskId: ${taskId}, ret: ${isEncrypted}`);
      clearTimeout(timer);
      CompressDialog.closeDecompressProcessingDialog();
      if (ObjectUtil.isNullOrUndefined(isEncrypted)) {
        HiLog.info(TAG, 'task canceled in fileDecompressForPhone');
        return;
      }
      if (isEncrypted) {
        AppStorage.setOrCreate(CompressDialog.PENDING_DECOMPRESS_KEY,
          new PendingDecompressContext(fileInfo, workerName, destDirPath));
        const option = new PasswordDialogOptions();
        option.onConfirm = (password: string) => {
          CompressDialog.closePasswordDialog();
          CompressDialog.showProgressDialog(workerName);
          FileCompressBusiness.fileDecompress(fileInfo, destDirPath, password, workerName);
        };
        option.onCancel = () => {
          CompressDialog.closePasswordDialog();
          AppStorage.delete(CompressDialog.PENDING_DECOMPRESS_KEY);
        };
        CompressDialog.openPasswordDialog(option);
      } else {
        CompressDialog.showProgressDialog(workerName);
        FileCompressBusiness.fileDecompress(fileInfo, destDirPath, '', workerName);
      }
    })
  }

  public static getDialogErrorTitle(taskType: FileCompressConst.TaskType): Resource {
    return FileCompressConst.DIALOG_ERROR_TITLE_MAP.get(taskType) ?? $r('app.string.decompression_failed');
  }

  public static getDialogErrorMsg(errCode: StandardErrCode): Resource {
    return FileCompressConst.DIALOG_ERROR_MESSAGE_MAP.get(errCode) ?? $r('app.string.compress_service_error');
  }
}
