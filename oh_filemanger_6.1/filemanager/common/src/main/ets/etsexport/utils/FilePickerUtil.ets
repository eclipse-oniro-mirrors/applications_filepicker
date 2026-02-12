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

import { FileAuthorityUtil } from '../../utils/FileAuthorityUtil';
import { FileInfo } from '../../fileoperate/FileInfo';
import { WindowType } from '../../const/FilePickerItems';
import { HiLog } from '../../dfx/HiLog';
import ctx from '@ohos.app.ability.common';
import wantConstant from '@ohos.app.ability.wantConstant';
import Want from '@ohos.app.ability.Want';
import lazy { dialogRequest } from '../../../../../indexLazyLoad';
import window from '@ohos.window';
import { BusinessError } from '@ohos.base';
import { FileAccessUtil } from '../../fileoperate/FileAccessUtil';
import { UIContext } from '@ohos.arkui.UIContext';
import { Constant, SELECT_MODE } from '../../const/Constant';
import { StartModeOptions } from '../../model/StartModeOptions';
import { FileUtil } from '../../fileoperate/FileUtil';
import { ability, common, uriPermissionManager } from '@kit.AbilityKit';
import AbilityCommonUtil from '../../utils/AbilityCommonUtil';
import { AssertExtUtil } from '../../utils/AssertExtUtil';
import { ObjectUtil } from '../../utils/ObjectUtil';
import FileMimeTypeUtil from '../../utils/FileMimeTypeUtil';
import { FileUriUtil } from '../../fileoperate/FileUriUtil';
import { ApplicationThemeColor } from '../../model/ApplicationThemeColor';
import { unifiedDataChannel, uniformDataStruct, uniformTypeDescriptor } from '@kit.ArkData';
import { StringUtil } from '../../utils/StringUtil';
import { ArrayUtil } from '../../utils/ArrayUtil';

interface abilityResultInterface {
  want: Want,
  resultCode: number
};

const TAG = 'FilePickerUtil';
const DOC_FILE_RECORD_SUFFIX = [ "xls",
  "xlsx",
  "doc",
  "docx",
  "ppt",
  "pptx",
  "pdf"]
export class FilePickerUtil {
  public static context: UIContext;
  public static readonly privacyKey: string = 'privacyKey';
  public static readonly privacyKeyLength: number = 10;
  public static readonly privacyFilePath: string = '/data/storage/el2/base/haps/pc/files/privacy';
  // 小于该数量的文件走老逻辑，即单个循环授权
  public static readonly NORMAL_SELECT_MAX_NUM: number = 50;
  private static readonly DEFAULT_MAX_SELECT_NUM: number = 500;

  public static getFileSuffix(fileName: string): string {
    let suffixIndex = fileName.lastIndexOf('.');
    let suffix: string = '';
    if (suffixIndex >= 0) {
      suffix = fileName.substring(suffixIndex);
    }
    return suffix;
  }

  public static getFilePrefix(fileName: string): string {
    let suffix = FilePickerUtil.getFileSuffix(fileName);
    return fileName.substring(0, fileName.length - suffix.length);
  }

  /**
   * 向授权三方授权uri，返回授权结果
   * @param uriArr 待授权uri
   * @param bundleName 三方应用名
   * @returns Promise<void>
   */
  public static async grantPermissionUris(
    uriArr: string[], bundleName: string, isNeedGrantPermission: boolean = true): Promise<number[]> {
    let audioSuccessCnt: number = 0;
    let audioFailedCnt: number = 0;
    let videoSuccessCnt: number = 0;
    let videoFailedCnt: number = 0;
    // 除媒体文件以外的文件类型, 使用otherSuccessCnt, otherFailedCnt记录它的访问次数
    let otherSuccessCnt: number = 0;
    let otherFailedCnt: number = 0;
    for (const uri of uriArr) {
      let success: boolean = true;
      if (isNeedGrantPermission) {
        success = await FilePickerUtil.grantPhonePermissionUri(uri, bundleName);
      }
    }
    return [audioSuccessCnt, audioFailedCnt, videoSuccessCnt, videoFailedCnt, otherSuccessCnt, otherFailedCnt];
  }

  public static async grantPhonePermissionUri(uri: string, bundleName: string): Promise<boolean> {
    let flag: wantConstant.Flags = wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION |
    wantConstant.Flags.FLAG_AUTH_WRITE_URI_PERMISSION | wantConstant.Flags.FLAG_AUTH_PERSISTABLE_URI_PERMISSION;
    return await FileAuthorityUtil.grantUriPermission(uri, bundleName, flag);
  }

