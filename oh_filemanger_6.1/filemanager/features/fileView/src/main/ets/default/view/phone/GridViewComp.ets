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
  StringUtil,
  UserState,
  UiUtil,
  DateUtil,
  FileMimeTypeUtil,
  FileUtil,
  renderSize,
  Z_INDEX,
  VirtualUri,
  Constant,
  ResourceUtil,
  PAGE_ROUTE_CONST,
  MyPhoneConstant,
  FileDataSource,
  TraceUtils,
  LocationType,
  HiLog,
  FileInfo,
  CommonUtil,
  FilePickerUtil,
  ApplicationThemeColor,
  FileSourceUri,
  LanguageUtil,
  AppDataPathUtil,
  AccessibilityManager,
  ACCESSIBILITY_LEVEL,
  CompId,
  FileSourceType,
  BundleResourceUtil
} from '@ohos/common';
import { FileContentComp } from './basicComp/FileContentComp';
import { FileIconComp } from './basicComp/FileIconComp';
import { FileNameComp } from './basicComp/FileNameComp';
import { PhoneItemViewModel } from '../../viewModel/PhoneItemViewModel';
import { getRootFolderInstruction } from '@ohos/common/src/main/ets/utils/Tools';
import { LongPressFileMenu } from './LongPressFileMenu';
import {
  ColumnModifier,
  FileNameModifier,
  FileTextModifier,
  ImageModifier,
  RowModifier
} from '../../viewModel/CustomedModifier';
import { UIUtils } from '@kit.ArkUI';

const TAG = 'GridViewComp';

@Component
export struct GridViewComp {
  public geometryId: string = '';
  @Link itemViewModel: PhoneItemViewModel;
  @Link @Watch('onUserStateChange') userState: UserState;
  // 复用时，该变量触发是否显示checkbox的变量
  @State isShowCheckBox: boolean = false;
  private isShowFileSource: boolean = false;
  private isShowRecentTime: boolean = false;
  private iconId: string = '';
  @Prop gridCompactLayout: boolean;
  // 当前是否被落入
  @Link isDropSelected: boolean;
  // 是否是选择器场景
  @Prop filePickerViewFlag: boolean;
  private fileName: string = '';
  @State isShowFolderSubCount: boolean = false;
  @Link pageName: string;
  @StorageLink('systemLanguage') @Watch('updateFileName') systemLanguage: string = '';
  // 是否在无障碍阅读模式
  @StorageProp('isAccessibilityMode') @Watch('updateAccessibilityText') isAccessibilityMode: boolean = false;
  // 图片或视频的无障碍播报内容
  @State accessibilityTextContent: string = '';
  // 点击文件事件的回调
  private onItemClick: Function = () => {
  };
  @Link fileListSource: FileDataSource;
  // 全选状态
  @Link @Watch('selectAllUpdate') isSelectAll: boolean;
  // 选择文件个数
  @Link @Watch('checkedNumChange') checkedNum: number;
  @State @Watch('cachedImageLoadChange') isCachedImageLoad: boolean = false;
  @Consume('showHiddenItemStatus') showHiddenItem: boolean;
  public isShowAlbumCover: boolean = false;
  @Prop curFolderUri: string = '';
  private index: number = 0;
  @State iconSize: number = Constant.GRID_VIEW_IMAGE_SIZE;
  @State fileNameWidth: Resource = $r('app.float.grid_view_text_area_width');
  // 当前状态是否为外折叠态
  @Consume('isOutsideFolded') @Watch('onIsOutsideFoldedChange') isOutsideFolded: boolean;
  private customTheme: CustomTheme = FilePickerUtil.getStartOptionsFromStorage().customTheme;
  private isUseDefaultThemeColor: boolean = this.customTheme.colors === ApplicationThemeColor.defaultTheme().colors;
  @Link showGridIconMenu: boolean;
  @Link menuLayoutRegionMargin: Margin;
  public isContextMenuForbidden: boolean = false;
  onLongClick: Function = (emitLocation?: string) => {
  };
  @Link toOperateFileList: FileInfo[];
  @State rootFolderInstruction?: Resource = undefined;
  // 使能拖拽
  @Prop @Watch('enableDragChange') enableDrag: boolean = false;
  public dragStart: Function = () => {
  };
  public dragEnd: Function = () => {
  };
  private fileNameTextModifier: FileNameModifier = new FileNameModifier();
  private outerColumnModifier: ColumnModifier = new ColumnModifier();
  private fileIconColumnModifier: ColumnModifier = new ColumnModifier();
  private remainDaysTextModifier?: FileTextModifier;
  private outerColumnOpacity: Resource = $r('app.float.common_opacity10');
  private isDraggable: boolean = false;
  // 第一行文字信息
  private firstLineTextModifier: FileTextModifier = new FileTextModifier();
  private firstLineText: string | Resource = '';
  private firstLineTextFontSize: | Resource = $r('sys.float.Caption_M');
  private isShowFirstTextLine: boolean = false;
  // 视频时长通过属性主动刷新
  private videoDurationModifier: FileTextModifier = new FileTextModifier();
  private videoDurationRowModifier: RowModifier = new RowModifier();
  // 原始对象，从对应的状态变量里获取而来，操作原始对象，性能更优，但是其变化不会触发状态更新，谨慎使用
  private itemViewModelNoState: PhoneItemViewModel = new PhoneItemViewModel(new FileInfo());
  @State fileSourceType: FileSourceType = FileSourceType.LOCAL_DISK;
  @StorageProp('isDarkMode') isDarkMode: boolean = false;

