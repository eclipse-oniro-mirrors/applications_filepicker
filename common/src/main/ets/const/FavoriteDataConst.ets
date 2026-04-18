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
 * 数据共享常量类
 */
export enum FavoriteDataEnum {
  /**
   * 数据库名称
   */
  DATABASE_NAME = 'fileManager.db',

  /**
   * 表名
   */
  TABLE_NAME = 'favorite',

  /**
   * 列名，INTEGER,记录id
   */
  COLUMN_ID = 'id',

  /**
   * 列名，TEXT,文件夹名称
   */
  COLUMN_NAME = 'name',

  /**
   * 列名，TEXT,完整收藏路径
   */
  COLUMN_PATH = 'path',

  /**
   * 列名，INTEGER,目录修改时间
   */
  COLUMN_MODIFY_TIME = 'modify_time',

  /**
   * 列名，INTEGER,放入收藏夹时间
   */
  COLUMN_SET_TIME = 'set_time',

  /**
   * 列名，BOOL,是否在回收站
   */
  COLUMN_RECYCLED = 'recycled',

  /**
   * 列名，INTEGER,文件存储类型，内置存储/外置存储
   */
  COLUMN_DEVICE_TYPE = 'device_type',

  /**
   * 列名，TEXT,外部存储唯一标识UUID
   */
  COLUMN_EXT_UUID = 'ext_uuid',

  /**
   * 列名，INTEGER,排序位置
   */
  COLUMN_SORT_INDEX = 'sort_index',


}

export class FavoriteDataConst {
  /**
   * 创建数据库sql语句
   */
  public static readonly SQL_CREATE_TABLE: string = 'CREATE TABLE IF NOT EXISTS ' +
    `${FavoriteDataEnum.TABLE_NAME}` +
    ' (' +
    `${FavoriteDataEnum.COLUMN_ID}` +
    ' INTEGER PRIMARY KEY AUTOINCREMENT,' +
    `${FavoriteDataEnum.COLUMN_NAME}` +
    ' TEXT,' +
    `${FavoriteDataEnum.COLUMN_PATH}` +
    ' TEXT,' +
    `${FavoriteDataEnum.COLUMN_MODIFY_TIME}` +
    ' INTEGER,' +
    `${FavoriteDataEnum.COLUMN_SET_TIME}` +
    ' INTEGER,' +
    `${FavoriteDataEnum.COLUMN_RECYCLED}` +
    ' INTEGER,' +
    `${FavoriteDataEnum.COLUMN_DEVICE_TYPE}` +
    ' INTEGER,' +
    `${FavoriteDataEnum.COLUMN_EXT_UUID}` +
    ' TEXT,' +
    `${FavoriteDataEnum.COLUMN_SORT_INDEX}` +
    ' INTEGER' +
    ' );';
  /**
   * 查询全部列
   */
  public static readonly COLUMNS = ['*'];
  /**
   * 查询FAVORITES_FOLDER的全部列
   */
  public static readonly FAVORITES_FOLDER_COLUMNS: FavoriteDataEnum[] =
    [FavoriteDataEnum.COLUMN_ID, FavoriteDataEnum.COLUMN_NAME, FavoriteDataEnum.COLUMN_PATH,
      FavoriteDataEnum.COLUMN_EXT_UUID, FavoriteDataEnum.COLUMN_SORT_INDEX];
}