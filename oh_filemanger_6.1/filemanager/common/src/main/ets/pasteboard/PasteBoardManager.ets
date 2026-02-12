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

import TaskPool from '@ohos.taskpool';

import { CommonPreferenceUtil } from '../preference/CommonPreferenceUtil'
import { Constant } from '../const/Constant';
import { PAGE_ROUTE_CONST } from '../const/PageRouteConst';
import { HiLog } from '../dfx/HiLog';
import { FileInfo } from '../fileoperate/FileInfo';
import { PasteboardDataModel } from '../model/PasteboardDataModel';
import { ArrayUtil } from '../utils/ArrayUtil';
import { EventBus } from '../utils/EventBus';
import { ObjectUtil } from '../utils/ObjectUtil';
import { PasteBoardUtil } from './PasteBoardUtil';
import { StartModeOptions } from '../model/StartModeOptions';
import { pasteboard } from '@kit.BasicServicesKit';
import { VirtualUri } from '../const/FolderRecord';

/**
 * TAG
 */
const TAG = 'PasteBoardManager';

/**
 * 剪切板内文件uri读写方法封装
 */
export class PasteBoardManager {
  private static instance: PasteBoardManager = new PasteBoardManager();
  private isReadPasteBoardExecuting: boolean = false;
  private readPasteBoardTask?: TaskPool.Task = undefined;
  private setPasteBoardTask?: TaskPool.Task = undefined;
  /**
   * 在应用切到前台时读取剪切板的特定页面
   */
  private readonly NEED_READ_PASTEBOARD_PAGES: string[] = [
    PAGE_ROUTE_CONST.MAIN_ENTRY,
    PAGE_ROUTE_CONST.MY_PHONE,
    PAGE_ROUTE_CONST.PREVIEW_TIP,
    PAGE_ROUTE_CONST.FILE_PREVIEW
  ]
  private isReadPasteBoard: boolean = true;

  /**
   * 获取剪切板管理类实例
   */
  public static getInstance(): PasteBoardManager {
    return PasteBoardManager.instance
  }

  /**
   * 检查是否需要读取剪切板
   * @param isNeedReadPasteBoard
   */
  public checkNeedReadPasteBoard(): boolean {
    const pageStack = AppStorage.get<NavPathStack>('pageStack') || new NavPathStack()
    const allPathName = pageStack.getAllPathName();
    const topPage = allPathName.pop();
    HiLog.info(TAG, 'checkNeedReadPasteBoard, current topPage:' + topPage)
    // 根页面(MainEntry)和固定的页面才需要读取剪切板
    let isSpecialPages: boolean = false;
    for (const entry of this.NEED_READ_PASTEBOARD_PAGES) {
      if (topPage?.includes(entry)) {
        isSpecialPages = true;
      }
    }
    return topPage === undefined || isSpecialPages;
  }

  /**
   * 启动将文件列表写入剪切板的任务
   * @param fileList 文件列表
   */
  public async startSetPasteBoardTask(fileList: FileInfo[], startModeOptions: StartModeOptions): Promise<boolean> {
    let result = false;
    if (ArrayUtil.isEmpty(fileList)) {
      HiLog.warn(TAG, 'setPasteBoardTask execute fail, fileList is null');
      return result;
    }
    try {
      // 只传文件uri列表
      const fileUriList: string[] = fileList.map((fileInfo: FileInfo) => fileInfo.uri);
      // 是否需要跨设备，包含外部存储文件时候暂时只允许本地粘贴
      const isNeedCrossDevice: boolean =
        !fileList.some((fileInfo: FileInfo) =>
        fileInfo.isExternalStorageDeviceFile || fileInfo.uri.startsWith(VirtualUri.GALLERY_URI));
      this.setPasteBoardTask = new TaskPool.Task(setUriToPasteboard, fileUriList, isNeedCrossDevice);
      result = await TaskPool.execute(this.setPasteBoardTask) as boolean;
      if (result) {
        // 记录当前设备写入剪切板数据的时间戳，标记不需要处理
        const pasteboardData = await this.startReadPasteboardTask(false, startModeOptions);
        // 不再处理文管向剪切板写入的文件数据
        if (!ObjectUtil.isNullOrUndefined(pasteboardData)) {
          CommonPreferenceUtil.setLastResolvePasteboardTimestamp(pasteboardData.timestamp);
        }
      }
    } catch (error) {
      HiLog.error(TAG, 'setPasteBoardTask execute fail, error:' + JSON.stringify(error) + error);
    }
    this.setPasteBoardTask = undefined;
    return result;
  }

