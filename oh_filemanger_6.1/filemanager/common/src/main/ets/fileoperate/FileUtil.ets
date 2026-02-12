/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { FileInfo } from './FileInfo';
import { VirtualUri } from '../const/FolderRecord';
import type { FileOrGroup } from '../filesort/FileOrGroup';
import fileExtensionInfo from '@ohos.file.fileExtensionInfo';
import { ObjectUtil } from '../utils/ObjectUtil';
import { HiLog } from '../dfx/HiLog';
import { Constant, FileSourceUri } from '../const/Constant';
import { ArrayUtil } from '../utils/ArrayUtil';
import fs, { ListFileOptions } from '@ohos.file.fs';
import FileUri from '@ohos.file.fileuri';
import distributedAccount from '@ohos.account.distributedAccount';
import { StringUtil } from '../utils/StringUtil';
import volumeManager from '@ohos.file.volumeManager';
import { DiskInfo, RootInfo } from '../externel/DiskInfo';
import { ERROR_CODE } from '../const/ErrorCode';
import { FsUtil } from '../utils/FsUtil';
import { HiSysEventUtil } from '../dfx/HiSysEventUtil';
import { BusinessError } from '@kit.BasicServicesKit';
import { HiSysEventName, InterfaceName } from '../const/HiSysEventConst';
import { FileDisplayType, FILE_DISPLAY_TYPE_MAP } from '../utils/FileDisplayType';
import { CommonUtil } from '../utils/CommonUtil';
import { ResourceUtil } from '../utils/ResourceUtil';
import { FileAccessError } from '../error/Error';
import lazy SecurityNapi from 'libSecurity.so';
import { bundleResourceManager } from '@kit.AbilityKit';
import lazy { file_monitor_napi } from '../model/search/FileMonitorNapi';
import { PAGE_ROUTE_CONST } from '../const/PageRouteConst';
import { AppDataPathUtil } from '../utils/AppDataPathUtil';
import { MyPhoneConstant } from '../const/MyPhoneConstant';
import { ExternalStorageUtil } from '../externel/ExternalStorageUtil';
import { getResourceString } from '../utils/Tools';
import { DeviceConfig } from '../data/DeviceConfig';
enum CompressType {
  ZIP = '.zip',
  Z7 = '.7z',
  RAR = '.rar',
  TAR = '.tar',
  GZ = '.gz',
  GZIP = '.gzip',
}
const TAG = 'FileUtil';

/**
 * File Util
 */
export class FileUtil {
  /**
   * uri 格式开头
   */
  public static readonly URI_START = 'file://';
  public static readonly URI_GALLERY = 'file://media/PhotoAlbum';
  private static readonly FILE_SPLIT: string = '/';
  /**
   * FAF 默认根路径
   */
  public static readonly URI_INTERNAL = 'file://docs/storage/Users/currentUser';

  /**
   * 名称超长连接字符
   */
  public static CONNECT_NAME_STR: String = '...';
  /**
   * 展示最长长度
   */
  public static readonly MAX_NAME_LENGTH: number = 12;
  /**
   * 保留长度前后各5个
   */
  public static readonly KEEP_NAME_LENGTH: number = 5;

  /**
   * @param uri : file uri
   * @return fileType
   */
  public static getFileTypeFromUri(uri?: string): string {
    if (!uri) {
      HiLog.warn(TAG, 'getFileTypeFromUri input string is empty');
      return '';
    }
    let index = uri.lastIndexOf('.');
    if ((!index) || (index <= 0)) {
      return '';
    }
    return uri.slice(index).toLowerCase();
  }

  public static getFileParentPathFromUri(uri?: string): string {
    if (!uri) {
      HiLog.warn(TAG, 'getFileParentPathFromUri input string is empty');
      return '';
    }
    let index = uri.lastIndexOf('/');
    if ((!index) || (index <= 0)) {
      return '';
    }
    return uri.slice(0, index);
  }

  /**
   * 获取文件名的前缀、后缀, 如：xx/abc.txt的前缀为abc, 后缀为txt
   * @param uri
   */
  public static getPreFixAndSuffixByUri(uri: string): string[] {
    let result: string[] = ['', ''];
    if (StringUtil.isEmpty(uri)) {
      HiLog.warn(TAG, 'getPrefixAndSuffix, params are err');
      return result;
    }
    let tempName: string = uri;
    let index = uri.lastIndexOf('/');
    if (index !== -1) {
      tempName = uri.substring(index + 1);
    }

    index = tempName.lastIndexOf('.');
    if (index === -1) {
      HiLog.warn(TAG, 'getPrefixAndSuffix, fileName has no suffix');
      result[0] = tempName;
      return result;
    }
    result[0] = tempName.substring(0, index);
    result[1] = tempName.substring(index + 1);
    HiLog.infoPrivate(TAG, `getPrefixAndSuffix, suffix ${result[1]}`, 'prefix = ' + result[0]);
    return result;

  }

  /**
   * 获取文件名的前缀、后缀, 如：abc.txt的前缀为abc, 后缀为.txt
   * @param fileName 文件名
   */
  public static getPrefixAndSuffix(fileName: string): string[] {
    let result: string[] = ['', ''];
    if (StringUtil.isEmpty(fileName)) {
      HiLog.warn(TAG, 'getPrefixAndSuffix, params are err');
      return result;
    }
    let index = fileName.lastIndexOf('.');
    if (index === -1) {
      HiLog.warn(TAG, 'getPrefixAndSuffix, fileName has no suffix');
      result[0] = fileName;
      return result;
    }
    result[0] = fileName.substring(0, index);
    result[1] = fileName.substring(index);
    HiLog.infoPrivate(TAG, `getPrefixAndSuffix, suffix ${result[1]}`, 'prefix = ' + result[0]);
    return result;
  }

