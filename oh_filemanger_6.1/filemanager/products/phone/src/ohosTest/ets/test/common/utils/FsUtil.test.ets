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
import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { Constant, FileUtil, FsUtil, HiLog } from '@ohos/common';
import { TestUtil } from '../../utils/TestUtil';
import fs from '@ohos.file.fs';
import { BusinessError } from '@kit.BasicServicesKit';

export default function FsUtilTest() {
  describe('FsUtilTest', () => {
    const TAG: string = 'FsUtilTest';

    it('statSync_error', 0, () => {
      let result: BusinessError | fs.Stat = FsUtil.statSync('');
      expect(result instanceof Error).assertTrue();
    })

    it('close_success', 0, async (done: Function) => {
      let file = FsUtil.openSync(TestUtil.TEST_FOLDER_PATH) as fs.File;
      let result = await FsUtil.close(file);
      expect(result instanceof Error).assertFalse();
      done();
    })

    it('close_error', 0, async (done: Function) => {
      let file = {} as fs.File;
      let result = await FsUtil.close(file);
      expect(result instanceof Error).assertTrue();
      done();
    })

    it('closeSync_error', 0, () => {
      let file = {} as fs.File;
      let result = FsUtil.closeSync(file);
      expect(result instanceof Error).assertTrue();
    })

    it('moveFile_success', 0, () => {
      const fileName: string = Date.now().toString() + '.jpg';
      TestUtil.createTestFileOrFolder([fileName], false);
      const src = TestUtil.TEST_FOLDER_PATH + '/' + fileName;
      const dest = 'storage/Users/currentUser/Documents';
      let result = FsUtil.moveFile(src, dest);
      expect(result instanceof Error).assertFalse();
    })

    it('openSync', 0, async (done: Function) => {
      let result: fs.File | BusinessError = FsUtil.openSync(Constant.INTERNAL_STORAGE_ROOT_PATH);
      expect(result as fs.File).not().assertUndefined();
      await FsUtil.close(result as fs.File);

      let result1 = await FsUtil.close(0);
      expect(result1 as BusinessError).assertUndefined();

      result =
        FsUtil.openSync('file://docs/storage/Users/currentUser/qsPF1/vqE3z/neudn/tyuey/d9iSu/TPBHH/iyerQ8auGaEN2UVBSjxL.xlsx',
          fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      expect(result as fs.File).not().assertUndefined();
      await FsUtil.close(result as fs.File);

      done();
    });

    it('isFile', 0, () => {
      let systemFolderUri: string = 'file://docs/storage/Users/currentUser/Documents';
      expect(FsUtil.isFile(FileUtil.getPathFromUri(systemFolderUri))).assertFalse();
    })

    it('setxattr_empty', 0, () => {
      let mocker = new MockKit();
      let mockFun = mocker.mockFunc(HiLog, HiLog.warn);
      when(mockFun)(ArgumentMatchers.any).afterReturnNothing();
      FsUtil.setxattr('', 'key', 'value');
      mocker.verify('warn', ['FsUtil', 'path to be marked is empty']).once();
      mocker.clear(HiLog);
    });

    it('setxattr_normal', 0, () => {
      let mocker = new MockKit();
      let mockFun1 = mocker.mockFunc(HiLog, HiLog.warn);
      when(mockFun1)(ArgumentMatchers.any).afterReturnNothing();
      FsUtil.setxattr('path', 'key', 'value');
      mocker.verify('warn', ['FsUtil', 'path to be marked is empty']).never();
      mocker.clear(HiLog);
    })

    it('file_copy_test_src_null', 0, async () => {
      const copySignal: fs.TaskSignal = new fs.TaskSignal();
      const progressListener: fs.ProgressListener = async (progress: fs.Progress) => {
      };
      const res = await FsUtil.fileCopy('', 'b', copySignal, progressListener);
      expect(res).assertFalse();
    })

    it('file_copy_test_dest_null', 0, async () => {
      const copySignal: fs.TaskSignal = new fs.TaskSignal();
      const progressListener: fs.ProgressListener = async (progress: fs.Progress) => {
      };
      const res = await FsUtil.fileCopy('a', '', copySignal, progressListener);
      expect(res).assertFalse();
    })

    it('file_copy_test_false', 0, async () => {
      const copySignal: fs.TaskSignal = new fs.TaskSignal();
      const progressListener: fs.ProgressListener = async (progress: fs.Progress) => {
      };
      const res = await FsUtil.fileCopy('a', 'B', copySignal, progressListener);
      expect(res).assertFalse();
    })

    it('file_copy_test_true', 0, async () => {
      const copySignal: fs.TaskSignal = new fs.TaskSignal();
      const progressListener: fs.ProgressListener = async (progress: fs.Progress) => {
      };
      const srcPath: string = '/storage/Users/currentUser/Documents/dt_test/file_copy_test/AA123';
      const destPath: string = '/storage/Users/currentUser/Documents/dt_test/file_copy_test/BB321';
      await FsUtil.mkdir(srcPath, true);
      await FsUtil.mkdir(destPath, true);
      const srcUri: string = FileUtil.getUriFromPath(srcPath);
      const destUri: string = FileUtil.getUriFromPath(destPath);
      const res: boolean = await FsUtil.fileCopy(srcUri, destUri, copySignal, progressListener);
      expect(res).assertTrue();
      const deleteRes: number | BusinessError =
        FsUtil.forceDelete('/storage/Users/currentUser/Documents/dt_test/file_copy_test');
      expect(deleteRes as number).assertEqual(0);
    })

    it('paste_file_by_fd_test_src_null', 0, () => {
      const srcFileUri = '';
      const destAlbumUri = 'aa';
      const res: boolean = FsUtil.pasteFileByFd(srcFileUri, destAlbumUri);
      expect(res).assertFalse();
    })

    it('paste_file_by_fd_test_dest_null', 0, () => {
      const srcFileUri = 'aa';
      const destAlbumUri = '';
      const res: boolean = FsUtil.pasteFileByFd(srcFileUri, destAlbumUri);
      expect(res).assertFalse();
    })

    it('paste_file_by_fd_test_src_dest_invalid', 0, () => {
      const srcFileUri = 'aa-aa';
      const destAlbumUri = 'bb-bb';
      const res: boolean = FsUtil.pasteFileByFd(srcFileUri, destAlbumUri);
      expect(res).assertFalse();
    })

    it('paste_file_by_fd_test_no_error', 0, async () => {
      const srcFileUri = '/storage/Users/currentUser/Documents/dt_test/paste_file_by_fd_test/test.txt';
      const destAlbumUri = '/storage/Users/currentUser/Documents/dt_test/paste_file_by_fd_test/test2.txt';
      await FsUtil.mkdir('/storage/Users/currentUser/Documents/dt_test/paste_file_by_fd_test', true);
      const fileRes : fs.File| BusinessError = FsUtil.openSync(srcFileUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      const fileRes2 : fs.File| BusinessError = FsUtil.openSync(destAlbumUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      expect(fileRes as fs.File).not().assertUndefined();
      expect(fileRes2 as fs.File).not().assertUndefined();
      await FsUtil.close(fileRes2 as fs.File);
      const resFilePath = (fileRes as fs.File).path;
      const writeData = 'writeData';
      const writeRes: number | BusinessError = FsUtil.writeSync((fileRes as fs.File).fd, writeData);
      expect(writeRes as number).assertLarger(0);
      try {
        const readRes: string = fs.readTextSync(resFilePath);
        expect(readRes).assertEqual(writeData);
      } catch (error) {
        expect(error).assertUndefined();
      }
      await FsUtil.close(fileRes as fs.File);
      const res: boolean = FsUtil.pasteFileByFd(srcFileUri, destAlbumUri);
      expect(res).assertTrue();
      const deleteRes: number | BusinessError =
        FsUtil.forceDelete('/storage/Users/currentUser/Documents/dt_test/paste_file_by_fd_test');
      expect(deleteRes as number).assertEqual(0);
    })
  })
}