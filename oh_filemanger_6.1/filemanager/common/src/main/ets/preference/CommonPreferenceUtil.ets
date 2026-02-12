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

import { Constant, LocationItemName } from '../const/Constant';
import { PreferenceConst } from '../const/PreferenceConst';
import { HiLog } from '../dfx/HiLog';
import { StorageSpaceInfo } from '../externel/DiskInfo';
import { StringUtil } from '../utils/StringUtil';
import { BasePreference } from './BasePreference';
import { PreferenceFactory } from './PreferenceFactory';
import { UEUtil } from '../dfx/UEUtil';
import { DFX } from '../dfx/const/DFXConst';
import { EnumTransferUtil } from '../dfx/EnumTransferUtil';
import { CommonUtil } from '../utils/CommonUtil';
import { systemParameter } from '@kit.BasicServicesKit';
import { FsUtil } from '../utils/FsUtil';
import { ObjectUtil } from '../utils/ObjectUtil';

//聚合视图未完成聚合时，toast提示显示次数上限
const TIPS_SHOW_TIMES_LIMIT = 3;

const TAG: string = 'CommonPreferenceUtil';

/**
 * 一些公共的持久化存储value的设置和获取方法工具类
 */
export class CommonPreferenceUtil {
  // 用于存储设备的空间信息
  private static storageDeviceSpace: Map<string, StorageSpaceInfo> = new Map();
  // 录音机文件是否已迁移完成
  private static recorderMigrationStatus: boolean = false;

  /**
   * 清理相册引导配置
   * @returns
   */
  public static async cleanAlbumGuideKey(uri: string[], isPicker: boolean): Promise<void> {
    const preference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    const allObj: Object = await preference.getAll() || ObjectUtil.empty();
    const allKeys = Object.keys(allObj);
    const albumGuideKeys = allKeys.filter((key: string) => {
      const keyUri = key.slice(PreferenceConst.KEY.ALBUM_GUIDE_TIP.length + String(isPicker).length);
      return key.startsWith(PreferenceConst.KEY.ALBUM_GUIDE_TIP) && !uri.includes(keyUri);
    });
    preference.batchDelete(albumGuideKeys);
  }

  /**
   * 获取下次打开文管时默认展示的tab
   * @returns
   */
  public static async getDefaultTabIndex(): Promise<void> {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    const defaultTabIndex =
      await preference.get<number>(PreferenceConst.KEY.DEFAULT_TAB_INDEX, Constant.TAB_ID.TAB_BROWSE);
    AppStorage.setOrCreate(PreferenceConst.KEY.DEFAULT_TAB_INDEX, defaultTabIndex);
  }

  /**
   * 设置下次打开文管时默认展示的tab
   * @returns
   */
  public static async setDefaultTabIndex(newTabIndex: number): Promise<void> {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    await preference.put(PreferenceConst.KEY.DEFAULT_TAB_INDEX, newTabIndex);
    AppStorage.setOrCreate(PreferenceConst.KEY.DEFAULT_TAB_INDEX, newTabIndex);
  }

  /**
   * 获取下次打开filepicker时默认展示的tab
   * @returns
   */
  public static async getFilePickerDefaultTabIndex(): Promise<number> {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    const defaultTabIndex =
      await preference.get<number>(PreferenceConst.KEY.FILE_PICKER_DEFAULT_TAB_INDEX, 0);
    return defaultTabIndex;
  }

  /**
   * 设置下次打开filepicker时默认展示的tab
   * @returns
   */
  public static async setFilePickerDefaultTabIndex(newTabIndex: number): Promise<void> {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    await preference.put(PreferenceConst.KEY.FILE_PICKER_DEFAULT_TAB_INDEX, newTabIndex);
  }

  /**
   * 获取上次在文管内进行复制移动等操作时拉起路径选择的文件夹uri
   * @returns
   */
  public static async getLastSelectFolderUri(): Promise<void> {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    const lastSelectFolderUri = await preference.get<string>(PreferenceConst.KEY.LAST_SELECT_FOLDER_URI, '');
    AppStorage.setOrCreate(PreferenceConst.KEY.LAST_SELECT_FOLDER_URI, lastSelectFolderUri);
  }

