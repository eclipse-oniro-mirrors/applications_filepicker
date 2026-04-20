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
  ArrayUtil,
  Constant,
  DiskInfo,
  EventBus,
  FilePickerUtil,
  HiLog,
  ObjectUtil,
  PAGE_ROUTE_CONST,
  PreferenceConst,
  StartModeOptions,
  AbilityOrRouterParams,
  DragManager,
  FavoriteDbManager,
  FavoriteModel,
  FileUtil,
  UsageHabitsPreferenceUtil,
  getDialogAlignment,
  DFX,
  UEUtil,
  CommonPreferenceUtil
} from '@ohos/common';
import { FolderIsExistDialog } from '@ohos/customDialog/indexPhoneOnly';
import { FavouriteDataSource } from '../../model/FavouriteDataSource';
import { FavouriteItem } from './FavouriteItem';
import lazy { LengthMetrics, SubHeader, TextModifier } from '@ohos/common/indexLazyLoad';
import { FavouriteItemLongPressMenu } from '../FavouriteItemLongPressMenu';
import { FavouriteItemPreviewView } from '../FavouriteItemPreviewView';

const TAG: string = 'collectionList';

@Component
export struct FavoriteList {
  private startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();
  context = this.startModeOptions.context;
  @State lastItem: FavoriteModel = new FavoriteModel();
  @Consume favouriteDataSource: FavouriteDataSource;
  @State isExpend?: boolean = true;
  @Consume @Watch('isEditChange') isEdit: boolean;
  @State dragIndex: number = 0;
  @State isMove: boolean = true;
  @State selectItem: string = '';
  @State expandPress: boolean = false;
  @State dragItem: FavoriteModel = new FavoriteModel();
  @State currentItem: FavoriteModel = new FavoriteModel();
  @StorageLink('storageDeviceList') @Watch('diskInfoChange') diskInfoArr: DiskInfo[] = [];
  @Consume('pageInfos') pageInfos: NavPathStack;
  @Consume('currentNavItem') currentNavItem: string;
  @Consume isSorted: boolean;
  private isLoading: boolean = false;
  private hasNex: boolean = false;
  private getFavoriteListBind: Function = () => this.isStartSearch();
  folderIsExistDialog: CustomDialogController = new CustomDialogController({
    builder: FolderIsExistDialog({
      confirm: (): void => this.deleteCurrentItem()
    }),
    alignment: getDialogAlignment(),
    offset: { dx: $r('app.float.dialog_offset_0'), dy: $r('app.float.dialog_offset_12') },
    autoCancel: false,
  })
  pageRoot: string = '';
  changeData: boolean = false;

  private onDragJumpCallback: Function = () => {};

  private favoriteTitleModifier: TextModifier = new TextModifier()
    .fontSize($r('sys.float.Subtitle_S'))
    .fontColor($r('sys.color.font_secondary'))
    .fontWeight(FontWeight.Medium)

  @State itemWidth: number = 0;

  aboutToAppear() {
    if (!ArrayUtil.isEmpty(this.diskInfoArr)) {
      this.diskInfoChange();
    }
    this.isStartSearch();
    this.addEventListener();
    const tempExpend = AppStorage.get<boolean>(PreferenceConst.KEY.FAVORITE_LIST_EXPAND)
    if (ObjectUtil.isNullOrUndefined(tempExpend)) {
      this.isExpend = true;
    } else {
      this.isExpend = tempExpend;
    }
  }

  deleteCurrentItem(): void {
    this.favouriteDataSource.deleteDataByPath(this.currentItem.path);
    this.lastItem = this.favouriteDataSource.getLastItem();
  }

  isStartSearch(): void {
    if (this.isEdit) {
      this.hasNex = true;
    } else {
      this.getFavoriteList();
    }
  }

  openFolderIsExistDialog(): void {
    this.folderIsExistDialog.open();
  }

  addEventListener(): void {
    EventBus.on(Constant.EVENTS.FAVORITE_REFRESH, this.getFavoriteListBind);
  }

  getFavoriteList(): void {
    if (this.isLoading) {
      this.hasNex = true;
    } else {
      this.isLoading = true;
      HiLog.info(TAG, 'getData start');
      FavoriteDbManager.getInstance().getAllFavoriteList(this.diskInfoArr).then((val) => {
        HiLog.info(TAG, 'getData end');
        HiLog.info(TAG, 'hasNex' + JSON.stringify(this.hasNex));
        this.favouriteDataSource.setData(val);
        this.lastItem = this.favouriteDataSource.getLastItem();
        this.isLoading = false;
        if (this.hasNex) {
          this.hasNex = false;
          this.getFavoriteList();
        }
        HiLog.info(TAG, 'getFavoriteList end:' + val.length);
      });
    }
  }

