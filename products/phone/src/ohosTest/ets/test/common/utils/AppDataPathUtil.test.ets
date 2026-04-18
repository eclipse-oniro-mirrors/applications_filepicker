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
import { AppDataPathUtil, BundleResourceUtil, FileUtil, MyComputerConstant } from '@ohos/common';
import { describe, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';

export default function AppDataPathUtilTest() {
  const URI_LOCAL_START = 'file://docs/';

  describe('AppDataPathUtilTest', () => {
    it('isPathWritable_isDevelopMode_true', 0, () => {
      const result: boolean = AppDataPathUtil.isPathWritable('test/path', true);
      expect(result).assertTrue();
    })

    it('isPathWritable_isDevelopMode_false', 0, () => {
      const result = AppDataPathUtil.isPathWritable('test/path', false);
      expect(result).assertTrue();
    })

    it('isPathWritable_uri_isDevelopMode_true', 0, () => {
      const uri = MyComputerConstant.myComputerChinese2UriMap[3][1] + 'test/path';
      const result = AppDataPathUtil.isPathWritable(uri, false);
      expect(result).assertFalse();
    })

    it('isPathWritable_uri_isDevelopMode_false', 0, () => {
      const uri = MyComputerConstant.myComputerChinese2UriMap[3][1] + 'test/path';
      const result = AppDataPathUtil.isPathWritable(uri, true);
      expect(result).assertTrue();
    })

    it('isSandBoxUri_0_test', 0, () => {
      expect(AppDataPathUtil.isSandBoxUri('test/path')).assertFalse();
    })

    it('isSandBoxUri_1_test', 0, () => {
      const uri: string = MyComputerConstant.myComputerChinese2UriMap[3][1] + '/test/path';
      const result: boolean = AppDataPathUtil.isSandBoxUri(uri);
      expect(result).assertTrue();
    })

    it('isSandBoxUri_2_test', 0, () => {
      const uri2: string[] = [];
      const result = AppDataPathUtil.isSandBoxUri(uri2[0]);
      expect(result).assertFalse();
    })
  })
}