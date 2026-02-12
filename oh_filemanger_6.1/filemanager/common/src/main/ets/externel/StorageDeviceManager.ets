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

import CommonEventManager from '@ohos.commonEventManager';
import type Base from '@ohos.base';
import fileExtensionInfo from '@ohos.file.fileExtensionInfo';
import { FileAccessUtil } from '../fileoperate/FileAccessUtil';
import { DiskChangeInfo, DiskInfo } from './DiskInfo';
import { EventBus } from '../utils/EventBus';
import { Constant, DeviceTypeConstants } from '../const/Constant';
import { HiLog } from '../dfx/HiLog';
import { ObjectUtil } from '../utils/ObjectUtil';
import { ArrayUtil } from '../utils/ArrayUtil';
import { FileUtil } from '../fileoperate/FileUtil';
import { GlobalHolder } from '../global/GlobalHolder';
import { StringUtil } from '../utils/StringUtil';
import { GlobalKey } from '../global/GlobalKey';
import { DFX } from '../dfx/const/DFXConst';
import { UEUtil } from '../dfx/UEUtil';

const TAG = 'DeviceManager';

/**
 * 存储设备列表管理工具类
 * 提供获取存储设备列表统一接口和监听存储设备列表变化
 */
export class StorageDeviceManager {
  /**
   * 工具类实例
   */
  private static instance: StorageDeviceManager = new StorageDeviceManager();
  /**
   * 存储设备变化的时间列表
   */
  private readonly eventList = [
    CommonEventManager.Support.COMMON_EVENT_VOLUME_REMOVED, // 提示已移除外部存储设备
    CommonEventManager.Support.COMMON_EVENT_VOLUME_UNMOUNTED, // 提示已卸载外部存储设备
    CommonEventManager.Support.COMMON_EVENT_VOLUME_MOUNTED, // 提示已挂载外部存储设备
    CommonEventManager.Support.COMMON_EVENT_VOLUME_BAD_REMOVAL, // 提示外部存储设备在挂载状态下被移除
    CommonEventManager.Support.COMMON_EVENT_VOLUME_EJECT// 提示用户已作出弹出外部存储介质的操作
  ];
  /**
   * 存储设备列表
   */
  private storageDeviceList: DiskInfo[] = [];
  /**
   * 新增存储设备uuid列表
   */
  private addDeviceUuidList: string[] = [];
  /**
   * 存储设备变化公共事件监听器
   */
  private subscriber?: CommonEventManager.CommonEventSubscriber;
  /**
   * 是否已经注册外挂设备监听
   */
  private isSubscribed: boolean = false;
  /**
   * 是否正在查询
   */
  private isQuery: boolean = false;
  private accountLogin: Function = () => this.accountLoginStatusChange(true);
  private accountLogout: Function = () => this.accountLoginStatusChange(false);
  private deviceType: DeviceTypeConstants = DeviceTypeConstants.PC;

  constructor() {
  }

  /**
   * 工具类实例
   * @returns
   */
  static getInstance(): StorageDeviceManager {
    return StorageDeviceManager.instance;
  }

  removeEventListener(): void {
    EventBus.off(Constant.EVENTS.ACCOUNT_LOGIN, this.accountLogin);
    EventBus.off(Constant.EVENTS.ACCOUNT_LOGOUT, this.accountLogout);
  }

  addEventListener(): void {
    EventBus.on(Constant.EVENTS.ACCOUNT_LOGIN, this.accountLogin);
    EventBus.on(Constant.EVENTS.ACCOUNT_LOGOUT, this.accountLogout);
  }

  accountLoginStatusChange(isLogin: boolean): void {
    HiLog.info(TAG, 'accountLoginStatusChange : isLogin = ' + isLogin);
    if (isLogin) {
      if (!this.isQuery) {
        this.getStorageDeviceListByWorker();
      }
    }
  }

  /**
   * 提供获取存储设备列表统一接口
   * @param isStart 是否是应用启动时调用，picker热启时isStart置为true，确保storageDeviceList获取正确
   * @returns 存储设备列表
   */
  async getStorageDeviceList(isStart: boolean = false): Promise<Array<DiskInfo>> {
    if (isStart || ArrayUtil.isEmpty(this.storageDeviceList)) {
      await this.getStorageDeviceListByWorker(isStart);
    }
    HiLog.info(TAG, `getStorageDeviceList length = ${this.storageDeviceList.length}`);
    return this.storageDeviceList;
  }

