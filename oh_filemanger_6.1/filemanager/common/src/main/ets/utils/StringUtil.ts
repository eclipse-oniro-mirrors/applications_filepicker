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

import util from '@ohos.util';
import { HiLog } from '../dfx/HiLog';
import buffer from '@ohos.buffer';

const TAG = 'StringUtil';

/**
 * 字符串工具类
 */
export class StringUtil {
  public static readonly RADIX_16 = 16;
  static textEncoder: util.TextEncoder = undefined;
  static textDecoder: util.TextDecoder = undefined;

  /**
   * 获取encoder实例
   * 编码格式默认为utf-8
   */
  static getTextEncoder(): util.TextEncoder {
    if (!this.textEncoder) {
      this.textEncoder = new util.TextEncoder();
    }
    return this.textEncoder;
  }

  /**
   * 获取decoder实例
   */
  static getTextDecoder(): util.TextDecoder {
    if (!this.textDecoder) {
      this.textDecoder = new util.TextDecoder();
    }
    return this.textDecoder;
  }

  /**
   * 字符串是否为空
   * @param str 字符串
   * @return 是否为空
   */
  public static isEmpty(str: string): boolean {
    return !str || str.length === 0;
  }

  /**
   * 将字符串转换成Uint8Array类型
   * @param str 字符串
   * @return 无符号整型数组
   */
  public static convert2Uint8Array(str: string): Uint8Array {
    if (StringUtil.isEmpty(str)) {
      return new Uint8Array();
    }
    return this.getTextEncoder().encodeInto(str);
  }

  /**
   * 将字符串做base64编码
   * @param str 字符串
   * @return Base64字符串
   */
  public static convert2Base64(str: string): string {
    if (StringUtil.isEmpty(str)) {
      return '';
    }
    const array = StringUtil.convert2Uint8Array(str);
    return new util.Base64Helper().encodeToStringSync(array);
  }

  /**
   * 字符串头部补全
   * @param num 待补全字符串
   * @param maxLen 补全后字符串的最大长度
   * @param placeholder 占位符
   * @return 不全后的字符串，如：1=>01
   */
  public static padStart(num: number | string, maxLen = 2, placeholder = '0'): string {
    return num.toString().padStart(maxLen, placeholder);
  }

  public static strSizeUTF8(str: string): number {
    if (!str) {
      HiLog.warn(TAG, 'parameter str of strSizeUTF8 is null or undefined');
      return 0;
    }
    let strLen = str.length;
    let bytesLen = 0;
    for (let i = 0; i < strLen; i++) {
      bytesLen += this.getOneCharByteLength(str[i]);
    }
    return bytesLen;
  }

  /**
   * 获取一个字符的字节长度
   * @param char 一个字符
   * @returns number
   */
  public static getOneCharByteLength(char: string): number {
    if (StringUtil.isEmpty(char)) {
      return 0;
    }
    if (char.length > 1) {
      return StringUtil.strSizeUTF8(char);
    }
    const charCode = char.charCodeAt(0);
    if (charCode <= 0x007f) {
      return 1;
    } else if (charCode <= 0x07ff) {
      return 2;
    } else if (charCode <= 0xffff) {
      return 3;
    } else {
      return 4;
    }
  }

  /**
   * 字符串转字节数组
   * @param str 字符串
   */
  public static stringToUint8Array(str: string): Uint8Array {
    let result = undefined;
    if (this.isEmpty(str)) {
      return result;
    }
    try {
      result = this.getTextEncoder().encodeInto(str);
    } catch (error) {
      HiLog.error(TAG, 'stringToUint8Array fail');
    }
    return result;
  }

  /**
   * 字节数组转字符串
   * @param bytes 字节数组
   */
  public static uint8ArrayToString(bytes: Uint8Array): string {
    let result = '';
    if ((!bytes) || (bytes.length === 0)) {
      return result;
    }

    try {
      result = this.getTextDecoder().decodeWithStream(bytes);
    } catch (error) {
      HiLog.error(TAG, 'uint8ArrayToString fail');
    }
    return result;
  }

  /**
   * 16进制字符串转字节数组
   * @param hexString 16进制字符串
   * @return 字节数组
   */
  public static hexStringToUint8Array(hexString: string): Uint8Array {
    let result: Uint8Array = undefined;
    if (StringUtil.isEmpty(hexString)) {
      return result;
    }
    if ((hexString.length % 2) !== 0) {
      HiLog.error(TAG, 'hexString is not even');
      return result;
    }

    try {
      result = new Uint8Array(buffer.from(hexString, 'hex').buffer);
    } catch (error) {
      HiLog.error(TAG, `hexStringToUint8Array fail, error.code:${error?.code}, error.message:${error?.message}`);
    }
    return result;
  }

  /**
   * 字节数组转16进制字符串
   * @param list 字节数组
   * @return 16进制字符串
   */
  public static uint8ArrayToHexString(bytes: Uint8Array): string {
    let result: string = '';
    if ((!bytes) || (!bytes.length)) {
      return result;
    }
    return buffer.from(bytes).toString('hex');
  }

  /**
   * 字符串转16进制字符串
   * @param str 普通字符串
   * @returns 16进制字符串
   */
  public static stringToHexString(str: string): string {
    if (StringUtil.isEmpty(str)) {
      return '';
    }
    return buffer.from(str, 'utf-8').toString('hex');
  }

  public static stringToArray(str: string): Uint8Array {
    try {
      let textEncoder: util.TextEncoder = util.TextEncoder.create('utf-8');
      return textEncoder.encodeInto(str);
    } catch (err) {
      HiLog.error(TAG, `Text encode error: ${JSON.stringify(err)}}`);
      return new Uint8Array;
    }
  }
}

/**
 * 匿名化函数  字符串匿名处理
 *
 * @param str 需要匿名化的字符串
 * @returns 字符串长度小于等于3 展示首尾字符; 字符串长度在4-8 展示首3个字符,尾2个字符; 字符串大于8,展示首3个字符,尾3个字符
 */
export function maskString(str: string): string {
  if (!str || str.length === 0) {
    return str;
  }
  if (str.length <= 3) {
    return str.substring(0, 1) + '***' + str.substring(str.length - 1);
  } else if (str.length < 9) {
    return str.substring(0, 3) + '***' + str.substring(str.length - 2);
  } else {
    return str.substring(0, 3) + '***' + str.substring(str.length - 3);
  }
}