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
  AbilityCommonUtil,
  AbilityName,
  AbilityOrRouterParams,
  AddressData,
  ArrayUtil,
  BOTTOM_BAR_MAP,
  BottomCallParams,
  BundleResourceUtil,
  CommonPreferenceUtil,
  Constant,
  DEFAULT_SORT_ORDER,
  DisplayUtil,
  DragManager,
  ERROR_CODE,
  EventBus,
  ExternalStorageUtil,
  FavoriteDbManager,
  FileDataSource,
  FileDataUtil,
  FileInfo,
  FileOperation,
  FilePickerUtil,
  FileSortParamUtil,
  FileUtil,
  getResourceString,
  GlobalHolder,
  GlobalKey,
  GroupAndSortParam,
  HiLog,
  HiSysEventUtil,
  HiTraceConst,
  LocalStorageConst,
  MyPhoneConstant,
  ObjectUtil,
  OperateName,
  OperateResult,
  PAGE_ROUTE_CONST,
  PageFinishType,
  PageUtil,
  PasteboardDataModel,
  PasteBoardManager,
  PhoneFilePickerUtil,
  PreferenceConst,
  QueryFileParam,
  RenameItem,
  ResultCodePicker,
  SortOrder,
  SortUtil,
  StartModeOptions,
  StorageDeviceManager,
  StringUtil,
  TaskManager,
  TaskStatus,
  toast,
  TopMenuDivider,
  TraceUtils,
  UiUtil,
  UsageHabitsPreferenceUtil,
  UserState,
  ViewMode,
  VirtualUri,
  WorkerConst,
  ThreadCommonUtil,
  FileOrGroup,
  DeviceTypeConstants,
  AppDataPathUtil,
  AccessibilityManager,
  FsUtil,
  ResourceUtil,
  CompId,
  PhotoAlbumSubType,
  UUID_TYPE,
  CalculateFolderListSizeTask,
  SettingsUtil,
  ThrottlingUtil,
  LocationType,
  FileMimeTypeUtil,
  DFX,
  EnumTransferUtil,
  UEUtil,
  PhotoAlbumType,
  QueryCheckedFilesSizeTask,
  renderSize,
  FileSourceUri,
  AppPackageName,
  RenameUtil,
  AppInfo,
  UdmfUtils,
  MenuUtil,
  PageRefreshData,
  DataPreferenceUtil,
  MenuItemName,
  MenuInfo,
  DeviceConfig,
  UsageHabitsPreferenceConst,
  UsageHabits,
  FolderOperationType,
  FilesQueryUtil,
  ToolBarStyle,
  TransitionAnimationController,
  CustomTransition,
  StandardAnimation,
  CreateDownloadUriShowMapTask,
  CommonUtil,
  COLOR_MODE,
  TabBarStyle,
  AccessibilityStorageKey,
  DataStatus
} from '@ohos/common';
import { getCurrentFolderPathByBreadCrumb, getDiskDes, menuCanClick } from '../../../base/utils/Common';
import lazy {
  PrintUtil,
  QueryLocalFileTask,
  QueryDownloadReceiveFileTask,
  promptAction
} from '@ohos/common/indexLazyLoad';
import { CellularTransmissionDialog, FileTypeFilterDialog } from '@ohos/customDialog';
import { Loading } from '../../component/common/Loading';
import lazy { FileListView, OutsideScreenFileListView } from '@ohos/fileView';
import { CopyCutManager } from '../../../base/manager/CopyCutManager';
import lazy { PreviewUtil } from '@ohos/common/src/main/ets/utils/PreviewUtil';
import CopyCutConst from '../../../base/constants/CopyCutConst';
import { FileCommonUtil } from '../../../base/utils/FileCommonUtil';
import { FileReportUtils } from '../../../base/report/FileReportUtils';
import { BreadCrumb } from '@ohos/breadCrumb';
import { MENU_ICONS, MENU_NAME, TitleBarComp, TitleMenuItem, TopMenuItem } from '@ohos/titleBar';
import lazy { BottomBar, BottomOptions } from '@ohos/bottomBar';
import { PathSelectParam } from '../../component/pathselect/PathSelectModel';
import { UiPickerButtonTips } from '../../picker/UiPickerButtonTips';
import { collections, JSON } from '@kit.ArkTS';
import data_preferences from '@ohos.data.preferences';
import { FileListViewLayout } from '@ohos/fileView/src/main/ets/default/viewModel/FileListViewLayout';
import lazy { LoadingDialog } from '@ohos/common/indexLazyLoad';
import { ShieldUri } from '@ohos/common/src/main/ets/const/FolderRecord';
import { MenuActionHandler } from '../../../base/manager/MenuActionHandler';
import { SideBarItem, SideBarItemModel } from '@ohos/sideBar';
import lazy { PhotoAccessUtil } from '@ohos/common/indexLazyLoad';
import { displaySync } from '@kit.ArkGraphics2D';
import { inputConsumer, KeyCode, KeyEvent } from '@kit.InputKit'
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'myPhone';

const rootFlag: string = 'root';
const TIPS_SHOW_TIMES_LIMIT: number = 3;
const ACCESSIBILITY_DELAY: number = 200;

const IMAGE_SIZE_FILTER_TRANS: number = 1000;
const IMAGE_SIZE_FILTER_DEFAULT: number = 30;
const BOTTOM_BAR_DIVIDE_INDEX: number = 4; // 用于分割不同界面的底部按钮组
const MAX_PERSIST_PERMISSION: number = 500;
const LATEST_RENAME_ITEMS: string = 'LATEST_RENAME_ITEMS';
const ORDER_NO_LOADING_FILES_THRESHOLD: number = 10000; // 排序不显示Loading的文件数

@Component
export struct MyPhone {
  // private timer: number = 0;
  // private oldValue: string = '';
  @State changeValue: string = '';
  controller: SearchController = new SearchController()
  @State isSearching: boolean = false;
  @LocalStorageProp(LocalStorageConst.STATUS_BAR_HEIGHT) statusBarHeight: number = 0;
  @LocalStorageProp(LocalStorageConst.BOTTOM_NAV_BAR_HEIGHT) bottomNavBarHeight: number = 0;
  /**
   * 正在加载
   */
  @State isShowLoading: boolean = false;
  private timeoutId: number = -1;
  @State isQueryEnd: boolean = false;
  /**
   * 面包屑
   */
  @State @Watch('onDireListChange') direList: AddressData[] = [];
  @State selectFilesList: FileInfo[] = [];
  @State allIsFolder: boolean = false;
  @State checkedNum: number = 0;
  @State @Watch('checkedNumChange') allCheckedNum: number = 0;
  @State isSelectAll: boolean = false;
  @State @Watch('optionChange') selectItem: string = '';
  @State @Watch('onUserStateChange') userState: UserState = UserState.BROWSER;
  @Consume showEntryBottomBarFlag: boolean;
  /**
   * 折叠机和直板机动效区分
   */
  @StorageLink('isAnimationShow') isAnimationShow: boolean = true;
  private startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();
  private filePickerViewFlag: boolean = this.startModeOptions.pickerFlag;
  @Consume isOpenMedia: boolean;
  /**
   * 增量授权模式
   */
  private isPersistPermission: boolean = this.startModeOptions.isPersistPermission;
  private tokenID: number = this.startModeOptions.tokenID;
  /**
   * 复制移动源文件路径
   */
  private copyCutSrcPath: string = '';
  private currentLanguage: string = AppStorage?.get<string>('systemLanguage') ?? '';
  private queryId = 0;
  @State moveType: string = '';
  @Provide isListView?: boolean = false;
  @Consume isLoading: boolean;
  @State originalTitle: string | Resource = '';
  /**
   * 搜索的目录
   */
  @State currentFolderUri: string = '';
  private rootUri: string = '';
  @State @Watch('onVirtualRootUriChange') virtualRootUri: string = '';
  @State isShowLocateAni: boolean = false;
  private rootRelativePath: string = '';
  private targetPath: string = '';
  private currentVirtualFolderUri: string = '';
  /**
   * picker窗下点击图库需要通过uriPath屏蔽搜索框
   */
  private uriPath: string = '';
  /**
   * 外部存储的唯一标识
   */
  @State uuid: string = '';
  // 判断当前页面是否为TF卡页面
  @State isTfCardPage: boolean = false;
  private finishType: PageFinishType = PageFinishType.DEFAULT;
  // 标题栏左侧icon
  @State leftIcon: TitleMenuItem = new TitleMenuItem();
  // 标题栏右侧icons
  @State rightIcons: Array<TitleMenuItem> = [];
  /**
   * 排序规则
   */
  @Provide @Watch('onSelectOrderAccept') order: string = SortOrder.TIME;
  @Provide viewMode: string = ViewMode.LIST;
  // 右上角菜单
  @State topMenu: Array<TopMenuItem> = [];
  @State pickerCheckArr: string[] = [];
  /**
   * 是否阻止页面返回
   */
  private isPreventBack: Boolean = false;
  /**
   * 是否倒序
   */
  @Provide @Watch('onSelectOrderAccept') isDesc: boolean = true;
  @State selectName: string = '';
  @State fileSize: number = 0;
  @State scrollStartIndex: number = 0;
  @State listYOffset: number = 0;
  @State listScrollShow: boolean = true;
  @State breadScrollEnd: boolean = false;
  private isFirstLoad: boolean = false;
  /**
   * 页面是否展示
   */
  @State isPageShow: boolean = false;
  isActive: boolean = false;
  @StorageLink('myPhoneRefresh') @Watch('dealRefreshWhenShow') myPhoneRefresh: boolean = false;
  @StorageLink('galleryRefresh') @Watch('dealGalleryRefresh') galleryRefresh: PageRefreshData
    = new PageRefreshData('', false);
  @StorageProp('isDarkMode') isDarkMode: boolean = false;
  private queryTask?: QueryLocalFileTask;
  private queryDownloadReceiveFileTask?: QueryDownloadReceiveFileTask;
  private pageParams: AbilityOrRouterParams | Object = {} as AbilityOrRouterParams;
  private pageFrom: string = '';
  private backFromPreview: boolean = false;
  @Consume('pageInfos') pageInfos: NavPathStack;
  @Consume('navMode') @Watch('onNavModeChange') navMode: NavigationMode;
  @Consume('currentNavItem') currentNavItem: string;
  @Consume('currLocalFolder') currLocalFolder: string;
  @Consume isVerticalTabBar: boolean;
  @Consume isPreviewMode: boolean;
  @Consume isEdit: boolean;
  // 搜索转场动效
  @State isAnimationEnter: boolean = false;
  @StorageLink('isRightShowMotion') isRightShowMotion: boolean = false;
  private albumType?: number;
  private albumSubType?: number;
  // 非根目录超1W+文件夹组装数据list
  @State concatData: FileInfo[] = [];
  @State handleMenu: boolean = false;
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  @State allIsFavorite: boolean = false;
  private isNeedRefreshDeviceItem: boolean = false;
  @State longPressChangeType: string = Constant.OPERATION_TYPE.PLAY;
  @Provide({ allowOverride: 'operationType' }) operationType: string = '';
  private accessibilityManager: AccessibilityManager = AccessibilityManager.getInstance();
  private printBind: Function = (): void => this.printChange();
  private copyBind: Function = (filInfo?: FileInfo): void => this.longPressCopy(filInfo);
  private moveBind: Function = (): void => this.moveChange();
  private setAsWallpaperBind: Function =
    (filInfo?: FileInfo): void => this.longPressTypeChange(Constant.OPERATION_TYPE.SET_AS_WALLPAPER, filInfo);
  private deleteBind: Function = (): void => this.longPressTypeChange(Constant.OPERATION_TYPE.DELETE);
  private renameBind: Function = (): void => this.longPressTypeChange(Constant.OPERATION_TYPE.RENAME);
  private openFolderBind: Function =
    (fileInfo: FileInfo): void => this.longPressTypeChange(Constant.OPERATION_TYPE.OPEN_FOLDER, fileInfo);
  private detailBind: Function = (): void => this.longPressTypeChange(Constant.OPERATION_TYPE.DETAIL);
  private otherAppBind: Function =
    (fileInfo: FileInfo): void => this.longPressTypeChange(Constant.OPERATION_TYPE.OTHER_APP, fileInfo);
  private detailClickBind: Function = (closeDialog: boolean): void => this.detailClick(closeDialog);
  private addNewFolderBind: Function = (newFolderName: string): Promise<void> => this.addNewFolder(newFolderName);
  /**
   * 当前文件夹name
   */
  private curFolderName: string = '';
  private dragInfo: string = '';
  // 长按菜单对应的文件
  @State fileInfo: FileInfo = new FileInfo();
  private incrementalQueryStart: boolean = false;
  private removeDeletedFileFromListBind: Function =
    (deletedFileList: string[], operationType: string) => this.removeDeletedFileFromList(deletedFileList,
      operationType);
  private resolvePathSelectEndBind: Function =
    (folderUri: string): Promise<void> => this.resolvePathSelectEnd(folderUri);
  private preventBackPressBind: Function = (isPreventBack: boolean) => this.preventBackPress(isPreventBack);
  private initDataBind: Function = () => this.initData();
  @StorageLink(Constant.SHOW_HIDDEN_ITEM_OPTION_NAME) @Watch('refreshData') showHiddenItem: boolean = false;
  @StorageLink(Constant.REFRESH_PAGE) @Watch('refreshData') isRefresh: boolean = false;
  private sdUsbChangeBind: Function = (uriArray: string[]) => this.sdUsbChange(uriArray);
  private isPullUpFromExternalBind: Function =
    (params: AbilityOrRouterParams): boolean => this.isPullUpFromExternal(params);
  private refreshFolderSubFileCountBind: Function = (folderUri: string) => this.refreshFolderSubFileCount(folderUri);
  private isPullEnd = true;
  @State createResultType: number = ERROR_CODE.PICKER.SAVE_SUCCESS;
  private queryLocalFileCallbackBind: Function =
    (result: FileInfo[], status: TaskStatus, queryId: number): void => this.receiveFileData(result, status, queryId);
  @State fileSource: FileDataSource = new FileDataSource();
  @State isFilter: boolean = false;
  private isBlackList: boolean = false;
  private suffixes: string[] = [];
  // 是否展示文件类型筛选半模态弹窗
  @State isShowSuffixFilter: boolean = false;
  @Provide suffixSheetType: SheetType = SheetType.BOTTOM;
  @State bottomOption: BottomOptions[] = [];
  @State @Watch('queryStateEndHandle') isQueryStateEnd: boolean = false;
  private isCurrentFileFound: boolean = false;
  // 返回根父目录时回到点击位置的偏移
  @State rootYOffset: number = 0;
  @State rootYOffsetIndex: number = 0;
  private oldTotal: number = 0;
  // 聚合视图下图片与视频下的文件夹，我的手机/图库目录下的文件夹，仅支持详情和删除操作
  private defaultBottomOption: BottomOptions[] = [
    // 复制
    new BottomOptions(Constant.OPERATION_TYPE.COPY, BOTTOM_BAR_MAP.copy, MENU_ICONS.copy, false, true),
    // 删除
    new BottomOptions(Constant.OPERATION_TYPE.DELETE, BOTTOM_BAR_MAP.delete, MENU_ICONS.delete, false, true),
    // 更多
    new BottomOptions(Constant.OPERATION_TYPE.MORE, BOTTOM_BAR_MAP.more, MENU_ICONS.more, false, true),
  ];
  private firstTargetEnter: boolean = false;
  @State needHighlight: boolean = false;
  @Provide sourceFlag: string = '';
  @Consume @Watch('onIsOutsideFoldedChange') isOutsideFolded: boolean;
  private isOutsideScreenDevice: boolean = DisplayUtil.isOutsideScreenDevice();
  @Consume @Watch('onIsDownScrollingChange') isDownScrolling: boolean;
  @State isShowTitleBar: boolean = true;
  @State titleBarTransitionEffect?: TransitionEffect<'asymmetric'> =
    TransitionEffect.asymmetric(this.scrollAppearTransition, this.scrollDisappearTransition);
  // 滚动显示动效
  private scrollAppearTransition?: TransitionEffect = undefined;
  // 滚动消失动效
  private scrollDisappearTransition?: TransitionEffect = undefined;
  private dataPreferences: data_preferences.Preferences | undefined = DataPreferenceUtil.getPreferencesSync(
    GlobalHolder.getInstance().getAppContext() as Context, { name: 'settingImageSizeFilter' });
  // 布局参数
  @State fileListViewLayout: FileListViewLayout = new FileListViewLayout;
  @State checkedSizeSubTitle: ResourceStr = '';
  private lastRandom: number = 0;
  private subTitleChangeTime: number = 0;
  @State curTypeSourcefileCount: number = 0;
  @Consume('isPhotosPage') isPhotosPage: boolean;
  @State showMaskLayer: boolean = false;
  @Consume('showPickerMaskLayer') showPickerMaskLayer: boolean;
  private menuActionHandler?: MenuActionHandler = undefined;
  private menuActionCallback: Function = (menuInfo: MenuInfo) => this.onMenuActionCallback(menuInfo);
  private navDestinationId: string = '';
  private folderAnimationCallBack: Function = () => this.resetFolderOperateType();
  @State animationController: TransitionAnimationController =
    new TransitionAnimationController(0, 1, 0, 1, this.folderAnimationCallBack);
  // 文件夹操作类型
  @State @Watch('onFolderOperationChange') folderOperateType: FolderOperationType = FolderOperationType.NONE;
  private isReplaced: boolean = false;
  private needJumpByBread: boolean = false;
  @Consume('isExpand') isExpand: boolean; // 是否为展开内容区域
  @Consume previewFileUri: string;
  // 页面内本页组件透明度 用于淡入淡出动效
  @State curPageOpacity: number = 1;
  @State isClosePage: boolean = false;
  // 分帧渲染逻辑，在第二帧时渲染mainContent
  @State isSecondFrame: boolean = false;
  private displaySync: displaySync.DisplaySync | undefined = undefined;
  private currentFrame: number = 0;
  @Consume @Watch('onTabIndexChange') currentTabIndex: number;
  private enterTabIndex: number = 0;
  private goToCurrentUri: string = ''; // 用于最近卡片右上角按钮跳转到来源对应位置
  private isShowMaskWhenPageShow: boolean = false;
  // 定义 Ctrl+C 快捷键配置
  private copyOption: inputConsumer.HotkeyOptions = {
    preKeys: [KeyCode.KEYCODE_CTRL_LEFT], // 修饰键（Ctrl）
    finalKey: KeyCode.KEYCODE_C, // 被修饰键（C）
    isRepeat: false // 不重复上报
  };
  // 定义Ctrl+V 快捷键配置
  private pasteOption: inputConsumer.HotkeyOptions = {
    preKeys: [KeyCode.KEYCODE_CTRL_LEFT], // 修饰键（Ctrl）
    finalKey: KeyCode.KEYCODE_V, // 被修饰键（V）
    isRepeat: false
  };
  private timeout: number | null = null;
  private readonly debounceTime: number = 500; // 防抖时间500ms
  @State searchResults: FileInfo[] = []; //搜索结果
  private originalFileList: FileInfo[] = []; //原始文件列表
  private searchQueryId: number = 0;
  private searchConcatData: FileInfo[] = []; // 添加累积变量

