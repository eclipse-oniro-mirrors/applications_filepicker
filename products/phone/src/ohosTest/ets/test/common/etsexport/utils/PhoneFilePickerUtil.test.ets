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
  Constant,
  FilePickerUtil,
  GlobalHolder,
  GlobalKey,
  ResultCodePicker,
  StartModeOptions,
  FileInfo,
  PhoneFilePickerUtil,
  AppConfig,
  HiLog,
  UEUtil,
  DFX
} from '@ohos/common';
import { describe, expect, it, MockKit } from '@ohos/hypium';

export default function PhoneFilePickerUtilTest() {

  describe("PhoneFilePickerUtilTest", () => {
    it("checkPickNumExceed0_Test", 0, () => {
      let item: FileInfo = new FileInfo();
      let startModeOptions: StartModeOptions = new StartModeOptions();
      startModeOptions.pickerFlag = false;
      let result = PhoneFilePickerUtil.checkPickNumExceed(item, 1, startModeOptions);
      expect(result).assertFalse();
    })

    it("checkPickNumExceed1_Test", 0, () => {
      let item: FileInfo = new FileInfo();
      let startModeOptions: StartModeOptions = new StartModeOptions();
      startModeOptions.pickerFlag = true;
      item.isChecked = true;
      let result = PhoneFilePickerUtil.checkPickNumExceed(item, 1, startModeOptions);
      expect(result).assertFalse();
    })

    it("checkPickNumExceed2_Test", 0, () => {
      let item: FileInfo = new FileInfo();
      let startModeOptions: StartModeOptions = new StartModeOptions();
      startModeOptions.pickerFlag = true;
      item.isChecked = false;
      startModeOptions.maxSelectNumber = 2;
      let result2 = PhoneFilePickerUtil.checkPickNumExceed(item, 1, startModeOptions);
      expect(result2).assertFalse();
    })

    it("checkPickNumExceed3_Test", 0, () => {
      let item: FileInfo = new FileInfo();
      let startModeOptions: StartModeOptions = new StartModeOptions();
      startModeOptions.pickerFlag = true;
      item.isChecked = false;
      startModeOptions.maxSelectNumber = 2;
      let result3 = PhoneFilePickerUtil.checkPickNumExceed(item, 3, startModeOptions);
      expect(result3).assertTrue();
    })

    it("checkFileCanPick1_Test", 0, () => {
      const item = new FileInfo();
      const startModeOptions = new StartModeOptions();
      // 测试批量授权模式
      startModeOptions.isBatchAuthMode = true;
      expect(PhoneFilePickerUtil.checkFileCanPick(item, 0, false, startModeOptions)).assertTrue();
    });

    it("checkFileCanPick2_Test", 0, () => {
      const item = new FileInfo();
      const startModeOptions = new StartModeOptions();
      startModeOptions.isBatchAuthMode = false;
      AppStorage.delete('isUploadPicker');

      // 测试文件大小限制
      startModeOptions.callerBundleName = Constant.FILE_MANAGER_BUNDLE_NAME;
      item.size = 2097152001; // 超过2G
      expect(PhoneFilePickerUtil.checkFileCanPick(item, 0, false, startModeOptions)).assertFalse();
      expect(PhoneFilePickerUtil.checkFileCanPick(item, 0, true, startModeOptions)).assertFalse();
    });

    it("checkFileCanPick3_Test", 0, () => {
      const item = new FileInfo();
      const startModeOptions = new StartModeOptions();
      startModeOptions.isBatchAuthMode = false;
      AppStorage.delete('isUploadPicker');

      // 测试文件大小限制
      startModeOptions.callerBundleName = Constant.FILE_MANAGER_BUNDLE_NAME;
      item.size = 0;
      expect(PhoneFilePickerUtil.checkFileCanPick(item, 0, false, startModeOptions)).assertFalse();
      expect(PhoneFilePickerUtil.checkFileCanPick(item, 0, true, startModeOptions)).assertFalse();
    });

    it("checkFileCanPick4_Test", 0, () => {
      const item = new FileInfo();
      const startModeOptions = new StartModeOptions();
      startModeOptions.isBatchAuthMode = false;
      AppStorage.delete('isUploadPicker');

      // 测试文件大小限制
      startModeOptions.callerBundleName = Constant.FILE_MANAGER_BUNDLE_NAME;
      // 测试文件数量限制
      item.size = 100;
      item.isChecked = true;
      startModeOptions.maxSelectNumber = 100;
      expect(PhoneFilePickerUtil.checkFileCanPick(item, 2, false, startModeOptions)).assertTrue();
    });

    it("checkFileCanPick5_Test", 0, () => {
      const item = new FileInfo();
      const startModeOptions = new StartModeOptions();
      startModeOptions.isBatchAuthMode = false;
      AppStorage.delete('isUploadPicker');

      // 测试文件大小限制
      startModeOptions.callerBundleName = Constant.FILE_MANAGER_BUNDLE_NAME;
      // 测试文件数量限制
      item.size = 100;
      startModeOptions.maxSelectNumber = 100;
      item.isChecked = false;
      startModeOptions.pickerFlag = true;
      expect(PhoneFilePickerUtil.checkFileCanPick(item, 200, true, startModeOptions)).assertFalse();
    });

    it("filterListByFileType_Flag_True_Test", 0, () => {
      let startModeOptions: StartModeOptions = new StartModeOptions();
      startModeOptions.pickerFlag = false;
      let fileDataList = [];
      let result = PhoneFilePickerUtil.filterListByFileType(fileDataList, startModeOptions);
      expect(result).assertEqual(fileDataList);
    })

    it("filterListByFileType_Flag_False_Test", 0, () => {
      let startModeOptions: StartModeOptions = new StartModeOptions();
      let fileDataList = [];
      startModeOptions.pickerFlag = true;
      let result = PhoneFilePickerUtil.filterListByFileType(fileDataList, startModeOptions);
      expect(result).assertEqual(fileDataList);
    })

    it('handleCheckFileType', 0, (done: Function) => {
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
      expect(PhoneFilePickerUtil.checkFileType(new FileInfo(), options)).assertTrue();
      done();
    })

    it('handleCheckFileTypeWithEmptyName', 0, (done: Function) => {
      let options = new StartModeOptions();
      options.isBatchAuthMode = false;
      options.pickerFlag = true;
      expect(PhoneFilePickerUtil.checkFileType(new FileInfo(), options)).assertFalse();
      done();
    })

    it('handleCheckFileTypeWithFolder', 0, (done: Function) => {
      let options = new StartModeOptions();
      options.selectMode = Constant.SELECT_MODE.FOLDER;
      options.isBatchAuthMode = false;
      options.pickerFlag = true;
      let fileInfo: FileInfo = new FileInfo();
      fileInfo.fileName = 'ha';
      fileInfo.isFolder = true;
      expect(PhoneFilePickerUtil.checkFileType(fileInfo, options)).assertTrue();
      done();
    })

    it('handleCheckFileTypeSelectFileInFolderMode', 0, (done: Function) => {
      let options = new StartModeOptions();
      options.selectMode = Constant.SELECT_MODE.FOLDER;
      options.isBatchAuthMode = false;
      options.pickerFlag = true;
      let fileInfo: FileInfo = new FileInfo();
      fileInfo.fileName = 'ha';
      expect(PhoneFilePickerUtil.checkFileType(fileInfo, options)).assertFalse();
      done();
    })

    it('handleCheckFileTypeInMixMode', 0, (done: Function) => {
      let options = new StartModeOptions();
      options.selectMode = Constant.SELECT_MODE.MIX;
      options.isBatchAuthMode = false;
      options.pickerFlag = true;
      let fileInfo: FileInfo = new FileInfo();
      fileInfo.fileName = 'ha';
      fileInfo.isFolder = true;
      expect(PhoneFilePickerUtil.checkFileType(fileInfo, options)).assertTrue();
      done();
    })

    it('handleCheckFileTypeSaveFolderWithFileMode', 0, (done: Function) => {
      let options = new StartModeOptions();
      options.selectMode = Constant.SELECT_MODE.FILE;
      options.isBatchAuthMode = false;
      options.pickerFlag = true;
      let fileInfo: FileInfo = new FileInfo();
      fileInfo.fileName = 'ha';
      fileInfo.isFolder = true;
      expect(PhoneFilePickerUtil.checkFileType(fileInfo, options)).assertFalse();
      done();
    })

    it('handleCheckFileTypeCheckIsWildCard', 0, (done: Function) => {
      let options = new StartModeOptions();
      options.selectMode = Constant.SELECT_MODE.FILE;
      options.isBatchAuthMode = false;
      options.pickerFlag = true;
      options.fileSuffixFilters = ['.mp3'];
      let fileInfo: FileInfo = new FileInfo();
      fileInfo.fileName = 'ha.mp3';
      expect(PhoneFilePickerUtil.checkFileType(fileInfo, options)).assertFalse();
      done();
    })

    it('checkFileTypeTest001_Test', 0, () => {
      let startModeOptions: StartModeOptions = new StartModeOptions();
      startModeOptions.pickerFlag = true;
      startModeOptions.phonePickerTypeList = [];
      let item: FileInfo = new FileInfo();
      item.fileName = 'Test';
      item.isFolder = false;
      let result = PhoneFilePickerUtil.checkFileType(item, startModeOptions);
      expect(result).assertTrue();
    })

    it('checkFileTypeTest002_Test', 0, () => {
      let startModeOptions: StartModeOptions = new StartModeOptions();
      startModeOptions.pickerFlag = true;
      startModeOptions.phonePickerTypeList = ['*'];
      let item: FileInfo = new FileInfo();
      item.fileName = 'Test';
      item.isFolder = false;
      let result1 = PhoneFilePickerUtil.checkFileType(item, startModeOptions);
      startModeOptions.phonePickerTypeList = ['*/*'];
      let result2 = PhoneFilePickerUtil.checkFileType(item, startModeOptions);
      expect(result1).assertTrue();
      expect(result2).assertTrue();
    })

    it('checkFileTypeTest003_Test', 0, () => {
      let startModeOptions: StartModeOptions = new StartModeOptions();
      startModeOptions.pickerFlag = true;
      startModeOptions.phonePickerTypeList = ['video/mp4'];
      let item: FileInfo = new FileInfo();
      item.fileName = 'Test.mp4';
      item.isFolder = false;
      let result1 = PhoneFilePickerUtil.checkFileType(item, startModeOptions);
      item.fileName = 'Test.mp4dhyfcgsdyufcguaytgdyutafg';
      let result2 = PhoneFilePickerUtil.checkFileType(item, startModeOptions);
      expect(result1).assertTrue();
      expect(result2).assertFalse();
    })

    it('terminateFilePicker001_Test', 0, async (done: Function) => {
      const mocker: MockKit = new MockKit();
      mocker.mockFunc(FilePickerUtil, FilePickerUtil.getPickerSelectMode);
      await PhoneFilePickerUtil.terminateFilePicker([], ResultCodePicker.SUCCESS, new StartModeOptions());
      mocker.clear(FilePickerUtil);
      mocker.verify('getPickerSelectMode', [[]]).never();
      done();
    })

    it('terminateFilePicker002_Test', 0, async (done: Function) => {
      const mocker: MockKit = new MockKit();
      mocker.mockFunc(UEUtil, UEUtil.reportPickerOper);
      const result: string[] = ['file://media/example.txt', 'file://example.txt'];
      let startModeOptions = new StartModeOptions();
      await PhoneFilePickerUtil.terminateFilePicker(result, ResultCodePicker.SUCCESS, startModeOptions);
      mocker.clear(UEUtil);
      mocker.verify('reportPickerOper',
        [DFX.PickerMode.FILE_PICKER, result.length, startModeOptions.callerBundleName]).once();
      done();
    })
  })
}

