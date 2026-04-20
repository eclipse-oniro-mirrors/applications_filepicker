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

import type { ErrorEvent, MessageEvents, ThreadWorkerGlobalScope } from '@ohos.worker';
import worker from '@ohos.worker';
import type { CopyCutSendParam } from '../workermanager/copycutmanager/CopyCutSendParam';
import type { DeleteRestoreSendParam } from '../workermanager/deleterestoremanager/DeleteRestoreSendParam';
import type { SendParams } from '../worker/SendParams';
import { FileCopyUtil } from '../workeroperate/fs/FileCopyUtil';
import { FileDeleteUtil } from '../workeroperate/fs/FileDeleteUtil';
import { HiLog } from '../dfx/HiLog';
import { WorkerConst } from '../worker/WorkerConst';

const TAG = 'FileOperateWorker';
HiLog.info(TAG, `FileOperateWorker worker start`);

let workerPort: ThreadWorkerGlobalScope = worker.workerPort;

let fileCopyUtil: FileCopyUtil | undefined;
let fileDeleteUtil: FileDeleteUtil | undefined;

const SWITCH_CASE_MAP = new Map([
  [WorkerConst.OperateType.COPY_FILE, async (sendParams: SendParams): Promise<void> => {
    let fileCopyUtil = getFileCopyUtil();
    fileCopyUtil.workerPort = workerPort;
    await fileCopyUtil.dealMessage(sendParams as CopyCutSendParam);
  }],
  [WorkerConst.OperateType.CUT_FILE, async (sendParams: SendParams): Promise<void> => {
    let fileCopyUtil = getFileCopyUtil();
    fileCopyUtil.workerPort = workerPort;
    await fileCopyUtil.dealMessage(sendParams as CopyCutSendParam);
  }],
  [WorkerConst.OperateType.DRAG_FILE, async (sendParams: SendParams): Promise<void> => {
    let fileCopyUtil = getFileCopyUtil();
    fileCopyUtil.workerPort = workerPort;
    await fileCopyUtil.dealMessage(sendParams as CopyCutSendParam);
  }],
  [WorkerConst.OperateType.UNDO_MOVE, async (sendParams: SendParams): Promise<void> => {
    let fileCopyUtil = getFileCopyUtil();
    fileCopyUtil.workerPort = workerPort;
    await fileCopyUtil.dealMessage(sendParams as CopyCutSendParam);
  }],
  [WorkerConst.OperateType.DELETE_FILE, async (sendParams: SendParams): Promise<void> => {
    let fileDeleteUtil = getFileDeleteUtil();
    fileDeleteUtil.workerPort = workerPort;
    await fileDeleteUtil.dealMessage(sendParams as DeleteRestoreSendParam);
  }],
  [WorkerConst.OperateType.SOFT_DELETE_FILE, async (sendParams: SendParams): Promise<void> => {
    let fileDeleteUtil = getFileDeleteUtil();
    fileDeleteUtil.workerPort = workerPort;
    await fileDeleteUtil.dealMessage(sendParams as DeleteRestoreSendParam);
  }],
  [WorkerConst.OperateType.RESTORE_FILE, async (sendParams: SendParams): Promise<void> => {
    let fileDeleteUtil = getFileDeleteUtil();
    fileDeleteUtil.workerPort = workerPort;
    await fileDeleteUtil.dealMessage(sendParams as DeleteRestoreSendParam);
  }],
]);

function getFileCopyUtil(): FileCopyUtil {
  if (!fileCopyUtil) {
    fileCopyUtil = new FileCopyUtil();
  }
  return fileCopyUtil;
}

function getFileDeleteUtil(): FileDeleteUtil {
  if (!fileDeleteUtil) {
    fileDeleteUtil = new FileDeleteUtil();
  }
  return fileDeleteUtil;
}

/**
 * 接收主线程发送的worker消息
 * @param e message data
 */
workerPort.onmessage = async (e: MessageEvents): Promise<void> => {
  let sendParams: SendParams = e.data;
  HiLog.info(TAG, `FileOperateWorker worker onmessage, sendType: ${sendParams.operateType}`);
  if (sendParams.operateType === WorkerConst.OperateType.CANCEL) {
    HiLog.info(TAG, 'FileOperateWorker task canceled');
    return;
  }
  await SWITCH_CASE_MAP.get(sendParams.operateType)!!(sendParams);
};

/**
 * 表示当Worker对象接收到一条无法被序列化的消息
 * @param e message data
 */
workerPort.onmessageerror = (e: MessageEvents): void => {
  HiLog.error(TAG, `FileOperateWorker onmessageerror: ${e.data}`);
};

/**
 * 表示Worker在执行过程中发生异常
 * @param e error message
 */
workerPort.onerror = (e: ErrorEvent): void => {
  HiLog.errorPrivate(TAG, `onerror:, ${e.message}`, e.filename);
};