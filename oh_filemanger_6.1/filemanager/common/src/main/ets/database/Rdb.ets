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

import type dataSharePredicates from '@ohos.data.dataSharePredicates';
import relationalStore from '@ohos.data.relationalStore';
import type common from '@ohos.app.ability.common';
import { HiLog } from '../dfx/HiLog';
import { GlobalHolder } from '../global/GlobalHolder';
import { FileUtil } from '../fileoperate/FileUtil';
import { RdbErrCode } from '../const/ErrorCode';
import { HiSysEventUtil } from '../dfx/HiSysEventUtil';
import { HiSysEventName } from '../const/HiSysEventConst';
import { InterfaceName } from '../const/HiSysEventConst';
import { RecentDataEnum, RecentDataConst } from '../const/RecentDataConst';
import { ValuesBucket } from '@kit.ArkData';
import { FileInfo } from '../fileoperate/FileInfo';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'Rdb';

/**
 * 抽象封装基础Rdb类
 */
export class Rdb {
  // 管理关系数据库(RDB)方法属性
  private rdbStore?: relationalStore.RdbStore = undefined;

  // 数据库表名称
  private tableName: string;

  // 创建SQLite表的语句字符串
  private sqlCreateTable: string;

  // 列名字段的数组
  private columns: string[];

  // 实例化 Rdb 对象时，初始化表名、创建表的语句、列名字段的数组
  constructor(tableName: string, sqlCreateTable: string, columns: string[]) {
    this.tableName = tableName;
    this.sqlCreateTable = sqlCreateTable;
    this.columns = columns;
  }

  /**
   * 获取操作数据库RdbStore对象是否初始化成功
   *
   * @return 数据库操作对象是否初始化成功
   */
  public isRdbStoreNotExist(): boolean {
    return !this.rdbStore;
  }

  /**
   * 获取操作数据库RdbStore对象的方法
   *
   * @param 数据库表格的配置信息
   * @return 是否初始化表格成功
   */
  public async getRdbStore(config: relationalStore.StoreConfig): Promise<boolean> {
    if (this.rdbStore) {
      HiLog.debug(TAG, 'The rdbStore exists.');
      return true;
    }
    // 获取context上下文, 不同的context对应目录会有差别，appContext在app根目录下，UIContext模块目录下
    let context: common.ApplicationContext = GlobalHolder.getInstance().getAppContext();
    try {
      this.rdbStore = await relationalStore.getRdbStore(context, config);
      // 执行Sql语句，使用创建表的字符串
      await this.rdbStore.executeSql(this.sqlCreateTable, [], (err) => {
        if (err) {
          HiLog.warn(TAG, `ExecuteSql failed, code is ${err.code}, message is ${err.message}`);
          return;
        }
      })
      const res = FileUtil.setDeleteControlFlag(`${context.databaseDir}/rdb`);
      if (res === undefined || res === -1) {
        HiLog.warn(TAG, `rdb file setDeleteControlFlag fail, result: ${res}`);
      }
    } catch (error) {
      HiLog.error(TAG, `getRdbStore failed, err: ${error}`);
      if (error.code === RdbErrCode.RdbErr) {
        Rdb.Restore(this.rdbStore);
      }
      return false;
    }
    HiLog.info(TAG, 'getRdbStore finished.');
    return true;
  }

  public getRdbStoreSync() {
    return this.rdbStore;
  }

  public async setVersion(version: number): Promise<void> {
    if (!this.rdbStore) {
      HiLog.error(TAG, 'rdbStore setVersion is undefined');
      return;
    }
    try {
      this.rdbStore.version = version;
    } catch (error) {
      HiLog.error(TAG, `setVersion failed, err: ${error}`);
    }
  }

  public async getVersion(): Promise<number> {
    if (!this.rdbStore) {
      HiLog.error(TAG, 'rdbStore getVersion is undefined');
      return -1;
    }
    return this.rdbStore.version;
  }

  /**
   * 批量插入数据的方法
   *
   * @param 待插入数据数组
   * @return 成功插入的数量
   */
  public async batchInsertData(valuesBucket: relationalStore.ValuesBucket[]): Promise<number> {
    let insertCount: number = 0;
    if (!this.rdbStore) {
      HiLog.error(TAG, 'rdbStore batchInsertData is undefined');
      return insertCount;
    }
    try {
      // rdbStore的批量插入方法
      insertCount = await this.rdbStore.batchInsert(this.tableName, valuesBucket);
    } catch (error) {
      HiLog.error(TAG, `batchInsert failed, err: ${error}`);
      if (error.code === RdbErrCode.RdbErr) {
        Rdb.Restore(this.rdbStore);
      }
    }
    HiLog.info(TAG, `batchInsert finished: ${insertCount}`);
    return insertCount;
  }

