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
export class ProgressTipInfo {
  /**
   * 操作类型
   */
  dialogType: WorkerConst.DialogType;

  /**
   * 文件数量
   */
  fileNum: number;

  /**
   * 是否为文件夹
   */
  isFolder: boolean;

  constructor(dialogType: WorkerConst.DialogType, fileNum: number, isFolder: boolean) {
    this.dialogType = dialogType;
    this.fileNum = fileNum;
    this.isFolder = isFolder;
  }
}