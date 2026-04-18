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
import { ObjectUtil } from '@ohos/common';
import { describe, it, expect } from '@ohos/hypium';

export default function ObjectUtilTest() {
  describe('ObjectUtilTest', () => {
    it('isNullFalseTest', 0, async () => {
      let result = ObjectUtil.isNull({});
      expect(result).assertEqual(false);
    });

    it('isNullUndefinedTest', 0, async () => {
      let result = ObjectUtil.isNull(undefined);
      expect(result).assertEqual(false);
    });

    it('isNull', 0, async () => {
      let result = ObjectUtil.isNull(null);
      expect(result).assertEqual(true);
    });

    it('isUndefined', 0, async () => {
      let result = ObjectUtil.isUndefined(undefined);
      expect(result).assertEqual(true);
    });

    it('isUndefinedFalse', 0, async () => {
      let result = ObjectUtil.isUndefined({});
      expect(result).assertEqual(false);
    });

    it('isNullOrUndefined', 0, async () => {
      let result = ObjectUtil.isNullOrUndefined(null);
      expect(result).assertEqual(true);
    });

    it('isNullOrUndefinedTrueTest', 0, async () => {
      let result = ObjectUtil.isNullOrUndefined(undefined);
      expect(result).assertEqual(true);
    });

    it('isNullOrUndefinedFalseTest', 0, async () => {
      let result = ObjectUtil.isNullOrUndefined({});
      expect(result).assertEqual(false);
    });

    it('toString', 0, async () => {
      let defaultValue: string = 'default';
      let result: string = ObjectUtil.toString(null, defaultValue);
      expect(result).assertEqual(defaultValue);
    });

    it('toStringTest', 0, async () => {
      let defaultValue: string = 'default';
      let obj: string = 'test';
      let result = ObjectUtil.toString(obj, defaultValue);
      expect(result).assertEqual(obj);
    });

    it('hasKey', 0, async () => {
      let result = ObjectUtil.hasKey({ key: 'value' }, 'key');
      expect(result).assertTrue();
    });

    it('hasKeyFalseTest', 0, async () => {
      let result = ObjectUtil.hasKey({ key: 'value' }, 'unknownKey');
      expect(result).assertFalse();
    });

    it('empty', 0, async () => {
      const result = ObjectUtil.empty();
      expect(result).assertDeepEquals({});
    });

    it('toArray', 0, async () => {
      let result = ObjectUtil.toArray<object>(null);
      expect(result).assertDeepEquals([]);
    });

    it('toArrayNotNullTest', 0, async () => {
      let result = ObjectUtil.toArray<number[]>([1, 2, 3]);
      expect(result).assertDeepEquals([1, 2, 3]);
    });

    it('toArrayNullTest', 0, async () => {
      let result = ObjectUtil.toArray<object>({ key: 'value' });
      expect(result).assertDeepEquals([]);
    });
  });
}