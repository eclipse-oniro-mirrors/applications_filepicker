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

import { FileInfo } from './FileInfo';
import type common from '@ohos.app.ability.common';
import type { BusinessError } from '@ohos.base';
import { HiSysEventUtil } from '../dfx/HiSysEventUtil';
import { HiLog } from '../dfx/HiLog';
import wantConstant from '@ohos.app.ability.wantConstant';
import type Want from '@ohos.app.ability.Want';
import FileMimeTypeUtil from '../utils/FileMimeTypeUtil';
import { GlobalHolder } from '../global/GlobalHolder';
import { FileUtil } from './FileUtil';
import { Actions } from '../const/Constant';
import { VirtualUri } from '../const/FolderRecord';
import { FsUtil } from '../utils/FsUtil';
import { HiSysEventName, InterfaceName, OperateName, OperateResult } from '../const/HiSysEventConst';
import lazy { filemanager } from '../model/filetag/FileManager';
import { DFX } from '../dfx/const/DFXConst';
import { UEUtil } from '../dfx/UEUtil';
import lazy TrashNapi from 'libTrash.so';

const tag = 'FileOperation';

export class FileOperation {
  /**
   * 使用第三方应用打开文件
   *
   * @param fileUri 要打开的文件uri
   * @param fileName 要打开文件的文件名
   * @param chooseApp  是否支持选择应用
   * @returns true,打开成功
   */
  public static async openFileByOtherApp(fileUri: string, fileName: string, chooseApp: boolean = true): Promise<void> {
    HiLog.infoPrivate(tag, 'openFileByOtherApp: ', fileUri + ' ; ' + chooseApp);
    let ctx: common.UIAbilityContext | common.ServiceExtensionContext | common.UIExtensionContext | undefined;
    let grantFlag: number = wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION |
      wantConstant.Flags.FLAG_AUTH_WRITE_URI_PERMISSION | wantConstant.Flags.FLAG_AUTH_PERSISTABLE_URI_PERMISSION;

    ctx = GlobalHolder.getInstance().getMainAbilityContext() || GlobalHolder.getInstance().getUIExtensionContext() ||
      GlobalHolder.getInstance().getExtensionContext();

    const want: Want = {
      action: Actions.VIEW_DATA,
      uri: fileUri,
      flags: grantFlag,
      parameters: {
        fileName: {
          name: fileName
        },
        'ohos.ability.params.showDefaultPicker': chooseApp,
        displayName: fileName,
      }
    };
    try {
      ctx!!.startAbility(want).then(() => {
        HiLog.infoPrivate(tag, 'startAbility want: ', JSON.stringify(want));
      })
    } catch (error) {
      HiLog.error(tag, 'openFileByOtherApp fail, startAbility error:' + JSON.stringify(error));
      return;
    }
    UEUtil.reportOpenFile(DFX.FileOpenMode.OPEN_BY_OTHER_APP, FileMimeTypeUtil.getFileSuffix(fileName));
  }

  /**
   * 刪除文件及文件夾
   *
   * @param path
   */
  public static async deleteFileToTrash(uri: string): Promise<string> {
    HiLog.warn(tag, 'deleteFile start');
    try {
      const res = await FileOperation.delete(uri);
      HiSysEventUtil.reportFileOperation(OperateName.DELETE, 'files', OperateResult.SUCCESS);
      HiLog.warn(tag, 'deleteFile end');
      return res;
    } catch (err) {
      HiSysEventUtil.reportFileOperation(OperateName.DELETE, 'files', OperateResult.FAIL);
      throw err as Error;
    }
  }

  /**
   * 删除文件
   * @param uri 删除文件的uri
   */
  public static async delete(uri: string): Promise<string> {
    try {
      HiLog.infoPrivate(tag, 'delete start', uri);
      const res: string = await TrashNapi.deleteFile(uri);
      return res;
    } catch (error) {
      HiLog.info(tag, 'deleteFile error = ' + JSON.stringify(error));
      HiSysEventUtil.reportFailureEvent(HiSysEventName.FILE_OPERATE_FAIL, InterfaceName.FAF_DELETE,
        (error as BusinessError).code);
      throw error as Error;
    }
  }

  /**
   * 还原文件
   * @param uri 还原文件的uri
   */
  public static async recover(uri: string): Promise<string> {
    try {
      HiLog.infoPrivate(tag, 'fileUri is: ', uri);
      const res: string = await TrashNapi.recoverFile(uri);
      return res;
    } catch (error) {
      HiLog.info(tag, 'recoverFile error = ' + JSON.stringify(error));
      HiSysEventUtil.reportFailureEvent(HiSysEventName.FILE_OPERATE_FAIL, InterfaceName.FAF_DELETE,
        (error as BusinessError).code);
      throw error as Error;
    }
  }

  //通过文件预览器直接打开预览文件
  public static quickView(fileUri: string, filename?: string): boolean {
    HiLog.info(tag, 'quickView begin to execute');
    let grantFlag: number = wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION |
      wantConstant.Flags.FLAG_AUTH_WRITE_URI_PERMISSION | wantConstant.Flags.FLAG_AUTH_PERSISTABLE_URI_PERMISSION;

    grantFlag = wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION;
    filename = FileUtil.getFileNameFromUri(fileUri);

    let ctx = GlobalHolder.getInstance().getMainAbilityContext() ||
      GlobalHolder.getInstance().getUIExtensionContext() || GlobalHolder.getInstance().getExtensionContext();
    let want: Want = {
      action: Actions.VIEW_DATA,
      bundleName: 'com.ohos.hipreview',
      abilityName: 'ApiAbility',
      flags: grantFlag,
      uri: fileUri,
      parameters: {
        'title': filename ?? '',
        'uri': fileUri,
        'mimeType': '',
        'ability.params.stream': [fileUri],
      }
    }
    try {
      ctx!!.startAbility(want).then(() => {
        HiLog.infoPrivate(tag, 'quickView startAbility want: ', JSON.stringify(want));
      })
    } catch (err) {
      let error = err as BusinessError;
      HiLog.error(tag, 'quickView failed, error.code: ' + error.code);
      return false;
    }
    return true;
  }

  /**
   * 对外接口打开文管获取对应跳转Uri
   * 若是文件夹，跳转到对应文件夹，若是文件，跳转到所在文件夹，路径不存在，默认跳转到文管首页
   */
  public static getTargetUri(uri: string): string {
    if (!FsUtil.accessSync(FileUtil.getPathFromUri(uri)) || FileInfo.fromFileUri(uri).isFolder) {
      return uri;
    }
    let lastIndex = uri.lastIndexOf('/');
    let parentUri = uri.substring(0, lastIndex);
    return parentUri;
  }
}

export interface RenameItem {
  oldUri?: string;
  oldPath?: string;
  rename?: string;
  newName?: string;
  type?: string;
  newUri: string;
  newPath?: string;
  hardDelete?: boolean;
  closeDialog?: boolean;
}

export interface BottomCallParams {
  item: RenameItem;
}