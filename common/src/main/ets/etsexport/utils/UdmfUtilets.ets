/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
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
import { UdmfInfo, UdmfUtils } from '../../dragfile/UdmfUtil';
import { BusinessError } from '@kit.BasicServicesKit';
import { TimeUtil } from '../../utils/TimeUtil';

const TAG = 'UdmfUtilets';
export class UdmfUtilets {

  protected static getDataFromUdmfRetry(event: DragEvent): UnifiedData | undefined {
    try {
      const data: UnifiedData = event.getData();
      if (!data) {
        return undefined;
      }
      return data;
    } catch (e) {
      HiLog.error(TAG, `getData failed, code =  + ${(e as BusinessError).code}, message = ${(e as BusinessError).message})`);
      return undefined;
    }
  }

  public static async getDataFromUdmf(event: DragEvent): Promise< UnifiedData | undefined> {
    let data: UnifiedData | undefined;
    // 获取数据失败后, 1000ms后重试，重试5次
    for (let i: number = 0; i < 5; i++) {
      data = UdmfUtilets.getDataFromUdmfRetry(event);
      if (data) {
        return data;
      }
      await TimeUtil.sleep(1000);
    }
    return data;
  }

  public static async getFileArrFromUDMF(event: DragEvent): Promise<string[]> {
    let fileUriArr: string[] = [];
    const dragData = await UdmfUtilets.getDataFromUdmf(event);
    if (!dragData) {
      HiLog.error(TAG, 'dropData undefined!');
      return fileUriArr;
    }
    HiLog.info(TAG, 'dropData start.');
    let record = dragData.getRecords();
    if (record.length <= 0) {
      HiLog.warn(TAG, 'dropData getRecords is null!');
      return fileUriArr;
    }
    let len = record.length;
    HiLog.info(TAG, 'record.length: ' + len);
    let isRemote: boolean = false;
    for (let i = 0; i < len; i++) {
      let dataContent: UdmfInfo = new UdmfInfo();
      let type = record[i].getType();
      dataContent = UdmfUtils.getRecordData(record[i], type);
      if (dataContent.fileUri === '') {
        continue;
      }
      isRemote = dataContent?.isRemote;
      fileUriArr.push(dataContent.fileUri);
    }
    HiLog.info(TAG, 'fileUriArr :' + fileUriArr.length + '  isRemote : ' + isRemote);
    return fileUriArr;
  }

}