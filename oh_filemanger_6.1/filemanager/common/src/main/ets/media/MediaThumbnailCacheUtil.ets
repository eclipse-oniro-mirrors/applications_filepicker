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

import image from '@ohos.multimedia.image';
import type common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import { StringUtil } from '../utils/StringUtil';
import { ObjectUtil } from '../utils/ObjectUtil';
import { HiLog } from '../dfx/HiLog';
import { GlobalHolder } from '../global/GlobalHolder';
import { FsUtil } from '../utils/FsUtil';
import { FileUtil } from '../fileoperate/FileUtil';
import { Constant } from '../const/Constant';
import { MediaThumbnailConst } from './MediaThumbnailConst';

const TAG = 'MediaThumbnailCacheUtil';

/**
 * 缩略图缓存管理工具类
 */
export class MediaThumbnailCacheUtil {
  /**
   * 获取缓存的根目录
   * @returns string 如：沙箱目录/files/thumbnail/
   */
  private static getCacheRootFolderPath(): string {
    const context: common.Context = GlobalHolder.getInstance().getMainAbilityContext() ||
    GlobalHolder.getInstance().getAppContext();
    let rootCacheFolderPath: string = '';
    if (context === null) {
      rootCacheFolderPath = `${Constant.SANDBOX_FILES_ROOT}/${MediaThumbnailConst.THUMBNAIL_CACHE_FOLDER_NAME}/`;
    } else {
      rootCacheFolderPath = `${context.filesDir}/${MediaThumbnailConst.THUMBNAIL_CACHE_FOLDER_NAME}/`;
    }
    const isExist = MediaThumbnailCacheUtil.checkCachePath(rootCacheFolderPath);
    if (isExist) {
      return rootCacheFolderPath;
    } else {
      return '';
    }
  }

  /**
   * 获取缩略图的缓存目录
   * @param storageDeviceId 存储设备的UID
   * @returns string 缓存目录, 如：沙箱目录/cache/thumbnail/local/
   */
  public static getCacheFolderPath(storageDeviceUID: string | number): string {
    const rootFolderPath = MediaThumbnailCacheUtil.getCacheRootFolderPath();
    storageDeviceUID =
      StringUtil.isEmpty(storageDeviceUID.toString()) ? MediaThumbnailConst.DEFAULT_STORAGE_DEVICE_UID :
        storageDeviceUID;
    const cacheFolderPath = rootFolderPath + storageDeviceUID + '/';
    const isExist = MediaThumbnailCacheUtil.checkCachePath(cacheFolderPath);
    if (isExist) {
      return cacheFolderPath;
    } else {
      return '';
    }
  }

  /**
   * 缓存缩略图
   * @param pixelMap 从图片中截取的部分像素信息
   * @param cacheFilePath 要缓存的文件路径（包括文件名）
   * @returns boolean 是否缓存成功
   */
  public static async cacheThumbnail(pixelMap: PixelMap, cacheFilePath: string): Promise<boolean> {
    let result = false;
    let file: fs.File | undefined;
    let imagePacker: image.ImagePacker | undefined;

    try {
      if (ObjectUtil.isNullOrUndefined(pixelMap)) {
        HiLog.error(TAG, `pixelMap is null`);

        throw new Error('pixelMap is null');
      }
      const opts: image.PackingOption = {
        format: MediaThumbnailConst.CURRENT_MIME_TYPE,
        quality: MediaThumbnailConst.CURRENT_QUALITY
      };
      file = FsUtil.openSync(cacheFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE) as fs.File;
      imagePacker = image.createImagePacker();
      // packToFile接口容易阻塞io，先用fs接口写入数据
      let buffer: ArrayBuffer = await imagePacker.packing(pixelMap, opts);
      FsUtil.writeSync(file.fd, buffer);
      result = await MediaThumbnailCacheUtil.checkCacheFileSize(file.fd, cacheFilePath);
      HiLog.debugPrivate(TAG, `cacheThumbnail result:${result}`, `cacheFilePath: ${cacheFilePath}`);
    } catch (error) {
      await FsUtil.unlink(cacheFilePath);
      HiLog.errorPrivate(TAG, `cacheThumbnail fail, error: ${JSON.stringify(error)}`,
        `cacheFilePath：${cacheFilePath}`);
    } finally {
      await MediaThumbnailCacheUtil.releaseSource(file, pixelMap, imagePacker);
    }
    return result;
  }

