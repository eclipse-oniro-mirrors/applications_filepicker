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
import { FileGroupDataSource, FileInfo, FileOrGroup, FileOrGroupInfo } from '@ohos/common';
import { describe, expect, it } from '@ohos/hypium';

export default function FileGroupDataSourceTest() {
  describe('FileGroupDataSourceTest', () => {
    it('FileGroupDataSourceTest_totalCount', 0, () => {
      let dataSource: FileGroupDataSource = new FileGroupDataSource();
      expect(dataSource.totalCount()).assertEqual(0);
    });

    it('setData', 0, () => {
      let dataSource: FileGroupDataSource = new FileGroupDataSource();
      let fileOrGroupInfo: FileOrGroupInfo = new FileOrGroupInfo();
      fileOrGroupInfo.fileOrGroups = [new FileOrGroup(true, 0, new FileInfo(), false, 333, 1)];
      dataSource.setData(fileOrGroupInfo);
      expect(dataSource.getData(0).groupName).assertEqual(333);
    });

    it('getIndexOfOriginalFileDataSource1_Test', 0, () => {
      let fileGroupDataSource: FileGroupDataSource = new FileGroupDataSource();
      fileGroupDataSource.groupIndexs = [1, 2, 3, 4];
      expect(fileGroupDataSource.getIndexOfOriginalFileDataSource(5)).assertEqual(1);
    });

    it('getIndexOfOriginalFileDataSource2_Test', 0, () => {
      let fileGroupDataSource: FileGroupDataSource = new FileGroupDataSource();
      fileGroupDataSource.groupIndexs = [1, 2, 3, 4];
      expect(fileGroupDataSource.getIndexOfOriginalFileDataSource(2)).assertEqual(1);
    });

    it('getIndexOfOriginalFileDataSource3_Test', 0, () => {
      let fileGroupDataSource: FileGroupDataSource = new FileGroupDataSource();
      expect(fileGroupDataSource.getIndexOfOriginalFileDataSource(-1)).assertEqual(-1);
    });

    it('getIndexOfOriFileDataSource1_Test', 0, () => {
      let dataSource: FileGroupDataSource = new FileGroupDataSource();
      let fileOrGroupInfo: FileOrGroupInfo = new FileOrGroupInfo();
      fileOrGroupInfo.fileOrGroups = [
        new FileOrGroup(true, 0, new FileInfo(), false, 3, 1),
        new FileOrGroup(false, 0, new FileInfo(), false, 4, 1),
        new FileOrGroup(false, 0, new FileInfo(), false, 5, 1)
      ];
      fileOrGroupInfo.fileOrGroups[2].showMode = 1
      dataSource.setData(fileOrGroupInfo);
      expect(dataSource.getIndexOfOriFileDataSource(1, 0)).assertEqual(0);
    });

    it('getIndexOfOriFileDataSource2_Test', 0, () => {
      let dataSource: FileGroupDataSource = new FileGroupDataSource();
      let fileOrGroupInfo: FileOrGroupInfo = new FileOrGroupInfo();
      fileOrGroupInfo.fileOrGroups = [
        new FileOrGroup(true, 0, new FileInfo(), false, 3, 1),
        new FileOrGroup(false, 0, new FileInfo(), false, 4, 1),
        new FileOrGroup(false, 0, new FileInfo(), false, 5, 1)
      ];
      fileOrGroupInfo.fileOrGroups[2].showMode = 1
      dataSource.setData(fileOrGroupInfo);
      fileOrGroupInfo.fileOrGroups[1].showMode = 1
      expect(dataSource.getIndexOfOriFileDataSource(2, 10)).assertEqual(-1);
    });

    it('getIndexOfOriFileDataSource3_Test', 0, () => {
      let dataSource: FileGroupDataSource = new FileGroupDataSource();
      let fileOrGroupInfo: FileOrGroupInfo = new FileOrGroupInfo();
      fileOrGroupInfo.fileOrGroups = [
        new FileOrGroup(true, 0, new FileInfo(), false, 3, 1),
        new FileOrGroup(false, 0, new FileInfo(), false, 4, 1),
        new FileOrGroup(false, 0, new FileInfo(), false, 5, 1)
      ];
      fileOrGroupInfo.fileOrGroups[2].showMode = 1
      dataSource.setData(fileOrGroupInfo);
      fileOrGroupInfo.fileOrGroups[1].showMode = 1
      expect(dataSource.getIndexOfOriFileDataSource(2, 10)).assertEqual(-1);
    });

    it('updateFileItemInGroup', 0, () => {
      let dataSource: FileGroupDataSource = new FileGroupDataSource();
      let fileOrGroupInfo: FileOrGroupInfo = new FileOrGroupInfo();
      fileOrGroupInfo.fileOrGroups = [
        new FileOrGroup(true, 0, new FileInfo(), false, 3, 1),
        new FileOrGroup(false, 0, new FileInfo(), false, 4, 1),
        new FileOrGroup(false, 0, new FileInfo(), false, 5, 1)
      ];
      fileOrGroupInfo.fileOrGroups[1].fileList = [];
      let file1: FileInfo = new FileInfo();
      file1.uri = '123';
      fileOrGroupInfo.fileOrGroups[2].fileList = [file1];
      dataSource.setData(fileOrGroupInfo);
      dataSource.updateFileItemInGroup('123');
      dataSource.updateFileItemInGroup('456');
      expect(dataSource.getDataArray().length).assertEqual(3);
    });

    it('getSharedGroupName1_Test', 0, () => {
      let dataSource: FileGroupDataSource = new FileGroupDataSource();
      let fileOrGroupInfo: FileOrGroupInfo = new FileOrGroupInfo();
      fileOrGroupInfo.fileOrGroups = [new FileOrGroup(true, 0, new FileInfo(), false, 3, 1)];
      fileOrGroupInfo.groupIndexs = [0];
      dataSource.setData(fileOrGroupInfo);
      expect(dataSource.getSharedGroupName(0)).assertEqual('');
    });

    it('getSharedGroupName2_Test', 0, () => {
      let dataSource: FileGroupDataSource = new FileGroupDataSource();
      let fileOrGroupInfo: FileOrGroupInfo = new FileOrGroupInfo();
      fileOrGroupInfo.fileOrGroups = [new FileOrGroup(true, 0, new FileInfo(), false, 3, 1)];
      fileOrGroupInfo.groupIndexs = [0];
      dataSource.setData(fileOrGroupInfo);

      fileOrGroupInfo.fileOrGroups.push(new FileOrGroup(false, 0, new FileInfo(), false, 4, 1));
      fileOrGroupInfo.fileOrGroups.push(new FileOrGroup(false, 0, new FileInfo(), false, 5, 1));
      fileOrGroupInfo.groupIndexs = [0, 1, 2];
      dataSource.setData(fileOrGroupInfo);
      expect(dataSource.getSharedGroupName(0)).assertEqual('');
    });

    it('getSharedGroupName3_Test', 0, () => {
      let dataSource: FileGroupDataSource = new FileGroupDataSource();
      let fileOrGroupInfo: FileOrGroupInfo = new FileOrGroupInfo();
      fileOrGroupInfo.fileOrGroups = [new FileOrGroup(true, 0, new FileInfo(), false, 3, 1)];
      fileOrGroupInfo.groupIndexs = [0];
      dataSource.setData(fileOrGroupInfo);

      fileOrGroupInfo.fileOrGroups.push(new FileOrGroup(false, 0, new FileInfo(), false, 4, 1));
      fileOrGroupInfo.fileOrGroups.push(new FileOrGroup(false, 0, new FileInfo(), false, 5, 1));
      fileOrGroupInfo.groupIndexs = [0, 1, 2];
      dataSource.setData(fileOrGroupInfo);
      expect(dataSource.getSharedGroupName(5)).assertEqual('');
    });
  })
}