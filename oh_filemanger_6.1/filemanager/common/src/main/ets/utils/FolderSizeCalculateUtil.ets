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

import { Constant } from '../const/Constant';
import { FileUtil } from '../fileoperate/FileUtil';
import { PageUtil } from './PageUtil';

/**
 * 计算文件夹大小
 */
export class FolderSizeCalculateUtil {
  /**
   * 计算文件夹大小
   *
   * @param fileUri 要计算的文件夹的uri
   * @param fromPage 当前页面，如果是聚合视图页面需要特殊处理
   * @returns Promise<number>
   */
  public static async calculateFolderSize(fileUri: string, fromPage: string): Promise<number> {
    if (FileUtil.isBundleNameInDownloadDir(fileUri)) {
      const appDownloadFolderUri = FileUtil.getDownloadPathByBundleName(fileUri);
      const appDownloadFolderSize = await FileUtil.getFolderSizeByFs(appDownloadFolderUri);
      return appDownloadFolderSize;
    }

    let currentFileUri = fileUri;
    const folderSize = await FileUtil.getFolderSizeByFs(currentFileUri);
    return folderSize;
  }

  /**
   * 计算本地已使用空间大小，总空间减去剩余空间
   *
   * @returns Promise<number>
   */
  public static async calculateLocalUsedSize(): Promise<number> {
    const totalSizeRes = PageUtil.getLocalTotalSpace();
    const freeSizeRes = PageUtil.getLocalFreeSpace();
    const resArr = await Promise.all([totalSizeRes, freeSizeRes]);
    const totalSize = resArr[0];
    const freeSize = resArr[1];
    const usedSize = totalSize - freeSize;
    return usedSize;
  }
}
