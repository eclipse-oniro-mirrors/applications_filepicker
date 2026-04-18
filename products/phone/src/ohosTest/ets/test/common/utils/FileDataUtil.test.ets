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

import { FileDataUtil, FileInfo, LocationType } from "@ohos/common";
import { describe, expect, it } from "@ohos/hypium";

export default function FileDataUtilTest() {
  describe('FileDataUtilTest', () => {
    it('setFileName_fileInfoUndefined', 0, async (done: Function) => {
      let fileInfo: FileInfo | undefined = new FileInfo();
      fileInfo = undefined;
      FileDataUtil.setFileName(fileInfo!!, 'test');
      expect(fileInfo).assertUndefined();
      done();
    });

    it('setFileName_fileInfoFolder', 0, async (done: Function) => {
      let fileInfo: FileInfo = new FileInfo();
      fileInfo.isFolder = true;
      FileDataUtil.setFileName(fileInfo, 'test');
      expect(fileInfo.fileName === 'test').assertTrue();
      done();
    });

    it('setFileName_fileInfoFileUpdateName', 0, async (done: Function) => {
      let fileInfo: FileInfo = new FileInfo();
      fileInfo.fileName = 'test.txt';
      fileInfo.isFolder = false;
      FileDataUtil.setFileName(fileInfo, 'new_test.txt');
      expect(fileInfo.fileName === 'new_test.txt').assertTrue();
      done();
    });

    it('setFileName_fileInfoFileUpdateNameAndThumbUri', 0, async (done: Function) => {
      let fileInfo: FileInfo = new FileInfo();
      fileInfo.fileName = 'test.txt';
      fileInfo.isFolder = false;
      fileInfo.uri = 'file://my_phone/test.txt';
      FileDataUtil.setFileName(fileInfo, 'new_test.jpg');
      expect(fileInfo.fileName === 'new_test.jpg').assertTrue();
      expect(fileInfo.thumbUri === fileInfo.uri).assertTrue();
      done();
    });

    it('setFileName_fileInfoFileUpdateNameThumbUriEmpty', 0, async (done: Function) => {
      let fileInfo: FileInfo = new FileInfo();
      fileInfo.fileName = 'test.txt';
      fileInfo.isFolder = false;
      FileDataUtil.setFileName(fileInfo, 'new_test.doc');
      expect(fileInfo.fileName === 'new_test.doc').assertTrue();
      done();
    });

    it('setFileName_fileInfoThumbUriEmpty', 0, async (done: Function) => {
      let fileInfo: FileInfo = new FileInfo();
      fileInfo.fileName = 'test.txt';
      fileInfo.isFolder = false;
      FileDataUtil.setFileName(fileInfo, 'new_test.doc');
      expect(fileInfo.thumbUri === '').assertTrue();
      done();
    });
  });
}