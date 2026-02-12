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

/**
 * 页面(ability)级状态存储常量
 */
export class LocalStorageConst {
  /**
   * 默认顶部状态栏的高度
   */
  public static readonly DEFAULT_STATUS_BAR_HEIGHT: number = 39;

  /**
   * 默认底部导航条的高度
   */
  public static readonly DEFAULT_BOTTOM_NAV_BAR_HEIGHT: number = 28;

  /**
   * 存在LocalStorage里顶部状态栏高度的key
   */
  public static readonly STATUS_BAR_HEIGHT: string = 'statusBarHeight';

  /**
   * 存在LocalStorage里底部导航条高度的key
   */
  public static readonly BOTTOM_NAV_BAR_HEIGHT: string = 'bottomNavBarHeight';

  /**
   * picker底部导航条的高度
   */
  public static readonly DEFAULT_BOTTOM_NAV_BAR_HEIGHT_ON_PICKER: string = 'pickerBottomNavBarHeight';


  /**
   * 当前手机的状态是否为单屏幕状态
   */
  public static IS_SINGLE_SCREEN: string = 'isSingleScreen';
}
