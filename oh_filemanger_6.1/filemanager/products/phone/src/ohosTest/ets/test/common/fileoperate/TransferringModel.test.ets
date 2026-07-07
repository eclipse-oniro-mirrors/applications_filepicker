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
import { TransferringModel, WorkerConst } from '@ohos/common';
import { describe, it, expect, beforeAll } from '@ohos/hypium';

const EXTERNAL_PATH = 'file://docs/storage/External/';
const INTERNAL_PATH = 'file://docs/storage/Users/currentUser/';

export default function TransferringModelTest() {
  let transfer: TransferringModel;
  let result: boolean;
  describe('TransferringModelTest', () => {
    beforeAll(() => {
      transfer = TransferringModel.getInstance();
    })

    it('addtransferData', 0, () => {
      transfer.addTransferData('test', INTERNAL_PATH + 'test01', INTERNAL_PATH + 'test02',
        WorkerConst.OperateType.CUT_FILE);
      result = transfer.pasteMap.hasKey('test');
      expect(result).assertTrue();
    })

    it('removeTransferData_false', 0, () => {
      transfer.removeTransferData('test1');
      result = transfer.pasteMap.hasKey('test1');
      expect(result).assertFalse();
    })

    it('removeTransferData_true', 0, () => {
      transfer.removeTransferData('test');
      result = transfer.pasteMap.hasKey('test');
      expect(result).assertTrue();
    })

  })
}