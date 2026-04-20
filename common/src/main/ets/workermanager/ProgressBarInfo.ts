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
import type WorkerConst from '../worker/WorkerConst';

/**
 * 进度条信息
 */
export class ProgressBarInfo {
  /**
   * 目标文件夹uri
   */
  public destFolderUri: string = '';

  /**
   * 操作类型
   */
  operateType: WorkerConst.OperateType;

  /**
   * 操作进度
   */
  progressRate: number;

  /**
   * 是否是外部：跨设备、跨盘
   */
  public isExternalOperate: boolean = false;

  /**
   * 文件总大小(phone专用)
   */
  totalSize: number;

  /**
   * 已完成大小(phone专用)
   */
  completeSize: number;

  /**
   * 文件总数量
   */
  totalCount: number;

  /**
   * 已完成数量(phone专用)
   */
  completeCount: number;

  constructor(operateType: WorkerConst.OperateType, progressRate: number) {
    this.operateType = operateType;
    this.progressRate = progressRate;
  }
}