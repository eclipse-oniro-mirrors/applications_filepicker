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
  AbilityName,
  AbilityOrRouterParams,
  AccessibilityManager,
  AddressData,
  ArrayUtil,
  AuditLogUtils,
  BOTTOM_BAR_MAP,
  BottomCallParams,
  Constant,
  DEFAULT_SORT_ORDER,
  DeleteRestoreConst,
  DeleteRestoreResultParam,
  DFX,
  DisplayUtil,
  DragManager,
  EnumTransferUtil,
  EventBus,
  FileDataSource,
  FileInfo,
  FileSortParamUtil,
  FileUtil,
  GlobalHolder,
  GlobalKey,
  GroupAndSortParam,
  HiLog,
  HiSysEventUtil,
  HiTraceConst,
  LocalStorageConst,
  ObjectUtil,
  PAGE_ROUTE_CONST,
  QueryFileParam,
  QueryTrashTaskPhone,
  ResourceUtil,
  SortOrder,
  StorageDeviceManager,
  TaskManager,
  TaskStatus,
  ThreadCommonUtil,
  TopMenuDivider,
  TraceUtils,
  TrashFileUtil,
  TrashUtil,
  UEUtil,
  UiUtil,
  UsageHabitsPreferenceUtil,
  UserState,
  ViewMode,
  SortUtil,
  UdmfUtils,
  VirtualUri,
  FsUtil,
  UsageHabits,
  UsageHabitsPreferenceConst,
  StartModeOptions,
  FilePickerUtil,
  ToolBarStyle,
  StandardAnimation,
  CommonUtil,
  CompId,
  MenuItemName,
  AccessibilityStorageKey,
} from '@ohos/common';
import { FileListView, OutsideScreenFileListView } from '@ohos/fileView';
import { MENU_ICONS, MENU_NAME, TitleBarComp, TitleMenuItem, TopMenuItem } from '@ohos/titleBar';
import curves from '@ohos.curves';
import lazy { BottomBar, BottomOptions } from '@ohos/bottomBar';
import { Loading } from '../../component/common/Loading';
import { FileListViewLayout } from '@ohos/fileView';
import { UIExtensionContentSession } from '@kit.AbilityKit';
import { CopyCutManager } from '../../../base/manager/CopyCutManager';
import { MenuActionHandler } from '../../../base/manager/MenuActionHandler';

const TAG = 'RecentDelete';

@Component
export struct RecentDelete {
  @LocalStorageProp(LocalStorageConst.STATUS_BAR_HEIGHT) statusBarHeight: number = 0;
  @LocalStorageProp(LocalStorageConst.BOTTOM_NAV_BAR_HEIGHT) bottomNavBarHeight: number = 0;
  @Provide viewMode: string = ViewMode.LIST;
  @State isShowLoading: boolean = false;
  @State fileSource: FileDataSource = new FileDataSource();
  @State selectFilesList: FileInfo[] = [];
  @State selectAll: boolean = false;
  @State @Watch('onUserStateChange') userState: UserState = UserState.BROWSER;
  // 标题栏左侧icon
  @State leftIcon: TitleMenuItem | null = null;
  @Consume('navMode') @Watch('onNavModeChange') navMode: NavigationMode;
  // 标题栏右侧icons
  @State rightIcons: Array<TitleMenuItem> = [];
  @State showHiddenItem: boolean = true;
  // 右上角菜单
  @State topMenu: Array<TopMenuItem> = [];
  @State checkedNum: number = 0;
  @State @Watch('checkedNumChange') allCheckedNum: number = 0;
  @StorageLink('recentDeleteRefresh') @Watch('dealRefreshWhenShow') myPhoneRefresh: boolean = false;
  @State isQueryEnd: boolean = false;
  @State @Watch('optionChange') selectItem: string = '';
  @Provide isListView: boolean = false;
  @Provide @Watch('onSelectOrderAccept') order: string = SortOrder.TIME; // 排序规则
  @StorageLink(Constant.SORT_CHANGE) @Watch('onSelectOrderAccept') sortChange: boolean = false;
  @Provide @Watch('onSelectOrderAccept') isDesc: boolean = true; // 是否倒序
  @Consume('pageInfos') pageInfos: NavPathStack;
  @Consume('currentNavItem') currentNavItem: string;
  @Consume showEntryBottomBarFlag: boolean;
  @Consume isVerticalTabBar: boolean;
  @State longPressChangeType: string = Constant.OPERATION_TYPE.PLAY;
  @State pickerCheckArr: string[] = [];
  private startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();
  // 搜索转场动效
  @State isAnimationEnter: boolean = false;
  @StorageLink('isRightShowMotion') isRightShowMotion: boolean = false;
  @StorageLink('isAnimationShow') isAnimationShow: boolean = false;
  private accessibilityManager: AccessibilityManager = AccessibilityManager.getInstance();
  private deleteBind: Function = (): void => this.deleteChange();
  private initDataBind: Function = (): void => this.initData();
  @State dragDeleteList: FileInfo[] = [];
  @State direList: AddressData[] = [];
  @State listScrollShow: boolean = true;
  @State scrollStartIndex: number = 0;
  @State listYOffset: number = 0;

