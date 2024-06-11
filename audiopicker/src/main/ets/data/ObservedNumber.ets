/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2021-2023. All rights reserved.
 */

/**
 * 可以观察的Number
 */
@Observed
export class ObservedNumber {
  public value: number = 0;

  constructor(value: number = 0) {
    this.value = value;
  }

  public setValue(value: number) {
    this.value = value;
  }

  public getValue() {
    return this.value;
  }
}