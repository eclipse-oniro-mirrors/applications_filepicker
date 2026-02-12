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
import type { FileInfo } from '../../fileoperate/FileInfo';
import type { ResultCode } from '../../worker/ResultCode';
import type { FavoriteModel } from '../../model/FavoriteModel';

/**
 * 复制移动主线程向子线程发送消息
 */
export class DeleteRestoreResultParam extends ResultParams {
  /**
   * 当前正在操作的文件名
   */
  public operatingFileName: string;

  /**
   * 粘贴进度比例
   */
  public pasteProgressRate: number;

  /**
   * 异常结果码（异常场景使用）
   */
  public exceptionCode?: ResultCode.Exception;

  /**
   * 错误结果码（错误场景使用）
   */
  public errorCode?: ResultCode.Error;

  /**
   * 异常文件（冲突场景使用）
   */
  public exceptionFile?: FileInfo;
  /**
   * 文件数量（异常场景使用）
   */
  public fileNum: number = 0;

  /**
   * 完成文件数量
   */
  public completeCount: number = 0;

  /**
   * 失败文件数量：手机端失败结束展示
   */
  public failCount: number = 0;

  /**
   * 失败文件名称：手机端失败展示
   */
  public failFileName: string = '';

  /**
   * 消息中成功的文件uri，手机用于移除当前页显示的item
   */
  public successUris: string[];

  /**
   * 更新的收藏数据
   */
  public updateFavoriteList: FavoriteModel[] = [];

  /**
   * 需要删除的收藏数据ID
   */
  public deleteFavoriteIdList: Array<number> = [];

  /**
   * 特殊场景处理：还原大文件夹速度慢，不能取消，将uri记录下来，在最近删除过滤掉，避免crash
   */
  public resolveUri: string = '';

  /**
   * 最近删除变化数量
   */
  public trashChangeCount: number = 0;

  /**
   * 是否还原至双升单备份目录：我的手机/升级备份/RecycleBin
   */
  public isToBackupPath: boolean = false;

  constructor(workerName: string, workerStatus: WorkerConst.WorkerStatus, resultType: number,
              operateType: WorkerConst.OperateType, operatingFileName: string,
              pasteProgressRate: number, completeCount: number, failCount: number,
              failFileName: string, successUris: string[]) {
    super(workerName, operateType, workerStatus, resultType);
    this.operatingFileName = operatingFileName;
    this.pasteProgressRate = pasteProgressRate;
    this.completeCount = completeCount;
    this.failCount = failCount;
    this.failFileName = failFileName;
    this.successUris = successUris;
  }
}