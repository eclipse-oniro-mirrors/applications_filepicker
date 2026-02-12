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

import { GlobalHolder, StringUtil } from '@ohos/common';
import { AppConfig, ENV } from '@ohos/common/src/main/ets/config/AppConfig';
import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { TestUtil } from '../../utils/TestUtil';

export default function AppConfigTest() {
  describe('AppConfigTest', () => {
    it('getAppVersionCode', 0, () => {
      let result: string = AppConfig.getAppVersionCode();
      const vList = AppConfig.APP_VERSION.split('.');
      let answer: string = `${vList[0]}${StringUtil.padStart(vList[1])}${StringUtil.padStart(vList[2])}${vList[3]}`;
      expect(result).assertEqual(answer);
    })

    it('getAppVersionCode_while_version_error', 0, () => {
      const temp: string = AppConfig.APP_VERSION;
      TestUtil.setPrivateAttribute(AppConfig, 'APP_VERSION', '1.1.1');
      let result: string = AppConfig.getAppVersionCode();
      TestUtil.setPrivateAttribute(AppConfig, 'APP_VERSION', temp);
      expect(result).assertEqual('');
    })

    it('isOnline', 0, () => {
      let result: boolean = AppConfig.isOnline();
      let answer: boolean = AppConfig.CURRENT_ENV === ENV.ONLINE;
      expect(result).assertEqual(answer);
    })

    it('getAppId_while_online', 0, () => {
      const mocker: MockKit = new MockKit();
      const func = mocker.mockFunc(AppConfig, AppConfig.isOnline);
      when(func)().afterReturn(true);
      let result: string = AppConfig.getAppId();
      mocker.ignoreMock(AppConfig, AppConfig.isOnline);
      expect(result).assertEqual(AppConfig.APP_ID_ONLINE);
    })

    it('getAppId_while_offline', 0, () => {
      const mocker: MockKit = new MockKit();
      const func = mocker.mockFunc(AppConfig, AppConfig.isOnline);
      when(func)().afterReturn(false);
      let result: string = AppConfig.getAppId();
      mocker.ignoreMock(AppConfig, AppConfig.isOnline);
      expect(result).assertEqual(AppConfig.APP_ID_MIRROR);
    })

    it('AppConfig', 0, () => {
      expect(AppConfig.CURRENT_ENV).assertEqual(ENV.ONLINE);
      expect(AppConfig.APP_ID_MIRROR).assertEqual('102082119');
      expect(AppConfig.APP_ID_ONLINE).assertEqual('107130961');
      expect(AppConfig.APP_PRODUCT_NAME).assertEqual('HmFileManager');
      expect(AppConfig.APP_PRODUCT_LINE).assertEqual('File Manager');
      expect(AppConfig.APP_PACKAGE_NAME).assertEqual('com.ohos.filemanager');
    })

    it('getAppSourceConfig', 0, () => {
      let appSourceConfig = AppConfig.getAppSourceConfig();
      let mocker: MockKit = new MockKit();
      let globalHolder = GlobalHolder.getInstance();
      let addressArrayMocker = mocker.mockFunc(globalHolder, globalHolder.getCommonContext);
      when(addressArrayMocker)(ArgumentMatchers.any).afterReturn({});
      appSourceConfig = AppConfig.getAppSourceConfig();
      mocker.clear(globalHolder);
      expect(appSourceConfig).assertUndefined();
    })
  })
}