  /**
   * 将uri编码，支持对特殊字符的编码，例如分隔符:"/"
   *
   * @param uri  需要编码的uri
   * @returns 返回编码之后的结果
   */
  public static encodeURIForFileManager(uri: string): string {
    if (StringUtil.isEmpty(uri)) {
      HiLog.warn(TAG, 'encodeURIForFileManager input string is empty');
      return uri;
    }
    try {
      uri = encodeURIComponent(uri);
    } catch (err) {
      HiLog.error(TAG, 'encode error : ' + JSON.stringify(err));
      uri = '';
    }
    return uri;
  }

  /**
   * 将uri解码，支持对特殊字符的解码
   *
   * @param uri  需要解码的uri
   * @returns 返回解码之后的结果
   */
  public static decodeURIForFileManager(uri: string): string {
    if (StringUtil.isEmpty(uri)) {
      HiLog.warn(TAG, 'decodeURIForFileManager input string is empty');
      return uri;
    }
    try {
      uri = decodeURIComponent(uri);
    } catch (err) {
      HiLog.error(TAG, 'decode error : ' + JSON.stringify(err));
      uri = '';
    }
    return uri;
  }

  /**
   * 根据fileAccess.FileInfo中的mode匹配是否是文件夹
   * @param mode number
   * @returns boolean
   */
  public static isFolder(mode: number): boolean {
    return (mode & fileExtensionInfo.DocumentFlag.REPRESENTS_DIR) === fileExtensionInfo.DocumentFlag.REPRESENTS_DIR;
  }

  public static getParentRelativePath(relativePath: string): string {
    let curPath = relativePath;
    if (StringUtil.isEmpty(relativePath)) {
      HiLog.warn(TAG, 'getParentRelativePath input string is empty');
      return '';
    }

    let index: number = curPath.lastIndexOf('/');
    // 去掉最后一个'/'
    if (index === curPath.length - 1) {
      curPath = curPath.substr(0, index);
    }
    index = curPath.lastIndexOf('/');
    if (index <= 0) {
      return '';
    }
    return curPath.substr(0, index);
  }

  /**
   * 是否是uri路径
   * @param uri 路径
   * @returns 结果
   */
  public static isUriPath(uri: string): boolean {
    if (StringUtil.isEmpty(uri)) {
      HiLog.warn(TAG, 'isUriPath input string is empty');
      return false;
    }
    // 过滤掉^file:\/\/\/+的非法uri
    const isLegalUri: boolean = uri.startsWith(FileUtil.URI_START) &&
      !uri.substring(FileUtil.URI_START.length).startsWith('/');
    if (!isLegalUri) {
      HiLog.warn(TAG, 'isUriPath: path illegal');
    }
    return isLegalUri;
  }

  public static containTrashFile(files: FileInfo[]): boolean {
    return files.some((item: FileInfo) => {
      return item.srcPath !== '';
    })
  }

  public static async hardDelete(uri: string): Promise<boolean> {
    if (StringUtil.isEmpty(uri)) {
      HiLog.warn(TAG, 'hardDelete input string is empty');
      return false;
    }
    try {
      let fileInfo = FileInfo.fromFileUri(uri);
      if (StringUtil.isEmpty(fileInfo.relativePath)) {
        return false;
      }
      await FileUtil.hardDeleteByFs(fileInfo.relativePath, fileInfo.isFolder);
      return true;
    } catch (e) {
      HiLog.error(TAG, 'hardDelete error: ' + JSON.stringify(e));
    }
    return false;
  }

  private static async hardDeleteByFs(path: string, isFolder: boolean): Promise<void> {
    if (!isFolder) {
      await FsUtil.unlink(path);
    } else {
      await FsUtil.rmdir(path);
    }
  }

  public static getPathWithFileSplit(path: string): string {
    let fileSplit: string = '/';
    if (path && (!path.endsWith(fileSplit))) {
      path = path + fileSplit;
    }
    return path;
  }

  public static getFileNameReName(fileName: string): string[] {
    if (StringUtil.isEmpty(fileName)) {
      return [];
    }
    let index = fileName.lastIndexOf(Constant.RENAME_CONNECT_CHARACTER);
    if (index === -1) {
      return [];
    }
    let str = fileName.substring(index + 1, fileName.length);
    let name = fileName.substring(0, index);
    return [name, str];
  }

  public static getCurrentDir(path: string, isFolder: boolean): string {
    if (isFolder) {
      return path;
    }
    if (path) {
      let index: number = path.lastIndexOf('/');
      let len: number = path.length;
      if ((len > 1) && (index > 1)) {
        return path.substring(0, index);
      }
    }
    return path;
  }

  public static openFile(fileUri: string, mode: number = fs.OpenMode.READ_ONLY): number {
    let fd = 0;
    try {
      const file = fs.openSync(fileUri, mode);
      fd = file.fd;
    } catch (error) {
      HiLog.error(TAG, 'openFile fail, error:' + JSON.stringify(error));
    }
    return fd;
  }

  /**
   * 给指定fileUri设置删除维测标记
   * @param fileUri 文件Uri
   * @param mode 打开方式，默认是文件夹
   * @returns 返回设置结果，0代表成功，-1代表失败
   */
  public static setDeleteControlFlag(fileUri: string, mode: number = fs.OpenMode.DIR): number {
    let file: fs.File | undefined;
    try {
      HiLog.info(TAG, `setDeleteControlFlag start.`);
      file = fs.openSync(fileUri, mode);
      const res = SecurityNapi.setDeleteControlFlag(file.fd);
      return res;
    } catch (error) {
      HiLog.error(TAG, 'setDeleteControlFlag fail, error:' + JSON.stringify(error));
      return -1;
    } finally {
      try {
        if (!!file) {
          fs.closeSync(file);
        }
      } catch (err) {
        HiLog.error(TAG, `setDeleteControlFlag close file error: ${JSON.stringify(err)}`);
      }
    }
  }

