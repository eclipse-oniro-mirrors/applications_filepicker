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

import {
  ArrayUtil,
  Constant,
  HiLog,
  LanguageUtil,
  ObjectUtil,
  StringUtil,
  FileUtil,
  UsageHabitsPreferenceConst,
  UsageHabits,
  UsageHabitsPreferenceUtil,
  SortOrder,
  FilesQueryUtil,
  SortUtil,
  UiUtil
} from '@ohos/common';
import type { DiskInfo } from '@ohos/common';
import { FolderData } from '@ohos/common/src/main/ets/fileoperate/FolderData';

const TAG = 'PathPickerUtil';

/**
 * 路径选择器关于文件夹数据处理相关方法的工具类
 */
export default class PathPickerUtil {
  /**
   * 将文件夹按照时间进行排序
   * @param folderDataList 文件夹列表
   * @param isDesc 是否为倒序
   * @returns Array<FolderData>
   */
  public static sortDataByTime(folderDataList: FolderData[], isDesc: boolean = true): FolderData[] {
    const language: string = LanguageUtil.getSystemLanguage();
    return folderDataList.sort((a: FolderData, b: FolderData) => {
      if (b.mtime !== a.mtime) {
        return isDesc ? b.mtime - a.mtime : a.mtime - b.mtime;
      } else {
        return isDesc ? b.fileName.localeCompare(a.fileName, language) : a.fileName.localeCompare(b.fileName, language);
      }
    });
  }

  /**
   * 将DiskInfo对象转化后FolderData对象
   * @param diskInfo 存储设备对象
   * @returns 文件夹对象
   */
  public static convertDiskInfoToFolderData(diskInfo: DiskInfo): FolderData {
    let rootFolderData = new FolderData();
    if (ObjectUtil.isNullOrUndefined(diskInfo)) {
      return rootFolderData;
    }
    rootFolderData.uri = diskInfo.uri;
    rootFolderData.relativePath = diskInfo.relativePath;
    rootFolderData.fileName = diskInfo.description;
    rootFolderData.isRootFolder = true;
    rootFolderData.deviceType = diskInfo.deviceType;
    rootFolderData.level = Constant.FOLDER_LEVEL.MIN_LEVEL;
    rootFolderData.isExpend = false;
    return rootFolderData;
  }

  /**
   * 将树状结构的文件夹变成列表结构的文件夹
   * @param folderData 树状结构的文件夹
   * @returns 列表结构的文件夹
   */
  public static getAllSubFolderList(folderDataList: FolderData[], parentFolderInfo: FolderData): FolderData[] {
    let newFolderDataList: FolderData[] = [];
    // pathpicker排序要与文管应用内一致
    folderDataList = PathPickerUtil.sortFolderListByUsageHabit(folderDataList, parentFolderInfo);
    for (let folderData of folderDataList) {
      // 序列化后对方里的方法丢失需要重新生成FileData对象
      const newFolderData = new FolderData(folderData);
      newFolderDataList.push(newFolderData);
      if (ArrayUtil.isEmpty(folderData.subFolderList)) {
        continue;
      }
      const newSubFolderList = PathPickerUtil.getAllSubFolderList(folderData.subFolderList, folderData);
      newFolderDataList = newFolderDataList.concat(newSubFolderList);
    }
    return newFolderDataList;
  }

  /**
   * 删除uri里最后的斜杠
   * @param folderUri 文件夹URI
   * @returns string
   */
  public static removeLastSeparator(folderUri: string): string {
    if (StringUtil.isEmpty(folderUri)) {
      return '';
    }
    if (folderUri[folderUri.length - 1] === '/') {
      return folderUri.substring(0, folderUri.length - 1);
    }
    return folderUri;
  }

  /**
   * 根据目标目录uri找到需要选中的文件夹，
   * 主要用于处理目标目录不存在的情况下选中其父目录
   * @param rootFolderData 文件夹所在根目录
   * @param targetFolderUri 目标目录URI
   * @returns FolderData
   */
  public static getTargetFolderData(rootFolderData: FolderData, targetFolderUri: string): FolderData {
    let targetFolderData = rootFolderData;
    try {
      const rootPath = FileUtil.getPathFromUri(rootFolderData.uri);
      const targetPath = FileUtil.getPathFromUri(targetFolderUri);
      const folderNameList =
        targetPath.replace(rootPath, '').split('/').filter((item: string) => !StringUtil.isEmpty(item));

      let subFolderList = rootFolderData.subFolderList;
      let index = 0;
      while (index < folderNameList.length) {
        const tempFolder = subFolderList.find((item: FolderData) => item.fileName === folderNameList[index]);
        if (!tempFolder) {
          break;
        }
        index++;
        subFolderList = tempFolder.subFolderList;
        targetFolderData = tempFolder;
      }
    } catch (error) {
      HiLog.error(TAG, 'getTargetFolderData fail, error: ' + error);
    }
    HiLog.infoPrivate(TAG, 'targetFolderData: ', targetFolderData.uri);
    return targetFolderData;
  }

  /**
   * 检查两个目录是否为父子关系或相等
   * @param parentFolderUri 父目录URI
   * @param subFolderUri 子目录URI
   * @returns boolean
   */
  public static checkParentOrSelf(parentFolderUri: string, subFolderUri: string): boolean {
    if (StringUtil.isEmpty(parentFolderUri) || StringUtil.isEmpty(subFolderUri)) {
      return false;
    }
    const separator = '/';
    if (!parentFolderUri.endsWith(separator)) {
      parentFolderUri += separator;
    }
    if (!subFolderUri.endsWith(separator)) {
      subFolderUri += separator;
    }
    // 给uri添加分割符避免出现文件夹名前半部分一样导致的问题
    return subFolderUri.startsWith(parentFolderUri);
  }

  /* *
 * 根据uri开头匹配用户在应用中对应页面的排序喜好
 * params uri 需要获取name的uri
 * return UsageHabitsPreferenceConst中的页面名称
 * */
  private static getUsageHabitPageNameByURI(uri: string): string {
    return UsageHabitsPreferenceConst.MY_PHONE;
  }

  /**
   * 查询子文件夹之后，对子文件夹排序
   * */
  private static sortFolderListByUsageHabit(folderList: FolderData[], parentFolderInfo: FolderData): FolderData[] {
    if (folderList.length === 0) {
      return folderList;
    }
    // 我的手机根目录需要进行特殊文件名转换
    if (parentFolderInfo.uri === Constant.MY_PHONE_URI) {
      HiLog.info(TAG, 'should translateFileNameByUri')
      folderList.forEach(folder => {
        folder.fileName = UiUtil.translateFileNameByUri(folder.uri, folder.fileName, true);
      })
    }
    const isFileSelectPicker: boolean = false;
    const usageHabits: UsageHabits = UsageHabitsPreferenceUtil.getUsageHabitsByPageName(
      PathPickerUtil.getUsageHabitPageNameByURI(folderList[0].uri), isFileSelectPicker);
    const orderType: string = usageHabits.orderType;
    const isDesc: boolean = usageHabits.isDesc;
    folderList.sort((folderA: FolderData, folderB: FolderData): number => {
      // 文件夹的排序规格：除了按时间排序，其他的都按照名称排序，与sortutil中一致
      if (orderType === SortOrder.TIME && folderA.mtime !== folderB.mtime) {
        return isDesc ? folderB.mtime - folderA.mtime : folderA.mtime - folderB.mtime;
      }
      return SortUtil.compareStr(isDesc, folderA.fileName, folderB.fileName);
    })
    return folderList;
  }
}