/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import { HiLog } from '@ohos/common';

@CustomDialog
export struct UIExtensionDialog {
  private TAG: string = 'UIExtensionDialog';
  controller?: CustomDialogController;
  filePath: string = '';
  cancel: () => void = () => {
  };
  confirm: () => void = () => {
  };
  storage: LocalStorage = LocalStorage.getShared();
  /**
   * 判断是否是深色模式
   */
  @StorageProp('isDarkMode') isDarkMode: boolean = false;

  aboutToAppear() {
    HiLog.info(this.TAG, 'UIExtensionDialog aboutToAppear.');
    this.filePath = this.storage.get<string>('fileInfoPath') as string;
  }

  build() {}
}
