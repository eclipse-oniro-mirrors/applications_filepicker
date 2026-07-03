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

import cryptoFramework from '@ohos.security.cryptoFramework';
import { ArrayUtil } from '../../utils/ArrayUtil';
import { CryptoCommonUtil } from './CryptoCommonUtil';

const TAG = 'CryptoFrameworkUtil';

/**
 * 系统加解密框架CryptoFramework相关方法
 */
export class CryptoFrameworkUtil {
  /**
   * AES/GCM 加解密规格, 密钥长度为32字节
   */
  public static readonly AES_GCM_256_NO_PADDING: string = 'AES256|GCM|NoPadding';

  /**
   * AES/GCM 加解密规格, 密钥长度为16字节
   */
  public static readonly AES_GCM_128_NO_PADDING: string = 'AES128|GCM|NoPadding';

  /**
   * AES/CTR 加解密规格, 密钥长度为32字节
   */
  public static readonly AES_CTR_256_NO_PADDING: string = 'AES256|CTR|NoPadding';

  /**
   * AES/CTR 加解密规格, 密钥长度为16字节
   */
  public static readonly AES_CTR_192_NO_PADDING: string = 'AES192|CTR|NoPadding';

  /**
   * AES/CTR 加解密规格, 密钥长度为16字节
   */
  public static readonly AES_CTR_128_NO_PADDING: string = 'AES128|CTR|NoPadding';

  /**
   * 密钥规格, 密钥长度为32字节
   */
  public static readonly AES_256: string = 'AES256';

  /**
   * 密钥规格, 密钥长度为24字节
   */
  public static readonly AES_192: string = 'AES192';

  /**
   * 密钥规格, 密钥长度为16字节
   */
  public static readonly AES_128: string = 'AES128';

  /**
   * 分段加密时每段的大小
   */
  public static readonly SEGMENTATION_SIZE: number = 100 * 1000;

  /**
   * 获取AES/GCM加密的Cipher实例
   * @param key 密钥
   * @param iv iv向量
   * @returns Cipher
   */
  public static async getAesGcmEncryptCipher(key: string | Uint8Array, iv: string | Uint8Array): Promise<cryptoFramework.Cipher> {
    const ivBytes = CryptoCommonUtil.convertToBytes(iv);
    const gcmParamsSpec: cryptoFramework.GcmParamsSpec = {
      algName: 'GcmParamsSpec',
      iv: {
        data: ivBytes
      },
      aad: {
        data: new Uint8Array()
      },
      authTag: {
        data: new Uint8Array()
      }
    };
    return await this.getAesGcmCipher(cryptoFramework.CryptoMode.ENCRYPT_MODE, key, gcmParamsSpec);
  }

  /**
   * 获取AES/GCM解密的Cipher实例
   * @param key 密钥
   * @param iv iv向量
   * @param authTag 校验待解密的密文是否完成的16位字节
   * @returns Cipher
   */
  public static async getAesGcmDecryptCipher(key: string | Uint8Array, iv: string | Uint8Array,
    authTag: Uint8Array): Promise<cryptoFramework.Cipher> {
    const ivBytes = CryptoCommonUtil.convertToBytes(iv);
    const gcmParamsSpec: cryptoFramework.GcmParamsSpec = {
      algName: 'GcmParamsSpec',
      iv: {
        data: ivBytes
      },
      aad: {
        data: new Uint8Array(),
      },
      authTag: {
        data: authTag
      }
    };
    return await this.getAesGcmCipher(cryptoFramework.CryptoMode.DECRYPT_MODE, key, gcmParamsSpec);
  }

  /**
   * 获取AES/CTR模式加密的Cipher实例
   * @param key 解密密钥
   * @param iv iv向量
   * @returns Cipher实例
   */
  public static async getAesCtrEncryptCipher(key: string | Uint8Array,
    iv: string | Uint8Array): Promise<cryptoFramework.Cipher> {
    const ivBytes = CryptoCommonUtil.convertToBytes(iv);
    const ivParamsSpec: cryptoFramework.IvParamsSpec = {
      algName: 'IvParamsSpec',
      iv: {
        data: ivBytes
      }
    };
    return await this.getAesCtrCipher(cryptoFramework.CryptoMode.ENCRYPT_MODE, key, ivParamsSpec);
  }

  /**
   * 获取AES/CTR模式解密的Cipher实例
   * @param key 解密密钥
   * @param iv iv向量
   * @returns Cipher实例
   */
  public static async getAesCtrDecryptCipher(key: string | Uint8Array,
    iv: string | Uint8Array): Promise<cryptoFramework.Cipher> {
    const ivBytes = CryptoCommonUtil.convertToBytes(iv);
    const ivParamsSpec: cryptoFramework.IvParamsSpec = {
      algName: 'IvParamsSpec',
      iv: {
        data: ivBytes
      }
    };
    return await this.getAesCtrCipher(cryptoFramework.CryptoMode.DECRYPT_MODE, key, ivParamsSpec);
  }

