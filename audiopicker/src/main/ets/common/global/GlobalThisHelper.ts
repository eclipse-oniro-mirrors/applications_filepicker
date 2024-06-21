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

import { Logger } from "../util/HiLogger"

/**
 * [系统全局globalThis管理类，挂载全局变量]
 *
 * @author
 * @version [V1.0.0.0, 2022/7/20]
 * @since V1.0.0.0
 */

const logger: Logger = new Logger("GlobalHelper")

// 支持注册的全局对象名称
export const globalKeys = {
  // 全局设备属性对象
  deviceInfo: 'deviceInfo',
  // ability对象
  app: 'app',
  // sp管理对象
  preferenceManager: 'preferenceManager',
  // 安全提示
  audioPickerPreference: 'audioPickerPreference'
}

/**
 * 设置或者已经创建就返回全局的global对象
 *
 * @param objectClass 类型
 * @param storageKey key
 * @param params 参数数组
 * @return storageObject
 */
export function createOrGet<T>(objectClass: { new(...params: any[]): T }, storageKey: string, params?: any[]): T {
  if (!globalKeys[storageKey]) {
    logger.error(`Cannot create key of ${storageKey}`)
    return undefined
  }
  if (!globalThis[storageKey]) {
    if (params) {
      globalThis[storageKey] = new objectClass(...params)
    } else {
      globalThis[storageKey] = new objectClass()
    }
    logger.info(`Create key of ${storageKey}${JSON.stringify(params)}`)
  }
  return globalThis[storageKey]
}

/**
 * 设置并返回全局的global对象
 *
 * @param objectClass 类型
 * @param storageKey key
 * @param params 参数数组
 * @return storageObject
 */
export function create<T>(objectClass: { new(...params: any[]): T }, storageKey: string, params?: any[]): T {
  if (!globalKeys[storageKey]) {
    logger.error(`Cannot create key of ${storageKey}`)
    return undefined
  }
  if (params) {
    globalThis[storageKey] = new objectClass(...params)
  } else {
    globalThis[storageKey] = new objectClass()
  }
  logger.info(`Create key of ${storageKey}${JSON.stringify(params)}`)
  return globalThis[storageKey]
}

/**
 * 设置全局的global对象
 *
 * @param object 类型
 * @param storageKey key
 * @return storageObject
 */
export function setGlobalObj<T>(object: T, storageKey: string): T {
  globalThis[storageKey] = object;
  logger.info(`Set key of ${storageKey}`)
  return globalThis[storageKey]
}

/**
 * 删除全局的global对象
 *
 * @param storageKey key
 */
export function delGlobalObj(storageKey: string): void {
  if (!globalKeys[storageKey]) {
    logger.error(`Cannot set key of ${storageKey}`)
    return
  }
  logger.info(`delGlobalObj key of ${storageKey}`)
  delete globalThis[storageKey]
}

/**
 * 获取设置过的global对象
 *
 * @param object 类型
 * @param storageKey key
 * @return storageObject
 */
export function getGlobalObj<T>(storageKey: string): T {
  if (!globalKeys[storageKey]) {
    logger.error(`Cannot get key of ${storageKey}`)
    return undefined
  }
  return globalThis[storageKey]
}
