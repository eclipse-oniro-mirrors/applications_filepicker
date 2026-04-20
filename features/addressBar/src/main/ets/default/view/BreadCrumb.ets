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
  AddressData,
  BundleResourceUtil,
  Constant,
  DeviceConfig,
  DFX,
  EnumTransferUtil,
  EventBus,
  FileUtil,
  HiLog,
  ResourceUtil,
  UEUtil,
  UiUtil,
  VirtualUri
} from '@ohos/common';

@Styles
function pressedStyles() {
  .borderRadius($r('app.float.common_borderRadius8'))
  .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
}

@Styles
function normalStyles() {
  .backgroundColor($r('app.color.transparent_color'))
  .borderRadius($r('app.float.common_borderRadius8'))
}

function getUEPageName(uri: string, fromPage: DFX.PageName): DFX.PageName {
  let pageName: DFX.PageName = EnumTransferUtil.transferUriToPageName(uri);
  if (pageName === DFX.PageName.UNKNOWN) {
    pageName = fromPage
  }
  return pageName;
}

const TAG = 'BreadCrumb';

@Component
export struct BreadCrumb {
  /**
   * 判断是否需要将面包屑列表滑动到最底部
   */
  @Link @Watch('onDireListUpdated') needScrollEnd: boolean;
  @Link @Watch('onDireListUpdated') direList: AddressData[];
  @Prop originalTitle: string | Resource = '';
  private scroller: Scroller = new Scroller();
  private toFoldedStatusBind: Function = (): void => this.toFoldedStatus();
  private fromPage: DFX.PageName = DFX.PageName.MY_PHONE;
  // 大字体间距
  @State private bigFontAutoSpace: ResourceStr = $r('app.float.common_mark_x0');
  resetPageParam: Function = () => {};

  aboutToAppear() {
    HiLog.info(TAG, 'aboutToAppear: ');
    // 折叠屏注册折叠状态变化监听
    EventBus.on(Constant.EVENTS.TO_FOLDED_STATUS, this.toFoldedStatusBind);
    if (this.needScrollEnd) {
      this.onDireListUpdated('');
    }
    this.getBigFontAutoSpace();
  }

  isGalleryAddress(): string {
    let curUri = '';
    if (this.direList.length > 0 && this.direList[0].uri) {
      curUri = this.direList[0].uri;
    }
    return curUri;
  }

  build() {
    Row() {
      Row() {
        Row() {
          Text((typeof this.originalTitle !== 'string' ||
            (this.originalTitle.length > 0 && this.direList[0]?.uri !== VirtualUri.GALLERY)) ?
            this.originalTitle : DeviceConfig.getInstance().config.myDevice)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontColor(this.direList.length === 0 ? $r('sys.color.ohos_id_color_text_primary') :
              $r('sys.color.ohos_id_color_text_secondary'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .padding({ left: $r('app.float.common_size8'), right: $r('app.float.common_size8') })
            .align(Alignment.Start)
            .stateStyles({
              pressed: pressedStyles,
              normal: normalStyles
            })
            .onSizeChange(() => {
              this.getBigFontAutoSpace();
            })
            .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)

          if (this.direList.length > 0) {
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .draggable(false)
              .fontSize($r('app.float.common_size19'))
              .fontColor([$r('sys.color.ohos_id_color_tertiary')])
          }
        }
        .enabled(this.direList.length === 0 ? false : true)
        .onClick(() => {
          if (!this.direList.length) {
            return;
          }
          UEUtil.reportAddressBarClick(getUEPageName(this.direList[0]?.uri ?? '', this.fromPage));
          this.direList = [];
        })

        Scroll(this.scroller) {
          Row() {
            ForEach(this.direList, (item: AddressData, index) => {
              BreadCrumbItem({
                direItem: item,
                index: index,
                direList: $direList,
                fromPage: this.fromPage,
                resetPageParam: this.resetPageParam
              })
            }, (item: Object | AddressData) => JSON.stringify(item))
          }
        }
        .layoutWeight(1)
        .align(Alignment.TopStart)
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Horizontal)
      }
      .height($r('app.float.common_size40'))
    }
    .alignItems(VerticalAlign.Center)
    .padding({
      left: $r('app.float.common_padding8'),
      right: $r('app.float.common_padding24')
    })
  }

  aboutToDisappear() {
    HiLog.info(TAG, 'aboutToDisappear: ');
    EventBus.off(Constant.EVENTS.TO_FOLDED_STATUS, this.toFoldedStatusBind);
  }