  /**
   * 释放资源
   */
  public static async releaseSource(file?: fs.File, pixelMap?: PixelMap,
    imagePacker?: image.ImagePacker): Promise<void> {
    try {
      if (file) {
        FsUtil.closeSync(file.fd);
      }

      if (pixelMap) {
        await pixelMap.release();
      }

      if (imagePacker) {
        await imagePacker.release();
      }
    } catch (error) {
      HiLog.error(TAG, 'imagePacker release fail');
    }
  }

  /**
   * 判断媒体文件是否缓存过缩略图
   * @param cacheFilePath 缩略图的路径
   * @returns boolean 是否已缓存
   */
  public static async hasCache(cacheFilePath: string): Promise<boolean> {
    const isExist = await FileUtil.isExistByPathWithFs(cacheFilePath);
    if (!isExist) {
      HiLog.warnPrivate(TAG, 'thumbnail has not cached', `cacheFilePath: ${cacheFilePath}`);
    }
    return isExist;
  }

  /**
   * 清除指定缓存目录，目前支持拔出U盘或SD卡场景
   * @param storageDeviceUID 外部存储设备UID
   * @returns boolean 是否清除成功
   */
  public static async cleanCacheFolder(storageDeviceUID: string | number): Promise<boolean> {
    let result = false;
    if (StringUtil.isEmpty(storageDeviceUID.toString())) {
      HiLog.warn(TAG, 'cleanCacheFolder fail, storageDeviceUID is empty');
      return result;
    }
    HiLog.info(TAG, 'cleanCacheFolder start, storageDeviceUID:' + storageDeviceUID);
    try {
      const folderPath = MediaThumbnailCacheUtil.getCacheFolderPath(storageDeviceUID);
      if (StringUtil.isEmpty(folderPath)) {
        HiLog.warn(TAG, 'cleanCacheFolder fail, folderPath is empty');
        return result;
      }
      await FsUtil.rmdir(folderPath);
      result = true;
    } catch (error) {
      HiLog.errorPrivate(TAG,
        `cleanCacheFolder fail, error: ${JSON.stringify(error)}`, `storageDeviceUID: ${storageDeviceUID}`);
    }
    return result;
  }

  /**
   * 清理缩略图缓存
   * @param isDeepClean 是否为深度清理，深度清理只保留一个月内生成的缩略图
   * @param isOnlyCleanUsb 是否只清理外部存储
   * @param usbDeviceUidList 当前挂载的外部存储uid列表
   * @returns boolean 是否清除成功
   */
  public static async clean(isDeepClean: boolean, isOnlyCleanUsb: boolean,
    usbDeviceUidList: string[]): Promise<boolean> {
    HiLog.infoPrivate(TAG,
      `clean start, isDeepClean: ${isDeepClean}, isOnlyCleanUsb: ${isOnlyCleanUsb} `, `usbDeviceUidList: ${JSON.stringify(usbDeviceUidList)}`);
    let cleanResult: boolean = true;
    const rootFolderPath = MediaThumbnailCacheUtil.getCacheRootFolderPath();
    if (StringUtil.isEmpty(rootFolderPath)) {
      HiLog.warn(TAG, 'clean fail, rootFolderPath is empty');
      return false;
    }
    // 默认每次都清理未挂载的外部存储
    cleanResult = await MediaThumbnailCacheUtil.cleanUsbStorageDevice(rootFolderPath, usbDeviceUidList);
    if (!cleanResult) {
      return cleanResult;
    }
    if (!isOnlyCleanUsb) {
      cleanResult = await MediaThumbnailCacheUtil.cleanAllStorageDevice(rootFolderPath, isDeepClean);
    }
    HiLog.info(TAG, 'clean complete, cleanResult:' + cleanResult);
    return cleanResult;
  }

