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

import { collections, HashMap } from '@kit.ArkTS';
import { VirtualUri } from '../const/FolderRecord';
import { HiLog } from '../dfx/HiLog';
import { FileUtil } from '../fileoperate/FileUtil';
import { bundleResourceManager } from '@kit.AbilityKit';
import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';
import { Constant, FileSourceUri } from '../const/Constant';
import { ResourceUtil } from './ResourceUtil';
import { StringUtil } from './StringUtil';
import { ParseUtil } from './ParseUtil';
import lazy { bundleManager } from '../../../../indexLazyLoadTs';

const TAG = 'BundleResourceUtil';
const brmFlag: bundleResourceManager.ResourceFlag = bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_ALL;
const bmFlag: bundleManager.BundleFlag = bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT;

export class BundleResourceUtil {
  public static readonly downloadUriShowNameMap: HashMap<string, string> = new HashMap<string, string>();
  public static readonly fileSourceShowIconMap: HashMap<string, ResourceStr> = new HashMap<string, ResourceStr>();
  // 订阅者信息
  private static subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [commonEventManager.Support.COMMON_EVENT_BUNDLE_RESOURCES_CHANGED], // 订阅BundleResourcesChanged公共事件
  };

  // 保存创建成功的订阅者对象，后续使用其完成订阅及退订的动作
  private static subscriber: commonEventManager.CommonEventSubscriber | null = null;

  static {
    BundleResourceUtil.fileSourceShowIconMap.set(FileSourceUri.BLUETOOTH, $r('app.media.ic_download_bluetooth'));
    BundleResourceUtil.fileSourceShowIconMap.set(FileSourceUri.SHARE, $r('app.media.ic_download_share'));
    BundleResourceUtil.fileSourceShowIconMap.set(FileSourceUri.DOWNLOAD_MANAGER, $r('app.media.ic_download_device'));
  }

  /**
   * 缓存下载控件包名对应的应用名
   */
  public static createDownloadUriShowMap(): void {
    HiLog.info(TAG, 'createDownloadUriShowNameMap start.');
    BundleResourceUtil.setDownloadUriShowMap(BundleResourceUtil.getDownloadNameMap());
    HiLog.info(TAG, `createDownloadUriShowMap length: ${BundleResourceUtil.downloadUriShowNameMap.length}`);
  }

  public static setDownloadUriShowMap(nameMap: collections.Map<string, string>) {
    if (!nameMap) {
      HiLog.error(TAG, 'nameMap is invalid');
      return;
    }
    nameMap.forEach((value, key) => {
      BundleResourceUtil.downloadUriShowNameMap.set(key, value);
    })
  }

  public static getDownloadNameMap(): collections.Map<string, string> {
    const fileNameArray = FileUtil.getSubFoldersSync(VirtualUri.DOWNLOAD);
    const bundleFlags = bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_ALL;
    let result = new collections.Map<string, string>();
    for (let i = 0; i < fileNameArray.length; i++) {
      const fileName =
        FileUtil.decodeURIComponent(fileNameArray[i].substring(fileNameArray[i].lastIndexOf('/') + 1));
      if (BundleResourceUtil.downloadUriShowNameMap.hasKey(fileName)) {
        HiLog.info(TAG, 'this bundle app label and icon is exist');
        continue;
      }
      try {
        if (fileName.split('.').length < 2) {
          continue;
        }
        const res = ParseUtil.getAppCloneIdentity(fileName);
        const resourceInfo =
          bundleResourceManager.getBundleResourceInfo(res?.bundleName, bundleFlags, res?.appIndex);
        result.set(fileName, resourceInfo.label);
      } catch (err) {
        HiLog.error(TAG, `getBundleResourceInfo failed: ${err?.code}, message: ${err?.message}`);
      }
    }
    return result;
  }

  /**
   * 根据包名获取应用名，用于后续将包名文件夹 适配多语言和添加icon
   * @param folderName 文件夹名称
   */
  public static addAppSandBoxBundleName(bundleName: string): void {
    if (!bundleName || BundleResourceUtil.downloadUriShowNameMap.hasKey(bundleName)) {
      HiLog.info(TAG, 'addAppSandBoxBundleName exception cause bundleName is null');
      return;
    }
    try {
      const bundleFlags = bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_ALL;
      const res = ParseUtil.getAppCloneIdentity(bundleName);
      const resourceInfo =
        bundleResourceManager.getBundleResourceInfo(res?.bundleName, bundleFlags, res?.appIndex);
      BundleResourceUtil.downloadUriShowNameMap.set(bundleName, resourceInfo.label);
    } catch (e) {
      HiLog.warn(TAG, `addAppSandBoxBundleName error: ${JSON.stringify(e)}`);
    }
  }

  public static isSandboxBundleName(bundleName: string): boolean {
    if (StringUtil.isEmpty(bundleName)) {
      return false;
    }

    return bundleName.endsWith(Constant.SANDBOX_SUFFIX);
  }

  public static getSandBoxRealBundleName(sandboxBundleName: string): string {
    if (BundleResourceUtil.isSandboxBundleName(sandboxBundleName)) {
      const index = sandboxBundleName.lastIndexOf(Constant.SANDBOX_SUFFIX);
      return sandboxBundleName.substring(0, index);
    }
    return sandboxBundleName;
  }

  public static getBundleLabelByBundleName(bundleName: string): string {
    try {
      if (ParseUtil.isCloneBundleName(bundleName)) {
        const index: number = ParseUtil.getCloneIndex(bundleName);
        const mainBundleName: string = ParseUtil.getCloneBundleName(bundleName);
        // 这里出错代表找不到此应用，使用此接口带上UserId，用于区分隐私空间和主空间
        bundleManager.getBundleInfoSync(mainBundleName, bmFlag, Constant.USER_ID);
        const sourceInfo = bundleResourceManager.getBundleResourceInfo(mainBundleName, brmFlag, index);
        return sourceInfo.label;
      }
      const resourceInfo: bundleResourceManager.BundleResourceInfo = bundleResourceManager.getBundleResourceInfo(
        bundleName, bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_ALL);
      return resourceInfo.label;
    } catch (err) {
      const message: string = (err as BusinessError).message;
      HiLog.error(TAG, `getBundleLabelByBundleName failed: ${message}`);
    }
    return bundleName;
  }

  public static getDownLoadBundleName(fileName: string): string {
    if (StringUtil.isEmpty(fileName)) {
      HiLog.warn(TAG, `fileName is null.`);
      return '';
    }
    if (BundleResourceUtil.downloadUriShowNameMap.hasKey(fileName)) {
      return BundleResourceUtil.downloadUriShowNameMap.get(fileName);
    }
    return fileName;
  }

  public static onSystemLanguageChange() {
    HiLog.info(TAG, 'onSystemLanguageChange getBundleResourceInfo start.');
    try {
      const bundleFlags = bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_ALL;
      BundleResourceUtil.downloadUriShowNameMap.forEach((_value, fileName) => {
        const res = ParseUtil.getAppCloneIdentity(fileName);
        const resourceInfo =
          bundleResourceManager.getBundleResourceInfo(res?.bundleName, bundleFlags, res?.appIndex);
        BundleResourceUtil.downloadUriShowNameMap.set(fileName, resourceInfo.label);
      })
    } catch (err) {
      HiLog.error(TAG, `getBundleResourceInfo failed: message: ${err?.message}`);
    }
  }

  public static isPhoneSandBoxExist(uri: string): boolean {
    try {
      const sandBoxPrefix = uri.substring(FileUtil.URI_START.length);
      let bundleName = sandBoxPrefix.substring(0, sandBoxPrefix.indexOf('/'));
      bundleResourceManager.getBundleResourceInfo(bundleName, bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_ALL);
      return true;
    } catch (err) {
      const message: string = (err as BusinessError).message;
      HiLog.error(TAG, `getBundleLabelByBundleName failed: ${message}`);
      return false;
    }
  }

  public static async subscribeBundleResourcesChangedEvent() {
    // 订阅公共事件回调
    if (BundleResourceUtil.subscriber == null) {
      // 创建订阅者回调
      BundleResourceUtil.subscriber = await commonEventManager.createSubscriber(BundleResourceUtil.subscribeInfo);
      commonEventManager.subscribe(BundleResourceUtil.subscriber,
        (err: BusinessError, data: commonEventManager.CommonEventData) => {
          if (err) {
            HiLog.error(TAG, `Failed to subscribe common event. Code is ${err.code}, message is ${err.message}`);
            return;
          }
          HiLog.warn(TAG, `BundleResourcesChanged, data: ${JSON.stringify(data)}`);
          AppStorage.setOrCreate('BundleResourcesChanged', !AppStorage.get<boolean>('BundleResourcesChanged'));
        });
    } else {
      HiLog.error(TAG, `subscriber already exists`);
    }
  }

  public static async unsubscribeBundleResourcesChangedEvent() {
    // subscriber为订阅事件时创建的订阅者对象
    if (BundleResourceUtil.subscriber !== null) {
      commonEventManager.unsubscribe(BundleResourceUtil.subscriber, (err: BusinessError) => {
        if (err) {
          HiLog.error(TAG, `unsubscribeBundleResourcesChangedEvent err = ${JSON.stringify(err)}`);
        } else {
          HiLog.info(TAG, `unsubscribeBundleResourcesChangedEvent success`);
          BundleResourceUtil.subscriber = null;
        }
      });
    }
  }
}