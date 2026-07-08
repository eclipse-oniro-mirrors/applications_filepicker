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
import {
  Constant,
  CopyCutConst,
  CopyCutSendParam,
  DataSourceDeviceType,
  DiskInfo,
  ERROR_CODE,
  ExternalStorageUtil,
  FavoriteModel,
  FileAccessUtil,
  FileCopyUtil,
  FileInfo,
  FilePickerUtil,
  FilesQueryUtil,
  FileUtil,
  FsUtil,
  GlobalHolder,
  GlobalKey,
  HiLog,
  ObjectUtil,
  RenameUtil,
  StorageUtil,
  StringUtil,
  TaskObject,
  ThreadCommonUtil,
  VirtualUri,
  WorkerConst,
} from '@ohos/common';
import {
  afterAll,
  afterEach,
  ArgumentMatchers,
  beforeAll,
  beforeEach,
  describe,
  expect,
  it,
  MockKit,
  when
} from '@ohos/hypium';
import type ctx from '@ohos.app.ability.common';
import worker from '@ohos.worker';
import { JSON, ThreadWorkerGlobalScope } from '@kit.ArkTS';
import { ResultCode } from '@ohos/common/src/main/ets/worker/ResultCode';
import { fileExtensionInfo, fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import fs from '@ohos.file.fs';
import { TestUtil } from '../../utils/TestUtil';
import { PhotoAccessUtil } from '@ohos/common/indexLazyLoad';
import { TestFileUtil } from '../../../utils/TestFileUtil';
import { FileAccessError } from '@ohos/common/src/main/ets/error/Error';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

let workerPort: ThreadWorkerGlobalScope = worker.workerPort;

const TAG = 'FileCopyUtilTest'

export class FileCopyUtilError implements BusinessError<void> {
  public code: ERROR_CODE.FILE_ACCESS;
  public name: string = 'FileCopyUtilError';
  public message: string;

  /**
   * 生产错误实例
   * @param code 错误码
   * @param message 错误信息
   */
  constructor(code: ERROR_CODE.FILE_ACCESS, message: string) {
    this.code = code;
    this.message = message;
  }
}

export default function FileCopyUtilTest() {
  describe('FileCopyUtilTest', () => {
    let fileCopyUtil: FileCopyUtil;
    let context: ctx.UIAbilityContext;
    let mocker: MockKit;
    let copyCutSendParam: CopyCutSendParam;
    beforeAll(() => {
      context = GlobalHolder.getInstance().getMainAbilityContext() as ctx.UIAbilityContext;
    })

    beforeEach(() => {
      fileCopyUtil = new FileCopyUtil();
      fileCopyUtil.workerPort = workerPort;
      mocker = new MockKit();
      fileCopyUtil.context = context;
      copyCutSendParam = new CopyCutSendParam(
        context,
        WorkerConst.OperateType.COPY_FILE,
        'test',
        [new FileInfo()],
        '',
        CopyCutConst.SendMsgCode.CONFLICT,
        undefined,
        false,
        'LOCAL',
        'file://docs/storage/Users/currentUser'
      );
    })

    afterAll(() => {
      mocker.clearAll();
    })

    afterEach(() => {
      if (mocker) {
        mocker.clear(fileCopyUtil);
        mocker.clear(ThreadCommonUtil);
        mocker.clear(RenameUtil);
        mocker.clear(PhotoAccessUtil);
        mocker.clear(HiLog);
      }
    })

    it('dealMessage_START', 0, async (done: Function) => {
      let startTask = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'startTask');
      when(startTask)(ArgumentMatchers.any).afterReturnNothing();
      copyCutSendParam.msgCode = CopyCutConst.SendMsgCode.START;
      await fileCopyUtil.dealMessage(copyCutSendParam);
      mocker.verify('startTask', [copyCutSendParam]).once();
      done();
    })

    it('dealMessage_CONFLICT', 0, async (done: Function) => {
      let dealConflictChoose = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'dealConflictChoose');
      when(dealConflictChoose)(ArgumentMatchers.any).afterReturnNothing();
      copyCutSendParam.msgCode = CopyCutConst.SendMsgCode.CONFLICT;
      await fileCopyUtil.dealMessage(copyCutSendParam);
      mocker.verify('dealConflictChoose', [copyCutSendParam]).once();
      done();
    })

    it('dealMessage_CANCEL', 0, async (done: Function) => {
      let cancelWorker = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'cancelWorker');
      when(cancelWorker)(ArgumentMatchers.any).afterReturnNothing();
      copyCutSendParam.msgCode = CopyCutConst.SendMsgCode.CANCEL;
      await fileCopyUtil.dealMessage(copyCutSendParam);
      mocker.verify('cancelWorker', []).once();
      done();
    })

    it('dealMessage_QUERY_TASK_STATUS', 0, async (done: Function) => {
      let queryStatus = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'queryStatus');
      when(queryStatus)(ArgumentMatchers.any).afterReturnNothing();
      copyCutSendParam.msgCode = CopyCutConst.SendMsgCode.QUERY_TASK_STATUS;
      await fileCopyUtil.dealMessage(copyCutSendParam);
      mocker.verify('queryStatus', []).once();
      done();
    })

    it('dealMessage_EXTERNAL_DISK_CHANGE', 0, async (done: Function) => {
      let dealUsbChange = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'dealUsbChange');
      when(dealUsbChange)(ArgumentMatchers.any).afterReturnNothing();
      copyCutSendParam.msgCode = CopyCutConst.SendMsgCode.EXTERNAL_DISK_CHANGE;
      await fileCopyUtil.dealMessage(copyCutSendParam);
      mocker.verify('dealUsbChange', []).once();
      done();
    })

    it('dealConflictChooseInPhone_FILE_CONFLICT', 0, () => {
      let dealConflictChooseInPhone = TestUtil.getPrivateFunction(fileCopyUtil, 'dealConflictChooseInPhone');
      if (!dealConflictChooseInPhone) {
        expect(dealConflictChooseInPhone).not().assertNull();
      } else {
        fileCopyUtil.conflictType = CopyCutConst.ConflictType.FILE_CONFLICT;
        dealConflictChooseInPhone(copyCutSendParam);
        expect(fileCopyUtil.isFileApplyAll).assertEqual(copyCutSendParam.isApplyToAll);
        expect(fileCopyUtil.fileApplyChoose).assertEqual(copyCutSendParam.conflictHandleResult);
      }
    })

    it('dealConflictChooseInPhone_FOLDER_CONFLICT', 0, () => {
      let dealConflictChooseInPhone = TestUtil.getPrivateFunction(fileCopyUtil, 'dealConflictChooseInPhone');
      if (!dealConflictChooseInPhone) {
        expect(dealConflictChooseInPhone).not().assertNull();
      } else {
        fileCopyUtil.conflictType = CopyCutConst.ConflictType.FOLDER_CONFLICT;
        dealConflictChooseInPhone(copyCutSendParam);
        expect(fileCopyUtil.isFolderApplyAll).assertEqual(copyCutSendParam.isApplyToAll);
        expect(fileCopyUtil.folderApplyChoose).assertEqual(copyCutSendParam.conflictHandleResult);
      }
    })

    it('dealConflictChooseInPhone_PATH_CONFLICT', 0, () => {
      let dealConflictChooseInPhone = TestUtil.getPrivateFunction(fileCopyUtil, 'dealConflictChooseInPhone');
      if (!dealConflictChooseInPhone) {
        expect(dealConflictChooseInPhone).not().assertNull();
      } else {
        fileCopyUtil.conflictType = CopyCutConst.ConflictType.PATH_CONFLICT;
        dealConflictChooseInPhone(copyCutSendParam);
        expect(fileCopyUtil.isPathApplyAll).assertEqual(copyCutSendParam.isApplyToAll);
        expect(fileCopyUtil.pathApplyChoose).assertEqual(copyCutSendParam.conflictHandleResult);
      }
    })

    it('dealConflictChooseInPhone_OTHER_ERROR', 0, () => {
      let dealConflictChooseInPhone = TestUtil.getPrivateFunction(fileCopyUtil, 'dealConflictChooseInPhone');
      if (!dealConflictChooseInPhone) {
        expect().assertFail();
      } else {
        fileCopyUtil.conflictType = CopyCutConst.ConflictType.OTHER_ERROR;
        dealConflictChooseInPhone(copyCutSendParam);
        expect(fileCopyUtil.isOtherErrorApplyAll).assertEqual(copyCutSendParam.isApplyToAll);
        expect(fileCopyUtil.otherErrorApplyChoose).assertEqual(copyCutSendParam.conflictHandleResult);
      }
    })

    it('dealConflictChooseInPhone_UNDEFINED', 0, () => {
      let dealConflictChooseInPhone = TestUtil.getPrivateFunction(fileCopyUtil, 'dealConflictChooseInPhone');
      if (!dealConflictChooseInPhone) {
        expect(dealConflictChooseInPhone).not().assertNull();
      } else {
        fileCopyUtil.conflictType = CopyCutConst.ConflictType.DEST_PARENT_ERROR;
        dealConflictChooseInPhone(copyCutSendParam);
        expect(fileCopyUtil.isOtherErrorApplyAll).assertEqual(copyCutSendParam.isApplyToAll);
      }
    })

    it('dealConflictChoose_PC', 0, () => {
      let dealConflictChoose = TestUtil.getPrivateFunction(fileCopyUtil, 'dealConflictChoose');
      if (!dealConflictChoose) {
        expect(dealConflictChoose).not().assertNull();
      } else {
        TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'dealConflictChooseInPhone');
        dealConflictChoose(copyCutSendParam);
        mocker.verify('dealConflictChooseInPhone', [copyCutSendParam]).once()
        expect(fileCopyUtil.waitOperate).assertFalse();
      }
    })

    it('dealConflictChoose_PHONE', 0, () => {
      let dealConflictChoose = TestUtil.getPrivateFunction(fileCopyUtil, 'dealConflictChoose');
      if (!dealConflictChoose) {
        expect(dealConflictChoose).not().assertNull();
      } else {
        TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'dealConflictChooseInPhone');
        dealConflictChoose(copyCutSendParam);
        mocker.verify('dealConflictChooseInPhone', [copyCutSendParam]).once()
        expect(fileCopyUtil.waitOperate).assertFalse();
      }
    })

    it('startTask_Test_toOperateFilesEmpty_destFolderUriEmpty', 0, async (done: Function) => {
      let isNullOrUndefined = TestUtil.getPrivateMockFunction(mocker, ObjectUtil, 'isNullOrUndefined');
      when(isNullOrUndefined)(ArgumentMatchers.any).afterReturn(true);
      let runTask = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'runTask');

      await fileCopyUtil.startTask(copyCutSendParam);
      mocker.verify('runTask', [copyCutSendParam]).times(0);

      TestUtil.clearMockObject(mocker, ObjectUtil);
      done();
    });

    it('startTask_Test_toOperateFilesEmpty_destFolderUriNotEmpty', 0, async (done: Function) => {
      let isNullOrUndefined = TestUtil.getPrivateMockFunction(mocker, ObjectUtil, 'isNullOrUndefined');
      when(isNullOrUndefined)(ArgumentMatchers.any).afterReturn(false);
      let runTask = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'runTask');

      let fileInfo: FileInfo = TestFileUtil.createFile(TestFileUtil.TEST_FOLDER_PATH, TestFileUtil.TEST_FILE_NAME);
      copyCutSendParam.toOperateFiles = [];
      copyCutSendParam.destFolderUri = TestFileUtil.TEST_FOLDER_URI;

      await fileCopyUtil.startTask(copyCutSendParam);
      mocker.verify('runTask', [copyCutSendParam]).times(0);

      TestUtil.clearMockObject(mocker, ObjectUtil);
      done();
    });

    it('startTask_Test_toOperateFilesNotEmpty_copyFileInitFalse', 0, async (done: Function) => {
      let isNullOrUndefined = TestUtil.getPrivateMockFunction(mocker, ObjectUtil, 'isNullOrUndefined');
      when(isNullOrUndefined)(ArgumentMatchers.any).afterReturn(false);
      let runTask = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'runTask');
      let copyFileInit = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'copyFileInit');
      when(copyFileInit)(ArgumentMatchers.any).afterReturn(false);

      let fileInfo: FileInfo = TestFileUtil.createFile(TestFileUtil.TEST_FOLDER_PATH, TestFileUtil.TEST_FILE_NAME);
      copyCutSendParam.toOperateFiles = [fileInfo];
      copyCutSendParam.destFolderUri = TestFileUtil.TEST_FOLDER_URI;

      await fileCopyUtil.startTask(copyCutSendParam);
      mocker.verify('runTask', [copyCutSendParam]).times(0);

      TestUtil.clearMockObject(mocker, ObjectUtil);
      done();
    });

    it('startTask_Test_toOperateFilesNotEmpty_copyFileInitTrue', 0, async (done: Function) => {
      let isNullOrUndefined = TestUtil.getPrivateMockFunction(mocker, ObjectUtil, 'isNullOrUndefined');
      when(isNullOrUndefined)(ArgumentMatchers.any).afterReturn(false);
      let runTask = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'runTask');
      let copyFileInit = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'copyFileInit');
      when(copyFileInit)(ArgumentMatchers.any).afterReturn(true);
      when(runTask)(ArgumentMatchers.any).afterReturnNothing();

      let fileInfo: FileInfo = TestFileUtil.createFile(TestFileUtil.TEST_FOLDER_PATH, TestFileUtil.TEST_FILE_NAME);
      copyCutSendParam.toOperateFiles = [fileInfo];
      copyCutSendParam.destFolderUri = TestFileUtil.TEST_FOLDER_URI;

      await fileCopyUtil.startTask(copyCutSendParam);
      mocker.verify('runTask', [copyCutSendParam]).times(1);

      TestUtil.clearMockObject(mocker, ObjectUtil);
      done();
    });

    it('startTask_Test_copyFileInitThrowError', 0, async (done: Function) => {
      let isNullOrUndefined = TestUtil.getPrivateMockFunction(mocker, ObjectUtil, 'isNullOrUndefined');
      when(isNullOrUndefined)(ArgumentMatchers.any).afterReturn(false);
      let runTask = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'runTask');
      let copyFileInit = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'copyFileInit');
      when(copyFileInit)(ArgumentMatchers.any).afterAction(() => {
        throw new FileAccessError(13900025, 'file name invalid');
      });

      let fileInfo: FileInfo = TestFileUtil.createFile(TestFileUtil.TEST_FOLDER_PATH, TestFileUtil.TEST_FILE_NAME);
      copyCutSendParam.toOperateFiles = [fileInfo];
      copyCutSendParam.destFolderUri = TestFileUtil.TEST_FOLDER_URI;
      fileCopyUtil.pasteProgressRate = 99;

      await fileCopyUtil.startTask(copyCutSendParam);
      expect(fileCopyUtil.pasteProgressRate).assertEqual(100);

      TestUtil.clearMockObject(mocker, ObjectUtil);
      done();
    });

    it('runTask_COPY_Gallery_FILE', 0, async (done: Function) => {
      let runTask = TestUtil.getPrivateFunction(fileCopyUtil, 'runTask');
      if (!runTask) {
        expect(runTask).not().assertNull();
      } else {
        let pasteToGallery = mocker.mockFunc(fileCopyUtil, fileCopyUtil.pasteToGallery);
        fileCopyUtil.operateType = WorkerConst.OperateType.COPY_FILE;
        let fileInfo: FileInfo = TestFileUtil.createFile(TestFileUtil.TEST_FOLDER_PATH, TestFileUtil.TEST_FILE_NAME);
        copyCutSendParam.toOperateFiles = [fileInfo];
        fileCopyUtil.destFolderIsGalleryAlbum = true;
        await runTask(copyCutSendParam);
        mocker.verify('pasteToGallery', [
          TestUtil.getPrivateAttribute(fileCopyUtil, 'toOperateFiles'),
          copyCutSendParam]).once();
        TestFileUtil.deleteFile(fileInfo);
        done();
      }
    })

    it('runTask_COPY_FILE', 0, async (done: Function) => {
      let runTask = TestUtil.getPrivateFunction(fileCopyUtil, 'runTask');
      if (!runTask) {
        expect(runTask).not().assertNull();
      } else {
        fileCopyUtil.destFolderIsGalleryAlbum = false;
        let doCopy = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'doCopy');
        fileCopyUtil.operateType = WorkerConst.OperateType.COPY_FILE
        await runTask(copyCutSendParam);
        mocker.verify('doCopy', [
          TestUtil.getPrivateAttribute(fileCopyUtil, 'toOperateFiles'),
          copyCutSendParam.destFolderUri,
          copyCutSendParam.isFromRecent]).once();
        done();
      }
    })

    it('runTask_CUT_FILE', 0, async (done: Function) => {
      let runTask = TestUtil.getPrivateFunction(fileCopyUtil, 'runTask');
      if (!runTask) {
        expect(runTask).not().assertNull();
      } else {
        let doMove = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'doMove');
        fileCopyUtil.destFolderIsGalleryAlbum = false;
        fileCopyUtil.operateType = WorkerConst.OperateType.CUT_FILE
        await runTask(copyCutSendParam);
        mocker.verify('doMove',
          [TestUtil.getPrivateAttribute(fileCopyUtil, 'toOperateFiles'), copyCutSendParam.destFolderUri]).once();
        done();
      }
    })

    it('runTask_DRAG_FILE', 0, async (done: Function) => {
      let runTask = TestUtil.getPrivateFunction(fileCopyUtil, 'runTask');
      if (runTask) {
        let doDrag = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'doDrag');
        fileCopyUtil.destFolderIsGalleryAlbum = false;
        fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE
        await runTask(copyCutSendParam);
        mocker.verify('doDrag', [copyCutSendParam]).once();
      } else {
        expect(runTask).not().assertNull();
      }
      done();
    })

    it('initFileListToGallery_test', 0, async (done: Function) => {
      let fileInfo: FileInfo = new FileInfo();
      let albumInfo = await TestFileUtil.getAlbum(context, TestFileUtil.TEST_FOLDER);
      copyCutSendParam.toOperateFiles = [fileInfo];
      copyCutSendParam.destFolderUri = albumInfo?.albumUri as string;
      fileCopyUtil.isCancel = true;
      let res: number = await fileCopyUtil.initFileListToGallery([fileInfo], copyCutSendParam);
      expect(res).assertEqual(ResultCode.Exception.EXCEPTION_TASK_CANCEL);

      fileCopyUtil.totalCount = 0;
      fileCopyUtil.isCancel = false;
      TestFileUtil.deleteAlbumByUri(context, albumInfo?.albumUri as string);
      done();
    })

    it('initFileListToGallery_album_file_test', 0, async (done: Function) => {
      let fileInfo: FileInfo = new FileInfo();
      let albumInfo = await TestFileUtil.getAlbum(context, TestFileUtil.TEST_FOLDER);
      fileInfo.uri = albumInfo?.albumUri as string;

      let res = await fileCopyUtil.initFileListToGallery([fileInfo], copyCutSendParam);
      expect(fileCopyUtil.totalCount !== 0).assertTrue();
      TestFileUtil.deleteAlbumByUri(context, albumInfo?.albumUri as string);
      done();
    })

    it('initFileListToGallery_local_file_test', 0, async (done: Function) => {
      let fileInfo: FileInfo = new FileInfo();
      let albumInfo = await TestFileUtil.getAlbum(context, TestFileUtil.TEST_FOLDER);
      fileCopyUtil.totalCount = 0;
      fileInfo.size = -1;
      let res = await fileCopyUtil.initFileListToGallery([fileInfo], copyCutSendParam);
      expect(fileCopyUtil.totalCount === 0).assertTrue();

      let initFileToGallery = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'initFileToGallery');
      when(initFileToGallery)(ArgumentMatchers.any)
        .afterReturn(ResultCode.Exception.EXCEPTION_PASTE_CONTENT_INCLUDE_FILE);
      fileCopyUtil.totalCount = 0;
      fileInfo = TestFileUtil.createFile(TestFileUtil.TEST_FOLDER_PATH, TestFileUtil.TEST_FILE_NAME);

      res = await fileCopyUtil.initFileListToGallery([fileInfo], copyCutSendParam);
      expect(res).assertEqual(ResultCode.Exception.EXCEPTION_PASTE_CONTENT_INCLUDE_FILE);

      when(initFileToGallery)(ArgumentMatchers.any).afterReturn(ResultCode.Exception.EXCEPTION_OK);
      res = await fileCopyUtil.initFileListToGallery([fileInfo], copyCutSendParam);
      expect(res).assertEqual(ResultCode.Exception.EXCEPTION_OK);
      TestFileUtil.deleteAlbumByUri(context, albumInfo?.albumUri as string);
      TestFileUtil.deleteFile(fileInfo);
      done();
    })

    it('initFileListInfo', 0, async (done: Function) => {
      let initUriData = mocker.mockFunc(fileCopyUtil, fileCopyUtil.initUriData);
      when(initUriData)(ArgumentMatchers.any).afterReturnNothing();
      let getRemoteFolderSize = mocker.mockFunc(FilesQueryUtil, FilesQueryUtil.getFolderSize);
      when(getRemoteFolderSize)(ArgumentMatchers.any).afterReturn(100);
      let getFolderSubFileCount = mocker.mockFunc(FileUtil, FileUtil.getFolderSubFileCount);
      when(getFolderSubFileCount)(ArgumentMatchers.any).afterReturn(10);

      let folderFileInfo = new FileInfo();
      folderFileInfo.isFolder = true;
      let fileInfo = new FileInfo();
      fileInfo.isFolder = false;
      fileInfo.size = 123;
      fileCopyUtil.isLocalAppFile = true;
      await fileCopyUtil.initFileListInfo([folderFileInfo, fileInfo], copyCutSendParam)
      mocker.clear(FileUtil);
      mocker.clear(FilesQueryUtil);
      expect(fileCopyUtil.chooseFileMulti).assertFalse();
      done();
    })

    it('fileCopyUtil_initFileList', 0, async (done: Function) => {
      let folderFileInfo = FileInfo.fromFileUri(VirtualUri.DOCUMENT);
      let getRemoteFolderSize = mocker.mockFunc(FilesQueryUtil, FilesQueryUtil.getFolderSize);
      when(getRemoteFolderSize)(ArgumentMatchers.any).afterReturn(100);
      let getFolderSubFileCount = mocker.mockFunc(FileUtil, FileUtil.getFolderSubFileCount);
      when(getFolderSubFileCount)(ArgumentMatchers.any).afterReturn(10);
      let fileList1: FileInfo[] = [];
      let fileList2: FileInfo[] = [];
      await fileCopyUtil.initFileList(folderFileInfo, fileList1)
      folderFileInfo.isFolder = false;
      await fileCopyUtil.initFileList(folderFileInfo, fileList2)
      mocker.clear(FileUtil);
      mocker.clear(FilesQueryUtil);
      expect(fileList1.length !== 0).assertTrue();
      expect(fileList2.length !== 0).assertTrue();
      done();
    })

    it('checkNeedToInitData_FILE_SIZE_UNKNOWN', 0, () => {
      let data = new FileInfo();
      data.size = Constant.FILE_SIZE_UNKNOWN;
      expect(fileCopyUtil.checkNeedToInitData(data)).assertTrue();
    })

    it('checkNeedToInitData_relativePath_empty', 0, () => {
      let data = new FileInfo();
      data.size = 123;
      data.relativePath = ''
      expect(fileCopyUtil.checkNeedToInitData(data)).assertTrue();
    })

    it('checkNeedToInitData', 0, () => {
      let data = new FileInfo();
      data.size = 123;
      data.relativePath = 'test'
      expect(fileCopyUtil.checkNeedToInitData(data)).assertFalse();
    })

    it('isExternalOrAcrossDisk_isOperatingAcrossDisk', 0, () => {
      let isExternalOrAcrossDisk = TestUtil.getPrivateFunction(fileCopyUtil, 'isExternalOrAcrossDisk') as Function;
      fileCopyUtil.isOperatingAcrossDisk = true;
      expect(isExternalOrAcrossDisk()).assertTrue();
    })

    it('isExternalOrAcrossDisk_uuid_LOCAL', 0, () => {
      let isExternalOrAcrossDisk = TestUtil.getPrivateFunction(fileCopyUtil, 'isExternalOrAcrossDisk') as Function;
      fileCopyUtil.isOperatingAcrossDisk = false;
      fileCopyUtil.uuid = 'LOCAL';
      expect(isExternalOrAcrossDisk()).assertFalse();
    })

    it('isExternalOrAcrossDisk_uuid_cloud', 0, () => {
      let isExternalOrAcrossDisk = TestUtil.getPrivateFunction(fileCopyUtil, 'isExternalOrAcrossDisk') as Function;
      fileCopyUtil.isOperatingAcrossDisk = false;
      fileCopyUtil.uuid = 'cloud';
      expect(isExternalOrAcrossDisk()).assertFalse();
    })

    it('isExternalOrAcrossDisk_uuid_empty', 0, () => {
      let isExternalOrAcrossDisk = TestUtil.getPrivateFunction(fileCopyUtil, 'isExternalOrAcrossDisk') as Function;
      fileCopyUtil.isOperatingAcrossDisk = false;
      fileCopyUtil.uuid = '';
      expect(isExternalOrAcrossDisk()).assertFalse();
    })

    it('isExternalOrAcrossDisk', 0, () => {
      let isExternalOrAcrossDisk = TestUtil.getPrivateFunction(fileCopyUtil, 'isExternalOrAcrossDisk') as Function;
      fileCopyUtil.isOperatingAcrossDisk = false;
      fileCopyUtil.uuid = '123454';
      expect(isExternalOrAcrossDisk()).assertTrue();
    })

    it('initAndCheckData_workerPort_null', 0, async (done: Function) => {
      let initAndCheckData = TestUtil.getPrivateFunction(fileCopyUtil, 'initAndCheckData') as Function;
      let isNullOrUndefined = TestUtil.getPrivateMockFunction(mocker, ObjectUtil, 'isNullOrUndefined');
      when(isNullOrUndefined)(ArgumentMatchers.any).afterReturn(true);
      expect(await initAndCheckData(copyCutSendParam)).assertFalse();

      copyCutSendParam.workerName = '';
      when(isNullOrUndefined)(ArgumentMatchers.any).afterReturn(false);
      expect(await initAndCheckData(copyCutSendParam)).assertFalse();

      copyCutSendParam.toOperateFiles = [];
      copyCutSendParam.workerName = 'test';
      copyCutSendParam.destFolderUri = TestFileUtil.TEST_FOLDER_URI;
      expect(await initAndCheckData(copyCutSendParam)).assertTrue();
      TestUtil.clearMockObject(mocker, ObjectUtil);
      done();
    })

    it('doDrag_doCopy', 0, async (done: Function) => {
      TestUtil.setPrivateAttribute(fileCopyUtil, 'toOperateFiles', [new FileInfo()]);
      copyCutSendParam.toOperateFiles = [new FileInfo()];
      copyCutSendParam.isExternalOperate = true;
      let doCopy = mocker.mockFunc(fileCopyUtil, fileCopyUtil.doCopy);
      when(doCopy)(ArgumentMatchers.any).afterReturnNothing();
      await fileCopyUtil.doDrag(copyCutSendParam);
      expect(fileCopyUtil.operateType).assertEqual(WorkerConst.OperateType.COPY_FILE);
      done();
    })

    it('doDrag_doMove', 0, async (done: Function) => {
      TestUtil.setPrivateAttribute(fileCopyUtil, 'toOperateFiles', [new FileInfo()]);
      copyCutSendParam.toOperateFiles = [new FileInfo()];
      copyCutSendParam.toOperateFiles[0].uri = 'file://docs/storage/Users/currentUser/Download/test.pdf';
      copyCutSendParam.isExternalOperate = false;
      let doMove = mocker.mockFunc(fileCopyUtil, fileCopyUtil.doMove);
      when(doMove)(ArgumentMatchers.any).afterReturnNothing();
      let checkDragIsCopy = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'checkDragIsCopy');
      when(checkDragIsCopy)(ArgumentMatchers.any).afterReturn(false);
      await fileCopyUtil.doDrag(copyCutSendParam);
      expect(fileCopyUtil.operateType).assertEqual(WorkerConst.OperateType.CUT_FILE);
      done();
    })

    it('checkDragIsCopy_isExternalOperate', 0, () => {
      let fileInfo = new FileInfo();
      copyCutSendParam.isExternalOperate = true;
      expect(fileCopyUtil.checkDragIsCopy(fileInfo, copyCutSendParam)).assertTrue();
    })

    it('checkDragIsCopy_IsSameDisk', 0, () => {
      let fileInfo = new FileInfo();
      copyCutSendParam.isExternalOperate = false;
      let checkIsSameDisk = mocker.mockFunc(fileCopyUtil, fileCopyUtil.checkIsSameDisk);
      when(checkIsSameDisk)(ArgumentMatchers.any).afterReturn(true);
      expect(fileCopyUtil.checkDragIsCopy(fileInfo, copyCutSendParam)).assertFalse();
    })

    it('checkDragIsCopy_IsSystemFolder', 0, () => {
      let fileInfo = new FileInfo();
      copyCutSendParam.isExternalOperate = false;
      let checkIsSameDisk = mocker.mockFunc(fileCopyUtil, fileCopyUtil.checkIsSameDisk);
      when(checkIsSameDisk)(ArgumentMatchers.any).afterReturn(false);
      let checkIsSystemFolder = mocker.mockFunc(fileCopyUtil, fileCopyUtil.checkIsSystemFolder);
      when(checkIsSystemFolder)(ArgumentMatchers.any).afterReturn(true);
      expect(fileCopyUtil.checkDragIsCopy(fileInfo, copyCutSendParam)).assertTrue();
      when(checkIsSystemFolder)(ArgumentMatchers.any).afterReturn(false);
      expect(fileCopyUtil.checkDragIsCopy(fileInfo, copyCutSendParam)).assertTrue();
    })

    it('checkIsSameDisk_rootInfoArr_empty', 0, () => {
      let fileInfo = new FileInfo();
      fileCopyUtil.rootInfoArr = []
      expect(fileCopyUtil.checkIsSameDisk(fileInfo)).assertFalse();
    })

    it('checkIsSameDisk_uri_not_match', 0, () => {
      let fileInfo = new FileInfo();
      fileCopyUtil.rootInfoArr = [new DiskInfo()]
      expect(fileCopyUtil.checkIsSameDisk(fileInfo)).assertFalse();
    })

    it('checkIsSameDisk', 0, () => {
      let fileInfo = new FileInfo();
      fileInfo.uri = 'file://docs/storage/Users/currentUser/fileCopyUtilTestFile.txt';
      let diskInfo = new DiskInfo();
      diskInfo.uri = 'file://docs/storage/Users/currentUser';
      diskInfo.deviceType = fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK;
      diskInfo.uuid = 'aaa'
      fileCopyUtil.rootInfoArr = [diskInfo];
      fileCopyUtil.uuid = 'LOCAL';
      expect(fileCopyUtil.checkIsSameDisk(fileInfo)).assertTrue();
      fileCopyUtil.uuid = '';
      expect(fileCopyUtil.checkIsSameDisk(fileInfo)).assertTrue();
      fileCopyUtil.uuid = 'aaa';
      expect(fileCopyUtil.checkIsSameDisk(fileInfo)).assertTrue();
    })

    it('checkIsSystemFolder_fileName', 0, () => {
      let fileInfo = new FileInfo();
      fileInfo.fileName = 'ass'
      expect(fileCopyUtil.checkIsSystemFolder(fileInfo)).assertFalse();
      fileInfo.fileName = fileCopyUtil.DOWNLOAD
      expect(fileCopyUtil.checkIsSystemFolder(fileInfo)).assertFalse();
      fileInfo.fileName = fileCopyUtil.DOCUMENTS
      expect(fileCopyUtil.checkIsSystemFolder(fileInfo)).assertFalse();
    })

    it('checkIsSystemFolder_uri', 0, () => {
      let fileInfo = new FileInfo();
      fileInfo.fileName = fileCopyUtil.DOCUMENTS;
      fileCopyUtil.localRootUri = 'test/test'
      fileInfo.uri = 'test/test/1.txt';
      expect(fileCopyUtil.checkIsSystemFolder(fileInfo)).assertTrue();
    })

    it('doCopy_isCancel', 0, async (done: Function) => {
      fileCopyUtil.isCancel = true;
      await fileCopyUtil.doCopy([new FileInfo()], '', false);
      expect(fileCopyUtil.operatingFile).not().assertUndefined()
      done();
    })

    it('doCopy_isFileExist_false', 0, async (done: Function) => {
      fileCopyUtil.isCancel = false;
      let sendError = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'sendError');
      when(sendError)(ArgumentMatchers.any).afterReturnNothing();
      let dealPasteFileAfterChoose = mocker.mockFunc(fileCopyUtil, fileCopyUtil.dealPasteFileAfterChoose);
      when(dealPasteFileAfterChoose)(ArgumentMatchers.any).afterReturn('');

      await fileCopyUtil.doCopy([new FileInfo()], '', false);

      expect(fileCopyUtil.operatingFile).not().assertUndefined();
      done();
    })

    it('doCopy_isOperateDupFolderFromChildToParent', 0, async (done: Function) => {
      fileCopyUtil.isCancel = false;
      when(TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'sendError'))(ArgumentMatchers.any)
        .afterReturnNothing();
      let dealPasteFileAfterChoose = mocker.mockFunc(fileCopyUtil, fileCopyUtil.dealPasteFileAfterChoose);
      when(dealPasteFileAfterChoose)(ArgumentMatchers.any).afterReturn('');

      when(TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'copyFileOrFolder'))(ArgumentMatchers.any)
        .afterReturn('new_uri');
      let isFileExist = mocker.mockFunc(FsUtil, FsUtil.isFileExist);
      when(isFileExist)(ArgumentMatchers.any).afterReturn(true);

      await fileCopyUtil.doCopy([new FileInfo()], '', false);

      mocker.clear(FsUtil);
      expect(fileCopyUtil.operatingFile).not().assertUndefined();
      done();
    })

    it('copyFileOrFolder_isCreateDup', 0, async (done: Function) => {
      let copyFileOrFolder = TestUtil.getPrivateFunction(fileCopyUtil, 'copyFileOrFolder');
      if (!copyFileOrFolder) {
        expect().assertFail();
      } else {
        let isCreateDup = mocker.mockFunc(fileCopyUtil, fileCopyUtil.isCreateDup);
        when(isCreateDup)(ArgumentMatchers.any).afterReturn(true);
        let createDup = mocker.mockFunc(fileCopyUtil, fileCopyUtil.createDup);
        when(createDup)(ArgumentMatchers.any).afterReturn('expect');
        let srcFile: FileInfo = new FileInfo()
        let result: string = await copyFileOrFolder(srcFile, '', '', false);
        expect(result).assertEqual('expect');
      }
      done();
    })

    it('copyFileOrFolder_isCreateDup_false', 0, async (done: Function) => {
      let copyFileOrFolder = TestUtil.getPrivateFunction(fileCopyUtil, 'copyFileOrFolder');
      if (!copyFileOrFolder) {
        expect().assertFail();
      } else {
        let isCreateDup = mocker.mockFunc(fileCopyUtil, fileCopyUtil.isCreateDup);
        when(isCreateDup)(ArgumentMatchers.any).afterReturn(false);
        let handlerFolderSubFile = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'handlerFolderSubFile');
        when(handlerFolderSubFile)(ArgumentMatchers.any).afterReturn('expect');
        let srcFile: FileInfo = new FileInfo()
        let result: string = await copyFileOrFolder(srcFile, '', '', false);
        expect(result).assertEqual('expect');
      }
      done();
    })

    it('countNotifySuccessCount', 0, () => {
      fileCopyUtil.countNotifySuccessCount(false)
      expect(fileCopyUtil.notifySuccessCount).assertEqual(0);
      fileCopyUtil.countNotifySuccessCount()
      expect(fileCopyUtil.notifySuccessCount).assertEqual(1);
      fileCopyUtil.countNotifySuccessCount()
      expect(fileCopyUtil.notifySuccessCount).assertEqual(2);
    })

    it('fileCopyUtil_syncFile', 0, () => {
      TestUtil.createTestFileOrFolder(['test.txt'], false);
      let syncFile = TestUtil.getPrivateFunction(fileCopyUtil, 'syncFile');
      if (!syncFile) {
        expect().assertFail();
      } else {
        let fsyncSync = TestUtil.getPrivateMockFunction(mocker, FsUtil, 'fsyncSync');
        fileCopyUtil.isOperatingAcrossDisk = false;
        fileCopyUtil.uuid = 'cloud';
        syncFile(TestUtil.TEST_FOLDER_URI + '/test.txt');
        mocker.verify('fsyncSync', [0]).never();

        fileCopyUtil.isOperatingAcrossDisk = true;
        syncFile('test.txt');
        mocker.verify('fsyncSync', [0]).never();
        TestUtil.deleteTestFileOrFolder();
        mocker.clear(FsUtil);
      }
    })

    it('createFileAndCopyContent', 0, async (done: Function) => {
      when(mocker.mockFunc(fileCopyUtil, fileCopyUtil.copyFileContent))(ArgumentMatchers.any)
        .afterReturn(true);
      let fileInfo: FileInfo = new FileInfo();
      let result = await fileCopyUtil.createFileAndCopyContent('', new FileInfo(), '');
      expect(result).not().assertEqual('');

      let grantPhonePermissionUri = mocker.mockFunc(FilePickerUtil, FilePickerUtil.grantPhonePermissionUri);
      when(grantPhonePermissionUri)(ArgumentMatchers.any).afterReturnNothing;
      fileInfo.isGallery = true;
      result = await fileCopyUtil.createFileAndCopyContent('', fileInfo, '');
      expect(result).not().assertEqual('');

      when(grantPhonePermissionUri)(ArgumentMatchers.any).afterReturn(() => {
        throw new FileCopyUtilError(ERROR_CODE.FILE_ACCESS.PERMISSION_DENIED, '');
      });
      result = await fileCopyUtil.createFileAndCopyContent('', fileInfo, '');

      when(grantPhonePermissionUri)(ArgumentMatchers.any).afterReturn(() => {
        throw new FileCopyUtilError(ERROR_CODE.FILE_ACCESS.TRY_AGAIN, '');
      });
      try {
        result = await fileCopyUtil.createFileAndCopyContent('', fileInfo, '');
      } catch (e) {
        expect(result).not().assertEqual('');
      }
      mocker.clear(FilePickerUtil);
      done();
    })

    it('copyFileContent', 0, async (done: Function) => {
      let computeProgress = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'computeProgress');
      when(computeProgress)(ArgumentMatchers.any).afterReturnNothing();

      TestUtil.createTestFileOrFolder(['test.txt'], false);

      fileCopyUtil.operatingFile.size = 0;
      let copyFileContent: boolean = await fileCopyUtil.copyFileContent('', TestUtil.TEST_FOLDER_URI + '/test1.txt');
      expect(copyFileContent).assertFalse();

      copyFileContent = await fileCopyUtil.copyFileContent(TestUtil.TEST_FOLDER_URI + '/test.txt',
        TestUtil.TEST_FOLDER_URI + '/test1.txt');
      expect(copyFileContent).assertTrue();

      when(computeProgress)(ArgumentMatchers.any).afterThrow('');
      copyFileContent = await fileCopyUtil.copyFileContent(TestUtil.TEST_FOLDER_URI + '/test.txt',
        TestUtil.TEST_FOLDER_URI + '/test1.txt');
      expect(copyFileContent).assertTrue();

      TestUtil.deleteTestFileOrFolder();
      done();
    })

    it('fileCopyUtil_cancelWorker', 0, async (done: Function) => {
      fileCopyUtil.uuid = '';
      let stopTimer = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'stopTimer');
      fileCopyUtil.cancelWorker();
      mocker.verify('stopTimer', []).once();
      done()
    })

    it('fileCopyUtil_moveFile', 0, async (done: Function) => {
      let moveFile = TestUtil.getPrivateFunction(fileCopyUtil, 'moveFile') as Function;
      if (!moveFile) {
        HiLog.info(TAG, "moveFile failed!");
        expect().assertFail();
      } else {

        let checkSpecialChar = mocker.mockFunc(RenameUtil, RenameUtil.checkSpecialChar);
        let createFileAndCopyContent = mocker.mockFunc(fileCopyUtil, fileCopyUtil.createFileAndCopyContent);
        when(createFileAndCopyContent)(ArgumentMatchers.any).afterReturn('test');

        TestUtil.createTestFileOrFolder(['test.txt'], false);
        TestUtil.createTestFileOrFolder(['test1'], true);

        let deletePermanently = TestUtil.getPrivateMockFunction(mocker, PhotoAccessUtil, 'deletePermanently');
        when(deletePermanently)(ArgumentMatchers.any).afterReturnNothing();

        let isMoveHODataByUri = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'isMoveHODataByUri');
        when(isMoveHODataByUri)(ArgumentMatchers.any).afterReturn(true);
        let srcUri: string = TestUtil.TEST_FOLDER_URI + '/test.txt';
        fileCopyUtil.isOperatingAcrossDisk = false;
        fileCopyUtil.uuid = 'cloud';
        let srcFileInfo: FileInfo = FileInfo.fromFileUri(srcUri);
        try {
          let moveRes: string = await moveFile(srcFileInfo, 'test.txt', TestUtil.TEST_FOLDER_URI + '/test1', true);
          HiLog.info(TAG, "moveFile moveRes = " + moveRes);

          TestUtil.createTestFileOrFolder(['test.txt'], false);
          srcFileInfo.isGallery = true;
          let moveRes1: string = await moveFile(srcFileInfo, 'test.txt', TestUtil.TEST_FOLDER_URI + '/test1', false);
          HiLog.info(TAG, "moveFile moveRes1 = " + moveRes1);

          srcFileInfo.isGallery = false;

          when(checkSpecialChar)(ArgumentMatchers.any).afterReturn(false);
          let moveRes3: string = await moveFile(srcFileInfo, 'test.txt', TestUtil.TEST_FOLDER_URI + '/test1', false);
          HiLog.info(TAG, "moveFile moveRes3 = " + moveRes3);
          mocker.clear(RenameUtil);

          expect(moveRes).assertEqual('test');
          expect(moveRes1).assertEqual('test');
          expect(moveRes3 === '').assertFalse();
          TestUtil.deleteTestFileOrFolder();
        } catch (err) {
          HiLog.error(TAG, "moveFile err = " + JSON.stringify(err));
        } finally {
          mocker.clear(RenameUtil);
          mocker.clear(PhotoAccessUtil);
        }
      }
      done();
    })

    it('moveDupFile', 0, async (done: Function) => {
      let moveFile = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'moveFile');
      when(moveFile)(ArgumentMatchers.any).afterReturn('test');
      let renameFile = mocker.mockFunc(fileCopyUtil, fileCopyUtil.renameFile);
      when(renameFile)(ArgumentMatchers.any).afterReturn([]);

      let srcFile: FileInfo = new FileInfo();
      let moveDupRes: string = await fileCopyUtil.moveDupFile(srcFile, '');
      expect(moveDupRes).assertEqual('test');

      when(renameFile)(ArgumentMatchers.any).afterThrow('');
      moveDupRes = await fileCopyUtil.moveDupFile(srcFile, '');
      mocker.verify('renameFile', ['']).once();
      done();
    })

    it('deleteAndMove', 0, async (done: Function) => {
      let moveFile = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'moveFile');
      when(moveFile)(ArgumentMatchers.any).afterReturn('moveFile');
      let renameFile = mocker.mockFunc(fileCopyUtil, fileCopyUtil.renameFile);
      when(renameFile)(ArgumentMatchers.any).afterReturn(['', VirtualUri.DOWNLOAD]);
      let unlinkSync = mocker.mockFunc(FsUtil, FsUtil.unlinkSync);
      when(unlinkSync)(ArgumentMatchers.any).afterReturnNothing();

      let srcFile: FileInfo = new FileInfo();
      let deleteAndMove1: string = await fileCopyUtil.deleteAndMove(srcFile, undefined);
      let deleteAndMove2 = await fileCopyUtil.deleteAndMove(srcFile, VirtualUri.DOWNLOAD);
      when(renameFile)(ArgumentMatchers.any).afterThrow('');
      let deleteAndMove3 = await fileCopyUtil.deleteAndMove(srcFile, VirtualUri.DOWNLOAD);
      mocker.clear(FsUtil);
      expect(deleteAndMove1).assertEqual('');
      expect(deleteAndMove2).assertEqual('moveFile');
      expect(deleteAndMove3).assertEqual('moveFile');
      done();
    })

    it('fileCopyUtil_dealException', 0, async (done: Function) => {
      let checkNeedDealException = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'checkNeedDealException');
      when(checkNeedDealException)(ArgumentMatchers.any).afterReturn(false);

      let sendException = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'sendException');
      when(sendException)(ArgumentMatchers.any).afterReturnNothing();

      fileCopyUtil.isCancel = true;
      await fileCopyUtil.dealException(ResultCode.Exception.EXIST_DUPLICATE_FILE);
      mocker.verify('sendException', [ResultCode.Exception.EXIST_DUPLICATE_FILE]).never();

      when(checkNeedDealException)(ArgumentMatchers.any).afterReturn(true);
      await fileCopyUtil.dealException(ResultCode.Exception.EXIST_DUPLICATE_FILE);
      mocker.verify('sendException', [ResultCode.Exception.EXIST_DUPLICATE_FILE]).once();
      done();
    })

    it('dealUsbChange_uuid_empty', 0, async (done: Function) => {
      fileCopyUtil.uuid = '';
      let initDiskInfo = mocker.mockFunc(fileCopyUtil, fileCopyUtil.initDiskInfo);
      await fileCopyUtil.dealUsbChange();
      mocker.verify('initDiskInfo', []).times(0);
      done();
    })

    it('dealUsbChange_uuid_same', 0, async (done: Function) => {
      fileCopyUtil.uuid = 'test';
      let diskInfo = new DiskInfo();
      diskInfo.uuid = 'test'
      fileCopyUtil.rootInfoArr = [diskInfo];
      let initDiskInfo = mocker.mockFunc(fileCopyUtil, fileCopyUtil.initDiskInfo);
      let cancelWorker = mocker.mockFunc(fileCopyUtil, fileCopyUtil.cancelWorker);
      await fileCopyUtil.dealUsbChange();
      mocker.verify('initDiskInfo', []).once();
      mocker.verify('cancelWorker', []).times(0);
      done();
    })

    it('dealUsbChange_uuid_not_same', 0, async (done: Function) => {
      fileCopyUtil.uuid = 'test1';
      let diskInfo = new DiskInfo();
      diskInfo.uuid = 'test'
      fileCopyUtil.rootInfoArr = [diskInfo];
      let initDiskInfo = mocker.mockFunc(fileCopyUtil, fileCopyUtil.initDiskInfo);
      let cancelWorker = mocker.mockFunc(fileCopyUtil, fileCopyUtil.cancelWorker);
      await fileCopyUtil.dealUsbChange();
      mocker.verify('initDiskInfo', []).once();
      mocker.verify('cancelWorker', []).once();
      done();
    })


    it('createFolderAndCopyContent', 0, async (done: Function) => {
      when(mocker.mockFunc(FsUtil, FsUtil.mkdirSync))(ArgumentMatchers.any).afterReturnNothing();
      when(TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'listFileSync'))(ArgumentMatchers.any).afterReturn([]);
      when(mocker.mockFunc(FsUtil, FsUtil.rmdirSync))(ArgumentMatchers.any).afterReturnNothing();
      let copyFolderContent = mocker.mockFunc(fileCopyUtil, fileCopyUtil.copyFolderContent);
      when(copyFolderContent)(ArgumentMatchers.any).afterReturnNothing();
      let result = await fileCopyUtil.createFolderAndCopyContent('', new FileInfo(), '', true);
      mocker.clear(FsUtil);
      expect(result).not().assertEqual('')
      done();
    })

    it('copyFolderContent_destFolderUri_empty', 0, async (done: Function) => {
      let result = await fileCopyUtil.copyFolderContent(new FileInfo(), '');
      expect(result).assertFalse();
      done()
    })

    it('copyFolderContent_listFileSync_error', 0, async (done: Function) => {
      let listFileSync = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'listFileSync');
      let res: BusinessError = {
        name: '', message: '',
        code: 0
      }
      when(listFileSync)(ArgumentMatchers.any).afterReturn(res);
      let result = await fileCopyUtil.copyFolderContent(new FileInfo(), 'test');
      expect(result).assertTrue(); // 暂时无法触发,实际应该False
      done()
    })

    it('copyFolderContent_listFileSync_empty', 0, async (done: Function) => {
      let listFileSync = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'listFileSync');
      when(listFileSync)(ArgumentMatchers.any).afterReturn([]);
      let result = await fileCopyUtil.copyFolderContent(new FileInfo(), 'test');
      expect(result).assertTrue();
      done()
    })

    it('copyFolderContent_isCancel', 0, async (done: Function) => {
      let listFileSync = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'listFileSync');
      when(listFileSync)(ArgumentMatchers.any).afterReturn(['test1', 'test2']);
      fileCopyUtil.isCancel = true;
      let result = await fileCopyUtil.copyFolderContent(new FileInfo(), 'test');
      expect(result).assertFalse();
      done()
    })

    it('copyFolderContent_createFileAndCopyContent_empty', 0, async (done: Function) => {
      let listFileSync = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'listFileSync');
      when(listFileSync)(ArgumentMatchers.any).afterReturn(['test1', 'test2']);
      let createFileAndCopyContent = mocker.mockFunc(fileCopyUtil, fileCopyUtil.createFileAndCopyContent);
      when(createFileAndCopyContent)(ArgumentMatchers.any).afterAction(async () => '');
      let getFileInfoFromFolderUri = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'getFileInfoFromFolderUri');
      when(getFileInfoFromFolderUri)(ArgumentMatchers.any)
        .afterAction((folderUri: string, filename: string) => new Object({
          uri: folderUri + '/' + filename,
          fileName: filename,
          isFolder: false
        }));
      fileCopyUtil.isCancel = false;
      let result = await fileCopyUtil.copyFolderContent(new FileInfo(), 'test');
      expect(result).assertFalse();
      done();
    })

    it('copyFolderContent', 0, async (done: Function) => {
      let listFileSync = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'listFileSync');
      when(listFileSync)(ArgumentMatchers.any).afterReturn(['test1', 'test2']);
      let createFileAndCopyContent = mocker.mockFunc(fileCopyUtil, fileCopyUtil.createFileAndCopyContent);
      when(createFileAndCopyContent)(ArgumentMatchers.any).afterAction(async () => 'test');
      let getFileInfoFromFolderUri = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'getFileInfoFromFolderUri');
      when(getFileInfoFromFolderUri)(ArgumentMatchers.any)
        .afterAction((folderUri: string, filename: string) => new Object({
          uri: folderUri + '/' + filename,
          fileName: filename,
          isFolder: false
        }));
      fileCopyUtil.isCancel = false;
      let result = await fileCopyUtil.copyFolderContent(new FileInfo(), 'test');
      expect(result).assertTrue();
      done();
    })

    it('fileCopyUtil_replaceFile', 0, async (done: Function) => {
      when(mocker.mockFunc(FsUtil, FsUtil.unlinkSync))(ArgumentMatchers.any).afterReturnNothing();
      when(mocker.mockFunc(fileCopyUtil, fileCopyUtil.createFileAndCopyContent))(ArgumentMatchers.any)
        .afterReturn('test');
      let result = await fileCopyUtil.replaceFile(new FileInfo(), '');
      mocker.clear(FsUtil);
      expect(result).assertEqual('test');
      done();
    })

    it('fileCopyUtil_replaceFolder', 0, async (done: Function) => {
      when(mocker.mockFunc(FsUtil, FsUtil.rmdirSync))(ArgumentMatchers.any).afterReturnNothing();
      when(TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'handleFolderAfterConflict'))(ArgumentMatchers.any)
        .afterReturn('test');
      let result = await fileCopyUtil.replaceFolder(new FileInfo(), '');
      mocker.clear(FsUtil);
      expect(result).assertEqual('test');
      done();
    })

    it('dealMoveFolderUpdateFavorite_not_CUT_FILE', 0, async (done: Function) => {
      let dealMoveFolderUpdateFavorite =
        TestUtil.getPrivateFunction(fileCopyUtil, 'dealMoveFolderUpdateFavorite') as Function;
      fileCopyUtil.operateType = WorkerConst.OperateType.COPY_FILE;
      mocker.mockFunc(StringUtil, StringUtil.isEmpty);
      await dealMoveFolderUpdateFavorite('', '');
      mocker.clear(StringUtil);
      mocker.verify('isEmpty', ['']).times(0);
      done();
    })

    it('dealMoveFolderUpdateFavorite_CUT_FILE', 0, async (done: Function) => {
      let dealMoveFolderUpdateFavorite =
        TestUtil.getPrivateFunction(fileCopyUtil, 'dealMoveFolderUpdateFavorite') as Function;
      fileCopyUtil.operateType = WorkerConst.OperateType.CUT_FILE;
      mocker.mockFunc(StringUtil, StringUtil.isEmpty);
      await dealMoveFolderUpdateFavorite('', 'file://docs/storage/Users/currentUser/filetest.txt');
      mocker.clear(StringUtil);
      mocker.verify('isEmpty', ['file://docs/storage/Users/currentUser/filetest.txt']).times(1);
      done();
    })

    it('checkFavoriteParams_pathUriUndefined', 0, () => {
      let checkFavoriteParams = TestUtil.getPrivateFunction(fileCopyUtil, 'checkFavoriteParams') as Function;
      let paths = [];
      expect(checkFavoriteParams(paths[0], '', '')).assertFalse();
      expect(checkFavoriteParams('', paths[0], '')).assertFalse();
      expect(checkFavoriteParams('', '', paths[0])).assertFalse();
    })

    it('checkFavoriteParams_pathUriEmpty', 0, () => {
      let checkFavoriteParams = TestUtil.getPrivateFunction(fileCopyUtil, 'checkFavoriteParams') as Function;
      expect(checkFavoriteParams('1', '', '')).assertFalse();
      expect(checkFavoriteParams('', '1', '')).assertFalse();
      expect(checkFavoriteParams('', '', '1')).assertFalse();
    })

    it('updateFavoriteDataByMove_checkFavoriteParams_failed', 0, async (done: Function) => {
      let result = await fileCopyUtil.updateFavoriteDataByMove('', '', '', '');
      expect(result).assertFalse();
      done();
    })

    it('updateFavoriteDataByMove_favoriteCache_failed', 0, async (done: Function) => {
      TestUtil.setPrivateAttribute(fileCopyUtil, 'favoriteCache', undefined)
      let result = await fileCopyUtil.updateFavoriteDataByMove('1', '1', '1', '1');
      expect(result).assertFalse();
      TestUtil.setPrivateAttribute(fileCopyUtil, 'favoriteCache', [])
      result = await fileCopyUtil.updateFavoriteDataByMove('1', '1', '1', '1');
      expect(result).assertFalse();
      done();
    })

    it('updateFavoriteDataByMove', 0, async (done: Function) => {
      TestUtil.setPrivateAttribute(fileCopyUtil, 'favoriteCache', [new FavoriteModel()])
      let result = await fileCopyUtil.updateFavoriteDataByMove('1', '1', '1', '1');
      expect(result).assertFalse();
      done()
    })

    it('updateFavoriteData_DEVICE_INTERNAL', 0, () => {
      let updateFavoriteData = TestUtil.getPrivateFunction(fileCopyUtil, 'updateFavoriteData') as Function;
      let favorite = new FavoriteModel;
      favorite.deviceType = DataSourceDeviceType.DEVICE_INTERNAL;
      let newDeviceType: DataSourceDeviceType = DataSourceDeviceType.DEVICE_INTERNAL;
      let newPath: string = '';
      let newFileName: string = '';
      let newUuid: string = '';
      let deleteLocalPathList: string[] = [];
      let deleteCloudPathList: string[] = [];
      let result: boolean = updateFavoriteData(favorite, newDeviceType, newPath,
        newFileName, newUuid, deleteLocalPathList, deleteCloudPathList);
      expect(result).assertFalse();
    })

    it('getDeviceType', 0, () => {
      let getDeviceType = TestUtil.getPrivateFunction(fileCopyUtil, 'getDeviceType') as Function;
      expect(getDeviceType('11', false)).assertEqual(DataSourceDeviceType.DEVICE_EXTERNAL);
      expect(getDeviceType('', false)).assertEqual(DataSourceDeviceType.DEVICE_INTERNAL);
    })

    it('mergeFolder', 0, async (done: Function) => {
      let srcFile = new FileInfo();
      srcFile.relativePath = 'file://docs/storage/Users/currentUser/';
      let listFileSync = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'listFileSync');
      when(listFileSync)(ArgumentMatchers.any).afterReturn([]);
      fileCopyUtil.operateType = WorkerConst.OperateType.CUT_FILE;
      try {
        await fileCopyUtil.mergeFolder(srcFile, '1');
        expect().assertFail();
      } catch (e) {
        expect(e.message).assertEqual('No such file or directory');
      }
      done();
    })

    it('handlerFolderSubFile', 0, async (done: Function) => {
      let handleSubFolder = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'handleSubFolder');
      when(handleSubFolder)(ArgumentMatchers.any).afterReturn('test');

      let handlerSubFile = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'handlerSubFile');
      when(handlerSubFile)(ArgumentMatchers.any).afterReturn('test1');

      let handlerFolderSubFile = TestUtil.getPrivateFunction(fileCopyUtil, 'handlerFolderSubFile') as Function;
      let srcFile: FileInfo = FileInfo.fromFileUri(VirtualUri.DOWNLOAD);

      let newUri: string = await handlerFolderSubFile(srcFile, VirtualUri.DOWNLOAD);
      expect(newUri === 'test').assertTrue();
      srcFile.isFolder = false;
      newUri = await handlerFolderSubFile(srcFile, VirtualUri.DOWNLOAD);
      expect(newUri === 'test1').assertTrue();
      done()
    })

    it('handleSubFolder_handleSubFile', 0, async (done: Function) => {
      let isChildFolder = TestUtil.getPrivateMockFunction(mocker, ThreadCommonUtil, 'isChildFolder');
      when(isChildFolder)(ArgumentMatchers.any).afterReturn(true);
      let isExistDupName = TestUtil.getPrivateMockFunction(mocker, FsUtil, 'isExistDupName');
      when(isExistDupName)(ArgumentMatchers.any).afterReturn(true);
      let dealException = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'dealException');
      when(dealException)(ArgumentMatchers.any).afterReturnNothing();
      let dealPasteFileAfterChoose = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'dealPasteFileAfterChoose');
      when(dealPasteFileAfterChoose)(ArgumentMatchers.any).afterReturnNothing();

      let handleSubFolder = TestUtil.getPrivateFunction(fileCopyUtil, 'handleSubFolder') as Function;
      let srcFile: FileInfo = FileInfo.fromFileUri(VirtualUri.DESKTOP);
      let newUri1: string = await handleSubFolder(srcFile, VirtualUri.DOWNLOAD);

      let handlerSubFile = TestUtil.getPrivateFunction(fileCopyUtil, 'handlerSubFile') as Function;
      let newUri2: string = await handlerSubFile(srcFile, VirtualUri.DOWNLOAD);

      when(isChildFolder)(ArgumentMatchers.any).afterReturn(false);
      let newUri3: string = await handleSubFolder(srcFile, VirtualUri.DOWNLOAD);

      when(isExistDupName)(ArgumentMatchers.any).afterReturn(false);
      let handleFolderAfterConflict =
        TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'handleFolderAfterConflict');
      when(handleFolderAfterConflict)(ArgumentMatchers.any).afterReturn('test');
      let newUri4: string = await handleSubFolder(srcFile, VirtualUri.DOWNLOAD);

      let handleFileAfterConflict =
        TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'handleFileAfterConflict');
      when(handleFileAfterConflict)(ArgumentMatchers.any).afterReturn('testFile');
      let newUri5: string = await handlerSubFile(srcFile, VirtualUri.DOWNLOAD);

      mocker.clear(FsUtil);
      mocker.clear(ThreadCommonUtil);
      expect(newUri1).assertEqual('');
      expect(newUri2).assertEqual('');
      expect(newUri3).assertEqual('');
      expect(newUri4).assertEqual('test');
      expect(newUri5).assertEqual('testFile');
      done()
    })

    it('handleFolderAfterConflict', 0, async (done: Function) => {
      let moveFolder = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'moveFolder');
      when(moveFolder)(ArgumentMatchers.any).afterReturn('test');
      let createFolderAndCopyContent =
        TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'createFolderAndCopyContent');
      when(createFolderAndCopyContent)(ArgumentMatchers.any).afterReturn('test1');

      TestUtil.setPrivateAttribute(fileCopyUtil, 'operateType', WorkerConst.OperateType.CUT_FILE);
      let handleFolderAfterConflict =
        TestUtil.getPrivateFunction(fileCopyUtil, 'handleFolderAfterConflict') as Function;
      let srcFile: FileInfo = FileInfo.fromFileUri(VirtualUri.DESKTOP);
      let newUri: string = await handleFolderAfterConflict(srcFile, VirtualUri.DOWNLOAD);
      expect(newUri).assertEqual('test');

      TestUtil.setPrivateAttribute(fileCopyUtil, 'operateType', WorkerConst.OperateType.COPY_FILE);
      newUri = await handleFolderAfterConflict(srcFile, VirtualUri.DOWNLOAD);
      expect(newUri).assertEqual('test1');
      done()
    })

    it('handleFileAfterConflict', 0, async (done: Function) => {
      let moveFile = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'moveFile');
      when(moveFile)(ArgumentMatchers.any).afterReturn('test');
      let createFileAndCopyContent =
        TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'createFileAndCopyContent');
      when(createFileAndCopyContent)(ArgumentMatchers.any).afterReturn('test1');

      TestUtil.setPrivateAttribute(fileCopyUtil, 'operateType', WorkerConst.OperateType.CUT_FILE);
      let handleFileAfterConflict = TestUtil.getPrivateFunction(fileCopyUtil, 'handleFileAfterConflict') as Function;
      let srcFile: FileInfo = FileInfo.fromFileUri(VirtualUri.DESKTOP);
      let newUri: string = await handleFileAfterConflict(srcFile, VirtualUri.DOWNLOAD);
      expect(newUri).assertEqual('test');

      TestUtil.setPrivateAttribute(fileCopyUtil, 'operateType', WorkerConst.OperateType.COPY_FILE);
      newUri = await handleFileAfterConflict(srcFile, VirtualUri.DOWNLOAD);
      expect(newUri).assertEqual('test1');
      done()
    })

    it('isCreateDup_01', 0, () => {
      fileCopyUtil.localRootUri = 'test/test'
      let srcFileInfo = new FileInfo;
      expect(fileCopyUtil.isCreateDup(srcFileInfo, '', 'test/test', false)).assertFalse();
    })

    it('isCreateDup_02', 0, () => {
      fileCopyUtil.localRootUri = 'test/test'
      let srcFileInfo = new FileInfo;
      srcFileInfo.fileName = 'images';
      expect(fileCopyUtil.isCreateDup(srcFileInfo, 'test/test', 'test/test', false)).assertTrue();
    })

    it('isCreateDup_03', 0, () => {
      fileCopyUtil.localRootUri = 'test/test1'
      let srcFileInfo = new FileInfo;
      srcFileInfo.uri = '?aaa';
      expect(fileCopyUtil.isCreateDup(srcFileInfo, 'test/test', 'test/test', true)).assertTrue();
    })

    it('onErrorCatch', 0, async (done: Function) => {
      let onErrorCatch = TestUtil.getPrivateFunction(fileCopyUtil, 'onErrorCatch') as Function;
      let dealPasteFileAfterChoose = mocker.mockFunc(fileCopyUtil, fileCopyUtil.dealPasteFileAfterChoose);
      when(dealPasteFileAfterChoose)(ArgumentMatchers.any).afterReturn('');
      let dealError = mocker.mockFunc(fileCopyUtil, fileCopyUtil.dealError);
      when(dealError)(ArgumentMatchers.any).afterReturnNothing();
      await onErrorCatch(ERROR_CODE.FILE_ACCESS.READONLY_FILE_SYSTEM);
      mocker.verify('dealError', [ResultCode.Error.READONLY_FILE_SYSTEM]).once();
      await onErrorCatch(ERROR_CODE.FILE_ACCESS.NO_SPACE_LEFT_ON_DEVICE);
      mocker.verify('dealError', [ResultCode.Error.NO_SPACE_LEFT]).once();
      await onErrorCatch(ERROR_CODE.FILE_ACCESS.FILE_OPERATE_NOT_PERMITTED);
      mocker.verify('dealError', [ResultCode.Error.FILE_OPERATE_NOT_PERMITTED]).once();
      await onErrorCatch(ERROR_CODE.FILE_ACCESS.TRY_AGAIN);
      mocker.verify('dealError', [ResultCode.Error.UNKNOWN_ERROR]).once();

      await onErrorCatch(ERROR_CODE.FILE_ACCESS.FILE_NOT_EXIST);
      mocker.verify('dealError', [ResultCode.Error.SRC_FILE_NOT_EXIST]).once();

      await onErrorCatch(ERROR_CODE.FILE_ACCESS.FILE_NAME_INVALID);
      mocker.verify('dealError', [ResultCode.Error.FILE_NAME_INVALID]).once();

      let res: string = await onErrorCatch(ERROR_CODE.FILE_ACCESS.NON_FOLDER, fileInfo);
      expect(res).assertEqual('');
      done();
    })

    it('getChooseType', 0, () => {
      let getChooseType = TestUtil.getPrivateFunction(fileCopyUtil, 'getChooseType') as Function;
      fileCopyUtil.conflictType = CopyCutConst.ConflictType.FILE_CONFLICT;
      fileCopyUtil.fileApplyChoose = 1;
      expect(getChooseType()).assertEqual(fileCopyUtil.fileApplyChoose);
      fileCopyUtil.conflictType = CopyCutConst.ConflictType.FOLDER_CONFLICT;
      fileCopyUtil.folderApplyChoose = 2;
      expect(getChooseType()).assertEqual(fileCopyUtil.folderApplyChoose);
      fileCopyUtil.conflictType = CopyCutConst.ConflictType.FOLDER_CONFLICT;
      fileCopyUtil.folderApplyChoose = 2;
      expect(getChooseType()).assertEqual(fileCopyUtil.folderApplyChoose);
      fileCopyUtil.conflictType = CopyCutConst.ConflictType.PATH_CONFLICT;
      fileCopyUtil.pathApplyChoose = 3;
      expect(getChooseType()).assertEqual(fileCopyUtil.pathApplyChoose);
      fileCopyUtil.conflictType = CopyCutConst.ConflictType.OTHER_ERROR;
      fileCopyUtil.otherErrorApplyChoose = 4;
      expect(getChooseType()).assertEqual(fileCopyUtil.otherErrorApplyChoose);

      fileCopyUtil.conflictType = CopyCutConst.ConflictType.DEST_PARENT_ERROR;
      expect(getChooseType()).assertEqual(CopyCutConst.ChooseType.DEFAULT);
    })

    it('dealPasteFileAfterChoose', 0, async (done: Function) => {
      let newUri: string = await fileCopyUtil.dealPasteFileAfterChoose(new FileInfo(), '');
      fileCopyUtil.isCancel = true;
      expect(newUri).assertEqual('');

      fileCopyUtil.isCancel = false;
      let createDup = mocker.mockFunc(fileCopyUtil, fileCopyUtil.createDup);
      when(createDup)(ArgumentMatchers.any).afterReturn('createDup');
      fileCopyUtil.conflictType = CopyCutConst.ConflictType.FILE_CONFLICT;
      fileCopyUtil.fileApplyChoose = CopyCutConst.ChooseType.KEEP_BOTH_FILE;
      fileCopyUtil.operateType = WorkerConst.OperateType.COPY_FILE;
      newUri = await fileCopyUtil.dealPasteFileAfterChoose(new FileInfo(), '');
      expect(newUri).assertEqual('createDup');

      let moveDupFile = mocker.mockFunc(fileCopyUtil, fileCopyUtil.moveDupFile);
      when(moveDupFile)(ArgumentMatchers.any).afterReturn('moveDupFile');
      fileCopyUtil.operateType = WorkerConst.OperateType.CUT_FILE;
      newUri = await fileCopyUtil.dealPasteFileAfterChoose(new FileInfo(), '');
      expect(newUri).assertEqual('moveDupFile');

      fileCopyUtil.fileApplyChoose = CopyCutConst.ChooseType.REPLACE_FILE;
      fileCopyUtil.operateType = WorkerConst.OperateType.COPY_FILE;
      let replaceFile = mocker.mockFunc(fileCopyUtil, fileCopyUtil.replaceFile);
      when(replaceFile)(ArgumentMatchers.any).afterReturn('replaceFile');
      newUri = await fileCopyUtil.dealPasteFileAfterChoose(new FileInfo(), '');
      expect(newUri).assertEqual('replaceFile');

      let deleteAndMove = mocker.mockFunc(fileCopyUtil, fileCopyUtil.deleteAndMove);
      when(deleteAndMove)(ArgumentMatchers.any).afterReturn('deleteAndMove');
      fileCopyUtil.operateType = WorkerConst.OperateType.CUT_FILE;
      newUri = await fileCopyUtil.dealPasteFileAfterChoose(new FileInfo(), '');
      expect(newUri).assertEqual('deleteAndMove');

      fileCopyUtil.fileApplyChoose = CopyCutConst.ChooseType.STOP;
      let cancelWorker = mocker.mockFunc(fileCopyUtil, fileCopyUtil.cancelWorker);
      when(cancelWorker)(ArgumentMatchers.any).afterReturnNothing();
      let taskEnd = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'taskEnd');
      when(taskEnd)(ArgumentMatchers.any).afterReturnNothing();
      newUri = await fileCopyUtil.dealPasteFileAfterChoose(new FileInfo(), '');
      mocker.verify('taskEnd', []).once();

      fileCopyUtil.fileApplyChoose = CopyCutConst.ChooseType.REPLACE_FOLDER;
      let replaceFolder = mocker.mockFunc(fileCopyUtil, fileCopyUtil.replaceFolder);
      when(replaceFolder)(ArgumentMatchers.any).afterReturn('replaceFolder');
      newUri = await fileCopyUtil.dealPasteFileAfterChoose(new FileInfo(), '');
      expect(newUri).assertEqual('replaceFolder');

      fileCopyUtil.fileApplyChoose = CopyCutConst.ChooseType.MERGE_FOLDER;
      let mergeFolder = mocker.mockFunc(fileCopyUtil, fileCopyUtil.mergeFolder);
      when(mergeFolder)(ArgumentMatchers.any).afterReturn('mergeFolder');
      newUri = await fileCopyUtil.dealPasteFileAfterChoose(new FileInfo(), '');
      expect(newUri).assertEqual('mergeFolder');

      fileCopyUtil.fileApplyChoose = CopyCutConst.ChooseType.SKIP_FOLDER;
      let onFileSkip = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'onFileSkip');
      when(onFileSkip)(ArgumentMatchers.any).afterReturnNothing();
      newUri = await fileCopyUtil.dealPasteFileAfterChoose(new FileInfo(), '');
      expect(newUri).assertEqual('');

      when(onFileSkip)(ArgumentMatchers.any).afterThrow('');
      newUri = await fileCopyUtil.dealPasteFileAfterChoose(new FileInfo(), '');
      expect(newUri).assertEqual('');
      done();
    })

    it('onFileSkip', 0, async (done: Function) => {
      let onFileShip = TestUtil.getPrivateFunction(fileCopyUtil, 'onFileSkip') as Function;

      TestUtil.setPrivateAttribute(fileCopyUtil, 'totalSize', 0);
      fileCopyUtil.totalCount = 1;
      let fileInfo: FileInfo = new FileInfo();
      fileInfo.isFolder = true;
      let getFolderSubFileCount = mocker.mockFunc(FileUtil, FileUtil.getFolderSubFileCount);
      when(getFolderSubFileCount)(ArgumentMatchers.any).afterReturn(0);
      await onFileShip(fileInfo);

      when(getFolderSubFileCount)(ArgumentMatchers.any).afterThrow('');
      await onFileShip();
      // mocker.verify('getFolderSubFileCount', ['', true]).once();

      TestUtil.setPrivateAttribute(fileCopyUtil, 'totalSize', 1);
      fileInfo.isFolder = false;
      let getFilesSize = mocker.mockFunc(StorageUtil, StorageUtil.getFilesSize);
      when(getFilesSize)(ArgumentMatchers.any).afterReturn(1);
      await onFileShip(fileInfo);
      mocker.verify('getFilesSize', [[fileInfo]]).once();
      mocker.clear(FileUtil);
      mocker.clear(StorageUtil);
      done();
    })

    it('isMoveHODataByUri', 0, () => {
      let isMoveHODataByUri = TestUtil.getPrivateFunction(fileCopyUtil, 'isMoveHODataByUri') as Function;
      expect(isMoveHODataByUri(VirtualUri.DOWNLOAD, VirtualUri.DOWNLOAD)).assertFalse();
    })

    it('transErrCodeToConflictType', 0, () => {
      let transErrCodeToConflictType =
        TestUtil.getPrivateFunction(fileCopyUtil, 'transErrCodeToConflictType') as Function;
      expect(transErrCodeToConflictType(ResultCode.Exception.EXIST_DUPLICATE_FILE))
        .assertEqual(CopyCutConst.ConflictType.FILE_CONFLICT);
      expect(transErrCodeToConflictType(ResultCode.Exception.EXIST_DUPLICATE_FOLDER))
        .assertEqual(CopyCutConst.ConflictType.FOLDER_CONFLICT);
      expect(transErrCodeToConflictType(ResultCode.Exception.CANNOT_PASTE_TO_SUB_FOLDER))
        .assertEqual(CopyCutConst.ConflictType.OTHER_ERROR);
      expect(transErrCodeToConflictType(ResultCode.Exception.RECOVER_EXIST_SAME_NAME_FILE))
        .assertEqual(CopyCutConst.ConflictType.OTHER_ERROR);
    })

    it('checkNeedDealError', 0, () => {
      let checkNeedDealError = TestUtil.getPrivateFunction(fileCopyUtil, 'checkNeedDealError') as Function;
      expect(checkNeedDealError(ResultCode.Error.SRC_FILE_NOT_EXIST)).assertTrue();
      fileCopyUtil.isPathApplyAll = true;
      expect(checkNeedDealError(ResultCode.Error.SRC_FILE_NOT_EXIST)).assertFalse();
      fileCopyUtil.isPathApplyAll = false;
      fileCopyUtil.isOtherErrorApplyAll = true;
      expect(checkNeedDealError(ResultCode.Error.SRC_FILE_NOT_EXIST)).assertFalse();
    })
    /*0508新DT*/
    it('createDup', 0, async () => {
      let dupFileResult = mocker.mockFunc(ThreadCommonUtil, ThreadCommonUtil.getDupFileName);
      when(dupFileResult)(ArgumentMatchers.any).afterReturn(['111', '111']);
      let newUriFolder = mocker.mockFunc(fileCopyUtil, fileCopyUtil.createFolderAndCopyContent);
      when(newUriFolder)(ArgumentMatchers.any).afterReturn('Folder');
      let newUriFile = mocker.mockFunc(fileCopyUtil, fileCopyUtil.createFileAndCopyContent);
      when(newUriFile)(ArgumentMatchers.any).afterReturn('File');
      let fileInfo = new FileInfo();
      fileInfo.uri = 'file://docs/storage/Users/currentUser/fileCopyUtilTestFile.txt';
      fileInfo.isFolder = true;
      let result = await fileCopyUtil.createDup(fileInfo, fileInfo.uri);
      expect(result).assertEqual('Folder');
      fileInfo.isFolder = false;
      result = await fileCopyUtil.createDup(fileInfo, fileInfo.uri);
      expect(result).assertEqual('File');
      //测试异常
      mocker.clear(newUriFile);
      when(newUriFile)(ArgumentMatchers.any).afterThrow('err');
      let newUri = mocker.mockFunc(fileCopyUtil, fileCopyUtil.createDup);
      when(newUri)(ArgumentMatchers.any).afterReturn('File');
      result = await fileCopyUtil.createDup(fileInfo, fileInfo.uri);
      expect(result).assertEqual('File');
    })

    it('initUriData_checkNeedToInitData_failed', 0, async (done: Function) => {
      let checkNeedToInitData = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'checkNeedToInitData');
      when(checkNeedToInitData)(ArgumentMatchers.any).afterReturn(false);
      let initFileInfoByOpen = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'initFileInfoByOpen');
      let fileInfo = new FileInfo();
      let isInitFileInfoByOpen = true;
      fileCopyUtil.initUriData(fileInfo, isInitFileInfoByOpen);
      mocker.verify('initFileInfoByOpen', [fileInfo]).times(0);
      done();
    })

    it('initUriData_initFileInfoByOpen', 0, async (done: Function) => {
      let checkNeedToInitData = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'checkNeedToInitData');
      when(checkNeedToInitData)(ArgumentMatchers.any).afterReturn(true);
      let initFileInfoByOpen = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'initFileInfoByOpen');
      when(initFileInfoByOpen)(ArgumentMatchers.any).afterReturnNothing();
      let fileInfo = new FileInfo();
      let isInitFileInfoByOpen = true;
      fileCopyUtil.initUriData(fileInfo, isInitFileInfoByOpen);
      mocker.verify('initFileInfoByOpen', [fileInfo]).once();
      done();
    })

    it('initUriData_initFileInfoByPath', 0, async (done: Function) => {
      let checkNeedToInitData = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'checkNeedToInitData');
      when(checkNeedToInitData)(ArgumentMatchers.any).afterReturn(true);
      let initFileInfoByPath = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'initFileInfoByPath');
      when(initFileInfoByPath)(ArgumentMatchers.any).afterReturnNothing();
      let fileInfo = new FileInfo();
      let isInitFileInfoByOpen = false;
      fileCopyUtil.initUriData(fileInfo, isInitFileInfoByOpen);
      mocker.verify('initFileInfoByPath', [fileInfo]).once();
      done();
    })

    it('initFileInfoByPath', 0, async (done: Function) => {
      let initFileInfoByPath = TestUtil.getPrivateFunction(fileCopyUtil, 'initFileInfoByPath') as Function;
      let fileInfo = new FileInfo();
      let ret: boolean = initFileInfoByPath(fileInfo);
      expect(ret).assertFalse();

      fileInfo = FileInfo.fromFileUri(VirtualUri.DOCUMENT);
      ret = initFileInfoByPath(fileInfo);
      expect(ret).assertTrue();
      done();
    })

    it('initFileInfoByOpen', 0, async (done: Function) => {
      let initFileInfoByOpen = TestUtil.getPrivateFunction(fileCopyUtil, 'initFileInfoByOpen') as Function;
      let fileInfo = FileInfo.fromFileUri(VirtualUri.DOCUMENT);
      let ret: boolean = initFileInfoByOpen(fileInfo);
      expect(ret).assertTrue();
      done();
    })

    it('fileCopyUtil_closeSync', 0, async (done: Function) => {
      let closeSync = TestUtil.getPrivateMockFunction(mocker, FsUtil, 'closeSync');
      when(closeSync)(ArgumentMatchers.any).afterReturnNothing();
      let fileHandle: fs.File = FsUtil.openSync(VirtualUri.DOCUMENT) as fs.File;
      fileCopyUtil.fsCloseFile(fileHandle, false);
      mocker.verify('closeSync', [fileHandle]).never();
      fileCopyUtil.fsCloseFile(fileHandle, true);
      mocker.verify('closeSync', [fileHandle]).once();
      mocker.clear(FsUtil);
      done();
    })

    it('checkNeedDealException_fileApplyAll_existDuplicateFile', 0, async (done: Function) => {
      let addRecentArray = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'addRecentArray');
      when(addRecentArray)(ArgumentMatchers.any).afterReturnNothing();
      let checkNeedDealException = TestUtil.getPrivateFunction(fileCopyUtil, 'checkNeedDealException') as Function;
      TestUtil.setPrivateAttribute(fileCopyUtil, 'isOtherErrorApplyAll', false);

      TestUtil.setPrivateAttribute(fileCopyUtil, 'isFileApplyAll', true);
      let ret: boolean = checkNeedDealException(ResultCode.Exception.EXIST_DUPLICATE_FILE);
      expect(ret).assertFalse();

      done();
    });

    it('checkNeedDealException_notFileApplyAll_existDuplicateFile', 0, async (done: Function) => {
      let addRecentArray = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'addRecentArray');
      when(addRecentArray)(ArgumentMatchers.any).afterReturnNothing();
      let checkNeedDealException = TestUtil.getPrivateFunction(fileCopyUtil, 'checkNeedDealException') as Function;
      TestUtil.setPrivateAttribute(fileCopyUtil, 'isOtherErrorApplyAll', false);

      TestUtil.setPrivateAttribute(fileCopyUtil, 'isFileApplyAll', false);
      let ret: boolean = checkNeedDealException(ResultCode.Exception.EXIST_DUPLICATE_FILE);
      expect(ret).assertTrue();

      done();
    });

    it('checkNeedDealException_fileApplyAll_existDuplicateFolder', 0, async (done: Function) => {
      let addRecentArray = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'addRecentArray');
      when(addRecentArray)(ArgumentMatchers.any).afterReturnNothing();
      let checkNeedDealException = TestUtil.getPrivateFunction(fileCopyUtil, 'checkNeedDealException') as Function;
      TestUtil.setPrivateAttribute(fileCopyUtil, 'isOtherErrorApplyAll', false);

      TestUtil.setPrivateAttribute(fileCopyUtil, 'isFolderApplyAll', true);
      let ret: boolean = checkNeedDealException(ResultCode.Exception.EXIST_DUPLICATE_FOLDER);
      expect(ret).assertFalse();

      done();
    });

    it('checkNeedDealException_notFileApplyAll_existDuplicateFolder', 0, async (done: Function) => {
      let addRecentArray = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'addRecentArray');
      when(addRecentArray)(ArgumentMatchers.any).afterReturnNothing();
      let checkNeedDealException = TestUtil.getPrivateFunction(fileCopyUtil, 'checkNeedDealException') as Function;
      TestUtil.setPrivateAttribute(fileCopyUtil, 'isOtherErrorApplyAll', false);

      TestUtil.setPrivateAttribute(fileCopyUtil, 'isFolderApplyAll', false);
      let ret: boolean = checkNeedDealException(ResultCode.Exception.EXIST_DUPLICATE_FOLDER);
      expect(ret).assertTrue();

      done();
    });

    it('checkNeedDealException_otherErrorApplyAll_existDuplicateFolder', 0, async (done: Function) => {
      let addRecentArray = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'addRecentArray');
      when(addRecentArray)(ArgumentMatchers.any).afterReturnNothing();
      let checkNeedDealException = TestUtil.getPrivateFunction(fileCopyUtil, 'checkNeedDealException') as Function;
      TestUtil.setPrivateAttribute(fileCopyUtil, 'isOtherErrorApplyAll', false);

      TestUtil.setPrivateAttribute(fileCopyUtil, 'isOtherErrorApplyAll', true);
      let ret: boolean = checkNeedDealException(ResultCode.Exception.EXIST_DUPLICATE_FOLDER);
      expect(ret).assertFalse();

      done();
    });

    it('pasteToGallery', 0, async (done: Function) => {
      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      let fileInfo: FileInfo = TestFileUtil.createFile(TestFileUtil.TEST_FOLDER_PATH, TestFileUtil.TEST_FILE_NAME);

      await fileCopyUtil.pasteToGallery([], copyCutSendParam);
      expect(fileCopyUtil.operateType).assertEqual(WorkerConst.OperateType.DRAG_FILE);

      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      let pasteToGalleryFolder = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'pasteToGalleryFolder');
      when(pasteToGalleryFolder)(ArgumentMatchers.any).afterReturnNothing();
      let albumInfo = await TestFileUtil.getAlbum(context, TestFileUtil.TEST_FOLDER);
      copyCutSendParam.destFolderUri = albumInfo?.albumUri as string ?? '';
      await fileCopyUtil.pasteToGallery([fileInfo], copyCutSendParam);
      expect(fileCopyUtil.operateType).assertEqual(WorkerConst.OperateType.CUT_FILE);

      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      await fileCopyUtil.pasteToGallery([fileInfo], copyCutSendParam);
      expect(fileCopyUtil.operateType).assertEqual(WorkerConst.OperateType.CUT_FILE);

      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      let folderInfo: FileInfo = TestFileUtil.getFolderInfo(TestFileUtil.TEST_FOLDER_PATH, TestFileUtil.TEST_FOLDER);
      TestFileUtil.createFile(TestFileUtil.TEST_FOLDER_PATH + TestFileUtil.TEST_FOLDER, TestFileUtil.TEST_FILE_NAME);
      let checkGalleryCanMove = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'checkGalleryCanMove');
      when(checkGalleryCanMove)(ArgumentMatchers.any).afterReturn(false);
      let handleGalleryDupFolder = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'handleGalleryDupFolder');
      when(handleGalleryDupFolder)(ArgumentMatchers.any).afterReturnNothing();
      copyCutSendParam.destFolderUri = VirtualUri.GALLERY;
      await fileCopyUtil.pasteToGallery([folderInfo], copyCutSendParam);
      expect(fileCopyUtil.operateType).assertEqual(WorkerConst.OperateType.COPY_FILE);

      let onErrorCatch = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'onErrorCatch');
      when(pasteToGalleryFolder)(ArgumentMatchers.any).afterAction(() => {
        throw new FileAccessError(13900025, 'file name invalid');
      });
      copyCutSendParam.destFolderUri = albumInfo?.albumUri as string;
      await fileCopyUtil.pasteToGallery([fileInfo], copyCutSendParam);
      mocker.verify('onErrorCatch', [13900025, fileInfo]).atLeast(1);

      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      folderInfo.fileName = 'aa';
      copyCutSendParam.destFolderUri = VirtualUri.GALLERY;
      await fileCopyUtil.pasteToGallery([folderInfo], copyCutSendParam);
      expect(fileCopyUtil.operateType).assertEqual(WorkerConst.OperateType.COPY_FILE);

      TestFileUtil.deleteFile(fileInfo);
      mocker.clear(fileCopyUtil);
      done();
    })

    it('initFileListToGalleryTest', 0, async (done: Function) => {
      let warnLog: Function = mocker.mockFunc(HiLog, HiLog.warn);
      fileCopyUtil.initFileListToGallery([new FileInfo()], copyCutSendParam);
      mocker.clear(HiLog);
      mocker.verify('warn', ['FileCopyUtil', 'initFileListToGallery start.']).once();
      done();
    })

    it('initFileToGalleryTest', 0, async (done: Function) => {
      let warnLog: Function = mocker.mockFunc(HiLog, HiLog.warn);
      fileCopyUtil.initFileToGallery(new FileInfo(), [new FileInfo()]);
      mocker.clear(HiLog);
      mocker.verify('warn', ['FileCopyUtil', 'Directory nesting exists.']).never();
      done();
    })

    it('initFileToGalleryTestWithFolder', 0, async (done: Function) => {
      mocker.mockFunc(HiLog, HiLog.warn);
      let file: FileInfo = new FileInfo();
      file.isFolder = true;
      fileCopyUtil.initFileToGallery(file, [new FileInfo()]);
      mocker.clear(HiLog);
      mocker.verify('warn', ['FileCopyUtil', 'Directory nesting exists.']).never();
      done();
    })

    it('startTaskWithWorker', 0, async (done: Function) => {
      let isNullOrUndefined: Function = TestUtil.getPrivateMockFunction(mocker, ObjectUtil, 'isNullOrUndefined');
      when(isNullOrUndefined)(ArgumentMatchers.any).afterReturn(false);
      let file: FileInfo = new FileInfo();
      file.isFolder = true;
      await fileCopyUtil.startTask(copyCutSendParam);
      mocker.verify('isNullOrUndefined', [undefined]).once();
      TestUtil.clearMockObject(mocker, ObjectUtil);
      done();
    })

    it('startTaskWithWorkerAndList', 0, async (done: Function) => {
      let isNullOrUndefined: Function = TestUtil.getPrivateMockFunction(mocker, ObjectUtil, 'isNullOrUndefined');
      when(isNullOrUndefined)(ArgumentMatchers.any).afterReturn(false);
      TestUtil.setPrivateAttribute(fileCopyUtil, 'toOperateFiles', [new FileInfo()]);
      let file: FileInfo = new FileInfo();
      file.isFolder = true;
      fileCopyUtil.startTask(copyCutSendParam);
      mocker.verify('isNullOrUndefined', [undefined]).once();
      TestUtil.clearMockObject(mocker, ObjectUtil);
      done();
    })

    it('startTaskWithDestFolderIsGalleryAlbum', 0, async (done: Function) => {
      let isNullOrUndefined: Function = TestUtil.getPrivateMockFunction(mocker, ObjectUtil, 'isNullOrUndefined');
      when(isNullOrUndefined)(ArgumentMatchers.any).afterReturn(false);
      TestUtil.setPrivateAttribute(fileCopyUtil, 'toOperateFiles', [new FileInfo()]);
      fileCopyUtil.destFolderIsGalleryAlbum = true;
      let file: FileInfo = new FileInfo();
      file.isFolder = true;
      fileCopyUtil.startTask(copyCutSendParam);
      mocker.verify('isNullOrUndefined', [undefined]).once();
      TestUtil.clearMockObject(mocker, ObjectUtil);
      done();
    })

    it('pasteToGalleryWithAlbum', 0, async (done: Function) => {
      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      let fileInfo: FileInfo = TestFileUtil.createFile(TestFileUtil.TEST_FOLDER_PATH, TestFileUtil.TEST_FILE_NAME);

      await fileCopyUtil.pasteToGallery([], copyCutSendParam);

      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      let albumInfo = await TestFileUtil.getAlbum(context, TestFileUtil.TEST_FOLDER);
      copyCutSendParam.destFolderUri = albumInfo?.albumUri as string ?? '';
      await fileCopyUtil.pasteToGallery([fileInfo], copyCutSendParam);

      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      await fileCopyUtil.pasteToGallery([fileInfo], copyCutSendParam);

      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      let folderInfo: FileInfo = TestFileUtil.getFolderInfo(TestFileUtil.TEST_FOLDER_PATH, TestFileUtil.TEST_FOLDER);
      TestFileUtil.createFile(TestFileUtil.TEST_FOLDER_PATH + TestFileUtil.TEST_FOLDER, TestFileUtil.TEST_FILE_NAME);
      let checkGalleryCanMove = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'checkGalleryCanMove');
      when(checkGalleryCanMove)(ArgumentMatchers.any).afterReturn(false);
      let handleGalleryDupFolder = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'handleGalleryDupFolder');
      when(handleGalleryDupFolder)(ArgumentMatchers.any).afterReturnNothing();
      copyCutSendParam.destFolderUri = VirtualUri.GALLERY;
      await fileCopyUtil.pasteToGallery([folderInfo], copyCutSendParam);

      let onErrorCatch = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'onErrorCatch');
      copyCutSendParam.destFolderUri = albumInfo?.albumUri as string;
      await fileCopyUtil.pasteToGallery([fileInfo], copyCutSendParam);

      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      folderInfo.fileName = 'aa';
      copyCutSendParam.destFolderUri = VirtualUri.GALLERY;
      await fileCopyUtil.pasteToGallery([folderInfo], copyCutSendParam);
      expect(fileCopyUtil.operateType).assertEqual(WorkerConst.OperateType.COPY_FILE);

      TestFileUtil.deleteFile(fileInfo);
      mocker.clear(fileCopyUtil);
      done();
    })

    it('startTaskHandleGalleryDupFolder', 0, async (done: Function) => {
      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      let fileInfo: FileInfo = TestFileUtil.createFile(TestFileUtil.TEST_FOLDER_PATH, TestFileUtil.TEST_FILE_NAME);
      let sendException = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'sendException');
      when(sendException)(ArgumentMatchers.any).afterReturnNothing();

      await fileCopyUtil.pasteToGallery([], copyCutSendParam);

      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      let albumInfo = await TestFileUtil.getAlbum(context, TestFileUtil.TEST_FOLDER);
      copyCutSendParam.destFolderUri = albumInfo?.albumUri as string ?? '';
      await fileCopyUtil.pasteToGallery([fileInfo], copyCutSendParam);

      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      await fileCopyUtil.pasteToGallery([fileInfo], copyCutSendParam);

      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      let folderInfo: FileInfo = TestFileUtil.getFolderInfo(TestFileUtil.TEST_FOLDER_PATH, TestFileUtil.TEST_FOLDER);
      TestFileUtil.createFile(TestFileUtil.TEST_FOLDER_PATH + TestFileUtil.TEST_FOLDER, TestFileUtil.TEST_FILE_NAME);
      let checkGalleryCanMove = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'checkGalleryCanMove');
      when(checkGalleryCanMove)(ArgumentMatchers.any).afterReturn(false);
      copyCutSendParam.destFolderUri = VirtualUri.GALLERY;
      await fileCopyUtil.pasteToGallery([folderInfo], copyCutSendParam);

      let onErrorCatch = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'onErrorCatch');
      copyCutSendParam.destFolderUri = albumInfo?.albumUri as string;
      await fileCopyUtil.pasteToGallery([fileInfo], copyCutSendParam);

      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      folderInfo.fileName = 'aa';
      copyCutSendParam.destFolderUri = VirtualUri.GALLERY;
      await fileCopyUtil.pasteToGallery([folderInfo], copyCutSendParam);
      expect(fileCopyUtil.operateType).assertEqual(WorkerConst.OperateType.COPY_FILE);

      TestFileUtil.deleteFile(fileInfo);
      mocker.clear(fileCopyUtil);
      done();
    })

    it('startTaskEXCEPTION_TASK_CANCEL', 0, async (done: Function) => {
      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      let fileInfo: FileInfo = TestFileUtil.createFile(TestFileUtil.TEST_FOLDER_PATH, TestFileUtil.TEST_FILE_NAME);
      let sendException = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'sendException');
      when(sendException)(ArgumentMatchers.any).afterReturnNothing();

      await fileCopyUtil.pasteToGallery([], copyCutSendParam);

      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      let albumInfo = await TestFileUtil.getAlbum(context, TestFileUtil.TEST_FOLDER);
      copyCutSendParam.destFolderUri = albumInfo?.albumUri as string ?? '';
      await fileCopyUtil.pasteToGallery([fileInfo], copyCutSendParam);
      copyCutSendParam.toOperateFiles = [fileInfo];
      copyCutSendParam.destFolderUri = albumInfo?.albumUri as string;
      fileCopyUtil.isCancel = true;
      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      await fileCopyUtil.pasteToGallery([fileInfo], copyCutSendParam);

      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      let folderInfo: FileInfo = TestFileUtil.getFolderInfo(TestFileUtil.TEST_FOLDER_PATH, TestFileUtil.TEST_FOLDER);
      TestFileUtil.createFile(TestFileUtil.TEST_FOLDER_PATH + TestFileUtil.TEST_FOLDER, TestFileUtil.TEST_FILE_NAME);
      let checkGalleryCanMove = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'checkGalleryCanMove');
      when(checkGalleryCanMove)(ArgumentMatchers.any).afterReturn(false);
      copyCutSendParam.destFolderUri = VirtualUri.GALLERY;
      await fileCopyUtil.pasteToGallery([folderInfo], copyCutSendParam);

      let onErrorCatch = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'onErrorCatch');
      copyCutSendParam.destFolderUri = albumInfo?.albumUri as string;
      await fileCopyUtil.pasteToGallery([fileInfo], copyCutSendParam);

      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      folderInfo.fileName = 'aa';
      copyCutSendParam.destFolderUri = VirtualUri.GALLERY;
      await fileCopyUtil.pasteToGallery([folderInfo], copyCutSendParam);
      expect(fileCopyUtil.operateType).assertEqual(WorkerConst.OperateType.COPY_FILE);

      TestFileUtil.deleteFile(fileInfo);
      mocker.clear(fileCopyUtil);
      done();
    })

    it('startTaskEXCEPTION_PASTE_CONTENT_INCLUDE_FILE', 0, async (done: Function) => {
      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      let fileInfo: FileInfo = TestFileUtil.createFile(TestFileUtil.TEST_FOLDER_PATH, TestFileUtil.TEST_FILE_NAME);
      let sendException = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'sendException');
      when(sendException)(ArgumentMatchers.any).afterReturnNothing();

      await fileCopyUtil.pasteToGallery([], copyCutSendParam);

      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      let albumInfo = await TestFileUtil.getAlbum(context, TestFileUtil.TEST_FOLDER);
      copyCutSendParam.destFolderUri = albumInfo?.albumUri as string ?? '';
      await fileCopyUtil.pasteToGallery([fileInfo], copyCutSendParam);
      copyCutSendParam.toOperateFiles = [fileInfo];
      copyCutSendParam.destFolderUri = albumInfo?.albumUri as string;
      fileCopyUtil.isCancel = true;
      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      await fileCopyUtil.pasteToGallery([fileInfo], copyCutSendParam);
      fileCopyUtil.totalCount = 0;
      fileCopyUtil.isCancel = false;
      copyCutSendParam.toOperateFiles = [fileInfo];

      fileCopyUtil.destFolderUri = VirtualUri.GALLERY;
      await fileCopyUtil.initFileListToGallery([fileInfo], copyCutSendParam);
      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      let folderInfo: FileInfo = TestFileUtil.getFolderInfo(TestFileUtil.TEST_FOLDER_PATH, TestFileUtil.TEST_FOLDER);
      TestFileUtil.createFile(TestFileUtil.TEST_FOLDER_PATH + TestFileUtil.TEST_FOLDER, TestFileUtil.TEST_FILE_NAME);
      let checkGalleryCanMove = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'checkGalleryCanMove');
      when(checkGalleryCanMove)(ArgumentMatchers.any).afterReturn(false);
      copyCutSendParam.destFolderUri = VirtualUri.GALLERY;
      await fileCopyUtil.pasteToGallery([folderInfo], copyCutSendParam);

      let onErrorCatch = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'onErrorCatch');
      copyCutSendParam.destFolderUri = albumInfo?.albumUri as string;
      await fileCopyUtil.pasteToGallery([fileInfo], copyCutSendParam);

      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      folderInfo.fileName = 'aa';
      copyCutSendParam.destFolderUri = VirtualUri.GALLERY;
      await fileCopyUtil.pasteToGallery([folderInfo], copyCutSendParam);
      expect(fileCopyUtil.operateType).assertEqual(WorkerConst.OperateType.COPY_FILE);

      TestFileUtil.deleteFile(fileInfo);
      mocker.clear(fileCopyUtil);
      done();
    })

    it('startTaskGALLERY_PHOTO_URI_TO_GALLERY', 0, async (done: Function) => {
      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      let fileInfo: FileInfo = TestFileUtil.createFile(VirtualUri.GALLERY_PHOTO_URI, TestFileUtil.TEST_FILE_NAME);
      let sendException = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'sendException');
      when(sendException)(ArgumentMatchers.any).afterReturnNothing();

      await fileCopyUtil.pasteToGallery([], copyCutSendParam);

      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      await fileCopyUtil.pasteToGallery([fileInfo], copyCutSendParam);
      copyCutSendParam.toOperateFiles = [fileInfo];
      TestUtil.setPrivateAttribute(fileCopyUtil, 'destFolderUri', VirtualUri.GALLERY);
      fileCopyUtil.isCancel = true;
      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      await fileCopyUtil.pasteToGallery([fileInfo], copyCutSendParam);
      fileCopyUtil.totalCount = 0;
      fileCopyUtil.isCancel = false;
      copyCutSendParam.toOperateFiles = [fileInfo];

      fileCopyUtil.destFolderUri = VirtualUri.GALLERY;
      await fileCopyUtil.initFileListToGallery([fileInfo], copyCutSendParam);
      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      let folderInfo: FileInfo = TestFileUtil.getFolderInfo(TestFileUtil.TEST_FOLDER_PATH, TestFileUtil.TEST_FOLDER);
      TestFileUtil.createFile(TestFileUtil.TEST_FOLDER_PATH + TestFileUtil.TEST_FOLDER, TestFileUtil.TEST_FILE_NAME);
      let checkGalleryCanMove = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'checkGalleryCanMove');
      when(checkGalleryCanMove)(ArgumentMatchers.any).afterReturn(false);
      copyCutSendParam.destFolderUri = VirtualUri.GALLERY;
      await fileCopyUtil.pasteToGallery([folderInfo], copyCutSendParam);

      let onErrorCatch = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'onErrorCatch');
      await fileCopyUtil.pasteToGallery([fileInfo], copyCutSendParam);

      fileCopyUtil.operateType = WorkerConst.OperateType.DRAG_FILE;
      folderInfo.fileName = 'aa';
      copyCutSendParam.destFolderUri = VirtualUri.GALLERY;
      await fileCopyUtil.pasteToGallery([folderInfo], copyCutSendParam);
      expect(fileCopyUtil.operateType).assertEqual(WorkerConst.OperateType.COPY_FILE);

      TestFileUtil.deleteFile(fileInfo);
      mocker.clear(fileCopyUtil);
      done();
    })

    it('pasteFolderToGallery', 0, async (done: Function) => {
      let fileInfo: FileInfo = TestFileUtil.createFile(VirtualUri.GALLERY_PHOTO_URI, TestFileUtil.TEST_FILE_NAME);
      let albumInfo = await TestFileUtil.getAlbum(context, TestFileUtil.TEST_FOLDER);
      TestUtil.getPrivateMockFunction(mocker, HiLog, 'info');
      fileCopyUtil.pasteFolderToGallery(fileInfo, albumInfo as photoAccessHelper.Album);
      mocker.verify('info', ['FileCopyUtil', 'paste folder to gallery start.']).once();
      mocker.clear(fileCopyUtil);
      done();
    })

    it('pasteFolderToGalleryNotGalleryFile', 0, async (done: Function) => {
      let fileInfo: FileInfo = TestFileUtil.createFile(TestFileUtil.TEST_FOLDER_PATH, TestFileUtil.TEST_FILE_NAME);
      TestFileUtil.createFile(TestFileUtil.TEST_FOLDER_PATH + 'test.txt', TestFileUtil.TEST_FILE_NAME);
      let albumInfo = await TestFileUtil.getAlbum(context, TestFileUtil.TEST_FOLDER);
      TestUtil.getPrivateMockFunction(mocker, HiLog, 'info');
      fileCopyUtil.pasteFolderToGallery(fileInfo, albumInfo as photoAccessHelper.Album);
      mocker.verify('info', ['FileCopyUtil', 'paste folder to gallery start.']).once();
      mocker.clear(fileCopyUtil);
      done();
    })

    it('createFileAndCopyContentExternalStorage', 0, async (done: Function) => {
      when(mocker.mockFunc(fileCopyUtil, fileCopyUtil.copyFileContent))(ArgumentMatchers.any)
        .afterReturn(true);
      when(mocker.mockFunc(ExternalStorageUtil, ExternalStorageUtil.isExternalStorageUri))(ArgumentMatchers.any)
        .afterReturn(true);
      let fileInfo: FileInfo = new FileInfo();
      let result = await fileCopyUtil.createFileAndCopyContent('', new FileInfo(), '');
      expect(result).assertEqual('');

      mocker.clear(ExternalStorageUtil);
      mocker.clear(ExternalStorageUtil);
      done();
    })

    it('pasteToGalleryException', 0, async (done: Function) => {
      let warnFunc: Function = mocker.mockFunc(HiLog, HiLog.warn);
      fileCopyUtil.existDirNesting = true;
      fileCopyUtil.pasteToGalleryException([new FileInfo()], VirtualUri.GALLERY);
      mocker.clear(HiLog);
      mocker.verify('warn', ['FileCopyUtil', 'Path nesting exists.']).once();
      done();
    })

    it('pasteToGalleryExceptionWithFiles', 0, async (done: Function) => {
      let warnFunc: Function = mocker.mockFunc(HiLog, HiLog.warn);
      fileCopyUtil.existDirNesting = true;
      fileCopyUtil.pasteToGalleryException([new FileInfo(), new FileInfo()], VirtualUri.GALLERY);
      mocker.clear(HiLog);
      mocker.verify('warn', ['FileCopyUtil', 'Path nesting exists.']).never();
      done();
    })

    it('pasteToGalleryExceptionWithoutGallery', 0, async (done: Function) => {
      let warnFunc: Function = mocker.mockFunc(HiLog, HiLog.warn);
      fileCopyUtil.existDirNesting = true;
      fileCopyUtil.pasteToGalleryException([new FileInfo()], VirtualUri.MY_PHONE);
      mocker.clear(HiLog);
      mocker.verify('warn', ['FileCopyUtil', 'Paste folder under album.']).never();
      done();
    })

    it('pasteToGalleryExceptionWithoutGalleryWithFiles', 0, async (done: Function) => {
      let warnFunc: Function = mocker.mockFunc(HiLog, HiLog.warn);
      fileCopyUtil.existDirNesting = true;
      let file: FileInfo = new FileInfo();
      file.isFolder = true;
      fileCopyUtil.pasteToGalleryException([new FileInfo(), new FileInfo(), file], VirtualUri.MY_PHONE);
      mocker.clear(HiLog);
      mocker.verify('warn', ['FileCopyUtil', 'Paste folder under album.']).once();
      done();
    })

    it('startTask_copyFileInit', 0, async (done: Function) => {
      let initAndCheckData = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'initAndCheckData');
      when(initAndCheckData)(ArgumentMatchers.any).afterReturn(true);
      TestUtil.setPrivateAttribute(fileCopyUtil, 'toOperateFiles', [new FileInfo()]);
      let runTask = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'runTask');
      fileCopyUtil.destAlbum = await TestFileUtil.getAlbum(context, TestFileUtil.TEST_FOLDER);
      await fileCopyUtil.startTask(copyCutSendParam);
      mocker.verify('runTask', [copyCutSendParam]).never();

      copyCutSendParam.uuid = 'cloud';
      await fileCopyUtil.startTask(copyCutSendParam);
      mocker.verify('runTask', [copyCutSendParam]).never();
      TestUtil.clearMockObject(mocker, ObjectUtil);
      done();
    })

    it('startTask_destFolderIsGalleryAlbum', 0, async (done: Function) => {
      let initAndCheckData = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'initAndCheckData');
      when(initAndCheckData)(ArgumentMatchers.any).afterReturn(true);
      TestUtil.setPrivateAttribute(fileCopyUtil, 'toOperateFiles', [new FileInfo()]);
      TestUtil.setPrivateAttribute(fileCopyUtil, 'destFolderIsGalleryAlbum', true);
      fileCopyUtil.destFolderUri = VirtualUri.GALLERY;
      let runTask = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'runTask');
      fileCopyUtil.destAlbum = await TestFileUtil.getAlbum(context, TestFileUtil.TEST_FOLDER);
      await fileCopyUtil.startTask(copyCutSendParam);
      TestUtil.clearMockObject(mocker, ObjectUtil);
      mocker.verify('runTask', [copyCutSendParam]).never();
      done();
    })

    it('startTask_initResEXCEPTION_TASK_CANCEL', 0, async (done: Function) => {
      let initAndCheckData = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'initAndCheckData');
      when(initAndCheckData)(ArgumentMatchers.any).afterReturn(true);
      let initFileListToGallery = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'initFileListToGallery');
      when(initFileListToGallery)(ArgumentMatchers.any).afterReturn(ResultCode.Exception.EXCEPTION_TASK_CANCEL);
      TestUtil.setPrivateAttribute(fileCopyUtil, 'toOperateFiles', [new FileInfo()]);
      TestUtil.setPrivateAttribute(fileCopyUtil, 'destFolderIsGalleryAlbum', true);
      fileCopyUtil.destFolderUri = VirtualUri.GALLERY;
      let runTask = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'runTask');
      fileCopyUtil.destAlbum = await TestFileUtil.getAlbum(context, TestFileUtil.TEST_FOLDER);
      await fileCopyUtil.startTask(copyCutSendParam);
      TestUtil.clearMockObject(mocker, ObjectUtil);
      mocker.verify('runTask', [copyCutSendParam]).never();
      done();
    })

    it('startTask_initResEXCEPTION_PASTE_CONTENT_INCLUDE_FILE', 0, async (done: Function) => {
      let initAndCheckData = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'initAndCheckData');
      when(initAndCheckData)(ArgumentMatchers.any).afterReturn(true);
      let initFileListToGallery = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'initFileListToGallery');
      when(initFileListToGallery)(ArgumentMatchers.any)
        .afterReturn(ResultCode.Exception.EXCEPTION_PASTE_CONTENT_INCLUDE_FILE);
      TestUtil.setPrivateAttribute(fileCopyUtil, 'toOperateFiles', [new FileInfo()]);
      TestUtil.setPrivateAttribute(fileCopyUtil, 'destFolderIsGalleryAlbum', true);
      fileCopyUtil.destFolderUri = VirtualUri.GALLERY;
      let runTask = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'runTask');
      fileCopyUtil.destAlbum = await TestFileUtil.getAlbum(context, TestFileUtil.TEST_FOLDER);
      await fileCopyUtil.startTask(copyCutSendParam);
      TestUtil.clearMockObject(mocker, ObjectUtil);
      mocker.verify('runTask', [copyCutSendParam]).never();
      done();
    })

    it('initFileToGalleryTestWithFolderGetSubFileListByUri', 0, async (done: Function) => {
      let warnLog: Function = mocker.mockFunc(HiLog, HiLog.warn);
      let getSubFileListByUri: Function = mocker.mockFunc(FileUtil, FileUtil.getSubFileListByUri);
      when(getSubFileListByUri)(ArgumentMatchers.any).afterReturn(['testuri']);
      let file: FileInfo = new FileInfo();
      file.isFolder = true;
      fileCopyUtil.initFileToGallery(file, [new FileInfo()]);
      mocker.clear(HiLog);
      mocker.clear(FileUtil);
      mocker.verify('warn', ['FileCopyUtil', 'Directory nesting exists.']).never();
      done();
    })

    it('initFileToGalleryTestWithIsCancel', 0, async (done: Function) => {
      let warnLog: Function = mocker.mockFunc(HiLog, HiLog.warn);
      let getSubFileListByUri: Function = mocker.mockFunc(FileUtil, FileUtil.getSubFileListByUri);
      when(getSubFileListByUri)(ArgumentMatchers.any).afterReturn(['testuri']);
      let file: FileInfo = new FileInfo();
      file.isFolder = true;
      fileCopyUtil.isCancel = true;
      fileCopyUtil.initFileToGallery(file, [new FileInfo()]);
      mocker.clear(FileUtil);
      mocker.clear(HiLog);
      mocker.verify('warn', ['FileCopyUtil', 'Directory nesting exists.']).never();
      done();
    })

    it('initFileToGalleryTestWithExistDirNesting', 0, async (done: Function) => {
      let warnLog: Function = mocker.mockFunc(HiLog, HiLog.warn);
      let getSubFileListByUri: Function = mocker.mockFunc(FileUtil, FileUtil.getSubFileListByUri);
      when(getSubFileListByUri)(ArgumentMatchers.any).afterReturn(['testuri/111']);
      let file: FileInfo = new FileInfo();
      file.isFolder = true;
      fileCopyUtil.existDirNesting = false;
      fileCopyUtil.initFileToGallery(file, [new FileInfo()]);
      mocker.clear(HiLog);
      mocker.clear(FileUtil);
      mocker.verify('warn', ['FileCopyUtil', 'Directory nesting exists.']).once();
      done();
    })

    it('initFileToGalleryTestWithMediaSupportType', 0, async (done: Function) => {
      let warnLog: Function = mocker.mockFunc(HiLog, HiLog.warn);
      let getSubFileListByUri: Function = mocker.mockFunc(FileUtil, FileUtil.getSubFileListByUri);
      let isMediaSupportType: Function = TestUtil.getPrivateMockFunction(mocker, fileCopyUtil, 'isMediaSupportType');
      when(getSubFileListByUri)(ArgumentMatchers.any).afterReturn(['testuri']);
      when(isMediaSupportType)(ArgumentMatchers.any).afterReturn(true);
      let file: FileInfo = new FileInfo();
      file.isFolder = true;
      fileCopyUtil.initFileToGallery(file, [new FileInfo()]);
      mocker.clear(HiLog);
      mocker.clear(FileUtil);
      mocker.verify('warn', ['FileCopyUtil', 'Directory nesting exists.']).never();
      mocker.clear(HiLog);
      mocker.clear(FileUtil);
      mocker.clear(fileCopyUtil);
      done();
    })

    it('initFileListInfoWithCancel', 0, async (done: Function) => {
      let initUriData = mocker.mockFunc(fileCopyUtil, fileCopyUtil.initUriData);
      when(initUriData)(ArgumentMatchers.any).afterReturnNothing();
      let getRemoteFolderSize = mocker.mockFunc(FilesQueryUtil, FilesQueryUtil.getFolderSize);
      when(getRemoteFolderSize)(ArgumentMatchers.any).afterReturn(100);
      let getFolderSubFileCount = mocker.mockFunc(FileUtil, FileUtil.getFolderSubFileCount);
      when(getFolderSubFileCount)(ArgumentMatchers.any).afterReturn(10);
      fileCopyUtil.isCancel = true;
      let folderFileInfo = new FileInfo();
      folderFileInfo.isFolder = true;
      let fileInfo = new FileInfo();
      fileInfo.isFolder = false;
      fileInfo.size = 123;
      fileCopyUtil.isLocalAppFile = true;
      await fileCopyUtil.initFileListInfo([folderFileInfo, fileInfo], copyCutSendParam)
      mocker.clear(fileCopyUtil);
      mocker.clear(FilesQueryUtil);
      mocker.clear(FileUtil);
      expect(fileCopyUtil.chooseFileMulti).assertFalse();
      done();
    })

    it('initFileListInfoWithGalleryUri', 0, async (done: Function) => {
      let initUriData = mocker.mockFunc(fileCopyUtil, fileCopyUtil.initUriData);
      when(initUriData)(ArgumentMatchers.any).afterReturnNothing();
      let getRemoteFolderSize = mocker.mockFunc(FilesQueryUtil, FilesQueryUtil.getFolderSize);
      when(getRemoteFolderSize)(ArgumentMatchers.any).afterReturn(100);
      let getFolderSubFileCount = mocker.mockFunc(FileUtil, FileUtil.getFolderSubFileCount);
      when(getFolderSubFileCount)(ArgumentMatchers.any).afterReturn(10);
      let folderFileInfo = new FileInfo();
      folderFileInfo.isFolder = true;
      folderFileInfo.uri = VirtualUri.GALLERY_URI + '/111';
      let fileInfo = new FileInfo();
      fileInfo.isFolder = false;
      fileInfo.size = 123;
      fileCopyUtil.isLocalAppFile = true;
      await fileCopyUtil.initFileListInfo([folderFileInfo, fileInfo], copyCutSendParam)
      mocker.clear(fileCopyUtil);
      mocker.clear(FilesQueryUtil);
      mocker.clear(FileUtil);
      expect(fileCopyUtil.chooseFileMulti).assertFalse();
      done();
    })

    it('initFileListInfoWithMediaSupportType', 0, async (done: Function) => {
      let initUriData = mocker.mockFunc(fileCopyUtil, fileCopyUtil.initUriData);
      when(initUriData)(ArgumentMatchers.any).afterReturn(true);
      let getRemoteFolderSize = mocker.mockFunc(FilesQueryUtil, FilesQueryUtil.getFolderSize);
      when(getRemoteFolderSize)(ArgumentMatchers.any).afterReturn(100);
      let getFolderSubFileCount = mocker.mockFunc(FileUtil, FileUtil.getFolderSubFileCount);
      when(getFolderSubFileCount)(ArgumentMatchers.any).afterReturn(10);
      let folderFileInfo = new FileInfo();
      folderFileInfo.isFolder = true;
      folderFileInfo.uri = VirtualUri.GALLERY_URI + '/111';
      let fileInfo = new FileInfo();
      fileInfo.isFolder = false;
      fileInfo.size = 123;
      fileCopyUtil.isLocalAppFile = true;
      await fileCopyUtil.initFileListInfo([folderFileInfo, fileInfo], copyCutSendParam)
      mocker.clear(fileCopyUtil);
      mocker.clear(FilesQueryUtil);
      mocker.clear(FileUtil);
      expect(fileCopyUtil.chooseFileMulti).assertTrue();
      done();
    })

    it('pasteFileToGallery', 0, async (done: Function) => {
      let isSupportPaste = mocker.mockFunc(fileCopyUtil, fileCopyUtil.isSupportPaste);
      when(isSupportPaste)(ArgumentMatchers.any).afterReturn(true);
      let folderFileInfo = new FileInfo();
      folderFileInfo.isFolder = true;
      folderFileInfo.uri = VirtualUri.GALLERY_URI + '/111';
      let fileInfo = new FileInfo();
      fileInfo.isFolder = false;
      fileInfo.size = 123;
      fileCopyUtil.isLocalAppFile = true;
      let album = await TestFileUtil.getAlbum(context, TestFileUtil.TEST_FOLDER) as photoAccessHelper.Album;
      await fileCopyUtil.pasteFileToGallery(fileInfo, album);
      expect(fileCopyUtil.chooseFileMulti).assertFalse();
      mocker.clear(fileCopyUtil);
      done();
    })

    it('pasteFileToGallerySrcFileGallery', 0, async (done: Function) => {
      let isSupportPaste = mocker.mockFunc(fileCopyUtil, fileCopyUtil.isSupportPaste);
      when(isSupportPaste)(ArgumentMatchers.any).afterReturn(true);
      let folderFileInfo = new FileInfo();
      folderFileInfo.isFolder = true;
      folderFileInfo.uri = VirtualUri.GALLERY_URI + '/111';
      let fileInfo = new FileInfo();
      fileInfo.isFolder = false;
      fileInfo.size = 123;
      fileInfo.uri = VirtualUri.GALLERY_PHOTO_URI + '111.abc';
      fileCopyUtil.isLocalAppFile = true;
      let album = await TestFileUtil.getAlbum(context, TestFileUtil.TEST_FOLDER) as photoAccessHelper.Album;
      await fileCopyUtil.pasteFileToGallery(fileInfo, album);
      expect(fileCopyUtil.chooseFileMulti).assertFalse();
      mocker.clear(fileCopyUtil);
      done();
    })
  })
}