  /**
   * 将文件uri转换成FileUri对象
   */
  public static getFileUriObjectFromUri(uri: string): FileUri.FileUri | undefined {
    let fileUriObject: FileUri.FileUri | undefined;
    try {
      fileUriObject = new FileUri.FileUri(uri);
    } catch (error) {
      HiLog.error(TAG, 'getFileUriObjectFromUri fail, error:' + JSON.stringify(error));
    }
    return fileUriObject;
  }

  /**
   * 通过将文件uri转换成FileUri对象获取文件名
   * @param uri 文件uri
   * @returns 文件名
   */
  public static getFileNameFromUri(uri: string): string {
    let fileName = '';
    const fileUriObj = FileUtil.getFileUriObjectFromUri(uri);
    if (!!fileUriObj) {
      fileName = fileUriObj.name;
    }
    return fileName;
  }

  /**
   * 通过将文件uri转换成FileUri对象获取文件的沙箱路径
   * @param uri 文件uri
   * @returns 文件的沙箱路径
   */
  public static getPathFromUri(uri: string): string {
    let path = '';
    const fileUriObj = FileUtil.getFileUriObjectFromUri(uri);
    if (!!fileUriObj) {
      path = fileUriObj.path;
    }
    return path;
  }

  /**
   * 根据Uri通过fs获取文件夹下的子文件
   * @param uri 文件夹uri
   * @param recursion 是否递归获取子文件夹下的文件
   * @returns 子文件的文件名列表
   */
  public static getSubFileListByUri(uri: string, recursion: boolean = false): string[] {
    let fileNameList: string[] = [];
    const path: string = FileUtil.getPathFromUri(uri);
    try {
      fileNameList = fs.listFileSync(path, {
        recursion: recursion
      });
    } catch (error) {
      HiLog.errorPrivate(TAG, `getSubFileListByUri fail, error: ${JSON.stringify(error)}`, uri);
    }
    return fileNameList;
  }

  /**
   * share文件名多语言化
   * 除中文环境其它全显示为英文
   * @param fileName 文件名
   */
  public static replaceFileName(fileName: string): string {
    let tempFileName: string = fileName;
    let firstPath: string = '';
    let lastPath: string = '';
    if (tempFileName.startsWith(FileUtil.FILE_SPLIT)) {
      tempFileName = tempFileName.substring(tempFileName.indexOf(FileUtil.FILE_SPLIT) + 1);
      firstPath = FileUtil.FILE_SPLIT;
    }
    if (tempFileName.endsWith(FileUtil.FILE_SPLIT)) {
      tempFileName = tempFileName.substring(0, tempFileName.lastIndexOf(FileUtil.FILE_SPLIT));
      lastPath = FileUtil.FILE_SPLIT;
    }
    if (tempFileName.toLowerCase() === Constant.FOLDER_SHARE.toLowerCase()) {
      fileName = firstPath + ResourceUtil.getStringByResource($r('app.string.share_folder_name')) + lastPath;
    }
    return fileName;
  }

  /**
   * 根据Uri通过fs获取文件夹下的子文件信息
   * @param uri 文件夹uri
   * @param recursion 是否递归获取子文件夹下的文件
   * @returns 子文件的文件名列表
   */
  public static async getSubFileNameByUriWithFs(uri: string, recursion: boolean = false,
    showHiddenItem: boolean = false): Promise<Array<string>> {
    let fileNameList: string[] = [];
    let option: ListFileOptions =
      showHiddenItem ? { recursion: recursion } :
        { recursion: recursion, filter: { displayName: [Constant.HIDDEN_ITEM_FILTER] } };
    const path = FileUtil.getPathFromUri(uri);
    try {
      fileNameList = await fs.listFile(path, option);
    } catch (error) {
      HiLog.errorPrivate(TAG, `getFileNameListByFs fail, code: ${error?.code}, error: ${error?.message}`, `, path = ${path}`);
    }
    return fileNameList;
  }

  /**
   * 根据path通过fs获取文件夹下的子文件信息
   * @param path 文件夹uri
   * @param recursion 是否递归获取子文件夹下的文件
   * @returns 子文件的文件名列表
   */
  public static async getSubFileNameByPathWithFs(path: string, recursion: boolean = false,
    showHiddenItem: boolean = false): Promise<Array<string>> {
    let fileNameList: string[] = [];
    let option: ListFileOptions =
      showHiddenItem ? { recursion: recursion } :
        { recursion: recursion, filter: { displayName: [Constant.HIDDEN_ITEM_FILTER] } };
    try {
      fileNameList = await fs.listFile(path, option);
    } catch (error) {
      HiLog.error(TAG, 'getFileNameListByFs fail, error:' + JSON.stringify(error));
    }
    return fileNameList;
  }

  /**
   * 通过fs获取文件信息
   * @param uri 文件沙箱路径或fd
   * @returns 文件stat对象
   */
  public static async getFileStatByFs(file: string | number): Promise<fs.Stat | undefined> {
    let stat: fs.Stat | undefined;
    try {
      stat = await fs.stat(file);
    } catch (error) {
      HiLog.error(TAG, 'getFileInfoByFs fail, error:' + JSON.stringify(error));
    }
    return stat;
  }

  /**
   * 通过fs获取文件的大小
   * @param uri 文件沙箱路径或fd
   * @returns 文件大小
   */
  public static async getFileSizeByFs(file: string | number): Promise<number> {
    const fileStat = await FileUtil.getFileStatByFs(file);
    if (!fileStat) {
      return 0;
    }
    return fileStat.size;
  }

