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

import { BasicDataSource, ArrayUtil, HiLog, ObjectUtil, StringUtil, FolderData, Constant,
  VirtualUri } from '@ohos/common';
import fileExtensionInfo from '@ohos.file.fileExtensionInfo';

const TAG = 'PathPickerFolderDataSource';

export class PathPickerFolderDataSource extends BasicDataSource {
  private dataArray: FolderData[] = [];

  public notifySourceDataChange() {
    this.dataArray = this.dataArray;
  }

  public totalCount(): number {
    return this.dataArray.length;
  }

  public setData(data: FolderData[]): void {
    this.dataArray = data.slice();
    this.notifyDataReload();
  }

  public getData(index: number): FolderData {
    return this.dataArray[index];
  }

  public getIndex(uri: string): number {
    return this.dataArray.findIndex(item => item?.uri === uri);
  }

  public getIndexByParentUri(uri: string): number {
    return this.dataArray.findIndex(item => item.parentUri === uri);
  }

  public addData(index: number, data: FolderData): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  /**
   * 将新获取到的目录
   * @param index
   * @param data
   * @param dataList
   * @returns
   */
  public insertFolderToList(index: number, dataList: FolderData[]): void {
    let tempList = dataList.reverse();
    for (let folder of tempList) {
      this.dataArray.splice(index + 1, 0, folder);
      this.notifyDataAdd(index + 1);
    }
  }

  public deleteData(index: number): void {
    this.dataArray.splice(index, 1);
    this.notifyDataDelete(index);
  }

  /**
   * 批量删除文件夹
   * @param fileUriList 要删除的文件夹uri列表
   */
  batchDeleteData(fileUriList: string[]): void {
    if (ArrayUtil.isEmpty(fileUriList)) {
      return;
    }
    fileUriList.forEach((fileUri) => {
      const index = this.getIndex(fileUri);
      if (index !== -1) {
        this.deleteData(index);
      }
    })
  }

  /**
   * 移除指定目录下的所有子目录
   * @param parentFolderUri 指定目录的uri
   * @param isRemoveSelf 是否移除自身
   */
  public removeAllSubFolder(parentFolderUri: string, isRemoveSelf: boolean = false): void {
    HiLog.infoPrivate(TAG, 'removeAllSubFolder, parentFolderUri:', parentFolderUri);
    if (StringUtil.isEmpty(parentFolderUri)) {
      return;
    }
    const subFolderList =
      this.dataArray.filter((item: FolderData) => {
        // 图库场景: 点击我的手机收起
        if (parentFolderUri === Constant.MY_PHONE_URI &&
          (item.uri === VirtualUri.GALLERY || item.parentUri === VirtualUri.GALLERY)) {
          return true;
        }
        return item.uri.startsWith(parentFolderUri + '/') ||
          item.parentUri === parentFolderUri
      });
    this.batchDeleteData(subFolderList.map((item: FolderData) => item.uri));
    if (isRemoveSelf) {
      const parentFolderIndex = this.getIndex(parentFolderUri);
      this.deleteData(parentFolderIndex);
    }
  }

  /**
   * 获取最后一项文件夹的uri
   * @returns
   */
  public getLastFolderUri(): string {
    if (ArrayUtil.isEmpty(this.dataArray)) {
      return ''
    }
    return this.dataArray[this.dataArray.length - 1].uri;
  }

  public getTreeMaxLocalIndex(): number {
    let len = this.dataArray.length;
    if (len === 0) {
      return len;
    }
    let count = 0;
    for (let i = 0; i < len; i++) {
      let item = this.dataArray[i];
      if (item.isRootFolder &&
        (item.deviceType !== fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK) &&
        (item.deviceType !== fileExtensionInfo.DeviceType.DEVICE_EXTERNAL_USB)) {
        break;
      }
      count++;
    }
    return count;
  }

  /**
   * 更新文件夹信息
   * @param folderData 新的文件夹信息
   */
  public updateFolderItem(folderData: FolderData): void {
    if (ObjectUtil.isNullOrUndefined(folderData) || StringUtil.isEmpty(folderData.uri)) {
      return;
    }
    const folderIndex = this.getIndex(folderData.uri);
    if (folderIndex === -1) {
      return;
    }
    this.dataArray.splice(folderIndex, 1, folderData);
    this.notifyDataChange(folderIndex);
  }

  /**
   * 设置指定目录的isLoading属性
   * @param folderUri 指定目录的uri
   * @param isLoading 是否需要展示loading
   */
  public setItemLoading(folderUri: string, isLoading: boolean): void {
    if (StringUtil.isEmpty(folderUri)) {
      return;
    }
    const folderIndex = this.getIndex(folderUri);
    if (folderIndex === -1) {
      return;
    }
    const folderData = this.getData(folderIndex);
    folderData.isLoading = isLoading;
    this.notifyDataChange(folderIndex);
  }

  /**
   * 设置指定目录的isExpend属性
   * @param folderUri 指定目录的uri
   * @param isExpend 是否需要展示目录
   */
  public setItemExpend(folderUri: string, isExpend: boolean): void {
    if (StringUtil.isEmpty(folderUri)) {
      return;
    }
    const folderIndex = this.getIndex(folderUri);
    if (folderIndex === -1) {
      return;
    }
    const folderData = this.getData(folderIndex);
    folderData.isExpend = isExpend;
    this.notifyDataChange(folderIndex);
  }
}