  aboutToAppear(): void {
    TraceUtils.startTrace(HiTraceConst.MY_PHONE_PAGE_ABOUT_TO_APPEAR);
    HiLog.info(TAG, 'MyPhone aboutToAppear');
    let task = new CreateDownloadUriShowMapTask((data: collections.Map<string, string>) => {
      BundleResourceUtil.setDownloadUriShowMap(data);
    });
    TaskManager.getInstance().executeTask(task);
    this.enterTabIndex = this.currentTabIndex;
    this.isFirstLoad = true;
    const params: AbilityOrRouterParams = this.getParams();
    this.getFileUsageHabits();
    this.initTitle(true);
    this.dealFromType();
    if (this.needJumpByBread) {
      this.jumpToBreadDirectory(params);
    } else if (this.isRootFolder()) {
      this.refreshRootListPage(true);
    } else {
      this.firstTargetEnter = true;

      // 如果是跳转到相册，需要带albumType、subType、相册名
      let param = this.pageParams as AbilityOrRouterParams;
      this.toTargetFolder(this.targetPath, param?.albumType, param?.albumSubType, param?.albumName);
    }
    this.initOutsideDeviceParam();
    this.updateTitleBarTransitionEffect();
    this.addEventListener();
    this.initGalleryAuthState();
    this.dragInfo = GlobalHolder.getInstance().getObject<string>(GlobalKey.DRAG_INFO_TIME) ?? '';
    AppStorage.delete(LATEST_RENAME_ITEMS);
    FileReportUtils.reportPageEvent('myphone');
    this.menuActionHandler = new MenuActionHandler(this.getFromPage());
    this.menuActionHandler.registerMenuEvent([MenuItemName.FAVORITE, MenuItemName.UN_FAVORITE,
      MenuItemName.SET_RINGTONE],
      this.menuActionCallback);
    this.addFrameListener();
    TraceUtils.finishTrace(HiTraceConst.MY_PHONE_PAGE_ABOUT_TO_APPEAR);
    this.goToCurrentUri = (this.pageParams as AbilityOrRouterParams)?.currentFileUri;
  }

  // 监听快捷键
  onShortcutMonitoring() {
    try {
      inputConsumer.on('hotkeyChange', this.copyOption, () => {
        HiLog.info(TAG, `Ctrl+C hotkeyOptions: ${JSON.stringify(this.copyOption)}`)
        HiLog.info(TAG, `Ctrl+C direList: ${JSON.stringify(this.direList)}`)
        // 复制uri到剪贴板
        this.writePasteBoardCallback(this.selectFilesList)
      })
    } catch (error) {
      console.error(`${TAG}  Subscribe failed, error: ${JSON.stringify(error, [`code`, `message`])}`);
    }
    HiLog.info(TAG, `Ctrl+C hotkeyChange succeed`)

    try {
      inputConsumer.on('hotkeyChange', this.pasteOption, () => {
        HiLog.info(TAG, `Ctrl+V hotkeyOptions: ${JSON.stringify(this.pasteOption)}`)
        HiLog.info(TAG, `Ctrl+V direList: ${JSON.stringify(this.direList)}`)
        // 从剪贴板  粘贴文件
        this.holdToPaste()
      })
    } catch (error) {
      console.error(`${TAG}  Subscribe failed, error: ${JSON.stringify(error, [`code`, `message`])}`);
    }
    HiLog.info(TAG, `Ctrl+V hotkeyChange succeed`)
  }

  // 关闭监听快捷键
  offShortcutMonitoring() {
    HiLog.info(TAG, `off shortcut monitoring`)
    try {
      inputConsumer.off('hotkeyChange', this.copyOption);
      inputConsumer.off('hotkeyChange', this.pasteOption);
    } catch (error) {
      console.error(`${TAG}  Unsubscribe failed, error: ${JSON.stringify(error, [`code`, `message`])}`);
    }
  }

  /**
   * 分帧渲染，当前第一帧耗时过长，导致响应性能差，将mainContent移到第二帧，提升响应性能
   */
  addFrameListener() {
    // Creating a DisplaySync Object
    this.displaySync = displaySync.create();
    // Add Frame Callback
    this.displaySync.on('frame', () => {
      this.currentFrame++;
      if (this.currentFrame === 2) {
        this.isSecondFrame = true;
        this.displaySync?.stop();
      }
    });
    // Enable frame callback listening
    this.displaySync.start();
  }

  // 跳转到面包屑目录
  jumpToBreadDirectory(params: AbilityOrRouterParams): void {
    this.rootYOffset = params.direList[0].yOffset;
    this.rootYOffsetIndex = params.direList[0].startFileIndex;
    params.direList.splice(0, 1);
    // 打开文件夹
    this.direList = params.direList;
    this.breadScrollEnd = true;
  }

  initOutsideDeviceParam() {
    if (this.isOutsideScreenDevice) {
      // 初始化滚动条记录
      AppStorage.setOrCreate<number>(Constant.OUTSIDE_SCREEN_SCROLL_KEY, 0);
    }
  }

  updateTitleBarTransitionEffect() {
    // 更新动画
    if (this.isOutsideFolded) {
      this.titleBarTransitionEffect =
        TransitionEffect.asymmetric(this.scrollAppearTransition, this.scrollDisappearTransition);
      // 文件夹操作使用自定义的转场动效，不使用transition
    } else if (this.folderOperateType || this.navMode === NavigationMode.Split) {
      this.titleBarTransitionEffect = undefined;
    } else {
      this.titleBarTransitionEffect = StandardAnimation.AnimationConstants.STANDARD_TITLE_TRANSITION;
    }
  }

  onIsOutsideFoldedChange() {
    // 展开是重新获取持久化配置
    if (!this.isOutsideFolded) {
      this.getFileUsageHabits();
    }
    // 初始化下滑标识
    this.isDownScrolling = false;
    this.isShowTitleBar = true;
    this.updateTitleBarTransitionEffect();
  }

  onIsDownScrollingChange() {
    if (this.isOutsideFolded && this.userState != UserState.MULTI_START) {
      this.scrollAppearTransition = TransitionEffect.translate({ y: -100 }).animation({
        curve: Curve.EaseIn, duration: 400
      });
      this.scrollDisappearTransition = TransitionEffect.translate({ y: -100 }).animation({
        curve: Curve.EaseIn, duration: 400
      });
      animateTo({
        duration: 300,
        curve: Curve.EaseOut,
        iterations: 1,
        playMode: PlayMode.Normal
      }, () => {
        this.isShowTitleBar = !this.isDownScrolling;
      })
    }
  }

  onTabIndexChange(): void {
    if (this.enterTabIndex === this.currentTabIndex) {
      this.addEventListener();
      this.menuActionHandler?.againRegisterMenuEvent();
    }
  }

  async onPageShow() {
    this.onShortcutMonitoring()
    HiLog.info(TAG, 'MyPhone onPageShow');
    // 后续可以修改为监听应用安装卸载事件，减少后台切前台的冗余逻辑
    if (!this.isFirstLoad) {
      BundleResourceUtil.createDownloadUriShowMap();
    }
    this.isAnimationShow = this.navMode === NavigationMode.Split;
    this.isPageShow = true;
    GlobalHolder.getInstance().setObject<boolean>(GlobalKey.MY_PHONE_IS_SHOW, true);
    this.getPhotosPage();
    // 文件选择器并且是多选模式下详情返回不更新，避免原有多选被重置
    if (this.filePickerViewFlag && this.userState !== UserState.BROWSER) {
      this.isFirstLoad = false;
      return;
    }
    const oldOrder = this.order;
    this.getFileUsageHabits();
    // 从子目录返回后需要判断排序规则是否发生变化需要重新排序
    if (this.order !== oldOrder) {
      const fileList = SortUtil.sortDataByOrder(this.fileSource.getDataArray(), this.order, this.isDesc);
      this.fileSource.setData(fileList);
    }
    if (!this.isPullEnd) {
      return;
    }
    const isLanguageChange: boolean = AppStorage?.get<string>('systemLanguage') !== this.currentLanguage;
    this.currentLanguage = isLanguageChange ? AppStorage?.get<string>('systemLanguage') ?? '' : this.currentLanguage;
    if ((!this.isFirstLoad) && (this.userState === UserState.BROWSER) && !this.backFromPreview) {
      this.refreshData();
    }
    this.backFromPreview = false;
    this.isFirstLoad = false;
  }

  build() {
    NavDestination() {
      this.buildStatusBar();
      Stack() {
        if (this.isSecondFrame) {
          this.myPhoneMainContent()
        }
        if (this.showMaskLayer && !this.filePickerViewFlag && !this.isOpenMedia) {
          this.pickerMaskLayer()
        }
        this.buildBlackMask();
      }
      .layoutWeight(1)
    }
    .opacity(this.animationController.pageOpacity)
    .onBackPressed(() => {
      return this.onBackPress();
    })
    .backgroundColor(this.filePickerViewFlag ? $r('sys.color.ohos_id_color_panel_bg') :
      $r('sys.color.ohos_id_color_sub_background'))
    .hideTitleBar(true)
    .onShown(() => this.onPageShow())
    .onActive(() => {
      HiLog.info(TAG, 'MyPhone onActive');
      this.isActive = true;
      if (this.isShowMaskWhenPageShow) {
        this.showMaskLayer = true;
        this.showPickerMaskLayer = true;
        this.isShowMaskWhenPageShow = false;
      }
    })
    .onInactive(() => {
      HiLog.info(TAG, 'MyPhone onInactive');
      this.isActive = false;
    })
    .onHidden(() => this.onPageHide())
    .width('100%')
    .height('100%')
    .id(CompId.MYPHONE_PAGE)
    .translate({ x: this.animationController.translateX })
    .zIndex(this.animationController.zIndexNumber)
    .onTouch(() => {
      this.needHighlight && this.disableHighlight();
    })
    .onReady((context: NavDestinationContext) => {
      if (!context.navDestinationId) {
        HiLog.error(TAG, 'context.navDestinationId is undefined!');
        return;
      }
      this.navDestinationId = context.navDestinationId;
      // Register a custom transition animation object
      CustomTransition.getInstance()
        .registerNavParam(this.navDestinationId, CustomTransition.REGISTER_TIME_OUT,
          StandardAnimation.TransitionAnimationType.FOLDER_OPEN_AND_EXIT,
          (transitionProxy: NavigationTransitionProxy, naviOperation: NavigationOperation) => {
            this.animationController.executeFolderAnimation(this.folderOperateType, this.isReplaced, transitionProxy);
          });
    })
    .onDisAppear(() => {
      CustomTransition.getInstance().unRegisterNavParam(this.navDestinationId);
    })
    .bindSheet($$this.isShowSuffixFilter, this.suffixFilter(), {
      height: SheetSize.FIT_CONTENT,
      dragBar: false,
      showClose: false,
      preferType: SheetType.CENTER,
      onAppear: () => {
        HiLog.info(TAG, 'SuffixFilter onAppear');
      },
      shouldDismiss: (sheetDismiss: SheetDismiss) => {
        sheetDismiss.dismiss();
      },
      onTypeDidChange: (sheetType: SheetType) => {
        HiLog.info(TAG, `SuffixFilter onTypeDidChange:${sheetType}`);
        this.suffixSheetType = sheetType;
      }
    })
    .onDrop(() => {
      HiLog.info(TAG, 'onDrop')
    })
  }

  @Builder
  pickerMaskLayer() {
  }

  onPageHide() {
    this.offShortcutMonitoring()
    HiLog.info(TAG, 'MyPhone onPageHide');
    this.recordOffset();
    this.isFirstLoad = false;
    this.isPageShow = false;
    this.isShowLocateAni = false;
    this.isAnimationShow = false;
    GlobalHolder.getInstance().setObject<boolean>(GlobalKey.MY_PHONE_IS_SHOW, false);
    this.needHighlight && this.disableHighlight();
  }

  onBackPress(): boolean {
    HiLog.info(TAG, 'onBackPress in');
    this.isLoading = false;
    this.getPhotosPage();
    if (this.showMaskLayer && !this.filePickerViewFlag && !this.isOpenMedia) {
      this.showMaskLayer = false;
      this.onBackPassForPhotosLock();
      return true;
    }

    if (this.isPersistPermission) {
      this.onPickerCancelClick();
      return true;
    }

    // picker一直处于编辑模式,阻塞对其无效
    if ((this.isPreventBack && !this.startModeOptions.isUxt()) && !this.isEdit) {
      HiLog.info(TAG, 'onBackPress isPreventBack');
      EventBus.emit(Constant.EVENTS.BACK_PRESS, true);
      return true;
    }

    if (this.userState !== UserState.BROWSER && !this.filePickerViewFlag) {
      this.resetUserState();
      // 退出多选态不需要播报标题变化，并重新聚焦播报
      AccessibilityManager.getInstance().notAnnouncedTitleAndFocusComponent(CompId.LEFT_ICON);
      return true;
    }

    const dirLen = this.direList.length;
    // 从下载与接收路径返回
    if ((this.virtualRootUri === VirtualUri.DOWNLOAD ||
      this.virtualRootUri === VirtualUri.SHARE ||
      this.virtualRootUri === VirtualUri.BLUETOOTH) && dirLen === 1) {
      this.originalTitle = $r('app.string.download_receive');
      this.virtualRootUri = VirtualUri.DOWNLOAD_RECEIVE;
    }

    // 如果是从主界面的收藏跳进来的，返回到主界面
    if (this.sourceFlag === PAGE_ROUTE_CONST.MAIN_ENTRY) {
      this.isClosePage = true;
      this.pageInfos.clear();
      return true;
    }

    this.isAnimationShow = dirLen > 0;
    if (dirLen) {
      const nowBreadData: AddressData = this.direList[dirLen - 1];
      if ((this.finishType === PageFinishType.DESTROY_PAGE) && (!StringUtil.isEmpty(this.targetPath))) {
        if ((this.targetPath === nowBreadData.uri) || (this.targetPath === FileUtil.getPathFromUri(nowBreadData.uri))) {
          this.backDestroyPage();
          return true;
        }
      }
      if (this.currentFolderUri.startsWith(Constant.MediaLibrary_URI_HEAD)) {
        this.originalTitle =
          (this.pageParams as AbilityOrRouterParams)?.title ?? DeviceConfig.getInstance().config.myDevice;
      }
      if (this.isArchiveOrInArchive()) {
        this.direList.splice(-1, 1);
      } else {
        this.exitFolderByNewPage();
      }
      return true;
    }
    if (this.navMode !== NavigationMode.Split) {
      this.backDestroyPage();
      return true;
    }
    return false;
  }

  aboutToDisappear() {
    HiLog.info(TAG, 'MyPhone aboutToDisappear');
    this.isFirstLoad = false;
    this.isShowLocateAni = false;
    if (this.navMode === NavigationMode.Split) {
      this.showEntryBottomBarFlag = true;
    }

    if (this.queryTask) {
      this.queryTask.cancelTask();
      this.concatData = [];
    }
    this.removeEventListener();
    if (this.navMode === NavigationMode.Stack) {
      this.currentNavItem = '';
    }
    if (this.menuActionHandler) {
      this.menuActionHandler.unregisterMenuEvent();
    }
    this.displaySync?.stop();
    // 关闭监听
    // this.offShortcutMonitoring()
    this.cancelCurrentSearch();
    this.clearSearch();
  }

  private getGoToCurrentUriAndSetItBlank(): string {
    const res = this.goToCurrentUri;
    if (!StringUtil.isEmpty(res)) {
      this.goToCurrentUri = '';
    }
    return res;
  }

  @Builder
  myPhoneMainContent() {
    Column() {
      // 头部导航
      if (this.isSearching) {
        // Column() {
        Row() {
          this.searchBarView()
        }
        .padding({ left: 16, right: 16 })
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .transition(
          TransitionEffect.asymmetric(
            TransitionEffect.OPACITY.animation({ duration: 250, delay: 50, curve: Curve.Sharp }),
            TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.Sharp })
          )
        )
      } else {
        TitleBarComp({
          title: this.isArchiveOrInArchive() ? this.direList[this.direList.length - 1].name :
            UiUtil.getTitleBarCompTitle(this.originalTitle, this.userState, this.checkedNum, this.operationType,
              this.filePickerViewFlag),
          subTitle: this.checkedSizeSubTitle,
          leftIcon: $leftIcon,
          iconArr: this.rightIcons,
          initMenu: () => this.initMenu(),
          topMenu: $topMenu,
          userState: this.userState,
          fileCount: this.getActualityFileCount(),
          startModeOptions: this.startModeOptions,
          folderOperateType: this.folderOperateType,
          animationController: this.animationController,
          isClosePage: this.isClosePage
        })
          .transition(this.titleBarTransitionEffect)
          .visibility(this.isShowTitleBar ? Visibility.Visible : Visibility.None)
          .opacity(this.animationController.titleOpacity)
      }

