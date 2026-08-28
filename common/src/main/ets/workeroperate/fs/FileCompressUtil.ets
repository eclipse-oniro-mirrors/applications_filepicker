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

import { HiLog } from '../../dfx/HiLog';
import lazy { FileCompressConst } from '../../workermanager/filecompressmanager/FileCompressConst';
import { FileCompressWorkerMgr } from '../../workermanager/filecompressmanager/FileCompressWorkerMgr';
import type { FileCompressSendParam } from '../../workermanager/filecompressmanager/FileCompressSendParam';
import { FileCompressResultParam } from '../../workermanager/filecompressmanager/FileCompressResultParam';
import type { ThreadWorkerGlobalScope } from '@ohos.worker';
import WorkerConst from '../../worker/WorkerConst';
import { FileInfo } from '../../fileoperate/FileInfo';
import lazy { compress } from '../../workermanager/filecompressmanager/FileCompressSdk';
import { StandardErrCode } from '../../workermanager/filecompressmanager/CompressStandardErrCode';
import { FileUtil } from '../../fileoperate/FileUtil';
import { ExternalStorageUtil } from '../../externel/ExternalStorageUtil';
import fs from '@ohos.file.fs';
import { FsUtil } from '../../utils/FsUtil';
import { ThreadCommonUtil } from './ThreadCommonUtil';
// TODO: oh7zip 上库后恢复 import { CompressProp, DeCompressProp } from '@ohos/oh7zip';
// TODO: oh7zip 上库后恢复 import type { CallbackCompress } from '@ohos/oh7zip';

class CompressProp {
  inFiles: string[] = [];
  dirFiles?: object[] = undefined;
  innerDir?: string = undefined;
  outFile: string = '';
  password?: string = undefined;
  archiveFormat?: string = undefined;
  algorithms?: string = undefined;
  compressionLevel?: number = undefined;
  volumeSize?: number = undefined;
  excludePaths?: string[] = undefined;
}

class DeCompressProp {
  inFile: string = '';
  innerFiles?: string[] = undefined;
  password?: string = undefined;
  outDir: string = '';
  outName?: string = undefined;
}

class CallbackCompress {
  public code: number = 0;
  public progress: number = 0;
  public file: string = '';
}

const COMPLETE_PROGRESS = 100;
const MAX_FULL_PATH_LEN: number = 4095; // 全路径超出该值均无法在操作系统中成功创建对应路径

class CompressDirFileItem {
  dirPath: string = '.';
  inFiles: string[] = [];
}

export class FileCompressUtil {
  private tag: string = 'FileCompressUtil';
  /*
   * worker端口
   */
  public workerPort?: ThreadWorkerGlobalScope;
  /*
   * worker名称
   */
  private workerName: string = '';
  /*
   * 发起操作的消息类型，用于区分worker内的操作,压缩解压缩业务固定为COMPRESS_FILE
   */
  private operateType: WorkerConst.OperateType = WorkerConst.OperateType.COMPRESS_FILE;
  /*
   * 任务进度
   */
  private progressRate: number = 0;
  /**
   * 当前正在操作文件的文件名,用于进度条显示
   */
  private operatingFileName: string = '';
  /**
   * 当前正在操作文件的文件名,用于进度条显示
   */
  private taskType: FileCompressConst.TaskType = FileCompressConst.TaskType.COMPRESS;
  private inputFilePath: string = '';
  private outputFilePath: string = '';
  private outputDirPath: string = '';
  private isTaskEnd: boolean = false;

  /*
   * 处理消息
   * @param compressSendParam 发送参数
   * @returns
   */
  public async dealMessage(sendParam: FileCompressSendParam): Promise<boolean> {
    this.taskType = sendParam.taskType;
    HiLog.info(this.tag, `dealMessage, taskType: ${this.taskType}`);
    if (this.taskType === FileCompressConst.TaskType.CANCEL) {
      this.workerName = sendParam.workerName;
      return this.taskCancel();
    }
    this.initObjectData(sendParam);
    switch (this.taskType) {
      case FileCompressConst.TaskType.COMPRESS:
        return await this.startCompressTask(sendParam);
      case FileCompressConst.TaskType.DECOMPRESS:
        return await this.startDecompressTask(sendParam);
      default:
        HiLog.error(this.tag, 'dealMessage, taskType is undefined');
        return false;
    }
  }