  private concatData: FileInfo[] = [];
  private isPageShow: boolean = false;
  private queryTask?: QueryTrashTaskPhone;
  private dragDeleteEventBind: Function = (list: FileInfo[]): void => this.dragDeleteEvent(list);
  private removeDeletedOrRestoredFileFromListBind: Function = (deletedRestoredFileUriList: string[],
    operationType: string) => this.removeDeletedOrRestoredFileFromList(deletedRestoredFileUriList, operationType)
  private timer: number = -1;
  private menuActionHandler?: MenuActionHandler = undefined;
  @State bottomOption: BottomOptions[] = [
    new BottomOptions(Constant.OPERATION_TYPE.RESTORE,
      BOTTOM_BAR_MAP.restore,
      MENU_ICONS.restore,
      false,
      true
    ),
    new BottomOptions(
      Constant.OPERATION_TYPE.DELETE,
      BOTTOM_BAR_MAP.delete,
      MENU_ICONS.delete,
      false,
      true
    ),
  ];

  @State needHighlight: boolean = false;
  @State titleBarTransitionEffect?: TransitionEffect<'asymmetric'> =
    TransitionEffect.asymmetric(this.scrollAppearTransition, this.scrollDisappearTransition);
  // 滚动显示动效
  private scrollAppearTransition?: TransitionEffect = undefined;
  // 滚动消失动效
  private scrollDisappearTransition?: TransitionEffect = undefined;
  @Consume @Watch('onIsOutsideFoldedChange') isOutsideFolded: boolean;
  private isOutsideScreenDevice: boolean = DisplayUtil.isOutsideScreenDevice();
  @Consume @Watch('onIsDownScrollingChange') isDownScrolling: boolean;
  @State isShowTitleBar: boolean = true;  @Provide({ allowOverride: 'operationType' }) operationType: string = '';
  // 布局参数
  @State fileListViewLayout: FileListViewLayout = new FileListViewLayout;
  @StorageLink('trashFileCount') recentDeleteCount: number = 0;
  @State rootYOffset: number = 0;
  @State rootYOffsetIndex: number = 0;
  // 页面内本页组件透明度 用于淡入淡出动效
  @State curPageOpacity: number = 1;
  @State isShowLocateAni: boolean = false;
  @State isClosePage: boolean = false;

  @Consume @Watch('onTabIndexChange') currentTabIndex: number;
  private enterTabIndex: number = 0;

