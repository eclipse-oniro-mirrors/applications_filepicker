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

import wantConstant from '@ohos.app.ability.wantConstant';
import type Want from '@ohos.app.ability.Want';
import { AppConfig } from '../config/AppConfig';
import { Actions, Constant } from '../const/Constant';
import { HiLog } from '../dfx/HiLog';
import { GlobalHolder } from '../global/GlobalHolder';
import { GlobalKey } from '../global/GlobalKey';
import { CommonPreferenceUtil } from '../preference/CommonPreferenceUtil';
import { ArrayUtil } from './ArrayUtil';
import { ObjectUtil } from './ObjectUtil';
import { UsageHabitsPreferenceUtil } from '../preference/UsageHabitsPreferenceUtil';
import { StartOptions } from '@kit.AbilityKit';
import { StartModeOptions } from '../model/StartModeOptions';
import { FilePickerUtil } from '../etsexport/utils/FilePickerUtil';
import { StringUtil } from './StringUtil';
import { toast } from './Tools';
import { HiSysEventUtil } from '../dfx/HiSysEventUtil';
import { UEUtil } from '../dfx/UEUtil';
import { DFX } from '../dfx/const/DFXConst';
import { PreferenceConst } from '../const/PreferenceConst';
import { CommonPreference } from '../preference/CommonPreference';
import { FsUtil } from './FsUtil';
import { BasePreference } from '../preference/BasePreference';
import { CommonUtil } from './CommonUtil';

const TAG = 'AbilityCommonUtil';
const APP_NOT_EXIST_ERROR_CODE: number = 16000001;

const PHOTOS: string = 'photos';

const SOUND_RECORDER: string = 'sound_recorder';
// 拉起设置进入设置存储的uri
const SETTING_URI: string = 'settings://storage_manager';

/**
 * Ability公共工具类
 */
export namespace AbilityCommonUtil {

  /**
   * 用来获取startAbility调用方应用uid的key
   */
  export const CALLER_UID = 'ohos.aafwk.param.callerUid';

  /**
   * 用来获取startAbility调用方应用的bundleName
   */
  export const CALLER_BUNDLE_NAME = 'ohos.aafwk.param.callerBundleName';

  /**
   * 用来获取startAbility调用方应用的pid
   */
  export const CALLER_PID = 'ohos.aafwk.param.callerPid';

  /**
   * 调用方token
   */
  export const CALLER_TOKEN = 'ohos.aafwk.param.callerToken';

  /**
   * 调用方分身id
   */
  export const CALLER_APP_CLONE_INDEX = 'ohos.param.callerAppCloneIndex';

  export const UDKEY = 'ability.want.params.udKey';

  /**
   * 最大选择文件的个数
   */
  export const MAX_FILE_PICK_NUM = 500;

  /**
   * 后缀最大长度,包括'.'
   */
  export const SUFFIX_MAX_LENGTH: number = 255;

  /**
   * 三方传入的后缀数组长度最大100
   */
  export const SUFFIX_LIST_MAX_LENGTH: number = 100;

  /**
   * picker对外返回的响应码
   */
  export enum ResultCodePicker {
    SUCCESS = 0,
    CANCEL = -1
  }

  /**
   * 用来获取文件可卸载应用版本号
   */
  export const HMFILES_APP_VERSION = 'HmFiles.appVersion';

  export enum AbilityList {
    FILE_MANAGER = 'MainAbility',
    FILE_PICKER = 'FilePickerAbility',
    PATH_PICKER = 'PathPickerAbility',
    PATH_EXT = 'PickerServiceExtAbility'
  }

