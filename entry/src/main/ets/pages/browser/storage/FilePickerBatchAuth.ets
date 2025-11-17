/*
 * Copyright (c) 2021-2025 Huawei Device Co., Ltd.
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
import Logger from '../../../base/log/Logger';
import { StartModeOptions } from '../../../base/model/StartModeOptions';
import AbilityCommonUtil, { ResultCodePicker } from '../../../base/utils/AbilityCommonUtil';
import { FilePickerUtil } from '../../../base/utils/FilePickerUtil';
import { getResourceString } from '../../../base/utils/Tools';
import { BreadData, FileDataSource, FilesData } from '../../../databases/model/FileData';
import { TaskManager } from '../../../taskpool/manager/TaskManager';
import { BatchAuthFilterTask } from '../../../taskpool/task/BatchAuthFilterTask';
import { Loading } from '../../component/common/Loading';
import { TopBar } from '../../component/common/TopBar';
import { FilesList } from '../../component/myphone/FilesList';

const TAG = 'FilePickerBatchAuth';
let storage = LocalStorage.getShared();

@Entry(storage)
@Component
struct FilePickerBatchAuth {
  @State checkedList: FilesData[] = [];
  @State isMulti: boolean = true;
  @State selectAll: boolean = true;
  @State @Watch('checkedNumChange') checkedNum: number = 0;
  private startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();
  @State isShowLoading: boolean = true;
  @State fileListSource: FileDataSource = new FileDataSource();
  @State direList: BreadData[] = [];
  @Provide isList: boolean = true;

  backCallback(): void {
    FilePickerUtil.terminateFilePicker([], ResultCodePicker.SUCCESS, this.startModeOptions);
  }

  menuCallback(): void {
  }

  startFilterUri(): void {
    let task = new BatchAuthFilterTask(this.startModeOptions.batchAuthUris, this.startModeOptions.udkey, (fileList: FilesData[]) => {
      this.setData(fileList);
    })
    TaskManager.getInstance().executeTask(task);
  }

  setData(fileList: FilesData[]): void {
    fileList.forEach(data => {
      data.isChecked = true;
      this.checkedList.push(data);
    });
    this.fileListSource.setData(fileList);
    this.checkedNum = this.checkedList.length;
    this.isShowLoading = false;
  }

  checkedNumChange(): void {
    this.selectAll = this.checkedNum === this.fileListSource.totalCount();
    this.checkedList = this.fileListSource.getSelectedFileList();
  }

  aboutToAppear(): void {
    this.startFilterUri();
  }

  build() {
    Column() {
    }.bindSheet(true, this.mainContent(), {
      height: '95%',
      dragBar: false,
      showClose: false,
      preferType: SheetType.CENTER,
      onAppear: () => {
      },
      shouldDismiss: () => {
        this.startModeOptions.session.terminateSelf();
      }
    })
  }

  @Builder
  mainContent() {
    Column() {
      // 头部导航
      TopBar({
        startModeOptions: this.startModeOptions,
        title: getResourceString($r('app.string.batch_auth_page_title')),
        isMulti: this.isMulti,
        selectAll: this.selectAll,
        checkedNum: $checkedNum,
        checkedList: $checkedList,
        backCallback: this.backCallback.bind(this),
        menuCallback: this.menuCallback.bind(this)
      })
      Column() {
        Loading({ isLoading: !!this.isShowLoading })
        if (!this.isShowLoading) {
          // 文件列表
          FilesList({
            startModeOptions: this.startModeOptions,
            fileListSource: $fileListSource,
            direList: $direList,
            isMulti: $isMulti,
            checkedNum: $checkedNum
          })
        }
      }.layoutWeight(1)
    }
    .width('100%')
  }
}