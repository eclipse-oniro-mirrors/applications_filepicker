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
import { BasePreference } from './BasePreference';
import type context from '@ohos.app.ability.common';
import { HiLog } from '../dfx/HiLog';
import { FolderRecord } from '../const/FolderRecord';
import type { BusinessError } from '@ohos.base';
import type preferences from '@ohos.data.preferences';
import { PreferenceMode } from '../const/FilePickerItems';
import { PreferenceConst } from '../const/PreferenceConst';
import { GlobalHolder } from '../global/GlobalHolder';
import { CommonPreference } from './CommonPreference';
import { FilePickerFolderPreference } from './FilePickerFolderPreference';
import { FolderPreference } from './FolderPreference';
import { GrsRoutesPreference } from './GrsRoutesPreference';
import { UsageHabitsPreference } from './UsageHabitsPreference';
import { PickerLastOpenedDirPreference } from './PickerLastOpenedDirPreference';

const TAG: string = 'PreferenceFactory';
const abilityStagePreferenceList: string[] = [
  PreferenceConst.FILE.COMMON,
  PreferenceConst.FILE.GRS_URLS
];

export class PreferenceFactory {
  private static preferenceMap: Map<string, BasePreference> = new Map();

  public static getPreference(type: string): BasePreference {
    let preference = PreferenceFactory.preferenceMap.get(type);
    if (preference === undefined) {
      let context: context.Context = GlobalHolder.getInstance().getMainAbilityContext() ||
      GlobalHolder.getInstance().getUIExtensionContext() || GlobalHolder.getInstance().getExtensionContext();
      if (abilityStagePreferenceList.findIndex(t => t === type) !== -1) {
        context = GlobalHolder.getInstance().abilityStageContext;
      }
      PreferenceFactory.registerPreferenceSync(context, type);
    }
    return PreferenceFactory.preferenceMap.get(type) as BasePreference;
  }

  public static async registerPreference(context: context.Context, type: string): Promise<FolderRecord> {
    let instance = PreferenceFactory.createInstance(type);
    let result = new FolderRecord();
    if ((type.length === 0) || (!instance) || (!context)) {
      HiLog.error(TAG, 'PreferenceFactory registerPreference is error ' + type);
      return result;
    }
    result = await instance.loadPreference(context, type) as FolderRecord;
    PreferenceFactory.preferenceMap.set(type, instance);
    HiLog.info(TAG, 'PreferenceFactory type is ' + type + ', size is ' + PreferenceFactory.preferenceMap.size);
    return result;
  }

  public static registerPreferenceSync(context: context.Context, type: string): void {
    let instance = PreferenceFactory.createInstance(type);
    if ((type.length === 0) || (!instance) || (!context)) {
      HiLog.error(TAG, 'PreferenceFactory registerPreference is error ' + type);
      return;
    }
    instance.loadPreferenceSync(context, type);
    PreferenceFactory.preferenceMap.set(type, instance);
    HiLog.info(TAG, `PreferenceFactory type is ${type}, size is ${PreferenceFactory.preferenceMap.size}`);
    return;
  }

  public static preferenceInstanceGetAll(preferenceInstance: preferences.Preferences): void {
    // 加载preference
    preferenceInstance.getAll()
      .then((all) => {
        let uriArray: string[] = [];
        Object.entries(all)
          .sort((entry1: string[], entry2: string[]) => {
            let record1: FolderRecord = JSON.parse(entry1[1]);
            let record2: FolderRecord = JSON.parse(entry2[1]);
            return record1.modTime - record2.modTime;
          })
          .forEach((entry: string[]) => {
            uriArray.push(entry[0]);
          });
        BasePreference.fileUriArray.set(TAG, uriArray);
        HiLog.info(TAG, 'load preferences and set uriArray successfully');
      })
      .catch((err: BusinessError) => {
        HiLog.warn(TAG, 'load preference err : ' + err);
      });
  }

  public static createInstance(type: string): BasePreference | undefined {
    if (!type) {
      HiLog.info(TAG, 'createInstance error type is null');
      return;
    }
    switch (type) {
      case PreferenceConst.FILE.COMMON:
        return new CommonPreference();
      case PreferenceConst.FILE.GRS_URLS:
        return new GrsRoutesPreference();
      case PreferenceConst.FILE.USAGE_HABITS:
        return new UsageHabitsPreference();
      case PreferenceConst.FILE.NEW_USAGE_HABITS:
        return new UsageHabitsPreference();
      case PreferenceMode.FILE_PICKER:
        return new FilePickerFolderPreference();
      case PreferenceMode.FOLDER:
        return new FolderPreference();
      case PreferenceConst.FILE.PICKER_LAST_OPENED_DIR:
        return new PickerLastOpenedDirPreference();
      default:
        HiLog.error(TAG, 'createInstance error type can not find');
        return;
    }
  }

  public static async deletePreference(basePreference: BasePreference): Promise<void> {
    if (!basePreference || !basePreference.fileName) {
      HiLog.error(TAG, 'deletePreference fail, cause basePreference or basePreference.fileName is undefined');
      return;
    }
    let context: context.Context = GlobalHolder.getInstance().getMainAbilityContext() ||
    GlobalHolder.getInstance().getUIExtensionContext() || GlobalHolder.getInstance().getExtensionContext();
    if (abilityStagePreferenceList.findIndex(t => t === basePreference.fileName) !== -1) {
      context = GlobalHolder.getInstance().abilityStageContext;
    }
    await basePreference.deletePreference(context);
    PreferenceFactory.preferenceMap.delete(basePreference.fileName);
  }

  public static deletePreferenceCache(basePreference: BasePreference): void {
    if (!basePreference || !basePreference.fileName) {
      HiLog.error(TAG, 'deletePreferenceCache fail, cause basePreference or basePreference.fileName is undefined');
      return;
    }
    let context: context.Context = GlobalHolder.getInstance().getMainAbilityContext() ||
    GlobalHolder.getInstance().getUIExtensionContext() || GlobalHolder.getInstance().getExtensionContext();
    if (abilityStagePreferenceList.findIndex(t => t === basePreference.fileName) !== -1) {
      context = GlobalHolder.getInstance().abilityStageContext;
    }
    basePreference.updateCache(context);
    HiLog.info(TAG, 'deletePreferenceCache success');
  }
}