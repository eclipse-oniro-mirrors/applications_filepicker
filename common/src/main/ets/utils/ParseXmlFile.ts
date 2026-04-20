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

import { ObjectUtil } from './ObjectUtil';
import { common } from '@kit.AbilityKit';
import { GlobalHolder } from '../global/GlobalHolder';
import { StringUtil } from './StringUtil';
import { HiLog } from '../dfx/HiLog';
import fs from '@ohos.file.fs';
import { JSON, xml } from '@kit.ArkTS';

const TAG: string = 'ParseXmlFile';
const PASTE_BUFFER = 4194304; // 4M

/**
 * 字符串工具类
 */
export class ParseXmlFile {
  private static getFileBuffer(filePath: string): ArrayBuffer {
    let file: fs.File | undefined;
    let arrayBuffer: ArrayBuffer = new ArrayBuffer(0);
    try {
      file = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      let stat = fs.statSync(file.fd);
      if (stat.size > PASTE_BUFFER) { // 防止出现异常超大文件，读取到内存中
        HiLog.warn(TAG, 'file is to large.');
        return arrayBuffer;
      }
      arrayBuffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, arrayBuffer);
    } catch (e) {
      HiLog.errorPrivate(TAG, `getFileBuffer error, code: ${e?.code}, message: ${e?.message}`, `filePath: ${filePath}`);
    } finally {
      if (file) {
        fs.closeSync(file);
      }
    }
    return arrayBuffer;
  }

  public static getXmlFileData(filePath: string, key: string): Map<string, string> {
    HiLog.warnPrivate(TAG, `get xml start.`, `, file path: ${filePath}`);
    let arrayBuffer = ParseXmlFile.getFileBuffer(filePath);
    let xmlParseMap: Map<string, string> = new Map();
    if (arrayBuffer.byteLength === 0) {
      HiLog.errorPrivate(TAG, 'file str is empty.', `file path: ${filePath}`);
      return xmlParseMap;
    }
    let keyArray: string[] = [];
    let valueArray: string[] = [];
    try {
      let parser = new xml.XmlPullParser(arrayBuffer, 'UTF-8');
      let options: xml.ParseOptions = {
        ignoreNameSpace: true,
        attributeValueCallbackFunction: (name: string, value: string) => {
          HiLog.infoPrivate(TAG, `attributeValueCallbackFunction, name: ${name}`, `, value: ${value}`);
          // name参数，值为key，用于单升单持久化识别  值为name 作为双升单xml文件识别值
          if (name === key) {
            keyArray.push(value);
          }
          // value，作为实际数值
          if (name === 'value') {
            valueArray.push(value);
          }
          return true;
        }
      };
      parser.parseXml(options);
      HiLog.info(TAG, `getXml length: ${keyArray.length},  ${valueArray.length} `);
    } catch (error) {
      HiLog.error(TAG, `XmlPullParser error code: ${error?.code}, message: ${error?.message}}`);
    }
    if (keyArray.length !== valueArray.length) {
      HiLog.warn(TAG, `keyArray.length !== valueArray.length`);
      return xmlParseMap;
    }
    for (let i = 0; i < keyArray.length; i++) {
      xmlParseMap.set(keyArray[i], valueArray[i]);
    }
    HiLog.info(TAG, `xml paste map : ${xmlParseMap.size}`)
    return xmlParseMap;
  }
}
