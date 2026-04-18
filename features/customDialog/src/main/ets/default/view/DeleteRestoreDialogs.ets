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
  EventBus,
  FileUtil,
  FsUtil,
  HiLog,
  StringUtil,
  FileInfo,
  toast
} from '@ohos/common';
import { DeleteRestoreProgressDialog } from './dialog/DeleteProgressDialog';
import { CopyCutFailResultDialog } from './dialog/CopyCutFailResultDialog';
import { DeleteRestoreManager } from '../manager/DeleteRestoreManager';
import UnableOpenFileDialog from './dialog/UnableOpenFileDialog';

const TAG = 'DeleteRestoreDialogs';

const MAX_PROCESS: number = 100;

/**
 * 删除还原操作
 */
@Component
export struct DeleteRestoreDialogs {
  // 已操作完成的文件列表
  deletedRestoredFileUriList: string[] = [];
  // 当前操作类型
  operationType: string = '';
  // 操作的文件总个数
  totalFileCount: number = 0
  // 是否为最近删除里的文件
  isFromRecentDelete: boolean = false;
  // 任务是否正常结束
  isDeleteRestoreFileTaskNormalEnd: boolean = false;
  // 任务是否被取消
  isCanceled: boolean = false;
  deleteRestoreManager: DeleteRestoreManager = new DeleteRestoreManager();
  // 删除还原进度弹窗
  deleteRestoreProgressDialogController?: CustomDialogController;
  // 删除还原失败结果提示弹窗
  deleteRestoreFailResultDialogController?: CustomDialogController;
  startDeleteRestoreTaskBind: Function = (fileList: FileInfo[], operationType: string,
    isFromRecentDelete: boolean = false, mediaSearchType: number = -1) => this.startDeleteRestoreTask(fileList,
    operationType, isFromRecentDelete, mediaSearchType)
  deleteRestoreTaskEndBind: Function = (completeFileCount: number, failFileCount: number,
    failFileName: string) => this.deleteRestoreTaskEnd(completeFileCount, failFileCount, failFileName)
  // 点击最近删除的的文件提示无法打开弹窗
  unableOpenDeletedFileDialogController?: CustomDialogController;
  showUnableOpenFileDialogBind: Function = () => this.showUnableOpenFileDialog()

  aboutToAppear() {
    EventBus.on(Constant.EVENTS.START_DELETE_RESTORE_FILE_TASK, this.startDeleteRestoreTaskBind);
    EventBus.on(Constant.EVENTS.DELETE_RESTORE_FILE_TASK_END, this.deleteRestoreTaskEndBind)
    EventBus.on(Constant.EVENTS.SHOW_UNABLE_OPEN_DELETED_FILE_DIALOG, this.showUnableOpenFileDialogBind)
  }

  aboutToDisappear() {
    EventBus.off(Constant.EVENTS.START_DELETE_RESTORE_FILE_TASK, this.startDeleteRestoreTaskBind)
    EventBus.off(Constant.EVENTS.DELETE_RESTORE_FILE_TASK_END, this.deleteRestoreTaskEndBind)
    EventBus.off(Constant.EVENTS.SHOW_UNABLE_OPEN_DELETED_FILE_DIALOG, this.showUnableOpenFileDialogBind)
  }

  init(operationType: string, isFromRecentDelete: boolean): void {
    this.deleteRestoreManager = new DeleteRestoreManager();
    this.deletedRestoredFileUriList = []
    this.isFromRecentDelete = isFromRecentDelete
    this.operationType = operationType
  }

  /**
   * 是否为还原操作
   */
  isRestoreOpt(): boolean {
    return this.operationType === Constant.OPERATION_TYPE.RESTORE
  }

