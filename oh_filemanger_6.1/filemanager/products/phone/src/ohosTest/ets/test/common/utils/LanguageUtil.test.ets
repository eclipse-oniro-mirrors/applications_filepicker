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
import { describe, it, expect } from '@ohos/hypium'
import {  LanguageUtil } from '@ohos/common';
import { TestUtil } from '../../utils/TestUtil';
import { i18n } from '@kit.LocalizationKit';

export default function LanguageUtilTest() {
  describe('LanguageUtilTest', () => {
    it('setSystemLanguage',0, () => {
      LanguageUtil.setSystemLanguage('zh');
      const systemLanguage: string = TestUtil.getPrivateAttribute(LanguageUtil, 'systemLanguage');
      expect(systemLanguage).assertEqual('zh');
    })

    it('getSystemLanguage',0, () => {
      LanguageUtil.setSystemLanguage('zh');
      expect(LanguageUtil.getSystemLanguage()).assertEqual('zh');
    })

    it('updateSystemLanguage',0, () => {
      const curLanguage: string = i18n.System.getSystemLanguage();
      LanguageUtil.updateSystemLanguage();
      const systemLanguage: string = TestUtil.getPrivateAttribute(LanguageUtil, 'systemLanguage');
      expect(curLanguage).assertEqual(systemLanguage);
    })

    it('getSystemRegion',0, () => {
      const curRegion: string = i18n.System.getSystemRegion();
      expect(LanguageUtil.getSystemRegion()).assertEqual(curRegion);
    })

    it('isChineseLanguageZhTest',0, () => {
      LanguageUtil.setSystemLanguage('zh-Hans');
      expect(LanguageUtil.isChineseLanguage()).assertEqual(true);
    })

    it('isChineseLanguageBoTest',0, () => {
      LanguageUtil.setSystemLanguage('bo');
      expect(LanguageUtil.isChineseLanguage()).assertEqual(false);
    })

    it('isChineseGroupLanguageZhTest',0, () => {
      LanguageUtil.setSystemLanguage('zh-Hans');
      expect(LanguageUtil.isChineseGroupLanguage()).assertEqual(true);
    })

    it('isChineseGroupLanguageBoTest',0, () => {
      LanguageUtil.setSystemLanguage('bo-aa');
      expect(LanguageUtil.isChineseGroupLanguage()).assertEqual(true);
    })

    it('isChineseGroupLanguageUgTest',0, () => {
      LanguageUtil.setSystemLanguage('ug-aa');
      expect(LanguageUtil.isChineseGroupLanguage()).assertEqual(true);
    })

    it('isChineseGroupLanguageEnTest',0, () => {
      LanguageUtil.setSystemLanguage('en-aa');
      expect(LanguageUtil.isChineseGroupLanguage()).assertEqual(false);
    })

    it('isEnglishLanguage',0, () => {
      LanguageUtil.setSystemLanguage('en-ens');
      expect(LanguageUtil.isEnglishLanguage()).assertEqual(true);
    })

    it('isEnglishLanguageUgTest',0, () => {
      LanguageUtil.setSystemLanguage('ug');
      expect(LanguageUtil.isEnglishLanguage()).assertEqual(false);
    })
  })
}