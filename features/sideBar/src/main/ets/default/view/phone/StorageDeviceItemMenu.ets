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

import { Constant, DFX, EventBus, HiLog, UEUtil } from '@ohos/common';

const TAG: string = 'StorageDeviceItemMenu';

@Component
export struct StorageDeviceItemMenu {
  private uuid: string = '';

  build() {
    Menu() {
      MenuItem({content: $r('app.string.securely_remove')})
        .borderRadius($r('app.float.common_borderRadius16'))
        .onClick(async () => {
          if (this.uuid === '') {
            HiLog.warn(TAG, 'uuid is null');
            return;
          }
          HiLog.info(TAG, 'emit storage device unmount');
          EventBus.emit(Constant.EVENTS.STORAGE_DEVICE_UNMOUNT, this.uuid);
          UEUtil.reportExternalOper(DFX.ExternalOperType.PRESS_REMOVE);
        })
    }
    .width($r('app.float.common_size224'))
  }
}
