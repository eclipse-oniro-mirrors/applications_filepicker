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
  ArrayUtil,
  CommonPreferenceUtil,
  Constant,
  DiskInfo,
  FilePickerUtil,
  HiLog,
  ObjectUtil,
  PAGE_ROUTE_CONST,
  ResourceUtil,
  StartModeOptions
} from '@ohos/common';
import StorageDeviceItem from './StorageDeviceItem';
import fileExtensionInfo from '@ohos.file.fileExtensionInfo';
import { SideBarItemModel } from '../../model/SideBarItemModel';
import { SideBarItem } from '../../constant/SideBarItem';

const TAG = 'StorageDeviceList';

@Component
export struct StorageDeviceList {
  @StorageLink('storageDeviceList') @Watch('diskInfoChange') diskInfoArr: DiskInfo[] = [];
  private startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();

  @State storageDeviceList: SideBarItemModel[] = [];
  @Prop parentId: string;
  @Consume @Watch('refreshItemShowStatus') isEdit: boolean;
  private onDragJumpCallback: Function = () => {};
  @Prop windowStatus: number;
  @Prop orientation: number;

  aboutToAppear() {
    HiLog.info(TAG, 'StorageDeviceList aboutToAppear enter');
    this.storageDeviceList.push(SideBarItem.myPhoneItem);
    if (!this.startModeOptions.isUxt()) {
      this.storageDeviceList.push(SideBarItem.recentDeleteItem);
    }
    if (!ArrayUtil.isEmpty(this.diskInfoArr)) {
      this.diskInfoChange();
    }
    this.refreshItemShowStatus();
    HiLog.info(TAG, 'StorageDeviceList aboutToAppear end');
  }

  refreshItemShowStatus(): void {
    HiLog.info(TAG, 'refreshItemShowStatus begin');
    let itemArray = [];
    for (let i = 0; i < itemArray.length; i++) {
      this.refreshSingleItemShowStatus(itemArray[i]);
    }
  }

  refreshSingleItemShowStatus(item: SideBarItemModel): void {
    if (ObjectUtil.isNullOrUndefined(item)) {
      HiLog.error(TAG, 'item is null or undefined.')
      return;
    }
    let index: number = this.storageDeviceList.indexOf(item);
    if (index >= 0 && index < this.storageDeviceList.length) {
      let singleItem: SideBarItemModel = this.storageDeviceList[index];
      singleItem.isShow = CommonPreferenceUtil.getLocationItemShowStatus(singleItem.itemName);
      this.storageDeviceList.splice(index, 1, singleItem);
    } else {
      HiLog.warn(TAG, `refreshItemShowStatus, no ${item.uri}`);
    }
  }

  build() {
    List() {
      ForEach(this.storageDeviceList, (info: SideBarItemModel, index) => {
        // 浏览页编辑状态、未设置是否展示值默认展示、isShow为true时展示存储位置项目
        if (this.isEdit || info.isShow === undefined || info.isShow) {
          StorageDeviceItem({
            info: info,
            startModeOptions: this.startModeOptions,
            parentId: this.parentId,
            onDragJumpCallback: this.onDragJumpCallback,
            isItemShow: info.isShow,
            windowStatus: this.windowStatus,
            orientation: this.orientation,
            refreshStorageDeviceItem: (item: SideBarItemModel) => {
              this.refreshSingleItemShowStatus(item)
            }
          });
        }
      })
    }
    .divider( { color:$r('sys.color.ohos_id_color_list_separator'), startMargin:52, endMargin: 12, strokeWidth: 0.3 })
    .borderRadius($r('app.float.common_borderRadius20'))
    .width('100%')
    .padding({
      top: $r('app.float.common_padding4'),
      bottom: $r('app.float.common_padding4')
    })
  }

  diskInfoChange() {
    // 默认展示我的手机和最近删除
    if ((this.diskInfoArr.length <= 1) && (this.storageDeviceList.length === 2)) {
      return;
    }
    this.storageDeviceList = [];
    // 我的手机
    this.storageDeviceList.push(SideBarItem.myPhoneItem);
    if (!this.startModeOptions.isUxt()) {
      // 最近删除
    }
    this.diskInfoArr.forEach((diskInfo, index) => {
      const isLocalDisk = diskInfo.deviceType === fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK;
      if (!isLocalDisk) {
        const externalSideBarItem: SideBarItemModel = {
          icon: diskInfo.isTfCard ? $r('app.media.ic_sd_card') : $r('app.media.ic_usb'),
          name: diskInfo.isTfCard ? $r('app.string.externalDisk') : diskInfo.description,
          uri: PAGE_ROUTE_CONST.MY_PHONE,
          deviceType: diskInfo.deviceType,
          num: Constant.LOCATION_LIST.MY_PHONE,
          rootUri: diskInfo.uri,
          uuid: diskInfo.uuid,
          dragEnable: true,
          isTfCard: diskInfo.isTfCard
        };
        if (this.startModeOptions.callerBundleName !== Constant.FILE_MANAGER_BUNDLE_NAME ||
          AppStorage.get<boolean>('isUploadPicker')) {
          if (diskInfo.isTfCard) {
            this.storageDeviceList.splice(1, 0, externalSideBarItem);
          } else {
            this.storageDeviceList.push(externalSideBarItem);
          }
        }
      }
    });

    if (!this.startModeOptions.isUxt()) {
      // 最近删除
      this.storageDeviceList.push(SideBarItem.recentDeleteItem);
    }
  }
}