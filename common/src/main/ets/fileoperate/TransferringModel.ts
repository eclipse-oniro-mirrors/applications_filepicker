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

import { Constant } from '../const/Constant';
import { HiLog } from '../dfx/HiLog';
import HashMap from '@ohos.util.HashMap';
import WorkerConst from '../worker/WorkerConst';

const REMOVE_TRANSFER_DATA_TIME_OUT = 50;

class TransferData {
  public srcUri: string;
  public dstUri: string;
  public operateType: WorkerConst.OperateType;

  constructor(srcUri: string, dstUri: string, operateType: WorkerConst.OperateType) {
    this.srcUri = srcUri;
    this.dstUri = dstUri;
    this.operateType = operateType;
  }
}

export class TransferringModel {
  // HashMap存储正在传输中源、目的uri和workerName
  public pasteMap: HashMap<string, TransferData>;
  private needShowDialog: boolean = false; // 表示是否需要弹出“U盘未安全移除，数据可能丢失”弹窗
  private TAG: string = 'TransferringModel';

  constructor() {
    this.pasteMap = new HashMap<string, TransferData>();
  }

  public static getInstance(): TransferringModel {
    if (AppStorage.get<TransferringModel>(Constant.TRANSFERRING_MODEL) === undefined) {
      AppStorage.setOrCreate<TransferringModel>(Constant.TRANSFERRING_MODEL, new TransferringModel());
    }
    return AppStorage.get<TransferringModel>(Constant.TRANSFERRING_MODEL) as TransferringModel;
  }

  /**
   * 新增传输任务
   */
  public addTransferData(workerName: string, srcUri: string, dstUri: string,
    operateType: WorkerConst.OperateType): void {
    let tempTransferData: TransferData = new TransferData(srcUri, dstUri, operateType);
    HiLog.info(this.TAG, ' add workerName , workerName : ' + workerName);
    this.pasteMap.set(workerName, tempTransferData);
    this.needShowDialog = true;
  }

  /**
   * 去除传输任务
   */
  public removeTransferData(workerName: string): void {
    if (!this.pasteMap.hasKey(workerName)) {
      HiLog.error(this.TAG, ' get workerName error, workerName : ' + workerName);
      return;
    }
    HiLog.info(this.TAG, ' remove workerName , workerName : ' + workerName);
    let timeoutBox = setTimeout(() => {
      this.pasteMap.remove(workerName);
      clearTimeout(timeoutBox);
    }, REMOVE_TRANSFER_DATA_TIME_OUT);
  }
}