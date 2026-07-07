/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import type { BusinessError } from '@ohos.base';
import fileExtensionInfo from '@ohos.file.fileExtensionInfo';
import { HiLog } from '../dfx/HiLog';
import { TraceUtils } from '../dfx/TraceUtils';
import { FileUtil } from './FileUtil';
import { ObjectUtil } from '../utils/ObjectUtil';
import type { DiskInfo, RootInfo } from '../externel/DiskInfo';
import { ERROR_CODE } from '../const/ErrorCode';
import { HiTraceConst } from '../const/HiTraceConst';
import { volumeManager } from '@kit.CoreFileKit';
import { FileInfo } from './FileInfo';

const LOCAL: string = 'LOCAL';

const TAG_FAF: string = 'FileAccessUtil';

export class FileAccessUtil {
  private static storageRootInfo: Map<string, RootInfo> = new Map();
  private static isRefreshingRoots: boolean = true;

  private static localRootInfo: RootInfo = {
    deviceType: fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK,
    uri: 'file://docs/storage/Users/currentUser',
    relativePath: '/storage/Users/currentUser',
    displayName: 'currentUser',
    deviceFlags: fileExtensionInfo.DeviceFlag.SUPPORTS_READ | fileExtensionInfo.DeviceFlag.SUPPORTS_WRITE
  };

  private static shareRootInfo: RootInfo = {
    deviceType: fileExtensionInfo.DeviceType.DEVICE_SHARED_DISK,
    uri: 'file://docs/storage/Share',
    relativePath: '/storage/Share',
    displayName: 'shared_disk',
    deviceFlags: fileExtensionInfo.DeviceFlag.SUPPORTS_READ | fileExtensionInfo.DeviceFlag.SUPPORTS_WRITE
  };

  /**
   * 获取存储根信息的Map，key：displayName, value：RootInfo
   */
  public static getStorageRootInfo(): Map<string, RootInfo> {
    return FileAccessUtil.storageRootInfo;
  }

  /**
   * 设置获取设备信息的时候是否重新获取
   */
  public static setStorageRefreshStatus(isRefresh: boolean): void {
    HiLog.warn(TAG_FAF, `setStorageRefreshStatus: ${isRefresh}`);
    FileAccessUtil.isRefreshingRoots = isRefresh;
  }

  /**
   * 根据Uri，获取uri属于哪个盘符
   */
  public static getDiskNameByUri(uri?: string): string {
    let diskName: string = '';
    if (!uri) {
      return diskName;
    }
    FileAccessUtil.getStorageRootInfo().forEach((value, key) => {
      if (uri.includes(value.uri)) {
        diskName = key;
        return;
      }
    });

    const filePath = FileUtil.getPathFromUri(uri)
    if (diskName === '' && filePath.startsWith('/data/storage/el2')) {
      diskName = LOCAL;
    }

    return diskName;
  }

  /**
   * 获取磁盘rootInfo对象
   */
  public static async getDiskRootInfo(uuid: string): Promise<RootInfo | undefined> {
    if (!FileAccessUtil.storageRootInfo.has(uuid)) {
      HiLog.error(TAG_FAF, 'getDiskRootInfo is null.');
      await FileAccessUtil.refreshRoots();
    }
    return FileAccessUtil.storageRootInfo.get(uuid);
  }

  public static async refreshStorageRootInfo(): Promise<void> {
    FileAccessUtil.storageRootInfo.clear();

    TraceUtils.startTrace(HiTraceConst.FILE_ACCESS_REFRESH_GET_ROOTS);
    FileAccessUtil.storageRootInfo.set(LOCAL, FileAccessUtil.localRootInfo);
    FileAccessUtil.storageRootInfo.set('shared_disk', FileAccessUtil.shareRootInfo);

    try {
      const allVolumes = await volumeManager.getAllVolumes();
      for (const value of allVolumes) {
        HiLog.info(TAG_FAF, 'getRoots, description : ' + value.description + ' device root uri: ');
        if (!value.description || !value.uuid) {
          HiLog.warn(TAG_FAF, 'getRoots, description or uuid is null');
          continue;
        }
        FileAccessUtil.storageRootInfo.set(value.uuid, {
          deviceType: fileExtensionInfo.DeviceType.DEVICE_EXTERNAL_USB,
          uri: `file://docs/storage/External/${value.uuid}`,
          relativePath: `/storage/External/${value.uuid}`,
          displayName: value.uuid,
          deviceFlags: fileExtensionInfo.DeviceFlag.SUPPORTS_READ | fileExtensionInfo.DeviceFlag.SUPPORTS_WRITE
        });
      }
      FileAccessUtil.isRefreshingRoots = false;
    } catch (err) {
      HiLog.error(TAG_FAF, `refreshStorageRootInfoOnPhoneFirstLoad error: ${err}`);
    }
    HiLog.info(TAG_FAF, `getRoots, length = ${FileAccessUtil.storageRootInfo?.size}`);
    TraceUtils.finishTrace(HiTraceConst.FILE_ACCESS_REFRESH_GET_ROOTS);
  }

  public static async refreshRoots(): Promise<void> {
    await FileAccessUtil.refreshStorageRootInfo();
  }

  /**
   * 根据uri查询文件信息
   * @param uri 当前路径
   */
  public static async getFileInfoFromUri(uri: string): Promise<FileInfo | undefined> {
    let file: FileInfo = new FileInfo();
    try {
      file = FileInfo.fromFileUri(uri);
    } catch (error) {
      HiLog.warn(TAG_FAF, 'file access exception. err = ' + JSON.stringify(error));
      if ((error as BusinessError).code === ERROR_CODE.FILE_ACCESS.FILE_NOT_EXIST) {
        HiLog.warn(TAG_FAF, 'file not exist.');
      }
      return undefined;
    }
    return file;
  }

  /**
   * 获取挂载目录
   *
   * @returns 返回挂载列表
   */
  public static async getRootListWithFaf(): Promise<DiskInfo[]> {
    let tag = 'getRootWithFaf';
    let storageRootInfo = FileAccessUtil.getStorageRootInfo();
    if (FileAccessUtil.isRefreshingRoots || storageRootInfo.size == 0 || !FileAccessUtil.storageRootInfo.has(LOCAL)) {
      await FileAccessUtil.refreshRoots();
      storageRootInfo = FileAccessUtil.getStorageRootInfo();
    }
    let rootInfoArr: DiskInfo[] = [];
    try {
      for (let value of storageRootInfo.values()) {
        const rootInfo: RootInfo = value;
        if (ObjectUtil.isNullOrUndefined(rootInfo)) {
          break;
        }

        let rootDiskInfo = await FileUtil.getRootDiskInfo(rootInfo);
        if (rootDiskInfo) {
          let isExist = await FileUtil.isExistByPathWithFs(rootInfo.relativePath);
          if (isExist) {
            rootInfoArr.push(rootDiskInfo);
          } else {
            HiLog.warnPrivate(tag, 'getRootListWithFaf', rootDiskInfo.relativePath + ' is not exist');
          }
        }
      }
    } catch (error) {
      HiLog.error(tag, 'getRootListWithFaf getRoots error: ' + JSON.stringify(error) + ', ' + error.toString());
    }
    // 按照deviceType排序，LOCAL是1，排在最前面
    rootInfoArr.sort((a, b) => {
      return a.deviceType - b.deviceType;
    });
    HiLog.info(tag, 'getRootListWithFaf getRoots rootInfoArr size: ' + rootInfoArr.length);
    return rootInfoArr;
  }
}