/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import data_preferences from '@ohos.data.preferences';
import { Logger } from '../util/HiLogger'

const logger: Logger = new Logger("PreferenceManager")

// store:通用，setting:应用全局配置，music_key_sp:工作秘钥缓存，music_info_sp:用户信息缓存
const preferKeys = ['store', 'setting', 'server_config', 'music_key_sp', 'user_info_sp']

/**
 * [系统全局SP管理类]
 *
 * @version [V1.0.0.0, 2022/7/20]
 * @since V1.0.0.0
 */
export class PreferenceManager {
  preferenceMap: Map<string, Promise<data_preferences.Preferences>> = new Map()
  preferKeys: any = {
    store: 'store',
    setting: 'setting',
    serverConfig: 'server_config',
    encrypt: 'music_key_sp',
    userInfo: 'user_info_sp'
  }
  context: any

  constructor(context: any) {
    this.context = context
    this.init()
  }

  init(): void {
    logger.info('init')
    preferKeys.forEach((item: string) => {
      let promise: Promise<data_preferences.Preferences> = data_preferences.getPreferences(this.context, item)
      this.preferenceMap.set(item, promise)
    })
  }


  /**
   * 获取storeName中的键值对
   *
   * @param keyName keyName
   * @param def def
   * @param storeName storeName
   * @return Promise<any>
   */
  get(keyName: string, def: number | string | boolean, storeName?: string): Promise<number | string | boolean> {
    if (!storeName) {
      storeName = preferKeys[0]
    }
    let promise: Promise<data_preferences.Preferences> = this.preferenceMap.get(storeName)
    if (!promise) {
      logger.error(`Can not get value of ${keyName} from ${storeName}`)
      return new Promise((resolve, reject) => {
        resolve(false)
      })
    }
    return new Promise((resolve, reject) => {
      promise.then((preferences: data_preferences.Preferences) => {
        let keyPromise = preferences.get(keyName, def)
        keyPromise.then((value: number | string | boolean) => {
          logger.info(`Get value of ${keyName} from ${storeName} is ${value}`)
          resolve(value)
        }).catch((err) => {
          logger.info(`Get value of ${keyName} from ${storeName} startup failed, err: ` + err)
          resolve(false)
        })
      }).catch((err) => {
        logger.info(`Get value of ${keyName} from ${storeName} startup failed, err: ` + err)
        resolve(false)
      })
    })
  }


  /**
   * 存储storeName中的键值对
   *
   * @param keyName keyName
   * @param def def
   * @param storeName storeName
   * @return Promise<boolean> 成功失败
   */
  put(keyName: string, def: any, autoFlush: boolean = true, storeName?: string): Promise<boolean> {
    if (!storeName) {
      storeName = preferKeys[0]
    }
    let promise: Promise<data_preferences.Preferences> = this.preferenceMap.get(storeName)
    if (!promise) {
      logger.error(`Can not put value of ${keyName} from ${storeName}`)
      return new Promise((resolve, reject) => {
        resolve(false)
      })
    }
    return new Promise((resolve, reject) => {
      promise.then((preferences: data_preferences.Preferences) => {
        let keyPromise = preferences.put(keyName, def)
        keyPromise.then(() => {
          if (autoFlush) {
            let flushPromise = preferences.flush()
            flushPromise.then(() => {
              resolve(true)
            }).catch((err) => {
              logger.info("Flush to file failed, err: " + err)
              resolve(false)
            })
          } else {
            resolve(true)
          }
        }).catch((err) => {
          logger.info(`Get value of ${keyName} from ${storeName} startup failed, err: ` + err)
          resolve(false)
        })
      }).catch((err) => {
        logger.info(`Get value of ${keyName} from ${storeName} startup failed, err: ` + err)
        resolve(false)
      })
    })
  }
}