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

import { FolderOperationType, PageFinishType } from '../const/Constant';
import { FileInfo } from '../fileoperate/FileInfo';
import { StartModeOptions } from './StartModeOptions';
import { FileDataSource } from '../etsexport/lazyLoadData/FileDataSource';
import { PhotoAlbumSubType, PhotoAlbumType } from '../media/AlbumType';
import { AddressData } from './address/AddressData';

export class AbilityOrRouterParams {
  // 查看器内文件索引
  public fileIndex: number = 0;
  // 来源page
  public pageFrom: string = '';
  // 页面结束类型
  public finishType: PageFinishType = PageFinishType.DEFAULT;
  // 标题栏标题
  public title: string | Resource = '';
  // 目标路径
  public path: string = '';
  // 根路径
  public rootUri: string = '';
  // uuid
  public uuid: string = '';
  // uri路径
  public uriPath: string = '';
  // 来源
  public from: string = '';
  // fileData
  public fileData: FileInfo = new FileInfo();
  public fileDataSource: FileDataSource = new FileDataSource();
  public isRecent: boolean = false;

  // 来源包名
  public bundleName: string = '';

  public startModeOptions: StartModeOptions | undefined = undefined;

  // 跳转到图库路径时，需要传入所在的相册名、type和sub type
  public albumName: string | undefined;
  public albumType: PhotoAlbumType = -1;
  public albumSubType: PhotoAlbumSubType | undefined;

  public folderOperateType: FolderOperationType = FolderOperationType.NONE // 打开文件夹操作
  public direList: AddressData[] = []; // 面包屑(包含根目录)
  // 是否为默认页面
  public isDefaultPage: boolean = false;
  // 在当前页面上预览图片视频（我的手机），详情内位置禁止跳转
  public isPreviewForbidJump: boolean = false;

  // 当前文件URI,用于最近跳来源跳到对应位置
  public currentFileUri: string = '';
}