  /**
   * 插入数据的方法
   *
   * @param 待插入数据
   * @return 插入数据后生成的id
   */
  public async insertData(valuesBucket: relationalStore.ValuesBucket): Promise<number> {
    let id: number = 0;
    if (!this.rdbStore) {
      HiLog.error(TAG, 'rdbStore insertData is undefined');
      return id;
    }
    try {
      // rdbStore的插入方法
      id = await this.rdbStore.insert(this.tableName, valuesBucket);
    } catch (error) {
      HiLog.error(TAG, `insertData failed, err: ${error}`);
      if (error.code === RdbErrCode.RdbErr) {
        Rdb.Restore(this.rdbStore);
      }
    }
    HiLog.info(TAG, `insertData finished, id: ${id}`);
    return id;
  }

  /**
   * 删除数据的方法
   *
   * @param 谓词
   * @return 删除成功数量
   */
  public async deleteData(predicates: relationalStore.RdbPredicates): Promise<number> {
    let deleteCount: number = 0;
    if (!this.rdbStore) {
      HiLog.error(TAG, 'rdbStore updateData is undefined');
      return deleteCount;
    }
    try {
      // rdbStore的删除方法
      deleteCount = await this.rdbStore.delete(predicates);
    } catch (error) {
      HiLog.error(TAG, `deleteData failed, err: ${error}`);
      if (error.code === RdbErrCode.RdbErr) {
        Rdb.Restore(this.rdbStore);
      }
    }
    HiLog.info(TAG, `deleteData finished: ${deleteCount}`);
    return deleteCount;
  }

  /**
   * 更新数据
   *
   * @param 谓词
   * @param 存储键值对
   * @return 更新的数量
   */
  public async updateData(valuesBucket: relationalStore.ValuesBucket,
    predicates: relationalStore.RdbPredicates): Promise<number> {
    let count: number = 0;
    if (!this.rdbStore) {
      HiLog.error(TAG, 'rdbStore updateData is undefined');
      return count;
    }
    try {
      // rdbStore的更新方法
      count = await this.rdbStore.update(valuesBucket, predicates);
    } catch (error) {
      HiLog.error(TAG, `updateData failed, err: ${error}`);
      if (error.code === RdbErrCode.RdbErr) {
        Rdb.Restore(this.rdbStore);
      }
    }
    HiLog.info(TAG, `updateData finished: ${count}`);
    return count;
  }

  /**
   * 查询数据
   *
   * @param 谓词
   * @return 查询结果
   */
  public async queryData(predicates: relationalStore.RdbPredicates): Promise<relationalStore.ResultSet | undefined> {
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    if (!this.rdbStore) {
      HiLog.error(TAG, 'rdbStore queryData is undefined');
      return resultSet;
    }
    try {
      // rdbStore的查询方法
      resultSet = await this.rdbStore.query(predicates, this.columns);
      Rdb.QueryErr(this.rdbStore, resultSet);
      HiLog.info(TAG, 'rdbStore queryData finished.');
    } catch (error) {
      HiLog.error(TAG, `rdbStore queryData error: ${error?.message}`);
      if (resultSet) {
        resultSet.close();
      }
    }
    return resultSet;
  }

  /**
   * 查询数据
   *
   * @param 谓词，dataSharePredicates类型
   * @return 查询结果
   */
  public async queryTableData(predicates: dataSharePredicates.DataSharePredicates):
    Promise<relationalStore.ResultSet | undefined> {
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    if (!this.rdbStore) {
      HiLog.error(TAG, 'rdbStore query is undefined');
      return resultSet;
    }
    try {
      // rdbStore的查询方法
      resultSet = await this.rdbStore.query(this.tableName, predicates, this.columns);
      Rdb.QueryErr(this.rdbStore, resultSet);
      HiLog.info(TAG, 'rdbStore queryTableData finished.');
    } catch (error) {
      HiLog.error(TAG, `rdbStore queryTableData error: ${error?.message}`);
      if (resultSet) {
        try {
          resultSet.close();
          HiLog.info(TAG, 'ResultSet has been closed.');
        } catch (e) {
          HiLog.error(TAG, `resultSet close error: ${e?.message}`);
        }
      }
    }
    return resultSet;
  }

  public static QueryErr(rdbStore: relationalStore.RdbStore | undefined, resultSet: relationalStore.ResultSet): void {
    if (rdbStore === undefined) {
      HiLog.warn(TAG, `rdbstore is undefined`);
      return;
    }
    if (resultSet?.rowCount === -1) {
      try {
        resultSet.isColumnNull(0);
      } catch (error) {
        HiLog.error(TAG, `QueryErr RdbErrCode: ${error.code}`);
        if (error.code === RdbErrCode.RdbErr) {
          Rdb.Restore(rdbStore);
        }
      }
    }
    return;
  }

  public static async Restore(rdbStore: relationalStore.RdbStore | undefined): Promise<void> {
    if (rdbStore === undefined) {
      HiLog.warn(TAG, `rdbstore is undefined`);
      return;
    }
    try {
      HiLog.info(TAG, `rdbStore.restore start`);
      await rdbStore.restore();
    } catch (error) {
      HiLog.error(TAG, `rdb Restore err: ${JSON.stringify(error)}`);
    }
  }