  diskInfoChange() {
    this.getFavoriteList();
  }

  isEditChange() {
    if ((!this.isEdit) && this.changeData) {
      this.changeData = false;
      FavoriteDbManager.getInstance()
        .saveFavoriteCache(this.favouriteDataSource.getDataArray())
        .then((val) => {
          this.getFavoriteList();
        })
    }
  }

  redirectPage(item: FavoriteModel) {
    HiLog.warnPrivate(TAG, 'favouite click', `item path: ${item?.path}`);
    if (!this.isEdit) {
      this.pageRoot = PAGE_ROUTE_CONST.MY_PHONE;
      FileUtil.isExistByPathWithFs(item.path).then((exist: boolean) => {
        if (exist) {
          if (this.currentNavItem === item.path) {
            HiLog.warn(TAG, 'currentNavItem === item.path');
            return;
          }
          this.currentNavItem = item.path;
          this.pageInfos.clear();
          EventBus.emit(Constant.EVENTS.RESET_LOCAL_CLOUD_FOLDER, this.pageRoot);
          HiLog.warn(TAG, 'open favourite file.');
          this.pageInfos.pushPath(new NavPathInfo(
            this.pageRoot,
            {
              path: item.path,
              from: PAGE_ROUTE_CONST.MAIN_ENTRY
            } as AbilityOrRouterParams));
        } else {
          HiLog.warn(TAG, 'favourite is not exist.');
          this.currentItem = item;
          this.openFolderIsExistDialog();
        }
      })
    }
  }

  build() {
    Column() {
      if (this.favouriteDataSource.totalCount() > 0) {
        this.favoriteTitle()
        if ((this.favouriteDataSource.totalCount() > 4) && (this.isExpend === true)) {
          this.collectionListView();
        } else if ((this.favouriteDataSource.totalCount() > 4) && (this.isExpend === false)) {
          Column() {
          }
        } else {
          this.collectionListView();
        }
      }
    }
    .margin({ left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })
  }

