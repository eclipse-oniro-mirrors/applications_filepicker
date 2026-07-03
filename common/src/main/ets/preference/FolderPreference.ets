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
import { VirtualUri} from '../const/FolderRecord';
import { HiLog } from '../dfx/HiLog';

const TAG = 'FolderPreference'

export class FolderPreference extends BasePreference {
  public fileName: string = '';
  public preferenceInstance?: preferences.Preferences;

  /**
   * load FolderPreference to uriArray
   * @param all
   */
  public async loadPreference(context: context.Context, fileName: string): Promise<void> {
    if (!context) {
      HiLog.infoPrivate(TAG, 'context is invalid, init preferences failed', fileName);
      return;
    }
    try {
      this.preferenceInstance = await preferences.getPreferences(context, fileName);
      // 初始化preference
      this.fileName = fileName;
      // 打开文管，默认展示“最近”，查询“最近”的视图
      await this.getRecord(VirtualUri.RECENT);
      let uriArray = BasePreference.fileUriArray.get(this.fileName);
      if (uriArray) {
        HiLog.infoPrivate(TAG, 'preferences has already loaded', this.fileName);
        return;
      }
      // 加载preference
      PreferenceFactory.preferenceInstanceGetAll(this.preferenceInstance);
    } catch (error) {
      HiLog.warnPrivate(TAG, `load preferences error.code: ${error?.code} error.message: ${error?.message}`,
        this.fileName);
    }
  }
}