  /**
   * 设置上次在文管内进行复制移动等操作时拉起路径选择的文件夹uri
   * @returns
   */
  public static async setLastSelectFolderUri(lastSelectFolderUri: string): Promise<void> {
    if (StringUtil.isEmpty(lastSelectFolderUri)) {
      return;
    }
    AppStorage.setOrCreate(PreferenceConst.KEY.LAST_SELECT_FOLDER_URI, lastSelectFolderUri);
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    await preference.put(PreferenceConst.KEY.LAST_SELECT_FOLDER_URI, lastSelectFolderUri);
  }

  /**
   * 获取上次处理剪切板上数据的时间戳
   */
  public static async getLastResolvePasteboardTimestamp(): Promise<number> {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    return await preference.get<number>(PreferenceConst.KEY.LAST_RESOLVE_PASTEBOARD_TIMESTAMP, 0);
  }

  /**
   * 设置上次处理剪切板上数据的时间戳
   */
  public static async setLastResolvePasteboardTimestamp(timestamp: number): Promise<void> {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    await preference.put(PreferenceConst.KEY.LAST_RESOLVE_PASTEBOARD_TIMESTAMP, timestamp);
  }

  /**
   * 获取上次清理缩略图缓存的时间
   * @returns number 时间戳
   */
  public static async getLastCleanThumbnailCacheTimeStamp(): Promise<number> {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    return await preference.get<number>(PreferenceConst.KEY.LAST_CLEAN_THUMBNAIL_CACHE_TIMESTAMP, 0);
  }

  /**
   * 更新清理缩略图缓存的时间
   * @returns void
   */
  public static async setLastCleanThumbnailCacheTimeStamp(): Promise<void> {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    await preference.put(PreferenceConst.KEY.LAST_CLEAN_THUMBNAIL_CACHE_TIMESTAMP, new Date().getTime());
  }

  /**
   * 获取上次清理USB设备缩略图缓存的时间
   * @returns number 时间戳
   */
  public static async getLastCleanUsbThumbnailCacheTimeStamp(): Promise<number> {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    return await preference.get<number>(PreferenceConst.KEY.LAST_CLEAN_USB_THUMBNAIL_CACHE_TIMESTAMP, 0);
  }

  /**
   * 更新清理USB设备缩略图缓存的时间
   * @returns void
   */
  public static async setLastCleanUsbThumbnailCacheTimeStamp(): Promise<void> {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    await preference.put(PreferenceConst.KEY.LAST_CLEAN_USB_THUMBNAIL_CACHE_TIMESTAMP, new Date().getTime());
  }

  /**
   * 更新双升单相关展示数据存储
   *
   * @param popTipsSwitch 双升单相关目录Tip提示
   * @returns
   */
  public static async setTipsAlreadyShowSwitch(key: string, popTipsSwitch: boolean): Promise<void> {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    await preference.put(key, popTipsSwitch);
  }

  /**
   * 获取气泡浏览页提示开关标识
   *
   * @returns 结果
   */
  public static async getTipsAlreadyShowSwitch(tipKey: string): Promise<boolean> {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    return await preference.get<boolean>(tipKey, false);
  }

  /**
   * 获取记录的空间大小信息
   * @returns
   */
  public static getDeviceStorageSpace(deviceType: string): StorageSpaceInfo | undefined {
    HiLog.info(TAG, 'getDevice StorageSpace start.');
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    if (CommonPreferenceUtil.storageDeviceSpace.has(deviceType)) {
      return CommonPreferenceUtil.storageDeviceSpace.get(deviceType);
    }
    let storageSpaceList: StorageSpaceInfo[] =
      preference.getSync<StorageSpaceInfo[]>(PreferenceConst.KEY.DEVICE_STORAGE_SPACE, []);
    for (let i = 0; i < storageSpaceList.length; i++) {
      if (storageSpaceList[i].deviceType === deviceType) {
        return storageSpaceList[i];
      }
    }
    return undefined;
  }