  public static async batchGrantUriPermission(fileUriList: string[], callId: number): Promise<string> {
    if (ArrayUtil.isEmpty(fileUriList)) {
      HiLog.error(TAG, 'batchGrantUriPermission invalid files');
      return '';
    }
    HiLog.info(TAG, 'batchGrantUriPermission begin');
    let udkey: string = await FilePickerUtil.insertDataToUdmf(fileUriList);
    if (StringUtil.isEmpty(udkey)) {
      HiLog.error(TAG, 'batchGrantUriPermission get udkey failed');
      return udkey;
    }
    try {
      let flag: wantConstant.Flags = wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION |
      wantConstant.Flags.FLAG_AUTH_WRITE_URI_PERMISSION |
      wantConstant.Flags.FLAG_AUTH_PERSISTABLE_URI_PERMISSION;
      await uriPermissionManager.grantUriPermissionByKey(udkey, flag, callId);
    } catch (err) {
      HiLog.error(TAG, 'insertData failed with errCode: ' + err?.code);
    }
    HiLog.info(TAG, 'batchGrantUriPermission end');
    return udkey;
  }

  private static async insertDataToUdmf(fileUriList: string[]): Promise<string> {
    HiLog.info(TAG, 'insertDataToUdmf begin');
    let unifiedData: unifiedDataChannel.UnifiedData | undefined = undefined;
    for (let i = 0; i < fileUriList.length; i++) {
      const fileUri = fileUriList[i];
      let uDFileUri: uniformDataStruct.FileUri = {
        uniformDataType: uniformTypeDescriptor.UniformDataType.FILE_URI,
        oriUri: fileUri,
        fileType: uniformTypeDescriptor.UniformDataType.FILE
      }
      try {
        let curRecord =
          new unifiedDataChannel.UnifiedRecord(uniformTypeDescriptor.UniformDataType.FILE_URI, uDFileUri);
        if (unifiedData === undefined) {
          unifiedData = new unifiedDataChannel.UnifiedData(curRecord);
        } else {
          unifiedData.addRecord(curRecord)
        }
      } catch (err) {
        HiLog.error(TAG, 'add unified data failed with errCode: ' + err?.code);
      }
    }
    if (unifiedData === undefined) {
      HiLog.error(TAG, 'insertDataToUdmf completely failed');
      return '';
    }
    try {
      const udkey =
        await unifiedDataChannel.insertData({ intention: unifiedDataChannel.Intention.PICKER }, unifiedData);
      return udkey ?? '';
    } catch (err) {
      HiLog.error(TAG, 'insertData failed with errCode: ' + err?.code);
    }
    HiLog.info(TAG, 'insertDataToUdmf end');
    return '';
  }

  public static async getBatchAuthUrisByUdkey(udkey: string): Promise<string[]> {
    let uris: Array<string> = [];
    try {
      let data: Array<UnifiedData> =
        await unifiedDataChannel.queryData({ intention: unifiedDataChannel.Intention.PICKER, key: udkey });
      if (data.length > 0) {
        let records: Array<unifiedDataChannel.UnifiedRecord> = data[0].getRecords();
        HiLog.info(TAG, 'getBatchAuthUrisByUdkey record length ' + records.length);
        for (let record of records) {
          uris.push((record.getValue() as uniformDataStruct.FileUri).oriUri);
        }
      }
    } catch (err) {
      HiLog.error(TAG, 'getBatchAuthUrisByUdkey failed with errCode: ' + err?.code);
    }
    return uris;
  }

  /**
   * 向授权三方授权uri，并上报安全隐私中心
   * @param uriArr 待授权uri
   * @param bundleName 三方应用名
   * @param isSaveFile 存储
   * @returns void
   */
  public static async grantPhonePermissionUrisWithRecords(uriArr: string[], bundleName: string,
  isSaveFile: boolean = false, isOnlyRecord: boolean = false): Promise<void> {
    const result: number[] = await FilePickerUtil.grantPermissionUris(uriArr, bundleName, !isOnlyRecord);
    const audioSuccessCnt = result[0];
    const audioFailedCnt = result[1];
    const videoSuccessCnt = result[2];
    const videoFailedCnt = result[3];
    const otherSuccessCnt: number = result[4];
    const otherFailedCnt: number = result[5];
  }

