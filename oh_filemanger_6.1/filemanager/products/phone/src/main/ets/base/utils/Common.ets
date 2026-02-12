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

import { getResourceString } from '@ohos/common/src/main/ets/utils/Tools';
import {
  AddressData,
  BundleResourceUtil,
  Constant,
  DeviceConfig,
  DiskInfo,
  FileUtil,
  FolderData,
  HiLog,
  ObjectUtil,
  StringUtil,
  UiUtil,
  VirtualUri
} from '@ohos/common';
import fileExtensionInfo from '@ohos.file.fileExtensionInfo';
import { BOTTOM_BAR_MAP } from '@ohos/common/src/main/ets/const/UiConstant';
import { BottomOptions } from '@ohos/bottomBar';
import { MENU_ICONS } from '@ohos/titleBar';

/**
 * 获取根目录名称
 * @param diskInfo info
 * @returns 名称
 */
export function getDiskDes(diskInfo: DiskInfo): undefined | string {
  if (ObjectUtil.isNullOrUndefined(diskInfo)) {
    return getResourceString(DeviceConfig.getInstance().config.myDevice);
  }
  if (diskInfo.deviceType === fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK) {
    return getResourceString(DeviceConfig.getInstance().config.myDevice);
  }
  if (StringUtil.isEmpty(diskInfo.description)) {
    return getResourceString($r('app.string.externalDisk'));
  }
  return diskInfo.description;
}

export function updateFolderNameAndFileNameResource(folderData: FolderData, fileName: string,
  deviceType: number): FolderData {
  let nameResource: Resource | string = getFileNameResourceByDevice(fileName, deviceType);
  if (typeof nameResource === 'string') {
    folderData.fileName = fileName;
  } else {
    folderData.fileName = getResourceString(nameResource);
    folderData.fileNameResource = nameResource;
  }
  return folderData;
}

export function getFileNameResourceByDevice(fileName: string, deviceType: number): Resource | string {
  switch (deviceType) {
    case fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK:
      return DeviceConfig.getInstance().config.myDevice;
  }
  if (StringUtil.isEmpty(fileName)) {
    HiLog.info('getFileNameResourceByDevice', 'root device filename empty');
    return $r('app.string.externalDisk');
  }
  return fileName;
}


/**
 * 根据面包屑获取当前展示文件夹的路径
 * ****由于FAF提供的文件相对路径带有前缀，该方法属于临时方案******
 *
 * @param direList direList
 * @param isEndAdd isEndAdd
 * @returns path
 */
export function getCurrentFolderPathByBreadCrumb(direList: AddressData[], isEndAdd: boolean): string {
  let path: string = '';
  for (let i = 0; i < direList.length; i++) {
    const item = direList[i].name;
    if (i === 0) {
      let realName: string = '';
      if (direList[i].uri.startsWith(VirtualUri.MY_PHONE)) {
        let uri = direList[i].uri.replace(VirtualUri.MY_PHONE, '');
        let index = uri.indexOf('/', 1);
        realName = FileUtil.decodeURIForFileManager(index !== -1 ? uri.substring(1, index) : uri.substring(1));
        path += UiUtil.translateFileNameByUri(FileUtil.decodeURIForFileManager(direList[i].uri), realName, true) ===
          item ? `/${realName}` : `/${item}`;
      } else {
        path += `/${item}`;
      }
    } else if (i === 1) {
      if (direList[i].uri.startsWith(VirtualUri.DOWNLOAD)) {
        path += decodeURIComponent(direList[i].uri.replace(VirtualUri.DOWNLOAD, ''));
      } else {
        path += `/${item}`;
      }
    } else {
      path += `/${item}`;
    }
  }
  if (isEndAdd) {
    path += '/';
  }
  return path;
}

/**
 * 判断menu能否点击
 *
 * @param checkedNum 选中文件数
 * @param operationType 操作类型
 * @returns 是否可点击，true可以点击 false不可点击
 */
export function menuCanClick(checkedNum: number, operationType: string): boolean {
  if (operationType) {
    if (operationType === Constant.OPERATION_TYPE.SELECT_ALL ||
      operationType === Constant.OPERATION_TYPE.DESELECT_ALL) {
      return true;
    } else if (!checkedNum) {
      return false;
    }
    return true;
  }
  return false;
}

export function getFilePickBottomOptions(isSelectAll: boolean): Array<BottomOptions> {
  let bottomOption: BottomOptions[] = [];
  if (isSelectAll) {
    bottomOption.push(new BottomOptions(
      Constant.OPERATION_TYPE.DESELECT_ALL,
      BOTTOM_BAR_MAP.deselectAll,
      MENU_ICONS.selectAll,
      false,
      true
    ));
  } else {
    bottomOption.push(new BottomOptions(
      Constant.OPERATION_TYPE.SELECT_ALL,
      BOTTOM_BAR_MAP.selectAll,
      MENU_ICONS.all,
      false,
      true
    ));
  }
  return bottomOption;
}

export function getSelectBottomOptions(bottomOption: Array<BottomOptions>, isSelectAll: boolean): Array<BottomOptions> {
  bottomOption.forEach((item, index) => {
    if ((!isSelectAll) && (item.type === Constant.OPERATION_TYPE.DESELECT_ALL)) {
      bottomOption[index] = new BottomOptions(
        Constant.OPERATION_TYPE.SELECT_ALL,
        BOTTOM_BAR_MAP.selectAll,
        MENU_ICONS.all,
        false,
        true
      )
    } else if (isSelectAll && (item.type === Constant.OPERATION_TYPE.SELECT_ALL)) {
      bottomOption[index] = new BottomOptions(
        Constant.OPERATION_TYPE.DESELECT_ALL,
        BOTTOM_BAR_MAP.deselectAll,
        MENU_ICONS.selectAll,
        false,
        true
      )
    }
  })
  return bottomOption;
}