  private getBigFontAutoSpace() {
    let fontSize = UiUtil.getFontSize();
    this.bigFontAutoSpace =
      Constant.BIG_FONT_SIZE_SPACE_MAP.get(fontSize) ? Constant.BIG_FONT_SIZE_SPACE_MAP.get(fontSize) as ResourceStr :
      $r('app.float.common_mark_x0');
  }

  // 监听面包屑变化，滚动到指定位置
  private onDireListUpdated(reason: string, isFold: boolean = false): void {
    setTimeout(() => {
      HiLog.info(TAG, `ondireListUpdated by ${reason}`);
      this.scroller.scrollEdge(Edge.End);
    }, isFold ? 500 : 15);
    this.needScrollEnd = false;
  }

  private toFoldedStatus() {
    this.onDireListUpdated('', true);
  }
}

@Component
struct BreadCrumbItem {
  @Prop direItem: AddressData;
  private index: number = 0;
  private fromPage: DFX.PageName = DFX.PageName.MY_PHONE;
  @Link direList: AddressData[];
  @Consume sourceFlag: string; // 来源
  @State title: string = this.getTitle(this.direItem.uri, this.direItem.name); // 标题
  @StorageProp('systemLanguage') @Watch('sysLanguageChange') sysLanguage: string = '';
  resetPageParam: Function = () => {};

  sysLanguageChange() {
    if (this.index < 0 || this.index >= this.direList.length) {
      HiLog.error(TAG, 'bread crumb index error!');
      this.title = this.direItem ? this.getTitle(this.direItem.uri, this.direItem.name) : '';
      return;
    }

    const tempAddressData: AddressData = this.direList[this.index];
    const uri: string = tempAddressData.uri;
    let translatedName: string = tempAddressData.name;
    // 我的手机目录下系统文件夹面包屑跟随系统语言变化
    if (uri.startsWith(VirtualUri.MY_PHONE)) {
      HiLog.warn(TAG, 'bread crumb name under myPhone change with language');
      // 通过当前文件夹名称获取路径名称
      const index: number = uri.lastIndexOf('/');
      const realName: string = FileUtil.decodeURIForFileManager(uri.substring(index + 1));
      // 进行多语言转换
      translatedName = UiUtil.translateFileNameByUri(uri, realName, true);
    } else if (uri === VirtualUri.GALLERY) {
      HiLog.warn(TAG, 'bread crumb name under gallery change with language');
      translatedName = ResourceUtil.getStringByResource($r('app.string.pc_gallery'));
    }

    if (translatedName !== tempAddressData.name) {
      // 当前名称与多语言转换后名称不符进行修改
      HiLog.warn(TAG, 'language change, to change name');
      tempAddressData.name = translatedName;
    }
    this.title = this.direItem ? this.getTitle(this.direItem.uri, this.direItem.name) : '';
  }

  build() {
    Row() {
      if (this.direItem) {
        Text(this.title)
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontColor(this.isLast() ? $r('sys.color.ohos_id_color_text_primary') :
          $r('sys.color.ohos_id_color_text_secondary'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Center)
          .padding({ left: $r('app.float.common_size8'), right: $r('app.float.common_size8') })
          .maxLines(1)
          .stateStyles({
            pressed: pressedStyles,
            normal: normalStyles
          })
          .enabled(!this.isLast())
          .onClick(() => {
            if (this.sourceFlag) {
              this.sourceFlag = '';
            }
            this.direList.splice(this.index + 1);
            this.resetPageParam();
            UEUtil.reportAddressBarClick(getUEPageName(this.direItem?.uri ?? '', this.fromPage));
          })
          .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)
      }
      if (!this.isLast()) {
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .draggable(false)
          .fontSize($r('app.float.common_size19'))
          .fontColor([$r('sys.color.ohos_id_color_tertiary')])
      }
    }
    .height($r('app.float.common_size48'))
  }

  private getTitle(fileUri: string, breadCrumb: string) {
    const breadCrumbMaxLength = 10;
    let translatedFileName = UiUtil.translateFileNameByUri(fileUri, breadCrumb, true);
    translatedFileName = BundleResourceUtil.getDownLoadBundleName(translatedFileName);
    return translatedFileName.length > breadCrumbMaxLength ?
      translatedFileName.substring(0, translatedFileName.length % 2 === 0 ?
      breadCrumbMaxLength : breadCrumbMaxLength + 1) + '...' : translatedFileName;
  }

  private isLast(): boolean {
    return this.index === this.direList.length - 1;
  }
}