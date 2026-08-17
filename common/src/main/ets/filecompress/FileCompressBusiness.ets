/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import { FileInfo } from '../fileoperate/FileInfo';
import { HiLog } from '../dfx/HiLog';
import { FileCompressWorkerMgr } from '../workermanager/filecompressmanager/FileCompressWorkerMgr';
import { FileCompressSendParam } from '../workermanager/filecompressmanager/FileCompressSendParam';
import { GlobalHolder } from '../global/GlobalHolder';
import type common from '@ohos.app.ability.common';
import WorkerConst from '../worker/WorkerConst';
import lazy { FileCompressConst } from '../workermanager/filecompressmanager/FileCompressConst';
import { StringUtil } from '../utils/StringUtil';

const TAG = 'FileCompressBusiness';

export class FileCompressBusiness {
  /**
   * 文件压缩功能入口
   * @param fileInfo: 文件信息列表
   */
  public static fileCompress(fileArray: FileInfo[], workerName: string, destFilePath: string): boolean {
    HiLog.infoPrivate(TAG, `fileCompress, fileArray`, `${JSON.stringify(fileArray)}`);
    const index = destFilePath.lastIndexOf('/');
    if (index === -1) {
      HiLog.error(TAG, 'destFilePath is invalid');
      return false;
    }
    const destDirPath = destFilePath.substring(0, index);
    const destFileName = destFilePath.substring(index + 1);
    if (StringUtil.isEmpty(destFileName) || StringUtil.isEmpty(destDirPath)) {
      HiLog.error(TAG, 'destDirPath or destFileName is invalid');
      return false;
    }
    const manager = FileCompressWorkerMgr.getInstance(workerName);
    const context = (GlobalHolder.getInstance().getMainAbilityContext() ??
      GlobalHolder.getInstance().getUIExtensionContext()) as common.Context;
    const sendParam: FileCompressSendParam = new FileCompressSendParam(
      context,
      WorkerConst.OperateType.COMPRESS_FILE,
      workerName,
      FileCompressConst.TaskType.COMPRESS,
      fileArray,
      destDirPath
    );
    // 执行压缩前，确定压缩包生成名
    sendParam.destFileName = destFileName;
    return manager.workerTaskStart(sendParam);
  }

  /**
   * 文件解压缩功能入口
   * @param fileInfo: 压缩包信息 （文件分卷解压缩：part1压缩包信息）
   */
  public static fileDecompress(fileInfo: FileInfo, outDirPath: string, password: string, workerName: string): boolean {
    HiLog.infoPrivate(TAG, `fileDecompress`, `fileName: ${fileInfo.fileName}, outpath: ${outDirPath}`);
    // 解压缩管理执行
    const manager = FileCompressWorkerMgr.getInstance(workerName);
    const isMgrReused: boolean = manager.isMgrReused();
    const context = GlobalHolder.getInstance().getMainAbilityContext() as common.UIAbilityContext;
    const sendParam: FileCompressSendParam = new FileCompressSendParam(
      context,
      WorkerConst.OperateType.COMPRESS_FILE,
      workerName,
      FileCompressConst.TaskType.DECOMPRESS,
      [fileInfo],
      outDirPath
    );
    sendParam.password = password;

    if (isMgrReused) {
      return manager.sendMsgToWorker(sendParam);
    }
    return manager.workerTaskStart(sendParam);
  }

  /**
   * 文件取消压缩/取消解压缩功能入口
   * @param workerName: 进度条窗口key值
   */
  public static fileCompressCancel(workerName: string): boolean {
    if (!workerName) {
      HiLog.error(TAG, 'fileCompressCancel, workerName not exist');
      return false;
    }
    const manager: FileCompressWorkerMgr = FileCompressWorkerMgr.getInstance(workerName);
    return manager.taskCancel(workerName);
  }
}