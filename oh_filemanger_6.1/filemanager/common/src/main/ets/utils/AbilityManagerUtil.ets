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
import ctx from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import { AbilityName } from '../const/HiSysEventConst';
import { HiLog } from '../dfx/HiLog';
import { HiSysEventUtil } from '../dfx/HiSysEventUtil';
import { StorageDeviceManager } from '../externel/StorageDeviceManager';
import { ObjectUtil } from './ObjectUtil';


const TAG: string = 'AbilityManagerUtil';

export class AbilityManagerUtil {
  private static abilityManagerUtil: AbilityManagerUtil;
  private allAbilityCount: number = 0;

  public static getInstance(): AbilityManagerUtil {
    if (!AbilityManagerUtil.abilityManagerUtil) {
      AbilityManagerUtil.abilityManagerUtil = new AbilityManagerUtil();
    }
    return AbilityManagerUtil.abilityManagerUtil;
  }

  public async addAbility(abilityName: AbilityName, callSource?: string,
    context?: ctx.UIAbilityContext): Promise<boolean> {
    let abilityNum = AppStorage.get<number>(abilityName);
    this.allAbilityCount++;
    let currentAbilityNum = abilityNum ? abilityNum + 1 : 1;
    HiLog.info(TAG, `${abilityName} addAbility:${currentAbilityNum}, allAbilityCount: ${this.allAbilityCount}`);
    AppStorage.setOrCreate<number>(abilityName, currentAbilityNum);
    let isAddAbilitySuccess: boolean = true;
    if ((!ObjectUtil.isNullOrUndefined(context)) && (currentAbilityNum > 50)) {
      HiLog.warn(TAG, 'currentAbilityNum is more than 50, need to terminateSelf');
      await context?.terminateSelf()
        .then(() => {
          HiLog.warn(TAG, 'terminateSelf success');
        })
        .catch((err: BusinessError) => {
          HiLog.error(TAG, 'terminateSelf failed, err:' + err);
        });
      isAddAbilitySuccess = false;
    }
    HiSysEventUtil.reportCreateAbility(abilityName, currentAbilityNum, callSource);
    return isAddAbilitySuccess;
  }

  public reduceAbility(abilityName: string): void {
    let abilityNum = AppStorage.get<number>(abilityName);
    let currentAbilityNum = abilityNum ? abilityNum - 1 : 0;
    this.allAbilityCount--;
    if (this.allAbilityCount === 0) {
      StorageDeviceManager.getInstance().unsubscribeStorageDeviceChangeEvent();
      HiLog.info(TAG, `allAbilityCount === 0,unsubscribeStorageDeviceChangeEvent`);
    }
    HiLog.info(TAG, `${abilityName} reduceAbility: ${currentAbilityNum}, allAbilityCount: ${this.allAbilityCount}`);
    AppStorage.setOrCreate<number>(abilityName, currentAbilityNum);
  }
}