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

import { BasicDataSource } from './BasicDataSource';
import { FileSourceType, LocationType } from '../../const/Constant';
import { FileInfo } from '../../fileoperate/FileInfo';
import { ArrayUtil } from '../../utils/ArrayUtil';
import { GroupFileInfo } from '../../model/GroupFileInfo';
import { HiLog } from '../../dfx/HiLog';
import { PhoneFilePickerUtil } from '../utils/PhoneFilePickerUtil';
import { StartModeOptions } from '../../model/StartModeOptions';
import { FileUtil } from '../../fileoperate/FileUtil';

const TAG = 'FileDataSource';

export class FileDataSource extends BasicDataSource {
  private dataArray: FileInfo[] = [];
  public dataCount: number = 0;
  public watchFlag : WatchFlag = new WatchFlag();
  public dataReceStatus: DataReceStatus = new DataReceStatus();

  public notifySourceDataChange() {
    this.dataArray = this.dataArray;
  }

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getDataArray(): FileInfo[] {
    return this.dataArray;
  }

  public getFileList(): FileInfo[] {
    return this.dataArray.filter(item =>!item.isFolder);
  }

  public getCanChooseCount(): number {
    return this.dataArray.filter(item => item.isMultiEnable).length;
  }

  public getFileViewList(): FileInfo[] {
    return this.dataArray.filter(item => (!item.isFolder && item.isMultiEnable));
  }

  public setData(data: FileInfo[]): void {
    this.watchFlag.executeWatch = false;
    this.dataCount = data.length; // 数值相同时不会触发状态监听
    this.watchFlag.executeWatch = true;
    this.dataArray = data.slice(); // 使用新数组赋值会触发状态监听
    this.notifyDataReload();
  }

  public isExistFusionAlbum() {
    return this.dataArray.some(item => item.isFusionAlbum === true);
  }

  public getFusionAlbumUri(): string {
    return this.dataArray.find(item => item.isFusionAlbum === true)?.uri || '';
  }

  public getData(index: number): FileInfo {
    return this.dataArray[index];
  }

  // 来源页全选文件，针对分类后的文件进行过滤
  public selectAllFilterFile(uris: string[]): void {
    this.dataArray.forEach((item) => {
      if (item.isMultiEnable && uris.includes(item.uri)) {
        item.isChecked = true;
      }
    })
  }

  public selectAll(isSelected: boolean): void {
    this.dataArray.forEach((item) => {
      if (item.isMultiEnable) {
        item.isChecked = isSelected;
      }
    })
  }

  public filePickSelectAll(checkNum: number, startModeOptions: StartModeOptions): number {
    let count: number = checkNum;
    this.dataArray.forEach((item: FileInfo) => {
      if (!item.isChecked && item.isFolder &&
      PhoneFilePickerUtil.checkFileCanPick(item, count, false, startModeOptions)) {
        item.isChecked = true;
        ++count;
      }
    })
    return count;
  }

  public hasCanPickFile(checkNum: number, startModeOptions: StartModeOptions): boolean {
    return this.dataArray.some((item: FileInfo) =>!item.isChecked && item.isFolder &&
    PhoneFilePickerUtil.checkFileCanPick(item, checkNum, false, startModeOptions));
  }

  public getIndex(uri: string): number {
    return this.dataArray.findIndex(item => item?.uri === uri);
  }

  public getIndexByDecodeUri(uri: string): number {
    return this.dataArray.findIndex(item => FileUtil.decodeURIComponent(item?.uri) === uri);
  }

  public getSelectedFileList(): FileInfo[] {
    return this.dataArray.filter(item => item.isChecked);
  }

  public deSelectedFileList(): FileInfo[] {
    return this.dataArray.map((item : FileInfo): FileInfo => {
      item.isChecked = false;
      return item;
    });
  }

  public replaceData(index: number, data: FileInfo): void {
    this.dataArray.splice(index, 1, data);
    this.notifyDataChange(index);
  }

