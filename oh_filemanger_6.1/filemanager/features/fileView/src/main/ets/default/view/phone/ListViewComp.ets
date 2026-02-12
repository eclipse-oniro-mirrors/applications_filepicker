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
  Constant,
  PAGE_ROUTE_CONST,
  StringUtil,
  UserState,
  Z_INDEX,
  UiUtil,
  DateUtil,
  FileMimeTypeUtil,
  FileUtil,
  renderSize,
  BundleResourceUtil,
  ObjectUtil,
  AppDataPathUtil,
  ResourceUtil,
  MyPhoneConstant,
  FileDataSource,
  TraceUtils,
  LocationType,
  HiLog,
  VirtualUri,
  CommonUtil,
  DisplayTimeUtil,
  FilePickerUtil,
  FileSourceUri,
  LanguageUtil,
  ACCESSIBILITY_LEVEL,
} from '@ohos/common';
import { FileContentComp } from './basicComp/FileContentComp';
import { FileIconComp } from './basicComp/FileIconComp';
import { FileNameComp } from './basicComp/FileNameComp';
import { PhoneItemViewModel } from '../../viewModel/PhoneItemViewModel';
import { LengthMetrics } from '@kit.ArkUI';
import { getRootFolderInstruction } from '@ohos/common/src/main/ets/utils/Tools';
import { FileNameModifier, FileTextModifier, RowModifier } from '../../viewModel/CustomedModifier';

const TAG = 'ListViewComp';

@Component
export struct ListViewComp {
  @Prop isRecent: boolean = false;
  @Prop isFileSourceView :boolean = false;
  @Prop isLongPress: boolean = false;
  @Link itemViewModel: PhoneItemViewModel;
  @Link @Watch('onUserStateChange') userState: UserState;
  @Link pageName: string;
  // 复用时，该变量触发是否显示checkbox的变量
  @State isShowCheckBox: boolean = false;
  @Link isDropSelected: boolean;
  private fileName: string = '';
  // 是否展示文件来源, 由最外层page传进来，不需要手动刷新，对组件复用无影响
  private isShowFileSource: boolean = false;
  // 是否显示最近访问时间, 由最外层page传进来，不需要手动刷新，对组件复用无影响
  private isShowRecentTime: boolean = false;
  // 是否是选择器场景
  @Prop filePickerViewFlag: boolean;
  private isPersistPermission: boolean = false;
  private iconId: string = '';
  // 点击文件事件的回调
  private onItemClick: Function = () => {
  };
  @StorageLink('systemLanguage') @Watch('updateFileName') systemLanguage: string = '';
  @State isShowFolderSubCount: boolean = false;
  @Link fileListSource: FileDataSource;
  // 全选状态
  @Link @Watch('selectAllUpdate') isSelectAll: boolean;
  // 选择文件个数
  @Link @Watch('checkedNumChange') checkedNum: number;
  @State isCachedImageLoad: boolean = false;
  @Prop curFolderUri: string;
  @Consume systemMultiple: number;
  @Consume('showHiddenItemStatus') showHiddenItem: boolean;
  @LocalStorageLink('systemLanguage') lang :string = 'cn-zh';
  public isBatchAuthPage: boolean = false;
  private customTheme: CustomTheme = FilePickerUtil.getStartOptionsFromStorage().customTheme;

  @State rootFolderInstruction?: Resource = undefined;
  private fileNameTextModifier: FileNameModifier = new FileNameModifier();
  private outerRowModifier: RowModifier = new RowModifier();
  private outerRowOpacity: Resource = $r('app.float.common_opacity10');
  private remainDaysTextModifier?: FileTextModifier;
  @StorageProp('isDarkMode') isDarkMode: boolean = false;

  aboutToAppear(): void {
    TraceUtils.startTrace('FileListItemAboutToAppear');
    // 组件首次和复用的时候的共同初始化逻辑请写init方法里
    this.initStates();
    TraceUtils.finishTrace('FileListItemAboutToAppear');
  }

  aboutToReuse(params: Record<string, Object>): void {
    this.isShowFolderSubCount = false;
    this.isCachedImageLoad = false;
    this.initStates();

    // 父组件传下来的非状态变量重新赋值
    this.isShowFileSource = params?.isShowFileSource as boolean ?? false;
    this.iconId = params?.iconId as string ?? '';
    // 属性刷新
    this.outerRowModifier.attribute?.id(this.iconId);
  }

