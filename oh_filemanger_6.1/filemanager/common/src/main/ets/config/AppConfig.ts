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

import { StringUtil } from '../utils/StringUtil';
import { bundleManager, common } from '@kit.AbilityKit';
import { GlobalHolder } from '../global/GlobalHolder';
import { HiLog } from '../dfx/HiLog';
import { Constant } from '../const/Constant';

const TAG = 'AppConfig';
/**
 * 环境枚举
 */
export enum ENV {
  DEVELOP, // 开发
  MIRROR, // 测试
  ONLINE // 现网
}

/**
 * 应用配置信息
 */
export class AppConfig {

  /**
   * 当前环境
   */
  public static readonly CURRENT_ENV: ENV = ENV.ONLINE;

  /**
   * APP ID 镜像环境
   */
  public static readonly APP_ID_MIRROR = '102082119';

  /**
   * APP ID 现网环境
   */
  public static readonly APP_ID_ONLINE = '107130961';

  /**
   * 应用产品名
   */
  public static readonly APP_PRODUCT_NAME = 'HmFileManager';

  /**
   * 产品线
   */
  public static readonly APP_PRODUCT_LINE = 'File Manager';

  /**
   * 应用包名
   */
  public static readonly APP_PACKAGE_NAME = 'com.ohos.filemanager';

  /**
   * Phone应用版本号
   */
  public static readonly APP_VERSION = AppConfig.getAppVersionName();

  /**
   * 双升单应用来源配置信息列表
   */
  public static readonly SOURCE_LIST = 'sourceList';

  /**
   * 包名
   */
  public static readonly BUNDLE_NAME = 'hmos_bundle_name';

  /**
   * 默认排序
   */
  public static readonly DEFAULT_ORDER = 'defaultOrder';

  /**
   * 来源数据对应路径
   */
  public static readonly PATH = 'path';

  /**
   * 默认是否显示
   */
  public static readonly IS_SHOW = 'isShow';

  /**
   * 配置文件对应版本信息
   */
  public static readonly VERSION = 'version';

  /**
   * 双框架来源配置信息
   */
  private static readonly APP_SOURCE_DUAL_ARCH_CFG = 'AppSourceDualArchCfg';

  /**
   * 配置文件
   */
  private static readonly CONFIG_FILE_NAME = 'filemanager_config.json';

  /**
   * 获取应用版本名
   * @returns 应用版本名
   */
  public static getAppVersionName(): string {
    let versionName: string = '0.0.0.0';
    try {
      const bundleInfo: bundleManager.BundleInfo = bundleManager.getBundleInfoSync(Constant.FILE_MANAGER_BUNDLE_NAME,
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO);
      versionName = bundleInfo.versionName;
    } catch (err) {
      // versionName未返回，Hilog中使用的AppConfig.APP_VERSION是无效值，打印日志会造成崩溃，因此修改为默认值
      versionName = '0.0.0.0';
    }
    return versionName;
  }

  /**
   * 获取应用版本号code，如：120101300
   */
  public static getAppVersionCode(): string {
    const vList = AppConfig.APP_VERSION.split('.');
    if (vList.length !== 4) {
      return '';
    }
    return `${vList[0]}${StringUtil.padStart(vList[1])}${StringUtil.padStart(vList[2])}${vList[3]}`;
  }

  /**
   * 判断当前环境是否为现网环境
   */
  public static isOnline(): boolean {
    return AppConfig.CURRENT_ENV === ENV.ONLINE;
  }

  /**
   * 获取APP ID
   */
  public static getAppId(): string {
    if (AppConfig.isOnline()) {
      return AppConfig.APP_ID_ONLINE;
    }
    return AppConfig.APP_ID_MIRROR;
  }

  public static getAppSourceConfig(): object {
    const context: common.Context = GlobalHolder.getInstance().getCommonContext();
    if (context === null) {
      return undefined;
    }
    try {
      let fileContent: Uint8Array = context.resourceManager?.getRawFileContentSync(AppConfig.CONFIG_FILE_NAME);
      let jsonString = StringUtil.uint8ArrayToString(fileContent);
      let jsonResult = JSON.parse(jsonString);
      return jsonResult[AppConfig.APP_SOURCE_DUAL_ARCH_CFG];
    } catch (error) {
      HiLog.error(TAG, 'getAppSourceConfig error:' + JSON.stringify(error));
    }
    return undefined;
  }
}