  public initObjectData(sendParam: FileCompressSendParam): void {
    const toOperateFiles: FileInfo[] = sendParam.toOperateFiles;
    if (toOperateFiles.length === 0) {
      HiLog.warn(this.tag, 'initObjectData, toOperateFiles is empty');
      this.workerName = sendParam.workerName;
      return;
    }
    const fileName: string = FileUtil.getFileNameFromUri(toOperateFiles[0].uri);
    this.workerName = sendParam.workerName;
    this.operatingFileName = toOperateFiles.length === 1 ? `string:${fileName}` : `number:${toOperateFiles.length}`;
  }

  private async startCompressTask(sendParam: FileCompressSendParam): Promise<boolean> {
    const destDirPath = sendParam.destDirPath;
    this.outputDirPath = destDirPath;
    this.outputFilePath = `${destDirPath}/${sendParam.destFileName}`;
    HiLog.debugPrivate(this.tag, 'startCompressTask', `prop: ${JSON.stringify(sendParam.toOperateFiles)}`);
    const prop = new CompressProp();
    const containsFolder = sendParam.toOperateFiles.some(fileInfo => fileInfo.isFolder);
    const inputPaths = sendParam.toOperateFiles.map(fileInfo => FileUtil.getPathFromUri(fileInfo.uri));
    if (containsFolder) {
      // 目录压缩走 dirFiles，并保留被选目录本身这一层目录名。
      prop.inFiles = [];
      prop.dirFiles = FileCompressUtil.buildDirFilesForSelection(sendParam.toOperateFiles);
      HiLog.info(this.tag, 'startCompressTask route: dirFiles(directory)');
    } else {
      // 纯文件压缩尝试通过 dirFiles 绑定到归档根目录，减少绝对路径前缀被打进包内。
      prop.inFiles = [];
      prop.dirFiles = FileCompressUtil.buildDirFilesForSelection(sendParam.toOperateFiles);
      HiLog.info(this.tag, 'startCompressTask route: dirFiles(files)');
    }
    // 尊重用户选择的目标目录，不再因「输出在源文件夹内」而上提路径；
    // 输出 zip 通过 excludePaths 排除，避免打进自身。
    prop.outFile = this.outputFilePath;
    prop.excludePaths = FileCompressUtil.buildExcludePaths(inputPaths, this.outputFilePath);
    HiLog.infoPrivate(this.tag, 'startCompressTask, dupFilename=', sendParam.destFileName);

    try {
      if (fs.accessSync(this.outputFilePath)) {
        fs.unlinkSync(this.outputFilePath);
      }
    } catch (e) {
      HiLog.warn(this.tag, `startCompressTask, remove existing output file failed: ${JSON.stringify(e)}`);
    }

    try {
      compress.compression(this.workerName, prop, this.taskCallback);
      HiLog.info(this.tag, `startCompressTask`);
    } catch (e) {
      HiLog.error(this.tag, `compress failed, errCode: ${e?.code}, errMsg: ${e?.message}`);
      return false;
    }
    return true;
  }

  private async startDecompressTask(sendParam: FileCompressSendParam): Promise<boolean> {
    // 确定新增文件夹路径名
    this.inputFilePath = FileUtil.getPathFromUri(sendParam.toOperateFiles[0].uri);
    let fileName: string = FileUtil.getFileNameByUri(this.inputFilePath);
    fileName = fileName.substring(0, fileName.lastIndexOf('.'));
    const outputDirPath = FileCompressUtil.getDecompressDirPath(sendParam.destDirPath, fileName);
    if (ThreadCommonUtil.getByteLen(outputDirPath) > MAX_FULL_PATH_LEN) { // 全路径过长场景
      HiLog.error(this.tag, 'output full path too long');
      const errorCode = StandardErrCode.ERR_COMPRESS_FAILED_FULL_PATH_TOO_LONG;
      this.postMessage(WorkerConst.ResultType.ERROR, WorkerConst.WorkerStatus.FAIL, '', errorCode);
      return false;
    }
    this.outputDirPath = outputDirPath;
    try { // 创建解压文件夹路径
      fs.mkdirSync(this.outputDirPath);
    } catch (e) {
      HiLog.error(this.tag, `startDecompressTask, mkdir error: ${JSON.stringify(e)}`);
      const errorCode = StandardErrCode.ERR_COMPRESS_FILE_DECOMPRESS_FAILED;
      this.postMessage(WorkerConst.ResultType.ERROR, WorkerConst.WorkerStatus.FAIL, '', errorCode);
      return false;
    }
    const prop = new DeCompressProp();
    prop.inFile = this.inputFilePath;
    prop.outDir = this.outputDirPath;
    prop.password = sendParam.password;
    HiLog.debugPrivate(this.tag, 'startDecompressTask', `prop: ${JSON.stringify(prop)}`);
    try {
      compress.deCompression(this.workerName, prop, this.taskCallback);
      HiLog.info(this.tag, `startDecompressTask`);
    } catch (e) {
      HiLog.error(this.tag, `deCompress failed, errCode: ${e?.code}, errMsg: ${e?.message}`);
      return false;
    }
    return true;
  }

