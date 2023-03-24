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

import fileAccess from '@ohos.file.fileAccess'
import Logger from '../log/Logger'
import abilityAccessCtrl from '@ohos.abilityAccessCtrl'
import { Permissions } from '@ohos.abilityAccessCtrl'
import BundleManager from '@ohos.bundle.bundleManager'
import FileShare from '@ohos.fileshare'
import wantConstant from '@ohos.app.ability.wantConstant'
import ErrorCodeConst from '../constants/ErrorCodeConst'
import MediaLibrary from '@ohos.multimedia.mediaLibrary'

const TAG = 'AbilityCommonUtil'

let mediaLibrary: MediaLibrary.MediaLibrary = null

/**
 * Ability公共工具类
 */
namespace AbilityCommonUtil {

/**
 * 需要用户授权的权限列表
 */
  export const PERMISSION_LIST: Array<Permissions> = [
    "ohos.permission.MEDIA_LOCATION",
    "ohos.permission.READ_MEDIA",
    "ohos.permission.WRITE_MEDIA"
  ]

  /**
   * 用来获取startAbility调用方应用uid的key
   */
  export const CALLER_UID = 'ohos.aafwk.param.callerUid'

  /**
   * 最大选择文件的个数
   */
  export const MAX_FILE_PICK_NUM = 500

  /**
   * picker对外返回的响应码
   */
  export const RESULT_CODE = {
    SUCCESS: 0,
    CANCEL: -1
  }

  export const ABILITY_LIST = {
    FILE_MANAGER: 'FileManagerAbility',
    FILE_PICKER: 'FilePickerAbility',
    PATH_PICKER: 'PathPickerAbility'
  }
  /**
   * 拉起Ability时必要的初始化操作
   */
  export function init(): Promise<void[]> {
    const fileAccessHelperPromise = createFileAccessHelper()
    getMediaLibrary()
    const getRequestPermission = requestPermission()
    return Promise.all([fileAccessHelperPromise, getRequestPermission])
  }

  /**
   * 获取FileAccessHelper，用于获取文件和操作文件
   */
  export function createFileAccessHelper(): Promise<void> {
    if (globalThis.fileAccessHelper) {
      return Promise.resolve()
    }
    return new Promise(async (resolve, reject) => {
      try {
        let wants = await fileAccess.getFileAccessAbilityInfo()
        globalThis.fileAcsHelper = fileAccess.createFileAccessHelper(globalThis.abilityContext, wants)
        // 获取设备根节点信息
        const rootIterator: fileAccess.RootIterator = await globalThis.fileAcsHelper.getRoots()
        let rootInfoArr = []
        let result = rootIterator.next()
        let isDone = result.done
        while (!isDone) {
          const rootInfo: fileAccess.RootInfo = result.value
          Logger.i(TAG, 'RootInfo: ' + rootInfo.uri + ', ' + rootInfo.deviceType + ', ' + rootInfo.deviceFlags + ', ' + rootInfo.displayName)
          rootInfoArr.push(rootInfo)
          result = rootIterator.next()
          isDone = result.done
        }
        globalThis.rootInfoArr = rootInfoArr
      } catch (err) {
        Logger.e(TAG, 'createFileAccessHelper fail, error:' + JSON.stringify(err))
      } finally {
        resolve()
      }
    })
  }

  /**
   * 申请文件管理器需用户授权的权限
   */
  export function requestPermission(): Promise<void> {
    let atManager = abilityAccessCtrl.createAtManager()
    try {
      return atManager.requestPermissionsFromUser(globalThis.abilityContext, PERMISSION_LIST).then((data) => {
        if (data.authResults.some(item => item !== 0)) {
          Logger.e(TAG, 'requestPermissionsFromUser some permission request fail, result:' + JSON.stringify(data))
        } else {
          Logger.i(TAG, 'requestPermissionsFromUser success, result:' + JSON.stringify(data))
        }
      }).catch((error) => {
        Logger.e(TAG, 'requestPermissionsFromUser fail, error:' + JSON.stringify(error))
      })
    } catch (error) {
      Logger.e(TAG, 'requestPermissionsFromUser error occurred, error:' + JSON.stringify(error))
    }
  }

  /**
   * 根据给定的uid获取对应的bundleName
   */
  export function getBundleNameByUid(uid: number): Promise<string> {
    if (!uid && uid !== 0) {
      Logger.e(TAG, `getBundleNameByUid fail, uid is null`)
      return Promise.resolve('')
    }
    try {
      return BundleManager.getBundleNameByUid(uid).then((bundleName) => {
        Logger.i(TAG, `getBundleNameByUid success, uid: ${uid}, bundleName: ${bundleName}`)
        return bundleName
      }).catch(error => {
        Logger.e(TAG, `getBundleNameByUid fail, uid: ${uid}, error: ${JSON.stringify(error)}`)
        return Promise.reject(error)
      })
    } catch (error) {
      Logger.e(TAG, `getBundleNameByUid error, uid: ${uid}, error: ${JSON.stringify(error)}`)
      return Promise.resolve('')
    }
  }
  /**
   * uri授权
   * @param uriList 待授权的uri列表
   * @param bundleName 授权应用的包名
   * @param flag 授权的权限，只读或读写
   */
  export function grantUriPermission(uriList: Array<string>, bundleName: string, flag: wantConstant.Flags): Promise<boolean> {
    return new Promise(async (resolve, reject) => {
      for (let uri of uriList) {
        try {
          await FileShare.grantUriPermission(uri, bundleName, flag)
          if (flag === wantConstant.Flags.FLAG_AUTH_WRITE_URI_PERMISSION) {
            await FileShare.grantUriPermission(uri, bundleName, wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION)
          }
          Logger.d(TAG, `grantUriPermission success, uri: ${uri}`)
        } catch (error) {
          resolve(false)
          Logger.e(TAG, `grantUriPermission fail, uri: ${uri}, error: ${JSON.stringify(error)}`)
          return
        }
        resolve(true)
      }
    })

  }

