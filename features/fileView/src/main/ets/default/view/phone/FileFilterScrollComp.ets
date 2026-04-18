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

// 文件过滤组件
import {
  Constant,
  DeviceConfig,
  FilePickerUtil,
  getResourceString,
  HiLog,
  PAGE_ROUTE_CONST,
  PreferenceConst,
  PreferenceFactory,
  StartModeOptions,
  UiUtil,
  UserState,
  VirtualUri
} from '@ohos/common';
import { systemParameterEnhance } from '@kit.BasicServicesKit';
import { LengthMetrics } from '@kit.ArkUI';

@Observed
class FileTypeOption {
  public index: number = 0;
  public fileTypeName: string | Resource = '';
  public selectStatus: boolean = false;
}

const TAG = 'FileFilterScrollComp'

@Styles
function pressedStyles() {
  .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
  .borderRadius($r('sys.float.corner_radius_level8'))
}

@Styles
function normalStyles() {
  .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  .borderRadius($r('sys.float.corner_radius_level8'))
}

@Component
export struct FileFilterScrollComp {
  @Link currentFolder: string;
  ; // 用来判断是否是图库来源
  public isBlackSuffix: boolean = false;
  @State fileTypeArr: FileTypeOption[] = [];
  @Prop isShowLoading: boolean = false;
  // 当前用户状态
  @Link userState: UserState;
  public isPickerFlag: boolean = false;
  @Link sharedGroupName: string;
  @Link isGridColumn: boolean;
  private bundleName: string = '';

  // 是否已经主动关闭
  @State isTipClosedManually: boolean = false;

  private isGalleryView() {
    return (this.currentFolder === PAGE_ROUTE_CONST.GALLERY || this.currentFolder.startsWith(VirtualUri.GALLERY_URI))
  }

  @State isBigMode: boolean = UiUtil.getFontSize() >= Constant.BIG_MODE.BIG_MODE_3_2x;
  private startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();

  private initOptions(): FileTypeOption[] {
    let optionArr: FileTypeOption[] = [];
    optionArr[0].selectStatus = true;
    return optionArr;
  }

  @Builder
  button(item: FileTypeOption, index: number) {
    Button() {
      Text(item.fileTypeName)
        .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)
        .maxFontSize($r('sys.float.Body_M'))
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
    }
    .borderRadius($r('app.float.common_size18'))
    .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
    .constraintSize({
      minWidth: this.isBigMode ? $r('app.float.common_size80') : $r('app.float.common_size62'),
      minHeight: $r('app.float.common_size28')
    })
    .padding({left: $r('app.float.common_size16'),
              right: $r('app.float.common_size16')})
    .onClick(() => {
      HiLog.info(TAG, `complete suffix selecting ${index}`);
      this.changeSelectedType(index);
    })
    .accessibilityChecked(item.selectStatus)
    .accessibilityDescription(item.selectStatus ? ' ' : undefined)
  }

  build() {
    Column() {
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.fileTypeArr, (item: FileTypeOption, index: number) => {
            this.button(item, index);
          })
        }
        .justifyContent(FlexAlign.Center)
        .margin({
          left: $r('app.float.common_margin16'),
          right: $r('app.float.common_margin16')
        })
      }
      .width('100%')
      .height(this.isBigMode ? $r('app.float.common_size60') : $r('app.float.common_size38'))
      .align(Alignment.Bottom)
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .enabled((this.userState !== UserState.MULTI_START || this.isPickerFlag) && !this.isShowLoading)
      .opacity((this.userState !== UserState.MULTI_START || this.isPickerFlag) && !this.isShowLoading ?
      $r('app.float.common_opacity10') : $r('app.float.common_opacity5'))
    }
    .padding({ bottom: this.isGridColumn ? 16 : 0 })
  }

  changeSelectedType(index: number) {
    this.fileTypeArr.forEach((item: FileTypeOption) => {
      if (item.index === index) {
        item.selectStatus = true;
      } else {
        item.selectStatus = false;
      }
    })
    this.sharedGroupName = '';
  }

  aboutToAppear() {
    HiLog.infoPrivate(TAG, 'aboutToAppear pageName ', this.currentFolder);
    this.fileTypeArr = this.initOptions();
    const preference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    this.isTipClosedManually = preference.getSync<boolean>(PreferenceConst.KEY.REMOVE_CACHE_DATA_TIP_CLOSED, false);
  }
}
