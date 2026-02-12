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
import { FileDataSource, FileInfo, GroupDataSource, GroupFileInfo } from '@ohos/common';
import { describe, expect, it } from '@ohos/hypium';

export default function GroupDataSourceTest() {
  describe('GroupDataSourceTest', () => {
    it('handleTotalCount', 0, () => {
      let groupDataSource: GroupDataSource = new GroupDataSource();
      let groupFileInfos: GroupFileInfo[] = [];
      groupDataSource.setData(groupFileInfos);
      expect(groupDataSource.totalCount()).assertEqual(0);
    })

    it('handleTotalFileCount', 0, () => {
      let groupDataSource: GroupDataSource = new GroupDataSource();
      let groupFileInfos: GroupFileInfo[] = [];
      groupDataSource.setData(groupFileInfos);
      expect(groupDataSource.totalFileCount()).assertEqual(0);
    })

    it('handleGetData', 0, () => {
      let groupDataSource: GroupDataSource = new GroupDataSource();
      let fileDataSource: FileDataSource = new FileDataSource();
      let fileInfo: FileInfo = new FileInfo();
      fileInfo.fileName = 'testFileInfo';
      fileDataSource.setData([fileInfo]);
      let groupFileInfos: GroupFileInfo[] = [new GroupFileInfo('testGroupInfo', 0, fileDataSource)];
      groupDataSource.setData(groupFileInfos);
      expect(groupDataSource.getData(0).getFileDataSource().getDataArray()[0].fileName).assertEqual('testFileInfo');
    })

    it('handleGetAllData', 0, () => {
      let groupDataSource: GroupDataSource = new GroupDataSource();
      let fileDataSource: FileDataSource = new FileDataSource();
      let fileInfo: FileInfo = new FileInfo();
      fileInfo.fileName = 'testFileInfo';
      fileDataSource.setData([fileInfo]);
      let groupFileInfos: GroupFileInfo[] = [new GroupFileInfo('testGroupInfo', 0, fileDataSource)];
      groupDataSource.setData(groupFileInfos);
      expect(groupDataSource.getAllData().length).assertEqual(1);
    })

    it('handleGetIndexOfOriginalFileDataSource', 0, () => {
      let groupDataSource: GroupDataSource = new GroupDataSource();
      let fileDataSource: FileDataSource = new FileDataSource();
      let fileInfo1: FileInfo = new FileInfo();
      fileInfo1.fileName = 'testFileInfo';
      let fileInfo2: FileInfo = new FileInfo();
      fileInfo2.fileName = 'testFileInfo';
      fileDataSource.setData([fileInfo1, fileInfo2]);
      let groupFileInfos: GroupFileInfo[] = [new GroupFileInfo('testGroupInfo', 0, fileDataSource), new GroupFileInfo('testGroupInfo', 0, fileDataSource)];
      groupDataSource.setData(groupFileInfos);
      expect(groupDataSource.getIndexOfOriginalFileDataSource(1, 1)).assertEqual(3);
    })

    it('handleGetFileInfoInGroup', 0, () => {
      let groupDataSource: GroupDataSource = new GroupDataSource();
      let fileDataSource: FileDataSource = new FileDataSource();
      let fileInfo1: FileInfo = new FileInfo();
      fileInfo1.fileName = 'testFileInfo';
      let fileInfo2: FileInfo = new FileInfo();
      fileInfo2.fileName = 'testFileInfo';
      fileDataSource.setData([fileInfo1, fileInfo2]);
      let groupFileInfos: GroupFileInfo[] = [new GroupFileInfo('testGroupInfo', 0, fileDataSource), new GroupFileInfo('testGroupInfo', 0, fileDataSource)];
      groupDataSource.setData(groupFileInfos);
      fileInfo2.fileName = 'updatedTestFileInfo';
      groupDataSource.updateFileItemInGroup(0);
      groupDataSource.updateFileItemInGroup(1);
      expect(groupDataSource.getData(0).getFileDataSource().getDataArray()[1].fileName).assertEqual('updatedTestFileInfo');
    })

    it('handleGetFileInfoInGroup2', 0, () => {
      let groupDataSource: GroupDataSource = new GroupDataSource();
      let fileDataSource: FileDataSource = new FileDataSource();
      let fileInfo1: FileInfo = new FileInfo();
      fileInfo1.fileName = 'testFileInfo';
      let fileInfo2: FileInfo = new FileInfo();
      fileInfo2.fileName = 'testFileInfo';
      fileDataSource.setData([fileInfo1, fileInfo2]);
      let groupFileInfos: GroupFileInfo[] = [new GroupFileInfo('testGroupInfo', 0, fileDataSource), new GroupFileInfo('testGroupInfo', 0, fileDataSource)];
      groupDataSource.setData(groupFileInfos);
      fileInfo2.fileName = 'updatedTestFileInfo';
      groupDataSource.updateFileItemInGroup(-1);
      expect(groupDataSource.getData(0).getFileDataSource().getDataArray()[1].fileName).assertEqual('updatedTestFileInfo');
    })

  })
}