  public getUuidByPath(path: string): string {
    let uuid = '';
    let deviceInfo = FileUtil.getDiskInfoByPath(path, this.storageDeviceList);
    if (deviceInfo) {
      uuid = deviceInfo.uuid || '';
    }
    return uuid;
  }

  /**
   * 根据uri获取对应根目录的绝对路径
   *
   * @param uri 根路径uri
   * @returns 返回对应路径
   */
  public getRelativePathByUri(uri: string): string {
    let relativePath = '';
    let deviceInfo = FileUtil.getRelativePathByRootUri(uri, this.storageDeviceList);
    if (deviceInfo) {
      relativePath = deviceInfo.relativePath || '';
    }
    return relativePath;
  }

  /**
   * 通过FAF获取所有存储设备列表，包括内部存储和外部存储（SD卡、U盘）
   * @param isStart 是否是应用启动时调用，picker热启时isStart置为true，确保storageDeviceList获取正确
   * @returns 存储设备列表
   */
  public async getStorageDeviceListByWorker(isStart: boolean = false): Promise<Array<DiskInfo>> {
    HiLog.info(TAG, 'getStorageDeviceListByWorker');
    return new Promise((resolve, reject) => {
      FileAccessUtil.getRootListWithFaf().then((rootInfoArray: DiskInfo[]) => {
        this.isQuery = false;
        let tempList: DiskInfo[] = [];
        let isNeedUpdate = false;
        if (ArrayUtil.isEmpty(rootInfoArray)) {
          HiLog.warn(TAG, 'getStorageDeviceListByWorker fail, rootInfoArray is empty');
          tempList = this.storageDeviceList.filter((item: DiskInfo) => item.deviceType ===
          fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK);
          isNeedUpdate = true;
        } else {
          tempList = this.filterSameUuid(rootInfoArray);
          isNeedUpdate = this.diskInfoChange(tempList, this.storageDeviceList);
          HiLog.info(TAG, `getStorageDeviceListByWorker isNeedUpdate = ${isNeedUpdate}`);
        }
        if (isNeedUpdate || isStart) {
          this.storageDeviceList = tempList;
          this.resetStorageDeviceList();
        }
        resolve(this.storageDeviceList);
        if (!ArrayUtil.isEmpty(this.storageDeviceList)) {
          let uuidList = this.storageDeviceList.map((diskInfo: DiskInfo) => diskInfo.uuid);
          this.removeNewDeviceUuid(uuidList);
        }
        let hasAddUuid = !ArrayUtil.isEmpty(this.addDeviceUuidList);
        if (hasAddUuid) {
          this.addDeviceUuidList = [];
          this.getStorageDeviceListByWorker();
        }
      });
    });
  }

  public getExternalStorageNameByUUID(uuid: string): string {
    if (ArrayUtil.isEmpty(this.storageDeviceList)) {
      HiLog.warn(TAG, 'getExternalStorageNameByUUID, get name fail');
      return '';
    }
    const targetDiskInfo: DiskInfo | undefined = this.storageDeviceList.find(diskInfo => diskInfo.uuid === uuid);
    if (targetDiskInfo) {
      return targetDiskInfo.description;
    }
    HiLog.warn(TAG, 'getExternalStorageNameByUUID, uuid not exists');
    return '';
  }

  /**
   * 监听存储设备挂载和移除的公共事件
   */
  async subscribeStorageDeviceChangeEvent(deviceType: DeviceTypeConstants = DeviceTypeConstants.PC): Promise<void> {
    try {
      this.deviceType = deviceType;
      if (this.isSubscribed) {
        HiLog.info(TAG, 'subscribeStorageDeviceChangeEvent has executed');
        return;
      }
      this.addEventListener();
      // 创建订阅者
      this.subscriber = await CommonEventManager.createSubscriber({
        events: this.eventList
      });
      // 订阅公共事件
      CommonEventManager.subscribe(this.subscriber,
        (error: Base.BusinessError, commonEventData: CommonEventManager.CommonEventData) => {
          HiLog.warn(TAG, `external device event:${commonEventData.event}`);
          this.storageDeviceChangeCallBack(error, commonEventData);
        });
      this.isSubscribed = true;
      HiLog.info(TAG, 'subscribeStorageDeviceChangeEvent success');
    } catch (error) {
      HiLog.error(TAG, 'subscribeStorageDeviceChangeEvent fail, error: ' + JSON.stringify(error));
    }
  }

