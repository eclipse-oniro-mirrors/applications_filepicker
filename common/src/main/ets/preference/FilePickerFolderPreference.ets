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
import preferences from '@ohos.data.preferences';
import type context from '@ohos.app.ability.common';
import { BasePreference } from './BasePreference';
import { PreferenceFactory } from './PreferenceFactory';
import { FileView, VirtualUri, FolderRecord } from '../const/FolderRecord';
import { HiLog } from '../dfx/HiLog';
import { FileGroupOrder, FileGroupType, FileSortOrder, FileSortType } from '../const/GroupAndSortConst';

const TAG = 'FilePickerFolderPreference'

export class FilePickerFolderPreference extends BasePreference {
  public fileName: string = '';
  public preferenceInstance?: preferences.Preferences;

  /**
   * load FilePickerFolderPreference to uriArray
   * @param all
   */
  public async loadPreference(context: context.Context, fileName: string): Promise<FolderRecord> {
    let result = new FolderRecord();
    if (!context) {
      HiLog.infoPrivate(TAG, 'context is invalid, init preferences failed', fileName);
      return result;
    }
    try {
      this.preferenceInstance = await preferences.getPreferences(context, fileName);
      // 初始化preference
      this.fileName = fileName;
      // 打开文件选择器，默认展示“桌面”，查询“我的电脑”的视图
      const record: FolderRecord | null = await this.getRecord(VirtualUri.MY_PC);
      if (record) {
        HiLog.infoPrivate(TAG, 'show fileView : ' + record.fileView + ', groupType : ' +
        record.groupType + ', groupOrder : ' + record.groupOrder + ', sortType : ' + record.sortType +
          ', sortOrder : ' + record.sortOrder, this.fileName);
        result.fileView = record.fileView;
        result.groupType = record.groupType;
        result.groupOrder = record.groupOrder;
        result.sortType = record.sortType;
        result.sortOrder = record.sortOrder;
      } else {
        HiLog.infoPrivate(TAG, 'show default fileView', this.fileName);
        result.fileView = FileView.GRID;
        result.groupType = FileGroupType.NONE;
        result.groupOrder = FileGroupOrder.ASC;
        result.sortType = FileSortType.NAME;
        result.sortOrder = FileSortOrder.ASC;
      }
      let uriArray = BasePreference.fileUriArray.get(this.fileName);
      if (uriArray) {
        HiLog.infoPrivate(TAG, 'preferences has already loaded', this.fileName);
        return result;
      }
      // 加载preference
      PreferenceFactory.preferenceInstanceGetAll(this.preferenceInstance);
      return result;
    } catch (error) {
      HiLog.warnPrivate(TAG, `load preferences error.code: ${error?.code} error.message: ${error?.message}`,
        this.fileName);
    }
    return result;
  }
}