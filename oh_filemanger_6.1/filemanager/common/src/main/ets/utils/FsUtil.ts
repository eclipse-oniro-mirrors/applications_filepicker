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

import fs, { ListFileOptions, ReadOptions, WriteOptions } from '@ohos.file.fs';
import { HiLog } from '../dfx/HiLog';
import { fileUri } from '@kit.CoreFileKit';
import { ERROR_CODE } from '../const/ErrorCode';
import { LocationType } from '../const/Constant';
import { HiSysEventUtil } from '../dfx/HiSysEventUtil';
import { HiSysEventName, InterfaceName } from '../const/HiSysEventConst';
import { BusinessError } from '@kit.BasicServicesKit';
import { StringUtil } from './StringUtil';

const TAG: string = 'FsUtil';
const PASTE_BUFFER = 4194304; // 4M

export class FsUtil {
  public static async stat(file: string | number): Promise<fs.Stat | BusinessError> {
    try {
      return await fs.stat(file);
    } catch (error) {
      HiLog.error(TAG, 'fs stat error = ' + error?.message);
      return error;
    }
  }

  public static statSyncByUri(uri: string): fs.Stat | BusinessError {
    try {
      const fileuri: fileUri.FileUri = new fileUri.FileUri(uri);
      return fs.statSync(fileuri.path);
    } catch (error) {
      HiLog.error(TAG, 'fs statSync error = ' + error?.message);
      return error;
    }
  }

  public static statSync(file: string | number): fs.Stat | BusinessError {
    try {
      return fs.statSync(file);
    } catch (error) {
      HiLog.error(TAG, 'fs statSync error = ' + error?.message);
      return error;
    }
  }

  public static async access(path: string): Promise<boolean | BusinessError> {
    try {
      return await fs.access(path);
    } catch (error) {
      HiLog.error(TAG, 'fs access error = ' + error?.message);
      return error;
    }
  }

  public static accessSync(path: string): boolean | BusinessError {
    try {
      return fs.accessSync(path);
    } catch (error) {
      HiLog.error(TAG, 'fs accessSync error = ' + error?.message);
      return error;
    }
  }

  public static checkAccessSync(path: string): boolean {
    let isExist: boolean = false;
    try {
      isExist = fs.accessSync(path);
    } catch (error) {
      HiLog.error(TAG, 'fs accessSync error = ' + error?.message);
    }
    return isExist;
  }

  public static openSync(path: string, mode?: number): fs.File | BusinessError {
    try {
      return fs.openSync(path, mode);
    } catch (error) {
      HiLog.error(TAG, 'fs openSync error = ' + error?.message);
      return error;
    }
  }

  public static async close(file: number | fs.File): Promise<void | BusinessError> {
    try {
      return await fs.close(file);
    } catch (error) {
      HiLog.error(TAG, 'fs close error = ' + error?.message);
      return error;
    }
  }

  public static closeSync(file: number | fs.File): void | BusinessError {
    try {
      return fs.closeSync(file);
    } catch (error) {
      HiLog.error(TAG, 'fs closeSync error = ' + error?.message);
      // 对于无效入参，不打点
      if ((error as BusinessError).code !== ERROR_CODE.FILE_ACCESS.INVALID_ARGUMENT) {
        HiSysEventUtil.reportFailureEvent(HiSysEventName.FILE_OPERATE_FAIL, InterfaceName.FS_CLOSE_SYNC,
          (error as BusinessError).code);
      }
      return error;
    }
  }

  public static async mkdir(path: string, recursion: boolean = false): Promise<void | BusinessError> {
    try {
      return await fs.mkdir(path, recursion);
    } catch (error) {
      HiLog.error(TAG, 'fs mkdir error = ' + error?.message);
      return error;
    }
  }

  public static mkdirSync(path: string, recursion: boolean = false): void | BusinessError {
    try {
      return fs.mkdirSync(path, recursion);
    } catch (error) {
      HiLog.error(TAG, 'fs mkdirSync error = ' + error?.message);
      HiSysEventUtil.reportFailureEvent(HiSysEventName.FILE_OPERATE_FAIL, InterfaceName.FS_MKDIR_SYNC,
        (error as BusinessError).code);
      return error;
    }
  }

  public static async rmdir(path: string): Promise<void | BusinessError> {
    try {
      return await fs.rmdir(path);
    } catch (error) {
      HiLog.error(TAG, 'fs rmdir error = ' + error?.message);
      return error;
    }
  }

