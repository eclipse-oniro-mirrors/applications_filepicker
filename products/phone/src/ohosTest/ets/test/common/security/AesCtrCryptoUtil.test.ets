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
import { HiLog, StringUtil } from '@ohos/common';
import { AesCtrCryptoUtil } from '@ohos/common/src/main/ets/security/crypto/AesCtrCryptoUtil';
import { CryptoCommonUtil } from '@ohos/common/src/main/ets/security/crypto/CryptoCommonUtil';
import { SafeRandomUtil } from '@ohos/common/src/main/ets/security/SafeRandomUtil';
import { describe, it, expect, beforeAll } from '@ohos/hypium';

let plainText = '';
let plainTextBytes: Uint8Array;
let plainTextHexString = '';

const TAG = 'AesCtrCryptoUtilTest';

export default function AesCtrCryptoUtilTest() {

  describe('AesCtrCryptoUtilTest', () => {
    beforeAll(() => {
      // 构造大小为13KB的文件
      HiLog.info(TAG, 'beforeAll start');
      for (let i = 0; i < 1000; i++) {
        plainText += new Date().getTime().toString();
      }
      plainTextBytes = StringUtil.stringToUint8Array(plainText);
      plainTextHexString = StringUtil.stringToHexString(plainText);
      HiLog.info(TAG, 'beforeAll end');
    });

    it('AesCtrCryptoUtilTest_encrypt2Bytes256_ivBytes', 0, async (done: Function) => {
      const keyBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.KEY_BYTE_LEN_256);
      const ivBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.AES_CTR_IV_LEN);
      const res = await AesCtrCryptoUtil.encrypt2Bytes(plainTextBytes, keyBytes, ivBytes);
      expect(res.length).assertEqual(CryptoCommonUtil.AES_CTR_IV_LEN + plainTextBytes.length);
      done();
    });

    it('AesCtrCryptoUtilTest_encrypt2Bytes256_ivHexString', 0, async (done: Function) => {
      const keyHexString = SafeRandomUtil.getSecureRandomString(CryptoCommonUtil.KEY_BYTE_LEN_256);
      const ivHexString = SafeRandomUtil.getSecureRandomString(CryptoCommonUtil.AES_CTR_IV_LEN);
      const res2 = await AesCtrCryptoUtil.encrypt2Bytes(plainTextHexString, keyHexString, ivHexString);
      expect(res2.length).assertEqual(CryptoCommonUtil.AES_CTR_IV_LEN + plainTextBytes.length);
      done();
    });

    it('AesCtrCryptoUtilTest_encrypt2Bytes128_ivBytes', 0, async (done: Function) => {
      const keyBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.KEY_BYTE_LEN_128);
      const ivBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.AES_CTR_IV_LEN);
      const res = await AesCtrCryptoUtil.encrypt2Bytes(plainTextBytes, keyBytes, ivBytes);
      expect(res.length).assertEqual(CryptoCommonUtil.AES_CTR_IV_LEN + plainTextBytes.length);
      done();
    });

    it('AesCtrCryptoUtilTest_encrypt2Bytes128_ivHexString', 0, async (done: Function) => {
      const keyHexString = SafeRandomUtil.getSecureRandomString(CryptoCommonUtil.KEY_BYTE_LEN_128);
      const ivHexString = SafeRandomUtil.getSecureRandomString(CryptoCommonUtil.AES_CTR_IV_LEN);
      const res2 = await AesCtrCryptoUtil.encrypt2Bytes(plainTextHexString, keyHexString, ivHexString);
      expect(res2.length).assertEqual(CryptoCommonUtil.AES_CTR_IV_LEN + plainTextBytes.length);
      done();
    });

    it('AesCtrCryptoUtilTest_decrypt2Bytes256_keyBytes', 0, async (done: Function) => {
      const keyBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.KEY_BYTE_LEN_256);
      const ivBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.AES_CTR_IV_LEN);
      const encryptRes = await AesCtrCryptoUtil.encrypt2Bytes(plainTextBytes, keyBytes, ivBytes);

      const decryptRes = await AesCtrCryptoUtil.decrypt2Bytes(encryptRes, keyBytes);
      expect(StringUtil.uint8ArrayToString(decryptRes)).assertEqual(plainText);
      done();
    });

    it('AesCtrCryptoUtilTest_decrypt2Bytes256_keyHexString', 0, async (done: Function) => {
      const keyBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.KEY_BYTE_LEN_256);
      const ivBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.AES_CTR_IV_LEN);
      const encryptRes = await AesCtrCryptoUtil.encrypt2Bytes(plainTextBytes, keyBytes, ivBytes);

      const keyHexString = StringUtil.uint8ArrayToHexString(keyBytes);
      const decryptRes2 = await AesCtrCryptoUtil.decrypt2Bytes(encryptRes, keyHexString);
      expect(StringUtil.uint8ArrayToString(decryptRes2)).assertEqual(plainText);
      done();
    });

    it('AesCtrCryptoUtilTest_decrypt2Bytes128_keyBytes', 0, async (done: Function) => {
      const keyBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.KEY_BYTE_LEN_128);
      const ivBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.AES_CTR_IV_LEN);
      const encryptRes = await AesCtrCryptoUtil.encrypt2Bytes(plainTextBytes, keyBytes, ivBytes);

      const decryptRes = await AesCtrCryptoUtil.decrypt2Bytes(encryptRes, keyBytes);
      expect(StringUtil.uint8ArrayToString(decryptRes)).assertEqual(plainText);
      done();
    });

    it('AesCtrCryptoUtilTest_decrypt2Bytes128_keyHexString', 0, async (done: Function) => {
      const keyBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.KEY_BYTE_LEN_128);
      const ivBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.AES_CTR_IV_LEN);
      const encryptRes = await AesCtrCryptoUtil.encrypt2Bytes(plainTextBytes, keyBytes, ivBytes);

      const keyHexString = StringUtil.uint8ArrayToHexString(keyBytes);
      const decryptRes2 = await AesCtrCryptoUtil.decrypt2Bytes(encryptRes, keyHexString);
      expect(StringUtil.uint8ArrayToString(decryptRes2)).assertEqual(plainText);
      done();
    });

    it('AesCtrCryptoUtilTest_encryptAndDecrypt2BytesWithOutIv', 0, async (done: Function) => {
      const keyBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.KEY_BYTE_LEN_256);
      const encryptRes = await AesCtrCryptoUtil.encrypt2Bytes(plainTextBytes, keyBytes);
      const decryptRes = await AesCtrCryptoUtil.decrypt2Bytes(encryptRes, keyBytes);
      expect(StringUtil.uint8ArrayToString(decryptRes)).assertEqual(plainText);
      done();
    });
  });
}