  @Builder
  favoriteTitle() {
    if (this.favouriteDataSource.totalCount() > 0) {
      Row() {
        SubHeader({
          primaryTitle: $r('app.string.favorite_title'),
          primaryTitleModifier: this.favoriteTitleModifier,
        })
          .width('70%')
        if (this.favouriteDataSource.totalCount() > 4) {
          Row() {
            Text($r('app.string.more'))
              .fontSize($r('app.float.common_font_size14'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .fontWeight(FontWeight.Medium)
              .margin({
                start: LengthMetrics.vp(12),
              })
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .width($r('app.float.common_size12'))
              .height($r('app.float.common_size24'))
              .draggable(false)
              .fontSize('24vp')
              .fontColor([$r('sys.color.icon_fourth')])
              .margin({ left: $r('sys.float.ohos_id_text_paragraph_margin_xs') })
              .rotate({ angle: this.isExpend ? 90 : 360 })
              .margin({
                left: $r('app.float.common_margin4')
              })
          }
          .padding({
            left: $r('app.float.common_margin16'),
            right: $r('app.float.common_margin13'),
            top: $r('app.float.common_margin24'),
          })
          .onClick(() => {
            this.isExpend = !this.isExpend;
            CommonPreferenceUtil.setFavouriteListExpand(this.isExpend);
            AppStorage.set(PreferenceConst.KEY.FAVORITE_LIST_EXPAND, this.isExpend);
          })
          .onDrop(() => {
            HiLog.info(TAG, 'drop click expend');
          })
          .onDragEnter(() => {
            if (this.isEdit) {
              return;
            }
            DragManager.getInstance().onDropEnterAnimation((isSelect: boolean) => {
              this.expandPress = isSelect;
            }, () => {
              this.isExpend = !this.isExpend;
            })
          })
          .onDragLeave(() => {
            DragManager.getInstance().onDropLeaveAnimation(() => {
              this.expandPress = false;
            })
          })
          .backgroundColor(this.expandPress ? $r('app.color.list_item_pressed_bg') : $r('app.color.transparent_color'))
          .borderRadius($r('app.float.common_borderRadius12'))
          .accessibilityText(this.isExpend ? $r('app.string.expanded') : $r('app.string.unexpanded'))
        }
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .constraintSize({
        minHeight: $r('app.float.common_size56')
      })

    }
  }

  @Builder
  previewFavouriteItem(item: FavoriteModel) {
    if (!this.isEdit) {
      FavouriteItemLongPressMenu({
        item: item,
        callbackFun: async (item: FavoriteModel) => {
          await this.deleteFavouriteItem(item);
          FavoriteDbManager.getInstance()
            .saveFavoriteCache(this.favouriteDataSource.getDataArray())
            .then(() => {
              this.getFavoriteList();
            })
        }
      });
    }
  }

  @Builder
  previewModel(item: FavoriteModel) {
    FavouriteItemPreviewView({item})
      .width(this.itemWidth)
  }

  @Builder
  collectionListView() {
    List() {
      LazyForEach(this.favouriteDataSource, (item: FavoriteModel, index) => {
        FavouriteItem({
          lastItem: $lastItem,
          isEdit: this.isEdit,
          item: item,
          dragItem: $dragItem,
          startModeOptions: this.startModeOptions,
          deleteCallback: (item: FavoriteModel) => {
            this.deleteCallback(item);
          },
          clickCallback: (item: FavoriteModel) => {
            this.favouriteItemClickFunc(item);
          },
          favouriteDragEnter: (item: FavoriteModel) => {
            this.favouriteDragEnter(item);
          },
          onDragJumpCallback: this.onDragJumpCallback,
        })
          .bindContextMenu(this.previewFavouriteItem(item), ResponseType.LongPress,
            this.isEdit ? {} :
            {
              preview: this.previewModel(item),
              placement: Placement.BottomLeft,
              previewAnimationOptions: { scale: [0.8, 1.0] },
              layoutRegionMargin: {
                left: $r('sys.float.padding_level8')
              },
              hapticFeedbackMode: HapticFeedbackMode.ENABLED
            })
          .onClick(() => {
            this.favouriteItemClickFunc(item);
          })
          .accessibilityGroup(true)
      }, (item: FavoriteModel) => item.path)
    }
    .divider({
      color: $r('sys.color.ohos_id_color_list_separator'),
      startMargin: 59,
      endMargin: 12,
      strokeWidth: 0.3
    })
    .onDrop(() => {
      this.dragItem = new FavoriteModel();
    })
    .borderRadius($r('app.float.common_borderRadius20'))
    .padding({
      top: $r('app.float.common_padding4'),
      bottom: $r('app.float.common_padding4')
    })
    .width('100%')
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius($r('app.float.common_borderRadius20'))
    .onSizeChange((_, newVal) => {
      this.itemWidth = Number(newVal.width);
    })
  }

  favouriteDragEnter(item: FavoriteModel) {
    this.isSorted = true
    if (item !== this.dragItem) {
      let current = this.favouriteDataSource.getIndex(this.dragItem.path);
      let index = this.favouriteDataSource.getIndex(item.path);
      this.favouriteDataSource.deleteData(current);
      this.favouriteDataSource.addData(index, this.dragItem);
      this.changeData = true;
    }
  }

  deleteCallback(item: FavoriteModel): void {
    FavoriteDbManager.getInstance().deleteFavoriteFolder(item).then((val) => {
      if (val) {
        this.favouriteDataSource.deleteDataByPath(item.path);
        this.lastItem = this.favouriteDataSource.getLastItem();
        this.changeData = true;
      } else {
        HiLog.error(TAG, 'delete fail');
      }
    })
  }

  async deleteFavouriteItem(item: FavoriteModel): Promise<void> {
    let val = await FavoriteDbManager.getInstance().deleteFavoriteFolder(item);
    if (val) {
      UEUtil.reportFileFavorite(DFX.FavoriteOperType.CANCEL_FROM_FAVORITE, DFX.OperateSource.FAVORITE_PRESS_MENU, 1);
      this.favouriteDataSource.deleteDataByPath(item.path);
      this.lastItem = this.favouriteDataSource.getLastItem();
      this.changeData = true;
    } else {
      HiLog.error(TAG, 'delete fail');
    }
  }

  favouriteItemClickFunc(item: FavoriteModel): void {
    this.redirectPage(item);
    UEUtil.reportEnterPage(DFX.PageName.FAVORITE);
  }
}