  public replaceDataSilence(index: number, data: FileInfo): void {
    this.dataArray.splice(index, 1, data);
  }

  public addData(index: number, data: FileInfo): void {
    this.dataArray.splice(index, 0, data);
    this.dataCount = this.dataArray.length;
    this.notifyDataAdd(index);
  }

  public pushData(data: FileInfo): void {
    this.dataArray.push(data);
    this.dataCount = this.dataArray.length;
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public pushDataArray(dataArray: FileInfo[]): void {
    this.watchFlag.executeWatch = false;
    this.dataCount += dataArray.length; // 数值相同时不会触发状态监听
    this.watchFlag.executeWatch = true;
    this.dataArray = this.dataArray.concat(dataArray); // 使用新数组赋值会触发状态监听
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public deleteData(index: number): void {
    this.dataArray.splice(index, 1);
    this.dataCount = this.dataArray.length;
    this.notifyDataDelete(index);
  }

  public batchDeleteData(fileUriList: string[]): void {
    const deleteUriSet = new Set(fileUriList);
    const remainFiles = this.dataArray.filter(file => !deleteUriSet.has(file.uri));
    this.setData(remainFiles);
  }

  public batchHashDeleteData(fileUriList: string[]): void {
    const deleteUriSet = new Set(fileUriList);
    let remainFiles = this.dataArray.filter(file => !deleteUriSet.has(file.uri));
    const countMap = new Map<string, number>();
    remainFiles.forEach(item => {
      const hash = item.fileSuffix;
      countMap.set(hash, (countMap.get(hash) || 0) + 1);
    });
    remainFiles = remainFiles.filter(item => {
      const duplicateFilesCount = countMap.get(item.fileSuffix);
      return duplicateFilesCount ? duplicateFilesCount > 1 : false;
    })
    this.setData(remainFiles);
  }

  public getLastFileUri(): string {
    if (ArrayUtil.isEmpty(this.dataArray)) {
      return '';
    }
    return this.dataArray[this.dataArray.length - 1].uri;
  }

  public updateItemInfo(uri: string): void {
    const index = this.getIndex(uri);
    if (index === -1) {
      return;
    }
    this.notifyDataChange(index);
  }

  public updateCheckStatus(uri: string, isChecked: boolean): void {
    const index = this.getIndex(uri);
    if (index !== -1) {
      this.dataArray[index].isChecked = isChecked;
    }
  }

  public getAllFolderName(): string[] {
    const folderList = this.dataArray.filter((fileInfo: FileInfo) => fileInfo.isFolder)
    if (ArrayUtil.isEmpty(folderList)) {
      return [];
    }
    return folderList.map((folder: FileInfo) => folder.fileName)
  }

  public freshFileListSource(): void {
    this.setData(this.dataArray)
  }

  public setDataFromGroups(groupFiles: GroupFileInfo[]): void {
    this.watchFlag.executeWatch = false;
    this.dataArray.length = 0; // 清空数组
    groupFiles.forEach(group => {
      this.dataArray = this.dataArray.concat(group.getFileDataSource().getDataArray());
    });
    this.watchFlag.executeWatch = true;
    this.notifyDataAdd(this.dataArray.length - 1);
    HiLog.info(TAG, `setDataFromGroups length : ${this.dataArray.length}`);
  }

  public getFileInfoCheckStatus(uri: string): boolean {
    let checkStatus: boolean = false;
    const index = this.getIndex(uri);
    if (index !== -1) {
      checkStatus = this.dataArray[index].isChecked;
    }
    return checkStatus;
  }
}

/**
 * 用于避免重复触发@Watch
 */
class WatchFlag {
  public executeWatch: boolean = true;
}

/**
 * 数据接收状态
 */
class DataReceStatus {
  public status: DataStatus = DataStatus.INIT;
}

export enum DataStatus {
  INIT = 0,
  PUSH,
  END
}