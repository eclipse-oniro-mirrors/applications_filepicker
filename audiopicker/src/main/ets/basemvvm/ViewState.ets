/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2021-2023. All rights reserved.
 */

/**
 * [页面状态]<BR>
 */

export enum BaseState {
  // 初始状态
  DEFAULT,

  // 渲染中
  LOADING,

  // 渲染失败
  ERROR,

  // 渲染完成
  NORMAL
}

@Observed
export class ViewState {
  public baseState: BaseState = BaseState.DEFAULT

  constructor(baseState: BaseState = BaseState.DEFAULT) {
    this.baseState = baseState
  }

  setViewState(baseState: BaseState) {
    this.baseState = baseState
  }

  getViewState() {
    return this.baseState;
  }

  isLoading(): boolean {
    return this.baseState === BaseState.LOADING ? true : false
  }

  isDefault(): boolean {
    return this.baseState === BaseState.DEFAULT ? true : false
  }

  isNormal(): boolean {
    return this.baseState === BaseState.NORMAL ? true : false
  }

  isError(): boolean {
    return this.baseState === BaseState.ERROR ? true : false
  }
}