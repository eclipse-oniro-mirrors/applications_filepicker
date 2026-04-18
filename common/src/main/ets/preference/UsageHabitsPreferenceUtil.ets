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
import { PreferenceConst } from '../const/PreferenceConst';
import { StringUtil } from '../utils/StringUtil';
import { PreferenceFactory } from './PreferenceFactory';
import type { BasePreference } from './BasePreference';
import preferences from '@ohos.data.preferences';
import { ObjectUtil } from '../utils/ObjectUtil';
import { UsageHabits, UsageHabitsPreferenceConst } from '../const/UsageHabitsPreferenceConst';
import { SortOrder } from '../const/Constant';
import { JSON } from '@kit.ArkTS';

/**
 * TAG
 */
const TAG = 'UsageHabitsPreferenceUtil';

/**
 * 更改列表视图枚举
 */
export enum ViewMode {
  LIST = 'list',
  GRID = 'grid'
}

/**
 * 默认的排序规则
 */
export const DEFAULT_SORT_ORDER = 'time true';

/**
 * 搜索页默认的排序规则
 */
export const SEARCH_DEFAULT_SORT_ORDER = `default true`;

/**
 * 用户使用习惯持久化版本
 */
const USAGE_HABITS_VERSION: string = '1.0';

/**
 * 用户使用习惯的设置和获取方法工具类，如排序方式，宫格列表视图
 */
export class UsageHabitsPreferenceUtil {
  /**
   * 获取对应持久化字段Key
   */
  public static getViewModelKey(name: string, isPicker: boolean) {
    const prefix: string = isPicker ? 'Picker' : '';
    return `${prefix}${name}ViewMode`;
  }

  public static getOrderTypeKey(name: string, isPicker: boolean) {
    const prefix: string = isPicker ? 'Picker' : '';
    return `${prefix}${name}OrderType`;
  }

  public static getIsDescKey(name: string, isPicker: boolean) {
    const prefix: string = isPicker ? 'Picker' : '';
    return `${prefix}${name}IsDesc`;
  }

