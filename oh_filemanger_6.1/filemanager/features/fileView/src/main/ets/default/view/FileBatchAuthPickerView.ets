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
  FileDataSource,
  FileInfo,
  FilePickerUtil,
  PAGE_ROUTE_CONST,
  PreferenceConst,
  SortOrder,
  StartModeOptions,
  UserState,
  ViewMode
} from '@ohos/common';
import { PhoneItemViewModel } from '../viewModel/PhoneItemViewModel';
import lazy { FileViewComp } from './phone/FileViewComp';

@Component
export struct FileBatchAuthPickerView {
  @Link fileListSource: FileDataSource;
  @Link @Watch('onSelectedNumChanged') selectedNum: number;
  @Link isSelectAll: boolean;
  @Provide toOperateFileList: FileInfo[] = [];
  @Provide pickerCheckArr: string[] = [];
  @Provide needHighlight: boolean = true;
  @Provide isListView: boolean = true;
  @Provide userState: UserState = UserState.MULTI_START;
  @Provide curFolderUri: string = '';
  @Provide viewMode: string =  ViewMode.LIST;
  @Provide operationType: string = '';
  @Provide order: string = SortOrder.NAME; // 排序
  @Provide isDesc: boolean = true; // 是否倒序
  @Provide('showHiddenItemStatus') showHiddenItemStatus: boolean = true;
  @Prop disableSwipe: boolean = false;
  @State listYOffset: number = 0;
  @State direList: AddressData[] = [];
  @State listScrollShow: boolean = true; // 列表滚动显示
  @State updateTimer: number = new Date().valueOf();
  @State showHiddenItem: boolean = true;
  public onItemClick: Function = () => {
  };
  private startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();
  
  private onSelectedNumChanged(): void {
    this.isSelectAll = this.selectedNum === this.startModeOptions.batchAuthUris.length;
  }

  build() {
    this.batchAuthPickerList()
  }

  @Builder
  batchAuthPickerList() {
    List() {
      LazyForEach(this.fileListSource, (item: FileInfo, index: number) => {
        FileViewComp({
          item: item,
          startModeOptions: this.startModeOptions,
          itemViewModel: new PhoneItemViewModel(item),
          userState: this.userState,
          checkedNum: this.selectedNum,
          isSelectAll: this.isSelectAll,
          isShowRecentTime: true,
          isShowFileSource: false,
          curFolderUri: this.curFolderUri,
          // 图库文件夹、大文件清理页面文件禁止拖出
          enableDrag: false,
          fileSource: this.fileListSource,
          pageName: PAGE_ROUTE_CONST.FILES_BATCH_AUTH_PAGE,
          compIdIndex: index,
          toOperateFileList: this.toOperateFileList,
          pickerCheckArr: this.pickerCheckArr,
          needHighlight: this.needHighlight,
          isChecked: item.isChecked,
          isBatchAuthPage: true,
          onItemClick: this.onItemClick
        })
      }, (item: FileInfo) => FileInfo.getRefreshMark(item) + this.updateTimer)
    }.cachedCount(5)
    .width('100%')
    .align(Alignment.TopStart)
    .flexGrow(1) // 文件展示部分自动填充满剩下区域
  }
}