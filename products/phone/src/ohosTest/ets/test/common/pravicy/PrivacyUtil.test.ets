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
import { GlobalHolder, HiLog, PrivacyUtil } from "@ohos/common";
import { describe, it, MockKit } from "@ohos/hypium";

export default function PrivacyUtilTest() {
  describe('PrivacyUtilTest', () => {
    it('syncSignStateToHmFiles_common', 0, async () => {
      const context: Context = GlobalHolder.getInstance().getUIExtensionContext();
      const mocker = new MockKit();
      let mockerFunc = mocker.mockFunc(HiLog, HiLog.info);
      await PrivacyUtil.syncSignStateToHmFiles(context);
      mocker.verify('info', ['PrivacyUtil', `begin sync signState to HmFiles.`]).once();
      mocker.ignoreMock(HiLog, HiLog.info);
    })
  })
}