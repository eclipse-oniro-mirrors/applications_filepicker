/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
 * 焦点键值
 */
export class FocusKey {
  public static readonly SETTING_BLANK_FOCUS = 'settingBlankFocus';
  public static readonly TAG_LIST_FOCUS = 'tagListFocus';
  public static readonly BLANK_FOCUS = 'blankFocus';
  public static readonly TAG_PREFIX = 'tag_';
  public static readonly TAG_INPUT_PREFIX = 'tagInput_';
  public static readonly SIDE_BAR_TAG_PREFIX = 'sideBarTag_';
  public static readonly SIDE_BAR_TAG_INPUT_PREFIX = 'sideBarTagInput_';
}

/**
 * 全局焦点组
 */
export class MainFocusGroup {
  public static readonly FORWARD_FOCUS = 'forwardFocus';
  public static readonly BACKWARDS_FOCUS = 'backwardsFocus';
  public static readonly TOOLBAR_FOCUS = 'toolbarFocus';
  public static readonly ADDRESS_FOCUS = 'addressFocus';
  public static readonly SIDEBAR_FOCUS = 'sidebarFocus';
  public static readonly FILE_VIEW_FOCUS = 'fileViewFocus';
}

/**
 * 全局焦点组tab切换顺序
 */
export enum MainFocusGroupIndex {
  NONE_FOCUS = -1, // 禁止走焦
  BACKWARDS_FOCUS = 1,
  FORWARD_FOCUS = 2,
  TOOLBAR_FOCUS = 3,
  ADDRESS_FOCUS = 5,
  SIDEBAR_FOCUS = 6,
  FILE_VIEW_FOCUS = 7
}

export class FocusStyle {
  public static readonly BORDER_WIDTH = 2;
  public static readonly BORDER_MARGIN = -2;
}

