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
import { HiLog } from '../dfx/HiLog';

export class GrsRoutesPreference extends BasePreference {
  public fileName: string = '';
  public preferenceInstance?: preferences.Preferences;

  /**
   * load FolderPreference to uriArray
   * @param all
   */
  public async loadPreference(context: context.Context, fileName: string): Promise<void> {
    try {
      this.preferenceInstance = await preferences.getPreferences(context, fileName);
      this.fileName = fileName;
    } catch (error) {
      HiLog.warnPrivate('GrsRoutesPreference',
        `load preferences error.code: ${error?.code} error.message: ${error?.message}`, this.fileName);
    }
    return;
  }
}