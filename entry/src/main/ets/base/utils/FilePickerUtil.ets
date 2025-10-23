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

import { toast } from '../../base/utils/Common';
import { FileMimeTypeUtil } from '../../base/utils/FileMimeTypeUtil';
import { FILE_SUFFIX, SELECT_MODE } from '../constants/Constant';
import ObjectUtil from './ObjectUtil';
import { ability, uriPermissionManager, Want, wantConstant } from '@kit.AbilityKit';
import Logger from '../log/Logger';
import { PickerWindowType } from '../constants/FilePickerItems';
import { StartModeOptions } from '../model/StartModeOptions';
import AbilityCommonUtil, { ResultCodePicker } from './AbilityCommonUtil';
import { FilesData } from '../../databases/model/FileData';

import ctx from '@ohos.app.ability.common';
import StringUtil from './StringUtil';
import { unifiedDataChannel, uniformDataStruct, uniformTypeDescriptor } from '@kit.ArkData';
import { BatchGrantUriPermissionTask } from '../../taskpool/task/BatchGrantPermissionTask';
import { TaskManager } from '../../taskpool/manager/TaskManager';

export interface abilityResultInterface {
  want: Want,
  resultCode: number
};

export interface PickerStatus {
  exceedLimit: boolean,
  differentTypes: boolean
}

const TAG = 'FilePickerUtil';
const BUNDLE_NAME = 'com.ohos.filepicker';

export namespace FilePickerUtil {
  export function returnAbilityResult(want: Want, resultCode: number, options: StartModeOptions) {
    Logger.i(TAG, 'returnPicker start');
    let context = getContext() as ctx.UIAbilityContext;
    if (options.windowType === PickerWindowType.ABILITY) {
      let abilityResult: abilityResultInterface = {
        want: want,
        resultCode: resultCode
      };
      Logger.i(TAG, 'terminateSelfWithResult start');
      context.terminateSelfWithResult(abilityResult, (error) => {
        Logger.e(TAG, 'terminateSelfWithResult is called = ' + error.code);
      });
    } else {
      let abilityResult: ability.AbilityResult = {
        resultCode: resultCode,
        want: want
      };
      options.session?.terminateSelfWithResult(abilityResult, (error) => {
        Logger.e(TAG, 'closeUIExtFilePicker terminateSelfWithResult is called = ' + error?.code);
      });
    }
  }

  export function getStartModeOptions(want: Want): StartModeOptions {
    let options = new StartModeOptions();
    if (!want) {
      Logger.e(TAG, 'getDocumentSelectOptions want is undefined')
      return options;
    }
    options.action = want.action as string || '';
    options.callerAbilityName = want.parameters?.['ohos.aafwk.param.callerAbilityName'] as string || '';
    options.callerBundleName = want.parameters?.['ohos.aafwk.param.callerBundleName'] as string || '';
    options.callerUid = want?.parameters?.[AbilityCommonUtil.CALLER_UID] as number || 0;
    options.defaultFilePathUri = want.parameters?.key_pick_dir_path as string || '';
    options.extType = want.parameters?.extType as string || '';
    options.pickerType = want.parameters?.pickerType as string || '';
    let multiAuthMode: boolean = want.parameters?.key_mult_auth_mode as boolean ?? false;
    let mergeTypeMode: number = want.parameters?.key_merge_type_mode as number ?? 0;
    options.isBatchAuthMode = multiAuthMode && (mergeTypeMode === 0);
    if (options.isBatchAuthMode) {
      options.udkey = want.parameters?.[AbilityCommonUtil.UDKEY] as string ?? '';
      if (StringUtil.isEmpty(options.udkey)) {
        options.batchAuthUris = ObjectUtil.toArray<string>(want.parameters?.key_mult_uri_arr) ?? [];
      }
      Logger.w(TAG, `file picker batch Auth mode: ${options.udkey}, ${options.batchAuthUris}`);
    }
    if (options.isOpenFileMode()) {
      options.fileSuffixFilters = want.parameters?.key_file_suffix_filter as string[] || [];
      options.maxSelectNumber = want.parameters?.key_pick_num as number || 1;
      options.setSelectMode(want.parameters?.key_select_mode as number);
      options.isAuthMode = want.parameters?.key_auth_mode as boolean || false;
      options.tokenID = want.parameters ? want.parameters?.[AbilityCommonUtil.CALLER_TOKEN] as number ?? 0 : 0;
    } else if (options.isCreateFileMode()) {
      options.setNewFileNames(want.parameters?.key_pick_file_name as string[]);
      options.fileSuffixChoices = want.parameters?.key_file_suffix_choices as string[] || [];
    } else {
      Logger.e(TAG, 'getDocumentSelectOptions mode is error')
    }
    Logger.i(TAG, 'getDocumentOptions : ' + JSON.stringify(options));
    return options;
  }

