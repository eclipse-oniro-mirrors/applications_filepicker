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

import { HiLog } from '../dfx/HiLog';
import { DiskInfo } from '../externel/DiskInfo';
import { FavoriteDbManager } from '../favorite/FavoriteDbManager';
import { FileInfo } from '../fileoperate/FileInfo';
import { TaskManager } from '../taskpool/manager/TaskManager';
import { StringUtil } from './StringUtil';
import { QueryTrashFileSumTask } from '../taskpool/task/FileQueryTask';
import lazy TrashNapi from 'libTrash.so';
const TAG = 'TrashFileUtil';

/**
 * 回收站相关工具和方法
 */
export class TrashFileUtil {
  public static readonly TRASH_FILE_COUNT: string = 'trashFileCount';

  /**
   * 获取回收站的总项数
   */
  public static getTrashFileCount(): void {
    TrashFileUtil.getTrashFileListByTask();
  }

  /**
   * 增加回收站文件的总项数
   * @param addCount 新增的个数
   */
  public static addTrashFileCount(addCount: number): void {
    const oldCount = AppStorage.get<number>(TrashFileUtil.TRASH_FILE_COUNT);
    if (oldCount !== undefined) {
      AppStorage.set<number>(TrashFileUtil.TRASH_FILE_COUNT, oldCount + addCount);
    }
  }

  /**
   * 减少回收站文件的总项数
   * @param reduceCount 减少的个数
   */
  public static reduceTrashFileCount(reduceCount: number): void {
    const oldCount = AppStorage.get<number>(TrashFileUtil.TRASH_FILE_COUNT);
    if (oldCount === undefined) {
      HiLog.error(TAG, 'reduceTrashFileCount getAppStorage is undefined');
      return;
    }
    let newCount = oldCount - reduceCount;
    newCount = newCount >= 0 ? newCount : 0;
    AppStorage.set<number>(TrashFileUtil.TRASH_FILE_COUNT, newCount);
  }

  /**
   * 使用taskpool来获取回收站内所有的文件
   * @returns
   */
  public static async getTrashFileListByTask(): Promise<number> {
    return new Promise((resolve, reject) => {
      let task = new QueryTrashFileSumTask(async (trashFileSum: number) => {
        AppStorage.setOrCreate<number>(TrashFileUtil.TRASH_FILE_COUNT, trashFileSum);
        resolve(trashFileSum);
      });
      TaskManager.getInstance().execute<number>(task);
    });
  }

  public static translateToFileData(trashFileList: FileInfo[],
    storageDeviceList: DiskInfo[]): FileInfo[] {
    let newFileList: FileInfo[] = [];
    let folderList: FileInfo[] = [];

    trashFileList.forEach((item: FileInfo) => {
      const storageDevice = storageDeviceList.find((deviceItem: DiskInfo) => {
        if (deviceItem.relativePath === undefined) {
          HiLog.error(TAG, 'translateToFileData deviceItem relativePath is undefined');
          return;
        }
        item.srcPath.startsWith(deviceItem.relativePath);
      });
      if (storageDevice !== undefined) {
        let path: string = storageDevice.relativePath as string;
        item.relativePath = item.srcPath.replace(path, '');
        item.srcPath = item.srcPath;
        item.parentPathForDetail = item.relativePath;
      }
      newFileList.push(item);
      if (item.isFolder) {
        folderList.push(item);
      }
    });
    FavoriteDbManager.getInstance().clearDirtyDataByTrashList(folderList);
    return newFileList;
  }

  /**
   * 还原回收站内的文件
   * @param trashFileUri 待还原文件的uri
   */
  public static recoverTrashFile(trashFileUri: string): void {
    if (StringUtil.isEmpty(trashFileUri)) {
      HiLog.warn(TAG, 'trashFileUri is empty')
      return;
    }
    TrashNapi.recoverFile(trashFileUri);
  }
}