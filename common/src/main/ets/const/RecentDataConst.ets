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
 * 图库最近删除常量类
 */
export enum RecentDataEnum {
  /**
   * 表名
   */
  TABLE_NAME = 'recent',

  /**
   * 列名，INTEGER,记录id
   */
  COLUMN_ID = 'id',

  /**
   * 列名，TEXT,图库最近删除资源文件名
   */
  COLUMN_NAME = 'fileName',
  /**
   * 列名，TEXT,图库最近删除资源uri
   */
  COLUMN_URI = 'uri',

  /**
   * 列名，INTEGER,图库最近删除资源修改时间
   */
  COLUMN_DELETE_TIME = 'delete_time',
}

export class RecentDataConst {
  /**
   * 创建数据库表sql语句
   */
  public static readonly SQL_CREATE_TABLE: string = 'CREATE TABLE IF NOT EXISTS ' +
    `${RecentDataEnum.TABLE_NAME}` +
    ' (' +
    `${RecentDataEnum.COLUMN_ID}` +
    ' INTEGER PRIMARY KEY AUTOINCREMENT,' +
    `${RecentDataEnum.COLUMN_NAME}` +
    ' TEXT,' +
    `${RecentDataEnum.COLUMN_URI}` +
    ' TEXT,' +
    `${RecentDataEnum.COLUMN_DELETE_TIME}` +
    ' INTEGER' +
    ' );';

  public static readonly RECENT_COLUMNS: RecentDataEnum[] =
    [RecentDataEnum.COLUMN_ID, RecentDataEnum.COLUMN_NAME, RecentDataEnum.COLUMN_URI,
      RecentDataEnum.COLUMN_DELETE_TIME];

  /**
   * 在查询最近删除的图库访问记录之前，先删除老化数据
   */
  public static readonly TRIGGER_DELETE_BEFORE_QUERY: string =
    `DELETE FROM "recent" WHERE delete_time < strftime('%s', DATETIME('now', '-30 days')) * 1000`
}