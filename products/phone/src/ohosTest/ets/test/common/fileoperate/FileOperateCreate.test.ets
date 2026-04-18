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
import { FsUtil, HiLog } from '@ohos/common';
import fs from '@ohos.file.fs';
import { describe, expect, it } from '@ohos/hypium';
import { BusinessError } from '@kit.BasicServicesKit';

export default function FileOperateCreateTest() {
  describe('FileOperateCreateTest', () => {
    // 测试新建单个普通命名文件
    it('FileOperateCreateTest_create_single_file_with_normal_name', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_file_with_normal_name';
      const dirpath: string = '/storage/Users/currentUser/Download';
      const fileName: string = 'normal_file';
      const fileUri: string = dirpath + '/' + fileName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件是否已经存在
      let isFileExist: boolean = FsUtil.isFileExist(fileUri);
      HiLog.info(TAG, `Old file is exist: ${isFileExist}`);
      if (isFileExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(fileUri);
        HiLog.info(TAG, `Old file deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件
      let fileOpenRes: BusinessError<void> | fs.File =
        FsUtil.openSync(fileUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      HiLog.info(TAG, `File open: ${JSON.stringify(fileOpenRes)}`);
      expect(fileOpenRes).not().assertUndefined();
      // 写文件
      const resFilePath: string = (fileOpenRes as fs.File).path;
      const writeData: string = 'test';
      const writeFileRes: number | BusinessError<void> = FsUtil.writeSync((fileOpenRes as fs.File).fd, writeData);
      HiLog.info(TAG, `File write: ${JSON.stringify(writeFileRes)}`);
      expect(writeFileRes as number).assertLarger(0);
      // 关闭句柄
      const closeRes: void | BusinessError<void> = FsUtil.closeSync(fileOpenRes as fs.File);
      HiLog.info(TAG, `File close: ${JSON.stringify(closeRes)}`);
      // 清理文件
      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(resFilePath);
      HiLog.info(TAG, `File deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含特殊字符命名文件%
    it('FileOperateCreateTest_create_single_file_with_percentage_symbol', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_file_with_percentage_symbol';
      const dirpath: string = '/storage/Users/currentUser/Download';
      const fileName: string = 'special_file%';
      const fileUri: string = dirpath + '/' + fileName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件是否已经存在
      let isFileExist: boolean = FsUtil.isFileExist(fileUri);
      HiLog.info(TAG, `Old file is exist: ${isFileExist}`);
      if (isFileExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(fileUri);
        HiLog.info(TAG, `Old file deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件
      let fileOpenRes: BusinessError<void> | fs.File =
        FsUtil.openSync(fileUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      HiLog.info(TAG, `File open: ${JSON.stringify(fileOpenRes)}`);
      expect(fileOpenRes).not().assertUndefined();
      // 写文件
      const resFilePath: string = (fileOpenRes as fs.File).path;
      const writeData: string = 'test';
      const writeFileRes: number | BusinessError<void> = FsUtil.writeSync((fileOpenRes as fs.File).fd, writeData);
      HiLog.info(TAG, `File write: ${JSON.stringify(writeFileRes)}`);
      expect(writeFileRes as number).assertLarger(0);
      // 关闭句柄
      const closeRes: void | BusinessError<void> = FsUtil.closeSync(fileOpenRes as fs.File);
      HiLog.info(TAG, `File close: ${JSON.stringify(closeRes)}`);
      // 清理文件
      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(resFilePath);
      HiLog.info(TAG, `File deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含特殊字符命名文件+
    it('FileOperateCreateTest_create_single_file_with_plus', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_file_with_plus';
      const dirpath: string = '/storage/Users/currentUser/Download';
      const fileName: string = 'special_file+';
      const fileUri: string = dirpath + '/' + fileName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件是否已经存在
      let isFileExist: boolean = FsUtil.isFileExist(fileUri);
      HiLog.info(TAG, `Old file is exist: ${isFileExist}`);
      if (isFileExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(fileUri);
        HiLog.info(TAG, `Old file deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件
      let fileOpenRes: BusinessError<void> | fs.File =
        FsUtil.openSync(fileUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      HiLog.info(TAG, `File open: ${JSON.stringify(fileOpenRes)}`);
      expect(fileOpenRes).not().assertUndefined();
      // 写文件
      const resFilePath: string = (fileOpenRes as fs.File).path;
      const writeData: string = 'test';
      const writeFileRes: number | BusinessError<void> = FsUtil.writeSync((fileOpenRes as fs.File).fd, writeData);
      HiLog.info(TAG, `File write: ${JSON.stringify(writeFileRes)}`);
      expect(writeFileRes as number).assertLarger(0);
      // 关闭句柄
      const closeRes: void | BusinessError<void> = FsUtil.closeSync(fileOpenRes as fs.File);
      HiLog.info(TAG, `File close: ${JSON.stringify(closeRes)}`);
      // 清理文件
      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(resFilePath);
      HiLog.info(TAG, `File deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含特殊字符命名文件=
    it('FileOperateCreateTest_create_single_file_with_equal', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_file_with_equal';
      const dirpath: string = '/storage/Users/currentUser/Download';
      const fileName: string = 'special_file=';
      const fileUri: string = dirpath + '/' + fileName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件是否已经存在
      let isFileExist: boolean = FsUtil.isFileExist(fileUri);
      HiLog.info(TAG, `Old file is exist: ${isFileExist}`);
      if (isFileExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(fileUri);
        HiLog.info(TAG, `Old file deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件
      let fileOpenRes: BusinessError<void> | fs.File =
        FsUtil.openSync(fileUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      HiLog.info(TAG, `File open: ${JSON.stringify(fileOpenRes)}`);
      expect(fileOpenRes).not().assertUndefined();
      // 写文件
      const resFilePath: string = (fileOpenRes as fs.File).path;
      const writeData: string = 'test';
      const writeFileRes: number | BusinessError<void> = FsUtil.writeSync((fileOpenRes as fs.File).fd, writeData);
      HiLog.info(TAG, `File write: ${JSON.stringify(writeFileRes)}`);
      expect(writeFileRes as number).assertLarger(0);
      // 关闭句柄
      const closeRes: void | BusinessError<void> = FsUtil.closeSync(fileOpenRes as fs.File);
      HiLog.info(TAG, `File close: ${JSON.stringify(closeRes)}`);
      // 清理文件
      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(resFilePath);
      HiLog.info(TAG, `File deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含不支持特殊字符\命名文件 不支持的特殊字符 \/:*?"<>|
    it('FileOperateCreateTest_create_single_file_with_backslash', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_file_with_backslash';
      const dirpath: string = '/storage/Users/currentUser/Download';
      const fileName: string = 'special_file\\';
      const fileUri: string = dirpath + '/' + fileName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件是否已经存在
      let isFileExist: boolean = FsUtil.isFileExist(fileUri);
      HiLog.info(TAG, `Old file is exist: ${isFileExist}`);
      if (isFileExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(fileUri);
        HiLog.info(TAG, `Old file deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件
      let fileOpenRes: BusinessError<void> | fs.File =
        FsUtil.openSync(fileUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      HiLog.info(TAG, `File open: ${JSON.stringify(fileOpenRes)}`);
      expect(fileOpenRes).not().assertUndefined();
      // 写文件
      const resFilePath: string = (fileOpenRes as fs.File).path;
      const writeData: string = 'test';
      const writeFileRes: number | BusinessError<void> = FsUtil.writeSync((fileOpenRes as fs.File).fd, writeData);
      HiLog.info(TAG, `File write: ${JSON.stringify(writeFileRes)}`);
      expect(writeFileRes as number).assertLarger(0);
      // 关闭句柄
      const closeRes: void | BusinessError<void> = FsUtil.closeSync(fileOpenRes as fs.File);
      HiLog.info(TAG, `File close: ${JSON.stringify(closeRes)}`);
      // 清理文件
      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(resFilePath);
      HiLog.info(TAG, `File deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含不支持特殊字符:命名文件 不支持的特殊字符 \/:*?"<>|
    it('FileOperateCreateTest_create_single_file_with_colon', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_file_with_colon';
      const dirpath: string = '/storage/Users/currentUser/Download';
      const fileName: string = 'special_file:';
      const fileUri: string = dirpath + '/' + fileName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件是否已经存在
      let isFileExist: boolean = FsUtil.isFileExist(fileUri);
      HiLog.info(TAG, `Old file is exist: ${isFileExist}`);
      if (isFileExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(fileUri);
        HiLog.info(TAG, `Old file deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件
      let fileOpenRes: BusinessError<void> | fs.File =
        FsUtil.openSync(fileUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      HiLog.info(TAG, `File open: ${JSON.stringify(fileOpenRes)}`);
      expect(fileOpenRes).not().assertUndefined();
      // 写文件
      const resFilePath: string = (fileOpenRes as fs.File).path;
      const writeData: string = 'test';
      const writeFileRes: number | BusinessError<void> = FsUtil.writeSync((fileOpenRes as fs.File).fd, writeData);
      HiLog.info(TAG, `File write: ${JSON.stringify(writeFileRes)}`);
      expect(writeFileRes as number).assertLarger(0);
      // 关闭句柄
      const closeRes: void | BusinessError<void> = FsUtil.closeSync(fileOpenRes as fs.File);
      HiLog.info(TAG, `File close: ${JSON.stringify(closeRes)}`);
      // 清理文件
      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(resFilePath);
      HiLog.info(TAG, `File deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含不支持特殊字符*命名文件 不支持的特殊字符 \/:*?"<>|
    it('FileOperateCreateTest_create_single_file_with_asterisk', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_file_with_asterisk';
      const dirpath: string = '/storage/Users/currentUser/Download';
      const fileName: string = 'special_file*';
      const fileUri: string = dirpath + '/' + fileName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件是否已经存在
      let isFileExist: boolean = FsUtil.isFileExist(fileUri);
      HiLog.info(TAG, `Old file is exist: ${isFileExist}`);
      if (isFileExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(fileUri);
        HiLog.info(TAG, `Old file deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件
      let fileOpenRes: BusinessError<void> | fs.File =
        FsUtil.openSync(fileUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      HiLog.info(TAG, `File open: ${JSON.stringify(fileOpenRes)}`);
      expect(fileOpenRes).not().assertUndefined();
      // 写文件
      const resFilePath: string = (fileOpenRes as fs.File).path;
      const writeData: string = 'test';
      const writeFileRes: number | BusinessError<void> = FsUtil.writeSync((fileOpenRes as fs.File).fd, writeData);
      HiLog.info(TAG, `File write: ${JSON.stringify(writeFileRes)}`);
      expect(writeFileRes as number).assertLarger(0);
      // 关闭句柄
      const closeRes: void | BusinessError<void> = FsUtil.closeSync(fileOpenRes as fs.File);
      HiLog.info(TAG, `File close: ${JSON.stringify(closeRes)}`);
      // 清理文件
      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(resFilePath);
      HiLog.info(TAG, `File deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含不支持特殊字符?命名文件 不支持的特殊字符 \/:*?"<>|
    it('FileOperateCreateTest_create_single_file_with_question_mark', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_file_with_question_mark';
      const dirpath: string = '/storage/Users/currentUser/Download';
      const fileName: string = 'special_file?';
      const fileUri: string = dirpath + '/' + fileName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件是否已经存在
      let isFileExist: boolean = FsUtil.isFileExist(fileUri);
      HiLog.info(TAG, `Old file is exist: ${isFileExist}`);
      if (isFileExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(fileUri);
        HiLog.info(TAG, `Old file deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件
      let fileOpenRes: BusinessError<void> | fs.File =
        FsUtil.openSync(fileUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      HiLog.info(TAG, `File open: ${JSON.stringify(fileOpenRes)}`);
      expect(fileOpenRes).not().assertUndefined();
      // 写文件
      const resFilePath: string = (fileOpenRes as fs.File).path;
      const writeData: string = 'test';
      const writeFileRes: number | BusinessError<void> = FsUtil.writeSync((fileOpenRes as fs.File).fd, writeData);
      HiLog.info(TAG, `File write: ${JSON.stringify(writeFileRes)}`);
      expect(writeFileRes as number).assertLarger(0);
      // 关闭句柄
      const closeRes: void | BusinessError<void> = FsUtil.closeSync(fileOpenRes as fs.File);
      HiLog.info(TAG, `File close: ${JSON.stringify(closeRes)}`);
      // 清理文件
      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(resFilePath);
      HiLog.info(TAG, `File deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含不支持特殊字符"命名文件 不支持的特殊字符 \/:*?"<>|
    it('FileOperateCreateTest_create_single_file_with_double_quotes', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_file_with_double_quotes';
      const dirpath: string = '/storage/Users/currentUser/Download';
      const fileName: string = 'special_file"';
      const fileUri: string = dirpath + '/' + fileName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      //判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件是否已经存在
      let isFileExist: boolean = FsUtil.isFileExist(fileUri);
      HiLog.info(TAG, `Old file is exist: ${isFileExist}`);
      if (isFileExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(fileUri);
        HiLog.info(TAG, `Old file deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件
      let fileOpenRes: BusinessError<void> | fs.File =
        FsUtil.openSync(fileUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      HiLog.info(TAG, `File open: ${JSON.stringify(fileOpenRes)}`);
      expect(fileOpenRes).not().assertUndefined();
      // 写文件
      const resFilePath: string = (fileOpenRes as fs.File).path;
      const writeData: string = 'test';
      const writeFileRes: number | BusinessError<void> = FsUtil.writeSync((fileOpenRes as fs.File).fd, writeData);
      HiLog.info(TAG, `File write: ${JSON.stringify(writeFileRes)}`);
      expect(writeFileRes as number).assertLarger(0);
      // 关闭句柄
      const closeRes: void | BusinessError<void> = FsUtil.closeSync(fileOpenRes as fs.File);
      HiLog.info(TAG, `File close: ${JSON.stringify(closeRes)}`);
      // 清理文件
      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(resFilePath);
      HiLog.info(TAG, `File deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含不支持特殊字符<命名文件 不支持的特殊字符 \/:*?"<>|
    it('FileOperateCreateTest_create_single_file_with_less', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_file_with_less';
      const dirpath: string = '/storage/Users/currentUser/Download';
      const fileName: string = 'special_file<';
      const fileUri: string = dirpath + '/' + fileName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件是否已经存在
      let isFileExist: boolean = FsUtil.isFileExist(fileUri);
      HiLog.info(TAG, `Old file is exist: ${isFileExist}`);
      if (isFileExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(fileUri);
        HiLog.info(TAG, `Old file deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件
      let fileOpenRes: BusinessError<void> | fs.File =
        FsUtil.openSync(fileUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      HiLog.info(TAG, `File open: ${JSON.stringify(fileOpenRes)}`);
      expect(fileOpenRes).not().assertUndefined();
      // 写文件
      const resFilePath: string = (fileOpenRes as fs.File).path;
      const writeData: string = 'test';
      const writeFileRes: number | BusinessError<void> = FsUtil.writeSync((fileOpenRes as fs.File).fd, writeData);
      HiLog.info(TAG, `File write: ${JSON.stringify(writeFileRes)}`);
      expect(writeFileRes as number).assertLarger(0);
      // 关闭句柄
      const closeRes: void | BusinessError<void> = FsUtil.closeSync(fileOpenRes as fs.File);
      HiLog.info(TAG, `File close: ${JSON.stringify(closeRes)}`);
      // 清理文件
      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(resFilePath);
      HiLog.info(TAG, `File deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含不支持特殊字符>命名文件 不支持的特殊字符 \/:*?"<>|
    it('FileOperateCreateTest_create_single_file_with_greater', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_file_with_greater';
      const dirpath: string = '/storage/Users/currentUser/Download';
      const fileName: string = 'special_file>';
      const fileUri: string = dirpath + '/' + fileName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件是否已经存在
      let isFileExist: boolean = FsUtil.isFileExist(fileUri);
      HiLog.info(TAG, `Old file is exist: ${isFileExist}`);
      if (isFileExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(fileUri);
        HiLog.info(TAG, `Old file deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件
      let fileOpenRes: BusinessError<void> | fs.File =
        FsUtil.openSync(fileUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      HiLog.info(TAG, `File open: ${JSON.stringify(fileOpenRes)}`);
      expect(fileOpenRes).not().assertUndefined();
      // 写文件
      const resFilePath: string = (fileOpenRes as fs.File).path;
      const writeData: string = 'test';
      const writeFileRes: number | BusinessError<void> = FsUtil.writeSync((fileOpenRes as fs.File).fd, writeData);
      HiLog.info(TAG, `File write: ${JSON.stringify(writeFileRes)}`);
      expect(writeFileRes as number).assertLarger(0);
      // 关闭句柄
      const closeRes: void | BusinessError<void> = FsUtil.closeSync(fileOpenRes as fs.File);
      HiLog.info(TAG, `File close: ${JSON.stringify(closeRes)}`);
      // 清理文件
      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(resFilePath);
      HiLog.info(TAG, `File deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含不支持特殊字符|命名文件 不支持的特殊字符 \/:*?"<>|
    it('FileOperateCreateTest_create_single_file_with_pipe', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_file_with_pipe';
      const dirpath: string = '/storage/Users/currentUser/Download';
      const fileName: string = 'special_file|';
      const fileUri: string = dirpath + '/' + fileName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件是否已经存在
      let isFileExist: boolean = FsUtil.isFileExist(fileUri);
      HiLog.info(TAG, `Old file is exist: ${isFileExist}`);
      if (isFileExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(fileUri);
        HiLog.info(TAG, `Old file deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件
      let fileOpenRes: BusinessError<void> | fs.File =
        FsUtil.openSync(fileUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      HiLog.info(TAG, `File open: ${JSON.stringify(fileOpenRes)}`);
      expect(fileOpenRes).not().assertUndefined();
      // 写文件
      const resFilePath: string = (fileOpenRes as fs.File).path;
      const writeData: string = 'test';
      const writeFileRes: number | BusinessError<void> = FsUtil.writeSync((fileOpenRes as fs.File).fd, writeData);
      HiLog.info(TAG, `File write: ${JSON.stringify(writeFileRes)}`);
      expect(writeFileRes as number).assertLarger(0);
      // 关闭句柄
      const closeRes: void | BusinessError<void> = FsUtil.closeSync(fileOpenRes as fs.File);
      HiLog.info(TAG, `File close: ${JSON.stringify(closeRes)}`);
      // 清理文件
      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(resFilePath);
      HiLog.info(TAG, `File deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建多个普通名称文件
    it('FileOperateCreateTest_create_multi_files_with_normal_name', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_multi_files_with_normal_name';
      // 根目录下创建文件 命名为'normal_file'
      const dirpath: string = '/storage/Users/currentUser/Download';
      const fileNameList: string[] = ['normal_file', 'normal_file1', 'normal_file2', 'normal_file3'];
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      for (const fileName of fileNameList) {
        const fileUri: string = dirpath + '/' + fileName;
        // 判断文件是否已经存在
        let isFileExist: boolean = FsUtil.isFileExist(fileUri);
        HiLog.info(TAG, `Old file is exist: ${isFileExist}`);
        if (isFileExist) {
          //先删除
          let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(fileUri);
          HiLog.info(TAG, `Old file deleted: ${JSON.stringify(deleteRes)}`);
          expect(deleteRes as number).assertEqual(0);
        }
        // 创建文件
        let fileOpenRes: BusinessError<void> | fs.File =
          FsUtil.openSync(fileUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        HiLog.info(TAG, `File open: ${JSON.stringify(fileOpenRes)}`);
        expect(fileOpenRes).not().assertUndefined();
        // 写文件
        const resFilePath: string = (fileOpenRes as fs.File).path;
        const writeData: string = 'test';
        const writeFileRes: number | BusinessError<void> = FsUtil.writeSync((fileOpenRes as fs.File).fd, writeData);
        HiLog.info(TAG, `File write: ${JSON.stringify(writeFileRes)}`);
        expect(writeFileRes as number).assertLarger(0);
        // 关闭句柄
        const closeRes: void | BusinessError<void> = FsUtil.closeSync(fileOpenRes as fs.File);
        HiLog.info(TAG, `File close: ${JSON.stringify(closeRes)}`);
        // 清理文件
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(resFilePath);
        HiLog.info(TAG, `File deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
    });

    // 新建多个含支持的特殊字符命名的文件
    it('FileOperateCreateTest_create_multi_files_with_supported_special_characters', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_multi_files_with_normal_name';
      // 根目录下创建文件 命名为'normal_file'
      const dirpath: string = '/storage/Users/currentUser/Download';
      const fileNameList: string[] = ['normal_file@', 'normal_file+', 'normal_file-', 'normal_file='];
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      for (const fileName of fileNameList) {
        const fileUri: string = dirpath + '/' + fileName;
        // 判断文件是否已经存在
        let isFileExist: boolean = FsUtil.isFileExist(fileUri);
        HiLog.info(TAG, `Old file is exist: ${isFileExist}`);
        if (isFileExist) {
          //先删除
          let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(fileUri);
          HiLog.info(TAG, `Old file deleted: ${JSON.stringify(deleteRes)}`);
          expect(deleteRes as number).assertEqual(0);
        }
        // 创建文件
        let fileOpenRes: BusinessError<void> | fs.File =
          FsUtil.openSync(fileUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        HiLog.info(TAG, `File open: ${JSON.stringify(fileOpenRes)}`);
        expect(fileOpenRes).not().assertUndefined();
        // 写文件
        const resFilePath: string = (fileOpenRes as fs.File).path;
        const writeData: string = 'test';
        const writeFileRes: number | BusinessError<void> = FsUtil.writeSync((fileOpenRes as fs.File).fd, writeData);
        HiLog.info(TAG, `File write: ${JSON.stringify(writeFileRes)}`);
        expect(writeFileRes as number).assertLarger(0);
        // 关闭句柄
        const closeRes: void | BusinessError<void> = FsUtil.closeSync(fileOpenRes as fs.File);
        HiLog.info(TAG, `File close: ${JSON.stringify(closeRes)}`);
        // 清理文件
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(resFilePath);
        HiLog.info(TAG, `File deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
    });

    // 新建多个含不支持的特殊字符命名的文件
    it('FileOperateCreateTest_create_multi_files_with_not_supported_special_characters', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_multi_files_with_not_supported_special_characters';
      // 根目录下创建文件 命名为'normal_file'
      const dirpath: string = '/storage/Users/currentUser/Download';
      const fileNameList: string[] = ['normal_file@', 'normal_file+', 'normal_file-', 'normal_file='];
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      for (const fileName of fileNameList) {
        const fileUri: string = dirpath + '/' + fileName;
        // 判断文件是否已经存在
        let isFileExist: boolean = FsUtil.isFileExist(fileUri);
        HiLog.info(TAG, `Old file is exist: ${isFileExist}`);
        if (isFileExist) {
          //先删除
          let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(fileUri);
          HiLog.info(TAG, `Old file deleted: ${JSON.stringify(deleteRes)}`);
          expect(deleteRes as number).assertEqual(0);
        }
        // 创建文件
        let fileOpenRes: BusinessError<void> | fs.File =
          FsUtil.openSync(fileUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        HiLog.info(TAG, `File open: ${JSON.stringify(fileOpenRes)}`);
        expect(fileOpenRes).not().assertUndefined();
        // 写文件
        const resFilePath: string = (fileOpenRes as fs.File).path;
        const writeData: string = 'test';
        const writeFileRes: number | BusinessError<void> = FsUtil.writeSync((fileOpenRes as fs.File).fd, writeData);
        HiLog.info(TAG, `File write: ${JSON.stringify(writeFileRes)}`);
        expect(writeFileRes as number).assertLarger(0);
        // 关闭句柄
        const closeRes: void | BusinessError<void> = FsUtil.closeSync(fileOpenRes as fs.File);
        HiLog.info(TAG, `File close: ${JSON.stringify(closeRes)}`);
        // 清理文件
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(resFilePath);
        HiLog.info(TAG, `File deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
    });

    // 新建单个普通名称空文件夹
    it('FileOperateCreateTest_create_single_empty_folder_with_normal_name', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_empty_folder_with_normal_name';
      // 根目录下创建文件 命名为'normal_file'
      const dirpath: string = '/storage/Users/currentUser/Download';
      const folderName: string = 'normal_folder';
      const folderUri: string = dirpath + '/' + folderName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件夹是否已经存在
      let isFolderExist: boolean = FsUtil.isExistSyncByPath(folderUri);
      HiLog.info(TAG, `Old Folder is exist: ${isFolderExist}`);
      if (isFolderExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
        HiLog.info(TAG, `Old Folder deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件夹
      let mkDirRes: void | BusinessError<void> = FsUtil.mkdirSync(folderUri);
      expect((mkDirRes as BusinessError<void>)).assertUndefined();
      // 删除
      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
      HiLog.info(TAG, `Folder deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含特殊字符命名空文件夹%
    it('FileOperateCreateTest_create_single_empty_folder_with_percentage_symbol', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_empty_folder_with_percentage_symbol';
      // 根目录下创建文件 命名为'normal_file'
      const dirpath: string = '/storage/Users/currentUser/Download';
      const folderName: string = 'normal_folder%';
      const folderUri: string = dirpath + '/' + folderName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件夹是否已经存在
      let isFolderExist: boolean = FsUtil.isExistSyncByPath(folderUri);
      HiLog.info(TAG, `Old Folder is exist: ${isFolderExist}`);
      if (isFolderExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
        HiLog.info(TAG, `Old Folder deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件夹
      let mkDirRes: void | BusinessError<void> = FsUtil.mkdirSync(folderUri);
      expect((mkDirRes as BusinessError<void>)).assertUndefined();

      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
      HiLog.info(TAG, `Folder deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含特殊字符命名空文件夹+
    it('FileOperateCreateTest_create_single_empty_folder_with_plus', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_empty_folder_with_plus';
      // 根目录下创建文件 命名为'normal_file'
      const dirpath: string = '/storage/Users/currentUser/Download';
      const folderName: string = 'normal_folder+';
      const folderUri: string = dirpath + '/' + folderName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件夹是否已经存在
      let isFolderExist: boolean = FsUtil.isExistSyncByPath(folderUri);
      HiLog.info(TAG, `Old Folder is exist: ${isFolderExist}`);
      if (isFolderExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
        HiLog.info(TAG, `Old Folder deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件夹
      let mkDirRes: void | BusinessError<void> = FsUtil.mkdirSync(folderUri);
      expect((mkDirRes as BusinessError<void>)).assertUndefined();

      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
      HiLog.info(TAG, `Folder deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含特殊字符命名空文件夹=
    it('FileOperateCreateTest_create_single_empty_folder_with_equal', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_empty_folder_with_equal';
      // 根目录下创建文件 命名为'normal_file'
      const dirpath: string = '/storage/Users/currentUser/Download';
      const folderName: string = 'normal_folder=';
      const folderUri: string = dirpath + '/' + folderName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件夹是否已经存在
      let isFolderExist: boolean = FsUtil.isExistSyncByPath(folderUri);
      HiLog.info(TAG, `Old Folder is exist: ${isFolderExist}`);
      if (isFolderExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
        HiLog.info(TAG, `Old Folder deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件夹
      let mkDirRes: void | BusinessError<void> = FsUtil.mkdirSync(folderUri);
      expect((mkDirRes as BusinessError<void>)).assertUndefined();

      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
      HiLog.info(TAG, `Folder deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含不支持特殊字符/命名空文件夹
    it('FileOperateCreateTest_create_single_empty_folder_with_slash', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_empty_folder_with_slash';
      // 根目录下创建文件 命名为'normal_file'
      const dirpath: string = '/storage/Users/currentUser/Download';
      const folderName: string = 'normal_folder\/';
      const folderUri: string = dirpath + '/' + folderName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件夹是否已经存在
      let isFolderExist: boolean = FsUtil.isExistSyncByPath(folderUri);
      HiLog.info(TAG, `Old Folder is exist: ${isFolderExist}`);
      if (isFolderExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
        HiLog.info(TAG, `Old Folder deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件夹
      let mkDirRes: void | BusinessError<void> = FsUtil.mkdirSync(folderUri);
      expect((mkDirRes as BusinessError<void>)).assertUndefined();

      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
      HiLog.info(TAG, `Folder deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含不支持特殊字符\命名空文件夹
    it('FileOperateCreateTest_create_single_empty_folder_with_backslash', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_empty_folder_with_slash';
      // 根目录下创建文件 命名为'normal_file'
      const dirpath: string = '/storage/Users/currentUser/Download';
      const folderName: string = 'normal_folder\\';
      const folderUri: string = dirpath + '/' + folderName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件夹是否已经存在
      let isFolderExist: boolean = FsUtil.isExistSyncByPath(folderUri);
      HiLog.info(TAG, `Old Folder is exist: ${isFolderExist}`);
      if (isFolderExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
        HiLog.info(TAG, `Old Folder deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件夹
      let mkDirRes: void | BusinessError<void> = FsUtil.mkdirSync(folderUri);
      expect((mkDirRes as BusinessError<void>)).assertUndefined();

      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
      HiLog.info(TAG, `Folder deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含不支持特殊字符:命名空文件夹 \/:*?"<>|
    it('FileOperateCreateTest_create_single_empty_folder_with_colon', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_empty_folder_with_colon';
      // 根目录下创建文件 命名为'normal_file'
      const dirpath: string = '/storage/Users/currentUser/Download';
      const folderName: string = 'normal_folder:';
      const folderUri: string = dirpath + '/' + folderName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件夹是否已经存在
      let isFolderExist: boolean = FsUtil.isExistSyncByPath(folderUri);
      HiLog.info(TAG, `Old Folder is exist: ${isFolderExist}`);
      if (isFolderExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
        HiLog.info(TAG, `Old Folder deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件夹
      let mkDirRes: void | BusinessError<void> = FsUtil.mkdirSync(folderUri);
      expect((mkDirRes as BusinessError<void>)).assertUndefined();

      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
      HiLog.info(TAG, `Folder deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含不支持特殊字符*命名空文件夹 \/:*?"<>|
    it('FileOperateCreateTest_create_single_empty_folder_with_asterisk', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_empty_folder_with_asterisk';
      // 根目录下创建文件 命名为'normal_file'
      const dirpath: string = '/storage/Users/currentUser/Download';
      const folderName: string = 'normal_folder*';
      const folderUri: string = dirpath + '/' + folderName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件夹是否已经存在
      let isFolderExist: boolean = FsUtil.isExistSyncByPath(folderUri);
      HiLog.info(TAG, `Old Folder is exist: ${isFolderExist}`);
      if (isFolderExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
        HiLog.info(TAG, `Old Folder deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件夹
      let mkDirRes: void | BusinessError<void> = FsUtil.mkdirSync(folderUri);
      expect((mkDirRes as BusinessError<void>)).assertUndefined();

      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
      HiLog.info(TAG, `Folder deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含不支持特殊字符?命名空文件夹 \/:*?"<>|
    it('FileOperateCreateTest_create_single_empty_folder_with_question_mark', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_empty_folder_with_question_mark';
      // 根目录下创建文件 命名为'normal_file'
      const dirpath: string = '/storage/Users/currentUser/Download';
      const folderName: string = 'normal_folder?';
      const folderUri: string = dirpath + '/' + folderName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件夹是否已经存在
      let isFolderExist: boolean = FsUtil.isExistSyncByPath(folderUri);
      HiLog.info(TAG, `Old Folder is exist: ${isFolderExist}`);
      if (isFolderExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
        HiLog.info(TAG, `Old Folder deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件夹
      let mkDirRes: void | BusinessError<void> = FsUtil.mkdirSync(folderUri);
      expect((mkDirRes as BusinessError<void>)).assertUndefined();

      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
      HiLog.info(TAG, `Folder deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含不支持特殊字符"命名空文件夹 \/:*?"<>|
    it('FileOperateCreateTest_create_single_empty_folder_with_double_quotes', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_empty_folder_with_double_quotes';
      // 根目录下创建文件 命名为'normal_file'
      const dirpath: string = '/storage/Users/currentUser/Download';
      const folderName: string = 'normal_folder?';
      const folderUri: string = dirpath + '/' + folderName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件夹是否已经存在
      let isFolderExist: boolean = FsUtil.isExistSyncByPath(folderUri);
      HiLog.info(TAG, `Old Folder is exist: ${isFolderExist}`);
      if (isFolderExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
        HiLog.info(TAG, `Old Folder deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件夹
      let mkDirRes: void | BusinessError<void> = FsUtil.mkdirSync(folderUri);
      expect((mkDirRes as BusinessError<void>)).assertUndefined();

      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
      HiLog.info(TAG, `Folder deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含不支持特殊字符<命名空文件夹 \/:*?"<>|
    it('FileOperateCreateTest_create_single_empty_folder_with_less', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_empty_folder_with_less';
      // 根目录下创建文件 命名为'normal_file'
      const dirpath: string = '/storage/Users/currentUser/Download';
      const folderName: string = 'normal_folder?';
      const folderUri: string = dirpath + '/' + folderName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件夹是否已经存在
      let isFolderExist: boolean = FsUtil.isExistSyncByPath(folderUri);
      HiLog.info(TAG, `Old Folder is exist: ${isFolderExist}`);
      if (isFolderExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
        HiLog.info(TAG, `Old Folder deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件夹
      let mkDirRes: void | BusinessError<void> = FsUtil.mkdirSync(folderUri);
      expect((mkDirRes as BusinessError<void>)).assertUndefined();

      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
      HiLog.info(TAG, `Folder deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含不支持特殊字符>命名空文件夹 \/:*?"<>|
    it('FileOperateCreateTest_create_single_empty_folder_with_greater', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_empty_folder_with_greater';
      // 根目录下创建文件 命名为'normal_file'
      const dirpath: string = '/storage/Users/currentUser/Download';
      const folderName: string = 'normal_folder?';
      const folderUri: string = dirpath + '/' + folderName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件夹是否已经存在
      let isFolderExist: boolean = FsUtil.isExistSyncByPath(folderUri);
      HiLog.info(TAG, `Old Folder is exist: ${isFolderExist}`);
      if (isFolderExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
        HiLog.info(TAG, `Old Folder deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件夹
      let mkDirRes: void | BusinessError<void> = FsUtil.mkdirSync(folderUri);
      expect((mkDirRes as BusinessError<void>)).assertUndefined();

      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
      HiLog.info(TAG, `Folder deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });

    // 新建单个含不支持特殊字符|命名空文件夹 \/:*?"<>|
    it('FileOperateCreateTest_create_single_empty_folder_with_pipe', 0, () => {
      const TAG: string = 'FileOperateCreateTest_create_single_empty_folder_with_pipe';
      // 根目录下创建文件 命名为'normal_file'
      const dirpath: string = '/storage/Users/currentUser/Download';
      const folderName: string = 'normal_folder?';
      const folderUri: string = dirpath + '/' + folderName;
      // 判断目录是否在
      let isExist: boolean = FsUtil.isExistSyncByPath(dirpath);
      HiLog.info(TAG, `Folder is exist: ${isExist}`);
      expect(isExist).assertTrue();
      // // 判断是否是目录
      let isFolder: boolean | BusinessError<void> = FsUtil.isFolder(dirpath);
      HiLog.info(TAG, `Folder is folder: ${isFolder}`);
      expect(isFolder as boolean).assertTrue();
      // 判断目录是否access
      let canAccess: boolean = FsUtil.checkAccessSync(dirpath);
      HiLog.info(TAG, `Folder can access: ${canAccess}`);
      expect(canAccess).assertTrue();
      // 判断文件夹是否已经存在
      let isFolderExist: boolean = FsUtil.isExistSyncByPath(folderUri);
      HiLog.info(TAG, `Old Folder is exist: ${isFolderExist}`);
      if (isFolderExist) {
        //先删除
        let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
        HiLog.info(TAG, `Old Folder deleted: ${JSON.stringify(deleteRes)}`);
        expect(deleteRes as number).assertEqual(0);
      }
      // 创建文件夹
      let mkDirRes: void | BusinessError<void> = FsUtil.mkdirSync(folderUri);
      expect((mkDirRes as BusinessError<void>)).assertUndefined();

      let deleteRes: number | BusinessError<void> = FsUtil.forceDelete(folderUri);
      HiLog.info(TAG, `Folder deleted: ${JSON.stringify(deleteRes)}`);
      expect(deleteRes as number).assertEqual(0);
    });
  });
}