  /**
   * 取消监听存储设备挂载和移除的公共事件
   */
  unsubscribeStorageDeviceChangeEvent(): void {
    this.removeEventListener();
    try {
      CommonEventManager.unsubscribe(this.subscriber, (error: Base.BusinessError) => {
        if (ObjectUtil.isNullOrUndefined(error)) {
          HiLog.info(TAG, 'Unsubscribed from StorageDeviceChangeEvent successfully!');
          this.isSubscribed = false;
          return;
        }
        HiLog.error(TAG,
          'unsubscribeStorageDeviceChangeEvent fail, error: ' + JSON.stringify(error) + ', ' + error.message);
      });
    } catch (error) {
      HiLog.error(TAG, 'unsubscribeStorageDeviceChangeEvent fail, error: ' + JSON.stringify(error));
    }
  }

  private diskInfoChange(currentDisks: DiskInfo[], diskInfoArr: DiskInfo[]): boolean {
    if (ObjectUtil.isNullOrUndefined(diskInfoArr) || (diskInfoArr.length !== currentDisks.length)) {
      return true;
    }
    for (let i = 0; i < diskInfoArr.length; i++) {
      let findIndex = currentDisks.findIndex(diskInfo => {
        return diskInfo.uri === diskInfoArr[i].uri &&
          diskInfo.deviceType === diskInfoArr[i].deviceType &&
          diskInfo.description === diskInfoArr[i].description &&
          diskInfo.displayName === diskInfoArr[i].displayName;
      });
      if (findIndex < 0) {
        return true;
      }
    }
    return false;
  }

  private filterSameUuid(deviceList: DiskInfo[]): DiskInfo[] {
    if (ObjectUtil.isNullOrUndefined(deviceList) || ArrayUtil.isEmpty(deviceList)) {
      return deviceList;
    }
    let tempList: DiskInfo[] = [];
    let len = deviceList.length;
    for (let i = 0; i < len; i++) {
      let device = deviceList[i];
      let index =
        tempList.findIndex(temp => !ObjectUtil.isNullOrUndefined(device.uuid) &&
          temp.deviceType === device.deviceType &&
          temp.uuid === device.uuid);
      if (index === -1) {
        tempList.push(device);
      }
    }
    return tempList;
  }

  private resetStorageDeviceList(): void {
    HiLog.info(TAG, 'resetStorageDeviceList storageDeviceList.length = ' + this.storageDeviceList.length);
    // 缓存设备列表用于页面更新
    AppStorage.setOrCreate<Array<DiskInfo>>('storageDeviceList', this.storageDeviceList);
    const uriArray = this.storageDeviceList.map((diskInfo: DiskInfo) => diskInfo.uri);
    // 通知页面储存设备有变化需刷新页面
    EventBus.emit(Constant.EVENTS.SD_USB_CHANGE, uriArray);
    // 更新本地存储根目录的uri
    this.updateLocalRootUri(this.storageDeviceList);
  }

  private updateLocalRootUri(diskArr: DiskInfo[]): void {
    if (ArrayUtil.isEmpty(diskArr)) {
      return;
    }
    // 获取本地RootUri
    const localDevice =
      diskArr.find((disk: DiskInfo) => disk.deviceType === fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK);
    if ((!localDevice) || StringUtil.isEmpty(localDevice.uri)) {
      HiLog.warn(TAG, 'not find localDevice or localDevice uri is null');
    } else {
      GlobalHolder.getInstance().setObject<string>(GlobalKey.LOCAL_ROOT_URI, localDevice.uri);
    }
  }

