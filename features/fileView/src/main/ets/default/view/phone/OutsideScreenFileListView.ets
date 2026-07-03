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
  AddressData,
  ArrayUtil,
  BottomCallParams,
  CompId,
  Constant,
  DataStatus,
  DeviceConfig,
  DFX,
  DisplayUtil,
  DragManager,
  EnumTransferUtil,
  ERROR_CODE,
  EventBus,
  ExternalStorageUtil,
  FileDataSource,
  FileGroupDataSource,
  FileGroupOrder,
  FileInfo,
  FileOrGroup,
  FileOrGroupInfo,
  FilePickerUtil,
  FileSourceUri,
  FilesQueryUtil,
  FileUtil,
  GlobalHolder,
  GlobalKey,
  GroupDataSource,
  GroupFileInfo,
  HiLog,
  LocalStorageConst,
  LocationType,
  MyPhoneConstant,
  ObjectUtil,
  OffsetRemainParam,
  PAGE_ROUTE_CONST,
  PasteboardDataModel,
  PasteBoardManager,
  PasteBoardUtil,
  PhoneFilePickerUtil,
  ResourceUtil,
  SafePadding,
  ScrollPosition,
  SHOW_MODE,
  SlideActionType,
  SortOrder,
  StartModeOptions,
  StringUtil,
  toast,
  ToolBarStyle,
  UEUtil,
  UiUtil,
  UserState,
  VirtualUri
} from '@ohos/common';
import { NoContent } from './basicComp/NoContent';
import lazy { FileViewComp } from './FileViewComp';
import { PhoneItemViewModel } from '../../viewModel/PhoneItemViewModel';
import { inputMethod } from '@kit.IMEKit';
import { TopMenuItem } from '@ohos/titleBar';
// import { harmonyShare } from '@kit.ShareKit';
import Curves from '@ohos.curves';
import { i18n } from '@kit.LocalizationKit';
import { CustomBottomButtonComp } from './basicComp/CustomButtonComp';
import { FileListViewLayout } from '../../viewModel/FileListViewLayout';
import { BusinessError } from '@kit.BasicServicesKit';
import { REUSE_VIEW_TYPE } from './constant/FileViewConst';
import { AlbumGuideTips } from './AlbumGuideTips';

const TAG = 'OutsideScreenFileListView';

const ROOT_TITLE_OFFSET = 'rootTitleOffset';

const RECENT_LOAD_DAYS: number = 30;
// 列表形式下滚动区域的宽度
const CHECK_BOX_WIDTH: number = 40;
// 热区
const HOT_AREA_LENGTH: number | undefined = DisplayUtil.getHotAreaLength();
// 滚动速度: 贝塞尔曲线
const SLIDE_SELECT_SPEED_CURVE = Curves.cubicBezierCurve(0.33, 0, 0.67, 1);
// 滚动速度: 最大速度
const AUTO_SPEED_MAX: number | undefined = DisplayUtil.getAutoScrollMaxSpeed();

const NOT_ALLOW_DROP_PAGES = [PAGE_ROUTE_CONST.RECENT_DELETE];

const SINGLE_SCREEN_THRESHOLD: number = 600;
const DOUBLE_SCREEN_THRESHOLD: number = 840;

// 来源下默认宫格一行展示的个数
const DEFAULT_GRID_COLUMN_NUM: number = 4;
// 来源下中等宽度宫格一行展示的个数
const MEDIUM_GRID_COLUMN_NUM: number = 6;
// 来源下大屏宫格一行展示的个数
const LARGE_GRID_COLUMN_NUM: number = 8;

// 滑动多选时，滚动条滚动的方向
enum SCROLL_DIR {
  NONE = 'NONE',
  TOP = 'TOP',
  BOTTOM = 'BOTTOM'
}

/**
 * 分组排序时分组字段映射
 */
const GROUP_TYPE_MAP = new Map([
  ['name', SortOrder.NAME],
  ['type', SortOrder.TYPE],
  ['time', SortOrder.TIME],
  ['size', SortOrder.SIZE]
]);

@Component
export struct OutsideScreenFileListView {
  currentTypeCountCallBack: Function = () => {};

  /**
   * 导航栏高度
   */
  @LocalStorageProp(LocalStorageConst.BOTTOM_NAV_BAR_HEIGHT) bottomNavBarHeight: number = 0;
  @ObjectLink layout: FileListViewLayout;
  /**
   * 文件列表
   */
  @Link @Watch('changeFileListSource') fileListSource: FileDataSource;
  @State groupDataSource: GroupDataSource = new GroupDataSource();
  /**
   * 共用的分组组名，根据分组列表顶部索引变化
   */
  @State sharedGroupName: string = '';
  @State fileGroupDataSource: FileGroupDataSource = new FileGroupDataSource();
  // 来源模式原始文件数据源
  private oriSourceFileListSource: FileDataSource = new FileDataSource;
  // 图片和视频数据源
  @State fileGridDataSource: FileDataSource = new FileDataSource;
  @State isGridColumn: boolean = false;
  // 来源混排下，滑动多选时生效的方向
  private gridDirection: PanDirection = PanDirection.All;
  // 来源中是否为纯list布局
  @State isSourceListView: boolean = false;
  // 来源混排中绑定的ListScroller，避免左滑取消删除后，无法恢复至未滑动状态
  private listScrollerMap: Map<string, ListScroller> = new Map();
  // 来源混排里，listItem左滑时回调
  private changeSwipeItem: (uri: string) => void = (uri) => {
  }
  // 来源混排里面左滑后回调是的item的uri
  private scrollerKey: string = '';
  /**
   * 排序规则
   */
  @Consume order: string;
  /**
   * 是否倒序
   */
  @Consume isDesc: boolean;
  @StorageLink('isNetwork') @Watch('onNetworkChange') isNetwork: boolean = true;
  @StorageProp('systemLanguage') @Watch('sysLanguageChange') sysLanguage: string = '';
  /**
   * 监听键盘高度，滑动状态下隐藏键盘
   */
  @StorageProp('keyBoardHeight') keyBoardHeight: number = 0;
  /**
   * 是否需要显示已使用空间及文件个数
   */
  @State hasTotalCapacity: boolean = false;
  /**
   * 操作状态，浏览、多选、移动复制选择目录等
   */
  @Link @Watch('changeUseState') userState: UserState;
  /**
   * 已选择项数
   */
  @Link @Watch('changeCheckNum') checkedNum: number;
  @Link @Watch('checkedNumChange') allCheckedNum: number;
  /**
   * 是否以列表视图进行展示
   */
  @Consume isListView: boolean;
  @Consume viewMode: string;
  @Consume operationType: string;
  /**
   * 宫格视图展示时每行布局的模板
   */
  @Consume('columnTemplate') columnTemplate: string;
  /**
   * 提示正在加载
   */
  @Consume isLoading: boolean;
  // 显示加载页面
  @Prop isShowLoading: boolean = false;
  /**
   * 记录文件的开始下标
   */
  @Link scrollStartIndex: number;
  private scrollEndIndex: number = 0;
  @Consume('isScrollReachEnd') isScrollReachEnd: boolean;
  /**
   * 记录不同文件夹内文件列表滚动的距离，用于返回时保持滚动距离不变
   */
  @Link listYOffset: number;
  /**
   * 面包屑列表
   */
  @Link @Watch('onDireListChange') direList: AddressData[];
  /**
   * 是否已滚动到指定距离结束，用于判断是否需要显示文件列表
   */
  @Link listScrollShow: boolean;
  /**
   * 是否为全选
   */
  @Prop isSelectAll: boolean = false;
  /**
   * 是否查询结束
   */
  @Prop isQueryEnd: boolean = false;
  /**
   * 当前显示的文件列表所在文件夹uri
   */
  @Prop curFolderUri: string = '';
  @Prop @Watch('needShowGroupListView') gridCompactLayout: boolean = false; // 是否宫格视图紧密排列
  /**
   * 是否开启拖拽
   */
  @State enableDrag: boolean = false;
  /**
   * 点击某一个文件的回调
   */
  private onItemClick: Function = () => {
  };
  @Link toOperateFileList: FileInfo[];
  // ListItem左滑删除的回调
  private swipeDeleteDialogCallback: Function = (bottomCallParams: BottomCallParams) => {
  };
  @Prop disableSwipe: boolean = false;
  /**
   * 长按粘贴回调
   */
  private longPressHoldToPaste: Function = () => {
  };
  /**
   * 列表组件的scroller，用于滚动列表到指定位置
   */
  private listScroller: ListScroller = new ListScroller();
  private totalScroller: Scroller = new Scroller();
  /**
   * 宫格组件的scroller，用于滚动宫格到指定位置
   */
  private gridScroller: Scroller = new Scroller();
  /**
   * 是否显示文件来源，如内部存储
   */
  private isShowFileSource: boolean = false;
  /**
   * 是否显示最近访问时间
   */
  private isShowRecentTime: boolean = false;
  /**
   * 滑动删除是否需要进入最近删除选项
   */
  isShowCheckBox: boolean = false;
  /**
   * 页面名字
   */
  @State pageName: string = '';
  @State listPosition: number = ScrollPosition.start;
  @State scrollPosition: number = ScrollPosition.start;
  @State showTitle: boolean = false;
  @State currentYOffset: number = 0;
  @State currentIndex: number = 0;
  @State headAngle: number = 0;
  @State bodyAngle: number = 0;
  @State swipeScale: number = 1;
  // 来源于哪个搜索页
  private geometryId: string = '';
  /**
   * 宫格视图的布局配置
   */
  @State gridLayoutOptions: GridLayoutOptions = {
    regularSize: [1, 1],
    irregularIndexes: undefined
  };
  /**
   * 文件拖拽时的drop回调
   */
  private onDropCallback: Function = () => {
  };
  @State @Watch('isShowPastMenu') longPressFileMenuShow: boolean = false;
  private startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();
  @State longPressColor: ResourceStr = $r('app.color.transparent_color');
  @Link pickerCheckArr: string[] | undefined;
  @Link @Watch('needHighlightChanged') needHighlight: boolean;
  @Provide('showHiddenItemStatus') showHiddenItemStatus: boolean = true;
  @Prop @Watch('showHiddenItemChanged') showHiddenItem: boolean;
  // picker 相关的属性
  @Consume isShowPickerTips: boolean;
  @Prop topMenu: TopMenuItem[];
  // 滑动多选相关的属性
  // 滑动过程中是否将经过的点设为选中状态
  @State setChecked: boolean = false;
  @StorageProp('orientation') @Watch('orientationChange') orientation: string = '';
  // 滑动的初始点位
  @State startIndex: number = -1;
  @State endIndex: number = -1;
  // 每次滑动时，当前选中的点
  @State oldCheckList: boolean[] = [];
  // list滑动过程中的各个点位确定
  @State itemEndMap: Map<number, string> = new Map();
  // 滚动部位显示区域的高度
  @State contentHeight: number = 0;
  @State contentWidth: number = 0;
  @State areaY: number = 0;
  // 列表宽度
  @State listWidth: number = 0;
  // 滑动多选时，当前变更选中状态的item
  @State updateIndex: number = -1;
  private lastUpdateIndex: number = -1;
  @State updateTimer: number = new Date().valueOf();
  // 是否可进行滑动多选
  @State canSlideSelect: boolean = true;
  @State scrollDir: SCROLL_DIR = SCROLL_DIR.NONE;
  @State isAutoScroll: boolean = false;
  // 停止手势
  @State stopGesture: boolean = false;
  @State isNeedToUpdateScroll: boolean = false;
  @Prop isSuffixFilter: boolean = false; // 是否已开启过滤
  // 控制下拉显示文件项数
  @State isShowFileCount: boolean = false;
  public onFilter: Function = () => {
  }; // 聚合视图点击过滤按钮回调
  private dragInfo = GlobalHolder.getInstance().getObject<string>(GlobalKey.DRAG_INFO_TIME) ?? '';
  @State noContentDescription: string | undefined = undefined;
  @Consume isDownScrolling: boolean;
  private scrollerStatusChangeTimeOut?: number = undefined;
  // 大字体间距
  @State bigFontAutoSpace: ResourceStr = $r('app.float.common_mark_x0');
  @Prop rootYOffset: number = 0;

