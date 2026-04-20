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
import { FileGroupType, FileGroupOrder, FileSortType, FileSortOrder } from './GroupAndSortConst';
import { GroupAndSortParam } from '../filesort/GroupAndSortParam';

/**
 * uri of the virtual directory
 */
export enum VirtualUri {
  // Quick Access
  RECENT = 'recent',
  DESKTOP = 'file://docs/storage/Users/currentUser/Desktop',
  DOWNLOAD = 'file://docs/storage/Users/currentUser/Download',
  DOWNLOAD_PATH = '/storage/Users/currentUser/Download',
  APPDATA = 'file://docs/storage/Users/currentUser/appdata',
  BLUETOOTH = 'file://docs/storage/Users/currentUser/Download/com.ohos.locationdialog',
  SHARE = 'file://docs/storage/Users/currentUser/Share',
  APPDATA_EL1_BASE = 'file://docs/storage/Users/currentUser/appdata/el1/base/',
  APPDATA_EL2_BASE = 'file://docs/storage/Users/currentUser/appdata/el2/base/',
  RECYCLE_BIN = 'recycleBin',
  // Storage Location
  MY_PC = 'file://docs/storage/Users/currentUser',
  MY_PHONE = 'file://docs/storage/Users/currentUser',
  DOCUMENT = 'file://docs/storage/Users/currentUser/Documents',
  EXTERNAL_DISK = 'file://docs/storage/External',
  PCENGINE = 'file://docs/storage/Users/currentUser/PCEngine',
  IMAGES = 'file://docs/storage/Users/currentUser/Images',
  IN_RECYCLE_BIN = 'file://docs/storage/Users/currentUser/.Trash',
  // gallery
  GALLERY = 'gallery',
  IMAGE = 'gallery/IMAGE',
  VIDEO = 'gallery/VIDEO',
  GALLERY_URI = 'file://media/PhotoAlbum',
  GALLERY_PHOTO_URI = 'file://media/Photo/',
  BROWSER = 'file://docs/storage/Users/currentUser/Download/com.ohos.browser',
  BROWSER_PATH = '/storage/Users/currentUser/Download/com.ohos.browser',
  LOCAL_PATH_HEAD = '/storage/Users/currentUser',
  EXTERNAL_PATH_HEAD = '/storage/External',

  // fileTag
  FILE_TAG = 'fileTag',
  // uri头部
  URI_HEAD = 'file://docs',
  // 文件处于回收站的标识
  URI_TRASH = '/.Trash/',
  // 沙箱文件头部
  SAND_BOX_URI_HEAD = 'file://com.',
  DOWNLOAD_RECEIVE = 'DownloadReceive',
  // rootTag
  ROOT_Tag = 'root',
  // 录音机Sounds目录
  SOUNDS_FOLDER = 'file://docs/storage/Users/currentUser/Sounds',
}

/**
 * 需要屏蔽的目录
 */
export enum ShieldUri {
  FILE_MANAGER = 'file://docs/storage/Users/currentUser/appdata/el2/base/com.ohos.filemanager',
  APP_DATA = 'file://docs/storage/Users/currentUser/appdata',
}

/**
 * value in FileView corresponds to value in ActionBar
 */
export enum FileView {
  GRID = 1,
  LIST,
  SECTION
}

export enum GridViewItemSize {
  SMALL,
  MEDIUM,
  BIG
}

export enum RecordParam {
  FILE_VIEW = 0,
  GRID_SIZE,
  GROUP_TYPE,
  GROUP_ORDER,
  SORT_TYPE,
  SORT_ORDER,
  MOD_TIME
}

export class FolderRecord {
  fileView: FileView;
  gridSize: GridViewItemSize;
  groupType: FileGroupType;
  groupOrder: FileGroupOrder;
  sortType: FileSortType;
  sortOrder: FileSortOrder;
  modTime: number; // ms

  constructor() {
    this.fileView = FileView.GRID;
    this.gridSize = GridViewItemSize.MEDIUM;
    this.groupType = FileGroupType.NONE;
    this.groupOrder = FileGroupOrder.ASC;
    this.sortType = FileSortType.NONE;
    this.sortOrder = FileSortOrder.DESC;
    this.modTime = new Date().getTime();
  }
}

export interface RecordData {
  fileView?: FileView;
  gridSize?: GridViewItemSize;
  groupType?: FileGroupType;
  groupOrder?: FileGroupOrder;
  sortType?: FileSortType;
  sortOrder?: FileSortOrder;
  nameWidth?:number,
  dateWidth?: number,
  typeWidth?:number,
  sizeWidth?:number,
  pathWidth?:number
}

export class RecentStructure {
  recycleBin: RecordData;
  recent: RecordData;
  picker: RecordData;
  constructor(recycleBin: RecordData, recent: RecordData, picker: RecordData) {
    this.recycleBin = recycleBin;
    this.recent = recent;
    this.picker = picker;
  }
}

export class CommonStructure {
  fileHashAndSize: string;
  interfaceSetting: RecordData;

  constructor(fileHashAndSize: string, interfaceSetting: RecordData) {
    this.fileHashAndSize = fileHashAndSize;
    this.interfaceSetting = interfaceSetting;
  }
}

export class EchoDataStructure {
  fileView: FileView;
  gridSize: GridViewItemSize;
  GroupAndSort: GroupAndSortParam;
  widthArray: number[];

  constructor(fileView: FileView = FileView.LIST,
    gridSize: GridViewItemSize = GridViewItemSize.MEDIUM,
    GroupAndSort: GroupAndSortParam = new GroupAndSortParam(), widthArray: number[] = [0, 0, 0, 0, 0, 0]) {
    this.fileView = fileView;
    this.gridSize = gridSize;
    this.GroupAndSort = GroupAndSort;
    this.widthArray = widthArray;
  }
}

export class GridItemControlSize {
  public imageSize: number = 0;
  public appIconSize: number = 0;
  public imageStackSize: number = 0;
  public wholeHeight: number = 0;
  public appIconOffset: number = 0;

  constructor(imageSize: number, wholeHeight: number, appIconSize: number,
    imageStackSize: number, appIconOffset: number) {
    this.imageSize = imageSize;
    this.wholeHeight = wholeHeight;
    this.appIconSize = appIconSize;
    this.imageStackSize = imageStackSize;
    this.appIconOffset = appIconOffset;
  }
}