  /**
   * 每次空间大小查询完之后，更新
   * @returns
   */
  public static async setDeviceStorageSpace(device: string, spaceInfo: StorageSpaceInfo): Promise<void> {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    if (CommonPreferenceUtil.storageDeviceSpace.has(device)) {
      let oldSpaceInfo: StorageSpaceInfo = CommonPreferenceUtil.storageDeviceSpace.get(device) as StorageSpaceInfo;
      if (oldSpaceInfo.totalSpaceSize === spaceInfo.totalSpaceSize &&
        oldSpaceInfo.freeSpaceSize === oldSpaceInfo.freeSpaceSize) {
        return;
      }
    }
    HiLog.warn(TAG, `setDeviceStorageSpace, isLocal: ${device === 'LOCAL'},`,
      `total: ${spaceInfo.totalSpaceSize}, useSize: ${spaceInfo.freeSpaceSize}`);
    CommonPreferenceUtil.storageDeviceSpace.set(device, spaceInfo);
    let deviceValuse = Array.from(CommonPreferenceUtil.storageDeviceSpace.values());
    preference.put(PreferenceConst.KEY.DEVICE_STORAGE_SPACE, deviceValuse);
  }

  /**
   * 设置存储位置项目显示状态
   * @param itemName 项目名称
   * @param isShow 是否显示
   */
  public static setLocationItemShowStatus(itemName: LocationItemName, isShow: boolean): void {
    if (!itemName) {
      HiLog.warn(TAG, `setLocationItemShowStatus, null itemName`);
      return;
    }
    HiLog.info(TAG, `setLocationItemShowStatus, itemName:${itemName}, isShow:${isShow}`);
    UEUtil.reportLocationItemOper(isShow ? DFX.LocationItemOperType.SHOW : DFX.LocationItemOperType.HIDE,
      EnumTransferUtil.transferLocationNameToPageName(itemName));
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    preference.putSync(itemName, isShow);
  }

  /**
   * 获取存储位置项目显示状态
   * @param itemName 项目名称
   * @returns 是否显示
   */
  public static getLocationItemShowStatus(itemName: LocationItemName | undefined): boolean {
    if (!itemName) {
      HiLog.warn(TAG, `getLocationItemShowStatus, null itemName`);
      return true;
    }
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    let isShow: boolean = preference.getSync(itemName, true);
    HiLog.info(TAG, `getLocationItemShowStatus, itemName:${itemName}, isShow:${isShow}`);
    return isShow;
  }

  /**
   * 设置收藏文件夹列表展开状态
   * @param itemName 项目名称
   * @returns 是否显示
   */
  public static setFavouriteListExpand(isExpand: boolean): void {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    preference.putSync(PreferenceConst.KEY.FAVORITE_LIST_EXPAND, isExpand);
    HiLog.info(TAG, `setFavouriteListExpend, isExpand:${isExpand}`);
  }

  /**
   * 获取收藏文件夹列表展开状态
   * @param itemName 项目名称
   * @returns 是否显示
   */
  public static getFavouriteListExpand(): boolean {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    let isExpand: boolean = preference.getSync(PreferenceConst.KEY.FAVORITE_LIST_EXPAND, true);
    HiLog.info(TAG, `getFavouriteListExpend, isExpand:${isExpand}`);
    return isExpand;
  }

  /**
   * 获取搜索页面熄屏提示状态
   * @param itemName 项目名称
   * @returns 是否显示
   */
  public static setPowerConsumptionHintConfirmed(isConfirmed: boolean): void {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    preference.putSync(PreferenceConst.KEY.POWER_HINT_CONFIRMED, isConfirmed);
    HiLog.info(TAG, `setPowerConsumptionHintConfirmed, isConfirmed:${isConfirmed}`);
  }

  /**
   * 获取收藏文件夹列表展开状态
   * @param itemName 项目名称
   * @returns 是否显示
   */
  public static getPowerConsumptionHintConfirmed(): boolean {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    let isConfirmed: boolean = preference.getSync(PreferenceConst.KEY.POWER_HINT_CONFIRMED, false);
    HiLog.info(TAG, `getPowerConsumptionHintConfirmed, isConfirmed:${isConfirmed}`);
    return isConfirmed;
  }

  /**
   * 设置是否通过应用指南
   * @returns
   */
  public static async setAppGuidance(appGuidancePass: boolean): Promise<void> {
    const preference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    await preference.put(PreferenceConst.KEY.APP_GUIDANCE_PASS, appGuidancePass);
    AppStorage.setOrCreate(PreferenceConst.KEY.APP_GUIDANCE_PASS, appGuidancePass);
  }

