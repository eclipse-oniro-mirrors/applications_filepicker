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

/**
 * Object工具类
 */
export class ObjectUtil {

/**
 * 判断是否为null
 */
  public static isNull<T>(obj: T): boolean {
    return obj === null;
  }
  /**
   * 判断是否为undefined
   * @param obj
   */
  public static isUndefined<T>(obj: T): boolean {
    return obj === undefined;
  }
  /**
   * 判断是否为null 或者 undefined
   * @param obj
   */
  public static isNullOrUndefined<T>(obj: T): boolean {
    return obj === null || obj === undefined;
  }

  /**
   * 返回string，如果是null or undefined返回defaultValue
   */
  public static toString<T>(obj: T, defaultValue: string = ''): string {
    if (this.isNullOrUndefined(obj)) {
      return defaultValue;
    } else {
      return obj.toString();
    }
  }

  /**
   * 判断对象中是否有某个属性
   * @param obj 校验对象
   * @param key 校验属性
   */
  public static hasKey(obj: object, key: string): boolean {
    return Object.prototype.hasOwnProperty.call(obj, key);
  }

  public static empty(): Object {
    return {};
  }

  /**
   * 转数组
   *
   * @param obj 对象
   * @returns 结果
   */
  public static toArray<T>(obj: object): T[] {
    if (ObjectUtil.isNullOrUndefined(obj)) {
      return [];
    }
    if (!Array.isArray(obj)) {
      return [];
    }
    return obj as T[];
  }
}