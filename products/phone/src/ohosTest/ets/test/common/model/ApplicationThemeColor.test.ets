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
import { ApplicationThemeColor } from "@ohos/common";
import { describe, expect, it } from "@ohos/hypium";
import { CustomColors } from "@kit.ArkUI";

export default function ApplicationThemeColorTest() {
  describe('ApplicationThemeColorTest', () => {
    it('getCustomThemeWithColor_undefined', 0, () => {
      let customTheme = ApplicationThemeColor.getCustomThemeWithColor(undefined);
      expect(customTheme).assertDeepEquals(ApplicationThemeColor.defaultTheme(false));
    })

    it('getCustomThemeWithColor_customColor', 0, () => {
      let customColor: CustomColors = {
        brand: $r('sys.color.brand'),
        fontPrimary: $r('sys.color.ohos_id_color_text_primary_activated'),
        fontEmphasize: $r('sys.color.font_emphasize'),
        compBackgroundEmphasize: $r('sys.color.comp_background_emphasize'),
        iconFourth: $r('sys.color.icon_fourth'),
      }

      let customTheme = ApplicationThemeColor.getCustomThemeWithColor(customColor);
      expect(customTheme.colors).assertDeepEquals(customColor);
    })
  })
}