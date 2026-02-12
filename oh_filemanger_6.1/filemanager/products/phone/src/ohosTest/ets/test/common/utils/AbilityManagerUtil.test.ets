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
import { describe, expect, it, MockKit, when } from '@ohos/hypium';
import { AbilityManagerUtil, AbilityName, HiLog } from '@ohos/common';
import ctx from '@ohos.app.ability.common';

export default function AbilityManagerUtilTest() {
  describe('AbilityManagerUtilTest', () => {
    const TAG: string = 'AbilityManagerUtil';

    it('abilityManagerUtil_success', 0, async (done: Function) => {
      let abilityManagerUtil = AbilityManagerUtil.getInstance();
      let result: boolean = await abilityManagerUtil.addAbility(AbilityName.FILE_PICKER_ABILITY);
      expect(result).assertTrue();
      done();
    })

    it('abilityManagerUtil_fail', 0, async (done: Function) => {
      let abilityManagerUtil = AbilityManagerUtil.getInstance();
      const myContext: ctx.UIAbilityContext = {
        terminateSelf: () => {
          return new Promise<void>(resolve => {resolve();});
        }
      } as ctx.UIAbilityContext;
      const abilityName: AbilityName = AbilityName.FILE_PICKER_ABILITY;
      const mocker: MockKit = new MockKit();
      let mockFunction = mocker.mockFunc(AppStorage, AppStorage.get);
      when(mockFunction)(abilityName).afterReturn(50);
      let result: boolean = await abilityManagerUtil.addAbility(abilityName, '', myContext)
      mocker.clear(AppStorage);
      expect(result).assertFalse();
      done();
    })

    it('reduceAbility_allAbilityCount_0', 0, () => {
      let abilityManagerUtil = AbilityManagerUtil.getInstance();
      const abilityName: AbilityName = AbilityName.FILE_PICKER_ABILITY;
      const mocker: MockKit = new MockKit();
      let mockFunction = mocker.mockFunc(AppStorage, AppStorage.get);
      when(mockFunction)(abilityName).afterReturn(undefined);
      mocker.mockFunc(HiLog, HiLog.info);
      abilityManagerUtil.reduceAbility(abilityName);
      mocker.clear(HiLog);
      mocker.clear(AppStorage);
      mocker.verify('info', [TAG, `allAbilityCount === 0,unsubscribeStorageDeviceChangeEvent`]);
    })

    it('reduceAbility_allAbilityCount_not_0', 0, () => {
      let abilityManagerUtil = AbilityManagerUtil.getInstance();
      const abilityName: AbilityName = AbilityName.FILE_PICKER_ABILITY;
      const mocker: MockKit = new MockKit();
      let mockFunction = mocker.mockFunc(AppStorage, AppStorage.get);
      when(mockFunction)(abilityName).afterReturn(10);
      mocker.mockFunc(HiLog, HiLog.info);
      mocker.mockFunc(AppStorage, AppStorage.set);
      abilityManagerUtil.reduceAbility(abilityName);
      mocker.clear(HiLog);
      mocker.clear(AppStorage);
      mocker.verify('info', [TAG, `${abilityName} reduceAbility: 10, allAbilityCount: 9`]);
    })

  })
}