  /**
   * 结束 Ability ，并返回
   *
   * @param want 返回值
   * @param resultCode 返回错误码
   * @param options 结束方式配置
   * @returns void
   * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified;
   */
  static returnAbilityResult(want: Want, resultCode: number, options: StartModeOptions): Promise<void> {
    HiLog.info(TAG, 'returnPicker start');
    let context = getContext() as ctx.UIAbilityContext;
    if (options.windowType === WindowType.SERVICE) {
      return FilePickerUtil.returnAbilityResultByService(want, resultCode);
    } else if (options.windowType === WindowType.ABILITY) {
      let abilityResult: abilityResultInterface = {
        want: want,
        resultCode: resultCode
      };
      HiLog.info(TAG, 'terminateSelfWithResult start');
      return new Promise<void>((resolve, reject) => {
        context.terminateSelfWithResult(abilityResult, (error) => {
          // 如果是service调用则通过eventBus返回
          HiLog.error(TAG, 'terminateSelfWithResult is called = ' + error.code);
          if (error && error.code) {
            reject(error);
          } else {
            resolve();
          }
        });
      });
    } else {
      let abilityResult: ability.AbilityResult = {
        resultCode: resultCode,
        want: want
      };
      return new Promise<void>((resolve, reject) => {
        options.session?.terminateSelfWithResult(abilityResult, (error: BusinessError) => {
          HiLog.error(TAG, 'closeUIExtFilePicker terminateSelfWithResult is called = ' + error?.code);
          if (error && error.code) {
            reject(error);
          } else {
            resolve();
          }
        });
      });
    }
  }

  /**
   * 以 picker 当前上下文结束 Ability ，并返回
   *
   * @param want 返回值
   * @param resultCode 返回错误码
   * @returns void
   * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified;
   */
  static returnAbilityResultWithContext(want: Want, resultCode: number, options: StartModeOptions): Promise<void> {
    if (FilePickerUtil.context) {
      return new Promise((resolve, reject) => {
        FilePickerUtil.context.runScopedTask(() => {
          FilePickerUtil.returnAbilityResult(want, resultCode, options)
            .then(resolve)
            .catch(reject);
        });
      });
    } else {
      return FilePickerUtil.returnAbilityResult(want, resultCode, options);
    }
  }

  public static async getPickerSelectMode(fileList: string[]): Promise<SELECT_MODE> {
    let folderNum: number = 0;
    // 判断有几个文件夹
    for (let fileUri of fileList) {
      let fileInfo = await FileAccessUtil.getFileInfoFromUri(fileUri) as FileInfo;
      if (fileInfo.isFolder) {
        folderNum++;
      }
    }
    if (folderNum === 0) {
      return SELECT_MODE.File;
    }
    if (folderNum < fileList.length) {
      return SELECT_MODE.Mixed;
    }
    return SELECT_MODE.Folder;
  }

  /**
   * 解析picker入参
   */
  public static getStartModeOptions(want: Want): StartModeOptions {
    let options = new StartModeOptions();
    if (!want) {
      HiLog.error(TAG, 'getDocumentSelectOptions want is undefined')
      return options;
    }
    options.action = (AssertExtUtil.coverToString(want.action, 'action'));
    options.callerAbilityName =
      AssertExtUtil.coverToString(want.parameters?.['ohos.aafwk.param.callerAbilityName'], 'callerAbilityName');
    options.callerBundleName =
      AssertExtUtil.coverToString(want.parameters?.[AbilityCommonUtil.CALLER_BUNDLE_NAME], 'callerBundleName');
    options.callerUid = want?.parameters?.[AbilityCommonUtil.CALLER_UID] as number || 0;
    options.callerPid =
      AssertExtUtil.coverToString(want.parameters?.[AbilityCommonUtil.CALLER_PID]?.toString(), 'callerPid');
    options.appCloneIndex = want?.parameters?.[AbilityCommonUtil.CALLER_APP_CLONE_INDEX] as number ?? 0;
    const tempDefaultFilePathUri =
      encodeURI(decodeURI(AssertExtUtil.coverToString(want.parameters?.key_pick_dir_path, 'key_pick_dir_path')));
    options.defaultFilePathUri = AssertExtUtil.trustedPathExt(tempDefaultFilePathUri) ? tempDefaultFilePathUri : '';
    options.isEncryptionSupported = want.parameters?.key_is_encryption_supported as boolean ?? false;
    if (options.defaultFilePathUri && FileUriUtil.isForbiddenVisitUri(options.defaultFilePathUri)) {
      HiLog.warn(TAG, 'forbidden default file path uri');
      options.defaultFilePathUri = Constant.MY_PHONE_URI;
    }
    options.extType = AssertExtUtil.coverToString(want.parameters?.extType, 'extType');
    options.pickerType = AssertExtUtil.coverToString(want.parameters?.pickerType, 'pickerType');
    HiLog.info(TAG, 'start get want param');
    let multAuthMode: boolean = want.parameters?.key_mult_auth_mode as boolean ?? false;
    let mergeTypeMode: number = want.parameters?.key_merge_type_mode as number ?? 0;
    options.isBatchAuthMode = multAuthMode && (mergeTypeMode === 0);
    if (options.isBatchAuthMode) {
      options.udkey = want.parameters?.[AbilityCommonUtil.UDKEY] as string ?? '';
      if (StringUtil.isEmpty(options.udkey)) {
        options.batchAuthUris = ObjectUtil.toArray<string>(want.parameters?.key_mult_uri_arr) ?? [];
      }
    } else if (options.isOpenFileMode()) {
      HiLog.info(TAG, 'filepicker is open file mode');
      options.customTheme = ApplicationThemeColor.getCustomThemeWithColor(want.parameters?.key_theme_color_mode, false);
      options.loadSuffixes(ObjectUtil.toArray<string>(want.parameters?.key_file_suffix_filter));
      options.maxSelectNumber = want.parameters?.key_pick_num as number;
      if (!Number.isSafeInteger(options.maxSelectNumber) || options.maxSelectNumber <= 0) {
        HiLog.info(TAG, 'invalid select number' + options.maxSelectNumber);
        options.maxSelectNumber = FilePickerUtil.DEFAULT_MAX_SELECT_NUM;
      }
      options.setSelectMode(want.parameters?.key_select_mode as number);
      options.isAuthMode = want.parameters?.key_auth_mode as boolean || false;
    } else if (options.isCreateFileMode()) {
      HiLog.info(TAG, 'filepicker is create file mode');
      options.customTheme = ApplicationThemeColor.getCustomThemeWithColor(want.parameters?.key_theme_color_mode, true);
      options.setNewFileNames(ObjectUtil.toArray<string>(want.parameters?.key_pick_file_name));
      options.loadSuffixes(ObjectUtil.toArray<string>(want.parameters?.key_file_suffix_choices));
    } else {
      HiLog.error(TAG, 'getDocumentSelectOptions mode is error')
    }
    HiLog.warn(TAG,
      `getDocumentOptions: bundle: ${options.callerBundleName}, appCloneIndex: ${options.appCloneIndex},
      isEncryptionSupported: ${options.isEncryptionSupported}, fileSuffixFilters: ${options.fileSuffixFilters},
      maxSelectNumber: ${options.maxSelectNumber}, pickerType: ${options.pickerType},
      suffixChoices: ${options.fileSuffixChoices}`);
    return options;
  }

