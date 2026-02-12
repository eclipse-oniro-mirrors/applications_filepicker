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
import { describe, it, expect } from '@ohos/hypium';
import { PrintUtil } from '@ohos/common/src/main/ets/utils/PrintUtil';
import { FileInfo } from '@ohos/common';

export default function PrintUtilTest() {

  describe('PrintUtilTest', () => {

    it('PrintUtil.printCondition_pdf', 0, () => {
      expect(PrintUtil.printCondition('.pdf')).assertTrue();
    });

    it('PrintUtil.printCondition_docx', 0, () => {
      expect(PrintUtil.printCondition('.docx')).assertTrue();
    });

    it('PrintUtil.printCondition_jpg', 0, () => {
      expect(PrintUtil.printCondition('.jpg')).assertTrue();
    });

    it('PrintUtil.printCondition_mp3', 0, () => {
      expect(PrintUtil.printCondition('.mp3')).assertFalse();
    });

    it('PrintUtil.printCondition_exe', 0, () => {
      expect(PrintUtil.printCondition('.exe')).assertFalse();
    });

    it('PrintUtil.canPrint_pdfUri_true', 0, () => {
      const pdfFileInfo: FileInfo = new FileInfo();
      pdfFileInfo.fileName = 'test';
      pdfFileInfo.uri = 'file://test.pdf';
      expect(PrintUtil.canPrint([pdfFileInfo.uri], pdfFileInfo, true)).assertTrue();
    });

    it('PrintUtil.canPrint_pdfUri_false', 0, () => {
      const pdfFileInfo: FileInfo = new FileInfo();
      pdfFileInfo.fileName = 'test';
      pdfFileInfo.uri = 'file://test.pdf';
      expect(PrintUtil.canPrint([pdfFileInfo.uri], pdfFileInfo, false)).assertTrue();
    });

    it('PrintUtil.canPrint_twoPdfUris_false', 0, () => {
      const pdfFileInfo: FileInfo = new FileInfo();
      pdfFileInfo.fileName = 'test';
      pdfFileInfo.uri = 'file://test.pdf';
      expect(PrintUtil.canPrint([pdfFileInfo.uri, pdfFileInfo.uri], pdfFileInfo, false)).assertTrue();
    });

    it('PrintUtil.canPrint_twoPdfUris_true', 0, () => {
      const pdfFileInfo: FileInfo = new FileInfo();
      pdfFileInfo.fileName = 'test';
      pdfFileInfo.uri = 'file://test.pdf';
      expect(PrintUtil.canPrint([pdfFileInfo.uri, pdfFileInfo.uri], pdfFileInfo, true)).assertTrue();
    });

    it('PrintUtil.canPrint_pdfAndMp3Uris_false', 0, () => {
      const pdfFileInfo: FileInfo = new FileInfo();
      pdfFileInfo.fileName = 'test';
      pdfFileInfo.uri = 'file://test.pdf';
      const mp3FileInfo: FileInfo = new FileInfo();
      mp3FileInfo.fileName = 'test2';
      mp3FileInfo.uri = 'file://test2.mp3';
      expect(PrintUtil.canPrint([pdfFileInfo.uri, mp3FileInfo.uri], pdfFileInfo, false)).assertTrue();
    });

    it('PrintUtil.canPrint_pdfAndMp3Uris_true', 0, () => {
      const pdfFileInfo: FileInfo = new FileInfo();
      pdfFileInfo.fileName = 'test';
      pdfFileInfo.uri = 'file://test.pdf';
      const mp3FileInfo: FileInfo = new FileInfo();
      mp3FileInfo.fileName = 'test2';
      mp3FileInfo.uri = 'file://test2.mp3';
      expect(PrintUtil.canPrint([pdfFileInfo.uri, mp3FileInfo.uri], pdfFileInfo, true)).assertTrue();
    });

    it('PrintUtil.canPrint_mp3Uri_true', 0, () => {
      const mp3FileInfo: FileInfo = new FileInfo();
      mp3FileInfo.fileName = 'test2';
      mp3FileInfo.uri = 'file://test2.mp3';
      expect(PrintUtil.canPrint([mp3FileInfo.uri], mp3FileInfo, true)).assertFalse();
    });

    it('PrintUtil.canPrint_mp3Uri_false', 0, () => {
      const mp3FileInfo: FileInfo = new FileInfo();
      mp3FileInfo.fileName = 'test2';
      mp3FileInfo.uri = 'file://test2.mp3';
      expect(PrintUtil.canPrint([mp3FileInfo.uri], mp3FileInfo, false)).assertFalse();
    });

    it('PrintUtil.canPrint_twoMp3Uris_true', 0, () => {
      const mp3FileInfo: FileInfo = new FileInfo();
      mp3FileInfo.fileName = 'test2';
      mp3FileInfo.uri = 'file://test2.mp3';
      expect(PrintUtil.canPrint([mp3FileInfo.uri, mp3FileInfo.uri], mp3FileInfo, true)).assertFalse();
    });
  });
}
