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
 * 文件分组类型
 */
export enum FileGroupType {
  NONE = -1,
  NAME,
  MODIFIED_TIME,
  DISPLAY_TYPE,
  SIZE,
  CREATED_TIME,
  TAG,
  RECENT_TIME,
  PATH,
  OPEN_TIME
}

/**
 * 文件分组升降序
 */
export enum FileGroupOrder {
  DESC = 0,
  ASC
}

/**
 * 文件排序类型，枚举内顺序不能随意改变，否则会影响属性栏显示
 */
export enum FileSortType {
  NONE = -1,
  NAME,
  MODIFIED_TIME,
  PATH,
  DISPLAY_TYPE,
  SIZE,
  STATE,
  CREATED_TIME,
  OPEN_TIME,
  RECENT_TIME,
  DELETE_TIME
}

/**
 * 文件排序升降序
 */
export enum FileSortOrder {
  DESC = 0,
  ASC
}