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
import type { ProgressBarInfo } from './ProgressBarInfo';
import type { ProgressTipInfo } from './ProgressTipInfo';

/**
 * 进度条信息
 */
export class ProgressInfo {
  /**
   * 线程名称
   */
  workerName: string;

  /**
   * 正在操作的文件名
   */
  operateFileName: string;

  /**
   * 输出的文件/目录路径
   */
  outputFilePath: string;

  /**
   * 进度条信息
   */
  progressBarInfo: ProgressBarInfo;

  /**
   * 进度条提示
   */
  progressTipInfo: ProgressTipInfo;

  /**
   * 是否显示提示
   */
  isShowTip: boolean;

  /**
   * 进度信息是否显示
   */
  isProgressVisible: boolean;

  constructor(workerName: string, operateFileName: string, progressBarInfo: ProgressBarInfo, isShowTip: boolean,
              isProgressVisible: boolean = false, outputFilePath: string = '') {
    this.workerName = workerName;
    this.operateFileName = operateFileName;
    this.progressBarInfo = progressBarInfo;
    this.isShowTip = isShowTip;
    this.isProgressVisible = isProgressVisible;
    this.outputFilePath = outputFilePath;
  }
}