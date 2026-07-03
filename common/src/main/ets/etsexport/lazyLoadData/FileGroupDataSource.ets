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
import { FileOrGroup } from '../../filesort/FileOrGroup';
import { HiLog } from '../../dfx/HiLog';

const TAG = 'GroupDataSource';

export class FileGroupDataSource extends BasicDataSource {
  private dataGroupArray: FileOrGroup[] = [];
  public dataCount: number = 0;
  public fileCount: number = 0;
  public groupIndexs: number[] = [];
  // 将所有files替换到原来的filedatasource后，此map记录file在filedatasource中的索引和fileOrGroups中索引的映射
  public indexMap: Map<number, number> = new Map();

  public totalCount(): number {
    return this.dataGroupArray.length;
  }

  public getData(index: number): FileOrGroup {
    return this.dataGroupArray[index];
  }

  public getDataArray(): FileOrGroup[] {
    return this.dataGroupArray;
  }

  public setData(fileOrGroupInfo: FileOrGroupInfo): void {
    HiLog.info(TAG,
      `setData, fileOrGroups lenghth : ${fileOrGroupInfo.fileOrGroups.length}, fileCount : ${fileOrGroupInfo.fileCount}`);
    this.dataGroupArray = fileOrGroupInfo.fileOrGroups;
    this.dataCount = this.dataGroupArray.length;
    this.fileCount = fileOrGroupInfo.fileCount;
    this.groupIndexs = fileOrGroupInfo.groupIndexs;
    this.indexMap = fileOrGroupInfo.indexMap;
    this.notifyDataReload();
    HiLog.info(TAG, `setData, end`);
  }

  /*
   * 通过Uri获取文件在dataGroupArray中的Index(包含组名)
   * */
  public getIndexIncludingGroupsByUri(targetUri: string): number {
    return this.dataGroupArray.findIndex(item => item?.fileInfo?.uri === targetUri);
  }

  public getIndexOfOriginalFileDataSource(itemIndex: number): number {
    let count: number = 0;
    for (let gIndex of this.groupIndexs) {
      if (gIndex < itemIndex) {
        count++;
      } else {
        break;
      }
    }
    return itemIndex - count;
  }

  /**
   * 获取原始文件数据源的索引
   * @param groupIndex 分组索引
   * @param gridIndex 网格索引
   * @returns 原始文件数据源的索引
   */
  public getIndexOfOriFileDataSource(groupIndex: number, gridIndex: number): number {
    // 获取当前组的数据
    const groupData = this.getData(groupIndex);
    const dataArray = this.getDataArray().slice(0, groupIndex);

    let gridNum: number = gridIndex;
    let previousGroupsTotal: number = 0;

    // 计算前面组的文件总数
    for (let i = 0; i < dataArray.length; i++) {
      if (dataArray[i].isGroup) {
        continue;
      }
      if (dataArray[i].showMode === 1) {
        previousGroupsTotal += dataArray[i].fileList.length;
      } else {
        // 列表视图下只包含一个文件
        previousGroupsTotal += 1;
      }
    }
    if (groupData.showMode === 1 && gridIndex >= groupData.fileList.length) {
      gridNum = groupData.fileList.length - 1;
    }
    // 计算最终索引
    const total = previousGroupsTotal + gridNum;
    // 调试日志
    HiLog.debug(TAG, `groupIndex:${groupIndex} previousGroupsTotal:${previousGroupsTotal}
     gridIndex:${gridIndex} total:${total} gridNum:${gridNum}`);

    return total;
  }

  /**
   * 更新组内FileInfo
   * @param originalIndex
   */
  public updateFileItemInGroup(fileUri: string): void {
    const index: number = this.dataGroupArray.findIndex(fileOrGroup => {
      if (fileOrGroup.fileList.length > 0) {
        return fileOrGroup.fileList.find(fileInfo => fileInfo.uri === fileUri) !== undefined;
      }
      return fileOrGroup.fileInfo.uri === fileUri;
    });

    if (index !== -1) {
      this.notifyDataChange(index);
      HiLog.info(TAG, `updateFileItemInGroup success, index : ${index}`);
    } else {
      HiLog.warnPrivate(TAG, `updateFileItemInGroup, value of fileUri not exists: `, `${fileUri}`);
    }
  }

  public getSharedGroupName(startIndex: number): string {
    let sharedGroupName = '';
    if (this.groupIndexs.length === 1) {
      sharedGroupName = this.getData(0).groupNameStr;
      return sharedGroupName;
    }
    for (let i = 1; i < this.groupIndexs.length; i++) {
      if (startIndex <= this.groupIndexs[i]) {
        sharedGroupName = this.getData(this.groupIndexs[i - 1]).groupNameStr;
        break;
      }
    }
    if (startIndex > this.groupIndexs[this.groupIndexs.length - 1]) {
      sharedGroupName = this.getData(this.groupIndexs[this.groupIndexs.length - 1]).groupNameStr;
    }
    return sharedGroupName;
  }
}

export class FileOrGroupInfo {
  public fileOrGroups: FileOrGroup[] = [];
  public fileCount: number = 0;
  public groupIndexs: number[] = [];
  public indexMap: Map<number, number> = new Map();
}