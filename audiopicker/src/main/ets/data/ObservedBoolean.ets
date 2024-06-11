/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2021-2023. All rights reserved.
 */

/**
 * 可以观察的Boolean
 */
@Observed
export class ObservedBoolean {
  public value: boolean = false;

  constructor(value: boolean = false) {
    this.value = value;
  }

  public setValue(value: boolean) {
    this.value = value;
  }

  public getValue() {
    return this.value;
  }
}