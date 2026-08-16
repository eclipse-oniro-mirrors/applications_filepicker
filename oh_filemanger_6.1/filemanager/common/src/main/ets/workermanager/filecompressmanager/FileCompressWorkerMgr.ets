/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 * Description: 压缩/解压缩业务管理控制类
 */

import { ObjectUtil } from '../../utils/ObjectUtil';
import { WorkerPoolManager } from '../../worker/WorkerPoolManager';
import { TaskObject } from '../../worker/TaskObject';
import WorkerConst from '../../worker/WorkerConst';
import { HiLog } from '../../dfx/HiLog';
import { FileCompressSendParam } from './FileCompressSendParam';
import type { FileCompressResultParam } from './FileCompressResultParam';
import { ProgressInfo } from '../ProgressInfo';
import { ProgressBarInfo } from '../ProgressBarInfo';
import lazy { FileCompressConst } from './FileCompressConst';
import { Constant } from '../../const/Constant';
import { TransferringModel } from '../../fileoperate/TransferringModel';
import { FileUtil } from '../../fileoperate/FileUtil';
import { GlobalHolder } from '../../global/GlobalHolder';
import fs from '@ohos.file.fs';
import { PageUtil } from '../../utils/PageUtil';
import { FileInfo } from '../../fileoperate/FileInfo';
import { ResourceUtil } from '../../utils/ResourceUtil';
import { compress } from './FileCompressSdk';
import { StandardErrCode } from './CompressStandardErrCode';
import { toast } from '../../utils/Tools';
import { EventBus } from '../../utils/EventBus';

const PROGRESS_INFO_KEY = 'CompressProgressInfoMap';
const ERR_TIP_INDEX_KEY = 'CompressErrTipIndexMap';
const DEFAULT_TIP_INDEX = -1;
const COMPRESS_MGR_KEY: string = 'CompressWorkerMgrMap'; // 统一管理文件压缩解压业务的manager
const MIN_PROGRESS_DISPLAY_MS = 800;

export class FileCompressWorkerMgr {
  private taskObj: TaskObject | null = null;
  private tag: string = 'FileCompressWorkerMgr';
  private taskType: FileCompressConst.TaskType | undefined;
  private isTaskEnd: boolean = false;
  private startTime: number = 0;
  private outputFilePath: string = '';
  private outputDirPath: string = '';

  /*
 * 创建压缩/解压缩workerManager
 * @param workerName: 任务名称
 */
  public static getInstance(workerName: string): FileCompressWorkerMgr {
    let managerMap: Map<string, FileCompressWorkerMgr> = new Map();
    let manager: FileCompressWorkerMgr = new FileCompressWorkerMgr();
    if (!AppStorage.has(COMPRESS_MGR_KEY)) {
      managerMap.set(workerName, manager);
      AppStorage.setOrCreate<Map<string, FileCompressWorkerMgr>>(COMPRESS_MGR_KEY, managerMap);
    } else {
      managerMap = AppStorage.get<Map<string, FileCompressWorkerMgr>>(COMPRESS_MGR_KEY)!!;
      if (!managerMap.has(workerName)) {
        managerMap.set(workerName, manager);
        AppStorage.setOrCreate<Map<string, FileCompressWorkerMgr>>(COMPRESS_MGR_KEY, managerMap);
      } else {
        manager = managerMap.get(workerName)!;
      }
    }
    return manager;
  }

  /*
   * 判断manager是否复用(带密码解压场景)
   */
  public isMgrReused(): boolean {
    return !ObjectUtil.isNullOrUndefined(this.taskObj);
  }

  /*
   * 删除压缩/解压缩workerManager
   * @param workerName: 任务名称
   */
  public static delManagerInstance(workerName: string): void {
    if (!AppStorage.has(COMPRESS_MGR_KEY)) {
      return;
    }
    let managerMap = AppStorage.get<Map<string, FileCompressWorkerMgr>>(COMPRESS_MGR_KEY)!;
    if (!managerMap.has(workerName)) {
      return;
    }
    managerMap.delete(workerName);
    AppStorage.setOrCreate<Map<string, FileCompressWorkerMgr>>(COMPRESS_MGR_KEY, managerMap);
  }

