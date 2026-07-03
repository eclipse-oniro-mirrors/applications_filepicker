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
import lazy { UDC, UTD } from '../../../../indexLazyLoadTs';

import { Constant } from '../const/Constant';
import { OperateName, OperateResult } from '../const/HiSysEventConst';
import { PAGE_ROUTE_CONST } from '../const/PageRouteConst';
import { HiLog } from '../dfx/HiLog';
import { HiSysEventUtil } from '../dfx/HiSysEventUtil';
import { UdmfUtilets } from '../etsexport/utils/UdmfUtilets';
import { FileInfo } from '../fileoperate/FileInfo';
import { FileUtil } from '../fileoperate/FileUtil';
import { GlobalHolder } from '../global/GlobalHolder';
import { GlobalKey } from '../global/GlobalKey';
import { StartModeOptions } from '../model/StartModeOptions';
import { ArrayUtil } from '../utils/ArrayUtil';
import { StringUtil } from '../utils/StringUtil';
import { TimeUtil } from '../utils/TimeUtil';
import { UdmfUtils } from './UdmfUtil';

const TAG = 'DragManager';

export class DragManager {
  /**
   * 实例
   */
  private static instance: DragManager;
  /**
   * 拖拽进入动效定时器
   */
  public dragTimeoutId?: number;

  public selectItemTimeId?: number;
  /**
   * 拖拽开始时所在的文件夹uri
   */
  public dragStartFolderUri: string = '';

  /**
   * 拖拽开始时非正常路径如：聚合、来源包名
   */
  public dragStartBundleName: string = '';
  // 来源拖起还是聚合拖起，true为来源拖起
  public dragStartSource: boolean = false;
  // 发起拖拽页面
  public dragStartPage: string = '';

  public dragFileList: FileInfo[] = [];
  /**
   * 是否是内部拖拽
   */
  public isInternalDrag = false;
  public selectItemTag: string = '';
  public canFallIn: string[] = [
    UTD.UniformDataType.FILE,
    UTD.UniformDataType.VIDEO,
    UTD.UniformDataType.IMAGE,
    UTD.UniformDataType.AUDIO,
    UTD.UniformDataType.FOLDER,
    UTD.UniformDataType.OPENHARMONY_PIXEL_MAP];

  public toOperateFileUris?: string[];

  static getInstance() {
    if (!DragManager.instance) {
      DragManager.instance = new DragManager();
    }
    return DragManager.instance;
  }

  enterSelectItem(tag: string) {
    if (this.selectItemTimeId) {
      clearTimeout(this.selectItemTimeId);
      this.selectItemTimeId = undefined;
    }
    if (StringUtil.isEmpty(tag)) {
      return;
    }
    this.selectItemTag = tag;
  }

  leaveSelectItem(callback: Function) {
    this.selectItemTimeId = setTimeout(() => {
      callback();
      this.selectItemTag = '';
    }, 200)
  }

  /**
   * 拖动开始执行的方法
   * @param curFolderUri
   */
  onDragStart(event: DragEvent, list: FileInfo[], folderUri: string): number {
    if (!event) {
      return 0;
    }
    if (ArrayUtil.isEmpty(list)) {
      HiSysEventUtil.reportFileOperation(OperateName.DRAG, 'files', OperateResult.FAIL);
      return 0;
    }

    if (list.length > UdmfUtils.CROSS_DEVICE_DRAG_FILE_MAX_NUM) {
      this.dragFileList = list;
      this.dragStartFolderUri = folderUri;
      this.isInternalDrag = true;
      event.setData(new UDC.UnifiedData());
      return list.length;
    }
    let unifiedData: UDC.UnifiedData | undefined;
    let num = 0;
    for (let i = 0; i < list.length; i++) {
      num++;
      let unifiedRecord: UDC.UnifiedRecord = UdmfUtils.setUnifiedData(list[i]);
      if (!unifiedData) {
        unifiedData = new UDC.UnifiedData(unifiedRecord);
      } else {
        unifiedData.addRecord(unifiedRecord)
      }
    }
    if (unifiedData) {
      event.setData(unifiedData);
    }
    this.dragStartFolderUri = folderUri;
    this.isInternalDrag = true;
    HiSysEventUtil.reportFileOperation(OperateName.DRAG, 'files', OperateResult.SUCCESS);
    return num;
  }

