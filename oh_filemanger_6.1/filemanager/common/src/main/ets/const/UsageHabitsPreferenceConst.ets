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
import { VIEW_MODE, SortOrder } from './Constant'
import { PreferenceConst } from './PreferenceConst';

export class UsageHabits {
  public viewMode: string;
  public orderType: string;
  public isDesc: boolean;

  constructor(viewMode: string, orderType: string, isDesc: boolean) {
    this.viewMode = viewMode;
    this.orderType = orderType;
    this.isDesc = isDesc;
  }
}

export class UsageHabitsPreferenceConst {
  /**
   * viewMode
   */
  public static readonly VIEW_MODE: string = 'viewMode';

  /**
   * OrderType
   */
  public static readonly ORDER_TYPE: string = 'orderType';

  /**
   * isDesc
   */
  public static readonly IS_DESC: string = 'isDesc';

  /**
   * 我的手机
   */
  public static readonly MY_PHONE: string = 'MyPhone';

  /**
   * 最近删除
   */
  public static readonly RECENT_DELETE: string = 'RecentDelete';

  /**
   * 外部存储
   */
  public static readonly EXTERNAL_STORAGE: string = 'ExternalStorage';

  /**
   * 文管需加载的页面的集合
   */
  public static readonly PAGE_SET: Set<string> = new Set([
    UsageHabitsPreferenceConst.MY_PHONE,
    UsageHabitsPreferenceConst.RECENT_DELETE,
    UsageHabitsPreferenceConst.EXTERNAL_STORAGE
  ]);

  /**
   * picker需加载的页面
   */
  public static readonly PICKER_PAGE_SET: Set<string> = new Set([
    UsageHabitsPreferenceConst.MY_PHONE,
    UsageHabitsPreferenceConst.EXTERNAL_STORAGE
  ]);

  public static readonly USAGE_HABITS_DEFAULT_VALUE: Map<string, UsageHabits> = new Map([
    [UsageHabitsPreferenceConst.MY_PHONE, new UsageHabits(VIEW_MODE.LIST, SortOrder.TIME, true)],
    [UsageHabitsPreferenceConst.RECENT_DELETE, new UsageHabits(VIEW_MODE.LIST, SortOrder.TIME, true)],
    [UsageHabitsPreferenceConst.EXTERNAL_STORAGE, new UsageHabits(VIEW_MODE.LIST, SortOrder.TIME, true)]
  ]);

  // 老版本OtherPage对应的page，需要同步viewMode到新版本的page的Set集合
  public static readonly OTHER_PAGE_SET: Set<string> = new Set([
    UsageHabitsPreferenceConst.MY_PHONE,
    UsageHabitsPreferenceConst.EXTERNAL_STORAGE,
    UsageHabitsPreferenceConst.RECENT_DELETE,
  ]);

  // 老版本排序需要同步的页面的集合
  public static readonly OLDER_ORDER_PAGE_SET: Set<string> = new Set([
    UsageHabitsPreferenceConst.MY_PHONE,
    UsageHabitsPreferenceConst.EXTERNAL_STORAGE,
    UsageHabitsPreferenceConst.RECENT_DELETE,
  ]);

  // 需同步至其他持久化文件的集合
  public static readonly NEED_SYNCHRONIZE_PROPERTY: Set<string> = new Set([
    PreferenceConst.KEY.POWER_HINT_CONFIRMED,
    PreferenceConst.KEY.FAVORITE_LIST_EXPAND
  ]);
}