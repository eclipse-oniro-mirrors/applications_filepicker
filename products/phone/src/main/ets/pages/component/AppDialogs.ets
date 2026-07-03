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
import { ToolOperateAreDialog } from '@ohos/customDialog';
import { CopyCutManager } from '../../base/manager/CopyCutManager';
import { DiskInfo, WorkerConst, CopyCutConst } from '@ohos/common';
import { CommonDialogs, CopyCutDialogs, DeleteRestoreDialogs } from '@ohos/customDialog/indexPhoneOnly';

const TAG: string = 'AppDialogs';

/**
 * 所有需要在应用任意界面弹起的弹框组成的组件
 */
@Component
export struct AppDialogs {
  cancelWorker: Function = (): void => CopyCutManager.getInstance()?.cancelWorker();
  usbSdChange: Function = (diskInfo: DiskInfo[]): void => CopyCutManager.getInstance().usbSdChange(diskInfo);
  getTaskIsRun: Function = (): boolean => {
    return CopyCutManager.getInstance().taskIsRun
  };
  hideProgress: Function =
    (taskType?: WorkerConst.OperateType): void => CopyCutManager.getInstance().hideProgress(taskType);
  sendConflictChooseResult: Function = (isApplyAll: boolean, chooseResult: CopyCutConst.ChooseType):
    void => CopyCutManager.getInstance().sendConflictChooseResult(isApplyAll, chooseResult);
  stopTask: Function = (): void => CopyCutManager.getInstance().stopTask();
  storageRemove: Function = (uuid: string): void => CopyCutManager.getInstance().forcedRemoval(uuid);
  continueToRunWorker: Function = () => CopyCutManager.getInstance().continueToRunWorker();
  isJumpFromSettings: boolean = false;

  build() {
    Column() {
      // 删除还原弹窗组件
      DeleteRestoreDialogs()
      if (!this.isJumpFromSettings) {
        // 复制移动弹框组件
        CopyCutDialogs({
          cancelWorker: this.cancelWorker,
          usbSdChange: this.usbSdChange,
          getTaskIsRun: this.getTaskIsRun,
          hideProgress: this.hideProgress,
          sendConflictChooseResult: this.sendConflictChooseResult,
          stopTask: this.stopTask,
          storageRemove: this.storageRemove,
          continueToRunWorker: this.continueToRunWorker
        })
        // 公共弹窗组件
        CommonDialogs()
        ToolOperateAreDialog()
      }
    }.width(0)
    .height(0)
  }
}