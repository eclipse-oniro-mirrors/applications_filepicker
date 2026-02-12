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

import { HiLog } from '../../dfx/HiLog';
import { StringUtil } from '../../utils/StringUtil';
import { CryptoFrameworkUtil } from './CryptoFrameworkUtil';
import { CryptoCommonUtil } from './CryptoCommonUtil';
import { SafeRandomUtil } from '../SafeRandomUtil';

const TAG = 'AesCtrCryptoUtil';

/**
 * AES/CTR加解密工具类
 */
export class AesCtrCryptoUtil {
  /**
   * 使用AES/CTR模式进行加密并返回密文的hexString
   */
  public static async encrypt(plainText: string | Uint8Array, key: string | Uint8Array, iv: string | Uint8Array = ''): Promise<string> {
    const encryptedBytes = await this.encrypt2Bytes(plainText, key, iv);
    return StringUtil.uint8ArrayToHexString(encryptedBytes);
  }

  /**
   * 使用AES/CTR模式进行解密并返回明文的hexString
   */
  public static async decrypt(cipherText: string | Uint8Array, key: string | Uint8Array): Promise<string> {
    const decryptedBytes = await this.decrypt2Bytes(cipherText, key);
    return StringUtil.uint8ArrayToHexString(decryptedBytes);
  }

  /**
   * 使用AES/CTR模式进行加密并返回密文的字节数组
   * @param plainText 待加密的明文，格式为hexString或字节数组
   * @param key 加密密钥，格式为hexString或字节数组
   * @param iv iv向量，格式为hexString或字节数组
   * @returns 密文的字节数组
   */
  public static async encrypt2Bytes(plainText: string | Uint8Array, key: string | Uint8Array, iv: string | Uint8Array = ''): Promise<Uint8Array> {
    let result: Uint8Array;
    try {
      CryptoCommonUtil.checkCryptoParam(plainText, key);
      if (CryptoCommonUtil.checkIvEmpty(iv)) {
        iv = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.AES_CTR_IV_LEN);
      }
      const cipher = await CryptoFrameworkUtil.getAesCtrEncryptCipher(key, iv);
      const encryptRes = await CryptoFrameworkUtil.encryptOrDecryptWithSegmentation(cipher, CryptoCommonUtil.convertToBytes(plainText));
      const ivBytes = CryptoCommonUtil.convertToBytes(iv);
      let finalEncryptData = new Uint8Array(encryptRes.length + ivBytes.length);
      finalEncryptData.set(ivBytes, 0);
      finalEncryptData.set(encryptRes, ivBytes.length);

      result = finalEncryptData;
    } catch (error) {
      HiLog.error(TAG, 'encrypt2Bytes fail, error' + error + JSON.stringify(error));
    }
    return result;
  }

  /**
   * 使用AES/CTR模式进行解密并返回明文的字节数组
   * @param cipherText 待解密的明文，格式为hexString或字节数组
   * @param key 解密密钥，格式为hexString或字节数组
   * @param iv iv向量，格式为hexString或字节数组
   * @returns 明文的字节数组
   */
  public static async decrypt2Bytes(cipherText: string | Uint8Array, key: string | Uint8Array): Promise<Uint8Array> {
    let result: Uint8Array;
    try {
      let iv: string | Uint8Array;
      let cipherData: string | Uint8Array;
      CryptoCommonUtil.checkCryptoParam(cipherText, key);
      if (typeof cipherText === 'string') {
        iv = cipherText.substring(0, CryptoCommonUtil.AES_CTR_IV_LEN * 2);
        cipherData = cipherText.substring(CryptoCommonUtil.AES_CTR_IV_LEN * 2);
      } else {
        iv = cipherText.slice(0, CryptoCommonUtil.AES_CTR_IV_LEN);
        cipherData = cipherText.slice(CryptoCommonUtil.AES_CTR_IV_LEN);
      }
      const cipher = await CryptoFrameworkUtil.getAesCtrDecryptCipher(key, iv);
      result = await CryptoFrameworkUtil.encryptOrDecryptWithSegmentation(cipher, CryptoCommonUtil.convertToBytes(cipherData));
    } catch (error) {
      HiLog.error(TAG, 'decrypt2Bytes fail, error' + error + JSON.stringify(error));
    }
    return result;
  }
}
