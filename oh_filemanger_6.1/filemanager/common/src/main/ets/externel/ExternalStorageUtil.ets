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
import storageStatistics from '@ohos.file.storageStatistics';
import volumeManager from '@ohos.file.volumeManager';
import { PasteFlag } from '../const/FilePasteConstants';
import { VirtualUri } from '../const/FolderRecord';
import { HiTraceConst } from '../const/HiTraceConst';
import { HiLog } from '../dfx/HiLog';
import { TraceUtils } from '../dfx/TraceUtils';
import { FileAccessUtil } from '../fileoperate/FileAccessUtil';
import { FileInfo } from '../fileoperate/FileInfo';
import { CommonUtil } from '../utils/CommonUtil';
import { ResourceUtil } from '../utils/ResourceUtil';
import { DiskChangeInfo, DiskInfo, RootInfo } from './DiskInfo';

const TAG: string = 'ExternalStorageUtil';
const externalStoragePathTag: string = 'file://docs/storage/External/';

/*
 * ExternalStorage Util
 * */
export class ExternalStorageUtil {
  public storageDetailStr: ResourceStr = '';
  public timeStamp: Date = new Date();

  constructor(storageDetailStr: ResourceStr, timeStamp: Date) {
    this.storageDetailStr = storageDetailStr;
    this.timeStamp = timeStamp;
  }

  /*
   * 根据UUID获取volumeId
   * */
  public static async getVolumeIdFromUUID(uuid: string): Promise<string> {
    let volume = await volumeManager.getVolumeByUuid(uuid);
    return volume?.id;
  }

  /*
   * 判断是否属于跨盘拖拽，跨盘拖拽等于复制
   * */
  public static isDragAcrossDisk(pasteFlag: PasteFlag, srcPath: string, destPath: string): boolean {
    HiLog.infoPrivate(TAG, 'isDragAcrossDisk',
      'srcPath: ' + srcPath + ', destPath: ' + destPath + ', pasteFlag: ' + pasteFlag);
    if (pasteFlag !== PasteFlag.DRAG) {
      return false;
    }
    return ExternalStorageUtil.isOperateAcrossDisk(srcPath, destPath);
  }

  /*
   * 判断是否为跨盘操作
   * */
  public static isOperateAcrossDisk(srcPath: string, destPath: string): boolean {
    HiLog.infoPrivate(TAG, 'isOperateAcrossDisk', 'srcPath: ' + srcPath + ', destPath: ' + destPath);
    let isFromExternal: boolean = ExternalStorageUtil.isExternalStorageUri(srcPath);
    let isToExternal: boolean = ExternalStorageUtil.isExternalStorageUri(destPath);
    if (isFromExternal !== isToExternal) {
      return true;
    } else {
      if (isFromExternal && isToExternal) {
        // 都来自外接存储设备，判断UUID
        let srcUUID = ExternalStorageUtil.getUUIDFromUri(srcPath);
        let destUUID = ExternalStorageUtil.getUUIDFromUri(destPath);
        return srcUUID !== destUUID;
      } else {
        return false;
      }
    }
  }

  /*
   * 判断是否显示存储空间信息
   * */
  public static isShowStorageSize(currentPathUri: string, deviceId: string): boolean {
    let isShow: boolean =
      currentPathUri === VirtualUri.MY_PC || currentPathUri === VirtualUri.EXTERNAL_DISK + '/' + deviceId;
    HiLog.infoPrivate(TAG, 'currentPath', 'uri:' + currentPathUri + ', isShowStorageSize: ' + isShow);
    return isShow;
  }

  /*
   * 输出文件数量和存储空间信息字符串
   * */
  public static async getStorageDetail(fileNum: number, folderNum: number,
    deviceId: string, currentPathUri: string, timeStamp: Date): Promise<ExternalStorageUtil> {
    let fileNumStr = await ResourceUtil.getStringByPluralParamResource($r('app.plural.storage_file_num'), fileNum);
    let folderNumStr =
      await ResourceUtil.getStringByPluralParamResource($r('app.plural.storage_folder_num'), folderNum);
    if (ExternalStorageUtil.isShowStorageSize(currentPathUri, deviceId)) {
      let storageSizeDetail: string[];
      if (deviceId === 'LOCAL') {
        storageSizeDetail = await ExternalStorageUtil.getLocalStorageDetail();
      } else {
        storageSizeDetail = await ExternalStorageUtil.getExternalStorageDetail(deviceId);
      }
      let storageFreeSize = storageSizeDetail[0];
      let storageTotalSize = storageSizeDetail[1];
      HiLog.debug(TAG, 'storageFreeSize: ' + storageFreeSize + ', storageTotalSize: ' + storageTotalSize);
      return new ExternalStorageUtil($r('app.string.storage_stem_all', fileNumStr, folderNumStr, storageFreeSize,
        storageTotalSize), timeStamp);
    }
    return new ExternalStorageUtil($r('app.string.storage_stem_part', fileNumStr, folderNumStr), timeStamp);
  }