  /**
   * 通过fs获取文件夹下的子文件个数
   * @param uri 文件夹uri
   * @returns 子文件个数
   */
  public static async getFolderSubFileCount(uri: string, recursion: boolean = false,
    showHiddenItem: boolean = false): Promise<number> {
    let count = 0;
    try {
      const fileNameList = await FileUtil.getSubFileNameByUriWithFs(uri, recursion, showHiddenItem);
      if (!ArrayUtil.isEmpty(fileNameList)) {
        count = fileNameList.length;
      }
      HiLog.debugPrivate(TAG, `getSubFileCount uri =, count = ${count}`, `uri = ${uri}`);
    } catch (error) {
      HiLog.errorPrivate(TAG, `getSubFileCount fail, error：${JSON.stringify(error)}`, `fileUri:${uri}}`);
    }
    return count;
  }

  /**
   * 根据文件的沙箱路径获取文件uri
   * @param path 文件的沙箱路径
   * @returns 文件的uri
   */
  public static getUriFromPath(path: string): string {
    let uri = '';
    try {
      // 该接口如果以’/'结尾，返回的uri会以‘/'结尾
      uri = FileUri.getUriFromPath(path);
    } catch (error) {
      HiLog.error(TAG, 'getUriFromPath fail, error:' + JSON.stringify(error));
    }
    return uri;
  }

  public static getParentPathForDetail(uri: string): string {
    if (!uri || uri.indexOf('/') === -1) {
      return uri;
    }
    try {
      return uri.substring(MyPhoneConstant.SYSTEM_URI.length + 1, uri.lastIndexOf('/'));
    } catch (err) {
      HiLog.warn(TAG, `getParentPathForDetail error: ${err}`);
      return '';
    }
  }

  /**
   * 通过fs获取文件夹下所有子文件的大小
   * @param uri 文件夹uri
   * @returns 文件夹大小
   */
  public static async getFolderSizeByFs(uri: string): Promise<number> {
    HiLog.infoPrivate(TAG, 'getFolderSizeByFs start: ', uri);
    const fileNameList = await FileUtil.getSubFileNameByUriWithFs(uri, true, true);
    const path = FileUtil.getPathFromUri(uri);
    let tempFolderSize = 0;
    if (!ArrayUtil.isEmpty(fileNameList)) {
      HiLog.info(TAG, 'getFolderSizeByFs fileSize: ' + fileNameList.length);
      for (let fileName of fileNameList) {
        const fileStat = await FileUtil.getFileStatByFs(path + fileName);
        if (!fileStat) {
          continue;
        }
        tempFolderSize += fileStat.size;
      }
    }
    HiLog.info(TAG, 'getFolderSizeByFs end: ' + tempFolderSize);
    return tempFolderSize;
  }

  /**
   * 通过fs接口判断文件是否存在
   * @param uri FAF的uri
   * @returns 返回文件是否存在
   */
  public static isExistByUriWithFs(uri: string): boolean {
    try {
      return fs.accessSync(FileUtil.getPathFromUri(uri));
    } catch (e) {
      HiLog.error(TAG, 'isExistByFs error: ' + JSON.stringify(e));
    }
    return false;
  }

  /**
   * 根据URI 获取文件名  /a/b/c/d.zip
   * @param uri
   * @returns
   */
  public static getFileNameByUri(uri: string): string {
    let fileName: string = '';
    const result: string[] = uri.split('/');
    if (result.length > 0) {
      fileName = result[result.length - 1];
    }
    return fileName;
  }

  /**
   * 根据 uri/path 判断是不是压缩包格式的后缀，目前支持 .zip .7z .rar .tar .gz
   * @param uriOrPath
   * @returns boolean
   */
  public static isArchiveSuffix(uriOrPath: string): boolean {
    if (!uriOrPath) {
      HiLog.warn(TAG, 'isArchiveSuffix, uriOrPath is empty string or undefined');
      return false;
    }
    const lowerUri = uriOrPath.toLocaleLowerCase();
    for (const suffix of Object.values(CompressType)) {
      if (lowerUri.endsWith(suffix)) {
        return true;
      }
    }
    return false;
  }

  /**
   * 通过uri/path判断是否是压缩文件
   * @param uriOrPath 文件uri/path
   * @returns 返回是否是压缩文件
   */
  public static isArchiveByUri(uriOrPath: string): boolean {
    if (!uriOrPath) {
      HiLog.warn(TAG, 'isArchiveByUri, uriOrPath is empty string or undefined');
      return false;
    }
    if (!FileUtil.isArchiveSuffix(uriOrPath)) {
      return false;
    }
    let fileUriObj: FileUri.FileUri;
    try {
      fileUriObj = new FileUri.FileUri(uriOrPath);
    } catch (e) {
      HiLog.errorPrivate(TAG, 'invalid file uriOrPath: ', uriOrPath);
      return false;
    }
    return !FsUtil.isFolder(fileUriObj.path);
  }

  /**
   * 通过fs接口判断文件是否存在
   * @param path 绝对路径
   * @returns 返回文件是否存在
   */
  public static async isExistByPathWithFs(path: string): Promise<boolean> {
    HiLog.infoPrivate(TAG, 'isExistByPathWithFs path: ', path);

    if (StringUtil.isEmpty(path)) {
      return false;
    }
    let isExist = false;
    try {
      isExist = await fs.access(path);
    } catch (e) {
      HiLog.error(TAG, 'isExistByFs error: ' + JSON.stringify(e));
    }
    return isExist;
  }

