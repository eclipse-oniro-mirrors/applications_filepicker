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
import { CustomColors, CustomTheme } from '@ohos.arkui.theme';

const TAG: string = 'DefaultThemeColor';

export class ApplicationThemeColor {
  private static rgbReg: RegExp = new RegExp('^#[0-9a-fA-F]{6}|[0-9a-fA-F]{8}$');
  private static defaultFilePickerThemeColor: CustomColors = {
    brand: $r('sys.color.brand'),
    fontPrimary: $r('sys.color.ohos_id_color_text_primary_activated'),
    fontEmphasize: $r('sys.color.font_emphasize'),
    compBackgroundEmphasize: $r('sys.color.comp_background_emphasize'),
    iconFourth: $r('sys.color.icon_fourth'),
  };

  private static defaultPathPickerThemeColor: CustomColors = {
    fontEmphasize: '',
    compBackgroundEmphasize: $r('app.color.path_pick_selected_bg')
  };

  public static defaultTheme(isCreateFileMode: boolean = false): CustomTheme {
    return {
      colors: isCreateFileMode ? ApplicationThemeColor.defaultPathPickerThemeColor :
      ApplicationThemeColor.defaultFilePickerThemeColor
    };
  }

  public static getCustomThemeWithColor(customColor: CustomColors | undefined,
    isCreateFileMode: boolean = false): CustomTheme {
    let defaultCustomColor: CustomColors = isCreateFileMode ? ApplicationThemeColor.defaultPathPickerThemeColor :
    ApplicationThemeColor.defaultFilePickerThemeColor;
    if (!customColor) {
      return { colors: defaultCustomColor };
    }
    customColor = ApplicationThemeColor.getThemeColorOptions(defaultCustomColor, customColor);
    let customTheme: CustomTheme = { colors: customColor };
    return customTheme;
  }

  private static getThemeColorOptions(defaultCustomColor: CustomColors, customColor: CustomColors): CustomColors {
    // 如果某类颜色没有通过应用传入，或者参数错误，则使用默认颜色
    if (defaultCustomColor.brand &&
      (!customColor.brand || !ApplicationThemeColor.rgbFormatCheck(customColor.brand as string))) {
      customColor.brand = defaultCustomColor.brand;
    }
    if (defaultCustomColor.fontPrimary &&
      (!customColor.fontPrimary || !ApplicationThemeColor.rgbFormatCheck(customColor.fontPrimary as string))) {
      customColor.fontPrimary = defaultCustomColor.fontPrimary;
    }
    if (defaultCustomColor.fontEmphasize &&
      (!customColor.fontEmphasize || !ApplicationThemeColor.rgbFormatCheck(customColor.fontEmphasize as string))) {
      customColor.fontEmphasize = defaultCustomColor.fontEmphasize;
    }
    if (defaultCustomColor.compBackgroundEmphasize && (!customColor.compBackgroundEmphasize ||
      !ApplicationThemeColor.rgbFormatCheck(customColor.compBackgroundEmphasize as string))) {
      customColor.compBackgroundEmphasize = defaultCustomColor.compBackgroundEmphasize;
    }
    if (defaultCustomColor.iconFourth &&
      (!customColor.iconFourth || !ApplicationThemeColor.rgbFormatCheck(customColor.iconFourth as string))) {
      customColor.iconFourth = defaultCustomColor.iconFourth;
    }
    return customColor;
  }

  private static rgbFormatCheck(inputValue: string): boolean {
    return ApplicationThemeColor.rgbReg.test(inputValue);
  }
}
