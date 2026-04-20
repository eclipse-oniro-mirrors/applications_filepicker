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

import { SafeRandom } from '@hms-security/agoh-crypto';
import { HiLog } from '../dfx/HiLog';

const TAG = 'SecureRandomUtil';

/**
 * 生成安全随机数的工具类
 */
export class SafeRandomUtil {
  /**
   * 随机生成16位长度的字符串
   */
  public static readonly RANDOM_FILE_NAME_LEN_32: number = 16;

  /**
   * 获取安全随机数（字节数组）
   * @param length 安全随机数的长度
   * @returns 安全随机数的字节数组
   */
  public static getSecureRandomBytes(length: number): Uint8Array {
    let random: Uint8Array = undefined;
    try {
      random = SafeRandom.ohAegRandom(length);
    } catch (error) {
      HiLog.error(TAG, 'getSecureRandomBytes fail:' + JSON.stringify(error));
      throw error;
    }
    return random;
  }

  /**
   * 获取安全随机数（16进制字符串）
   * @param length 安全随机数的长度
   * @returns 16进制的安全随机数字符串
   */
  public static getSecureRandomString(length: number): string {
    let random = '';
    try {
      random = SafeRandom.ohAegRandomHex(length);
    } catch (error) {
      HiLog.error(TAG, 'getSecureRandom fail:' + JSON.stringify(error));
      throw error;
    }
    return random;
  }

  /**
   * 随机生成32为字符串
   */
  public static getRandomFileName(): string {
    return this.getSecureRandomString(this.RANDOM_FILE_NAME_LEN_32);
  }
}