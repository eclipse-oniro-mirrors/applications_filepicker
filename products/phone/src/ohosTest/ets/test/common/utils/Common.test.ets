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
import { describe, expect, it } from '@ohos/hypium';
import { AddressData, Constant } from '@ohos/common';
import {
  getCurrentFolderPathByBreadCrumb,
  getFilePickBottomOptions,
  getSelectBottomOptions,
  menuCanClick
} from '../../../../../main/ets/base/utils/Common';
import { BottomOptions } from '@ohos/bottomBar';

export default function CommonTest() {
  describe('CommonTest', () => {
    it('getCurrentFolderPathByBreadCrumb', 0, () => {
      let uri1: string = 'file://docs/storage/Users/currentUser/Downloadname';
      let uri2: string = 'file://docs/storage/Users/currentUser/Download/com.ohos.browsername';
      let direList: AddressData[] =
        [new AddressData(uri1, 'Download', 'LOCAL'), new AddressData(uri2, '浏览器', 'LOCAL')];
      let pathByBreadCrumb: string = getCurrentFolderPathByBreadCrumb(direList, false);
      expect(pathByBreadCrumb).assertEqual('/Download/com.ohos.browsername')

      pathByBreadCrumb = getCurrentFolderPathByBreadCrumb(direList, true);
      expect(pathByBreadCrumb).assertEqual('/Download/com.ohos.browsername/')
    })

    it('menuCanClick', 0, () => {
      let operationType: string = '';
      let checkedNum: number = 0;
      let canClick: boolean = menuCanClick(checkedNum, operationType);
      expect(canClick).assertFalse();
    })

    it('menuCanClickSelectText', 0, () => {
      let checkedNum: number = 0;
      let operationType = Constant.OPERATION_TYPE.SELECT_ALL;
      let canClick = menuCanClick(checkedNum, operationType);
      expect(canClick).assertTrue();
    })

    it('menuCanClickDeselectTest', 0, () => {
      let checkedNum: number = 0;
      let operationType = Constant.OPERATION_TYPE.DESELECT_ALL;
      let canClick = menuCanClick(checkedNum, operationType);
      expect(canClick).assertTrue();
    })

    it('menuCanClickFolderTest', 0, () => {
      let checkedNum: number = 0;
      let operationType = Constant.OPERATION_TYPE.OPEN_FOLDER;
      let canClick = menuCanClick(checkedNum, operationType);
      expect(canClick).assertFalse();
    })

    it('menuCanClickCheckedOneTest', 0, () => {
      let operationType = Constant.OPERATION_TYPE.OPEN_FOLDER;
      let checkedNum = 1;
      let canClick = menuCanClick(checkedNum, operationType);
      expect(canClick).assertTrue();
    })

    it('getFilePickBottomOptions', 0, () => {
      let isSelectAll: boolean = false;
      let filePickBottomOptions: BottomOptions[] = getFilePickBottomOptions(isSelectAll);
      expect(filePickBottomOptions[0].type).assertEqual(Constant.OPERATION_TYPE.SELECT_ALL);
    })

    it('getFilePickBottomOptionsTrueTest', 0, () => {
      let isSelectAll = true;
      let filePickBottomOptions = getFilePickBottomOptions(isSelectAll);
      expect(filePickBottomOptions[0].type).assertEqual(Constant.OPERATION_TYPE.DESELECT_ALL);
    })

    it('getSelectBottomOptions', 0, () => {
      let isSelectAll: boolean = false;
      let filePickBottomOptions: BottomOptions[] = getFilePickBottomOptions(isSelectAll);
      let selectBottomOptions: BottomOptions[] = getSelectBottomOptions(filePickBottomOptions, isSelectAll);
      expect(selectBottomOptions[0].type).assertEqual(Constant.OPERATION_TYPE.SELECT_ALL);
    })

    it('getSelectBottomOptionsBottomOptionsTest', 0, () => {
      let isSelectAll: boolean = false;
      let filePickBottomOptions: BottomOptions[] = getFilePickBottomOptions(isSelectAll);
      isSelectAll = true;
      let selectBottomOptions = getSelectBottomOptions(filePickBottomOptions, isSelectAll);
      expect(filePickBottomOptions[0].type).assertEqual(Constant.OPERATION_TYPE.DESELECT_ALL);
    })

    it('getSelectBottomOptionsTrueTest', 0, () => {
      let isSelectAll = true;
      let filePickBottomOptions = getFilePickBottomOptions(isSelectAll);
      expect(filePickBottomOptions[0].type).assertEqual(Constant.OPERATION_TYPE.DESELECT_ALL);
    })

    it('getSelectBottomOptionsFalseText', 0, () => {
      let isSelectAll = false;
      let filePickBottomOptions = getFilePickBottomOptions(isSelectAll);
      expect(filePickBottomOptions[0].type).assertEqual(Constant.OPERATION_TYPE.SELECT_ALL);
    })
  })
}