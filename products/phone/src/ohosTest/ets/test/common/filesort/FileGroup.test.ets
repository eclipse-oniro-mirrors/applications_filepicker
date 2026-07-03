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
import { describe, expect, it, } from '@ohos/hypium';
import { FileInfo, FileOrGroup } from '@ohos/common';

export default function FileGroupTest() {
  describe('FileGroupTest', () => {
    it('getRefreshMark_success_with_group', 0, () => {
      let fileOrGroup = new FileOrGroup(true, 0, new FileInfo(), false, 1, 1);
      let result = FileOrGroup.getRefreshMark(fileOrGroup);
      expect(result).assertEqual('true__0_1__0000_0_-1_');
    });
  });
}