  aboutToAppear(): void {
    TraceUtils.startTrace('FileGridItemAboutToAppear');
    // 组件首次和复用的时候的共同初始化逻辑请写init方法里
    this.initStates();
    this.isDraggable = this.itemViewModel.isDraggable(this.enableDrag, this.checkedNum);
    TraceUtils.finishTrace('FileGridItemAboutToAppear');
  }

  aboutToReuse(params: Record<string, Object>): void {
    this.isCachedImageLoad = false;
    this.isShowFolderSubCount = false;
    this.initStates();

    // 父组件传下来的非状态变量重新赋值
    this.geometryId = params?.geometryId as string ?? '';
    this.iconId = params?.iconId as string ?? '';
    this.isShowAlbumCover = params?.isShowAlbumCover as boolean ?? false;
    this.index = params?.index as number ?? 0;
    this.isContextMenuForbidden = params?.isContextMenuForbidden as boolean ?? false;

    this.outerColumnModifier.attribute?.opacity(this.outerColumnOpacity);
    this.fileNameTextModifier.updateConstructorParams(this.fileName);
    this.updateIsDraggable();
    if (this.isShowFirstTextLine) {
      this.firstLineTextModifier.updateConstructorParams(this.firstLineText);
      this.firstLineTextModifier.attribute?.fontSize(this.firstLineTextFontSize);
    }
    this.firstLineTextModifier.attribute?.visibility(this.isShowFirstTextLine ? Visibility.Visible :
      Visibility.None);
    if (FileMimeTypeUtil.isVideo(this.itemViewModelNoState.fileInfo.mimeTypeObj)) {
      this.videoDurationRowModifier.attribute?.visibility(Visibility.None);
    }
  }

