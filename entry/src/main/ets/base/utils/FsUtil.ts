import type { BusinessError } from '@ohos.base';
import fs from '@ohos.file.fs';
import fileuri from '@ohos.file.fileuri';
import type uri from '@ohos.uri';
import Logger from '../log/Logger';

export class FsUtil {
  static readonly TAG: string = 'FsUtil';

  public static async stat(file: string | number): Promise<fs.Stat | BusinessError> {
    try {
      return await fs.stat(file);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs stat error = ' + JSON.stringify(error));
      return error;
    }
  }

  public static statSync(file: string | number): fs.Stat | BusinessError {
    try {
      return fs.statSync(file);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs statSync error = ' + JSON.stringify(error));
      return error;
    }
  }

  public static async access(path: string): Promise<boolean | BusinessError> {
    try {
      return await fs.access(path);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs access error = ' + JSON.stringify(error));
      return error;
    }
  }

  public static accessSync(path: string): boolean {
    try {
      return fs.accessSync(path);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs accessSync error = ' + JSON.stringify(error));
      return false;
    }
  }

  public static openSync(path: string, mode?: number): fs.File | BusinessError {
    try {
      return fs.openSync(path, mode);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs openSync error = ' + JSON.stringify(error));
      return error;
    }
  }

  public static async close(file: number | fs.File): Promise<void | BusinessError> {
    try {
      return await fs.close(file);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs close error = ' + JSON.stringify(error));
      return error;
    }
  }

  public static closeSync(file: number | fs.File): void | BusinessError {
    try {
      return fs.closeSync(file);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs closeSync error = ' + JSON.stringify(error));
      return error;
    }
  }

  public static async mkdir(path: string, recursion: boolean = false): Promise<void | BusinessError> {
    try {
      return await fs.mkdir(path, recursion);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs mkdir error = ' + JSON.stringify(error));
      return error;
    }
  }

  public static mkdirSync(path: string, recursion: boolean = false): void | BusinessError {
    try {
      return fs.mkdirSync(path, recursion);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs mkdirSync error = ' + JSON.stringify(error));
      return error;
    }
  }

  public static async rmdir(path: string): Promise<void | BusinessError> {
    try {
      return await fs.rmdir(path);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs rmdir error = ' + JSON.stringify(error));
      return error;
    }
  }

  public static rmdirSync(path: string): void | BusinessError {
    try {
      return fs.rmdirSync(path);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs rmdirSync error = ' + JSON.stringify(error));
      return error;
    }
  }

  public static async moveFile(src: string, dest: string, mode?: number): Promise<void | BusinessError> {
    try {
      return await fs.moveFile(src, dest, mode);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs moveFile error = ' + JSON.stringify(error));
      return error;
    }
  }

  public static async moveDir(src: string, dest: string, mode?: number): Promise<void | BusinessError> {
    try {
      return await fs.moveDir(src, dest, mode);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs moveDir error = ' + JSON.stringify(error));
      return error;
    }
  }

  public static moveFileSync(src: string, dest: string, mode?: number): void | BusinessError {
    try {
      return fs.moveFileSync(src, dest, mode);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs moveFileSync error = ' + JSON.stringify(error));
      return error;
    }
  }

  public static moveDirSync(src: string, dest: string, mode?: number): void | BusinessError {
    try {
      return fs.moveDirSync(src, dest, mode);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs moveDirSync error = ' + JSON.stringify(error));
      return error;
    }
  }

  public static async rename(oldPath: string, newPath: string): Promise<void | BusinessError> {
    try {
      return await fs.rename(oldPath, newPath);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs rename error = ' + JSON.stringify(error));
      return error;
    }
  }

  public static renameSync(oldPath: string, newPath: string): void | BusinessError {
    try {
      return fs.renameSync(oldPath, newPath);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs renameSync error = ' + JSON.stringify(error));
      return error;
    }
  }

  public static async unlink(path: string): Promise<void | BusinessError> {
    try {
       return await fs.unlink(path);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs unlink error = ' + JSON.stringify(error));
      return error;
    }
  }

  public static unlinkSync(path: string): void | BusinessError {
    try {
      return fs.unlinkSync(path);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs unlinkSync error = ' + JSON.stringify(error));
      return error;
    }
  }

  // @ts-ignore
  public static async write(fd: number, buffer: ArrayBuffer | string, options?: fs.WriteOptions): Promise<number | BusinessError> {
    try {
      return await fs.write(fd, buffer, options);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs write error = ' + JSON.stringify(error));
      return error;
    }
  }

  // @ts-ignore
  public static writeSync(fd: number, buffer: ArrayBuffer | string, options?: fs.WriteOptions): number | BusinessError {
    try {
      return fs.writeSync(fd, buffer, options);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs writeSync error = ' + JSON.stringify(error));
      return error;
    }
  }

  // @ts-ignore
  public static async read(fd: number, buffer: ArrayBuffer, options?: fs.ReadOptions): Promise<number | BusinessError> {
    try {
      return await fs.read(fd, buffer, options);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs read error = ' + JSON.stringify(error));
      return error;
    }
  }

