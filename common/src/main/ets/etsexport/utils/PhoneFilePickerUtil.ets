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

import Want from '@ohos.app.ability.Want';
import { HiLog } from '../../dfx/HiLog';
import { ArrayUtil } from '../../utils/ArrayUtil';
import { FileInfo } from '../../fileoperate/FileInfo';
import { Constant } from '../../const/Constant';
import FileMimeTypeUtil from '../../utils/FileMimeTypeUtil';
import { StringUtil } from '../../utils/StringUtil';
import { StartModeOptions } from '../../model/StartModeOptions';
import { FilePickerUtil } from './FilePickerUtil';
import { HiSysEventUtil } from '../../dfx/HiSysEventUtil';
import lazy { promptAction } from '../../../../../indexLazyLoad';
import { uriPermissionManager, wantConstant } from '@kit.AbilityKit';
import { FileUtil } from '../../fileoperate/FileUtil';
import { toast } from '../../utils/Tools';
import { DFX } from '../../dfx/const/DFXConst';
import { UEUtil } from '../../dfx/UEUtil';
import { BatchGrantUriPermissionTask } from '../../taskpool/task/BatchGrantUriPermissionTask';
import { TaskManager } from '../../taskpool/manager/TaskManager';

const TAG = 'FilePickerUtil';
const PICK_WILD_CARD = ['*', '.*', '*.*']; // picker后缀过滤通配符，默认不过滤

interface AbilityResult {
  want: Want,
  resultCode: number
};

/**
 * picker对外返回的响应码
 */
export enum ResultCodePicker {
  SUCCESS = 0,
  CANCEL = -1
}

/**
 * 手机端文件选择器相关方法
 */
export namespace PhoneFilePickerUtil {

  /**
   * 文件选择器检查选择的文件个数是否已超过最大个数
   *
   * @param item 文件对象
   * @param checkedNum 已选中数量
   * @return 是否超限
   */
  export function checkPickNumExceed(item: FileInfo, checkedNum: number, startModeOptions: StartModeOptions): boolean {
    if (!startModeOptions.isFilePickerMode() || item.isChecked) {
      // 非文件选择器场景 文件当前已被选中，要取消选中
      return false;
    }
    return checkedNum >= startModeOptions.maxSelectNumber;
  }

  /**
   * 根据文件类型检查文件是否可以选择
   * @param item 文件对象
   * @return boolean 是否可被选择
   */
  export function checkFileType(item: FileInfo, startModeOptions: StartModeOptions): boolean {
    // 非文件选择器场景
    if (!startModeOptions.pickerFlag) {
      return true;
    }

    if (StringUtil.isEmpty(item.fileName)) {
      return false
    }

    const selectMode = startModeOptions.selectMode;
    if ((selectMode === Constant.SELECT_MODE.FILE) && item.isFolder) {
      return false;
    }

    // 选择模式为文件夹
    if (selectMode === Constant.SELECT_MODE.FOLDER) {
      return item.isFolder;
    }
    // 选择模式为混选
    if ((selectMode === Constant.SELECT_MODE.MIX) && item.isFolder) {
      return true;
    }

    // 校验文件后缀是否符合条件
    const targetSuffixList: string[] = startModeOptions.fileSuffixFilters;
    const isWildCard = targetSuffixList.some(v => PICK_WILD_CARD.includes(v));
    if (!ArrayUtil.isEmpty(targetSuffixList) && !isWildCard) {
      const fileSuffix = Constant.FILE_SUFFIX.SUFFIX_START + FileMimeTypeUtil.getFileSuffix(item.fileName);
      return targetSuffixList.some(item => fileSuffix.endsWith(item));
    }

    // 校验文件mimeType是否符合条件
    const targetMimeTypeList: string[] = startModeOptions.phonePickerTypeList;
    if (ArrayUtil.isEmpty(targetMimeTypeList)) {
      return true;
    }
    return checkFileMimetype(item.fileName, targetMimeTypeList);
  }

  /**
   * 校验文件的mimetype是否符合条件
   *
   * @param fileName 文件名称
   * @return 是否符合条件
   */
  function checkFileMimetype(fileName: string, targetMimeTypeList: string[]): boolean {
    // 类型列表为空或包含*或*/*时,可选择所有文件
    if (targetMimeTypeList.includes('*') || targetMimeTypeList.includes('*/*')) {
      return true;
    }
    // 输入的类型全转换成小写，避免大小敏感问题
    targetMimeTypeList.forEach(item => item.toLowerCase());

    // 根据文件名获取文件的mimeType对象
    const mimeTypeObj = FileMimeTypeUtil.getFileMimeType(fileName);
    const mimeType = mimeTypeObj.mimeType;

    // mimeType未知不可选
    if (!mimeType) {
      return false;
    }

    // mimeType完全匹配
    if (targetMimeTypeList.includes(mimeType)) {
      return true;
    }

    const index = mimeType.indexOf('/');
    if (index > 0) {
      // 获取文件的大分类
      const fileCategory = mimeType.substring(0, index);
      // 判断是否包换选择某一类文件
      if (targetMimeTypeList.includes(fileCategory) || targetMimeTypeList.includes(`${fileCategory}/*`)) {
        return true;
      }
    }

    return false;
  }

