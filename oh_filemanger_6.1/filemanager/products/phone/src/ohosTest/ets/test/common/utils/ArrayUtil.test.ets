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
import { ArrayUtil } from '@ohos/common';
import { describe, expect, it } from '@ohos/hypium';

export default function ArrayUtilTest() {
  describe('ArrayUtilTest', () => {
    it('isEmpty_undefined', 0, () => {
      let result = ArrayUtil.isEmpty(undefined);
      expect(result).assertTrue();
    });

    it('isEmpty_null', 0, () => {
      let result = ArrayUtil.isEmpty(null);
      expect(result).assertTrue();
    });

    it('isEmpty_empty_array', 0, () => {
      let result = ArrayUtil.isEmpty([]);
      expect(result).assertTrue();
    });

    it('isEmpty_number_array', 0, () => {
      let result = ArrayUtil.isEmpty(['1', '2']);
      expect(result).assertFalse();
    });

    it('contains_undefined_array', 0, () => {
      let result = ArrayUtil.contains(undefined, 'test');
      expect(result).assertFalse();
    });

    it('contains_null_array', 0, () => {
      let result = ArrayUtil.contains(null, 'test');
      expect(result).assertFalse();
    });

    it('contains_empty_array', 0, () => {
      let result = ArrayUtil.contains([], 'test');
      expect(result).assertFalse();
    });

    it('contains_undefined_item', 0, () => {
      let result = ArrayUtil.contains(['test'], undefined);
      expect(result).assertFalse();
    });

    it('contains_null_item', 0, () => {
      let result = ArrayUtil.contains(['test'], null);
      expect(result).assertFalse();
    });

    it('contains_not_have_item', 0, () => {
      let result = ArrayUtil.contains(['noTest'], 'test');
      expect(result).assertFalse();
    });

    it('contains_have_item', 0, () => {
      let result = ArrayUtil.contains(['test'], 'test');
      expect(result).assertTrue();
    });

    it('max_positive_number', 0, () => {
      let result = ArrayUtil.max([1, 3, 5, 7]);
      expect(result).assertEqual(7);
    });

    it('max_negative_number', 0, () => {
      let result = ArrayUtil.max([-1, -3, -5, -7]);
      expect(result).assertEqual(-1);
    });

    it('min_positive_number', 0, () => {
      let result = ArrayUtil.min([1, 3, 5, 7]);
      expect(result).assertEqual(1);
    });

    it('min_negative_number', 0, () => {
      let result = ArrayUtil.min([-1, -3, -5, -7]);
      expect(result).assertEqual(-7);
    });
  });
}