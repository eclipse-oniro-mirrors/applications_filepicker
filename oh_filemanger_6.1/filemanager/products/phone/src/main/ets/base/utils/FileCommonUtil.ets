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
  ArrayUtil,
  BundleResourceUtil,
  Constant,
  DiskInfo,
  ERROR_CODE,
  FsUtil,
  GlobalHolder,
  GlobalKey,
  HiLog,
  ObjectUtil,
  StringUtil,
  VirtualUri,
  FileAccessUtil,
  FileInfo,
  FileUtil,
  StorageDeviceManager,
  ThreadCommonUtil
} from '@ohos/common';
import fileExtensionInfo from '@ohos.file.fileExtensionInfo';
import type { BusinessError } from '@ohos.base';
import fs, { ListFileOptions } from '@ohos.file.fs';
import PathPickerUtil from './PathPickerUtil';
import taskpool from '@ohos.taskpool';
import { FolderData } from '@ohos/common/src/main/ets/fileoperate/FolderData';


const TAG = 'FileCommonUtil';


/**
 * 工具类
 */
export class FileCommonUtil {
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

  public static getCurrentFolderByFileData(fileData: FileInfo): string {
    if (fileData !== null) {
      let path = fileData.relativePath;
      // 因为relativePath是文件的父目录相对路径，所以如果文件是文件夹，获取当前目录，需要拼接个文件名称
      return FileUtil.getCurrentDir(path, fileData.isFolder);
    }
    return '';
  }

  public static async tryRenameFileOperate(fileName: string, dirUri: string, renameCount: number,
    fileNameList: string[] = []): Promise<string | BusinessError> {
    let index = fileName.lastIndexOf('.');
    let name = fileName;
    let suffix = '';
    let context = GlobalHolder.getInstance().getMainAbilityContext();
    if (index !== -1) {
      suffix = fileName.substring(index, fileName.length);
      name = fileName.substring(0, index);
    }
    let hasReNameCount = FileUtil.getFileNameReName(name);
    if (!ObjectUtil.isNullOrUndefined(hasReNameCount)) {
      let num = Number(hasReNameCount[1]);
      if (!isNaN(num)) {
        name = hasReNameCount[0];
        renameCount = num;
      }
    }

    let newName = fileName;
    while (true) {
      newName = ThreadCommonUtil.getDupFileResult(name, suffix, renameCount++);
      let index = FileUtil.getIndex(newName, fileNameList);
      HiLog.infoPrivate(TAG, 'tryRenameFileOperate : ', newName + ' ; index = ' + index);
      if (index === -1) {
        const result = FileUtil.createFile(dirUri, newName);
        if (StringUtil.isEmpty(result as string)) {
          HiLog.infoPrivate(TAG, 'tryRenameFileOperate createOK: ', result + '');
          return result;
        } else {
          HiLog.infoPrivate(TAG, 'tryRenameFileOperate createFail: ', JSON.stringify(result) + ' ; ' + newName);
          if ((result as BusinessError).code === ERROR_CODE.FILE_ACCESS.FILE_EXISTS) {
            fileNameList.push(newName);
          } else {
            return result;
          }
        }
      }
    }
  }

  /**
   * 文件路径信息变更
   * @param fileList fileList
   * @param oldFileList oldFileList
   * @returns
   */
  public static dirDataChange(fileList: FileInfo[], oldFileList?: FileInfo[]): boolean {
    if ((!oldFileList) || ObjectUtil.isNullOrUndefined(fileList)) {
      return true;
    }
    if (fileList.length !== oldFileList.length) {
      return true;
    }
    let len = fileList.length;
    for (let i = 0; i < len; i++) {
      if ((fileList[i].uri !== oldFileList[i].uri) ||
        (fileList[i].size !== oldFileList[i].size) ||
        (fileList[i].mtime !== oldFileList[i].mtime) ||
        (fileList[i].isFolder && fileList[i].subFileCount !== oldFileList[i].subFileCount)) {
        return true;
      }
    }
    return false;
  }

  /**
   * 获取列表中文件夹的最大层级
   *
   * @param fileList 文件列表
   * @returns 如果文件列表包含文件夹，则返回文件夹的最大层级；否则返回0
   */
  public static async getMaxFolderLevel(fileList: FileInfo[]): Promise<number> {
    let folderLevel: number = 0;
    if (fileList.length === 0) {
      return folderLevel;
    }
    for (let i = 0; i < fileList.length; i++) {
      let file = fileList[i];
      if (!file.isFolder) {
        continue;
      }
      let subFolderList = FileUtil.getSubFoldersSync(file.uri);
      let maxFolderLevel = await FileUtil.getMaxFolderLevelByUri(subFolderList);
      folderLevel = Math.max(folderLevel, maxFolderLevel + 1);
    }
    // 单个文件也算一级
    folderLevel = folderLevel === 0 ? 1 : folderLevel;
    return folderLevel;
  }

