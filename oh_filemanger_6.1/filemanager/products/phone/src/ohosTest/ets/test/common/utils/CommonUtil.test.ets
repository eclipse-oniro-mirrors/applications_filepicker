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
import { CommonUtil, Constant, FileInfo, GlobalHolder, MyPhoneConstant } from '@ohos/common';
import { describe, expect, it } from '@ohos/hypium';
import { StartOptions } from '@kit.AbilityKit';
import { TestUtil } from '../../utils/TestUtil';

export default function CommonUtilTest() {
  describe('CommonUtilTest', () => {
    it('getFileExtension', 0, () => {
      expect(CommonUtil.getFileExtension('')).assertEqual('');
    })

    it('getFileExtensionNullTest', 0, () => {
      expect(CommonUtil.getFileExtension('testFile')).assertEqual('');
    })

    it('getFileExtensionTxtTest', 0, () => {
      expect(CommonUtil.getFileExtension('testFile.txt')).assertEqual('txt');
    })

    it('sizeConversion', 0, () => {
      expect(CommonUtil.sizeConversion(2000 * 1000 * 1000 * 1000)).assertEqual('2.00 TB');
    })

    it('sizeConversionGigabyteTest', 0, () => {
      expect(CommonUtil.sizeConversion(2000 * 1000 * 1000)).assertEqual('2.00 GB');
    })

    it('sizeConversionMegabyteTest', 0, () => {
      expect(CommonUtil.sizeConversion(2000 * 1000)).assertEqual('2.00 MB');
    })

    it('sizeConversionKilobyteTest', 0, () => {
      expect(CommonUtil.sizeConversion(2000)).assertEqual('2.00 KB');
    })

    it('sizeConversionByteTest', 0, () => {
      expect(CommonUtil.sizeConversion(200)).assertEqual('200 B');
    })

    it('getOption', 0, () => {
      let screenWidth: number = 1080;
      let screenHeight: number = 1920;
      let windowWidth: number = 800;
      let windowHeight: number = 600;
      let result: StartOptions = CommonUtil.getOption(screenWidth, screenHeight, windowWidth, windowHeight);
      expect(result.windowLeft).assertEqual((screenWidth - windowWidth) / 2);
      expect(result.windowTop).assertEqual((screenHeight - windowHeight) / 2);
      expect(result.windowWidth).assertEqual(windowWidth);
      expect(result.windowHeight).assertEqual(windowHeight);
    })

    it('startProgressAbilityConfirmTest', 0, () => {
      expect(CommonUtil.isFastClick($r('app.string.confirm'))).assertEqual(false);
    })

    it('startProgressAbilityNullTest', 0, () => {
      expect(CommonUtil.isFastClick('')).assertEqual(false);
    })


    it('getAndSetTime', 0, () => {
      let func = TestUtil.getPrivateFunction(CommonUtil, 'getAndSetTime');
      if (func === null) {
        expect(func).not().assertNull();
      } else {
        expect(func(Date.now() - 499, 500)).assertTrue();
        expect(func(0, 500)).assertFalse();
      }
    })


    it('isPrivacySpaceMode', 0, async () => {
      const result = await CommonUtil.isPrivacySpaceMode();
      expect(result).assertEqual(false);
    })

    it('getRemainDaysDefaultDayTomorrow', 0, () => {
      let deleteTime: number = Date.now() + Constant.TIME.ONE_DAY;
      let result = CommonUtil.getRemainDays(deleteTime);
      expect(result).assertEqual(Constant.DEFAULT_SAVE_DAY);
    })

    it('getRemainDaysDefaultDayNow', 0, () => {
      let deleteTime = Date.now();
      let result = CommonUtil.getRemainDays(deleteTime);
      expect(result).assertEqual(Constant.DEFAULT_SAVE_DAY);
    })

    it('getRemainDaysForTwenty', 0, () => {
      let deleteTime = Date.now() - Constant.TIME.ONE_DAY * 10;
      let result = CommonUtil.getRemainDays(deleteTime);
      expect(result).assertEqual(20);
    })

    it('getRemainDaysZero', 0, () => {
      let deleteTime = Date.now() - Constant.TIME.ONE_DAY * (Constant.DEFAULT_SAVE_DAY + 1);
      let result = CommonUtil.getRemainDays(deleteTime);
      expect(result).assertEqual(0);
    })

    it('getRemainDaysDefaultTest', 0, () => {
      let deleteTime = Date.now();
      let result = CommonUtil.getRemainDays(deleteTime);
      expect(result).assertEqual(Constant.DEFAULT_SAVE_DAY);
    })

    it('getRemainDaysTwentyTest', 0, () => {
      let deleteTime = Date.now() - Constant.TIME.ONE_DAY * 10;
      let result = CommonUtil.getRemainDays(deleteTime);
      expect(result).assertEqual(20);
    })

    it('getRemainDaysZeroTest', 0, () => {
      let deleteTime = Date.now() - Constant.TIME.ONE_DAY * (Constant.DEFAULT_SAVE_DAY + 1);
      let result = CommonUtil.getRemainDays(deleteTime);
      expect(result).assertEqual(0);
    })

    it("isShowCheckBoxFalse", 0, () => {
      let fileInfo: FileInfo = new FileInfo();
      fileInfo.fileName = MyPhoneConstant.MY_PHONE_GALLERY;
      let pickerFlag: boolean = true;
      const result: boolean = CommonUtil.isShowCheckBox(fileInfo, pickerFlag);
      expect(result).assertFalse();
    })

    it("isShowCheckBoxTrue", 0, () => {
      let fileInfo: FileInfo = new FileInfo();
      let pickerFlag: boolean = true;
      fileInfo.fileName = MyPhoneConstant.ROOT_URI;
      const result: boolean = CommonUtil.isShowCheckBox(fileInfo, pickerFlag);
      expect(result).assertTrue();
    })

    it('isHmFilesExist', 0, async () => {
      let context = GlobalHolder.getInstance().getMainAbilityContext() ||
      GlobalHolder.getInstance().getUIExtensionContext() || GlobalHolder.getInstance().getExtensionContext();
      const result = await CommonUtil.isHmFilesExist(context);
      expect(result).assertEqual(true);
    })

    it('getHdsBottomBuilderHeightOutsideFolded', 0, () => {
      const result = CommonUtil.getHdsBottomBuilderHeight(true);
      expect(result).assertEqual(0);
    })

    it('getHdsBottomBuilderHeightNotOutsideFolded', 0, () => {
      const result = CommonUtil.getHdsBottomBuilderHeight(false);
      expect(result).assertLarger(0);
    })
  })
}