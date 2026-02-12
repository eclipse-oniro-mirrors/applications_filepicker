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

import { Rdb } from '@ohos/common/src/main/ets/database/Rdb';
import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';
import rdb from '@ohos.data.relationalStore';
import { dataSharePredicates, relationalStore, ValuesBucket } from '@kit.ArkData';
import { FavoriteDataConst, FavoriteDataEnum, FileInfo, FileUtil, HiLog } from '@ohos/common';
import { TestUtil } from '../../utils/TestUtil';
import { BusinessError } from '@ohos.base';
import { RdbErrCode } from '@ohos/common/src/main/ets/const/ErrorCode'

const TAG = 'Rdb';
const STORE_CONFIG: rdb.StoreConfig = {
  name: FavoriteDataEnum.DATABASE_NAME, securityLevel: rdb.SecurityLevel.S2
};

export default function RdbTest() {
  describe('RdbTest', () => {
    it('isRdbStoreNotExist', 0, () => {
      isRdbStoreNotExist();
    });

    it('getRdbStoreSync_undefined', 0, () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      expect(table.getRdbStoreSync()).assertUndefined();
    });

    it('getRdbStore_res', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      let mocker = new MockKit();
      let mockFun = mocker.mockFunc(FileUtil, FileUtil.setDeleteControlFlag);
      when(mockFun)(ArgumentMatchers.any).afterReturn(-1);
      mocker.clear(FileUtil);
      expect(await table.getRdbStore(STORE_CONFIG)).assertTrue();
    });

    it('setVersion', 0, async () => {
      await setVersion_rdbStoreIsUndefined(STORE_CONFIG);
    });

    it('batchInsertData_noRdb', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      let valuesBuckets: ValuesBucket[] = [];
      expect(await table.batchInsertData(valuesBuckets)).assertEqual(0);
    });

    it('batchInsertData_Rdb', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      let valuesBuckets: ValuesBucket[] = [];
      await table.getRdbStore(STORE_CONFIG)
      expect(await table.batchInsertData(valuesBuckets)).assertEqual(0);
    });

    it('insertData_noRdb', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      expect(await table.insertData(null)).assertEqual(0);
    });

    it('insertData_Rdb', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      await table.getRdbStore(STORE_CONFIG);
      expect(await table.insertData(null)).assertEqual(0);
    });

    it('deleteData_noRdb', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      let predicates = new rdb.RdbPredicates(FavoriteDataEnum.TABLE_NAME);
      expect(await table.deleteData(predicates)).assertEqual(0);
    });

    it('deleteData_Rdb', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      let predicates = new rdb.RdbPredicates(FavoriteDataEnum.TABLE_NAME);
      await table.getRdbStore(STORE_CONFIG);
      expect(await table.deleteData(predicates)).assertLargerOrEqual(0);
    });

    it('updateData_noRdb', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      let predicates = new rdb.RdbPredicates(FavoriteDataEnum.TABLE_NAME);
      expect(await table.updateData(null, predicates)).assertEqual(0);
    });

    it('updateData_Rdb', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      let predicates = new rdb.RdbPredicates(FavoriteDataEnum.TABLE_NAME);
      await table.getRdbStore(STORE_CONFIG);
      expect(await table.updateData(null, predicates)).assertEqual(0);
    });

    it('queryData_noRdb', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      let predicates = new rdb.RdbPredicates(FavoriteDataEnum.TABLE_NAME);
      TestUtil.setPrivateAttribute(table, 'rdbStore', undefined);
      expect(await table.queryData(predicates)).assertUndefined();
    });

    it('queryData_Err', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      let predicates = new rdb.RdbPredicates(FavoriteDataEnum.TABLE_NAME);
      let mocker = new MockKit();
      let queryFun = mocker.mockFunc(Rdb, Rdb.QueryErr);
      await table.getRdbStore(STORE_CONFIG);
      when(queryFun)(ArgumentMatchers.any).afterThrow('err');
      let res: relationalStore.ResultSet | undefined = await table.queryData(predicates);
      mocker.clear(Rdb);
      expect(res).not().assertUndefined();
    });

    it('queryData_Rdb', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      let predicates = new rdb.RdbPredicates(FavoriteDataEnum.TABLE_NAME);
      await table.getRdbStore(STORE_CONFIG);
      expect(await table.queryData(predicates)).not().assertUndefined();
    });

    it('queryTableData_noRdb', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      let predicates = new dataSharePredicates.DataSharePredicates();
      predicates.orderByDesc(FavoriteDataEnum.COLUMN_SORT_INDEX)
        .orderByDesc(FavoriteDataEnum.COLUMN_SET_TIME);
      expect(await table.queryTableData(predicates)).assertUndefined();
    });

    it('queryTableData_Err', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      let predicates = new dataSharePredicates.DataSharePredicates();
      let mocker = new MockKit();
      let queryFun = mocker.mockFunc(Rdb, Rdb.QueryErr);
      when(queryFun)(ArgumentMatchers.any).afterThrow('err');
      await table.getRdbStore(STORE_CONFIG);
      let res: relationalStore.ResultSet | undefined = await table.queryTableData(predicates);
      mocker.clear(Rdb);
      expect(res).not().assertUndefined();
    });

    it('queryTableData_Rdb', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      let predicates = new dataSharePredicates.DataSharePredicates();
      await table.getRdbStore(STORE_CONFIG);
      expect(await table.queryTableData(predicates)).not().assertUndefined();
    });

    it('queryError_noRdb', 0, async () => {
      let mocker = new MockKit();
      let mockFun = mocker.mockFunc(HiLog, HiLog.warn);
      when(mockFun)(ArgumentMatchers.any).afterReturnNothing();
      let resultSet = {rowCount: 0} as relationalStore.ResultSet;
      Rdb.QueryErr(undefined, resultSet);
      mocker.clear(HiLog);
      mocker.verify('warn', [TAG, 'rdbstore is undefined']);
    });

    it('queryError_rdb', 0, async () => {
      let mocker = new MockKit();
      let mockFun = mocker.mockFunc(HiLog, HiLog.error);
      when(mockFun)(ArgumentMatchers.any).afterReturnNothing();
      let resultSet = {rowCount: -1} as relationalStore.ResultSet;

      Rdb.QueryErr({} as relationalStore.RdbStore, resultSet);
      mocker.clear(HiLog);
      mocker.verify('error', [TAG, 'QueryErr RdbErrCode: undefined']);
    });

    it('restore_noRdb', 0, async () => {
      let mocker = new MockKit();
      let mockFun = mocker.mockFunc(HiLog, HiLog.warn);
      when(mockFun)(ArgumentMatchers.any).afterReturnNothing();
      await Rdb.Restore(undefined);
      mocker.clear(HiLog);
      mocker.verify('warn', [TAG, 'rdbstore is undefined']);
    });

    it('recentDataAging_noRdb', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      const res: boolean = await table.recentDataAging();
      expect(res).assertFalse();
    })

    it('getRecentNumber', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      const res: number = await table.getRecentNumber();
      expect(res).assertEqual(0);
    })

    it('queryRecent_NoRdb', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      const res: boolean[] = await table.queryRecent([]);
      expect(res.length).assertEqual(0);
    });

    it('queryRecent_Rdb', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      await table.getRdbStore(STORE_CONFIG);
      let res2: boolean[] = await table.queryRecent([]);
      expect(res2.length).assertEqual(0);
    });

    it('insertRecent_noRdb', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      const res: number = await table.insertRecent([]);
      expect(res).assertEqual(0);
    });

    it('insertRecent_Rdb', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      await table.getRdbStore(STORE_CONFIG);
      let file = new FileInfo();
      file.uri = 'file://docs/storage/Users/currentUser/Documents/test.file';
      file.fileName = 'test';
      const res1: number = await table.insertRecent([file]);
      expect(res1).assertEqual(-1);
    })

    it('handleSetVersion', 0, async (done: Function) => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, '112', FavoriteDataConst.COLUMNS);
      await table.getRdbStore(STORE_CONFIG);
      table.setVersion(111);
      expect(await table.getVersion()).assertEqual(111);
      done();
    })

    it('handleGetRecentNumber', 0, async (done: Function) => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, '114', FavoriteDataConst.COLUMNS);
      await table.getRdbStore(STORE_CONFIG);
      const res: number = await table.getRecentNumber();
      expect(res).assertEqual(0);
      done();
    })

    it('handleQueryRecent', 0, async (done: Function) => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, '115', FavoriteDataConst.COLUMNS);
      await table.getRdbStore(STORE_CONFIG);
      const res: boolean[] = await table.queryRecent(['111111']);
      expect(res.length).assertEqual(0);
      done();
    })

    it('getRdbStore_RdbErr', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      let mocker1: MockKit = new MockKit();
      let setDeleteControlFlage1 = mocker1.mockFunc(FileUtil, FileUtil.setDeleteControlFlag);
      when(setDeleteControlFlage1)(ArgumentMatchers.any).afterAction(() => {
        let e: BusinessError = { code: RdbErrCode.RdbErr, message: '' } as BusinessError;
        throw e as Error;
      });
      let res: boolean = await table.getRdbStore(STORE_CONFIG);
      mocker1.clear(FileUtil);
      expect(res).assertFalse();
    })

    it('getRdbStore_Undefined', 0, async () => {
      let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      await table.getRdbStore(STORE_CONFIG);
      let mocker: MockKit = new MockKit();
      let setDeleteControlFlage = mocker.mockFunc(FileUtil, FileUtil.setDeleteControlFlag);
      when(setDeleteControlFlage)(ArgumentMatchers.any).afterReturn(undefined);
      let res2: boolean = await table.getRdbStore(STORE_CONFIG);
      mocker.clear(FileUtil);
      expect(res2).assertTrue();
    })

    it('getRdbStore_Object', 0, async () => {
      let table1: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
      TestUtil.setPrivateAttribute(table1, 'rdbStore', new Object());
      let res1: boolean = await table1.getRdbStore(STORE_CONFIG);
      expect(res1).assertTrue();
    })
  })
}

function isRdbStoreNotExist(): void {
  let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
  expect(table.isRdbStoreNotExist()).assertTrue();
}

async function setVersion_rdbStoreIsUndefined(storeConfig: rdb.StoreConfig): Promise<void> {
  let table: Rdb = new Rdb(FavoriteDataEnum.TABLE_NAME, FavoriteDataConst.SQL_CREATE_TABLE, FavoriteDataConst.COLUMNS);
  table.setVersion(-1);
  let re: number = await table.getVersion();
  expect(re).assertEqual(-1);
}