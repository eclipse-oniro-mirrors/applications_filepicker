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
import { DisplayUtil, GlobalHolder, GlobalKey, HiLog, LocalStorageConst, UiUtil } from '@ohos/common';
import { curves, display } from '@kit.ArkUI';

const TAG: string = 'PreviewTip';

@Component
export struct PreviewTip {
  @LocalStorageProp(LocalStorageConst.STATUS_BAR_HEIGHT) statusBarHeight: number = 0;
  @LocalStorageProp(LocalStorageConst.BOTTOM_NAV_BAR_HEIGHT) bottomNavBarHeight: number = 0;
  // 搜索转场动效
  @State isAnimationEnter: boolean = false;
  @StorageLink('isRightShowMotion') isRightShowMotion: boolean = false;
  // 获取当前屏幕
  @StorageLink(GlobalKey.DISPLAY_INFO) @Watch('getOrientation') display: string = '';
  @StorageLink('orientation') @Watch('describePositionChange') orientation: boolean = false;

  private alignRus: Record<string, Record<string, string | VerticalAlign | HorizontalAlign>> = {
    'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
    'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start }
  };
  private relConB: Record<string, Record<string, string | VerticalAlign | HorizontalAlign>> = {
    'top': { 'anchor': 'row1', 'align': VerticalAlign.Bottom },
    'left': { 'anchor': 'row1', 'align': HorizontalAlign.Start }
  };
  @State describePosition : number = -60;
  @StorageLink('deviceFoldStatus') @Watch('describePositionChange') deviceFoldStatus: number = DisplayUtil.getFoldStatus();

  aboutToAppear(): void {
    this.describePositionChange();
  }

  build() {
    NavDestination() {
      RelativeContainer() {
        Row().width('100%').height('40%')
          .alignRules(this.alignRus)
          .id('row1')
        Row() {
          this.contentView()
        }.width('100%')
        .alignRules(this.relConB)
        .offset({ y: this.describePosition })
        .id('row2')
      }.width('100%')
      .alignRules(this.relConB)
      .offset({ y: -60 })
      .id('row2')
    }
    .onDrop(() => {
      HiLog.info(TAG, 'PreviewTip onDrop');
    })
    .onDragMove((event: DragEvent) => {
      event.setResult(DragResult.DROP_DISABLED);
    })
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onBackPressed(() => this.onBackPress())
    .height('100%')
    .hideTitleBar(true)
    .padding({ top: this.statusBarHeight, bottom: this.bottomNavBarHeight })
  }

  @Builder
  contentView() {
    Column() {
      Image($r('app.media.preview_tip'))
        .draggable(false)
        .height($r('app.float.common_size120'))
        .width($r('app.float.common_size120'))
      Text($r('app.string.click_preview_detail'))
        .fontSize($r('app.float.common_font_size14'))
        .opacity($r('app.float.common_opacity6'))
        .margin({ top: $r('app.float.common_padding8') })
    }.width('100%')
    .height('100%')
    .padding({
      left: $r('app.float.common_padding16'),
      right: $r('app.float.common_padding16')
    })
    .opacity(this.isAnimationEnter ? 1 : 0)
    .onAppear(() => {
      // 折叠屏展开态从搜索界面返回后的动效
      if (this.isRightShowMotion) {
        animateTo({
          curve: curves.cubicBezierCurve(0.4, 0, 0.2, 1),
        }, () => {
          this.isAnimationEnter = true;
          this.isRightShowMotion = false;
        })
      }
      this.isAnimationEnter = true;
    })
  }

  onBackPress() {
    return false;
  }

  private describePositionChange() {
    this.describePosition = (GlobalHolder.getInstance().getObject<boolean>(GlobalKey.IS_DIRECT_PHONE) &&
      this.orientation) || (DisplayUtil.isFoldable() && this.deviceFoldStatus === DisplayUtil.FOLD_STATUS_FOLDED &&
        this.orientation) ? 20 : -60;
  }

  // 屏幕横竖屏变化
  getOrientation(): void {
    this.orientation = UiUtil.getOrientationStatus(this.display);
  }
}