  private taskCancel(): boolean {
    if (this.isTaskEnd) {
      // 底层线程释放，cancel之后并不会触发callback，须应用层主动上报取消结束消息
      this.postMessage(WorkerConst.ResultType.CANCEL, WorkerConst.WorkerStatus.CANCEL, '');
      return true;
    }
    try {
      const res: number = compress.cancel(this.workerName);
      HiLog.info(this.tag, `taskCancel, workerName: ${this.workerName}, retCode: ${res}`);
    } catch (e) {
      HiLog.error(this.tag, `compress.cancel failed, errCode: ${e?.code}, errMsg: ${e?.message}`);
      return false;
    }
    return true;
  }

  private postMessage(resultType: WorkerConst.ResultType, workerStatus: WorkerConst.WorkerStatus, filePath: string,
    errCode?: StandardErrCode, customErrCode?: number, fileInfos?: FileInfo[]): void {
    let inputFilepath = '';
    let outputFilePath = '';
    if (this.taskType === FileCompressConst.TaskType.COMPRESS) {
      inputFilepath = filePath; // 压缩任务时源子文件
      outputFilePath = this.outputFilePath; // 压缩任务时输出文件
    } else {
      inputFilepath = this.inputFilePath; // 解压任务时源文件
      outputFilePath = filePath; // 解压任务时输出子文件
    }
    const compressResultParam = new FileCompressResultParam(
      this.workerName,
      workerStatus,
      resultType,
      this.operateType,
      this.progressRate,
      this.operatingFileName,
      inputFilepath,
      outputFilePath,
      this.outputDirPath,
      errCode,
      customErrCode,
      fileInfos
    );
    this.workerPort?.postMessage(compressResultParam);
  }

  private taskCallback = (data: CallbackCompress): void => {
    HiLog.info(this.tag, `taskCallback, workerName: ${this.workerName}, code: ${data.code}, progress: ${data.progress}`);
    if (data.code === StandardErrCode.ERR_FILEMGR_OK) {
      if (this.progressRate === data.progress) {
        return;
      }
      // 发送进度
      this.progressRate = data.progress;
      this.postMessage(WorkerConst.ResultType.PROGRESS, WorkerConst.WorkerStatus.RUNNING, data?.file ?? '');
      HiLog.debugPrivate(this.tag, `taskCallback, workerName: ${this.workerName}`, `data: ${JSON.stringify(data)}`);
      return;
    }
    this.isTaskEnd = true;
    HiLog.info(this.tag, `taskCallback, workerName: ${this.workerName}, retCode: ${data.code}`);
    this.syncData();
    // 结束消息延时50ms 防止进度在结束后返回
    const END_MESSAGE_DELAY = 50;
    setTimeout(() => {
      if ((data.code === StandardErrCode.ERR_COMPRESS_FILE_COMPRESS_SUCC) ||
        (data.code === StandardErrCode.ERR_COMPRESS_FILE_DECOMPRESS_SUCC) ||
        (data.code === StandardErrCode.ERR_COMPRESS_FILE_NAME_TOO_LONG_TRUNCATED)) {
        // 压缩/解压成功，关闭进度条
        const currProgressRate = this.progressRate;
        if (currProgressRate !== COMPLETE_PROGRESS) {
          // 控制任务进度数据始终能显示100
          this.progressRate = COMPLETE_PROGRESS;
          this.postMessage(WorkerConst.ResultType.PROGRESS, WorkerConst.WorkerStatus.RUNNING, data?.file ?? '');
        }
        this.postMessage(WorkerConst.ResultType.SUCCESS, WorkerConst.WorkerStatus.SUCCESS, data?.file ?? '', data.code);
      } else if ((data.code === StandardErrCode.ERR_COMPRESS_CANCEL_FILE_COMPRESS_SUCC) ||
        (data.code === StandardErrCode.ERR_COMPRESS_CANCEL_FILE_DECOMPRESS_SUCC)) {
        // 上报任务取消成功
        this.postMessage(WorkerConst.ResultType.CANCEL, WorkerConst.WorkerStatus.CANCEL, '');
      } else {
        if (this.taskType === FileCompressConst.TaskType.COMPRESS) {
          FileCompressUtil.removeIncompleteOutput(this.outputFilePath);
        } else {
          FileCompressUtil.removeDecompressOutputDir(this.outputDirPath);
        }
        this.progressRate = 0;
        // 解压/压缩错误，关闭进度条并提示错误信息
        this.postMessage(WorkerConst.ResultType.ERROR, WorkerConst.WorkerStatus.FAIL, data?.file ?? '', data.code);
      }
    }, END_MESSAGE_DELAY);
  }

