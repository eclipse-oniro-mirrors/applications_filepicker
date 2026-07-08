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
import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { AbilityCommonUtil } from '@ohos/common/src/main/ets/utils/AbilityCommonUtil';
import { GlobalHolder, StartModeOptions } from '@ohos/common';

export default function AbilityCommonUtilTest() {
  describe('AbilityCommonUtilTest', () => {

    it('getPickFileNum_A', 0, () => {
      // if(true) if(true)
      let num:Number = 128;
      let result = AbilityCommonUtil.getPickFileNum(num);
      expect(result).assertEqual(128);
      // if(false)
      let test:String = 'test';
      result = AbilityCommonUtil.getPickFileNum(test);
      expect(result).assertEqual(500);
    })

    it('getPickFileNum_B', 0, () => {
      // if(true) if(false)
      let num:Number = 590;
      let result = AbilityCommonUtil.getPickFileNum(num);
      expect(result).assertEqual(500);
    })

    it('getPickFileNum_C', 0, () => {
      // if(false)
      let test:String = 'test';
      let result = AbilityCommonUtil.getPickFileNum(test);
      expect(result).assertEqual(500);
    })

    it('getKeyPickTypeList_A', 0, () => {
      // if(true) if(false)
      let num:Number = 128;
      let result = AbilityCommonUtil.getKeyPickTypeList(num,num);
      expect(result.length).assertEqual(1);
    })

    it('getKeyPickTypeList_B', 0, () => {
      // if(false) if(true)
      let nums:Number[] = [];
      let num:Number = 128;
      let result = AbilityCommonUtil.getKeyPickTypeList(nums,[num,num]);
      expect(result.length).assertEqual(2);
    })

    it('getKeyPickTypeList_C', 0, () => {
      // if(false) if(false)
      let nums:Number[] = [];
      let num:Number = 128;
      let result = AbilityCommonUtil.getKeyPickTypeList(nums[0],[]);
      expect(result.length).assertEqual(0);
    })

    it('getKeyFileSuffixFilter_A', 0, () => {
      // if(false)
      let str:string[] = [];
      let result = AbilityCommonUtil.getKeyFileSuffixFilter(str);
      expect(result.length).assertEqual(0);
    })

    it('getKeyFileSuffixFilter_B', 0, () => {
      // if(false)
      let str:string[] = [];
      str.length = 500;
      let result = AbilityCommonUtil.getKeyFileSuffixFilter(str);
      expect(result.length).assertEqual(0);
    })

    it('getKeyFileSuffixFilter_C', 0, () => {
      // if(true) if(true) if(true)
      let str2:string[] = ['test.doc', 'test.unknown', 'test.doc.docx', 'test', '.doc'];
      let result = AbilityCommonUtil.getKeyFileSuffixFilter(str2);
      expect(result.length).assertEqual(5);
    })

    it('checkFileSuffix', 0, () => {
      let str = 'string';
      let result = AbilityCommonUtil.checkFileSuffix(str);
      expect(result).assertTrue();
    })

    it('getKeyFileSuffixChoicesEmpty', 0, () => {
      // if(false)
      let str:string[] = [];
      let result = AbilityCommonUtil.getKeyFileSuffixChoices(str);
      expect(result).assertDeepEquals('');
    })

    it('getKeyFileSuffixChoicesDefault', 0, () => {
      // if(true) if(false)
      let str:string[] = [];
      str.length = 200;
      let result = AbilityCommonUtil.getKeyFileSuffixChoices(str);
      expect(result).assertDeepEquals('');
    })

    it('getKeyFileSuffixChoicesCommon', 0, () => {
      // if(true) if(true) if(true)
      let str2:string[] = ['test.doc', 'test.unknown', 'test.doc.docx', 'test', '.doc'];
      let result = AbilityCommonUtil.getKeyFileSuffixChoices(str2);
      expect(result).assertDeepEquals('test.doc');
    })

    it('getKeyFileSuffixChoices_A', 0, () => {
      // if(false)
      let str:string[] = [];
      let result = AbilityCommonUtil.getKeyFileSuffixChoices(str);
      expect(result).assertDeepEquals('');
    })

    it('getKeyFileSuffixChoices_B', 0, () => {
      let str:string[] = [];
      str.length = 200;
      let result = AbilityCommonUtil.getKeyFileSuffixChoices(str);
      expect(result).assertDeepEquals('');
    })

    it('getKeyFileSuffixChoices_C', 0, () => {
      // if(true) if(true) if(true)
      let str2:string[] = ['test.doc', 'test.unknown', 'test.doc.docx', 'test', '.doc'];
      let result = AbilityCommonUtil.getKeyFileSuffixChoices(str2);
      expect(result).assertDeepEquals('test.doc');
    })

    it('startGalleryAbilityFromPhone', 0, async () => {
      let mock = new MockKit();
      let func = mock.mockFunc(GlobalHolder, GlobalHolder.getInstance);
      when(func)(ArgumentMatchers.any).afterThrow('testError');
      let result2 = await AbilityCommonUtil.startGalleryAbilityFromPhone('', '');
      mock.clear(GlobalHolder);
      expect(result2).assertFalse();
    })

    it('startSoundRecorderAbility', 0, async () => {
      let mock = new MockKit();
      mock.mockFunc(GlobalHolder, GlobalHolder.getInstance);
      await AbilityCommonUtil.startSoundRecorderAbility('');
      mock.clear(GlobalHolder);
      mock.verify('getInstance',[]).times(1);
    })

    it('getFileDefaultPickPath_A', 0, () => {
      let startModeOptions: StartModeOptions = new StartModeOptions();
      startModeOptions.defaultFilePathUri = '';
      let result = AbilityCommonUtil.getFileDefaultPickPath(startModeOptions);
      expect(result).assertEqual('');
    })

    it('getFileDefaultPickPath_B', 0, () => {
      let startModeOptions: StartModeOptions = new StartModeOptions();
      startModeOptions.defaultFilePathUri = 'defaultDir';
      let result = AbilityCommonUtil.getFileDefaultPickPath(startModeOptions);
      expect(result).assertEqual('defaultDir');
    })

    it('getFileDefaultPickPath_C', 0, () => {
      let startModeOptions: StartModeOptions = new StartModeOptions();
      let stringDefault: string[] = [];
      startModeOptions.defaultFilePathUri = stringDefault[0];
      const result = AbilityCommonUtil.getFileDefaultPickPath(startModeOptions);
      expect(result).assertEqual('');
    })

    it('getFilePickerViewFlag', 0, () => {
      let startModeOptions: StartModeOptions = new StartModeOptions();
      startModeOptions.pickerFlag = false;
      let result = AbilityCommonUtil.getFilePickerViewFlag(startModeOptions);
      expect(result).assertFalse();
    })

    it('getFilePickerViewFlag_B', 0, () => {
      let startModeOptions: StartModeOptions = new StartModeOptions();
      startModeOptions.pickerFlag = true;
      const result = AbilityCommonUtil.getFilePickerViewFlag(startModeOptions);
      expect(result).assertTrue();
    })

    it('getFilePickerViewFlag_C', 0, () => {
      let startModeOptions: StartModeOptions = new StartModeOptions();
      let flagDefault: boolean[] = [];
      startModeOptions.pickerFlag = flagDefault[0];
      const result = AbilityCommonUtil.getFilePickerViewFlag(startModeOptions);
      expect(result).assertFalse();
    })

    it('getFileSuffixChoices_A', 0, () => {
      let startModeOptions: StartModeOptions = new StartModeOptions();
      let result = AbilityCommonUtil.getFileSuffixChoices(startModeOptions);
      expect(result).assertEqual('');
    })

    it('getFileSuffixChoices_B', 0, () => {
      let startModeOptions: StartModeOptions = new StartModeOptions();
      startModeOptions.PhoneFileSuffixChoices = 'suffix';
      const result = AbilityCommonUtil.getFileSuffixChoices(startModeOptions);
      expect(result).assertEqual('suffix');
    })

    it('getFileSuffixChoices_C', 0, () => {
      let startModeOptions: StartModeOptions = new StartModeOptions();
      let stringDefault: string[] = [];
      startModeOptions.PhoneFileSuffixChoices = stringDefault[0];
      const result = AbilityCommonUtil.getFileSuffixChoices(startModeOptions);
      expect(result).assertEqual('');
    })

    it('getPathDefaultPickDir_A', 0, () => {
      let startModeOptions: StartModeOptions = new StartModeOptions();
      let result = AbilityCommonUtil.getPathDefaultPickDir(startModeOptions);
      expect(result).assertEqual('');
    })

    it('getPathDefaultPickDir_B', 0, () => {
      let startModeOptions: StartModeOptions = new StartModeOptions();
      startModeOptions.defaultFilePathUri = 'defaultDir';
      const result = AbilityCommonUtil.getPathDefaultPickDir(startModeOptions);
      expect(result).assertEqual('defaultDir');
    })

    it('getPathDefaultPickDir_C', 0, () => {
      let startModeOptions: StartModeOptions = new StartModeOptions();
      let stringDefault: string[] = [];
      startModeOptions.defaultFilePathUri = stringDefault[0];
      const result = AbilityCommonUtil.getPathDefaultPickDir(startModeOptions);
      expect(result).assertEqual('');
    })

    it('should_start_settings_ability_successfully', 0, () => {
      let mock = new MockKit();
      mock.mockFunc(GlobalHolder, GlobalHolder.getInstance);
      AbilityCommonUtil.startSettingsAbility();
      mock.clear(GlobalHolder);
      mock.verify('getInstance',[]).times(1);
    })

    it('should_handle_error_when_start_ability_fails', 0, () => {
      let mocker: MockKit = new MockKit();
      let getUIExtensionContext: Function = mocker.mockFunc(GlobalHolder.getInstance(), GlobalHolder.getInstance().getUIExtensionContext);
      when(getUIExtensionContext)(ArgumentMatchers.any).afterThrow("Error");
      AbilityCommonUtil.startSettingsAbility();
      mocker.clear(GlobalHolder.getInstance());
      mocker.verify('getUIExtensionContext',[]).times(1);
    });
  })
}