  public static async syncFile(uri: string): Promise<void> {
    if (StringUtil.isEmpty(uri)) {
      return;
    }
    let newFile = undefined;
    try {
      let newFile = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      await fs.fsync(newFile.fd);
    } catch (error) {
      HiLog.info(TAG, 'createDir error ' + error.toString());
    } finally {
      if (newFile) {
        try {
          fs.closeSync(newFile);
        } catch (error) {
          HiLog.info(TAG, 'close error ' + error.toString());
        }
      }
    }
  }

  /**
   * 将uri解码，支持对特殊字符的解码
   *
   * @param uri  需要解码的uri
   * @returns 返回解码之后的结果
   */
  public static decodeURIComponent(uri: string): string {
    try {
      uri = decodeURIComponent(uri);
    } catch (err) {
      HiLog.error(TAG, JSON.stringify(err));
      uri = '';
    }
    return uri;
  }

  public static getIndex(fileName: string, fileNameList: string[] = []): number {
    return fileNameList.findIndex(value => value.toLowerCase() === fileName.toLowerCase());
  }

  /**
   * 通过uri获取列表中文件夹的最大层级
   *
   * @param uriList uri列表
   * @returns 如果文件列表包含文件夹，则返回文件夹的最大层级；否则返回0
   */
  static async getMaxFolderLevelByUri(uriList: string[]): Promise<number> {
    let folderLevel: number = 0;
    if (uriList.length === 0) {
      return folderLevel;
    }
    for (let i = 0; i < uriList.length; i++) {
      let uri = uriList[i];
      let subFolderList = FileUtil.getSubFoldersSync(uri);
      folderLevel = Math.max(folderLevel, await FileUtil.getMaxFolderLevelByUri(subFolderList) + 1);
    }
    return folderLevel;
  }

  /**
   * 根据Uri获取目标文件夹下的子文件夹uri-同步方法
   *
   * @param dirUri 目标文件夹uri
   * @returns 目标文件夹下的子文件夹列表
   */
  public static getSubFoldersSync(dirUri: string): string[] {
    let folders: string[] = [];
    // 获取文件夹路径
    const path = FileUtil.getPathFromUri(dirUri);
    // 遍历源文件夹下一层所有文件夹
    const listFileOption: ListFileOptions = {
      recursion: false,
      listNum: 0,
    };
    let filenames = FsUtil.listFileSync(path, listFileOption) as Array<string>;
    let len = filenames.length;
    for (let i = 0; i < len; i++) {
      if (filenames[i].startsWith('.')) {
        continue;
      }
      let filePath = path + '/' + filenames[i];
      const result = FsUtil.statSync(filePath);
      if (result instanceof Error || !result.isDirectory()) {
        continue; // 不是文件夹，跳过
      }
      // 根据path获取uri
      let uriTemp = FileUtil.getUriFromPath(filePath);
      folders.push(uriTemp);
    }
    return folders;
  }

  /**
   * 将根目录rootInfo转换成DiskInfo
   * @param rootInfo rootInfo
   * @returns diskInfo
   */
  public static async getRootDiskInfo(rootInfo: RootInfo): Promise<DiskInfo | undefined> {
    HiLog.info(TAG, 'getRootDiskInfo deviceType = ' + rootInfo.deviceType);

    if (rootInfo.deviceType === fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK) {
      return new DiskInfo('LOCAL', '', rootInfo.relativePath, rootInfo);
    }

    // 挂载目录
    if (rootInfo.deviceType === fileExtensionInfo.DeviceType.DEVICE_EXTERNAL_USB) {
      let description: string = '';
      let path: string = '';
      let uuid: string = '';
      let isTfCard: boolean = false;
      try {
        let volumeInfo: volumeManager.Volume = await volumeManager.getVolumeByUuid(rootInfo.displayName);
        path = volumeInfo.path;
        uuid = volumeInfo.uuid;
        isTfCard = await FileUtil.isTfCard(uuid);
        description =
          isTfCard ? ResourceUtil.getStringByResource($r('app.string.externalDisk')) : volumeInfo.description;
      } catch (err) {
        HiLog.error(TAG, 'getVolumeById err: ' + JSON.stringify(err) + ', ' + err.toString());
      }
      return new DiskInfo(uuid, description, path, rootInfo, isTfCard);
    }
    return undefined;
  }

  // 获取外接储存是否为TF卡
  public static async isTfCard(uuid: string): Promise<boolean> {
    let deviceType: number = Constant.EXTERNAL_DEVICE_TYPE.UNKNOWN;
    try {
      const fsUuidModel: file_monitor_napi.FsUuidModel = {
        fsUuid: uuid
      };
      deviceType = await file_monitor_napi.GetDeviceTypeFromUuid(fsUuidModel);
      HiLog.infoPrivate(TAG, `get deviceType end, `, `deviceType: ${deviceType} uuid: ${fsUuidModel.fsUuid}`);
    } catch (error) {
      HiLog.error(TAG, `file_monitor_napi GetDeviceTypeFromUuid failed, error: ${JSON.stringify(error)}`);
      return false;
    }
    return deviceType === Constant.EXTERNAL_DEVICE_TYPE.TF_CARD;
  }

  /**
   * 通过文件路径获取文件所在的挂载设备
   *
   * @param path 文件绝对路径
   * @param storageDeviceList  设备列表
   * @returns 返回设备信息
   */
  public static getDiskInfoByPath(path: string, storageDeviceList: DiskInfo[]): DiskInfo | undefined {
    let deviceInfo: DiskInfo | undefined;
    if (ArrayUtil.isEmpty(storageDeviceList)) {
      HiLog.info(TAG, 'getUuidByPath:deviceList is null');
      return deviceInfo;
    }
    let len = storageDeviceList.length;
    for (let i = 0; i < len; i++) {
      let diskInfo = storageDeviceList[i];
      let diskPath = diskInfo.relativePath;
      if ((diskPath === path) || path.startsWith(FileUtil.getPathWithFileSplit(diskPath))) {
        deviceInfo = diskInfo;
        break;
      }
    }
    return deviceInfo;
  }

