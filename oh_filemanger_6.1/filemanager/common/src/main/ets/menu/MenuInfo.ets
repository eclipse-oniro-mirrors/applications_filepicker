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
import { FileInfo } from '../fileoperate/FileInfo';

export enum MenuItemName {
  // 打开所在文件夹
  OPEN_FOLDER = 1,
  // 其他应用打开
  OPEN_BY_OTHER_APP,
  // 打印
  PRINT,
  // 收藏
  FAVORITE,
  // 取消收藏
  UN_FAVORITE,
  //设置为铃声
  SET_RINGTONE,
  // 设置为壁纸
  SET_WALLPAPER,
  // 多选
  MULTIPLE_CHOICES,
  // 剪切 移动
  MOVE,
  // 复制
  COPY,
  // 重命名
  RENAME,
  // 详情
  DETAILS,
  // 删除
  DELETE,
  // 还原
  RESTORE,
  // 删除访问记录
  CLEAR_RECENT_RECORD
}

export class MenuInfo {
  public menuName: MenuItemName;
  public isLongPress: boolean;
  // 后面由多选模块取代
  public selectedFiles: FileInfo[];
  public fileInfo: FileInfo;

  constructor(menuName: MenuItemName, selectedFiles: FileInfo[], fileInfo: FileInfo, isLongPress: boolean) {
    this.menuName = menuName;
    this.isLongPress = isLongPress;
    this.selectedFiles = selectedFiles;
    this.fileInfo = fileInfo;
  }
}