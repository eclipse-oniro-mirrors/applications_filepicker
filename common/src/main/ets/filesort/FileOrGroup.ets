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

import { FileInfo } from '../fileoperate/FileInfo';

export class FileOrGroup {
  // 区分当前是文件还是组名
  public isGroup: boolean = false;
  // 如果是文件名，则此项代表在fileArray中的index。
  public fileIndex: number = 0;
  // 文件信息
  public fileInfo: FileInfo;
  // 如果是组名，则此项代表组名的枚举值
  public groupName: number = 0;
  public groupNameStr: string = '';
  // 如果是组名，则此项代表该组数量
  public groupItemCount: number = 0;
  // 组内index
  public indexInGroup: number = 0;
  public isLastInGroup: boolean = false;
  // 宫格列表展示模式
  public showMode: number = 0;
  // 宫格视图下文件列表
  public fileList: FileInfo[] = [];

  constructor(
    isGroup: boolean,
    fileIndex?: number,
    fileInfo?: FileInfo,
    groupName?: number,
    groupItemCount?: number) {
    this.isGroup = isGroup;
    this.fileIndex = fileIndex ?? 0;
    this.fileInfo = fileInfo ?? new FileInfo();
    this.groupName = groupName ?? 0;
    this.groupItemCount = groupItemCount ?? 0;
  }

  public static getRefreshMark(fileOrGroup: FileOrGroup): string {
    return fileOrGroup.isGroup + '_' + fileOrGroup.groupNameStr + '_' + fileOrGroup.fileList.length + '_' +
    fileOrGroup.groupItemCount + '_' + fileOrGroup.fileInfo?.uri + '_' + fileOrGroup.fileInfo?.mtime +
      fileOrGroup.fileInfo?.recentTime + fileOrGroup.fileInfo?.locationType +
      '_' + fileOrGroup.fileInfo?.size + '_' + fileOrGroup.fileInfo?.subFileCount;
  }
}