  // 组件首次和复用的时候的共同初始化逻辑
  initStates(): void {
    // 获取原始对象，比直接操作对象包装对象性能更优
    this.itemViewModelNoState = UIUtils.getTarget(this.itemViewModel);
    this.fileSourceType = this.itemViewModel.fileInfo.sourceType;
    this.outerColumnOpacity = this.getOpacity();
    this.initIconSize();
    this.showCheckBox();
    this.itemViewModelNoState.getFolderSubFileCount(this.showHiddenItem, () => {
      if (this.itemViewModelNoState.fileInfo.subFileCount > Constant.FOLDER_SUB_DEFAULT) {
        this.isShowFolderSubCount = true;
      }
    });
    this.updateAccessibilityText();
    if (this.itemViewModelNoState.fileInfo.isGallery) {
      this.updateVideoDurationModifier();
    } else {
      this.itemViewModelNoState.getMediaFileMetaDataWithoutThumb(() => {
        this.updateVideoDurationModifier();
      });
    }
    // 这些场景不需要显示detailInfo
    if (this.gridCompactLayout) {
      return;
    }
    this.getOrUpdateFileName();
    if (!this.isShowOtherInfo()) {
      return;
    }
    // 初始化otherInfo中需要的显示的元素
    this.rootFolderInstruction = getRootFolderInstruction(this.curFolderUri, this.itemViewModelNoState.fileInfo.uri);
    // 初始化otherInfo中的第一行text
    if (this.pageName !== PAGE_ROUTE_CONST.RECENT_DELETE) {
      this.firstLineText = DateUtil.getPhoneDateText(
        this.itemViewModelNoState.getShowTime(this.isShowRecentTime, false));
      this.firstLineTextFontSize = $r('sys.float.Caption_M');
      this.isShowFirstTextLine = true;
    } else {
      this.isShowFirstTextLine = false;
    }

    if (this.isShowRemainDays()) {
      this.remainDaysTextModifier = this.remainDaysTextModifier ?? new FileTextModifier();
      this.remainDaysTextModifier.updateConstructorParams(this.getRemainDaysText());
    }
  }

  updateVideoDurationModifier(): void {
    if (FileMimeTypeUtil.isVideo(this.itemViewModelNoState.fileInfo.mimeTypeObj)) {
      this.videoDurationModifier.updateConstructorParams(DateUtil.formatDuration(
        this.itemViewModelNoState.fileInfo.duration));
      this.updateAccessibilityText();
    }
  }

  cachedImageLoadChange() {
    if (this.isCachedImageLoad && FileMimeTypeUtil.isVideo(this.itemViewModelNoState.fileInfo.mimeTypeObj)) {
      this.videoDurationRowModifier.attribute?.visibility(Visibility.Visible);
    }
  }

  onUserStateChange() {
    let newOpacity = this.getOpacity();
    if (newOpacity !== this.outerColumnOpacity) {
      this.outerColumnOpacity = newOpacity;
    }
    this.outerColumnModifier.attribute?.opacity(this.outerColumnOpacity);
  }

  enableDragChange() {
    this.updateIsDraggable();
  }

  updateIsDraggable() {
    let oldDraggable = this.isDraggable;
    this.isDraggable = this.itemViewModelNoState.isDraggable(this.enableDrag, this.checkedNum);
    if (oldDraggable !== this.isDraggable) {
      this.fileIconColumnModifier.attribute?.draggable(this.isDraggable);
    }
  }

  getOpacity(): Resource {
    return this.isVirtualNormalOpacity() && this.userState === UserState.BROWSER ?
      $r('app.float.common_opacity10') : this.itemViewModelNoState.getItemOpacity();
  }

  isShowRemainDays(): boolean {
    return this.pageName === PAGE_ROUTE_CONST.RECENT_DELETE;
  }

  initIconSize() {
    this.iconSize = Constant.GRID_VIEW_IMAGE_SIZE;
    if (this.isOutsideFolded) {
      this.iconSize = Constant.OUTSIDE_SCREEN_GRID_VIEW_IMAGE_SIZE;
      return;
    }
    if (this.isShowAlbumCover) {
      this.iconSize = Constant.GRID_VIEW_ALBUM_IMAGE_SIZE;
    }
  }

  onIsOutsideFoldedChange() {
    this.initIconSize();
    this.fileNameWidth =
      this.isOutsideFolded ? $r('app.float.common_size88') : $r('app.float.grid_view_text_area_width');
  }