  export function getStartOptionsFromStorage(): StartModeOptions {
    let storage: LocalStorage = LocalStorage.getShared();
    if (!storage) {
      Logger.i(TAG, `Storage is null`)
      return new StartModeOptions();
    }
    let options: StartModeOptions | undefined = storage.get<StartModeOptions>('startModeOptions');
    if (options === undefined) {
      options = new StartModeOptions();
      storage.setOrCreate('startModeOptions', options);
    }
    return options;
  }

  export async function batchGrantUriPermission(fileUriList: string[], callerId: number): Promise<string> {
    if (fileUriList.length === 0) {
      Logger.w(TAG, 'batchGrantUriPermission fileUriList empty');
      return '';
    }
    Logger.i(TAG, 'batchGrantUriPermission start');
    let udKey: string = await FilePickerUtil.insertDataToUdmf(fileUriList);
    if (StringUtil.isEmpty(udKey)) {
      Logger.e(TAG, 'batchGrantUriPermission get udKey failed');
      return '';
    }
    try {
      let flag: wantConstant.Flags = wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION |
        wantConstant.Flags.FLAG_AUTH_WRITE_URI_PERMISSION |
        wantConstant.Flags.FLAG_AUTH_PERSISTABLE_URI_PERMISSION;
      await uriPermissionManager.grantUriPermissionByKey(udKey, flag, callerId);
    } catch (error) {
      Logger.e(TAG, `grantUriPermissionByKey error: ${error?.code}`);
    }
    Logger.i(TAG, 'batchGrantUriPermission end');
    return udKey;
  }

  export async function insertDataToUdmf(fileUris: string[]): Promise<string> {
    Logger.i(TAG, 'insertDataToUdmf start');
    let unifiedData: unifiedDataChannel.UnifiedData | undefined = undefined;
    for (let i = 0; i < fileUris.length; i++) {
      const fileUri = fileUris[i];
      let uDFileUri: uniformDataStruct.FileUri = {
        uniformDataType: uniformTypeDescriptor.UniformDataType.FILE_URI,
        oriUri: fileUri,
        fileType: uniformTypeDescriptor.UniformDataType.FILE
      }
      try {
        let curRecord = new unifiedDataChannel.UnifiedRecord(uniformTypeDescriptor.UniformDataType.FILE_URI, uDFileUri);
        if (!unifiedData) {
          unifiedData = new unifiedDataChannel.UnifiedData(curRecord);
        } else {
          unifiedData.addRecord(curRecord);
        }
      } catch (error) {
        Logger.e(TAG, `unifiedData addRecord error: ${error?.code}`);
      }
    }
    if (!unifiedData) {
      Logger.e(TAG, `insertDataToUdmf completely failec`);
    }
    try {
      const udKey =
        await unifiedDataChannel.insertData({ intention: unifiedDataChannel.Intention.PICKER }, unifiedData);
      return udKey ?? '';
    } catch (error) {
      Logger.e(TAG, `insertData error: ${error?.code}`);
    }
    Logger.i(TAG, 'insertDataToUdmf end');
    return '';
  }

  export async function getBatchAuthUriByUdKey(udKey: string): Promise<string[]> {
    let uris: string[] = [];
    try {
      let data: UnifiedData[] = await unifiedDataChannel.queryData({ intention: unifiedDataChannel.Intention.PICKER, key: udKey});
      if (data.length >= 0) {
        let records: unifiedDataChannel.UnifiedRecord[] = data[0].getRecords();
        Logger.i(TAG, `getBatchAuthUriByUdKey record len: ${records.length}`);
        records.forEach(record => {
          uris.push((record.getValue() as uniformDataStruct.FileUri).oriUri);
        })
      }
    } catch (err) {
      Logger.e(TAG, `getBatchAuthUriByUdKey error: ${err?.code}`);
    }
    return uris;
  }

  /**
   * 文件选择完成，返回uri列表
   * @param resultCode
   * @param result
   * @param message
   */
  export async function terminateFilePicker(result: string[] = [],
    resultCode: number = ResultCodePicker.SUCCESS, startModeOptions: StartModeOptions): Promise<void> {
    Logger.i(TAG, 'enter terminateFilePicker, result length： ' + result.length + ', resultCode:' + resultCode);
    const NORMAL_PICKER_SELECT_NUM: number = 50;
    if (result.length > NORMAL_PICKER_SELECT_NUM) {
      let task = new BatchGrantUriPermissionTask(result, startModeOptions.tokenID, (udKey: string) => {
        let want: Want = {
          parameters: {
            'ability.params.udkey': udKey
          }
        };
        returnAbilityResult(want, resultCode, startModeOptions);
      });
      TaskManager.getInstance().execute(task, 1, false, 1);
    } else {
      let want: Want = {
        bundleName: BUNDLE_NAME,
        flags: wantConstant.Flags.FLAG_AUTH_WRITE_URI_PERMISSION,
        parameters: {
          'ability.params.stream': result
        }
      };
      returnAbilityResult(want, resultCode, startModeOptions);
    }
  }
}

