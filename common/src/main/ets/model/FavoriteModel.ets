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

import { DataSourceDeviceType } from '../const/Constant';
import { FavoriteModelUtil } from '../favorite/FavoriteModelUtil';

/**
 * 收藏数据模型
 * 基本类型需要序列化，不能写公有方法，可写到FavoriteModelUtil
 */
export class FavoriteModel {
  public id: number = -1;
  public name: string = '';
  public path: string = '';
  public modifyTime: number = 0;
  public setTime: number = 0;
  public recycled: boolean = false;
  public deviceType: DataSourceDeviceType = DataSourceDeviceType.DEVICE_INTERNAL;
  public externalStorageUUID: string = '';
  public sortIndex: number = 0;
  public oldSortIndex: number = -1;

  constructor(id: number = -1, name: string = '', path: string = '', modifyTime: number = 0, setTime: number = 0,
    recycledStatus: number = 0, deviceType: number = DataSourceDeviceType.DEVICE_INTERNAL,
    uuid: string = '', sortIndex: number = -1) {
    this.id = id;
    this.name = name;
    this.path = path;
    this.modifyTime = modifyTime;
    this.setTime = setTime;
    this.recycled = FavoriteModelUtil.isRecycled(recycledStatus);
    this.deviceType = FavoriteModelUtil.getDeviceTypeByNumber(deviceType);
    this.externalStorageUUID = uuid;
    this.sortIndex = sortIndex;
  }
}
