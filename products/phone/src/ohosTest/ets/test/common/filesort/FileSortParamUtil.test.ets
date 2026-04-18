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
import { describe, it, expect, } from '@ohos/hypium';
import { FileGroupOrder, FileSortOrder, FileSortParamUtil, GroupAndSortParam, SortOrder } from '@ohos/common';
import { FileGroupType, FileSortType, } from '@ohos/common/indexDT';

export default function FileSortParamUtilTest() {
  describe('initPhoneGroupAndSortParam_testSuite', () => {
    it('should_return_correct_GroupAndSortParam_for_DEFAULT_order_with_isDesc_true', 0, () => {
      const result: GroupAndSortParam = FileSortParamUtil.initPhoneGroupAndSortParam(SortOrder.DEFAULT, true);
      const groupAndSortParam =
        new GroupAndSortParam(FileGroupType.NONE, FileGroupOrder.ASC, FileSortType.NONE, FileSortOrder.DESC);
      expect(result).assertDeepEquals(groupAndSortParam);
    });

    it('should_return_correct_GroupAndSortParam_for_NAME_order_with_isDesc_false', 0, () => {
      const result: GroupAndSortParam = FileSortParamUtil.initPhoneGroupAndSortParam(SortOrder.NAME, false);
      const groupAndSortParam =
        new GroupAndSortParam(FileGroupType.NAME, FileGroupOrder.ASC, FileSortType.NAME, FileSortOrder.ASC);
      expect(result).assertDeepEquals(groupAndSortParam);
    });

    it('should_return_correct_GroupAndSortParam_for_TYPE_order_with_isRecent_true', 0, () => {
      const result: GroupAndSortParam = FileSortParamUtil.initPhoneGroupAndSortParam(SortOrder.TYPE, true, true);
      const groupAndSortParam = new GroupAndSortParam(FileGroupType.DISPLAY_TYPE, FileGroupOrder.ASC,
        FileSortType.DISPLAY_TYPE, FileSortOrder.DESC);
      expect(result).assertDeepEquals(groupAndSortParam);
    });

    it('should_return_correct_GroupAndSortParam_for_SIZE_order_with_isRecent_false', 0, () => {
      const result: GroupAndSortParam = FileSortParamUtil.initPhoneGroupAndSortParam(SortOrder.SIZE, false, false);
      const groupAndSortParam = new GroupAndSortParam(FileGroupType.SIZE, FileGroupOrder.ASC,
        FileSortType.SIZE, FileSortOrder.ASC);
      expect(result).assertDeepEquals(groupAndSortParam);
    });

    it('should_return_correct_GroupAndSortParam_for_invalid_order', 0, () => {
      const result: GroupAndSortParam = FileSortParamUtil.initPhoneGroupAndSortParam("INVALID_ORDER", true);
      const groupAndSortParam = new GroupAndSortParam(FileGroupType.MODIFIED_TIME, FileGroupOrder.DESC,
        FileSortType.MODIFIED_TIME, FileSortOrder.DESC);
      expect(result).assertDeepEquals(groupAndSortParam);
    });
  });
}