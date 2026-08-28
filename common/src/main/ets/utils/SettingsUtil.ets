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

import { FileUtil } from '../fileoperate/FileUtil';
import { fileIo as fs, ReadOptions } from '@kit.CoreFileKit';
import { buffer } from '@kit.ArkTS';
import { HiLog } from '../dfx/HiLog';

// 目前只克隆显示隐藏文件、后续可扩展到其他设置项
export class SettingsSaveObject {
  public showHiddenItem: boolean = false;
  public isUploadPicker: boolean = false;
}

const TAG: string = 'SETTINGSUTIL';

export class SettingsUtil {
  private static readonly SETTINGS_SAVE_FOLDER_URI: string =
    'file://com.ohos.filemanager/data/storage/el2/base/files/settings/';
  public static readonly SETTINGS_SAVE_FILE_URI: string =
    'file://com.ohos.filemanager/data/storage/el2/base/files/settings/settings.json';
  private static readonly SETTINGS_SAVE_FOLDER_NAME: string = 'settings';
  private static readonly FILEMNAGER_SANDBOX_URI: string =
    'file://com.ohos.filemanager/data/storage/el2/base/files';
  private static readonly MAX_BUFFER_SIZE: number = 1024;

  public static async saveSettings2File(settingsObj: SettingsSaveObject): Promise<void> {
    HiLog.info(TAG, `saveSettings2File SettingsSaveObject = ${JSON.stringify(settingsObj)}`);
    if (!FileUtil.isExistByUriWithFs(SettingsUtil.SETTINGS_SAVE_FOLDER_URI)) {
      await FileUtil.createFolderByFs(SettingsUtil.FILEMNAGER_SANDBOX_URI,
        SettingsUtil.SETTINGS_SAVE_FOLDER_NAME);
    }
    const settingsStr = JSON.stringify(settingsObj);
    try {
      fs.open(SettingsUtil.SETTINGS_SAVE_FILE_URI,
        fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC)
        .then((file) => {
          try {
            file.tryLock(true);
            fs.writeSync(file.fd, settingsStr);
            fs.fsyncSync(file.fd);
            file.unlock();
          } catch (e) {
            HiLog.error(TAG, `saveSettings2File write file error ${e.message}`);
          } finally {
            fs.closeSync(file);
          }
        });
    } catch (e) {
      HiLog.error(TAG, `saveSettings2File open file error ${e.message}`);
    }
  }

  private static getSettings(filePathOrUri: string): SettingsSaveObject {
    try {
      const file = fs.openSync(filePathOrUri, fs.OpenMode.READ_ONLY);
      if (file === undefined) {
        return new SettingsSaveObject();
      }
      let arrayBuffer = new ArrayBuffer(SettingsUtil.MAX_BUFFER_SIZE);
      // 设置读取的偏移量和长度
      const readOptions: ReadOptions = { offset: 0, length: arrayBuffer.byteLength };
      let readLen: number = 0;
      try {
        file.tryLock(false);
        readLen = fs.readSync(file.fd, arrayBuffer, readOptions);
        file.unlock();
      } catch (e) {
        HiLog.error(TAG, `getSettings read file error ${e.message}`);
      } finally {
        fs.closeSync(file);
      }
      const buf = buffer.from(arrayBuffer, 0, readLen);
      const settingsObj: SettingsSaveObject = JSON.parse(buf.toString());
      return settingsObj;
    } catch (e) {
      HiLog.error(TAG, `getSettings error ${e.message}`);
    }
    return new SettingsSaveObject();
  }

  public static getSettingsFromFileUri(fileUri: string = SettingsUtil.SETTINGS_SAVE_FILE_URI): SettingsSaveObject {
    if (!FileUtil.isExistByUriWithFs(fileUri)) {
      HiLog.error(TAG, `getSettingsFromFileUri file is not exist!`);
      return new SettingsSaveObject();
    }

    return SettingsUtil.getSettings(fileUri);
  }

  public static getSettingsFromFilePath(filePath: string): SettingsSaveObject {
    if (!FileUtil.isExistByPathWithFs(filePath)) {
      HiLog.error(TAG, `getSettingsFromFilePath file is not exist!`);
      return new SettingsSaveObject();
    }

    return SettingsUtil.getSettings(filePath);
  }
}