  // @ts-ignore
  public static readSync(fd: number, buffer: ArrayBuffer, options?: fs.ReadOptions): number | BusinessError {
    try {
      return fs.readSync(fd, buffer, options);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs readSync error = ' + JSON.stringify(error));
      return error;
    }
  }

  public static readTextSync(path: string): string | BusinessError {
    try {
      return fs.readTextSync(path);
    } catch (error) {
      Logger.i(FsUtil.TAG, `fs readTextSync error =  ${JSON.stringify(error)}`);
      return error;
    }
  }

  // @ts-ignore
  public static listFileSync(path: string, options?: fs.ListFileOptions): string[] | BusinessError {
    try {
      let res = fs.listFileSync(path, options);
      return res;
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs listFileSync error = ' + JSON.stringify(error));
      return error;
    }
  }

  public static async fsync(fd: number): Promise<void | BusinessError> {
    try {
      return await fs.fsync(fd);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs fsync error = ' + JSON.stringify(error));
      return error;
    }
  }

  public static fsyncSync(fd: number): void | BusinessError {
    try {
      return fs.fsyncSync(fd);
    } catch (error) {
      Logger.i(FsUtil.TAG, 'fs fsync error = ' + JSON.stringify(error));
      return error;
    }
  }

  /**
   * 强制删除文件
   * @param uri 删除文件的uri
   */
  public static forceDelete(uri: string): number | BusinessError {
    try {
      let fileUri: fileuri.FileUri = new fileuri.FileUri(uri);
      let filePath: string = fileUri.path;
      if (fs.statSync(filePath).isDirectory()) {
        fs.rmdirSync(filePath);
      } else {
        fs.unlinkSync(filePath);
      }
      return 0;
    } catch (error) {
      Logger.i(FsUtil.TAG, 'force delete file error: ' + JSON.stringify(error));
      return error;
    }
  }

  /**
   * 文件夹判空
   * @param path 文件夹的uri
   */
  public static isFolderEmpty(path: string): boolean | BusinessError {
    try {
      let fileList = fs.listFileSync(path, { listNum: 1 });
      return fileList.length === 0;
    } catch (error) {
      Logger.i(FsUtil.TAG, 'isFolderEmpty error: ' + JSON.stringify(error));
      return error;
    }
  }
  /**
   * 判断文件是否为文件夹（目前暂不支持应用沙箱目录）
   * @param path 文件
   * @returns
   */
  public static isFolder(path: string): boolean | BusinessError {
    try {
      let stat = fs.statSync(path);
      return stat?.isDirectory();
    } catch (error) {
      Logger.i(FsUtil.TAG, path + ' isFolder error: ' + JSON.stringify(error));
      return error;
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
      Logger.i(FsUtil.TAG, 'open start');
      let fileFd: fs.File = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      fs.closeSync(fileFd);
      isExist = true;
    } catch (error) {
      Logger.i(FsUtil.TAG, 'openSync fail: ' + JSON.stringify(error));
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
      Logger.i(FsUtil.TAG, 'open start');
      let fileFd: fs.File = fs.openSync(uri, fs.OpenMode.READ_ONLY); // 此处报错说明被硬删除了
      const path = fileFd.path;
      fs.closeSync(fileFd);
      let stat = fs.statSync(path);
      if (stat.ctime === 0 && stat.mtime === 0) { // 说明被软删除了
        return true;
      }
      return false;
    } catch (error) {
      Logger.i(FsUtil.TAG, 'openSync fail: ' + JSON.stringify(error));
      return true;
    }
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
      let destFileInfo: uri.URI = new fileuri.FileUri(destUri);
      let newFilePath: string = destFileInfo.path + '/' + fileName;
      isExistDupName = fs.accessSync(newFilePath);
    } catch (err) {
      Logger.i(FsUtil.TAG, 'isExistDupName err: ' + JSON.stringify(err));
    }
    return isExistDupName;
  }

  public static getInoByUri(uri: string): string {
    try {
      let fileUri: fileuri.FileUri = new fileuri.FileUri(uri);
      let stat = fs.statSync(fileUri.path);
      return stat.ino.toString();
    } catch (error) {
      Logger.i(FsUtil.TAG, `get ino failed, error message : ${error?.message}, error code : ${error?.code}`);
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
      Logger.i(FsUtil.TAG, 'copyFileSyncByPath err: ' + JSON.stringify(error));
      return false;
    }
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
      Logger.i(FsUtil.TAG, 'isExistSyncByPath error = ' + JSON.stringify(error));
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
      Logger.i(FsUtil.TAG, 'fs renameSync error = ' + JSON.stringify(error));
      return false;
    }
  }

  /**
   * 同步获取文件大小
   * @param path 文件全路径
   * @returns 文件夹大小
   */
  public static getFileSizeSyncByPath(path: string): number {
    let size = 0;
    try {
      let stat = fs.statSync(path);
      size = stat.size;
    } catch (error) {
      Logger.i(FsUtil.TAG, 'getFileInfoByFs fail, error:' + JSON.stringify(error));
    }
    return size;
  }
}