  /**
   * 压缩/解压任务完成后,针对目标路径为外盘的文件执行落盘操作
   * */
  private syncData(): void {
    if (this.taskType === FileCompressConst.TaskType.COMPRESS &&
    ExternalStorageUtil.isExternalStorageUri(FileUtil.getUriFromPath(this.outputFilePath))) {
      HiLog.info(this.tag, 'sync external file for compression task');
      FsUtil.syncFile(this.outputFilePath);
    } else if (this.taskType === FileCompressConst.TaskType.DECOMPRESS &&
    ExternalStorageUtil.isExternalStorageUri(FileUtil.getUriFromPath(this.outputDirPath))) {
      HiLog.info(this.tag, 'sync external file for decompression task');
      FsUtil.syncFolderRecursively(this.outputDirPath);
    }
  }

  private static removeIncompleteOutput(outputFilePath: string): void {
    if (outputFilePath === '') {
      return;
    }
    try {
      if (fs.accessSync(outputFilePath)) {
        fs.unlinkSync(outputFilePath);
      }
    } catch (e) {
      HiLog.warn('FileCompressUtil', `removeIncompleteOutput failed: ${JSON.stringify(e)}`);
    }
  }

  private static removeDecompressOutputDir(dirPath: string): void {
    FileCompressWorkerMgr.removeDecompressOutputDirSync(dirPath);
  }

  private static buildDirFilesForSelection(fileInfos: FileInfo[]): object[] {
    if (fileInfos.length === 0) {
      return [];
    }
    const dirFiles: object[] = [];
    const rootFiles = new CompressDirFileItem();
    for (const fileInfo of fileInfos) {
      const inputPath = FileUtil.getPathFromUri(fileInfo.uri);
      if (fileInfo.isFolder) {
        const folderDirFileItem = new CompressDirFileItem();
        folderDirFileItem.dirPath = fileInfo.fileName;
        folderDirFileItem.inFiles = [inputPath];
        dirFiles.push(folderDirFileItem);
        continue;
      }
      rootFiles.inFiles.push(inputPath);
    }
    if (rootFiles.inFiles.length > 0) {
      dirFiles.push(rootFiles);
    }
    return dirFiles;
  }

  private static buildExcludePaths(inFiles: string[], outputFilePath: string): string[] {
    const excludeSet: Set<string> = new Set<string>();
    const lastSlash = outputFilePath.lastIndexOf('/');
    const outputFileName = lastSlash >= 0 ? outputFilePath.substring(lastSlash + 1) : outputFilePath;
    // 对齐 Config7z.xr：递归排除输出压缩包自身，避免同目录压缩打进 zip
    if (outputFileName.length > 0) {
      excludeSet.add(`!${outputFileName}`);
    }
    return Array.from(excludeSet);
  }

  private static getDecompressDirPath(parentPath: string, dirName: string): string {
    const folderNameFunc = (n: number): string => {
      return (n <= 1 ? dirName : ThreadCommonUtil.getDupFileResult(dirName, '', n));
    };
    let num = -1;
    let decompressDirPath: string = '';
    try {
      do {
        num++;
        decompressDirPath = `${parentPath}/${folderNameFunc(num)}`;
        if (ThreadCommonUtil.getByteLen(decompressDirPath) > MAX_FULL_PATH_LEN) {
          break;
        }
      } while (fs.accessSync(decompressDirPath));
    } catch (error) {
      HiLog.error('FileCompressUtil', `accessSync error: ${error?.code}`);

    }
    HiLog.debugPrivate('FileCompressUtil', `getDecompressDirPath, newFolderPath: `, decompressDirPath);
    return decompressDirPath;
  }
}