  public static rmdirSync(path: string): void | BusinessError {
    try {
      return fs.rmdirSync(path);
    } catch (error) {
      HiLog.error(TAG, 'fs rmdirSync error = ' + error?.message);
      HiSysEventUtil.reportFailureEvent(HiSysEventName.FILE_OPERATE_FAIL, InterfaceName.FS_RMDIR_SYNC,
        (error as BusinessError).code);
      return error;
    }
  }

  public static async moveFile(src: string, dest: string, mode?: number): Promise<void | BusinessError> {
    try {
      return await fs.moveFile(src, dest, mode);
    } catch (error) {
      HiLog.error(TAG, 'fs moveFile error = ' + error?.message);
      return error;
    }
  }

  public static async moveDir(src: string, dest: string, mode?: number): Promise<void | BusinessError> {
    try {
      return await fs.moveDir(src, dest, mode);
    } catch (error) {
      HiLog.error(TAG, 'fs moveDir error = ' + error?.message);
      return error;
    }
  }

  public static moveFileSync(src: string, dest: string, mode?: number): void | BusinessError {
    try {
      return fs.moveFileSync(src, dest, mode);
    } catch (error) {
      HiLog.error(TAG, 'fs moveFileSync error = ' + error?.message);
      return error;
    }
  }

  public static moveDirSync(src: string, dest: string, mode?: number): void | BusinessError {
    try {
      return fs.moveDirSync(src, dest, mode);
    } catch (error) {
      HiLog.error(TAG, 'fs moveDirSync error = ' + error?.message);
      return error;
    }
  }

  public static async rename(oldPath: string, newPath: string): Promise<void | BusinessError> {
    try {
      return await fs.rename(oldPath, newPath);
    } catch (error) {
      HiLog.error(TAG, 'fs rename error = ' + error?.message);
      return error;
    }
  }

  public static renameSync(oldPath: string, newPath: string): void | BusinessError {
    try {
      return fs.renameSync(oldPath, newPath);
    } catch (error) {
      HiLog.info(TAG, 'fs renameSync error = ' + error?.message);
      return error;
    }
  }

  public static async unlink(path: string): Promise<void | BusinessError> {
    try {
      return await fs.unlink(path);
    } catch (error) {
      HiLog.error(TAG, 'fs unlink error = ' + error?.message);
      return error;
    }
  }

  public static unlinkSync(path: string): void | BusinessError {
    try {
      return fs.unlinkSync(path);
    } catch (error) {
      HiLog.error(TAG, 'fs unlinkSync error = ' + error?.message);
      HiSysEventUtil.reportFailureEvent(HiSysEventName.FILE_OPERATE_FAIL, InterfaceName.FS_UNLINK_SYNC,
        (error as BusinessError).code);
      return error;
    }
  }

  public static async write(fd: number, buffer: ArrayBuffer | string,
    options?: WriteOptions): Promise<number | BusinessError> {
    try {
      return await fs.write(fd, buffer, options);
    } catch (error) {
      HiLog.error(TAG, 'fs write error = ' + error?.message);
      return error;
    }
  }

  public static writeSync(fd: number, buffer: ArrayBuffer | string, options?: WriteOptions): number | BusinessError {
    try {
      return fs.writeSync(fd, buffer, options);
    } catch (error) {
      HiLog.error(TAG, 'fs writeSync error = ' + error?.message);
      return error;
    }
  }

  public static async read(fd: number, buffer: ArrayBuffer, options?: ReadOptions): Promise<number | BusinessError> {
    try {
      return await fs.read(fd, buffer, options);
    } catch (error) {
      HiLog.error(TAG, 'fs read error = ' + error?.message);
      return error;
    }
  }

  public static readSync(fd: number, buffer: ArrayBuffer, options?: ReadOptions): number | BusinessError {
    try {
      return fs.readSync(fd, buffer, options);
    } catch (error) {
      HiLog.error(TAG, 'fs readSync error = ' + error?.message);
      return error;
    }
  }

  public static readTextSync(path: string): string | BusinessError {
    try {
      return fs.readTextSync(path);
    } catch (error) {
      HiLog.error(TAG, `fs readTextSync error =  ${error?.message}`);
      return error;
    }
  }

  public static listFileSync(path: string, options?: ListFileOptions): string[] | BusinessError {
    try {
      return fs.listFileSync(path, options);
    } catch (error) {
      HiLog.error(TAG, 'fs listFileSync error = ' + error?.message);
      // list的非文件夹路径，不做打点
      if ((error as BusinessError).code !== ERROR_CODE.FILE_ACCESS.NON_FOLDER) {
        HiSysEventUtil.reportFailureEvent(HiSysEventName.FILE_OPERATE_FAIL, InterfaceName.FS_LIST_FILE_SYNC,
          (error as BusinessError).code);
      }
      return error;
    }
  }

