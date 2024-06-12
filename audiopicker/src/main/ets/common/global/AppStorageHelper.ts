/*
 * Copyright (c) 2021-2023 Huawei Device Co., Ltd.
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
import { Logger } from '../util/HiLogger'

const logger: Logger = new Logger("AppStorageHelper")

/**
 * [系统全局storage管理类，支持界面绑定]
 *
 * @author
 * @version [V1.0.0.0, 2022/7/20]
 * @since V1.0.0.0
 */
export class AppStorageHelper {
  active: boolean = true
  unhandledMap: Map<string, any> = new Map()
  disable: () => void = () => {
    this.active = false
  }
  enable: () => void = () => {
    this.active = true
    if (!this.unhandledMap.size) {
      return
    }
    this.unhandledMap.forEach((value, key) => {
      setOrCreateAppStorage(key, value)
    })
    this.unhandledMap.clear()
  }
}

// 定义了AppStorage下支持挂载的对象
export const appStorageKeys = {
  // 屏幕宽度 px
  screenWidth: 'screenWidth',
  // 屏幕高度 px
  screenHeight: 'screenHeight',
  // 窗口宽度 px
  windowWidth: 'windowWidth',
  // 窗口高度 px
  windowHeight: 'windowHeight',
  // 顶部状态栏高度 px
  statusBarHeight: 'statusBarHeight',
  // 底部导航栏高度 px
  navigatorBarHeight: 'navigatorBarHeight',
  // 样式单位管理对象
  styleConfig: 'styleConfig',
  // 主题管理对象
  themeConfig: 'themeConfig',
  // 窗口密度模式
  densityType: 'densityType',
  // 设置
  setting: 'setting',
  // 是否可以访问网络
  isInternetConnected: 'isInternetConnected',
  // 当前系统语言
  lang: "lang",
  // 是否是深色主题
  isDarkTheme: "isDarkTheme",
  // 横竖屏切换宽高对象
  windowArea: "windowArea",
  // 全屏模式比例
  appSplitRatio: "appSplitRatio",
  serverEnvironment: "serverEnvironment",
  // 铃声播放状态
  ringTonePlayStatus: "ringTonePlayStatus"
}

/**
 * 创建或者重新设置appstorage
 *
 * @param storageKey key
 * @param object 塞入的对象
 */
export function setOrCreateAppStorage<T>(storageKey: string, object: T): void {
  let globalStore = globalThis.appStorageHelper as AppStorageHelper
  if (globalStore && !globalStore.active) {
    globalStore.unhandledMap.set(storageKey, object)
    return
  }
  if (!appStorageKeys[storageKey]) {
    logger.error(`Cannot Create storage key of ${storageKey}`)
    return
  }
  AppStorage.SetOrCreate<T>(storageKey, object)
}

/**
 * 获取设置过的appstorage
 *
 * @param storageKey key
 * @return storageValue
 */
export function getAppStorage<T>(storageKey: string): T {
  logger.info('getAppStorage' + storageKey)
  if (!appStorageKeys[storageKey]) {
    logger.error(`Cannot getAppStorage storage key of ${storageKey}`)
    return undefined
  }
  return AppStorage.Get<T>(storageKey)
}