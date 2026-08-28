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

import { HiLog } from '../dfx/HiLog';
import type StartOptions from '@ohos.app.ability.StartOptions';
import { UnityStartMode } from '../const/FilePickerItems';
import { Constant, LocationType } from '../const/Constant';
import account_osAccount from '@ohos.account.osAccount';
import { FileInfo } from '../fileoperate/FileInfo';
import { MyPhoneConstant } from '../const/MyPhoneConstant';
import { FileUtil } from '../fileoperate/FileUtil';
import { bundleManager } from '@kit.AbilityKit';
import { systemParameterEnhance } from '@kit.BasicServicesKit';

const FIXED_NUM = 2;
const TAG = 'CommonUtil';

export class CommonUtil {
  // 帮助与客服分配的接入渠道ID：手机文管、PC文管共用6044，通过设备类型区分展示内容
  public static readonly phoneAppId = '6044';

  // 帮助与客服分配的接入渠道ID：专门为小平板申请的帮助与客服6046
  public static readonly miniPadAppId = '6046';

  /**
   * 引导页，的默认值为1，配置文件当下为1
   */
  public static readonly APP_GUIDANCE_DEFAULT_VERSION = 1;

  /**
   * 当前引导页版本号，如果app_guidance_config.json更新后需要刷新这个定义
   * 后面做云推后，需要在云端下载完成后刷新这个值
   */
  public static readonly APP_GUIDANCE_CONFIG_VERSION = 4;

  /**
   * 新特性引导，默认版本号为 0
   */
  public static readonly NEW_FEATURE_GUIDE_DEFAULT_VERSION = 0;

  /**
   * 当前新特性引导版本号，通过版本号区分是否在最近页面展示宣传卡片
   */
  public static readonly NEW_FEATURE_GUIDE_CONFIG_VERSION = 1;

  /**
   * 沙箱缓存提示语，默认版本号为 0
   */
  public static readonly REMOVE_CACHE_DATA_TIP_CLOSED_DEFAULT_VERSION = 0;

  /**
   * 沙箱缓存提示语是否存在更新，更新版本号后来源处需要重新展示
   */
  public static readonly REMOVE_CACHE_DATA_TIP_CLOSED_VERSION = 1;

  public static lastConfirmClickTime: number = 0;
  public static lastCancelClickTime: number = 0;
  public static lastOtherClickTime: number = 0;
  public static startMode: UnityStartMode = UnityStartMode.NORMAL;

  /*
   * 获取文件后缀
   * */
  public static getFileExtension(fileName: string): string {
    let index = fileName.lastIndexOf('.');
    return index === -1 ? '' : fileName.substring(index + 1);
  }

  /*
   * 文件大小单位转换
   * */
  public static sizeConversion(size: number): string {
    let fileSize = 0;
    if (size >= (1000 * 1000 * 1000 * 1000)) {
      fileSize = size / (1000 * 1000 * 1000 * 1000);
      return fileSize.toFixed(FIXED_NUM) + ' TB';
    } else if (size >= (1000 * 1000 * 1000)) {
      fileSize = size / (1000 * 1000 * 1000);
      return fileSize.toFixed(FIXED_NUM) + ' GB';
    } else if (size >= (1000 * 1000)) {
      fileSize = size / (1000 * 1000);
      return fileSize.toFixed(FIXED_NUM) + ' MB';
    } else if (size >= 1000) {
      fileSize = size / 1000;
      return fileSize.toFixed(FIXED_NUM) + ' KB';
    } else {
      return size + ' B';
    }
  }

  public static getOption(screenWidth: number, screenHeight: number, windowWidth: number,
                          windowHeight: number): StartOptions {
    let options: StartOptions = {
      windowLeft: (screenWidth - windowWidth) / 2,
      windowTop: (screenHeight - windowHeight) / 2,
      windowWidth: windowWidth,
      windowHeight: windowHeight
    };
    return options;
  }

  // 连点事件分割开确定和去修还有其他按键，否则不能在点击确定后立刻点击取消
  public static isFastClick(fromName: ResourceStr = ''): boolean {
    switch (fromName) {
      case $r('app.string.cancel'):
        return CommonUtil.getAndSetTime(CommonUtil.lastCancelClickTime);
      case $r('app.string.confirm'):
        return CommonUtil.getAndSetTime(CommonUtil.lastConfirmClickTime);
      default:
        return CommonUtil.getAndSetTime(CommonUtil.lastOtherClickTime);

    }
  }

  private static getAndSetTime(lastTime: number, time: number = 500): boolean {
    let currentTime = Date.now();
    if (currentTime - lastTime < time) {
      lastTime = currentTime;
      return true;
    }
    lastTime = currentTime;
    return false;
  }

  /**
   * 判断当前用户是否处于隐私空间
   * @param
   */
  public static async isPrivacySpaceMode(): Promise<boolean> {
    try {
      let accountManager: account_osAccount.AccountManager = account_osAccount.getAccountManager();
      let osAccountType: account_osAccount.OsAccountType = await accountManager.getOsAccountType();
      if (osAccountType === account_osAccount.OsAccountType.PRIVATE) {
        return true;
      }
      return false;
    } catch (e) {
      HiLog.info(TAG, 'getOsAccountType exception: ' + JSON.stringify(e));
      return false;
    }
  }

  /**
   * 获取最近删除文件剩余保存时间
   * @param deleteTime 删除时间
   */
  public static getRemainDays(deleteTime: number): number {
    const deleteDays: number = (Date.now() - deleteTime) / Constant.TIME.ONE_DAY;
    const remainDays: number = Math.floor(Constant.DEFAULT_SAVE_DAY - deleteDays);
    if (remainDays > Constant.DEFAULT_SAVE_DAY) {
      return Constant.DEFAULT_SAVE_DAY;
    }
    return remainDays < 0 ? 0 : remainDays;
  }

  /**
   * 判断是否需要显示多选框
   * @param fileInfo 文件信息
   */
  public static isShowCheckBox(fileInfo: FileInfo, isPickerFlag: boolean): boolean {
    if (fileInfo.fileName === MyPhoneConstant.MY_PHONE_GALLERY ||
      fileInfo.fileName === MyPhoneConstant.MY_PHONE_SOUND_RECORDER ||
      (fileInfo.isFolder && fileInfo.isGallery) || fileInfo.isFusionAlbum) {
      return false;
    }
    return !isPickerFlag || !fileInfo.isFolder;
  }

  /**
   * 判断壳应用是否存在
   */
  public static async isHmFilesExist(context: Context): Promise<boolean> {
    try {
      return await bundleManager.isApplicationEnabled(Constant.FILE_APP_PACKAGE_NAME);
    } catch (e) {
      HiLog.warn(TAG, `HmFiles is not exist.`);
      return false;
    }
  }

  /**
   * 获取picker在浏览页/最近页的搜索栏高度
   * */
  public static getHdsBottomBuilderHeight(isOutsideFolded: boolean): number {
    return 0;
  }
}