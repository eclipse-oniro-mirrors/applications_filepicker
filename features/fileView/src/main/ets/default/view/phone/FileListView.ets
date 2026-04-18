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
  ArrayUtil,
  Constant,
  FileSourceUri,
  EventBus,
  DeviceConfig,
  HiLog,
  ObjectUtil,
  PAGE_ROUTE_CONST,
  PasteboardDataModel,
  ScrollPosition,
  UserState,
  BottomCallParams,
  FileInfo,
  PasteBoardManager,
  PasteBoardUtil,
  StartModeOptions,
  FilePickerUtil,
  FileDataSource,
  OffsetRemainParam,
  SafePadding,
  GlobalHolder,
  GlobalKey,
  ACCESSIBILITY_LEVEL,
  CompId,
  ResourceUtil,
  toast,
  ERROR_CODE,
  FilesQueryUtil,
  FileUtil,
  LocationType,
  UiUtil,
  DragManager,
  UsageHabitsPreferenceUtil,
  PreferenceConst,
  ViewMode,
  HiSysEventUtil,
  AbilityName,
  ThreadCommonUtil,
  SlideActionType,
  MyPhoneConstant,
  PhoneFilePickerUtil,
  EnumTransferUtil,
  UEUtil,
  DFX,
  ExternalStorageUtil,
  FileGroupOrder,
  GroupDataSource,
  GroupFileInfo,
  FileOrGroup,
  FileGroupDataSource,
  FileOrGroupInfo,
  SortOrder,
  DisplayUtil,
  VirtualUri,
  SHOW_MODE,
  LocalStorageConst,
  FsUtil,
  ToolBarStyle,
  StorageDeviceManager,
  StringUtil,
  DataStatus,
  TabBarStyle
} from '@ohos/common';
import { NoContent } from './basicComp/NoContent';
import lazy { FileViewComp } from './FileViewComp';
import { PhoneItemViewModel } from '../../viewModel/PhoneItemViewModel';
import { inputMethod } from '@kit.IMEKit';
import { TopMenuItem } from '@ohos/titleBar';
// import { harmonyShare } from '@kit.ShareKit';
import { ToolOperateType, ToolOperateArea } from '../ToolOperateArea';
import { CustomBottomButtonComp } from './basicComp/CustomButtonComp';
import { App, componentUtils, LengthMetrics } from '@kit.ArkUI';
import Curves from '@ohos.curves';
import { i18n } from '@kit.LocalizationKit';
import { FileListViewLayout } from '../../viewModel/FileListViewLayout';
import { FileFilterScrollComp } from './FileFilterScrollComp';
import { BusinessError } from '@kit.BasicServicesKit';
import { REUSE_VIEW_TYPE } from './constant/FileViewConst';
import { AlbumGuideTips } from './AlbumGuideTips';

const TAG = 'FileListView';

const ROOT_TITLE_OFFSET = 'rootTitleOffset';
const RECENT_LOAD_DAYS: number = 30;
// 列表形式下滚动区域的宽度
const CHECK_BOX_WIDTH: number = 40;
// 来源中宫格模式下单列的基础宽度
const BASE_WIDTH: number = 90;
// 来源混排中grid的边距等参数
const SOURCE_GRID_MARGIN: number = 8;
const SOURCE_GRID_PADDING: number = 24;
const SOURCE_GRID_COLUMN_GAP: number = 4;
// 热区
const HOT_AREA_LENGTH: number | undefined = DisplayUtil.getHotAreaLength();
// 滚动速度: 贝塞尔曲线
const SLIDE_SELECT_SPEED_CURVE = Curves.cubicBezierCurve(0.33, 0, 0.67, 1);
// 滚动速度: 最大速度
const AUTO_SPEED_MAX: number | undefined = DisplayUtil.getAutoScrollMaxSpeed();

const NOT_ALLOW_DROP_PAGES = [PAGE_ROUTE_CONST.RECENT_DELETE];

