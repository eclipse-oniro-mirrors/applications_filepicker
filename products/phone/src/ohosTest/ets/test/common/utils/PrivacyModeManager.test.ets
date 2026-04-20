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
import { HiLog, PAGE_ROUTE_CONST, PrivacyModeManager } from '@ohos/common';
import { beforeEach, describe, expect, it, MockKit } from '@ohos/hypium';
import { TestUtil } from '../../utils/TestUtil';

export default function PrivacyModeManagerTest() {
  beforeEach(() => {
    PrivacyModeManager.getInstance().setPrivacyMode(false);
  })

  describe('PrivacyModeManagerTest', () => {
    it('setPrivacyModeTrue', 0, () => {
      PrivacyModeManager.getInstance().setPrivacyMode(true);
      const privacyMode: boolean =
        TestUtil.getPrivateAttribute<boolean>(PrivacyModeManager.getInstance(), 'lastPrivacyMode');
      expect(privacyMode).assertEqual(true);
    })

    it('setPrivacyModeTwice', 0, () => {
      PrivacyModeManager.getInstance().setPrivacyMode(true);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.info);
      PrivacyModeManager.getInstance().setPrivacyMode(true);
      mocker.ignoreMock(HiLog, HiLog.info);
      mocker.verify('info', ['PrivacyModeManager', 'no need set privacy mode']).once();
    })

    it('onFrontPageChangeWithUndefined', 0, () => {
      PrivacyModeManager.getInstance().onFrontPageChange(undefined);
      const privacyMode: boolean =
        TestUtil.getPrivateAttribute<boolean>(PrivacyModeManager.getInstance(), 'lastPrivacyMode');
      expect(privacyMode).assertEqual(false);
    })

    it('onFrontPageChangeWithIgnorePage', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.info);
      mocker.ignoreMock(HiLog, HiLog.info);
      mocker.verify('info', ['PrivacyModeManager', 'ignore page, no need set']).once();
    })
  })
}