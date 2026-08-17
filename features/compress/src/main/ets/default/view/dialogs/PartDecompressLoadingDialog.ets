/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
import { CompressDialog } from '../CompressDialogs';
import { Constant, EventBus, HiLog } from '@ohos/common';
import lazy { LoadingDialog } from '@ohos/common/indexLazyLoad';
import lazy { compress } from '@ohos/common/src/main/ets/workermanager/filecompressmanager/FileCompressSdk';

export class PartDecompressDialogOptions {
  public taskName: string = '';
  public onCancel = () => {};
}

// 局部解压缩加载过程的加载弹窗
@Component
export struct PartDecompressLoadingDialog {
  private tag: string = 'PartDecompressLoadingDialog';
  @StorageProp(CompressDialog.PART_DECOMPRESS_LOADING_KEY) @Watch('onPartDecompressDialogChange')
    options?: PartDecompressDialogOptions = undefined;
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

  onPartDecompressDialogChange() {
    HiLog.info(this.tag, 'onPartDecompressDialogChange');
    if (!this.options || this.options.taskName.length === 0) {
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
        HiLog.warn(this.tag, `onWillDismiss, reason: ${action.reason}, taskName: ${this.options?.taskName}`);
        try {
          compress.cancel(this.options?.taskName ?? '');
        } catch (e) {
          HiLog.error(this.tag, `compress cancel failed, errCode: ${e?.code}, errMsg: ${e?.message}`);
        }
        this.options?.onCancel();
        action.dismiss();
      },
    })
    this.controller.open();
  }
}