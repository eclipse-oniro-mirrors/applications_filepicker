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
import { BasicDataSource } from '@ohos/common/src/main/ets/lazyLoadData/BasicDataSource';
import { beforeEach, describe, expect, it } from '@ohos/hypium';

export default function BasicDataSourceTest2() {
  describe('BasicDataSourceTest2', () => {
    let flag: boolean = false;
    beforeEach(() => {
      flag = false;
    })

    it('BasicDataSourceTest2_getListeners', 0, () => {
      const temp = new BasicDataSource();
      expect(temp.getListeners()).assertDeepEquals([]);
    })

    it('BasicDataSourceTest2_setListeners', 0, () => {
      const temp = new BasicDataSource();
      temp.setListeners([]);
      expect(temp.totalCount()).assertEqual(0);
    })

    it('BasicDataSourceTest2_totalCount', 0, () => {
      const temp = new BasicDataSource();
      expect(temp.totalCount()).assertEqual(0);
    })

    it('BasicDataSourceTest2_getData', 0, () => {
      const temp = new BasicDataSource();
      expect(temp.getData(0)).assertDeepEquals(new Object());
    })

    it('BasicDataSourceTest2_registerDataChangeListener', 0, () => {
      const temp = new BasicDataSource();
      temp.registerDataChangeListener({} as DataChangeListener);
      expect(temp.getListeners().length).assertEqual(1);
    })

    it('BasicDataSourceTest2_unregisterDataChangeListener', 0, () => {
      const temp = new BasicDataSource();
      temp.unregisterDataChangeListener({} as DataChangeListener);
      let listener: DataChangeListener = {} as DataChangeListener
      temp.setListeners([listener]);
      temp.unregisterDataChangeListener(listener);
      expect(temp.getListeners().length).assertEqual(0);
    })

    it('BasicDataSourceTest2_notifyDataReload_success', 0, () => {
      const dataSource = new BasicDataSource();
      dataSource.registerDataChangeListener({
        onDataReloaded: () => {
          flag = true;
        }
      } as DataChangeListener);
      dataSource.notifyDataReload();
      expect(flag).assertTrue();
    })

    it('BasicDataSourceTest2_notifyDataAdd_success', 0, () => {
      const dataSource = new BasicDataSource();
      dataSource.registerDataChangeListener({
        onDataAdd: (index: number) => {
        }
      } as DataChangeListener);
      dataSource.notifyDataAdd(0);
      expect(dataSource.getListeners().length).assertEqual(1);
    })

    it('BasicDataSourceTest2_notifyDataChange_success', 0, () => {
      const dataSource = new BasicDataSource();
      dataSource.registerDataChangeListener({
        onDataChange: (index: number) => {
        }
      } as DataChangeListener);
      dataSource.notifyDataChange(0);
      expect(dataSource.getListeners().length).assertEqual(1);
    })

    it('BasicDataSourceTest2_notifyDataDelete_success', 0, () => {
      const dataSource = new BasicDataSource();
      dataSource.registerDataChangeListener({
        onDataDelete: (index: number) => {
        }
      } as DataChangeListener);
      dataSource.notifyDataDelete(0);
      expect(dataSource.getListeners().length).assertEqual(1);
    })

    it('BasicDataSourceTest2_notifyDataMove_success', 0, () => {
      const dataSource = new BasicDataSource();
      dataSource.registerDataChangeListener({
        onDataMove: (from: number, to: number) => {
        }
      } as DataChangeListener);
      dataSource.notifyDataMove(0, 1);
      expect(dataSource.getListeners().length).assertEqual(1);
    })

    it('BasicDataSourceTest2_notifyDatasetChange_success', 0, () => {
      const dataSource = new BasicDataSource();
      dataSource.registerDataChangeListener({
        onDatasetChange: (dataOperations: DataOperation[]) => {
        }
      } as DataChangeListener);
      dataSource.notifyDatasetChange([]);
      expect(dataSource.getListeners().length).assertEqual(1);
    })
  })
}