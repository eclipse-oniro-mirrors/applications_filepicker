/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023. All rights reserved.
 */

import ObjectUtil from "./ObjectUtil"

/**
 * 字符串工具类
 */
export class ArrayUtil {
  public static readonly INDEX_INVALID: number = -1;

  /**
   * 判断array是否为空
   *
   * @param collection collection
   * @return boolean
   */
  public static isEmpty<T>(array: T[]): boolean {
    if (ObjectUtil.isNullOrUndefined(array)) {
      return true;
    }
    return array.length === 0;
  }

  /**
   * 判断array是否包含item
   *
   * @param array
   * @param item
   */
  public static contains<T>(array: T[], item: T): boolean {
    if (this.isEmpty(array) || ObjectUtil.isNullOrUndefined(item)) {
      return false;
    }
    return array.indexOf(item) !== this.INDEX_INVALID;
  }

  /**
   * 查找 array 中最大值
   * @param array
   */
  public static max(array: number[]): number {
    return Math.max.apply(null, array);
  }

  /**
   * 查找 array 中最小值
   * @param array
   */
  public static min(array: number[]): number {
    return Math.min.apply(null, array);
  }
}