  /**
   * 根据根目录Uri获取对应设备信息
   *
   * @param rootUri 根目录uri
   * @param storageDeviceList 设备列表
   * @returns 返回设备信息
   */
  public static getRelativePathByRootUri(rootUri: string, storageDeviceList: DiskInfo[]): DiskInfo | undefined {
    let deviceInfo: DiskInfo | undefined;
    if (ArrayUtil.isEmpty(storageDeviceList)) {
      HiLog.info(TAG, 'getRelativePathByUri:deviceList is null');
      return deviceInfo;
    }
    let len = storageDeviceList.length;
    for (let i = 0; i < len; i++) {
      let diskInfo = storageDeviceList[i];
      let diskUri = diskInfo.uri;
      if (diskUri === rootUri) {
        deviceInfo = diskInfo;
        break;
      }
    }
    return deviceInfo;
  }

  /**
   * 文件重命名
   * @param oldFileUri 原文件uri
   * @param newFileName 新文件名
   * @returns 新文件uri
   */
  public static renameFileByFs(oldFileUri: string, newFileName: string): string {
    try {
      const oldFilePath = FileUtil.getPathFromUri(oldFileUri);
      const parentFolderPath = FileUtil.getParentRelativePath(oldFilePath);
      const newFilePath = parentFolderPath + '/' + newFileName;
      // 大小写不同不支持重命名
      if (oldFilePath.toUpperCase() === newFilePath.toUpperCase()) {
        throw new FileAccessError(ERROR_CODE.FILE_ACCESS.FILE_EXISTS, 'File name exists ignoring case');
      } else {
        // 检查新文件路径是否已存在
        const isExist = fs.accessSync(newFilePath);
        if (isExist) {
          HiLog.warn(TAG, 'renameFileByFs fail, File exists');
          throw new FileAccessError(ERROR_CODE.FILE_ACCESS.FILE_EXISTS, 'File exists');
        }
        fs.renameSync(oldFilePath, newFilePath);
      }
      return FileUtil.getUriFromPath(newFilePath);
    } catch (error) {
      HiLog.error(TAG, 'renameFileByFs fail, error:' + JSON.stringify(error));
      HiSysEventUtil.reportFailureEvent(HiSysEventName.FILE_OPERATE_FAIL, InterfaceName.FS_RENAME_SYNC,
        (error as BusinessError).code);
      throw error as Error;
    }
  }

  /**
   * 创建文件夹
   * @param parentFolderUri 父目录uri
   * @param newFolderName 新文件夹名
   * @returns 新文件夹uri
   */
  public static async createFolderByFs(parentFolderUri: string, newFolderName: string): Promise<string> {
    try {
      const parentFolderPath = FileUtil.getPathFromUri(parentFolderUri);
      const newFolderPath = parentFolderPath + '/' + newFolderName;
      await fs.mkdir(newFolderPath);
      return FileUtil.getUriFromPath(newFolderPath);
    } catch (error) {
      HiLog.error(TAG, 'createFolderByFs fail, error:' + JSON.stringify(error));
      throw error as Error;
    }
  }

  /**
   *
   * @returns
   */
  public static getMaxLengthFileName(currentFileName: string, caretPosition: number, maxLength: number): string {
    let newFileName = '';
    if (StringUtil.isEmpty(currentFileName)) {
      return newFileName;
    }

    const startPartStr = currentFileName.substring(0, caretPosition);
    const endPartStr = currentFileName.substring(caretPosition);
    const endPartByteLength = StringUtil.strSizeUTF8(endPartStr);
    const startPartByteLength = maxLength - endPartByteLength;
    let newStartPartStr = '';
    let tempLength = 0;
    for (let char of startPartStr) {
      tempLength += StringUtil.getOneCharByteLength(char);
      if (tempLength > startPartByteLength) {
        return newStartPartStr + endPartStr;
      } else {
        newStartPartStr += char;
      }
    }
    return newStartPartStr + endPartStr;
  }

  /**
   * 判断路径是否是内部存储路径
   *
   * @param path  校验路径
   * @param storageDeviceList  当前手机挂载信息
   * @returns true：内部存储路径
   */
  public static isInternalPath(path: string, storageDeviceList: DiskInfo[]): boolean {
    if (ArrayUtil.isEmpty(storageDeviceList)) {
      return false;
    }
    if (StringUtil.isEmpty(path)) {
      return false;
    }
    for (let storageInfo of storageDeviceList) {
      if (storageInfo.deviceType !== fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK) {
        continue;
      }
      if (path.startsWith(storageInfo.relativePath)) {
        return true;
      }
    }
    return false;
  }

  /**
   * 创建文件流
   * @param filePath 文件路径
   * @returns fs.Stream 文件流
   */
  public static async createStream(filePath: string, mode: string): Promise<fs.Stream | undefined> {
    let stream: fs.Stream | undefined;
    if (StringUtil.isEmpty(filePath)) {
      return stream;
    }
    try {
      stream = await fs.createStream(filePath, mode);
    } catch (error) {
      HiLog.error(TAG, 'createStream fail, error:' + JSON.stringify(error));
    }
    return stream;
  }