/**
 * 文件选择器文件状态
 *
 * @param item 文件对象
 * @param checkedNum 选中数量
 * @return 是否超限  选择类型是否不匹配
 */
export function pickerStatus(item: FilesData, checkedNum: number, startModeOptions: StartModeOptions): PickerStatus {
  let status: PickerStatus = {
    // 选择是否超限
    exceedLimit: (!startModeOptions.isBatchAuthMode) && checkedNum >= startModeOptions.maxSelectNumber &&
      !item.isChecked,
    // 选择类型是否不匹配
    differentTypes: !checkFileSelectable(item, startModeOptions)
  };
  return status;
}

/**
 * 根据文件后缀判断文件是否可选
 * @param item
 */
function checkFileSelectable(item: FilesData, startModeOptions: StartModeOptions): boolean {
  // selectMode检查
  let selectMode: number = startModeOptions.selectMode;
  let isFolder = false;
  if (ObjectUtil.hasKey(item, 'isFolder')) {
    isFolder = item.isFolder;
  }
  // 文件夹模式，直接返回
  if (selectMode === SELECT_MODE.FOLDER) {
    return isFolder;
  }

  if (isFolder) {
    // 混选模式下，文件夹直接返回
    if (selectMode === SELECT_MODE.MIX) {
      return true;
    }
    // 文件模式下，文件夹直接返回false
    return false;
  }
  // 后缀检查
  let keyFileSuffixFilter: string[] = startModeOptions.fileSuffixFilters;
  if (Array.isArray(keyFileSuffixFilter) && keyFileSuffixFilter.length > 0) {
    return checkFileSuffix(item.fileName, keyFileSuffixFilter);
  }

  // mimeType检查
  return checkFileMimetype(item.fileName, startModeOptions);
}

/**
 * 校验选中的文件后缀
 *
 * @param fileName 文件名称
 * @param keyFileSuffixFilter 指定后缀
 * @return 如果文件后缀满足三方指定，则返回true
 */
function checkFileSuffix(fileName: string, keyFileSuffixFilter: Array<string>): boolean {
  if (keyFileSuffixFilter) {
    if (fileName) {
      const suffix = FILE_SUFFIX.SUFFIX_START + FileMimeTypeUtil.getFileSuffix(fileName);
      if (keyFileSuffixFilter.includes(suffix)) {
        return true;
      }
    }
    return false;
  }
  return true;
}

/**
 * 校验选中的文件mimetype
 *
 * @param fileName 文件名称
 * @return 条件满足返回true
 */
function checkFileMimetype(fileName: string, startModeOptions: StartModeOptions): boolean {
  if (!fileName) {
    return false;
  }
  let keyPickTypeList: string[] = startModeOptions.phonePickerTypeList;
  // 输入的类型全转换成小写，避免大小敏感问题
  keyPickTypeList.forEach(item => item.toLowerCase());
  // 类型列表为空或包含*或*/*时,可选择所有文件
  if (!keyPickTypeList || keyPickTypeList.length === 0 ||
  keyPickTypeList.includes('*') || keyPickTypeList.includes('*/*')) {
    return true;
  }

  const mimeTypeObj = FileMimeTypeUtil.getFileMimeType(fileName);
  const mimeType = mimeTypeObj.getMimeType();

  // mimeType未知不可选
  if (!mimeType) {
    return false;
  }

  // mimeType完全匹配
  if (keyPickTypeList.includes(mimeType)) {
    return true;
  }

  let fileCategory = mimeType;
  const index = mimeType.indexOf('/');
  if (index > 0) {
    fileCategory = mimeType.substring(0, index);
  }
  // 某一类文件
  if (keyPickTypeList.includes(fileCategory) || keyPickTypeList.includes(`${fileCategory}/*`)) {
    return true;
  }

  return false;
}

/**
 * 文件选择器 选择超限提示
 *
 * @param isImmersion 是否沉浸式
 */
export const filePickerTip = (startModeOptions: StartModeOptions) => {
  globalThis.abilityContext.resourceManager.getPluralString($r('app.plural.filePickerTip').id,
    startModeOptions.maxSelectNumber)
    .then((value: string) => {
      toast(value)
    })
}


