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

import hilog from '@ohos.hilog';
import { AppConfig } from '../config/AppConfig';
// import { LOG, Logger as PafLogger, LogLevel, PafLogNode } from '@hw-hmf/logger';
import { appManager, common } from '@kit.AbilityKit';
import { process } from '@kit.ArkTS';
import fs from '@ohos.file.fs';

const TAG = 'LoggerHelper';
const LOG_BYTES_PER_FILE = 2048; // 落盘单文件大小，单位KB
const APP_TAG = 'FileMgr';

export class HiLog {
  /**
   * Service Domain
   */
  public static readonly LOG_DOMAIN = 0xf666;
  public static readonly LOG_DIR: string = '/pafLog';
  public static logPath: string = '';
  // 不同ability保存日志大小限制，获取日志，上限为100M，考虑给服务预留30M
  // 单次操作场景，日志比例：克隆:大文件清理:  1:2:4
  // 当前仅将这几个模块日志打印到沙箱，后续其他模块，根据舆情扩展
  public static readonly abilityLogSize: Map<string, number> = new Map<string, number>([
    ['commonUI', 20], // 文管主进程
    ['filePicker', 10], // picker进程
    ['backup', 2] // 升级克隆
  ]);

  static async init(context: common.Context): Promise<void> {
    HiLog.info(TAG, 'init Logger start');
    if (!context) {
      HiLog.warn(TAG, 'init Logger failed, context is empty.');
      return;
    }
    if (!context.filesDir) {
      HiLog.warn(TAG, 'init Logger failed, path is empty.');
      return;
    }
    const logDir: string = context.filesDir + HiLog.LOG_DIR;
    const logTotaleLimit: number = await HiLog.getAppendProcessNameSize();
    HiLog.warn(TAG, `log limit size: ${logTotaleLimit}`);
    if (logTotaleLimit < 0) { // 仅指定模块将日志打印到问题建议
      return;
    }
    const createDirAsyncRes: boolean = await HiLog.createDirAsync(logDir);
    if (!createDirAsyncRes) {
      HiLog.warn(TAG, `init Logger failed, createDirAsyncRes：${createDirAsyncRes}`);
      return;
    }
    HiLog.logPath = logDir;
  }

  // 调用日志落盘
  public static logFlush(): void {
    // LOG.flush();
  }

  // 根据进程名称获取日志大小限制，只有指定模块进行日志打印
  public static async getAppendProcessNameSize(): Promise<number> {
    let logSize: number = -1;
    try {
      const infos = await appManager.getRunningProcessInformation();
      const currentProccessInfo = infos.find((info) => info.pid === process.pid);
      HiLog.warn(TAG, `app processName: ${currentProccessInfo?.processName}`);
      if (!currentProccessInfo?.processName) {
        return logSize;
      }

      for (let key of HiLog.abilityLogSize.keys()) {
        if (currentProccessInfo.processName.includes(key)) {
          logSize = HiLog.abilityLogSize.get(key)?? -1;
        }
      }
    } catch (e) {
      HiLog.error(TAG, `appendProcessNameToDir error`);
    }
    return logSize;
  }

  // 异步创建文件路径，paflog初始化需要确保日志文件已存在
  public static async createDirAsync(dir: string): Promise<boolean> {
    let isDirExist = false;
    try {
      isDirExist = await fs.access(dir);
    } catch (e) {
      HiLog.warn(TAG, `createDirAsync access error code:${e?.code} message:${e?.message}`);
    }
    if (isDirExist) {
      return true;
    }
    try {
      await fs.mkdir(dir, true);
      return true;
    } catch (e) {
      HiLog.error(TAG, `createDirAsync mkdir error code:${e?.code} message:${e?.message}`);
      return false;
    }
  }

  /**
   * 打印 Debug 日志
   * @param tag 日志Tag
   * @param message 打印信息
   */
  public static debug(tag: string, message: string, ...args: ESObject[]): void {
    // LOG.d(`${AppConfig.APP_VERSION}`, `${tag}:${message} %s`, args);
    hilog.debug(HiLog.LOG_DOMAIN, `${APP_TAG}:${tag}`, '%{public}s', message, args);
  }

