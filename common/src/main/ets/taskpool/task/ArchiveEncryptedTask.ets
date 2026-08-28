/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */
import taskpool from '@ohos.taskpool';
import { BaseTask } from '../base/BaseTask';
import { TaskPoolName } from '../const/TaskConst';
import { HiLog } from '../../dfx/HiLog';
import lazy { compress } from '../../workermanager/filecompressmanager/FileCompressSdk';

/**
 * 解压文件判断是否加密任务
 */
export class EncryptCheckTask extends BaseTask {
  constructor(filepath: string) {
    super(TaskPoolName.DECOMPRESSION_ENCRYPTED_JUDGE);
    this.task = new taskpool.Task(encryptCheck, filepath);
  }
}


/**
 * 判断待解压文件是否加密
 */
@Concurrent
async function encryptCheck(filepath: string): Promise<void> {
  HiLog.info(TaskPoolName.DECOMPRESSION_ENCRYPTED_JUDGE, 'task start');

  let isEncrypted: boolean = false;
  try {
    isEncrypted = compress.isCompressEncryptedSync(filepath);
  } catch (err) {
    HiLog.error(TaskPoolName.DECOMPRESSION_ENCRYPTED_JUDGE,
      `isEncrypted failed, errCode: ${err?.code}, errMsg: ${err?.message}`);
    taskpool.Task.sendData(undefined);
    return;
  }

  HiLog.info(TaskPoolName.DECOMPRESSION_ENCRYPTED_JUDGE, 'task finished');
  try {
    if (taskpool.Task.isCanceled()) {
      HiLog.info(TaskPoolName.DECOMPRESSION_ENCRYPTED_JUDGE, `task canceled encryptCheck`);
      taskpool.Task.sendData(undefined);
      return;
    }
    taskpool.Task.sendData(isEncrypted);
  } catch (err) {
    HiLog.error(TaskPoolName.DECOMPRESSION_ENCRYPTED_JUDGE,
      `task sendData failed, errCode: ${err?.code}, errMsg: ${err?.message}`);
    taskpool.Task.sendData(undefined);
  }
}