  /**
   * 获取内部存储根目录
   *
   * @param storageDeviceList  设备列表
   * @returns 根目录
   */
  public static getInternalStoragePath(storageDeviceList: DiskInfo[]): string {
    let rootPath = '';
    if (ObjectUtil.isNullOrUndefined(storageDeviceList) || ArrayUtil.isEmpty(storageDeviceList)) {
      HiLog.info(TAG, 'getInternalStoragePath:deviceList is null');
      return rootPath;
    }
    let len = storageDeviceList.length;
    for (let i = 0; i < len; i++) {
      let diskInfo = storageDeviceList[i];
      if (diskInfo.deviceType === fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK) {
        rootPath = diskInfo.relativePath || '';
        break;
      }
    }
    return rootPath;
  }

  /**
   * 文件类型显示
   * @param fileInfo
   */
  public static displayTypeConversion(fileInfo: FileInfo): Resource {
    // 文件夹
    if (fileInfo.isFolder) {
      return FILE_DISPLAY_TYPE_MAP.get('folder')!!;
    }
    // 文件以后缀映射实体类型
    let fileExtension = CommonUtil.getFileExtension(fileInfo.fileName);
    let typeResource: Resource | undefined = FILE_DISPLAY_TYPE_MAP.get(FileDisplayType[fileExtension.toUpperCase()]);
    if (!!typeResource) {
      return typeResource;
    }
    return $r('app.string.unknown');
  }

  /**
   * 判断给定的URI是否以媒体库的URI头部开始
   * @param uri 需要判断的URI字符串
   * @return 如果URI以媒体库文件的URI头部开始，则返回true，否则返回false
   */
  public static isMediaUri(uri: string): boolean {
    return uri.startsWith(Constant.MediaLibrary_URI_HEAD);
  }

  /**
   * 检查给定的URI数组是否全部为媒体库文件URI
   * @param uris 需要检查的URI数组
   * @return 如果所有URI都是媒体URI，返回true，否则返回false
   */
  public static isAllMediaUri(uris: string[]): boolean {
   return uris.every((uri) => FileUtil.isMediaUri(uri))
  }

  /**
   * 检查给定的URI的文件名是否包含特殊路径
   * @param uri 需要检查的URI
   * @param filterPath 检查过滤的文件名数组
   * @return 如果文件名为特殊文件名，返回true，否则返回false
   */
  public static isIncludeSpecialFile(uri: string, filterPath: Set<string>) {
    if (!uri || uri.length === 0 || filterPath.size === 0) {
      return false;
    }
    const fileName = FileUtil.getFileNameByUri(uri).toLocaleLowerCase();
    if (filterPath.has(fileName)) {
      return true;
    }
    return false;
  }

  /**
   * 检查给定的uri or path是否为沙箱内路径
   * @param uriOrPath 需要检查的uri/path
   * @return 如果uri/path为沙箱内路径，返回true，否则返回false
   */
  public static isSandboxUri(uriOrPath: string): boolean {
    const filePath = uriOrPath.startsWith(FileUtil.URI_START) ? FileUtil.getPathFromUri(uriOrPath) : uriOrPath;
    const sandboxBasePath = FileUtil.getParentRelativePath(Constant.SANDBOX_FILES_ROOT);
    return filePath.startsWith(Constant.SANDBOX_APPDATA_PATH + '/') || (filePath === Constant.SANDBOX_APPDATA_PATH) ||
      filePath.startsWith(sandboxBasePath + '/') || (filePath === sandboxBasePath);
  }

  public static getApplicationIconOrLabel(bundleName: string, isIcon: boolean = true): string {
    try {
      const resourceInfo = bundleResourceManager.getBundleResourceInfo(bundleName,
        bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_ALL);
      return isIcon ? resourceInfo.icon : resourceInfo.label;
    } catch (err) {
      HiLog.error(TAG, 'getApplicationIconOrLabel error:' + JSON.stringify(err));
    }
    return '';
  }

  public static createFile(fileUri: string, fileName: string): string | BusinessError {
    HiLog.infoPrivate(TAG, 'createFile enter ', fileUri);

    let newFileUri = fileUri;
    if (fileUri.charAt(fileUri.length - 1) === '/') {
      newFileUri = fileUri.substring(0, fileUri.length - 1);
    }

    let filePath = FileUtil.getPathFromUri(`${newFileUri}/${encodeURIComponent(fileName)}`);
    try {
      if (fs.accessSync(filePath)) {
        return { code: ERROR_CODE.FILE_ACCESS.FILE_EXISTS } as BusinessError;
      }
      let fileFd: fs.File = fs.openSync(filePath, fs.OpenMode.CREATE);
      fs.closeSync(fileFd);
      newFileUri += `/${encodeURIComponent(fileName)}`;
      return newFileUri;
    } catch (err) {
      HiLog.error(TAG, `createFile failed, err: ${JSON.stringify(err)}`);
      return err;
    }
  }

  /**
   * 判断uri是否是图库路径
   * @param fileUri
   * @returns
   */
  public static isGalleryAddress(fileUri: string): boolean {
    if (StringUtil.isEmpty(fileUri)) {
      return false;
    }
    return fileUri === VirtualUri.GALLERY || fileUri.startsWith(FileUtil.URI_GALLERY) ||
      fileUri === PAGE_ROUTE_CONST.IMAGE || fileUri === PAGE_ROUTE_CONST.VIDEO;
  }

  /**
   * 判断fileInfo是否是图库文件夹
   * @param fileInfo
   * @returns
   */
  public static isGalleryFolder(fileInfo: FileInfo): boolean {
    return fileInfo.isGallery && fileInfo.isFolder;
  }

