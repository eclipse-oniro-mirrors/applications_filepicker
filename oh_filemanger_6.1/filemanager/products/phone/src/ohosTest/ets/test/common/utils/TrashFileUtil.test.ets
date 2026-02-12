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
import { TrashFileUtil, FileInfo, DiskInfo,StringUtil } from '@ohos/common';
import { ArgumentMatchers, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';

export default function TrashFileUtilTest() {
  beforeEach(() => {

  })
  describe('TrashFileUtilTest', () => {
    let mocker: MockKit = new MockKit();
    it('getTrashFileCount', 0, () => {
      mocker.mockFunc(TrashFileUtil, TrashFileUtil.getTrashFileListByTask);
      TrashFileUtil.getTrashFileCount();
      mocker.ignoreMock(TrashFileUtil, TrashFileUtil.getTrashFileListByTask);
      mocker.clear(TrashFileUtil);
      mocker.verify('getTrashFileListByTask',[]).once();
    });

    it('addTrashFileCount', 0, () => {
      AppStorage.setOrCreate<number>(TrashFileUtil.TRASH_FILE_COUNT, 2);
      TrashFileUtil.addTrashFileCount(1);
      const result = AppStorage.get<number>(TrashFileUtil.TRASH_FILE_COUNT);
      expect(result).assertEqual(3);
      AppStorage.delete(TrashFileUtil.TRASH_FILE_COUNT);
    });

    it('reduceTrashFileCount', 0, () => {
      AppStorage.delete(TrashFileUtil.TRASH_FILE_COUNT);
      TrashFileUtil.addTrashFileCount(1);
      const resultBefore = AppStorage.get<number>(TrashFileUtil.TRASH_FILE_COUNT);
      expect(resultBefore).assertUndefined();
      AppStorage.setOrCreate<number>(TrashFileUtil.TRASH_FILE_COUNT, 2);
      TrashFileUtil.reduceTrashFileCount(1);
      const result = AppStorage.get<number>(TrashFileUtil.TRASH_FILE_COUNT);
      expect(result).assertEqual(1);
      AppStorage.delete(TrashFileUtil.TRASH_FILE_COUNT);
    })

    it('translateToFileData', 0, () => {
      let trashFileList: FileInfo[] = [];
      for (let i = 0; i < 3; i++) {
        let file = new FileInfo();
        file.srcPath = `file://com.ohos.fimanager/${i}.jpg`;
        file.isFolder = i > 1;
        trashFileList.push(file);
      }
      const diskInfo1 = new DiskInfo();
      diskInfo1.relativePath = 'file://';
      const diskInfo2 = new DiskInfo();
      let result = TrashFileUtil.translateToFileData(trashFileList, [diskInfo2, diskInfo1]);
      expect(result.length).assertEqual(3);
    })

    it('recoverTrashFile', 0, () => {
      let isEmpty = mocker.mockFunc(StringUtil,StringUtil.isEmpty);
      when(isEmpty)(ArgumentMatchers.any).afterReturn(true);
      let uri = '';
      TrashFileUtil.recoverTrashFile(uri);
      mocker.clear(StringUtil);
      mocker.verify('isEmpty',['']).once();
    })
  })
}