  /**
   * 开始删除或还原任务
   * @param operationType 操作类型
   * @param fileList 要操作的文件列表
   */
  startDeleteRestoreTask(fileList: FileInfo[], operationType: string, isFromRecentDelete: boolean = false,
    mediaSearchType: number = -1): void {
    if (ArrayUtil.isEmpty(fileList)) {
      HiLog.warn(TAG, 'fileList is empty');
      return;
    }
    HiLog.info(TAG, 'startDeleteRestoreTask mediaSearchType =' + mediaSearchType);
    let listLen = fileList.length;

    if (mediaSearchType !== -1) {
      // 图库相册删除聚合视图图片与视频删除相册删除，操作为删除相册内图片，不删除相册或者文件夹
      for (let i = 0; i < fileList.length; i++) {
        listLen += fileList[i].subFileCount; // 只算子目录的数量
      }
      listLen -= fileList.length; // 删除文件要剔除本身的数量
    }
    HiLog.info(TAG, 'enter startDeleteRestoreTask, totalListLen:' + fileList.length +
      ', listLen = ' + listLen + ', operationType:' + operationType);
    this.init(operationType, isFromRecentDelete);
    this.deleteRestoreManager.registerCallback(
      (completeCount: number, successUris: string[] = []): void => this.updateProgress(completeCount, successUris),
      (deleteRestoreFailFileUri: string): void => this.dealDeleteRestoreFail(deleteRestoreFailFileUri),
      (resolvingFileUri: string): void => this.deleteRestoreCanceled(resolvingFileUri),
    )
    AppStorage.setOrCreate('deleteRestoreTotalFileCount', listLen);
    this.totalFileCount = listLen;
    this.isCanceled = false;
    this.showDeleteRestoreProgressDialog(operationType);
    switch (operationType) {
      case Constant.OPERATION_TYPE.DELETE:
        this.deleteRestoreManager.deleteFiles(fileList, mediaSearchType);
        break;
      case Constant.OPERATION_TYPE.HARD_DELETE:
        this.deleteRestoreManager.hardDeleteFiles(fileList, isFromRecentDelete, mediaSearchType);
        break;
      case Constant.OPERATION_TYPE.RESTORE:
        this.deleteRestoreManager.restoreFiles(fileList);
        break;
      default:
        HiLog.warn(TAG, 'operationType is invalid:' + operationType);
        return;
    }
  }

  /**
   * 展示操作进度弹窗
   * @param operationType 操作类型
   */
  showDeleteRestoreProgressDialog(operationType: string): void {
    this.deleteRestoreProgressDialogController = new CustomDialogController({
      builder: DeleteRestoreProgressDialog({
        operationType: operationType,
        cancel: () => {
          this.cancelDeleteRestore()
        }
      }),
      cancel: () => {
        this.cancelDeleteRestore()
      },
      autoCancel: false,
      alignment: DialogAlignment.Center,
    })
    this.deleteRestoreProgressDialogController.open();
  }

  /**
   * 结束删除还原操作任务
   * @param failFileCount 失败的个数
   * @param failFileName 失败的文件名
   */
  deleteRestoreTaskEnd(completeFileCount: number, failFileCount: number, failFileName: string): void {
    HiLog.warn(TAG, `deleteRestoreTaskEnd:${completeFileCount}_${this.totalFileCount}`)
    if (completeFileCount === this.totalFileCount) {
      this.isDeleteRestoreFileTaskNormalEnd = true
      const uiContext = this.getUIContext();
      // 延时300ms防止和进度弹窗重叠
      let timeoutId = setTimeout(() => {
        if (failFileCount > 0 && !this.isCanceled) {
          this.showDeleteRestoreFailResultDialog(failFileCount, failFileName)
        } else if (this.isFromRecentDelete) {
          uiContext?.runScopedTask(() => {
            if (this.isRestoreOpt()) {
              toast($r('app.string.restore_success'));
            } else {
              toast($r('app.string.del_suc'));
            }
          })
        }
        clearTimeout(timeoutId);
      }, 300)
    }
    this.removeDeletedRestoredFileFromList();
    this.closeDeleteRestoreProgressDialog();
  }

  /**
   * 更新操作进度进度
   * @param completeCount 已处理的文件的个数
   * @param resolvingFileUri 正在处理的文件uri
   */
  updateProgress(completeCount: number, successUris: string[]): void {
    EventBus.emit(Constant.EVENTS.UPDATE_DELETED_RESTORED_FILE_COUNT, completeCount)
    if (ArrayUtil.isEmpty(successUris)) {
      return;
    }
    this.deletedRestoredFileUriList = this.deletedRestoredFileUriList.concat(successUris);
  }

