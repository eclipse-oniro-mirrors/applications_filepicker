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
import { OperateFileResult } from '@ohos/common/src/main/ets/const/ErrorCode';
import { RenameUtil, FileInfo } from '@ohos/common';
import { describe, expect, it } from '@ohos/hypium'

export default function RenameUtilTest() {
  describe('RenameUtilTest', () => {
    it('renameFileNameCheck_01_fileName', 0, () => {
      const fileInfo = new FileInfo();
      fileInfo.fileName = 'testFile.docx';
      let result = RenameUtil.renameFileNameCheck('', fileInfo);
      expect(result).assertEqual(OperateFileResult.EXIT_RENAME);
    })

    it('renameFileNameCheck_02_fileName', 0, () => {
      const fileInfo = new FileInfo();
      fileInfo.fileName = 'testFile.docx';
      let result = RenameUtil.renameFileNameCheck('    ', fileInfo);
      expect(result).assertEqual(OperateFileResult.ALL_IS_SPACE);
    })

    it('renameFileNameCheck_03_fileName', 0, () => {
      const fileInfo = new FileInfo();
      fileInfo.fileName = 'testFile.docx';
      let result = RenameUtil.renameFileNameCheck('.', fileInfo);
      expect(result).assertEqual(OperateFileResult.FILE_EXISTS);
    })

    it('renameFileNameCheck_04_fileName', 0, () => {
      const fileInfo = new FileInfo();
      fileInfo.fileName = 'testFile.docx';
      let result = RenameUtil.renameFileNameCheck('..', fileInfo);
      expect(result).assertEqual(OperateFileResult.FILE_EXISTS);
    })

    it('renameFileNameCheck_05_fileName', 0, () => {
      const fileInfo = new FileInfo();
      fileInfo.fileName = 'testFile.docx';
      let result = RenameUtil.renameFileNameCheck('tes[]?^.tFile.docx', fileInfo);
      expect(result).assertEqual(OperateFileResult.CONTAIN_SPECIAL_CHARACTER);
    })

    it('renameFileNameCheck_06_fileName', 0, () => {
      const fileInfo = new FileInfo();
      fileInfo.fileName = 'testFile.docx';
      let result = RenameUtil.renameFileNameCheck('testFile.docx', fileInfo);
      expect(result).assertEqual(OperateFileResult.EXIT_RENAME);
    })

    it('renameFileNameCheck_07_fileName', 0, () => {
      const fileInfo = new FileInfo();
      fileInfo.fileName = 'testFile.docx';
      let result = RenameUtil.renameFileNameCheck('.docx', fileInfo);
      expect(result).assertEqual(OperateFileResult.EXIT_RENAME);
    })

    it('renameFileNameCheck_09_fileName', 0, () => {
      const fileInfo = new FileInfo();
      fileInfo.fileName = 'testFile.docx';
      let result = RenameUtil.renameFileNameCheck('test[File.docx', fileInfo);
      expect(result).assertEqual(OperateFileResult.NORMAL_RESULT);
    })

    it('renameFileNameCheck_10_fileName', 0, () => {
      const fileInfo = new FileInfo();
      fileInfo.fileName = 'testFile.docx';
      let result = RenameUtil.renameFileNameCheck('testFile.doc', fileInfo);
      expect(result).assertEqual(OperateFileResult.FILE_EXTENSION_CHANGE);
    })

    it('renameFileNameCheck_11_fileName', 0, () => {
      const fileInfo = new FileInfo();
      fileInfo.fileName = 'testFile.docx';
      let result = RenameUtil.renameFileNameCheck('testFiles.docx', fileInfo);
      expect(result).assertEqual(OperateFileResult.NORMAL_RESULT);
    })

    it('rmUnExpectDot_01_inputText', 0, () => {
      let result = RenameUtil.rmUnExpectDot('testFile.docx');
      expect(result).assertEqual('testFile.docx');
    })

    it('rmUnExpectDot_02_inputText', 0, () => {
      let result = RenameUtil.rmUnExpectDot('testFiles.');
      expect(result).assertEqual('testFiles');
    })

    it('checkSameName_true', 0, () => {
      let result = RenameUtil.checkSameName('testFile.docx', 'testFile.docx');
      expect(result).assertTrue();
    })

    it('checkSameName_false', 0, () => {
      let result = RenameUtil.checkSameName('testFiles.docx', 'testFile.docx');
      expect(result).assertFalse();
    })

    it('checkOnlyExtension_01_folder', 0, () => {
      let result = RenameUtil.checkOnlyExtension('testFile.docx', false);
      expect(result).assertFalse();
    })

    it('checkOnlyExtension_02_fileName', 0, () => {
      let result = RenameUtil.checkOnlyExtension('testFile.docx');
      expect(result).assertFalse();
    })

    it('checkOnlyExtension_03_extension', 0, () => {
      let result = RenameUtil.checkOnlyExtension('.docx');
      expect(result).assertTrue();
    })

    it('getEscapedFileName_01_srcFileName', 0, () => {
      expect(RenameUtil.getEscapedFileName('test.docx')).assertEqual('test.docx');
    })

    it('getEscapedFileName_02_srcFileName', 0, () => {
      expect(RenameUtil.getEscapedFileName('test.123.docx')).assertEqual('test.123.docx');
    })

    it('getEscapedFileName_03_srcFileName', 0, () => {
      expect(RenameUtil.getEscapedFileName('test:123:456')).assertEqual('test_123_456');
    })

    it('getEscapedFileName_04_srcFileName', 0, () => {
      expect(RenameUtil.getEscapedFileName('test?123.docx')).assertEqual('test_123.docx');
    })

    it('getEscapedFolderName', 0, () => {
      expect(RenameUtil.getEscapedFolderName('test<123>')).assertEqual('test_123_');
    })

    it('checkSpecialChar_01_inputText', 0, () => {
      let result = RenameUtil.checkSpecialChar('');
      expect(result).assertTrue();
    })

    it('checkSpecialChar_02_inputText', 0, () => {
      let result = RenameUtil.checkSpecialChar('test[File');
      expect(result).assertFalse();
    })

    it('checkSpecialChar_03_inputText', 0, () => {
      let result = RenameUtil.checkSpecialChar('test]File');
      expect(result).assertFalse();
    })

    it('checkSpecialChar_04_inputText', 0, () => {
      let result = RenameUtil.checkSpecialChar('test\"File');
      expect(result).assertTrue();
    })

    it('checkSpecialChar_05_inputText', 0, () => {
      let result = RenameUtil.checkSpecialChar('test\'File');
      expect(result).assertFalse();
    })

    it('checkSpecialChar_06_inputText', 0, () => {
      let result = RenameUtil.checkSpecialChar('test:File');
      expect(result).assertTrue();
    })

    it('checkSpecialChar_07_inputText', 0, () => {
      let result = RenameUtil.checkSpecialChar('test/File');
      expect(result).assertTrue();
    })

    it('checkSpecialChar_08_inputText', 0, () => {
      let result = RenameUtil.checkSpecialChar('test*File');
      expect(result).assertTrue();
    })

    it('checkSpecialChar_09_inputText', 0, () => {
      let result = RenameUtil.checkSpecialChar('test*File');
      expect(result).assertTrue();
    })

    it('checkSpecialChar_10_inputText', 0, () => {
      let result = RenameUtil.checkSpecialChar('test?File');
      expect(result).assertTrue();
    })

    it('checkSpecialChar_11_inputText', 0, () => {
      let result = RenameUtil.checkSpecialChar('test<File');
      expect(result).assertTrue();
    })

    it('checkSpecialChar_12_inputText', 0, () => {
      let result = RenameUtil.checkSpecialChar('test>File');
      expect(result).assertTrue();
    })

    it('checkSpecialChar_13_inputText', 0, () => {
      let result = RenameUtil.checkSpecialChar('test|File');
      expect(result).assertTrue();
    })

    it('checkSpecialChar_14_inputText', 0, () => {
      let result = RenameUtil.checkSpecialChar('test`File');
      expect(result).assertFalse();
    })

    it('checkSpecialChar_15_inputText', 0, () => {
      let result = RenameUtil.checkSpecialChar('test{File');
      expect(result).assertFalse();
    })

    it('checkSpecialChar_16_inputText', 0, () => {
      let result = RenameUtil.checkSpecialChar('test}File');
      expect(result).assertFalse();
    })

    it('checkSpecialChar_17_inputText', 0, () => {
      let result = RenameUtil.checkSpecialChar('testFile');
      expect(result).assertFalse();
    })

    it('checkFileExtensionChange_01_inputText', 0, () => {
      const fileInfo = new FileInfo();
      fileInfo.fileName = 'testFile.docx';
      let result = RenameUtil.checkFileExtensionChange('testFile.doc', fileInfo);
      expect(result).assertTrue();
    })

    it('checkFileExtensionChange_02_inputText', 0, () => {
      const fileInfo = new FileInfo();
      fileInfo.fileName = 'testFile.docx';
      let result = RenameUtil.checkFileExtensionChange('testFile.docx', fileInfo);
      expect(result).assertFalse();
    })

    it('checkFileExtensionChange_03_inputText', 0, () => {
      const fileInfo = new FileInfo();
      fileInfo.fileName = 'testFile.docx';
      fileInfo.isFolder = true;
      let result = RenameUtil.checkFileExtensionChange('testFile.doc', fileInfo);
      expect(result).assertFalse();
    })

    it('isAllSpace_true', 0, () => {
      let inputText: string = '   ';
      expect(RenameUtil.isAllSpace(inputText)).assertTrue();
    })

    it('isAllSpace_false', 0, () => {
      let inputText: string = 'test';
      expect(RenameUtil.isAllSpace(inputText)).assertFalse();
    })

    it('isAllDots_true', 0, () => {
      let inputText: string = '..';
      expect(RenameUtil.isAllDots(inputText)).assertTrue();
    })

    it('isAllDots_false', 0, () => {
      let inputText: string = 'test';
      expect(RenameUtil.isAllSpace(inputText)).assertFalse();
    })

    it('isOneOrTwoDots_true', 0, () => {
      let inputText: string = '..';
      expect(RenameUtil.isOneOrTwoDots(inputText)).assertTrue();
    })

    it('isOneOrTwoDots_false', 0, () => {
      let inputText: string = 'test';
      expect(RenameUtil.isOneOrTwoDots(inputText)).assertFalse();
    })

    it('checkGallerySpecialChar_01_inputText', 0, () => {
      let result = RenameUtil.checkGallerySpecialChar('');
      expect(result).assertFalse();
    });

    it('checkGallerySpecialChar_02_inputText', 0, () => {
      let result = RenameUtil.checkGallerySpecialChar('test[File');
      expect(result).assertTrue();
    });

    it('checkGallerySpecialChar_03_inputText', 0, () => {
      let result = RenameUtil.checkGallerySpecialChar('test]File');
      expect(result).assertTrue();
    });

    it('checkGallerySpecialChar_04_inputText', 0, () => {
      let result = RenameUtil.checkGallerySpecialChar('test\"File');
      expect(result).assertTrue();
    });

    it('checkGallerySpecialChar_05_inputText', 0, () => {
      let result = RenameUtil.checkGallerySpecialChar('test\'File');
      expect(result).assertTrue();
    });

    it('ccheckGallerySpecialChar_06_inputText', 0, () => {
      let result = RenameUtil.checkGallerySpecialChar('test:File');
      expect(result).assertTrue();
    });

    it('checkGallerySpecialChar_07_inputText', 0, () => {
      let result = RenameUtil.checkGallerySpecialChar('test/File');
      expect(result).assertTrue();
    });

    it('checkGallerySpecialChar_08_inputText', 0, () => {
      let result = RenameUtil.checkGallerySpecialChar('test*File');
      expect(result).assertTrue();
    });

    it('checkGallerySpecialChar_09_inputText', 0, () => {
      let result = RenameUtil.checkGallerySpecialChar('test*File');
      expect(result).assertTrue();
    });

    it('checkGallerySpecialChar_10_inputText', 0, () => {
      let result = RenameUtil.checkGallerySpecialChar('test?File');
      expect(result).assertTrue();
    });

    it('checkGallerySpecialChar_11_inputText', 0, () => {
      let result = RenameUtil.checkGallerySpecialChar('test<File');
      expect(result).assertTrue();
    });

    it('checkGallerySpecialChar_12_inputText', 0, () => {
      let result = RenameUtil.checkGallerySpecialChar('test>File');
      expect(result).assertTrue();
    });

    it('checkGallerySpecialChar_13_inputText', 0, () => {
      let result = RenameUtil.checkGallerySpecialChar('test|File');
      expect(result).assertTrue();
    });

    it('checkGallerySpecialChar_14_inputText', 0, () => {
      let result = RenameUtil.checkGallerySpecialChar('test`File');
      expect(result).assertTrue();
    });

    it('checkGallerySpecialChar_15_inputText', 0, () => {
      let result = RenameUtil.checkGallerySpecialChar('test{File');
      expect(result).assertTrue();
    });

    it('checkGallerySpecialChar_16_inputText', 0, () => {
      let result = RenameUtil.checkGallerySpecialChar('test}File');
      expect(result).assertTrue();
    });

    it('checkGallerySpecialChar_17_inputText', 0, () => {
      let result = RenameUtil.checkGallerySpecialChar('testFile');
      expect(result).assertFalse();
    });
  });
}