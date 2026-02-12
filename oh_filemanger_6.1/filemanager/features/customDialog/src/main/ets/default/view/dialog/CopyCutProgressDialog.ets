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

import { DialogButtonDivider, DialogButton, DialogTitle } from './DialogComponent';
import { Constant, EventBus, HiLog, WorkerConst } from '@ohos/common';
import { LineProgress } from './Lineprogress';

const TAG: string = 'CopyCutProgressDialog';

/**
 * 复制移动进度弹框
 */
@Component
@CustomDialog
export struct CopyCutProgressDialog {
  controller?: CustomDialogController;
  cancelWorker: Function = () => {
  };
  hideProgress: Function = () => {
  };
  /**
   * 总大小
   */
  @StorageProp('copyCutTotalSize') totalSize: number = 0;
  /**
   * 完成大小
   */
  @StorageProp('copyCutCompleteSize') @Watch('setProgress') completeSize: number = -1;
  /**
   * 总个数
   */
  @StorageProp('copyCutTotalCount') @Watch('setFileNum') totalCount: number = 0;
  /**
   * 完成个数
   */
  @StorageProp('copyCutCompleteCount') @Watch('setProgress') completeCount: number = -1;
  /**
   * 进度
   */
  @State progress: number = 0;
  /**
   * 文件数量
   */
  filesNum: number = 0;
  /**
   * 取消点击事件
   */
  cancel: Function = () => {
  };
  /**
   * 隐藏点击事件
   */
  confirm?: Function;
  /**
   * 更新内容
   */
  updateContent?: Function;
  /**
   * 弹框内容
   */
  @State content: Resource = $r('app.string.initialization');
  @State contentShow: boolean = true;
  /**
   * 任务类型
   */
  taskType?: WorkerConst.OperateType;
  /**
   * 目标目录
   */
  targetName: string = '';
  /**
   * 弹框标题栏
   */
  title?: Resource;
  closeDialogBind: Function = () => this.closeDialog();
  closeDialog(): void {
    if (this.controller && this.taskType) {
      this.controller.close();
      this.hideProgress(this.taskType);
    }
  }

  /**
   * 判断是否是深色模式
   */
  @StorageProp('isDarkMode') isDarkMode: boolean = false;

  aboutToAppear() {
    HiLog.info(TAG, 'aboutToAppear');
    this.initTitle();
    this.initContent();
    if ((this.totalSize === 0) && (this.totalCount === 0)) {
      this.content = $r('app.string.initialization');
    } else {
      this.setProgress();
    }
    EventBus.on(Constant.EVENTS.CLOSE_INFO_DISPLAY_DIALOGS, this.closeDialogBind);
  }

  aboutToDisappear(): void {
    HiLog.info(TAG, 'aboutToDisappear');
    EventBus.off(Constant.EVENTS.CLOSE_INFO_DISPLAY_DIALOGS, this.closeDialogBind);
  }

  initTitle(): void {
    switch (this.taskType) {
      case WorkerConst.OperateType.COPY_FILE:
        this.title = $r('app.string.copy_file');
        break;
      case WorkerConst.OperateType.CUT_FILE:
        this.title = $r('app.string.move_file');
        break;
      case WorkerConst.OperateType.DRAG_FILE:
        this.title = $r('app.string.drag_file');
        break;
      case WorkerConst.OperateType.DELETE_FILE:
        this.title = $r('app.string.delete_file');
        break;
      default:
        break;
    }
  }

  initContent(): void {
    switch (this.taskType) {
      case WorkerConst.OperateType.COPY_FILE:
        this.content = $r('app.plural.copy_dialog_title_other', this.filesNum, this.filesNum, this.targetName);
        break;
      case WorkerConst.OperateType.CUT_FILE:
        this.content = $r('app.plural.move_dialog_title_other', this.filesNum, this.filesNum, this.targetName);
        break;
      case WorkerConst.OperateType.DRAG_FILE:
        this.content = $r('app.plural.drag_dialog_title', this.filesNum, this.filesNum, this.targetName);
        break;
      case WorkerConst.OperateType.DELETE_FILE:
        this.content = $r('app.plural.delete_dialog_title', this.totalCount, this.totalCount);
        break;
      default:
        break;
    }
  }

  setFileNum(): void {
    if (this.totalCount !== 0) {
      this.filesNum = this.totalCount;
    }
  }

  setProgress(): void {
    this.setFileNum();
    if (this.totalSize !== 0) {
      let percent: number = Math.floor(this.completeSize / this.totalSize * 100);
      this.progress = percent > 100 ? 100 : percent;
      this.progress = percent < 0 ? 0 : this.progress;
      this.initContent();
      return;
    }
    if (this.totalCount !== 0) {
      let percent: number = Math.floor(this.completeCount / this.totalCount * 100)
      this.progress = percent > 100 ? 100 : percent;
      this.progress = percent < 0 ? 0 : this.progress;
      this.initContent();
    } else {
      this.progress = 0;
    }
  }

  build() {
    Column() {
      DialogTitle({
        title: this.title
      })
      LineProgress({
        progress: this.progress,
        content: this.content,
        contentShow: this.contentShow
      })
        .margin({ bottom: $r('app.float.common_margin8') })
      this.bottomButton();
    }
    .padding(
      {
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8'),
        bottom: $r('sys.float.padding_level8')
      }
    )
  }

  @Builder
  bottomButton() {
    Row() {
      DialogButton({
        text: $r('app.string.cancel'),
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        isDisabled: false,
        click: () => {
          this.controller?.close();
          this.cancelWorker();
        }
      })
      DialogButtonDivider();
      DialogButton({
        text: $r('app.string.hide'),
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        isDisabled: false,
        click: () => {
          HiLog.info(TAG, 'Click to hide CopyCutProgressDialog');
          // 关闭弹窗
          this.hideProgress(this.taskType);
        }
      })
    }
  }
}