  isShowOtherInfo() {
    return !this.isOutsideFolded;
  }

  // 更新无障碍阅读内容
  updateAccessibilityText(): void {
    if (!this.itemViewModel) {
      HiLog.warn(TAG, 'updateAccessibilityText param is undefined.');
      return;
    }
    if (this.isAccessibilityMode &&
      (this.gridCompactLayout)) {
      this.accessibilityTextContent = AccessibilityManager.getMediaFileAccessibilityText(
        this.itemViewModel.fileInfo, this.index, this.systemLanguage);
    }
  }

  build() {
    Column() {
      this.FileIcon() // 文件图标
      if (!this.gridCompactLayout) {
        this.FileDetailInfo() // 文件详细信息
      }
    }
    .width('100%')
    .padding(this.gridCompactLayout ? 0 : $r('app.float.common_padding4'))
    .opacity(this.outerColumnOpacity)
    .attributeModifier(this.outerColumnModifier)
  }

  @Builder
  FileIcon() {
    Column() {
      Column() {
        FileIconComp({
          itemViewModel: this.itemViewModel,
          isShowFolderSubCount: this.isShowFolderSubCount,
          isCachedImageLoad: this.isCachedImageLoad,
          gridCompactLayout: this.gridCompactLayout,
          isListView: false
        })
          .id(this.iconId)
      }
      .width('100%')
      // 拖拽和长按菜单需要绑定同一个组件， 否则多选和单选长按菜单切换时，拖拽状态可能无法重置，导致多选聚拢失效
      .draggable(this.isDraggable)
      .onDragStart((event: DragEvent): CustomBuilder | DragItemInfo => {
        return this.dragStart(event);
      })
      .onDragEnd((event?: DragEvent, extraParams?: string) => {
        this.dragEnd(event);
      })
      .bindGridContextMenu()
      .attributeModifier(this.fileIconColumnModifier)

      // 视频时长标签
      if (FileMimeTypeUtil.isVideo(this.itemViewModel.fileInfo.mimeTypeObj)) {
        this.videoDurationTag();
      }
      // checkbox
      if (this.userState === UserState.MULTI_START && this.isShowCheckBox) {
        this.buildCheckbox();
      }

      // 虚拟融合相册图标
      if (this.itemViewModel.fileInfo.isFusionAlbum) {
        Column() {
          SymbolGlyph($r('sys.symbol.arrowshape_turn_up_right_fill'))
            .width($r('app.float.common_size12'))
            .height($r('app.float.common_size12'))
            .fontSize($r('app.float.common_size12'))
            .zIndex(Z_INDEX.LEVEL10)
            .draggable(false)
            .fontColor([$r('sys.color.font_emphasize')])
        }
        .position({
          // lock 的右下角点位与 FileIcon 右下角点位偏移 +4vp
          left: $r('app.float.common_size8'),
          bottom: $r('app.float.common_size2')
        })
        .backgroundColor($r('sys.color.ohos_id_blur_style_component_ultra_thick_color'))
        .size({
          width: $r('app.float.common_size18'),
          height: $r('app.float.common_size18')
        })
        .borderRadius('50%')
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .borderColor($r('sys.color.comp_divider'))
        .borderWidth($r('app.float.common_size05'))
      }

      // 图片预览icon
      if (this.filePickerViewFlag && FileMimeTypeUtil.isImage(this.itemViewModel.fileInfo.mimeTypeObj)) {
        Image($r('app.media.expendView'))
          .fillColor($r('sys.color.ohos_id_color_primary'))
          .objectFit(ImageFit.Fill)
          .height($r('app.float.common_size24'))
          .width($r('app.float.common_size24'))
          .zIndex(Z_INDEX.LOW)
          .position({ x: $r('app.float.common_position4'), y: $r('app.float.common_position4') })
          .draggable(false)
          .interpolation(ImageInterpolation.High)
          .onClick(() => {
            if (this.onItemClick) {
              this.onItemClick(this.itemViewModel.fileInfo, true);
            }
          })
          .accessibilityText($r('app.string.preview'))
          .accessibilityRole(AccessibilityRoleType.BUTTON)
          .accessibilityLevel(ACCESSIBILITY_LEVEL.YES)
          .id(CompId.EXPEND_VIEW_IMAGE)
      }
    }
    .accessibilityGroup(true)
    .accessibilityText(this.accessibilityTextContent)
    .justifyContent(FlexAlign.End)
    .width('100%')
    .aspectRatio(1)
  }

