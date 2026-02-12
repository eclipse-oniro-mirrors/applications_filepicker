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
import lazy { fileShare } from '../../../../indexLazyLoadTs';
import { HiLog } from '../dfx/HiLog';

const TAG = 'PersistPermissionCheck';

// @ts-ignore
export type PathPolicyInfo = fileShare.PathPolicyInfo;

export class PersistPermissionCheck {
  public static async checkPathPermission(tokenID: number, policies: PathPolicyInfo[]): Promise<boolean[]> {
    let results: boolean[] = [];
    try {
      // @ts-ignore
      results = await fileShare.checkPathPermission(tokenID, policies, fileShare.PolicyType.PERSISTENT_TYPE);
    } catch (e) {
      HiLog.error(TAG, `checkPathPermission error: ${JSON.stringify(e)}`);
    }
    return results;
  }
}