  public static async fsync(fd: number): Promise<void | BusinessError> {
    try {
      return await fs.fsync(fd);
    } catch (error) {
      HiLog.error(TAG, 'fs fsync error = ' + error?.message);
      HiSysEventUtil.reportFailureEvent(HiSysEventName.FILE_OPERATE_FAIL, InterfaceName.FS_FILE_SYNC,
        (error as BusinessError).code);
      return error;
    }
  }

  public static fsyncSync(fd: number): void | BusinessError {
    try {
      return fs.fsyncSync(fd);
    } catch (error) {
      HiLog.error(TAG, 'fs fsync error = ' + error?.message);
      HiSysEventUtil.reportFailureEvent(HiSysEventName.FILE_OPERATE_FAIL, InterfaceName.FS_FILE_SYNC,
        (error as BusinessError).code);
      return error;
    }
  }

  /**
   * 获取locationType
   *
   * @param filePath 文件路径
   * @returns locationType 文件位置 LOCAL/CLOUD
   */
  public static getLocationType(filePath: string): number {
    try {
      return fs.statSync(filePath).location;
    } catch (error) {
      HiLog.error(TAG, 'getLocationType err: ' + error?.message);
    }
    return LocationType.LOCAL;
  }

  /**
   * 强制删除文件
   * @param uri 删除文件的uri
   */
  public static forceDelete(uri: string): number | BusinessError {
    try {
      const fileuri: fileUri.FileUri = new fileUri.FileUri(uri);
      if (fs.statSync(fileuri.path).isDirectory()) {
        fs.rmdirSync(fileuri.path);
      } else {
        fs.unlinkSync(fileuri.path);
      }
      return 0;
    } catch (error) {
      HiLog.error(TAG, 'force delete file error: ' + error?.message);
      return error;
    }
  }

  /**
   * 文件夹判空
   * @param path 文件夹的uri
   */
  public static isFolderEmpty(path: string): boolean {
    try {
      const fileList = fs.listFileSync(path, { listNum: 1 });
      return fileList.length === 0;
    } catch (error) {
      HiLog.error(TAG, 'isFolderEmpty error: ' + error?.message);
      // 无法判断视为空文件夹
      return false;
    }
  }

  /**
   * 判断文件是否为文件夹（目前暂不支持应用沙箱目录）
   * @param path 文件
   * @returns
   */
  public static isFolder(path: string): boolean | BusinessError {
    try {
      const stat = fs.statSync(path);
      return stat?.isDirectory();
    } catch (error) {
      HiLog.errorPrivate(TAG, ' isFolder error: ' + error?.message, path);
      return error;
    }
  }

  /**
   * 判断文件是否为文件
   * @param path 文件路径
   * @returns 是否为普通文件 异常场景视为非文件
   */
  public static isFile(path: string): boolean {
    try {
      const stat = fs.statSync(path);
      return stat.isFile();
    } catch (error) {
      HiLog.error(TAG, `isFile error: ${error?.code} ${error?.message}`);
      return false;
    }
  }

  /**
   * 判断文件是否存在
   * @param uri 文件uri
   * @returns 判断结果
   */
  public static isFileExist(uri: string): boolean {
    let isExist: boolean = false;
    try {
      HiLog.info(TAG, 'open start');
      let fileFd: fs.File = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      fs.closeSync(fileFd);
      isExist = true;
    } catch (error) {
      HiLog.error(TAG, 'openSync fail: ' + error?.message);
      if (error.code === ERROR_CODE.FILE_ACCESS.FILE_NOT_EXIST) {
        HiLog.error(TAG, 'file is not exist');
      }
    }
    return isExist;
  }

  /**
   * 判断文件是否被删除（包括软删除和硬删除）
   * @param uri 文件uri
   * @returns 判断结果
   */
  public static isFileDeleted(uri: string): boolean {
    try {
      const fileuri: fileUri.FileUri = new fileUri.FileUri(uri);
      return !fs.accessSync(fileuri.path); // 此处报错说明被硬删除了
    } catch (error) {
      HiLog.error(TAG, 'accessSync fail: ' + error?.message);
    }
    return true;
  }

  /**
   * 判断目录下是否存在同名文件
   * @param destUri：目录uri
   * @param fileName：待判断的文件名
   * @returns 判断结果
   */
  public static isExistDupName(destUri: string, fileName: string): boolean {
    let isExistDupName: boolean = false;
    try {
      const destFileInfo: fileUri.FileUri = new fileUri.FileUri(destUri);
      const newFilePath: string = destFileInfo.path + '/' + fileName;
      isExistDupName = fs.accessSync(newFilePath);
    } catch (err) {
      HiLog.warn(TAG, 'isExistDupName err: ' + err?.message);
    }
    return isExistDupName;
  }