  @Consume @Watch('previewFileUriChange') previewFileUri: string;
  @Prop isShowLocateAni: boolean = false;

  @State bottomAvoidHeight: Length = 0;
  private bottomWaitTimeoutId: number = -1;

  isQueryTotalEndOrCurrentFileFound: () => boolean = () => {
    return false;
  };

  // 在页面显示时跳到对应文件的索引
  private goToSourceFileIndex: number = 0;

  // 要跳到文件的uri
  goToCurrentUri: string = '';

  // 跳到当前文件的次数
  private jumpToCurrentUriTimes = 0;

  @State isShowSourceMixView: boolean = false;

  onNetworkChange() {
    if (!this.isNetwork) {
      HiLog.warn(TAG, 'lost net');
      EventBus.emit(Constant.EVENTS.CLOSE_DOWNLOAD_PROGRESS_DIALOG);
      EventBus.emit(Constant.EVENTS.CANCEL_DOWNLOAD_PROGRESS_DIALOG);
    }
  }

  showHiddenItemChanged(): void {
    this.showHiddenItemStatus = this.showHiddenItem;
  }

  previewFileUriChange(): void {
    let fileIndex = -1;
    fileIndex = this.fileListSource.getIndex(this.previewFileUri);
    if (fileIndex === -1) {
      HiLog.warn(TAG, `previewFileUriChange fileIndex -1`);
      return;
    }
    let scroller: Scroller = this.getCurScroller();
    scroller?.scrollToIndex(fileIndex, false, ScrollAlign.AUTO);
  }

  // 当需要高亮的时候，立马执行一次滚动，以免List或者Grid不刷新的时候，没有走onAppear内的滚动
  needHighlightChanged(): void {
    this.needHighlight && this.jumpToFocusFile();
  }

  // 手机横竖屏切换
  orientationChange(): void {
    if (this.isAutoScroll) {
      this.slideActionEnd();
    }
  }

  // 系统语言改变
  sysLanguageChange(): void {
    this.setGroupFilesData();
  }

  // userState发生变化时
  changeUseState(): void {
    HiLog.info(TAG, `userState:${this.userState},autoScroll: ${this.isAutoScroll}`);
    if (this.userState !== UserState.MULTI_START && this.isAutoScroll) {
      this.slideActionEnd();
    }
    clearTimeout(this.bottomWaitTimeoutId);
    if (this.startModeOptions.pickerFlag || this.userState !== UserState.MULTI_START) {
      this.bottomAvoidHeight = 0;
    } else {
      // 延时增加底部栏避让高度，等待底部栏动效结束
      this.bottomWaitTimeoutId = setTimeout(() => {
        this.bottomAvoidHeight = ToolBarStyle.BOTTOM_BAR_HEIGHT + this.bottomNavBarHeight;
      }, Constant.TIMER_TIME.TIMER_500);
    }
  }

  // 非滚动条滚动时
  changeCheckNum(): void {
    if (!this.isAutoScroll || !this.canSlideSelect) {
      this.allCheckedNum = this.checkedNum;
    }
  }

  // 设置来源视图分组数据
  setSourceGroupFilesData(oriFileInfos: FileInfo[]) {
    HiLog.info(TAG, `setSourceGroupFilesData, executeWatch : ${this.fileListSource.watchFlag.executeWatch},
     dataStatus : ${this.fileListSource.dataReceStatus.status}`);
    if (!this.fileListSource.watchFlag.executeWatch) {
      return;
    }
    // 对后缀进行处理, 避免过滤失败
    const offset = 1;
    oriFileInfos.forEach((file: FileInfo) => {
      let firstPoint: number = file.fileName.lastIndexOf('.');
      if (firstPoint !== -1) {
        file.fileSuffix = file.fileName.slice(firstPoint + offset);
      }
    })
    const filterFiles = oriFileInfos;
    HiLog.info(TAG, `setSourceGroupFilesData filter before:${oriFileInfos.length} after:${filterFiles.length}`);

    // 计算从最近页面跳到来源时，要跳到对应文件的索引
    if (!StringUtil.isEmpty(this.goToCurrentUri)) {
      let curIndex = this.goToSourceFileIndex;
      if (this.isQueryTotalEndOrCurrentFileFound()) {
        HiLog.info(TAG, `goToSourceFileIndex : ${this.goToSourceFileIndex}`);
        this.isShowSourceMixView = true;
      }
      if (curIndex != this.goToSourceFileIndex) {
        HiLog.warn(TAG, `curIndex : ${curIndex} jumpToCurrentUriTimes ${this.jumpToCurrentUriTimes}`);
        if (this.jumpToCurrentUriTimes != 0) {
          this.jumpToFocusFile();
        }
      } else if (this.fileListSource.dataReceStatus.status === DataStatus.END) {
        HiLog.info(TAG, 'fileListSource recvStatus is end, set goToCurrentUri blank');
        this.goToCurrentUri = '';
      }
    } else {
      this.isShowSourceMixView = true;
    }

    this.isGridColumn = false;
    this.isSourceListView = true;
    if (this.currentTypeCountCallBack) {
      this.currentTypeCountCallBack(filterFiles.length);
    }

    if (!this.isGridColumn && !this.isSourceListView) {
      let timer = setTimeout(() => {
        this.changeSwipeItem = (uri: string) => {
          try {
            if (this.scrollerKey) {
              this.listScrollerMap.get(this.scrollerKey)?.closeAllSwipeActions();
            }
          } catch (e) {
            HiLog.info(TAG, `change swipe item error`)
          }
          this.scrollerKey = uri;
        }
        clearTimeout(timer);
      }, Constant.TIMER_TIME.TIMER_500)
    }
  }

