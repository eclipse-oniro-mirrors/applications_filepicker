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
import { Constant, DisplayUtil,
  FileSourceUri,
  getDialogAlignment,
  GlobalHolder,
  isFastClick, LanguageUtil, renderSize } from '@ohos/common';
import { describe, beforeEach, afterEach, expect, it, MockKit, when } from '@ohos/hypium';
import { getRootFolderInstruction, getResourceString } from '@ohos/common/src/main/ets/utils/Tools';
import { resourceManager } from '@kit.LocalizationKit';

export default function ToolsTest() {
  describe('ToolsTest', () => {

    beforeEach(() => {

    });

    afterEach(() => {

    });


    it('isFastClickTest', 0, () => {
      isFastClick(100);
      let result = isFastClick(100);
      expect(result).assertEqual(true);

      const timer = setTimeout(()=>{
        result = isFastClick(100);
        clearTimeout(timer);
        expect(result).assertEqual(false);
      }, 200)
    });

    it('should_return_0_B_when_fileSize_is_0', 0, () => {
      const result = renderSize(0);
      expect(result).assertEqual('0 B');
    });

    it('should_return_1023_00_B_when_fileSize_is_less_than_1024_and_carry_is_1024', 0, () => {
      const result = renderSize(1023, 1024);
      expect(result).assertEqual('1023.00 B');
    });

    it('should_return_1_00_KB_when_fileSize_is_1024_and_carry_is_1024', 0, () => {
      const result = renderSize(1024, 1024);
      expect(result).assertEqual('1.00 KB');
    });

    it('should_return_1_00_MB_when_fileSize_is_1024_KB_and_carry_is_1024', 0, () => {
      const result = renderSize(1024 * 1024, 1024);
      expect(result).assertEqual('1.00 MB');
    });

    it('should_return_1_00_GB_when_fileSize_is_1024_MB_and_carry_is_1024', 0, () => {
      const result = renderSize(1024 * 1024 * 1024, 1024);
      expect(result).assertEqual('1.00 GB');
    });

    it('should_return_1_00_TB_when_fileSize_is_1024_TB_and_carry_is_1024', 0, () => {
      const result = renderSize(1024 * 1024 * 1024 * 1024, 1024);
      expect(result).assertEqual('1.00 TB');
    });

    it('should_return_1_00_PB_when_fileSize_is_1024_X5_and_carry_is_1024', 0, () => {
      const result = renderSize(1024 * 1024 * 1024 * 1024 * 1024, 1024);
      expect(result).assertEqual('1.00 PB');
    });

    it('should_return_1_00_EB_when_fileSize_is_1024_X6_and_carry_is_1024', 0, () => {
      const result = renderSize(1024 * 1024 * 1024 * 1024 * 1024 * 1024, 1024);
      expect(result).assertEqual('1.00 EB');
    });

    it('should_return_1_00_ZB_when_fileSize_is_1024_X7_and_carry_is_1024', 0, () => {
      const result = renderSize(1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024, 1024);
      expect(result).assertEqual('1.00 ZB');
    });

    it('should_return_1_ZB_when_fileSize_is_1024_X7_and_carry_is_1024_and_isTotalSize_is_true', 0, () => {
      const result = renderSize(1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024, 1024, true);
      expect(result).assertEqual('1 ZB');
    });

    it('should_throw_error_when_fileSize_exceed_the_maximum_unit', 0, () => {
      const testError: Function = () => {
        renderSize(1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024, 1024, true);
      };
      // assertThrowError 验证行为不能带括号，目前想要传递参数就另行封装一个空参方法，再转而测试这个空参方法
      expect(testError).assertThrowError('Exceeding the maximum storage unit');
    });

    it('should_return_1_EB_when_fileSize_is_1024_X6_and_carry_is_1024', 0, () => {
      const result = renderSize(1024 * 1024 * 1024 * 1024 * 1024 * 1024, 1024, true);
      expect(result).assertEqual('1 EB');
    });

    it('should_return_1_PB_when_fileSize_is_1024_X5_and_carry_is_1024', 0, () => {
      const result = renderSize(1024 * 1024 * 1024 * 1024 * 1024, 1024, true);
      expect(result).assertEqual('1 PB');
    });

    it('should_return_1_TB_when_fileSize_is_1024_TB_and_carry_is_1024', 0, () => {
      const result = renderSize(1024 * 1024 * 1024 * 1024, 1024, true);
      expect(result).assertEqual('1 TB');
    });

    it('should_return_1_GB_when_fileSize_is_1024_X3_and_carry_is_1024_and_isTotalSize_is_true', 0, () => {
      const result = renderSize(1024 * 1024 * 1024, 1024, true);
      expect(result).assertEqual('1 GB');
    });

    it('should_return_1_MB_when_fileSize_is_1024_X2_and_carry_is_1024_and_isTotalSize_is_true', 0, () => {
      const result = renderSize(1024 * 1024, 1024, true);
      expect(result).assertEqual('1 MB');
    });

    it('should_return_1_KB_when_fileSize_is_1024_and_carry_is_1024_and_isTotalSize_is_true', 0, () => {
      const result = renderSize(1024, 1024, true);
      expect(result).assertEqual('1 KB');
    });

    it('should_return_1_B_when_fileSize_is_1_and_carry_is_1024_and_isTotalSize_is_true', 0, () => {
      const result = renderSize(1, 1024, true);
      expect(result).assertEqual('1 B');
    });

    it('should_return_1023_B_when_fileSize_is_less_than_1024_and_carry_is_1024_and_isTotalSize_is_true', 0, () => {
      const result = renderSize(1023, 1024, true);
      expect(result).assertEqual('1023 B');
    });

    it('should_return_DialogAlignment_Bottom_when_deviceType_is_PHONE_and_DisplayUtil_isFoldable_or_getFoldStatus_is_FOLD_STATUS_FOLDED', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockfuncDisplayUtil: Function = mocker.mockFunc(DisplayUtil, DisplayUtil.isFoldable);
      when(mockfuncDisplayUtil)().afterReturn(false);
      const result = getDialogAlignment();
      mocker.ignoreMock(DisplayUtil, DisplayUtil.isFoldable);
      expect(result).assertEqual(DialogAlignment.Bottom);
    });

    it('getRootFolderInstruction', 0, () => {
      let curFolderUri = Constant.MY_PHONE_URI;
      let language = LanguageUtil.getSystemLanguage();
      LanguageUtil.setSystemLanguage('zh-Hans');
      let result = getRootFolderInstruction(curFolderUri, FileSourceUri.DOCUMENTS);
      LanguageUtil.setSystemLanguage(language);
      expect(result?.id).assertEqual($r('app.string.root_path_documents_folder_instruction').id);
    });

    it('getRootFolderInstructionShouldReturnUndefined', 0, () => {
      let curFolderUri = 'test';
      let result = getRootFolderInstruction(curFolderUri, FileSourceUri.DOCUMENTS);
      expect(result).assertUndefined()
    });

    it('getResourceString', 0, () => {
      const myResourceManager: resourceManager.ResourceManager = {
        getStringSync: (resId: number) => {
          return '我的手机';
        }
      } as resourceManager.ResourceManager;
      const myContext: Context = { resourceManager: myResourceManager } as Context;
      const globalHolder = GlobalHolder.getInstance();
      const mocker: MockKit = new MockKit();
      let mockFunction = mocker.mockFunc(globalHolder, globalHolder.getAppContext);
      when(mockFunction)().afterReturn(myContext);
      let res = $r('app.string.myPhone');
      let result = getResourceString(res);
      mocker.clear(globalHolder);
      expect(result).assertEqual('我的手机');
    });

    it('getResourceStringWithReplaceString', 0, () => {
      const myResourceManager: resourceManager.ResourceManager = {
        getStringSync: (resId: number) => {
          return '将文件保存至 "%s"';
        }
      } as resourceManager.ResourceManager;
      const myContext: Context = { resourceManager: myResourceManager } as Context;
      const globalHolder = GlobalHolder.getInstance();
      const mocker: MockKit = new MockKit();
      let mockFunction = mocker.mockFunc(globalHolder, globalHolder.getAppContext);
      when(mockFunction)().afterReturn(myContext);
      let res = $r('app.string.to_save');
      let args: string = '图库';
      let result = getResourceString(res, args);
      mocker.clear(globalHolder);
      expect(result).assertEqual('将文件保存至 "图库"');
    });

    it('getResourceStringWithReplaceNumber', 0, () => {
      const myResourceManager: resourceManager.ResourceManager = {
        getStringSync: (resId: number) => {
          return '最大输入 %d KB';
        }
      } as resourceManager.ResourceManager;
      const myContext: Context = { resourceManager: myResourceManager } as Context;
      const globalHolder = GlobalHolder.getInstance();
      const mocker: MockKit = new MockKit();
      let mockFunction = mocker.mockFunc(globalHolder, globalHolder.getAppContext);
      when(mockFunction)().afterReturn(myContext);
      let res = $r('app.string.image_size_filter_max_input');
      let args = 30;
      let result = getResourceString(res, args);
      mocker.clear(globalHolder);
      expect(result).assertEqual('最大输入 30 KB');
    });
  });
}