/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import { HiLog } from '../dfx/HiLog';
import { osAccount } from '@kit.BasicServicesKit';
import { ResourceUtil } from './ResourceUtil';

const TAG = 'AccountUtil';

/**
 * 账号工具类
 */
export class AccountUtil {
  private static accountLocalId: number = 0;
  private static accountName: string = '';

  public static async getAccountLocalId(): Promise<number> {
    if (this.accountLocalId === 0) {
      HiLog.info(TAG, 'init accountLocalId');
      this.accountLocalId = await osAccount.getAccountManager().getOsAccountLocalId();
    }
    HiLog.info(TAG, 'getAccountLocalId, id: ' + this.accountLocalId);
    return this.accountLocalId;
  }

  public static getAccountName(): string {
    if (this.accountName === '') {
      this.setAccountName();
    }
    return this.accountName;
  }

  public static async setAccountName(): Promise<void> {
    try {
      let defaultAccountName: string = ResourceUtil.getStringByResource($r('app.string.my_pc'));
      this.accountName = await osAccount.getAccountManager().getOsAccountName() || defaultAccountName;
    } catch (error) {
      this.accountName = ResourceUtil.getStringByResource($r('app.string.my_pc'));
      HiLog.errorPrivate(TAG, `getAccountName error:`, JSON.stringify(error));
    }
    return;
  }
}
