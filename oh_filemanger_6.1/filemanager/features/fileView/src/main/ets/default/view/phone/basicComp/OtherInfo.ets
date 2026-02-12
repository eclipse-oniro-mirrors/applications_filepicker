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
  AppDataPathUtil,
  BundleResourceUtil,
  Constant,
  DateUtil,
  PAGE_ROUTE_CONST,
  renderSize,
  FileUtil,
} from '@ohos/common';
import { PhoneItemViewModel } from '../../../viewModel/PhoneItemViewModel';
import { FileContentComp } from './FileContentComp'

const OUTSIDE_DEVICE_MAX_SCALE = 1.5;

@Component
export struct OtherInfo {
  @Link itemViewModel: PhoneItemViewModel;
  @Link isDropSelected: boolean;
  private isShowFileSource: boolean = false;
  @Link pageName: string;
  private isShowRecentTime: boolean = false;
  private isShowFolderSubCount: boolean = false;
  // 是否是选择器场景
  @Prop filePickerViewFlag: boolean;
  private showHiddenItem: boolean = true;
  @Consume isOutsideFolded: boolean;

  aboutToAppear(): void {
    this.itemViewModel.getFolderSubFileCount(this.showHiddenItem, () => {
      if (this.itemViewModel.fileInfo.isFolder &&
        this.itemViewModel.fileInfo.subFileCount > Constant.FOLDER_SUB_DEFAULT) {
        this.isShowFolderSubCount = true;
      }
    });
  }

  build() {
    Row() {
      if (this.itemViewModel.fileInfo.highLightContent.length > 0) {
        // 搜索场景，文件内容匹配时部分文件内容需要在页面上显示
        FileContentComp({
          fileContentList: Array.from(this.itemViewModel.fileInfo.highLightContent),
          isDropSelected: this.isDropSelected
        })
          .opacity(this.itemViewModel.getItemOpacity())
      } else {
        this.normalInfomation()
      }
    }.margin({ top: $r('app.float.common_padding2') })
  }

  @Builder
  normalInfomation() {
    Text() {
      // 文件的上次访问时间或更新时间
      Span(DateUtil.getPhoneDateText(
        this.itemViewModel.getShowTime(this.isShowRecentTime, this.pageName === PAGE_ROUTE_CONST.RECENT_DELETE)));
      // 文件夹子项个数
      if (this.isShowFolderSubCountItem()) {
        if (!FileUtil.isGalleryAddress(this.itemViewModel.fileInfo.uri)) {
          Span(' - ')
        }
        Span($r('app.string.select_num', this.itemViewModel.fileInfo.subFileCount))
      } else if (!this.itemViewModel.fileInfo.isFolder) {
        // 文件大小
        Span(' - ')
        Span(renderSize(this.itemViewModel.fileInfo.size))
      }
      // 文件来源
      if (this.isShowFileSource) {
          Span(' - ')
          Span('local')
      }
    }
    .fontWeight(FontWeight.Regular)
    .fontSize($r('sys.float.Body_S'))
    .fontColor($r('sys.color.font_secondary'))
    .opacity(this.itemViewModel.getItemOpacity())
    .textOverflow({ overflow: TextOverflow.Ellipsis })
    .ellipsisMode(EllipsisMode.CENTER)
    .maxLines(1)
    .maxFontScale(this.isOutsideFolded ? OUTSIDE_DEVICE_MAX_SCALE : Constant.BIG_MODE.BIG_MODE_2x)
  }

  private isShowFolderSubCountItem(): boolean {
    return this.isShowFolderSubCount && this.itemViewModel.fileInfo.isFolder && !this.filePickerViewFlag &&
      this.itemViewModel.fileInfo.subFileCount > Constant.FOLDER_SUB_DEFAULT;
  }
}