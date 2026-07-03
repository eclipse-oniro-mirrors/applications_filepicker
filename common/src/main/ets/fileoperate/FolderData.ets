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

import fileExtensionInfo from '@ohos.file.fileExtensionInfo';
import { ArrayUtil } from '../utils/ArrayUtil';

/**
 * 路径选择器场景使用的文件夹数据模型
 */
export class FolderData {
  /**
   * 文件夹名
   */
  public fileName: string = '';
  /**
   * 文件夹名称资源，没有则为undefined
   */
  public fileNameResource?: Resource;
  /**
   * 文件夹uri
   */
  public uri: string = '';
  /**
   * 文件夹的相对路径
   */
  public relativePath: string = '';
  /**
   * 更新时间
   */
  public mtime: number = 0;
  /**
   * 子文件夹列表
   */
  public subFolderList: FolderData[] = [];
  /**
   * 当前文件夹所在层级
   */
  public level: number = 0;
  /**
   * 是否正在加载子目录
   */
  public isLoading: boolean = false;
  /**
   * 是否已展开显示了子目录
   */
  public isExpend: boolean = false;
  /**
   * 是否为根目录，如内部存储、U盘等
   */
  public isRootFolder: boolean = false;
  /**
   * 设备类型，只有根目录才会使用到
   */
  public deviceType: number = fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK;
  /**
   * 文件夹的父目录uri
   */
  public parentUri: string = '';

  public ipOrHostName: string = '';

  constructor(folder?: FolderData) {
    this.fileName = folder?.fileName || '';
    this.uri = folder?.uri || '';
    this.relativePath = folder?.relativePath || '';
    this.mtime = folder?.mtime || 0;
    this.subFolderList = folder?.subFolderList || [];
    this.level = folder?.level || 0;
    this.isLoading = folder?.isLoading || false;
    this.isExpend = folder?.isExpend || false;
    this.isRootFolder = this.isRootFolder || false;
    this.deviceType = folder?.deviceType || fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK;
    this.parentUri = folder?.parentUri || '';
    this.ipOrHostName = folder?.ipOrHostName || '';
  }

  /**
   * 判断是否为内部存储根目录
   */
  isLocalRootFolder(): boolean {
    return this.isRootFolder && this.deviceType === fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK;
  }

  /**
   * 判断是否为空文件件夹
   */
  isEmptyFolder(): boolean {
    return ArrayUtil.isEmpty(this.subFolderList);
  }
}