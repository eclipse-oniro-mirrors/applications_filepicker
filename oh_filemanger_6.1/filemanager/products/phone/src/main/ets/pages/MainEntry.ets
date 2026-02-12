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
  ACCESSIBILITY_LEVEL,
  ArrayUtil,
  Constant,
  DeviceInfoUtil,
  DiskInfo,
  DisplayUtil,
  DeviceConfig,
  EventBus,
  FilePickerUtil,
  GlobalHolder,
  GlobalKey,
  HiLog,
  LocalStorageConst,
  ObjectUtil,
  PAGE_ROUTE_CONST,
  PreferenceConst,
  ResultCodePicker,
  StartModeOptions,
  StringUtil,
  VirtualUri,
  AbilityCommonUtil,
  AbilityOrRouterParams,
  FileInfo,
  FileUtil,
  PasteBoardManager,
  StorageDeviceManager,
  SYSTEM_BAR_COLOR,
  ThumbnailLoad,
  TraceUtils,
  HiTraceConst,
  UiUtil,
  TrashFileUtil,
  CommonPreferenceUtil,
  HiSysEventUtil,
  LanguageUtil,
  AccessibilityManager,
  CompId,
  toast,
  ResourceUtil,
  NetworkUtil,
  SecurityData,
  SecurityWarning,
  SettingsUtil,
  BundleResourceUtil,
  DFX,
  EnumTransferUtil,
  FavoriteDbManager,
  UEUtil,
  ProcessFileRecycleTask,
  TaskManager,
  AccountManager,
  PhoneFilePickerUtil,
  FileType,
  OpenMediaUtil,
  DragManager,
  AppConfig,
  BreakPoint,
  CustomTransition,
  StandardAnimation,
  HdsUIConfig,
  TabBarStyle,
  CommonUtil,
  COLOR_MODE,
  PrivacyModeManager,
  MENU_ICONS
} from '@ohos/common';
import lazy { AppDialogs } from './component/AppDialogs';
import { GlobalPasteboard } from './component/common/GlobalPasteboard';
import app from '@system.app';
import lazy { HomePage } from './browser/HomePage';
import lazy { MyPhone } from './browser/storage/MyPhone';
import lazy { RecentDelete } from './browser/storage/RecentDelete';
import lazy { CopyCutManager } from '../base/manager/CopyCutManager';
import { DeviceTypeConstants, BottomTabNumber, PageFinishType } from '@ohos/common/src/main/ets/const/Constant';
import lazy { FilePreview } from './component/preview/FilePreview';
import { ThumbnailCacheManager } from '../base/manager/ThumbnailCacheManager';
import fileExtensionInfo from '@ohos.file.fileExtensionInfo';
import { isFastClick } from '../base/utils/Lodash';
import window from '@ohos.window';
import lazy { PreviewTip } from './component/preview/PreviewTip';
import curves from '@ohos.curves';
import lazy { FileDetailDialog } from '@ohos/customDialog/src/main/ets/default/view/dialog/FileDetailDialog';
import { UIExtSessionManager } from '../base/extension/UIExtSessionManager';
import { PathSelectTree } from './component/pathselect/PathSelectTree';
import { PathSelectParam } from './component/pathselect/PathSelectModel';
import { FileCommonUtil } from '../base/utils/FileCommonUtil';
import { common } from '@kit.AbilityKit';
import { display } from '@kit.ArkUI';
import lazy { TabController } from './picker/TabController';
import { BusinessError, commonEventManager, systemParameterEnhance } from '@kit.BasicServicesKit';
import { connection } from '@kit.NetworkKit';
import lazy { PhotoAccessUtil } from '@ohos/common/indexLazyLoad';
import lazy { photoAccessHelper } from '@ohos/common/indexLazyLoadTs';
import { JumpConfirmDialog } from '@ohos/customDialog/indexPhoneOnly';
import lazy { PopupTips } from '@ohos/common/src/main/ets/const/Constant';
import { JSON } from '@kit.ArkTS';
import { SideBarItem, SideBarItemModel } from '@ohos/sideBar';
import lazy { FileBatchAuthPickerPage } from './FileBatchAuthPickerPage';
import { WallpaperPreview } from './preview/WallpaperPreview';
import { ExpandButton, MENU_NAME } from '@ohos/titleBar';
import { ShellAppCompatibleVersion } from '../base/const/CommonConst';
import FeatureIntroducePage from './browser/storage/FeatureIntroducePage';
import { SelectMode } from '@ohos/common/src/main/ets/const/FilePickerItems';
import { Settings, SettingsBuilder } from './Settings';

let storage = LocalStorage.getShared();
const TAG = 'MainEntry';
const LARGE_WINDOW_SIZE = 1000; // 防止反向横屏的标志
const TAB_BAR_HEIGHT = 48;
const REFRESH_RECENT_EVENT: string = 'file.event.INDEX_INSERT_REFRESH_RECENT';
const REGISTER_CLOUD_FILE_SYNC_DELAY: number = 500;