  /**
   * 判断bundle name是否是download目录的包名目录
   * @param fileInfoUrl
   * @returns
   */
  public static isBundleNameInDownloadDir(bundleName: string): boolean {
    const fileNameArray = FileUtil.getSubFoldersSync(VirtualUri.DOWNLOAD);
    const len = fileNameArray.length;
    for (let i = 0; i < len; i++) {
      const fileUri = fileNameArray[i].substring(fileNameArray[i].lastIndexOf('/') + 1);

      if (fileUri === bundleName) {
        return true;
      }
    }

    return false;
  }

  /**
   * 通过包名获取下载目录下的完整路径
   * @param fileInfoUrl
   * @returns
   */
  public static getDownloadPathByBundleName(bundleName: string): string {
    return `${VirtualUri.DOWNLOAD}/${bundleName}`;
  }

  /*
 * 获取文件父路径
 * @param uri 当前文件uri
 * @returns 返回父路径uri
 */
  public static getParentUri(uri: string): string {
    if (uri.endsWith('/')) {
      uri = uri.substring(0, uri.lastIndexOf('/'));
    }
    let lastIndex = uri.lastIndexOf('/');
    if (lastIndex === -1) {
      HiLog.info(TAG, 'No corresponding character found.');
      return '';
    }
    let parentUri = uri.substring(0, lastIndex);
    return parentUri;
  }

  /**
   * 获取uri下文件夹名称
   * @param uri 目录
   * @returns 该目录下一层文件夹名称
   */
  public static getSubFolderNamesSync(uri: string): string[] {
    try {
      const names: string[] = fs.listFileSync(uri, { recursion: false, listNum: 0 });
      let folderNames: string[] = [];
      for (let i = 0; i < names.length; i++) {
        const stat: fs.Stat | BusinessError = FsUtil.statSync(uri + '/' + names[i]);
        if (stat instanceof Error) {
          HiLog.errorPrivate(TAG, `file stat error: `, `${uri + '/' + names[i]}`);
          continue;
        }
        if (stat.isDirectory()) {
          folderNames.push(names[i]);
        }
      }
      return folderNames;
    } catch (error) {
      HiLog.error(TAG, `getSubFolderNamesSync error: ${JSON.stringify(error)}`);
      return [];
    }
  }

  /**
   * 显示时，将超长文件名进行截断处理
   * @param fileName 文件名
   * @returns 阶段后的文件名
   */
  public static dealCopyCutNameLength(fileName: string): string {
    HiLog.info(TAG, 'dealCopyCutNameLength ' + fileName.length);
    if (ObjectUtil.isNullOrUndefined(fileName)) {
      return fileName;
    }
    let name = fileName;
    // 文件名超长处理：字符长度超过12个，截取前5个后5个，中间拼接...
    if (fileName.length > FileUtil.MAX_NAME_LENGTH) {
      name = fileName.substring(0, FileUtil.KEEP_NAME_LENGTH) + FileUtil.CONNECT_NAME_STR +
      fileName.substring(fileName.length - FileUtil.KEEP_NAME_LENGTH, fileName.length);
    }
    return name;
  }

  /**
   * 判断uri是否是下载与接收页面路径
   * @param fileUri
   * @returns
   */
  public static isDownloadAndReceiveAddress(fileUri: string, relativePath: string): boolean {
    if (StringUtil.isEmpty(fileUri)) {
      return false;
    }
    return (fileUri === FileSourceUri.BLUETOOTH || fileUri === FileSourceUri.DOWNLOAD_MANAGER ||
      fileUri === FileSourceUri.SHARE) && StringUtil.isEmpty(relativePath);
  }

  /**
   * 判断uri是否是本地的路径
   * @param uri
   * @returns
   */
  public static isLocalPath(uri: string): boolean {
    return uri.startsWith(FileUtil.URI_INTERNAL) || FileUtil.isGalleryAddress(uri);
  }

  /**
   * 判断外接储存uri是否为u盘
   * @param uri
   * @returns
   */
  public static isUDiskFile(destUri: string): boolean {
    if (StringUtil.isEmpty(destUri) || !ExternalStorageUtil.isExternalStorageUri(destUri)) {
      return false;
    }
    const uuid: string = ExternalStorageUtil.getUUIDFromUri(destUri);
    let deviceType: number = Constant.EXTERNAL_DEVICE_TYPE.UNKNOWN;
    try {
      const fsUuidModel: file_monitor_napi.FsUuidModel = {
        fsUuid: uuid
      };
      deviceType = file_monitor_napi.GetDeviceTypeFromUuid(fsUuidModel);
      HiLog.infoPrivate(TAG, `isUDisk `, `deviceType: ${deviceType} uuid: ${fsUuidModel.fsUuid}`);
    } catch (error) {
      HiLog.error(TAG, `file_monitor_napi GetDeviceTypeFromUuid failed, code: ${error?.code}, msg: ${error?.message}`);
      return false;
    }
    return deviceType === Constant.EXTERNAL_DEVICE_TYPE.U_DISK;
  }

  /**
   * 获取根目录名称
   * @param diskInfo info
   * @returns 名称
   */
  public static getDiskDes(diskInfo: DiskInfo): undefined | string {
    if (ObjectUtil.isNullOrUndefined(diskInfo)) {
      return getResourceString(DeviceConfig.getInstance().config.myDevice);
    }
    if (diskInfo.deviceType === fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK) {
      return getResourceString(DeviceConfig.getInstance().config.myDevice);
    }
    if (StringUtil.isEmpty(diskInfo.description)) {
      return getResourceString($r('app.string.externalDisk'));
    }
    return diskInfo.description;
  }

  /**
   * 将uri转换成path
   *
   * @param uri
   * @returns path
   */
  public static getPath(uri: string) {
    if (uri.startsWith('file://docs')) {
      return FileUtil.decodeURIForFileManager(uri.replace('file://docs', ''));
    }
    return FileUtil.decodeURIForFileManager(uri);
  }
}