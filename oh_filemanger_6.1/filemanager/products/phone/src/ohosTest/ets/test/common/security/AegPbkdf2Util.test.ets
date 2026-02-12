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
import { HiLog } from '@ohos/common'
import { AegPbkdf2Util } from '@ohos/common/src/main/ets/security/crypto/AegPbkdf2Util';
import { describe, it, expect} from '@ohos/hypium'

const input = 'who are you?';
const salt = 'c5b686af6b13f71ff38c709c87e4549c';
const exceptRet_sha256_10000 = '81d40fe67ba91c9bfcdffb97300145464e1be1ff44094148ed3e930e94401ecf';
const exceptRet_sha256_5000 = '5114cdd9c84797158b39f7a7f8dc620ff8662ecf82a2be67dacb7e8f314f6aab';
const exceptRet_sha256_1000 = 'bac3f40b8f3b96f3b43f56679d9a66cf0a880738159ab6dcf28bca728bc81689';
const exceptRet_sha1_1000 = '7247119df9bef6e84dacec4f39d88aae56ad8604c7115672';

export default function AegPbkdf2UtilTest() {

  describe('AegPbkdf2UtilTest', () => {
    it('pbkdf2Sha256ITERATION10000', 0, async (done: Function) => {
      const res = await AegPbkdf2Util.pbkdf2Sha256(input, salt, AegPbkdf2Util.PBKDF2_ITERATION_10000);
      HiLog.info('AegPbkdf2UtilTest', 'Pbkdf2>10000>' + res);
      expect(res).assertEqual(exceptRet_sha256_10000);
      done();
    });

    it('pbkdf2Sha256ITERATION5000', 0, async (done: Function) => {
      const res = await AegPbkdf2Util.pbkdf2Sha256(input, salt, AegPbkdf2Util.PBKDF2_ITERATION_5000);
      HiLog.info('AegPbkdf2UtilTest', 'Pbkdf2>5000>' + res);
      expect(res).assertEqual(exceptRet_sha256_5000);
      done();
    });

    it('pbkdf2Sha256ITERATION1000', 0, async (done: Function) => {
      const res = await AegPbkdf2Util.pbkdf2Sha256(input, salt, AegPbkdf2Util.PBKDF2_ITERATION_1000);
      HiLog.info('AegPbkdf2UtilTest', 'Pbkdf2>1000>' + res);
      expect(res).assertEqual(exceptRet_sha256_1000);
      done();
    });

    it('pbkdf2Sha1ITERATION1000', 0, async (done: Function) => {
      const res = await AegPbkdf2Util.pbkdf2Sha1(input, salt, AegPbkdf2Util.PBKDF2_ITERATION_1000);
      HiLog.info('AegPbkdf2UtilTest', 'Pbkdf2>1000>' + res);
      expect(res).assertEqual(exceptRet_sha1_1000);
      done();
    });

  });
}