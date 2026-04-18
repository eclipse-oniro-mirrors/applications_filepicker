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

import { afterAll, beforeAll, describe, expect, it, Level } from '@ohos/hypium'
import { HiLog, VirtualUri, ThreadCommonUtil, FileInfo } from '@ohos/common';
import { PasteFlag } from '@ohos/common/src/main/ets/const/FilePasteConstants';
import { ProgressBarStatus } from '@ohos/common//src/main/ets/workermanager/copycutmanager/CopyCutSendParam';
import fs from '@ohos.file.fs';
import { TestUtil } from '../../utils/TestUtil';

const TAG = 'ThreadCommonUtilTest';
const ROOT_PATH = '/storage/Users/currentUser/';
const ROOT_URI = 'file://docs/storage/Users/currentUser/';
const FOLDER_NAME = 'test';
const FILE_NAME = 'test.txt';
let folderPath = ROOT_PATH + FOLDER_NAME;  // /storage/Users/currentUser/test;
let filePath = ROOT_PATH + FILE_NAME;      // /storage/Users/currentUser/test.txt;
let folderMaxName = FOLDER_NAME;
let folderMaxPath = ROOT_PATH;
let folderName1 = 'test(1)';
let folderPath1 = folderName1 + FOLDER_NAME;

export default function ThreadCommonUtilTest() {
  describe('ThreadCommonUtilTest', () => {
    beforeAll(() => {
      testBeforeAll();
    })
    afterAll(() => {
      testAfterAll();
    })

    it('shouldReturnNotPullUp_WhenCutSameDisk_LocalAppFile', 0, (done: Function) => {
      let file1: FileInfo = new FileInfo();
      file1.uri = 'test1';
      file1.fileName = 'file1';
      file1.size = 100;
      file1.isFolder = false;
      let file2: FileInfo = new FileInfo();
      file2.uri = 'test2';
      file2.fileName = 'file2';
      file2.size = 200;
      file2.isFolder = false;
      let files: FileInfo[] = [file1, file2];
      const result = ThreadCommonUtil.isShowProgressByFileSize(files, PasteFlag.CUT, false, true);
      expect(result).assertEqual(ProgressBarStatus.NOT_PULL_UP);
      done();
    })

    it('shouldReturnNotPullUp_WhenCutSameDisk_OperateAcrossDisk', 0, (done: Function) => {
      let file1: FileInfo = new FileInfo();
      file1.uri = 'test1';
      file1.fileName = 'file1';
      file1.size = 100;
      file1.isFolder = false;
      let file2: FileInfo = new FileInfo();
      file2.uri = 'test2';
      file2.fileName = 'file2';
      file2.size = 200;
      file2.isFolder = false;
      let files: FileInfo[] = [file1, file2];
      const result = ThreadCommonUtil.isShowProgressByFileSize(files, PasteFlag.CUT, true, false);
      expect(result).assertEqual(ProgressBarStatus.NOT_PULL_UP);
      done();
    })

    it('shouldReturnNotPullUp_WhenCutSameDisk_OperateAcrossDisk_3length', 0, (done: Function) => {
      let file1: FileInfo = new FileInfo();
      file1.uri = 'test1';
      file1.fileName = 'file1';
      file1.size = 100;
      file1.isFolder = false;
      let file2: FileInfo = new FileInfo();
      file2.uri = 'test2';
      file2.fileName = 'file2';
      file2.size = 200;
      file2.isFolder = false;
      let file3: FileInfo = new FileInfo();
      file3.uri = 'test2';
      file3.fileName = 'file2';
      file3.size = 200;
      file3.isFolder = true;
      let files = [file1, file2, file3];
      const result2 = ThreadCommonUtil.isShowProgressByFileSize(files, PasteFlag.CUT, true, false);
      expect(result2).assertEqual(ProgressBarStatus.NOT_JUDGED);
      done();
    })

    it('shouldReturnNeedPullUp_WhenFileCountExceedsThreshold', 0, () => {
      let file1: FileInfo = new FileInfo();
      file1.uri = 'test1';
      file1.fileName = 'file1';
      file1.size = 100;
      file1.isFolder = false;
      let files: FileInfo[] = [];
      for (let i = 0; i < 300; ++i) {
        files.push(file1);
      }
      const result = ThreadCommonUtil.isShowProgressByFileSize(files, PasteFlag.COPY, true, false);
      expect(result).assertEqual(ProgressBarStatus.NEEDS_TO_BE_PULLED_UP);
    });

    it('shouldReturnNeedPullUp_WhenFileCountExceedsThreshold_BigSize', 0, () => {
      let file1: FileInfo = new FileInfo();
      file1.uri = 'test1';
      file1.fileName = 'file1';
      file1.size = 100;
      file1.isFolder = false;
      let files: FileInfo[] = [];
      for (let i = 0; i < 300; ++i) {
        files.push(file1);
      }
      let file2: FileInfo = new FileInfo();
      file2.uri = 'test2';
      file2.fileName = 'file2';
      file2.size = 324288000;
      file2.isFolder = false;
      let files2: FileInfo[] = [file2, file2];
      const result2 = ThreadCommonUtil.isShowProgressByFileSize(files2, PasteFlag.COPY, true, false);
      expect(result2).assertEqual(ProgressBarStatus.NEEDS_TO_BE_PULLED_UP);
    });

    it('shouldReturnCorrectByteLengthForASCII', 0, () => {
      const len = ThreadCommonUtil.getByteLen('abc');
      expect(len).assertEqual(3);
    });

    it('shouldReturnCorrectByteLengthForChinese', 0, () => {
      const len = ThreadCommonUtil.getByteLen('测试');
      expect(len).assertEqual(6);
    });

    it('shouldReturnFalse_WhenNotFolderOperation', 0, () => {
      let fileInfo: FileInfo = new FileInfo();
      fileInfo.uri = 'content://test/file.txt';
      fileInfo.fileName = 'file.txt';
      fileInfo.size = 100;
      fileInfo.isFolder = false;
      const result = ThreadCommonUtil.isOperateDupFolderFromChildToParent(fileInfo, 'content://test');
      expect(result).assertFalse();
    });

    it("isShowProgressTest", 0, async () => {
      let pasteFlag = PasteFlag.CUT;
      let isOperateAcrossDisk = false;
      let isLocalAppFile = true;
      let totalSize = 0;
      let totalCount = 0;
      let result = ThreadCommonUtil.isShowProgress(totalSize, totalCount, pasteFlag,
        isOperateAcrossDisk, isLocalAppFile);
      expect(result).assertFalse();
    })

    it("isShowProgressOperateAcrossDiskIsTrue", 0, async () => {
      let pasteFlag = PasteFlag.CUT;
      let isOperateAcrossDisk = false;
      let isLocalAppFile = true;
      let totalSize = 0;
      let totalCount = 0;

      isOperateAcrossDisk = true;
      let result = ThreadCommonUtil.isShowProgress(totalSize, totalCount, pasteFlag,
        isOperateAcrossDisk, isLocalAppFile);
      expect(result).assertFalse();
    })

    it("isShowProgressLocalAppFileIsFalse", 0, async () => {
      let pasteFlag = PasteFlag.CUT;
      let isOperateAcrossDisk = false;
      let isLocalAppFile = true;
      let totalSize = 0;
      let totalCount = 0;

      isOperateAcrossDisk = true;
      isLocalAppFile = false;
      totalCount = 200;
      let result = ThreadCommonUtil.isShowProgress(totalSize, totalCount, pasteFlag,
        isOperateAcrossDisk, isLocalAppFile);
      expect(result).assertTrue();
    })

    it("isShowProgressCOPY", 0, async () => {
      let pasteFlag = PasteFlag.CUT;
      let isOperateAcrossDisk = false;
      let isLocalAppFile = true;
      let totalSize = 0;
      let totalCount = 0;

      isOperateAcrossDisk = true;
      isLocalAppFile = false;
      totalCount = 200;
      pasteFlag = PasteFlag.COPY;
      totalSize = 524288000;
      let result = ThreadCommonUtil.isShowProgress(totalSize, totalCount, pasteFlag,
        isOperateAcrossDisk, isLocalAppFile);
      expect(result).assertTrue();
    })

    it("getWorkerNameTest", 0, () => {
      let result = ThreadCommonUtil.getWorkerName('test');
      let ept = result.length;
      expect(ept).assertLarger(0);
    })

    it("getWorkerNameTrue", 0, () => {
      let result = ThreadCommonUtil.getWorkerName('test', true);
      let ept = result.length;
      expect(ept).assertLarger(0);
    })

    it("getWorkerName_", 0, () => {
      const workerName = ThreadCommonUtil.getWorkerName('testTag');
      expect(workerName).assertContain('testTag_');
    })

    it("getParentUriTest", 0, () => {
      let result = ThreadCommonUtil.getParentUri('test');
      let ept = result.length;
      expect(ept).assertLarger(-1);
    })

    it("getFileNameByUriTest", 0, () => {
      let result = ThreadCommonUtil.getFileNameByUri('test');
      let ept = result.length;
      expect(ept).assertLarger(-1);
    })

    it('getSubFileUriRemoteTest', 0, () => {
      let remoteFolderUri: string = 'file://storage/media/100/local/files/Docs/remoteFolder?networkid=111';
      let remoteSubFileName: string = 'remoteFile';
      let result = ThreadCommonUtil.getSubFileUri(remoteFolderUri, remoteSubFileName);
      expect(result).assertEqual('file://storage/media/100/local/files/Docs/remoteFolder/remoteFile?networkid=111');
    })

    it('getSubFileUriLocalTest', 0, () => {
      let localFolderUri: string = 'file://storage/media/100/local/files/Docs/localFolder';
      let localSubFileName: string = 'localFile';
      let result = ThreadCommonUtil.getSubFileUri(localFolderUri, localSubFileName);
      expect(result).assertEqual('file://storage/media/100/local/files/Docs/localFolder/localFile');
    })

    it("getDupFileName_1_Test", 0, () => {
      let result = ThreadCommonUtil.getDupFileName('test', VirtualUri.DOWNLOAD, false);
      let ept = result.length;
      expect(ept).assertLarger(-1);
    })

    it("getDupFileName_2_Test", 0, () => {
      let result = ThreadCommonUtil.getDupFileName(VirtualUri.DESKTOP, VirtualUri.DOWNLOAD, false);
      let ept = result.length;
      expect(ept).assertLarger(-1);
    })

    it("getDupFileName_3_Test", 0, () => {
      let result = ThreadCommonUtil.getDupFileName('test', VirtualUri.DOWNLOAD, true);
      let ept = result.length;
      expect(ept).assertLarger(-1);
    })

    it("getDupFileName_4_Test", 0, () => {
      let result = ThreadCommonUtil.getDupFileName(VirtualUri.DESKTOP, VirtualUri.DOWNLOAD, true);
      let ept = result.length;
      expect(ept).assertLarger(-1);
    })

    it("getDupFileName_5_Test", 0, () => {
      let result = ThreadCommonUtil.getDupFileName(FOLDER_NAME, ROOT_URI, true);
      let ept = result.length;
      expect(ept).assertLarger(-1);
    })

    it("getDupFileName_6_Test", 0, () => {
      let result = ThreadCommonUtil.getDupFileName(FILE_NAME, ROOT_URI, false);
      let ept = result.length;
      expect(ept).assertLarger(-1);
    })

    it("getDupFileName_7_Test", 0, () => {
      let result = ThreadCommonUtil.getDupFileName(folderMaxName, ROOT_URI, true);
      let ept = result.length;
      expect(ept).assertLarger(-1);
    })

    it("getDupFileName_8_Test", 0, () => {
      let result = ThreadCommonUtil.getDupFileName(folderName1, ROOT_URI, true);
      let ept = result.length;
      expect(ept).assertLarger(-1);
    })

    it("getDupFileName_9_Test", 0, () => {
      let result = ThreadCommonUtil.getDupFileName(folderName1, 'unExistPath', true);
      let ept = result.length;
      expect(ept).assertLarger(-1);
    })

    it("isChildFolder_1_Test", 0, () => {
      let uri = VirtualUri.DOWNLOAD;
      let result = ThreadCommonUtil.isChildFolder(VirtualUri.DESKTOP, uri);
      expect(result).assertFalse()
    })

    it("isChildFolder_2_Test", 0, () => {
      const srcUri = 'content://media/external/files';
      const destUri = 'content://media/external/files/subfolder';
      const result = ThreadCommonUtil.isChildFolder(srcUri, destUri);
      expect(result).assertTrue();
    })

    it("isChildFolder_3_Test", 0, () => {
      const srcUri = 'content://media/external/files1';
      const destUri = 'content://media/external/files2';
      const result = ThreadCommonUtil.isChildFolder(srcUri, destUri);
      expect(result).assertFalse();
    })

    it("isOperateDupFolderFromChildToParent_1_Test", 0, () => {
      let srcFileInfo = new FileInfo();
      srcFileInfo.isFolder = false;
      let result = ThreadCommonUtil.isOperateDupFolderFromChildToParent(srcFileInfo, VirtualUri.DOWNLOAD);
      expect(result).assertFalse();
    })

    it("isOperateDupFolderFromChildToParent_2_Test", 0, () => {
      let srcFileInfo = new FileInfo();
      srcFileInfo.isFolder = true;
      let result = ThreadCommonUtil.isOperateDupFolderFromChildToParent(srcFileInfo, VirtualUri.DOWNLOAD);
      expect(result).assertFalse();
    })

    it('should_return_empty_string_when_uri_is_undefined', 0, () => {
      const result = ThreadCommonUtil.getNoSlashUri(undefined);
      expect(result).assertEqual('');
    });

    it('should_return_empty_string_when_uri_is_null', 0, () => {
      const result = ThreadCommonUtil.getNoSlashUri();
      expect(result).assertEqual('');
    });

    it('should_return_uri_as_is_when_it_does_not_end_with_slash', 0, () => {
      const result = ThreadCommonUtil.getNoSlashUri('http://example.com/path');
      expect(result).assertEqual('http://example.com/path');
    });

    it('should_return_uri_without_trailing_slash_when_it_ends_with_slash', 0, () => {
      const result = ThreadCommonUtil.getNoSlashUri('http://example.com/path/');
      expect(result).assertEqual('http://example.com/path');
    });

    it('should_return_empty_string_when_uri_is_empty_string', 0, () => {
      const result = ThreadCommonUtil.getNoSlashUri('');
      expect(result).assertEqual('');
    });

    it('should_return_uri_without_trailing_slash_when_uri_ends_with_double_slash', 0, () => {
      const result = ThreadCommonUtil.getNoSlashUri('http://example.com/path/');
      expect(result).assertEqual('http://example.com/path');
    });

    it('getDupFileResult_4_Test', 0, () => {
      let result = ThreadCommonUtil.getDupFileResult('example', '.txt', 4);
      expect(result).assertEqual('example (4).txt');
    });

    it('getRawDupFileName_InputParamsAreUndefined', Level.LEVEL0, () => {
      const getRawDupFileName = TestUtil.getPrivateFunction(ThreadCommonUtil, 'getRawDupFileName');
      if (getRawDupFileName) {
        let srcFileName = undefined;
        let destFolderUri = undefined;
        let isFolder: boolean = false;
        let result: string[] = getRawDupFileName(srcFileName, destFolderUri, isFolder);
        expect(result[0]).assertEqual('');
        expect(result[1]).assertEqual('');
      } else {
        expect().assertFail();
      }
    });

    it('getRawDupFileName_srcFileNameIsUndefined', Level.LEVEL0, () => {
      const getRawDupFileName = TestUtil.getPrivateFunction(ThreadCommonUtil, 'getRawDupFileName');
      if (getRawDupFileName) {
        let srcFileName = undefined;
        let destFolderUri = '/storage/Users/currentUser/';
        let isFolder: boolean = false;
        let result: string[] = getRawDupFileName(srcFileName, destFolderUri, isFolder);
        expect(result[0]).assertEqual('');
        expect(result[1]).assertEqual('');
      } else {
        expect().assertFail();
      }
    });

    it('getRawDupFileName_destFolderUriIsUndefined', Level.LEVEL0, () => {
      const getRawDupFileName = TestUtil.getPrivateFunction(ThreadCommonUtil, 'getRawDupFileName');
      if (getRawDupFileName) {
        let srcFileName = 'testFile.txt';
        let destFolderUri = undefined;
        let isFolder: boolean = false;
        let result: string[] = getRawDupFileName(srcFileName, destFolderUri, isFolder);
        expect(result[0]).assertEqual('');
        expect(result[1]).assertEqual('');
      } else {
        expect().assertFail();
      }
    });

    it('getRawDupFileName_destFolderNotExist', Level.LEVEL0, () => {
      const getRawDupFileName = TestUtil.getPrivateFunction(ThreadCommonUtil, 'getRawDupFileName');
      if (getRawDupFileName) {
        let srcFileName = 'testFile.txt';
        let destFolderUri = '/storage/Users/currentUser/notExistFolder';
        let isFolder: boolean = false;
        let result: string[] = getRawDupFileName(srcFileName, destFolderUri, isFolder);
        expect(result[0]).assertEqual('testFile');
        expect(result[1]).assertEqual('.txt');
      } else {
        expect().assertFail();
      }
    });

    it('getRawDupFileName_NotExistDuplicateFileName', Level.LEVEL0, () => {
      const getRawDupFileName = TestUtil.getPrivateFunction(ThreadCommonUtil, 'getRawDupFileName');
      if (getRawDupFileName) {
        let srcFileName = FILE_NAME;
        let destFolderUri = folderPath;
        let isFolder: boolean = false;
        let result: string[] = getRawDupFileName(srcFileName, destFolderUri, isFolder);
        expect(result[0]).assertEqual(FILE_NAME);
        expect(result[1]).assertEqual('');
      } else {
        expect().assertFail();
      }
    });

    it('getRawDupFileName_ExistDuplicateFileName', Level.LEVEL0, () => {
      const getRawDupFileName = TestUtil.getPrivateFunction(ThreadCommonUtil, 'getRawDupFileName');
      if (getRawDupFileName) {
        let duplicateFile: string = folderPath + '/' + FILE_NAME;
        createFile(duplicateFile);

        let srcFileName = FILE_NAME;
        let destFolderUri = folderPath;
        let isFolder: boolean = false;
        let result: string[] = getRawDupFileName(srcFileName, destFolderUri, isFolder);
        expect(result[0]).assertEqual('test (2).txt');
        expect(result[1]).assertEqual(destFolderUri + '/' + srcFileName);
        removeFile(duplicateFile);
      } else {
        expect().assertFail();
      }
    });

    it('getRawDupFileName_fileNameExceedLength', Level.LEVEL0, () => {
      const getRawDupFileName = TestUtil.getPrivateFunction(ThreadCommonUtil, 'getRawDupFileName');
      if (getRawDupFileName) {
        let fileName: string = 'a'.repeat(251) + '.txt';
        createFile(folderPath + '/' + fileName);

        let srcFileName = fileName;
        let destFolderUri = folderPath;
        let isFolder: boolean = false;
        let result: string[] = getRawDupFileName(srcFileName, destFolderUri, isFolder);
        let resultFileName: string = 'a'.repeat(251 - 10) + ' (2).txt';
        expect(result[0]).assertEqual(resultFileName);
        expect(result[1]).assertEqual(destFolderUri + '/' + srcFileName);
        removeFile(folderPath + '/' + fileName);
      } else {
        expect().assertFail();
      }
    });

    it('getRawDupFileName_fileNameSuffixNotMatch', Level.LEVEL0, () => {
      const getRawDupFileName = TestUtil.getPrivateFunction(ThreadCommonUtil, 'getRawDupFileName');
      if (getRawDupFileName) {
        let fileName: string = 'a.jpg';

        let srcFileName = fileName;
        let destFolderUri = folderPath;
        let isFolder: boolean = false;
        let result: string[] = getRawDupFileName(srcFileName, destFolderUri, isFolder);
        expect(result[0]).assertEqual(fileName);
        expect(result[1]).assertEqual('');
      } else {
        expect().assertFail();
      }
    });

    it('getRawDupFileName_NotExistDuplicateFolderName', Level.LEVEL0, () => {
      const getRawDupFileName = TestUtil.getPrivateFunction(ThreadCommonUtil, 'getRawDupFileName');
      if (getRawDupFileName) {
        let folderName: string = 'testFolder';

        let srcFileName = folderName;
        let destFolderUri = folderPath;
        let isFolder: boolean = true;
        let result: string[] = getRawDupFileName(srcFileName, destFolderUri, isFolder);
        expect(result[0]).assertEqual('testFolder');
        expect(result[1]).assertEqual('');
      } else {
        expect().assertFail();
      }
    });

    it('getRawDupFileName_ExistDuplicateFolderName', Level.LEVEL0, () => {
      const getRawDupFileName = TestUtil.getPrivateFunction(ThreadCommonUtil, 'getRawDupFileName');
      if (getRawDupFileName) {
        let folderName: string = 'testFolder';
        createFolder(folderPath + '/' + folderName);

        let srcFileName = folderName;
        let destFolderUri = folderPath;
        let isFolder: boolean = true;
        let result: string[] = getRawDupFileName(srcFileName, destFolderUri, isFolder);
        expect(result[0]).assertEqual('testFolder (2)');
        expect(result[1]).assertEqual(folderPath + '/' + folderName);
        removeFolder(folderPath + '/' + folderName);
      } else {
        expect().assertFail();
      }
    });

    it('getRawDupFileName_FolderNameExceedLength', Level.LEVEL0, () => {
      const getRawDupFileName = TestUtil.getPrivateFunction(ThreadCommonUtil, 'getRawDupFileName');
      if (getRawDupFileName) {
        let fileName: string = 'a'.repeat(255);
        createFolder(folderPath + '/' + fileName);

        let srcFileName = fileName;
        let destFolderUri = folderPath;
        let isFolder: boolean = true;
        let result: string[] = getRawDupFileName(srcFileName, destFolderUri, isFolder);
        let resultFileName: string = 'a'.repeat(255 - 10) + ' (2)';
        expect(result[0]).assertEqual(resultFileName);
        expect(result[1]).assertEqual(destFolderUri + '/' + srcFileName);
        removeFolder(folderPath + '/' + fileName);
      } else {
        expect().assertFail();
      }
    });
  })
}