  /**
   * recent表数据老化
   * @returns
   */
  public async recentDataAging(): Promise<boolean> {
    let res: boolean = false;
    if (!this.rdbStore) {
      HiLog.error(TAG, 'rdbStore recentDataAging rdb is undefined');
      return res;
    }

    try {
      await this.rdbStore.executeSql(RecentDataConst.TRIGGER_DELETE_BEFORE_QUERY);
      res = true;
    } catch (error) {
      HiLog.error(TAG, `TRIGGER_DELETE_BEFORE_QUERY failed, err: ${error}`);
      if (error.code === RdbErrCode.RdbErr) {
        Rdb.Restore(this.rdbStore);
      }
    }
    return res;
  }

  /**
   * 获取最近删除表中数据的数量
   * @returns
   */
  public async getRecentNumber(): Promise<number> {
    let count: number = 0;
    HiLog.info(TAG, `getRecentNumber start`);
    if (!this.rdbStore) {
      HiLog.error(TAG, 'getRecentNumber rdbStore getRecentNumber rdb is undefined');
      return count;
    }
    let sql: string = `select count(*) as count from recent`;
    let resultSet: relationalStore.ResultSet | undefined;
    try {
      resultSet = await this.rdbStore.querySql(sql);
      if (resultSet?.goToFirstRow()) {
        count = resultSet.getLong(0);
        HiLog.info(TAG, `getRecentNumber query result count: ${count}`);
      }
    } catch (error) {
      HiLog.error(TAG, `getRecentNumber failed, err: ${error}`);
      if (error.code === RdbErrCode.RdbErr) {
        Rdb.Restore(this.rdbStore);
      }
    } finally {
      if (resultSet) {
        resultSet.close();
      }
    }
    return count;
  }

  /**
   * 查询fileList中的数据是否在recent表中
   * @param fileList
   * @returns
   */
  public async queryRecent(galleryUris: string[]): Promise<boolean[]> {
    HiLog.info(TAG, 'queryRecent start');
    let res: boolean[] = [];
    if (!this.rdbStore) {
      HiLog.error(TAG, 'queryRecent rdbStore batchInsertData is undefined');
      return res;
    }
    let uris: string[] = [];
    let querySql: string = 'SELECT uri FROM recent';
    let resultSet: relationalStore.ResultSet | undefined;
    try {
      resultSet = await this.rdbStore?.querySql(querySql);
      const index = resultSet.getColumnIndex('uri');
      while (resultSet?.goToNextRow()) {
        const uri = resultSet.getString(index);
        uris.push(uri);
      }
    } catch (e) {
      const err: BusinessError = e;
      HiLog.error(TAG, `querySqlList from recent err, code: ${err?.code}, msg: ${err?.message}`);
    } finally {
      if (resultSet) {
        resultSet.close();
      }
    }
    if (!uris || uris.length === 0) {
      HiLog.error(TAG, 'queryRecent err with uris is undefined');
      return res;
    }

    res = galleryUris.map((uri) => {
      return uris.includes(uri)
    })

    HiLog.info(TAG, 'queryRecent end:' + res.length);
    return res;
  }

  /**
   * 插入最近页面删除访问记录的数据到recent表
   * @param fileList
   * @returns
   */
  public async insertRecent(fileList: FileInfo[]): Promise<number> {
    HiLog.info(TAG, 'insertRecent start')
    if (!this.rdbStore) {
      HiLog.error(TAG, 'insertRecent batchInsertData is undefined');
      return 0;
    }

    let valuesBuckets: relationalStore.ValuesBucket[] = [];
    valuesBuckets = this.generateRecentBucket(fileList)

    let rows: number = -1;
    try {
      // rdbStore的批量插入方法
      rows = await this.rdbStore?.batchInsert(this.tableName, valuesBuckets);
      HiLog.info(TAG, 'insertRecent success:' + rows)
    } catch (e) {
      const err: BusinessError = e;
      HiLog.error(TAG, `insertRecent err, code is ${err?.code}, message is ${err?.message}`);
    }

    return rows;
  }

  /**
   * 生成recent表实例的ValuesBucket结构数据用于数据插入
   * @param items
   * @returns
   */
  private generateRecentBucket(items: FileInfo[]): ValuesBucket[] {
    let res: ValuesBucket[] = [];
    for (let i = 0; i < items.length; i++) {
      const filename = items[i].fileName;
      const uri = items[i].uri;
      const time = new Date().getTime();
      let obj: ValuesBucket = {
        [RecentDataEnum.COLUMN_NAME]: filename,
        [RecentDataEnum.COLUMN_URI]: uri,
        [RecentDataEnum.COLUMN_DELETE_TIME]: time
      };
      res.push(obj);
    }
    return res;
  }
}