  /**
   * 设置用户看到过的引导页的版本
   *
   * @param version
   */
  public static async setAppGuidancePassVersion(version: number): Promise<void> {
    const preference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    await preference.put(PreferenceConst.KEY.APP_GUIDANCE_PASS_VERSION, version);
  }

  /**
   * 设置最近页是否展示特性更新卡片
   *
   * @param isShow
   */
  public static async setRecentNewFeatureCardShow(isShow: boolean): Promise<void> {
    const preference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    await preference.put(PreferenceConst.KEY.RECENT_NEW_FEATURE_CARD_SHOW, isShow);
    AppStorage.setOrCreate(PreferenceConst.KEY.RECENT_NEW_FEATURE_CARD_SHOW, isShow);
  }

  /**
   * 设置最近页底部栏是否显示红点提醒
   *
   * @param isShow
   */
  public static async setRecentBarRedDotShow(isShow: boolean): Promise<void> {
    const preference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    await preference.put(PreferenceConst.KEY.RECENT_BAR_RED_DOT_SHOW, isShow);
    AppStorage.setOrCreate(PreferenceConst.KEY.RECENT_BAR_RED_DOT_SHOW, isShow);
  }

  public static async loadNewFeatureGuideState(): Promise<void> {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    const newFeatureGuideVersion = await preference.get<number>(
      PreferenceConst.KEY.NEW_FEATURE_GUIDE_VERSION, CommonUtil.NEW_FEATURE_GUIDE_DEFAULT_VERSION);

    const configVersion: number = CommonUtil.NEW_FEATURE_GUIDE_CONFIG_VERSION;
    HiLog.warn(TAG, `newFeatureGuideVersion : ${newFeatureGuideVersion}, currentVersion: ${configVersion}`);

    if (newFeatureGuideVersion < configVersion) {
      // 版本号有更新，刷新持久化版本号，并且重置最近页宣传卡片和最近页红点显示
      await preference.put(PreferenceConst.KEY.NEW_FEATURE_GUIDE_VERSION, configVersion);
      await CommonPreferenceUtil.setRecentNewFeatureCardShow(true);
      await CommonPreferenceUtil.setRecentBarRedDotShow(true);
    } else {
      const cardShow: boolean = await preference.get<boolean>(PreferenceConst.KEY.RECENT_NEW_FEATURE_CARD_SHOW, false);
      const redDotShow: boolean = await preference.get<boolean>(PreferenceConst.KEY.RECENT_BAR_RED_DOT_SHOW, false);
      AppStorage.setOrCreate(PreferenceConst.KEY.RECENT_NEW_FEATURE_CARD_SHOW, cardShow);
      AppStorage.setOrCreate(PreferenceConst.KEY.RECENT_BAR_RED_DOT_SHOW, redDotShow);
    }
  }

  public static async loadCacheDataRemoveTipClosedState(): Promise<void> {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    const version: number = await preference.get<number>(PreferenceConst.KEY.REMOVE_CACHE_DATA_TIP_CLOSED_VERSION,
      CommonUtil.REMOVE_CACHE_DATA_TIP_CLOSED_DEFAULT_VERSION);

    const configVersion: number = CommonUtil.REMOVE_CACHE_DATA_TIP_CLOSED_VERSION;
    HiLog.warn(TAG, `cacheDataRemoveTipClosedVersion version : ${version}, currentVersion: ${configVersion}`);

    if (version < configVersion) {
      // 版本号有更新，刷新持久化版本号，并且重置出现来源下的缓存文件提示语
      await preference.put(PreferenceConst.KEY.REMOVE_CACHE_DATA_TIP_CLOSED_VERSION, configVersion);
      await preference.put(PreferenceConst.KEY.REMOVE_CACHE_DATA_TIP_CLOSED, false);
    }
  }