  @Builder
  videoDurationTag() {
    Row() {
      Image($r('app.media.triangleshape_fill'))
        .objectFit(ImageFit.Contain)
        .height($r('app.float.common_size6'))
        .width($r('app.float.common_size6'))
        .margin({ right: $r('app.float.common_margin2') })
        .draggable(false)
        .interpolation(ImageInterpolation.High)
        .fillColor(Color.White)
        .rotate({ angle: 90 })

      Text(DateUtil.formatDuration(this.itemViewModelNoState.fileInfo.duration))
        .fontColor($r('app.color.white'))
        .fontSize($r('app.float.common_size10'))
        .accessibilityLevel(ACCESSIBILITY_LEVEL.NO)
        .attributeModifier(this.videoDurationModifier)
    }
    .position({ x: 0, y: '100%' })
    .markAnchor({ x: $r('app.float.recent_markAnchor_4'), y: $r('app.float.recent_markAnchor_20') })
    .padding({
      left: $r('app.float.common_padding4'),
      right: $r('app.float.common_padding4'),
      top: $r('app.float.common_padding2'),
      bottom: $r('app.float.common_padding2')
    })
    .borderRadius($r('app.float.common_borderRadius8'))
    .backgroundColor('rgba(0, 0, 0, 0.35)')
    .visibility(Visibility.None)
    .attributeModifier(this.videoDurationRowModifier)
  }

  @Styles
  bindGridContextMenu() {
    .bindContextMenu(this.showGridIconMenu, this.LongPressFileMenu(), this.isContextMenuForbidden ? {} :
      {
        preview: MenuPreviewMode.IMAGE,
        backgroundBlurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
        previewAnimationOptions: { scale: [1.0, 1.0] },
        aboutToDisappear: () => {
          this.showGridIconMenu = false;
        },
        layoutRegionMargin: this.menuLayoutRegionMargin
      })
  }

  @Builder
  LongPressFileMenu() {
    if (!this.isContextMenuForbidden) {
      this.longPressFileMenuContent();
    }
  }

  @Builder
  longPressFileMenuContent() {
    this.longPressMenu();
  }

