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
import { Constant, PAGE_ROUTE_CONST, UiUtil } from '@ohos/common';
import { PhoneItemViewModel } from '../../../viewModel/PhoneItemViewModel';
import { FileIconComp } from './FileIconComp';
import { OtherInfo } from './OtherInfo';
import { LengthMetrics } from '@kit.ArkUI';

const TAG = 'DragPreview';
const DEFAULT_MIN_HEIGHT: Resource = $r('app.float.common_size64');

/**
 * 拖拽视图
 */
@Component
export struct DragPreview {
  @Prop isListView: boolean;
  @Link itemViewModel: PhoneItemViewModel;
  @Link pageName: string;
  @Link isDropSelected: boolean;
  @State fileName: string = '';
  private isShowFileSource: boolean = false;
  private isShowRecentTime: boolean = false;
  private isDragView: boolean = false;
  @StorageLink('isDarkMode') isDarkMode: boolean = false;
  @Prop gridCompactLayout: boolean;
  // 是否是选择器场景
  @Prop filePickerViewFlag: boolean;

  @State isShowFolderSubCount: boolean = false;
  @State isCachedImageLoad: boolean = false;
  private showHiddenItem: boolean = true;
  @Consume isOutsideFolded: boolean;
  @State minHeight: Resource = DEFAULT_MIN_HEIGHT;
  @State fontSize: number = 1;
  @Prop listItemWidth: Length;
  @Prop gridItemSize: Length = $r('app.float.common_size88');

  aboutToAppear(): void {
    this.fileName = UiUtil.translateFileNameByUri(this.itemViewModel.fileInfo.uri, this.itemViewModel.fileInfo.fileName,
      this.itemViewModel.fileInfo.isFolder);

    this.itemViewModel.getFolderSubFileCount(this.showHiddenItem, () => {
      if (this.itemViewModel.fileInfo.isFolder &&
        this.itemViewModel.fileInfo.subFileCount > Constant.FOLDER_SUB_DEFAULT) {
        this.isShowFolderSubCount = true;
      }
    });
    this.fontSize = UiUtil.getFontSize();
  }

  build() {
    if (this.isListView) {
      this.listPreview()
    } else {
      this.gridPreview()
    }
  }

  @Builder
  listPreview() {
    Column() {
      Row() {
        Row() {
          this.iconPreview()
        }
        .alignItems(VerticalAlign.Center)
        .size({ width: $r('app.float.common_size36'), height: $r('app.float.common_size36') })
        this.fileDetailInfo()
      }
      .alignItems(VerticalAlign.Center)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .constraintSize({
      minHeight: this.minHeight
    })
    .width(this.isDragView ? $r('app.float.common_size288') : this.listItemWidth)
    .backgroundColor(this.isDragView && this.isDarkMode ? $r('app.color.drag_view_color_dark') :
      $r('sys.color.comp_background_list_card'))
    .backgroundBlurStyle(this.isDragView ? BlurStyle.NONE : BlurStyle.COMPONENT_ULTRA_THICK)
    .borderRadius($r('sys.float.corner_radius_level10'))
    .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
    .accessibilityGroup(true)
  }

  @Builder
  gridPreview() {
    Row() {
      this.iconPreview()
    }
    .size({ width: this.gridItemSize, height: this.gridItemSize })
    .alignItems(VerticalAlign.Bottom)
    .margin({
      top: $r('sys.float.padding_level5'),
      bottom: $r('sys.float.padding_level5')
    })
  }

  @Builder
  iconPreview() {
    FileIconComp({
      itemViewModel: this.itemViewModel,
      isFromLongPress: true,
      isShowFolderSubCount: this.isShowFolderSubCount,
      isCachedImageLoad: this.isCachedImageLoad,
      gridCompactLayout: this.gridCompactLayout,
      isListView: this.isListView
    })
  }

  @Builder
  fileDetailInfo() {
    Column() {
      Text(this.fileName)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .maxLines(Constant.LINE_COUNT.ONE)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .ellipsisMode(EllipsisMode.CENTER)
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
        .constraintSize({
          // 适老化适配，将文本框的高度设置为最小18vp，当文字变大时文本框会跟随变高。从而解决文字与图片叠加问题
          minHeight: $r('app.float.common_size19')
        })
        .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)
      // 其他信息
      this.otherInfo();
    }
    .margin({ start: LengthMetrics.resource($r('sys.float.padding_level8')) })
    .padding({
      top: $r('app.float.common_padding4'),
      bottom: $r('app.float.common_padding4')
    })
    .alignItems(HorizontalAlign.Start)
    .constraintSize({
      maxWidth: `calc(100% - 36vp)`
    })
  }

  @Builder
  otherInfo() {
    OtherInfo({
      itemViewModel: this.itemViewModel,
      isDropSelected: this.isDropSelected,
      isShowFileSource: this.isShowFileSource,
      pageName: this.pageName,
      isShowRecentTime: this.isShowRecentTime,
      filePickerViewFlag: this.filePickerViewFlag
    })
      .constraintSize({
        maxWidth: `calc(100% - 42vp)`
      })
  }
}