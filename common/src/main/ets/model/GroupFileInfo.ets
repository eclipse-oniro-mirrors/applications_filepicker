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
import { FileDataSource } from '../etsexport/lazyLoadData/FileDataSource';
import { FileInfo } from '../fileoperate/FileInfo';
import { BasicDataSource } from '../lazyLoadData/BasicDataSource';


export class GroupFileInfo {
  // 组名
  private groupName: ResourceStr;
  // 组下标
  private groupIndex: number;
  // 组内数据列表
  private fileDataSource: FileDataSource;

  private showMode : number = 0; // 根据不同业务场景，展示模式不同

  constructor(groupName: ResourceStr, groupIndex: number, fileDataSource: FileDataSource, showMode : number = 0) {

    this.groupName = groupName;

    this.groupIndex = groupIndex;

    this.fileDataSource = fileDataSource;

    this.showMode = showMode;
  }

  public getFileDataSource() {
    return this.fileDataSource;
  }

  public getGroupName() {
    return this.groupName
  }

  public getGroupIndex() {
    return this.groupIndex
  }

  public setFileDataSource(fileDataSource: FileDataSource) {
    this.fileDataSource = fileDataSource;
  }

  public setGroupName(groupName: ResourceStr) {
    this.groupName = groupName;
  }

  public setGroupIndex(groupIndex: number) {
    this.groupIndex = groupIndex;
  }

  public getShowMode() {
    return this.showMode;
  }

  // 根据size大小进行分片处理
  public getDoubleFileDataSource(size :number) : DoubleFileDataSource {
    const fileDataSource = this.fileDataSource;
    const chunkSize = size;

    // 判断fileDataSource是否为空
    if (!fileDataSource || fileDataSource.dataCount === 0) {
      return new DoubleFileDataSource([]);
    }
    const dataSourceArray: FileInfo[][] = [];
    // 计算分片数
    const chunkCount = Math.ceil(fileDataSource.dataCount / chunkSize);

    for (let i = 0; i < chunkCount; i++) {
      const start = i * chunkSize;
      const end = Math.min(start + chunkSize, fileDataSource.dataCount);
      const chunk = fileDataSource.getDataArray().slice(start, end);
      dataSourceArray.push(chunk);
    }
    return new DoubleFileDataSource(dataSourceArray);
  }
}


class DoubleFileDataSource extends BasicDataSource {
  private dataArray: FileInfo[][];

  constructor(arr: FileInfo[][]) {
    super();
    this.dataArray = arr;
  }

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): FileInfo[] {
    return this.dataArray[index];
  }

  public setData(data: FileInfo[][]): void {
    this.dataArray = data.slice();
    this.notifyDataReload();
  }

  public changeArray(lazyNums: FileInfo[][]): void {
    this.dataArray = lazyNums;
    this.notifyDataReload();
  }

  public addData(index: number, data: FileInfo[]): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public deleteData(index: number): void {
    this.dataArray.splice(index, 1);
    this.notifyDataDelete(index);
  }

  public getDataArray(): FileInfo[][] {
    return this.dataArray;
  }
}