  /**
   * 获取应用指南通过状态
   * @returns
   */
  public static async loadAppGuidanceState(): Promise<void> {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    const appGuidancePass = await preference.get<boolean>(PreferenceConst.KEY.APP_GUIDANCE_PASS, false);
    // 需要弹app引导页时，无需再读取版本号
    if (!appGuidancePass) {
      AppStorage.setOrCreate(PreferenceConst.KEY.APP_GUIDANCE_PASS, appGuidancePass);
      return;
    }

    try {
      // 默认值为1，不能为0，因为已有配置文件里的版本为1
      const appGuidancePassVersion = Number(await preference.get<number>(
        PreferenceConst.KEY.APP_GUIDANCE_PASS_VERSION, CommonUtil.APP_GUIDANCE_DEFAULT_VERSION));

      const configVersion: number = CommonUtil.APP_GUIDANCE_CONFIG_VERSION;
      HiLog.info(TAG, `appGuidancePassVersion : ${appGuidancePassVersion}, currentVersion: ${configVersion}`);

      if (appGuidancePassVersion < configVersion) {
        CommonPreferenceUtil.setAppGuidance(false);
      } else {
        AppStorage.setOrCreate(PreferenceConst.KEY.APP_GUIDANCE_PASS, appGuidancePass);
      }
    } catch (err) {
      HiLog.error(TAG, `get config error: ${err?.message}`);
    }
  }

  /**
   *检测是否门店演示版本设备
   */
  public static isStoreVersion(): boolean {
    let isStoreVersion: boolean = false;
    try {
      let value = systemParameter.getSync('const.dfx.enable_retail');
      isStoreVersion = Boolean(value).valueOf();
    } catch (error) {
      HiLog.error(TAG, `enable_retail error code:${error?.code} msg:${error?.message}`);
    }
    HiLog.info(TAG, `isStoreVersion():${isStoreVersion}`);
    return isStoreVersion;
  }

  /**
   * 获取录音机迁移是否完成持久化数据
   * @returns
   */
  public static getSoundsRecordMigrationStatus(): boolean {
    HiLog.warn(TAG, 'get SoundsRecordMigration status start.');
    if (CommonPreferenceUtil.recorderMigrationStatus) {
      return CommonPreferenceUtil.recorderMigrationStatus;
    }

    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    if (preference) {
      CommonPreferenceUtil.recorderMigrationStatus =
        preference.getSync<boolean>(PreferenceConst.KEY.RECORDER_MIGRATION, false);
    }
    if (!CommonPreferenceUtil.recorderMigrationStatus) {
      CommonPreferenceUtil.setSoundsRecordMigrationStatus();
    }
    return CommonPreferenceUtil.recorderMigrationStatus;
  }

  /**
   * 设置录音机迁移是否完成持久化数据
   * @returns
   */
  public static setSoundsRecordMigrationStatus(): void {
    let filePath: string = Constant.SOUND_RECORD_APPDATA_PATH + Constant.SOUND_RECORD_MIGRATION_COMPLETE_FILE;
    CommonPreferenceUtil.recorderMigrationStatus = FsUtil.isExistSyncByPath(filePath);
    HiLog.warn(TAG, `set SoundsRecordMigration status: ${CommonPreferenceUtil.recorderMigrationStatus}`);
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    if (preference) {
      preference.putSync(PreferenceConst.KEY.RECORDER_MIGRATION, CommonPreferenceUtil.recorderMigrationStatus);
    }
  }

  /**
   * 获取通知栏授权状态
   */
  public static async getPreferenceNotifyStatus(): Promise<boolean | undefined> {
    HiLog.info(TAG, 'getPreferenceNotifyStatus');
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    return preference?.get<boolean>(PreferenceConst.KEY.NOTIFICATION_PERMISSION, 'boolean');
  }

  /**
   * 设置是否允许状态栏通知
   */
  public static async setNotifyStatus(isPermitted: boolean): Promise<void> {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    if (!preference) {
      HiLog.warn(TAG, 'saveNotifyStatus fail, preference is null');
      return;
    }
    await preference.put(PreferenceConst.KEY.NOTIFICATION_PERMISSION, isPermitted);
    HiLog.info(TAG, 'set notificationPermission: ' + isPermitted);
  }

  /**
   * 获取是否首次启动应用
   * @returns 是否首次启动应用
   */
  public static async getFirstLaunch(): Promise<boolean> {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    return await preference.get<boolean>(PreferenceConst.SYSTEM.FIRST_LAUNCH, true);
  }

  /**
   * 设置是否首次启动应用
   * @param firstLaunch 是否首次启动应用
   */
  public static async setFirstLaunch(firstLaunch: boolean): Promise<void> {
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    await preference.put(PreferenceConst.SYSTEM.FIRST_LAUNCH, firstLaunch);
  }
}