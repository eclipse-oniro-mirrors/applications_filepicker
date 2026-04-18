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
import { BasePreference, GlobalHolder,
  HiLog, PreferenceConst, PreferenceFactory,
} from '@ohos/common';
import { ArgumentMatchers, beforeAll, describe, expect, it, MockKit, when} from '@ohos/hypium';
import { common } from '@kit.AbilityKit';
import { abilityDelegatorRegistry } from '@kit.TestKit';

const TAG = 'PreferenceFactory';

export default function PreferenceFactoryTest() {
  describe('PreferenceFactoryTest', () => {

    beforeAll(() => {
      try {
        let abilityDelegator: abilityDelegatorRegistry.AbilityDelegator;

        abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

        let context = abilityDelegator.getAppContext() as common.AbilityStageContext;
        GlobalHolder.getInstance().abilityStageContext = context;
      } catch (error) {
        HiLog.error(TAG, 'get context error');
      }
    })

    it('deletePreference_fileName_null', 0, async () => {
      let mode: string = PreferenceConst.FILE.USAGE_HABITS;
      let preference: BasePreference = PreferenceFactory.getPreference(mode);
      preference.fileName = '';
      let res = PreferenceFactory.deletePreference(preference);
      expect(res).assertPromiseIsResolved();
    });

    it('deletePreference_fileName_equal_0', 0, async () => {
      let mode: string = PreferenceConst.FILE.USAGE_HABITS;
      let preference: BasePreference = PreferenceFactory.getPreference(mode);
      preference.fileName = PreferenceConst.FILE.COMMON;
      let res = PreferenceFactory.deletePreference(preference);
      expect(res).assertPromiseIsPending();
    });

    it('deletePreference_fileName_equal_-1', 0, async () => {
      let mode: string = PreferenceConst.FILE.USAGE_HABITS;
      let preference: BasePreference = PreferenceFactory.getPreference(mode);
      preference.fileName = 'HHHH';
      let res = PreferenceFactory.deletePreference(preference);
      expect(res).assertPromiseIsPending();
    });

    it('deletePreferenceCache_fileName_null', 0, async () => {
      let mode: string = PreferenceConst.FILE.USAGE_HABITS;
      let preference: BasePreference = PreferenceFactory.getPreference(mode);
      preference.fileName = '';
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.error);
      PreferenceFactory.deletePreferenceCache(preference);
      mocker.clear(HiLog);
      mocker.verify('error',
        [TAG, 'deletePreferenceCache fail, cause basePreference or basePreference.fileName is undefined']).once();
    });

    it('deletePreferenceCache_fileName_equal_0', 0, async () => {
      let mode: string = PreferenceConst.FILE.USAGE_HABITS;
      let preference: BasePreference = PreferenceFactory.getPreference(mode);
      preference.fileName = PreferenceConst.FILE.COMMON;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.info);
      PreferenceFactory.deletePreferenceCache(preference);
      mocker.clear(HiLog);
      mocker.verify('info', [TAG, 'deletePreferenceCache success']).once();
    });

    it('deletePreferenceCache_fileName_equal_-1', 0, async () => {
      let mode: string = PreferenceConst.FILE.USAGE_HABITS;
      let preference: BasePreference = PreferenceFactory.getPreference(mode);
      preference.fileName = 'HHHH';
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.info);
      PreferenceFactory.deletePreferenceCache(preference);
      mocker.clear(HiLog);
      mocker.verify('info', [TAG, 'deletePreferenceCache success']).once();
    });
  })
}