  /**
   * 拉起Ability时必要的初始化操作
   */
  export function init(startModeOptions: StartModeOptions | undefined = undefined): Promise<void[]> {
    let isPickerFlag: boolean = startModeOptions?.pickerFlag ?? false;
    const usageHabitsPromise = UsageHabitsPreferenceUtil.loadingUsageHabits(isPickerFlag);
    const defaultTabPromise = CommonPreferenceUtil.getDefaultTabIndex();
    const lastSelectFolderUriPromise = CommonPreferenceUtil.getLastSelectFolderUri();
    const loadNewFeatureGuideState = CommonPreferenceUtil.loadNewFeatureGuideState();
    const loadCacheDataRemoveTipClosedState = CommonPreferenceUtil.loadCacheDataRemoveTipClosedState();
    const loadAppGuidanceState = CommonPreferenceUtil.loadAppGuidanceState();
    return Promise.all([usageHabitsPromise, defaultTabPromise, lastSelectFolderUriPromise, loadNewFeatureGuideState,
      loadCacheDataRemoveTipClosedState, loadAppGuidanceState]);
  }

  export function toSettingPermission(): void {
    let wantInfo: Want = {
      action: Actions.SETTING_APP_INFO,
      // 打开指定应用的详情页面
      parameters: {
        settingsParamBundleName: AppConfig.APP_PACKAGE_NAME
      }
    };
    GlobalHolder.getInstance()
      .getMainAbilityContext()
      .startAbility(wantInfo)
      .then(() => {
        HiLog.info(TAG, 'start settings');
      })
      .catch((err: Error) => {
        HiLog.error(TAG, 'start settings error: ' + JSON.stringify(err));
      });
  }

  /**
   * 文件创建完成，返回uri列表
   * @param result
   * @param resultCode
   * @param message
   */
  export async function terminatePathPicker(result: string[],
    resultCode: number = ResultCodePicker.SUCCESS, startModeOptions: StartModeOptions): Promise<void> {
    if (GlobalHolder.getInstance().getObject<boolean>(GlobalKey.PICKER_EXTENSION)) {
      const destroyFun = GlobalHolder.getInstance().getObject<(
        data: Array<string>, resultCode: number, message: string) => void>(GlobalKey.PICKER_ON_DESTROY);
      destroyFun(result, resultCode, '');
      return;
    }
    if (result && result.length > 0) {
      // 上报记录
      try {
        let bundleName = startModeOptions.callerBundleName;
        await FilePickerUtil.grantPhonePermissionUrisWithRecords(result, bundleName, true, true);
      } catch (err) {
        HiLog.error(TAG, 'grantPhonePermissionUri failed with errCode: ' + err.code);
      }
    }
    let flag = wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION |
    wantConstant.Flags.FLAG_AUTH_WRITE_URI_PERMISSION | wantConstant.Flags.FLAG_AUTH_PERSISTABLE_URI_PERMISSION;
    HiLog.info(TAG, 'enter terminatePathPicker, result length： ' + result.length + ', resultCode:' + resultCode);
    if (resultCode === ResultCodePicker.SUCCESS) {
      UEUtil.reportPickerOper(DFX.PickerMode.PATH_PICKER, result.length, startModeOptions.callerBundleName);
    }
    let want: Want = {
      bundleName: Constant.FILE_MANAGER_BUNDLE_NAME,
      abilityName: AbilityList.PATH_PICKER,
      flags: flag,
      parameters: {
        'ability.params.stream': result,
        KEY_PICK_SELECT_CLOUD_DISK: false
      }
    };
    FilePickerUtil.returnAbilityResult(want, resultCode, startModeOptions);
  }

  /**
   * 获取选择文件的最大个数
   * @param num 调用方传入的个数
   */
  export function getPickFileNum(num: object): number {
    if (typeof num === 'number') {
      if ((num > 0) && (num <= MAX_FILE_PICK_NUM)) {
        return num;
      }
    }
    return MAX_FILE_PICK_NUM;
  }

  /**
   * 获取选择文件的类型列表
   * @param keyPickType 调用方传入文件类型（兼容双框架action）
   * @param keyPickTypeList 调用方传入文件类型列表
   */
  export function getKeyPickTypeList(keyPickType: object, keyPickTypeList: object): string[] {
    let typeList: string[] = [];
    if (keyPickType) {
      typeList.push(String(keyPickType));
    }
    if (keyPickTypeList && (keyPickTypeList instanceof Array) && (keyPickTypeList.length !== 0)) {
      typeList = typeList.concat(keyPickTypeList);
    }
    return typeList.filter(item => item);
  }

