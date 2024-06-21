/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { LocalAudioFile } from '../../localresource/localaudio/LocalAudioFile'
import { AbsBaseViewData } from '../../basemvvm/AbsBaseViewData'
import { BaseState, ViewState } from '../../basemvvm/ViewState'

/**
 * [audioPicker页面 viewData]
 */
@Observed
export class AudioPickerViewData extends AbsBaseViewData<ViewState, LocalAudioFile> {
  // 页面加载状态
  public viewState: ViewState = new ViewState(BaseState.DEFAULT)
  // 页面错误码
  public errCode: number = -2
  // 是否加载更多
  public hasMoreData: boolean = false
  // 是否正在加载更多
  public isLoadMore: boolean = false

  constructor() {
    super()
  }

  /**
   * 初始化页面状态为DEFAULT
   * @returns
   */
  protected createViewState(): ViewState {
    return new ViewState(BaseState.DEFAULT)
  }

  getViewState() {
    return this.viewState
  }

  setViewState(state: BaseState) {
    if (this.viewState.baseState === state) {
      return
    }
    this.viewState.setViewState(state)
  }
}