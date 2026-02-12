/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import fileExtensionInfo from '@ohos.file.fileExtensionInfo';

export class RootInfo {
  public displayName: string = '';
  public deviceType: fileExtensionInfo.DeviceType = fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK;
  public uri: string = '';
  public relativePath: string = '';
  public deviceFlags: number = 0;
}

export class DiskInfo {
  uuid: string;
  description: string;
  uri: string = '';
  deviceType: number = fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK;
  displayName: string = '';
  path?: string;
  relativePath: string;
  isTfCard: boolean;

  constructor(uuid: string = '', description: string = '', path: string = '', rootInfo?: RootInfo,
    isTfCard: boolean = false) {
    this.uuid = uuid;
    this.description = description;
    this.path = path;
    this.uri = rootInfo?.uri;
    this.deviceType = rootInfo?.deviceType;
    this.displayName = rootInfo?.displayName;
    this.relativePath = rootInfo?.relativePath;
    this.isTfCard = isTfCard;
  }
}

export class DiskChangeInfo {
  diskManagerIsChange: boolean;
  uuid: string;

  constructor(diskManagerIsChange: boolean, uuid: string = '') {
    this.diskManagerIsChange = diskManagerIsChange;
    this.uuid = uuid;
  }
}

export class DiskInfoForDialog {
  flag: boolean;
  param: string;

  constructor(flag: boolean, param: string = '') {
    this.flag = flag;
    this.param = param;
  }
}

export class StorageSpaceInfo {
  public deviceType: string = '';
  public totalSpaceSize: number = 0;
  public freeSpaceSize: number = 0;

  constructor(deviceType: string, totalSize: number, freeSize: number) {
    this.deviceType = deviceType;
    this.totalSpaceSize = totalSize;
    this.freeSpaceSize = freeSize;
  }
}