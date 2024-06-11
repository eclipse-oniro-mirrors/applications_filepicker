/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2021-2023. All rights reserved.
 */

/**
 * [ObservedArray可观察的数组] <BR>
 *
 * @Author: lWX927629
 * @Date: 2024/3/7
 * @Version: V1.0.71
 */

@Observed
export class ObservedArray<T> extends Array<T> {
  constructor(args?: T[]) {
    if (args instanceof Array) {
      super(...args);
    } else {
      super();
    }
  }
}