  /**
   * 存储设备挂载和移除之后重新获取存储设备列表
   */
  private async storageDeviceChangeCallBack(error: Base.BusinessError,
    commonEventData: CommonEventManager.CommonEventData): Promise<void> {
    if (!ObjectUtil.isNullOrUndefined(error)) {
      HiLog.warn(TAG, 'storageDeviceChangeCallBack error: ' + JSON.stringify(error) + ', ' + error.message);
      return;
    }

    let changeUuid = this.getUuidByParams(commonEventData);
    HiLog.infoPrivate(TAG, 'subscribe : ', changeUuid + ' ; ' + JSON.stringify(commonEventData));
    switch (commonEventData.event) {
      case CommonEventManager.Support.COMMON_EVENT_VOLUME_MOUNTED:
        UEUtil.reportExternalOper(DFX.ExternalOperType.INSERT);
        await FileAccessUtil.refreshStorageRootInfo(); // 刷新根节点
        if (this.isQuery) {
          this.addNewDeviceUuid(changeUuid);
        } else {
          this.getStorageDeviceListByWorker();
        }
        break;
      case CommonEventManager.Support.COMMON_EVENT_VOLUME_BAD_REMOVAL:
        UEUtil.reportExternalOper(DFX.ExternalOperType.DIRECTLY_REMOVE);
      case CommonEventManager.Support.COMMON_EVENT_VOLUME_UNMOUNTED:
      case CommonEventManager.Support.COMMON_EVENT_VOLUME_EJECT:
        this.usbStorageDeviceRemoved(commonEventData, changeUuid);
        break;
      default:
        break;
    }
  }

  private usbStorageDeviceRemoved(commonEventData: CommonEventManager.CommonEventData, changeUuid: string): void {
    if ((ObjectUtil.isNullOrUndefined(this.storageDeviceList)) ||
      (ArrayUtil.isEmpty(this.storageDeviceList))) {
      HiLog.warn(TAG, 'usbStorageDeviceRemoved storageDeviceList is empty');
      return;
    }
    if (StringUtil.isEmpty(changeUuid)) {
      HiLog.warn(TAG, 'usbStorageDeviceRemoved changeUuid is empty');
      return;
    }
    let index = this.storageDeviceList.findIndex(deviceItem => deviceItem.uuid === changeUuid);
    if (index === -1) {
      HiLog.warn(TAG, 'usbStorageDeviceRemoved index not find');
      return;
    }
    // unmount接口调用->ejecting->unmounted,手动移除COMMON_EVENT_VOLUME_BAD_REMOVAL
    if (commonEventData.event === CommonEventManager.Support.COMMON_EVENT_VOLUME_EJECT) {
      HiLog.info(TAG, 'event COMMON_EVENT_VOLUME_EJECT');
      AppStorage.setOrCreate<DiskChangeInfo>('DiskStatusChange', new DiskChangeInfo(false, changeUuid));
      return;
    }
    this.storageDeviceList.splice(index, 1);
    this.resetStorageDeviceList();
    let delUuidList: string[] = [];
    delUuidList.push(changeUuid);
    this.removeNewDeviceUuid(delUuidList);
  }

  private addNewDeviceUuid(newUuid: string): void {
    if (ObjectUtil.isNullOrUndefined(newUuid) || StringUtil.isEmpty(newUuid)) {
      return;
    }
    let index = this.addDeviceUuidList.findIndex(uuid => uuid === newUuid);
    if (index === -1) {
      this.addDeviceUuidList.push(newUuid);
    }
  }

  private removeNewDeviceUuid(uuidList: string[] = []): void {
    if (!ArrayUtil.isEmpty(uuidList)) {
      let len = uuidList.length;
      for (let i = 0; i < len; i++) {
        let delUuid = uuidList[i];
        let index = this.addDeviceUuidList.findIndex(uuid => uuid === delUuid);
        if (index !== -1) {
          this.addDeviceUuidList.splice(index, 1);
        }
      }
    }
  }

  private getUuidByParams(commonEventData: CommonEventManager.CommonEventData): string {
    if (!ObjectUtil.isNullOrUndefined(commonEventData)) {
      let params = commonEventData.parameters;
      if (params) {
        let uuid: object = params.fsUuid;
        if (typeof uuid === 'string') {
          return uuid as string;
        }
      }
    }
    return '';
  }
}