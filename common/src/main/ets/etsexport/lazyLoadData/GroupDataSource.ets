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
import { GroupFileInfo } from '../../model/GroupFileInfo';
import { HiLog } from '../../dfx/HiLog';

const TAG = 'GroupDataSource';

export class GroupDataSource extends BasicDataSource {
  private groupArray: GroupFileInfo[] = [];

  public totalCount(): number {
    return this.groupArray.length;
  }

  public totalFileCount(): number {
    const totalFileCount = this.groupArray.reduce((sum, group) => sum + group.getFileDataSource().totalCount(), 0);
    return totalFileCount;
  }

  public setData(newGroupArray: GroupFileInfo[]): void {
    HiLog.info(TAG, `setData, groupArray lenghth : ${newGroupArray.length}`);
    this.groupArray = newGroupArray;
    this.notifyDataReload();
    HiLog.info(TAG, `setData end, totalFileCount : ${this.totalFileCount()}`);
  }

  public getData(index: number): GroupFileInfo {
    return this.groupArray[index];
  }

  public getAllData(): GroupFileInfo[] {
    return this.groupArray;
  }

  public getIndexOfOriginalFileDataSource(groupIndex: number, itemIndexInGroup: number): number {
    let sum = 0;
    for (let index = 0; index < groupIndex; index++) {
      sum += this.groupArray[index].getFileDataSource().totalCount();
    }
    return sum + itemIndexInGroup;
  }

  private getFileInfoInGroup(originalIndex: number): FileInfoInGroup {
    let total = 0;
    let fileInfoInGroup = new FileInfoInGroup();
    for (let group of this.groupArray) {
      const fileCount = group.getFileDataSource().totalCount();
      if (originalIndex < total + fileCount) {
        const itemIndexInGroup = originalIndex - total;
        fileInfoInGroup.groupIndex = group.getGroupIndex();
        fileInfoInGroup.itemIndexInGroup = itemIndexInGroup;
        break;
      }
      total += fileCount;
    }
    HiLog.info(TAG, `getFileInfoInGroup, fileInfoInGroup : ${JSON.stringify(fileInfoInGroup)}`);
    return fileInfoInGroup;
  }

  /**
   * 更新组内FileInfo
   * @param originalIndex
   */
  public updateFileItemInGroup(originalIndex: number): void {
    let fileInfoInGroup = this.getFileInfoInGroup(originalIndex);
    let groupIndex = fileInfoInGroup.groupIndex;
    let itemIndexInGroup = fileInfoInGroup.itemIndexInGroup;
    if (groupIndex < 0 || groupIndex >= this.groupArray.length || itemIndexInGroup < 0) {
      HiLog.info(TAG, `updateFileItemInGroup, index err`);
      return;
    }
    this.groupArray[groupIndex].getFileDataSource().notifyDataChange(itemIndexInGroup);
    HiLog.info(TAG, `updateFileItemInGroup success`);
  }
}

class FileInfoInGroup {
  public groupIndex: number = -1;
  public itemIndexInGroup: number = -1;
}