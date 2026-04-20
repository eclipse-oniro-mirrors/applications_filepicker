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

import { Constant, EventBus } from '@ohos/common';
import { DialogButton, DialogTitle } from './DialogComponent';
import { LineProgress } from './Lineprogress';

@Component
@CustomDialog
export struct DeleteRestoreProgressDialog {
  controller?: CustomDialogController;
  /**
   * 总个数
   */
  @StorageLink('deleteRestoreTotalFileCount') totalCount: number = 0;

  /**
   * 完成个数
   */
  @State completeCount: number = 0;

  /**
   * 进度
   */
  @State progress: number = 0;

  /**
   * 取消点击事件
   */
  cancel: Function = () => {};

  /**
   * 弹框标题栏
   */
  @State title?: Resource = undefined;

  /**
   * 弹框内容
   */
  @State content?: Resource = undefined;

  /**
   * 判断是否是深色模式
   */
  @StorageProp('isDarkMode') isDarkMode: boolean = false;

  operationType: string = ''

  updateCompleteCountBind: Function = (count: number): void => this.updateCompleteCount(count);

  aboutToAppear() {
    this.setDialogContent();
    this.updateProgress();
    EventBus.on(Constant.EVENTS.UPDATE_DELETED_RESTORED_FILE_COUNT, this.updateCompleteCountBind);
  }

  aboutToDisappear() {
    EventBus.off(Constant.EVENTS.UPDATE_DELETED_RESTORED_FILE_COUNT, this.updateCompleteCountBind);
  }

  updateCompleteCount(count: number): void {
    this.completeCount = count;
    this.updateProgress();
  }

  setDialogTitle(): void {
    if (this.operationType === Constant.OPERATION_TYPE.RESTORE) {
      this.title = $r('app.string.restore_file')
    } else {
      this.title = $r('app.string.delete_file')
    }
  }

  setDialogContent(): void {
    if (this.operationType === Constant.OPERATION_TYPE.RESTORE) {
      this.content = $r('app.plural.restore_dialog_title', this.totalCount, this.totalCount)
    } else {
      this.content = $r('app.plural.delete_dialog_title', this.totalCount, this.totalCount)
    }
  }

  updateProgress() {
    if (!this.totalCount) {
      this.progress = 0;
    } else {
      this.setDialogTitle();
      this.progress = Math.floor(this.completeCount / this.totalCount * 100);
    }
    AppStorage.setOrCreate<number>('deleteRestoreProgressCount', this.progress);
  }

  build() {
      Column() {
        DialogTitle({
          title: this.title
        })
        LineProgress({
          progress: this.progress,
          content: this.content
        })
        this.bottomButton();
      }
      .margin({
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8'),
      })
  }

  @Builder
  bottomButton() {
    Row() {
      DialogButton({
        text: $r('app.string.cancel'),
        bgColor: $r('sys.color.ohos_id_color_button_normal'),
        isDisabled: false,
        click: () => {
          this.cancel();
          this.controller?.close();
        }
      })
    }
    .margin({ bottom: 8 })
    .constraintSize({
      minHeight: 56
    })
  }
}
