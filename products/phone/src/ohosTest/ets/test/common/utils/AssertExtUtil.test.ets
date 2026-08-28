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
import { VirtualUri, AssertExtUtil, StringUtil, FsUtil } from '@ohos/common';
import { FileUriUtil } from '@ohos/common/indexDT';
import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { OpenFolderData, SendData } from '../../../../../main/ets/base/extension/model/SendDataModel';

export default function AssertExtUtilTest() {
  describe('AssertExtUtilTest', () => {
    it('checkUriTrusted0_Test', 0, () => {
      let result = AssertExtUtil.checkUriTrusted('file://docs/storage/Users/currentUser./Download');
      expect(result.length > 0).assertTrue();
    })

    it('checkUriTrusted1_Test', 0, () => {
      let result = AssertExtUtil.checkUriTrusted('file://docs/storage/Users/currentUser../Download');
      expect(result.length > 0).assertTrue();
    })

    it('checkUriTrusted2_Test', 0, () => {
      let result = AssertExtUtil.checkUriTrusted('file://docs/storage/Users/currentUser%00/Download');
      expect(result.length > 0).assertTrue();
    })

    it('checkUriTrusted3_Test', 0, () => {
      let result = AssertExtUtil.checkUriTrusted('file://docs/storage/Users/currentUser.\\.\\/Download');
      expect(result.length > 0).assertTrue();
    })

    it('checkUriTrusted4_Test', 0, () => {
      let result = AssertExtUtil.checkUriTrusted('file://docs/storage/Users/currentUser/Download');
      expect(result.length === 0).assertTrue();
    })

    it('checkIsForbiddenUri', 0, () => {
      let mock = new MockKit();
      let func_isForbiddenVisitUri = mock.mockFunc(FileUriUtil, FileUriUtil.isForbiddenVisitUri);
      when(func_isForbiddenVisitUri)(ArgumentMatchers.any).afterReturn(true);
      let result = AssertExtUtil.checkIsForbiddenUri('testUri');
      expect(result).assertTrue();

      when(func_isForbiddenVisitUri)(ArgumentMatchers.any).afterReturn(false);
      result = AssertExtUtil.checkIsForbiddenUri('testUri');
      mock.clear(FileUriUtil);
      expect(result).assertFalse();
    })

    it('checkIsForbiddenUri_not_string_param', 0, () => {
      let str: string =
        '{"data":{"folderUri":16.024397481573672,"from":"thirdApp","operationType":"openFolder"},"event":"openFolder"}';
      let sendData: SendData = JSON.parse(str) as SendData;
      let param: OpenFolderData = sendData.data as OpenFolderData;
      let result = AssertExtUtil.checkIsForbiddenUri(param.folderUri as string);
      expect(result).assertTrue();
    })

    it('checkIsForbiddenUri_untrustedPath', 0, () => {
      let mock = new MockKit();
      let func_isForbiddenVisitUri = mock.mockFunc(FileUriUtil, FileUriUtil.isForbiddenVisitUri);
      when(func_isForbiddenVisitUri)(ArgumentMatchers.any).afterReturn(true);
      let result = AssertExtUtil.checkIsForbiddenUri('testUri/../test');
      mock.clear(FileUriUtil);
      expect(result).assertTrue();
    })

    it('checkUriTrustedBatch', 0, () => {
      let urisTrue = [VirtualUri.MY_PC + '/Download', VirtualUri.MY_PC, VirtualUri.MY_PC];
      let urisUnTrusted = [VirtualUri.MY_PC + './a.txt', VirtualUri.MY_PC, VirtualUri.MY_PC];
      let urisTrue2 = [VirtualUri.MY_PC + '/Download1', VirtualUri.MY_PC, VirtualUri.MY_PC];
      expect(AssertExtUtil.checkUriTrustedBatch(urisTrue) === '').assertTrue();
      expect(AssertExtUtil.checkUriTrustedBatch(urisTrue2) === '').assertTrue();
      expect(AssertExtUtil.checkUriTrustedBatch(urisUnTrusted) === ' uri is Untrusted').assertTrue();
      expect(AssertExtUtil.checkUriTrustedBatch([])).assertEqual('');
    })

    it('checkUriExist_0_test', 0, () => {
      let mock = new MockKit();
      let func_checkUriTrusted = mock.mockFunc(AssertExtUtil, AssertExtUtil.checkUriTrusted);
      let func_isFileExist = mock.mockFunc(FsUtil, FsUtil.isFileExist);
      when(func_checkUriTrusted)(ArgumentMatchers.any).afterReturn('');
      when(func_isFileExist)(ArgumentMatchers.any).afterReturn(false);
      let result = AssertExtUtil.checkUriExist('testUri');
      mock.clear(AssertExtUtil);
      mock.clear(FsUtil);
      expect(result).assertEqual(' uri is Not Exist');
    })

    it('checkUriExist_1_test', 0, () => {
      let mock = new MockKit();
      let func_checkUriTrusted = mock.mockFunc(AssertExtUtil, AssertExtUtil.checkUriTrusted);
      let func_isFileExist = mock.mockFunc(FsUtil, FsUtil.isFileExist);
      when(func_checkUriTrusted)(ArgumentMatchers.any).afterReturn('testError');
      when(func_isFileExist)(ArgumentMatchers.any).afterReturn(true);
      let result = AssertExtUtil.checkUriExist('testUri');
      mock.clear(AssertExtUtil);
      mock.clear(FsUtil);
      expect(result).assertEqual('testError');
    })

    it('checkUriAccess_0_test', 0, () => {
      let mock = new MockKit();
      let func_checkUriTrusted = mock.mockFunc(AssertExtUtil, AssertExtUtil.checkUriTrusted);
      let func_allowAccessPathExt = mock.mockFunc(AssertExtUtil, AssertExtUtil.allowAccessPathExt);
      when(func_checkUriTrusted)(ArgumentMatchers.any).afterReturn('');
      when(func_allowAccessPathExt)(ArgumentMatchers.any).afterReturn(false);
      let result = AssertExtUtil.checkUriAccess('testUri');
      expect(result).assertEqual(' uri is No Permission');
      mock.clear(AssertExtUtil);
    })

    it('checkUriAccess_1_test', 0, () => {
      let mock = new MockKit();
      let func_checkUriTrusted = mock.mockFunc(AssertExtUtil, AssertExtUtil.checkUriTrusted);
      let func_allowAccessPathExt = mock.mockFunc(AssertExtUtil, AssertExtUtil.allowAccessPathExt);
      when(func_checkUriTrusted)(ArgumentMatchers.any).afterReturn('testError');
      when(func_allowAccessPathExt)(ArgumentMatchers.any).afterReturn(true);
      let result = AssertExtUtil.checkUriAccess('testUri');
      expect(result).assertEqual('testError');
      mock.clear(AssertExtUtil);
    })

    it('checkUri_0_test', 0, () => {
      let mock = new MockKit();
      let func_isEmpty = mock.mockFunc(StringUtil, StringUtil.isEmpty);
      let func_allowAccessPathExt = mock.mockFunc(AssertExtUtil, AssertExtUtil.allowAccessPathExt);
      let func_isFileExist = mock.mockFunc(FsUtil, FsUtil.isFileExist);

      when(func_isEmpty)(ArgumentMatchers.any).afterReturn(true);
      when(func_allowAccessPathExt)(ArgumentMatchers.any).afterReturn(false);
      when(func_isFileExist)(ArgumentMatchers.any).afterReturn(true);
      let result = AssertExtUtil.checkUri(VirtualUri.MY_PC + '/Download');

      mock.clear(StringUtil);
      mock.clear(AssertExtUtil);
      mock.clear(FsUtil);
      expect(result).assertEqual(' uri is No Permission');
    })

    it('checkUri_1_test', 0, () => {
      let mock = new MockKit();
      let func_isEmpty = mock.mockFunc(StringUtil, StringUtil.isEmpty);
      let func_allowAccessPathExt = mock.mockFunc(AssertExtUtil, AssertExtUtil.allowAccessPathExt);
      let func_isFileExist = mock.mockFunc(FsUtil, FsUtil.isFileExist);

      when(func_isEmpty)(ArgumentMatchers.any).afterReturn(true);
      when(func_allowAccessPathExt)(ArgumentMatchers.any).afterReturn(true);
      when(func_isFileExist)(ArgumentMatchers.any).afterReturn(false);
      let result = AssertExtUtil.checkUri(VirtualUri.MY_PC + '/Download');

      mock.clear(StringUtil);
      mock.clear(AssertExtUtil);
      mock.clear(FsUtil);
      expect(result).assertEqual(' uri is Not Exist');
    })

    it('checkUriBatch_0_test', 0, () => {
      let uris: string[] = [];
      let result = AssertExtUtil.checkUriBatch(uris);
      expect(result).assertEqual('');
    })

    it('checkUriBatch_1_test', 0, () => {
      let uris: string[] = [];
      let mock = new MockKit();
      let func_checkUri = mock.mockFunc(AssertExtUtil, AssertExtUtil.checkUri);
      when(func_checkUri)(ArgumentMatchers.any).afterReturn('testError');
      uris = ['testUri'];
      const result = AssertExtUtil.checkUriBatch(uris);
      expect(result).assertEqual('testError');
      mock.clear(AssertExtUtil);
    })

    it('checkUriBatch_2_test', 0, () => {
      let uris: string[] = [];
      let mock = new MockKit();
      let func_checkUri = mock.mockFunc(AssertExtUtil, AssertExtUtil.checkUri);
      uris = ['testUri'];
      when(func_checkUri)(ArgumentMatchers.any).afterReturn('');
      const result = AssertExtUtil.checkUriBatch(uris);
      expect(result).assertEqual('');
      mock.clear(AssertExtUtil);
    })

    it('trustedPathExt_empty', 0, () => {
      let uri = '';
      let result = AssertExtUtil.trustedPathExt(uri);
      expect(result).assertTrue();
    })

    it('trustedPathExt_invalid', 0, () => {
      let uri = '%00';
      let result = AssertExtUtil.trustedPathExt(uri);
      expect(result).assertFalse();
    })

    it('trustedPathExt_normal', 0, () => {
      let uri = 'uri';
      let result = AssertExtUtil.trustedPathExt(uri);
      expect(result).assertTrue();
    })

    it('allowAccessPathExt', 0, () => {
      let uri = '';
      let result = AssertExtUtil.allowAccessPathExt(uri);
      expect(result).assertTrue();
      uri = 'string';
      result = AssertExtUtil.allowAccessPathExt(uri);
      expect(result).assertFalse();
    })

    it('checkIsError', 0, () => {
      let resEmpty = '';
      expect(AssertExtUtil.checkIsError('TAG', resEmpty)).assertFalse();
      let resString = '123';
      expect(AssertExtUtil.checkIsError('TAG', resString)).assertTrue();
    })

    it('coverToString', 0, () => {
      let resNull = null;
      expect(AssertExtUtil.coverToString(resNull, 'resNull') === '').assertTrue();
      let resUndefined = undefined;
      expect(AssertExtUtil.coverToString(resUndefined, 'resUndefined') === '').assertTrue();
      let resNumber = 0;
      expect(AssertExtUtil.coverToString(resNumber, 'resNumber') === '').assertTrue();
      let resEmpty = '';
      expect(AssertExtUtil.coverToString(resEmpty, 'resEmpty') === '').assertTrue();
      let resObject = new AssertExtUtil;
      expect(AssertExtUtil.coverToString(resObject, 'resObject') === '').assertTrue();
      let resString = '123';
      expect(AssertExtUtil.coverToString(resString, 'resString') === '123').assertTrue();
    })
  })
}