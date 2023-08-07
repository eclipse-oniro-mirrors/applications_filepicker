/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023. All rights reserved.
 */

/**
 * Object工具类
 */
namespace ObjectUtil {

/**
 * 判断是否为null
 */
  export function isNull(obj: any): boolean {
    return obj === null;
  }
  /**
   * 判断是否为undefined
   * @param obj
   */
  export function isUndefined(obj: any): boolean {
    return obj === undefined;
  }
  /**
   * 判断是否为null 或者 undefined
   * @param obj
   */
  export function isNullOrUndefined(obj: any): boolean {
    return isNull(obj) || isUndefined(obj);
  }

  /**
   * 返回string，如果是null or undefined返回defaultValue
   */
  export function toString(obj: any, defaultValue: string = ''): string {
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
  export function hasKey(obj: object, key: string): boolean {
    return Object.prototype.hasOwnProperty.call(obj, key);
  }
}

export default ObjectUtil;