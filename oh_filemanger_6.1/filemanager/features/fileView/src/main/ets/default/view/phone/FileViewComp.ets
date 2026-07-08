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
  AccessibilityManager,
  AccessibilityStorageKey,
  AppDataPathUtil,
  BottomCallParams,
  CommonUtil,
  Constant,
  DeviceConfig,
  DFX,
  DisplayUtil,
  DragManager,
  EnumTransferUtil,
  ExternalStorageUtil,
  FileDataSource,
  FileInfo,
  FilePickerUtil,
  FileUtil,
  GlobalHolder,
  GlobalKey,
  HiLog,
  LocationType,
  MyPhoneConstant,
  ObjectUtil,
  PAGE_ROUTE_CONST,
  PhoneFilePickerUtil,
  RenameItem,
  StartModeOptions,
  StringUtil,
  toast,
  TraceUtils,
  UdmfUtils,
  UEUtil,
  UiUtil,
  UserState,
  VirtualUri
} from '@ohos/common';
import { PhoneItemViewModel } from '../../viewModel/PhoneItemViewModel';
import { LongPressFileMenu } from './LongPressFileMenu';
import { FileDeleteDialog } from '@ohos/customDialog/indexPhoneOnly';
import { systemFileDeleteDialog } from '@ohos/customDialog/src/main/ets/default/view/dialog/systemFileDeleteDialog';
import { CompId, VibrateType } from '@ohos/common/src/main/ets/const/CompId';
import { GridViewComp } from './GridViewComp';
import { inputMethod } from '@kit.IMEKit';
import { ListViewComp } from './ListViewComp';
import { DragPreview } from './basicComp/DragPreview';
import { componentUtils, display, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonModifier, ListItemModifier } from '../../viewModel/CustomedModifier';

const TAG = 'FileViewCompPhone';
const DELETE_SWIPE_HEAD_WIDTH: number = 72;
const DELETE_SWIPE_BODY_WIDTH: number = 123;
const ANGLE_RADIO: number = 10;
const MAX_HEAD_ANGLE: number = 17;
const BODY_HEAD_CRITICAL_ANGLE: number = 12;
const MAX_BODY_ANGLE: number = 10;
const ICON: string = 'Icon';
const DRAG_OPACITY = 0.95;

