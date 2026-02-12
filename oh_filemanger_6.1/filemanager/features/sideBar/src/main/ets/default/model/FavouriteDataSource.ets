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
import { ObjectUtil, ArrayUtil, BasicDataSource, FavoriteModel } from '@ohos/common';

export class FavouriteDataSource extends BasicDataSource {
  private dataArray: FavoriteModel[] = [];
  public dataCount: number = 0;

  public notifySourceDataChange() {
    this.dataArray = this.dataArray;
  }

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getDataArray(): FavoriteModel[] {
    return this.dataArray;
  }

  public setData(data: FavoriteModel[]): void {
    this.dataArray = data.slice();
    this.dataCount = this.dataArray.length;
    this.notifyDataReload();
  }

  public getData(index: number): FavoriteModel {
    return this.dataArray[index];
  }

  public replaceData(index: number, data: FavoriteModel): void {
    this.dataArray.splice(index, 1, data);
    this.notifyDataChange(index);
  }

  public addData(index: number, data: FavoriteModel): void {
    this.dataArray.splice(index, 0, data);
    this.dataCount = this.dataArray.length;
    this.notifyDataAdd(index);
  }

  public pushData(data: FavoriteModel): void {
    this.dataArray.push(data);
    this.dataCount = this.dataArray.length;
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public deleteData(index: number): void {
    this.dataArray.splice(index, 1);
    this.dataCount = this.dataArray.length;
    this.notifyDataDelete(index);
  }

  public deleteDataByPath(path: string): void {
    let index = this.dataArray.findIndex(item => item.path === path)
    if (index !== -1) {
      this.dataArray.splice(index, 1);
      this.dataCount = this.dataArray.length;
      this.notifyDataDelete(index);
    }
  }

  public getIndex(path: string): number {
    return this.dataArray.findIndex(item => item.path === path);
  }

  public getLastItem(): FavoriteModel {
    if (ObjectUtil.isNullOrUndefined(this.dataArray) || ArrayUtil.isEmpty(this.dataArray)) {
      return new FavoriteModel();
    }
    return this.dataArray[this.dataArray.length - 1]
  }
}