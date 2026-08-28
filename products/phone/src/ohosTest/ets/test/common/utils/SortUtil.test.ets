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
import { SortUtil, FileInfo, SortOrder } from  '@ohos/common';

export default function SortUtilTest() {
  describe("SortUtilTest", () => {
    it("getCollator", 0, () => {
      (SortUtil as object)['collator'] = undefined;
      SortUtil.getCollator();
      expect((SortUtil as object)['collator']).not().assertUndefined();
    })

    it("sortDataBySizeAscending", 0, () => {
      let param: FileInfo[] = getFileInfoList(true);
      const result: FileInfo[] = SortUtil.sortDataBySize(param);
      expect(result[0].fileName).assertEqual('folder1');
    });

    it("sortDataBySizeDescending", 0, () => {
      let param: FileInfo[] = getFileInfoList(true);
      const result: FileInfo[] = SortUtil.sortDataBySize(param, true);
      expect(result[0].fileName).assertEqual('file3.xlsx');
    });

    it("sortDataByTimeAscending", 0, () => {
      let param: FileInfo[] = getFileInfoList(false);
      const result: FileInfo[] = SortUtil.sortDataByTime(param);
      expect(result[0].fileName).assertEqual('file1.docx');
    });

    it("sortDataByTimeDescending", 0, () => {
      let param: FileInfo[] = getFileInfoList(false);
      const result: FileInfo[] = SortUtil.sortDataByTime(param, true);
      expect(result[0].fileName).assertEqual('file3.xlsx');
    });

    it("sortDataByTimeAscendingReverse", 0, () => {
      let param: FileInfo[] = getFileInfoList(false);
      const result: FileInfo[] = SortUtil.sortDataByTime(param, false, true);
      expect(result[0].fileName).assertEqual('file1.docx');
    });

    it("sortDataByTimeDescendingReverse", 0, () => {
      let param: FileInfo[] = getFileInfoList(false);
      const result: FileInfo[] = SortUtil.sortDataByTime(param, true, true);
      expect(result[0].fileName).assertEqual('file3.xlsx');
    });

    it("sortDataByTimeAscendingNoReverse", 0, () => {
      let param: FileInfo[] = getFileInfoList(false);
      const result: FileInfo[] = SortUtil.sortDataByTime(param, false, false, true);
      expect(result[0].fileName).assertEqual('file1.docx');
    });

    it("sortDataByTimeDescendingNoReverse", 0, () => {
      let param: FileInfo[] = getFileInfoList(false);
      const result: FileInfo[] = SortUtil.sortDataByTime(param, true, false, true);
      expect(result[0].fileName).assertEqual('file3.xlsx');
    });

    it("sortDataByTypeAscending", 0, () => {
      let param: FileInfo[] = getFileInfoList(true);
      const result: FileInfo[] = SortUtil.sortDataByType(param);
      expect(result[0].fileName).assertEqual('folder1');
      expect(result[2].fileName).assertEqual('file1.docx');
    });

    it("sortDataByTypeDescending", 0, () => {
      let param: FileInfo[] = getFileInfoList(true);
      const result: FileInfo[] = SortUtil.sortDataByType(param, true);
      expect(result[0].fileName).assertEqual('folder2');
      expect(result[2].fileName).assertEqual('file3.xlsx');
    });

    it("sortDataByNameAscending", 0, () => {
      let param: FileInfo[] = getFileInfoList(false);
      const result: FileInfo[] = SortUtil.sortDataByName(param);
      expect(result[0].fileName).assertEqual('file1.docx');
    });

    it("sortDataByNameDescending", 0, () => {
      let param: FileInfo[] = getFileInfoList(false);
      const result: FileInfo[] = SortUtil.sortDataByName(param, true);
      expect(result[0].fileName).assertEqual('file3.xlsx');
    });

    it("sortDataByOrderSize", 0, () => {
      let param: FileInfo[] = getFileInfoList(false);
      const result: FileInfo[] = SortUtil.sortDataByOrder(param, SortOrder.SIZE);
      expect(result[0].fileName).assertEqual('file2.xlsx');
    });

    it("sortDataByOrderTime", 0, () => {
      let param: FileInfo[] = getFileInfoList(false);
      const result: FileInfo[] = SortUtil.sortDataByOrder(param, SortOrder.TIME);
      expect(result[0].fileName).assertEqual('file2.xlsx');
    });

    it("sortDataByOrderType", 0, () => {
      let param: FileInfo[] = getFileInfoList(false);
      const result: FileInfo[] = SortUtil.sortDataByOrder(param, SortOrder.TYPE);
      expect(result[0].fileName).assertEqual('file2.xlsx');
    });

    it("sortDataByOrderName", 0, () => {
      let param: FileInfo[] = getFileInfoList(false);
      const result: FileInfo[] = SortUtil.sortDataByOrder(param, SortOrder.NAME);
      expect(result[0].fileName).assertEqual('file2.xlsx');
    });
  });
}

function getFileInfoList(hasFolder: boolean): FileInfo[] {
  let file1 = new FileInfo();
  file1.isFolder = false;
  file1.fileName = 'file1.docx';
  file1.recentTime = 1;
  file1.deleteTime = 1;
  file1.mtime = 1;
  file1.ctime = 1000;
  file1.size = 10;
  let file2 = new FileInfo();
  file2.isFolder = false;
  file2.fileName = 'file2.xlsx';
  file2.recentTime = 2;
  file2.deleteTime = 2;
  file2.mtime = 2;
  file2.ctime = 2000;
  file2.size = 12;
  file2.uri = ''
  let file3 = new FileInfo();
  file3.isFolder = false;
  file3.fileName = 'file3.xlsx';
  file3.recentTime = 2;
  file3.deleteTime = 2;
  file3.mtime = 2;
  file3.ctime = 3000;
  file3.size = 12;
  let folder1 = new FileInfo();
  folder1.isFolder = true;
  folder1.fileName = 'folder1';
  folder1.size = 12;
  let folder2 = new FileInfo();
  folder2.isFolder = true;
  folder2.fileName = 'folder2';
  folder2.size = 14;
  let param: FileInfo[] = hasFolder ? [file1, file2, file3, folder1, folder2] : [file1, file2, file3];
  return param;
}