function testBeforeAll(): void {
  folderPath = ROOT_PATH + FOLDER_NAME;
  filePath = ROOT_PATH + FILE_NAME;
  folderMaxName = FOLDER_NAME;
  //测试复制的文件即将超过最大长度限制，功能是否正常
  for (let index = 0; index < 62; index++) {
    folderMaxName = folderMaxName + FOLDER_NAME;
  }
  folderMaxName = folderMaxName + 'te';
  folderMaxPath = ROOT_PATH + folderMaxName;
  try {
    HiLog.info(TAG, 'ThreadCommonUtilTest beforeAll');
    if (!fs.accessSync(folderPath)) {
      fs.mkdirSync(folderPath);
    }
    if (!fs.accessSync(folderPath1)) {
      fs.mkdirSync(folderPath1);
    }
    if (!fs.accessSync(filePath)) {
      let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.closeSync(file);
    }
    if (!fs.accessSync(folderMaxPath)) {
      fs.mkdirSync(folderMaxPath);
    }
  } catch (error) {
    HiLog.error(TAG, 'ThreadCommonUtilTest beforeAll error');
  }
}

function testAfterAll(): void {
  try {
    HiLog.info(TAG, 'ThreadCommonUtilTest afterAll');
    if (fs.accessSync(folderPath)) {
      fs.rmdirSync(folderPath);
    }
    if (fs.accessSync(folderPath1)) {
      fs.rmdirSync(folderPath1);
    }
    if (fs.accessSync(filePath)) {
      fs.unlinkSync(filePath);
    }
    if (fs.accessSync(folderMaxPath)) {
      fs.rmdirSync(folderMaxPath);
    }
  } catch (error) {
    HiLog.error(TAG, 'ThreadCommonUtilTest afterAll error');
  }
}

function createFile(filePath: string): void {
  if (!fs.accessSync(filePath)) {
    let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    fs.closeSync(file);
  }
}

function removeFile(filePath: string): void {
  if (fs.accessSync(filePath)) {
    fs.unlinkSync(filePath);
  }
}

function createFolder(folderPath: string): void {
  if (!fs.accessSync(folderPath)) {
    fs.mkdirSync(folderPath);
  }
}

function removeFolder(folderPath: string): void {
  if (fs.accessSync(folderPath)) {
    fs.rmdirSync(folderPath);
  }
}
