/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { FileGroupType, FileGroupOrder, FileSortType, FileSortOrder } from '../const/GroupAndSortConst';

export class GroupAndSortParam {
  /**
   * 文件分组类型
   */
  fileGroupType: FileGroupType = FileGroupType.NONE;

  /**
   * 文件分组升降序
   */
  fileGroupOrder: FileGroupOrder = FileGroupOrder.ASC;

  /**
   * 文件排序类型
   */
  fileSortType: FileSortType = FileSortType.NONE;

  /**
   * 文件排序升降序
   */
  fileSortOrder: FileSortOrder = FileSortOrder.DESC;

  constructor(fileGroupType: FileGroupType = FileGroupType.NONE, fileGroupOrder: FileGroupOrder = FileGroupOrder.ASC,
              fileSortType: FileSortType = FileSortType.NONE, fileSortOrder: FileSortOrder = FileSortOrder.DESC) {
    this.fileGroupType = fileGroupType;
    this.fileGroupOrder = fileGroupOrder;
    this.fileSortType = fileSortType;
    this.fileSortOrder = fileSortOrder;
  }
}