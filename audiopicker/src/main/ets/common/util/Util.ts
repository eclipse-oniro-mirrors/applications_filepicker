/*
* Copyright (c) Huawei Technologies Co., Ltd. 2021-2024. All rights reserved.
*/

import util from '@ohos.util'

/**
 * [处理工具类]
 */
export class Util {
  /**
   * 判断是否为空值
   * @param value 数值
   * @returns
   */
  static isEmpty(value: string | null | undefined): boolean {
    return value === null || value === undefined || value.length === 0
  }

  static systemUUid(): string {
    return util.generateRandomUUID(true).toUpperCase();
  }

  static uuid(len?: number, radix?: number): string {
    let chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('');
    let uuids: Array<string> = [];
    let i: number;
    radix = radix || chars.length;

    if (len) {
      // Compact form
      for (i = 0; i < len; i++) {
        uuids[i] = chars[0 | Math.random() * radix];
      }
    } else {
      // rfc4122, version 4 form
      let r: number;
      // rfc4122 requires these characters
      uuids[8] = uuids[13] = uuids[18] = uuids[23] = '-';
      uuids[14] = '4';

      // Fill in random data. At i==19 set the high bits of clock sequence as
      // per rfc4122, sec. 4.1.5
      for (i = 0; i < 36; i++) {
        if (!uuids[i]) {
          r = 0 | Math.random() * 16;
          uuids[i] = chars[(i === 19) ? (r & 0x3) | 0x8 : r];
        }
      }
    }
    return uuids.join('');
  }

  /**
   * 只能拷贝简单格式，正则之类的拷贝不了
   *
   * @param obj 原始对象
   * @return cloned obj
   */
  static deepClone(obj): any {
    let copy
    if (null === obj || "object" !== typeof obj) {
      return obj;
    }
    if (obj instanceof Array) {
      copy = []
      for (let i = 0, len = obj.length; i < len; i++) {
        copy[i] = Util.deepClone(obj[i])
      }
      return copy
    }
    if (obj instanceof Object) {
      copy = {}
      for (let attr in obj) {
        if (Object.prototype.hasOwnProperty.call(obj, attr)) {
          copy[attr] = Util.deepClone(obj[attr])
        }
      }
    }
    return copy
  }

  /**
   * 立即执行函数，delay时间段内不再执行
   *
   * @param fn 函数
   * @param delay 时间毫秒
   * @returns
   */
  static debounceImmediate(fn, delay): () => void {
    let debounceTimer = null

    return function (...args): void {
      if (debounceTimer !== null) {
        return
      }
      fn.apply(this, args)
      debounceTimer = setTimeout(() => {
        debounceTimer = null
      }, delay)
    }
  }
}
