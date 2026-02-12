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

// 长按多选菜单栏
import {
  AppDataPathUtil,
  Constant,
  EventBus,
  ExternalStorageUtil,
  FavoriteDbManager,
  FileSourceType,
  FileUtil,
  HiLog,
  LocationType,
  MyPhoneConstant,
  PAGE_ROUTE_CONST,
  UiUtil,
  FileInfo,
  VibrateType,
  DFX,
  EnumTransferUtil,
  UEUtil,
  PhotoAlbumType,
  MenuUtil,
  OpenMediaUtil,
  MenuItemName,
  MenuInfo,
  BOTTOM_BAR_MAP,
  MENU_ITEM_MAP,
  moreMap,
  MORE_MENU_ICON_MAP,
  FileMimeTypeUtil,
} from '@ohos/common';
// import lazy { PrintUtil, ringtone } from '@ohos/common/indexLazyLoad';\
import lazy { PrintUtil } from '@ohos/common/indexLazyLoad';
import { LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI';
import lazy { UTD } from '@ohos/common/indexLazyLoadTs';
import { MENU_ICONS } from '@ohos/titleBar';

const TAG = 'LongPressFileMenu';
@Styles
function pressedStyles() {
  .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
  .borderRadius($r('app.float.common_borderRadius8'))
}

@Styles
function normalStyles() {
  .backgroundColor($r('app.color.transparent_color'))
  .borderRadius($r('app.float.common_borderRadius8'))
}

@Component
export struct LongPressFileMenu {
  private pageName: string = '';
  // 长按点击事件的回调
  onLongPressClick: Function = (emitLocation?: string) => {
  };
  @Prop fileInfo: FileInfo;
  @Prop checkedNum: number;
  @Prop isChecked: boolean;
  @Link showContextMenu: boolean;
  @Prop toOperateFileList: FileInfo[];
  private isMulti: boolean = false;
  // 来源于哪个搜索页
  private geometryId: string = '';
  private simplifiedArrayLength: number = 0;

  // 更多菜单标志位
  private isMoreMenu: boolean = false;
  // 更多菜单数组
  private moreBottomMenuItems: MenuItemName[] = [];
  private doClickFun: Function = () => {};

  @State isOutsideFolded: boolean = false;
  @State private menuArray: MenuItemName[][] = [];
  @State private simplifiedMenuArray: MenuItemName[][] = [];
  @State longPressIconMenus: MenuOptions[] = [];
  @State isListMenuNeedScroll: boolean = false;

  async aboutToAppear(): Promise<void> {
    HiLog.infoPrivate(TAG, `aboutToAppear ${ this.pageName }`, `, fileName :${this.fileInfo?.fileName}`);
    UiUtil.touchVibrate(VibrateType.LONG_PRESS);
    this.buildMenuArray();
    // 根据menuArray构建MoreArray
    this.buildMoreMenuArray();
    this.simplifiedArrayLength = 0;
    this.simplifiedMenuArray.forEach((group: MenuItemName[]) => {
      this.simplifiedArrayLength += group.length;
    });
    this.doClickFun = () => {};
    HiLog.warn(TAG, `temp menu is MoreMenu: ${this.isMoreMenu}, temp fileList length: ${this.toOperateFileList.length}`);
  }

  buildMoreMenuArray() {
    if (!this.isMoreMenu) {
      return;
    }
    this.longPressIconMenus.forEach((item: MenuOptions) => {
      if (this.shouldShowMoreItem(item.menuItem)) {
        this.moreBottomMenuItems.push(item.menuItem);
      }
    });
    this.menuArray.forEach((items: MenuItemName[]) => {
      items.forEach((item: MenuItemName) => {
        if (this.shouldShowMoreItem(item)) {
          this.moreBottomMenuItems.push(item);
        }
      })
    })
  }

  shouldShowMoreItem(name: number): boolean {
    // 当前更多菜单仅存在 复制、删除和更多菜单的组合
    if (name === MenuItemName.COPY || name === MenuItemName.DELETE) {
      return false;
    }
    if (name === MenuItemName.SET_WALLPAPER && this.isOutsideFolded) {
      return false;
    }
    return true;
  }

  aboutToDisappear() {
    HiLog.warn(TAG, `temp menuArray length ${this.menuArray.length} icon menu length ${this.longPressIconMenus.length},
      simplified menu ${this.simplifiedArrayLength}, more menu length ${this.moreBottomMenuItems.length}`);
    this.doClickFun();
    this.doClickFun = () => {};
    this.menuArray = [];
    this.moreBottomMenuItems = [];
    HiLog.infoPrivate(TAG, `aboutToDisappear ${ this.pageName}`, `, fileName :${this.fileInfo?.fileName}`);
  }

  build() {
    if (this.isMoreMenu) {
      this.buildMoreMenu();
    } else {
      this.buildMenu();
    }
  }

  @Builder
  buildMoreMenu() {
    Menu() {
      ForEach(this.moreBottomMenuItems, (item: MenuItemName, index: number) => {
        this.buildMenuItem(item);
        if (index !== this.moreBottomMenuItems.length - 1) {
          this.addDivider(false);
        }
      })
    }
    .menuItemGroupDivider({
      strokeWidth: LengthMetrics.vp(0),
      color: $r('sys.color.comp_background_tertiary'),
      startMargin: LengthMetrics.vp(0),
      endMargin: LengthMetrics.vp(0)
    }) // 每行之间的分界线
    .padding({ top: $r('sys.float.padding_level2'), bottom: $r('sys.float.padding_level2') })
    .width($r('app.float.common_size224'))
  }

  @Builder
  buildMenu() {
    Menu() {
      if (this.isOutsideFolded) {
        // 精简菜单栏总数不多于三个显示为文本菜单项
        if (this.longPressIconMenus.length + this.simplifiedArrayLength <= 3) {
          ForEach(this.longPressIconMenus, (menuItem: MenuOptions, menuItemIndex) => {
            this.buildMenuItem(menuItem.menuItem);
            // 如果不是最后一个菜单项则添加细divider
            if (menuItemIndex !== this.longPressIconMenus.length - 1) {
              this.addDivider(false);
            } else if (this.simplifiedMenuArray.length !== 0) {
              this.addDivider(true);
            }
          })
        } else {
          this.IconMenus();
          if (this.simplifiedMenuArray.length > 0 && this.longPressIconMenus.length !== 0 &&
            !this.isFromRecentDelete()) {
            this.addDivider(true);
          }
        }
        // 精简菜单栏
        ForEach(this.simplifiedMenuArray, (menuGroup: number[], menuGroupIndex: number) => {
          ForEach(menuGroup, (menuItem: number, menuItemIndex: number) => {
            this.buildMenuItem(menuItem);
            // 如果不是最后一个菜单项则添加细divider
            if (menuItemIndex !== menuGroup.length - 1) {
              this.addDivider(false);
            }
          })
          // 如果不是最后一个菜单组则添加粗divider
          if (menuGroupIndex !== this.simplifiedMenuArray.length - 1) {
            this.addDivider(true);
          }
        })
      } else {
        // 普通菜单栏
        this.IconMenus();
        if (this.menuArray.length > 0 && this.longPressIconMenus.length !== 0 && !this.isFromRecentDelete()) {
          this.addDivider(true);
        }
        ForEach(this.menuArray, (menuGroup: number[], menuGroupIndex: number) => {
          ForEach(menuGroup, (menuItem: number, menuItemIndex: number) => {
            this.buildMenuItem(menuItem);
            // 如果不是最后一个菜单项则添加细divider
            if (menuItemIndex !== menuGroup.length - 1) {
              this.addDivider(false);
            }
          })
          // 如果不是最后一个菜单组则添加粗divider
          if (menuGroupIndex !== this.menuArray.length - 1) {
            this.addDivider(true);
          }
        })
      }
    }
    .menuItemGroupDivider({
      strokeWidth: LengthMetrics.vp(0),
      color: $r('sys.color.comp_background_tertiary'),
      startMargin: LengthMetrics.vp(0),
      endMargin: LengthMetrics.vp(0)
    }) // 每行之间的分界线
    .padding({ top: $r('sys.float.padding_level2'), bottom: $r('sys.float.padding_level2') })
    .width($r('app.float.common_size224'))
  }

  @Builder
  IconMenus() {
    if (this.longPressIconMenus.length === 1) {
      this.buildMenuItem(this.longPressIconMenus[0].menuItem);
    } else {
      if (UiUtil.getFontSize() > Constant.BIG_MODE.BIG_MODE_1_75x) {
        ForEach(this.longPressIconMenus, (item: MenuOptions, index: number) => {
          this.buildMenuItem(item.menuItem);
          if (index !== this.longPressIconMenus.length - 1) {
            this.addDivider(false);
          }
        })
      } else {
        Row() {
          ForEach(this.longPressIconMenus, (item: MenuOptions) => {
            MenuBaseItem({
              barItem: item,
            })
              .stateStyles({
                pressed: pressedStyles,
                normal: normalStyles
              })
              .padding({
                left: $r('sys.float.padding_level4'),
                right: $r('sys.float.padding_level4')
              })
              .margin({
                top: $r('app.float.common_margin4'),
                bottom: $r('app.float.common_margin4')
              })
              .onClick(() => {
                HiLog.warn(TAG, `MenuBaseItem onClick ${MENU_ITEM_MAP.get(item.menuItem)?.event}`);
                this.showContextMenu = false;
                this.doClickFun = () => {
                  this.emitEvents(MENU_ITEM_MAP.get(item.menuItem)?.event || '', item.menuItem, true);
                }
                this.reportUEEvent(MENU_ITEM_MAP.get(item.menuItem)?.event)
              })
              .accessibilityRole(AccessibilityRoleType.BUTTON)
              .accessibilityGroup(true)
              .layoutWeight(1)
              .align(Alignment.Center)
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly)
        .hitTestBehavior(HitTestMode.None)
        .padding({
          top: $r('sys.float.padding_level2'),
          bottom: $r('sys.float.padding_level2'),
        })
        .margin({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
        .alignItems(VerticalAlign.Top)
      }
    }
  }

  @Builder
  buildMenuItem(menuItem: number) {
    if (MENU_ITEM_MAP.get(menuItem)) {
      MenuItem({
        content: MENU_ITEM_MAP.get(menuItem)?.content,
        symbolEndIcon: new SymbolGlyphModifier(MENU_ITEM_MAP.get(menuItem)?.icon)
          .fontColor([menuItem === MenuItemName.DELETE ? $r('sys.color.warning') : $r('sys.color.font_primary')])
          .fontSize($r('app.float.common_size20'))
      })
        .onClick(() => {
          if (this.isMoreMenu) {
            HiLog.warn(TAG, `click moreMenu item ${menuItem}`);
            this.emitEvents(MENU_ITEM_MAP.get(menuItem)?.event || '', menuItem, false);
            return;
          }
          HiLog.warn(TAG, `MenuItem onClick longPress menu ${MENU_ITEM_MAP.get(menuItem)?.event}`);
          this.doClickFun = () => {
            this.emitEvents(MENU_ITEM_MAP.get(menuItem)?.event || '', menuItem, true);
          }
          this.reportUEEvent(MENU_ITEM_MAP.get(menuItem)?.event)
        })
        .accessibilityRole(AccessibilityRoleType.MENU_ITEM)
        .margin({ left: $r('sys.float.padding_level2'), right: $r('sys.float.padding_level2') })
        .contentFontColor(menuItem === MenuItemName.DELETE ? $r('sys.color.warning') : $r('sys.color.font_primary'))
        .width('100%')
        .borderRadius($r('sys.float.corner_radius_level8'))
    }
  }

  private reportUEEvent(event?: string): void {
    if (!event) {
      return;
    }
    switch (event) {
      case Constant.EVENTS.LONG_PRESS_MOVE:
      case Constant.EVENTS.LONG_PRESS_COPY: {
        AppStorage.setOrCreate<DFX.OperateSource>(DFX.StorageKey.OPERATE_SOURCE, DFX.OperateSource.PRESS_MENU);
        const page = this.fileInfo.isExternalStorageDeviceFile? DFX.PageName.EXTERNAL:EnumTransferUtil.transferToPageName(this.pageName);
        AppStorage.setOrCreate<DFX.PageName>(DFX.StorageKey.OPERATE_PAGE, page);
        break;
      }
      default: {
        HiLog.warn(TAG, `no need to add UEEvent: ${event}`);
      }
    }
  }

  @Builder
  addDivider(isThick?: boolean) {
    Divider()
      .vertical(false)
      .strokeWidth(isThick ? 8 : '1px')
      .color(isThick ? $r('sys.color.comp_background_tertiary') : $r('sys.color.comp_divider'))
      .width('100%')
      .margin( isThick ? {bottom: LengthMetrics.vp(0),top: LengthMetrics.vp(0)} :
        { left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })
  }

  // 构建最近删除页面菜单项
  private buildRecentDeleteMenuArray() {
    if (this.isOutsideFolded) {
      // 外屏长按菜单不显示多选按钮
      this.simplifiedMenuArray.push([MenuItemName.RESTORE, MenuItemName.DELETE]);
      return;
    }
    this.menuArray = [];
    let menuGroupArray: MenuItemName[] = [];
    // 多选
    if (this.shouldShowMenuItem(MenuItemName.MULTIPLE_CHOICES)) {
      menuGroupArray.push(MenuItemName.MULTIPLE_CHOICES);
    }
    menuGroupArray.push(MenuItemName.RESTORE);
    menuGroupArray.push(MenuItemName.DELETE);
    if (menuGroupArray.length > 0) {
      this.menuArray.push(menuGroupArray);
    }
  }

  private buildOpenMediaSingleChoiceMenuArray() {
    // 拉起视频页，单选右键菜单功能裁剪要求
    // 1. 右键菜单保留 重命名，删除，详情，其余屏蔽
    // 2. 详情屏蔽路径跳转
    // 3. 删除、重命名这种对文件修改的，打点区分外部和文管入口
    this.menuArray = [];
    let menuGroupArray: MenuItemName[] = [];
    // 多选
    if (this.shouldShowMenuItem(MenuItemName.MULTIPLE_CHOICES)) {
      this.menuArray.push([MenuItemName.MULTIPLE_CHOICES]);
    }
    if (menuGroupArray.length > 0) {
      this.menuArray.push(menuGroupArray);
      menuGroupArray = [];
    }
    // 重命名   系统文件夹不可移动删除重命名
    if (this.shouldShowMenuItem(MenuItemName.RENAME)) {
      menuGroupArray.push(MenuItemName.RENAME);
    }
    let simplifiedMenu: MenuItemName[] = [];
    // 详情
    if (this.shouldShowMenuItem(MenuItemName.DETAILS)) {
      menuGroupArray.push(MenuItemName.DETAILS);
      simplifiedMenu.push(MenuItemName.DETAILS);
    }
    // 删除
    if (this.shouldShowMenuItem(MenuItemName.DELETE)) {
      menuGroupArray.push(MenuItemName.DELETE);
      simplifiedMenu.push(MenuItemName.DELETE);
    }
    if (simplifiedMenu.length > 0) {
      this.simplifiedMenuArray.push(simplifiedMenu);
    }
    if (menuGroupArray.length > 0 ){
      this.menuArray.push(menuGroupArray);
    }
  }

  private buildOpenMediaMoreChoiceMenuArray() {
    // 拉起视频页，多选右键菜单功能裁剪要求
    // 1. 右键菜单保留 删除，分享，其余屏蔽
    // 2. 删除打点区分外部和文管入口
    this.menuArray = [];
    let menuGroupArray: MenuItemName[] = [];
    // 删除
    if (this.shouldShowMenuItem(MenuItemName.DELETE)) {
      menuGroupArray.push(MenuItemName.DELETE);
      this.simplifiedMenuArray.push([MenuItemName.DELETE]);
    }
    if (menuGroupArray.length > 0) {
      this.menuArray.push(menuGroupArray);
    }
  }

  // 构建单选菜单项
  private buildSingleChoiceMenuArray() {
    // 复制
    if (this.shouldShowMenuItem(MenuItemName.COPY)) {
      this.longPressIconMenus.push(new MenuOptions(Constant.OPERATION_TYPE.COPY, BOTTOM_BAR_MAP.copy,
        $r('sys.symbol.plus_square_on_square'), MenuItemName.COPY))
    }
    // 移动  剪切
    if (this.shouldShowMenuItem(MenuItemName.MOVE)) {
      this.longPressIconMenus.push(new MenuOptions(Constant.OPERATION_TYPE.MOVE, BOTTOM_BAR_MAP.move,
        $r('sys.symbol.arrow_right_folder_circle'), MenuItemName.MOVE))
    }
    this.menuArray = [];
    let menuGroupArray: MenuItemName[] = [];
    // 【单选状态】
    // 一、打开能力:1，打开所在文件夹 2，其他应用打开
    // 打开所在文件夹，当处于 最近、搜索、聚合、来源的时候展示
    if (this.shouldShowMenuItem(MenuItemName.OPEN_FOLDER)) {
      menuGroupArray.push(MenuItemName.OPEN_FOLDER);
    }
    // 其它应用打开
    if (this.shouldShowMenuItem(MenuItemName.OPEN_BY_OTHER_APP)) {
      menuGroupArray.push(MenuItemName.OPEN_BY_OTHER_APP);
    }
    if (menuGroupArray.length > 0) {
      this.menuArray.push(menuGroupArray);
      menuGroupArray = [];
    }
    // 多选
    if (this.shouldShowMenuItem(MenuItemName.MULTIPLE_CHOICES)) {
      menuGroupArray.push(MenuItemName.MULTIPLE_CHOICES);
    }
    // 收藏
    if (this.shouldShowMenuItem(MenuItemName.FAVORITE)) {
      menuGroupArray.push(MenuItemName.FAVORITE);
    }
    // 取消收藏
    if (this.shouldShowMenuItem(MenuItemName.UN_FAVORITE)) {
      menuGroupArray.push(MenuItemName.UN_FAVORITE);
    }
    // 打印
    if (this.shouldShowMenuItem(MenuItemName.PRINT)) {
      menuGroupArray.push(MenuItemName.PRINT);
    }
    // 重命名   系统文件夹不可移动删除重命名
    if (this.shouldShowMenuItem(MenuItemName.RENAME)) {
      menuGroupArray.push(MenuItemName.RENAME);
    }
    // 二、系统能力:1，收藏 or取消收藏 2，打印  4，分享
    //设置为铃声
    if (this.shouldShowMenuItem(MenuItemName.SET_RINGTONE)) {
      menuGroupArray.push(MenuItemName.SET_RINGTONE);
    }
    // 设置成壁纸
    if (this.shouldShowMenuItem(MenuItemName.SET_WALLPAPER)) {
      menuGroupArray.push(MenuItemName.SET_WALLPAPER);
    }
    if (menuGroupArray.length > 0) {
      this.menuArray.push(menuGroupArray);
      menuGroupArray = [];
    }
    // 其他: 1，详情 2,删除
    let simplifiedMenu: MenuItemName[] = [];
    if (this.shouldShowMenuItem(MenuItemName.DETAILS)) {
      menuGroupArray.push(MenuItemName.DETAILS);
      simplifiedMenu.push(MenuItemName.DETAILS);
    }
    if (this.shouldShowMenuItem(MenuItemName.DELETE)) {
      menuGroupArray.push(MenuItemName.DELETE);
      simplifiedMenu.push(MenuItemName.DELETE);
    }
    if (simplifiedMenu.length > 0) {
      this.simplifiedMenuArray.push(simplifiedMenu);
    }
    if (menuGroupArray.length > 0) {
      this.menuArray.push(menuGroupArray);
    }
  }

  // 构建多选菜单项
  private buildMoreChoiceMenuArray() {
    this.menuArray = [];
    let menuGroupArray: MenuItemName[] = [];
    // 【多选状态】
    // 收藏
    if (this.shouldShowMenuItem(MenuItemName.FAVORITE)) {
      menuGroupArray.push(MenuItemName.FAVORITE);
    }
    // 取消收藏
    if (this.shouldShowMenuItem(MenuItemName.UN_FAVORITE)) {
      menuGroupArray.push(MenuItemName.UN_FAVORITE);
    }
    if (menuGroupArray.length > 0) {
      this.menuArray.push(menuGroupArray);
    }
    menuGroupArray = [];
    // 复制
    if (this.shouldShowMenuItem(MenuItemName.COPY)) {
      this.longPressIconMenus.push(new MenuOptions(Constant.OPERATION_TYPE.COPY, BOTTOM_BAR_MAP.copy, MENU_ICONS.copy,
        MenuItemName.COPY))
    }
    // 移动
    if (this.shouldShowMenuItem(MenuItemName.MOVE)) {
      this.longPressIconMenus.push(new MenuOptions(Constant.OPERATION_TYPE.MOVE, BOTTOM_BAR_MAP.move, MENU_ICONS.move,
        MenuItemName.MOVE))
    }
    // 删除
    if (this.shouldShowMenuItem(MenuItemName.DELETE)) {
      menuGroupArray.push(MenuItemName.DELETE);
      this.simplifiedMenuArray.push([MenuItemName.DELETE]);
    }
    if (menuGroupArray.length > 0) {
      this.menuArray.push(menuGroupArray);
    }
  }

  private isFromRecentDelete(): boolean {
    return this.pageName === PAGE_ROUTE_CONST.RECENT_DELETE ||
      this.fileInfo.sourceType === FileSourceType.RECENT_DELETE;
  }

  /**
   * 按照设计顺序构建存放菜单项的数组
   * */
  private buildMenuArray() {
    if (this.isFromRecentDelete()) {
      // 构建最近删除页菜单项
      this.buildRecentDeleteMenuArray();
    } else if (this.checkedNum < 2 || !this.isChecked) {
      if (OpenMediaUtil.isOpenMedia()) {
        // 外部拉起聚合页场景构建单选页菜单
        this.buildOpenMediaSingleChoiceMenuArray();
        return;
      }
      // 构建单选页菜单项
      this.buildSingleChoiceMenuArray();
    } else {
      if (OpenMediaUtil.isOpenMedia()) {
        // 外部拉起聚合页场景构建多选页菜单
        this.buildOpenMediaMoreChoiceMenuArray();
        return;
      }
      // 构建多选页菜单项
      this.buildMoreChoiceMenuArray();
    }
  }

  /*
   * 沙箱文件禁止移动/删除;
   * 系统文件夹禁止删除
   * */
  private disableFileOperate(): boolean {
    if (this.checkedNum < 2) {
      return MyPhoneConstant.isSystemFolder(ExternalStorageUtil.getParentUri(this.fileInfo.uri),
        this.fileInfo.fileName, this.fileInfo.isFolder);
    } else {
      for (let i = 0; i < this.toOperateFileList.length; ++i) {
        if (MyPhoneConstant.isSystemFolder(ExternalStorageUtil.getParentUri(this.toOperateFileList[i].uri),
          this.toOperateFileList[i].fileName, this.toOperateFileList[i].isFolder)) {
          return true;
        }
      }
      return false;
    }
  }

  /*
   * 沙箱文件禁止重命名;
   *
   * */
  private isDisableRename(): boolean {
    if (this.checkedNum < 2) {
      return (MyPhoneConstant.isSystemFolder(ExternalStorageUtil.getParentUri(this.fileInfo.uri),
        this.fileInfo.fileName, this.fileInfo.isFolder));
    } else {
      for (let i = 0; i < this.toOperateFileList.length; ++i) {
        if (MyPhoneConstant.isSystemFolder(ExternalStorageUtil.getParentUri(this.toOperateFileList[i].uri),
          this.toOperateFileList[i].fileName, this.toOperateFileList[i].isFolder)) {
          return true;
        }
      }
      return false;
    }
  }

  /**
   * 是否展示收藏
   * 只有文件夹蔡展示收藏
   */
  private isShowFavorite(): boolean {
    // 删除页和已删除的文件夹不显示
    if (this.pageName === PAGE_ROUTE_CONST.RECENT_DELETE) {
      return false;
    }
    if (!this.isMulti || !this.isChecked) {
      return this.fileInfo.isFolder;
    }
    return this.toOperateFileList.every((item) => {
      return item.isFolder;
    })
  }

  /**
   * 是否特殊目录，只包含聚合视图下图片和视频的文件夹和我的手机/图库目录下的所有文件夹，该目录下仅支持多选，详情，删除功能
   */
  private isSpecialDir(): boolean {
    return FileUtil.isGalleryAddress(this.fileInfo.uri);
  }

  private isGalleryAlbumDirOfMyPhone(): boolean {
    return this.fileInfo.uri.startsWith(FileUtil.URI_GALLERY);
  }

  /**
   * 是否我的手机-图库下的用户相册
   */
  private isMyPhoneGalleryUserAlbum(): boolean {
    return this.fileInfo.isFolder && this.fileInfo.uri.startsWith(FileUtil.URI_GALLERY)
      && this.fileInfo.albumType === PhotoAlbumType.USER;
  }

  /**
   * 判断文件夹是否都被收藏
   * @param emitLocation
   */
  private isFavorite(): boolean {
    // 是否多选模式或者当前是否选中
    let fileList: FileInfo[] = !this.isMulti || !this.isChecked ? [this.fileInfo] : this.toOperateFileList;
    return fileList.every((item) => FavoriteDbManager.getInstance().isFavorite(item));
  }

  private emitEvents(emitLocation: string, menuItem: number, isLongPress: boolean): void {
    if (emitLocation === Constant.EVENTS.LONG_PRESS_OPEN_FOLDER ||
      emitLocation === Constant.EVENTS.LONG_PRESS_OTHER_APP) {
      EventBus.emit(emitLocation, this.fileInfo);
      return;
    } else if (emitLocation === Constant.EVENTS.LONG_PRESS_CLEAR_RECENT_RECORD) {
      if (this.fileInfo) {
        EventBus.emit(emitLocation, [this.fileInfo]);
      }
      return;
    } else if (emitLocation === Constant.EVENTS.LONG_PRESS_FAVORITE ||
      emitLocation === Constant.EVENTS.LONG_PRESS_UNFAVORITE || emitLocation === Constant.EVENTS.LONG_PRESS_RESTORE) {
      if (!this.isChecked) {
        EventBus.emit(Constant.EVENTS.MENU_CLICK,
          new MenuInfo(menuItem, this.toOperateFileList, this.fileInfo, isLongPress));
        return;
      }
      // 其他菜单逐步向这种方式迁移
      EventBus.emit(Constant.EVENTS.MENU_CLICK,
        new MenuInfo(menuItem, this.toOperateFileList, this.fileInfo, isLongPress));
      return;
    } else if (emitLocation === Constant.EVENTS.LONG_PRESS_RINGTONE ||
      emitLocation === Constant.EVENTS.LONG_PRESS_SHARE) {
      // 避免toOperateFileList未刷新
      EventBus.emit(Constant.EVENTS.MENU_CLICK,
        new MenuInfo(menuItem, this.toOperateFileList, this.fileInfo, isLongPress));
      this.onLongPressClick(emitLocation);
    } else {
      this.onLongPressClick(emitLocation);
      EventBus.emit(emitLocation);
    }
  }

  /**
   * 检查选择的文件是否包含来源相册
   * @returns
   */
  private checkContainSourceAlbum(): boolean {
    if (this.checkedNum < 2) {
      return this.fileInfo.albumType === PhotoAlbumType.SOURCE;
    }
    return this.toOperateFileList.some(file => (file.albumType === PhotoAlbumType.SOURCE));
  }

  /**
   * 菜单项显示逻辑
   * @param MenuItemName
   */
  private shouldShowMenuItem(menuItem: MenuItemName): boolean {
    switch (menuItem) {
      case MenuItemName.OPEN_FOLDER:
        return false;
      case MenuItemName.OPEN_BY_OTHER_APP:
        return !this.fileInfo.isFolder && !this.isSpecialDir();
      case MenuItemName.PRINT:
        return !this.fileInfo.isFolder &&
          PrintUtil.printCondition(FileUtil.getFileTypeFromUri(this.fileInfo.uri)) &&
          !this.isSpecialDir();
      case MenuItemName.FAVORITE:
        return this.isShowFavorite() && !this.isFavorite() && !this.isSpecialDir();
      case MenuItemName.UN_FAVORITE:
        return this.isShowFavorite() && this.isFavorite() && !this.isSpecialDir();
      case MenuItemName.SET_RINGTONE:
        return this.canSetAsRingtone(this.fileInfo) && !this.isSpecialDir();
      case MenuItemName.SET_WALLPAPER:
        return MenuUtil.canSetAsWallpaper(this.fileInfo);
      case MenuItemName.MULTIPLE_CHOICES:
        return !this.isMulti;
      case MenuItemName.MOVE:
        return (!this.disableFileOperate() && !this.isSpecialDir()) ||
          (this.isGalleryAlbumDirOfMyPhone() && !this.checkContainSourceAlbum());
      case MenuItemName.COPY:
        return !this.isSpecialDir() || this.isGalleryAlbumDirOfMyPhone();
      case MenuItemName.RENAME:
        return !this.isDisableRename() && (!this.isSpecialDir() || this.isMyPhoneGalleryUserAlbum());
      case MenuItemName.DETAILS:
        return !this.isChecked || this.checkedNum < 2;
      case MenuItemName.DELETE:
        return !this.disableFileOperate();
      case MenuItemName.RESTORE:
        return (this.pageName === PAGE_ROUTE_CONST.RECENT_DELETE ||
          this.fileInfo.sourceType === FileSourceType.RECENT_DELETE) && !this.isSpecialDir();
      default:
        return false;
    }
  }

  private canSetAsRingtone(fileInfo: FileInfo): boolean {
    const uriLowerCase: string = fileInfo.uri.toLowerCase();
    // 获取文件类型的后缀
    const fileNameExtension: string = UTD.getUniformDataTypeByFilenameExtension("." + fileInfo.mimeTypeObj.extension);
    // 获取所有支持的铃声类型
    // const supportedTypes: ringtone.RingtoneType[] = ringtone.getSupportedRingtoneTypes();
    // // 遍历支持的铃声类型，检查文件类型是否匹配
    // for (const type of supportedTypes) {
    //   // 获取对应铃声类型支持的文件类型
    //   const supportedDataTypes: UTD.UniformDataType[] = ringtone.getSupportedDataTypes(type);
    //   for (const item of supportedDataTypes) {
    //     if (item === fileNameExtension) {
    //       return true;
    //     }
    //   }
    // }
    // 文件类型不符合任一铃声类型
    return false;
  }
}

@Component
struct MenuBaseItem {
  barItem?: MenuOptions;

  build() {
    Column() {
      SymbolGlyph(this.barItem?.icon)
        .fontColor([$r('sys.color.font_primary')])
        .fontSize($r('app.float.common_size20'))
        .margin({ bottom: $r('app.float.common_margin4') })
        .draggable(false)
        .maxFontScale(Constant.BIG_MODE.BIG_MODE_1x)
      Text(this.barItem?.name)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_S'))
        .fontWeight(FontWeight.Medium)
        .fontFamily('HarmonyHeiTi')
        .constraintSize({
          minHeight: $r('app.float.common_line_height13')
        })
    }
    .height('auto')
  }
}

export class MenuOptions {
  public type: string
  public name: Resource
  public icon: Resource
  public menuItem: number;

  constructor(type: string, name: Resource, icon: Resource, menuItem: number) {
    this.type = type;
    this.name = name;
    this.icon = icon;
    this.menuItem = menuItem;
  }
}