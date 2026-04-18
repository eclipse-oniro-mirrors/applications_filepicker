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
import { HiLog } from '../dfx/HiLog';
import { Constant } from '../const/Constant';
import { DisplayUtil } from './DisplayUtil';
import { GlobalHolder } from '../global/GlobalHolder';
import lazy { promptAction } from '../../../../indexLazyLoad';
import { LanguageUtil } from './LanguageUtil';
import { MyPhoneConstant } from '../const/MyPhoneConstant';
const TAG = 'Tools'

export function getDialogAlignment() {
  if (!DisplayUtil.isFoldable() || DisplayUtil.getFoldStatus() === DisplayUtil.FOLD_STATUS_FOLDED) {
    return DialogAlignment.Bottom;
  } else {
    return DialogAlignment.Center;
  }
}

export function toast(text: string | Resource, time = Constant.TIME.ONE_SECOND): void {
  try {
    promptAction.showToast({ message: text, duration: time });
  } catch (err) {
    HiLog.error(TAG, `showToast fail, err is ${JSON.stringify(err)}`);
  }
}

/**
 *  格式化显示大小
 */
export function renderSize(fileSize: number, carry: number = Constant.BYTE.STORAGE_KB,
  isTotalSize: boolean = false): string {
  if (!fileSize || fileSize <= 0) {
    return '0 B';
  }
  let unitArr = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  let index: number = Math.floor(Math.log(fileSize) / Math.log(carry));
  let size: number = fileSize / Math.pow(carry, index);
  if (size >= carry) {
    size = size / carry;
    index++;
  }
  // isTotalSize 为true时，使用去尾法，不显示小数点后内容
  if (index < unitArr.length) {
    return (isTotalSize ? Math.floor(size) : size.toFixed(2)) + ' ' + unitArr[index];
  } else {
    throw new Error('Exceeding the maximum storage unit');
  }
}

/**
 * @description 获取指定资源ID对应的字符串
 * @param resource: 指定资源
 * @return
 */

export function getResourceString(resource: Resource, ...args: number[] | string[]): string {
  let isString: RegExp = new RegExp('%s'); // 字符串类型
  let isNum: RegExp = new RegExp('%d'); // 数字类型
  let resStr: string = '';
  try {
    resStr = GlobalHolder.getInstance().getAppContext().resourceManager.getStringSync(resource.id);
  } catch (error) {
    HiLog.error(TAG, `getResourceString error，message: ${error}, Resource:${JSON.stringify(resource)}`);
    return resStr;
  }

  if (args.length) {
    args.forEach((item: number | string) => {
      if (typeof item === 'string') {
        resStr = resStr.replace(isString, item);
      } else if (typeof item === 'number') {
        resStr = resStr.replace(isNum, item.toString());
      }
    })
  }
  return resStr;
}

let lastClickTime: number = 0;

export function isFastClick(time: number = 500): boolean {
  let currentTime = Date.now();
  if (currentTime - lastClickTime < time) {
    lastClickTime = currentTime;
    return true;
  }
  lastClickTime = currentTime;
  return false;
}

export function getRootFolderInstruction(curFolderUri: string, itemUri: string): Resource | undefined {
  if (curFolderUri === Constant.MY_PHONE_URI && LanguageUtil.isChineseLanguage()) {
    return MyPhoneConstant.ROOT_FOLDER_INSTRUCTIONS_MAP.get(itemUri);
  }
  return undefined;
}
