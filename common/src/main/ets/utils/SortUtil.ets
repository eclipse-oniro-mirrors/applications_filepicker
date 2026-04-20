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

import { SortOrder } from '../const/Constant';
import { VirtualUri } from '../const/FolderRecord';
import type { FileInfo } from '../fileoperate/FileInfo';
import FileMimeTypeUtil from './FileMimeTypeUtil';
import { LanguageUtil } from './LanguageUtil';

/**
 * 时间工具类
 */
export class SortUtil {
   private static collator : Intl.Collator | undefined;
  // 文件名排序规则
  private static readonly FILE_NAME_SORT_OPTIONS: Intl.CollatorOptions = {
    numeric: true, // 使用数字排序，这样数字会被正确地比较
  };

   /**
    * 筛选类型和说明文字配置
    */
   private static sortNameMap = new Map([
     [SortOrder.NAME, $r('app.string.sort_by_name')],
     [SortOrder.TIME, $r('app.string.sort_by_time')],
     [SortOrder.SIZE, $r('app.string.sort_by_size')],
     [SortOrder.TYPE, $r('app.string.sort_by_type')],
   ])

   public static getCollator() : Intl.Collator {
     if (!SortUtil.collator) {
       const language = LanguageUtil.getSystemLanguage();
       SortUtil.collator = Intl.Collator(language, SortUtil.FILE_NAME_SORT_OPTIONS);
     }
     return SortUtil.collator;
   }

  public static updateCollator(): void {
    const language = LanguageUtil.getSystemLanguage();
    SortUtil.collator = Intl.Collator(language);
  }

  public static sortDataBySize(dataList: FileInfo[], isDesc: boolean = false): FileInfo[] {
    const fileList: FileInfo[] = dataList.filter((item: FileInfo) =>!item.isFolder);
    const folderList: FileInfo[] = dataList.filter((item: FileInfo) => item.isFolder);

    fileList.sort((a: FileInfo, b: FileInfo) => {
      return SortUtil.compareFileBySize(a, b, isDesc);
    })
    // 按照大小排序的时候文件夹按照名称排序
    folderList.sort((a: FileInfo, b: FileInfo) => {
      return SortUtil.compareStr(isDesc, a.fileName, b.fileName);
    })

    return isDesc ? fileList.concat(folderList) : folderList.concat(fileList);
  }

  public static compareFileBySize(fileA: FileInfo, fileB: FileInfo, isDesc: boolean): number {
    if (fileB.size !== fileA.size) {
      return isDesc ? fileB.size - fileA.size : fileA.size - fileB.size;
    } else {
      return SortUtil.compareStr(isDesc, fileA.fileName, fileB.fileName);
    }
  }

  public static sortDataByTime(dataList: FileInfo[], isDesc: boolean = false,
    isRecent: boolean = false, isRecentDeletePage: boolean = false): FileInfo[] {
    // 规避@State修饰的数组变量执行sort方法不生效问题
    const fileList = dataList.filter((item: FileInfo) => item);

    return fileList.sort((a: FileInfo, b: FileInfo) => {
      return SortUtil.compareFileByTime(a, b, isDesc, isRecent, isRecentDeletePage);
    });
  }

  public static compareFileByTime(fileA: FileInfo, fileB: FileInfo, isDesc: boolean, isRecent: boolean = false,
    isRecentDeletePage: boolean = false): number {
    let fileTypeA = fileA.isFolder ? 0 : 1;
    let fileTypeB = fileB.isFolder ? 0 : 1;
    if (fileTypeA !== fileTypeB) {
      return isDesc ? fileTypeB - fileTypeA : fileTypeA - fileTypeB;
    }
    let aTime = isRecent ? fileA.recentTime : (isRecentDeletePage ? fileA.deleteTime : fileA.mtime);
    let bTime = isRecent ? fileB.recentTime : (isRecentDeletePage ? fileB.deleteTime : fileB.mtime);
    if (bTime !== aTime) {
      return isDesc ? bTime - aTime : aTime - bTime;
    }
    return SortUtil.compareStr(isDesc, fileA.fileName, fileB.fileName);
  }

  public static sortDataByType(dataList: FileInfo[], isDesc: boolean = false, isRecent: boolean = false): FileInfo[] {
    const fileList = dataList.filter((item: FileInfo) =>!item.isFolder);
    const folderList = dataList.filter((item: FileInfo) => item.isFolder);
    // 按照类型排序的时候文件夹按照名称排序
    folderList.sort((a: FileInfo, b: FileInfo) => {
      return SortUtil.compareStr(isDesc, a.fileName, b.fileName);
    });
    let newDataList = folderList;
    // 将文件列表按照指定后缀顺序进行排序
    fileList.sort((a: FileInfo, b: FileInfo) => {
      return SortUtil.compareFileByType(a, b, isDesc);
    })
    // 合并文件夹列表和文件列表
    newDataList = newDataList.concat(fileList);
    return newDataList;
  }

