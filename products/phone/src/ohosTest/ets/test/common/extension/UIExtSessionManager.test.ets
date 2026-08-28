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
import { HiLog } from '@ohos/common';
import {
  CopyCutCompleteData,
  CopyCutProgressData,
  JumpPageData
} from '../../../../../main/ets/base/extension/model/SendDataModel';
import { UIExtSessionManager } from '../../../../../main/ets/base/extension/UIExtSessionManager';
import { describe, expect, it } from '@ohos/hypium';

const uIExtSessionManager = UIExtSessionManager.getInstance();
const TAG = 'UIExtSessionManagerTest';

export default function UIExtSessionManagerTest() {
  describe('UIExtSessionManagerTest', () => {

    it('setSessionBeforeAfter', 0, (done: Function) => {
      expect(uIExtSessionManager.isLoadFromUIExtension()).assertFalse();

      let jumpPageData: JumpPageData = {
        pageName: ''
      };
      uIExtSessionManager.jumpPage(jumpPageData);

      let copyCutProgressData: CopyCutProgressData = {
        folderUri: '',
        progress: 0,
        deliveryTime: 0,
        operatingFileName: ''
      };
      uIExtSessionManager.publishCopyCutProgressNotification(copyCutProgressData);

      let copyCutCompleteData: CopyCutCompleteData = {
        folderUri: '',
        title: '',
        text: '',
        isCancel: false
      };

      uIExtSessionManager.publishCopyCutCompleteNotification(copyCutCompleteData);
      uIExtSessionManager.cancelCopyCutProgressNotification();
      uIExtSessionManager.cancelCopyCutCompleteNotification();
      uIExtSessionManager.sendHasOnOpenFolderEvent();
      done();
    });
  });
}