  /**
   * 文件选择完成，返回uri列表
   * @param resultCode
   * @param result
   * @param message
   */
  export async function terminateFilePicker(result: Array<string> = [], resultCode: number = RESULT_CODE.SUCCESS, message: string = ''): Promise<void> {
    const bundleName = await AbilityCommonUtil.getBundleNameByUid(globalThis.pickerCallerUid)
    if (result.length && bundleName) {
      // uri授权
      const isSuccess = await grantUriPermission(result, bundleName, wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION)
      if (!isSuccess) {
        resultCode = ErrorCodeConst.PICKER.GRANT_URI_PERMISSION_FAIL,
        result = []
        message = 'uri grant permission fail'
      }
    }

    let abilityResult = {
      resultCode: resultCode,
      want: {
        bundleName: globalThis.abilityContext.abilityInfo.bundleName,
        abilityName: ABILITY_LIST.FILE_PICKER,
        parameters: {
          'select_item_list': result,
          message: message
        }
      }
    }
    globalThis.abilityContext.terminateSelfWithResult(abilityResult, (error) => {
      if (error.code) {
        Logger.e(TAG, 'Operation failed. Cause: ' + JSON.stringify(error))
        return
      }
      Logger.d(TAG, 'Operation failed. Cause: ' + JSON.stringify(abilityResult))
    })
  }
  /**
   * 文件创建完成，返回uri列表
   * @param result
   * @param resultCode
   * @param message
   */
  export async function terminatePathPicker(result: Array<string>, resultCode: number = RESULT_CODE.SUCCESS, message: string = ''): Promise<void> {
    const bundleName = await AbilityCommonUtil.getBundleNameByUid(globalThis.pathCallerUid)
    if (result.length && bundleName) {
      // uri授权
      const isSuccess = await grantUriPermission(result, bundleName, wantConstant.Flags.FLAG_AUTH_WRITE_URI_PERMISSION)
      if (!isSuccess) {
        resultCode = ErrorCodeConst.PICKER.GRANT_URI_PERMISSION_FAIL,
        result = []
        message = 'uri grant permission fail'
      }
    }
    let abilityResult = {
      resultCode: resultCode,
      want: {
        bundleName: globalThis.pathAbilityContext.abilityInfo.bundleName,
        abilityName: ABILITY_LIST.PATH_PICKER,
        parameters: {
          'pick_path_return': result,
          'key_pick_select_clouddisk': false,
          'message': message
        }
      }
    }
    globalThis.pathAbilityContext.terminateSelfWithResult(abilityResult, (error) => {
      if (error.code) {
        Logger.e(TAG, 'Operation failed. Cause: ' + JSON.stringify(error))
        return
      }
      Logger.d(TAG, 'Operation failed. Cause: ' + JSON.stringify(abilityResult))
    })
  }

  /**
   * 获取选择文件的最大个数
   * @param num 调用方传入的个数
   */
  export function getPickFileNum(num: number): number {
    if(!num || num > MAX_FILE_PICK_NUM){
      return MAX_FILE_PICK_NUM
    }
    return num
  }

  /**
   * 获取选择文件的类型列表
   * @param keyPickType 调用方传入文件类型（兼容双框架action）
   * @param keyPickTypeList 调用方传入文件类型列表
   */
  export function getKeyPickTypeList(keyPickType, keyPickTypeList): Array<string>{
    let typeList =[]
    if (keyPickType) {
      typeList.push(keyPickType)
    }
    if (keyPickTypeList && keyPickTypeList.length !== 0) {
      typeList = typeList.concat(keyPickTypeList)
    }
    return typeList.filter(item => item)
  }

  /**
   * 获取媒体库对象实例的统一接口
   */
  export function getMediaLibrary(): MediaLibrary.MediaLibrary {
    if (!mediaLibrary) {
      try {
        mediaLibrary = MediaLibrary.getMediaLibrary(globalThis.abilityContext)
      } catch (error) {
        Logger.e(TAG, 'getMediaLibrary fail, error:' + JSON.stringify(error))
      }
    }
    return mediaLibrary
  }

  export function releaseMediaLibrary(): void {
    if (!mediaLibrary) {
      try {
        mediaLibrary.release()
      } catch (error) {
        Logger.e(TAG, 'releaseMediaLibrary fail, error: ' + JSON.stringify(error))
      }
    }
  }
}

export default AbilityCommonUtil
