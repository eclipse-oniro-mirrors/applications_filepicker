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

import { AegAesGcm } from '@hms-security/agoh-crypto';
import { HiLog } from '../../dfx/HiLog';
import { SafeRandomUtil } from '../SafeRandomUtil';
import { CryptoCommonUtil } from './CryptoCommonUtil';
import { StringUtil } from '../../utils/StringUtil';

const TAG = 'AesGcmCryptoUtil';

/**
 * AES/GCM加解密工具类
 */
export class AesGcmCryptoUtil {
  /**
   * AES GCM加密，密钥长度支持128和256
   * @param plainText 待加密的明文 hexString或字节数组
   * @param key 加密密钥, 16进制字符串 hexString或字节数组
   * @param iv iv向量
   * @return 加密后的密文HexString，格式如下iv+data，不包含冒号”：“
   */
  public static async encrypt(plainText: string | Uint8Array, key: string | Uint8Array, iv: string | Uint8Array = ''): Promise<string> {
    const encryptedBytes = await this.encrypt2Bytes(plainText, key, iv);
    return StringUtil.uint8ArrayToHexString(encryptedBytes);
  }

  /**
   * AES GCM解密，密钥长度支持128和256
   * @param encryptData 待解密的密文，格式为：iv+data
   * @param key 解密的密钥
   * @param iv 加密时的iv向量
   * @return 解密后的明文HexString
   */
  public static async decrypt(cipherText: string | Uint8Array, key: string | Uint8Array): Promise<string> {
    const decryptedBytes = await this.decrypt2Bytes(cipherText, key);
    return StringUtil.uint8ArrayToHexString(decryptedBytes);
  }


  /**
   * 将明文数据加密成字节数组
   * @param plainText 加密前的明文数据
   * @param key 加密密钥
   * @param iv iv向量
   * @returns 密文字节数组，格式为iv+data，不包含冒号”：“
   */
  public static async encrypt2Bytes(plainText: string | Uint8Array, key: string | Uint8Array, iv: string | Uint8Array = ''): Promise<Uint8Array> {
    let result: Uint8Array = undefined;
    try {
      CryptoCommonUtil.checkCryptoParam(plainText, key);
      if (CryptoCommonUtil.checkIvEmpty(iv)) {
        iv = SafeRandomUtil.getSecureRandomString(CryptoCommonUtil.AES_GCM_IV_LEN);
      }
      const cipherText = await AegAesGcm.ohAegAesGcmEnc(plainText, key, iv);
      // aegis加密后返回的格式为iv:data，需要移除冒号
      const ivBytes = cipherText.slice(0, CryptoCommonUtil.AES_GCM_IV_LEN);
      const dataBytes = cipherText.slice(CryptoCommonUtil.AES_GCM_IV_LEN + CryptoCommonUtil.AEGIS_IV_DATA_SEPARATOR.length);
      result = new Uint8Array(cipherText.length - CryptoCommonUtil.AEGIS_IV_DATA_SEPARATOR.length);
      result.set(ivBytes, 0);
      result.set(dataBytes, ivBytes.length);
    } catch (error) {
      HiLog.error(TAG, 'encrypt2Bytes fail, error:' + JSON.stringify(error));
    }
    return result;
  }

  /**
   * 将密文数据加密成字节数组
   * @param plainText 解密前的密文数据，格式为：iv+data
   * @param key 解密密钥
   * @returns 密文字节数组
   */
  public static async decrypt2Bytes(cipherText: string | Uint8Array, key: string | Uint8Array): Promise<Uint8Array> {
    let result: Uint8Array = undefined;
    try {
      CryptoCommonUtil.checkCryptoParam(cipherText, key);
      // 将hexString密文转换成aegis需要的格式
      const tempCipherText: string | Uint8Array = this.convert2AegisCipherText(cipherText);
      result = await AegAesGcm.ohAegAesGcmDec(tempCipherText, key);
    } catch (error) {
      HiLog.error(TAG, 'decrypt2Bytes fail, error:' + JSON.stringify(error));
    }
    return result;
  }

  /**
   * 将hexString密文转换成aegis解密时需要的格式iv+:+data
   * @param cipherText 原始密文,iv+data
   * @returns 转换后的密文iv+:+data
   */
  private static convert2AegisCipherText(cipherText: string | Uint8Array): string | Uint8Array {
    if (typeof cipherText === 'string') {
      const iv = cipherText.substring(0, CryptoCommonUtil.AES_GCM_IV_LEN * 2);
      const data = cipherText.substring(CryptoCommonUtil.AES_GCM_IV_LEN * 2);
      return iv + CryptoCommonUtil.AEGIS_IV_DATA_SEPARATOR + data;
    } else {
      const ivBytes = cipherText.slice(0, CryptoCommonUtil.AES_GCM_IV_LEN);
      const dataBytes = cipherText.slice(CryptoCommonUtil.AES_GCM_IV_LEN);
      let resultBytes = new Uint8Array(cipherText.length + CryptoCommonUtil.AEGIS_IV_DATA_SEPARATOR.length);
      resultBytes.set(ivBytes, 0);
      resultBytes.set(StringUtil.stringToUint8Array(CryptoCommonUtil.AEGIS_IV_DATA_SEPARATOR), ivBytes.length);
      resultBytes.set(dataBytes, ivBytes.length + CryptoCommonUtil.AEGIS_IV_DATA_SEPARATOR.length);
      return resultBytes;
    }
  }
}
