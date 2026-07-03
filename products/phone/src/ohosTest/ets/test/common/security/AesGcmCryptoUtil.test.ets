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
import { AesGcmCryptoUtil } from '@ohos/common/src/main/ets/security/crypto/AesGcmCryptoUtil';
import { CryptoCommonUtil } from '@ohos/common/src/main/ets/security/crypto/CryptoCommonUtil';
import { SafeRandomUtil } from '@ohos/common/src/main/ets/security/SafeRandomUtil';
import { describe, it, expect } from '@ohos/hypium';

const plainText = 'GCM>0330_testData';
const plainTextBytes = StringUtil.stringToUint8Array(plainText);
const plainTextHexString = StringUtil.stringToHexString(plainText);

export default function AesGcmCryptoUtilTest() {

  describe('AesGcmCryptoUtilTest', () => {
    it('AesGcmCryptoUtilTest_encrypt2Bytes256_keyBytes', 0, async () => {
      const keyBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.KEY_BYTE_LEN_256);
      const ivBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.AES_GCM_IV_LEN);
      const res = await AesGcmCryptoUtil.encrypt2Bytes(plainTextBytes, keyBytes, ivBytes);
      expect(res.length)
        .assertEqual(CryptoCommonUtil.AES_GCM_IV_LEN + plainTextBytes.length + CryptoCommonUtil.AES_GCM_AUTH_TAG_LEN);
    });

    it('AesGcmCryptoUtilTest_encrypt2Bytes256_keyHexString', 0, async () => {
      const keyHexString = SafeRandomUtil.getSecureRandomString(CryptoCommonUtil.KEY_BYTE_LEN_256);
      const ivHexString = SafeRandomUtil.getSecureRandomString(CryptoCommonUtil.AES_GCM_IV_LEN);
      const res2 = await AesGcmCryptoUtil.encrypt2Bytes(plainTextHexString, keyHexString, ivHexString);
      expect(res2.length)
        .assertEqual(CryptoCommonUtil.AES_GCM_IV_LEN + plainTextBytes.length + CryptoCommonUtil.AES_GCM_AUTH_TAG_LEN);
    });

    it('encrypt2Bytes256_keyBytesLength_equals_keyHexStringLength', 0, async () => {
      const keyBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.KEY_BYTE_LEN_256);
      const ivBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.AES_GCM_IV_LEN);
      const res = await AesGcmCryptoUtil.encrypt2Bytes(plainTextBytes, keyBytes, ivBytes);

      const keyHexString = SafeRandomUtil.getSecureRandomString(CryptoCommonUtil.KEY_BYTE_LEN_256);
      const ivHexString = SafeRandomUtil.getSecureRandomString(CryptoCommonUtil.AES_GCM_IV_LEN);
      const res2 = await AesGcmCryptoUtil.encrypt2Bytes(plainTextHexString, keyHexString, ivHexString);

      expect(res.length).assertEqual(res2.length);
    });

    it('AesGcmCryptoUtilTest_encrypt2Bytes192_keyBytes', 0, async () => {
      const keyBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.KEY_BYTE_LEN_192);
      const ivBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.AES_GCM_IV_LEN);
      const res = await AesGcmCryptoUtil.encrypt2Bytes(plainTextBytes, keyBytes, ivBytes);
      expect(res.length)
        .assertEqual(CryptoCommonUtil.AES_GCM_IV_LEN + plainTextBytes.length + CryptoCommonUtil.AES_GCM_AUTH_TAG_LEN);
    });

    it('AesGcmCryptoUtilTest_encrypt2Bytes192_keyHexString', 0, async () => {
      const keyHexString = SafeRandomUtil.getSecureRandomString(CryptoCommonUtil.KEY_BYTE_LEN_192);
      const ivHexString = SafeRandomUtil.getSecureRandomString(CryptoCommonUtil.AES_GCM_IV_LEN);
      const res2 = await AesGcmCryptoUtil.encrypt2Bytes(plainTextHexString, keyHexString, ivHexString);
      expect(res2.length)
        .assertEqual(CryptoCommonUtil.AES_GCM_IV_LEN + plainTextBytes.length + CryptoCommonUtil.AES_GCM_AUTH_TAG_LEN);
    });

    it('encrypt2Bytes192_keyBytesLength_equals_keyHexStringLength', 0, async () => {
      const keyBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.KEY_BYTE_LEN_192);
      const ivBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.AES_GCM_IV_LEN);
      const res = await AesGcmCryptoUtil.encrypt2Bytes(plainTextBytes, keyBytes, ivBytes);

      const keyHexString = SafeRandomUtil.getSecureRandomString(CryptoCommonUtil.KEY_BYTE_LEN_192);
      const ivHexString = SafeRandomUtil.getSecureRandomString(CryptoCommonUtil.AES_GCM_IV_LEN);
      const res2 = await AesGcmCryptoUtil.encrypt2Bytes(plainTextHexString, keyHexString, ivHexString);

      expect(res.length).assertEqual(res2.length);
    });

    it('encrypt2Bytes128_keyBytes', 0, async () => {
      const keyBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.KEY_BYTE_LEN_128);
      const ivBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.AES_GCM_IV_LEN);
      const res = await AesGcmCryptoUtil.encrypt2Bytes(plainTextBytes, keyBytes, ivBytes);
      expect(res.length)
        .assertEqual(CryptoCommonUtil.AES_GCM_IV_LEN + plainTextBytes.length + CryptoCommonUtil.AES_GCM_AUTH_TAG_LEN);
    });

    it('AesGcmCryptoUtilTest_encrypt2Bytes128_keyHexString', 0, async () => {
      const keyHexString = SafeRandomUtil.getSecureRandomString(CryptoCommonUtil.KEY_BYTE_LEN_128);
      const ivHexString = SafeRandomUtil.getSecureRandomString(CryptoCommonUtil.AES_GCM_IV_LEN);
      const res2 = await AesGcmCryptoUtil.encrypt2Bytes(plainTextHexString, keyHexString, ivHexString);
      expect(res2.length)
        .assertEqual(CryptoCommonUtil.AES_GCM_IV_LEN + plainTextBytes.length + CryptoCommonUtil.AES_GCM_AUTH_TAG_LEN);
    });

    it('encrypt2Bytes128_keyBytesLength_equals_keyHexStringLength', 0, async () => {
      const keyBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.KEY_BYTE_LEN_128);
      const ivBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.AES_GCM_IV_LEN);
      const res = await AesGcmCryptoUtil.encrypt2Bytes(plainTextBytes, keyBytes, ivBytes);

      const keyHexString = SafeRandomUtil.getSecureRandomString(CryptoCommonUtil.KEY_BYTE_LEN_128);
      const ivHexString = SafeRandomUtil.getSecureRandomString(CryptoCommonUtil.AES_GCM_IV_LEN);
      const res2 = await AesGcmCryptoUtil.encrypt2Bytes(plainTextHexString, keyHexString, ivHexString);

      expect(res.length).assertEqual(res2.length);
    });

    it('AesGcmCryptoUtilTest_decrypt2Bytes256_keyBytes', 0, async () => {
      const keyBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.KEY_BYTE_LEN_256);
      const ivBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.AES_GCM_IV_LEN);
      const encryptRes = await AesGcmCryptoUtil.encrypt2Bytes(plainTextBytes, keyBytes, ivBytes);

      const decryptRes = await AesGcmCryptoUtil.decrypt2Bytes(encryptRes, keyBytes);
      expect(StringUtil.uint8ArrayToString(decryptRes)).assertEqual(plainText);
    });

    it('AesGcmCryptoUtilTest_decrypt2Bytes256_keyHexString', 0, async () => {
      const keyBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.KEY_BYTE_LEN_256);
      const ivBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.AES_GCM_IV_LEN);
      const encryptRes = await AesGcmCryptoUtil.encrypt2Bytes(plainTextBytes, keyBytes, ivBytes);

      const keyHexString = StringUtil.uint8ArrayToHexString(keyBytes);
      const decryptRes2 = await AesGcmCryptoUtil.decrypt2Bytes(encryptRes, keyHexString);
      expect(StringUtil.uint8ArrayToString(decryptRes2)).assertEqual(plainText);
    });

    it('decrypt2Bytes192_keyBytes', 0, async () => {
      const keyBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.KEY_BYTE_LEN_192);
      const ivBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.AES_GCM_IV_LEN);
      const encryptRes = await AesGcmCryptoUtil.encrypt2Bytes(plainTextBytes, keyBytes, ivBytes);

      const decryptRes = await AesGcmCryptoUtil.decrypt2Bytes(encryptRes, keyBytes);
      expect(StringUtil.uint8ArrayToString(decryptRes)).assertEqual(plainText);
    });

    it('AesGcmCryptoUtilTest_decrypt2Bytes192_keyHexString', 0, async () => {
      const keyBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.KEY_BYTE_LEN_192);
      const ivBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.AES_GCM_IV_LEN);
      const encryptRes = await AesGcmCryptoUtil.encrypt2Bytes(plainTextBytes, keyBytes, ivBytes);

      const keyHexString = StringUtil.uint8ArrayToHexString(keyBytes);
      const decryptRes2 = await AesGcmCryptoUtil.decrypt2Bytes(encryptRes, keyHexString);
      expect(StringUtil.uint8ArrayToString(decryptRes2)).assertEqual(plainText);
    });

    it('AesGcmCryptoUtilTest_decrypt2Bytes128_keyBytes', 0, async () => {
      const keyBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.KEY_BYTE_LEN_128);
      const ivBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.AES_GCM_IV_LEN);
      const encryptRes = await AesGcmCryptoUtil.encrypt2Bytes(plainTextBytes, keyBytes, ivBytes);

      const decryptRes = await AesGcmCryptoUtil.decrypt2Bytes(encryptRes, keyBytes);
      expect(StringUtil.uint8ArrayToString(decryptRes)).assertEqual(plainText);
    });

    it('AesGcmCryptoUtilTest_decrypt2Bytes128_keyHexString', 0, async () => {
      const keyBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.KEY_BYTE_LEN_128);
      const ivBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.AES_GCM_IV_LEN);
      const encryptRes = await AesGcmCryptoUtil.encrypt2Bytes(plainTextBytes, keyBytes, ivBytes);

      const keyHexString = StringUtil.uint8ArrayToHexString(keyBytes);
      const decryptRes2 = await AesGcmCryptoUtil.decrypt2Bytes(encryptRes, keyHexString);
      expect(StringUtil.uint8ArrayToString(decryptRes2)).assertEqual(plainText);
    });

    it('AesGcmCryptoUtilTest_encryptAndDecrypt2BytesWithOutIv', 0, async () => {
      const keyBytes = SafeRandomUtil.getSecureRandomBytes(CryptoCommonUtil.KEY_BYTE_LEN_256);
      const encryptRes = await AesGcmCryptoUtil.encrypt2Bytes(plainTextBytes, keyBytes);

      const decryptRes = await AesGcmCryptoUtil.decrypt2Bytes(encryptRes, keyBytes);
      expect(StringUtil.uint8ArrayToString(decryptRes)).assertEqual(plainText);
    });

  });
}