/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { SendParams } from '../../worker/SendParams';
import type common from '@ohos.app.ability.common';
import WorkerConst from '../../worker/WorkerConst';
import type { FileInfo } from '../../fileoperate/FileInfo';
import CopyCutConst from './CopyCutConst';
import type { DiskInfo } from '../../externel/DiskInfo';
import type { FavoriteModel } from '../../model/FavoriteModel';

export enum ProgressBarStatus {
  NOT_JUDGED = -1, // 未判断
  NEEDS_TO_BE_PULLED_UP, // 需要拉起
  NOT_PULL_UP // 不拉起
}

/**
 * 复制移动主线程向子线程发送消息
 */
export class CopyCutSendParam extends SendParams {
  /**
   * 要操作的文件 FileInfo 数组
   */
  public toOperateFiles: FileInfo[];

  /**
   * 目标文件夹uri
   */
  public destFolderUri: string;

  /**
   * 消息指令
   */
  public msgCode: CopyCutConst.SendMsgCode;

  /**
   * 冲突处理结果
   */
  public conflictHandleResult: CopyCutConst.ChooseType = CopyCutConst.ChooseType.DEFAULT;

  /**
   * 是否应用到全部
   */
  public isApplyToAll: boolean;

  /**
   * 存储设备uuid
   */
  public uuid: string;

  /**
   * 本地根目录uri
   */
  public localRootUri: string;

  /**
   * 源文件夹uri（phone独有）
   */
  public srcFolderUri?: string;

  /**
   * 目标文件夹名称（phone独有）
   */
  public destFolderName: string = '';

  /**
   * 所操作文件是否来自最近（pc独有）
   */
  public isFromRecent: boolean = false;

  /**
   * 文件是否为本地文件（pc独有）
   */
  public isLocalAppFile: boolean = false;


  /**
   * usb列表
   */
  public diskInfoList: DiskInfo[] = [];

  /**
   * 即将删除的文件对应的收藏列表
   */
  public favoriteList: FavoriteModel[] = [];

  /**
   * 是否是外部：跨设备、跨盘
   */
  public isExternalOperate: boolean = false;

  /**
   * 是否是起进度条
   */
  public progressBarShowStatus: ProgressBarStatus = ProgressBarStatus.NOT_JUDGED;

  constructor(context: common.Context, operateType: WorkerConst.OperateType = WorkerConst.OperateType.CANCEL,
    workerName: string, toOperateFiles: FileInfo[], destFolderUri: string, msgCode: CopyCutConst.SendMsgCode,
    conflictHandleResult: CopyCutConst.ChooseType | undefined, isApplyToAll: boolean, uuid: string,
    localRootUri: string) {
    super(context, operateType, workerName);
    this.toOperateFiles = toOperateFiles;
    this.destFolderUri = destFolderUri;
    this.msgCode = msgCode;
    this.conflictHandleResult = conflictHandleResult ?? CopyCutConst.ChooseType.DEFAULT;
    this.isApplyToAll = isApplyToAll;
    this.uuid = uuid;
    this.localRootUri = localRootUri;
  }
}