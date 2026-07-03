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
  BatchAuthUrisFilterTask,
  CompId,
  Constant,
  FileDataSource,
  FileDataUtil,
  FileInfo,
  FilePickerUtil,
  HiLog,
  HiSysEventUtil,
  isFastClick,
  LocationType,
  NetworkUtil,
  OperateName,
  OperateResult,
  PhoneFilePickerUtil,
  ResultCodePicker,
  StartModeOptions,
  TaskManager,
  toast,
} from '@ohos/common';
import { UiPickerButtonTips } from './picker/UiPickerButtonTips';
import { FileBatchAuthPickerView } from '@ohos/fileView';
import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { collections, JSON } from '@kit.ArkTS';
import { Loading } from './component/common/Loading';
/*批量授权文件访问权限*/
const TAG: string = 'FileBatchAuthPickerPage';

@Component
export struct FileBatchAuthPickerPage {
  @State fileListSource: FileDataSource = new FileDataSource();
  private startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();
  @State selectedNum: number = 0;
  @State isSelectAll: boolean = true;
  @State toOperateFileList: FileInfo[] = [];
  @State pickerCheckArr: string[] = [];
  @State needHighlight: boolean = true;
  private waitDownloadLists: FileInfo[] = [];
  @StorageLink('isNetwork') isNetWork: boolean = true;
  private failedUri: string = '';
  private netCon?: connection.NetConnection;
  private isNetStart: boolean = false; // 防止联网会触发2次回调
  @StorageLink('isCellular') isCellular: boolean = false;
  @State isLoading: boolean = true;
  private filterCallbackBind: Function =
    (filteredFiles: collections.Array<FileInfo>): void => this.urisFilteredCallBack(filteredFiles);

  aboutToAppear(): void {
    HiLog.info(TAG, 'about to appear');
    this.subscribeNetworkStateChange();
    const fileFilterTask : BatchAuthUrisFilterTask =
      new BatchAuthUrisFilterTask(this.filterCallbackBind, this.startModeOptions.batchAuthUris,
        this.startModeOptions.udkey);
    TaskManager.getInstance().executeTask<collections.Array<FileInfo>>(fileFilterTask);
    this.startModeOptions.pickerFlag = true;
    HiLog.info(TAG, 'about to appear end');
  }

