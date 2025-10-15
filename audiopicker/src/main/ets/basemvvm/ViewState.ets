/*
 * Copyright (c) 2021-2023 Huawei Device Co., Ltd.
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