function checkFileTypeTest(): void {
  let startModeOptions: StartModeOptions = new StartModeOptions();
  startModeOptions.pickerFlag = false;
  let item: FileInfo = new FileInfo();
  let result = PhoneFilePickerUtil.checkFileType(item, startModeOptions);
  expect(result).assertTrue();

  startModeOptions.pickerFlag = true;
  let result1 = PhoneFilePickerUtil.checkFileType(item, startModeOptions);
  expect(result1).assertFalse();
  item.fileName = 'test.txt';
  GlobalHolder.getInstance().setObject<number>(GlobalKey.PICK_SELECT_MODE, Constant.SELECT_MODE.FILE);
  item.isFolder = true;
  let result2 = PhoneFilePickerUtil.checkFileType(item, startModeOptions);
  expect(result2).assertFalse();

  GlobalHolder.getInstance().setObject<number>(GlobalKey.PICK_SELECT_MODE, Constant.SELECT_MODE.FOLDER);
  let result3 = PhoneFilePickerUtil.checkFileType(item, startModeOptions);
  expect(result3).assertTrue();

  GlobalHolder.getInstance().setObject<number>(GlobalKey.PICK_SELECT_MODE, Constant.SELECT_MODE.MIX);
  let result4 = PhoneFilePickerUtil.checkFileType(item, startModeOptions);
  expect(result4).assertTrue();

  item.isFolder = false;
  let result5 = PhoneFilePickerUtil.checkFileType(item, startModeOptions);
  expect(result5).assertTrue();
}

