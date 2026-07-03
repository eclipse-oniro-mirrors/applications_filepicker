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

import { HiLog, Constant, GlobalHolder, DiskInfo, CommonPreferenceUtil } from '@ohos/common';
import TaskPool from '@ohos.taskpool';
import common from '@ohos.app.ability.common';
import storageStatistics from '@ohos.file.storageStatistics';
import fileExtensionInfo from '@ohos.file.fileExtensionInfo';
import { StorageDeviceManager, MediaThumbnailCacheUtil } from '@ohos/common';

/**
 * TAG
 */
const TAG = 'ThumbnailCacheManager';

/**
 * 缩略图缓存管理工具类
 */
export class ThumbnailCacheManager {
  private static instance: ThumbnailCacheManager = new ThumbnailCacheManager();
  private isTaskRunning: boolean = false;
  private cleanThumbnailCacheTask?: TaskPool.Task = undefined;

  /**
   * 缩略图缓存管理工具实例
   */
  public static getInstance(): ThumbnailCacheManager {
    return ThumbnailCacheManager.instance
  }

  /**
   * 应用启动后检查是否需要清理内部存储缓存在沙箱下的缩略图
   * @returns boolean 是否需要清理
   */
  private async checkNeedCleanByLastCleanTime(): Promise<boolean> {
    const lastTimeStamp = await CommonPreferenceUtil.getLastCleanThumbnailCacheTimeStamp();
    const now = new Date().getTime();
    if ((now - lastTimeStamp) < Constant.TIME.ONE_MONTH) {
      return false;
    }
    return true
  }

  /**
   * 应用启动后根据内部存储剩余空间大小检查是否需要清理缩略图缓存
   * @returns boolean 是否需要清理
   */
  private async checkNeedCleanByStorageFreeSize(): Promise<boolean> {
    let result = false;
    try {
      const freeSize = await storageStatistics.getFreeSize();
      if (freeSize < Constant.BYTE.ONE_GB) {
        result = true
      }
    } catch (error) {
      HiLog.error(TAG, 'getFreeSize fail, error:' + JSON.stringify(error) + error)
    }
    return result
  }

  /**
   * 应用启动后检查是否需要清理USB设备缓存在沙箱下的缩略图
   * @returns boolean 是否需要清理
   */
  private async checkNeedCleanByLastUsbCleanTime(): Promise<boolean> {
    const lastTimeStamp = await CommonPreferenceUtil.getLastCleanUsbThumbnailCacheTimeStamp();
    const now = new Date().getTime();
    if ((now - lastTimeStamp) < Constant.TIME.ONE_WEEK) {
      return false;
    }
    return true
  }

  /**
   * 清理缩略图缓存
   * @param isDeepClean 是否为深度清理
   * @returns boolean 是否清理成功
   */
  public async cleanThumbnailCache(isDeepClean: boolean = false): Promise<boolean> {
    // 正在清理...
    if (this.isTaskRunning) {
      HiLog.warn(TAG, `cleanThumbnailCacheTask is running`);
      return false;
    }
    let isOnlyCleanUsb = false;
    // 定期自动清理时需要检查上次清理时间和内存剩余空间大小
    if (!isDeepClean) {
      if (await this.checkNeedCleanByStorageFreeSize()) {
        // 空间不足时需要深度清理（只保留最近一个月生成的缩略图）
        HiLog.debug(TAG, `CleanByStorageFreeSize`);
        isDeepClean = true
      } else if (await this.checkNeedCleanByLastCleanTime()) {
        HiLog.debug(TAG, `CleanByLastCleanTime`);
      } else if (await this.checkNeedCleanByLastUsbCleanTime()) {
        isOnlyCleanUsb = true
        HiLog.debug(TAG, `CleanByLastUsbCleanTime`);
      } else {
        HiLog.debug(TAG, `don't need clean`);
        return false;
      }
    }
    return await this.startCleanThumbnailCacheTask(isDeepClean, isOnlyCleanUsb)
  }

  /**
   * 启动清理缩略图任务
   * @param isDeepClean 是否为深度清理
   * @returns boolean 是否清理成功
   */
  public async startCleanThumbnailCacheTask(isDeepClean: boolean, isOnlyCleanUsb: boolean): Promise<boolean> {
    let result: boolean = false;
    HiLog.info(TAG, `cleanThumbnailCacheTask execute, isDeepClean: ${isDeepClean}`)
    try {
      this.isTaskRunning = true
      const storageDeviceList = await StorageDeviceManager.getInstance().getStorageDeviceList();
      const usbStorageDeviceList = storageDeviceList.filter((item: DiskInfo) => item.deviceType ===
      fileExtensionInfo.DeviceType.DEVICE_EXTERNAL_USB)
      const usbDeviceUidList = usbStorageDeviceList.map((item: DiskInfo) => item.uuid)
      const context = GlobalHolder.getInstance().getMainAbilityContext() ||
        GlobalHolder.getInstance().getUIExtensionContext() || GlobalHolder.getInstance().getExtensionContext()
      this.cleanThumbnailCacheTask = new TaskPool.Task(cleanThumbnailCache, isDeepClean, isOnlyCleanUsb,
        usbDeviceUidList, context);
      result = await TaskPool.execute(this.cleanThumbnailCacheTask) as boolean;
    } catch (error) {
      HiLog.error(TAG, 'cleanThumbnailCacheTask execute fail, error:' + JSON.stringify(error) + error);
    }
    this.cleanThumbnailCacheTask = undefined;
    if (result) {
      if (!isOnlyCleanUsb) {
        await CommonPreferenceUtil.setLastCleanThumbnailCacheTimeStamp();
      }
      await CommonPreferenceUtil.setLastCleanUsbThumbnailCacheTimeStamp();
    }
    this.isTaskRunning = false
    return result;
  }
}

/**
 * 清理缩略图缓存
 * @param isDeepClean 是否为深度清理
 * @param isOnlyCleanUsb 是否只清理外部存储
 * @param usbDeviceUidList 外部存储的uid列表
 * @param context 应用上下文
 * @returns boolean 是否清理成功
 */
@Concurrent
async function cleanThumbnailCache(isDeepClean: boolean, isOnlyCleanUsb: boolean, usbDeviceUidList: string[],
  context: common.UIAbilityContext): Promise<boolean> {
  GlobalHolder.getInstance().setMainAbilityContext(context);
  return await MediaThumbnailCacheUtil.clean(isDeepClean, isOnlyCleanUsb, usbDeviceUidList)
}