  /**
   * 获取AES/GCM加解密的Cipher实例
   * @param mode 模式，加密或解密
   * @param key 密钥
   * @param gcmParamsSpec 加解密参数
   * @returns Cipher
   */
  private static async getAesGcmCipher(mode: cryptoFramework.CryptoMode, key: string | Uint8Array,
    gcmParamsSpec: cryptoFramework.GcmParamsSpec): Promise<cryptoFramework.Cipher> {
    let cipherAlgName = '';
    let keyAlgName = '';
    const keyBytes = CryptoCommonUtil.convertToBytes(key);
    if (keyBytes.length === CryptoCommonUtil.KEY_BYTE_LEN_256) {
      keyAlgName = this.AES_256;
      cipherAlgName = this.AES_GCM_256_NO_PADDING;
    } else if (keyBytes.length === CryptoCommonUtil.KEY_BYTE_LEN_128) {
      keyAlgName = this.AES_128;
      cipherAlgName = this.AES_GCM_128_NO_PADDING;
    } else {
      throw new Error('key length is invalid');
    }
    return await this.getCipher(cipherAlgName, keyAlgName, mode, keyBytes, gcmParamsSpec);
  }

  /**
   * 获取AES/CTR模式加解密的Cipher实例
   * @param mode 模式，加密或解密
   * @param key 密钥
   * @param ivParamsSpec 加解密参数
   * @returns Cipher实例
   */
  private static async getAesCtrCipher(mode: cryptoFramework.CryptoMode, key: string | Uint8Array,
    ivParamsSpec: cryptoFramework.IvParamsSpec): Promise<cryptoFramework.Cipher> {
    let cipherAlgName = '';
    let keyAlgName = '';
    const keyBytes = CryptoCommonUtil.convertToBytes(key);
    if (keyBytes.length === CryptoCommonUtil.KEY_BYTE_LEN_256) {
      keyAlgName = this.AES_256;
      cipherAlgName = this.AES_CTR_256_NO_PADDING;
    } else if (keyBytes.length === CryptoCommonUtil.KEY_BYTE_LEN_128) {
      keyAlgName = this.AES_128;
      cipherAlgName = this.AES_CTR_128_NO_PADDING;
    } else if (keyBytes.length === CryptoCommonUtil.KEY_BYTE_LEN_192) {
      keyAlgName = this.AES_192;
      cipherAlgName = this.AES_CTR_192_NO_PADDING;
    } else {
      throw new Error('key length is invalid');
    }
    return await this.getCipher(cipherAlgName, keyAlgName, mode, keyBytes, ivParamsSpec);
  }

  /**
   * 获取指定加解密模式的Cipher实例
   * @param cipherAlgName 加解密规格
   * @param keyAlgName 密钥规格
   * @param mode 加密或解密
   * @param key 密钥
   * @param paramsSpec 加解密参数
   * @returns Cipher实例
   */
  private static async getCipher(cipherAlgName: string, keyAlgName: string, mode: cryptoFramework.CryptoMode,
    key: Uint8Array, paramsSpec: cryptoFramework.ParamsSpec): Promise<cryptoFramework.Cipher> {
    const symKeyGenerator = cryptoFramework.createSymKeyGenerator(keyAlgName);
    const keyDataBlob = { data: key };
    const cipher = cryptoFramework.createCipher(cipherAlgName);
    const symKey = await symKeyGenerator.convertKey(keyDataBlob);
    await cipher.init(mode, symKey, paramsSpec);
    return cipher;
  }

  /**
   * 分段加解密
   * @param cipher Cipher实例
   * @param data 待加解密的数据
   * @return 加解密后的字节数组
   */
  public static async encryptOrDecryptWithSegmentation(cipher: cryptoFramework.Cipher,
    data: Uint8Array): Promise<Uint8Array> {
    let result: Uint8Array = new Uint8Array(data.length);
    let resolveBytesLen = 0;
    while (resolveBytesLen < data.length) {
      const endIndex = Math.min(resolveBytesLen + this.SEGMENTATION_SIZE, data.length);
      const tempData = data.slice(resolveBytesLen, endIndex);
      const updateRes = await cipher.update({
        data: tempData
      });
      if (updateRes && updateRes.data) {
        result.set(updateRes.data, resolveBytesLen);
      }
      resolveBytesLen += this.SEGMENTATION_SIZE;
    }
    const finalRes = await cipher.doFinal(null);
    if (finalRes && (!ArrayUtil.isEmpty(finalRes.data))) {
      const newBytes = new Uint8Array(result.length + finalRes.data.length);
      newBytes.set(result, 0);
      newBytes.set(finalRes.data, result.length);
      result = newBytes;
    }
    return result;
  }
}
