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
import { ArgumentMatchers, beforeAll, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { PreviewUtil } from '@ohos/common/src/main/ets/utils/PreviewUtil';
import { FileInfo, FileMimeTypeUtil, FileUtil, HiLog, MimeType } from '@ohos/common';
import { FileOperation } from '@ohos/common/src/main/ets/fileoperate/FileOperation';
import { PREVIEW_TYPE } from '@ohos/common/src/main/ets/const/Constant';

const TAG = 'FilePreviewUtilTest';

export default function FilePreviewUtilTest() {
  describe("FilePreviewUtilTest", () => {
    let fileList: FileInfo[];

    beforeAll(() => {
      let file1: FileInfo = new FileInfo();
      file1.mimeTypeObj = new MimeType('DOCX', 1, 1, 'test', 'test');
      file1.isFolder = false;
      file1.fileName = 'test.docx';
      file1.uri = 'uri1';
      let file2: FileInfo = new FileInfo();
      file2.mimeTypeObj = new MimeType('TEST', 1, 1, 'test', 'test');
      file2.isFolder = false;
      file2.fileName = 'test.xlsx';
      file2.uri = 'uri2';
      let file3: FileInfo = new FileInfo();
      file3.mimeTypeObj = new MimeType('XLSX', 1, 1, 'test', 'test');
      file3.isFolder = false;
      file3.fileName = 'test.link';
      file3.uri = 'uri3';
      fileList = [file1, file2, file3];
    })

    it("filePreview_quickView", 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockerFunc: Function = mocker.mockFunc(FileOperation, FileOperation.quickView);
      when(mockerFunc)(ArgumentMatchers.any).afterReturn(true);
      let file: FileInfo = new FileInfo();
      file.uri = 'file://docs/storage/Users/currentUser/Documents/test.pdf';
      file.fileName = 'test.pdf';
      if (!FileUtil.isExistByUriWithFs(file.uri)) {
        FileUtil.createFile('file://docs/storage/Users/currentUser/Documents', file.fileName);
      }
      try {
        await PreviewUtil.filePreview(file, PREVIEW_TYPE.PREVIEW_BY_API, false);
      } catch (error) {
        HiLog.info(TAG, `TEST_0429 error${JSON.stringify(error)}`);
      }
      mocker.clear(FileOperation);
      mocker.verify('quickView', [file.uri, file.fileName]).once();
      done();
    })

    it("filePreview_open_by_other_app", 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockerFunc: Function = mocker.mockFunc(FileOperation, FileOperation.openFileByOtherApp);
      when(mockerFunc)(ArgumentMatchers.any).afterThrow('openFileByOtherApp');
      try {
        await PreviewUtil.filePreview(new FileInfo(), PREVIEW_TYPE.PREVIEW_BY_APP)
      } catch (e) {
        expect(e).assertEqual('openFileByOtherApp');
      } finally {
        mocker.clear(FileOperation);
      }
      done();
    })
  })
}