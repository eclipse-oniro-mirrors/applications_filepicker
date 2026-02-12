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

import { StringUtil } from '../../utils/StringUtil';
import { ArrayUtil } from '../../utils/ArrayUtil';

const TAG = 'CryptoCommonUtil';

/**
 * 加解密相关的公共方法和常量
 */
export class CryptoCommonUtil {
  /**
   * 密钥长度
   */
  public static readonly KEY_BYTE_LEN_256 = 32;

  /**
   * 密钥长度
   */
  public static readonly KEY_BYTE_LEN_192 = 24;

  /**
   * 密钥长度
   */
  public static readonly KEY_BYTE_LEN_128 = 16;

  /**
   * AES GCM加密时iv的字节长度
   */
  public static readonly AES_GCM_IV_LEN: number = 12;

  /**
   * AES GCM 生成的authTag的字节长度
   */
  public static readonly AES_GCM_AUTH_TAG_LEN: number = 16;

  /**
   * AES CTR加密时iv的字节长度
   */
  public static readonly AES_CTR_IV_LEN: number = 16;

  /**
   * aegis加解密时，返回的数据里iv和密文数据之间的分隔符，如：iv:data
   */
  public static readonly AEGIS_IV_DATA_SEPARATOR: string = ':';

  /**
   * 检查要加解密的数据和密钥
   * @param data 加解密的数据
   * @param key 密钥
   */
  public static checkCryptoParam(data: string | Uint8Array, key: string | Uint8Array): void {
    // 检查密钥
    if (typeof key === 'string') {
      if (StringUtil.isEmpty(key)) {
        throw new Error('key is empty');
      }
    } else {
      if (ArrayUtil.isEmpty(key)) {
        throw new Error('key is empty');
      }
    }
    // 检查加解密数据
    if (typeof data === 'string') {
      if (StringUtil.isEmpty(data)) {
        throw new Error('data is empty');
      }
    } else {
      if (ArrayUtil.isEmpty(data)) {
        throw new Error('data is empty');
      }
    }
  }

  /**
   * 检查iv向量是否为空
   * @param iv iv向量
   * @returns 是否为空
   */
  public static checkIvEmpty(iv: string | Uint8Array): boolean {
    if (typeof iv === 'string') {
      return StringUtil.isEmpty(iv);
    } else {
      return ArrayUtil.isEmpty(iv);
    }
  }

  /**
   * 将不确定的数据转换成字节数组
   * @param data 待转换的数据
   * @returns 转换后的字节数组
   */
  public static convertToBytes(data: string | Uint8Array): Uint8Array {
    if (typeof data === 'string') {
      return StringUtil.hexStringToUint8Array(data);
    } else {
      return data;
    }
  }
}
