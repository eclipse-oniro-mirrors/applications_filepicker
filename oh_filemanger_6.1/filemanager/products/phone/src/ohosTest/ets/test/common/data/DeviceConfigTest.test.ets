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
import { Config, DeviceConfig, DeviceType } from "@ohos/common";
import { beforeEach, describe, expect, it } from "@ohos/hypium";
import { TestUtil } from "../../utils/TestUtil";

export default function DeviceConfigTest() {
  describe('DeviceConfigTest', () => {
    beforeEach(() => {

    });
    it('getConfigShouldReturnPhoneConfigWhenInitializedWithPhoneType', 0 , () => {
      TestUtil.setPrivateAttribute(DeviceConfig.getInstance(), '_config', null);
      TestUtil.setPrivateAttribute(DeviceConfig.getInstance(), '_deviceType', DeviceType.PHONE);
      const configMap: Map<DeviceType, Config> = TestUtil.getPrivateAttribute(DeviceConfig.getInstance(), 'configMap');
      expect(DeviceConfig.getInstance().config).assertEqual(configMap.get(DeviceType.PHONE));
    });

    it('getConfigShouldReturnTabletConfigWhenInitializedWithTabletType', 0 , () => {
      TestUtil.setPrivateAttribute(DeviceConfig.getInstance(), '_config', null);
      TestUtil.setPrivateAttribute(DeviceConfig.getInstance(), '_deviceType', DeviceType.TABLET);
      const configMap: Map<DeviceType, Config> = TestUtil.getPrivateAttribute(DeviceConfig.getInstance(), 'configMap');
      expect(DeviceConfig.getInstance().config).assertEqual(configMap.get(DeviceType.TABLET));
    });

    it('getConfigShouldReturnPhoneConfigWhenInitializedWithUnknownType', 0 , () => {
      TestUtil.setPrivateAttribute(DeviceConfig.getInstance(), '_config', null);
      TestUtil.setPrivateAttribute(DeviceConfig.getInstance(), '_deviceType', DeviceType.UNKNOWN);
      const configMap: Map<DeviceType, Config> = TestUtil.getPrivateAttribute(DeviceConfig.getInstance(), 'configMap');
      expect(DeviceConfig.getInstance().config).assertEqual(configMap.get(DeviceType.PHONE));
    });

    it('devTypeStr2Enum_phone', 0 , () => {
      const devTypeStr2Enum = TestUtil.getPrivateFunction(DeviceConfig.getInstance(), 'devTypeStr2Enum');
      if (devTypeStr2Enum) {
        expect(devTypeStr2Enum('phone')).assertEqual(DeviceType.PHONE);
      } else {
        expect().assertFail();
      }
    });

    it('devTypeStr2Enum_tablet', 0 , () => {
      const devTypeStr2Enum = TestUtil.getPrivateFunction(DeviceConfig.getInstance(), 'devTypeStr2Enum');
      if (devTypeStr2Enum) {
        expect(devTypeStr2Enum('tablet')).assertEqual(DeviceType.TABLET);
      } else {
        expect().assertFail();
      }
    });

    it('devTypeStr2Enum_unknown', 0 , () => {
      const devTypeStr2Enum = TestUtil.getPrivateFunction(DeviceConfig.getInstance(), 'devTypeStr2Enum');
      if (devTypeStr2Enum) {
        expect(devTypeStr2Enum('unknown')).assertEqual(DeviceType.UNKNOWN);
      } else {
        expect().assertFail();
      }
    });
  })
}