  /**
   * 获取支持的文件后缀列表
   * @param keyFileSuffixFilter 调用方传入文件后缀列表
   */
  export function getKeyFileSuffixFilter(keyFileSuffixFilter: string[]): string[] {
    let suffixList: string[] = [];
    if (!ArrayUtil.isEmpty(keyFileSuffixFilter)) {
      let len = keyFileSuffixFilter.length;
      let size = len > SUFFIX_LIST_MAX_LENGTH ? SUFFIX_LIST_MAX_LENGTH : len;
      for (let index = 0; index < size; index++) {
        const suffixStr = keyFileSuffixFilter[index];
        if (typeof suffixStr === 'string') {
          const suffixArray = suffixStr.split(Constant.FILE_SUFFIX.SUFFIX_SPLIT);
          for (let index = 0; index < suffixArray.length; index++) {
            const suffix = suffixArray[index];
            if (checkFileSuffix(suffix)) {
              suffixList.push(suffix.toUpperCase());
            }
          }
        }
      }
    }
    return suffixList.filter((item, index, array) => {
      return array.indexOf(item) === index;
    });
  }

  export function checkFileSuffix(fileSuffix: string): boolean {
    return fileSuffix.length > 0 && fileSuffix.length <= SUFFIX_MAX_LENGTH;
  }

  /**
   * 路径选择器获取支持的文件后缀，只支持获取第一个文件后缀
   * @param keyFileSuffixChoices 调用方传入文件后缀列表
   */
  export function getKeyFileSuffixChoices(keyFileSuffixChoices: string[]): string {
    if (!ArrayUtil.isEmpty(keyFileSuffixChoices)) {
      let len = keyFileSuffixChoices.length;
      let size = len > SUFFIX_LIST_MAX_LENGTH ? SUFFIX_LIST_MAX_LENGTH : len;
      for (let index = 0; index < size; index++) {
        const suffixStr = keyFileSuffixChoices[index];
        if (typeof suffixStr === 'string') {
          const suffixArray = suffixStr.split(Constant.FILE_SUFFIX.SUFFIX_SPLIT);
          for (let index = 0; index < suffixArray.length; index++) {
            const suffix = suffixArray[index];
            if (checkFileSuffix(suffix)) {
              return suffix;
            }
          }
        }
      }
    }
    return '';
  }

  /**
   * 拉起图库
   */
  export function startGalleryAbilityFromPc(reqFromFileMgr: string = ''): boolean {
    try {
      const want = getStartGalleryAbilityWant(reqFromFileMgr);
      GlobalHolder.getInstance().getMainAbilityContext().startAbilityForResult(want);
    } catch (error) {
      HiLog.error(TAG, `startGalleryAbility fail, error: ${error}`);
      return false;
    }
    return true;
  }

  /**
   * 拉起图库
   */
  export async function startGalleryAbilityFromPhone(
    sourceFrom: string = '', reqFromFileMgr: string = ''): Promise<boolean> {
    try {
      HiLog.info(TAG, `startGalleryAbility reqFromFileMgR: ${reqFromFileMgr}`);
      const want = getStartGalleryAbilityWant(reqFromFileMgr);
      const context =
        GlobalHolder.getInstance().getUIExtensionContext() || GlobalHolder.getInstance().getMainAbilityContext();
      if (ObjectUtil.isNullOrUndefined(context)) {
        HiLog.error(TAG, 'startGalleryAbility fail, context is null or undefined');
        return false;
      }
      await context.startAbility(want, { windowMode: Constant.WINDOW_DISPLAY_MODE.FULL_SCREEN });
      HiSysEventUtil.reportOpenOtherApp(PHOTOS, sourceFrom, reqFromFileMgr, true);
    } catch (error) {
      HiLog.error(TAG, `startGalleryAbility fail, error: ${error}`);
      HiSysEventUtil.reportOpenOtherApp(PHOTOS, sourceFrom, reqFromFileMgr, false, error?.code);
      return false;
    }
    return true;
  }

