/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2021-2023. All rights reserved.
 */
import { ObservedArray } from '../data/ObservedArray';
import { ViewState } from './ViewState';

/**
 * [AbsBaseViewModel]<BR>
 *
 * @Author: lWX927629
 * @Date: 2024/3/7
 * @Version: V1.0.71
 */

export abstract class  AbsBaseViewModel<VD> {
  protected abstract getState() : ViewState
  protected abstract getData() : ObservedArray<VD>;
}