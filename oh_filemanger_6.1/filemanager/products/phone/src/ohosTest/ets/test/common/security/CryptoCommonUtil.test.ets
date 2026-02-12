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
import { CryptoCommonUtil } from '@ohos/common/src/main/ets/security/crypto/CryptoCommonUtil';
import { describe, it, expect } from '@ohos/hypium';

const DATA_ERR_MSG = 'data is empty';
const KEY_ERR_MSG = 'key is empty';

export default function CryptoCommonUtilTest() {

  describe('CryptoCommonUtilTest', () => {
    it('checkCryptoParam_empty_string_data', 0, (done: Function) => {
      const data = '';
      const key = 'test';

      try {
        CryptoCommonUtil.checkCryptoParam(data, key);
      } catch (e) {
        expect(e?.message).assertEqual(DATA_ERR_MSG);
      }
      done();
    });

    it('checkCryptoParam_empty_Uint8Array_data', 0, (done: Function) => {
      const data: Uint8Array = new Uint8Array([]);
      const key = 'test';

      try {
        CryptoCommonUtil.checkCryptoParam(data, key);
      } catch (e) {
        expect(e?.message).assertEqual(DATA_ERR_MSG);
      }
      done();
    });

    it('checkCryptoParam_empty_string_key', 0, (done: Function) => {
      const data = 'test';
      const key = '';

      try {
        CryptoCommonUtil.checkCryptoParam(data, key);
      } catch (e) {
        expect(e?.message).assertEqual(KEY_ERR_MSG);
      }
      done();
    });

    it('checkCryptoParam_empty_Uint8Array_key', 0, (done: Function) => {
      const data = 'test';
      const key: Uint8Array = new Uint8Array([]);

      try {
        CryptoCommonUtil.checkCryptoParam(data, key);
      } catch (e) {
        expect(e?.message).assertEqual(KEY_ERR_MSG);
      }
      done();
    });
  });
}