  /**
   * 检查剪切板上的数据
   */
  public async startReadPasteboardTask(isNeedCheckTimestamp: boolean = false,
    startModeOptions: StartModeOptions): Promise<PasteboardDataModel> {
    let pasteboardData: PasteboardDataModel = new PasteboardDataModel();
    if (!this.isReadPasteBoard) {
      this.isReadPasteBoard = true;
      HiLog.warn(TAG, `startReadPasteboardTask: ${this.isReadPasteBoard}`);
      return pasteboardData;
    }
    // 文件选择器场景不读取剪切板
    if (startModeOptions.pickerFlag) {
      HiLog.warn(TAG, `can't execute startReadPasteboardTask, current usage scenes is picker`);
      return pasteboardData;
    }
    const isNeedReadPasteBoard = this.checkNeedReadPasteBoard();
    if (!isNeedReadPasteBoard) {
      HiLog.warn(TAG, `can't execute startReadPasteboardTask, current page is not need read PasteBoard.`)
      return pasteboardData;
    }
    // 正在读取...
    if (this.isReadPasteBoardExecuting) {
      HiLog.warn(TAG, `can't execute startReadPasteboardTask, task is running.` + this.isReadPasteBoardExecuting);
      return pasteboardData;
    }
    HiLog.info(TAG, 'startReadPasteboardTask');
    try {
      this.isReadPasteBoardExecuting = true;
      const pasteData = await PasteBoardUtil.getPasteData();
      AppStorage.setOrCreate<pasteboard.PasteData | undefined>('globalPasteDate', pasteData);
      const temPasteboardData: PasteboardDataModel = await PasteBoardUtil.getUriFromPasteboard(pasteData);
      this.isReadPasteBoardExecuting = false;
      if (ObjectUtil.isNullOrUndefined(temPasteboardData)) {
        HiLog.info(TAG, 'readPasteBoardTask end, pasteboardData is null');
        return pasteboardData;
      }
      const isNeedReadPasteBoard = this.checkNeedReadPasteBoard();
      if (!isNeedReadPasteBoard) {
        HiLog.warn(TAG, `readPasteBoardTask end, current page is not need read PasteBoard.`);
        return pasteboardData;
      }
      pasteboardData = temPasteboardData;
      HiLog.infoPrivate(TAG, 'readPasteBoardTask success, pasteboardData:', JSON.stringify(pasteboardData));
      if (isNeedCheckTimestamp) {
        // 通过时间戳判断是否已处理过剪切板里的数据
        const lastResolvePasteboardTimestamp = await CommonPreferenceUtil.getLastResolvePasteboardTimestamp();
        HiLog.info(TAG,
          `getUriFromPasteboard lastResolvePasteboardTimestamp: ${lastResolvePasteboardTimestamp}`);
        // 判断是否已处理过剪切板上的uri数据
        if (lastResolvePasteboardTimestamp === pasteboardData.timestamp) {
          HiLog.info(TAG, 'pasteboard has resolved');
        } else {
          EventBus.emit(Constant.EVENTS.CLOSE_PATH_PICKER);
          EventBus.emit(Constant.EVENTS.PASTEBOARD_REMAINDER_DIALOG, pasteboardData);
          HiLog.info(TAG, 'show pasteboardReminderDialog');
        }
      }
    } catch (error) {
      this.isReadPasteBoardExecuting = false;
      HiLog.error(TAG, 'readPasteBoardTask execute fail, error:' + JSON.stringify(error) + error);
    }
    return pasteboardData;
  }

  /**
   * 是否读剪贴板
   * @param isRead
   * @returns
   */
  public setWhetherToReadPasteBoard(isRead: boolean): void {
    HiLog.info(TAG, `setWhetherToReadPasteBoard: ${isRead}`);
    this.isReadPasteBoard = isRead;
  }
}


/**
 * 写入文件的uri到剪切板里
 * @param fileUriList 文件uri列表
 * @param context 应用上下文
 * @returns 是否写入成功
 */
@Concurrent
async function setUriToPasteboard(fileUriList: Array<string>, isNeedCrossDevice: boolean): Promise<boolean> {
  const result = await PasteBoardUtil.setUriToPasteboard(fileUriList, '', isNeedCrossDevice);
  return result;
}

/**
 * 获取剪切板里文件uri数据
 * @param context 应用上下文
 * @returns 剪切板里的文件uri数组
 */
@Concurrent
async function getUriFromPasteboard(): Promise<PasteboardDataModel> {
  const pasteData = await PasteBoardUtil.getPasteData();
  return await PasteBoardUtil.getUriFromPasteboard(pasteData);
}