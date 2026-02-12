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

import { HiLog } from '../dfx/HiLog';
import storageStatistics from '@ohos.file.storageStatistics';
import type common from '@ohos.app.ability.common';
import { FileAccessUtil } from '../fileoperate/FileAccessUtil';
import { FileInfo } from '../fileoperate/FileInfo';
import { StorageDeviceManager } from '../externel/StorageDeviceManager';
import { DiskInfo } from '../externel/DiskInfo';
import { fileExtensionInfo } from '@kit.CoreFileKit';
import { UUID_TYPE } from '../const/Constant';
import { FilesQueryUtil } from '../fileoperate/FilesQueryUtil';

const TAG = 'StorageUtil';

/*
 * 存储空间相关工具类
 * */
export class StorageUtil {
  /**
   * 内部存储设备的UUID
   */
  public static readonly LOCAL_STORAGE_DEVICE_UUID = 'LOCAL';

  /**
   * 操作前判断剩余空间是否足够
   * @param totalSize 总大小
   * @param deviceId 设备ID
   * @returns 判断结果
   */
  public static async hasEnoughFreeSize(totalSize: number, uuid: string): Promise<boolean> {
    let deviceUuid: string = uuid;
    let freeSize: number = await StorageUtil.getFreeSize(deviceUuid);
    HiLog.info(TAG, 'totalSize: ' + totalSize + ', freeSize: ' + freeSize);
    return totalSize <= freeSize;
  }

  /**
   * 获取剩余空间
   * @param deviceId 设备ID
   * @returns 剩余空间大小
   */
  public static async getFreeSize(deviceId: string): Promise<number> {
    let freeSize: number = 0;
    if (deviceId === StorageUtil.LOCAL_STORAGE_DEVICE_UUID) {
      await storageStatistics.getFreeSize()
        .then((size) => {
          HiLog.info(TAG, `getFreeSize, size: ${size}`);
          freeSize = size;
        }).catch((err: Error) => {
          HiLog.warn(TAG, 'getFreeSize err: ' + JSON.stringify(err));
        });
    } else {
      await storageStatistics.getFreeSizeOfVolume(deviceId)
        .then((size) => {
          HiLog.infoPrivate(TAG, `getFreeSizeOfVolume size: ${size}`, `uuid: ${deviceId}`);
          freeSize = size;
        }).catch((err: Error) => {
          HiLog.warn(TAG, 'getFreeSizeOfVolume err: ' + JSON.stringify(err));
        });
    }
    return freeSize;
  }

  /**
   * 获取文件占用空间
   * @param pastedFiles：要粘贴的文件
   * @returns 文件占用空间
   */
  public static async getFilesSize(pastedFiles: FileInfo[]): Promise<number> {
    if (!pastedFiles) {
      HiLog.info(TAG, 'pastedFiles is undefined');
      return 0;
    }
    let totalSize = 0;
    for (let i = 0; i < pastedFiles.length; i++) {
      let file = pastedFiles[i];
      if (file.isFolder) {
        let folderSize = FilesQueryUtil.getFolderSize(file.uri);
        totalSize += folderSize;
      } else {
        totalSize += file.size;
      }
    }
    HiLog.info(TAG, 'pasteFileSize ' + totalSize);
    return totalSize;
  }

  // 获取路径uuid
  public static async getDeviceUUID(destUri: string | undefined): Promise<string> {
    const storageDeviceList = await StorageDeviceManager.getInstance().getStorageDeviceList();
    let storageDevice: DiskInfo | undefined;
    if (!!destUri) {
      storageDevice = storageDeviceList.find((deviceItem: DiskInfo) => destUri.startsWith(deviceItem.uri));
    }
    if (!storageDevice) {
      return UUID_TYPE.LOCAL;
    }
    if (storageDevice.deviceType === fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK) {
      return UUID_TYPE.LOCAL;
    }
    return storageDevice.uuid;
  }
}