      if (this.rootUri !== VirtualUri.GALLERY) {
        // 面包屑
        BreadCrumb({
          direList: $direList,
          originalTitle: this.getTitle(this.originalTitle),
          fromPage: DFX.PageName.MY_PHONE,
          needScrollEnd: this.breadScrollEnd,
          resetPageParam: () => {
            this.pageFrom = '';
          }
        })
          .visibility(this.isOutsideFolded ? Visibility.None : Visibility.Visible)
      }
      Stack({ alignContent: Alignment.Bottom }) {
        if (this.isOutsideFolded) {
          // 文件列表
          OutsideScreenFileListView({
            layout: this.fileListViewLayout,
            startModeOptions: this.startModeOptions,
            fileListSource: this.fileSource,
            checkedNum: $checkedNum,
            allCheckedNum: this.allCheckedNum,
            userState: $userState,
            isSelectAll: this.isSelectAll,
            listYOffset: $listYOffset,
            scrollStartIndex: this.scrollStartIndex,
            direList: $direList,
            listScrollShow: $listScrollShow,
            isQueryEnd: this.isQueryEnd,
            hasTotalCapacity: this.isShowUsedSpace(),
            onItemClick: (fileItem: FileInfo) => this.onItemClick(fileItem),
            onDropCallback: async (event: DragEvent, targetFolderUri: string, targetFolderName: string,
              extraParams?: string): Promise<void> =>
            this.onDropCallback(event, targetFolderUri, targetFolderName, extraParams),
            curFolderUri: this.currentFolderUri,
            longPressHoldToPaste: () => this.holdToPaste(),
            enableDrag: DragManager.getInstance().supportDrag(this.startModeOptions),
            toOperateFileList: this.selectFilesList,
            swipeDeleteDialogCallback: (event: BottomCallParams): void => this.dialogCallback(event),
            disableSwipe: this.shouldDisableSwipe(),
            pageName: PAGE_ROUTE_CONST.MY_PHONE,
            needHighlight: this.needHighlight,
            pickerCheckArr: this.pickerCheckArr,
            topMenu: this.topMenu,
            showHiddenItem: this.showHiddenItem,
            isSuffixFilter: this.isFilter,
            onFilter: () => this.openSuffixDialog(),
            isShowCheckBox: true && !this.isExternalStorageDevice(),
            isShowLoading: this.isShowLoading,
            currentTypeCountCallBack: (count: number) => this.curTypeSourcefileCount = count,
            rootYOffset: this.rootYOffset,
            isShowLocateAni: this.isShowLocateAni,
            isQueryTotalEndOrCurrentFileFound: () => {
              return this.isQueryStateEnd || this.isCurrentFileFound;
            },
            goToCurrentUri: this.getGoToCurrentUriAndSetItBlank()
          })
            .padding(
              this.filePickerViewFlag && this.userState === UserState.BROWSER ?
                { bottom: $r('app.float.common_size24') } : {})
        } else {
          // 文件列表
          FileListView({
            layout: this.fileListViewLayout,
            startModeOptions: this.startModeOptions,
            fileListSource: this.fileSource,
            checkedNum: $checkedNum,
            allCheckedNum: this.allCheckedNum,
            userState: $userState,
            isSelectAll: this.isSelectAll,
            listYOffset: $listYOffset,
            scrollStartIndex: this.scrollStartIndex,
            direList: $direList,
            listScrollShow: $listScrollShow,
            isQueryEnd: this.isQueryEnd,
            hasTotalCapacity: this.isShowUsedSpace(),
            onItemClick: (fileItem: FileInfo) => this.onItemClick(fileItem),
            onDropCallback: async (event: DragEvent, targetFolderUri: string, targetFolderName: string,
              extraParams?: string): Promise<void> =>
            this.onDropCallback(event, targetFolderUri, targetFolderName, extraParams),
            onDragJumpCallback: async (event: DragEvent, extraParams?: string): Promise<void> =>
            CopyCutManager.getInstance().onDragJumpCallback(event, extraParams),
            curFolderUri: this.currentFolderUri,
            longPressHoldToPaste: () => this.holdToPaste(),
            enableDrag: DragManager.getInstance().supportDrag(this.startModeOptions),
            toOperateFileList: this.selectFilesList,
            swipeDeleteDialogCallback: (event: BottomCallParams): void => this.dialogCallback(event),
            disableSwipe: this.shouldDisableSwipe(),
            pageName: this.pageFrom || PAGE_ROUTE_CONST.MY_PHONE,
            needHighlight: this.needHighlight,
            pickerCheckArr: this.pickerCheckArr,
            topMenu: this.topMenu,
            showHiddenItem: this.showHiddenItem,
            isSuffixFilter: this.isFilter,
            onFilter: () => this.openSuffixDialog(),
            isShowCheckBox: true && !this.isExternalStorageDevice(),
            isShowLoading: this.isShowLoading,
            currentTypeCountCallBack: (count: number) => this.curTypeSourcefileCount = count,
            rootYOffset: this.rootYOffset,
            rootYOffsetIndex: this.rootYOffsetIndex,
            persistentViewModeHabit: (viewMode: string) => this.persistentViewModeHabit(viewMode),
            isShowLocateAni: this.isShowLocateAni,
            isQueryTotalEndOrCurrentFileFound: () => {
              return this.isQueryStateEnd || this.isCurrentFileFound;
            },
            goToCurrentUri: this.getGoToCurrentUriAndSetItBlank()
          })
            .padding(
              this.filePickerViewFlag && this.userState === UserState.BROWSER ?
                { bottom: $r('app.float.common_size24') } : {})
        }

        Loading({
          isLoading: true,
          showOffset: { x: 0, y: -Constant.TOP_BAR_AVOID_AREA_HEIGHT },
          bgColor: this.startModeOptions.pickerFlag ?
            $r('sys.color.ohos_id_color_panel_bg') : $r('sys.color.ohos_id_color_sub_background')
        })
          .margin({ top: $r('app.float.common_size56') })
          .padding({ bottom: this.bottomNavBarHeight })
          .visibility(this.isShowLoading ? Visibility.Visible : Visibility.None)
          .size({ width: '100%', height: `calc(100% - ${Constant.TOP_BAR_AVOID_AREA_HEIGHT}vp)` })

        // selectItem BottomBar点击事件
        if (!this.filePickerViewFlag) {
          BottomBar({
            bottomOptions: $bottomOption,
            selectItem: $selectItem,
            checkedNum: this.checkedNum,
            selectFilesList: $selectFilesList,
            isShowCheckBox: true && !this.isExternalStorageDevice(),
            dialogCallback: (event: BottomCallParams): void => this.dialogCallback(event),
            isMyPhonePage: true,
            fromPage: Constant.FROM_TYPE.MY_PHONE,
            longPressChangeType: this.longPressChangeType,
            fileInfo: this.fileInfo,
            isExternalStorageDeviceFile: this.isExternalStorageDevice(),
            checkCanClick: (): boolean => this.checkCopyCutTaskCallback(),
            writePasteBoard: (list: FileInfo[]): Promise<void> => this.writePasteBoardCallback(list),
            fileOperationCallBack: this.fileOperation,
            pullUpPickerCallBack: (): void => this.pullUpPicker(),
            isFromSource: false,
            isFromExternal: ExternalStorageUtil.isExternalStorageUri(this.currentFolderUri),
            wallpaperPreviewPopCallBack: (popInfo: PopInfo): void => this.previewPagePopCallBack(popInfo),
            pageName: this.pageFrom || PAGE_ROUTE_CONST.MY_PHONE,
            isShowBottomBar: this.userState !== UserState.BROWSER
          })
        }
      }.layoutWeight(1)

      if (this.filePickerViewFlag) {
        Column() {
          UiPickerButtonTips({
            isShowAll: true,
            checkedNum: this.pickerCheckArr.length,
            terminate: () => {
              this.onPickerOkIconClick()
            },
          })
        }
        .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
        .padding({ bottom: this.isOutsideFolded ? 0 : $r('app.float.common_padding28') })
      }