  /**
   * 处理操作失败的场景
   */
  dealDeleteRestoreFail(failFileUri: string): void {
    if (StringUtil.isEmpty(failFileUri)) {
      this.closeDeleteRestoreProgressDialog();
      // 延迟300ms再显示toast，避免和弹窗重叠
      setTimeout(() => {
        if (this.isRestoreOpt()) {
          toast($r('app.string.del_fail'));
        } else {
          toast($r('app.string.restore_fail'));
        }
      }, 300)
    } else {
      // 由于刚开始操作文件时就将uri加入完成的列表了，当操作失败时需再从完成列表中删除
      const index = this.deletedRestoredFileUriList.indexOf(failFileUri);
      if (index !== -1) {
        this.deletedRestoredFileUriList.splice(index, 1)
      }
    }
  }

  /**
   * 操作被取消
   * @param resolvingFileUri 取消前正在处理的文件uri
   */
  deleteRestoreCanceled(resolvingFileUri: string) {
    if (StringUtil.isEmpty(resolvingFileUri)) {
      return;
    }
    this.deletedRestoredFileUriList.push(resolvingFileUri);
    this.removeDeletedRestoredFileFromList();
  }

  /**
   * 取消删除还原操作
   */
  cancelDeleteRestore(): void {
    this.deleteRestoreManager.cancel();
    this.isCanceled = true;
    this.closeDeleteRestoreProgressDialog();
    if (this.isFromRecentDelete) {
      setTimeout(() => {
        // 没有正常操作结束才toast提示取消
        if (!this.isDeleteRestoreFileTaskNormalEnd) {
          if (this.isRestoreOpt()) {
            toast($r('app.string.restore_suspended'));
          } else {
            toast($r('app.string.delete_suspended'));
          }
        }
      }, 300)
    }
  }

  /**
   * 关闭删除还原操作进度弹窗
   */
  closeDeleteRestoreProgressDialog() {
    if (!this.deleteRestoreProgressDialogController) {
      return;
    }
    const progress = AppStorage.get<number>('deleteRestoreProgressCount') ?? 0;
    if (progress < MAX_PROCESS) {
      this.deleteRestoreProgressDialogController.close();
      return;
    }
    this.deleteRestoreProgressDialogController?.close();
  }

  /**
   * 从文件列表中移除已删除或还原的文件
   */
  removeDeletedRestoredFileFromList() {
    const operateSuccessList = this.deletedRestoredFileUriList.slice(0);
    this.deletedRestoredFileUriList = [];
    EventBus.emit(Constant.EVENTS.REMOVE_DELETED_RESTORED_FILE_FROM_LIST, operateSuccessList, this.operationType);
  }

  /**
   * 打开删除还原失败结果弹窗
   * @param operationType 操作类型
   * @param failCount 文件个数
   * @param failFileName 失败的文件名
   */
  showDeleteRestoreFailResultDialog(failCount: number, failFileName: string): void {
    let content: Resource | undefined = undefined

    // 只有一个文件的时候展示“XXX”删除失败
    if (failCount === 1) {
      if (this.isRestoreOpt()) {
        content = $r('app.string.restore_fail_dialog_content_singular', failFileName);
      } else {
        content = $r('app.string.delete_fail_dialog_content_singular', failFileName);
      }
    } else {
      if (this.isRestoreOpt()) {
        content = $r('app.plural.restore_fail_dialog_content_plurals', failCount, failCount);
      } else {
        content = $r('app.plural.delete_fail_dialog_content_plurals', failCount, failCount);
      }
    }
    this.deleteRestoreFailResultDialogController = new CustomDialogController({
      builder: CopyCutFailResultDialog({
        content: content
      }),
      autoCancel: false,
      alignment: DialogAlignment.Center,
    })
    this.deleteRestoreFailResultDialogController.open();
  }

  showUnableOpenFileDialog(): void {
    if (!this.unableOpenDeletedFileDialogController) {
      this.unableOpenDeletedFileDialogController = new CustomDialogController({
        builder: UnableOpenFileDialog(),
        alignment: DialogAlignment.Center,
        autoCancel: false
      })
    }
    this.unableOpenDeletedFileDialogController.open();
  }

  build() {
  }
}