  /*
   * 创建压缩/解压缩workerTask
   * @param sendParam: 压缩发送worker线程参数
   */
  public workerTaskStart(sendParam: FileCompressSendParam): boolean {
    HiLog.info(this.tag, `workerTaskStart, taskType: ${sendParam.taskType}, workerName: ${sendParam.workerName}`);
    if (!this.isParamValid(sendParam)) {
      HiLog.error(this.tag, 'workerTaskStart, sendParam is invalid.');
      return false;
    }
    this.isTaskEnd = false;
    this.taskType = sendParam.taskType;
    this.seedInitialProgress(sendParam);
    try {
      this.taskObj = new TaskObject(sendParam, (result: FileCompressResultParam) => this.onRecvMsgFromWorker(result));
      WorkerPoolManager.getInstance().execute(this.taskObj);
    } catch (err) {
      HiLog.error(this.tag, `workerTaskStart, error: ${err.code}`);
      return false;
    }
    return true;
  }

  /*
   * 取消压缩/解压缩
   * @param workerName: 任务唯一标识
   */
  public taskCancel(workerName: string): boolean {
    if (this.isTaskEnd) {
      return true;
    }
    if (!this.taskObj) {
      HiLog.error(this.tag, 'taskCancel, taskObj is null.');
      return false;
    }
    if (!this.taskObj.worker) {
      // 取消任务池中正在排队的任务
      HiLog.info(this.tag, `taskCancel, taskObj is on pending, remove from taskQueue`);
      WorkerPoolManager.getInstance().removeFromTaskQueue(this.taskObj);
      this.isTaskEnd = true;
      this.dealTaskEnd(workerName);
      return true;
    }
    const sendParam: FileCompressSendParam = new FileCompressSendParam(
      GlobalHolder.getInstance().getMainAbilityContext(),
      WorkerConst.OperateType.COMPRESS_FILE,
      workerName,
      FileCompressConst.TaskType.CANCEL,
      [],
      ''
    );
    return this.sendMsgToWorker(sendParam);
  }

  public isParamValid(sendParam: FileCompressSendParam): boolean {
    if (sendParam.operateType !== WorkerConst.OperateType.COMPRESS_FILE) {
      HiLog.error(this.tag, 'isParamValid, operateType is error.');
      return false;
    }

    if (sendParam.workerName === '') {
      HiLog.error(this.tag, 'isParamValid, workerName is empty.');
      return false;
    }

    if (sendParam.toOperateFiles.length === 0) {
      HiLog.error(this.tag, 'isParamValid, fileArray is empty.');
      return false;
    } else {
      for (const fileItem of sendParam.toOperateFiles) {
        if (fileItem.uri === '') {
          HiLog.error(this.tag, 'isParamValid, relativePath is invalid.');
          return false;
        }
      }
    }

    if ((sendParam.taskType === FileCompressConst.TaskType.COMPRESS) && (sendParam.destFileName === '')) {
      HiLog.error(this.tag, 'isParamValid, destFilePath is empty with compression task.');
      return false;
    }

    if (!fs.accessSync(sendParam.destDirPath)) {
      HiLog.error(this.tag, 'isParamValid, destDirPath is invalid.');
      return false;
    }
    return true;
  }