      if (this.isSearching) {
        Blank()
          .width('100%')
          .height('100%')
          .backgroundColor(Color.Black)
          .opacity(0.5)
          .onClick(() => {
            this.isSearching = false
          })
          .zIndex(10) // 确保遮罩层在合适层级
      }
    }
    .opacity(this.curPageOpacity)
  }

  // 状态栏
  @Builder
  buildStatusBar() {
    Column() {
    }
    .width('100%')
    .height(this.isOutsideFolded ? 0 : this.statusBarHeight)
    .bindMaskStyles()
  }

  // 蒙黑层
  @Builder
  buildBlackMask() {
    if (this.animationController.isAnimationRunning) {
      Column() {
      }
      .width('100%')
      .height('100%')
      .enabled(false)
      .focusable(false)
      .bindMaskStyles()
    }
  }

  // 蒙黑层透明度
  @Styles
  bindMaskStyles() {
    .backgroundColor($r('sys.color.black'))
    .opacity(this.animationController.maskOpacity)
  }

  // 判断当前是否是TF卡页面
  getIsTfCardPage(): boolean {
    return false;
  }

  @Builder
  suffixFilter() {
    Column() {
      FileTypeFilterDialog({
        filePickerViewFlag: this.filePickerViewFlag,
        confirm: (isFilter: boolean, isBlackSuffix: boolean, suffixArr: string[]) => {
          HiLog.info(TAG, `confirm file suffix, isBlackSuffix:${isBlackSuffix}, suffixArr:${suffixArr}`);
          // 关闭弹窗
          this.isShowSuffixFilter = false;
          // 过滤按钮状态变更
          this.isFilter = isFilter;
          this.isBlackList = isBlackSuffix;
          this.suffixes = suffixArr;
        },
        close: () => {
          HiLog.info(TAG, 'close SuffixFilter');
          this.isShowSuffixFilter = false;
        }
      })
    }
    .width('100%')
  }

  public persistentViewModeHabit(viewMode: string): void {
    const pageName: string = this.getUsageHabitsPageName();
    const isPicker: boolean = this.startModeOptions.pickerFlag;
    UsageHabitsPreferenceUtil.updateUsageHabit(pageName, isPicker, UsageHabitsPreferenceConst.VIEW_MODE, viewMode);
  }

  /**
   * 获取文件后缀过滤参数
   */
  readSuffixParam(): void {
    HiLog.warn(TAG, 'readSuffixParam warn: suffixPreference is undefined.');
    return;
  }

  onVirtualRootUriChange() {
    HiLog.info(TAG, 'virtualRoot Uri change');
    this.initMenu();
    this.rightIcons = this.buildRightIcons();
    this.initTitle();
  }

  public previewPagePopCallBack(popInfo: PopInfo) {
    HiLog.info(TAG, `preview onPopped`);
    this.backFromPreview = true;
  }

  /**
   * 监听文件夹操作类型变更
   */
  private onFolderOperationChange(): void {
    if (this.folderOperateType !== FolderOperationType.NONE) {
      this.updateTitleBarTransitionEffect();
    }
  }

  // 退出文件夹并以新页面打开父级目录
  private exitFolderByNewPage(): void {
    HiLog.info(TAG, `exitFolderByNewPage`);
    if (this.pageFrom?.startsWith(FileUtil.URI_GALLERY)) {
      this.pageInfos.pop();
      return;
    }
    const rootBread = new AddressData(this.rootUri);
    rootBread.yOffset = this.rootYOffset;
    rootBread.startFileIndex = this.rootYOffsetIndex;
    const breadOffsetList: AddressData[] = [rootBread];
    this.direList.forEach((breadItem) => {
      const tmpBread = JSON.parse(JSON.stringify(breadItem)) as AddressData;
      breadOffsetList.push(tmpBread);
    })
    breadOffsetList.splice(-1, 1)
    this.folderOperateType = FolderOperationType.EXIT_FOLDER;
    this.isReplaced = true;
    this.animationController.zIndexNumber = 101;
    let params: AbilityOrRouterParams = this.getReplacePageParam(breadOffsetList);
    CustomTransition.getInstance().transitionAnimationType =
      StandardAnimation.TransitionAnimationType.FOLDER_OPEN_AND_EXIT;
    this.pageInfos.replacePath(new NavPathInfo(PAGE_ROUTE_CONST.MY_PHONE, params), true);
  }

  // 退出相册并以新页面打开父级目录
  private exitAlbumByNewPage(): void {
    // 根目录滚动位置
    const rootBread = new AddressData(this.rootUri);
    HiLog.info(TAG, `exitAlbumByNewPage`);
    rootBread.yOffset = this.rootYOffset;
    rootBread.startFileIndex = this.rootYOffsetIndex;
    const breadOffsetList: AddressData[] = [rootBread];
    this.folderOperateType = FolderOperationType.EXIT_FOLDER;
    this.isReplaced = true;
    this.animationController.zIndexNumber = 101;
    let params: AbilityOrRouterParams = this.getReplacePageParam(breadOffsetList);
    params.title = '';
    params.rootUri = '';
    params.uriPath = '';
    CustomTransition.getInstance().transitionAnimationType =
      StandardAnimation.TransitionAnimationType.FOLDER_OPEN_AND_EXIT;
    this.pageInfos.replacePath(new NavPathInfo(PAGE_ROUTE_CONST.MY_PHONE, params), true);
  }

  // 是否展示picker的工具栏
  private isShowPickerBar(): boolean {
    return this.filePickerViewFlag && !FileUtil.isGalleryAddress(this.currentFolderUri);
  }

  private getActualityFileCount(): number {
    if (this.isQueryEnd === false) {
      return this.oldTotal;
    }
    let total = this.fileSource.totalCount();
    if (this.filePickerViewFlag) {
      this.oldTotal = total;
      return total;
    }

    // 剔除双生单的Sounds目录里面的录音机虚拟目录所占用的文件数量
    if (this.rootUri.startsWith(FileUtil.URI_INTERNAL) &&
      this.direList.length === 1 && Constant.FOLDER_SOUNDS === this.direList[0].name) {
      total--;
    }
    this.oldTotal = total;
    return total;
  }

  private resetUserState(): void {
    if (this.userState === UserState.SELECT_PATH) {
      EventBus.emit(Constant.EVENTS.CLOSE_PATH_PICKER);
    } else {
      this.initData();
    }
  }

  private resetBackPressPage(): void {
    this.originalTitle = (this.pageParams as AbilityOrRouterParams)?.title;
    this.currentVirtualFolderUri = '';
    this.currentFolderUri = '';
    this.getListFile(new AddressData(''), false);
    this.direList.splice(-1, 1); // 改变面包屑，触发FileListView里面的监听进而调用jumpToFocusFile
  }

  private fileOperation = (message: ResourceStr) => {
    return false;
  }

  private shouldDisableSwipe() {
    // 禁用列表左右滑动删除文件
    return this.filePickerViewFlag || this.virtualRootUri === VirtualUri.DOWNLOAD_RECEIVE;
  }

  private getParams(): AbilityOrRouterParams {
    const params = this.pageParams as AbilityOrRouterParams;
    HiLog.infoPrivate(TAG, `getParams params from: ${params.from},` +
      `bundleName: ${params.bundleName}, `, `params uri: ${params.uriPath}`);
    if (ObjectUtil.isNullOrUndefined(params)) {
      return params;
    }
    this.sourceFlag = params.from;
    this.finishType = params.finishType;
    this.pageFrom = params.pageFrom;
    if (this.isPersistPermission) {
      this.originalTitle = $r('app.string.persist_permission_import');
    } else {
      this.originalTitle = params.title || DeviceConfig.getInstance().config.myDevice;
      if (typeof this.originalTitle === 'string') {
        this.originalTitle = PhotoAccessUtil.getSysResourceParentAlbumName(this.originalTitle);
      }
    }
    this.targetPath = params.path;
    this.uriPath = params.uriPath ?? '';
    this.folderOperateType = params.folderOperateType;
    // 退出相册不使用面包屑跳转
    this.needJumpByBread = params?.direList && params?.direList.length > 0;
    if (params.startModeOptions) {
      this.startModeOptions = params.startModeOptions;
      this.filePickerViewFlag = this.startModeOptions.isUxt();
    }
    if (params.from === Constant.FROM_TYPE.COPY_CUT_NOTIFICATION) {
      this.isNeedRefreshDeviceItem = true;
    }
    // 支持uri跳转
    if (ObjectUtil.isNullOrUndefined(this.targetPath) && !ObjectUtil.isNullOrUndefined(params.uriPath)) {
      this.targetPath = FileOperation.getTargetUri(params.uriPath);
    }
    const isLocalFolderEmpty = StringUtil.isEmpty(this.currLocalFolder);
    const isSplitMode = this.navMode === NavigationMode.Split;
    const isUriInArchive = this.targetPath ? FileUtil.isArchiveByUri(this.targetPath) : false;
    if (!isLocalFolderEmpty && isSplitMode && !isUriInArchive) {
      this.targetPath = this.currLocalFolder;
    }
    this.rootUri = params.rootUri || GlobalHolder.getInstance()
      .getObject<string>(GlobalKey.LOCAL_ROOT_URI) || FileUtil.URI_INTERNAL;
    this.currentFolderUri = this.rootUri;
    this.curFolderName = this.getSelectName();
    this.rootRelativePath = StorageDeviceManager.getInstance().getRelativePathByUri(this.rootUri);
    this.uuid = params.uuid || '';
    this.getIsTfCardPage();
    return params;
  }

  private getUsageHabitsPageName(): string {
    if (this.isExternalStorageDevice()) {
      return UsageHabitsPreferenceConst.EXTERNAL_STORAGE;
    }
    return UsageHabitsPreferenceConst.MY_PHONE;
  }

  private getFileUsageHabits() {
    const usageHabits: UsageHabits = UsageHabitsPreferenceUtil.getUsageHabitsByPageName(
      this.getUsageHabitsPageName(), this.startModeOptions.pickerFlag);
    this.viewMode = usageHabits.viewMode;
    // 外屏不需要读取展示格式的持久化数据
    if (!this.isOutsideFolded) {
      this.isListView = this.viewMode === ViewMode.LIST;
    }
    this.order = usageHabits.orderType;
    this.isDesc = usageHabits.isDesc;
  }

  private initTitle(first: boolean = false): void {
    if (!this.leftIcon) {
      this.leftIcon = new TitleMenuItem(MENU_ICONS.back, MENU_NAME.back, () => this.onBackPress());
    } else {
      this.leftIcon.icon = MENU_ICONS.back;
      this.leftIcon.name = MENU_NAME.back;
      this.leftIcon.action = () => this.onBackPress();
    }
    this.leftIcon.isShown =
      this.navMode !== NavigationMode.Split || this.direList.length > 0 || (first && !this.isRootFolder());
    this.leftIcon.dragEnable = true;
    if (this.isPersistPermission) {
      this.leftIcon.isShown = false;
    }
    this.rightIcons = this.buildRightIcons();
  }

  private buildRightIcons(): TitleMenuItem[] {
    let newRightIcons: TitleMenuItem[] = [];
    if (this.virtualRootUri !== VirtualUri.DOWNLOAD_RECEIVE &&
      this.currentFolderUri !== PAGE_ROUTE_CONST.IMAGE &&
      this.currentFolderUri !== PAGE_ROUTE_CONST.VIDEO &&
      this.filePickerViewFlag === false) {
      newRightIcons.push(this.buildMultipleChoiceButton())
    }
    // 添加搜索按钮
    if (this.userState === UserState.BROWSER) { // 只在浏览模式下显示搜索按钮
      newRightIcons.push(this.buildSearchButton());
    }
    if (this.isPersistPermission) {
      newRightIcons.push(this.buildMultipleChoiceButton());
      this.userState = UserState.MULTI_START;
    }

    const isDownloadRecvView = this.virtualRootUri === VirtualUri.DOWNLOAD_RECEIVE;

    if (this.filePickerViewFlag) {
      const cancelButton =
        new TitleMenuItem(MENU_ICONS.cancel, MENU_NAME.close, () => this.onPickerCancelClick(),
          true, false, true, false);
      newRightIcons.push(cancelButton);
    }
    return newRightIcons;
  }

  private buildMultipleChoiceButton(): TitleMenuItem {
    // 未进入多选 显示多选按钮
    if (this.userState !== UserState.MULTI_START) {
      return new TitleMenuItem($r('app.string.multiple_choices'), MENU_NAME.multipleChoice, () => {
        AppStorage.setOrCreate<number>(AccessibilityStorageKey.MULTIPLE_CHOICE_KEY, 1);
        this.multipleChoiceCallBack();
        AccessibilityManager.getInstance().sendCustomIdFocusForAccessibility(CompId.TOP_TITLE);
      }, this.getActualityFileCount() !== 0, false, true, false, true);
    }
    // 已在多选时 判断全选状态
    if (this.isSelectAll) {
      // 取消全选
      return new TitleMenuItem($r('app.string.cancel_all_selection'), MENU_NAME.cancelSelectAll, () => {
        this.onSelectAllIconClick(false);
        AccessibilityManager.getInstance()
          .announcedStringAndFocusComponent(ResourceUtil.getStringByResource($r('app.string.already_deselect_all')),
            CompId.TOP_BUTTON);
        UEUtil.reportSelectOrDeselectAll(this.getUEPageName(), DFX.SelectAllType.DESELECT_ALL);
      }, true, false, true, false, true);
    } else {
      // 全选
      /* 判断按钮是否可以点击
         如果是filepicker增量授权：
           正在加载：false
           加载结束：有文件：true
                   没有：false
         如果不是filepicker增量授权： true
      * */
      return new TitleMenuItem($r('app.string.select_all'), MENU_NAME.selectAll, () => {
        this.onSelectAllIconClick(true);
        AccessibilityManager.getInstance()
          .announcedStringAndFocusComponent(ResourceUtil.getStringByResource($r('app.string.already_select_all')),
            CompId.TOP_BUTTON);
        UEUtil.reportSelectOrDeselectAll(this.getUEPageName(), DFX.SelectAllType.SELECT_ALL);
      }, this.isPersistPermission ? (this.isLoading ? false : this.fileSource.totalCount() > 0) : true, false, true,
        false, true);
    }
  }

  private buildSearchButton(): TitleMenuItem {
    return new TitleMenuItem(MENU_ICONS.search, MENU_ICONS.search, () => {
      this.onSearchClick();
    }, true, false, true, false, false);
  }

  private onSearchClick(): void {
    HiLog.info(TAG, 'Search button clicked');
    // 打开搜索时清空搜索结果，但保留搜索框关键词
    this.searchResults = [];
    // 显示搜索框
    this.isSearching = true;
  }

  @Builder
  searchBarView(): void {
    Search({ value: this.changeValue, placeholder: $r('app.string.search'), controller: this.controller })
      .placeholderColor($r('sys.color.font_secondary'))
      .placeholderFont({
        size: ($r('sys.float.Body_L')),
        weight: FontWeight.Regular
      })
      .fontColor($r('sys.color.font_primary'))
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .defaultFocus(true)
      .onChange((value: string) => {
        this.handleSearchInput(value)
      })
      .onSubmit((value) => {
        // 点击键盘搜索按钮时立即搜索
        this.performSearch(value);
        this.isSearching = false;
      })
      .enabled(true)
  }

  /**
   * 处理搜索输入
   * @param value
   */
  private handleSearchInput(value: string): void {
    this.changeValue = value
    // 清除之前的定时器
    if (this.timeout !== null) {
      clearTimeout(this.timeout);
      this.timeout = null;
    }

    // 当输入空白时，恢复显示原始全量数据
    if (!value.trim()) {
      // 恢复原始文件列表
      if (this.originalFileList.length > 0) {
        const newFileList = SortUtil.sortDataByOrder(this.originalFileList, this.order, this.isDesc);
        this.fileSource.setData(newFileList);
        this.searchResults = [];
      }
      return;
    }

    // 只更新搜索框的值，不自动执行搜索
    // 搜索逻辑只在onSubmit方法中执行
  }

  // 清空搜索
  private clearSearch(): void {
    // 保留搜索关键词，只清空搜索结果和搜索状态
    this.searchResults = [];
    this.isSearching = false;
    // 取消正在进行的搜索任务
    if (this.queryTask) {
      try {
        this.queryTask.cancelTask();
        HiLog.debug(TAG, '已取消搜索任务');
      } catch (error) {
        HiLog.error(TAG, `取消任务失败: ${error}`);
      }
      this.queryTask = undefined
    }
    // 清空定时器
    if (this.timeout) {
      clearTimeout(this.timeout);
      this.timeout = null;
    }
  }

  private async performSearch(keyword: string): Promise<void> {
    if (!keyword.trim()) {
      return;
    }
    //获取当前目录的uri
    const currentUri: string = this.getCurrentDirUri();
    HiLog.info(TAG, `开始搜索: "${keyword}", 目录: ${currentUri}`);
    this.isSearching = true;

    try {
      // 检查是否在图库子目录下，如果是且数据已加载，直接对当前数据进行过滤
      if (currentUri.startsWith(VirtualUri.GALLERY_URI) && this.fileSource.totalCount() > 0) {
        HiLog.info(TAG, `在图库子目录下，使用已有数据进行搜索，文件总数: ${this.fileSource.totalCount()}`);
        
        // 保存原始数据以便恢复
        if (this.originalFileList.length === 0) {
          this.originalFileList = [...this.fileSource.getDataArray()];
        }
        
        // 获取当前的过滤条件
        const queryParam: QueryFileParam = this.getSearchQueryParam(currentUri, keyword);
        let suffixSet: Set<string> = new Set<string>(queryParam.suffixList.map((suffix: string) => suffix.toLowerCase()));
        
        // 过滤符合条件的文件
        const filteredFiles = this.originalFileList.filter((file: FileInfo) => {
          // 检查文件名是否包含搜索关键词
          const nameMatch = file.fileName.toLowerCase().includes(keyword.toLowerCase());
          
          // 检查文件后缀是否符合过滤条件
          let suffixMatch = true;
          if (suffixSet.size > 0) {
            let fileSuffix: string = FileMimeTypeUtil.getFileSuffix(file.fileName).toLowerCase();
            suffixMatch = suffixSet.has(fileSuffix) !== queryParam.isBlackSuffix;
          }
          
          return nameMatch && suffixMatch;
        });
        
        HiLog.info(TAG, `搜索完成，找到匹配文件数: ${filteredFiles.length}`);
        
        // 更新搜索结果
        this.isSearching = false;
        this.searchResults = filteredFiles;
        this.updateFileSource(this.searchResults);
        return;
      }
      
      // 非图库子目录或数据未加载的情况，使用原有搜索逻辑
      const queryParam: QueryFileParam = this.getSearchQueryParam(currentUri, keyword);
      this.queryTask = new QueryLocalFileTask(
        this.queryLocalFileCallbackBind,
        queryParam,
        this.filePickerViewFlag
      );
      // 使用TaskManager执行这个查询任务
      TaskManager.getInstance().executeTask<void>(this.queryTask);

    } catch (error) {
      const err = error as BusinessError;
      HiLog.error(TAG, `搜索执行失败: code=${err.code}, message=${err.message}`);
      this.isSearching = false;
    }
  }

  /**
   * 处理搜索结果
   * @param result
   * @param status
   * @param queryId
   */
  private handleSearchData(result: FileInfo[], status: TaskStatus, queryId: number): void {
    HiLog.info(TAG, `处理搜索数据: status=${status}, 数量=${result.length}`);

    // 保留原有的预处理逻辑（文件名转换等）
    result.forEach(item => {
      if (item.uri.startsWith(VirtualUri.EXTERNAL_DISK)) {
        item.rootName = this.isTfCardPage ? ResourceUtil.getStringByResource($r('app.string.externalDisk')) :
          item.rootName;
      }
      if (ExternalStorageUtil.getParentUri(item.uri) === Constant.MY_PHONE_URI) {
        item.fileName = UiUtil.translateFileNameByUri(item.uri, item.fileName, item.isFolder);
      }
    });

    // 文件类型过滤
    let tmpArr = PhoneFilePickerUtil.filterListByFileType(result, this.startModeOptions);

    // 根据状态处理（保持原有逻辑结构）
    switch (status) {
      case TaskStatus.RUNNING:
        // 搜索时也累积数据
        this.searchConcatData = this.searchConcatData.concat(tmpArr);
        // 可选：实时显示部分结果
        this.processPartialSearchResults(tmpArr);
        return;

      case TaskStatus.END:
        // 处理最终搜索结果
        this.processFinalSearchResults(tmpArr);
        return;

      default:
        this.searchConcatData = [];
    }
  }

  // 处理部分搜索结果（RUNNING状态）
  private processPartialSearchResults(data: FileInfo[]): void {
    // 后台线程过滤
    const filtered = this.filterFilesByKeyword(data, this.changeValue);

    if (filtered.length === 0) {
      return;
    }

    // 切换到UI线程更新
    runOnUIThread(() => {
      // 增量添加，不覆盖
      this.searchResults = [...this.searchResults, ...filtered];
      this.updateFileSource(this.searchResults);

      HiLog.debug(TAG, `实时更新搜索结果: +${filtered.length}，总计${this.searchResults.length}`);
    });
  }

  // 处理最终搜索结果（END状态）
  private processFinalSearchResults(data: FileInfo[]): void {
    // 合并所有累积的数据
    const allData = this.searchConcatData.concat(data);

    // 最终过滤
    const filteredResults = this.filterFilesByKeyword(allData, this.changeValue);

    // 切换到UI线程
    runOnUIThread(() => {
      try {
        // 保存原始数据（用于清空搜索时恢复）
        this.originalFileList = [...allData];

        // 更新搜索结果
        this.searchResults = filteredResults;

        this.updateFileSource(this.searchResults);

        // 更新状态
        this.isLoading = false;
        this.isPullEnd = true;

        HiLog.info(TAG, `搜索完成: ${filteredResults.length}个结果`);

        // 空结果处理
        if (filteredResults.length === 0 && this.changeValue) {
          HiLog.info(TAG, `未找到"${this.changeValue}"的相关文件`);
        }

        // 清理累积数据
        this.searchConcatData = [];
        this.searchQueryId = -1

      } catch (err) {
        HiLog.error(TAG, `处理搜索结果失败: ${err}`);
      }
    });
  }

  /**
   * 构造搜索参数
   * @param dirUri
   * @param keyword
   * @returns
   */
  private getSearchQueryParam(dirUri: string, keyword: string): QueryFileParam {
    HiLog.info(TAG, `构建搜索参数: dirUri=${dirUri}, keyword=${keyword}`);

    // 使用现有的getQueryParam方法
    const queryParam = this.getQueryParam(dirUri);
    queryParam.showHiddenItem = this.showHiddenItem;
    queryParam.isPersistPermission = this.isPersistPermission;
    queryParam.tokenID = this.tokenID;

    // 添加搜索特定参数
    queryParam.keyword = keyword; // 搜索关键词
    queryParam.recursive = false; // 递归搜索子目录

    this.searchQueryId = this.queryId

    HiLog.debug(TAG, `搜索参数构建完成:
      keyword=${queryParam.keyword}`);

    return queryParam;
  }

  /**
   * 过滤搜索结果
   * @param files
   * @param keyword
   * @returns
   */
  private filterFilesByKeyword(files: Array<FileInfo>, keyword: string): FileInfo[] {
    const lowerKeyword = keyword.toLowerCase().trim();
    if (!lowerKeyword) {
      return files.filter(file => !file.isFolder);
    }
    return files.filter(file => {
      const fileName = file.fileName || '';
      if (file.isFolder) {
        return fileName.toLowerCase().includes(lowerKeyword);
      } else {
        const lastDotIndex = fileName.lastIndexOf('.');
        if (lastDotIndex === -1) {
          return fileName.toLowerCase().includes(lowerKeyword);
        }
        const fileNameWithoutSuffix = fileName.substring(0, lastDotIndex);
        return fileNameWithoutSuffix.toLowerCase().includes(lowerKeyword);
      }
    });
  }

  /**
   * 取消搜索
   */
  private cancelCurrentSearch(): void {
    if (this.timeout !== null) {
      clearTimeout(this.timeout);
      this.timeout = null;
    }
    this.isSearching = false;
  }

  /**
   *更新fileSource数据源
   */
  private updateFileSource(files: FileInfo[]): void {
    // 直接替换整个数据源
    this.fileSource.setData(files);
    const newFileList = SortUtil.sortDataByOrder(this.fileSource.getDataArray(), this.order, this.isDesc);
    this.fileSource.setData(newFileList);
    HiLog.debug(TAG, `更新fileSource: ${this.fileSource.totalCount()}个文件`);
  }

  /**
   * 获取UE页面名称
   * @returns UE页面信息
   */
  private getUEPageName(): DFX.PageName {
    if (this.isExternalStorageDevice()) {
      return DFX.PageName.EXTERNAL;
    }
    return DFX.PageName.MY_PHONE;
  }

  private dealFromType(): void {
    const otherFrom: string = GlobalHolder.getInstance().getObject<string>(GlobalKey.FROM);
    if (StringUtil.isEmpty(otherFrom)) {
      return;
    }
    HiLog.info(TAG, 'dealFromType: ' + otherFrom);
    // 需要高亮定位的场景
    if (otherFrom === Constant.FROM_TYPE.THIRD_APP ||
      otherFrom === Constant.FROM_TYPE.MY_PHONE) {
      this.enableHighlight();
    }

    if (otherFrom === Constant.FROM_TYPE.COPY_CUT_NOTIFICATION) {
      CopyCutManager.getInstance().dealNotifyToPage();
      this.isNeedRefreshDeviceItem = true;
    }
    if (otherFrom !== Constant.FROM_TYPE.FROM_MEDIA_VIEW) {
      GlobalHolder.getInstance().deleteObject(GlobalKey.FROM);
    }
  }

  /**
   * 是否包含选项"全部"
   */
  private containsOptionAll(indexArr: number[]): boolean {
    return indexArr.length === 0 || indexArr.includes(0);
  }

  /**
   * 刷新根目录页面
   */
  private refreshRootListPage(isShowLoading: boolean = false, isDelete: boolean = false): void {
    HiLog.info(TAG, `refreshRootListPage in ${isShowLoading}`);
    this.currLocalFolder = rootFlag;
    this.resetQueryTask(isShowLoading);
    this.initMenu();
    this.rightIcons = this.buildRightIcons();
    const queryParam: QueryFileParam = new QueryFileParam();
    queryParam.currBreadFullPath = getCurrentFolderPathByBreadCrumb(this.direList, true);
    queryParam.isExternalStorageDevice = this.isExternalStorageDevice();
    queryParam.rootName = this.getTitle(this.originalTitle);
    queryParam.dirUri = this.rootUri;
    queryParam.isDesc = this.isDesc;
    queryParam.orderBy = this.order;
    this.queryId++;
    queryParam.queryId = this.queryId;
    queryParam.context = this.startModeOptions.context;
    const imageSizeMin = this.dataPreferences?.getSync('imageSizeFilter', IMAGE_SIZE_FILTER_DEFAULT) as number;
    queryParam.sizeMin = imageSizeMin === 0 ? 1 : imageSizeMin * IMAGE_SIZE_FILTER_TRANS;
    queryParam.isBlackSuffix = this.isBlackList;
    queryParam.suffixList = this.suffixes;
    if (queryParam.isExternalStorageDevice) {
      queryParam.storageDeviceUid = this.uuid;
    }
    queryParam.showHiddenItem = this.showHiddenItem;
    queryParam.isPersistPermission = this.isPersistPermission;
    queryParam.tokenID = this.tokenID;
    this.queryTask = new QueryLocalFileTask(this.queryLocalFileCallbackBind, queryParam, this.filePickerViewFlag);
    TaskManager.getInstance().executeTask<void>(this.queryTask);
  }

  private receiveFileData(result: FileInfo[], status: TaskStatus, queryId: number): void {
    HiLog.info(TAG, `getListLocalFiles queryFilesEnd status ${status}, length = ${result.length},` +
      ` queryId = ${queryId}, this.queryId = ${this.queryId}`);
    this.isQueryStateEnd = status === TaskStatus.END;
    if (queryId !== this.queryId) {
      HiLog.warn(TAG, `receiveFileData queryId !== this.queryId`)
      return;
    }
    // 先判断是否是搜索查询
    if (queryId === this.searchQueryId) {
      // 搜索查询
      this.handleSearchData(result, status, queryId);
      return;
    }

    this.isPullEnd = true;
    result.forEach(item => {
      if (item.uri.startsWith(VirtualUri.EXTERNAL_DISK)) {
        item.rootName = this.isTfCardPage ? ResourceUtil.getStringByResource($r('app.string.externalDisk')) :
          item.rootName;
      }
      // 我的手机目录下，进行文件名多语言转换
      if (ExternalStorageUtil.getParentUri(item.uri) === Constant.MY_PHONE_URI) {
        item.fileName = UiUtil.translateFileNameByUri(item.uri, item.fileName, item.isFolder);
      }
    })
    let tmpArr = PhoneFilePickerUtil.filterListByFileType(result, this.startModeOptions);
    if (this.currentFolderUri.startsWith(FileUtil.URI_GALLERY)) {
      if (status === TaskStatus.END) {
        this.isLoading = false;
        if (this.isPersistPermission) {
          // 加载结束后全选按钮变可用
          this.rightIcons[0] = new TitleMenuItem($r('app.string.select_all'), MENU_NAME.selectAll, () => {
            this.onSelectAllIconClick(true);
          }, this.fileSource.totalCount() > 0 || result.length > 0, false, true, false, true);
        }
      }
      this.receiveIncrementalData(tmpArr);
      return;
    }
    switch (status) {
      case TaskStatus.RUNNING:
        this.concatData = this.concatData.concat(tmpArr);
        return;
      case TaskStatus.END:
        this.queryTaskEndHandle(tmpArr);
        return;
      default:
        this.concatData = [];
    }
    return;
  }

  /**
   * 增量查询，查询到文件就显示
   * @param tmpArr 查询到的文件列表
   *
   */
  private receiveIncrementalData(tmpArr: FileInfo[]) {
    if (this.isQueryStateEnd) {
      HiLog.info(TAG, 'taskStatus is end.');
      this.setShowLoading(false);
      this.isCurrentFileFound = false;
    }
    if (this.incrementalQueryStart) {
      this.queryTaskEndHandle(tmpArr);
    } else {
      this.pushFileSource(tmpArr);
    }
    if (this.isPersistPermission && tmpArr.length > 0) {
      this.setShowLoading(false);
    }
    HiLog.info(TAG, 'receiveIncrementalData' + this.incrementalQueryStart);
    this.incrementalQueryStart = false;
  }

  private pushFileSource(tmpArr: FileInfo[]) {
    HiLog.warn(TAG, `pushFileSource isQueryStateEnd: ${this.isQueryStateEnd}
      temArr.length: ${tmpArr.length}`);
    if (tmpArr.length === 0 && !this.isQueryStateEnd) {
      return;
    }
    const currentUri: string = (this.pageParams as AbilityOrRouterParams)?.currentFileUri;
    tmpArr.forEach((item: FileInfo) => {
      const fileName = FileUtil.decodeURIComponent(item.fileName);
      item.fileName = BundleResourceUtil.downloadUriShowNameMap.get(fileName) ?? item.fileName;
      if (!StringUtil.isEmpty(currentUri) && currentUri === item.uri) {
        if (!this.isQueryStateEnd) {
          this.isCurrentFileFound = true;
        }
        this.setShowLoading(false);
        HiLog.info(TAG, 'current file found');
      }
    });
    if (this.isQueryStateEnd) {
      this.fileSource.dataReceStatus.status = DataStatus.END;
    }
    this.fileSource.pushDataArray(tmpArr);
  }

  private addVirtualFile(tmpArr: FileInfo[]) {
    if (this.filePickerViewFlag) {
      return;
    }
    const isPhone: boolean = DeviceConfig.getInstance().config.soundName === Constant.FOLDER_SOUNDS;
    // 非手机，录音机图标放在Music/SoundRecorder路径下
    // 手机，录音机Sounds路径下显示图标
    if ((!isPhone && this.currentFolderUri === Constant.PAD_SOUNDS_URI) ||
      (isPhone && this.rootUri.startsWith(FileUtil.URI_INTERNAL) &&
        this.direList.length == 1 && Constant.FOLDER_SOUNDS === this.direList[0].name)) {
      if (!CommonPreferenceUtil.getSoundsRecordMigrationStatus()) {
        HiLog.warn(TAG, 'unshift sound record item.');
        tmpArr.unshift(this.getSoundRecordFileInfo());
      }
    }
  }

  private queryTaskEndHandle(tmpArr: FileInfo[]) {
    HiLog.info(TAG, 'queryTaskEndHandle start');
    this.addVirtualFile(tmpArr);
    if (tmpArr && tmpArr.length > 0) {
      this.concatData = this.concatData.concat(tmpArr);
    }
    let fileList: FileInfo[] = [...this.concatData];
    this.concatData = [];
    const pickerTargetUriIsFile: boolean = this.pickerTargetUriIsFile();
    if (pickerTargetUriIsFile) {
      fileList = fileList.filter(item => item.isFolder || item.uri === this.startModeOptions.defaultFilePathUri);
    }
    if ((this.direList.length === 0) && (!StringUtil.isEmpty(this.rootUri))) {
      this.currentFolderUri = this.rootUri;
      this.curFolderName = this.getSelectName();
      HiLog.infoPrivate(TAG, 'firstUri', this.rootUri);
    }
    const isLanguageChange: boolean = AppStorage?.get<string>('systemLanguage') !== this.currentLanguage;
    const isDataChange =
      this.isNeedSort() ? true : FileCommonUtil.dirDataChange(fileList, this.fileSource.getDataArray());
    if (((this.startModeOptions.isPersistPermission || !isLanguageChange) && !isDataChange) ||
      (this.userState === UserState.MULTI_START && !this.filePickerViewFlag)) {
      if (!this.isPersistPermission) {
        this.listScrollShow = true;
        this.isQueryEnd = true;
        clearTimeout(this.timeoutId);
        this.setShowLoading(false);
      }
      return;
    }

    if (this.isNeedSort()) {
      HiLog.info(TAG, 'queryTaskEndHandle: sort before set data, len = ' + fileList.length);
      const newFileList = SortUtil.sortDataByOrder(fileList, this.order, this.isDesc);
      if (!this.isShowLocateAni) {
        this.fileSource.setData(newFileList);
      } else {
        this.getUIContext()?.animateTo({
          duration: 350,
          curve: Curve.Smooth,
          onFinish: () => {
            this.isShowLocateAni = false;
          }
        }, () => {
          this.fileSource.setData(newFileList);
        })
      }
    } else {
      HiLog.info(TAG, 'queryTaskEndHandle: do not sort before set data, len = ' + fileList.length);
      if (this.isQueryStateEnd) {
        this.fileSource.dataReceStatus.status = DataStatus.END;
      }
      if (!this.isShowLocateAni) {
        this.fileSource.setData(fileList);
      } else {
        this.getUIContext()?.animateTo({
          duration: 350, curve: Curve.Smooth,
          onFinish: () => {
            this.isShowLocateAni = false;
          }
        }, () => {
          this.fileSource.setData(fileList);
        })
      }
    }
    this.listScrollShow = true;
    this.isQueryEnd = true;
    clearTimeout(this.timeoutId);
    if (this.filePickerViewFlag) {
      this.filePickerViewFlagFileListAction(pickerTargetUriIsFile);
    }
    const currentUri: string = (this.pageParams as AbilityOrRouterParams)?.currentFileUri;
    if (StringUtil.isEmpty(currentUri)) {
      this.setShowLoading(false);
    } else {
      for (const item of tmpArr) {
        if (currentUri === item.uri) {
          if (!this.isQueryStateEnd) {
            this.isCurrentFileFound = true;
          }
          this.setShowLoading(false);
          break;
        }
      }
    }

    this.currentLanguage = AppStorage?.get<string>('systemLanguage') ?? '';
    HiLog.info(TAG, 'queryTaskEndHandle end');
  }

  /**
   * 是否需要排序
   * @returns
   */
  private isNeedSort(): boolean {
    // 排序操作
    // 查询结束后，需要应用侧排序的场景：
    // 非聚合视图：virtualRootUri不等于DOWNLOAD_RECEIVE
    const isGalleryAddress: boolean = FileUtil.isGalleryAddress(this.currentFolderUri);
    HiLog.infoPrivate(TAG, `isGalleryAddress: ${isGalleryAddress} virtualRootUri:`, `${this.virtualRootUri}`);

    return (this.virtualRootUri !== VirtualUri.DOWNLOAD_RECEIVE) || !this.isArchiveOrInArchive();
  }

  private filePickerViewFlagFileListAction(pickerTargetUriIsFile: boolean) {
    this.fileSource.getDataArray().forEach((item: FileInfo) => {
      if (this.pickerCheckArr.includes(item.uri)) {
        item.isChecked = true;
      }
    })
    this.multipleChoiceCallBack();
    const index = this.fileSource.getIndex(this.startModeOptions.defaultFilePathUri);
    if (this.firstTargetEnter && pickerTargetUriIsFile && index > -1) {
      const tempFile = this.fileSource.getData(index);
      this.selectFilesList = [tempFile];
      this.checkedNum = this.selectFilesList.length;
      tempFile.isChecked = true;
      this.pickerCheckArr = [this.startModeOptions.defaultFilePathUri];
    }
  }

  private async toTargetFolder(filePath: string, albumType?: PhotoAlbumType, albumSubType?: PhotoAlbumSubType,
    albumName?: string): Promise<void> {
    if (StringUtil.isEmpty(filePath)) {
      this.refreshRootListPage(true);
      return;
    }
    this.currLocalFolder = filePath;
    this.isQueryEnd = false;
    this.setShowLoading(true);
    this.isCancelTask();

    const tempDireList: AddressData[] = [];

    if (FileUtil.isGalleryAddress(filePath)) {
      HiLog.info(TAG, `toTargetFolder isGalleryAddress. album:${albumType}-${albumSubType}`);
      // 构建图库的面包屑，固定为 我的手机-图库-xxx
      const rootBreadData: AddressData = new AddressData(VirtualUri.GALLERY,
        ResourceUtil.getStringByResource($r('app.string.pc_gallery'), getContext(this)));
      tempDireList.push(rootBreadData);

      if (filePath.startsWith(FileUtil.URI_GALLERY)) {
        let breadData: AddressData = new AddressData(filePath, albumName ?? '');
        breadData.albumType = albumType;
        breadData.albumSubType = albumSubType;
        tempDireList.push(breadData);
      }

      this.originalTitle = getResourceString(DeviceConfig.getInstance().config.myDevice); // 图库跳转路径 title显示“我的手机”
    } else {
      HiLog.infoPrivate(TAG, `toTargetFolder filePath = `, filePath);
      if (FileUtil.isUriPath(filePath)) {
        filePath = FileUtil.getPathFromUri(filePath);
        const tempDir: string = GlobalHolder.getInstance().getCommonContext().tempDir;
        if (filePath.startsWith(tempDir) && FileUtil.isArchiveByUri(filePath)) {
          // 文官内嵌套压缩包选择文管打开预览,须转换filepath,否则匹配不到rootInfo
          const appBaseDir = FileUtil.getParentRelativePath(GlobalHolder.getInstance().getAppContext().filesDir);
          // /data/storage/el2/base 替换为/storage/Users/currentUser/appdata/el2/base/com.ohos.filemanager
          filePath = filePath.replace(appBaseDir, ShieldUri.FILE_MANAGER.replace(VirtualUri.URI_HEAD, ''));
        }
      }
      const rootInfo = await FileCommonUtil.getStorageDeviceInfoByFilePath(filePath);
      const isPathExist = await FileUtil.isExistByPathWithFs(filePath);
      const isSandBoxUri: boolean = FileUtil.isSandboxUri(filePath);
      HiLog.info(TAG, `toTargetFolder isPathExist = ${isPathExist}, isSandBoxUri = ${isSandBoxUri}`);

      if (!rootInfo || !isPathExist || (isSandBoxUri && !FileUtil.isArchiveByUri(filePath))) {
        this.startModeOptions.defaultFilePathUri = '';
        toast($r('app.string.open_failure_msg'));
        this.isClosePage = true;
        this.pageInfos.pop();
        return;
      }
      // 保存存储设备信息
      this.uuid = rootInfo.uuid || '';
      this.rootUri = rootInfo.uri;
      this.rootRelativePath = rootInfo.relativePath || '';
      this.originalTitle = getDiskDes(rootInfo) || '';
      // 沙箱内压缩文件隐藏沙箱路径(仅显示沙箱压缩文件路径)
      if (isSandBoxUri && FileUtil.isArchiveByUri(filePath)) {
        const archiveUri = FileUtil.getUriFromPath(filePath);
        const archiveName = filePath.substring(filePath.lastIndexOf('/') + 1);
        tempDireList.push(new AddressData(archiveUri, archiveName));
      } else {
        // 构造面包屑数据
        const tempTargetFolderPath = filePath.replace(rootInfo.relativePath || '', '');
        const folderNameList = tempTargetFolderPath.split('/');
        let tempFolderPath = FileUtil.getPathWithFileSplit(rootInfo.relativePath);
        for (const folderName of folderNameList) {
          if (!StringUtil.isEmpty(folderName)) {
            tempFolderPath += folderName;
            const tempBreadData: AddressData = new AddressData(FileUtil.getUriFromPath(tempFolderPath), folderName);
            tempFolderPath += '/';
            tempDireList.push(tempBreadData);
          }
        }
      }
    }
    if (this.isNeedRefreshDeviceItem) {
      this.isNeedRefreshDeviceItem = false;
      EventBus.emit(Constant.EVENTS.REFRESH_DEVICE_ITEM, this.uuid);
    }
    this.direList = tempDireList;
    this.listScrollShow = true;
    this.breadScrollEnd = true;
  }

  private addEventListener(): void {
    EventBus.on(Constant.EVENTS.EXIT_MULTI_STATE, this.initDataBind)
    EventBus.on(Constant.EVENTS.OPEN_TARGET_FOLDER, this.isPullUpFromExternalBind, true);
    EventBus.on(Constant.EVENTS.SD_USB_CHANGE, this.sdUsbChangeBind);
    EventBus.on(Constant.EVENTS.REFRESH_FOLDER_SUB_FILE_COUNT, this.refreshFolderSubFileCountBind);
    EventBus.on(Constant.EVENTS.STOP_COPY_CUT_TASK, this.initDataBind);
    EventBus.on(Constant.EVENTS.REMOVE_DELETED_RESTORED_FILE_FROM_LIST, this.removeDeletedFileFromListBind);
    EventBus.on(Constant.EVENTS.LONG_PRESS_PRINT, this.printBind, true);
    EventBus.on(Constant.EVENTS.LONG_PRESS_COPY, this.copyBind, true);
    EventBus.on(Constant.EVENTS.LONG_PRESS_MOVE, this.moveBind, true);
    EventBus.on(Constant.EVENTS.LONG_PRESS_DELETE, this.deleteBind, true);
    EventBus.on(Constant.EVENTS.LONG_PRESS_RENAME, this.renameBind, true);
    EventBus.on(Constant.EVENTS.LONG_PRESS_DETAIL, this.detailBind, true);
    EventBus.on(Constant.EVENTS.LONG_PRESS_OTHER_APP, this.otherAppBind, true);
    EventBus.on(Constant.EVENTS.MY_PHONE_CLICK, this.detailClickBind, true);
    EventBus.on(Constant.EVENTS.CHANGE_STATE_BROSE, this.changeState, true);
    EventBus.on(Constant.EVENTS.LONG_PRESS_OPEN_FOLDER, this.openFolderBind, true);
    EventBus.on(Constant.EVENTS.LONG_PRESS_WALLPAPER, this.setAsWallpaperBind, true);
    EventBus.on(Constant.EVENTS.ADD_NEW_FOLDER, this.addNewFolderBind, true);
  }

  // 状态改变
  private changeState = () => {
    this.userState = UserState.BROWSER;
  }

  // 复制粘贴后，监听到图库相册内容变化时，触发刷新
  private dealGalleryRefresh(): void {
    HiLog.warn(TAG, 'dealGalleryRefresh');
    if (this.currentFolderUri !== '' && this.currentFolderUri === this.galleryRefresh.fileUri) {
      this.fileSource.getDataArray();
      this.refreshData();
    }
  }

  private dealRefreshWhenShow() {
    HiLog.warn(TAG, 'dealRefreshWhenShow');
    // 刷新我的手机的空间大小
    EventBus.emit(Constant.EVENTS.REFRESH_PHONE_SPACE_SIZE);
    // 如果当前页面正在展示，立即刷新，否则在pageShow时刷新
    if (!this.isPageShow && !this.isPreviewMode) {
      return;
    }
    const delay = 50;
    const timer = setTimeout(() => {
      this.refreshData();
      clearTimeout(timer);
    }, delay);
  }

  // 读取剪切板，进行粘贴
  private async holdToPaste(): Promise<void> {
    const pasteboardData: PasteboardDataModel =
      await PasteBoardManager.getInstance().startReadPasteboardTask(false, this.startModeOptions);
    if (ObjectUtil.isNullOrUndefined(pasteboardData) || ArrayUtil.isEmpty(pasteboardData.fileUriList)) {
      HiLog.warn(TAG, 'paste fail, pasteboardData or fileUriList is null');
      return;
    }
    const targetFolderUri = this.getCurrentDirUri();
    HiLog.infoPrivate(TAG, 'holdToPaste targetFolderUri', targetFolderUri);
    let fileInfoList: FileInfo[] = [];
    for (let fileUri of pasteboardData.fileUriList) {
      const fileName = FileUtil.getFileNameFromUri(fileUri);
      let data = new FileInfo();
      data.uri = fileUri;
      data.fileName = fileName;
      fileInfoList.push(data);
    }
    HiLog.info(TAG, 'holdToPaste fileUriList length:  ' + pasteboardData.fileUriList.length);
    CopyCutManager.getInstance()
      .pasteCutFile(fileInfoList, '', targetFolderUri, WorkerConst.OperateType.COPY_FILE, this.getSelectName(),
        CopyCutConst.OperateFrom.PASTE_BOARD);
    CommonPreferenceUtil.setLastResolvePasteboardTimestamp(pasteboardData.timestamp);
  }

  private async onDropCallback(event: DragEvent, targetFolderUri: string, targetFolderName: string,
    extraParams?: string): Promise<void> {
    HiLog.infoPrivate(TAG, 'drop callback',
      `targetFolderUri: ${targetFolderUri}, dragStartFolderUri: ${DragManager.getInstance().dragStartFolderUri}`)
    if (this.userState === UserState.MULTI_START) {
      this.userState = UserState.BROWSER;
    }
    if (StringUtil.isEmpty(targetFolderName)) {
      targetFolderName = this.curFolderName;
    }
    // 格式化系统文件夹名称，适配多种语言
    targetFolderName = MyPhoneConstant.getMyPhoneNameLanguageValue(targetFolderName);
    // 从当前目录拖出的文件drop时不再处理
    if (targetFolderUri === DragManager.getInstance().dragStartFolderUri) {
      HiLog.info(TAG, 'drop is invalid');
      return;
    }
    let dropFileList: FileInfo[] = [];
    let extraInfo: string = UdmfUtils.getExtra(extraParams);
    if (extraInfo === UdmfUtils.DRAG_IN_THE_APP) {
      HiLog.warn(TAG, 'Get data from local sources.');
      dropFileList = DragManager.getInstance().dragFileList;
    } else {
      dropFileList = await DragManager.getInstance().getFileInfoListFromUDMF(event);
    }
    HiLog.warn(TAG, `drop file start, file length: ${dropFileList.length}`);
    if (ArrayUtil.isEmpty(dropFileList)) {
      HiLog.warn(TAG, 'dropFileList is empty');
      return;
    }
    let operPage: DFX.PageName = this.isExternalStorageDevice() ? DFX.PageName.EXTERNAL : DFX.PageName.MY_PHONE;
    UEUtil.reportDragFile(DFX.DragType.DRAG_END, operPage, dropFileList.length);
    CopyCutManager.getInstance()
      .pasteCutFile(dropFileList, '', targetFolderUri, WorkerConst.OperateType.DRAG_FILE, targetFolderName, '',
        !DragManager.getInstance()
          .isInternalDrag);
  }

  /**
   * 是否展示已使用空间大小
   */
  private isShowUsedSpace(): boolean {
    return this.userState === UserState.BROWSER;
  }

  private onSelectOrderAccept(): void {
    HiLog.info(TAG, `onSelectOrderAccept: ${this.order}, desc : ${this.isDesc}`);
    UsageHabitsPreferenceUtil.updateUsageHabit(this.getUsageHabitsPageName(), this.startModeOptions.pickerFlag,
      UsageHabitsPreferenceConst.ORDER_TYPE, this.order);
    UsageHabitsPreferenceUtil.updateUsageHabit(this.getUsageHabitsPageName(), this.startModeOptions.pickerFlag,
      UsageHabitsPreferenceConst.IS_DESC, this.isDesc);
    if (this.fileSource.totalCount() === 0) {
      return;
    }
    const groupAndSortParam: GroupAndSortParam =
      FileSortParamUtil.initPhoneGroupAndSortParam(this.order, this.isDesc, false);
    HiSysEventUtil.reportFileGroupAndSortParamChange(groupAndSortParam,
      FileSortParamUtil.initPhoneGroupAndSortParam(this.order, this.isDesc, false),
      this.filePickerViewFlag ? AbilityName.FILE_PICKER : AbilityName.FILE_MANAGER);
    const pageRoute: string = PAGE_ROUTE_CONST.MY_PHONE;
    UEUtil.reportSortRuleChange(EnumTransferUtil.transferToSortType(this.order), !this.isDesc,
      EnumTransferUtil.transferToPageName(pageRoute), this.filePickerViewFlag);
    this.setShowLoading(this.fileSource.totalCount() > ORDER_NO_LOADING_FILES_THRESHOLD);
    setTimeout(() => {
      const newFileList = SortUtil.sortDataByOrder(this.fileSource.getDataArray(), this.order, this.isDesc);
      this.fileSource.setData(newFileList);
      this.setShowLoading(false);
    }, 20);
  }

  private initMenu(): void {
    this.topMenu = [];
  }

  private multipleChoiceCallBack(): void {
    // 数据查询时无法进入多选
    if (this.isQueryEnd === false) {
      return;
    }
    this.userState = UserState.MULTI_START;
    UEUtil.reportMultiSelect(DFX.OperateSource.MULTI_SELECT_BUTTON, this.getUEPageName());
    this.checkedNumChange();
  }

  private checkedNumChange(): void {
    this.selectItem = '';
    this.updateTitleMenu();
    if (!this.filePickerViewFlag) {
      this.updateBottom();
      this.isSelectAll = this.checkedNum === this.fileSource.getCanChooseCount();
      this.rightIcons = [this.buildMultipleChoiceButton()];
    }
    if (this.userState === UserState.MULTI_START) {
      this.getFileSize();
    } else {
      this.checkedSizeSubTitle = '';
    }
  }

  private getFileSize(): void {
    HiLog.info(TAG, `getFileSize start, selectFilesList length: ${this.selectFilesList.length}`);
    this.lastRandom = Math.random();
    let totalSize: number = 0;
    if (this.selectFilesList.length === 0) {
      this.checkedSizeSubTitle = '';
      return;
    }
    const ctx = GlobalHolder.getInstance().getExtensionContext();
    const totalFiles: FileInfo[] = [...this.selectFilesList];
    const fileArrLen: number = totalFiles.length;
    const sumTaskNum: number = Math.ceil(fileArrLen / 10000);
    let tempFinishedNum: number = 0;
    let isCalculated: boolean = false;
    const lastRandom: number = this.lastRandom;
    // 使用延时器，在计算线程超过150ms才返回结果时显示正在计算的字段
    const subTitleTimer: number = setTimeout(() => {
      if (!isCalculated && this.userState === UserState.MULTI_START &&
        Date.now() - this.subTitleChangeTime > Constant.SUB_TITLE_REFRESH_DELAY) {
        this.checkedSizeSubTitle = $r('app.string.get_folder_size_tips');
      }
      clearTimeout(subTitleTimer);
    }, Constant.SUB_TITLE_REFRESH_DELAY);
    for (let i: number = 0; i < sumTaskNum; i++) {
      let files = totalFiles.splice(0, 10000);
      let task: QueryCheckedFilesSizeTask = new QueryCheckedFilesSizeTask(files, ctx,
        (resSize: number) => {
          if (this.userState === UserState.MULTI_START && lastRandom === this.lastRandom) {
            HiLog.info(TAG, `resSize: ${resSize}`);
            this.subTitleChangeTime = Date.now();
            totalSize += resSize;
            tempFinishedNum++;
            if (tempFinishedNum === sumTaskNum) {
              isCalculated = true;
            }
            if (this.selectFilesList.length > 0) {
              this.checkedSizeSubTitle = $r('app.string.choose_size', renderSize(totalSize));
            } else {
              this.checkedSizeSubTitle = '';
            }
          }
        });
      TaskManager.getInstance().execute<number>(task);
    }
  }

  private updateBottom(): void {
    this.selectFilesList = this.fileSource.getSelectedFileList();
    this.allIsFavorite = this.selectFilesList.every((item) => FavoriteDbManager.getInstance()
      .isFavorite(item));
    this.allIsFolder = this.selectFilesList.every(item => item.isFolder);
    HiLog.info(TAG, 'isFavorite ' + this.allIsFavorite + ', this.allIsFolder ' + this.allIsFolder);
    let tempBottom: BottomOptions[] = [];

    tempBottom = this.defaultBottomOption.slice(0, BOTTOM_BAR_DIVIDE_INDEX);

    this.bottomOption = [];
    if (this.checkedNum === UiUtil.SELECT_NONE) {
      this.setBottomSelectNone(tempBottom);
    } else {
      this.updateBottomSelect(tempBottom);
    }
    this.fileSize = 0;
    this.selectFilesList.forEach(item => {
      this.fileSize += item.size;
    })
  }

  /**
   * 检查多选的文件夹是否包含系统文件夹
   * @returns
   */
  private checkContainSystemFolder(): boolean {
    // 判断是否为外接设备或选择列表为空
    if (this.isExternalStorageDevice() || ArrayUtil.isEmpty(this.selectFilesList)) {
      return false;
    }
    return this.selectFilesList.some(file =>
    MyPhoneConstant.isSystemFolder(ExternalStorageUtil.getParentUri(file.uri), file.fileName, file.isFolder));
  }

  /**
   * 检查多选的文件夹是否包含图库文件夹
   * @returns
   */
  private checkContainGalleryFolder(): boolean {
    // 判断是否为外接设备或选择列表为空
    if (this.isExternalStorageDevice() || ArrayUtil.isEmpty(this.selectFilesList)) {
      return false;
    }
    return this.selectFilesList.some(file => (
      file.uri.startsWith(Constant.MediaLibrary_URI_HEAD) && file.isFolder));
  }

  private updateBottomSelect(bottoms: BottomOptions[]) {
    // 检查是否有系统文件夹
    const selectSystemFolder: boolean = this.checkContainSystemFolder();
    const selectGalleryFolder: boolean = this.checkContainGalleryFolder();
    // 检查是否多选了2个以上的文件/文件夹
    const isMultiSelectOverTwo: boolean = this.selectFilesList.length >= 2;

    bottoms.forEach(item => {
      item.display = true;
      // 如果更多按钮里面为空，则置灰 更多菜单当前不存在为空的场景
      item.disabled = false;

      // 系统文件夹不可删除移动
      if (selectSystemFolder) {
        if (item.type === Constant.OPERATION_TYPE.MOVE || item.type === Constant.OPERATION_TYPE.DELETE) {
          item.disabled = true;
        }
        // 多选2个以上且包含系统文件夹时，禁用更多按钮
        if (isMultiSelectOverTwo && item.type === Constant.OPERATION_TYPE.MORE) {
          item.disabled = true;
        }
      }
      if (this.getCurrentDirUri() === VirtualUri.GALLERY) {
        item.disabled = true;
      }
      this.bottomOption.push(item);
    });
  }

  private isShowSetWallPaperButton(): boolean {
    if (this.selectFilesList.length !== 1) {
      return false;
    }
    return MenuUtil.canSetAsWallpaper(this.selectFilesList[0]);
  }

  // 底部按钮置灰
  private setBottomSelectNone(bottoms: BottomOptions[]) {
    bottoms.forEach(item => {
      item.disabled = true;
      this.bottomOption.push(item);
    });
  }

  private getCurrentDirUri(): string {
    HiLog.info(TAG,
      'getCurrentDirUri' +
        `            direListInfo:${JSON.stringify(this.direList)} direListLength:${this.direList.length}`);
    if (this.direList.length) {
      const lastBread = this.direList[this.direList.length - 1];
      return lastBread.uri;
    } else {
      if (!StringUtil.isEmpty(this.rootUri)) {
        return this.rootUri;
      }
    }

    HiLog.error(TAG, 'currentDir uri is null');
    return '';
  }

  private isCancelTask(): void {
    if (this.queryTask) {
      this.concatData = [];
      this.queryTask.cancelTask();
    }
  }

  private resetQueryTask(isShowLoading: boolean): void {
    if (this.queryTask) {
      this.queryTask.cancelTask();
      this.concatData = [];
    }
    if (isShowLoading || this.isShowLoading) {
      clearTimeout(this.timeoutId);
      this.timeoutId = setTimeout(() => {
        this.setShowLoading(true);
      }, 200);
      this.isQueryEnd = false;
    } else {
      clearTimeout(this.timeoutId);
      this.setShowLoading(false);
      this.isQueryEnd = true;
    }
  }

  private getQueryParam(dirUrl: string, albumType?: number, albumSubType?: number): QueryFileParam {
    const queryParam: QueryFileParam = new QueryFileParam();
    queryParam.isDesc = this.isDesc;
    queryParam.orderBy = this.order;
    this.queryId++;
    queryParam.queryId = this.queryId;
    queryParam.context = this.startModeOptions.context;
    queryParam.rootName = this.getTitle(this.originalTitle);
    queryParam.dirUri = dirUrl;
    const imageSizeMin = this.dataPreferences?.getSync('imageSizeFilter', IMAGE_SIZE_FILTER_DEFAULT) as number;
    queryParam.sizeMin = imageSizeMin === 0 ? 1 : imageSizeMin * IMAGE_SIZE_FILTER_TRANS;
    queryParam.pageFrom = this.pageFrom;

    if (this.isExternalStorageDevice()) {
      queryParam.isExternalStorageDevice = true;
      queryParam.storageDeviceUid = this.uuid;
    }
    if (!this.virtualRootUri) {
      queryParam.currBreadFullPath = getCurrentFolderPathByBreadCrumb(this.direList, true);
    }

    if (albumType !== undefined && albumSubType) {
      HiLog.info(TAG, `getQueryParam with albumType:${albumType}_${albumSubType}`)
      queryParam.albumType = albumType;
      queryParam.albumSubType = albumSubType;
    }
    queryParam.isBlackSuffix = this.isBlackList;
    queryParam.suffixList = this.suffixes;
    return queryParam;
  }

  private getListFile(curAddressData: AddressData, isShowLoading: boolean = false) {
    HiLog.info(TAG, 'getListFile start');
    this.resetQueryTask(isShowLoading);
    const dirUrl = curAddressData.uri;
    this.currLocalFolder = dirUrl;
    const queryParam = this.getQueryParam(dirUrl, curAddressData.albumType, curAddressData.albumSubType);
    this.isLoading = false;
    if (dirUrl.startsWith(Constant.MediaLibrary_URI_HEAD)) {
      this.incrementalQueryStart = true;
    }
    if (FileUtil.isArchiveByUri(queryParam.dirUri)) {
      this.initMenu();
      this.rightIcons = this.buildRightIcons();
    } else {
      this.initMenu();
      this.rightIcons = this.buildRightIcons();
      queryParam.showHiddenItem = this.showHiddenItem;
      queryParam.isPersistPermission = this.isPersistPermission;
      queryParam.tokenID = this.tokenID;
      this.queryTask = new QueryLocalFileTask(this.queryLocalFileCallbackBind, queryParam, this.filePickerViewFlag);
      TaskManager.getInstance().executeTask<FileInfo[]>(this.queryTask);
    }
  }

  private async queryDownloadReceive() {
    const fileOrGroupList: FileInfo[] = [];

    this.fileSource.setData(fileOrGroupList);
    this.setShowLoading(false); // 下载与接收单独调用queryDownloadReceive，没有调用通用的queryTaskEndHandle
    this.resetQueryTask(false);
  }

  private async queryDownloadFileInfo(value: string, key: string, fileOrGroupList: FileInfo[]) {
    const fileInfo = new FileInfo();
    fileInfo.uri = value;
    fileInfo.isFolder = true;
    fileInfo.fileName = key;
    fileOrGroupList.push(fileInfo);
  }

  private getSoundRecordFileInfo(): FileInfo {
    const soundRecordFileInfo = new FileInfo();
    soundRecordFileInfo.uri = '';
    soundRecordFileInfo.isFolder = true;
    soundRecordFileInfo.fileName = MyPhoneConstant.MY_PHONE_SOUND_RECORDER;
    soundRecordFileInfo.subFileCount = Constant.FOLDER_SUB_DEFAULT;
    soundRecordFileInfo.isChecked = false;
    soundRecordFileInfo.isMultiEnable = false;
    return soundRecordFileInfo;
  }

  // 文件操作处理
  private async optionChange(): Promise<void> {
    if (!menuCanClick(this.checkedNum, this.selectItem)) {
      return;
    }
    switch (this.selectItem) {
      case Constant.OPERATION_TYPE.COPY:
        this.moveType = Constant.OPERATION_TYPE.COPY;
        this.operationType = Constant.OPERATION_TYPE.COPY;
        this.copyOperation();
        break;
      case Constant.OPERATION_TYPE.PASTING:
        this.selectName = this.getSelectName();
        this.pasteFiles(this.selectFilesList, this.getCurrentDirUri());
        break;
      case Constant.OPERATION_TYPE.MOVE:
        this.moveType = Constant.OPERATION_TYPE.MOVE;
        this.operationType = Constant.OPERATION_TYPE.MOVE;
        this.move();
        break;
      case Constant.OPERATION_TYPE.MOVE_TO_CURRENT_FOLDER:
        this.selectName = this.getSelectName();
        this.moveFiles(this.selectFilesList, this.getCurrentDirUri());
        break;
      case Constant.OPERATION_TYPE.MOVE_TO_OTHER_FOLDER:
        this.moveToOtherFolder();
        break;
      default:
        break;
    }
  }

  private copyOperation() {
    this.copyCutSrcPath = this.getCurrentDirUri();
  }

  private move(): void {
    if (this.fileOperation($r('app.string.cannot_delete_app_data'))) {
      return;
    }
    this.copyCutSrcPath = this.getCurrentDirUri();
    this.moveToOtherFolder();
  }

  private moveToOtherFolder(): void {
    EventBus.on(Constant.EVENTS.PATH_SELECT_END, this.resolvePathSelectEndBind);
    const pathSelectParam = new PathSelectParam(this.selectFilesList, this.operationType);
    EventBus.emit(Constant.EVENTS.SHOW_PATH_PICKER, pathSelectParam);
  }

  private pasteTargetUri: string = '';
  @StorageLink('isCellular') isCellular: boolean = false;
  @StorageLink('isNetwork') isNetwork: boolean = false;
  @StorageLink('cellularTransmissionFileSize') cellularTransmissionFileSize: number = 0;
  private confirmCallback: Callback<void> = () => {
  };

  private async resolvePathSelectEnd(folderUri: string): Promise<void> {
    EventBus.off(Constant.EVENTS.PATH_SELECT_END, this.resolvePathSelectEndBind);
    this.pasteTargetUri = folderUri;
    if (StringUtil.isEmpty(folderUri)) {
      HiLog.warn(TAG, 'resolvePathSelectEnd folderUri is empty');
      this.selectItem = '';
      return;
    }
    if (FileUtil.getFileParentPathFromUri(folderUri) === VirtualUri.EXTERNAL_DISK) {
      const storageDeviceList = await StorageDeviceManager.getInstance().getStorageDeviceList();
      for (let rootInfo of storageDeviceList) {
        if (rootInfo.uri !== folderUri) {
          continue;
        }
        this.selectName = rootInfo.description;
        break;
      }
    } else {
      this.selectName = FileUtil.getFileNameFromUri(folderUri);
    }
    if (this.moveType === Constant.OPERATION_TYPE.MOVE) {
      this.moveFiles(this.selectFilesList, folderUri);
    } else if (this.moveType === Constant.OPERATION_TYPE.COPY) {
      this.pasteFiles(this.selectFilesList, folderUri);
    }
  }

  private pasteFiles(fileList: FileInfo[], targetFolderUri: string) {
    // 退出多选
    this.backCallback();
    HiLog.info(TAG, 'paste file.');

    CopyCutManager.getInstance()
      .pasteCutFile(fileList, this.copyCutSrcPath, targetFolderUri, WorkerConst.OperateType.COPY_FILE,
        this.selectName);
  }

  private moveFiles(fileList: FileInfo[], currentFolderUri: string) {
    // 退出多选
    this.backCallback();
    CopyCutManager.getInstance()
      .pasteCutFile(fileList, this.copyCutSrcPath, currentFolderUri, WorkerConst.OperateType.CUT_FILE,
        this.selectName);
  }

  private getSelectName() {
    if (this.direList.length > 0) {
      const lastBread = this.direList[this.direList.length - 1];
      return lastBread.name;
    }
    return this.getTitle(this.originalTitle || DeviceConfig.getInstance().config.myDevice);
  }

  /**
   * 从文件列表中移除已删除的文件
   */
  private removeDeletedFileFromList(deletedFileList: string[], operationType: string): void {
    HiLog.info(TAG, 'remove Deleted File From List');
    if (this.isPreviewMode) {
      HiLog.warn(TAG, 'preview mode not need update fileSource');
      return;
    }
    if (this.currentFolderUri === VirtualUri.GALLERY) {
      HiLog.info(TAG, 'removeDeletedFileFromList ' + deletedFileList.length);
      this.userState = UserState.BROWSER;
      this.refreshData(false);
      return;
    }
    if (this.userState === UserState.MULTI_START) {
      this.backCallback();
    }
    if (ArrayUtil.isEmpty(deletedFileList) || (operationType === Constant.OPERATION_TYPE.RESTORE)) {
      return;
    }
    this.operationType = operationType;
    if (deletedFileList.length === this.fileSource.totalCount()) {
      this.fileSource.batchDeleteData(deletedFileList);
      const newFileList = SortUtil.sortDataByOrder(this.fileSource.getDataArray(), this.order, this.isDesc);
      this.fileSource.setData(newFileList);
      return;
    }
    this.isShowLocateAni = true;
    this.getUIContext()?.animateTo({
      duration: 350,
      curve: Curve.Smooth, onFinish: () => {
        this.isShowLocateAni = false;
      }
    }, () => {
      this.fileSource.batchDeleteData(deletedFileList);
      const newFileList = SortUtil.sortDataByOrder(this.fileSource.getDataArray(), this.order, this.isDesc);
      this.fileSource.setData(newFileList);
    })
  }

  private checkCopyCutTaskCallback(): boolean {
    return CopyCutManager.getInstance().checkTaskIsRun();
  }

  private async writePasteBoardCallback(selectFilesList: FileInfo[]): Promise<void> {
    PasteBoardManager.getInstance().startSetPasteBoardTask(selectFilesList, this.startModeOptions);
  }

  private dialogCallback(event: BottomCallParams) {
    const type = event.item.type;
    const closeDialog = event.item.closeDialog;
    let mediaSearchType = -1;
    HiLog.warn(TAG, 'dialogCallback :' + mediaSearchType)
    switch (type) {
      case Constant.OPERATION_TYPE.DELETE:
        EventBus.emit(Constant.EVENTS.START_DELETE_RESTORE_FILE_TASK, this.selectFilesList,
          Constant.OPERATION_TYPE.DELETE, false, mediaSearchType);
        break;
      case Constant.OPERATION_TYPE.RENAME:
        this.dialogCallbackRenameAction(event);
        this.recordRenameFiles(event.item);
        break;
      case Constant.OPERATION_TYPE.DETAIL:
        if (!closeDialog) {
          return;
        }
        this.initData();
        break
      case Constant.OPERATION_TYPE.HARD_DELETE:
        EventBus.emit(Constant.EVENTS.START_DELETE_RESTORE_FILE_TASK, this.selectFilesList,
          Constant.OPERATION_TYPE.HARD_DELETE, false, mediaSearchType);
        this.initData();
      default:
        break
    }
  }

  private dialogCallbackRenameAction(event: BottomCallParams) {
    const newName = event.item.newName;
    const oldUri: string | undefined = event.item.oldUri;
    try {
      if (!newName || !oldUri) {
        return;
      }
      const newUri = event.item.newUri;
      const theIndex = this.fileSource.getIndex(oldUri);
      if (theIndex >= 0) {
        const fileItem = this.fileSource.getData(theIndex);
        if (!StringUtil.isEmpty(newUri)) {
          fileItem.uri = newUri;
        }
        let newPath = event.item.newPath;
        if ((!ObjectUtil.isNullOrUndefined(newPath)) && (!StringUtil.isEmpty(newPath))) {
          fileItem.relativePath = newPath || '';
        }
        FileDataUtil.setFileName(fileItem, newName);
        // 获取显示隐藏开关状态
        if (this.showHiddenItem === false && newName.startsWith('.')) {
          this.fileSource.deleteData(theIndex); // 新文件名需要隐藏
        } else {
          this.fileSource.replaceData(theIndex, fileItem);
          this.notifyUpdateFileItemInGroup(theIndex);
        }
        let newFileList: FileInfo[] = this.fileSource.getDataArray();
        if (this.order === SortOrder.NAME) {
          newFileList = SortUtil.sortDataByOrder(newFileList, this.order, this.isDesc);
        }
        this.fileSource.setData(newFileList);
      }
    } catch (err) {
      HiLog.info(TAG, `renameCallbackAction err, ${JSON.stringify(err)}`)
    } finally {
      this.backCallback();
    }
  }

  private async recordRenameFiles(renameItem: RenameItem): Promise<void> {
    // 仅我的手机页需要记录
    if (renameItem.oldUri && renameItem.newName) {
      let renameItems: RenameItem[] = AppStorage.get(LATEST_RENAME_ITEMS) ?? [];
      renameItems.push(renameItem);
      AppStorage.setOrCreate<RenameItem[]>(LATEST_RENAME_ITEMS, renameItems);
    }
  }

  private notifyUpdateFileItemInGroup(originalIndex: number): void {
    HiLog.info(TAG, `notifyUpdateFileItemInGroup`);
    EventBus.emit(Constant.EVENTS.UPDATE_FILE_ITEM_IN_GROUP, originalIndex);
  }

  private onPickerCancelClick(): void {
    EventBus.emit(Constant.EVENTS.CLOSE_UI_FILE_PICKER + this.startModeOptions.currentCreateTimeStamp);
  }

  private initData(): void {
    this.selectFilesList = [];
    this.checkedNum = 0;
    this.userState = UserState.BROWSER;
    this.selectItem = '';
    this.fileSize = 0;
    // 全部数据列表的isChecked置为false
    this.fileSource.selectAll(false);
  }

  private backCallback(isLeftIcon: boolean = false): void {
    if (this.userState === UserState.BROWSER) {
      this.backDestroyPage();
      return;
    }
    this.initData();
  }

  private onPickerOkIconClick(): void {
    if (!this.pickerCheckArr) {
      return;
    }
    PhoneFilePickerUtil.terminateFilePicker([...this.pickerCheckArr], ResultCodePicker.SUCCESS, this.startModeOptions);
  }

  private onSelectAllIconClick(isSelectAll: boolean): void {
    HiLog.info(TAG, 'onSelectAllIconClick ' + isSelectAll);
    if (isSelectAll) {
      if (this.filePickerViewFlag) {
        this.checkedNum = this.fileSource.filePickSelectAll(this.checkedNum, this.startModeOptions);
      } else {
        this.fileSource.selectAll(true);
        this.checkedNum = this.fileSource.getCanChooseCount();
      }
      this.accessibilityManager.sendCustomIdFocusForAccessibility(Constant.OPERATION_TYPE.DESELECT_ALL);
      this.isSelectAll = true;

      if (this.isPersistPermission) {
        this.pickerCheckArr = [];
        let pickerCheckArrTemp: string[] = [];
        this.fileSource.getFileList().forEach((item: FileInfo) => {
          if (item.isChecked) {
            pickerCheckArrTemp.push(item.uri);
          }
        })
        this.pickerCheckArr = pickerCheckArrTemp;
        if (this.fileSource.totalCount() > this.startModeOptions.maxSelectNumber) {
          promptAction.showToast({
            message: $r('app.plural.filePickerMaxSelect', this.startModeOptions.maxSelectNumber,
              this.startModeOptions.maxSelectNumber)
          })
        }
      }
    } else {
      this.fileSource.selectAll(false);
      this.checkedNum = 0;
      this.isSelectAll = false;
      this.selectFilesList = [];
      this.accessibilityManager.sendCustomIdFocusForAccessibility(Constant.OPERATION_TYPE.SELECT_ALL);
      this.pickerCheckArr = [];
    }
    this.rightIcons = [this.buildMultipleChoiceButton()];
    if (this.isPersistPermission) {
      const cancelButton = new TitleMenuItem(MENU_ICONS.cancel, MENU_NAME.cancel,
        () => this.onPickerCancelClick(), true, false);
      cancelButton.accessibilityRoleType = AccessibilityRoleType.BUTTON;
      this.rightIcons.push(cancelButton);
    }
  }

  private refreshData(isDelete: boolean = false) {
    if (this.direList.length) {
      HiLog.info(TAG, 'refresh data getListFile');
      const lastBread = this.direList[this.direList.length - 1];
      this.getListFile(lastBread, true);
      return;
    }
    this.refreshRootListPage(false, isDelete);
  }

  private renameUpdate(): void {
    let renameItems: RenameItem[] | undefined = AppStorage.get(LATEST_RENAME_ITEMS);
    if (!renameItems) {
      HiLog.warn(TAG, `renameItems not exists`);
      return;
    }
    HiLog.info(TAG, `MyPhone renameUpdate renameItems.length:${renameItems.length}`);
    renameItems.forEach((renameItem) => {
      const oldUri: string | undefined = renameItem.oldUri;
      const newName: string | undefined = renameItem.newName;
      const newUri: string = renameItem.newUri;
      const newPath: string | undefined = renameItem.newPath;
      if (!oldUri || !newName || !newUri || !newPath) {
        HiLog.warn(TAG, `part of rename info missing `);
        return;
      }
      const renamedFileIndex = this.fileSource.getIndex(oldUri);
      if (renamedFileIndex >= 0) {
        const fileItem = this.fileSource.getData(renamedFileIndex);
        fileItem.uri = newUri;
        fileItem.relativePath = newPath;
        FileDataUtil.setFileName(fileItem, newName);
        this.fileSource.replaceData(renamedFileIndex, fileItem);
        this.notifyUpdateFileItemInGroup(renamedFileIndex);
      }
    });
    AppStorage.delete(LATEST_RENAME_ITEMS);
  }

  private isPullUpFromExternal(params: AbilityOrRouterParams): boolean {
    let otherFrom: string = GlobalHolder.getInstance().getObject<string>(GlobalKey.FROM);
    if (StringUtil.isEmpty(otherFrom)) {
      return false;
    }
    HiLog.info(TAG, 'from ' + otherFrom);
    switch (otherFrom) {
      case Constant.FROM_TYPE.COPY_CUT_NOTIFICATION:
      case Constant.FROM_TYPE.FROM_MEDIA_VIEW:
      case Constant.FROM_TYPE.THIRD_APP:
        // 如果当前处于不属于来源页面，且当前目录在我的手机(网路邻居)中，且不是压缩包内的路径：跳转到指定目录
        if ((this.currentFolderUri?.startsWith(VirtualUri.MY_PHONE) || (FileUtil.isSandboxUri(this.currentFolderUri) &&
        FileUtil.isArchiveByUri(this.currentFolderUri)))) {
          this.isPullEnd = false;
          this.pageParams = params;
          this.getParams();
          this.menuActionHandler?.refreshFromPage(this.pageFrom);
          this.getFileUsageHabits();
          this.initTitle();
          this.setShowLoading(true);
          this.isQueryEnd = false;
          this.dealFromType();
          GlobalHolder.getInstance().deleteObject(GlobalKey.FROM);
          if (StringUtil.isEmpty(this.targetPath)) {
            this.refreshRootListPage(true);
          } else {
            this.toTargetFolder(this.targetPath);
          }
        } else {
          if (params.uriPath === this.currentFolderUri &&
            this.pageInfos.getAllPathName().pop() === PAGE_ROUTE_CONST.MY_PHONE) {
            this.pageInfos.replacePath(new NavPathInfo(PAGE_ROUTE_CONST.MY_PHONE, params),
              UiUtil.showSwitchAnimation(this.navMode));
          } else {
            this.pageInfos.pushPath(new NavPathInfo(PAGE_ROUTE_CONST.MY_PHONE, params),
              UiUtil.showSwitchAnimation(this.navMode));
          }
        }
        return true;
      default:
        return false;
    }
  }

  private removeEventListener(isDisappear: boolean = true): void {
    /**
     * 避免在进入搜索页面时取消此事件，导致通知栏点击后无法监听相关的事件而不进行页面的跳转
     */
    if (isDisappear) {
      EventBus.off(Constant.EVENTS.OPEN_TARGET_FOLDER, this.isPullUpFromExternalBind);
    }
    EventBus.off(Constant.EVENTS.EXIT_MULTI_STATE, this.initDataBind)
    EventBus.off(Constant.EVENTS.SD_USB_CHANGE, this.sdUsbChangeBind);
    EventBus.off(Constant.EVENTS.REFRESH_FOLDER_SUB_FILE_COUNT, this.refreshFolderSubFileCountBind);
    EventBus.off(Constant.EVENTS.STOP_COPY_CUT_TASK, this.initDataBind);
    EventBus.off(Constant.EVENTS.REMOVE_DELETED_RESTORED_FILE_FROM_LIST, this.removeDeletedFileFromListBind);
    EventBus.off(Constant.EVENTS.LONG_PRESS_PRINT, this.printBind);
    EventBus.off(Constant.EVENTS.LONG_PRESS_COPY, this.copyBind);
    EventBus.off(Constant.EVENTS.LONG_PRESS_MOVE, this.moveBind);
    EventBus.off(Constant.EVENTS.LONG_PRESS_DELETE, this.deleteBind);
    EventBus.off(Constant.EVENTS.LONG_PRESS_RENAME, this.renameBind);
    EventBus.off(Constant.EVENTS.LONG_PRESS_DETAIL, this.detailBind);
    EventBus.off(Constant.EVENTS.LONG_PRESS_OTHER_APP, this.otherAppBind);
    EventBus.off(Constant.EVENTS.MY_PHONE_CLICK, this.detailClickBind);
    EventBus.off(Constant.EVENTS.CHANGE_STATE_BROSE, this.changeState);
    EventBus.off(Constant.EVENTS.LONG_PRESS_OPEN_FOLDER, this.openFolderBind);
    EventBus.off(Constant.EVENTS.LONG_PRESS_WALLPAPER, this.setAsWallpaperBind);
    EventBus.off(Constant.EVENTS.ADD_NEW_FOLDER, this.addNewFolderBind);
  }

  private printChange(): void {
    let printFiles: string[] = [];
    for (let i = 0; i < this.selectFilesList.length; i++) {
      HiLog.infoPrivate(TAG, `Print menu onClick, index is ${i}`, `URI is ${this.selectFilesList[i].uri}`);
      printFiles.push(this.selectFilesList[i].uri);
    }
    PrintUtil.printPhoneFiles(printFiles, getContext(this))
      .finally(() => {
        this.backCallback();
      });
  }

  // 长按菜单的复制
  private longPressCopy(fileInfo?: FileInfo): void {
    let list: FileInfo[] = [];
    if (fileInfo) {
      HiLog.info(TAG, 'longPressCopy fileInfo exist');
      list.push(fileInfo);
    } else if (this.userState === UserState.MULTI_START) {
      list = this.selectFilesList;
    } else {
      HiLog.warn(TAG, 'not get operate files, list is null');
    }
    HiLog.warn(TAG, `longPressCopy operate list length ${list.length}`);
    this.selectFilesList = list;
    this.writePasteBoardCallback(list);
    this.pullUpPicker();
  }

  // 复制文件，拉起picker
  private pullUpPicker() {
    HiLog.info(TAG, 'pullUpPicker');
    this.moveType = Constant.OPERATION_TYPE.COPY;
    this.operationType = Constant.OPERATION_TYPE.COPY;
    EventBus.on(Constant.EVENTS.PATH_SELECT_END, this.resolvePathSelectEndBind);
    const pathSelectParam = new PathSelectParam(this.selectFilesList, Constant.OPERATION_TYPE.PASTING)
    EventBus.emit(Constant.EVENTS.SHOW_PATH_PICKER, pathSelectParam);
  }

  private moveChange(): void {
    this.moveType = Constant.OPERATION_TYPE.MOVE;
    this.operationType = Constant.OPERATION_TYPE.MOVE;
    this.move();
    setTimeout(() => {
      this.longPressChangeType = Constant.OPERATION_TYPE.MOVE;
    }, 100)
  }

  private longPressTypeChange(type: string, fileInfo?: FileInfo): void {
    if (fileInfo) {
      this.fileInfo = fileInfo;
    }
    HiLog.info(TAG, 'myphone long press type change' + type);
    setTimeout(() => {
      this.longPressChangeType = type;
    }, 100)
  }

  private detailClick(closeDialog: boolean): void {
    const data: RenameItem = {
      closeDialog: closeDialog,
      type: Constant.OPERATION_TYPE.DETAIL,
      newUri: ''
    }
    this.dialogCallback({ item: data } as BottomCallParams);
  }

  private async refreshFolderSubFileCount(folderUri: string): Promise<void> {
    const subItemCount = await FileUtil.getFolderSubFileCount(folderUri, false, this.showHiddenItem);
    const index = this.fileSource.getIndex(folderUri);
    if (index >= 0) {
      const oldFolder = this.fileSource.getData(index);
      oldFolder.subFileCount = subItemCount;
      this.fileSource.replaceData(index, oldFolder);
    }
  }

  private preventBackPress(isPreventBack: boolean): void {
    this.isPreventBack = isPreventBack;
  }

  private sdUsbChange(uriArray: string[]): void {
    // U盘或SD卡移除时返回首页
    if ((!StringUtil.isEmpty(this.rootUri)) && (uriArray.indexOf(this.rootUri) === -1)) {
      this.isClosePage = true;
      this.pageInfos.clear();
    }
  }

  private isRootFolder() {
    return StringUtil.isEmpty(this.targetPath) || this.targetPath === rootFlag;
  }

  private onDireListChange(): void {
    HiLog.info(TAG, 'myPhone onDireListChange' +
      `          direListInfo:${JSON.stringify(this.direList)},direListLength:${this.direList.length}`);
    if ((this.userState === UserState.BROWSER) && this.leftIcon) {
      this.leftIcon.isShown = this.navMode !== NavigationMode.Split || this.direList.length > 0 ||
      this.currentVirtualFolderUri.startsWith(VirtualUri.GALLERY);
    }
    this.listScrollShow = false;
    this.isLoading = false;
    HiLog.info(TAG, 'listScrollShow start. ');
    this.fileSource.setData([]);
    this.updateState();
    this.currentFolderUri = this.getCurrentDirUri();
    const direLen = this.direList.length;
    if (direLen > 0) { // 非根目录
      const curBreadCrumb = this.direList[direLen - 1];
      HiLog.infoPrivate(TAG, 'curBreadCrumb: ', curBreadCrumb.name);
      this.getListFile(curBreadCrumb, true);
    } else {
      this.refreshRootListPage(true);
      // 进入根目录面包屑消失，主动更新无障碍焦点
      this.accessibilityFocusNextFloor();
    }
    this.getPhotosPage();
    this.curFolderName = this.getSelectName();
    HiLog.info(TAG, 'onDireListChange BreadCrumb length:' + this.direList.length);
    setTimeout(() => {
      this.listScrollShow = true;
    }, 10);
  }

  private updateState(): void {
    if (this.userState === UserState.COPY || this.userState === UserState.MOVE ||
      this.userState === UserState.SELECT_PATH) {
      return;
    }
    this.checkedNum = 0;
    this.userState = UserState.BROWSER;
    this.selectFilesList = [];
  }

  private setShowLoading(isShow: boolean): void {
    HiLog.info(TAG, `setShowLoading:${isShow}`);
    this.isShowLoading = isShow;
  }

  private backDestroyPage(): void {
    if (this.finishType === PageFinishType.FINISH_ABILITY) {
      GlobalHolder.getInstance().getMainAbilityContext().terminateSelf();
      return;
    }
    if (this.navMode !== NavigationMode.Split) {
      this.destroyAllMyPhone();
      return;
    }
    this.direList = [];
  }

  private destroyAllMyPhone() {
    this.isClosePage = true;
    const pageInfo: NavPathInfo | undefined = this.pageInfos.pop();
    if (pageInfo && (pageInfo.name !== PAGE_ROUTE_CONST.MY_PHONE) && (pageInfo.name !== PAGE_ROUTE_CONST.IMAGE) &&
      (pageInfo.name !== PAGE_ROUTE_CONST.VIDEO) && (pageInfo.name !== PAGE_ROUTE_CONST.GALLERY)) {
      this.pageInfos.pushPath(pageInfo);
      this.noGalleryPageProcess();
      return;
    }
  }

  /**
   * 当前只处理打开文件或文件夹
   * @param fileItem fileItem
   */
  private onItemClick(fileItem: FileInfo): void {
    if (this.virtualRootUri === VirtualUri.DOWNLOAD_RECEIVE) {
      this.virtualRootUri = fileItem.uri;
      this.originalTitle = fileItem.fileName;
    }

    // 目录点进去
    if (fileItem.isFolder) {
      this.clickFolder(fileItem);
      return;
    }
    // 目前文件不支持本地预览，所有文件均只能用第三方应用打开
    // 压缩包也走第三方应用打开的逻辑，可以通过FileUtil.isArchiveByUri(fileItem.uri)判断是否是压缩包
    this.clickFile(fileItem);
  }

  private onUserStateChange(): void {
    if (this.filePickerViewFlag) {
      return;
    }

    HiLog.warn(TAG, `userStateChange to ${this.userState}`);
    if (this.navMode === NavigationMode.Split) {
      if (this.userState !== UserState.BROWSER) {
        this.showEntryBottomBarFlag = false;
      } else {
        this.showEntryBottomBarFlag = true;
      }
    }

    if (this.userState === UserState.MULTI_START) {
      this.leftIcon.icon = $r('sys.symbol.xmark');
      this.leftIcon.name = MENU_NAME.close;
      this.leftIcon.action = () => this.onBackPress();
      this.leftIcon.isShown = true;
      this.leftIcon.dragEnable = false;
      this.rightIcons = [this.buildMultipleChoiceButton()];
      return;
    } else {
      this.checkedSizeSubTitle = '';
    }
    if (this.userState === UserState.BROWSER) {
      this.getFileUsageHabits();
      this.initTitle();
      this.isSelectAll = false;
      this.longPressChangeType = '';
      this.fileSource.selectAll(false);
      return;
    }
    if ((this.userState === UserState.COPY) || (this.userState === UserState.MOVE)) {
      this.rightIcons = [];
    }
  }

  private updateTitleMenu(): void {
    if (this.filePickerViewFlag) {
      return;
    }
    if (this.userState === UserState.MULTI_START) {
      // 选择器场景
      this.rightIcons = [this.buildMultipleChoiceButton()];
      return;
    }
    if ((this.userState === UserState.COPY) || (this.userState === UserState.MOVE)) {
      this.rightIcons = [];
    }
  }

  private recordOffset() {
    const len = this.direList.length;
    if (len) {
      this.direList[len - 1].yOffset = this.listYOffset;
      this.direList[len - 1].startFileIndex = this.scrollStartIndex;
    } else {
      this.rootYOffset = this.listYOffset;
      this.rootYOffsetIndex = this.scrollStartIndex;
    }
  }

  /**
   * 点击文件夹
   */
  private clickFolder(fileItem: FileInfo): void {
    HiLog.info(TAG, `clickFolder this.scrollStartIndex:${this.scrollStartIndex}, this listYOffset:${this.listYOffset}`);
    HiSysEventUtil.reportFileOperation(OperateName.OPEN, 'folder', OperateResult.SUCCESS);
    this.recordOffset();
    // 沙箱压缩文件内文件夹须支持跳转
    if (!FileUtil.isGalleryAddress(this.currentFolderUri) && !this.checkItemAndBreadUri(fileItem.relativePath) &&
      !(FileUtil.isSandboxUri(fileItem.uri) && FileUtil.isArchiveByUri(fileItem.uri))) {
      this.onDireListChange();
      return;
    }
    const tempBreadData: AddressData = new AddressData(fileItem.uri, fileItem.fileName);
    if (fileItem.uri.startsWith(VirtualUri.GALLERY_URI)) {
      tempBreadData.albumType = fileItem.albumType;
      tempBreadData.albumSubType = fileItem.albumSubType;
    }
    this.reportEnterAlbumUE(fileItem, DFX.EnterAlbumType.GALLERY_FOLDER);
    if (this.showMaskLayer || FileUtil.isArchiveByUri(fileItem.uri)) {
      this.direList.push(tempBreadData);
      this.listYOffset = 0;
      this.scrollStartIndex = 0;
      this.accessibilityFocusNextFloor();
    } else {
      this.openFolderByNewPage(fileItem, tempBreadData);
    }
  }

  // 新页面打开文件夹
  private openFolderByNewPage(fileItem: FileInfo, nextBread: AddressData): void {
    HiLog.info(TAG, 'openFolderByNewPage');
    // 融合相册跳转
    if (fileItem.isFusionAlbum) {
      let params = {
        uriPath: fileItem.uri,
        pageFrom: this.currentFolderUri
      } as AbilityOrRouterParams;
      this.currLocalFolder = '';
      this.pageInfos.pushPath(new NavPathInfo(PAGE_ROUTE_CONST.MY_PHONE, params), true);
      this.resetUserState();
      return;
    }
    const rootBread = new AddressData(this.rootUri);
    rootBread.yOffset = this.rootYOffset;
    rootBread.startFileIndex = this.rootYOffsetIndex;
    const breadOffsetList: AddressData[] = [rootBread];
    this.direList.forEach((breadItem) => {
      const tmpBread = JSON.parse(JSON.stringify(breadItem)) as AddressData;
      breadOffsetList.push(tmpBread);
    })
    breadOffsetList.push(nextBread);
    this.folderOperateType = FolderOperationType.OPEN_FOLDER;
    this.isReplaced = true;
    this.animationController.zIndexNumber = 1;
    let params: AbilityOrRouterParams = this.getReplacePageParam(breadOffsetList);
    params.path = fileItem.uri;
    CustomTransition.getInstance().transitionAnimationType =
      StandardAnimation.TransitionAnimationType.FOLDER_OPEN_AND_EXIT;
    this.pageInfos.replacePath(new NavPathInfo(PAGE_ROUTE_CONST.MY_PHONE, params), true);
  }

  // 获取文件夹/相册变更基础参数
  private getReplacePageParam(breadList: AddressData[]): AbilityOrRouterParams {
    return {
      uuid: this.uuid,
      from: this.sourceFlag,
      pageFrom: this.pageFrom,
      title: this.originalTitle,
      rootUri: this.rootUri,
      folderOperateType: this.folderOperateType,
      direList: breadList
    } as AbilityOrRouterParams;
  }

  /**
   * 校验点击的目录和当前的面包屑路径是否匹配，如果不匹配，就不执行后续逻辑
   * @param itemPath 当前点击的文件夹Path
   * @returns true：校验OK，继续执行后续查询逻辑
   */
  private checkItemAndBreadUri(itemPath: string = ''): boolean {
    let len = this.direList.length
    if (len) {
      if (StringUtil.isEmpty(this.rootRelativePath)) {
        return true;
      }
      let breadPath = this.rootRelativePath + getCurrentFolderPathByBreadCrumb(this.direList, false);
      HiLog.infoPrivate(TAG, 'checkItemAndBreadUri', `itemPath: ${itemPath}, breadPath: ${breadPath}`);
      if (itemPath === breadPath) {
        HiLog.info(TAG, 'checkItemAndBreadUri is equal');
        return false;
      }
      let index = itemPath.indexOf(breadPath);
      if (index === -1) {
        HiLog.info(TAG, 'checkItemAndBreadUri is not ');
        return false;
      }
      let temp = itemPath.substring(breadPath.length + 1);
      HiLog.infoPrivate(TAG, 'checkItemAndBreadUri:', temp);
      let splitIndex = temp.indexOf('/');
      return splitIndex === -1;
    } else {
      return true;
    }
  }

  private clickFile(fileItem: FileInfo): void {
    HiSysEventUtil.reportFileOperation(OperateName.OPEN, 'files', OperateResult.SUCCESS);
    this.recordOffset();
    PreviewUtil.filePreview(fileItem);
  }

  /**
   * 判断您是否为外部存储
   * uuid是外部存储的唯一标识，可以用于判断是否为外部存储
   * @returns
   */
  private isExternalStorageDevice(): boolean {
    return !StringUtil.isEmpty(this.uuid) && this.uuid !== UUID_TYPE.LOCAL;
  }

  private onNavModeChange(): void {
    if (this.userState === UserState.BROWSER) {
      this.getFileUsageHabits();
      this.initTitle();
    } else {
      if (this.navMode === NavigationMode.Split) {
        this.showEntryBottomBarFlag = false;
      }
    }
  }

  private getTitle(title: string | Resource): string {
    if (ObjectUtil.isNullOrUndefined(title)) {
      return '';
    }
    if (typeof title === 'string') {
      return title;
    }
    return getResourceString(title);
  }

  /**
   * 激活高亮。
   *
   * @returns
   */
  private enableHighlight() {
    HiLog.info(TAG, 'enableHighlight');
    this.needHighlight = true;
  }

  /**
   * 取消高亮。
   *
   * @returns
   */
  private disableHighlight() {
    HiLog.info(TAG, 'disableHighlight');
    this.needHighlight = false;
  }

  // 无障碍模式下进入下一层级主动获焦
  private accessibilityFocusNextFloor(): void {
    let timer = setTimeout(() => {
      if (this.fileSource.totalCount()) {
        AccessibilityManager.getInstance().sendCustomIdFocusForAccessibility((this.startModeOptions.pickerFlag ?
          CompId.FILE_ITEM_PICKER : CompId.FILE_ITEM) + 0);
      } else {
        AccessibilityManager.getInstance().sendCustomIdFocusForAccessibility(this.startModeOptions.pickerFlag ?
          CompId.NO_CONTENT_PICKER : CompId.NO_CONTENT);
      }
      clearTimeout(timer);
    }, ACCESSIBILITY_DELAY);
  }

  private pickerTargetUriIsFile() {
    if (!this.filePickerViewFlag || StringUtil.isEmpty(this.startModeOptions.defaultFilePathUri)) {
      return false;
    }
    return FsUtil.isFile(FileUtil.getPathFromUri(this.startModeOptions.defaultFilePathUri));
  }

  private openSuffixDialog(): void {
    this.isShowSuffixFilter = true;
  }

  /**
   * 上报进入相册的UE事件
   * @param fileItem 文件信息
   * @param enterType 进入方式
   */
  private reportEnterAlbumUE(fileItem: FileInfo, enterType: DFX.EnterAlbumType): void {
    if (fileItem.albumType === -1 || fileItem.albumSubType === -1) {
      HiLog.warn(TAG, `reportEnterAlbumUE fail, albumType:${fileItem.albumType},albumSubType:${fileItem.albumSubType}`);
      return;
    }
    let albumType: DFX.AlbumType = EnumTransferUtil.transferToAlbumType(fileItem.albumType);
    let subAlbumType: DFX.SubAlbumType = EnumTransferUtil.transferToSubAlbumType(fileItem.albumSubType);
    UEUtil.reportEnterAlbum(albumType, subAlbumType, enterType);
  }

  private needInitGalleryAuthState(): boolean {
    return false;
  }

  /**
   * 初始化来源-图库的认证状态
   */
  private initGalleryAuthState(): void {
    if (this.needInitGalleryAuthState()) {
      this.showMaskLayer = true;
      this.showPickerMaskLayer = true;
      this.isPhotosPage = true;
    }
  }

  /**
   * 认证失败回退场景处理
   */
  private onBackPassForPhotosLock(): void {
    if (this.currentFolderUri === VirtualUri.GALLERY || this.currentFolderUri.startsWith(VirtualUri.GALLERY_URI)) {
      HiLog.info(TAG, 'onBackPassForPhotosLock clear');
      this.pageInfos.clear(false); // 转场动画，会看到图库内容
    }
  }

  /**
   * 认证成功处理
   */
  private onAuthPhotosSuccess(): void {
    HiLog.info(TAG, 'onAuthPhotosSuccess');
    this.showMaskLayer = false;
  }

  /**
   * 添加新建文件夹到数据源和当前页面
   */
  private async addNewFolder(newFolderName: string): Promise<void> {
    if (!newFolderName) {
      HiLog.warn(TAG, 'newFolderName is empty');
      return;
    }
    const currentUri: string = this.getCurrentDirUri();
    const queryParam = this.getQueryParam(currentUri);
    queryParam.showHiddenItem = this.showHiddenItem;
    const path: string = FileUtil.getPathWithFileSplit(FileUtil.getPathFromUri(currentUri));
    const folderPath: string = path + newFolderName;
    let fileInfo: FileInfo;
    if (this.currentFolderUri === VirtualUri.GALLERY) {
      fileInfo = await PhotoAccessUtil.getNewUserAlbumByName(queryParam, newFolderName);
    } else {
      fileInfo = FilesQueryUtil.getFileDataByPathWidthFs(folderPath, newFolderName, queryParam);
    }
    if (fileInfo.fileName !== newFolderName) {
      HiLog.warnPrivate(TAG, 'fileName not equal with newFolderName',
        `fileName:${fileInfo.fileName}, newFolderName:${newFolderName}`);
      return;
    }
    // 加入数据源
    this.fileSource.addData(this.fileSource.totalCount(), fileInfo);
    // 重新排序
    this.onSelectOrderAccept();
  }

  /**
   * 获取当前是否为纯图库内容界面
   */
  private getPhotosPage(): void {
    if (!this.currentFolderUri.startsWith(VirtualUri.GALLERY_URI) && this.currentFolderUri !== VirtualUri.GALLERY) {
      this.noGalleryPageProcess();
    } else {
      this.isPhotosPage = true;
    }
  }

  private noGalleryPageProcess(): void {
    this.isPhotosPage = false;
    this.showPickerMaskLayer = false;
  }

  private isArchiveOrInArchive() {
    return this.direList && this.direList.length > 0 &&
    FileUtil.isArchiveByUri(this.direList[this.direList.length - 1].uri)
  }

  private onMenuActionCallback(menuInfo: MenuInfo): void {
    if (ObjectUtil.isNullOrUndefined(menuInfo)) {
      HiLog.error(TAG, 'undefined menu info');
      return;
    }
    HiLog.info(TAG, `onMenuActionCallback ${menuInfo.menuName}`);
    switch (menuInfo.menuName) {
      case MenuItemName.SET_RINGTONE:
        this.backCallback(false);
        break;
      default:
        break;
    }
  }

  private getFromPage(): string {
    return Constant.FROM_TYPE.MY_PHONE;
  }

  queryStateEndHandle(): void {
    if (this.isPersistPermission && this.isQueryStateEnd) {
      HiLog.info(TAG, 'isPersistPermission, isQueryStateEnd');
      this.listScrollShow = true;
      clearTimeout(this.timeoutId);
      this.isQueryEnd = true;
      this.setShowLoading(false);
    }
  }

  /**
   * 重置文件夹操作类型
   */
  private resetFolderOperateType(): void {
    this.folderOperateType = FolderOperationType.NONE;
  }
}

/**
 * 在UI线程执行函数
 * @param callback
 */
function runOnUIThread(callback: () => void): void {
  setTimeout(() => {
    callback();
  }, 0);
}