  aboutToAppear() {
    TraceUtils.startTrace(HiTraceConst.RECENT_DELETE_PAGE_ABOUT_TO_APPEAR);
    HiLog.info(TAG, 'RecentDelete aboutToAppear')
    this.enterTabIndex = this.currentTabIndex;
    this.getFileUsageHabits();
    this.initTitle();
    this.initOutsideDeviceParam();
    this.addEventListener();
    this.getTrashFileList(true);
    this.updateTitleBarTransitionEffect();
    TraceUtils.finishTrace(HiTraceConst.RECENT_DELETE_PAGE_ABOUT_TO_APPEAR);
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
      this.titleBarTransitionEffect = TransitionEffect.asymmetric(this.scrollAppearTransition, this.scrollDisappearTransition);
    } else if (this.navMode === NavigationMode.Split) {
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
      this.scrollAppearTransition = TransitionEffect.translate({y: -100}).animation({
        curve: Curve.EaseIn, duration: 400 });
      this.scrollDisappearTransition = TransitionEffect.translate({y: -100}).animation({
        curve: Curve.EaseIn, duration: 400 });
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
    }
  }

  onPageShow() {
    HiLog.info(TAG, 'RecentDelete onPageShow');
    this.isPageShow = true;
    this.isAnimationShow = this.navMode === NavigationMode.Split;
    if (this.userState !== UserState.BROWSER) {
      return;
    }
    this.getTrashFileList(true);
    this.getFileUsageHabits();
  }

  build() {
    NavDestination() {
      Stack() {
        this.buildRecentDeleteMainContent();
      }
    }
    .hideTitleBar(true)
    .onBackPressed(() => this.onBackPress())
    .onShown(() => this.onPageShow())
    .onHidden(() => {
      this.onPageHide()
    })
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onDrop((event: DragEvent, extraParams: string) => {
      HiLog.info(TAG, 'onDrop')
      if (DragManager.getInstance().isInternalDrag) {
        this.onDropCallback(event, extraParams);
      }
    })
    .onDragMove((event?: DragEvent) => {
      // 最近删除页面不显示拖拽
      if (event) {
        event.setResult(DragResult.DROP_DISABLED);
      }
    })
    .allowDrop(Constant.ALLOW_DROP.ALL_FILE)
    .padding({
      top: this.statusBarHeight,
    })
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

  onPageHide() {
    HiLog.info(TAG, 'RecentDelete onPageHide')
    this.recordOffset();
    this.isPageShow = false;
    this.isAnimationShow = false;
  }

  onBackPress() {
    if (this.userState !== UserState.BROWSER) {
      this.initData();
      return true;
    }
    if (this.navMode === NavigationMode.Split) {
      return false;
    }
    this.isClosePage = true;
    this.pageInfos.pop();
    return true;
  }

  aboutToDisappear() {
    this.queryTask?.cancelTask();
    this.queryTask = undefined;
    if (this.navMode === NavigationMode.Split) {
      this.showEntryBottomBarFlag = true;
    }

    this.removeEventListener();
    if (this.navMode === NavigationMode.Stack) {
      this.currentNavItem = '';
    }
  }

  @Builder
  TitleBarComponent() {
    TitleBarComp({
      title: UiUtil.getTitleBarCompTitle($r('app.string.recentlyDeleted'), this.userState, this.checkedNum),
      subTitle: '',
      leftIcon: $leftIcon,
      iconArr: $rightIcons,
      initMenu: (): void => this.initMenu(),
      topMenu: $topMenu,
      userState: this.userState,
      fileCount: this.fileSource.totalCount(),
      isClosePage: this.isClosePage
    })
      .opacity(this.isAnimationEnter ? 1 : 0)
      .onAppear(() => {
        if ((DisplayUtil.getFoldStatus() === DisplayUtil.FOLD_STATUS_EXPANDED) && this.isRightShowMotion) {
          animateTo({
            curve: curves.cubicBezierCurve(0.4, 0, 0.2, 1),
          }, () => {
            this.isAnimationEnter = true;
            this.isRightShowMotion = false;
          })
        }
        this.isAnimationEnter = true;
      })
      .transition(this.titleBarTransitionEffect)
      .visibility(this.isShowTitleBar ? Visibility.Visible : Visibility.None)
  }

  @Builder
  buildRecentDeleteMainContent() {
    Column() {
      // 头部导航
      this.TitleBarComponent()
      Stack({ alignContent: Alignment.Bottom }) {
        // 文件列表
        this.FileListViewContent();
        Loading({ isLoading: this.isShowLoading })
          .visibility(this.isShowLoading ? Visibility.Visible : Visibility.None)
          .size({ width: '100%', height: '100%' })
        // 底部菜单栏
        BottomBar({
          bottomOptions: $bottomOption,
          selectItem: $selectItem,
          checkedNum: this.checkedNum,
          selectFilesList: $selectFilesList,
          longPressChangeType: this.longPressChangeType,
          dialogCallback: (event: BottomCallParams): Promise<void> => this.dialogCallback(event),
          pageName: PAGE_ROUTE_CONST.RECENT_DELETE,
          isRecentDeletePage: true,
          isShowBottomBar: this.userState !== UserState.BROWSER
        })
      }
      .layoutWeight(1)
    }
    .opacity(this.curPageOpacity)
  }

  @Builder
  FileListViewContent() {
    if (this.isOutsideFolded) {
      OutsideScreenFileListView({
        layout: this.fileListViewLayout,
        fileListSource: $fileSource,
        checkedNum: $checkedNum,
        allCheckedNum: this.allCheckedNum,
        userState: $userState,
        isSelectAll: this.selectAll,
        hasTotalCapacity: true,
        isQueryEnd: this.isQueryEnd,
        onItemClick: (item: FileInfo): void => this.showOpenConfirmOpenFileDialog(item),
        direList: this.direList,
        listScrollShow: this.listScrollShow,
        listYOffset: this.listYOffset,
        scrollStartIndex: this.scrollStartIndex,
        isShowFileSource: true,
        onDropCallback: this.onDropCallback,
        pageName: PAGE_ROUTE_CONST.RECENT_DELETE,
        toOperateFileList: this.selectFilesList,
        swipeDeleteDialogCallback: (event: BottomCallParams): Promise<void> => this.dialogCallback(event),
        pickerCheckArr: this.pickerCheckArr,
        needHighlight: this.needHighlight,
        showHiddenItem: this.showHiddenItem,
        isShowLocateAni: this.isShowLocateAni
      })
    } else {
      FileListView({
        layout : this.fileListViewLayout,
        fileListSource: $fileSource,
        checkedNum: $checkedNum,
        allCheckedNum: this.allCheckedNum,
        userState: $userState,
        isSelectAll: this.selectAll,
        hasTotalCapacity: true,
        isQueryEnd: this.isQueryEnd,
        onItemClick: (item: FileInfo): void => this.showOpenConfirmOpenFileDialog(item),
        direList: this.direList,
        listScrollShow: this.listScrollShow,
        listYOffset: this.listYOffset,
        scrollStartIndex: this.scrollStartIndex,
        isShowFileSource: true,
        onDropCallback: this.onDropCallback,
        pageName: PAGE_ROUTE_CONST.RECENT_DELETE,
        toOperateFileList: this.selectFilesList,
        swipeDeleteDialogCallback: (event: BottomCallParams): Promise<void> => this.dialogCallback(event),
        pickerCheckArr: this.pickerCheckArr,
        needHighlight: this.needHighlight,
        showHiddenItem: this.showHiddenItem,
        onDragJumpCallback: async (event: DragEvent, extraParams?: string): Promise<void> =>
          CopyCutManager.getInstance().onDragJumpCallback(event, extraParams),
        rootYOffset: this.rootYOffset,
        rootYOffsetIndex: this.scrollStartIndex,
        persistentViewModeHabit: (viewMode: string) => this.persistentViewModeHabit(viewMode),
        isShowLocateAni: this.isShowLocateAni
      })
    }
  }

  private dealRefreshWhenShow() {
    if (!this.isPageShow) {
      return;
    }
    this.getFileUsageHabits();
    this.getTrashFileList();
  }

  private multipleChoiceCallBack(): void {
    // 数据查询时无法进入多选
    if (this.isQueryEnd === false) {
      return;
    }
    this.userState = UserState.MULTI_START;
    this.rightIcons = [];
    UEUtil.reportMultiSelect(DFX.OperateSource.MULTI_SELECT_BUTTON, DFX.PageName.RECENT_DELETE);
    this.checkedNumChange();
  }

  private deleteChange(): void {
    setTimeout(() => {
      this.longPressChangeType = Constant.OPERATION_TYPE.DELETE;
    }, 100)
  }

  private onUserStateChange() {
    if (this.navMode === NavigationMode.Split) {
      if (this.userState !== UserState.BROWSER) {
        this.showEntryBottomBarFlag = false;
      } else {
        this.showEntryBottomBarFlag = true;
      }
    }

    if (this.userState === UserState.MULTI_START) {
      if (this.leftIcon) {
        this.leftIcon.icon = $r('sys.symbol.xmark');
        this.leftIcon.action = (): void => this.backCallback();
        this.leftIcon.isShown = true;
        this.leftIcon.dragEnable = false;
        this.rightIcons = [this.buildMultipleChoiceButton()];
      }
      return;
    }
    if (this.userState !== UserState.BROWSER) {
      return;
    }
    this.getFileUsageHabits();
    this.initTitle();
    this.selectAll = false;
    this.longPressChangeType = '';
  }

  private checkedNumChange(): void {
    this.updateBottom();
    this.selectAll = this.checkedNum === this.fileSource.getCanChooseCount();
    this.selectItem = '';
    this.rightIcons = [this.buildMultipleChoiceButton()];
  }

  private updateBottom(): void {
    this.selectFilesList = this.fileSource.getSelectedFileList();
    let tempBottomOption = this.bottomOption;
    this.bottomOption = [];
    if (this.checkedNum === 0) {
      tempBottomOption.forEach(item => {
        item.disabled = true;
        item.display = true;
        this.bottomOption.push(item);
      })
      return;
    }
    tempBottomOption.forEach(item => {
      item.disabled = false;
      item.display = this.checkedNum <= 1 || item.type !== Constant.OPERATION_TYPE.DETAIL;
      this.bottomOption.push(item);
    });
  }

  private setShowLoading(isShow: boolean): void {
    this.isShowLoading = isShow;
  }

  private getTrashFileList(isShowLoading: boolean = false): void {
    HiLog.info(TAG, `getTrashFileList queryFilesStart isShowLoading = ${isShowLoading}  this.userState is ${this.userState}`);
    if (this.userState !== UserState.BROWSER) {
      return;
    }
    if (this.queryTask) {
      HiLog.info(TAG, 'checkQueryTaskState queryTaskObj state: ' + this.queryTask.isRunning);
      if (this.queryTask.isRunning && (!this.queryTask.isCancel)) {
        return;
      }
      this.queryTask.cancelTask();
      this.queryTask = undefined;
    }
    if (isShowLoading || this.isShowLoading) {
      clearTimeout(this.timer);
      this.timer = setTimeout(() => {
        this.setShowLoading(true);
      }, 200);
      this.isQueryEnd = false;
    } else {
      clearTimeout(this.timer);
      this.setShowLoading(false);
      this.isQueryEnd = true;
    }
    const param: QueryFileParam = new QueryFileParam();
    param.orderBy = this.order;
    param.isDesc = this.isDesc;
    param.context = getContext(this);
    this.queryTask = new QueryTrashTaskPhone(
      (result: FileInfo[], status: TaskStatus): void => this.receiveFileData(result, status), param);
    TaskManager.getInstance().executeTask<void>(this.queryTask)
  }

  private checkTrashDataChange(newFiles: FileInfo[], oldFiles: FileInfo[]): boolean {
    if ((!oldFiles) || ObjectUtil.isNullOrUndefined(newFiles) || newFiles.length !== oldFiles.length) {
      return true;
    }
    const len = newFiles.length;
    for (let i = 0; i < len; i++) {
      if ((newFiles[i].uri !== oldFiles[i].uri) ||
        (newFiles[i].size !== oldFiles[i].size) ||
        newFiles[i].mtime !== oldFiles[i].mtime) {
        return true;
      }
    }
    return false;
  }

  private receiveFileData(result: FileInfo[], status: TaskStatus): void {
    HiLog.info(TAG, 'getListTrashFiles queryFilesEnd: ' + status + ' ' + result.length);
    if (this.queryTask && (status !== TaskStatus.RUNNING)) {
      this.queryTask.isRunning = false;
    }
    switch (status) {
      case TaskStatus.RUNNING:
        this.concatData = this.concatData.concat(result);
        break;
      case TaskStatus.END:
        this.queryTaskEndHandle(result);
        break;
      default:
        break;
    }
  }

  private async queryTaskEndHandle(result: FileInfo[]): Promise<void> {
    this.queryTask = undefined;
    this.concatData = this.concatData.concat(result && result.length > 0 ? result : []);
    this.deleteDeprecatedFiles();
    let fileList: FileInfo[] = [...this.concatData];
    this.concatData = [];
    AppStorage.setOrCreate<number>(TrashFileUtil.TRASH_FILE_COUNT, fileList.length);
    const storageDeviceList = await StorageDeviceManager.getInstance().getStorageDeviceList();
    const translatedFileList = TrashFileUtil.translateToFileData(fileList, storageDeviceList);
    if (this.userState === UserState.MULTI_START) {
      this.taskEndAction();
      return;
    }
    if (!this.checkTrashDataChange(translatedFileList, this.fileSource.getDataArray())) {
      HiLog.info(TAG, 'TrashFileList has not changed');
      this.taskEndAction();
      return;
    }
    this.fileSource.setData(translatedFileList);
    this.taskEndAction();
    HiLog.info(TAG, `queryTrashFilesEnd: length = ${translatedFileList.length}`);
  }

  private taskEndAction() {
    this.isQueryEnd = true;
    clearTimeout(this.timer);
    this.setShowLoading(false);
  }

  private deleteDeprecatedFiles(): void {
    let deleteFileArray: FileInfo[] = [];
    let reservedFileArray: FileInfo[] = [];
    if (this.concatData.length < 1) {
      HiLog.error(TAG, 'deleteDeprecatedFiles file count is zero');
      return;
    }
    let currentTime: number = Date.now();
    this.concatData.forEach((item: FileInfo) => {
      if (currentTime - item.deleteTime >= Constant.DEFAULT_SAVE_TIME) {
        deleteFileArray.push(item);
      } else {
        reservedFileArray.push(item);
      }
    });
    HiLog.error(TAG, `delete files: ${deleteFileArray.length} current files: ${reservedFileArray.length}`);
    this.concatData = [...reservedFileArray];
    if (deleteFileArray.length < 1) {
      HiLog.warn(TAG, 'deleteDeprecatedFiles delete file array length is zero');
      return;
    }
    let list: FileInfo[] = [];
    for (let i = 0; i < deleteFileArray.length; i++) {
      let data = deleteFileArray[i];
      let dataTmp = new FileInfo();
      dataTmp.fileName = data.fileName;
      dataTmp.uri = data.uri;
      dataTmp.thumbnailType = data.thumbnailType;
      dataTmp.isFolder = data.isFolder;
      dataTmp.storageDeviceUid = data.storageDeviceUid;
      dataTmp.srcPath = data.srcPath;
      dataTmp.isGallery = data.isGallery;
      dataTmp.albumType = data.albumType;
      dataTmp.albumSubType = data.albumSubType;
      list.push(dataTmp);
    }
    let workerName: string = ThreadCommonUtil.getWorkerName(Constant.OPERATION_TYPE.DELETE);
    TrashUtil.startHardDeleteTask(list, workerName,
      DeleteRestoreConst.TaskType.DELETE_FILE_FROM_TRASH,
      (result: DeleteRestoreResultParam) => this.resolveDeleteTaskResult(result), []);
  }

  private resolveDeleteTaskResult(result: DeleteRestoreResultParam): void {
    if(ObjectUtil.isNullOrUndefined(result) || ObjectUtil.isNullOrUndefined(result.successUris)) {
      HiLog.warn(TAG, `DeleteRestoreResultParam invalid`);
      return;
    }
    for (const uri of result.successUris) {
      AuditLogUtils.getInstance()
        .writeAudit(uri, FileUtil.getFileNameFromUri(uri), 'clearRecentDeleteDeprecatedFile', Date.now());
    }
  }

  public persistentViewModeHabit(viewMode: string): void {
    const pageName: string = UsageHabitsPreferenceConst.RECENT_DELETE;
    const isPicker: boolean = this.startModeOptions.pickerFlag;
    UsageHabitsPreferenceUtil.updateUsageHabit(pageName, isPicker, UsageHabitsPreferenceConst.VIEW_MODE, viewMode);
  }

  private getFileUsageHabits() {
    const usageHabits: UsageHabits = UsageHabitsPreferenceUtil.getUsageHabitsByPageName(
      UsageHabitsPreferenceConst.RECENT_DELETE, this.startModeOptions.pickerFlag);
    this.viewMode = usageHabits.viewMode;
    // 外屏不需要读取展示格式的持久化数据
    if (!this.isOutsideFolded) {
      this.isListView = this.viewMode === ViewMode.LIST;
    }
    this.order = usageHabits.orderType;
    this.isDesc = usageHabits.isDesc;
  }

  private menuCanClick(operationType: string): boolean {
    if (!operationType) {
      return false;
    }
    return operationType === Constant.OPERATION_TYPE.SELECT_ALL ||
      operationType === Constant.OPERATION_TYPE.DESELECT_ALL || !!this.checkedNum;
  }

  // 文件操作处理
  private async optionChange(): Promise<void> {
    if (!this.menuCanClick(this.selectItem)) {
      return;
    }
    switch (this.selectItem) {
      case Constant.OPERATION_TYPE.RESTORE:
        UEUtil.reportRestoreFile(DFX.OperateSource.BOTTOM_MENU,this.selectFilesList.length);
        this.deleteOrRestoreFiles(this.selectFilesList, Constant.OPERATION_TYPE.RESTORE)
        return;
      default:
        return;
    }
  }

  private async onDropCallback(event: DragEvent, extraParams: string) {
    HiLog.info(TAG, 'drop callback');
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
    EventBus.emit(Constant.EVENTS.DRAG_DROP, dropFileList);
  }

  /**
   * 从文件列表中移除已删除或被还原的文件
   */
  private removeDeletedOrRestoredFileFromList(deletedRestoredFileUriList: string[], operationType: string): void {
    if (this.userState === UserState.MULTI_START) {
      this.backCallback();
    }
    if (ArrayUtil.isEmpty(deletedRestoredFileUriList)) {
      return;
    }
    if (deletedRestoredFileUriList.length === this.fileSource.totalCount()) {
      this.fileSource.batchDeleteData(deletedRestoredFileUriList);
      return;
    }
    this.isShowLocateAni = true;
    this.getUIContext()?.animateTo({ duration: 350,
      curve: Curve.Smooth,
      onFinish: () => {
        this.isShowLocateAni = false;
      }}, () => {
      this.fileSource.batchDeleteData(deletedRestoredFileUriList);
    })
  }

  /**
   * 硬删除文件
   * @param uriList 文件uri列表
   */
  private deleteOrRestoreFiles(fileList: FileInfo[], operationType: string, isDropDelete: boolean = false): void {
    EventBus.emit(Constant.EVENTS.START_DELETE_RESTORE_FILE_TASK, fileList, operationType, !isDropDelete)
  }

  private async dialogCallback(e: BottomCallParams): Promise<void> {
    const type = e.item.type;
    if (type === Constant.OPERATION_TYPE.DELETE || type === Constant.OPERATION_TYPE.HARD_DELETE) {
      this.deleteOrRestoreFiles(this.selectFilesList, Constant.OPERATION_TYPE.HARD_DELETE);
    }
  }

  private backCallback(): void {
    if (this.userState === UserState.BROWSER) {
      this.isClosePage = true;
      this.pageInfos.pop();
      return;
    }
    // 退出多选态不需要播报标题变化，并重新聚焦播报
    AccessibilityManager.getInstance().notAnnouncedTitleAndFocusComponent(CompId.LEFT_ICON);
    this.initData();
  }

  private addEventListener(): void {
    EventBus.on(Constant.EVENTS.DRAG_DROP, this.dragDeleteEventBind);
    EventBus.on(Constant.EVENTS.REMOVE_DELETED_RESTORED_FILE_FROM_LIST, this.removeDeletedOrRestoredFileFromListBind);
    EventBus.on(Constant.EVENTS.LONG_PRESS_DELETE, this.deleteBind, true);
    EventBus.on(Constant.EVENTS.EXIT_MULTI_STATE, this.initDataBind, true);
    if (!this.menuActionHandler) {
      this.menuActionHandler = new MenuActionHandler(PAGE_ROUTE_CONST.RECENT_DELETE);
      this.menuActionHandler.registerMenuEvent([MenuItemName.RESTORE]);
    } else {
      this.menuActionHandler.againRegisterMenuEvent();
    }
  }

  private dragDeleteEvent(list: FileInfo[]) {
    if (ArrayUtil.isEmpty(list)) {
      return;
    }
    this.dragDeleteList = list;
  }

  private removeEventListener(): void {
    EventBus.off(Constant.EVENTS.DRAG_DROP, this.dragDeleteEventBind);
    EventBus.off(Constant.EVENTS.REMOVE_DELETED_RESTORED_FILE_FROM_LIST, this.removeDeletedOrRestoredFileFromListBind);
    EventBus.off(Constant.EVENTS.LONG_PRESS_DELETE, this.deleteBind);
    EventBus.off(Constant.EVENTS.EXIT_MULTI_STATE, this.initDataBind);
    if (this.menuActionHandler) {
      this.menuActionHandler.unregisterMenuEvent();
    }
  }

  private initTitle() {
    if (this.leftIcon == null) {
      this.leftIcon = new TitleMenuItem(MENU_ICONS.back, MENU_NAME.back, (): void => this.backCallback());
      this.leftIcon.isShown = this.navMode !== NavigationMode.Split;
      this.leftIcon.dragEnable = true;
    } else {
      this.leftIcon.icon = MENU_ICONS.back;
      this.leftIcon.name = MENU_NAME.back;
      this.leftIcon.action = (): void => this.backCallback();
      this.leftIcon.isShown = this.navMode !== NavigationMode.Split;
      this.leftIcon.dragEnable = true;
    }
    this.rightIcons = this.buildRightIcons();
  }

  private buildRightIcons(): TitleMenuItem[] {
    let newRightIcons: TitleMenuItem[] = [];
    newRightIcons.push(this.buildMultipleChoiceButton())
    return newRightIcons;
  }

  private buildMultipleChoiceButton(): TitleMenuItem {
    // 未进入多选 显示多选按钮
    if (this.userState !== UserState.MULTI_START) {
      return new TitleMenuItem($r('app.string.multiple_choices'), MENU_NAME.multipleChoice, () => {
        AppStorage.setOrCreate<number>(AccessibilityStorageKey.MULTIPLE_CHOICE_KEY, 1);
        AccessibilityManager.getInstance().sendCustomIdFocusForAccessibility(CompId.TOP_TITLE);
        this.multipleChoiceCallBack();
      }, this.fileSource.totalCount() !== 0, false, true, false, true);
    }
    // 已在多选时 判断全选状态
    if (this.selectAll) {
      // 取消全选
      return new TitleMenuItem($r('app.string.cancel_all_selection'), MENU_NAME.cancelSelectAll, () => {
        this.onSelectAllIconClick();
        AccessibilityManager.getInstance()
          .announcedStringAndFocusComponent(ResourceUtil.getStringByResource($r('app.string.already_deselect_all')),
            CompId.TOP_BUTTON);
        UEUtil.reportSelectOrDeselectAll(DFX.PageName.RECENT_DELETE, DFX.SelectAllType.DESELECT_ALL);
      }, true, false, true, false, true);
    } else {
      // 全选
      return new TitleMenuItem($r('app.string.select_all'), MENU_NAME.selectAll, () => {
        this.onAllIconClick();
        AccessibilityManager.getInstance()
          .announcedStringAndFocusComponent(ResourceUtil.getStringByResource($r('app.string.already_select_all')),
            CompId.TOP_BUTTON);
        UEUtil.reportSelectOrDeselectAll(DFX.PageName.RECENT_DELETE, DFX.SelectAllType.SELECT_ALL);
      }, true, false, true, false, true);
    }
  }

  private initData(): void {
    this.selectFilesList = [];
    this.selectAll = false;
    this.checkedNum = 0;
    this.userState = UserState.BROWSER;
    this.selectItem = '';
    // 全部数据列表的isChecked置为false
    this.fileSource.selectAll(false);
  }

  private onSelectAllIconClick(): void {
    this.fileSource.selectAll(false);
    this.selectFilesList = [];
    this.checkedNum = 0;
    this.selectAll = false;
    this.accessibilityManager.sendCustomIdFocusForAccessibility(Constant.OPERATION_TYPE.SELECT_ALL);
  }

  private onAllIconClick(): void {
    this.fileSource.selectAll(true);
    this.checkedNum = this.fileSource.getCanChooseCount();
    this.accessibilityManager.sendCustomIdFocusForAccessibility(Constant.OPERATION_TYPE.DESELECT_ALL);
  }

  private onSelectOrderAccept(): void {
    let groupAndSortParam: GroupAndSortParam = FileSortParamUtil.initPhoneGroupAndSortParam(this.order,
      this.isDesc, false);
    UsageHabitsPreferenceUtil.updateUsageHabit(UsageHabitsPreferenceConst.RECENT_DELETE,
      this.startModeOptions.pickerFlag,
      UsageHabitsPreferenceConst.ORDER_TYPE, this.order);
    UsageHabitsPreferenceUtil.updateUsageHabit(UsageHabitsPreferenceConst.RECENT_DELETE,
      this.startModeOptions.pickerFlag,
      UsageHabitsPreferenceConst.IS_DESC, this.isDesc);
    const fileInfoListNew =
      SortUtil.sortDataByOrder(this.fileSource.getDataArray(), this.order, this.isDesc, false, true);
    this.fileSource.setData(fileInfoListNew);
    HiSysEventUtil.reportFileGroupAndSortParamChange(groupAndSortParam,
      FileSortParamUtil.initPhoneGroupAndSortParam(this.order, this.isDesc, false), AbilityName.FILE_MANAGER);
    UEUtil.reportSortRuleChange(EnumTransferUtil.transferToSortType(this.order), !this.isDesc,
      DFX.PageName.RECENT_DELETE, false);
  }

  private initMenu(): void {
    this.topMenu = [];
    this.topMenu.push(new TopMenuItem(MENU_ICONS.multipleChoice, () => this.multipleChoiceCallBack(),
      MENU_NAME.multipleChoice, SortOrder.ADD, TopMenuDivider.TYPE_ONE));
  }

  private showOpenConfirmOpenFileDialog(item: FileInfo) {
    EventBus.emit(Constant.EVENTS.SHOW_RECENT_DELETED_FILE_DETAIL_DIALOG, item, true)
  }

  private onNavModeChange(): void {
    if (this.userState !== UserState.BROWSER) {
      if (this.navMode === NavigationMode.Split) {
        this.showEntryBottomBarFlag = false;
      }
      return;
    }
    this.getFileUsageHabits();
    this.initTitle();
  }
}