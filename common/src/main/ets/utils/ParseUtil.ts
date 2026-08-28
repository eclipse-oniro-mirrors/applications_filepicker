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
import { StringUtil } from './StringUtil';
import { bundleManager } from '@kit.AbilityKit';

const TAG = 'ParseUtil';

// 分身应用包名前缀 带'+'符号
const CLONE_APP_PREFIX_WITH_PLUS = '+clone-';

/**
 * 字符串转换类型工具类
 */
export class ParseUtil {

/**
 * Json格式字符串转换成对应类型
 * @param str json字符串
 * @return string
 */
  public static jsonParse<T>(input: string): T | undefined {
    try {
      return JSON.parse(input) as T;
    } catch (err) {
      HiLog.error(TAG, 'jsonParse error: ' + err.toString());
      return undefined;
    }
  }

  public static getAppCloneIdentity(cloneBundleName: string): bundleManager.AppCloneIdentity | undefined {
    let res: bundleManager.AppCloneIdentity | undefined = undefined;
    if (StringUtil.isEmpty(cloneBundleName)) {
      return res;
    }
    try {
      res = bundleManager.getAppCloneIdentityBySandboxDataDir(cloneBundleName);
    } catch (error) {
      HiLog.warn(TAG, `getAppCloneIdentity error ${JSON.stringify(error)}`);
    }
    return res;
  }

  public static getCloneIndex(cloneBundleName: string): number {
    HiLog.info(TAG, `getCloneIndex start, cloneBundleName ${cloneBundleName}`);
    let appIndex = 0; // 默认为主应用，id为0
    if (StringUtil.isEmpty(cloneBundleName)) {
      return appIndex;
    }
    try {
      const res: bundleManager.AppCloneIdentity = bundleManager.getAppCloneIdentityBySandboxDataDir(cloneBundleName);
      appIndex = res.appIndex;
    } catch (error) {
      HiLog.warn(TAG, `getCloneIndex error ${JSON.stringify(error)}`);
    }
    HiLog.info(TAG, `getCloneIndex end, appIndex : ${appIndex}`);
    return appIndex;
  }

  public static getCloneBundleName(cloneBundleName: string): string {
    HiLog.info(TAG, `getCloneBundleName start, cloneBundleName ${cloneBundleName}`);
    let bundleName = cloneBundleName;
    if (StringUtil.isEmpty(bundleName)) {
      return cloneBundleName;
    }
    try {
      const res: bundleManager.AppCloneIdentity = bundleManager.getAppCloneIdentityBySandboxDataDir(cloneBundleName);
      bundleName = res.bundleName;
    } catch (error) {
      HiLog.warn(TAG, `getCloneBundleName error ${JSON.stringify(error)}`);
    }
    HiLog.info(TAG, `getCloneBundleName end, bundleName : ${bundleName}`);
    return bundleName;
  }

  public static getSandboxDataDir(bundleName: string, appIndex: number): string {
    let dataDir: string = '';
    if (StringUtil.isEmpty(bundleName)) {
      HiLog.info(TAG, 'getSandboxDataDir bundleName is null or undefined');
      return dataDir;
    }
    try {
      dataDir = bundleManager.getSandboxDataDir(bundleName, appIndex);
    } catch (error) {
      HiLog.warn(TAG, `getSandboxDataDir error ${JSON.stringify(error)}`);
    }
    HiLog.info(TAG, `getSandboxDataDir bundleName : ${bundleName} appIndex : ${appIndex} dataDir : ${dataDir}`);
    return dataDir;
  }

  public static isCloneBundleName(bundleName: string): boolean {
    if (!StringUtil.isEmpty(bundleName) && bundleName.startsWith(CLONE_APP_PREFIX_WITH_PLUS)) {
      return true;
    }
    return false;
  }
}