@Reusable
@Component({ freezeWhenInactive: true })
export struct FileViewComp {
  /**
   * 监听键盘高度，滑动状态下隐藏键盘
   */
  @StorageProp('keyBoardHeight') keyBoardHeight: number = 0;
  // 是否在无障碍阅读模式
  @StorageProp('isAccessibilityMode') isAccessibilityMode: boolean = false;
  private startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();
  private item: FileInfo = new FileInfo();
  // 是否是分组中的最后一个文件，控制分组模式下每组最后一个文件是否显示分隔符
  @State isLastInGroup: boolean = false;
  // 是否为列表视图
  @Consume isListView: boolean;
  @Prop isGridItem: boolean = false;
  // 列表item
  @State itemViewModel: PhoneItemViewModel = new PhoneItemViewModel(this.item);
  // 拖拽预开始标志
  @State isPreDrag: boolean = false;
  // 当前用户状态
  @Link @Watch('onUserStateChange') userState: UserState;
  // 选择文件个数
  @Link @Watch('checkedNumChange') checkedNum: number;
  // 滑动项发生变更
  @Prop @Watch('changeSelectIndex') updateIndex: number = -1;
  // 全选状态
  @Link isSelectAll: boolean;
  // 当前文件所在目录的uri
  @Link curFolderUri: string;
  // 文件列表所展示在的页面名
  @Prop pageName: string;
  @Prop gridCompactLayout: boolean;
  // 使能拖拽
  @Prop @Watch('enableDragChange') enableDrag: boolean = false;
  // 文件类表数据源(FileDataSource：非最近)
  @Link fileSource: FileDataSource;
  @State isChecked: boolean = false;
  // 是否拖拽到当前文件夹上
  @State isDropSelected: boolean = false;
  // 自动化所需index角标
  private compIdIndex: number = 0;
  // 是否显示最近访问时间, 由最外层page传进来，不需要手动刷新，对组件复用无影响
  private isShowRecentTime: boolean = false;
  // 是否展示文件来源, 由最外层page传进来，不需要手动刷新，对组件复用无影响
  private isShowFileSource: boolean = false;
  private iconId: string = '';
  // 由最外层page传进来，不需要手动刷新，对组件复用无影响
  private geometryId: string = '';
  // 点击文件事件的回调
  private onItemClick: Function = () => {
  };
  // 拖拽时drop文件回调
  private onDropCallback: Function = () => {
  };
  private onDragJumpCallback: Function = () => {
  };
  // ListItem左滑删除的回调
  private swipeDeleteDialogCallback: Function = (bottomCallParams: BottomCallParams) => {
  };
  // 横滑删除的文件
  private dragInfo: string = '';
  // 滑动删除是否需要进入最近删除选项, 外置存储界面不显示
  public isShowCheckBox: boolean = false;
  private swipeDeleteFileInfo: FileInfo = new FileInfo();
  @Link toOperateFileList: FileInfo[];
  @Prop disableSwipe: boolean = false;
  @State headAngle: number = 0;
  @State bodyAngle: number = 0;
  @State swipeScale: number = 1;
  private isCurFolderEnableDrop: boolean = true; // 判断该组件所在路径是否支持拖入
  // 获取当前分屏状态
  @StorageLink('windowStatus') @Watch('onWindowStatusChange') windowStatus: number =
    window.WindowStatusType.FULL_SCREEN;
  onSelectChanged: Function = (fileInfo: FileInfo) => {
  }
  // 鼠标左键是否按下,内部变量
  private mouseLeftPressed: boolean = false;
  @State showContextMenu: boolean = false;
  @State showGridIconMenu: boolean = false;
  @State isLongPress: boolean = false;
  @State listItemWidth: Length = $r('app.float.common_size288');
  @State gridItemSize: Length = $r('app.float.common_size88');
  // 横滑删除时，点击删除之后的弹窗
  private fileDeleteDialog: CustomDialogController = new CustomDialogController({
    builder: FileDeleteDialog({
      isShowCheckBox: this.isShowCheckBox,
      operationFileList: [this.swipeDeleteFileInfo],
      title: $r('app.plural.delete_confirm_dialog_title', 1, 1),
      content: this.getDeleteConfirmDialogContent(),
      confirmButtonText: $r('app.string.delete'),
      confirm: (isHardDelete: boolean): void => {
        this.fileDelete(isHardDelete);
        this.closeAllSwipeActions();
      }
    ,
      cancel: (): void => {
        this.closeAllSwipeActions();
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center
  });
  // 横滑删除系统文件时，点击删除之后的弹窗
  private systemFileDeleteDialog: CustomDialogController = new CustomDialogController({
    builder: systemFileDeleteDialog({
      content: $r('app.string.delete_system_file_tips'),
      buttonText: $r('app.string.confirm'),
      buttonFunc: (): void => {
        this.closeAllSwipeActions();
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center
  });

  // 横滑删除融合资产文件时，点击删除之后的弹窗
  private fusionAlbumDeleteDialog: CustomDialogController = new CustomDialogController({
    builder: FileDeleteDialog({
      content: $r('app.string.delete_fusion_album_warning'),
      confirmButtonText: $r('app.string.get_it'),
      title: $r('app.string.note'),
      isDeleteFusionAlbum: true,
      noCancelBtn: true,
      confirm: (): void => {
        this.closeAllSwipeActions();
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center
  });

  /**
   * 列表组件的scroller，用于滚动列表到指定位置
   */
  private listScroller: ListScroller = new ListScroller();
  @State isSwipeLeft: boolean = false;
  @Link needHighlight: boolean;
  // 当前获焦项的uri
  @Consume('currentNavItem') currentNavItem: string;
  // 分栏模式变更
  @Consume('navMode') @Watch('onNavModeChange') navMode: NavigationMode;
  @Link pickerCheckArr: string[] | undefined;
  @State isShowAlbumCover: boolean = false;
  @Consume @Watch('onIsOutsideFolded') isOutsideFolded: boolean;
  @State menuLayoutRegionMargin: Margin = {};
  @Prop isCardSelected: boolean = false;
  @Prop @Watch('onCardSelectChanged') cardSelectButtonClicked: boolean = false;
  public isBatchAuthPage: boolean = false;
  @Prop isShowLocateAni: boolean = false;
  private listItemModifier: ListItemModifier = new ListItemModifier();
  @State notShowPreviewer: boolean = false;
  private gridItemModifier: CommonModifier = new CommonModifier();
  private swipeAction: SwipeActionOptions = {}
  // 左滑时的回调
  private changeSwipeItem?: (key: string) => void = (key: string) => {
  };
  private isDraggable: boolean = false;
  // 避免dragpreviewoptions属性绑定checkedNum状态变量，导致每次checkednum变化整个节点属性进行属性
  // 只要保证拖拽的时候dragBadgeNumber正确就行，没必要绑定状态变量
  private dragBadgeNumber = this.checkedNum;

  closeAllSwipeActions(): void {
    try {
      this.listScroller.closeAllSwipeActions() //点击确认后，关闭左滑状态
    } catch (e) {
      let message = (e as BusinessError).message;
      HiLog.error(TAG, ' onCloseAllSwipe closeAllSwipeActions error ' + message);
    }
  }

  aboutToAppear(): void {
    this.itemViewModel = new PhoneItemViewModel(this.item);
    // 组件首次和复用的时候的共同初始化逻辑请写init方法里
    this.initStates();
    this.loadMenuLayoutRegionMargin();
    if (this.showListItem()) {
      this.swipeAction = this.updateSwipeAction();
    }
    this.isDraggable = this.itemViewModel.isDraggable(this.enableDrag, this.checkedNum);
  }

  aboutToReuse(params: Record<string, Object>): void {
    this.item = params?.item as FileInfo;
    this.itemViewModel.resetFileInfo(this.item);
    this.initStates();

    // 父组件传下来的非状态变量重新赋值
    this.listScroller = params?.listScroller as ListScroller ?? new ListScroller();
    this.isLastInGroup = params?.isLastInGroup as boolean ?? false;
    this.compIdIndex = params?.compIdIndex as number ?? 0;
    this.isCurFolderEnableDrop = params?.isCurFolderEnableDrop as boolean ?? false;

    // 需要重置的变量
    this.isPreDrag = false;

    // 属性刷新
    if (this.showListItem()) {
      this.updateListSwipeAction();
      this.listItemModifier.attribute?.id(this.getId());
    } else {
      this.gridItemModifier.attribute?.id(this.getId());
    }
    this.updateIsDraggable();
  }

  // 组件首次和复用的时候的共同初始化逻辑
  initStates(): void {
    this.isShowAlbumCover = !StringUtil.isEmpty(this.item.coverUri);
    this.iconId = this.item.uri + ICON;
    if (GlobalHolder.getInstance().getObject<number>(GlobalKey.DRAG_INFO_TIME)) {
      this.dragInfo = GlobalHolder.getInstance().getObject<string>(GlobalKey.DRAG_INFO_TIME);
    }
    this.notShowPreviewer = this.isNotShowPreview();
  }

  checkedNumChange() {
    this.updateIsDraggable();
    this.dragBadgeNumber = this.checkedNum;
  }

  enableDragChange() {
    this.updateIsDraggable();
  }

  getId() {
    return (this.startModeOptions.pickerFlag ? CompId.FILE_ITEM_PICKER : CompId.FILE_ITEM) +
    this.item.uri + this.pageName;
  }

  updateIsDraggable() {
    let oldDraggable = this.isDraggable;
    this.isDraggable = this.itemViewModel.isDraggable(this.enableDrag, this.checkedNum);
    if (oldDraggable !== this.isDraggable) {
      if (this.showListItem()) {
        this.listItemModifier.attribute?.draggable(this.isDraggable);
      } else {
        this.gridItemModifier.attribute?.draggable(this.isDraggable);
      }
    }
  }

  onIsOutsideFolded(): void {
    this.loadMenuLayoutRegionMargin();
  }

  onWindowStatusChange(): void {
    this.loadMenuLayoutRegionMargin();
  }

  loadMenuLayoutRegionMargin(): void {
    if (this.isOutsideFolded) {
      // 强制配置左右边距
      this.menuLayoutRegionMargin = {
        right: $r('app.float.common_size10'),
        left: $r('app.float.common_size10'),
        top: $r('app.float.common_size10'),
        bottom: $r('app.float.common_size10'),
      }
    } else if (this.windowStatus === window.WindowStatusType.SPLIT_SCREEN) {
      // 缩小顶部和底部边距
      this.menuLayoutRegionMargin = {
        right: $r('app.float.common_size16'),
        left: $r('app.float.common_size16'),
        top: $r('app.float.common_size0'),
        bottom: $r('app.float.common_size0'),
      }
    } else {
      this.menuLayoutRegionMargin = {
        right: $r('app.float.common_size16'),
        left: $r('app.float.common_size16'),
      }
    }
  }

  /**
   * 获取UE页面名称
   * @returns UE页面信息
   */
  getUEPageName(): DFX.PageName {
    if (ExternalStorageUtil.isExternalStorageUri(this.curFolderUri)) {
      return DFX.PageName.EXTERNAL;
    }
    return EnumTransferUtil.transferToPageName(this.pageName);
  }

  // 滑动多选时当前选中的值变更
  changeSelectIndex() {
    this.item.isChecked = (this.fileSource as FileDataSource).getFileInfoCheckStatus(this.item.uri);
    if (this.userState === UserState.MULTI_START && this.itemViewModel.isChecked !== this.item.isChecked) {
      this.itemViewModel.isChecked = this.item.isChecked;
      if (this.itemViewModel.filePickerViewFlag && this.pickerCheckArr) {
        if (this.itemViewModel.isChecked) {
          // 增加uri去重判断，重复uri不添加
          if (!this.pickerCheckArr.includes(this.item.uri)) {
            this.pickerCheckArr.push(this.item.uri);
          }
        } else {
          const index: number = this.pickerCheckArr.findIndex((uri: string) => {
            return uri === this.item.uri;
          });
          // 避免查询不到uri，返回-1后删除其他uri导致数据对不上
          if (index > -1) {
            this.pickerCheckArr.splice(index, 1);
          }
        }
      }
    }
  }

  showListItem(): boolean {
    // 其它视图 从全局isListView取值
    return this.isListView;
  }

  build() {
    if (this.showListItem()) {
      this.ListItemView();
    } else {
      this.gridItemView();
    }
  }

  @Builder
  gridItemView() {
    // 禁用长按文件弹出预览菜单
    if (this.notShowPreviewer) {
      GridItem() {
        this.atomisticGridFileItem()
      }
      .fileViewBuilder()
      .gridViewBuilder()
      .selected(this.itemViewModel.isChecked)
      .dragManage()
      .filePickerBindMenuStyles()
      .attributeModifier(this.gridItemModifier)
      .accessibilityDescription(this.isAccessibilityMode ? this.getNotShowPreviewDescription() : undefined)
    } else {
      GridItem() {
        this.atomisticGridFileItem()
      }
      .dragManage()
      .bindMenuStyles()
      .fileViewBuilder()
      .gridViewBuilder()
      .attributeModifier(this.gridItemModifier)
      .selected(this.itemViewModel.isChecked || this.isChecked) // 无障碍模式播报已选中
      .accessibilityDescription(undefined)
    }
  }

  @Styles
  filePickerBindMenuStyles(){
    .gesture(
      LongPressGesture()
        .onAction(() => {
          if (this.startModeOptions.pickerFlag) {
            return;
          }
          if (FileUtil.isGalleryFolder(this.item)) {
            toast($r('app.string.not_support_modified_directory'));
            return;
          } else if (this.item.isFusionAlbum) {
            toast($r('app.string.not_support_modified_directory'));
            return;
          }
        })
    )
  }

  @Builder
  ListItemView() {
    // 禁用长按文件弹出预览菜单
    if (this.notShowPreviewer) {
      this.listNotShowPreview();
    } else {
      this.listShowPreview();
    }
  }

  @Builder
  listNotShowPreview() {
    ListItem() {
      this.atomisticListFileItem()
    }
    .margin({ left: $r('app.float.common_margin8'), right: $r('app.float.common_margin8') })
    .fileViewBuilder()
    .dragManage()
    .selected(this.itemViewModel.isChecked) // 无障碍模式播报已选中
    .swipeAction(this.swipeAction)
    .attributeModifier(this.listItemModifier)
    .filePickerBindMenuStyles()
    .borderRadius($r('app.float.common_borderRadius16'))
    .accessibilityDescription(this.isAccessibilityMode ? this.getNotShowPreviewDescription() : undefined)
  }

  @Builder
  listShowPreview() {
    ListItem() {
      Column() {
        this.atomisticListFileItem();
      }
    }
    .margin({ left: $r('app.float.common_margin8'), right: $r('app.float.common_margin8') })
    .dragManage()
    .onTouch((event: TouchEvent) => {
      this.isPreDrag = true;
    })
    .dragPreview(this.isPreDrag ? this.dragViewBuilder() : undefined)
    .fileViewBuilder()
    .selected(this.itemViewModel.isChecked) // 无障碍模式播报已选中
    .swipeAction(this.swipeAction)
    .attributeModifier(this.listItemModifier)
    .bindMenuStyles()
    .borderRadius($r('app.float.common_borderRadius16'))
  }

  @Styles
  gridViewBuilder() {
    .onTouch((event: TouchEvent) => {
      // 触摸时关闭键盘
      try {
        if (this.keyBoardHeight > 0) {
          inputMethod.getController().hideTextInput();
        }
      } catch (err) {
        HiLog.info(TAG, 'FileItem close keyboard err');
      }
      if (this.isSwipeLeft) {
        this.itemViewModel.bgColor = $r('app.color.transparent_color');
        return;
      }
    })
    .borderRadius(this.getGridBorderRadius())
  }

  getGridBorderRadius() {
    const shouldUseRadius: boolean = this.isShowAlbumCover || !this.gridCompactLayout;
    return shouldUseRadius ? $r('sys.float.corner_radius_level10') : 0;
  }

  @Styles
  fileViewBuilder() {
    .transition(!this.isShowLocateAni ? TransitionEffect.IDENTITY :
    TransitionEffect.asymmetric(TransitionEffect.scale({ x: 0, y: 0 })
      .combine(TransitionEffect.opacity(0)).animation({ duration: 300, curve: Curve.Sharp }),
      TransitionEffect.scale({ x: 0.75, y: 0.75 })
        .combine(TransitionEffect.opacity(0)).animation({ duration: 300, curve: Curve.Sharp })))
    .stateStyles({
      selected: this.selectStyles,
      normal: this.selectStyles
    })
    .opacity(this.getFileItemOpacity())
    .id((this.startModeOptions.pickerFlag ? CompId.FILE_ITEM_PICKER : CompId.FILE_ITEM) +
    this.item.uri + this.pageName)
    .backgroundColor(this.checkNeedHighlight() ? $r('sys.color.interactive_pressed') : this.itemViewModel.bgColor)
    .onClick(() => {
      if (this.isLongPress || this.showContextMenu) {
        HiLog.warn(TAG, 'fileViewBuilder onclick: longPress action');
        return;
      }
      if (this.isNotShowPreview()) {
        AccessibilityManager.getInstance().sendCustomIdFocusForAccessibility(
          (this.startModeOptions.pickerFlag ? CompId.FILE_ITEM_PICKER : CompId.FILE_ITEM) +
          this.itemViewModel.fileInfo.uri + this.pageName);
      }
      this.onClickEvent();
    })
    .parallelGesture(
      TapGesture()
        .onAction((event: GestureEvent) => {
        }), GestureMask.Normal)
    // 补充未选中状态
    .accessibilityChecked(this.isAccessibilityMode ? this.getAccessibilityChecked() : undefined)
  }

  @Builder
  renderSwipeBuilder(): void {
    if (this.isSwipeLeft) {
      Row() {
        this.stackBuilder()
      }
      .id('id_deleteFileInfo_img')
      .padding({
        top: 4,
        bottom: 4,
        right: 28,
        left: 16
      })
      .onAppear(() => {
        this.changeSwipeItem?.(this.item.uri);
      })
      .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
        let wid = newValue.width;
        this.headAngle = (Number(wid) - DELETE_SWIPE_HEAD_WIDTH) / DELETE_SWIPE_HEAD_WIDTH * ANGLE_RADIO;
        if (this.headAngle <= 0) {
          this.headAngle = 0;
        }
        if (this.headAngle >= MAX_HEAD_ANGLE) {
          this.headAngle = MAX_HEAD_ANGLE;
        }
        if (this.headAngle > BODY_HEAD_CRITICAL_ANGLE) {
          this.swipeScale = 1.05;
          this.bodyAngle = (Number(wid) - DELETE_SWIPE_BODY_WIDTH) / DELETE_SWIPE_BODY_WIDTH * ANGLE_RADIO;
        } else {
          this.bodyAngle = 0;
          this.swipeScale = 1;
        }
        if (this.bodyAngle > MAX_BODY_ANGLE) {
          this.bodyAngle = MAX_BODY_ANGLE;
          this.swipeScale = 1.05;
        }
        this.bodyAngle = (-1) * this.bodyAngle;
      })
      .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
      .justifyContent(FlexAlign.SpaceEvenly)
      .height('100%')
    }
  }

  @Builder
  stackBuilder() {
    Stack() {
      this.flexBuilder()
    }
    .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
    .borderRadius($r('sys.float.corner_radius_level10'))
    .height('40vp')
    .width('40vp')
    .scale({ x: this.swipeScale, y: this.swipeScale })
    .backgroundColor($r('sys.color.ohos_id_color_warning'))
    .onClick(() => {
      this.stackBuilderClickEvent();
    })
  }

  @Builder
  flexBuilder() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      Image($r('app.media.ic_delete_head'))
        .width('18vp')
        .rotate({
          x: 0,
          y: 0,
          z: 1,
          centerX: '100%',
          centerY: '100%',
          angle: this.headAngle,
        });
      Image($r('app.media.ic_delete_body'))
        .width('15vp')
        .rotate({
          x: 0,
          y: 0,
          z: 1,
          centerX: '100%',
          centerY: 0,
          angle: this.bodyAngle,
        });
    }
    .width($r('app.float.common_size40'))
    .height($r('app.float.common_line_height40'))
  }

  @Builder
  atomisticGridFileItem() {
    GridViewComp({
      geometryId: this.geometryId,
      filePickerViewFlag: this.startModeOptions.pickerFlag,
      itemViewModel: this.itemViewModel,
      userState: this.userState,
      onItemClick: this.onItemClick,
      isShowFileSource: this.isShowFileSource,
      isShowRecentTime: this.isShowRecentTime,
      gridCompactLayout: this.gridCompactLayout,
      isDropSelected: this.isDropSelected,
      iconId: this.iconId,
      index: this.compIdIndex,
      pageName: this.pageName,
      fileListSource: this.fileSource,
      toOperateFileList: this.toOperateFileList,
      checkedNum: this.checkedNum,
      isSelectAll: this.isSelectAll,
      isShowAlbumCover: this.isShowAlbumCover,
      curFolderUri: this.curFolderUri,
      showGridIconMenu: this.showGridIconMenu,
      menuLayoutRegionMargin: this.menuLayoutRegionMargin,
      isContextMenuForbidden: false,
      onLongClick: (emitLocation?: string) => this.onLongClick(emitLocation),
      enableDrag: this.enableDrag,
      dragStart: (event: DragEvent, extraParams?: string) => {
        return this.dragStart(event, extraParams);
      },
      dragEnd: (event?: DragEvent) => {
        return this.dragEnd(event);
      }
    })
  }

  @Builder
  dragViewBuilder() {
    Row() {
      DragPreview({
        isListView: this.showListItem(),
        itemViewModel: this.itemViewModel,
        filePickerViewFlag: this.startModeOptions.pickerFlag,
        pageName: this.pageName,
        isShowFileSource: this.isShowFileSource,
        isShowRecentTime: this.isShowRecentTime,
        gridCompactLayout: this.gridCompactLayout,
        isDropSelected: this.isDropSelected,
        isDragView: true
      })
    }
    .opacity(DRAG_OPACITY)
  }

  @Builder
  atomisticListFileItem() {
    ListViewComp({
      filePickerViewFlag: this.startModeOptions.pickerFlag,
      isPersistPermission: this.startModeOptions.isPersistPermission,
      itemViewModel: this.itemViewModel,
      userState: this.userState,
      pageName: this.pageName,
      onItemClick: this.onItemClick,
      isShowFileSource: this.isShowFileSource,
      isShowRecentTime: this.isShowRecentTime,
      isDropSelected: this.isDropSelected,
      iconId: this.iconId,
      fileListSource: this.fileSource,
      checkedNum: this.checkedNum,
      isSelectAll: this.isSelectAll,
      curFolderUri: this.curFolderUri,
      isBatchAuthPage: this.isBatchAuthPage,
      isFileSourceView: false,
      isLongPress: this.isLongPress
    })
      .onTouch((event: TouchEvent) => {
        // 触摸时关闭键盘
        try {
          if (this.keyBoardHeight > 0) {
            inputMethod.getController().hideTextInput();
          }
        } catch (err) {
          HiLog.info(TAG, 'FileItem close keyboard err');
        }
        if (this.isSwipeLeft) {
          this.itemViewModel.bgColor = $r('app.color.transparent_color');
          return;
        }
      })
  }

  @Builder
  LongPressFileMenu() {
    this.longPressFileMenuContent();
  }

  @Builder
  longPressFileMenuContent() {
    this.longPressMenu();
  }

  @Builder
  longPressMenu() {
    LongPressFileMenu({
      isOutsideFolded: this.isOutsideFolded,
      showContextMenu: this.showContextMenu,
      onLongPressClick: (emitLocation?: string) => {
        this.onLongClick(emitLocation)
      },
      pageName: this.pageName,
      fileInfo: this.itemViewModel.fileInfo,
      checkedNum: this.checkedNum,
      isChecked: this.itemViewModel.isChecked,
      geometryId: this.geometryId,
      isMulti: this.userState === UserState.MULTI_START,
      toOperateFileList: this.toOperateFileList,
    })
  }

  @Builder
  longPressPreview() {
    DragPreview({
      isListView: this.showListItem(),
      itemViewModel: this.itemViewModel,
      filePickerViewFlag: this.startModeOptions.pickerFlag,
      pageName: this.pageName,
      isShowFileSource: this.isShowFileSource,
      isShowRecentTime: this.isShowRecentTime,
      gridCompactLayout: this.gridCompactLayout,
      isDropSelected: this.isDropSelected,
      listItemWidth: this.listItemWidth,
      gridItemSize: this.gridItemSize
    })
  }

  @Styles
  selectStyles() {
    .backgroundColor(this.itemViewModel.bgColor)
  }

  @Styles
  bindMenuStyles() {
    .onMouse((event?: MouseEvent) => {
      // 鼠标左键按下的时候，不要弹出长按菜单，不要触发左滑删除
      if (event && event.button === MouseButton.Left) {
        this.mouseLeftPressed = true;
        this.disableSwipe = true;
      } else {
        this.mouseLeftPressed = false;
        this.disableSwipe = false;
      }
    })
    // 长按时延规范为500ms
    .parallelGesture(GestureGroup(GestureMode.Parallel,
      LongPressGesture({
        duration: this.getSelectedFileList().length === 1 ?
        Constant.LONG_PRESS_DELAY_TIME : Constant.MUL_LONG_PRESS_DELAY_TIME
      })
        .onAction(() => {
          this.isLongPress = !this.mouseLeftPressed; // 鼠标左键长按的时候，使能触发单击
          this.disableSwipe = true; // 长按的时候，禁止左滑
          if (!this.mouseLeftPressed) {
            if (this.showListItem() || this.itemViewModel.isChecked) {
              this.calcPreviewSize();
              this.showContextMenu = true;
            } else {
              this.showGridIconMenu = true;
            }
          }
        })
        .onActionEnd(() => {
          this.isLongPress = false;
          this.disableSwipe = false;
        })
        .onActionCancel(() => {
          HiLog.info(TAG, 'onActionCancel: receive touch cancel');
          this.isLongPress = false;
          this.disableSwipe = false;
        })
    ))
    .bindContextMenu(this.showContextMenu, this.LongPressFileMenu(), {
        preview: this.longPressPreview(),
        backgroundBlurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
        previewAnimationOptions: { scale: [1.0, this.showListItem() ? 0.9 : 1.0] },
        aboutToDisappear: () => {
          this.showContextMenu = false;
        },
        layoutRegionMargin: this.menuLayoutRegionMargin
      })
    .bindContextMenu(this.LongPressFileMenu(), ResponseType.RightClick, {
        preview: this.longPressPreview(),
        onAppear: () => {
          this.showContextMenu = true;
        },
        onWillDisappear: () => {
          this.showContextMenu = false;
        },
        previewAnimationOptions: { scale: [0.8, 1.0] }
      })
  }

  @Styles
  dragManage() {
    .dragPreview(this.iconId)
    .dragPreviewOptions({
      numberBadge: this.itemViewModel.isChecked ? this.dragBadgeNumber : 0,
      mode: DragPreviewMode.DISABLE_SCALE
    },
      { isMultiSelectionEnabled: true, defaultAnimationBeforeLifting: false })
    .allowDrop(this.userState === UserState.BROWSER && this.isAllowDrop() ?
    Constant.ALLOW_DROP.ALL_FILE : Constant.ALLOW_DROP.NONE
    )
    .draggable(this.isDraggable)
    .onDragStart((event: DragEvent): CustomBuilder | DragItemInfo => {
      return this.dragStart(event);
    })
    .onDragEnd((event?: DragEvent, extraParams?: string) => {
      this.dragEnd(event);
    })
    .onDrop((event: DragEvent, extraParams?: string) => {
      this.drop(event, extraParams);
    })
    .onDragEnter((event: DragEvent, extraParams: string) => {
      this.dragEnter(event, extraParams);
    })
    .onDragLeave((event: DragEvent, extraParams: string) => {
      this.dragLeave(event, extraParams);
    })
    .onDragMove((event: DragEvent, extraParams: string) => {
      this.dragMove(event, extraParams);
    })
  }

  onUserStateChange(): void {
    switch (this.userState) {
      case UserState.BROWSER:
        this.checkedNum = 0;
      case UserState.MOVE:
      case UserState.COPY:
        this.itemViewModel.isChecked = false;
        break;
      default:
        break;
    }
    if (this.showListItem()) {
      this.updateListSwipeAction();
    }
  }

  /**
   * 长按事件
   */
  onLongClick(emitLocation?: string): void {
    if (this.userState === UserState.MULTI_START && !this.itemViewModel.isChecked) {
      // 多选模式下长按未选中对象
      // 重置数据源所有fileInfo选中状态
      this.fileSource.selectAll(false);
      // 重置所有itemModel选中状态
      this.checkedNum = UiUtil.SELECT_NONE;
      this.updateCheckedInMulti();
    }
    if (this.userState === UserState.BROWSER) {
      if (!this.itemViewModel.fileInfo.isMultiEnable) {
        return;
      }
      this.userState = UserState.MULTI_START;
      // 无障碍不播报长按进入的多选状态
      if (AccessibilityManager.getInstance().getIsAccessibilityMode()) {
        AppStorage.setOrCreate<number>(AccessibilityStorageKey.MULTIPLE_CHOICE_KEY, 1);
      }
      if (emitLocation === Constant.EVENTS.LONG_PRESS_SELECT) {
        UEUtil.reportMultiSelect(DFX.OperateSource.PRESS_MENU, this.getUEPageName());
      }
      if (this.itemViewModel.filePickerViewFlag) {
        if (!PhoneFilePickerUtil.checkFileCanPick(
          this.itemViewModel.fileInfo, this.checkedNum, false, this.startModeOptions)) {
          return;
        }
      }
      if (!this.itemViewModel.showCheckBox()) {
        if (this.onItemClick) {
          this.onItemClick(this.itemViewModel.fileInfo, false);
        }
        return;
      }
      this.onClickEvent();
    } else if (this.userState === UserState.COPY) {
      // 文件复制场景长按文件状态
      this.updateSelectedInCopy();
    }
  }

  /**
   * 判断是否需要进入文件夹并操作
   */
  enterFolder(): void {
    if (this.itemViewModel.fileInfo.isFolder) {
      // 点击文件夹则进入文件夹
      this.onItemClick(this.itemViewModel.fileInfo, false);
    }
  }

  /**
   * 多选模式下文件选择状态切换
   */
  updateCheckedInMulti(): void {
    if (!this.itemViewModel.fileInfo.isMultiEnable) {
      HiLog.warn(TAG, 'updateCheckedInMulti: fileinfo isMultiUnable');
      return;
    }
    if (!this.itemViewModel.showCheckBox()) {
      HiLog.warn(TAG, 'updateCheckedInMulti: fileinfo showCheckBox false');
      if (this.onItemClick) {
        this.onItemClick(this.itemViewModel.fileInfo, false);
      }
      return;
    }

    const changeChecked = !this.itemViewModel.isChecked;
    HiLog.info(TAG, `datasource updateCheckStatus: ${changeChecked}`);
    (this.fileSource as FileDataSource).updateCheckStatus(this.itemViewModel.fileInfo.uri, changeChecked);
    this.itemViewModel.isChecked = changeChecked;
    this.itemViewModel.fileInfo.isChecked = changeChecked;
    // 选中
    if (this.itemViewModel.isChecked) {
      HiLog.info(TAG, 'updateCheckedInMulti pick num ' + this.checkedNum);
      if (this.itemViewModel.filePickerViewFlag && this.pickerCheckArr) {
        HiLog.info(TAG, `file already in arr: ${this.pickerCheckArr.includes(this.item.uri)}`);
        this.pickerCheckArr.push(this.item.uri);
        this.checkedNum = this.pickerCheckArr.length;
      } else {
        HiLog.info(TAG, `recentdatasource updateCheckStatus: ${changeChecked}`);
        this.checkedNum++;
      }
      return;
    }
    HiLog.info(TAG, 'remove Checked In Multi pick num: ' + this.checkedNum);
    // 移除选中
    if (this.itemViewModel.filePickerViewFlag && this.pickerCheckArr && this.pickerCheckArr.length > 0) {
      HiLog.info(TAG, 'splice uri in pickerCheckArr: ');
      const index: number = this.pickerCheckArr.findIndex((uri: string) => {
        return uri === this.item.uri;
      });
      this.pickerCheckArr.splice(index, 1);
      this.checkedNum = this.pickerCheckArr.length;
    } else if (this.checkedNum > 0) {
      this.checkedNum--;
    }
  }

  isPathSelection(): boolean {
    return (this.userState === UserState.COPY) || (this.userState === UserState.MOVE) ||
      (this.userState === UserState.SELECT_PATH);
  }

  onCardSelectChanged() {
    this.itemViewModel.isChecked = this.isCardSelected;
  }

  private updateListSwipeAction() {
    this.listItemModifier.attribute?.swipeAction(this.updateSwipeAction());
  }

  private updateSwipeAction(): SwipeActionOptions {
    let shouldDisableSwipe = this.disableSwipe ||
    AppStorage.has('dragStatus') ||
      this.itemViewModel.fileInfo.fileName === MyPhoneConstant.MY_PHONE_GALLERY ||
      this.itemViewModel.fileInfo.fileName === MyPhoneConstant.MY_PHONE_SOUND_RECORDER ||
      this.userState === UserState.MULTI_START
    return shouldDisableSwipe ? {} : {
      onOffsetChange: (offset: number) => {
        this.isSwipeLeft = offset < 0;
      },
      end: {
        builder: () => this.renderSwipeBuilder(),
        onAction: () => this.onActionOfSwipeAction(),
        actionAreaDistance: 56,
      }
    }
  }

  private stackBuilderClickEvent() {
    let dialogTimeout = setTimeout(() => {
      this.fileDeleteOperation(this.item);
      clearTimeout(dialogTimeout);
    }, 150);
  }

  private getFileItemOpacity(): Resource {
    if (this.itemViewModel.filePickerViewFlag) {
      const pickNum = this.pickerCheckArr?.length ?? this.checkedNum;
      return PhoneFilePickerUtil.checkFileCanPick(this.itemViewModel.fileInfo, pickNum, false, this.startModeOptions) ||
      this.itemViewModel.fileInfo.isFolder ? $r('app.float.common_opacity10') : $r('sys.float.ohos_id_alpha_disabled');
    }
    return $r('app.float.common_opacity10');
  }

  private checkNeedHighlight(): boolean {
    if (this.needHighlight) {
      const uri: string = GlobalHolder.getInstance().getObject<string>(GlobalKey.URI_PATH) ?? '';
      const uriArray: string[] = GlobalHolder.getInstance().getObject<string[]>(GlobalKey.FILE_URI_ARRAY) ?? [];
      // 高亮一群
      if (uriArray.length && uriArray.includes(this.itemViewModel.fileInfo.uri)) {
        return true;
      }
      // 只高亮一个
      if (!uriArray.length && uri && uri === this.itemViewModel.fileInfo.uri) {
        return true;
      }
    }
    return false;
  }

  private onNavModeChange(): void {
    this.itemViewModel.setBackGround(this.navMode, this.currentNavItem);
  }

  // 是否支持预览
  private isNotShowPreview(): boolean {
    // 浏览页搜索，已删除的文件，图库文件夹，大文件清理也不支持长按
    return this.startModeOptions.pickerFlag ||
      !this.item.isMultiEnable ||
      this.item.fileName === MyPhoneConstant.MY_PHONE_SOUND_RECORDER ||
      this.item.fileName === MyPhoneConstant.MY_PHONE_GALLERY ||
      this.item.isFusionAlbum;
  }

  private isDropEnable(): boolean {
    // 最近页的文件夹和搜索页的文件夹支持落入
    return (this.pageName === PAGE_ROUTE_CONST.MY_PHONE) &&
      (DragManager.getInstance().supportDrag(this.startModeOptions)) && this.enableDrag
  }

  private dragMove(event: DragEvent, extraParams: string): void {
    let dragStatus = AppStorage.get<boolean>('dragStatus');
    if (!dragStatus) {
      event.setResult(DragResult.DROP_ENABLED);
      return;
    }
    const isDropEnable: boolean = this.isDropEnable();
    if ((this.dragInfo !== JSON.parse(extraParams)?.extraInfo) && isDropEnable) {
      event.dragBehavior = DragManager.getInstance().isCanDrop(event) ? DragBehavior.COPY : DragBehavior.MOVE;
      event.setResult(DragResult.DROP_ENABLED);
      return;
    }
    if (isDropEnable) {
      event.dragBehavior = this.itemViewModel.fileInfo.isFolder ? DragBehavior.COPY : DragBehavior.MOVE;
      event.setResult(DragResult.DROP_ENABLED);
      return;
    }
    event.setResult(DragResult.DROP_DISABLED);
  }

  private dragLeave(event: DragEvent, extraParams: string): void {
    HiLog.info(TAG, 'onDragLeave');
    DragManager.getInstance().getDragFlag(event, extraParams, this.dragInfo);
    DragManager.getInstance().onDropLeaveAnimation((isSelect: boolean) => {
      this.itemViewModel.bgColor =
        isSelect ? $r('app.color.list_item_pressed_bg') : $r('app.color.transparent_color');
      this.isDropSelected = isSelect;
    })
  }

  private dragEnter(event: DragEvent, extraParams: string): void {
    if (!this.enableDrag && DragManager.getInstance().supportDrag(this.startModeOptions) ||
      !DragManager.getInstance().isCanDrop(event)) {
      return;
    }
    DragManager.getInstance().getDragFlag(event, extraParams, this.dragInfo);
    if (this.itemViewModel.fileInfo.isFolder && (this.userState === UserState.BROWSER)) {
      this.itemViewModel.bgColor = $r('app.color.list_item_pressed_bg');
      DragManager.getInstance().onDropEnterAnimation((isSelect: boolean) => {
        this.itemViewModel.bgColor =
          isSelect ? $r('sys.color.comp_emphasize_tertiary') : $r('app.color.transparent_color');
        this.isDropSelected = isSelect;
      }, () => {
        if (this.onItemClick) {
          this.onItemClick(this.itemViewModel.fileInfo);
        }
      })
    }
  }

  private drop(event: DragEvent, extraParams?: string): void {
    HiLog.info(TAG, 'onDrop');
    DragManager.getInstance().onDrop();
    this.itemViewModel.bgColor = $r('app.color.transparent_color');
    this.isDropSelected = false;
    let folderUri: string =
      this.itemViewModel.fileInfo.isFolder ? this.itemViewModel.fileInfo.uri : this.curFolderUri;
    HiLog.infoPrivate(TAG, 'drop callback',
      `targetFolderUri: ${folderUri}, dragStartFolderUri: ${DragManager.getInstance().dragStartFolderUri}`)
    if (this.isAllowDrop()) {
      if (this.userState !== UserState.BROWSER && this.userState !== UserState.MULTI_START) {
        HiLog.warn(TAG, 'is not browser or multiStart state, do not allow drop.');
        return;
      }
      this.onDropCallback(event, folderUri,
        this.itemViewModel.fileInfo.isFolder ? FileUtil.getFileNameFromUri(folderUri) : '', extraParams);
      return;
    } else {
      let dragStatus = AppStorage.get<boolean>('dragStatus');
      if (!dragStatus) {
        this.onDragJumpCallback(event, extraParams);
      }
      return;
    }
  }

  private dragEnd(event?: DragEvent): void {
    HiLog.info(TAG, 'onDragEnd');
    if (AppStorage.has('dragStatus')) {
      AppStorage.delete('dragStatus');
    }
    HiLog.info(TAG, 'onDropEnd');
    DragManager.getInstance().onDragEnd(event);
  }

  private dragStart(event: DragEvent, extraParams?: string): CustomBuilder | DragItemInfo {
    HiLog.info(TAG, 'onDragStart');
    UiUtil.touchVibrate(VibrateType.DRAG_UP);
    AppStorage.setOrCreate<boolean>('dragStatus', true);
    let selectedFileList: FileInfo[] =
      this.itemViewModel.isChecked ? this.fileSource.getSelectedFileList() : [this.itemViewModel.fileInfo];
    selectedFileList = selectedFileList.filter((item: FileInfo) => {
      return !MyPhoneConstant.isSystemFolder(ExternalStorageUtil.getParentUri(item.uri), item.fileName,
        item.isFolder) && !FileUtil.isGalleryFolder(item);
    });
    DragManager.getInstance().onDragStart(event, selectedFileList, this.curFolderUri);
    UEUtil.reportDragFile(DFX.DragType.DRAG_START, this.getUEPageName(), selectedFileList.length);

    // 单次拖拽超过2000个，拖拽不写拖拽框架
    if (selectedFileList.length > UdmfUtils.CROSS_DEVICE_DRAG_FILE_MAX_NUM) {
      return { extraInfo: UdmfUtils.DRAG_IN_THE_APP };
    }
    return { extraInfo: this.dragInfo };
  }

  private getSelectedFileList(): FileInfo[] {
    if (ObjectUtil.isNullOrUndefined(this.itemViewModel.fileInfo)) {
      HiLog.warn(TAG, 'getSelectedFileList, fileInfo is null');
      return [];
    }
    return this.itemViewModel.fileInfo.isChecked ? this.fileSource.getSelectedFileList() :
      [this.itemViewModel.fileInfo];
  }

  /**
   * 复制模式下文件选择状态切换
   */
  private updateSelectedInCopy(): void {
    this.fileSource.deSelectedFileList();
  }

  /**
   * 单击事件
   */
  private onClickEvent(): void {
    HiLog.infoPrivate(TAG, 'onClickEvent: ', this.itemViewModel.fileInfo.uri);
    if (this.itemViewModel.filePickerViewFlag) {
      // 文件选择器场景  -- 直接多选状态
      if (!this.itemViewModel.fileInfo.isFolder &&
        !PhoneFilePickerUtil.checkFileCanPick(
          this.itemViewModel.fileInfo, this.pickerCheckArr?.length ?? this.checkedNum, true, this.startModeOptions)) {
        // 不满足选择条件不处理
        return
      }
      if (AppStorage.has('dragStatus') && AppStorage.get<boolean>('dragStatus')) {
        this.enterFolder();
        return;
      }
      // 选中当前文件
      this.updateCheckedInMulti();
      return;
    }
    // 文件管理场景
    if (this.userState === UserState.BROWSER) {
      this.onItemClick(this.itemViewModel.fileInfo, true);
      return;
    }
    if (this.userState === UserState.MULTI_START) {
      // 多选状态则选中当前文件
      if (AppStorage.has('dragStatus') && AppStorage.get<boolean>('dragStatus')) {
        this.enterFolder();
        return;
      }
      this.updateCheckedInMulti();
      return;
    }
    if (this.isPathSelection() && this.itemViewModel.fileInfo.isFolder) {
      this.onItemClick(this.itemViewModel.fileInfo, false);
      return;
    }
  }

  private getDeleteConfirmDialogContent() {
    if (this.pageName === PAGE_ROUTE_CONST.RECENT_DELETE) {
      return $r('app.string.delete_complete_tips');
    }
    if (
      this.curFolderUri.startsWith(VirtualUri.EXTERNAL_DISK) ||
      this.item.uri.startsWith(VirtualUri.EXTERNAL_DISK)
    ) {
      return $r('app.string.complete_delete_tips');
    }
    return $r('app.string.softDelete');
  }

  private onActionOfSwipeAction(): void {
    animateTo({ duration: 1000 }, () => {
      this.fileDeleteOperation(this.item);
    });
  }

  private fileDelete(isHardDelete: boolean): void {
    this.toOperateFileList = [];
    this.toOperateFileList.push(this.swipeDeleteFileInfo);
    const data: RenameItem = {
      type: isHardDelete ? Constant.OPERATION_TYPE.HARD_DELETE : Constant.OPERATION_TYPE.DELETE,
      newUri: ''
    }
    const deleteType: DFX.DeleteType =
      this.pageName == PAGE_ROUTE_CONST.RECENT_DELETE ? DFX.DeleteType.DELETE : DFX.DeleteType.SOFT_DELETE;
    UEUtil.reportDeleteFile(this.getUEPageName(), deleteType, DFX.OperateSource.LEFT_SLIDE, 1);
    this.swipeDeleteDialogCallback({ item: data } as BottomCallParams);
    HiLog.info(TAG, 'swipe delete success.');
  }

  private fileDeleteOperation(item: FileInfo): void {
    HiLog.info(TAG, 'fileDeleteOperation start.');
    this.swipeDeleteFileInfo = item;
    if (MyPhoneConstant.isSystemFolder(ExternalStorageUtil.getParentUri(item.uri),
      item.fileName, item.isFolder)) {
      HiLog.info(TAG, 'systemFileDeleteDialog open.');
      this.systemFileDeleteDialog.open();
    } else if (this.itemViewModel.fileInfo.isFusionAlbum) {
      HiLog.info(TAG, 'Delete fusionAlbum.');
      this.fusionAlbumDeleteDialog.open();
    } else {
      HiLog.info(TAG, 'fileDeleteDialog open.');
      this.fileDeleteDialog.open();
    }
  }

  /*
   * 判断是否支持拖入
   * */
  private isAllowDrop(): boolean {
    if (!this.isCurFolderEnableDrop) {
      return false;
    }
    if (this.item.isFusionAlbum) {
      return false;
    }
    if (this.curFolderUri === VirtualUri.GALLERY || this.curFolderUri.startsWith(VirtualUri.GALLERY_URI)) {
      return true;
    }
    return true;
  }

  // 计算预览图尺寸
  private calcPreviewSize(): void {
    if (this.showListItem()) {
      // item
      const longPressItemId: string = CompId.FILE_ITEM + this.item.uri + this.pageName;
      try {
        const itemInfo = componentUtils.getRectangleById(longPressItemId);
        const itemWidth = px2vp(itemInfo.size.width);
        if (itemWidth > 0) {
          this.listItemWidth = itemWidth;
        }
      } catch (e) {
        HiLog.error(TAG, `calcPreviewSize listItem getRectangleById error: ${e?.code}`);
      }
    }
  }

  private getAccessibilityChecked(): boolean | undefined {
    if (!this.itemViewModel || !this.itemViewModel.fileInfo) {
      HiLog.warn(TAG, 'getAccessibilityChecked param is undefined');
      return undefined;
    }

    return CommonUtil.isShowCheckBox(this.itemViewModel.fileInfo,
      this.startModeOptions.pickerFlag) && this.userState === UserState.MULTI_START && !this.itemViewModel.isChecked ?
      false : undefined;
  }

  private getNotShowPreviewDescription(): Resource | undefined {
    if (this.startModeOptions.pickerFlag) {
      if (CommonUtil.isShowCheckBox(this.item, true)) {
        return this.itemViewModel.isChecked ? $r('app.string.unchecked_accessibility') :
        $r('app.string.checked_accessibility');
      }
      return $r('app.string.click_accessibility');
    }
    return undefined;
  }
}