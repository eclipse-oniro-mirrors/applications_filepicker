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
  AbilityCommonUtil,
  Constant,
  DFX,
  EventBus,
  HiLog,
  toast,
  UEUtil,
  ObjectUtil
} from '@ohos/common';
import { ConfirmTemplateDialog } from './dialog/ConfirmTemplateDialog';
import { WaitingDialog } from './dialog/WaitingDialog';

const TAG = 'CommonDialogs';

/**
 * 复制移动弹框
 */
@Component
export struct CommonDialogs {
  /**
   * 数据处理弹窗
   */
  waitingDialogController: CustomDialogController | undefined = undefined;
  private showWaitingDialogBind: Function = (): void => this.showWaitingDialog();
  private closeWaitingDialogBind: Function = (): void => this.closeWaitingDialog();
  /**
   * 内存不足500M弹框
   */
  insufficientDiskSpaceDialog: CustomDialogController | undefined = undefined;
  private showInsufficientDialogBind: Function =
    (reasonType: DFX.ReasonType): void => this.showInsufficientDialog(reasonType);
  private reasonType: DFX.ReasonType = DFX.ReasonType.ERR_CODE;

  aboutToAppear() {
    EventBus.on(Constant.EVENTS.SHOW_WAITING_DIALOG, this.showWaitingDialogBind);
    EventBus.on(Constant.EVENTS.CLOSE_WAITING_DIALOG, this.closeWaitingDialogBind);
    EventBus.on(Constant.EVENTS.SHOW_INSUFFICIENT_DISK_SPACE_DIALOG, this.showInsufficientDialogBind);
  }

  aboutToDisappear() {
    EventBus.off(Constant.EVENTS.SHOW_WAITING_DIALOG, this.showWaitingDialogBind);
    EventBus.off(Constant.EVENTS.CLOSE_WAITING_DIALOG, this.closeWaitingDialogBind);
    EventBus.off(Constant.EVENTS.SHOW_INSUFFICIENT_DISK_SPACE_DIALOG, this.showInsufficientDialogBind);
  }

  showWaitingDialog() {
    if (ObjectUtil.isNullOrUndefined(this.waitingDialogController)) {
      this.waitingDialogController = new CustomDialogController({
        builder: WaitingDialog(),
        cancel: () => {
          EventBus.emit(Constant.EVENTS.CANCEL_WAITING_DIALOG);
        },
        autoCancel: false
      })
    }
    this.waitingDialogController?.open();
  }

  closeWaitingDialog() {
    if (ObjectUtil.isNullOrUndefined(this.waitingDialogController)) {
      return;
    }
    this.waitingDialogController?.close();
  }

  showInsufficientDialog(reasonType: DFX.ReasonType) {
    HiLog.warn(TAG, `show insufficient disk space dialog because of ${reasonType}`);
    this.reasonType = reasonType;
    if (this.insufficientDiskSpaceDialog) {
      this.insufficientDiskSpaceDialog.open();
      return;
    }
    this.insufficientDiskSpaceDialog = new CustomDialogController({
      builder: ConfirmTemplateDialog({
        title: $r('app.string.space_not_enough_title'),
        content: $r('app.string.low_memory_notice'),
        firstButtonText: $r('app.string.cancel'),
        firstButtonCallback: () => {
          HiLog.info(TAG, `cancel `);
          UEUtil.reportShowLowMemoryDialog(this.reasonType, true);
        },
        secondButtonText: $r('app.string.go_now'),
        secondButtonCallback: () => {
          HiLog.info(TAG, `go to clear `);
          AbilityCommonUtil.startSettingsAbility();
          UEUtil.reportShowLowMemoryDialog(this.reasonType, false);
        }
      }),
      alignment: DialogAlignment.Center,
    });
    this.insufficientDiskSpaceDialog.open();
  }

  build() {
    Column() {
    }.width(0)
    .height(0)
  }
}