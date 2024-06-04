/*
 * Copyright (c) 2021-2023 Huawei Device Co., Ltd.
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

import { getFileIcon, randomId, formatSuffix } from '../../base/utils/Tools';
import { MILLISECOND } from '../../base/constants/Constant';
import fileAccess from '@ohos.file.fileAccess';
import { THUMBNAIL_SIZE } from '../../base/constants/UiConstant';
import { MimeType } from './MimeType';
import { BasicDataSource } from './BasicDataSource';
import AbilityCommonUtil from '../../base/utils/AbilityCommonUtil';
import { FileUtil } from '../../base/utils/FileUtil';
import { ArrayUtil } from '../../base/utils/ArrayUtil';

export class BreadData {
  title: string;
  url: string;
  fileIterator?: fileAccess.FileInfo;

  constructor(obj) {
    this.title = obj.title;
    this.url = obj.url;
    this.fileIterator = obj.fileIterator;
  }
}

export class FileDataSource extends BasicDataSource {
  private dataArray: FilesData[] = [];
  dataCount: number = 0;

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getDataArray(): FilesData[] {
    return this.dataArray;
  }

  public getFileList(): FilesData[] {
    return this.dataArray.filter(item =>!item.isFolder);
  }

  public setData(data: FilesData[]): void {
    this.dataArray = [...data];
    this.dataCount = this.dataArray.length;
    this.notifyDataReload();
  }

  public getData(index: number): FilesData {
    return this.dataArray[index];
  }

  public selectAll(isSelected): void {
    this.dataArray.forEach(item => {
      item.isChecked = isSelected;
    });
  }

  public getIndex(uri): number {
    return this.dataArray.findIndex(item => item.uri === uri);
  }

  public getSelectedFileList(): FilesData[] {
    return this.dataArray.filter(item => item.isChecked);
  }

  public replaceData(index, data: FilesData): void {
    this.dataArray.splice(index, 1, data);
    this.notifyDataChange(index);
  }

  public addData(index: number, data: FilesData): void {
    this.dataArray.splice(index, 0, data);
    this.dataCount = this.dataArray.length;
    this.notifyDataAdd(index);
  }

  public pushData(data: FilesData): void {
    this.dataArray.push(data);
    this.dataCount = this.dataArray.length;
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public deleteData(index: number): void {
    this.dataArray.splice(index, 1);
    this.dataCount = this.dataArray.length;
    this.notifyDataDelete(index);
  }
}

export class FilesData {
  id: string;
  uri: string;
  thumbUri: string;
  displayName: string;
  deviceId: string;
  flags: number;
  name: string;
  fileName: string;
  mode: string;
  size: number;
  mtime: number;
  suffix: string;
  mimeType: string;
  icon: any;
  gridIcon: any;
  localGridIcon: any;
  isChecked: boolean;
  path?: string;
  sub?: number;
  scale?: number;
  angle?: number;
  offsetX?: number | string;
  offsetY?: number | string;
  picWidth?: number | string;
  picHeight?: number | string;
  fileIterator?: fileAccess.FileInfo;
  isMedia: boolean = false;
  isImage: boolean = false;
  isVideo: boolean = false;
  isAudio: boolean = false;
  isFolder: boolean = false;
  duration: number;
  mimeTypeObj: MimeType;
  subFolderList: FilesData[];
  subFileList: FilesData[];
  layer: number;
  autoShow: boolean = false;
  currentDir?: string;

  constructor(obj) {
    this.isFolder = obj.isFolder || FileUtil.isFolder(obj.mode);
    this.id = obj.id || randomId();
    this.uri = obj.uri || '';
    this.deviceId = obj.deviceId || '';
    this.flags = obj.flags || 0;
    this.name = obj.name || '';
    this.fileName = obj.fileName || obj.displayName || '';
    this.suffix = formatSuffix(this.fileName);
    this.mode = obj.mode || '';
    this.size = obj.size || 0;
    this.mtime = obj.mtime * MILLISECOND.ONE_SECOND || 0;
    this.mimeType = obj.mimeType || '';
    this.isChecked = false;
    this.path = obj.path || obj.relativePath || '';
    this.sub = obj.sub || 0;
    this.scale = obj.scale || 1;
    this.angle = obj.angle || 0;
    this.offsetX = obj.offsetX || 0;
    this.offsetY = obj.offsetY || 0;
    this.picWidth = obj.picWidth || '100%';
    this.picHeight = obj.picHeight || '100%';
    this.fileIterator = obj.fileIterator;
    this.duration = obj.duration || 0;
    this.mimeTypeObj = getFileIcon(this.fileName, this.isFolder);
    this.icon = this.mimeTypeObj.getResID();
    this.gridIcon = this.mimeTypeObj.getGridResID();
    this.localGridIcon = this.mimeTypeObj.getLocalGridResID();
    if (this.mimeTypeObj.isMedia()) {
      this.thumbUri = this.uri;
    }
    if (this.isFolder) {
      this.sub = getSubFileNum(this.fileIterator);
    }
    this.currentDir = FileUtil.getCurrentDir(this.path, this.isFolder);
  }

  setFileName(fileName: string): void {
    this.fileName = fileName;
    this.mimeTypeObj = getFileIcon(this.fileName);
    this.icon = this.mimeTypeObj.getResID();
    this.gridIcon = this.mimeTypeObj.getGridResID();
    this.localGridIcon = this.mimeTypeObj.getLocalGridResID();
    if (this.mimeTypeObj.isMedia()) {
      this.thumbUri = `${this.uri}/thumbnail/${THUMBNAIL_SIZE.WIDTH}/${THUMBNAIL_SIZE.HEIGHT}`;
    }
  }

  pickFile(): void {
    AbilityCommonUtil.terminateFilePicker([this.uri], [this.fileName]);
  }

  setSubFolderList(subFolderList: FilesData[]) {
    this.subFolderList = subFolderList;
  }

  setSubList(subList: FilesData[]) {
    if (!ArrayUtil.isEmpty(subList)) {
      let folderList: FilesData[] =[];
      let fileList: FilesData[] = [];
      for (let i = 0; i < subList.length; i++) {
        let fileData: FilesData = subList[i];
        if (fileData.isFolder) {
          folderList.push(fileData);
        } else {
          fileList.push(fileData);
        }
      }
      this.subFolderList = folderList;
      this.subFileList = fileList;
    }
  }

  hasSubFolderList(): boolean {
    if (ArrayUtil.isEmpty(this.subFolderList)) {
      return false;
    }
    return this.subFolderList.length > 0;
  }

  getSubFolderList(): FilesData[] {
    return this.subFolderList;
  }

  setLayer(layer: number) {
    this.layer = layer;
  }

  getLayer(): number {
    if (this.layer) {
      return this.layer;
    }
    return 1;
  }
}

export function getSubFileNum(fileInfo: fileAccess.FileInfo): number {
  let subFileNum = 0;
  if (!fileInfo) {
    return subFileNum;
  }
  let fileIterator = fileInfo.listFile();
  if (!fileIterator) {
    return subFileNum;
  }
  let result = fileIterator.next();
  let isDone = result.done;
  while (!isDone) {
    subFileNum += 1;
    result = fileIterator.next();
    isDone = result.done;
  }
  return subFileNum;
}

export class selectedFileData {
  id?: string;
  uri: string;
  mimeType: string;
  thumbUri: string;
  title: string;
  fileName: string;
  mode: string;
  relativePath: string;
  size: number;
  albumUri: string;
  albumName: string;
  isFolder: boolean;
  displayName?: string;

  constructor(obj) {
    this.id = obj.id || -1;
    this.uri = obj.uri || '';
    this.mimeType = obj.mimetype || '';
    this.thumbUri = obj.thumbUri || '';
    this.title = obj.title || '';
    this.fileName = obj.fileName || obj.displayName || '';
    this.mode = obj.mode || '';
    this.isFolder = obj.isFolder;
    this.relativePath = obj.relativePath || '';
    this.size = obj.size || 0;
    this.albumUri = obj.albumUri || '';
    this.albumName = obj.albumName || '';
  }
}

export class FileData {
  id: string;
  fileName: string;
  thumbnail: string;
  editedTime: string;
  subItemSize: number;
  parentFolder: string;
  fileType: string;
  fileSize: number;
  isChecked: boolean;
  children: [];

  constructor(id: string, fileName: string, thumbnail: string, editedTime: string, subItemSize: number,
              parentFolder: string, fileType: string, fileSize: number, isChecked: boolean, children: []) {
    this.id = id;
    this.fileName = fileName;
    this.thumbnail = thumbnail;
    this.editedTime = editedTime;
    this.subItemSize = subItemSize;
    this.parentFolder = parentFolder;
    this.fileType = fileType;
    this.fileSize = fileSize;
    this.isChecked = isChecked;
    this.children = children;
  }
}

export class fileDetail {
  key: string | Resource;
  value: string | Resource;
  path?: string = '';
  params?: any;

  constructor(key: string, value: string, path: string, params: any) {
    this.key = key;
    this.value = value;
    this.path = path;
    this.params = params;
  }
}

export class bottomOptions {
  optionName: string;
  name: string;
  icon: Resource;
  disabled: boolean = false;
  display: boolean = true;

  constructor(optionName: string, name: string, icon: Resource, disabled: boolean, display: boolean) {
    this.optionName = optionName;
    this.name = name;
    this.icon = icon;
    this.disabled = disabled;
    this.display = display;
  }
}