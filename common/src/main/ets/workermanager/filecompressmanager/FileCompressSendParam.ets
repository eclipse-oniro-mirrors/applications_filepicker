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
import type WorkerConst from '../../worker/WorkerConst';
import type { FileInfo } from '../../fileoperate/FileInfo';
import lazy { FileCompressConst } from './FileCompressConst';

/**
 * 主线程向子线程发送消息参数
 */
export class FileCompressSendParam extends SendParams {
  public taskType: FileCompressConst.TaskType;
  public toOperateFiles: FileInfo[]; // 文件信息列表
  public destDirPath: string; // 业务目录
  public destFileName: string = ''; // 压缩场景下的输出文件名(同业务目录组成完整路径)
  public password: string = ''; // 解压缩时需要的密码(解压场景使用)
  public volumeSize: number = 0; // 分卷压缩大小

  constructor(context: common.Context, operateType: WorkerConst.OperateType, workerName: string,
    taskType: FileCompressConst.TaskType, toOperateFiles: FileInfo[], destDirPath: string) {
    super(context, operateType, workerName);
    this.taskType = taskType;
    this.toOperateFiles = toOperateFiles;
    this.destDirPath = destDirPath
  }
}