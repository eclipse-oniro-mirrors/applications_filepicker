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

import { FileInfo } from '../fileoperate/FileInfo';
import { WindowModelData } from './WindowModelData';

export interface BottomTabParams {
  icon: string | Resource;
  iconSelect: string | Resource;
  name: string | Resource;
  index: number;
}

export interface DireListParams {
  direList: BreadParamData[];
  fileIndex: number;
  mimeType: string;
  pageFrom: string;
}

export interface BreadParamData {
  title: string;
  url: string;
  childArr?: FileInfo[];
  yOffset?: number;
}

export interface urlAddress {
  index: number;
}

export interface ZIndex {
  TOP: number,
  MIDDLE: number,
  LOW: number,
  LEVEL10: number,
  LEVEL100: number,
  LEVEL101: number
}

export interface BottomBarColor {
  enabled: number,
  disabled: number
}

export interface SystemBarColor {
  WHITE: WindowModelData,
  BLACK: WindowModelData,
  LIGHT_GRAY: WindowModelData,
  PATH_PICK: WindowModelData,
  PATH_PICK_DARK: WindowModelData,
}

export interface BottomBarMap {
  copy: Resource,
  pasting: Resource,
  move: Resource,
  delete: Resource,
  play: Resource,
  pause: Resource,
  more: Resource,
  details: Resource,
  otherLocation: Resource,
  restore: Resource,
  selectAll: Resource,
  deselectAll: Resource,
  rotate: Resource,
  rename: Resource,
}

export interface DateFormat {
  YYYY_MM_DD: string,
  MM_DD: string,
  DATE_TIME: string,
  YYYY_MM_DD_CHINESE: string,
  MM_DD_CHINESE: string,
  DATE_TIME_CHINESE: string,
  HH_MM: string,
}

export interface otherAppOpenData {
  title: Resource | string;
  type: string;
}

/**
 * 手机屏幕的安全区域边距
 */
export interface SafePadding {
  left: number;
  right: number;
  top: number;
  bottom: number;
}

/**
 * 手机实际滑动量
 */
export interface OffsetRemainParam {
  offsetRemain: number;
}

// 日期上下午中文
export interface AmOrPmChinese {
  AM_CHINESE: Resource,
  PM_CHINESE: Resource
}

// 日期12小时制中文风格
export interface AmOrPmChineseStyle {
  MIDNIGHT: Resource
  BEFORE_DAWN: Resource,
  DAWN: Resource,
  EARLY_MORNING: Resource,
  MORNING: Resource,
  NOON: Resource,
  AFTERNOON: Resource,
  DUSK: Resource,
  EVENING: Resource
}