  // 组件首次和复用的时候的共同初始化逻辑
  initStates(): void {
    this.outerRowOpacity = this.getOpacity();

    this.rootFolderInstruction = getRootFolderInstruction(this.curFolderUri, this.itemViewModel.fileInfo.uri);
    this.showCheckBox();
    this.getOrUpdateFileName();
    this.fileNameTextModifier.updateConstructorParams(this.fileName);
    this.itemViewModel.getFolderSubFileCount(this.showHiddenItem, () => {
      if (this.itemViewModel.fileInfo.subFileCount > Constant.FOLDER_SUB_DEFAULT) {
        this.isShowFolderSubCount = true;
      }
    });
    if (this.isShowRemainDays()) {
      this.remainDaysTextModifier = this.remainDaysTextModifier ?? new FileTextModifier();
      this.remainDaysTextModifier.updateConstructorParams(this.getRemainDaysText());
    }
    this.itemViewModel.getMediaFileMetaDataWithoutThumb();
  }

  build() {
    Row() {
      Row() {
        // 文件图标
        this.startIcon()
        // 文件信息
        this.fileDetailInfo()
      }
      .layoutWeight(1)
      .padding({
        start: LengthMetrics.vp(0),
        end: LengthMetrics.vp(8),
        top: LengthMetrics.resource(this.getBigModePadding()),
        bottom: LengthMetrics.resource(this.getBigModePadding())
      })
      this.endIcon()
    }
    .justifyContent(FlexAlign.Start)
    .id(this.iconId)
    .margin({
      start: LengthMetrics.vp(8),
      end: LengthMetrics.vp(0)
    })
    .constraintSize({
      minHeight: $r('app.float.common_size56')
    })
    .opacity(this.outerRowOpacity)
    .attributeModifier(this.outerRowModifier)
  }

