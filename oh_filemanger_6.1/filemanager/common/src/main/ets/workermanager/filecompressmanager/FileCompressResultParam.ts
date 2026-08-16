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
import type { StandardErrCode } from './CompressStandardErrCode';

/*
 * 主线程收到子线程结果消息参数
 */
export class FileCompressResultParam extends ResultParams {
  progressRate: number; // 任务进度
  inputFilePath: string; // 输入文件
  outputFilePath: string; // 输出文件
  operatingFileName: string; // 进度条任务显示内容
  outputDirPath:string = ''; // 解压到的文件夹
  /**
   * 自定义错误码
   */
  customErrCode?: number;
  errorCode: StandardErrCode; // 异常结果码（异常场景使用）
  innerArchiveFileInfos: object[]; // 预览压缩包内文件信息

  constructor(
    workerName: string,
    workerStatus: WorkerConst.WorkerStatus,
    resultType: WorkerConst.ResultType,
    operateType: WorkerConst.OperateType,
    progressRate: number,
    operatingFileName: string,
    inputFilePath: string = '',
    outputFilePath: string = '',
    outputDirPath: string = '',
    errorCode?: StandardErrCode,
    customErrCode?: number,
    innerArchiveFileInfos?: object[]
  ) {
    super(workerName, operateType, workerStatus, resultType);
    this.progressRate = progressRate;
    this.operatingFileName = operatingFileName;
    this.errorCode = errorCode;
    this.inputFilePath = inputFilePath;
    this.outputFilePath = outputFilePath;
    this.outputDirPath = outputDirPath;
    this.customErrCode = customErrCode;
    this.innerArchiveFileInfos = innerArchiveFileInfos;
  }
}