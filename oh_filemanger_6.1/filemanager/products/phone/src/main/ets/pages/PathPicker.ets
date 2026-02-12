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

/*
 * 用户选择文件保存路径
 * 路径选择界面：半模态选择界面
 * 文件保存位置选择
 */
import {
  AbilityCommonUtil,
  AccountManager,
  StorageDeviceManager,
  SYSTEM_BAR_COLOR,
  Constant,
  DeviceTypeConstants,
  FilePickerUtil,
  GlobalKey,
  LanguageUtil,
  StartModeOptions,
  EventBus,
  HiLog,
} from '@ohos/common';
import { PathSelectTree } from './component/pathselect/PathSelectTree';
import { UiUtil } from '@ohos/common/src/main/ets/utils/UiUtil';

const TAG = 'PathPicker';

@Entry
@Component
struct PathPicker {
  @Provide('isSetDialogWidth') isSetDialogWidth: boolean = false;
  private startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();
  @State pathPickerSwitch: boolean = this.startModeOptions.isUxt();
  private cancelTimeOut?: number;

  aboutToAppear() {
    StorageDeviceManager.getInstance().subscribeStorageDeviceChangeEvent(DeviceTypeConstants.PHONE);
    // 更新系统语言
    LanguageUtil.updateSystemLanguage();
    // 订阅账号状态变化公共事件
    AccountManager.getInstance().subscribeAccountChangeEvent();
    // 监听半模态关闭事件
    EventBus.on(Constant.EVENTS.CLOSE_UI_PATH_PICKER + this.startModeOptions.currentCreateTimeStamp,
      () => this.pathPickerSwitch = false, true);
  }

  onPageShow() {
    UiUtil.setWindowBackground(SYSTEM_BAR_COLOR.PATH_PICK, GlobalKey.WINDOW_PATH_PICKER_CLASS);
  }

  build() {
    Column() {
      this.pickerContent();
    }
  }

  onBackPress(): boolean {
    AbilityCommonUtil.terminatePathPicker([], AbilityCommonUtil.ResultCodePicker.CANCEL, this.startModeOptions);
    return true;
  }

  aboutToDisappear(): void {
    EventBus.off(Constant.EVENTS.CLOSE_UI_PATH_PICKER + this.startModeOptions.currentCreateTimeStamp);
    if (this.cancelTimeOut) {
      clearTimeout(this.cancelTimeOut);
      this.cancelTimeOut = undefined;
    }
  }

  @Builder
  pickerContent() {
    Column() {
    }
    .bindSheet($$this.pathPickerSwitch, this.mainContent(), {
      height: SheetSize.LARGE,
      dragBar: false,
      showClose: false,
      preferType: SheetType.CENTER,
      onAppear: () => {
        HiLog.info(TAG, 'PathPicker onAppear');
      },
      shouldDismiss: (sheetDismiss: SheetDismiss) => {
        sheetDismiss.dismiss();
      },
      onWillSpringBackWhenDismiss: ((springBackAction: SpringBackAction) => {
        //没有注册springBack, 下拉半模态页面无回弹行为
      }),
      onWillDisappear: () => {
        HiLog.info(TAG, 'PathPicker onWillDisappear');
        this.cancelTimeOut = setTimeout(() => {
          // 返回取消操作给文件子系统
          AbilityCommonUtil.terminatePathPicker([], AbilityCommonUtil.ResultCodePicker.CANCEL, this.startModeOptions);
          HiLog.warn(TAG, 'resolvePathSelectEnd, folderUri is empty');
          clearTimeout(this.cancelTimeOut);
        }, 200);
      }
    })
  }

  @Builder
  mainContent() {
    Column() {
      PathSelectTree({
        operationType: Constant.OPERATION_TYPE.SAVE,
        startModeOptions: this.startModeOptions
      })
    }
  }
}