  isShowRemainDays(): boolean {
    return this.pageName === PAGE_ROUTE_CONST.RECENT_DELETE ;
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

  @Builder
  startIcon() {
    Column() {
      FileIconComp({
        itemViewModel: this.itemViewModel,
        isShowFolderSubCount: this.isShowFolderSubCount,
        isCachedImageLoad: this.isCachedImageLoad,
        isListView: true,
        isFileSourceView: this.isFileSourceView,
      })

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
          left: $r('app.float.common_position_neg3'),
          bottom: $r('app.float.common_size0')
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

      if (FileMimeTypeUtil.isVideo(this.itemViewModel.fileInfo.mimeTypeObj) && this.isCachedImageLoad) {
        Image($r('app.media.hidisk_ic_video_list'))
          .fillColor($r('sys.color.ohos_id_color_primary'))
          .objectFit(ImageFit.Contain)
          .autoResize(true)
          .height($r('app.float.common_size20'))
          .width($r('app.float.common_size20'))
          .position({ x: $r('app.float.common_position8'), y: $r('app.float.common_position8') })
          .draggable(false)
          .interpolation(ImageInterpolation.High)
      }
      if (!this.isPersistPermission && this.filePickerViewFlag &&
        FileMimeTypeUtil.isImage(this.itemViewModel.fileInfo.mimeTypeObj)) {
        Image($r('app.media.expendView'))
          .fillColor($r('sys.color.ohos_id_color_primary'))
          .objectFit(ImageFit.Contain)
          .height($r('app.float.common_size12'))
          .width($r('app.float.common_size12'))
          .zIndex(Z_INDEX.LOW)
          .position({ x: $r('app.float.common_position2'), y: $r('app.float.common_position2') })
          .draggable(false)
          .interpolation(ImageInterpolation.High)
      }
    }
    .justifyContent(FlexAlign.Center)
    .width($r('app.float.common_size38'))
    .height($r('app.float.common_size38'))
    .onClick(() => {
      if (this.isRecent && this.userState === UserState.MULTI_START) {
        return;
      }
      if (this.isPersistPermission) {
        return;
      }
      if (this.isLongPress) {
        return;
      }
      // 非文件选择器场景点击图标可以进行预览, 或文件选择器场景点击图片图标可以进行预览
      if ((!this.filePickerViewFlag) || FileMimeTypeUtil.isImage(this.itemViewModel.fileInfo.mimeTypeObj)) {
        this.onItemClick(this.itemViewModel.fileInfo, true);
      }
    })
    .accessibilityLevel(ACCESSIBILITY_LEVEL.NO)
  }

  @Builder
  fileDetailInfo() {
    Column() {
      Text(this.fileName)
        .maxLines(2)
        .ellipsisMode(EllipsisMode.END)
        .attributeModifier(this.fileNameTextModifier)
      // 其他信息
      this.otherInfo()
    }
    .margin({ start: LengthMetrics.vp(16)})
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
  }

  @Builder
  otherInfo() {
    Row() {
      if (this.itemViewModel.fileInfo.highLightContent.length > 0) {
        // 搜索场景，文件内容匹配时部分文件内容需要在页面上显示
        FileContentComp({
          fileContentList: Array.from(this.itemViewModel.fileInfo.highLightContent),
          isDropSelected: this.isDropSelected
        })
      } else {
        this.normalInfomation()
      }
    }
    .margin({ top: $r('app.float.common_padding5') })
  }

  @Builder
  normalInfomation() {
    Text() {
      // 文件的上次访问时间或更新时间
      if (this.isShowTime()) {
        Span(this.getDisplayTime());
      }
      // 文件夹子项个数
      if (this.isShowFolderSubCountItem()) {
        if (!FileUtil.isGalleryAddress(this.itemViewModel.fileInfo.uri) &&
          !FileUtil.isDownloadAndReceiveAddress(this.itemViewModel.fileInfo.uri,
            this.itemViewModel.fileInfo.relativePath) &&
          !this.itemViewModel.fileInfo.isFusionAlbum) {
          Span(this.isShowTime() ? ' - ' : ' ')
        }
        Span($r('app.string.select_num', this.itemViewModel.fileInfo.subFileCount))
      } else if (!this.itemViewModel.fileInfo.isFolder) {
        Span(' - ')
        // 文件大小
        Span(renderSize(this.itemViewModel.fileInfo.size))
      }
      // 文件来源
      if (this.isShowFileSource) {
        //判断是不是最近删除页,最近删除页根据SrcPath来显示来源，其他页通过uri来判断
        Span(' - ')
        Span(' - ')
      }
      // 我的手机根目录下的文件说明提示
      if (this.rootFolderInstruction) {
        if (this.itemViewModel.fileInfo.uri !== FileSourceUri.GALLERY) {
          Span(' - ')
        }
        Span(this.rootFolderInstruction)
      }
    }
    .fontWeight(FontWeight.Regular)
    .fontSize($r('sys.float.Body_S'))
    .fontColor($r('sys.color.font_secondary'))
    .ellipsisMode(EllipsisMode.CENTER)
  }

  private getDisplayTime(): ResourceStr {
    let displayTime: number | undefined =
      this.itemViewModel.getShowTime(this.isShowRecentTime, this.pageName === PAGE_ROUTE_CONST.RECENT_DELETE);
    return DateUtil.getPhoneDateText(displayTime);
  }

  isShowTime() {
    // 融合相册不展示时间
    if (this.itemViewModel.fileInfo.isFusionAlbum) {
      return false;
    }
    if (this.isBatchAuthPage) {
      return true;
    }
    if (this.isPersistPermission) {
      return true;
    }
    return this.curFolderUri !== PAGE_ROUTE_CONST.IMAGE && this.curFolderUri !== PAGE_ROUTE_CONST.VIDEO &&
      this.itemViewModel.fileInfo.uri !== VirtualUri.GALLERY;
  }

  isShowCheckBoxFlag(): boolean {
    return this.userState === UserState.MULTI_START && this.isShowCheckBox;
  }

  @Builder
  endIcon() {
    // 多选模式时显示CheckBox
    if (this.isShowCheckBoxFlag()) {
      Column() {
        if (this.filePickerViewFlag) {
          WithTheme({theme: this.customTheme}) {
            Checkbox()
              .select(this.itemViewModel.isChecked)
              .hitTestBehavior(HitTestMode.None)
              .shape(CheckBoxShape.CIRCLE)
              .margin({
                end: LengthMetrics.resource($r('app.float.common_margin16'))
              })
              .alignSelf(ItemAlign.End)
              .unselectedColor(this.isDarkMode ? Color.White : undefined)
          }
        } else {
          Checkbox()
            .select(this.itemViewModel.isChecked)
            .selectedColor($r('sys.color.comp_background_emphasize'))
            .hitTestBehavior(HitTestMode.None)
            .shape(CheckBoxShape.CIRCLE)
            .margin({
              end: LengthMetrics.resource($r('app.float.common_margin16'))
            })
            .alignSelf(ItemAlign.End)
            .unselectedColor(this.isDarkMode ? Color.White : undefined)
        }
      }
      .accessibilityGroup(true)
      .width($r('app.float.common_size40'))
      .constraintSize({
        minHeight: $r('app.float.common_size24')
      })
      .opacity(this.itemViewModel.getItemOpacity())
    } else if (this.itemViewModel.fileInfo.isFolder && !this.isShowRemainDays()) {
      Column() {
        // 非多选模式下且非最近删除页，文件夹右侧显示箭头>
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize($r('app.float.common_size24'))
          .fontColor([this.isDropSelected ? $r('sys.color.font_on_secondary') : $r('sys.color.ohos_id_color_fourth')])
          .width($r('app.float.common_size12'))
          .height($r('app.float.common_size24'))
          .draggable(false)
      }
      .width($r('app.float.common_size40'))
      .constraintSize({
        minHeight: $r('app.float.common_size24')
      })
    } else if (this.isShowRemainDays()) {
      Text(this.getRemainDaysText())
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
        .constraintSize({
          // 适老化适配，将文本框的高度设置为最小18vp，当文字变大时文本框会跟随变高。从而解决文字与图片叠加问题
          minHeight:  $r('app.float.common_size21')
        })
        .margin({ right: $r('app.float.common_margin16') })
        .alignSelf(ItemAlign.Center)
        .attributeModifier(this.remainDaysTextModifier)
    }
  }

  getRemainDaysText(): Resource {
    let remainDays: number = CommonUtil.getRemainDays(this.itemViewModel.fileInfo.deleteTime);
    return $r('app.plural.file_day_item', remainDays, remainDays);
  }

  onUserStateChange() {
    let newOpacity = this.getOpacity();
    if (newOpacity !== this.outerRowOpacity) {
      this.outerRowOpacity = newOpacity;
    }
    this.outerRowModifier.attribute?.opacity(this.outerRowOpacity);
  }

  getOpacity(): Resource {
    return this.isVirtualNormalOpacity() && this.userState === UserState.BROWSER ?
      $r('app.float.common_opacity10') : this.itemViewModel.getItemOpacity();
  }

  /**
   * 判断是否显示CheckBox
   * 文件选择器场景下，文件夹,图库文件夹暂不支持选择
   * @returns
   */
  showCheckBox(): void {
    const fileInfo = this.itemViewModel.fileInfo;
    this.isShowCheckBox = CommonUtil.isShowCheckBox(fileInfo, this.itemViewModel.filePickerViewFlag);
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
      HiLog.error(TAG, 'selectAllUpdate error');
    }
  }

