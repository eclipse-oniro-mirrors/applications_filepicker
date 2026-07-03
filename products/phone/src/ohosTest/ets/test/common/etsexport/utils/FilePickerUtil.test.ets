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

import {
  afterAll,
  ArgumentMatchers,
  beforeAll,
  describe,
  expect,
  it,
  MockKit,
  when
} from '@ohos/hypium';
import {
  AbilityCommonUtil,
  AssertExtUtil,
  Constant,
  FilePickerUtil,
  HiLog,
  PhoneFilePickerUtil,
  ResultCodePicker,
  StartModeOptions,
} from '@ohos/common';
import Want from '@ohos.app.ability.Want';
import { WindowType } from '@ohos/common/indexDT';
import { TestUtil } from '../../../utils/TestUtil';

const EXTERNAL_PATH = 'file://docs/storage/External/';
const INTERNAL_PATH = 'file://docs/storage/Users/currentUser/';
const APPDATA_PATH = 'file://docs/storage/Users/currentUser/appdata/';
const TAG: string = 'FilePickerUtilTest';

export default function FilePickerUtilTest() {
  describe('FilePickerUtilTest', () => {
    let isPhone = true;
    beforeAll(() => {
    });


    it('getFileSuffix_File_Test', 0, () => {
      let fileName: string = 'FilePickerUtilTest.txt';
      let suffix: string = FilePickerUtil.getFileSuffix(fileName);
      expect(suffix).assertEqual('.txt');

      fileName = 'FilePickerUtilTest';
      suffix = FilePickerUtil.getFileSuffix(fileName);
      expect(suffix).assertEqual('');
    })

    it('getFileSuffix_Empty_Test', 0, () => {
      let fileName: string = 'FilePickerUtilTest';
      let suffix: string = FilePickerUtil.getFileSuffix(fileName);
      expect(suffix).assertEqual('');
    })

    it('getFilePrefix_Normal_Test', 0, () => {
      let fileName: string = 'FilePickerUtilTest.txt';
      let prefix: string = FilePickerUtil.getFilePrefix(fileName);
      expect(prefix).assertEqual('FilePickerUtilTest');
    })

    it('getFilePrefix', 0, () => {
      let fileName: string = 'FilePickerUtilTest.doc';
      let prefix: string = FilePickerUtil.getFilePrefix(fileName);
      expect(prefix).assertEqual('FilePickerUtilTest');
    })

    it('handleMaxSelectNumber_Test', 0, (done: Function) => {
      let want: Want = {
        "deviceId": "",
        "bundleName": "com.ohos.filemanager",
        "abilityName": "FilePickerUIExtAbility",
        "moduleName": "phone",
        "uri": "",
        "type": "",
        "flags": 0,
        "action": "ohos.want.action.OPEN_FILE_SERVICE",
        "parameters": {
          "ability.want.params.uiExtensionTargetType": "filePicker",
          "ability.want.params.uiExtensionType": "sysPicker/filePicker",
          "component.startup.newRules": true,
          "extType": "filePicker",
          "key_auth_mode": false,
          "key_file_suffix_filter": ["所有文件 (*.*)|"],
          "key_is_encryption_supported": false,
          "key_merge_type_mode": 0,
          "key_mult_auth_mode": false,
          "key_pick_dir_path": "",
          "key_pick_num": 48,
          "key_select_mode": 0,
          "moduleName": "phone",
          "ohos.aafwk.param.callerAbilityName": "MainAbility",
          "ohos.aafwk.param.callerAppIdentifier": "5765880207853993265",
          "ohos.aafwk.param.callerBundleName": "com.ohos.notepad",
          "pickerType": "select",
          "startMode": "choose"
        },
        "fds": {},
        "entities": []
      };
      let options = FilePickerUtil.getStartModeOptions(want);
      options.windowType = WindowType.SERVICE;
      PhoneFilePickerUtil.terminateFilePicker([Constant.MY_PHONE_URI + '/dtdt'], ResultCodePicker.SUCCESS, options);
      expect(options.maxSelectNumber).assertEqual(48);
      done();
    })

    it('handleOpenFileMode_Test', 0, (done: Function) => {
      let want: Want = {
        "deviceId": "",
        "bundleName": "com.ohos.filemanager",
        "abilityName": "FilePickerUIExtAbility",
        "moduleName": "phone",
        "uri": "",
        "type": "",
        "flags": 0,
        "action": "ohos.want.action.OPEN_FILE_SERVICE",
        "parameters": {
          "ability.want.params.uiExtensionTargetType": "filePicker",
          "ability.want.params.uiExtensionType": "sysPicker/filePicker",
          "component.startup.newRules": true,
          "extType": "filePicker",
          "key_auth_mode": false,
          "key_file_suffix_filter": ["所有文件 (*.*)|"],
          "key_is_encryption_supported": false,
          "key_merge_type_mode": 0,
          "key_mult_auth_mode": false,
          "key_pick_dir_path": "",
          "key_pick_num": 48,
          "key_select_mode": 0,
          "moduleName": "phone",
          "ohos.aafwk.param.callerAbilityName": "MainAbility",
          "ohos.aafwk.param.callerAppIdentifier": "5765880207853993265",
          "ohos.aafwk.param.callerBundleName": "com.ohos.notepad",
          "pickerType": "select",
          "startMode": "choose"
        },
        "fds": {},
        "entities": []
      };
      let options = FilePickerUtil.getStartModeOptions(want);
      PhoneFilePickerUtil.terminateFilePicker([Constant.MY_PHONE_URI + '/dtdt'], ResultCodePicker.SUCCESS, options);
      expect(options.isOpenFileMode()).assertTrue();
      done();
    })

    it('handleAuthMode', 0, (done: Function) => {
      let want: Want = {
        "deviceId": "",
        "bundleName": "com.ohos.filemanager",
        "abilityName": "FilePickerUIExtAbility",
        "moduleName": "phone",
        "uri": "",
        "type": "",
        "flags": 0,
        "action": "ohos.want.action.OPEN_FILE_SERVICE",
        "parameters": {
          "ability.want.params.uiExtensionTargetType": "filePicker",
          "ability.want.params.uiExtensionType": "sysPicker/filePicker",
          "component.startup.newRules": true,
          "extType": "filePicker",
          "key_auth_mode": false,
          "key_file_suffix_filter": ["所有文件 (*.*)|"],
          "key_is_encryption_supported": false,
          "key_merge_type_mode": 0,
          "key_mult_auth_mode": false,
          "key_pick_dir_path": "",
          "key_pick_num": 48,
          "key_select_mode": 0,
          "moduleName": "phone",
          "ohos.aafwk.param.callerAbilityName": "MainAbility",
          "ohos.aafwk.param.callerAppIdentifier": "5765880207853993265",
          "ohos.aafwk.param.callerBundleName": "com.ohos.notepad",
          "pickerType": "select",
          "startMode": "choose"
        },
        "fds": {},
        "entities": []
      };
      let options = FilePickerUtil.getStartModeOptions(want);
      options.windowType = WindowType.UI;
      PhoneFilePickerUtil.terminateFilePicker([Constant.MY_PHONE_URI + '/dtdt'], ResultCodePicker.SUCCESS, options);
      expect(options.isAuthMode).assertFalse();
      done();
    })

    it('handleFilePickerModeErr', 0, (done: Function) => {
      let mocker: MockKit = new MockKit();
      let error: Function = mocker.mockFunc(HiLog, HiLog.error);
      when(error)(ArgumentMatchers.any).afterReturnNothing();
      let want: Want = {};
      let options = FilePickerUtil.getStartModeOptions(want);
      options.windowType = WindowType.UI;
      PhoneFilePickerUtil.terminateFilePicker([Constant.MY_PHONE_URI + '/dtdt'], ResultCodePicker.SUCCESS, options);
      mocker.ignoreMock(HiLog, HiLog.error);
      mocker.verify('error', ['FilePickerUtil', 'getDocumentSelectOptions mode is error']).once();
      done();
    })

    it('handleCreateFile', 0, (done: Function) => {
      let want: Want = {
        "deviceId": "",
        "bundleName": "com.ohos.filemanager",
        "abilityName": "FilePickerUIExtAbility",
        "moduleName": "phone",
        "uri": "",
        "type": "",
        "flags": 0,
        "action": "ohos.want.action.CREATE_FILE_SERVICE",
        "parameters": {
          "ability.want.params.uiExtensionTargetType": "filePicker",
          "ability.want.params.uiExtensionType": "sysPicker/filePicker",
          "component.startup.newRules": true,
          "extType": "filePicker",
          "key_auth_mode": false,
          "key_file_suffix_filter": ["所有文件 (*.*)|"],
          "key_is_encryption_supported": false,
          "key_merge_type_mode": 0,
          "key_mult_auth_mode": false,
          "key_pick_dir_path": "",
          "key_pick_num": 48,
          "key_select_mode": 0,
          "moduleName": "phone",
          "ohos.aafwk.param.callerAbilityName": "MainAbility",
          "ohos.aafwk.param.callerAppIdentifier": "5765880207853993265",
          "ohos.aafwk.param.callerBundleName": "com.ohos.notepad",
          "pickerType": "select",
          "startMode": "choose"
        },
        "fds": {},
        "entities": []
      };
      let options = FilePickerUtil.getStartModeOptions(want);
      options.windowType = WindowType.UI;
      AbilityCommonUtil.terminatePathPicker([Constant.MY_PHONE_URI + '/dtdt.txt'], ResultCodePicker.SUCCESS, options);
      expect(options.isCreateFileMode()).assertTrue();
      done();
    })

    it('grantPermissionUris_Uri_Empty_Test', 0, async (done: Function) => {
      const uriArr: string[] = [];
      const bundleName: string = '';
      let isNeedGrantPermission: boolean = true;

      let grantPermissionUrisFunc = TestUtil.getPrivateFunction(FilePickerUtil, 'grantPermissionUris');
      if (grantPermissionUrisFunc) {
        const result: number[] = await grantPermissionUrisFunc(uriArr, bundleName, isPhone, isNeedGrantPermission);
        expect(result).assertDeepEquals([0, 0, 0, 0, 0, 0]);
      }
      done();
    })

    it('grantPermissionUris_File_Type_Test', 0, async (done: Function) => {
      const uriArr: string[] = ['test1', 'test2'];
      const bundleName: string = '';
      let isNeedGrantPermission: boolean = true;

      let grantPermissionUrisFunc = TestUtil.getPrivateFunction(FilePickerUtil, 'grantPermissionUris');
      if (grantPermissionUrisFunc) {
        const result: number[] =
          await grantPermissionUrisFunc(uriArr, bundleName, isPhone, isNeedGrantPermission);
        expect(result).assertDeepEquals([0,0,0,0,0,2]);
      } else {
        expect().assertFail();
      }
      done();
    })

    it('grantPermissionUris_Audio_Type_Test', 0, async (done: Function) => {
      const bundleName: string = '';
      let isNeedGrantPermission: boolean = true;

      let grantPermissionUrisFunc = TestUtil.getPrivateFunction(FilePickerUtil, 'grantPermissionUris');
      if (grantPermissionUrisFunc) {
        const result: number[] =
          await grantPermissionUrisFunc(['test.wav'], bundleName, isPhone, isNeedGrantPermission);
        expect(result).assertDeepEquals([0, 1, 0, 0, 0, 0]);
      } else {
        expect().assertFail();
      }
      done();
    })

    it('grantPermissionUris_Image_Type_Test', 0, async (done: Function) => {
      const bundleName: string = '';
      let isNeedGrantPermission: boolean = true;

      let grantPermissionUrisFunc = TestUtil.getPrivateFunction(FilePickerUtil, 'grantPermissionUris');
      if (grantPermissionUrisFunc) {
        const result: number[] =
          await grantPermissionUrisFunc(['test.jpg'], bundleName, isPhone, isNeedGrantPermission);
        expect(result).assertDeepEquals([0, 0, 0, 1, 0, 0]);
      } else {
        expect().assertFail();
      }
      done();
    })

    it('grantPermissionUris_Video_Type_Test', 0, async (done: Function) => {
      const bundleName: string = '';
      let isPhone: boolean = true;
      let isNeedGrantPermission: boolean = true;

      let grantPermissionUrisFunc = TestUtil.getPrivateFunction(FilePickerUtil, 'grantPermissionUris');
      if (grantPermissionUrisFunc) {
        const result: number[] =
          await grantPermissionUrisFunc(['test.mp4'], bundleName, isPhone, isNeedGrantPermission);
        expect(result).assertDeepEquals([0, 0, 0, 1, 0, 0]);
      } else {
        expect().assertFail();
      }
      done();
    })

    it('grantPermissionUris_File_Type_Mock_Test', 0, async (done: Function) => {
      const uriArr: string[] = ['test1', 'test2'];
      const bundleName: string = '';
      let isPhone: boolean = true;
      let isNeedGrantPermission: boolean = true;

      let grantPermissionUrisFunc = TestUtil.getPrivateFunction(FilePickerUtil, 'grantPermissionUris');
      if (grantPermissionUrisFunc) {
        const mocker: MockKit = new MockKit();
        const grantPhonePermissionUri = mocker.mockFunc(FilePickerUtil, FilePickerUtil.grantPhonePermissionUri);
        when(grantPhonePermissionUri)(ArgumentMatchers.any).afterReturn(true);
        const result: number[] = await grantPermissionUrisFunc(uriArr, bundleName, isPhone, isNeedGrantPermission);
        mocker.clear(FilePickerUtil);
        expect(result).assertDeepEquals([0,0,0,0,2,0]);
      } else {
        expect().assertFail();
      }
      done();
    })

    it('grantPermissionUris_Audio_Type_Mock_Test', 0, async (done: Function) => {
      const bundleName: string = '';
      let isPhone: boolean = true;
      let isNeedGrantPermission: boolean = true;

      let grantPermissionUrisFunc = TestUtil.getPrivateFunction(FilePickerUtil, 'grantPermissionUris');
      if (grantPermissionUrisFunc) {
        const mocker: MockKit = new MockKit();
        const grantPhonePermissionUri = mocker.mockFunc(FilePickerUtil, FilePickerUtil.grantPhonePermissionUri);
        when(grantPhonePermissionUri)(ArgumentMatchers.any).afterReturn(true);
        const result: number[] =
          await grantPermissionUrisFunc(['test.wav'], bundleName, isPhone, isNeedGrantPermission);
        mocker.clear(FilePickerUtil);
        expect(result).assertDeepEquals([1,0,0,0,0,0]);
      } else {
        expect().assertFail();
      }
      done();
    })

    it('grantPermissionUris_Image_Type_Mock_Test', 0, async (done: Function) => {
      const bundleName: string = '';
      let isPhone: boolean = true;
      let isNeedGrantPermission: boolean = true;

      let grantPermissionUrisFunc = TestUtil.getPrivateFunction(FilePickerUtil, 'grantPermissionUris');
      if (grantPermissionUrisFunc) {
        const mocker: MockKit = new MockKit();
        const grantPhonePermissionUri = mocker.mockFunc(FilePickerUtil, FilePickerUtil.grantPhonePermissionUri);
        when(grantPhonePermissionUri)(ArgumentMatchers.any).afterReturn(true);
        const result: number[] =
          await grantPermissionUrisFunc(['test.jpg'], bundleName, isPhone, isNeedGrantPermission);
        mocker.clear(FilePickerUtil);
        expect(result).assertDeepEquals([0,0,1,0,0,0]);
      } else {
        expect().assertFail();
      }
      done();
    })

    it('grantPermissionUris_Video_Type_Mock_Test', 0, async (done: Function) => {
      const bundleName: string = '';
      let isPhone: boolean = true;
      let isNeedGrantPermission: boolean = true;

      let grantPermissionUrisFunc = TestUtil.getPrivateFunction(FilePickerUtil, 'grantPermissionUris');
      if (grantPermissionUrisFunc) {
        const mocker: MockKit = new MockKit();
        const grantPhonePermissionUri = mocker.mockFunc(FilePickerUtil, FilePickerUtil.grantPhonePermissionUri);
        when(grantPhonePermissionUri)(ArgumentMatchers.any).afterReturn(true);
        const result: number[] =
          await grantPermissionUrisFunc(['test.mp4'], bundleName, isPhone, isNeedGrantPermission);
        mocker.clear(FilePickerUtil);
        expect(result).assertDeepEquals([0,0,1,0,0,0]);
      } else {
        expect().assertFail();
      }
      done();
    })

    it('returnAbilityResultWithContext001', 0, async (done: Function)=> {
      const mocker: MockKit = new MockKit();
      mocker.mockFunc(FilePickerUtil, FilePickerUtil.returnAbilityResult);
      const want: Want = {};
      const resultCode: number = 0;
      const options: StartModeOptions = new StartModeOptions();
      await FilePickerUtil.returnAbilityResultWithContext(want, resultCode, options);
      mocker.clear(FilePickerUtil);
      mocker.verify('returnAbilityResult', [want, resultCode, options]).once();
      done();
    })

    it('batchGrantUriPermissionNormal', 0, async (done: Function) => {
      let udkey =
        await FilePickerUtil.batchGrantUriPermission(['file://docs/storage/Users/currentUser/test',
          'file://docs/storage/Users/currentUser/test2'], 1);
      expect(udkey).not().assertNull();
      done();
    })

    it('batchGrantUriPermissionEmptyUdkey', 0, async (done: Function) => {
      const mocker: MockKit = new MockKit();
      let insertFunction = TestUtil.getPrivateMockFunction(mocker, FilePickerUtil, 'insertDataToUdmf');
      when(insertFunction)(ArgumentMatchers.any).afterReturn('');
      let udkey =
        await FilePickerUtil.batchGrantUriPermission(['file://docs/storage/Users/currentUser/test'], 1);
      expect(udkey).assertEqual('');
      mocker.clear(FilePickerUtil);
      mocker.ignoreMock(FilePickerUtil, insertFunction);
      done();
    })

    it('batchGrantUriPermissionInvalidUris', 0, async (done: Function) => {
      let uris = [];
      let udkey =
        await FilePickerUtil.batchGrantUriPermission(uris[0], 1);
      expect(udkey).assertEqual('');
      done();
    })

    it('getBatchAuthUrisByUdkey', 0, async (done: Function) => {
      let udkey =
        await FilePickerUtil.batchGrantUriPermission(['file://docs/storage/Users/currentUser/test',
          'file://docs/storage/Users/currentUser/test2'], 1);
      let result = await FilePickerUtil.getBatchAuthUrisByUdkey(udkey);
      expect(result.length).assertEqual(2);
      expect(result[0]).assertEqual('file://docs/storage/Users/currentUser/test');
      expect(result[1]).assertEqual('file://docs/storage/Users/currentUser/test2');
      done();
    })
  })
}
