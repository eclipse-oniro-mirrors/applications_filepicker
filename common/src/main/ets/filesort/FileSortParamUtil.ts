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
import { FileGroupOrder, FileGroupType, FileSortOrder, FileSortType } from '../const/GroupAndSortConst';
import { GroupAndSortParam } from './GroupAndSortParam';
import { SortOrder } from '../const/Constant';

export class FileSortParamUtil {
  public static initPhoneGroupAndSortParam(order: string, isDesc: boolean,
    isRecent: boolean = false): GroupAndSortParam {
    let fileGroupType: FileGroupType = isRecent ? FileGroupType.RECENT_TIME : FileGroupType.MODIFIED_TIME;
    let fileGroupOrder: FileGroupOrder = FileGroupOrder.DESC;
    let fileSortType: FileSortType = isRecent ? FileSortType.RECENT_TIME : FileSortType.MODIFIED_TIME;
    switch (order) {
      case SortOrder.DEFAULT:
        fileGroupType = FileGroupType.NONE;
        fileGroupOrder = FileGroupOrder.ASC;
        fileSortType = FileSortType.NONE;
        break;
      case SortOrder.NAME:
        fileGroupType = FileGroupType.NAME;
        fileGroupOrder = FileGroupOrder.ASC;
        fileSortType = FileSortType.NAME;
        break;
      case SortOrder.TYPE:
        fileGroupType = FileGroupType.DISPLAY_TYPE;
        fileGroupOrder = FileGroupOrder.ASC;
        fileSortType = FileSortType.DISPLAY_TYPE;
        break;
      case SortOrder.SIZE:
        fileGroupType = FileGroupType.SIZE;
        fileGroupOrder = FileGroupOrder.ASC;
        fileSortType = FileSortType.SIZE;
        break;
      default:
        break;
    }
    return new GroupAndSortParam(fileGroupType, fileGroupOrder, fileSortType,
      isDesc ? FileSortOrder.DESC : FileSortOrder.ASC);
  }
}