  @Builder
  longPressMenu() {
    LongPressFileMenu({
      isOutsideFolded: this.isOutsideFolded,
      showContextMenu: this.showGridIconMenu,
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

  getIconSize(): SizeOptions {
    return {
      width: this.gridCompactLayout ? '100%' : this.iconSize
    }
  }

  @Builder
  buildCheckbox() {
    Stack() {
      if (this.filePickerViewFlag) {
        WithTheme({ theme: this.customTheme }) {
          Checkbox()
            .select(this.itemViewModel.isChecked)
            .hitTestBehavior(HitTestMode.None)
            .shape(CheckBoxShape.CIRCLE)
            .border({ radius: $r('app.float.common_size10') })
            .margin(0)
            .opacity(this.itemViewModel.isChecked ? 1 :
              $r('app.float.common_opacity4'))
            .backgroundColor($r('app.color.black'))
            .unselectedColor(Color.White)
        }
      } else {
        Checkbox()
          .select(this.itemViewModel.isChecked)
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .hitTestBehavior(HitTestMode.None)
          .opacity(this.itemViewModel.isChecked ? 1 :
            $r('app.float.common_opacity4'))
          .backgroundColor($r('app.color.black'))
          .shape(CheckBoxShape.CIRCLE)
          .border({ radius: $r('app.float.common_size10') })
          .margin(0)
      }
      Column()
        .height($r('app.float.common_size20'))
        .width($r('app.float.common_size20'))
        .border({
          color: $r('app.color.white'),
          width: this.itemViewModel.isChecked
            ? $r('app.float.common_size0') : $r('app.float.common_size1'),
          radius: $r('app.float.common_size10')
        })
    }
    .accessibilityGroup(true)
    .markAnchor({ x: $r('app.float.common_markAnchor_24'), y: $r('app.float.common_markAnchor_24') })
    .position({ x: '100%', y: '100%' })
  }

  @Builder
  FileDetailInfo() {
    Column() {
      // 文件名
      FileNameComp({
        fileName: this.fileName,
        maxLines: 1, // 当前规格，列表视图只显示两行，中间截断
        ellipsisMode: EllipsisMode.CENTER,
        isDropSelected: this.isDropSelected
      })

      // 其他信息
      if (this.isShowOtherInfo()) {
        this.OtherInfo()
      }
    }
    .width('100%')
    .margin({ top: this.gridCompactLayout ? 0 : $r('app.float.common_margin8') })
  }

  @Builder
  OtherInfo() {
    if (this.itemViewModel.fileInfo.highLightContent.length > 0) {
      // 搜索场景，文件内容匹配时部分文件内容需要在页面上显示
      FileContentComp({
        fileContentList: Array.from(this.itemViewModel.fileInfo.highLightContent),
        isDropSelected: this.isDropSelected
      })
    } else {
      Row() {
        Text(this.firstLineText)
          .fontWeight(FontWeight.Regular)
          .fontSize(this.firstLineTextFontSize)
          .fontColor($r('sys.color.font_secondary'))
          .visibility(this.isShowFirstTextLine ? Visibility.Visible :
            Visibility.None)
          .attributeModifier(this.firstLineTextModifier)
      }

      if (this.pageName !== PAGE_ROUTE_CONST.RECENT_DELETE) {
        // 展示文件来源
        if (this.isShowFileSource) {
          Text('local')
            .fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
        } else if (this.isShowFolderSubCountItem()) {
          if (this.rootFolderInstruction) {
            // 文件夹子项个数 - 文件夹说明文字
            Text(`${ResourceUtil.getStringByResource(
              $r('app.string.select_num', this.itemViewModel.fileInfo.subFileCount))} - ${
            ResourceUtil.getStringByResource(this.rootFolderInstruction)}`)
              .fontWeight(FontWeight.Regular)
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_secondary'))
              .visibility(this.isShowFolderSubCount ? Visibility.Visible : Visibility.Hidden)
              .textAlign(TextAlign.Center)
          } else {
            // 文件夹子项个数 融合相册添加后缀说明
            Text(this.itemViewModel.fileInfo.isFusionAlbum ? `${ResourceUtil.getStringByResource(
              $r('app.string.select_num', this.itemViewModel.fileInfo.subFileCount))}` :
              $r('app.string.select_num', this.itemViewModel.fileInfo.subFileCount))
              .fontWeight(FontWeight.Regular)
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_secondary'))
              .visibility(this.isShowFolderSubCount ? Visibility.Visible : Visibility.Hidden)
          }
        } else if (!this.itemViewModel.fileInfo.isFolder) {
          // 文件大小
          Text() {
            Span(renderSize(this.itemViewModel.fileInfo.size))
          }
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_secondary'))
        } else if (this.itemViewModel.fileInfo.uri === FileSourceUri.GALLERY) {
          Text(this.rootFolderInstruction)
            .fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Caption_M'))
            .fontColor($r('sys.color.font_secondary'))
            .visibility(this.isShowFolderSubCount ? Visibility.Visible : Visibility.Hidden)
            .textAlign(TextAlign.Center)
        }
      }
      // 最近删除剩余保存天数
      if (this.isShowRemainDays()) {
        Text(this.getRemainDaysText())
          .fontSize($r('app.float.common_font_size10'))
          .fontColor($r('sys.color.font_secondary'))
          .visibility(this.userState !== UserState.MULTI_START ? Visibility.Visible : Visibility.Hidden)
          .attributeModifier(this.remainDaysTextModifier)
      }
    }
  }

  getRemainDaysText(): Resource {
    let remainDays: number = CommonUtil.getRemainDays(this.itemViewModelNoState.fileInfo.deleteTime);
    return $r('app.plural.file_day_item', remainDays, remainDays);
  }

  selectAllUpdate(): void {
    try {
      if (!this.itemViewModel.fileInfo.isMultiEnable) {
        return;
      }
      if (this.isSelectAll) {
        const index = this.fileListSource.getIndex(this.itemViewModel.fileInfo.uri);
        if (index !== -1) {
          const file = this.fileListSource.getData(index);
          this.itemViewModel.isChecked = file.isChecked;
        }
        return;
      }
      if (this.checkedNum === 0) {
        this.itemViewModel.isChecked = false;
      }
    } catch (e) {
      HiLog.error(TAG, 'gridview comp selectAllUpdate error');
    }
  }

  /**
   * 判断是否显示CheckBox
   * 文件选择器场景下，文件夹，图库文件夹暂不支持选择
   * @returns
   */
  showCheckBox(): void {
    const fileInfo = this.itemViewModelNoState.fileInfo;
    this.isShowCheckBox = CommonUtil.isShowCheckBox(fileInfo, this.itemViewModelNoState.filePickerViewFlag);
  }

  private isShowFolderSubCountItem() {
    return this.itemViewModel.fileInfo.isFolder && !this.itemViewModel.fileInfo.isGallery;
  }

  private isVirtualNormalOpacity() {
    return this.itemViewModelNoState.fileInfo.fileName === MyPhoneConstant.MY_PHONE_GALLERY ||
      this.itemViewModelNoState.fileInfo.fileName === MyPhoneConstant.MY_PHONE_SOUND_RECORDER ||
      (this.itemViewModelNoState.fileInfo.isFolder && this.itemViewModelNoState.fileInfo.isGallery) ||
    this.itemViewModel.fileInfo.isFusionAlbum;
  }

  checkedNumChange(): void {
    if (this.checkedNum === UiUtil.SELECT_NONE) {
      this.itemViewModel.isChecked = false;
    }
    this.updateIsDraggable();
  }

  private getOrUpdateFileName() {
    if (this.itemViewModelNoState.fileInfo.relativePath === VirtualUri.LOCAL_PATH_HEAD) {
      // 我的手机在 聚合视图下显示为 0
      this.fileName = '0';
    } else {
      this.fileName = UiUtil.translateFileNameByUri(this.itemViewModelNoState.fileInfo.uri,
        this.itemViewModelNoState.fileInfo.fileName, this.itemViewModelNoState.fileInfo.isFolder);
    }
    this.fileName = this.fileName;
  }

  private updateFileName() {
    if (this.itemViewModel.fileInfo.fileName === MyPhoneConstant.MY_PHONE_GALLERY ||
      this.itemViewModel.fileInfo.fileName === MyPhoneConstant.MY_PHONE_SOUND_RECORDER) {
      this.getOrUpdateFileName();
      this.fileNameTextModifier.updateConstructorParams(this.fileName);
    }
    // 更新根目录特定文件夹的说明信息
    this.rootFolderInstruction = undefined;
    this.rootFolderInstruction = getRootFolderInstruction(this.curFolderUri, this.itemViewModel.fileInfo.uri);
  }
}