  changeFileListSource(): void {
    HiLog.info(TAG, `changeFileListSource size = ${this.fileListSource.totalCount()}`);
    this.isDownScrolling = false;
    this.updateTimer = new Date().valueOf();
    // 若数据源有变更时若已开始滑动多选则需要重新获取所有的文件袋选中状态
    if (this.startIndex > -1) {
      this.oldCheckList = this.fileListSource.getDataArray().map(it => it.isChecked);
    }
    // 更新需要占一整行的GridItem的Index
    this.gridLayoutOptions.irregularIndexes = undefined;
    this.setGroupFilesData();
  }

  updateOutsideScreenDeviceFileInfo() {
    this.initIsListView();
    this.isNeedToUpdateScroll = true;
    // 判断当前是否分组的内容为空，若是则尝试重新获取
    if (this.needShowGroupListView() && this.groupDataSource.totalCount() === 0) {
      this.setGroupFilesData();
    }
  }

  aboutToAppear(): void {
    HiLog.info(TAG, 'about to appear');
    this.showHiddenItemStatus = this.showHiddenItem;
    AppStorage.delete(ROOT_TITLE_OFFSET);
    // 初始化需要占一整行的GridItem的Index
    this.gridLayoutOptions.irregularIndexes = undefined;
    this.updateOutsideScreenDeviceFileInfo();
    EventBus.on(Constant.EVENTS.BOTTOM_BAR_ITEM_CLICK, this.bottomBarClickCallback);
    EventBus.on(Constant.EVENTS.WINDOW_STAGE_EVENT, this.windowStageChange);
    EventBus.on(Constant.EVENTS.UPDATE_FILE_ITEM_IN_GROUP, this.updateFileItemInGroup);
  }

  aboutToDisappear(): void {
    HiLog.info(TAG, 'aboutToDisappear');
    this.isDownScrolling = false;
    if (this.scrollerStatusChangeTimeOut) {
      clearInterval(this.scrollerStatusChangeTimeOut);
      this.scrollerStatusChangeTimeOut = undefined;
    }
    EventBus.off(Constant.EVENTS.BOTTOM_BAR_ITEM_CLICK, this.bottomBarClickCallback);
    EventBus.off(Constant.EVENTS.WINDOW_STAGE_EVENT, this.windowStageChange);
    EventBus.off(Constant.EVENTS.UPDATE_FILE_ITEM_IN_GROUP, this.updateFileItemInGroup);
    this.listScrollerMap.clear();
  }

  updateFileItemInGroup: (originalIndex: number) => void = (originalIndex: number) => {
    HiLog.info(TAG, `updateFileItemInSourceGroup, originalIndex : ${originalIndex}`);
    const fileInfo = this.fileListSource.getDataArray()[originalIndex];
    this.fileGroupDataSource.updateFileItemInGroup(fileInfo.uri);
  }

  // 底部按钮点击时，
  bottomBarClickCallback: (data: string) => void = (data: string) => {
    HiLog.info(TAG, `click-bottom-bar: ${data},${this.userState},${this.isAutoScroll}`);
    if (this.userState === UserState.MULTI_START && this.isAutoScroll) {
      if (Constant.BOTTOM_TYPE_LIST.includes(data)) {
        this.canSlideSelect = false;
        (this.isListView ? this.listScroller : this.gridScroller).scrollBy(0, 0);
        this.allCheckedNum = this.checkedNum;
      }
    }
  }

  windowStageChange: (data: number) => void = (data: number) => {
    if (Constant.WINDOW_STAGE_LIST.includes(data) && this.isAutoScroll) {
      (this.isListView ? this.listScroller : this.gridScroller).scrollBy(0, 0);
    }
  }

  needShowGroupListView(): boolean {
    return this.inOtherShowGroupView();
  }

  // 2. 其他模式且处于列表模式且非第一层目录，聚合试图的压缩预览没有使用分组列表显示的
  inOtherShowGroupView(): boolean {
    return this.layout.groupMode && this.isListView;
  }

  // 分组模式数据统一入口
  setGroupFilesData(): void {
    if (!this.needShowGroupListView() || this.isArchiveOrInArchive()) {
      HiLog.info(TAG, `setGroupFilesData no needShowGroupListView`);
      return;
    }
    const oriFileInfos = this.fileListSource.getDataArray();
    HiLog.info(TAG, `setGroupFilesData pageName:${this.pageName} oriFileCount: ${oriFileInfos.length}`);
  }

  getFileOrGroupInfo(groups: GroupFileInfo[]): FileOrGroupInfo {
    HiLog.info(TAG, `getFileOrGroups start, groups length : ${groups.length}`);
    let fileOrGroupInfo = new FileOrGroupInfo();
    let fileOrGroups: FileOrGroup[] = [];
    let fileCount = 0;
    // 将所有files替换到原来的filedatasource，记录file在filedatasource中的索引和fileOrGroups中索引的映射
    let indexMap = new Map<number, number>();
    for (let gIndex = 0; gIndex < groups.length; gIndex++) {
      let group = groups[gIndex];
      let files = group.getFileDataSource().getDataArray();
      // 创建组
      let groupItem = new FileOrGroup(true, -1, undefined, undefined, files.length);
      groupItem.groupNameStr = ResourceUtil.getStringByResourceOrString(group.getGroupName());
      HiLog.info(TAG,
        `getFileOrGroups, groupName : ${groupItem.groupNameStr}, itemCount : ${groupItem.groupItemCount}`);
      fileOrGroups.push(groupItem); // 添加groupItem
      fileOrGroupInfo.groupIndexs.push(fileOrGroups.length - 1); // 记录groupIndexs
      for (let fIndex = 0; fIndex < files.length; fIndex++) {
        let file = files[fIndex];
        let fileItem = new FileOrGroup(false, -1, file, undefined, -1);
        if (fIndex === files.length - 1) {
          fileItem.isLastInGroup = true;
        }
        fileItem.indexInGroup = fIndex;
        this.listScrollerMap.set(fileItem.fileInfo.uri, new ListScroller())
        fileOrGroups.push(fileItem); // 添加fileItem
        indexMap.set(fileCount - 1, fileOrGroups.length - 1);
        fileCount++;
      }
    }
    fileOrGroupInfo.fileOrGroups = fileOrGroups;
    fileOrGroupInfo.fileCount = fileCount;
    fileOrGroupInfo.indexMap = indexMap;
    HiLog.info(TAG, `getFileOrGroups end, fileOrGroups length : ${fileOrGroups.length}, fileCount : ${fileCount},
    indexMap length : ${indexMap.size}, groupIndexs ： ${JSON.stringify(fileOrGroupInfo.groupIndexs)}`);
    return fileOrGroupInfo;
  }

  onListOrGridDidScroll(scroller: Scroller): void {
    try {
      this.listYOffset = scroller.getItemRect(this.scrollStartIndex).y;
    } catch (e) {
      this.listYOffset = 0;
      const error: BusinessError = e as BusinessError;
      HiLog.error(TAG, `getItemRect error, code: ${error.code} message: ${error.message}`);
    }
  }

  build() {
    Column() {
      this.fileListViewContent()
    }
    .padding({
      left: px2vp(AppStorage.get<SafePadding>('safePadding')?.left || 0) + 'vp',
      right: px2vp(AppStorage.get<SafePadding>('safePadding')?.right || 0) + 'vp',
      bottom: 0
    })
    .margin({
      bottom: this.bottomAvoidHeight
    })
    .width('100%')
    .dragManager()
  }

  getUEPageName(): DFX.PageName {
    if (ExternalStorageUtil.isExternalStorageUri(this.curFolderUri)) {
      return DFX.PageName.EXTERNAL;
    }
    return EnumTransferUtil.transferToPageName(this.pageName);
  }

  @Builder
  fileListViewContent() {
    Scroll(this.totalScroller) {
      Column() {
        // 图库引导提示
        if (this.curFolderUri.startsWith(VirtualUri.GALLERY_URI + '/')) {
          AlbumGuideTips({
            fileListSource: this.fileListSource,
            pageFrom: this.curFolderUri,
            userState: this.userState,
            isPicker: this.startModeOptions.pickerFlag
          })
        }
        if (!this.isShowLoading) {
          this.autoFileListViewContent()
        }
      }
    }
    .onDidScroll(() => {
      if (this.direList.length == 0) {
        AppStorage.setOrCreate<number>(ROOT_TITLE_OFFSET, this.totalScroller.currentOffset()?.yOffset ?? 0);
      }

      this.isScrollerAtEnd(this.listScroller);
    })
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
    .layoutWeight(1) // 文件展示部分自动填充满剩下区域
  }

  @Builder
  autoFileListViewContent() {
    if (this.fileListSource.totalCount()) {
      this.rootFileCount();
      if (this.isListView) {
        if (!this.isArchiveOrInArchive() && this.needShowGroupListView()) {
          this.buildGroupOrFileListView();
        } else {
          this.buildListView();
        }
      } else {
        this.buildGridView();
      }
    } else if (this.isQueryEnd) {
      NoContent({
        pageName: this.pageName,
      })
        .height('100%')
        .align(Alignment.Center)
        .id(this.startModeOptions.pickerFlag ? CompId.NO_CONTENT_PICKER : CompId.NO_CONTENT)
        .bindContextMenu(this.longPressBlankMenu, ResponseType.LongPress, {
          aboutToAppear: this.menuAboutToAppear()
        })
        .bindContextMenu(this.longPressBlankMenu, ResponseType.RightClick, {
          aboutToAppear: this.menuAboutToAppear()
        })
        .onAttach(() => {
          // 判断是否会弹出菜单，若会弹出菜单则需要适配无障碍，否则无需适配无障碍
          this.initIsNeedBindMenu().then((isNeedBindMenu) => {
            this.noContentDescription = isNeedBindMenu ? undefined : ' ';
          })
        })
        .accessibilityDescription(this.noContentDescription)
    }
  }