  supportDrag(startModeOptions: StartModeOptions): boolean {
    return !startModeOptions.pickerFlag;
  }

  onDragEnd(event?: DragEvent) {
    this.dragStartFolderUri = '';
    this.dragStartBundleName = '';
    this.dragStartSource = false;
    this.isInternalDrag = false;
  }

  onDrop() {
    if (this.dragTimeoutId) {
      clearTimeout(this.dragTimeoutId);
      this.dragTimeoutId = undefined;
    }
  }

  /**
   * 进入动效
   * @param updateBackGround 设置背景回调
   * @param enterClick 点击回调
   */
  onDropEnterAnimation(updateBackGround: Function, enterClick: Function, laseNeedSelect: boolean = false) {
    updateBackGround(true);
    this.dragTimeoutId = setTimeout(async () => {
      let isSelect = false;
      for (let i = 0; i < 4; i++) {
        updateBackGround(isSelect);
        await TimeUtil.sleep(Constant.DRAG_ENTER_SHINE_DELAY_TIME);
        isSelect = !isSelect;
      }
      enterClick();
      if (!laseNeedSelect) {
        updateBackGround(false);
      }
    }, Constant.DRAG_ENTER_DELAY_TIME);
  }

  public async getFileInfoListFromUDMF(event: DragEvent): Promise<FileInfo[]> {
    let list: FileInfo[] = [];
    if (!event) {
      return list;
    }
    try {
      let dragData = await UdmfUtilets.getDataFromUdmf(event);
      if (!dragData) {
        return list;
      }
      let records = dragData.getRecords();
      if (ArrayUtil.isEmpty(records)) {
        return list;
      }
      const localRootUri = GlobalHolder.getInstance().getObject<string>(GlobalKey.LOCAL_ROOT_URI)
      for (let i = 0; i < records.length; i++) {
        let type = records[i].getType();
        let udmInfo = UdmfUtils.getRecordData(records[i], type);
        if (!FileUtil.isUriPath(udmInfo.fileUri)) {
          HiLog.warn(TAG, 'getFileInfoListFromUDMF: fileUri illegal');
          continue;
        }
        let fileInfo = new FileInfo();
        fileInfo.uri = udmInfo.fileUri;
        fileInfo.isFolder = (type === UTD.UniformDataType.FOLDER);
        if (this.isInternalDrag && (!fileInfo.uri.startsWith(localRootUri))) {
          fileInfo.isExternalStorageDeviceFile = true;
        }
        fileInfo.fileName = FileUtil.getFileNameFromUri(fileInfo.uri);
        list.push(fileInfo);
      }
    } catch (error) {
      HiLog.error(TAG, 'getFileInfoListFromUDMF error: ' + error.code + ' ' + error.message)
    }
    return list;
  }

  /**
   * 离开动效
   */
  onDropLeaveAnimation(updateBackGround: Function) {
    if (this.dragTimeoutId) {
      clearTimeout(this.dragTimeoutId);
      this.dragTimeoutId = undefined;
    }
    updateBackGround(false);
  }

  storageItemCanDrop(pageUri: string) {
    return pageUri !== PAGE_ROUTE_CONST.RECENT_DELETE;
  }

  // 获取拖拽角标，根据extraParams来判断拖拽文件属于内部还是外部
  getDragFlag(event: DragEvent, extraParams: string, dragInfo: string): void {
    if (dragInfo !== (JSON.parse(extraParams) as DragClass).extraInfo && this.isCanDrop(event)) {
      event.dragBehavior = DragBehavior.COPY;
      return;
    }
    event.dragBehavior = DragBehavior.MOVE;
  }

  // 获取拖拽的类型是否可以落入
  isCanDrop(event: DragEvent): boolean {
    const events: Record<string, number> = event.getSummary().summary;
    const reg = new RegExp(this.canFallIn.join('|'), 'g');
    return reg.test(JSON.stringify(events));
  }

  // 设置发起拖拽页面
  setDragStartPage(fromPage: string): void {
    this.dragStartPage = fromPage;
  }

  // 获取发起拖拽页面
  getDragStartPage(): string {
    return this.dragStartPage;
  }

  // 重置发起拖拽页面
  resetDragStartPage(): void {
    this.dragStartPage = '';
  }
}

// 拖拽的信息类
export interface DragClass {
  extraInfo: string;
}