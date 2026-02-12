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
import { DuplicateFilesDataSource, DuplicateFilesInfo, DuplicateFileType } from '@ohos/common';

export default function DuplicateFilesDataSourceTest() {
  describe('DuplicateFilesDataSourceTest', () => {
    it('DuplicateFilesDataSourceTest_totalCount', 0, () => {
      const temp = new DuplicateFilesDataSource();
      expect(temp.totalCount()).assertEqual(0);
    })

    it('DuplicateFilesDataSourceTest_get_and_setData', 0, () => {
      const temp = new DuplicateFilesDataSource();
      let duplicateFile1: DuplicateFilesInfo = new DuplicateFilesInfo();
      duplicateFile1.fileType = DuplicateFileType.IMAGE;
      let duplicateFile2: DuplicateFilesInfo = new DuplicateFilesInfo();
      duplicateFile2.fileType = DuplicateFileType.VIDEO;
      let duplicateFileArray: DuplicateFilesInfo[] = [duplicateFile1, duplicateFile2];
      temp.setData(duplicateFileArray);
      expect(temp.totalCount()).assertEqual(2);
      expect(temp.getData(0).fileType).assertEqual(DuplicateFileType.IMAGE);
      expect(temp.getData(1).fileType).assertEqual(DuplicateFileType.VIDEO);
    })

    it('DuplicateFilesDataSourceTest_getDataArray', 0, () => {
      const temp = new DuplicateFilesDataSource();
      let duplicateFileArray: DuplicateFilesInfo[] = temp.getDataArray();
      expect(duplicateFileArray.length).assertEqual(0);
    })

    it('DuplicateFilesDataSourceTest_selectAll', 0, () => {
      const temp = new DuplicateFilesDataSource();
      let duplicateFile: DuplicateFilesInfo = new DuplicateFilesInfo();
      duplicateFile.isChecked = false;
      duplicateFile.checkNums = 1;
      let duplicateFileArray: DuplicateFilesInfo[] = [duplicateFile];
      temp.setData(duplicateFileArray);
      expect(temp.totalCount()).assertEqual(1);
      temp.selectAll(true);
      expect(temp.getData(0).isChecked).assertEqual(true);
      expect(temp.getData(0).checkNums).assertEqual(0);
    })

    it('DuplicateFilesDataSourceTest_getAllFileSize', 0, () => {
      const temp = new DuplicateFilesDataSource();
      let duplicateFile1: DuplicateFilesInfo = new DuplicateFilesInfo();
      duplicateFile1.totalSize = 11;
      let duplicateFile2: DuplicateFilesInfo = new DuplicateFilesInfo();
      duplicateFile2.totalSize = 22;
      let duplicateFileArray: DuplicateFilesInfo[] = [duplicateFile1, duplicateFile2];
      temp.setData(duplicateFileArray);
      expect(temp.totalCount()).assertEqual(2);
      expect(temp.getAllFileSize()).assertEqual(duplicateFile1.totalSize + duplicateFile2.totalSize);
    })

    it('DuplicateFilesDataSourceTest_getDuplicateTypeExpandState', 0, () => {
      const temp = new DuplicateFilesDataSource();
      let duplicateFile: DuplicateFilesInfo = new DuplicateFilesInfo();
      duplicateFile.fileType = DuplicateFileType.IMAGE;
      duplicateFile.isExpand = true;
      temp.setData([duplicateFile]);
      expect(temp.totalCount()).assertEqual(1);
      expect(temp.getDuplicateTypeExpandState().get(DuplicateFileType.IMAGE)).assertEqual(duplicateFile.isExpand);
    })
  })
}