  /*
   * 接收worker向主线程发送消息
   * @param result 结果
   */
  public onRecvMsgFromWorker(result: FileCompressResultParam): void {
    if (this.isTaskEnd) {
      // 任务结束后 不再接收
      return;
    }
    HiLog.debugPrivate(this.tag, `onRecvMsgFromWorker, workname: ${result.workerName}`, `result: ${JSON.stringify(result)}`);
    this.outputFilePath = result.outputFilePath;
    this.outputDirPath = result.outputDirPath;
    switch (result.resultType) {
      case WorkerConst.ResultType.SUCCESS:
        this.notifyTaskSuccess(result.errorCode);
        this.isTaskEnd = true;
        this.dealTaskEnd(result.workerName, false);
        break;
      case WorkerConst.ResultType.CANCEL:
        // 成功场景删除进度数据
        this.isTaskEnd = true;
        this.dealTaskEnd(result.workerName);
        this.removeEmptyDecompressDir();
        break;
      case WorkerConst.ResultType.ERROR:
        // 处理异常
        this.dealTaskError(result);
        break;
      case WorkerConst.ResultType.PROGRESS:
        // 更新进度
        this.dealTaskRunning(result);
        return;
      default:
        break;
    }
  }

  private notifyTaskSuccess(errorCode: StandardErrCode): void {
    let message: ResourceStr = '';
    const outputPath = this.taskType === FileCompressConst.TaskType.COMPRESS ?
      this.outputFilePath : this.outputDirPath;
    if (this.taskType === FileCompressConst.TaskType.COMPRESS) {
      let parentPath = FileUtil.getParentRelativePath(this.outputFilePath);
      toast(`成功压缩至 ${parentPath}`);
    } else {
      message = errorCode === StandardErrCode.ERR_COMPRESS_FILE_NAME_TOO_LONG_TRUNCATED ?
        $r('app.string.decompress_auto_truncate_tips') : `成功解压至 ${this.outputDirPath}`;
      toast(message);
    }
    EventBus.emit(Constant.EVENTS.COMPRESS_TASK_END, this.taskType, outputPath);
    PageUtil.refreshMyPhonePage();
    EventBus.emit(Constant.EVENTS.REFRESH_PHONE_SPACE_SIZE);
  }

  private seedInitialProgress(sendParam: FileCompressSendParam): void {
    const toOperateFiles = sendParam.toOperateFiles;
    if (toOperateFiles.length === 0) {
      return;
    }
    const fileName = FileUtil.getFileNameFromUri(toOperateFiles[0].uri);
    const operatingFileName = toOperateFiles.length === 1 ? `string:${fileName}` : `number:${toOperateFiles.length}`;
    const outputPath = sendParam.taskType === FileCompressConst.TaskType.COMPRESS ?
      `${sendParam.destDirPath}/${sendParam.destFileName}` : sendParam.destDirPath;
    const progressInfo = new ProgressInfo(
      sendParam.workerName,
      operatingFileName,
      new ProgressBarInfo(sendParam.operateType, 0),
      false,
      true,
      outputPath
    );
    this.createOrUpdateProgressMap(progressInfo);
    this.startTime = Date.now();
  }

  private getProgressInfoFromResult(result: FileCompressResultParam, isShowTip: boolean,
    isProgressVisible: boolean = true): ProgressInfo {
    return new ProgressInfo(
      result.workerName,
      result.operatingFileName,
      new ProgressBarInfo(
        result.operateType,
        result.progressRate
      ),
      isShowTip,
      isProgressVisible,
      this.outputFilePath
    );
  }

  /*
   * 进行中处理
   * @param result 消息
   */
  private dealTaskRunning(result: FileCompressResultParam): void {
    const progressInfo: ProgressInfo = this.getProgressInfoFromResult(result, false);
    this.createOrUpdateProgressMap(progressInfo);
    if (this.startTime === 0) {
      this.startTime = Date.now();
    }
  }

  /*
  * 结束处理 同时清理manager
  * @param workerName 任务名称
  * @param isCancel 是否为取消调用(false为成功调用)
  */
  private dealTaskEnd(workerName: string, isCancel: boolean = true): void {
    HiLog.info(this.tag, `dealTaskEnd, workerName: ${workerName}`);
    const elapsed = this.startTime > 0 ? Date.now() - this.startTime : 0;
    const closeDelay = isCancel ? 0 : Math.max(0, MIN_PROGRESS_DISPLAY_MS - elapsed);
    setTimeout(() => {
      this.stopCompressOperate(workerName);
      this.taskObj = null;
      FileCompressWorkerMgr.delManagerInstance(workerName);
    }, closeDelay);
  }

