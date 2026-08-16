/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2026. All rights reserved.
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
  HiLog,
  ObjectUtil,
  VirtualUri,
  FileInfo,
  FileUtil,
  toast,
  ERROR_CODE,
  SystemShareUtil,
} from '@ohos/common';
// import lazy { SystemShareUtil } from '@ohos/common/indexLazyLoad';
import { JSON, taskpool } from '@kit.ArkTS';
import { systemShare } from '@kit.ShareKit';

const TAG = 'FileShareManager';

export class FileShareManager {
  private hasCancel: boolean = false;
  private timer: number | undefined = undefined;
  private cancelWaitingDialogCallBackBind = () => this.cancelWaitingDialogCallBack();

  constructor() {
    this.init()
  }

  /**
   * 初始化成员变量
   */
  private init() {
    this.hasCancel = false;
    this.timer = undefined;
  }

  /**
   * 显示分享弹窗
   * @param fileList 要分享的文件列表
   * @returns 是否正常拉起分享弹窗
   */
  public async showShareDialog(fileList: FileInfo[]): Promise<boolean> {
    HiLog.warn(TAG, `showShareDialog start, fileList length: ${fileList.length}`);
    if (ArrayUtil.isEmpty(fileList)) {
      HiLog.warn(TAG, 'showShareDialog fail, fileList is empty');
      return false;
    }
    // 开启显示请稍候弹窗的定时器
    this.startTimer();
    let tempFileList: FileInfo[] = [];
    // 过滤掉空文件夹暂不支持分享
    for (const file of fileList) {
      // 判断分享是否被取消
      if (this.hasCancel) {
        HiLog.warn(TAG, 'share cancel, filter empty folder ');
        return false;
      }
      if (!file.isFolder) {
        tempFileList.push(file);
        continue;
      }
      let subFileList: string[] = [];
      subFileList = await FileUtil.getSubFileNameByUriWithFs(file.uri, true, true);
      if (ArrayUtil.isEmpty(subFileList)) {
        HiLog.debugPrivate(TAG, 'folder is empty, folderName:', file.fileName);
        continue;
      }
      tempFileList.push(file);
    }
    // 如果过滤后的所有文件夹都为空则给予提示
    if (ArrayUtil.isEmpty(tempFileList)) {
      HiLog.warn(TAG, `all selected folders are empty.`);
      this.stopTimerAndCloseDialog();
      toast($r('app.string.share_folder_no_content'));
      return false;
    } else {
      fileList = tempFileList;
    }
    HiLog.info(TAG, 'filtered fileList length:' + fileList.length);
    try {
      await SystemShareUtil.showShareDialog(fileList);
      HiLog.info(TAG, 'shareDialog show execute');
    } catch (error) {
      HiLog.error(TAG, 'showShareDialog fail, errorCode:' + (error as BusinessError).code +
        `errorMessage:${JSON.stringify((error as BusinessError).message)}`);
      const errorCode: number = Number(error?.code ?? -1);
      if (errorCode === ERROR_CODE.SystemShare.EXCEED_MAXIMUM || errorCode === ERROR_CODE.SystemShare.EXCEED_IPC) {
        let timer = setTimeout(() => {
          toast($r('app.string.share_failed_msg', Constant.FILE_SHARE_LIMIT_NUM));
          clearTimeout(timer);
        }, Constant.TIMER_TIME.TIMER_100);
      }
      this.stopTimerAndCloseDialog();
      return false;
    }
    this.stopTimerAndCloseDialog();
    HiLog.warn(TAG, 'showShareDialog end');
    return true;
  }

  /**
   * 取消分享
   */
  public cancelShare(): void {
    this.hasCancel = true;
  }

  /**
   * 是否已取消
   */
  public checkCancel(): boolean {
    return this.hasCancel
  }

  /**
   * 数据处理超过100ms显示请稍候...弹窗
   */
  private startTimer(): void {
    this.timer = setTimeout(() => {
      EventBus.on(Constant.EVENTS.CANCEL_WAITING_DIALOG, this.cancelWaitingDialogCallBackBind)
      EventBus.emit(Constant.EVENTS.SHOW_WAITING_DIALOG);
    }, 100)
  }

  /**
   * 请稍候...弹窗显示的时候点返回键后标记取消文件分享操作
   */
  private cancelWaitingDialogCallBack(): void {
    this.hasCancel = true;
    this.timer = undefined;
    EventBus.off(Constant.EVENTS.CANCEL_WAITING_DIALOG, this.cancelWaitingDialogCallBackBind)
    HiLog.info(TAG, 'cancelWaitingDialogCallBack execute');
  }


  /**
   * 数据处理完成停止定时器并关闭请稍候...弹窗
   */
  private stopTimerAndCloseDialog(): void {
    if (!ObjectUtil.isNullOrUndefined(this.timer)) {
      clearTimeout(this.timer);
      this.timer = undefined;
      EventBus.off(Constant.EVENTS.CANCEL_WAITING_DIALOG, this.cancelWaitingDialogCallBackBind)
    }
    EventBus.emit(Constant.EVENTS.CLOSE_WAITING_DIALOG);
    HiLog.info(TAG, 'stopTimerAndCloseDialog execute');
  }
}