  public static getInoByUri(uri: string): string {
    try {
      const fileuri: fileUri.FileUri = new fileUri.FileUri(uri);
      const stat = fs.statSync(fileuri.path);
      return stat.ino.toString();
    } catch (error) {
      HiLog.error(TAG, `get ino failed, error message : ${error?.message}, error code : ${error?.code}`);
      return '';
    }
  }

  /**
   * 文件拷贝同步接口，适合十几兆的小文件拷贝
   * @param srcPath 源文件
   * @param destinationPath 目标文件
   * @param mode 拷贝模式
   * @returns true：拷贝成功，目标文件已经存在
   */
  public static copyFileSyncByPath(srcPath: string, destinationPath: string, mode?: number): boolean {
    try {
      fs.copyFileSync(srcPath, destinationPath, mode);
      return FsUtil.isExistSyncByPath(destinationPath);
    } catch (error) {
      HiLog.error(TAG, 'copyFileSyncByPath err: ' + error?.message);
      return false;
    }
  }

  public static pasteFileByFd(srcFileUri: string, destAlbumUri: string): boolean {
    if ((!srcFileUri) || (!destAlbumUri)) {
      HiLog.warn(TAG, 'params are err');
      return false;
    }
    let srcFile: fs.File | undefined;
    let destFile: fs.File | undefined;
    try {
      srcFile = fs.openSync(srcFileUri, fs.OpenMode.READ_ONLY);
      destFile = fs.openSync(destAlbumUri, fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
      let isDone = false;
      let buf = new ArrayBuffer(PASTE_BUFFER);
      while (!isDone) {
        let readLen = fs.readSync(srcFile.fd, buf);
        fs.writeSync(destFile.fd, buf, { length: readLen });
        isDone = readLen === 0;
      }
    } catch (err) {
      return false;
    } finally {
      if (srcFile) {
        FsUtil.closeSync(srcFile);
      }
      if (destFile) {
        FsUtil.closeSync(destFile);
      }
    }
    return true;
  }


  /**
   * 判断文件是否存在
   *
   * @param path 文件全目录
   * @returns true：文件存在
   */
  public static isExistSyncByPath(path: string): boolean {
    try {
      return fs.accessSync(path);
    } catch (error) {
      HiLog.error(TAG, 'isExistSyncByPath error = ' + error?.message);
      return false;
    }
  }

  /**
   * 重命名异步接口
   * @param oldPath 即将要重命名的文件全路径
   * @param newPath 重命名之后的文件全路径
   * @returns true：命名成功
   */
  public static renameSyncByPath(oldPath: string, newPath: string): boolean {
    try {
      fs.renameSync(oldPath, newPath);
      return FsUtil.isExistSyncByPath(newPath);
    } catch (error) {
      HiLog.info(TAG, 'fs renameSync error = ' + error?.message);
      return false;
    }
  }

  /**
   * 同步获取文件大小
   * @param path 文件全路径
   * @returns 文件夹大小
   */
  public static getFileSizeSyncByPath(path: string): number {
    try {
      return fs.statSync(path).size;
    } catch (error) {
      HiLog.error(TAG, 'getFileInfoByFs fail, error:' + error?.message);
      return 0;
    }
  }

  public static async fileCopy(srcFileUri: string, destFileUri: string,
    copySignal: fs.TaskSignal, progressListener: fs.ProgressListener): Promise<boolean> {
    if (!srcFileUri || !destFileUri) {
      HiLog.warn(TAG, 'fileCopy, params are err');
      return false;
    }

    let copyOption: fs.CopyOptions = {
      'progressListener': progressListener,
      'copySignal': copySignal
    };
    try{
      await fs.copy(srcFileUri, destFileUri, copyOption);
    } catch (error) {
      HiLog.error(TAG, `fileCopy error, code: ${error?.code} message: ${error?.message}`);
      return false;
    }

    return true;
  }

  /**
   * 设置文件拓展信息
   * @param path 文件沙箱路径
   * @param key 拓展信息名称
   * @param value 拓展信息值
   */
  public static setxattr(path: string, key: string, value: string): void {
    if (StringUtil.isEmpty(path)) {
      HiLog.warn(TAG, 'path to be marked is empty');
      return;
    }
    fs.setxattr(path, key, value).catch((err: BusinessError) => {
      HiLog.error(TAG, 'Failed to set extended attribute with error message: ' +
      err.message + ', error code: ' + err.code);
    });
  }
}
