/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2015-2022. All rights reserved.
 */

import dataPreferences from '@ohos.data.preferences'
import Logger from '../log/Logger'

const TAG = 'PreferencesUtil'

export const getPreferences = (preferenceName: string) => {
  return dataPreferences.getPreferences(globalThis.abilityContext, preferenceName)
}

export const deletePreferences = (preferenceName: string) => {
  return dataPreferences.deletePreferences(globalThis.abilityContext, preferenceName)
}

export const removePreferencesFromCache = (preferenceName: string) => {
  return dataPreferences.removePreferencesFromCache(globalThis.abilityContext, preferenceName)
}

export const setPreferencesValue = (name: string, key: string, newVal) => {
  return getPreferences(name).then(async preferences => {
    await preferences.put(key, newVal)
    await preferences.flush()
  }).catch(err => {
    Logger.e(TAG, 'setPreferencesValue error: ' + JSON.stringify(err))
  })
}