  @Builder
  recentEndView() {
    Text($r('app.string.recent_load_end', RECENT_LOAD_DAYS))
      .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
      .margin({
        top: $r('app.float.common_margin16'),
        bottom: $r('app.float.common_margin16'),
      })
      .opacity($r('sys.float.ohos_id_alpha_content_secondary'))
      .textAlign(TextAlign.Center)
      .width('100%')
  }

  @Builder
  buildListView() {
    List({ scroller: this.listScroller }) {
      //文件列表信息
      LazyForEach(this.fileListSource, (item: FileInfo, index: number) => {
        this.atomisticFileItem(item, index, REUSE_VIEW_TYPE.LIST_VIEW);
      }, (item: FileInfo) => FileInfo.getRefreshMark(item))
    }
    .divider({
      strokeWidth: 0.5,
      color: $r('sys.color.ohos_id_color_list_separator'),
      startMargin: $r('app.float.common_margin68'),
      endMargin: $r('app.float.common_margin16')
    })
    .gesture(
      // 手势滑动
      PanGesture({ direction: PanDirection.Vertical })
        .tag(`list_${this.updateTimer}`)
        .onActionStart((event: GestureEvent | undefined) => {
          this.panGestureAction(SlideActionType.START, event, this.listScroller, false);
        })
        .onActionUpdate((event: GestureEvent | undefined) => {
          this.panGestureAction(SlideActionType.UPDATE, event, this.listScroller, false);
        })
        .onActionEnd((event?: GestureEvent) => {
          this.panGestureAction(SlideActionType.END, event, this.listScroller, false);
        }),
      GestureMask.Normal
    )
    .onGestureRecognizerJudgeBegin((event: BaseGestureEvent, current: GestureRecognizer,
      recognizers: Array<GestureRecognizer>) => {
      if (this.userState === UserState.MULTI_START && current.isBuiltIn() &&
        current.getType() == GestureControl.GestureType.PAN_GESTURE &&
        (i18n.isRTL(i18n.System.getSystemLanguage()) ? event.fingerList[0]?.localX < CHECK_BOX_WIDTH :
          event.fingerList[0]?.localX > this.listWidth - CHECK_BOX_WIDTH)) {
        return GestureJudgeResult.REJECT;
      }
      return GestureJudgeResult.CONTINUE;
    })
    .accessibilityLevel(ACCESSIBILITY_LEVEL.NO)
    .listViewFancy()
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .cachedCount(12)
    .onScrollIndex((start, end) => {
      this.scrollStartIndex = start;
      this.scrollEndIndex = end;
    })
    .onReachStart(() => this.listPosition = ScrollPosition.start)
    .onReachEnd(() => this.listPosition = ScrollPosition.end)
    .onDidScroll(() => this.onListOrGridDidScroll(this.listScroller))
    .onScrollFrameBegin((offset: number, state: ScrollState) => {
      return this.onScrollFrameChange(offset, this.listScroller.currentOffset()?.yOffset);
    })
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
    .onScrollStart(() => {
      // 滑动时隐藏键盘
      try {
        if (this.keyBoardHeight > 0) {
          inputMethod.getController().hideTextInput();
        }
      } catch (err) {
        HiLog.info(TAG, `keyBoardHeight ${err}`)
      }
    })
    .onScrollStop(() => {
      this.onScrollStop(this.listScroller);
    })
    .onAttach(() => {
      this.updateScrollPosition();
      if (this.needHighlight) {
        this.jumpToFocusFile();
      }
      this.isScrollerAtEnd(this.listScroller);
    })
    .scrollBar(this.userState === UserState.MULTI_START ? BarState.Off : BarState.Auto)
    .onAreaChange((oldVal, newVal) => {
      this.listWidth = newVal.width as number;
      this.areaY = newVal.globalPosition.y as number;
      this.contentHeight = newVal.height as number;
    })
  }

