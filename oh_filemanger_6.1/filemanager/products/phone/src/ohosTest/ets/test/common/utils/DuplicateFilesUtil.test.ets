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
import { describe, it, expect } from '@ohos/hypium'
import lazy { DuplicateFileUtil, index_insert_napi } from '@ohos/common/indexLazyLoad';
import {
  DuplicateFilesInfo,
  DuplicateFileType,
  FileInfo,
  FileOrGroup,
  FileOrGroupInfo
} from '@ohos/common';
import { TestUtil } from '../../utils/TestUtil';

export default function DuplicateFilesUtilTest() {
  describe('DuplicateFilesUtilTest', () => {

    it('convertingSourceDataToUiData', 0, () => {
      let fileInfos :FileInfo[] = [];
      let fileInfo1 = new FileInfo();
      fileInfo1.duplicateFileType = DuplicateFileType.OTHER;
      fileInfo1.fileSuffix = 'log';
      fileInfo1.duplicateFileHash = 'duplicateHash';
      fileInfos.push(fileInfo1);
      let fileInfo2 = new FileInfo();
      fileInfo2.duplicateFileType = DuplicateFileType.OTHER;
      fileInfo2.fileSuffix = 'log';
      fileInfo2.duplicateFileHash = 'duplicateHash';
      fileInfos.push(fileInfo2);
      let duplicateFilesInfo =
        DuplicateFileUtil.convertingSourceDataToUiData(fileInfos, 3, new Map<DuplicateFileType, boolean>(), false);
      expect(duplicateFilesInfo.length).assertEqual(1);
    })

    it('getGroupTypeCheckedState', 0, () => {
      let duplicateFilesInfo: DuplicateFilesInfo = new DuplicateFilesInfo();
      let fileOrGroupInfo: FileOrGroupInfo = new FileOrGroupInfo();
      let fileInfo: FileInfo = new FileInfo();
      let fileOrGroup = new FileOrGroup(true, 0, fileInfo, false, 333, 1);
      fileInfo.isChecked = true;
      fileOrGroupInfo.fileOrGroups = [fileOrGroup];
      duplicateFilesInfo.fileOrGroupSource.setData(fileOrGroupInfo);
      let groupCheckState = DuplicateFileUtil.getGroupTypeCheckedState(false, duplicateFilesInfo);
      expect(groupCheckState).assertEqual(true);
      fileOrGroup.indexInGroup = 1;
      fileInfo.isChecked = false;
      groupCheckState = DuplicateFileUtil.getGroupTypeCheckedState(false, duplicateFilesInfo);
      expect(groupCheckState).assertEqual(false);
      fileOrGroup.fileList.push(fileInfo);
      groupCheckState = DuplicateFileUtil.getGroupTypeCheckedState(true, duplicateFilesInfo);
      expect(groupCheckState).assertEqual(false);
      fileInfo.isChecked = true;
      groupCheckState = DuplicateFileUtil.getGroupTypeCheckedState(true, duplicateFilesInfo);
      expect(groupCheckState).assertEqual(true);
    })

    it('updateSingleFileSelectChange', 0, () => {
      TestUtil.setPrivateAttribute(DuplicateFileUtil, 'isDuplicateScanning', true);
      let duplicateFilesInfo: DuplicateFilesInfo = new DuplicateFilesInfo();
      duplicateFilesInfo.checkNums = 5;
      DuplicateFileUtil.updateSingleFileSelectChange(true, 0, duplicateFilesInfo);
      expect(duplicateFilesInfo.checkNums).assertEqual(6);
      DuplicateFileUtil.updateSingleFileSelectChange(false, 0, duplicateFilesInfo);
      expect(duplicateFilesInfo.checkNums).assertEqual(5);
    })

    it('stopDuplicateFileScan', 0, () => {
      TestUtil.setPrivateAttribute(DuplicateFileUtil, 'isDuplicateScanning', true);
      DuplicateFileUtil.stopDuplicateFileScan();
      let scanState = TestUtil.getPrivateAttribute<boolean>(DuplicateFileUtil, 'isDuplicateScanning');
      expect(scanState).assertEqual(false);
    })
  })
}