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

import { LengthMetrics } from '@ohos.arkui.node';
import {
  Constant,
  FavoriteModel,
  FileUtil,
  GlobalKey,
  HiLog,
  StorageDeviceManager,
  UiUtil
} from '@ohos/common';
import { i18n } from '@kit.LocalizationKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'FavouriteItemPreviewView';

@Component
export struct FavouriteItemPreviewView {
  private item: FavoriteModel = new FavoriteModel();
  @State folderSymbol: Resource = $r('app.media.ic_normal_folder');
  @State fileName: string = '';
  @State showDirection: Direction = i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr;
  @StorageProp('isDarkMode') isDarkMode: boolean = false;
  @State shownPath: string = '';
  @State rootName: Resource | string = $r('app.string.tab_item_phone');
  @StorageLink(GlobalKey.DISPLAY_INFO) display: string = '';
  @State orientation: boolean = UiUtil.getOrientationStatus(this.display);

  aboutToAppear() {
    HiLog.info(TAG, 'about to appear.');
    this.fileName = this.item.name;
    this.onCurrentNavItemChange();
    this.getShownPath();
  }

  build() {
    Row() {
      Row() {
        Row() {
          Image(this.folderSymbol)
            .draggable(false)
            .margin({ end: LengthMetrics.vp(16) })
            .size({height: $r('app.float.common_size24')})
          Column() {
            Text(this.fileName)
              .fontSize($r('app.float.common_font_size16'))
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontWeight(FontWeight.Normal)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(2)
              .constraintSize({
                maxWidth: '75%',
                minHeight: $r('app.float.common_size20')
              })
              .direction(this.showDirection)
            Row() {
              Text(this.rootName)
                .maxLines(1)
                .fontSize($r('app.float.common_font_size14'))
                .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                .fontWeight(FontWeight.Normal)
                .wordBreak(WordBreak.BREAK_ALL)
              Text(this.shownPath)
                .maxLines(1)
                .fontSize($r('app.float.common_font_size14'))
                .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                .fontWeight(FontWeight.Normal)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .wordBreak(WordBreak.BREAK_ALL)
                .direction(this.showDirection)
            }
            .constraintSize({
              maxWidth: this.orientation ? '75%' : '80%',
              minHeight: $r('app.float.common_size20')
            })
            .margin({top: 2})
          }
          .alignItems(HorizontalAlign.Start)
        }

        // 文件夹带右箭头
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontColor([$r('sys.color.ohos_id_color_fourth')])
          .margin({ left: $r('sys.float.ohos_id_text_paragraph_margin_xs') })
          .width($r('app.float.common_size12'))
          .height($r('app.float.common_size24'))
          .draggable(false)
          .fontSize($r('app.float.common_size24'))
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius($r('app.float.common_borderRadius20'))
      .constraintSize({
        minHeight: $r('app.float.common_size72')
      })
      .accessibilityGroup(true)
      .width('100%')
      .padding({
        left: $r('app.float.common_padding16'),
        right: $r('app.float.common_padding16')
      })
    }
    .borderRadius($r('app.float.common_borderRadius20'))
    .width('100%')
    .draggable(false)
  }

  onCurrentNavItemChange(): void {
    // 刷新文件夹图标
    FileUtil.getFolderSubFileCount(this.item.path).then(count => {
      if (count > 0) {
        this.folderSymbol = this.isDarkMode ?
          $r('app.media.hidisk_icon_folder_has_file_dark') : $r('app.media.hidisk_icon_folder_has_file');
      } else {
        this.folderSymbol = this.isDarkMode ?
          $r('app.media.hidisk_icon_folder_dark') : $r('app.media.hidisk_icon_folder');
      }
    });
  }

  revertPath(): void {
    if (this.shownPath === '') {
      return;
    }
    let paths: string[] = this.shownPath.split('/');
    this.shownPath = '/' + paths.reverse().join('/').substring(0, this.shownPath.length - 1);
    HiLog.infoPrivate(TAG, 'shownPath: ', `${this.shownPath}`);
  }

  getShownPath(): void {
    if (this.item.path.startsWith(Constant.INTERNAL_STORAGE_ROOT_PATH)) {
      this.rootName = $r('app.string.tab_item_phone');
      this.shownPath = this.item.path.substring(Constant.INTERNAL_STORAGE_ROOT_PATH.length, this.item.path.lastIndexOf('/'));
      if (this.showDirection === Direction.Rtl) {
        this.revertPath();
      }
    } else {
      // 切换语言需要重新刷新设备缓存
      StorageDeviceManager.getInstance().getStorageDeviceListByWorker().then(diskInfos => {
        diskInfos.forEach((diskInfo) => {
          let uri = FileUtil.getUriFromPath(this.item.path);
          if (uri.startsWith(diskInfo.uri)) {
            this.rootName = diskInfo.description;
            try {
              this.shownPath = decodeURIComponent(uri).substring(diskInfo.uri.length, uri.lastIndexOf('/'));
              if (this.showDirection === Direction.Rtl) {
                this.revertPath();
              }
            } catch (err) {
              err = err as BusinessError;
              HiLog.info(TAG, `decodeURIComponent fail, code: ${err.code}, msg: ${err.message}`);
            }
          }
        })
      })
    }
  }
}