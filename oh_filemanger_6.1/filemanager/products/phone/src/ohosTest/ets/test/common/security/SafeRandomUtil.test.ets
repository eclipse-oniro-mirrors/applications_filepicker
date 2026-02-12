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
import { SafeRandomUtil } from '@ohos/common/src/main/ets/security/SafeRandomUtil';
import { describe, it, expect } from '@ohos/hypium';

const len = 32;

export default function SafeRandomUtilTest() {

  describe('SafeRandomUtilTest', () => {
    it('getSecureRandomBytes', 0, () => {
      const res = SafeRandomUtil.getSecureRandomBytes(len);
      expect(res.length).assertEqual(len);
    });

    it('getSecureRandomString', 0, () => {
      const res = SafeRandomUtil.getSecureRandomString(len);
      expect(res.length).assertEqual(len * 2);
    });

    it('getRandomFileName', 0, () => {
      const res = SafeRandomUtil.getRandomFileName();
      expect(res.length).assertEqual(len);
    });
  });
}