@Entry(storage)
@Component
struct MainEntry {
  private startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();
  private filePickerViewFlag: boolean = this.startModeOptions.pickerFlag;
  @StorageProp('isDarkMode') @Watch('onDarkModeChange') isDarkMode: boolean = false;
  @LocalStorageProp(LocalStorageConst.STATUS_BAR_HEIGHT) statusBarHeight: number = 0;
  @LocalStorageProp(LocalStorageConst.BOTTOM_NAV_BAR_HEIGHT) bottomNavBarHeight: number = 0;
  @LocalStorageLink(LocalStorageConst.IS_SINGLE_SCREEN) @Watch('changeIsSingleScreenDisplay') isSingleScreenDisplay: boolean =
    false;
  @State positionLeft: Dimension = 0;
  @Provide('expandAnimationStatus') expandAnimationStatus: AnimationStatus = AnimationStatus.Paused;
  @StorageLink('isNetwork') isNetWork: boolean = false;
  @StorageLink('isCellular') isCellular: boolean = false;
  @StorageLink(PreferenceConst.KEY.RECENT_NEW_FEATURE_CARD_SHOW) recentNewFeatureCardShow: boolean = false;
  @StorageLink(PreferenceConst.KEY.RECENT_BAR_RED_DOT_SHOW) recentTabBarRedDotStatus: boolean = false;
  private isFirstLoad: boolean = true;
  @Provide isSorted: boolean = false;
  @Provide @Watch('isEditChange') isEdit: boolean = false;
  private netCon?: connection.NetConnection;
  /**
   * 是否阻止手机返回按钮事件
   */
  @State isPreventBackPress: boolean = false;
  /**
   * 进入文管先看到的页面
   */
  @Provide @Watch('onTabIndexChange') currentTabIndex: number =
    AppStorage.get<number>(PreferenceConst.KEY.DEFAULT_TAB_INDEX) || 0;
  @Provide('browserPageStack') browserPageStack: NavPathStack = new NavPathStack();
  private recentItemTag: string = '';
  private browserItemTag: string = '';
  private recentNavMode: NavigationMode = NavigationMode.Stack;
  private browserNavMode: NavigationMode = NavigationMode.Auto;
  @Provide('pageInfos') @Watch('onPageInfoChange') pageInfos: NavPathStack = new NavPathStack();
  @Provide('navMode') navMode: NavigationMode = NavigationMode.Stack;
  @Provide('currentNavItem') currentNavItem: string = '';
  @Provide('columnTemplate') columnTemplate: string = Constant.COLUMN_TEMPLATE.PHONE;
  @Provide('isSetDialogWidth') isSetDialogWidth: boolean = false;
  @Provide('currLocalFolder') currLocalFolder: string = '';
  @Provide('isScrollReachEnd') isScrollReachEnd: boolean = false;
  // 进入预览模式（预览页面，壁纸编辑页面）
  @Provide isPreviewMode: boolean = false;
  @Provide isPageShowAll: boolean = true;
  @Provide previewFileUri: string = '';
  @State @Watch('recentNumChange') recentNum: number = 0;
  @State currentOrientation: number = 0;
  @StorageProp('orientation') @Watch('orientationChange') orientation: number = 0;
  // 获取当前分屏状态
  @StorageLink('windowStatus') windowStatus: number = window.WindowStatusType.FULL_SCREEN;
  // 是否需要避让摄像头
  @State isAvoidCameraArea: boolean = false;
  // 避让摄像头间距
  @State avoidCameraAreaSize: number = 0;
  // 获取当前横竖屏状态
  @StorageLink(GlobalKey.DISPLAY_INFO) display: string = '';
  /**
   * 是否显示底部tab，多选状态下不显示
   */
  @Provide showEntryBottomBarFlag: boolean = true;
  private currentStorageItem: string = '';
  private controller: TabsController = new TabsController();
  @Provide isLoading: boolean = false;
  private isFrontShow: boolean = false; // 文管在前台
  /**
   * 监听最近刷新
   */
  @StorageLink('recentRefresh') @Watch('dealRefreshWhenShow') recentRefresh: boolean = false;
  @StorageLink('showAboutPage') showAboutPage: boolean = false;
  startReadPasteboardTaskBind: Function =
    () => {
      if (!this.showPickerMaskLayer) {
        PasteBoardManager.getInstance().startReadPasteboardTask(true, this.startModeOptions)
      }
    };
  private openPageBind: Function = (): void => this.openPage();
  private toBrowserTabBind: Function = (): void => this.toBrowserTab();
  private accountLogoutBind: Function = (): void => this.accountLogout(false);
  private cancelEditBind: Function = (): void => this.cancelEdit();
  private resetFolderBind: Function = (pagePath: string): void => this.restCurrFolder(pagePath);
  private externalChangeBind: Function = (uriArray: string[]): void => this.externalChange(uriArray);
  private preventBackPressBind: Function = (flag: boolean): void => this.preventBackPress(flag);
  private pickerCurrentIndexBind: Function = (index: number): void => this.pickerCurrentIndexChange(index);
  // 文件选择器跳转指定目录是否完成
  loadPickFinish: boolean = false;
  /**
   * 是否拉起了路径选择器
   */
  @State isShowPathPicker: boolean = false;
  private showPathPickerBind: Function = (param: PathSelectParam): void => this.showPathPicker(param);
  private closePathPickerBind: Function = (folderUri: string): void => this.hidePathPicker(folderUri);
  private accessibilityFocusJumpBind: Function = (): void => this.accessibilityFocusJump();
  private dragJumpBind: Function = (): void => this.dragJump();
  @State pathSelectParam: PathSelectParam = new PathSelectParam([], '');
  // 是否展示详情半模态弹窗
  @State isShowFileDetail: boolean = false;
  // 是否展示最近删除详情半模态
  @State isShowRecentDeleteFileDetail: boolean = false;
  @Provide systemMultiple: number = 0;
  private isRecentDeletePage: boolean = false;
  private isMyPhonePage: boolean = false;
  private isPreviewForbidJump: boolean = false;
  private fromPage: string = '';
  private fileInfo: FileInfo = new FileInfo();
  // 聚合视图一步直达使用浏览tab页
  @State pickerCurrentIndex: number = Constant.TAB_ID.TAB_BROWSE
  @State uiPickerSwitch: boolean = this.startModeOptions.isUxt();
  @StorageLink('deviceFoldStatus') @Watch('onFoldStatusChange') deviceFoldStatus: number = DisplayUtil.getFoldStatus();
  @Provide('isBigFold') isBigFold: boolean = DisplayUtil.isBigFold();
  @Provide isShowPickerTips: boolean = false;
  // 当前状态是否为外折叠态
  @Provide @Watch('onIsOutsideFoldedChange') isOutsideFolded: boolean = DisplayUtil.isOutsideFolded();
  // 是否正在向下滚动，外折叠态需要隐藏标题及底部Tab
  @Provide @Watch('onIsDownScrollingChange') isDownScrolling: boolean = false;
  // 当前是否为三折叠三屏显示
  @State isTripleExpand: boolean = DisplayUtil.isTripleFoldExpanded();
  private isJumpFromSettings: boolean = false; // 是否从设置页面跳转
  private recentSubscriber: commonEventManager.CommonEventSubscriber | undefined = undefined;
  @Provide('showPickerMaskLayer') showPickerMaskLayer: boolean = false;
  @Provide('isPhotosPage') isPhotosPage: boolean = false; // 当前是否纯图库页(包括预览)
  @Provide isOpenMedia: boolean = OpenMediaUtil.isOpenMedia(); // 是否开放媒体能力场景
  @StorageProp('windowAvoidArea') @Watch('getCameraArea') windowAvoidArea: window.AvoidArea = {
    visible: false,
    leftRect: {
      left: 0,
      top: 0,
      width: 0,
      height: 0
    },
    topRect: {
      left: 0,
      top: 0,
      width: 0,
      height: 0
    },
    rightRect: {
      left: 0,
      top: 0,
      width: 0,
      height: 0
    },
    bottomRect: {
      left: 0,
      top: 0,
      width: 0,
      height: 0
    }
  }
  private isNavBarVisible: boolean = true;
  @State needSkipHome: boolean = this.isHomePageShown(); // 是否跳过首页
  @Provide isVerticalTabBar: boolean = true;
  @Provide('isOnPageShow') isOnPageShow: boolean = false;
  @Provide('isExpand') isExpand: boolean = false; // 是否为展开内容区域
  @State opacityNum: number = 1;
  @State showLongTakeAnimation: boolean = false;
  @StorageProp('appGuidancePass') appGuidancePass: boolean = false;
  // 路径选择器选择的路径
  private selectedTreePath: string = '';
  @State isClosePage: boolean = false;
  // 最近页使用的scroller，在picker状态下需要绑定到HdsNavigation上
  private recentScroller: Scroller = new Scroller();
  // 浏览页使用的scroller，在picker状态下需要绑定到HdsNavigation上
  private homeScroller: Scroller = new Scroller();
  private tabController: TabsController = new TabsController();
  // 最近页的listScroller
  private listScroller: ListScroller = new ListScroller();
  // 浏览页的外层scroller
  private wrapperScroller: Scroller = new Scroller();

  recentNumChange() {
    if (this.navMode !== NavigationMode.Split) {
      return;
    }
    if (this.recentNum === 0) {
      this.clearDefaultView();
    } else {
      if (this.pageInfos.size() === 0) {
        this.pageInfos.pushPath(new NavPathInfo(PAGE_ROUTE_CONST.PREVIEW_TIP, {} as AbilityOrRouterParams),
          UiUtil.showSwitchAnimation(this.navMode));
      }
    }
  }

  orientationChange() {
    // 更新横竖屏状态
    this.currentOrientation = this.orientation;
  }

  onIsOutsideFoldedChange() {
    // 更新宫格配置
    this.columnTemplate =
      this.isOutsideFolded ? Constant.COLUMN_TEMPLATE.OUTSIDE_SCREEN_PHONE : Constant.COLUMN_TEMPLATE.PHONE;
    // 监听到折叠变化就初始化配置
    this.isDownScrolling = false;
    if (this.controller) {
      this.controller.setTabBarTranslate({ y: 0 });
    } else {
      HiLog.warn(TAG, 'onIsOutsideFoldedChange TabController is null or undefined.');
    }
    this.showAboutPage = false;
  }

  onIsDownScrollingChange() {
    if (!this.controller || !this.isOutsideFolded) {
      HiLog.warn(TAG, `onIsDownScrollingChange execute fail, isOutsideFolded: ${this.isOutsideFolded}`);
      return;
    }
    animateTo({
      duration: 300
    }, () => {
      this.controller.setTabBarTranslate({
        y: this.isDownScrolling ? TAB_BAR_HEIGHT : 0
      });
    })
  }

  checkNotificationStatus(): void {
    if (!this.filePickerViewFlag) {
      UIExtSessionManager.getInstance().sendCheckNotificationEvent();
    }
  }

  dragJump(): void {
    this.currLocalFolder = '';
    const params = {
      uriPath: Constant.MY_PHONE_SHARE_PATH,
      finishType: PageFinishType.DEFAULT,
    } as AbilityOrRouterParams;
    this.pageInfos.pushPath(new NavPathInfo(PAGE_ROUTE_CONST.MY_PHONE, params),
      UiUtil.showSwitchAnimation(this.navMode));
  }

  dealRefreshWhenShow() {
    // 刷新我的手机的空间大小
    EventBus.emit(Constant.EVENTS.REFRESH_PHONE_SPACE_SIZE);
  }

  onTabIndexChange() {
    if (this.currentTabIndex === Constant.TAB_ID.TAB_BROWSE && this.navMode === NavigationMode.Split &&
      this.pageInfos.size() === 0) {
      this.createDefaultView();
    }
  }