  public static getStartOptionsFromStorage(): StartModeOptions {
    let storage: LocalStorage = LocalStorage.getShared();
    let options: StartModeOptions | undefined = storage?.get<StartModeOptions>('startModeOptions');
    if (options === undefined) {
      options = new StartModeOptions();
      options.windowType = WindowType.ABILITY;
      options.context = options.uiContext = getContext() as common.UIAbilityContext;
      storage?.setOrCreate('startModeOptions', options);
    }
    return options;
  }

  /**
   * 以服务方式结束 Ability，并返回
   *
   * @param want 返回值
   * @param resultCode 返回错误码
   * @returns void
   * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified;
   */
  private static returnAbilityResultByService(want: Want, resultCode: number): Promise<void> {
    let storage = LocalStorage.getShared();
    let context = getContext() as ctx.UIAbilityContext;
    // 模态返回
    HiLog.info(TAG, 'returnPicker by isPickerServiceExtAbility');
    let abilityResult: dialogRequest.RequestResult = {
      'result': resultCode === 0 ? dialogRequest.ResultCode.RESULT_OK : dialogRequest.ResultCode.RESULT_CANCEL,
      'want': want
    };
    if (storage.get<dialogRequest.RequestCallback>('requestCallback')) {
      HiLog.info(TAG, 'returnPicker setRequestResult');
      let requestCallback =
        storage.get<dialogRequest.RequestCallback>('requestCallback') as dialogRequest.RequestCallback;
      requestCallback.setRequestResult(abilityResult)
    }
    if (storage.get<window.Window>('windowClass')) {
      let windowClass: window.Window | null = storage.get<window.Window>('windowClass') as window.Window;
      try {
        windowClass.destroyWindow((err) => {
          if (err.code) {
            HiLog.error(TAG, 'Failed to destroy the window. Cause:' + JSON.stringify(err));
            return;
          }
          HiLog.error(TAG, 'Succeeded in destroying the window.');
          windowClass = null;
        });
      } catch (e) {
        HiLog.error(TAG, 'destroyWindow error ' + JSON.stringify(e));
      }
    }
    return new Promise<void>((resolve, reject) => {
      context.terminateSelf()
        .then(() => {
          HiLog.warn(TAG, 'terminateSelf success');
          resolve();
        })
        .catch((err: BusinessError) => {
          HiLog.error(TAG, 'terminateSelf failed, err:' + err);
          reject(err);
        });
    });
  }
}