  /*
   * 外接存储设备内通过uri获取父路径uri
   * */
  public static getParentUri(uri: string): string {
    let lastIndex = uri.lastIndexOf('/');
    if (lastIndex === -1) {
      HiLog.info(TAG, 'No corresponding character found.')
      return '';
    }
    let parentUri = uri.substring(0, lastIndex);
    return parentUri;
  }

  /*
   * 判断uri是否来源于外卡
   * */
  public static isExternalStorageUri(uri: string): boolean {
    return uri.startsWith(externalStoragePathTag);
  }

  /*
   * 判断是否在外接存储设备内操作
   * */
  public static isInExternalStorage(deviceId: string): boolean {
    return deviceId !== 'LOCAL';
  }

  /*
   * 判断外接存储设备是否正在传输数据
   * */
  public static isExternalStorageTransferData(deviceId: string, srcUri: string, dstUri: string): boolean {
    return ((ExternalStorageUtil.getUUIDFromUri(srcUri) === deviceId) ||
      (ExternalStorageUtil.getUUIDFromUri(dstUri) === deviceId));
  }

  /**
   * 获取本地设备空间占用信息
   * @returns 空间占用情况
   */
  public static async getLocalStorageDetail(): Promise<string[]> {
    let totalSize: number = 0;
    let freeSize: number = 0;
    TraceUtils.startTrace(HiTraceConst.GET_LOCAL_STORAGE_DETAIL);
    try {
      totalSize = await storageStatistics.getTotalSize();
      freeSize = await storageStatistics.getFreeSize();
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      HiLog.error(TAG, `get size fail, code:${error?.code}, message:${error?.message}`);
    }
    TraceUtils.finishTrace(HiTraceConst.GET_LOCAL_STORAGE_DETAIL);
    HiLog.infoPrivate(TAG, `getLocalSize done, `, `totalSize:${totalSize}, freeSize:${freeSize}`);
    return [CommonUtil.sizeConversion(freeSize), CommonUtil.sizeConversion(totalSize)];
  }

  /**
   * 获取外接存储设备空间占用信息
   * @param uuid 设备UDID信息
   * @returns 空间占用情况
   */
  public static async getExternalStorageDetail(uuid: string): Promise<string[]> {
    HiLog.infoPrivate(TAG, `getExternalStorageDetail, `, `uuid:${uuid}`);
    TraceUtils.startTrace(HiTraceConst.GET_EXTERNAL_STORAGE_DETAIL);
    const totalSize: string = CommonUtil.sizeConversion(await ExternalStorageUtil.getTotalSizeOfVolume(uuid));
    const freeSize: string = CommonUtil.sizeConversion(await ExternalStorageUtil.getFreeSizeOfVolume(uuid));
    TraceUtils.finishTrace(HiTraceConst.GET_EXTERNAL_STORAGE_DETAIL);
    HiLog.infoPrivate(TAG, `getExternalSize done, `, `totalSize:${totalSize}, freeSize:${freeSize}`);
    return [freeSize, totalSize];
  }

  /*
   * 通过外接存储设备uri获取uuid
   * */
  public static getUUIDFromUri(uri: string): string {
    uri = uri.substring(externalStoragePathTag.length);
    if (uri.indexOf('/') !== -1) {
      uri = uri.substring(0, uri.indexOf('/'));
    }
    return uri;
  }

  /*
   * 获取外接存储设备总空间大小
   * */
  public static async getTotalSizeOfVolume(uuid: string): Promise<number> {
    let totalSize: number = 0;
    try {
      totalSize = await storageStatistics.getTotalSizeOfVolume(uuid);
    } catch (error) {
      HiLog.info(TAG, 'getTotalSizeOfVolume fail, error: ' + JSON.stringify(error));
    }
    HiLog.debugPrivate(TAG, 'getTotalSizeOfVolume', `Volume uuid: ${uuid}, totalSize: ${totalSize}`);
    return totalSize;
  }

  /*
   * 获取外接存储设备可用空间大小
   * */
  public static async getFreeSizeOfVolume(uuid: string): Promise<number> {
    let freeSize: number = 0;
    try {
      freeSize = await storageStatistics.getFreeSizeOfVolume(uuid);
    } catch (error) {
      HiLog.info(TAG, 'getFreeSizeOfVolume fail, error: ' + JSON.stringify(error));
    }
    HiLog.debugPrivate(TAG, 'getFreeSizeOfVolume', ` Volume uuid: ${uuid}, freeSize: ${freeSize}`);
    return freeSize;
  }