  private isShowFolderSubCountItem() {
    return this.isShowFolderSubCount && this.itemViewModel.fileInfo.isFolder &&
      this.itemViewModel.fileInfo.subFileCount > Constant.FOLDER_SUB_DEFAULT &&
      !this.itemViewModel.fileInfo.isGallery;
  }

  private isVirtualNormalOpacity() {
    return this.itemViewModel.fileInfo.fileName === MyPhoneConstant.MY_PHONE_GALLERY ||
      this.itemViewModel.fileInfo.fileName === MyPhoneConstant.MY_PHONE_SOUND_RECORDER ||
      (this.itemViewModel.fileInfo.isFolder && this.itemViewModel.fileInfo.isGallery) ||
      this.itemViewModel.fileInfo.isFusionAlbum;
  }

  checkedNumChange(): void {
    if (this.checkedNum === UiUtil.SELECT_NONE) {
      this.itemViewModel.isChecked = false;
    }
  }

  private getOrUpdateFileName(): void {
    this.fileName = UiUtil.translateFileNameByUri(this.itemViewModel.fileInfo.uri,
      this.itemViewModel.fileInfo.fileName, this.itemViewModel.fileInfo.isFolder);
  }

  private updateFileName(): void {
    if (this.itemViewModel.fileInfo.fileName === MyPhoneConstant.MY_PHONE_GALLERY ||
      this.itemViewModel.fileInfo.fileName === MyPhoneConstant.MY_PHONE_SOUND_RECORDER) {
      this.getOrUpdateFileName();
      this.fileNameTextModifier.updateConstructorParams(this.fileName);
    }
    this.rootFolderInstruction = undefined;
    this.rootFolderInstruction = getRootFolderInstruction(this.curFolderUri, this.itemViewModel.fileInfo.uri);
  }
}
