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
  DisplayUtil,
  HiLog,
  LocalStorageConst,
  MENU_ICONS,
  StandardAnimation,
  UserState
} from '@ohos/common';
import {
  MENU_NAME,
  TitleBarComp,
  TitleMenuItem,
  TopMenuItem
} from '@ohos/titleBar';

const TAG: string = 'VersionIntroducePage';

@Component
export default struct FeatureIntroducePage {
  @LocalStorageProp(LocalStorageConst.STATUS_BAR_HEIGHT) statusBarHeight: number = 0;
  @LocalStorageProp(LocalStorageConst.BOTTOM_NAV_BAR_HEIGHT) bottomNavBarHeight: number = 0;
  private scroller: Scroller = new Scroller();
  // 后续优化成通过CCM判断
  private isXtDevice: boolean = false;
  @Consume('pageInfos') pageInfos: NavPathStack;
  // 用户状态
  @State userState: UserState = UserState.BROWSER;
  // 标题栏左侧icon
  @State leftIcon: TitleMenuItem = new TitleMenuItem();
  // 标题栏右侧icons
  @State rightIcons: Array<TitleMenuItem> = [];
  // 右上角菜单
  @State topMenu: Array<TopMenuItem> = [];
  private titleBarTransitionEffect?: TransitionEffect<'asymmetric'> =
    StandardAnimation.AnimationConstants.STANDARD_TITLE_TRANSITION;
  // 标题栏
  private title: Resource = $r('app.string.new_features_online');

  aboutToAppear(): void {
    HiLog.info(TAG, 'FeatureIntroducePage appear');
    this.initTitle();
    this.isXtDevice = DisplayUtil.isXtDevice();
  }

  build() {
    NavDestination() {
      Column() {
        // 头部导航
        TitleBarComp({
          title: this.title,
          subTitle: '',
          leftIcon: this.leftIcon,
          iconArr: $rightIcons,
          topMenu: $topMenu,
          userState: this.userState
        })
          .transition(this.titleBarTransitionEffect)

        Scroll(this.scroller) {
          Column() {
            Image(this.isXtDevice ? $r('app.media.new_feature_gxx_01') : $r('app.media.new_feature_other_01'))
              .fillColor($r('sys.color.ohos_id_color_primary'))
              .draggable(false)
              .focusable(true)
              .objectFit(ImageFit.Contain)
              .autoResize(true)
              .interpolation(ImageInterpolation.High)
            Image(this.isXtDevice ? $r('app.media.new_feature_gxx_02') : $r('app.media.new_feature_other_02'))
              .fillColor($r('sys.color.ohos_id_color_primary'))
              .draggable(false)
              .focusable(true)
              .objectFit(ImageFit.Contain)
              .autoResize(true)
              .interpolation(ImageInterpolation.High)
            Image(this.isXtDevice ? $r('app.media.new_feature_gxx_03') : $r('app.media.new_feature_other_03'))
              .fillColor($r('sys.color.ohos_id_color_primary'))
              .draggable(false)
              .focusable(true)
              .objectFit(ImageFit.Contain)
              .autoResize(true)
              .interpolation(ImageInterpolation.High)

          }
        }
        .edgeEffect(EdgeEffect.Spring)
        .align(Alignment.Top)
        .width('100%')
      }
      .margin({
        bottom: $r('app.float.common_size40')
      })
    }
    .onBackPressed(() => {
      return this.onBackPress();
    })
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .padding({
      top: this.statusBarHeight,
      bottom: this.bottomNavBarHeight
    })
  }

  onBackPress(): boolean {
    HiLog.info(TAG, 'onBackPress in');
    this.pageInfos.pop(true);
    return true;
  }

  // 初始化标题栏
  initTitle() {
    if (!this.leftIcon) {
      this.leftIcon = new TitleMenuItem(MENU_ICONS.back, MENU_NAME.back, () => {
        this.pageInfos.pop(true);
      });
    } else {
      this.leftIcon.icon = MENU_ICONS.back;
      this.leftIcon.name = MENU_NAME.back;
      this.leftIcon.action = () => {
        this.pageInfos.pop(true);
      };
    }
    this.leftIcon.isShown = true;
    this.leftIcon.dragEnable = true;
  }
}