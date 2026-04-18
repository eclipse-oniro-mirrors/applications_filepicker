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
import { getOperatorResource, getResourceString, HiLog } from '@ohos/common';
import { describe, it, expect } from '@ohos/hypium';

const DATA_ERR_MSG = 'data is empty';
const KEY_ERR_MSG = 'key is empty';

const TAG = 'FileOperationTypeTest';

export default function FileOperationTypeTest() {

  describe('FileOperationTypeTest', () => {
    it('getOperatorResource_CREATE_NEW', 0, (done: Function) => {
      let result = getOperatorResource(0);
      expect(result).not().assertUndefined();
      done();
    });

    it('getOperatorResource_RENAME', 0, (done: Function) => {
      let result = getOperatorResource(1);
      expect(result).not().assertUndefined();
      done();
    });

    it('getOperatorResource_COPY', 0, (done: Function) => {
      let result = getOperatorResource(2);
      expect(result).not().assertUndefined();
      done();
    });

    it('getOperatorResource_MOVE', 0, (done: Function) => {
      let result = getOperatorResource(3);
      expect(result).not().assertUndefined();
      done();
    });

    it('getOperatorResource_RECYCLE', 0, (done: Function) => {
      let result = getOperatorResource(4);
      expect(result).not().assertUndefined();
      done();
    });

    it('getOperatorResource_RESTORE', 0, (done: Function) => {
      let result = getOperatorResource(5);
      expect(result).not().assertUndefined();
      done();
    });

    it('getOperatorResource_DELETE', 0, (done: Function) => {
      let result = getOperatorResource(6);
      expect(result).not().assertUndefined();
      done();
    });

    it('getOperatorResource_ADD_TAG', 0, (done: Function) => {
      let result = getOperatorResource(7);
      expect(result).not().assertUndefined();
      done();
    });

    it('getOperatorResource_DEFAULT', 0, (done: Function) => {
      let result = getOperatorResource(8);
      expect(result).not().assertUndefined();
      done();
    });
  });
}