  /**
   * 打印 Info 日志
   * @param tag 日志Tag
   * @param message 打印信息
   */
  public static info(tag: string, message: string, ...args: ESObject[]): void {
    // LOG.i(`${AppConfig.APP_VERSION}`, `${tag}:${message} %s`, args);
    hilog.info(HiLog.LOG_DOMAIN, `${APP_TAG}:${tag}`, '%{public}s', message, args);
  }

  /**
   * 打印 Warn 日志
   * @param tag 日志Tag
   * @param message 打印信息
   */
  public static warn(tag: string, message: string, ...args: ESObject[]): void {
    // LOG.w(`${AppConfig.APP_VERSION}`, `${tag}:${message} %s`, args);
    hilog.warn(HiLog.LOG_DOMAIN, `${APP_TAG}:${tag}`, '%{public}s', message, args);
  }

  /**
   * 打印 Error 日志
   * @param tag 日志Tag
   * @param message 打印信息
   */
  public static error(tag: string, message: string, ...args: ESObject[]): void {
    // LOG.e(`${AppConfig.APP_VERSION}`, `${tag}:${message} %s`, args);
    hilog.error(HiLog.LOG_DOMAIN, `${APP_TAG}:${tag}`, '%{public}s', message, args);
  }

  /**
   * 打印 Fatal 日志
   * @param tag 日志Tag
   * @param message 打印信息
   */
  public static fatal(tag: string, message: string, ...args: ESObject[]): void {
    // LOG.f(`${AppConfig.APP_VERSION}`, `${tag}:${message} %s`, args);
    hilog.fatal(HiLog.LOG_DOMAIN, `${APP_TAG}:${tag}`, '%{public}s', message, args);
  }

  /**
   * 打印 private debug 日志, 适用于带隐私参数
   * @param tag 日志Tag
   * @param message 打印信息
   */
  public static debugPrivate(tag: string, publicMessage: string, privateMessage: string, ...args: ESObject[]): void {
    // LOG.d(`${AppConfig.APP_VERSION}`, `${tag}:${publicMessage}`);
    hilog.debug(HiLog.LOG_DOMAIN, `${APP_TAG}:${tag}`, '%{public}s %{private}s', publicMessage, privateMessage, args);
  }

  /**
   * 打印 private Info 日志, 适用于带隐私参数
   * @param tag 日志Tag
   * @param message 打印信息
   */
  public static infoPrivate(tag: string, publicMessage: string, privateMessage: string, ...args: ESObject[]): void {
    // LOG.i(`${AppConfig.APP_VERSION}`, `${tag}:${publicMessage}`);
    hilog.info(HiLog.LOG_DOMAIN, `${APP_TAG}:${tag}`, '%{public}s %{private}s', publicMessage, privateMessage, args);
  }

  /**
   * 打印 private warn 日志, 适用于带隐私参数
   * @param tag 日志Tag
   * @param message 打印信息
   */
  public static warnPrivate(tag: string, publicMessage: string, privateMessage: string, ...args: ESObject[]): void {
    // LOG.w(`${AppConfig.APP_VERSION}`, `${tag}:${publicMessage}`);
    hilog.warn(HiLog.LOG_DOMAIN, `${APP_TAG}:${tag}`, '%{public}s %{private}s', publicMessage, privateMessage, args);
  }

  /**
   * 打印 private error 日志, 适用于带隐私参数
   * @param tag 日志Tag
   * @param message 打印信息
   */
  public static errorPrivate(tag: string, publicMessage: string, privateMessage: string, ...args: ESObject[]): void {
    // LOG.e(`${AppConfig.APP_VERSION}`, `${tag}:${publicMessage}`);
    hilog.error(HiLog.LOG_DOMAIN, `${APP_TAG}:${tag}`, '%{public}s %{private}s', publicMessage, privateMessage, args);
  }

  /**
   * 打印 private fatal 日志, 适用于带隐私参数
   * @param tag 日志Tag
   * @param message 打印信息
   */
  public static fatalPrivate(tag: string, publicMessage: string, privateMessage: string, ...args: ESObject[]): void {
    // LOG.f(`${AppConfig.APP_VERSION}`, `${tag}:${publicMessage}`);
    hilog.fatal(HiLog.LOG_DOMAIN, `${APP_TAG}:${tag}`, '%{public}s %{private}s', publicMessage, privateMessage, args);
  }
}