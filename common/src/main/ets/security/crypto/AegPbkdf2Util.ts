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

import { PbkdfUtil } from '@hms-security/agoh-crypto';
import { HiLog } from '../../dfx/HiLog';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { StringUtil } from '../../utils/StringUtil';

const TAG = 'AegPbkdf2Util';

/**
 * 口令保存PBKDF2工具类
 */
export class AegPbkdf2Util {
  /**
   * PBKDF2加盐迭代次数，最少10000次，推荐使用
   */
  public static readonly PBKDF2_ITERATION_10000: number = 10000;

  /**
   * PBKDF2加盐迭代次数，目前只是为了兼容双框，请勿随意使用
   */
  public static readonly PBKDF2_ITERATION_5000: number = 5000;

  /**
   * PBKDF2加盐迭代次数，目前只是为了兼容双框，请勿随意使用
   */
  public static readonly PBKDF2_ITERATION_1000: number = 1000;

  /**
   * 对口令使用PBKDF2 sha256处理
   * @param input 口令
   * @param salt 盐值
   * @return 经过多次hash计算后的sha256字符串
   */
  public static async pbkdf2Sha256(input: string, salt: string, iteration: number = this.PBKDF2_ITERATION_10000): Promise<string> {
    let result = '';
    try {
      result = await PbkdfUtil.ohAegPbkdf2Sha256(input, salt, iteration);
    } catch (error) {
      HiLog.error(TAG, 'pbkdf2Sha256 fail, error:' + JSON.stringify(error) + error);
    }
    return result;
  }

  /**
   * 对口令使用PBKDF2 SHA1处理,同双框架
   * @param input 口令
   * @param salt 盐值
   * @return 经过多次hash计算后的sha256字符串
   */
  public static async pbkdf2Sha1(input: string, salt: string, iteration: number = this.PBKDF2_ITERATION_10000): Promise<string> {
    let result = '';
    try {
      let kdf = cryptoFramework.createKdf('PBKDF2|SHA1');
      let spec: cryptoFramework.PBKDF2Spec = {
        algName: 'PBKDF2',
        password: input,
        salt: StringUtil.hexStringToUint8Array(salt),
        iterations: iteration,
        keySize: 24
      };
      const tempRes = await kdf.generateSecret(spec);
      result = StringUtil.uint8ArrayToHexString(tempRes.data);
    } catch (error) {
      HiLog.error(TAG, 'pbkdf2Sha251 fail, error:' + JSON.stringify(error) + error);
    }
    return result;
  }
}
