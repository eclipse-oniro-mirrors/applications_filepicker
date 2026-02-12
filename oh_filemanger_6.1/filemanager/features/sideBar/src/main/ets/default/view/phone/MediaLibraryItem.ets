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
  Constant,
  EventBus,
  GlobalHolder,
  HiLog,
  PAGE_ROUTE_CONST,
  ResourceUtil,
  StringUtil
} from '@ohos/common';
import { SideBarItemModel } from '../../model/SideBarItemModel';
import { AbilityOrRouterParams } from '@ohos/common';
import { LengthMetrics } from '@kit.ArkUI';

const TAG = 'MediaLibraryItem';



@Component
export struct MediaLibraryItem {
  private info: SideBarItemModel = {} as SideBarItemModel;
  @Consume('pageInfos') pageInfos: NavPathStack;
  @Consume('navMode') @Watch('onCurrentNavItemChange') navMode: NavigationMode;
  @Consume('currentNavItem') @Watch('onCurrentNavItemChange') currentNavItem: string;
  @State itemBackColor: Resource = $r('app.color.transparent_color');

  build() {
      Row() {
        this.mediaLibraryComp()
      }
      .width('100%')
      .padding({
        left: $r('app.float.common_padding4'),
        right: $r('app.float.common_padding4')
      })
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.setSelectItemBackGround();
        } else if ((event.type === TouchType.Up) || (event.type === TouchType.Cancel)) {
          if ((this.navMode !== NavigationMode.Split) || (this.currentNavItem !== this.getItemPageTag())) {
            this.itemBackColor = $r('app.color.transparent_color');
          }
        }
      })
      .borderRadius($r('app.float.common_borderRadius16'))
      .onClick(() => {
         this.clickEvent();
      })
  }

  setSelectItemBackGround(): void {
    if (this.navMode === NavigationMode.Split) {
      this.itemBackColor = $r('sys.color.interactive_pressed');
    } else {
      this.itemBackColor = $r('sys.color.interactive_pressed');
    }
  }

  onCurrentNavItemChange() {
    this.initBackColor();
  }

  initBackColor(): void {
    this.itemBackColor =
      this.currentNavItem === this.getItemPageTag() && this.navMode === NavigationMode.Split
        ? $r('sys.color.interactive_pressed') : $r('app.color.transparent_color');
  }
  getItemPageTag(): string {
    if (!this.info.uuid) {
      return this.info.uri + '';
    }
    return this.info.uri + this.info.uuid;
  }

  clickEvent(): void {
    let params: AbilityOrRouterParams = {
      rootUri: this.info.rootUri,
      title: this.info.name,
      uuid: this.info.uuid,
      uriPath: this.info.uri
    } as AbilityOrRouterParams;
    EventBus.emit(Constant.EVENTS.RESET_LOCAL_CLOUD_FOLDER, this.info.uri);
    this.pageInfos.pushPath(new NavPathInfo(this.info.uri, params));
  }

  @Builder
  mediaLibraryComp() {
    Row() {
      if (this.info.icon) {
        Image(this.info.icon)
          .objectFit(ImageFit.Contain)
          .renderMode(ImageRenderMode.Original)
          .aspectRatio(1)
          .width($r('app.float.common_size24'))
          .borderRadius($r('app.float.common_size4'))
          .alignSelf(ItemAlign.Center)
          .margin({ end: LengthMetrics.vp(10) })
          .draggable(false)
          .syncLoad(true)
          .interpolation(ImageInterpolation.High)
          .borderWidth('1px')
          .borderColor($r('sys.color.ohos_id_color_component_normal'))
      }
      Column() {
        Text(this.info.name)
          .fontSize($r('app.float.common_font_size16'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Medium)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)

      Flex({ justifyContent: FlexAlign.End }) {
      }
      .layoutWeight(1)
      .padding({ left: $r('app.float.common_padding8') })

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontColor([$r('sys.color.ohos_id_color_fourth')])
        .margin({ left: $r('sys.float.ohos_id_text_paragraph_margin_xs') })
        .width($r('app.float.common_size12'))
        .height($r('app.float.common_size24'))
        .draggable(false)
        .fontSize($r('app.float.common_size24'))
    }
    .constraintSize({
      minHeight: $r('app.float.common_size56')
    })
    .backgroundColor(this.itemBackColor)
    .borderRadius($r('app.float.common_borderRadius16'))
    .padding({
      left: $r('app.float.common_padding8'),
      right: $r('app.float.common_padding8')
    })
  }
}