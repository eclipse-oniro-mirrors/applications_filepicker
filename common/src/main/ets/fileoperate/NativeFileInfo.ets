/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { FileInfo } from './FileInfo';
import { Constant } from '../const/Constant';

export class NativeFileInfo {
  public fileName: string = '';
  public uri: string = ''; // 文件uri
  public relativePath: string = ''; // 文件的绝对路径
  public isFolder: boolean = false;
  public size: number = 0;
  public addedDate: number = 0; // 存stat的atime
  public mtime: number = 0; // 修改时间
  public ctime: number = 0; // ctime不是创建时间，是change time表示文件的状态信息最后一次被改变的时间
  public locationType: number = 0;

  public static getFileInfoFromNative(inFile: NativeFileInfo): FileInfo {
    let newFile = new FileInfo();
    newFile.fileName = inFile.fileName;
    newFile.uri = inFile.uri;
    newFile.ctime = inFile.ctime;
    newFile.mtime = inFile.mtime * Constant.TIME.ONE_SECOND;
    newFile.size = inFile.size;
    newFile.isFolder = inFile.isFolder;
    newFile.locationType = inFile.locationType;
    newFile.relativePath = inFile.relativePath;
    FileInfo.getThumbnailType(newFile);
    return newFile;
  }
}