  @Builder
  groupView(groupName: ResourceStr) {
    Text(groupName)
      .fontFamily('HarmonyHeiTi')
      .fontWeight(FontWeight.Regular)
      .fontSize(14)
      .lineHeight(16)
      .fontColor($r('sys.color.font_secondary'))
      .width('100%')
      .padding({
        left: 16,
        right: 20,
        top: 3,
        bottom: 3
      })
      .backgroundColor(this.startModeOptions.pickerFlag ?
      $r('sys.color.ohos_id_color_panel_bg') : $r('sys.color.ohos_id_color_sub_background')) // 和页面背景色保持一致
      .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr)
  }

  @Builder
  groupOrFileItem(item: FileOrGroup, index: number) {
    if (item.isGroup) {
      ListItem() {
        this.groupView(item.groupNameStr)
      }
    } else {
      this.atomisticFileItemInGroup(item.fileInfo, index, item.isLastInGroup);
    }
  }

  /**
   * 通用分组排序组件(单层循环)
   */
  @Builder
  buildGroupOrFileListView() {
    List({ scroller: this.listScroller }) {
      //文件列表信息
      LazyForEach(this.fileGroupDataSource, (item: FileOrGroup, index: number) => {
        this.groupOrFileItem(item, index);
      }, (item: FileOrGroup) => FileOrGroup.getRefreshMark(item))
    }
    .gesture(
      // 手势滑动
      PanGesture({
        direction: PanDirection.Vertical
      })
        .tag(`list_${this.updateTimer}`)
        .onActionStart((event: GestureEvent | undefined) => {
          this.panGestureActionInGroup(SlideActionType.START, event, this.listScroller);
        })
        .onActionUpdate((event: GestureEvent | undefined) => {
          this.panGestureActionInGroup(SlideActionType.UPDATE, event, this.listScroller);
        })
        .onActionEnd((event?: GestureEvent) => {
          this.panGestureActionInGroup(SlideActionType.END, event, this.listScroller);
        }),
      GestureMask.Normal
    )
    .onGestureRecognizerJudgeBegin((event: BaseGestureEvent, current: GestureRecognizer,
      recognizers: Array<GestureRecognizer>) => {
      if (this.userState === UserState.MULTI_START && current.isBuiltIn() &&
        current.getType() == GestureControl.GestureType.PAN_GESTURE &&
        (i18n.isRTL(i18n.System.getSystemLanguage()) ? event.fingerList[0]?.localX < CHECK_BOX_WIDTH :
          event.fingerList[0]?.localX > this.listWidth - CHECK_BOX_WIDTH)) {
        return GestureJudgeResult.REJECT;
      }
      return GestureJudgeResult.CONTINUE;
    })
    .accessibilityLevel(ACCESSIBILITY_LEVEL.NO)
    .listViewFancy()
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .cachedCount(12)
    .onScrollIndex((start, end) => {
      this.scrollStartIndex = start;
      this.scrollEndIndex = end;
      if (start === 0) {
        this.sharedGroupName = '';
      } else {
        this.sharedGroupName = this.fileGroupDataSource.getSharedGroupName(start);
      }
    })
    .onReachStart(() => this.listPosition = ScrollPosition.start)
    .onReachEnd(() => this.listPosition = ScrollPosition.end)
    .onDidScroll(() => this.onListOrGridDidScroll(this.listScroller))
    .onScrollFrameBegin((offset: number, state: ScrollState) => {
      return this.onScrollFrameChange(offset, this.listScroller.currentOffset()?.yOffset);
    })
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
    .onScrollStart(() => {
      // 滑动时隐藏键盘
      try {
        if (this.keyBoardHeight > 0) {
          inputMethod.getController().hideTextInput();
        }
      } catch (err) {
        HiLog.info(TAG, `keyBoardHeight ${err}`)
      }
    })
    .onScrollStop(() => {
      // 记录当前的位置
      this.onScrollStop(this.listScroller);
    })
    .onAppear(() => {
      if (!StringUtil.isEmpty(this.goToCurrentUri)) {
        this.jumpToFocusFile();
      } else {
        this.updateScrollPosition();
        if (this.needHighlight) {
          this.jumpToFocusFile();
        }
        this.isScrollerAtEnd(this.listScroller);
      }
    })
    .scrollBar(this.userState === UserState.MULTI_START ? BarState.Off : BarState.Auto)
    .onAreaChange((oldVal, newVal) => {
      this.listWidth = newVal.width as number;
      this.areaY = newVal.globalPosition.y as number;
      this.contentHeight = newVal.height as number;
      this.contentWidth = this.listWidth;
    })
  }

  onScrollStop(scroller: Scroller) {
    // 防止抖动
    this.scrollerStatusChangeTimeOut = setTimeout(() => {
      this.isDownScrolling = false;
      this.scrollerStatusChangeTimeOut = undefined;
    }, 300);
    // 记录当前的位置
    AppStorage.setOrCreate<number>(Constant.OUTSIDE_SCREEN_SCROLL_KEY, this.scrollStartIndex);
    this.isScrollerAtEnd(scroller);
  }

  // 接续内外屏的滚动条
  updateScrollPosition() {
    // 若是高亮跳转此处无需再对Scroll进行跳转
    if (this.isNeedToUpdateScroll && !this.needHighlight) {
      setTimeout(() => {
        this.scrollStartIndex = AppStorage.get<number>(Constant.OUTSIDE_SCREEN_SCROLL_KEY) ?? 0;
        this.listScroller.scrollToIndex(this.scrollStartIndex, false, ScrollAlign.START);
        this.gridScroller.scrollToIndex(this.scrollStartIndex, false, ScrollAlign.START);
      }, 50)
      this.isNeedToUpdateScroll = false;
    }
  }

  /**
   * 滑动多选操作
   */
  panGestureActionInGroup(type: SlideActionType, event: GestureEvent | undefined,
    scroller: Scroller | undefined, isSourceMix: boolean = false): void {
    HiLog.info(TAG, `wxs pangesture start`)
    if (this.stopGesture) {
      return;
    }
    if (!scroller) {
      HiLog.warn(TAG, `panGestureAction, scroller undefined`);
      return;
    }
    // 非多选情况下不操作
    if (this.userState !== UserState.MULTI_START || !event) {
      return;
    }
    // 非单指滑动不操作
    if (event.fingerList?.length !== 1) {
      return;
    }
    const finger = event.fingerList[0];
    // 获取当前操作的文件在fileSource中的绝对索引
    let index = this.getIndexInGroup(finger, scroller, isSourceMix);
    if (index == -1 && type !== SlideActionType.END) {
      HiLog.warn(TAG, `getIndex -1, return`);
      return;
    }
    switch (type) {
      case SlideActionType.START: {
        this.slideActionStart(index);
        break;
      }
      case SlideActionType.UPDATE: {
        this.slideActionUpdate(index);
        this.autoScroll(finger);
        break;
      }
      case SlideActionType.END: {
        if (isSourceMix) {
          // 来源混排模式下：结束后重置手势方向为all，避免其从列表滑动到宫格视图滑动的切换中，滑动无法生效
          this.gridDirection = PanDirection.All;
        }
        this.slideActionEnd();
        break;
      }
      default: {
      }
    }
  }

  getIndexInGroup(finger: FingerInfo, scroller: Scroller, isSourceMix: boolean = false): number {
    let index = -1;
    try {
      if (scroller.getItemIndex) {
        index = scroller.getItemIndex(finger.localX, finger.localY);
      }
      // 非来源混排模式下，取值按照原来的方式进行，混排模式下不需要下面的判断
      if (!isSourceMix) {
        if (index === -1) {
          return this.findIndexByScrollRange(finger, scroller);
        }
        let isGroup = this.fileGroupDataSource.getData(index).isGroup;
        if (isGroup) {
          return -1;
        }
        index = this.fileGroupDataSource.getIndexOfOriginalFileDataSource(index);
      }
      if (index === -1) {
        for (let i = this.scrollStartIndex; i <= this.scrollEndIndex; i++) {
          const item = scroller.getItemRect(i);
          if (finger.localY < item.y ||
            finger.localY >= item.y && finger.localY <= item.y + item.height && finger.localX < item.x) {
            break;
          }
          index = i;
        }
      }
    } catch {
      // scroller未绑定完成时，直接调用getItemRect和getItemIndex会报错，闪退
      this.stopGesture = true;
      HiLog.info(TAG, 'controller not bound to component');
      return index;
    }
    // 滚动条向上滑动时，
    if (index === -1 && this.scrollDir === SCROLL_DIR.TOP) {
      index = this.scrollStartIndex;
    }
    return isSourceMix ? this.getIndexInFilesByIndexOfGrid(index) : index;
  }

  /**
   * 来源混排中通过gridItem的序号计算除去组外，列表中file的排序
   * @param index：gridItem的排序
   * @returns
   */
  getIndexInFilesByIndexOfGrid(index: number) {
    let count = index;
    for (let groupIndex of this.fileGroupDataSource.groupIndexs) {
      // 下滑时，手指停留在组上，index不计算此组在内。上滑时，需要计算
      if (index > groupIndex || (index == groupIndex && this.startIndex <= count)) {
        count--;
      }
    }
    return count;
  }

  /**
   * 滑动多选操作
   * @param type 0：start,1:update,2:end
   * @param event
   */
  panGestureAction(type: SlideActionType, event: GestureEvent | undefined,
    scroller: Scroller | undefined, isListScroller: boolean): void {
    if (this.stopGesture) {
      return;
    }
    if (!scroller) {
      HiLog.warn(TAG, `panGestureAction, scroller undefined`);
      return;
    }
    // 非多选情况下不操作
    if (this.userState !== UserState.MULTI_START || !event) {
      return;
    }
    // 非单指滑动不操作
    if (event.fingerList?.length !== 1) {
      return;
    }
    const finger = event.fingerList[0];
    // 获取当前操作的文件在fileSource中的绝对索引
    let index = this.getIndex(finger, isListScroller);
    if (index == -1 && type !== SlideActionType.END) {
      HiLog.warn(TAG, `getIndex -1, return`);
      return;
    }
    switch (type) {
      case SlideActionType.START: {
        this.slideActionStart(index);
        break;
      }
      case SlideActionType.UPDATE: {
        this.slideActionUpdate(index);
        this.autoScroll(finger);
        break;
      }
      case SlideActionType.END: {
        this.slideActionEnd();
        break;
      }
      default: {
      }
    }
  }

  getIndexOfOrangeFileDataSource(groupIndex: number, itemIndexInGroup: number): number {
    let index = this.groupDataSource.getIndexOfOriginalFileDataSource(groupIndex, itemIndexInGroup);
    return index;
  }

  getCurScroller(): Scroller {
    return this.isListView ? this.listScroller : this.gridScroller;
  }

  /**
   * 获取当前点位
   * @param finger
   * @returns
   */
  getIndex(finger: FingerInfo, isListScroller: boolean): number {
    // 初始化数据
    let index = -1;
    const scroller = this.getCurScroller();
    try {
      if (isListScroller) {
        const visibleListContentInfo =
          (scroller as ListScroller).getVisibleListContentInfo(finger.localX, finger.localY);
        index = visibleListContentInfo.itemIndexInGroup ?? -1;
        if (index === -1) {
          HiLog.warn(TAG, `getIndex itemIndexInGroup -1`);
          return index;
        }
        const groupIndex = visibleListContentInfo.index;
        index = this.getIndexOfOrangeFileDataSource(groupIndex, index);
      } else {
        if (scroller.getItemIndex) {
          index = scroller.getItemIndex(finger.localX, finger.localY);
        }
      }
      if (index === -1) {
        index = this.findIndexByScrollRange(finger, scroller);
      }
    } catch {
      // scroller未绑定完成时，直接调用getItemRect和getItemIndex会报错，闪退
      this.stopGesture = true;
      HiLog.info(TAG, 'controller not bound to component');
      return index;
    }
    // 滚动条向上滑动时，
    if (index === -1 && this.scrollDir === SCROLL_DIR.TOP) {
      index = this.scrollStartIndex;
    }
    return index;
  }

  /**
   * 自动滚动--
   * @param finger
   */
  autoScroll(finger: FingerInfo): void {
    // 不可多选
    if (!this.canSlideSelect || HOT_AREA_LENGTH === undefined || AUTO_SPEED_MAX === undefined) {
      HiLog.warn(TAG, `autoScroll warn: param warn, canSlideSelect: ${this.canSlideSelect}`);
      return;
    }
    let scroller = this.getCurScroller();
    let pointY = finger.globalY - this.areaY;
    if (pointY <= HOT_AREA_LENGTH) {
      if (this.isAutoScroll && pointY <= 0) {
        return;
      }
      const speedFlag = pointY > 0 ? SLIDE_SELECT_SPEED_CURVE
        .interpolate(1 - pointY / HOT_AREA_LENGTH) : 1;
      scroller.scrollEdge(Edge.Top, {
        velocity: speedFlag * AUTO_SPEED_MAX
      })
      this.scrollDir = SCROLL_DIR.TOP;
      this.isAutoScroll = true;
    } else if (pointY > this.contentHeight - HOT_AREA_LENGTH) {
      // 将顶部总项数的标题滚动到外面(最近页此值保持为undefined，无法滚动)
      if (this.totalScroller.isAtEnd() === false) {
        this.totalScroller.scrollEdge(Edge.Bottom, {
          velocity: AUTO_SPEED_MAX
        });
        return;
      }
      if (this.isAutoScroll && pointY >= this.contentHeight) {
        return;
      }
      const speedFlag = pointY < this.contentHeight ? SLIDE_SELECT_SPEED_CURVE
        .interpolate(1 - (this.contentHeight - pointY) / HOT_AREA_LENGTH) : 1;
      scroller.scrollEdge(Edge.Bottom, {
        velocity: speedFlag * AUTO_SPEED_MAX
      })
      this.scrollDir = SCROLL_DIR.BOTTOM;
      this.isAutoScroll = true;
    } else {
      if (this.isAutoScroll) {
        scroller.scrollBy(0, 0);
        this.scrollDir = SCROLL_DIR.NONE;
        this.isAutoScroll = false;
      }
    }
  }

  /**
   * 开始滑动多选-配置滑动过程中的初始数据
   * @param index
   */
  slideActionStart(index: number): void {
    if (index < 0) {
      HiLog.info(TAG, `index is -1`);
      return;
    }
    const list: FileInfo[] = this.fileListSource.getDataArray();
    this.oldCheckList = list.map(it => it.isChecked);
    const targetFile = list[index];
    // 当初始接触时不可滑动多选时，直接返回。
    if (!targetFile.isChecked &&
      !PhoneFilePickerUtil.checkFileCanPick(targetFile, this.checkedNum, false, this.startModeOptions)) {
      this.canSlideSelect = false;
      return;
    }
    this.setChecked = !targetFile.isChecked;
    this.startIndex = index;
    targetFile.isChecked = this.setChecked;
    HiLog.info(TAG, `pageGesture start: ${this.startIndex},${index}`);
    UEUtil.reportSlideSelect(this.getUEPageName(), FilePickerUtil.getStartOptionsFromStorage().pickerFlag);
  }

  /**
   * 滑动多选中
   * @param index
   */
  slideActionUpdate(index: number): void {
    if (!this.canSlideSelect) {
      HiLog.info(TAG, `can not slide select`);
      return;
    }
    if (this.startIndex === -1) {
      //（初始接触点在空隙）时，重新配置滑动的初始数据
      this.slideActionStart(index);
      return;
    }
    if (index === -1) {
      HiLog.info(TAG, `no slide on file`);
      return;
    }
    // 1.滑动选择的项没有发生变化。2、滚动条向下滚动时，滑动选择的项应该依次递增。3、滚动条向上滚动时，滑动选择的项应该依次递减
    if (this.updateIndex === index ||
      (this.scrollDir === SCROLL_DIR.BOTTOM && index < this.updateIndex) ||
      (this.scrollDir === SCROLL_DIR.TOP && index > this.updateIndex)) {
      return;
    }
    this.lastUpdateIndex = this.updateIndex;
    this.setFileListSourceChecked(index);
    this.updateIndex = index;
  }

  /**
   * 重置列表数据中的选中项
   */
  setFileListSourceChecked(index: number): void {
    const beginIndex = this.lastUpdateIndex === -1 ? this.startIndex : this.lastUpdateIndex;
    const start = Math.min(beginIndex, index);
    const end = Math.max(beginIndex, index);
    let currentNum = this.pickerCheckArr?.length ?? 0;
    // 滑动多选经过的item选中状态重置为滑动多选之前的状态
    for (let i = start; i < end + 1; i++) {
      let item = this.fileListSource.getDataArray()[i];
      if (!item) {
        continue;
      }
      if (item.isMultiEnable && this.showCheckBox(item)) {
        const isChecked = this.getCheckedByIndex(index, i);
        // 当前文件不可被选择
        if (isChecked && !PhoneFilePickerUtil.checkFileCanPick(item, currentNum, true, this.startModeOptions)) {
          HiLog.info(TAG, `show num ${currentNum}`);
          this.canSlideSelect = false;
          let scroller = this.getCurScroller();
          scroller.scrollBy(0, 0);
          break;
        }
        item.isChecked = isChecked;
        if (i > start) {
          currentNum += isChecked ? 1 : -1;
        }
      } else {
        item.isChecked = false;
      }
    }
    // 在picker中。会监听checkedNum，其会影响选中的项数，此处异步执行。
    let timer = setTimeout(() => {
      this.checkedNum = this.fileListSource.getSelectedFileList().length;
      clearTimeout(timer)
    })
  }

  /**
   * 获取targetIndex处的item的选中状态
   * @param currentIndex
   * @param targetIndex
   * @returns
   */
  getCheckedByIndex(currentIndex: number, targetIndex: number): boolean {
    const lastIndex = this.lastUpdateIndex === -1 ? this.startIndex : this.lastUpdateIndex;
    if (currentIndex >= lastIndex && lastIndex >= this.startIndex ||
      currentIndex <= lastIndex && lastIndex <= this.startIndex) {
      // 上次的点位在起始点和当前点位之间（上次点位和此次点位之间的数据都为初始点位的选中状态）
      return this.setChecked;
    } else {
      // 起始点在中间（起始点位到当前点位之间的数据的选中状态和其实点位保持一致，起始点位和上次选中点位的状态复原）
      return targetIndex >= this.startIndex && targetIndex <= currentIndex ||
        targetIndex <= this.startIndex && targetIndex >= currentIndex ? this.setChecked :
      this.oldCheckList[targetIndex];
    }
  }

  /**
   * 当前项是否可以滑动多选
   * @param fileInfo
   * @returns
   */
  showCheckBox(fileInfo: FileInfo): boolean {
    let filePickerViewFlag = this.startModeOptions.pickerFlag;
    if (fileInfo.fileName === MyPhoneConstant.MY_PHONE_GALLERY ||
      fileInfo.fileName === MyPhoneConstant.MY_PHONE_SOUND_RECORDER ||
      (fileInfo.isFolder && fileInfo.isGallery) ||
      fileInfo.isFusionAlbum) {
      return false;
    }
    return !filePickerViewFlag || !fileInfo.isFolder;
  }

  /**
   * 滑动结束
   */
  slideActionEnd(): void {
    let scroller = this.getCurScroller();
    this.startIndex = -1;
    this.oldCheckList = [];
    this.updateIndex = -1;
    this.canSlideSelect = true;
    scroller.scrollBy(0, 0);
    this.isAutoScroll = false;
    this.scrollDir = SCROLL_DIR.NONE;
    this.allCheckedNum = this.checkedNum;
    HiLog.info(TAG, `slide action end`);
  }

  @Builder
  buildGridView() {
    Grid(this.gridScroller, this.gridLayoutOptions) {
      LazyForEach(this.fileListSource, (item: FileInfo, index: number) => {
        this.atomisticFileItem(item, index, REUSE_VIEW_TYPE.GRID_VIEW);
      }, (item: FileInfo) => FileInfo.getRefreshMark(item))
    }
    .gesture(
      // 手势滑动
      PanGesture({ direction: PanDirection.Horizontal })
        .tag(`grid_${this.updateTimer}`)
        .onActionStart((event: GestureEvent | undefined) => {
          this.panGestureAction(SlideActionType.START, event, this.gridScroller, false);
        })
        .onActionUpdate((event: GestureEvent | undefined) => {
          this.panGestureAction(SlideActionType.UPDATE, event, this.gridScroller, false);
        })
        .onActionEnd((event?: GestureEvent) => {
          this.panGestureAction(SlideActionType.END, event, this.gridScroller, false);
        })
    )
    .accessibilityLevel(ACCESSIBILITY_LEVEL.NO)
    .listViewFancy()
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .cachedCount(3)
    .columnsTemplate(this.gridCompactLayout ? '1fr 1fr 1fr 1fr' : this.columnTemplate)
    .columnsGap(this.gridCompactLayout ? $r('app.float.common_padding2') : $r('app.float.file_list_columns_gap'))
    .rowsGap(this.gridCompactLayout ? $r('app.float.common_padding2') : $r('app.float.file_list_rows_gap'))
    .onReachStart(() => this.listPosition = ScrollPosition.start)
    .onReachEnd(() => this.listPosition = ScrollPosition.end)
    .onScrollIndex((start, end) => {
      this.scrollStartIndex = start;
      this.scrollEndIndex = end;
    })
    .onDidScroll(() => this.onListOrGridDidScroll(this.gridScroller))
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
    .onScrollFrameBegin((offset: number, state: ScrollState) => {
      return this.onScrollFrameChange(offset, this.gridScroller.currentOffset()?.yOffset);
    })
    .padding({
      left: this.gridCompactLayout ? 0 : $r('app.float.common_padding16'),
      right: this.gridCompactLayout ? 0 : $r('app.float.common_padding16')
    })
    .onScrollStart(() => {
      // 滑动时隐藏键盘
      try {
        if (this.keyBoardHeight > 0) {
          inputMethod.getController().hideTextInput();
        }
      } catch (err) {
        HiLog.info(TAG, `keyBoardHeight ${err}`)
      }
    })
    .onScrollStop(() => {
      this.onScrollStop(this.gridScroller);
    })
    .onAttach(() => {
      this.updateScrollPosition();
      if (this.needHighlight) {
        this.jumpToFocusFile();
      }
      this.isScrollerAtEnd(this.gridScroller);
    })
    .scrollBar(BarState.Auto)
    .onAreaChange((oldVal, newVal) => {
      let y = newVal.globalPosition.y as number;
      let height = newVal.height as number;
      this.areaY = y;
      this.contentHeight = height;
    })
  }

  @Builder
  rootFileCount() {
    Row() {
      this.blankArea();
      if (this.inOtherShowGroupView()) {
        Text(this.isLoading ? $r('app.string.loading') :
        $r('app.plural.item', this.fileGroupDataSource.fileCount, this.fileGroupDataSource.fileCount))
          .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
      } else {
        Text(this.isLoading ? $r('app.string.loading') :
        $r('app.plural.item', this.fileListSource.totalCount(), this.fileListSource.totalCount()))
          .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
      }
      this.blankArea();
    }
    .margin({
      top: $r('app.float.common_margin10'),
      bottom: $r('app.float.common_margin10'),
      left: $r('app.float.common_margin8'),
      right: $r('app.float.common_margin8')
    })
    .opacity($r('sys.float.ohos_id_alpha_content_secondary'))
    .visibility(this.isShowFileCount ? Visibility.Visible : Visibility.None)
    .width('100%')
    .animation({
      duration: 200,
      curve: Curve.EaseOut
    })
  }

  @Builder
  blankArea() {
    Blank()
      .bindContextMenu(this.longPressBlankMenu, ResponseType.LongPress, {
        aboutToAppear: this.menuAboutToAppear()
      })
      .bindContextMenu(this.longPressBlankMenu, ResponseType.RightClick, {
        aboutToAppear: this.menuAboutToAppear()
      })
      .accessibilityLevel('no')
  }

  @Builder
  atomisticFileItemInGroup(item: FileInfo, index: number, isLastInGroup: boolean, isSourceMix: boolean = false) {
    FileViewComp({
      item: item,
      startModeOptions: this.startModeOptions,
      itemViewModel: new PhoneItemViewModel(item),
      userState: this.userState,
      checkedNum: this.checkedNum,
      isSelectAll: this.isSelectAll,
      onItemClick: this.onItemClick,
      isShowRecentTime: this.isShowRecentTime,
      isShowFileSource: this.isShowFileSource,
      isShowCheckBox: this.isShowCheckBox,
      curFolderUri: this.curFolderUri,
      // 图库文件夹、大文件清理页面文件禁止拖出
      enableDrag: this.enableDrag
        && this.curFolderUri !== PAGE_ROUTE_CONST.IMAGE
        && this.curFolderUri !== PAGE_ROUTE_CONST.VIDEO,
      onDropCallback: this.onDropCallback,
      fileSource: $fileListSource,
      pageName: this.pageName,
      compIdIndex: index,
      toOperateFileList: this.toOperateFileList,
      swipeDeleteDialogCallback: this.swipeDeleteDialogCallback,
      listScroller: isSourceMix ? this.listScrollerMap.get(item.uri) : this.listScroller,
      disableSwipe: this.disableSwipe,
      geometryId: this.geometryId,
      pickerCheckArr: this.pickerCheckArr,
      needHighlight: this.needHighlight,
      gridCompactLayout: this.gridCompactLayout,
      isChecked: item.isChecked,
      updateIndex: this.updateIndex,
      isCurFolderEnableDrop: this.isAllowDrop(),
      isLastInGroup: isLastInGroup,
      isShowLocateAni: this.isShowLocateAni,
      changeSwipeItem: isSourceMix ? (uri) => this.changeSwipeItem(uri) : undefined
    })
  }

  @Builder
  atomisticFileItem(item: FileInfo, index: number, reuseId: string) {
    FileViewComp({
      item: item,
      startModeOptions: this.startModeOptions,
      itemViewModel: new PhoneItemViewModel(item),
      userState: this.userState,
      checkedNum: this.checkedNum,
      isSelectAll: this.isSelectAll,
      onItemClick: this.onItemClick,
      isShowRecentTime: this.isShowRecentTime,
      isShowFileSource: this.isShowFileSource,
      isShowCheckBox: this.isShowCheckBox,
      curFolderUri: this.curFolderUri,
      // 图库文件夹、大文件清理页面文件禁止拖出
      enableDrag: this.enableDrag
        && this.curFolderUri !== PAGE_ROUTE_CONST.IMAGE
        && this.curFolderUri !== PAGE_ROUTE_CONST.VIDEO,
      onDropCallback: this.onDropCallback,
      fileSource: $fileListSource,
      pageName: this.pageName,
      compIdIndex: index,
      toOperateFileList: this.toOperateFileList,
      swipeDeleteDialogCallback: this.swipeDeleteDialogCallback,
      listScroller: this.listScroller,
      disableSwipe: this.disableSwipe,
      geometryId: this.geometryId,
      pickerCheckArr: this.pickerCheckArr,
      needHighlight: this.needHighlight,
      gridCompactLayout: this.gridCompactLayout,
      isChecked: item.isChecked,
      updateIndex: this.updateIndex,
      isCurFolderEnableDrop: this.isAllowDrop(),
      isShowLocateAni: this.isShowLocateAni,
    })
      .reuseId(reuseId)
  }

  @Builder
  sourceGroupView(groupName: ResourceStr) {
    Text(groupName)
      .fontFamily('HarmonyHeiTi')
      .fontWeight(FontWeight.Regular)
      .fontSize(14)
      .lineHeight(16)
      .fontColor($r('sys.color.font_secondary'))
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 10,
        bottom: 8
      })
      .backgroundColor(this.startModeOptions.pickerFlag ?
      $r('sys.color.ohos_id_color_panel_bg') : $r('sys.color.ohos_id_color_sub_background')) // 和页面背景色保持一致
      .height(48)
  }

  @Builder
  longPressFileMenu() {
    // 最近页长按空白处不弹出粘贴
    if (this.isShowPastMenu()) {
      Row() {
        Text($r('app.string.paste'))
          .fontSize(16)
          .lineHeight(22)
          .fontFamily('HarmonyHeiTi')
          .margin({ left: $r('sys.float.padding_level6') })
          .fontColor($r('sys.color.font_primary'))
      }
      .onClick(() => {
        this.longPressFileMenuShow = false;
        this.longPressHoldToPaste();
        //粘贴打点
        PasteBoardUtil.getPasteData().then(res => {
          if (res) {
            // 操作页面不能通过uri判断时，使用pageName判断
            let pageName = EnumTransferUtil.transferUriToPageName(this.curFolderUri);
            if (pageName === DFX.PageName.UNKNOWN) {
              pageName = EnumTransferUtil.transferToPageName(this.pageName);
            }
            UEUtil.reportPasteFile(pageName, DFX.PasteType.BLANK_PRESS_MENU, res.getRecordCount());
          }
        })
      })
      .onTouch((event?: TouchEvent) => {
        if (event && (event.type === TouchType.Down)) {
          this.longPressColor = $r('sys.color.ohos_id_color_click_effect');
        } else if (event && (event.type === TouchType.Up)) {
          this.longPressColor = $r('app.color.transparent_color');
        }
      })
      .backgroundColor(this.longPressColor)
      .borderRadius($r('sys.float.corner_radius_level8'))
      .padding({
        top: 13, bottom: 13
      })
      .width($r('app.float.common_size216'))
    }
  }

  @Builder
  longPressBlankMenu() {
    this.longPressFileMenu();
  }

  @Styles
  listViewFancy() {
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .visibility(this.listScrollShow ? Visibility.Visible : Visibility.Hidden)
    .align(Alignment.TopStart)
    .bindContextMenu(this.longPressBlankMenu, ResponseType.LongPress, {
      aboutToAppear: this.menuAboutToAppear()
    })
    .bindContextMenu(this.longPressBlankMenu, ResponseType.RightClick, {
      aboutToAppear: this.menuAboutToAppear()
    })
    .onAppear(() => {
      if (this.needHighlight) {
        this.jumpToFocusFile();
      }

      this.isScrollerAtEnd(this.gridScroller);
    })
  }

  @Styles
  dragManager() {
    .allowDrop(this.isAllowDrop() ?
    Constant.ALLOW_DROP.ALL_FILE : Constant.ALLOW_DROP.NONE
    )
    .onDrop((event: DragEvent, extraParam?: string) => {
      HiLog.info(TAG, 'FileListView on drop');
      if (!this.isAllowDrop()) {
        HiLog.warn(TAG, 'current folder do not support drop');
        toast(DeviceConfig.getInstance().config.dragTip);
        return;
      }
      this.drop(event, extraParam);
    })
    .onDragEnter((event: DragEvent, extraParams: string) => {
      DragManager.getInstance().getDragFlag(event, extraParams, this.dragInfo);
    })
    .onDragLeave((event: DragEvent, extraParams: string) => {
      DragManager.getInstance().getDragFlag(event, extraParams, this.dragInfo);
    })
    .onDragMove((event: DragEvent, extraParams: string) => {
      DragManager.getInstance().getDragFlag(event, extraParams, this.dragInfo);
      event.setResult(this.isAllowDrop() && this.curFolderUri !== DragManager.getInstance().dragStartFolderUri ?
      DragResult.DROP_ENABLED : DragResult.DROP_DISABLED);
    })
  }

  initIsListView(): void {
    this.isListView = true;
  }

  // 选中文件
  checkedNumChange(fromSource: string): void {
    HiLog.info(TAG, `checked num change : ${this.checkedNum}, source: ${fromSource}`);
    if (this.checkedNum === UiUtil.SELECT_NONE) {
    } else {
      this.touchShareListenChange();
    }
  }

  // 碰一碰监听状态改变
  touchShareListenChange(): void {
    HiLog.info(TAG, `touchShareListenChange, user state : ${this.userState}`);
    // 如果是多选状态，创建监听， 退出多选，取消监听
    if (this.userState !== UserState.MULTI_START) {
      return;
    }

    let isAllowShare: boolean = !(this.startModeOptions.pickerFlag ||
      this.pageName === PAGE_ROUTE_CONST.RECENT_DELETE);
    HiLog.info(TAG, `allow Share listen : ${isAllowShare}`);
    if (!isAllowShare) {
      return;
    }
  }

  /**
   * 根据滚动范围查找索引
   * @param finger 手指信息
   * @param scroller 滚动器
   * @returns 索引
   */
  private findIndexByScrollRange(finger: FingerInfo, scroller: Scroller): number {
    for (let i = this.scrollStartIndex; i <= this.scrollEndIndex; i++) {
      const item = scroller.getItemRect(i);
      if (finger.localY < item.y ||
        (finger.localY >= item.y && finger.localY <= item.y + item.height && finger.localX < item.x)) {
        return i;
      }
    }
    return -1;
  }

  private isShowPastMenu(): boolean {
    return (this.longPressFileMenuShow && !this.startModeOptions.pickerFlag &&
      this.userState !== UserState.MULTI_START) &&
      this.curFolderUri !== PAGE_ROUTE_CONST.IMAGE &&
      this.curFolderUri !== PAGE_ROUTE_CONST.VIDEO;
  }

  /**
   * 通过scrollTo与面包屑实现返回上次进入位置，需要在懒加载出滚动条后执行，否则无法生效
   */
  private onDireListChange() {
    this.isDownScrolling = false;
    if (this.scrollerStatusChangeTimeOut) {
      clearInterval(this.scrollerStatusChangeTimeOut);
      this.scrollerStatusChangeTimeOut = undefined;
    }
    let timeoutBox = setTimeout(() => {
      if (this.needHighlight) { // 如果需要进行文件跳转、高亮，则直接返回
        return;
      }
      const yOffset: number =
        ArrayUtil.isEmpty(this.direList) ? this.rootYOffset : this.direList[this.direList.length - 1].yOffset;
      if (this.isListView) {
        if (this.isAllowTitleOffset()) {
          this.totalScroller.scrollTo({ xOffset: 0, yOffset: AppStorage.get<number>(ROOT_TITLE_OFFSET) ?? 0 })
        }
        this.listScroller.scrollTo({ xOffset: 0, yOffset });
      } else {
        if (this.isAllowTitleOffset()) {
          this.totalScroller.scrollTo({ xOffset: 0, yOffset: AppStorage.get<number>(ROOT_TITLE_OFFSET) ?? 0 })
        }
        this.gridScroller.scrollTo({ xOffset: 0, yOffset });
      }
      HiLog.info(TAG, 'listScrollShow end. yOffset:' + yOffset);
      this.listScrollShow = true;
      this.listYOffset = 0;
      clearTimeout(timeoutBox)
    }, 100)
  }

  private isAllowTitleOffset() {
    return this.fileListSource.totalCount() &&
    this.hasTotalCapacity && this.direList.length == 0;
  }

  /**
   * 通过scrollToIndex实现宫格列表视图间切换时可视区域内显示的文件保持不变
   */
  private onIsListChange(): void {
    HiLog.info(TAG, `onIsListChange`);
    this.listYOffset = 0;
    setTimeout(() => {
      if (this.isListView) {
        this.listScroller.scrollToIndex(this.scrollStartIndex, false, ScrollAlign.START);
      } else {
        this.gridScroller.scrollToIndex(this.scrollStartIndex, false, ScrollAlign.START);
      }
    }, 20);
    this.setGroupFilesData();
  }

  private onScrollFrameChange(offset: number, currentOffset: number): OffsetRemainParam {
    // 向下拖动显示文件数目
    if (!this.isShowFileCount && currentOffset <= 0 && offset < 0) {
      this.isShowFileCount = true;
    }
    // 清空定时
    if (this.scrollerStatusChangeTimeOut) {
      clearTimeout(this.scrollerStatusChangeTimeOut);
      this.scrollerStatusChangeTimeOut = undefined;
    }
    // 向下滚动状态更新
    if (offset > 3 && currentOffset > 0 && !this.isScrollReachEnd) {
      this.isDownScrolling = true;
    } else if (offset < -3) {
      this.isDownScrolling = false;
    }
    if (!((this.listPosition === ScrollPosition.start && (offset < 0)) ||
      (this.listPosition === ScrollPosition.end && (offset > 0)))) {
      this.listPosition = ScrollPosition.center;
    }
    return { offsetRemain: offset > 50 ? 50 : offset }
  }

  private menuAboutToAppear(): () => void {
    return async () => {
      await this.initLongPressFileMenuShow();
    };
  }

  /**
   * 滚动界面到指定文件的位置。有两种情况：
   * 1. 单文件 - 滚动到该文件处于屏幕中的位置。
   * 2. 多文件 - 滚动到使得uriArray中的第一个文件处于屏幕中的位置。
   *
   * @returns
   */
  private jumpToFocusFile(): void {
    HiLog.info(TAG, 'jumpToFocusFile');
    if (!StringUtil.isEmpty(this.goToCurrentUri)) {
      HiLog.info(TAG, `scroll to index : ${this.goToSourceFileIndex}`)
      if (this.fileListSource.dataReceStatus.status === DataStatus.END) {
        HiLog.info(TAG, 'jump to goToCurrentUri, set it blank.');
        this.goToCurrentUri = '';
      }
      this.jumpToCurrentUriTimes++;
      this.listScroller.scrollToIndex(this.goToSourceFileIndex, false, ScrollAlign.START);
      // 记录当前的位置
      this.scrollStartIndex = this.goToSourceFileIndex;
      AppStorage.setOrCreate<number>(Constant.OUTSIDE_SCREEN_SCROLL_KEY, this.scrollStartIndex);
      return;
    }

    const uri: string = GlobalHolder.getInstance().getObject<string>(GlobalKey.URI_PATH) ?? '';
    const uriArray: string[] = GlobalHolder.getInstance().getObject<string []>(GlobalKey.FILE_URI_ARRAY) ?? [];
    const index = uriArray.length ? this.fileListSource.getIndex(uriArray[0]) : this.fileListSource.getIndex(uri);
    // 无动画的scrollBy滚动，100这个数值为了将 页面上方 “xx项” 滚出屏幕
    this.totalScroller.scrollBy(0, 100);
    if (this.isListView) {
      this.listScroller.scrollToIndex(index, false, ScrollAlign.CENTER);
    } else {
      this.gridScroller.scrollToIndex(index, false, ScrollAlign.CENTER);
    }
  }

  /*
   * 判断当前路径是否支持拖拽
   * */
  private isAllowDrop(): boolean {
    const isNotEnableDropFolder: boolean = NOT_ALLOW_DROP_PAGES.includes(this.pageName);
    if (isNotEnableDropFolder) {
      return false;
    }
    if (this.curFolderUri === VirtualUri.GALLERY || this.curFolderUri.startsWith(VirtualUri.GALLERY_URI)) {
      return true;
    }

    return true;
  }

  /*
   * 根据uri和当前路径名称处理拖拽数据
   * */
  private drop(event: DragEvent, extraParam?: string): void {
    HiLog.info(TAG, 'filelist on drop');
    DragManager.getInstance().onDrop();
    this.onDropCallback(event, this.curFolderUri, FileUtil.getFileNameFromUri(this.curFolderUri), extraParam);
  }

  /*
  * 是否滚到底部
  * */
  private isScrollerAtEnd(scroller: Scroller): void {
    if (scroller) {
      this.isScrollReachEnd = scroller.isAtEnd();
    }
  }

  private getBigFontAutoSpace() {
    let fontSize = UiUtil.getFontSize();
    this.bigFontAutoSpace =
      Constant.BIG_FONT_SIZE_SPACE_MAP.get(fontSize) ? Constant.BIG_FONT_SIZE_SPACE_MAP.get(fontSize) as ResourceStr :
      $r('app.float.common_mark_x0');
  }

  private isArchiveOrInArchive() {
    return this.direList && this.direList.length > 0 &&
    FileUtil.isArchiveByUri(this.direList[this.direList.length - 1].uri)
  }

  private async initLongPressFileMenuShow(): Promise<void> {
    if ((!PasteBoardUtil.checkUriData()) || this.pageName === PAGE_ROUTE_CONST.RECENT_DELETE) {
      HiLog.info(TAG, 'do not show longPressFileMenu');
      this.longPressFileMenuShow = false;
      return;
    }
    this.longPressFileMenuShow = true;
  }

  private async initIsNeedBindMenu(): Promise<boolean> {
    await this.initLongPressFileMenuShow();
    return this.isShowPastMenu();
  }
}