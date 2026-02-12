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
import { DFX, FileOperation, UEUtil, VirtualUri } from '@ohos/common';
import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { TestUtil } from '../../utils/TestUtil';

export default function FileOperationTest() {
  describe('FileOperationTest', () => {
    it('openFileByOtherApp_DOCUMENT_URI', 0, () => {
      let fileUri: string = VirtualUri.DOCUMENT + '/test.pdf';
      let fileName: string = 'test.pdf';
      let mocker = new MockKit();
      let mockFunc = mocker.mockFunc(UEUtil, UEUtil.reportOpenFile);
      when(mockFunc)(ArgumentMatchers.any).afterReturnNothing();
      FileOperation.openFileByOtherApp(fileUri, fileName);
      mocker.clear(UEUtil);
      mocker.verify('reportOpenFile', [DFX.FileOpenMode.OPEN_BY_OTHER_APP, 'PDF']).times(1);
    })

    it('deleteFileAndRecover_delete', 0, async () => {
      let fileName: string = Date.now().toString() + '.pdf';
      TestUtil.createTestFileOrFolder([fileName], false);
      let fileUri: string = TestUtil.TEST_FOLDER_URI + '/' + fileName;
      let result: string = await FileOperation.deleteFileToTrash(fileUri);
      let recycleUri: string = 'file://docs/storage/Users/currentUser/.Trash/' + fileName;
      expect(result).assertEqual(recycleUri);
    })

    it('deleteFileAndRecover_recover', 0, async () => {
      let fileName: string = Date.now().toString() + '.pdf';
      TestUtil.createTestFileOrFolder([fileName], false);
      let fileUri: string = TestUtil.TEST_FOLDER_URI + '/' + fileName;
      await FileOperation.deleteFileToTrash(fileUri);
      let recycleUri: string = 'file://docs/storage/Users/currentUser/.Trash/' + fileName;
      let result: string = await FileOperation.recover(recycleUri);
      expect(result).assertEqual(fileUri);
    })

    it('quickView_local_file', 0, () => {
      let fileName: string = Date.now().toString() + '.pdf';
      TestUtil.createTestFileOrFolder([fileName], false);
      let fileUri: string = TestUtil.TEST_FOLDER_URI + '/' + fileName;
      let result: boolean = FileOperation.quickView(fileUri);
      expect(result).assertTrue();
    })

    it('getTargetUri', 0, () => {
      let result: string = FileOperation.getTargetUri(TestUtil.TEST_FOLDER_URI);
      expect(result).assertEqual(TestUtil.TEST_FOLDER_URI);
      let fileName: string = Date.now().toString() + '.ppt';
      TestUtil.createTestFileOrFolder([fileName], false);
      result = FileOperation.getTargetUri(TestUtil.TEST_FOLDER_URI);
      expect(result).assertEqual(TestUtil.TEST_FOLDER_URI);
    })
  })
}