  /*
   * 处理错误
   * @param result 结果参数
   */
  private dealTaskError(result: FileCompressResultParam): void {
    HiLog.info(this.tag, `dealTaskError, errorCode: ${result.errorCode}`);
    if (this.isTaskEnd) {
      return;
    }
    if (this.taskType === FileCompressConst.TaskType.DECOMPRESS) {
      this.removeDecompressOutputDir();
    }
    this.isTaskEnd = true;
    if (this.taskObj?.worker) {
      this.sendMsgToWorker(new FileCompressSendParam(
        GlobalHolder.getInstance().getMainAbilityContext(),
        WorkerConst.OperateType.COMPRESS_FILE,
        result.workerName,
        FileCompressConst.TaskType.CANCEL,
        [],
        ''
      ));
    }
    EventBus.emit(Constant.EVENTS.COMPRESS_OR_DECOMPRESS_FAIL, this.taskType, result.errorCode);
    this.dealTaskEnd(result.workerName, true);
  }

  private removeDecompressOutputDir(): void {
    if (this.taskType === FileCompressConst.TaskType.COMPRESS || this.outputDirPath === '') {
      return;
    }
    FileCompressWorkerMgr.removeDecompressOutputDirSync(this.outputDirPath);
  }

  public static removeDecompressOutputDirSync(dirPath: string): void {
    if (dirPath === '') {
      return;
    }
    try {
      if (!fs.accessSync(dirPath)) {
        return;
      }
      const entries: string[] = fs.listFileSync(dirPath);
      for (const entry of entries) {
        const childPath = `${dirPath}/${entry}`;
        const stat = fs.statSync(childPath);
        if (stat.isDirectory()) {
          FileCompressWorkerMgr.removeDecompressOutputDirSync(childPath);
        } else {
          fs.unlinkSync(childPath);
        }
      }
      fs.rmdirSync(dirPath);
      HiLog.info('FileCompressWorkerMgr', `removeDecompressOutputDirSync success: ${dirPath}`);
    } catch (error) {
      HiLog.error('FileCompressWorkerMgr', `removeDecompressOutputDirSync error: ${JSON.stringify(error)}`);
    }
  }

  private removeEmptyDecompressDir(): void {
    if (this.taskType === FileCompressConst.TaskType.COMPRESS) {
      return;
    }
    try {
      const fileList: string[] = fs.listFileSync(this.outputDirPath);
      if (fileList.length === 0) {
        fs.rmdirSync(this.outputDirPath);
      }
    } catch (error) {
      HiLog.error(this.tag, `removeEmptyDecompressDir error: ${JSON.stringify(error)}`);
    }
  }

  /*
   * 主线程向worker发送消息
   * @param sendParam send参数
   */
  public sendMsgToWorker(sendParam: FileCompressSendParam): boolean {
    if (!this.taskObj) {
      HiLog.error(this.tag, 'sendMsgToWorker, taskObj is null.');
      return false;
    }
    if (!this.taskObj.worker) {
      HiLog.error(this.tag, 'sendMsgToWorker, worker is null.');
      return false;
    }
    this.taskObj.notifyMsg(sendParam);
    return true;
  }

  private createProgressMap(taskType: string, progressInfo: ProgressInfo): void {
    HiLog.info(this.tag, 'createProgressMap, create new progress map');
    AppStorage.setOrCreate<Map<string, ProgressInfo[]>>(PROGRESS_INFO_KEY, new Map([[taskType, [progressInfo]]]));
  }