  /**
   * 展示路径选择器
   * @param selectFilesList 要操作的文件列表
   * @param operationType 操作类型，复制或移动
   */
  showPathPicker(param: PathSelectParam): void {
    // 记录需要传递给路径选择器是必要参数
    this.pathSelectParam = param;
    animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
      this.isShowPathPicker = true;
      AppStorage.setOrCreate<DFX.PageName>(DFX.StorageKey.OPERATE_PAGE,
        EnumTransferUtil.transferToPageName(this.pageInfos.getAllPathName().pop()));
    })
  }

  /**
   * 隐藏路径选择器
   * @param folderUri 选择的文件夹uri
   */
  hidePathPicker(folderUri: string = ''): void {
    this.selectedTreePath = folderUri;
    TraceUtils.startTrace("hidePathPicker animateTo");
    this.isShowPathPicker = false;
    this.accessibilityFocusJump();
    TraceUtils.finishTrace("hidePathPicker animateTo");
  }

  accessibilityFocusJump(): void {
    if (this.pageInfos.size() > 0) {
      AccessibilityManager.getInstance().sendCustomIdFocusForAccessibility(CompId.TOP_TITLE);
    } else {
      AccessibilityManager.getInstance().sendCustomIdFocusForAccessibility(CompId.NAVIGATIONFIELD__TEXT__MAINTITLE);
    }
  }

  aboutToAppear() {
    TraceUtils.startTrace(HiTraceConst.MAIN_ENTRY_PAGE_ABOUT_TO_APPEAR);
    HiLog.info(TAG, 'MainEntry aboutToAppear cardShow: ' + this.recentNewFeatureCardShow
      + ', redDotShow: ' + this.recentTabBarRedDotStatus);
    let jumpPageInfo: string = AppStorage.get<string>(GlobalKey.JUMP_PAGE) ?? '';
    if (!jumpPageInfo || jumpPageInfo === '') {
      HiLog.warn(TAG, 'aboutToAppear jumpPageInfo is undefined');
    }
    this.initDeviceData();
    if (DisplayUtil.getFoldStatus() === FoldStatus.FOLD_STATUS_EXPANDED && !this.filePickerViewFlag) {
      // 折叠机每次打开文管默认打开最近页
      this.navMode = NavigationMode.Stack;
      AppStorage.setOrCreate<boolean>('isDefaultShowRecent', true);
    }
    this.onWindowSizeChange();

    this.initPageInfos(this.currentTabIndex);
    // 更新系统语言
    LanguageUtil.updateSystemLanguage();
    // 获取屏幕上可用于操作的矩形区域的边距
    UiUtil.getSafePadding();
    // 设置image组件缓存
    this.setImageCache();

    // 初始化图标资源的pixelMap
    ThumbnailLoad.initPixelMapResource();
    Constant.updateUserId();

    // 获取Picker上次关闭时的tab页面
    CommonPreferenceUtil.getFilePickerDefaultTabIndex().then((lastFilePickerTabIndex: number) => {
      this.pickerCurrentIndex = StringUtil.isEmpty(this.startModeOptions.defaultFilePathUri) ? lastFilePickerTabIndex :
        Constant.TAB_ID.TAB_BROWSE;
      if (this.startModeOptions.isUxt()) {
        this.currentTabIndex = this.pickerCurrentIndex;
      }
    })
    this.setNavInterception();
    TraceUtils.finishTrace(HiTraceConst.MAIN_ENTRY_PAGE_ABOUT_TO_APPEAR);
    // this.tabController.bindScroller(0, this.listScroller, this.recentScroller);
    this.setTabsScroller();
    HiLog.info(TAG, `aboutToAppear. shellAppVer: ${GlobalHolder.getInstance()
      .getObject<number>(GlobalKey.SHELL_APP_COMPATIBLE_VERSION)}, passState: ${this.appGuidancePass}`)
  }

  preventBackPress(flag: boolean): void {
    this.isPreventBackPress = flag;
  }

  initPageInfos(tabIndex: number) {
    this.pageInfos = this.browserPageStack;
    this.recentItemTag = this.currentNavItem;
    this.currentNavItem = this.browserItemTag;

    this.opacityNum = 1;
  }

  setDefaultSplitView(navMode: number): void {
    if (this.currentTabIndex === Constant.TAB_ID.TAB_BROWSE) {
      if (navMode === NavigationMode.Split) {
        if (this.pageInfos.size() === 0) {
          this.createDefaultView()
        }
      } else if (navMode === NavigationMode.Stack && this.isSingleScreen()) {
        this.clearDefaultView();
      }
    }
  }

  /**
   * 创建默认页面添加到路由栈中
   */
  createDefaultView() {
    const sidebar = SideBarItem.myPhoneItem;
    this.currLocalFolder = '';
    this.currentNavItem = (sidebar.uri ?? '') + (sidebar.uuid ?? '');
    this.pageInfos.pushPath(new NavPathInfo(PAGE_ROUTE_CONST.MY_PHONE,
      { isDefaultPage: true } as AbilityOrRouterParams), UiUtil.showSwitchAnimation(this.navMode));
    AppStorage.setOrCreate<DFX.PageName>(DFX.StorageKey.OPERATE_PAGE, DFX.PageName.MY_PHONE);
  }

  clearDefaultView(): void {
    if (this.pageInfos.size() === 0) {
      return;
    }
    // 路由栈顶层的路由为预览提示页面或默认页面时需要从栈中移除
    const pathStack = this.pageInfos.getPathStack();
    const lastPage = pathStack[pathStack.length - 1];
    const param = lastPage.param as AbilityOrRouterParams;
    if (lastPage.name.startsWith(PAGE_ROUTE_CONST.PREVIEW_TIP) || param?.isDefaultPage) {
      this.pageInfos.removeByNavDestinationId(lastPage.navDestinationId);
    }
  }

  onFoldStatusChange(reason: string): void {
    HiLog.info(TAG, `onFoldStatusChange by ${reason}`);
    this.isOutsideFolded = DisplayUtil.isOutsideFolded();
    // changedPropertyName覆盖status导致类型为string
    const status = this.deviceFoldStatus;
    if (status !== DisplayUtil.FOLD_STATUS_FOLDED) {
      this.isSetDialogWidth = true;
    } else {
      this.isSetDialogWidth = false;
    }
    if (status === DisplayUtil.FOLD_STATUS_FOLDED) {
      EventBus.emit(Constant.EVENTS.TO_FOLDED_STATUS);
    }
  }

  initDeviceData() {
    NetworkUtil.checkNetworkConnectAndCellular();
    this.columnTemplate =
      this.isOutsideFolded ? Constant.COLUMN_TEMPLATE.OUTSIDE_SCREEN_PHONE : Constant.COLUMN_TEMPLATE.PHONE;
    let isFoldable: boolean = DisplayUtil.isFoldable();
    if (isFoldable) {
      GlobalHolder.getInstance().setObject<boolean>(GlobalKey.IS_DIRECT_PHONE, false);
    } else {
      GlobalHolder.getInstance().setObject<boolean>(GlobalKey.IS_DIRECT_PHONE, true);
    }
    if (isFoldable && (DisplayUtil.getFoldStatus() !== DisplayUtil.FOLD_STATUS_FOLDED)) {
      this.isSetDialogWidth = true;
    } else {
      this.isSetDialogWidth = false;
    }
  }

  toBrowserTab(): void {
    if ((this.currentTabIndex !== Constant.TAB_ID.TAB_BROWSE)) {
      this.initPageInfos(Constant.TAB_ID.TAB_BROWSE);
    }
    this.isPreventBackPress = false;
    this.currentTabIndex = Constant.TAB_ID.TAB_BROWSE;
    this.navMode = this.browserNavMode;
    EventBus.emit(Constant.EVENTS.TAB_CHANGE, Constant.TAB_ID.TAB_BROWSE);
    if (this.controller) {
      this.controller.changeIndex(this.currentTabIndex);
    } else {
      HiLog.warn(TAG, 'toBrowserTab TabController is null or undefined.');
    }
    CommonPreferenceUtil.setDefaultTabIndex(this.currentTabIndex);
  }

  externalChange(uriArray: string[]): void {
    if ((this.currentTabIndex === Constant.TAB_ID.TAB_BROWSE) || StringUtil.isEmpty(this.browserItemTag) ||
    ArrayUtil.isEmpty(uriArray)) {
      return;
    }
    if (!this.browserItemTag.startsWith(PAGE_ROUTE_CONST.MY_PHONE)) {
      return;
    }
    let externalName: string = this.browserItemTag.replace(PAGE_ROUTE_CONST.MY_PHONE, '');
    if (StringUtil.isEmpty(externalName)) {
      return;
    }

    let index: number = uriArray.findIndex(item => item.endsWith(externalName));
    // 当前浏览页焦点对应外置存储已经弹出
    if (index === -1) {
      this.browserItemTag = '';
      this.browserPageStack.clear();
    }
  }

  accountLogout(isLogin: boolean): void {
    HiLog.info(TAG, 'accountLoginStatusChange : isLogin = ' + isLogin);
    EventBus.emit(Constant.EVENTS.STOP_DOWNLOAD_FILES);
  }

  aboutToDisappear() {
    // 声明周期日志，辅助定位
    HiLog.info(TAG, 'MainEntry aboutToDisappear');
    // 取消订阅存储设备列表变化的公共事件
    StorageDeviceManager.getInstance().unsubscribeStorageDeviceChangeEvent();
    // 取消订阅包管理资源变化的公共事件
    BundleResourceUtil.unsubscribeBundleResourcesChangedEvent();
    EventBus.off(Constant.EVENTS.FILE_MANAGER_ON_NEW_WANT, this.openPageBind);
    EventBus.off(Constant.EVENTS.ABILITY_ON_FOREGROUND, this.startReadPasteboardTaskBind);
    EventBus.off(Constant.EVENTS.TO_BROWSER_TAB, this.toBrowserTabBind);
    EventBus.emit(Constant.EVENTS.STOP_DOWNLOAD_FILES);
    EventBus.off(Constant.EVENTS.STOP_DOWNLOAD_FILES);
    EventBus.off(Constant.EVENTS.BACK_PRESS, this.cancelEditBind);
    EventBus.off(Constant.EVENTS.RESET_LOCAL_CLOUD_FOLDER, this.resetFolderBind);
    EventBus.off(Constant.EVENTS.SD_USB_CHANGE, this.externalChangeBind);
    EventBus.off(Constant.EVENTS.PREVENT_BACK_PRESS, this.preventBackPressBind);
    EventBus.off(Constant.EVENTS.SHOW_PATH_PICKER, this.showPathPickerBind);
    EventBus.off(Constant.EVENTS.CLOSE_PATH_PICKER, this.closePathPickerBind);
    EventBus.off(Constant.EVENTS.UI_EXTENSION_PICKER_INDEX_CHANGE + this.startModeOptions.currentCreateTimeStamp,
      this.pickerCurrentIndexBind);
    EventBus.off(Constant.EVENTS.CLOSE_UI_FILE_PICKER + this.startModeOptions.currentCreateTimeStamp);
    EventBus.off(Constant.EVENTS.ACCESSIBILITY_FOCUS_JUMP, this.accessibilityFocusJumpBind);
    EventBus.off(Constant.EVENTS.SHOW_RECENT_DELETED_FILE_DETAIL_DIALOG);
    this.browserPageStack.clear();
    if (this.recentSubscriber !== undefined) {
      commonEventManager.unsubscribe(this.recentSubscriber, (err: BusinessError) => {
        if (err) {
          HiLog.error(TAG, `unsubscribe recentSubscriber err = ${JSON.stringify(err)}`);
        } else {
          HiLog.info(TAG, `unsubscribe recentSubscriber success`);
        }
      });
    }
    if (this.netCon) {
      this.netCon.unregister((error: BusinessError) => {
        HiLog.error(TAG, `unRegister netCon error code: ${error?.code}, error msg: ${error?.message}`);
      });
    } else {
      HiLog.warn(TAG, 'aboutToDisappear: NetConnection is null or undefined');
    }
    UiUtil.offWindowSizeChange();
  }

  onPageHide() {
    HiLog.info(TAG, 'MainEntry onPageHide');
    this.isFrontShow = false;
    this.isOnPageShow = false;
    HiLog.info(TAG, 'MainEntry onPageHide finish');
  }

  setImageCache() {
    let holder = GlobalHolder.getInstance();
    if (!holder.getObject<boolean>(GlobalKey.IS_SET_IMAGE_CACHE)) {
      HiLog.info(TAG, 'setImageCacheCount and setImageRawDataCacheSize');
      app.setImageCacheCount(100);
      // 设置缓存100M
      app.setImageRawDataCacheSize(50 * 1000 * 1000);
      holder.setObject<boolean>(GlobalKey.IS_SET_IMAGE_CACHE, true);
    }
  }

  openPage(): void {
    let otherFrom: string = GlobalHolder.getInstance().getObject<string>(GlobalKey.FROM);
    if (ObjectUtil.isNullOrUndefined(otherFrom) || StringUtil.isEmpty(otherFrom)) {
      HiLog.warn(TAG, 'openPage: empty from');
      return;
    }
    HiLog.info(TAG, 'openPage:from ' + otherFrom);
    this.toTargetFolder(otherFrom);
  }

  /**
   * 点击手机返回按钮
   */
  onBackPress() {
    HiLog.info(TAG, 'onBackPress in!');
    if (this.isShowPathPicker) {
      this.hidePathPicker();
      return true;
    }
    if (this.showAboutPage) {
      this.showAboutPage = false;
      return true;
    }
    if (this.isPreventBackPress) {
      HiLog.error(TAG, 'prevent back in mainEntry');
      EventBus.emit(Constant.EVENTS.BACK_PRESS, true);
      return true;
    }
    if (this.isEdit) {
      this.isEdit = false;
      return true;
    }
    if (CopyCutManager.getInstance().checkTaskIsRun(true)) {
      return true;
    }
    if (this.isExpand && this.currentTabIndex === Constant.TAB_ID.TAB_BROWSE) {
      this.setNavExpandAnimation();
      return true;
    }
    if (this.isJumpFromSettings) {
      this.isClosePage = true;
    }
    return false;
  }

  restCurrFolder(pageUrl: string) {
    this.isLoading = false;
    if (pageUrl === PAGE_ROUTE_CONST.MY_PHONE) {
      this.currLocalFolder = '';
      this.currentStorageItem = PAGE_ROUTE_CONST.MY_PHONE;
    } else if (pageUrl === PAGE_ROUTE_CONST.RECENT_DELETE) {
      this.currentStorageItem = PAGE_ROUTE_CONST.RECENT_DELETE;
    } else if (pageUrl === VirtualUri.GALLERY) {
      this.currLocalFolder = '';
      this.currentStorageItem = PAGE_ROUTE_CONST.MY_PHONE;
    }
  }

  onPageShow() {
    HiLog.info(TAG, 'MainEntry onPageShow');
    // 直板机，在MainEntry显示时，将 currentNavItem置为空
    if (this.navMode === NavigationMode.Stack) {
      this.currentNavItem = '';
    }
    this.isFrontShow = true;
    this.getCameraArea();
    if (this.isDarkMode) {
      UiUtil.setWindowBackground(SYSTEM_BAR_COLOR.PATH_PICK_DARK,
        FileCommonUtil.getWindowClass(this.filePickerViewFlag));
    } else {
      UiUtil.setWindowBackground(SYSTEM_BAR_COLOR.PATH_PICK, FileCommonUtil.getWindowClass(this.filePickerViewFlag));
    }
    TrashFileUtil.getTrashFileCount();
    // 刷新外部存储设备的空间大小
    EventBus.emit(Constant.EVENTS.REFRESH_SD_USB_SPACE_SIZE);
    // 刷新内部存储的空间大小， 解决图库删除图片异步删除， 不即时刷新问题
    EventBus.emit(Constant.EVENTS.REFRESH_PHONE_SPACE_SIZE);
    this.openFilePickerAgain();
    // 老化最近页删除的图库数据
    FavoriteDbManager.getInstance().recentDataAging();
    this.openPage();
    this.systemMultiple = UiUtil.getFontSize();
    this.isOnPageShow = true;
    const width = UiUtil.getWidth();
    this.isSingleScreenDisplay = this.getUIContext().px2vp(width) <= BreakPoint.SM;
  }

  onPageInfoChange(): void {
    AppStorage.setOrCreate<NavPathStack>('pageStack', this.pageInfos);
    PrivacyModeManager.getInstance().onFrontPageChange(this.getTopPage());
  }

  build() {
    if (this.startModeOptions.isUxt() && this.startModeOptions.selectMode === SelectMode.FOLDER) {
      Column()
        .onAppear(() => {
          toast($r('app.string.disabled'))
          setTimeout(() => {
            // 返回取消操作给文件子系统
            PhoneFilePickerUtil.terminateFilePicker([], ResultCodePicker.CANCEL, this.startModeOptions);
          }, 1000);
        })
    } else if (this.startModeOptions.isUxt()) {
      this.uiPickerMain();
    } else {
      this.mainContent();
    }
  }

  @Builder
  pickerMaskLayer() {
  }

  @Builder
  uiPickerLockContent() {
    Stack() {
      this.uiPickerContent()
      if (this.showPickerMaskLayer) { // 解锁界面需要重新渲染
        this.pickerMaskLayer();
      }
    }
    .onAreaChange((_, newValue: Area) => {
      AppStorage.setOrCreate<window.Size>('windowSize', {
        width: this.getUIContext().vp2px(Number(newValue.width)),
        height: this.getUIContext().vp2px(Number(newValue.height)),
      });
    })
  }

  @Builder
  uiPickerMain() {
    Stack() {
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM])
    .bindSheet($$this.uiPickerSwitch, this.uiPickerLockContent(), {
      height: SheetSize.LARGE,
      showClose: this.startModeOptions.isBatchAuthMode, // 批量授权还是使用sheet自带的关闭按钮，其他情况使用Navigation中自定义的关闭按钮
      preferType: SheetType.CENTER,
      backgroundColor: $r('sys.color.ohos_id_color_panel_bg'),
      onWillDismiss: (action: DismissSheetAction) => {
        action.dismiss();
      },
      onWillSpringBackWhenDismiss: ((springBackAction: SpringBackAction) => {
        //没有注册springBack, 下拉半模态页面无回弹行为
      }),
      onWillDisappear: () => {
        HiLog.info(TAG, 'uiPickerMain onWillDisappear');
        setTimeout(() => {
          // 返回取消操作给文件子系统
          PhoneFilePickerUtil.terminateFilePicker([], ResultCodePicker.CANCEL, this.startModeOptions);
        }, 200);
      },
      onAppear: () => {
        if (this.needSkipHome) {
          this.needSkipHome = false;
        }
      }
    })
  }

  @Builder
  hdsStackBuilder() {
    TabController({
      currentIndex: this.pickerCurrentIndex,
      currentCreateTimeStamp: this.startModeOptions.currentCreateTimeStamp
    })
  }

  @Builder
  uiPickerContent() {
    Stack() {
      if (this.startModeOptions.isBatchAuthMode) {
        FileBatchAuthPickerPage()
      } else {
        Navigation(this.pageInfos) {
          if (this.needSkipHome) {
            Blank()
          } else {
            HomePage({
              startModeOptions: this.startModeOptions,
              showLongTakeAnimation: this.showLongTakeAnimation,
              homeScroller: this.homeScroller
            })
              // .visibility(this.pickerCurrentIndex === 1 ? Visibility.Visible : Visibility.None)
          }
        }
        .navDestination(this.pageMap)
        .mode(NavigationMode.Stack)
        .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
          return CustomTransition.getCustomAnimation(from, to, operation, this.currentTabIndex);
        })
      }
    }
    .height('100%')
    .width('100%')
  }

  /**
   * 是否是单屏 折叠机折叠起来也是单屏
   * @returns boolean
   */
  isSingleScreen(): boolean {
    if (DeviceConfig.getInstance().config.isPortraitNavStack) {
      if (this.currentOrientation === display.Orientation.PORTRAIT ||
        this.currentOrientation === display.Orientation.PORTRAIT_INVERTED) {
        return !this.isExpand;
      } else {
        return false;
      }
    }
    if (!DisplayUtil.isFoldable()) {
      return true;
    }
    return this.deviceFoldStatus === DisplayUtil.FOLD_STATUS_FOLDED || (DisplayUtil.isOutsideScreenDevice() &&
      this.deviceFoldStatus === DisplayUtil.FOLD_STATUS_EXPANDED);
  }

  getNavMode(tabIndex: number): number {
    if (this.isOpenMedia) {
      return NavigationMode.Stack;
    }

    let navMode: number = (this.isOutsideFolded || this.isSingleScreen()) ||
    this.isSingleScreenDisplay ? NavigationMode.Stack : NavigationMode.Auto;
    HiLog.debug(TAG, `getNavMode tabIndex:${tabIndex} navMode:${navMode}`);
    return navMode;
  }

  getBarHeight(): Length {
    let barHeight: Length = $r('app.float.common_size0');
    if (this.isPreviewMode) {
      return barHeight;
    }

    if (this.showEntryBottomBarFlag) {
      if (this.isSingleScreen()) {
        this.isVerticalTabBar = true;
        barHeight = TabBarStyle.SINGLE_SCREEN_HEIGHT + this.bottomNavBarHeight;
      } else {
        this.isVerticalTabBar = false;
        barHeight = TabBarStyle.FOLD_EXPANDED_HEIGHT + this.bottomNavBarHeight;
      }
    }

    return barHeight;
  }

  setNavExpandAnimation(): void {
    this.expandAnimationStatus = AnimationStatus.Initial;
    this.getUIContext().animateTo({
      curve: curves.cubicBezierCurve(0.2, 0.2, 0.1, 1),
      duration: 450,
      onFinish: () => {
        this.expandAnimationStatus = AnimationStatus.Stopped;
      }
    }, () => {
      this.positionLeft = this.positionLeft === 0 ? '-100%' : 0;
      this.isExpand = !this.isExpand;
      this.expandAnimationStatus = AnimationStatus.Running;
    })
  }

  // 绑定scroller
  setTabsScroller() {
  }

  @Builder
  mainNavigation(pageInfos: NavPathStack, tabIndex: number) {
    Stack({ alignContent: Alignment.TopStart }) {
      Navigation(pageInfos) {
        if (this.isOpenMedia) {
          // 外部拉起的场景仅展示空页面，不展示主页
          Blank()
        } else {
          if (this.isJumpFromSettings) {
          } else {
            // 首页tabs
            if (tabIndex === Constant.TAB_ID.TAB_BROWSE) {
              HomePage({
                startModeOptions: this.startModeOptions,
                showLongTakeAnimation: this.showLongTakeAnimation,
                homeScroller: this.homeScroller
              }).position({
                left: this.positionLeft
              })
            }
          }
        }
      }
      .opacity(this.opacityNum)
      .backgroundColor(Color.Transparent)
      .navDestination(this.pageMap)
      .hideNavBar((this.navMode === NavigationMode.Split && this.isPreviewMode) ||
        (tabIndex === Constant.TAB_ID.TAB_BROWSE && this.isExpand))
      // 外屏不需要分栏显示
      .mode(this.getNavMode(tabIndex))
      .onNavigationModeChange((mode: NavigationMode) => {
        HiLog.info(TAG, `onNavigationModeChange tabIdex: ${this.currentTabIndex} navMode: ${mode}`)
        this.setDefaultSplitView(mode);
        if (tabIndex === Constant.TAB_ID.TAB_BROWSE) {
          this.browserNavMode = mode;
          this.navMode = mode;
          if (!this.isJumpFromSettings) {
            this.showEntryBottomBarFlag = this.isNavBarVisible ||
              (this.navMode === NavigationMode.Split && !this.isSingleScreenDisplay);
          } else {
            this.showEntryBottomBarFlag = false;
          }
        }
      })
      .navBarWidth('43%')
      .hideTitleBar(true) // 必须设置titleMode，list的回弹效果才不会失效
      .titleMode(NavigationTitleMode.Mini)
      .onNavBarStateChange((isVisible: boolean) => {
        HiLog.info(TAG, 'onNavBarStateChange isVisible:' + isVisible);
        this.isNavBarVisible = isVisible;
        if (!this.isJumpFromSettings) {
          this.showEntryBottomBarFlag = isVisible || (this.navMode === NavigationMode.Split);
        } else {
          this.showEntryBottomBarFlag = false;
        }
        if (!isVisible) {
          return;
        }
        // 由于应用冷启动时页面的声明周期onPageShow和Navigation的onNavBarStateChange都会触发
        // 导致onPageShow方法被调了两次，所以追加此判断
        if (this.isFirstLoad) {
          this.isFirstLoad = false;
        } else {
          if (this.isOpenMedia) {
            // 第二次加载时表示已从视频页回退到主页，需要通知宿主关闭页面并回退，否则无法自动回退到宿主的页面
            HiLog.info(TAG, 'sendOpenMediaFinishEvent');
            UIExtSessionManager.getInstance().sendOpenMediaFinishEvent();
          }
          this.onPageShow();
        }
      })
      .bindSheet(this.isShowFileDetail && tabIndex === this.currentTabIndex,
        this.fileDetail(tabIndex), {
          height: SheetSize.FIT_CONTENT,
          dragBar: false,
          showClose: true,
          preferType: SheetType.CENTER,
          title: { title: $r('app.string.details') },
          blurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
          onAppear: () => {
            HiLog.info(TAG, 'fileDetail onAppear.');
          },
          onWillDisappear: () => {
            this.isShowFileDetail = false;
            if (GlobalHolder.getInstance().getObject(Constant.EVENTS.EXIT_MULTI_STATE)) {
              EventBus.emit(Constant.EVENTS.EXIT_MULTI_STATE);
              GlobalHolder.getInstance().deleteObject(Constant.EVENTS.EXIT_MULTI_STATE);
            }
          },
          onWillSpringBackWhenDismiss: ((SpringBackAction: SpringBackAction) => {
            //没有注册springBack, 下拉半模态页面无回弹行为
          })
        })
      .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
        return CustomTransition.getCustomAnimation(from, to, operation, this.currentTabIndex);
      })
      .accessibilityLevel(ACCESSIBILITY_LEVEL.AUTO)

      // 显示展开按钮：非预览且是分栏 且非设置进入的场景
      if (tabIndex === Constant.TAB_ID.TAB_BROWSE && !this.isPreviewMode && this.navMode === NavigationMode.Split) {
        ExpandButton({
          changeExpand: () => {
            this.setNavExpandAnimation();
          }
        }).margin({
          top: this.statusBarHeight,
          left: $r('sys.float.padding_level8'),
          right: $r('sys.float.padding_level8')
        })
          .opacity(this.opacityNum)
          .expandSafeArea([SafeAreaType.KEYBOARD])
          .accessibilityLevel(ACCESSIBILITY_LEVEL.AUTO)
      }
    }
    .padding({
      left: (!this.isPreviewMode && this.isAvoidCameraArea &&
        this.currentOrientation === display.Orientation.LANDSCAPE_INVERTED) ? this.avoidCameraAreaSize : 0,
      right: (!this.isPreviewMode && this.isAvoidCameraArea &&
        this.currentOrientation === display.Orientation.LANDSCAPE) ? this.avoidCameraAreaSize : 0
    })
    .onDrop(async (event: DragEvent, extraParams?: string) => {
      HiLog.info(TAG, 'onDrop');
      DragManager.getInstance().onDrop();
      CopyCutManager.getInstance().onDragJumpCallback(event, extraParams);
    })
    .onDragMove((event: DragEvent) => {
      let canDrag = DragManager.getInstance().supportDrag(this.startModeOptions);
      event.setResult(canDrag ? DragResult.DROP_ENABLED : DragResult.DROP_DISABLED);
    })
  }

  @Builder
  mainContent() {
    // 隐藏底部tab栏
    this.mainNavigation(this.browserPageStack, Constant.TAB_ID.TAB_BROWSE);
    this.appView();
    this.pathPickerContent();
  }

  // 监听是否触发文件详情弹窗
  emitEvent() {
    EventBus.on(Constant.EVENTS.TO_BROWSER_TAB, this.toBrowserTabBind);
    EventBus.on(Constant.EVENTS.ACCOUNT_LOGOUT, this.accountLogoutBind);
    EventBus.on(Constant.EVENTS.RESET_LOCAL_CLOUD_FOLDER, this.resetFolderBind);
    EventBus.on(Constant.EVENTS.SD_USB_CHANGE, this.externalChangeBind);
    EventBus.on(Constant.EVENTS.SHOW_PATH_PICKER, this.showPathPickerBind);
    EventBus.on(Constant.EVENTS.CLOSE_PATH_PICKER, this.closePathPickerBind);
    EventBus.on(Constant.EVENTS.CLOSE_UI_FILE_PICKER + this.startModeOptions.currentCreateTimeStamp, () => {
      this.uiPickerSwitch = false;
    }, true);
    EventBus.on(Constant.EVENTS.DRAG_JUMP, this.dragJumpBind);
  }

  @Builder
  fileDetail(tabIndex: number) {
    if (this.currentTabIndex === tabIndex) {
      Column() {
        FileDetailDialog({
          fileInfo: this.fileInfo,
          isRecentDeletePage: this.isRecentDeletePage,
          isMyPhonePage: this.isMyPhonePage,
          fromPage: this.fromPage,
          isOutsideFolded: this.isOutsideFolded,
          isOnPageShow: this.isOnPageShow,
          isJumpFromSettings: this.isJumpFromSettings,
          isPreviewForbidJump: this.isPreviewForbidJump
        })
      }
      .width('100%')
    }
  }

  // 获取摄像头避让
  async getCameraArea() {
    try {
      let isLandscape: boolean = true; // 是否横屏
      this.currentOrientation = display.getDefaultDisplaySync().orientation;
      if (this.currentOrientation === display.Orientation.LANDSCAPE_INVERTED) {
        // 若避让区域可见则进行避让
        if (this.windowAvoidArea.visible) {
          this.avoidCameraAreaSize = px2vp(this.windowAvoidArea.leftRect.width + this.windowAvoidArea.leftRect.left);
        }
      } else if (this.currentOrientation === display.Orientation.LANDSCAPE) {
        // 逆横屏，若避让区域可见则进行避让
        if (this.windowAvoidArea.visible) {
          this.avoidCameraAreaSize =
            px2vp(display.getDefaultDisplaySync().width - this.windowAvoidArea.rightRect.left);
        }
      } else {
        // 非横屏 使用系统自带避让
        this.avoidCameraAreaSize = 0;
        isLandscape = false;
      }

      // 横屏需要变化，分屏不需要变化，小屏也不需要变化, 三折叠也不需要变化
      this.isAvoidCameraArea = (this.windowStatus === window.WindowStatusType.FULL_SCREEN &&
        isLandscape && DisplayUtil.getFoldStatus() !== DisplayUtil.FOLD_STATUS_EXPANDED) &&
        this.avoidCameraAreaSize < LARGE_WINDOW_SIZE && !DisplayUtil.isXtDevice();
      HiLog.info(TAG,
        `MainEntry isAvoidCameraArea ${this.isAvoidCameraArea} avoidCameraAreaSize ${this.avoidCameraAreaSize} current
        Orientation ${this.currentOrientation}`)
    } catch (err) {
      HiLog.info(TAG, `MainEntry getCameraArea ${err} `)
    }
  }

  @Builder
  appView() {
    // 应用级布局，需要在任何页面拉起
    if (!GlobalHolder.getInstance().getObject<boolean>(GlobalKey.PICKER_FLAG)) {
      GlobalPasteboard();
      AppDialogs({
        isJumpFromSettings: this.isJumpFromSettings
      });
    }
  }

  @Builder
  pathPickerContent() {
    Column() {
    }
    .bindSheet(this.isShowPathPicker, this.pathPickerBuilder(), {
      height: SheetSize.LARGE,
      dragBar: false,
      showClose: false,
      preferType: SheetType.CENTER,
      onAppear: () => {
        HiLog.info(TAG, 'pathPickerBuilder onAppear');
      },
      onDisappear: () => {
        HiLog.info(TAG, 'pathPickerBuilder onDisAppear');
        // 路径选择器关闭时通知其他页面路径选择结束
        EventBus.emit(Constant.EVENTS.PATH_SELECT_END, this.selectedTreePath);
      },
      shouldDismiss: (sheetDismiss: SheetDismiss) => {
        HiLog.info(TAG, 'pathPickerBuilder shouldDismiss');
        sheetDismiss.dismiss();
      },
      onWillSpringBackWhenDismiss: ((springBackAction: SpringBackAction) => {
        //没有注册springBack, 下拉半模态页面无回弹行为
      }),
      onWillDisappear: () => {
        HiLog.info(TAG, 'pathPickerBuilder onWillDisappear');
        if (this.isShowPathPicker) {
          EventBus.emit(Constant.EVENTS.CLOSE_PATH_PICKER);
        }
      }
    })
  }

  @Builder
  pathPickerBuilder() {
    Column() {
      PathSelectTree({
        selectFilesList: this.pathSelectParam.selectFilesList,
        operationType: this.pathSelectParam.operationType,
        startModeOptions: this.startModeOptions,
        isOutsideFolded: this.isOutsideFolded
      })
    }
  }

  dealRecentTabPageInfos() {
    this.isPreventBackPress = false;
    if (this.pageInfos.size() <= 1) {
      this.pageInfos.clear(UiUtil.showSwitchAnimation(this.navMode));
      return;
    }
    let tempPathInfos: NavPathInfo[] = [];
    while (this.pageInfos.size() > 1) {
      tempPathInfos.push(this.pageInfos.pop(UiUtil.showSwitchAnimation(this.navMode)) as NavPathInfo);
    }
    this.pageInfos.clear(UiUtil.showSwitchAnimation(this.navMode));
    while (tempPathInfos.length > 0) {
      this.pageInfos.pushPath(tempPathInfos.pop(), UiUtil.showSwitchAnimation(this.navMode));
    }
  }

  onTabChange(index: number) {
    HiLog.info(TAG, 'onTabChange: ' + index);
    // 如果tab没有切换，没必要继续
    if (index === this.currentTabIndex) {
      return;
    }
    if (!this.isEdit && this.isSorted) {
      EventBus.emit(Constant.EVENTS.FAVORITE_REFRESH);
    }
    this.isEdit = false;
    // 解决卡顿：当前所在索引值交给currentTabIndex 放在onChange事件完成
    this.initPageInfos(index);
    // 暂时屏蔽最近页面相关
    EventBus.removeEmit(Constant.EVENTS.RECENTLY_REFRESH);
    this.navMode = this.browserNavMode;
    AppStorage.setOrCreate('isAnimationEnter', true);
    EventBus.emit(Constant.EVENTS.TAB_CHANGE, index);
    HiSysEventUtil.reportBottomTabClick(BottomTabNumber.BROWSE);
    UEUtil.reportBottomTabClick(DFX.BottomTabName.BROWSE);
    // 刷新外部存储设备的空间大小
    EventBus.emit(Constant.EVENTS.REFRESH_SD_USB_SPACE_SIZE);
    // 刷新内部存储的空间大小， 解决图库删除图片异步删除， 不即时刷新问题
    EventBus.emit(Constant.EVENTS.REFRESH_PHONE_SPACE_SIZE);
    CommonPreferenceUtil.setDefaultTabIndex(index);
    this.currentTabIndex = index;
  }

  @Builder
  pageMap(name: string, params: Object) {
    if (name === PAGE_ROUTE_CONST.MY_PHONE || name === PAGE_ROUTE_CONST.GALLERY ||
      name === PAGE_ROUTE_CONST.IMAGE || name === PAGE_ROUTE_CONST.VIDEO) {
      MyPhone({ pageParams: params, startModeOptions: this.startModeOptions });
    } else if (name === PAGE_ROUTE_CONST.RECENT_DELETE) {
      RecentDelete();
    } else if (name && name.startsWith(PAGE_ROUTE_CONST.FILE_PREVIEW)) {
      FilePreview({ pageParams: params });
    } else if (name && name.startsWith(PAGE_ROUTE_CONST.PREVIEW_TIP)) {
      PreviewTip();
    } else if (name === PAGE_ROUTE_CONST.WALLPAPER_PREVIEW) {
      WallpaperPreview({ pageParams: params });
    } else if (name === PAGE_ROUTE_CONST.FEATURE_INTRODUCE_PAGE) {
      FeatureIntroducePage();
    } else if (name === PAGE_ROUTE_CONST.SETTINGS) {
      Settings()
    }
  }

  async toTargetFolder(otherFrom: string) {
    const folderUri = GlobalHolder.getInstance().getObject<string>(GlobalKey.URI_PATH);
    HiLog.infoPrivate(TAG, 'toTargetFolder:folder uri:', `${folderUri}`);
    if (StringUtil.isEmpty(folderUri)) {
      HiLog.warn(TAG, 'toTargetFolder fail, folderUri is empty');
      return;
    }
    AppStorage.setOrCreate<boolean>('isDefaultShowRecent', false);
    // 路由跳转时关闭所有展示类弹窗
    EventBus.emit(Constant.EVENTS.CLOSE_INFO_DISPLAY_DIALOGS);
    this.isShowFileDetail = false;
    this.toBrowserTab();
    const params = {
      uriPath: folderUri,
      finishType: PageFinishType.DEFAULT,
      from: otherFrom
    } as AbilityOrRouterParams;
    if (FileUtil.isMediaUri(folderUri)) {
      let album: photoAccessHelper.Album | undefined =
        await PhotoAccessUtil.getAlbumByUri(getContext(this) as common.Context, folderUri);
      if (!album) {
        return;
      }
      let param = {
        path: folderUri,
        finishType: PageFinishType.DESTROY_PAGE,
        albumName: album.albumName,
        albumType: album.albumType as number,
        albumSubType: album.albumSubtype as number,
      } as AbilityOrRouterParams;
      this.pageInfos.pushPath(new NavPathInfo(PAGE_ROUTE_CONST.MY_PHONE, param));
    } else {
      this.currLocalFolder = '';
      this.jumpToTargetPage(PAGE_ROUTE_CONST.MY_PHONE, params)
    }
  }

  /**
   * 跳转到指定的页面
   * @param pageName 页面名
   * @param otherFrom 来自哪个场景
   */
  jumpToTargetPage(pageName: string, params: AbilityOrRouterParams) {
    try {
      /* 当第三方应用拉起文管，需要跳转到某个page时，先检查关于页面是否处于打开状态，如果是，先关闭关于页面再跳转到目标页面。 */
      const isAboutPageShowing = AppStorage.get<boolean>('showAboutPage');
      if (!this.isSingleScreen()) {
        this.showEntryBottomBarFlag = true;
      }
      const index = this.pageInfos.moveToTop(pageName, UiUtil.showSwitchAnimation(this.navMode));
      if (index === -1) {
        HiLog.info(TAG, `pushPath ${pageName} page`);
        this.currentNavItem = '';
        this.pageInfos.clear();
        this.pageInfos.pushPath(new NavPathInfo(pageName, params), UiUtil.showSwitchAnimation(this.navMode));
      } else {
        HiLog.info(TAG, `${pageName} page already exists`);
        // 跳转到默认页面时避免折叠异常需要清除掉默认标识
        const page = this.pageInfos.getPathStack()[index];
        const param = page.param as AbilityOrRouterParams;
        if (param?.isDefaultPage) {
          param.isDefaultPage = false;
        }
        EventBus.emit(Constant.EVENTS.OPEN_TARGET_FOLDER, params);
      }
    } catch (error) {
      HiLog.error(TAG, 'jumpToTargetPage error: ' + error.code + ', ' + error.message);
    }
  }

  isEditChange() {
    EventBus.emit(Constant.EVENTS.PREVENT_BACK_PRESS, this.isEdit);
    if (this.isEdit) {
      EventBus.on(Constant.EVENTS.BACK_PRESS, this.cancelEditBind);
    } else {
      EventBus.off(Constant.EVENTS.BACK_PRESS, this.cancelEditBind);
    }
  }

  cancelEdit() {
    this.isEdit = false;
  }

  onDarkModeChange() {
    if (this.isDarkMode) {
      UiUtil.setWindowBackground(SYSTEM_BAR_COLOR.PATH_PICK_DARK,
        FileCommonUtil.getWindowClass(this.filePickerViewFlag));
    } else {
      UiUtil.setWindowBackground(SYSTEM_BAR_COLOR.PATH_PICK, FileCommonUtil.getWindowClass(this.filePickerViewFlag));
    }
  }

  changeIsSingleScreenDisplay(): void {
    if (this.isSingleScreenDisplay) {
      this.positionLeft = 0;
      this.isExpand = false;
      if (this.pageInfos.size() > 0) {
        this.showEntryBottomBarFlag = false
      }
    }
  }

  onDidBuild(): void {
    HiLog.info(TAG, 'MainEntry onDidBuild');
    AccessibilityManager.getInstance().initAccessibilityModeListener();
    TaskManager.getInstance().execute(new ProcessFileRecycleTask()); // 恢复双升单回收站数据

    EventBus.on(Constant.EVENTS.SHOW_RECENT_DELETED_FILE_DETAIL_DIALOG,
      (fileInfo: FileInfo, isShowRecentDeleteFileDetail: boolean) => {
        this.isShowRecentDeleteFileDetail = isShowRecentDeleteFileDetail;
        this.fileInfo = fileInfo;
        this.isShowFileDetail = isShowRecentDeleteFileDetail;
        this.fromPage = PAGE_ROUTE_CONST.RECENT_DELETE;
        this.isRecentDeletePage = true;
      });
    EventBus.on(Constant.EVENTS.PREVENT_BACK_PRESS, this.preventBackPressBind);
    EventBus.on(Constant.EVENTS.UI_EXTENSION_PICKER_INDEX_CHANGE + this.startModeOptions.currentCreateTimeStamp,
      this.pickerCurrentIndexBind, true);
    EventBus.on(Constant.EVENTS.ACCESSIBILITY_FOCUS_JUMP, this.accessibilityFocusJumpBind);
    GlobalHolder.getInstance().setObject<boolean>(GlobalKey.INIT_ROOT_INFO_ON_PHONE_FIRST_LOAD, true);
    if (!GlobalHolder.getInstance().getObject<boolean>(GlobalKey.PICKER_FLAG)) {
      EventBus.on(Constant.EVENTS.FILE_MANAGER_ON_NEW_WANT, this.openPageBind);
      UIExtSessionManager.getInstance().sendHasOnOpenFolderEvent()
    }
    // 监听应用前后台切换
    EventBus.on(Constant.EVENTS.ABILITY_ON_FOREGROUND, this.startReadPasteboardTaskBind);
    this.emitDetailEvent();
    if (this.isJumpFromSettings) {
      HiLog.warn(TAG, 'MainEntry isJumpFromSettings true');
      return;
    }
    this.subscribeNetworkStateChange();
    this.initCommonPreferenceParam();
    this.loadDefaultPickDir();
    this.initPopupTipSwitch();
    // 订阅存储设备列表变化的公共事件
    StorageDeviceManager.getInstance().subscribeStorageDeviceChangeEvent(DeviceTypeConstants.PHONE);
    // 订阅账号状态变化公共事件
    AccountManager.getInstance().subscribeAccountChangeEvent();
    // 进入文管首次获取存储设备列表
    StorageDeviceManager.getInstance().getStorageDeviceList(true);
    // 打开文管读取剪切板
    PasteBoardManager.getInstance().startReadPasteboardTask(true, this.startModeOptions);
    // 打开文管时启动清理缩略图任务
    ThumbnailCacheManager.getInstance().cleanThumbnailCache();
    // 订阅包管理资源变化的公共事件
    BundleResourceUtil.subscribeBundleResourcesChangedEvent();
    // 订阅最近
    this.subscribeRecentRefreshEvent();
    this.emitEvent();
  }

  @Builder
  tabBarIconView(index: number, src: Resource) {
    Badge({
      value: '',
      position: BadgePosition.RightTop,
      style: {
        badgeSize: $r('app.float.common_size0'),
        badgeColor: $r('sys.color.ohos_id_color_badge_red')
      }
    }) {
      SymbolGlyph(src)
        .fontSize($r('app.float.common_size24'))
        .maxFontScale(Constant.BIG_MODE.BIG_MODE_1x)
        .fontColor(this.currentTabIndex === index ?
          [$r('sys.color.comp_background_emphasize')] : [$r('sys.color.icon_tertiary')])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
        .symbolEffect(new BounceSymbolEffect(EffectScope.LAYER, EffectDirection.DOWN), this.currentTabIndex === index)
    }
    .width($r('app.float.common_size24'))
    .height($r('app.float.common_size24'))
    .margin({
      right: this.isSingleScreen() ? $r('app.float.common_size0') : $r('app.float.common_size6')
    })
  }

  @Builder
  tabBarTextView(index: number, text: ResourceStr) {
    Text(text)
      .fontColor(this.currentTabIndex === index ?
        $r('sys.color.comp_background_emphasize') : $r('sys.color.ohos_id_color_text_secondary'))
      .fontSize(this.isSingleScreen() ? $r('app.float.common_size10') : $r('app.float.common_size12'))
      .fontFamily('HarmonyHeiTi')
      .fontWeight(FontWeight.Medium)
      .maxFontScale(Constant.BIG_MODE.BIG_MODE_1x)
      .lineHeight($r('app.float.common_line_height14'))
  }

  @Builder
  tabBarBuilder(index: number, src: Resource, text: ResourceStr) {
    if (this.isSingleScreen()) {
      Column() {
        this.tabBarIconView(index, src);
        this.tabBarTextView(index, text);
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ bottom: this.bottomNavBarHeight })
    } else {
      Row() {
        this.tabBarIconView(index, src);
        this.tabBarTextView(index, text);
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ bottom: this.bottomNavBarHeight })
    }
  }

  // 是否展示tips
  private getShowPickerTipsStatus(): boolean {
    let isShowTips: boolean = false;
    if (storage && storage.get(SecurityData.SecurityWarning) === undefined) {
      HiLog.info(TAG, 'getShowPickerTipsStatus is undefined');
      return isShowTips;
    }
    isShowTips = storage && storage.get(SecurityData.SecurityWarning) === SecurityWarning.DISAGREE;
    HiLog.info(TAG, 'getShowPickerTipsStatus is ${isShowTips}');
    return isShowTips;
  }

  private setNavInterception(): void {
    this.browserPageStack.setInterception(this.getInterception());
  }

  private getInterception(): NavigationInterception {
    let interception: NavigationInterception = {
      willShow: (from: NavDestinationContext | "navBar", to: NavDestinationContext | "navBar") => {
        if (typeof to === 'string') {
          HiLog.info(TAG, 'back to home page');
          PrivacyModeManager.getInstance().setPrivacyMode(false);
          return;
        } else {
          let target: NavDestinationContext = to as NavDestinationContext;
          const topPage = this.getTopPage()
          // 折叠屏多tab页场景
          // 但是这种场景不应该设置可截屏状态。
          if (topPage !== target.pathInfo.name) {
            HiLog.info(TAG, 'top not equal target page');
            return;
          }
          PrivacyModeManager.getInstance().onFrontPageChange(target.pathInfo.name);
        }
      }
    }
    return interception;
  }

  private getTopPage(): string | undefined {
    const allPathName = this.pageInfos.getAllPathName();
    return allPathName.pop();
  }

  private async subscribeRecentRefreshEvent(): Promise<void> {
    commonEventManager.createSubscriber({
      events: [REFRESH_RECENT_EVENT], // 订阅最近刷新公共事件
    }).then(recentSubscriber => {
      this.recentSubscriber = recentSubscriber;
      commonEventManager.subscribe(recentSubscriber,
        (err: BusinessError, data: commonEventManager.CommonEventData) => {
          if (err) {
            HiLog.error(TAG, `Failed to subscribe common event. Code is ${err.code}, message is ${err.message}`);
            return;
          }
          HiLog.info(TAG, `INDEX_INSERT_REFRESH_RECENT`);
        });
    })
  }

  private pickerCurrentIndexChange(index: number) {
    CommonPreferenceUtil.setFilePickerDefaultTabIndex(index);
    if (this.startModeOptions.isUxt()) {
      this.currentTabIndex = index;
    }
    this.pickerCurrentIndex = index;
  }

  private onWindowSizeChange() {
    UiUtil.onWindowSizeChange((size: window.Size) => {
      HiLog.info(TAG, `onWindowSizeChange size width: ${size.width}, height: ${size.height}`);
      //监听到窗口变化则重新判断是否为外折叠态
      this.isOutsideFolded = DisplayUtil.isOutsideFolded();
      this.isTripleExpand = DisplayUtil.isTripleFoldExpanded();
      const width = this.getUIContext().px2vp(size.width);
      if (this.isSingleScreenDisplay !== width <= BreakPoint.SM) {
        this.setTabsScroller();
        this.isSingleScreenDisplay = width <= BreakPoint.SM;
      }
    });
  }

  /**
   * 文件选择器状态，如果用户制定了默认选择器目录，就直接跳转到存储的指定目录
   */
  private loadDefaultPickDir() {
    if (!this.filePickerViewFlag) {
      this.loadPickFinish = true;
      return;
    }
    this.isShowPickerTips = this.getShowPickerTipsStatus();
    const defaultPickPath: string = AbilityCommonUtil.getFileDefaultPickPath(this.startModeOptions);
    if (StringUtil.isEmpty(defaultPickPath)) {
      this.loadPickFinish = true;
      return;
    }
    StorageDeviceManager.getInstance().getStorageDeviceList().then((storageDeviceList: DiskInfo[]) => {
      if (ObjectUtil.isUndefined(storageDeviceList) || ArrayUtil.isEmpty(storageDeviceList)) {
        this.loadPickFinish = true;
        HiLog.warn(TAG, 'storageDeviceList is empty');
        return;
      }
      let pageUrl = PAGE_ROUTE_CONST.MY_PHONE;
      if (!this.loadPickFinish) {
        this.restCurrFolder(pageUrl);
        this.pageInfos.pushPath(new NavPathInfo(pageUrl, { 'uriPath': defaultPickPath, } as AbilityOrRouterParams),
          false);
        this.loadPickFinish = true;
      }
    })
  }

  private openFilePickerAgain(): void {
    if (GlobalHolder.getInstance().getObject<boolean>(GlobalKey.OPEN_FILE_PICKER_AGAIN)) {
      this.loadPickFinish = false;
      this.loadDefaultPickDir();
      GlobalHolder.getInstance().deleteObject(GlobalKey.OPEN_FILE_PICKER_AGAIN);
    }
  }

  /**
   * 监听网络变化，网络不可用时，给出toast 网络未连接，请检查网络设置
   */
  private async subscribeNetworkStateChange() {
    // 创建NetConnection对象
    this.netCon = connection.createNetConnection();
    // 先使用register接口注册订阅事件
    this.netCon.register((error: BusinessError) => {
      if (error) {
        HiLog.error(TAG, 'network state change register error: ' + error);
      }
    });
    // 订阅网络可用事件。调用register后，才能接收到此事件通知
    this.netCon.on('netUnavailable', () => {
      HiLog.info(TAG, 'network net unavailable');
      this.isNetWork = false;
      // 首次启动时未连接网络置false
      AppStorage.setOrCreate(Constant.APP_STORAGE_KEY_NETWORK_AVAILABLE, false);
    });
    // 联网后自动触发netCapabilitiesChange监听
    this.netCon.on('netCapabilitiesChange',
      async (data: connection.NetCapabilityInfo) => this.netCapabilitiesChangeCallBack(data));
    // 断网后自动触发netLost监听
    this.netCon.on('netLost', async (data: connection.NetHandle) => this.netLostCallBack(data));
  }

  private async netCapabilitiesChangeCallBack(data: connection.NetCapabilityInfo) {
    if (!data || !data.netCap) {
      HiLog.warn(TAG, 'netCapabilitiesChangeCallBack param is null or undefined.');
    } else {
      HiLog.info(TAG, `netCapabilitiesChange is: ${JSON.stringify(data.netCap.networkCap)}`);
      if (data.netCap.bearerTypes) {
        if (data.netCap.bearerTypes.length > 0) {
          this.isCellular = (data.netCap.bearerTypes[0] === connection.NetBearType.BEARER_CELLULAR);
        }
        HiLog.info(TAG, `netCapabilitiesChange isCellular: ${this.isCellular}`);
      }
      // 连接状态下网络可用发生变化，刷新标志位
      if (data.netCap.networkCap?.includes(connection.NetCap.NET_CAPABILITY_VALIDATED)) {
        AppStorage.setOrCreate(Constant.APP_STORAGE_KEY_NETWORK_AVAILABLE, true);
        HiLog.info(TAG, 'refreshNetworkUsable: netWork usable');
      } else {
        AppStorage.setOrCreate(Constant.APP_STORAGE_KEY_NETWORK_AVAILABLE, false);
        HiLog.info(TAG, 'refreshNetworkUsable: netWork unusable');
      }
    }
    this.isNetWork = true;
  }

  private async netLostCallBack(data: connection.NetHandle) {
    HiLog.info(TAG, 'netLostCallBack: lost net connection');
    this.isNetWork = false;
    this.isCellular = false;
    AppStorage.setOrCreate(Constant.APP_STORAGE_KEY_NETWORK_AVAILABLE, false);
  }

  private isDirectPhoneLandCape(): boolean {
    // 是否为直板机
    const isDirectPhone: boolean = GlobalHolder.getInstance().getObject<boolean>(GlobalKey.IS_DIRECT_PHONE);
    // 是否为折叠屏折叠态
    const isFoldStatusFolded: boolean = DisplayUtil.getFoldStatus() === DisplayUtil.FOLD_STATUS_FOLDED;
    // 获取当前屏幕状态，用于判断是否为竖屏
    let orientation: display.Orientation = -1;
    try {
      orientation = display.getDefaultDisplaySync().orientation;
    } catch (error) {
      HiLog.error(TAG, `display getDefaultDisplaySync error ${JSON.stringify(error)}`);
    }
    let isPortraitMode: boolean = false;
    if (orientation === display.Orientation.PORTRAIT || orientation === display.Orientation.PORTRAIT_INVERTED) {
      isPortraitMode = true;
    }
    return isPortraitMode && (isDirectPhone || isFoldStatusFolded);
  }

  private async initCommonPreferenceParam() {
    // 获取收藏页面展开标识
    const isFavouriteListExpend: boolean = await CommonPreferenceUtil.getFavouriteListExpand();
    AppStorage.setOrCreate<boolean>(PreferenceConst.KEY.FAVORITE_LIST_EXPAND, isFavouriteListExpend);
  }

  private isCurrentPageHasPhotos(): boolean {
    return false;
  }

  private initPopupTipSwitch() {
    Object.values(PopupTips).forEach(async (tipKey) => {
      const tipSwitch: boolean = await CommonPreferenceUtil.getTipsAlreadyShowSwitch(tipKey);
      AppStorage.setOrCreate<boolean>(tipKey, tipSwitch);
    })
  }

  // 是否跳过首页
  private isHomePageShown(): boolean {
    return this.startModeOptions.isUxt() && (this.startModeOptions.defaultFilePathUri.length > 0);
  }

  private isShellAppCompatibleCall(): boolean {
    return GlobalHolder.getInstance().getObject<number>(GlobalKey.SHELL_APP_COMPATIBLE_VERSION) >
    ShellAppCompatibleVersion.DEFAULT_VER;
  }

  private emitDetailEvent(): void {
    EventBus.on(Constant.EVENTS.FILE_DETAIL,
      (fileInfo: FileInfo, isRecentDeletePage: boolean, isMyPhonePage: boolean,
        fromPage: string, isPreviewForbidJump: boolean) => {
        this.fileInfo = fileInfo;
        this.isRecentDeletePage = isRecentDeletePage;
        this.isMyPhonePage = isMyPhonePage;
        this.fromPage = fromPage;
        this.isShowFileDetail = true;
        this.isPreviewForbidJump = isPreviewForbidJump;
      });
    EventBus.on(Constant.EVENTS.FILE_DETAIL_SHOW, (isShowFileDetail: boolean) => {
      this.isShowFileDetail = isShowFileDetail;
    })
  }
}