  public static getWindowClass(filePickerViewFlag: boolean): string {
    if (filePickerViewFlag) {
      return GlobalKey.WINDOW_FILE_PICKER_CLASS;
    } else {
      return GlobalKey.WINDOW_CLASS_EXT;
    }
  }

  /**
   * 根据文件路径找到存储设备的信息
   * @param filePath 文件路径
   * @returns 存储设备的信息
   */
  public static async getStorageDeviceInfoByFilePath(filePath: string): Promise<DiskInfo | undefined> {
    let storageDeviceList: DiskInfo[] = await StorageDeviceManager.getInstance().getStorageDeviceList();
    if (ArrayUtil.isEmpty(storageDeviceList)) {
      HiLog.warn(TAG, 'storageDeviceList is empty');
      return undefined;
    }
    let result: DiskInfo | undefined =
      storageDeviceList.find((item: DiskInfo) => filePath.startsWith(item.relativePath));
    if (!result) {
      storageDeviceList = await StorageDeviceManager.getInstance().getStorageDeviceListByWorker();
      result = storageDeviceList.find((item: DiskInfo) => filePath.startsWith(item.relativePath));
    }
    return result;
  }

  /**
   * 查询指定目录下的所有文件夹数据
   * @param parentFolderUri 父目录uri
   * @param isRootUri 是否为根目录
   * @param targetFolderUri 必须要查询到的目标目录
   * @param level 目录层级
   * @returns 文件夹列表
   */
  public static async getSubFolderListWithFs(parentFolderUri: string, isRootUri: boolean, targetFolderUri: string,
    level: number, showHiddenItem: boolean): Promise<Array<FolderData>> {
    let folderList: FolderData[] = [];
    try {
      const parentFolderPath = FileUtil.getPathFromUri(parentFolderUri);
      HiLog.infoPrivate(TAG, 'getSubFolderListWithFs parentFolderPath: ', parentFolderPath);
      const option: ListFileOptions = showHiddenItem ? {} : { filter: { displayName: [Constant.HIDDEN_ITEM_FILTER] } };
      const fileNameList = FsUtil.listFileSync(parentFolderPath, option) as Array<string>;
      HiLog.info(TAG, 'getSubFolderListWithFs fileNameList: ' + fileNameList.length);
      for (let fileName of fileNameList) {
        if (taskpool.Task.isCanceled()) {
          HiLog.warn(TAG, 'getSubFolderListWithFs has canceled');
          return [];
        }
        // 排除不需要显示的系统目录，如桌面目录、存放最近和存放回收站文件数据的目录
        if (isRootUri && Constant.PHONE_SYSTEM_FOLDER_NAME.includes(fileName)) {
          continue;
        }
        const filePath = parentFolderPath + '/' + fileName;
        const stat: fs.Stat = fs.statSync(filePath);
        // 只需要获取文件夹
        if (stat.isFile()) {
          continue;
        }
        if (parentFolderUri.toLowerCase() === VirtualUri.DOWNLOAD.toLowerCase()) {
          BundleResourceUtil.addAppSandBoxBundleName(fileName);
        }
        let folderData: FolderData = new FolderData();
        const folderUri = FileUtil.getUriFromPath(filePath);
        folderData.fileName = BundleResourceUtil.downloadUriShowNameMap.get(fileName) ?? fileName;
        folderData.uri = folderUri;
        folderData.mtime = stat.mtime * Constant.TIME.ONE_SECOND;
        folderData.relativePath = filePath;
        folderData.level = level;
        folderData.parentUri = parentFolderUri;
        // 没有达到目标目录则继续递归获取
        if (PathPickerUtil.checkParentOrSelf(folderUri, targetFolderUri) &&
          (level <= Constant.FOLDER_LEVEL.MAX_LEVEL)) {
          folderData.isExpend = true;
          folderData.subFolderList =
            await FileCommonUtil.getSubFolderListWithFs(folderUri, false, targetFolderUri, level + 1, showHiddenItem);
        } else {
          folderData.isExpend = false;
          folderData.subFolderList = [];
        }
        folderList.push(folderData);
      }
      folderList = PathPickerUtil.sortDataByTime(folderList, true);
    } catch (error) {
      HiLog.errorPrivate(TAG, `error: ${JSON.stringify(error)}`,
        `getSubFolderListWithFs fail, parentFolderUri: ${parentFolderUri}`);
      folderList = [];
    }
    HiLog.info(TAG, 'getSubFolderListWithFs folderList: ' + folderList.length);
    return folderList;
  }
}