  private updateProgressMap(taskType: string, progressInfo: ProgressInfo): void {
    HiLog.info(this.tag, 'updateProgressMap, flush progressList');
    let progressInfoMap: Map<string, ProgressInfo[]> = new Map<string, ProgressInfo[]>();
    if (AppStorage.has(PROGRESS_INFO_KEY)) {
      progressInfoMap = AppStorage.get<Map<string, ProgressInfo[]>>(PROGRESS_INFO_KEY)!;
    }
    const errTipIndexMap = AppStorage.get<Map<string, number>>(ERR_TIP_INDEX_KEY) ??
      new Map([[taskType, DEFAULT_TIP_INDEX]]);
    const progressList: ProgressInfo[] = progressInfoMap.get(taskType) || [];
    let workerName = progressInfo.workerName;
    let isShowTip = progressInfo.isShowTip;
    // 更新已有进度条或增加新进度条
    let isAddNewProgressBar: boolean = true;
    for (let i = 0; i < progressList.length; i++) {
      if (progressList[i].workerName === workerName) {
        isAddNewProgressBar = false;
        if ((progressList[i].progressBarInfo.progressRate === progressInfo.progressBarInfo.progressRate) &&
          (progressList[i].isShowTip === progressInfo.isShowTip)) {
          break;
        }
        // 出现异常弹框
        if ((!progressList[i].isShowTip) && isShowTip) {
          errTipIndexMap.set(taskType, i);
          AppStorage.setOrCreate<Map<string, number>>(ERR_TIP_INDEX_KEY, errTipIndexMap);
        }
        progressList[i] = progressInfo;
        break;
      }
    }
    if (isAddNewProgressBar) {
      HiLog.info(this.tag, `updateProgressMap, add new progressInfo: ${progressInfo.workerName}`);
      progressList.push(progressInfo);
      if (isShowTip) {
        errTipIndexMap.set(taskType, progressList.length - 1);
        AppStorage.setOrCreate<Map<string, number>>(ERR_TIP_INDEX_KEY, errTipIndexMap);
      }
    }
    progressInfoMap.set(taskType, progressList);
    AppStorage.setOrCreate<Map<string, ProgressInfo[]>>(PROGRESS_INFO_KEY, progressInfoMap);
  }

  public createOrUpdateProgressMap(progressInfo: ProgressInfo): void {
    HiLog.infoPrivate(this.tag, 'createOrUpdateProgressMap, createOrUpdateProgress: ', JSON.stringify(progressInfo));
    const taskType: string = progressInfo.workerName.startsWith(Constant.OPERATION_TYPE.COMPRESSION) ?
    Constant.OPERATION_TYPE.COMPRESSION : Constant.OPERATION_TYPE.DECOMPRESSION;
    if (AppStorage.has(PROGRESS_INFO_KEY)) {
      // 更新map进度信息
      this.updateProgressMap(taskType, progressInfo);
    } else {
      // 新建map进度信息
      this.createProgressMap(taskType, progressInfo);
    }
  }

  private stopCompressOperate(workerName: string): void {
    this.updateProgressOnStop(workerName);
  }

  private updateProgressOnStop(workerName: string): void {
    const taskType: string = workerName.startsWith(Constant.OPERATION_TYPE.COMPRESSION)
      ? Constant.OPERATION_TYPE.COMPRESSION
      : Constant.OPERATION_TYPE.DECOMPRESSION;
    const progressInfoMap = AppStorage.get<Map<string, ProgressInfo[]>>(PROGRESS_INFO_KEY);
    if (!progressInfoMap) {
      return;
    }
    const progressList = progressInfoMap.get(taskType);
    if (!progressList) {
      return;
    }
    const newProgressList = progressList.filter(item => {
      return item.workerName !== workerName;
    });
    HiLog.info(this.tag, `updateProgressOnStop, remove progressInfo, workerName: ${workerName}`);
    if (newProgressList.length > 0) {
      progressInfoMap.set(taskType, newProgressList);
      AppStorage.setOrCreate<Map<string, ProgressInfo[]>>(PROGRESS_INFO_KEY, progressInfoMap);
      return;
    }
    progressInfoMap.delete(taskType);
    AppStorage.setOrCreate<Map<string, ProgressInfo[]>>(PROGRESS_INFO_KEY, progressInfoMap);
  }
}