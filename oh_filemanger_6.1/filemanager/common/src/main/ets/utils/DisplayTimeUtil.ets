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

import Intl from '@ohos.intl';
import { HiLog } from '../dfx/HiLog';

const TAG:string = 'DisplayTimeUtil';

export class DisplayTimeUtil {
  private static instance: DisplayTimeUtil;
  private static MIN_1 = 60000; // 1分钟毫秒数
  private static MIN_60 = 3600000; // 60分钟毫秒数
  private static DAY_1 = 86400000; // 1天毫秒数
  private static twelveHourDateFormat?: Intl.DateTimeFormat = undefined;
  private static language?: string = undefined;

  private constructor() {
  }

  public static getInstance(): DisplayTimeUtil {
    if (!DisplayTimeUtil.instance) {
      DisplayTimeUtil.instance = new DisplayTimeUtil();
    }
    return DisplayTimeUtil.instance;
  }

  public static get12HourDateStr(lang: string, date: Date): string {
    if (!date) {
      HiLog.warn(TAG, 'get12HourDateStr param is undefined.');
      return '';
    }

    if (!DisplayTimeUtil.twelveHourDateFormat || DisplayTimeUtil.language != lang) {
      DisplayTimeUtil.twelveHourDateFormat = new Intl.DateTimeFormat(lang, {
        dateStyle: 'long',
        timeStyle:'medium',
        hour12: true,
      });
      DisplayTimeUtil.language = lang;
    }
    return DisplayTimeUtil.twelveHourDateFormat.format(date);
  }
}