  /*
   * 获取外部存储设备信息
   * */
  public static async getDiskInfos(): Promise<DiskInfo[]> {
    HiLog.info(TAG, 'getDiskInfos start');
    let storageRootInfo = FileAccessUtil.getStorageRootInfo();
    if (storageRootInfo?.size === 0) {
      HiLog.error(TAG, 'storageRootInfo is null, init root');
      await FileAccessUtil.refreshRoots();
    }
    let disk: DiskInfo[] = [];
    let it = storageRootInfo.keys();
    let t: IteratorResult<string, string> = it.next();
    while (!t.done) {
      if (storageRootInfo.get(t.value)?.deviceType === fileExtensionInfo.DeviceType.DEVICE_EXTERNAL_USB) {
        try {
          let volumeInfo: volumeManager.Volume = await volumeManager.getVolumeByUuid(t.value);
          HiLog.infoPrivate(TAG, 'disk description', JSON.stringify(volumeInfo.description));
          let diskInfo: DiskInfo =
            new DiskInfo(t.value, volumeInfo.description, volumeInfo.path, storageRootInfo.get(t.value));
          disk.push(diskInfo);
        } catch (err) {
          HiLog.info(TAG, `getDiskInfos err:${err.code}`);
        }
      }
      t = it.next();
    }
    return disk;
  }

  /*
   * 卸载盘符
   * */
  public static async unmountDisk(uuid: string): Promise<void> {
    let storageRootInfo: Map<string, RootInfo> = FileAccessUtil.getStorageRootInfo();
    if (storageRootInfo?.size === 0) {
      HiLog.error(TAG, 'storageRootInfo is null, init storageRootInfo');
      await FileAccessUtil.refreshRoots();
      storageRootInfo = FileAccessUtil.getStorageRootInfo();
      if (storageRootInfo?.size === 0) {
        HiLog.error(TAG, 'get storageRootInfo again, but storageRootInfo is still null');
        return;
      }
    }
    let it = storageRootInfo.values();
    let t: IteratorResult<RootInfo, RootInfo> = it.next();
    while (!t.done) {
      if (t.value.displayName === uuid) {
        let volumeId = await ExternalStorageUtil.getVolumeIdFromUUID(uuid);
        volumeManager.unmount(volumeId).then(() => {
          HiLog.info(TAG, 'diskManagerChange VOLUME_BAD_REMOVAL');
          AppStorage.set<DiskChangeInfo>('DiskStatusChange', new DiskChangeInfo(false, uuid));
        }).catch((error: Error) => {
          HiLog.info(TAG, `unmountDisk failed with error message: ${error?.message}`);
          return;
        });
        break;
      }
      t = it.next();
    }
  }

  /**
   * 获取盘符路径的 uri
   */
  public static async getDiskRootFileInfo(uuid: string): Promise<string> {
    HiLog.infoPrivate(TAG, 'get disk root info. ', `uuid: ${uuid}`);
    let rootInfo = await FileAccessUtil.getDiskRootInfo(uuid) as RootInfo;
    HiLog.infoPrivate(TAG, 'disk root info', JSON.stringify(rootInfo.uri));
    let diskRootFileInfo: FileInfo =
      await FileAccessUtil.getFileInfoFromUri(rootInfo.uri) as FileInfo;
    HiLog.infoPrivate(TAG, 'disk root info', JSON.stringify(diskRootFileInfo.uri));
    return diskRootFileInfo.uri;
  }

  /*
   * 移除盘符
   * */
  public static async delDisk(uuid: string): Promise<void> {
    let storageRootInfo = FileAccessUtil.getStorageRootInfo();
    if (storageRootInfo.has(uuid)) {
      storageRootInfo.delete(uuid);
    }
  }

  public static async unmountStorageDevice(uuid: string): Promise<void> {
    let volumeId = await ExternalStorageUtil.getVolumeIdFromUUID(uuid);
    HiLog.info(TAG, 'diskManagerChange VOLUME_BAD_REMOVAL start');
    volumeManager.unmount(volumeId).then(() => {
      HiLog.info(TAG, 'diskManagerChange VOLUME_BAD_REMOVAL end');
    }).catch((error: Error) => {
      HiLog.error(TAG, `unmountDisk failed with error:  ${error?.message}`);
    });
  }

  public static isReadOnlySystem(): boolean {
    if (AppStorage.has('exStorageReadOnlyFlag')) {
      return AppStorage.get<boolean>('exStorageReadOnlyFlag') as boolean;
    }
    return false;
  }
}