  /**
   * Tips拉起图库
   */
  export async function startGalleryAbilityFromTips(
    sourceFrom: string = '', reqFromFileMgr: string = ''): Promise<boolean> {
    try {
      HiLog.info(TAG, `startGalleryAbility reqFromFileMgR: ${reqFromFileMgr}`);
      const want = getStartGalleryAbilityWant(reqFromFileMgr);
      const context =
        GlobalHolder.getInstance().getUIExtensionContext() || GlobalHolder.getInstance().getMainAbilityContext();
      await context.startAbility(want);
      HiSysEventUtil.reportOpenOtherApp(PHOTOS, sourceFrom, reqFromFileMgr, true);
    } catch (error) {
      HiLog.error(TAG, `startGalleryAbility fail, error.code: ${error?.code} error.message: ${error?.message}`);
      HiSysEventUtil.reportOpenOtherApp(PHOTOS, sourceFrom, reqFromFileMgr, false, error?.code);
      return false;
    }
    return true;
  }

  function getStartGalleryAbilityWant(reqFromFileMgr: string = ''): Want {
    return StringUtil.isEmpty(reqFromFileMgr) ? {
      bundleName: Constant.GALLERY_BUNDLE_NAME,
      abilityName: Constant.GALLERY_BUNDLE_NAME + '.MainAbility',
    } : {
      parameters: {
        uri: 'fileManager',
        reqFromFileMgr: reqFromFileMgr
      },
      bundleName: Constant.GALLERY_BUNDLE_NAME,
      abilityName: Constant.GALLERY_BUNDLE_NAME + '.MainAbility',
    };
  }

  /**
   * 拉起录音机
   */
  export async function startSoundRecorderAbility(sourceFrom: string = '') {
    try {
      const want: Want = {
        bundleName: Constant.SOUND_RECORD_BUNDLE_NAME,
        abilityName: 'MainAbility',
      };
      const context =
        GlobalHolder.getInstance().getUIExtensionContext() || GlobalHolder.getInstance().getMainAbilityContext();
      await context.startAbility(want);
      HiSysEventUtil.reportOpenOtherApp(SOUND_RECORDER, sourceFrom, 'MainAbility', true);
    } catch (err) {
      HiLog.error(TAG, `startSoundRecorderAbility error: ${JSON.stringify(err)}`);
      HiSysEventUtil.reportOpenOtherApp(SOUND_RECORDER, sourceFrom, 'MainAbility', false, err?.code);
      if (err?.code === APP_NOT_EXIST_ERROR_CODE) {
        toast($r('app.string.sound_recorder_not_exist'));
      }
    }
  }

  /**
   * 拉起设置-存储
   */
  export function startSettingsAbility() {
    try {
      const want: Want = {
        bundleName: Constant.SETTING_BUNDLE_NAME,
        abilityName: `${Constant.SETTING_BUNDLE_NAME}.MainAbility`,
        uri: SETTING_URI
      };
      const context = GlobalHolder.getInstance().getUIExtensionContext();
      context.startAbility(want);
    } catch (err) {
      HiLog.error(TAG, `startSettingsAbility error: ${JSON.stringify(err)}`);
    }
  }

  export function getFileDefaultPickPath(startModeOptions: StartModeOptions): string {
    let defaultDir: string = startModeOptions.defaultFilePathUri;
    return ObjectUtil.isNullOrUndefined(defaultDir) ? '' : defaultDir;
  }

  export function getFilePickerViewFlag(startModeOptions: StartModeOptions): boolean {
    let pickerFlag: boolean = startModeOptions.pickerFlag;
    return ObjectUtil.isNullOrUndefined(pickerFlag) ? false : pickerFlag;
  }

  export function getFileSuffixChoices(startModeOptions: StartModeOptions): string {
    let suffix: string = startModeOptions.PhoneFileSuffixChoices;
    return ObjectUtil.isNullOrUndefined(suffix) ? '' : suffix;
  }

  export function getPathDefaultPickDir(startModeOptions: StartModeOptions): string {
    let defaultDir: string = startModeOptions.defaultFilePathUri;
    return ObjectUtil.isNullOrUndefined(defaultDir) ? '' : defaultDir;
  }
}

export default AbilityCommonUtil