  aboutToDisappear() {
    try {
      this.netCon?.unregister((error: BusinessError) => {
        if (error) {
          HiLog.error(TAG, 'unRegister netCon error: ' + error);
        }
      });
    } catch (e) {
      HiLog.info(TAG, `unregister err, code: ${(e as BusinessError).code}`);
    }
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.batch_grant_permission'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .maxFontScale(Constant.BIG_MODE.BIG_MODE_1x)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .id(CompId.TOP_TITLE)
      }
      .width('100%')
      .constraintSize({
        minHeight: 56
      })
      .margin({ top: 8 })
      .padding({ left: 16, right: 16 + 40 + 8 })
      Stack({ alignContent: Alignment.BottomEnd }) {
        Column() {
          if (this.isLoading) {
            Loading({ isLoading: this.isLoading })
          } else {
            FileBatchAuthPickerView({
              fileListSource: this.fileListSource,
              selectedNum: this.selectedNum,
              isSelectAll: this.isSelectAll,
              toOperateFileList: this.toOperateFileList,
              pickerCheckArr: this.pickerCheckArr,
              needHighlight: this.needHighlight,
              onItemClick: (fileItem: FileInfo, isPreview: boolean) => this.onItemClick(fileItem),
            }).height('100%')
          }
        }
        .margin({ bottom: 92 })
        Column() {
          UiPickerButtonTips({
            isShowAll: true,
            checkedNum: this.selectedNum,
            terminate: () => { this.terminate() },
          })
        }
        .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
        .width('100%')
        .margin({ bottom: 28 })
      }
      .layoutWeight(1)
    }
  }

  private terminate(): void {
    if (!this.pickerCheckArr) {
      return;
    }
    HiLog.info(TAG, `batch auth terminate, start grantPhonePermission, len: ${this.pickerCheckArr.length}`);
    PhoneFilePickerUtil.terminateFilePicker([...this.pickerCheckArr], ResultCodePicker.SUCCESS, this.startModeOptions);
  }
  /*
   * 过滤掉不可访问uri的结果之后，将uri添加到datasource
   * */
  private urisFilteredCallBack(filteredFiles: collections.Array<FileInfo>): void {
    HiLog.info(TAG, `urisFilteredCallBack len: ${filteredFiles.length}`);
    // 避免频繁操作状态变量导致性能问题
    let tempPickerCheckArr: string[] = [];
    let tempOperateFileList: FileInfo[] = []
    filteredFiles.forEach((file: FileInfo) => {
      if (file.isChecked) {
        tempPickerCheckArr.push(file.uri);
      }
      tempOperateFileList.push(file);
    });
    this.toOperateFileList = tempOperateFileList;
    this.pickerCheckArr = tempPickerCheckArr;
    this.fileListSource.setData(this.toOperateFileList);
    this.isLoading = false;
    this.selectedNum = this.pickerCheckArr.length;
    return;
  }

  private onItemClick(fileItem: FileInfo): void {
    // 如果是初始云标状态,点击文件触发下载，下载完成
    this.clickFile(fileItem);
  }

  private clickFile(fileItem: FileInfo): void {
    if (isFastClick()) {
      HiLog.info(TAG, 'clickFile too fast return');
      return;
    }
    HiLog.infoPrivate(TAG, 'clickFile fileItem is: ', JSON.stringify(fileItem));
    HiSysEventUtil.reportFileOperation(OperateName.OPEN, 'files', OperateResult.SUCCESS);
  }

  private async netLostCallBack(data: connection.NetHandle): Promise<void> {
    this.isNetWork = false;
    this.isNetStart = false;
    // 断网之后，把所有waitDownloadList里面的数据状态置为等待网络
    if (this.waitDownloadLists.length === 0 && this.failedUri) {
      const theIndex = this.fileListSource.getIndex(this.failedUri);
      const fileItem: FileInfo =
        theIndex === -1 ? FileInfo.fromFileUri(this.failedUri) : this.fileListSource.getData(theIndex);
      this.waitDownloadLists.push(fileItem);
      this.fileListSource.replaceData(theIndex, fileItem);
      return;
    }
    HiLog.info(TAG, 'netLost' + JSON.stringify(data));
  }

  /**
   * 监听网络变化，网络不可用时，给出toast 网络未连接，请检查网络设置
   */
  private subscribeNetworkStateChange(): void {
    // 创建NetConnection对象
    this.netCon = connection.createNetConnection();
    // 先使用register接口注册订阅事件
    try {
      this.netCon.register((error: BusinessError) => {
        if (error) {
          HiLog.error(TAG, `network state change register error: ${JSON.stringify(error)}`);
        }
      });
    } catch (e) {
      HiLog.error(TAG, `register: code: ${(e as BusinessError).code}`);
    }
    // 订阅网络可用事件。调用register后，才能接收到此事件通知
    this.netCon.on('netUnavailable', () => {
      HiLog.info(TAG, 'network net unavailable');
      this.isNetWork = false;
      toast($r('app.string.net_disconnect'));
    });
    // 联网后自动触发netCapabilitiesChange监听
    this.netCon.on('netCapabilitiesChange',
      async (data: connection.NetCapabilityInfo) => this.netCapabilitiesChangeCallBack(data));
    // 断网后自动触发netLost监听
    this.netCon.on('netLost', async (data: connection.NetHandle) => this.netLostCallBack(data));
  }


  // 断网后联网触发的回调
  private async netCapabilitiesChangeCallBack(data: connection.NetCapabilityInfo): Promise<void> {
    HiLog.info(TAG, `netCapabilitiesChange is: ${JSON.stringify(data.netCap.networkCap)}`);
    if (data.netCap.bearerTypes.length) {
      this.isCellular = (data.netCap.bearerTypes[0] === connection.NetBearType.BEARER_CELLULAR);
    }
    HiLog.info(TAG, `netCapabilitiesChange isCellular: ${this.isCellular}`);
    if (this.isNetStart) {
      return;
    }
    this.isNetStart = true;
    this.isNetWork = true;
    HiLog.info(TAG, 'waitDownloadLists length: ' + JSON.stringify(this.waitDownloadLists.length));
    // 联网之后，重新下载waitDownloadList里的文件
    if (this.waitDownloadLists.length && this.isNetStart) {
      const networkCap = data.netCap.networkCap;
      if (networkCap?.length && (networkCap?.indexOf(connection.NetCap.NET_CAPABILITY_INTERNET) !== -1) &&
        (networkCap?.indexOf(connection.NetCap.NET_CAPABILITY_VALIDATED) !== -1)) {
        // 联网之后先注册监听
        HiLog.info(TAG, 'wait downloadLists callback: ' + JSON.stringify(data));
        this.waitDownloadLists = [];
        this.failedUri = '';
      }
    }
  }
}