  /**
   * 清理未挂载的外部存储设备缓存的缩略图
   * @param rootFolderPath 缓存根目录
   * @param usbDeviceUidList 外部存储的uid列表
   * @returns boolean 是否清除成功
   */
  private static async cleanUsbStorageDevice(rootFolderPath: string, usbDeviceUidList: string[]): Promise<boolean> {
    let cleanResult: boolean = true;
    try {
      // 遍历第一层获取缓存目录下文件夹列表（存储设备Uid列表）
      let folderNameList = await FileUtil.getSubFileNameByPathWithFs(rootFolderPath, false, true);
      for (let folderName of folderNameList) {
        // 内部存储或外部存储设备挂载时不处理
        if ((folderName === MediaThumbnailConst.DEFAULT_STORAGE_DEVICE_UID) || usbDeviceUidList.includes(folderName)) {
          continue;
        }
        // 外部存储设备未挂载时直接删除整个目录
        await FsUtil.rmdir(rootFolderPath + folderName);
      }
    } catch (error) {
      HiLog.error(TAG, 'cleanUsbDevice fail, error:' + JSON.stringify(error) + error);
      cleanResult = false;
    }
    HiLog.info(TAG, 'cleanUsbStorageDevice complete, cleanResult:' + cleanResult);
    return cleanResult;
  }

  /**
   * 按规则清除所有存储设备缓存的缩略图
   * @param rootFolderPath 缓存根目录
   * @param isDeepClean 是否为深度清理，深度清理只保留一个月内生成的缩略图
   * @param usbDeviceUidList 外部存储的uid列表
   * @returns boolean 是否清除成功
   */
  private static async cleanAllStorageDevice(rootFolderPath: string, isDeepClean: boolean): Promise<boolean> {
    const timeInterval = isDeepClean ? Constant.TIME.ONE_MONTH : Constant.TIME.ONE_YEAR;
    const now = new Date().getTime();
    let cleanResult: boolean = true;
    try {
      const fileNameList = await FileUtil.getSubFileNameByPathWithFs(rootFolderPath, true, true);
      for (let fileName of fileNameList) {
        const filePath = rootFolderPath + fileName;
        const fileStat = await FileUtil.getFileStatByFs(filePath);
        if ((!fileStat) || fileStat.isDirectory()) {
          continue;
        }
        if ((now - fileStat.ctime * Constant.TIME.ONE_SECOND) < timeInterval) {
          continue;
        }
        await FsUtil.unlink(filePath);
      }
    } catch (error) {
      cleanResult = false;
      HiLog.error(TAG, 'clean fail, error:' + JSON.stringify(error) + error);
    }
    HiLog.info(TAG, 'cleanAllStorageDevice complete, cleanResult:' + cleanResult);
    return cleanResult;
  }

  /**
   * 校验缓存目录如不存在则进行创建
   * @param path 缓存目录
   * @returns boolean 检验成功
   */
  private static checkCachePath(path: string): boolean {
    try {
      if (FsUtil.accessSync(path)) {
        return true;
      }
      FsUtil.mkdirSync(path);
    } catch (error) {
      HiLog.error(TAG, 'checkCachePath fail, error:' + JSON.stringify(error) + error);
      return false;
    }
    return true;
  }

  /**
   * 根据文件大小检验文件是否缓存成功
   * @param cacheFilePath 缓存文件的路径
   * @param fd 文件fd
   * @returns boolean 缓存的文件大小是否正常
   */
  private static async checkCacheFileSize(fd: number, cacheFilePath: string): Promise<boolean> {
    if (ObjectUtil.isNullOrUndefined(fd)) {
      HiLog.errorPrivate(TAG, 'checkCacheFileSize open file fail', cacheFilePath);
      return false;
    }
    const stat = await FileUtil.getFileStatByFs(fd);
    if (!stat) {
      HiLog.errorPrivate(TAG, 'checkCacheFileSize get stat fail, cacheFilePath', cacheFilePath);
      return false;
    }
    if (stat.size === 0) {
      HiLog.errorPrivate(TAG, 'checkCacheFileSize fileSize is 0, cacheFilePath', cacheFilePath);
      await FsUtil.unlink(cacheFilePath);
      return false;
    }
    return true;
  }
}