// 来源下默认宫格一行展示的个数
const DEFAULT_GRID_COLUMN_NUM: number = 4;

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
export struct FileListView {
  currentTypeCountCallBack: Function = () => {};
  // 当前窗口尺寸是否小于600
  @LocalStorageProp(LocalStorageConst.IS_SINGLE_SCREEN) isSingleScreen: boolean = false;
  // 包含Grid的滚动条状态
  @State barState: BarState = BarState.Auto;
  @ObjectLink layout: FileListViewLayout;
  /**
   * 文件列表
   */
  @LocalStorageProp(LocalStorageConst.BOTTOM_NAV_BAR_HEIGHT) bottomNavBarHeight: number = 0;
  @Link @Watch('changeFileListSource') fileListSource: FileDataSource;
  @State groupDataSource: GroupDataSource = new GroupDataSource();
  /**
   * 共用的分组组名，根据分组列表顶部索引变化
   */
  @State sharedGroupName: string = '';
  // 来源页筛选过后的数据，包含文件数据和日期数据
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
  };
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
  /**
   * 监听键盘高度，滑动状态下隐藏键盘
   */
  @StorageProp('keyBoardHeight') keyBoardHeight: number = 0;
  /**
   * 是否需要显示已使用空间及文件个数
   */
  @Prop hasTotalCapacity: boolean = false;
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
  @Consume @Watch('onIsListChange') isListView: boolean;
  @Consume viewMode: string;
  @Consume operationType: string;
  @Consume('navMode') navMode: NavigationMode;
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
  @StorageLink('isNetwork') @Watch('onNetworkChange') isNetwork: boolean = true;
  @StorageProp('systemLanguage') @Watch('sysLanguageChange') sysLanguage: string = '';
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
  @State isShowCheckBox: boolean = false;
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
  private onDragJumpCallback: Function = () => {
    toast(DeviceConfig.getInstance().config.dragTip);
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
  @Prop pickerSortMenuArray: Array<TopMenuItem>;
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
  private isOutsideScreenDevice: boolean = DisplayUtil.isOutsideScreenDevice();
  @Consume @Watch('onIsOutsideFoldedChange') isOutsideFolded: boolean;
  @Prop isSuffixFilter: boolean = false; // 是否已开启过滤
  // 控制下拉显示文件项数
  @State isShowFileCount: boolean = false;
  public onFilter: Function = () => {}; // 聚合视图点击过滤按钮回调
  private dragInfo = GlobalHolder.getInstance().getObject<string>(GlobalKey.DRAG_INFO_TIME) ?? '';
  @State noContentDescription: string | undefined = undefined;
  @Prop rootYOffset: number = 0;
  @Prop rootYOffsetIndex: number = 0;
  public persistentViewModeHabit: Function = (viewMode: string) => {}; // 持久化视图习惯

  @Consume @Watch('previewFileUriChange') previewFileUri: string;
  @Prop isShowLocateAni: boolean = false;
  @Consume isVerticalTabBar: boolean;

  @State bottomAvoidHeight: Length = 0;
  private bottomWaitTimeoutId: number = -1;
  @State isShowSourceMixView: boolean = false;
  // 在页面显示时跳到对应文件的索引
  private goToSourceFileIndex: number = 0;
  isQueryTotalEndOrCurrentFileFound: () => boolean = () => {
    return false;
  };

  // 要跳到文件的uri
  goToCurrentUri: string = '';

  // 跳到当前文件的次数
  private jumpToCurrentUriTimes = 0;

  showHiddenItemChanged(): void {
    this.showHiddenItemStatus = this.showHiddenItem;
  }

  // 当需要高亮的时候，立马执行一次滚动，以免List或者Grid不刷新的时候，没有走onAttach内的滚动
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

  onNetworkChange() {
    if (!this.isNetwork) {
      HiLog.warn(TAG, 'lost net');
      EventBus.emit(Constant.EVENTS.CLOSE_DOWNLOAD_PROGRESS_DIALOG);
      EventBus.emit(Constant.EVENTS.CANCEL_DOWNLOAD_PROGRESS_DIALOG);
    }
  }

  onIsOutsideFoldedChange(): void {
    this.setGroupFilesData();
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

  needShowGroupListView(): boolean {
    return this.inOtherShowGroupView();
  }

  // 其他模式且处于列表模式且非第一层目录，聚合试图的压缩预览没有使用分组列表显示的
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
      HiLog.info(TAG, `getFileOrGroups, groupName: ${groupItem.groupNameStr}, itemCount : ${groupItem.groupItemCount}`);
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
        indexMap.set(fileCount, fileOrGroups.length - 1);
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

    this.gridLayoutOptions.irregularIndexes = this.getIrregularIndexes();
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
    this.updateTimer = new Date().valueOf();
    // 若数据源有变更时若已开始滑动多选则需要重新获取所有的文件袋选中状态
    if (this.startIndex > -1) {
      this.oldCheckList = this.fileListSource.getDataArray().map(it => it.isChecked);
    }
    // 更新需要占一整行的GridItem的Index
    this.gridLayoutOptions.irregularIndexes = this.getIrregularIndexes();
    this.setGroupFilesData();
  }

  getIrregularIndexes(): number[] | undefined {
    if (this.fileGridDataSource && this.fileGridDataSource.totalCount() > 0) {
      return [this.fileGridDataSource.totalCount()];
    }
    if (this.fileListSource && this.fileListSource.totalCount() > 0) {
      return [this.fileListSource.totalCount()];
    }
    return undefined;
  }

  aboutToAppear(): void {
    HiLog.info(TAG, 'aboutToAppear ' + this.pageName);
    this.showHiddenItemStatus = this.showHiddenItem;
    AppStorage.delete(ROOT_TITLE_OFFSET);
    // 初始化需要占一整行的GridItem的Index
    this.gridLayoutOptions.irregularIndexes = this.getIrregularIndexes();
    if (this.isOutsideScreenDevice) {
      this.isNeedToUpdateScroll = true;
    }
    if (this.fileListSource.dataCount > 0) {
      this.setGroupFilesData();
    }

    EventBus.on(Constant.EVENTS.BOTTOM_BAR_ITEM_CLICK, this.bottomBarClickCallback);
    EventBus.on(Constant.EVENTS.WINDOW_STAGE_EVENT, this.windowStageChange);
    EventBus.on(Constant.EVENTS.UPDATE_FILE_ITEM_IN_GROUP, this.updateFileItemInGroup);
  }

  aboutToDisappear(): void {
    HiLog.info(TAG, 'aboutToDisappear');
    // 退出界面时, 需要清掉过滤类型,保证下次进来初始化时不会直接过滤导致数据异常
    EventBus.off(Constant.EVENTS.BOTTOM_BAR_ITEM_CLICK, this.bottomBarClickCallback);
    EventBus.off(Constant.EVENTS.WINDOW_STAGE_EVENT, this.windowStageChange);
    EventBus.off(Constant.EVENTS.UPDATE_FILE_ITEM_IN_GROUP, this.updateFileItemInGroup)
    this.listScrollerMap.clear();
  }

  updateFileItemInGroup: (originalIndex: number) => void = (originalIndex: number) => {
    HiLog.info(TAG, `updateFileItemInGroup, originalIndex : ${originalIndex}`);
    if (originalIndex < 0 || originalIndex >= this.fileListSource.getDataArray()?.length) {
      HiLog.warn(TAG, `updateFileItemInGroup failed, invalid index`);
      return;
    }
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

  onListOrGirdDidScroll(scroller: Scroller): void {
    try {
      this.listYOffset = scroller.getItemRect(this.scrollStartIndex).y;
    } catch (e) {
      this.listYOffset = 0;
      const error: BusinessError = e as BusinessError;
      HiLog.error(TAG, `getItemRect error, code: ${error.code} message: ${error.message}`);
    }
  }

  // 滑动吸顶显示时间
  @Builder
  dataCeiling() {
    if (!this.isGridColumn) {
      Row() {
        Text(this.sharedGroupName || ' ')
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize(14)
          .lineHeight(16)
          .fontColor($r('sys.color.font_secondary'))
          .width('100%')
          .padding({ start: LengthMetrics.vp(16), top: LengthMetrics.vp(4), bottom: LengthMetrics.vp(4) })
          .backgroundColor(this.startModeOptions.pickerFlag ? $r('sys.color.ohos_id_color_panel_bg') :
            $r('sys.color.ohos_id_color_sub_background')) // 和页面背景色保持一致
          .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr)
      }
    }
  }

  build() {
    Column() {
      if (this.pageName === PAGE_ROUTE_CONST.RECENT_DELETE) {
        this.showRecentDeleteTip();
      }
      if (this.layout.showFilterButton) {
        FileFilterScrollComp({
          currentFolder: this.curFolderUri,
          userState: $userState,
          isPickerFlag: this.startModeOptions.pickerFlag,
          sharedGroupName: this.sharedGroupName,
          isGridColumn: this.isGridColumn,
          isShowLoading: this.isShowLoading,
          bundleName: ''
        })
        this.dataCeiling()
      } else if (!this.isArchiveOrInArchive()) {
        ToolOperateArea({
          isFileSourceView: false,
          pageName: this.pageName,
          isPickerFlag: this.startModeOptions.pickerFlag,
          currentFolder: this.curFolderUri,
          onClickCallback: (operateType: ToolOperateType) => this.toolOperateAreaCallback(operateType),
          isSuffixFilter: this.isSuffixFilter,
          isShowLoading: this.isShowLoading,
          userState: this.userState
        })
          .flexShrink(0)
      }
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

  @Builder
  showRecentDeleteTip() {
    Text($r('app.string.recent_delete_file_save_day', Constant.DEFAULT_SAVE_DAY))
      .fontSize($r('sys.float.Body_M'))
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(FontWeight.Regular)
      .margin({
        left: $r('app.float.common_margin16'),
        right: $r('app.float.common_margin16'),
        top: $r('app.float.common_margin8')
      })
      // 限制适老化最大倍数
      .maxFontScale(Constant.BIG_MODE.BIG_MODE_1x)
      .alignSelf(ItemAlign.Start)
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
          this.autoFileListViewContent();
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
    .layoutWeight(1) // 避让stack底部组件
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
    } else if (this.isQueryEnd && !this.isLoading) {
      NoContent({
        pageName: this.pageName
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
        .padding({
          bottom: this.getPaddingHeight()
        })
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

  /**
   * list的底部偏移距离
   */
  getListEndOffset(): number {
    let h = this.getAvoidSafeScene() ? 0 : Constant.THREE_BUTTON_NAVIGATION_HEIGHT;
    if (this.navMode === NavigationMode.Split && this.userState === UserState.BROWSER &&
      !this.isShowBottomButton()) {
      h += UiUtil.getTabBarPadding(this.isVerticalTabBar, this.bottomNavBarHeight);
    }
    return h;
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
      color: $r('sys.color.comp_background_secondary'),
      startMargin: $r('app.float.common_margin68'),
      endMargin: $r('app.float.common_padding16')
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
    .scrollBarMargin({
      end: this.getScrollerMargin()
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
    .onDidScroll(() => this.onListOrGirdDidScroll(this.listScroller))
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
      if (this.isOutsideScreenDevice) {
        // 记录当前的位置
        AppStorage.setOrCreate(Constant.OUTSIDE_SCREEN_SCROLL_KEY, this.scrollStartIndex);
      }
      this.isScrollerAtEnd(this.listScroller);
    })
    .scrollBar(this.userState === UserState.MULTI_START ? BarState.Off : this.barState)
    .contentEndOffset(this.getListEndOffset())
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
        top: 16,
        bottom: 8
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
      PanGesture({ direction: PanDirection.Vertical })
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
    .scrollBarMargin({
      end: this.getScrollerMargin()
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
    .onDidScroll(() => this.onListOrGirdDidScroll(this.listScroller))
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
      if (this.isOutsideScreenDevice) {
        // 记录当前的位置
        AppStorage.setOrCreate<number>(Constant.OUTSIDE_SCREEN_SCROLL_KEY, this.scrollStartIndex);
      }
      this.isScrollerAtEnd(this.listScroller);
    })
    .scrollBar(this.userState === UserState.MULTI_START ? BarState.Off : this.barState)
    .contentEndOffset(this.getListEndOffset())
  }

  // 包含pick 分屏场景 多选
  getAvoidScene(): boolean {
    return (this.startModeOptions.pickerFlag || this.navMode === NavigationMode.Split ||
      this.userState === UserState.MULTI_START);
  }

  // 包含pick 分屏场景 多选
  getAvoidSafeScene(): boolean {
    return (this.getAvoidScene());
  }

  // 接续内外屏的滚动条
  updateScrollPosition(): void {
    // 若是高亮跳转此处无需再对Scroll进行跳转
    if (this.isNeedToUpdateScroll && !this.needHighlight) {
      let timeOutBox = setTimeout(() => {
        const outsideScrollStartIndex = AppStorage.get<number>(Constant.OUTSIDE_SCREEN_SCROLL_KEY) ?? 0;
        // 默认顶部，无需滚动
        if (outsideScrollStartIndex !== 0) {
          this.listScroller.scrollToIndex(outsideScrollStartIndex, false, ScrollAlign.START);
          this.gridScroller.scrollToIndex(outsideScrollStartIndex, false, ScrollAlign.START);
        }
        clearTimeout(timeOutBox);
      }, 50)
      this.isNeedToUpdateScroll = false;
    }
  }

  /**
   * 滑动多选操作
   */
  panGestureActionInGroup(type: SlideActionType, event: GestureEvent | undefined,
    scroller: Scroller | undefined, isSourceMix: boolean = false): void {
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
        // index为-1存在手指位置处于最下方/最上方没有被正确计算索引的情况，需要根据手指位置以及组件宽度高度，再次计算一次当前手势所处于的组件索引
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
  panGestureAction(
    type: SlideActionType,
    event: GestureEvent | undefined,
    scroller: Scroller | undefined,
    isListScroller: boolean
  ): void {
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
        const visibleListContentInfo = (scroller as ListScroller).getVisibleListContentInfo(finger.localX, finger.localY);
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
    const list: FileInfo[] = this.fileListSource.getDataArray();
    if (index < 0 && index >= list.length) {
      HiLog.warn(TAG, `invalid index, index: ${index}, length: ${list.length}`);
      return;
    }
    this.oldCheckList = list.map(it => it.isChecked);
    const targetFile = list[index];
    if (!targetFile) {
      HiLog.warn(TAG, `targetFile is undefind`);
      this.canSlideSelect = false;
      return;
    }
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
      if (!this.getAvoidSafeScene()) {
        GridItem().height(Constant.THREE_BUTTON_NAVIGATION_HEIGHT)
      }
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
    .scrollBarMargin({
      end: this.getScrollerMargin()
    })
    .accessibilityLevel(ACCESSIBILITY_LEVEL.NO)
    .gridViewFancy()
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .cachedCount(3)
    .columnsTemplate(this.getColumnsTemplate())
    .columnsGap(this.gridCompactLayout ? $r('app.float.common_padding2') : $r('app.float.common_size4'))
    .rowsGap(this.gridCompactLayout ? $r('app.float.common_padding2') : $r('app.float.common_size8'))
    .onReachStart(() => this.listPosition = ScrollPosition.start)
    .onReachEnd(() => this.listPosition = ScrollPosition.end)
    .onScrollIndex((start, end) => {
      this.scrollStartIndex = start;
      this.scrollEndIndex = end;
    })
    .onDidScroll(() => this.onListOrGirdDidScroll(this.gridScroller))
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
    .onScrollFrameBegin((offset: number, state: ScrollState) => {
      return this.onScrollFrameChange(offset, this.gridScroller.currentOffset()?.yOffset);
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
      if (this.isOutsideScreenDevice) {
        // 记录当前的位置
        AppStorage.setOrCreate(Constant.OUTSIDE_SCREEN_SCROLL_KEY, this.scrollStartIndex);
      }
      this.isScrollerAtEnd(this.gridScroller);
    })
    .scrollBar(this.barState)
  }

  @Builder
  rootFileCount() {
    if (this.hasTotalCapacity) {
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
      .constraintSize({
        minHeight: $r('app.float.common_size40')
      })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .margin({
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
      .constraintSize({
        minHeight: 40
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
      onDragJumpCallback: this.onDragJumpCallback,
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
      onDragJumpCallback: this.onDragJumpCallback,
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
      isShowLocateAni: this.isShowLocateAni
    })
      .reuseId(reuseId);
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
        top: 16,
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
    .onAttach(() => {
      this.updateScrollPosition();
      this.jumpToFocusFile();
      this.isScrollerAtEnd(this.listScroller);
    })
    .onAreaChange((oldVal, newVal) => {
      this.listWidth = newVal.width as number;
      this.areaY = newVal.globalPosition.y as number;
      this.contentHeight = newVal.height as number;
      this.contentWidth = this.listWidth;
    })
    .onTouchIntercept((event: TouchEvent) => {
      if (event.touches && event.touches.length > 1) {
        return HitTestMode.Block;
      }
      return HitTestMode.Transparent;
    })
  }

  /**
   * 是否显示底部的迁入按钮
   * @returns
   */
  isShowBottomButton(): boolean {
    return !this.startModeOptions.pickerFlag && this.userState !== UserState.MULTI_START
  }
  /**
   * 获取底部的内边距
   */
  getPaddingHeight(): number {
    return this.navMode === NavigationMode.Split && this.userState === UserState.BROWSER && !this.isShowBottomButton() ?
    UiUtil.getTabBarPadding(this.isVerticalTabBar, this.bottomNavBarHeight) : 0;
  }

  /**
   * 获取滚动条的偏移距离
   */
  getScrollerMargin(): LengthMetrics {
    return LengthMetrics.vp(this.userState === UserState.MULTI_START || this.startModeOptions.isUxt() ||
    this.isShowBottomButton() || this.navMode === NavigationMode.Stack ? 0 :
      (this.isVerticalTabBar ? TabBarStyle.SINGLE_SCREEN_HEIGHT :
      TabBarStyle.FOLD_EXPANDED_HEIGHT) + this.bottomNavBarHeight)
  }

  @Styles
  gridViewFancy() {
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .visibility(this.listScrollShow ? Visibility.Visible : Visibility.Hidden)
    .align(Alignment.TopStart)
    .padding({
      left: this.gridCompactLayout ? 0 : $r('app.float.common_padding12'),
      right: this.gridCompactLayout ? 0 : $r('app.float.common_padding12'),
      bottom: this.getPaddingHeight()
    })
    .bindContextMenu(this.longPressBlankMenu, ResponseType.LongPress, {
      aboutToAppear: this.menuAboutToAppear()
    })
    .bindContextMenu(this.longPressBlankMenu, ResponseType.RightClick, {
      aboutToAppear: this.menuAboutToAppear()
    })
    .onAttach(() => {
      this.updateScrollPosition();
      this.jumpToFocusFile();
      this.isScrollerAtEnd(this.gridScroller);
    })
    .onAreaChange((oldVal, newVal) => {
      let y = newVal.globalPosition.y as number;
      let height = newVal.height as number;
      let width = newVal.width as number;
      this.areaY = y;
      this.contentHeight = height;
      this.contentWidth = width;
    })
    .onTouchIntercept((event: TouchEvent) => {
      if (event.touches && event.touches.length > 1) {
        return HitTestMode.Block;
      }
      return HitTestMode.Transparent;
    })
  }

  @Styles
  dragManager() {
    .allowDrop(this.isAllowDrop() ? Constant.ALLOW_DROP.ALL_FILE : Constant.ALLOW_DROP.NONE)
    .onDrop((event: DragEvent, extraParam?: string) => {
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
      let dragStatus = AppStorage.get<boolean>('dragStatus');
      if (!dragStatus) {
        event.setResult(DragResult.DROP_ENABLED);
      } else {
        event.setResult(this.isAllowDrop() && this.curFolderUri !== DragManager.getInstance().dragStartFolderUri ?
        DragResult.DROP_ENABLED : DragResult.DROP_DISABLED);
      }
    })
  }

  // 选中文件
  checkedNumChange(fromSource: string): void {
    HiLog.info(TAG,
      `checked num change checkedNum:${this.checkedNum}, allCheckedNum: ${this.allCheckedNum}, source: ${fromSource}`);
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

  private toolOperateAreaCallback(operateType: ToolOperateType): void {
    switch (operateType) {
      case ToolOperateType.NEW_FOLDER:
        HiLog.infoPrivate(TAG, 'create folder', `, curFolder uri : ${this.curFolderUri}`);
        EventBus.emit(Constant.EVENTS.SHOW_NEW_FOLDER_DIALOG,
          this.fileListSource.getAllFolderName(), this.curFolderUri, (folderName: string) => {
            HiLog.info(TAG, 'SHOW_NEW_FOLDER_DIALOG callback.');
            if (this.pageName === PAGE_ROUTE_CONST.MY_PHONE) {
              EventBus.emit(Constant.EVENTS.ADD_NEW_FOLDER, folderName);
            } else {
              AppStorage.setOrCreate<boolean>(Constant.REFRESH_PAGE, !AppStorage.get<boolean>(Constant.REFRESH_PAGE));
            }
            UEUtil.reportCreateNewFolder(this.getUEPageName(), this.startModeOptions.pickerFlag);
          });
        break;
      case ToolOperateType.VIEW_CHANGE_LIST:
        this.setGridOrListView(ViewMode.LIST);
        break;
      case ToolOperateType.VIEW_CHANGE_GRID:
        this.setGridOrListView(ViewMode.GRID);
        break;
      case ToolOperateType.CLEAR_FILES:
        if (this.fileListSource.totalCount() !== 0) {
          EventBus.emit(Constant.EVENTS.SHOW_CLEAR_ALL_FILES_DIALOG,
            this.fileListSource.getDataArray());
          return;
        }
        toast($r('app.string.no_recent_delete_file'));
        break;
      case ToolOperateType.FILES_FILTER:
        this.onFilter();
        break;
      default:
        break;
    }
  }

  private setGridOrListView(viewMode: string): void {
    HiLog.warn(TAG, `view change : ${viewMode}`);
    HiSysEventUtil.reportFileViewChange(this.viewMode, viewMode,
      this.startModeOptions.pickerFlag ? AbilityName.FILE_PICKER : AbilityName.FILE_MANAGER);
    UEUtil.reportFileViewChange(EnumTransferUtil.transferToViewMode(this.viewMode),
      EnumTransferUtil.transferToViewMode(viewMode), EnumTransferUtil.transferToPageName(this.pageName),
      this.startModeOptions.pickerFlag);
    this.viewMode = viewMode;
    this.isListView = viewMode === ViewMode.LIST;
    this.persistentViewModeHabit(this.viewMode);
    this.fileListSource.notifyDataReload();
  }

  /**
   * 根据滚动范围查找索引
   * @param finger 手指信息
   * @param scroller 滚动器
   * @returns 索引
   */
  private findIndexByScrollRange(finger: FingerInfo, scroller: Scroller): number {
    const item: RectResult = scroller.getItemRect(this.updateIndex);
    if (!item) {
      return -1;
    }
    // 向下滚动: 只要手指y轴超过当前update索引组件的y+height，并且当前更新索引非最大值，就提供下一个idx
    if (this.scrollDir === SCROLL_DIR.BOTTOM && finger.localY > item.y + item.height &&
      this.updateIndex < this.scrollEndIndex) {
      return this.updateIndex + 1;
    }
    // 向上滚动: 手指y轴小于当前update索引组件的y，并且当前索引大于最小值，就提供上一个idx
    if (this.scrollDir === SCROLL_DIR.TOP && finger.localY < item.y && this.updateIndex > this.scrollStartIndex) {
      return this.updateIndex - 1;
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
   * 通过scrollTo与面包屑实现返回上次进入位置，在组件树挂载的时候绑定，避免出现生硬跳转
   */
  private onDireListChange() {
    HiLog.info(TAG, `DireListChange`);
    this.jumpToFocusFile();
  }

  private isAllowTitleOffset() {
    return this.fileListSource.totalCount() &&
    this.hasTotalCapacity && this.direList.length == 0;
  }

  /**
   * 通过scrollToIndex实现宫格列表视图间切换时可视区域内显示的文件保持不变
   */
  private onIsListChange(): void {
    HiLog.info(TAG, `onIsListChange is ${this.isListView}`);
    setTimeout(() => {
      if (this.isListView) {
        this.listScroller.scrollToIndex(this.scrollStartIndex, false, ScrollAlign.START);
      } else {
        this.gridScroller.scrollToIndex(this.scrollStartIndex, false, ScrollAlign.START);
      }
    }, 20);
    this.setGroupFilesData();
    this.listYOffset = 0;
  }

  private onScrollFrameChange(offset: number, currentOffset: number): OffsetRemainParam {
    // 向下拖动显示文件数目
    if (!this.isShowFileCount && currentOffset && currentOffset <= 0 && offset < 0) {
      this.isShowFileCount = true;
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
   * 滚动界面到指定的位置。
   * 1.滚动到指定的文件（Index）位置：
   *  1.1 单文件 - 滚动到该文件处于屏幕中的位置。
   *  1.2 多文件 - 滚动到使得uriArray中的第一个文件处于屏幕中的位置。
   * 2.滚动到指定的偏移量
   *
   * @returns
   */
  private jumpToFocusFile(): void {
    HiLog.info(TAG, 'jumpToFocusFile');
    // 从最近点击卡片右上角xx项，跳至来源对应位置
    if (!StringUtil.isEmpty(this.goToCurrentUri)) {
      HiLog.info(TAG, `scroll to index : ${this.goToSourceFileIndex}`);
      if (this.fileListSource.dataReceStatus.status === DataStatus.END) {
        HiLog.info(TAG, 'jump to goToCurrentUri, set it blank.');
        this.goToCurrentUri = '';
      }
      this.jumpToCurrentUriTimes++;
      this.listScroller.scrollToIndex(this.goToSourceFileIndex, false, ScrollAlign.START);
      this.scrollStartIndex = this.goToSourceFileIndex;
      if (this.isOutsideScreenDevice) {
        // 记录当前的位置
        AppStorage.setOrCreate<number>(Constant.OUTSIDE_SCREEN_SCROLL_KEY, this.scrollStartIndex);
      }
      return;
    }

    this.isShowFileCount = false;
    // 跳转首先判断需不需要高亮，文件夹进出位置记录的场景不需要高亮
    if (this.needHighlight) {
      const uri: string = GlobalHolder.getInstance().getObject<string>(GlobalKey.URI_PATH) ?? '';
      const uriArray: string[] = GlobalHolder.getInstance().getObject<string []>(GlobalKey.FILE_URI_ARRAY) ?? [];
      const index = uriArray.length ? this.fileListSource.getIndex(uriArray[0]) : this.fileListSource.getIndex(uri);
      HiLog.info(TAG, `jumpToFocusFile() - index:${index}`);
      if (this.isListView) {
        this.listScroller.scrollToIndex(index, false, ScrollAlign.CENTER);
      } else {
        this.gridScroller.scrollToIndex(index, false, ScrollAlign.CENTER);
      }
    } else {
      let yOffset: number = 0;
      let yIndex: number = 0;
      if (ArrayUtil.isEmpty(this.direList)) {
        yOffset = this.rootYOffset;
        yIndex = this.rootYOffsetIndex;
      } else {
        yOffset = this.direList[this.direList.length - 1].yOffset;
        yIndex = this.direList[this.direList.length - 1].startFileIndex;
      }
      if (this.isListView) {
        if (this.isAllowTitleOffset()) {
          this.totalScroller.scrollBy(0, AppStorage.get<number>(ROOT_TITLE_OFFSET) ?? 0);
        }
        this.listScroller.scrollToIndex(yIndex, false, ScrollAlign.START, { extraOffset: LengthMetrics.vp(-yOffset) });
      } else {
        if (this.isAllowTitleOffset()) {
          this.totalScroller.scrollBy(0, AppStorage.get<number>(ROOT_TITLE_OFFSET) ?? 0);
        }
        this.gridScroller.scrollToIndex(yIndex, false, ScrollAlign.START, { extraOffset: LengthMetrics.vp(-yOffset) });
      }
      HiLog.info(TAG, `listScrollShow end. yOffset: ${yOffset} yIndex: ${yIndex}`);
      this.scrollStartIndex = yIndex;
      this.listYOffset = yOffset;
      this.listScrollShow = true;
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
    let dragManger = DragManager.getInstance();
    HiLog.infoPrivate(TAG, `FileListView on drop page name: ${this.pageName}`,
      `targetFolderUri: ${this.curFolderUri}, dragStartFolderUri: ${dragManger.dragStartFolderUri}`);
    if (this.isAllowDrop()) {
      DragManager.getInstance().onDrop();
      let targetFolderName: string = FileUtil.getFileNameFromUri(this.curFolderUri);
      if (FileUtil.getParentUri(this.curFolderUri) === Constant.EXTERNAL_STORAGE_URI) {
        // 外设分区根目录的FileName存储的是uuid，显示名称实际为description
        targetFolderName = StorageDeviceManager.getInstance().getExternalStorageNameByUUID(targetFolderName);
      }
      this.onDropCallback(event, this.curFolderUri, targetFolderName, extraParam);
      return;
    } else {
      let dragStatus = AppStorage.get<boolean>('dragStatus');
      if (!dragStatus) {
        DragManager.getInstance().onDrop();
        this.onDragJumpCallback(event, extraParam);
      }
      return;
    }
  }

  /*
  * 是否滚到底部
  * */
  private isScrollerAtEnd(scroller: Scroller): void {
    if (scroller) {
      this.isScrollReachEnd = scroller.isAtEnd();
    }
  }

  private isArchiveOrInArchive() {
    return this.direList && this.direList.length > 0 &&
    FileUtil.isArchiveByUri(this.direList[this.direList.length - 1].uri)
  }

  private getColumnsTemplate() {
    if (this.gridCompactLayout) {
      return '1fr 1fr 1fr 1fr';
    }
    // 窗口尺寸小于600时，3行显示
    if (this.isSingleScreen) {
      return '1fr 1fr 1fr';
    }
    // 设置固定尺寸填充，避免当前组件窗口变更时，动效中出现突变
    return DeviceConfig.getInstance().config.gridColumnsTemplate;
  }

  private async initLongPressFileMenuShow(): Promise<void> {
    if (!PasteBoardUtil.checkUriData() || this.pageName === PAGE_ROUTE_CONST.RECENT_DELETE) {
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
