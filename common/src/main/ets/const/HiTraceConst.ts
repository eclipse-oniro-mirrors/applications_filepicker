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
 * 用于Trace记录的常量
 */
export enum HiTraceConst {
  // 获取指定资源文件缩略图
  CREATE_CACHE_RESOURCE = 'CreateCacheResource',

  // 文件系统获取根路径信息
  FILE_ACCESS_REFRESH_GET_ROOTS = 'FileAccessRefreshGetRoots',

  // 获取本地设备空间占用信息
  GET_LOCAL_STORAGE_DETAIL = 'GetLocalStorageDetail',

  // 获取外接存储设备空间占用信息
  GET_EXTERNAL_STORAGE_DETAIL = 'GetExternalStorageDetail',

  // 强制删除文件
  FORCE_DELETE = 'ForceDelete',

  // 复制文件
  COPY_FILE = 'CopyFile',

  // 删除文件
  CUT_FILE = 'CutFile',

  // MAIN_ENTRY加载
  MAIN_ENTRY_PAGE_ABOUT_TO_APPEAR = 'MainEntryPageAboutToAppear',

  // 浏览页加载
  HOME_PAGE_ABOUT_TO_APPEAR = 'HomePageAboutToAppear',

  // 我的手机页面加载
  MY_PHONE_PAGE_ABOUT_TO_APPEAR = 'MyPhonePageAboutToAppear',

  // 最近删除页面加载
  RECENT_DELETE_PAGE_ABOUT_TO_APPEAR = 'RecentDeletePageAboutToAppear',

  // 大文件清理页面加载
  BIG_FILES_CLEAN_ABOUT_TO_APPEAR = 'BigFilesCleanAboutToAppear',

  // 索引注入服务预加载
  PREHEAT_INDEX_INSERT_SERVICE_TASK = 'PreheatIndexInsertServiceTask',
}