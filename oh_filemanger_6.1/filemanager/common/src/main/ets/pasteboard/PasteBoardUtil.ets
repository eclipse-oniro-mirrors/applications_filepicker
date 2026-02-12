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
import pasteboard from '@ohos.pasteboard';
import { PasteFlag } from '../const/FilePasteConstants';
import { HiLog } from '../dfx/HiLog';
import { ArrayUtil } from '../utils/ArrayUtil';
import { StringUtil } from '../utils/StringUtil';
import { PasteboardDataModel } from '../model/PasteboardDataModel';
import { LocationType } from '../const/Constant';
import { PasteBoardUtilTemp } from './PasteBoardUtilTemp';

const TAG_PU = 'PasteBoardUtil';

export class PasteBoardUtil {

  /**
   * 从全局map中根据workerName找到对应pasteDate对象，通过该pasteDate对象发起关闭p2p通道请求，并从全局map中移除该对象
   * @param workerName
   */
  public static removePasteDateFromGlobalPasteDateMap(workerName: string): void {
    if (AppStorage.has('globalPasteDateMap')) {
      let globalPasteDateMap: Map<string, pasteboard.PasteData | undefined> =
        AppStorage.get<Map<string, pasteboard.PasteData | undefined>>('globalPasteDateMap')!;
      if (globalPasteDateMap.has(workerName)) {
        let pasteData: pasteboard.PasteData | undefined = globalPasteDateMap.get(workerName);
        HiLog.info(TAG_PU, `pasteComplete workerName: ${workerName}`);
        PasteBoardUtilTemp.pasteComplete(pasteData);
        globalPasteDateMap.delete(workerName);
      }
    }
  }

  /**
   * 将文件uri写入剪切板
   * @param uris 文件ur数组
   * @param pasteDataTag 粘贴数据的tag
   * @param isNeedCrossDevice 是否跨设备
   * @returns
   */
  public static async setUriToPasteboard(fileUriList: string[], pasteDataTag: string = '',
    isNeedCrossDevice: boolean = true): Promise<boolean> {
    let result = false;
    if (ArrayUtil.isEmpty(fileUriList)) {
      return result;
    }
    HiLog.info(TAG_PU,
      `setUriToPasteboard fileUriList length:${fileUriList.length}, pasteboardTag: ${pasteDataTag} ,isNeedCrossDevice: ${isNeedCrossDevice}`);
    try {
      let pasteData: pasteboard.PasteData | undefined;
      fileUriList.forEach((fileUri) => {
        if (!pasteData) {
          pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_URI, fileUri);
        } else {
          pasteData.addRecord(pasteboard.MIMETYPE_TEXT_URI, fileUri);
        }
      });
      if (!pasteData) {
        return false;
      }
      let property = pasteData.getProperty();
      property.tag = pasteDataTag;
      property.shareOption =
        isNeedCrossDevice ? pasteboard.ShareOption.CROSSDEVICE : pasteboard.ShareOption.LOCALDEVICE;
      pasteData.setProperty(property);
      const systemPasteboard = pasteboard.getSystemPasteboard();
      await systemPasteboard.setData(pasteData);
      result = true;
      HiLog.info(TAG_PU, 'setUriToPasteboard setData success');
    } catch (error) {
      HiLog.error(TAG_PU, 'setUriToPasteboard fail, error:' + JSON.stringify(error));
    }
    HiLog.info(TAG_PU, `setUriToPasteboard result: ${result}`);
    return result;
  }

  /**
   * 从剪切板获取pasteData对象
   */
  public static async getPasteData(): Promise<pasteboard.PasteData | undefined> {
    let pasteData: pasteboard.PasteData | undefined;
    try {
      let systemPasteboard = pasteboard.getSystemPasteboard();
      pasteData = await systemPasteboard.getData();
    } catch (error) {
      HiLog.error(TAG_PU, `getPasteData fail, error: ${JSON.stringify(error)}`)
    }
    return pasteData;
  }

  /**
   * 获取剪切板里文件uri数据
   */
  public static async getUriFromPasteboard(pasteData: pasteboard.PasteData | undefined): Promise<PasteboardDataModel> {
    let pasteboardData: PasteboardDataModel = new PasteboardDataModel();
    HiLog.info(TAG_PU, 'getUriFromPasteboard start');
    try {
      const hasUriData = PasteBoardUtil.checkUriData();
      if (!hasUriData) {
        HiLog.warn(TAG_PU, 'systemPasteboard has no uri data');
        return pasteboardData;
      }
      if (!pasteData) {
        return pasteboardData;
      }
      const property = pasteData.getProperty();
      const uriCount = pasteData.getRecordCount();
      let index = 0;
      let uriList: string[] = [];
      while (index < uriCount) {
        const pasteDataRecord = pasteData.getRecord(index);
        if (pasteDataRecord.uri) {
          if (!uriList) {
            uriList = [pasteDataRecord.uri];
          } else {
            uriList.push(pasteDataRecord.uri);
          }
        }
        index++;
      }
      if (ArrayUtil.isEmpty(uriList)) {
        HiLog.warn(TAG_PU, 'uriList in pasteboard is empty');
      } else {
        pasteboardData = {
          fileUriList: uriList,
          timestamp: property.timestamp,
          source: '',
          tag: property.tag || ''
        };
      }
      HiLog.info(TAG_PU, 'getUriFromPasteboard success');
    } catch (error) {
      HiLog.error(TAG_PU, 'getUriFromPasteboard fail, error:' + JSON.stringify(error));
    }
    HiLog.info(TAG_PU, 'getUriFromPasteboard end');
    return pasteboardData;
  }

  /**
   * 检查剪切板上是否有uri数据
   * returns 是否有uri数据
   */
  public static checkUriData(): boolean {
    let result: boolean = false;
    try {
      let systemPasteboard = pasteboard.getSystemPasteboard();
      result = systemPasteboard.hasDataType(pasteboard.MIMETYPE_TEXT_URI);
    } catch (error) {
      HiLog.error(TAG_PU, 'checkUriData fail, error:' + JSON.stringify(error));
    }
    HiLog.info(TAG_PU, 'checkUriData result:' + result);
    return result;
  }

  /**
   * 清空剪切板上的数据
   * returns 是否清除成功
   */
  public static async clearPasteData(): Promise<boolean> {
    let result: boolean = false;
    try {
      const systemPasteboard = pasteboard.getSystemPasteboard();
      await systemPasteboard.clearData();
      result = true;
    } catch (error) {
      HiLog.error(TAG_PU, 'clearPasteData fail, error:' + JSON.stringify(error));
    }
    HiLog.info(TAG_PU, 'clearPasteData result:' + result);
    return result;
  }
}