  /**
   * 选择的文件个数超限进行toast提示
   */
  export function showPickNumExceedTip(startModeOptions: StartModeOptions): void {
    const maxNum = startModeOptions.maxSelectNumber;
    promptAction.showToast({
      message: $r('app.plural.filePickerTip', maxNum, maxNum)
    })
  }

  /**
   * 检查当前文件是否可被选择
   *
   * @param fileItem 当前文件信息
   * @param checkedNum 已选中的文件个数
   * @param isShowToast 是否需要显示超限toast
   * @returns boolean 是否可以被选择
   */
  export function checkFileCanPick(
    fileItem: FileInfo,
    checkedNum: number,
    isNeedShowToast: boolean = false,
    startModeOptions: StartModeOptions): boolean {
    // 批量授权模式不对文件数量做限制
    if (startModeOptions.isBatchAuthMode) {
      return true;
    }
    if (checkPickNumExceed(fileItem, checkedNum, startModeOptions)) {
      if (isNeedShowToast) {
        showPickNumExceedTip(startModeOptions);
      }
      return false;
    }
    return checkFileType(fileItem, startModeOptions);
  }

  /**
   * 文件选择器根据文件类型过滤文件列表
   * @param fileDataList 待过滤的文件列表
   * @returns 过滤后的文件列表
   */
  export function filterListByFileType(fileDataList: FileInfo[], startModeOptions: StartModeOptions): FileInfo[] {
    // 非文件选择器场景
    if (!startModeOptions.pickerFlag) {
      return fileDataList;
    }

    if (ArrayUtil.isEmpty(fileDataList)) {
      return fileDataList;
    }

    return fileDataList.filter((item: FileInfo) => item.isFolder || checkFileType(item, startModeOptions));
  }


  /**
   * 文件选择完成，返回uri列表
   * @param resultCode
   * @param result
   * @param message
   */
  export async function terminateFilePicker(result: string[] = [],
    resultCode: number = ResultCodePicker.SUCCESS, startModeOptions: StartModeOptions): Promise<void> {
    HiLog.warn(TAG, 'enter terminateFilePicker, result length： ' + result.length + ', resultCode:' + resultCode);
    let want: Want = {
      parameters: {
        'ability.params.stream': result
      }
    };
    // 授权URI给拉起Picker的应用
    if (result && result.length > 0) {
      UEUtil.reportPickerOper(DFX.PickerMode.FILE_PICKER, result.length, startModeOptions.callerBundleName);
      try {
        let bundleName = startModeOptions.callerBundleName;
        await FilePickerUtil.grantPhonePermissionUrisWithRecords(result, bundleName, false, true); // 此处只进行记录，不授权
      } catch (err) {
        HiLog.error(TAG, 'grantPhonePermissionUri failed with errCode: ' + err.code);
      }
      try {
        if (result.length > FilePickerUtil.NORMAL_SELECT_MAX_NUM) {
          let batchGrantTask: BatchGrantUriPermissionTask = new BatchGrantUriPermissionTask(result, startModeOptions.tokenID,
            async (udKey: string)=> {
              let want: Want = {
                parameters: {
                  'ability.params.udkey': udKey // 大批量场景下有效
                }
              };
              // 打点上报
              FilePickerUtil.returnAbilityResult(want, resultCode, startModeOptions);
              // 手机只支持选择file模式
              HiSysEventUtil.reportFilePickerSelectAbility(Constant.SELECT_MODE.FILE, result.length);
            });
          TaskManager.getInstance().execute(batchGrantTask, 1, false, 1);
        } else {
          await FilePickerUtil.grantPermissionUris(result, startModeOptions.callerBundleName);
          let flag = wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION |
          wantConstant.Flags.FLAG_AUTH_WRITE_URI_PERMISSION |
          wantConstant.Flags.FLAG_AUTH_PERSISTABLE_URI_PERMISSION;
          want = {
            parameters: {
              'ability.params.stream': result
            },
            flags: flag
          };
          FilePickerUtil.returnAbilityResult(want, resultCode, startModeOptions);
          HiSysEventUtil.reportFilePickerSelectAbility(Constant.SELECT_MODE.FILE, result.length);
        }
      } catch (err) {
        HiLog.error(TAG, 'grantPhonePermissionUri failed with errCode: ' + err?.code);
      }
      return;
    }
    // 传选择结果给文件子系统
    FilePickerUtil.returnAbilityResult(want, resultCode, startModeOptions);
  }
}
