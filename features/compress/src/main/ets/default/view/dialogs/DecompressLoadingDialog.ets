/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { CompressDialog } from '../CompressDialogs';
import { Constant, EventBus, HiLog } from '@ohos/common';
import taskpool from '@ohos.taskpool';
import lazy { LoadingDialog } from '@ohos/common/indexLazyLoad';

// 解压前判断是否加密等待过程的加载弹窗
@Component
export struct DecompressLoadingDialog {
  private tag: string = 'DecompressLoadingDialog';
  @StorageProp(CompressDialog.DECOMPRESS_LOADING_KEY) @Watch('onTaskIdChange') taskId: number = 0;
  private controller?: CustomDialogController;
  private closeDialogBind: () => void = () => this.closeDialog();

  aboutToAppear(): void {
    EventBus.on(Constant.EVENTS.CLOSE_INFO_DISPLAY_DIALOGS, this.closeDialogBind);
  }

  aboutToDisappear(): void {
    EventBus.off(Constant.EVENTS.CLOSE_INFO_DISPLAY_DIALOGS, this.closeDialogBind);
  }

  closeDialog(): void {
    if (this.controller) {
      this.controller.close();
      this.controller = undefined;
    }
  }

  build() {
  }

  onTaskIdChange() {
    HiLog.info(this.tag, `onLoadingDialogChange, ${JSON.stringify(this.taskId)}`);
    if (this.taskId === 0) {
      this.controller?.close();
      this.controller = undefined;
      return;
    }
    this.controller = new CustomDialogController({
      builder: LoadingDialog({ content: $r('app.string.processing') }),
      alignment: DialogAlignment.Center,
      backgroundBlurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
      autoCancel: false,
      onWillDismiss: (action: DismissDialogAction) => {
        HiLog.info(this.tag, `onWillDismiss, reason: ${action.reason}, taskId: ${this.taskId}`);
        try {
          taskpool.cancel(this.taskId);
        } catch (e) {
          HiLog.error(this.tag, `taskpool cancel failed, errCode: ${e?.code}, errMsg: ${e?.message}`);
        }
        action.dismiss();
      },
    })
    this.controller.open();
  }
}