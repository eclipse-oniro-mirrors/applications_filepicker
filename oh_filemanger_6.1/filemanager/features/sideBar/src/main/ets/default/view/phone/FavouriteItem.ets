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
  HiLog,
  DataSourceDeviceType,
  DragManager,
  FavoriteModel,
  UiUtil,
  FileUtil,
  MyPhoneConstant,
  ExternalStorageUtil,
  StartModeOptions,
  ResourceUtil,
  StorageDeviceManager,
  GlobalKey,
  FileDefaultIconUtil,
  DFX,
  UEUtil
} from '@ohos/common';
import { FavouriteDataSource } from '../../model/FavouriteDataSource';
import { LengthMetrics } from '@kit.ArkUI';
import { ACCESSIBILITY_LEVEL, Constant } from '@ohos/common/src/main/ets/const/Constant';
import { i18n } from '@kit.LocalizationKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'FavouriteItem';

@Component
export struct FavouriteItem {
  private startModeOptions: StartModeOptions = new StartModeOptions();
  @Prop isEdit: boolean = false;
  private item: FavoriteModel = new FavoriteModel();
  @Link dragItem: FavoriteModel;
  deleteCallback: Function = () => {
  }
  favouriteDragEnter: Function = () => {
  }
  clickCallback: Function = () => {
  }
  @Consume('pageInfos') pageInfos: NavPathStack;
  @Consume('navMode') @Watch('onCurrentNavItemChange') navMode: NavigationMode;
  @Consume('currentNavItem') @Watch('onCurrentNavItemChange') currentNavItem: string;
  @State itemBackColor: Resource = $r('app.color.transparent_color');
  @Link lastItem: FavoriteModel;
  @Consume favouriteDataSource: FavouriteDataSource;
  @State folderSymbol: Resource = $r('app.media.ic_normal_folder');
  @StorageProp('isDarkMode') isDarkMode: boolean = false;
  @State showDirection: Direction = i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr;
  @StorageLink('systemLanguage') @Watch('onSystemLanguageChange') systemLanguage: string = '';
  // 获取当前横竖屏状态
  @StorageLink(GlobalKey.DISPLAY_INFO) @Watch('getOrientation') display: string = '';
  // 获取当前横竖屏状态
  @State orientation: boolean = false;
  @State shownPath: string = '';
  @State rootName: Resource | string = $r('app.string.myPhone');

  // 大字体
  @Consume systemMultiple: number;

  private onDragJumpCallback: Function = () => {};

  onSystemLanguageChange(): void {
    if (i18n.isRTL(i18n.System.getSystemLanguage())) {
      this.showDirection = Direction.Rtl;
    } else {
      this.showDirection = Direction.Ltr;
    }

    this.getShownPathOnSystemLanguageChange();
  }

  onCurrentNavItemChange() {
    this.itemBackColor =
      this.currentNavItem === this.item.path && this.navMode === NavigationMode.Split
        ? $r('sys.color.comp_emphasize_tertiary') : $r('app.color.transparent_color');

    // 刷新文件夹图标
    FileUtil.getFolderSubFileCount(this.item.path, false, true).then(count => {
      if (count > 0) {
        this.folderSymbol = this.isDarkMode ?
        $r('app.media.hidisk_icon_folder_has_file_dark') : $r('app.media.hidisk_icon_folder_has_file');
      } else {
        this.folderSymbol = this.isDarkMode ?
        $r('app.media.hidisk_icon_folder_dark') : $r('app.media.hidisk_icon_folder');
      }
    });

    this.getShownPathOnSystemLanguageChange();
  }

