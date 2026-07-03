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

import storageStatistics from '@ohos.file.storageStatistics';
import { Constant } from '../const/Constant';
import { HiLog } from '../dfx/HiLog';
import type { FileInfo } from '../fileoperate/FileInfo';
import { DisplayUtil } from './DisplayUtil';


const TAG = 'PageUtil';

export class PageRefreshData {
  public fileUri: string = '';
  public statusChange: boolean = false;

  constructor(fileUri: string, statusChange: boolean) {
    this.fileUri = fileUri;
    this.statusChange = statusChange;
  }
}

/**
 * 页面相关工具类
 */
export class PageUtil {

  /**
   * 通知刷新我的手机界面：当我的手机展示时，立即刷新，否则等展示时才刷新
   */
  static refreshMyPhonePage(): void {
    let status = AppStorage.get<boolean>('myPhoneRefresh');
    AppStorage.setOrCreate('myPhoneRefresh', !status);
  }

  /**
   * 通知刷新我的图库界面：当我的手机展示时，立即刷新，否则等展示时才刷新
   */
  static refreshGalleryPage(fileUri: string = ''): void {
    let status = AppStorage.get<PageRefreshData>('galleryRefresh') ?? new PageRefreshData('', true);
    status.fileUri = fileUri;
    status.statusChange = !status.statusChange;
    AppStorage.setOrCreate('galleryRefresh', status);
  }

  /**
   * 通知刷新最近删除页面：最近删除页面展示时，立即刷新，否则等展示时最近删除页面才刷新
   */
  static refreshRecentDelete(): void {
    let status = AppStorage.get<boolean>('recentDeleteRefresh');
    AppStorage.setOrCreate('recentDeleteRefresh', !status);
  }

  /**
   * 获取外部存储空间总大小
   * @param uuid uuid
   * @returns
   */
  static async getTotalSizeOfVolume(uuid: string): Promise<number> {
    let totalSize: number = 0;
    try {
      totalSize = await storageStatistics.getTotalSizeOfVolume(uuid);
    } catch (err) {
      HiLog.info(TAG, 'getTotalSizeOfVolume err: ' + JSON.stringify(err));
    }
    return totalSize;
  }

  /*
  * 获取外接存储设备可用空间大小
  * */
  static async getFreeSizeOfVolume(uuid: string): Promise<number> {
    let freeSize: number = 0;
    try {
      freeSize = await storageStatistics.getFreeSizeOfVolume(uuid);
    } catch (err) {
      HiLog.info(TAG, 'getFreeSizeOfVolume err: ' + JSON.stringify(err));
    }
    return freeSize;
  }

  static async getLocalFreeSpace(): Promise<number> {
    let freeSize: number = 0;
    try {
      freeSize = await storageStatistics.getFreeSize();
    } catch (err) {
      HiLog.info(TAG, 'getLocalFreeSpace err: ' + JSON.stringify(err));
    }
    return freeSize;
  }

  static async getLocalTotalSpace(): Promise<number> {
    let totalSize: number = 0;
    try {
      totalSize = await storageStatistics.getTotalSize();
    } catch (err) {
      HiLog.info(TAG, 'getLocalTotalSpace err: ' + JSON.stringify(err));
    }
    return totalSize;
  }

  /**
   * 需要缓存当前的这些文件的时候
   */
  public static isInsufficientSpace(currentFreeSize: number = 0, list: FileInfo[] = []): boolean {
    // 当前剩余可用内存
    let freeSize = currentFreeSize - Constant.MIN_REMAIN_SIZE;
    HiLog.info(TAG, `freeSize: ${freeSize}`);
    if (freeSize < 0) {
      return true;
    }
    for (let file of list) {
      // 当前剩余的可供操作的内存少于当前文件时
      if (freeSize < file.size) {
        return true;
      }
      freeSize -= file.size;
    }
    return false;
  }
}