  /**
   * 加载用户使用习惯(在文管启动时加载)
   */
  public static async loadingUsageHabits(isPicker: boolean = false): Promise<void> {
    try {
      HiLog.info(TAG, 'start to loadingUsageHabits.');
      // 老版本持久化数据
      const oldPreference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.USAGE_HABITS);
      const oldUsageHabitObj: Object = await oldPreference.getAll() || ObjectUtil.empty();
      const oldHabitsKeys = Object.keys(oldUsageHabitObj);
      const oldUsageHabit = oldUsageHabitObj as Record<string, preferences.ValueType>;
      // 新版本持久化数据
      const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.NEW_USAGE_HABITS);
      const usageHabitObj: Object = await preference.getAll() || ObjectUtil.empty();
      const habitsKeys = Object.keys(usageHabitObj);
      if (oldHabitsKeys.length > 0 && habitsKeys.length === 0) {
        HiLog.info(TAG, 'loadingUsageHabits from old version.');
        UsageHabitsPreferenceUtil.getUsageHabitsInfoFromOldVersion(isPicker, oldHabitsKeys, oldUsageHabit, preference);
        PreferenceFactory.deletePreference(oldPreference);
      }
      HiLog.info(TAG, 'loadingUsageHabits end.');
    } catch (e) {
      HiLog.error(TAG, `loadingUsageHabits: error: ${JSON.stringify(e)}, error message: ${e?.message}`);
    }
  }

  /**
   * 获取对应的页面UsageHabits信息
   */
  public static getUsageHabitsByPageName(pageName: string, isPicker: boolean): UsageHabits {
    HiLog.info(TAG, `getUsageHabitsByPageName start, pageName: ${pageName}, isPicker: ${isPicker}`);
    // 获取对应的key值
    const viewModelKey: string = UsageHabitsPreferenceUtil.getViewModelKey(pageName, isPicker);
    const orderTypeKey: string = UsageHabitsPreferenceUtil.getOrderTypeKey(pageName, isPicker);
    const isDescKey: string = UsageHabitsPreferenceUtil.getIsDescKey(pageName, isPicker);

    // 获取对应的默认值
    const defaultInfo: UsageHabits | undefined = UsageHabitsPreferenceConst.USAGE_HABITS_DEFAULT_VALUE.get(pageName);
    const viewModelDefaultVal: string = defaultInfo ? defaultInfo.viewMode : ViewMode.LIST;
    const orderTypeDefaultVal: string = defaultInfo ? defaultInfo.orderType : SortOrder.TIME;
    const isDescDefaultVal: boolean = defaultInfo ? defaultInfo.isDesc : true;

    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.NEW_USAGE_HABITS);
    const viewMode: string = preference.getSync<string>(viewModelKey, viewModelDefaultVal);
    const orderType: string = preference.getSync<string>(orderTypeKey, orderTypeDefaultVal);
    const isDesc: boolean = preference.getSync<boolean>(isDescKey, isDescDefaultVal);

    HiLog.info(TAG, `getUsageHabitsByPageName end`);
    return new UsageHabits(viewMode, orderType, isDesc);
  }

  /**
   * 设置用户的某个使用习惯
   */
  public static updateUsageHabit(pageName: string, isPicker: boolean, habitsType: string,
    value: preferences.ValueType): void {
    HiLog.info(TAG, `setUsageHabit start, pageName: ${pageName}, isPicker: ${isPicker}, habitsType: ${habitsType}`);
    if (StringUtil.isEmpty(pageName)) {
      HiLog.warn(TAG, `setUsageHabit error,cause pageName is empty`);
      return;
    }
    let key: string = '';
    switch (habitsType) {
      case UsageHabitsPreferenceConst.VIEW_MODE:
        key = UsageHabitsPreferenceUtil.getViewModelKey(pageName, isPicker);
        break;
      case UsageHabitsPreferenceConst.ORDER_TYPE:
        key = UsageHabitsPreferenceUtil.getOrderTypeKey(pageName, isPicker);
        break;
      case UsageHabitsPreferenceConst.IS_DESC:
        key = UsageHabitsPreferenceUtil.getIsDescKey(pageName, isPicker);
        break;
      default:
        break;
    }
    if (StringUtil.isEmpty(key)) {
      HiLog.warn(TAG, `setUsageHabit error,cause key is empty`);
      return;
    }
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.NEW_USAGE_HABITS);
    if (!preference) {
      HiLog.warn(TAG, `setUsageHabit error,preference is null or undefined`);
      return;
    }
    preference.putSync(key, value);
  }

  /**
   * 清除持久化缓存
   * */
  public static clearUsageHabitCache(): void {
    // 清除缓存
    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.NEW_USAGE_HABITS);
    PreferenceFactory.deletePreferenceCache(preference);
  }

  /**
   * 同步老版本的排序记忆
   */
  private static synchronizeOrderInfo(isPicker: boolean, oldKeys: string[],
    oldUsageHabit: Record<string, preferences.ValueType>,
    pageName: string, usageHabit: UsageHabits, updateMap: Map<string, preferences.ValueType>): void {
    // 是否存储了所有页面的排序
    const hasOtherPageOrderInfo: boolean = oldKeys.includes(PreferenceConst.KEY.OTHER_PAGE_SORT_ORDER) &&
      !StringUtil.isEmpty(oldUsageHabit[PreferenceConst.KEY.OTHER_PAGE_SORT_ORDER] as string);
    const pickerOrderTypeKey: string = UsageHabitsPreferenceUtil.getOrderTypeKey(pageName, true);
    const commonOrderTypeKey: string = UsageHabitsPreferenceUtil.getOrderTypeKey(pageName, false);
    const pickerIsDescKey: string = UsageHabitsPreferenceUtil.getIsDescKey(pageName, true);
    const commonIsDescKey: string = UsageHabitsPreferenceUtil.getIsDescKey(pageName, false);
    const needUpdatePickerInfo: boolean = UsageHabitsPreferenceConst.PICKER_PAGE_SET.has(pageName);
    // 判断是否需要同步老版本的持久化数据
    if (hasOtherPageOrderInfo && UsageHabitsPreferenceConst.OLDER_ORDER_PAGE_SET.has(pageName)) {
      let orderInfo: string = oldUsageHabit[PreferenceConst.KEY.OTHER_PAGE_SORT_ORDER] as string;
      let array: string[] = orderInfo.split(' ');
      if (array.length === 2) {
        usageHabit.orderType = array[0];
        usageHabit.isDesc = array[1] === 'true';
        updateMap.set(commonOrderTypeKey, usageHabit.orderType);
        updateMap.set(commonIsDescKey, usageHabit.isDesc);
        if (needUpdatePickerInfo) {
          updateMap.set(pickerOrderTypeKey, usageHabit.orderType);
          updateMap.set(pickerIsDescKey, usageHabit.isDesc);
        }
      }
    }
  }

  private static synchronizeViewModeInfo(isPicker: boolean, oldKeys: string[],
    oldUsageHabit: Record<string, preferences.ValueType>,
    pageName: string, usageHabit: UsageHabits, updateMap: Map<string, preferences.ValueType>): void {
    const needUpdatePickerInfo: boolean = UsageHabitsPreferenceConst.PICKER_PAGE_SET.has(pageName);
    // 判断持久化文件中是否存储了对应的数据，若存储了，则同步至新版本，否则则使用默认值
    const hasOtherPageViewModelInfo: boolean = oldKeys.includes(PreferenceConst.KEY.OTHER_PAGE_VIEW_MODE) &&
      !StringUtil.isEmpty(oldUsageHabit[PreferenceConst.KEY.OTHER_PAGE_VIEW_MODE] as string);
    const pickerViewModeKey: string = UsageHabitsPreferenceUtil.getViewModelKey(pageName, true);
    const commonViewModeKey: string = UsageHabitsPreferenceUtil.getViewModelKey(pageName, false);
    let isNeedToUpdateViewMode: boolean = false;

    if (UsageHabitsPreferenceConst.OTHER_PAGE_SET.has(pageName) && hasOtherPageViewModelInfo) {
      usageHabit.viewMode = oldUsageHabit[PreferenceConst.KEY.OTHER_PAGE_VIEW_MODE] as string;
      isNeedToUpdateViewMode = true;
    }
    if (isNeedToUpdateViewMode) {
      updateMap.set(commonViewModeKey, usageHabit.viewMode);
      if (needUpdatePickerInfo) {
        updateMap.set(pickerViewModeKey, usageHabit.viewMode);
      }
    }
  }

  /**
   * 加载老版本的UsageHabits持久化数据
   */
  private static getUsageHabitsInfoFromOldVersion(isPicker: boolean, oldKeys: string[],
    oldUsageHabit: Record<string, preferences.ValueType>, preference: BasePreference): void {
    // 记录后续需要更新到持久化文件的数据
    let updateMap: Map<string, preferences.ValueType> = new Map();
    // 老版本（内部存储、外部存储、最近删除）的展示形式
    for (const pageName of UsageHabitsPreferenceConst.PAGE_SET) {
      // 获取对应的默认值
      const defaultInfo: UsageHabits | undefined = UsageHabitsPreferenceConst.USAGE_HABITS_DEFAULT_VALUE.get(pageName);
      let viewMode: string = defaultInfo ? defaultInfo.viewMode : ViewMode.LIST;
      let orderType: string = defaultInfo ? defaultInfo.orderType : SortOrder.TIME;
      let isDesc: boolean = defaultInfo ? defaultInfo.isDesc : true;
      let usageHabit: UsageHabits = new UsageHabits(viewMode, orderType, isDesc);
      // 同步老版本的排序数据
      UsageHabitsPreferenceUtil.synchronizeOrderInfo(isPicker, oldKeys, oldUsageHabit, pageName, usageHabit, updateMap);
      // 同步老版本的视图信息
      UsageHabitsPreferenceUtil.synchronizeViewModeInfo(isPicker, oldKeys, oldUsageHabit, pageName, usageHabit,
        updateMap);
    }
    // 更新至新版本文件中
    preference.putFromMap(updateMap);
    // 同步其他持久化数据至common下（收藏文件是否展开、 搜索页面熄屏分析提示是否显示）
    const commonPreference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    for (let key of UsageHabitsPreferenceConst.NEED_SYNCHRONIZE_PROPERTY) {
      if (oldKeys.includes(key) && !ObjectUtil.isNullOrUndefined(oldUsageHabit[key])) {
        commonPreference.putSync(key, oldUsageHabit[key]);
      }
    }
  }
}