  getShownPathOnSystemLanguageChange(): void {
    if (this.item.path.startsWith(Constant.INTERNAL_STORAGE_ROOT_PATH)) {
      this.rootName = $r('app.string.myPhone');
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

  aboutToAppear() {
    HiLog.info(TAG, 'aboutToAppear');
    this.onCurrentNavItemChange();
    if (i18n.isRTL(i18n.System.getSystemLanguage())) {
      this.showDirection = Direction.Rtl;
    } else {
      this.showDirection = Direction.Ltr;
    }
  }

  aboutToDisappear() {
    if (this.currentNavItem === this.item.path) {
      this.currentNavItem = '';
    }
  }

  getBigModePadding(): Resource {
    let padding: Resource = $r('app.float.common_margin8');
    if (this.systemMultiple >= Constant.BIG_MODE.BIG_MODE_3_2x) {
      padding = $r('app.float.common_padding24');
    } else if (this.systemMultiple >= Constant.BIG_MODE.BIG_MODE_2x) {
      padding = $r('app.float.common_padding20');
    } else if (this.systemMultiple >= Constant.BIG_MODE.BIG_MODE_1_75x) {
      padding = $r('app.float.common_padding16');
    }
    return padding;
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
            Text(UiUtil.translateFileNameByUri(FileUtil.getUriFromPath(this.item.path), this.item.name, true))
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
            // 收藏文件的路径
            Row() {
              Text() {
                Span(this.rootName)
                Span(this.shownPath + '/' + this.item.name)
              }
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
        .layoutWeight(1)
        .padding({
          top: LengthMetrics.resource(this.getBigModePadding()),
          bottom: LengthMetrics.resource(this.getBigModePadding())
        })

        if (this.isEdit) {
          SymbolGlyph($r('sys.symbol.minus_circle'))
            .fontSize($r('app.float.common_size22'))
            .fontColor([$r('sys.color.ohos_id_color_warning')])
            .margin({ left: $r('sys.float.ohos_id_text_paragraph_margin_xs') })
            .aspectRatio(1)
            .draggable(false)
            .accessibilityLevel(ACCESSIBILITY_LEVEL.YES)
            .accessibilityText(ResourceUtil.getStringByResource($r('app.string.unfavorite')))
            .accessibilityRole(AccessibilityRoleType.BUTTON)
            .onClick(() => {
              UEUtil.reportFileFavorite(DFX.FavoriteOperType.CANCEL_FROM_FAVORITE, DFX.OperateSource.EDIT, 1);
              this.deleteCallback(this.item);
            })
            .transition(TransitionEffect.OPACITY.animation({ duration: 100 }))
        } else {
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontColor([$r('sys.color.ohos_id_color_fourth')])
            .margin({ left: $r('sys.float.ohos_id_text_paragraph_margin_xs') })
            .width($r('app.float.common_size12'))
            .height($r('app.float.common_size24'))
            .draggable(false)
            .fontSize($r('app.float.common_size24'))
        }
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor(this.itemBackColor)
      .borderRadius($r('app.float.common_borderRadius16'))
      .constraintSize({
        minHeight: $r('app.float.common_size72')
      })
      .width('100%')
      .padding({
        left: $r('app.float.common_padding8'),
        right: $r('app.float.common_padding8')
      })
    }
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.setSelectItemBackGround();
      } else if ((event.type === TouchType.Up) || (event.type === TouchType.Cancel)) {
        if ((this.navMode !== NavigationMode.Split) || (this.currentNavItem !== this.item.path)) {
          this.itemBackColor = $r('app.color.transparent_color');
        } else {
          this.itemBackColor = $r('sys.color.comp_emphasize_tertiary');
        }
      }
    })
    .borderRadius($r('app.float.common_borderRadius16'))
    .width('100%')
    .padding({
      left: $r('app.float.common_padding4'),
      right: $r('app.float.common_padding4')
    })
    .draggable(false)
    .onDragStart(() => {
      this.dragItem = this.item
    })
    .onDragEnter(() => {
      if (this.isEdit) {
        this.favouriteDragEnter(this.item);
        this.lastItem = this.favouriteDataSource.getLastItem()
      } else {
        DragManager.getInstance().enterSelectItem(this.currentNavItem);
        this.updateItemBackGround(true);
        if (!DragManager.getInstance().supportDrag(this.startModeOptions)) {
          return;
        }
        this.currentNavItem = '';
        DragManager.getInstance().onDropEnterAnimation((isSelect: boolean) => {
          this.updateItemBackGround(isSelect);
        }, () => {
          this.clickCallback(this.item);
        })
      }
    })
    .onDrop(async (event: DragEvent, extraParams?: string) => {
      HiLog.info(TAG, 'onDrop');
      this.dragItem = new FavoriteModel();
      DragManager.getInstance().leaveSelectItem(() => {
        this.currentNavItem = DragManager.getInstance().selectItemTag;
      });
      this.onDragJumpCallback(event, extraParams);
    })
    .onDragMove((event: DragEvent, extraParams: string) => {
      if (!this.isEdit) {
        let canDrag = DragManager.getInstance()
          .supportDrag(this.startModeOptions);
        event.setResult(canDrag ? DragResult.DROP_ENABLED : DragResult.DROP_DISABLED);
      }
    })
    .onDragLeave((event?: DragEvent, extraParams?: string) => {
      HiLog.info(TAG, 'onDragLeave');
      DragManager.getInstance().leaveSelectItem(() => {
        this.currentNavItem = DragManager.getInstance().selectItemTag;
      });
      DragManager.getInstance().onDropLeaveAnimation((isSelect: boolean) => {
        this.updateItemBackGround(isSelect);
      })
    })
  }

  revertPath(): void {
    if (this.shownPath === '') {
      return;
    }
    let paths: string[] = this.shownPath.split('/');
    this.shownPath = '/' + paths.reverse().join('/').substring(0, this.shownPath.length - 1);
    HiLog.infoPrivate(TAG, 'shownPath: ', `${this.shownPath}`);
  }

  updateItemBackGround(isSelect: boolean) {
    if (isSelect) {
      this.setSelectItemBackGround();
    } else {
      this.itemBackColor = $r('app.color.transparent_color');
    }
  }

  setSelectItemBackGround() {
    if (this.navMode !== NavigationMode.Split) {
      this.itemBackColor = $r('sys.color.interactive_pressed');
    } else {
      this.itemBackColor = $r('sys.color.comp_emphasize_tertiary');
    }
  }

  getFolderIcon(): Resource | string {
    const fileUri = FileUtil.getUriFromPath(this.item.path);
    if (!MyPhoneConstant.isSystemFolder(ExternalStorageUtil.getParentUri(fileUri), this.item.name, true)) {
      return $r('app.media.ic_normal_folder');
    }
    return MyPhoneConstant.getFolderImage(false, this.item.name, false);
  }

  // 屏幕横竖屏变化
  getOrientation(): void {
    this.orientation = UiUtil.getOrientationStatus(this.display);
  }
}