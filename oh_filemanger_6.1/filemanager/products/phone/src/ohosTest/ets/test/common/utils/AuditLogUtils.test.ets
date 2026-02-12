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
import { AuditLogUtils, FileUtil, VirtualUri } from "@ohos/common";
import { ArgumentMatchers, beforeAll, describe, expect, it, MockKit, when } from "@ohos/hypium"
import { TestUtil } from "../../utils/TestUtil";
import { BusinessError } from "@kit.BasicServicesKit";

export default function AuditLogUtilsTest() {
  describe('AuditLogUtilsTest', () => {

    beforeAll(()=>{
      FileUtil.createFile(VirtualUri.DOWNLOAD, 'isFile.txt');
    })

    it('batchWriteAudit', 0, (done: Function) => {
      let fileNameList = [];
      let mocker = new MockKit();
      let auditLogUtils = AuditLogUtils.getInstance();
      let writeAudit = mocker.mockFunc(auditLogUtils, auditLogUtils.writeAudit);
      when(writeAudit)(ArgumentMatchers.any).afterReturnNothing();
      auditLogUtils.batchWriteAudit(fileNameList, 'hardDelete');
      mocker.verify('writeAudit', ['', '', 'hardDelete', -1]).never();
      mocker.clear(auditLogUtils);
      done();
    })

    it('addZero', 0, () => {
      let base: number = 0;
      let flag: boolean = false;
      let addZero = TestUtil.getPrivateFunction(AuditLogUtils, 'addZero');
      if (addZero) {
        let result: string = addZero(base, flag);
        expect(result).assertEqual(`0${base}`);
      } else {
        expect().assertFail();
      }
    })

    it('addZeroWithFlag', 0, () => {
      let base: number = 0;
      let flag: boolean = false;
      let addZero = TestUtil.getPrivateFunction(AuditLogUtils, 'addZero');
      if (addZero) {
        let result: string = addZero(base, flag);
        flag = true;
        result = addZero(base, flag);
        expect(result).assertEqual(`00${base}`);
      } else {
        expect().assertFail();
      }
    })

    it('addZeroNinetyNine', 0, () => {
      let base: number = 0;
      let flag: boolean = false;
      let addZero = TestUtil.getPrivateFunction(AuditLogUtils, 'addZero');
      if (addZero) {
        let result: string = addZero(base, flag);
        flag = true;
        base = 99;
        result = addZero(base, flag);
        expect(result).assertEqual(`0${base}`);
      } else {
        expect().assertFail();
      }
    })

    it('addZeroOneHundred', 0, () => {
      let base: number = 0;
      let flag: boolean = false;
      let addZero = TestUtil.getPrivateFunction(AuditLogUtils, 'addZero');
      if (addZero) {
        let result: string = addZero(base, flag);
        flag = true;
        base = 100;
        result = addZero(base, flag);
        expect(result).assertEqual(base.toString());
      } else {
        expect().assertFail();
      }
    })

    it('AuditLogUtilsTest_getFormatTime', 0, () => {
      let result: string = AuditLogUtils.getFormatTime();
      expect(result.length > 0).assertTrue()
    })

    it('zipFile', 0, async (done: Function) => {
      let auditLogUtils = AuditLogUtils.getInstance();
      let zipFile = TestUtil.getPrivateFunction(auditLogUtils, 'zipFile');
      if (zipFile) {
        let src = '';
        let zipPath = '';
        let result: boolean = await zipFile(src, zipPath);
        expect(result).assertFalse();
        let mocker = new MockKit();
        let isFileExist = TestUtil.getPrivateMockFunction(mocker, auditLogUtils, 'isFileExist');
        when(isFileExist)(ArgumentMatchers.any).afterReturn(true);
        result = await zipFile(src, zipPath);
        expect(result).assertFalse();
        mocker.clear(auditLogUtils);
      } else {
        expect().assertFail();
      }
      done();
    })

    it('getAuditLogKeys', 0, () => {
      let auditLogUtils = AuditLogUtils.getInstance();
      let getAuditLogKeys = TestUtil.getPrivateFunction(auditLogUtils, 'getAuditLogKeys');
      if (getAuditLogKeys) {
        let obj: AuditLog = {
          happenTime: '1',
          packageName: "",
          isForeground: false,
          isUserBehavior: false,
          cause: "",
          operationType: "",
          operationScenario: "",
          operationCount: 0,
          operationStatus: "",
          extend: ""
        }
        let result: string = getAuditLogKeys(obj);
        expect(result).assertEqual(Object.keys(obj).join(', ') + '\n');
      } else {
        expect().assertFail();
      }
    })

    it('mkdirSync', 0, () => {
      let auditLogUtils = AuditLogUtils.getInstance();
      let mkdirSync = TestUtil.getPrivateFunction(auditLogUtils, 'mkdirSync');
      if (mkdirSync) {
        let dirPath: string = 'file://docs/storage/Users/currentUser/Documents';
        let result: boolean = mkdirSync(dirPath);
        expect(result).assertFalse();
      } else {
        expect().assertFail();
      }
    })

    it('isFile', 0, async (done: Function) => {
      let auditLogUtils = AuditLogUtils.getInstance();
      let isFile = TestUtil.getPrivateFunction(auditLogUtils, 'isFile');
      if (isFile) {
        let uri: string | BusinessError = FileUtil.createFile(VirtualUri.DOWNLOAD, 'isFile.txt');
        if (typeof uri === 'string') {
          let result: boolean = isFile(uri);
          expect(result).assertTrue();
          await FileUtil.hardDelete(uri);
          result = isFile(uri);
          expect(result).assertFalse();
        }
      } else {
        expect().assertFail();
      }
      done();
    })
  })
}

/**
 * 日志字段封装类
 */
export interface AuditLog {
  happenTime: string;
  packageName: string;
  isForeground: boolean;
  isUserBehavior: boolean;
  cause: string;
  operationType: string;
  operationScenario: string;
  operationCount: number;
  operationStatus: string;
  extend: string;
}