  public static compareFileByType(fileA: FileInfo, fileB: FileInfo, isDesc: boolean) : number {
    const aFileTypeOrder = FileMimeTypeUtil.getFileTypeOrder(fileA.fileName);
    const bFileTypeOrder = FileMimeTypeUtil.getFileTypeOrder(fileB.fileName);
    const aSuffixName = FileMimeTypeUtil.getFileSuffix(fileA.fileName);
    const bSuffixName = FileMimeTypeUtil.getFileSuffix(fileB.fileName);
    if (aFileTypeOrder !== bFileTypeOrder) {
      return isDesc ? bFileTypeOrder - aFileTypeOrder : aFileTypeOrder - bFileTypeOrder;
    } else if (aSuffixName !== bSuffixName) {
      return SortUtil.compareStr(isDesc, aSuffixName, bSuffixName);
    } else {
      return SortUtil.compareStr(isDesc, fileA.fileName, fileB.fileName);
    }
  }

  public static sortDataByName(dataList: FileInfo[], isDesc: boolean = false): FileInfo[] {
    // 规避@State修饰的数组变量执行sort方法不生效问题
    const fileList = dataList.filter((item: FileInfo) => item);
    return fileList.sort((a: FileInfo, b: FileInfo) => {
      let fileTypeA = a.isFolder ? 0 : 1;
      let fileTypeB = b.isFolder ? 0 : 1;
      if (fileTypeA !== fileTypeB) {
        return isDesc ? fileTypeB - fileTypeA : fileTypeA - fileTypeB;
      }
      return SortUtil.compareStr(isDesc, a.fileName, b.fileName);
    });
  }

  // 排序多个融合相册，如果有的话
  public static sortFusionAlbums(dataList: FileInfo[]): [FileInfo[], FileInfo[]] {
    let fusionAlbums: FileInfo[] = [];
    // 初始化指针
    let pointer = 0;

    // 遍历数组
    for (let i = 0; i < dataList.length; i++) {
      if (dataList[i].isFusionAlbum === true) {
        // 将符合条件的元素移动到指针位置
        let temp = [dataList[i], dataList[pointer]];
        dataList[pointer] = temp[0];
        dataList[i] = temp[1];
        pointer++;
      }
    }

    // 拆分点
    const splitIndex = pointer;

    // 拆分后的两部分
    fusionAlbums = dataList.slice(0, splitIndex);
    const newDataList = dataList.slice(splitIndex);
    return [fusionAlbums, newDataList];
  }

  /**
   * @description 实现文件排序
   * @param dataList: 待排序的文件列表
   * @param sortOrder: 排序字段
   * @param isDesc: 是否降序
   */
  public static sortDataByOrder(dataList: FileInfo[], sortOrder: string, isDesc: boolean = false,
    isRecent: boolean = false, isRecentDeletePage: boolean = false): FileInfo[] {
    if (!dataList || dataList.length === 0) {
      return dataList;
    }
    const findIndex = dataList.findIndex(item => {
      return false;
    });
    let virtualFile: FileInfo | undefined = undefined;
    if (findIndex > -1) {
      virtualFile = dataList[findIndex];
      const newDataList = [...dataList.slice(0, findIndex), ...dataList.slice(findIndex + 1)];
      dataList = newDataList;
    }
    let sortFusionAlbumsRes: [FileInfo[], FileInfo[]] = SortUtil.sortFusionAlbums(dataList);
    let fusionAlbums: FileInfo[] = sortFusionAlbumsRes[0];
    dataList = sortFusionAlbumsRes[1]
    if (sortOrder === SortOrder.SIZE) {
      dataList = SortUtil.sortDataBySize(dataList, isDesc);
    } else if (sortOrder === SortOrder.TIME) {
      dataList = SortUtil.sortDataByTime(dataList, isDesc, isRecent, isRecentDeletePage);
    } else if (sortOrder === SortOrder.TYPE) {
      dataList = SortUtil.sortDataByType(dataList, isDesc, isRecent);
    } else if (sortOrder === SortOrder.NAME) {
      dataList = SortUtil.sortDataByName(dataList, isDesc);
    }
    if (fusionAlbums && fusionAlbums.length > 0) {
      dataList = fusionAlbums.concat(dataList);
    }
    if (virtualFile) {
      dataList.unshift(virtualFile);
    }
    return dataList;
  }

  public static compareStr(isDesc: boolean, str1: string, str2: string): number {
    return isDesc ? SortUtil.getCollator().compare(str2, str1) : SortUtil.getCollator().compare(str1, str2);
  }
}