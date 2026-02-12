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

import type WorkerConst from '../../worker/WorkerConst';
import { ResultParams } from '../../worker/ResultParams';
import { ResultCode } from '../../worker/ResultCode';
import type { PasteResult } from './PasteResult';
import type { FavoriteModel } from '../../model/FavoriteModel';

/**
 * 复制移动主线程向子线程发送消息
 */
export class CopyCutResultParam extends ResultParams {
  /**
   * 当前正在操作的文件名
   */
  public operatingFileName: string;
  /**
   * 当前操作文件uri
   */
  public operatingFileUri: string = '';
  /**
   * 当前正在操作的文件是否是文件夹
   */
  public operatingFileIsFolder: boolean = false;
  /**
   * 粘贴进度比例
   */
  public pasteProgressRate: number;
  /**
   * 文件数量（异常场景使用）
   */
  public fileNum: number = 0;
  /**
   * 是否是外部：跨设备、跨盘
   */
  public isExternalOperate: boolean = false;
  /**
   * 是否展示应用到全部
   */
  public isShowApplyAll: boolean = false;
  /**
   * 异常结果码（异常场景使用）
   */
  public exceptionCode: ResultCode.Exception = ResultCode.Exception.EXIST_DUPLICATE_FILE;
  /**
   * 错误结果码（错误场景使用）
   */
  public errorCode: ResultCode.Error = ResultCode.Error.SRC_FILE_NOT_EXIST;
  /**
   * 目标文件夹名称(phone专用)
   */
  public destFolderName: string = '';
  /**
   * 文件总大小(phone专用)
   */
  public totalSize: number = 0;
  /**
   * 已完成大小(phone专用)
   */
  public completeSize: number = 0;
  /**
   * 文件总数量(phone专用)
   */
  public totalCount: number = 0;
  /**
   * 已完成数量(phone专用)
   */
  public completeCount: number = 0;
  /**
   * 成功数量(phone专用)
   */
  public successCount: number = 0;
  /**
   * 失败数量
   */
  public failCount: number = 0;
  /**
   * 通知栏跳转的uri(phone专用)
   */
  public notifyUri: string = '';
  /**
   * 目标文件夹uri
   */
  public destFolderUri: string = '';
  /**
   * 操作结果，存储源文件uri与操作后的新uri（PC专用）
   */
  public pasteFilesRes: Array<PasteResult> = [];
  /**
   * 需要更新的收藏数据
   */
  public updateFavoriteList: FavoriteModel[] = [];
  /**
   * 需要移除的本地收藏路径
   */
  public deleteLocalFavoritePath: string[] = [];

  /**
   * 是否显示进度条
   */
  public isShowProgressBar: boolean = false;

  /**
   * 是否发生初始化异常
   */
  public isFileInitError: boolean = false;

  constructor(workerName: string, workerStatus: WorkerConst.WorkerStatus, resultType: number,
    operateType: WorkerConst.OperateType, operatingFileName: string, pasteProgressRate: number) {
    super(workerName, operateType, workerStatus, resultType);
    this.operatingFileName = operatingFileName;
    this.pasteProgressRate = pasteProgressRate;
  }
}