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

import wantConstant from '@ohos.app.ability.wantConstant';
import type { FileInfo } from '../fileoperate/FileInfo';
import { FileAuthorityUtil } from './FileAuthorityUtil';
import { FileUtil } from '../fileoperate/FileUtil';
import { HiLog } from '../dfx/HiLog';
import { GlobalHolder } from '../global/GlobalHolder';
import lazy { print } from '../../../../indexLazyLoad';
import { EnumTransferUtil } from '../dfx/EnumTransferUtil';
import { UEUtil } from '../dfx/UEUtil';
import FileMimeTypeUtil from './FileMimeTypeUtil';
import { HashSet } from '@kit.ArkTS';

const TAG = 'PrintUtil';
const PRINT_BUNDLE_NAME: string = 'com.ohos.spooler';

export class PrintUtil {
  public static supportPrintType: Set<string> = new Set(['.jpeg', '.png', '.gif', '.webp', '.bmp', '.svg', '.ico',
    '.dng', '.jpg', '.jpe', '.jfif', '.jif', '.docx', '.doc', '.txt', '.docm', '.dot', '.dotx', '.dotm', '.wps',
    '.wpt', '.rtf', '.xml', '.htm', '.html', '.mht', '.mhtml', '.xlsx', '.xls', '.et', '.ett', '.xlt', '.xlsm',
    '.xltx', '.ltm', '.xlsb', '.csv', '.ppt', '.pptx', '.dps', '.dpt', '.potm', '.potx', '.pot', '.ppsm', '.ppsx',
    '.pps', '.pptm', '.pdf', '.ofd']);

  /**
   * 打印文件
   *
   * @param path
   */
  public static async printFile(files: string[]): Promise<void> {
    HiLog.info(TAG, 'Print start !');
    for (let i = 0; i < files.length; i++) {
      await FileAuthorityUtil.grantUriPermission(files[i], PRINT_BUNDLE_NAME,
        wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION | wantConstant.Flags.FLAG_AUTH_WRITE_URI_PERMISSION);
    }
    try {
      let context = GlobalHolder.getInstance().getCommonContext();
      print.print(files, context).then((jobTask: print.PrintTask) => {
        jobTask.on('block', () => {
          HiLog.info(TAG, 'PrintSpooler state is block');
        });
        jobTask.on('succeed', () => {
          HiLog.info(TAG, 'PrintSpooler state is succeed');
        });
        jobTask.on('fail', () => {
          HiLog.info(TAG, 'PrintSpooler state is fail');
        });
        jobTask.on('cancel', () => {
          HiLog.info(TAG, 'PrintSpooler state is cancel');
        });
      });
    } catch (error) {
      HiLog.error(TAG, 'printFile error : ' + error);
    }
  }

  /**
   * 手机端-打印文件
   *
   * @param path
   * @param context
   */
  public static async printPhoneFiles(files: string[], context: Context): Promise<void> {
    HiLog.info(TAG, 'Print phone files start !');
    let successFileArray: string[] = [];
    let filesSuffixSet: HashSet<string> = new HashSet();
    for (let i = 0; i < files.length; i++) {
      const isSuccess: boolean = await FileAuthorityUtil.grantUriPermission(files[i], PRINT_BUNDLE_NAME,
        wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION | wantConstant.Flags.FLAG_AUTH_WRITE_URI_PERMISSION);
      if (isSuccess) {
        filesSuffixSet.add(FileMimeTypeUtil.getFileSuffix(files[i]));
        successFileArray.push(files[i]);
      }
    }
    UEUtil.reportPrintFile(EnumTransferUtil.transferSetToString(filesSuffixSet));
    try {
      print.print(files, context).then((jobTask: print.PrintTask) => {
        jobTask.on('block', () => {
          HiLog.info(TAG, 'PrintSpooler state is block');
        });
        jobTask.on('succeed', () => {
          HiLog.info(TAG, 'PrintSpooler state is succeed');
        });
        jobTask.on('fail', () => {
          HiLog.info(TAG, 'PrintSpooler state is fail');
        });
        jobTask.on('cancel', () => {
          HiLog.info(TAG, 'PrintSpooler state is cancel');
        });
      });
    } catch (error) {
      HiLog.error(TAG, `Print phone files error : ${error}`);
    }
  }

  /**
   * 判断是否能打印
   * @param MulChoicesArr
   * @param fileArray
   */

  public static canPrint(selectFiles: string[], fileInfo: FileInfo, isFocusStart: boolean): boolean {
    if ((!isFocusStart) || (selectFiles.length === 1)) {
      return PrintUtil.printCondition(FileUtil.getFileTypeFromUri(fileInfo.uri));
    }

    for (let i = 0; i < selectFiles.length; i++) {
      if (PrintUtil.printCondition(FileUtil.getFileTypeFromUri(selectFiles[i]))) {
        return true;
      }
    }
    return false;
  }

  public static printCondition(mimeType: string): boolean {
    if (PrintUtil.supportPrintType.has(mimeType)) {
      return true;
    }
    return false;
  }
}