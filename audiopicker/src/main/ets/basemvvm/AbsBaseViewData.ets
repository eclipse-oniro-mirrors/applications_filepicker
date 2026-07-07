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
import { ObservedArray } from '../data/ObservedArray';
import { BaseState, ViewState } from './ViewState';

/**
 *
 * @param <VS> 页面状态
 * @param <VD> 页面数据
 */
export abstract class AbsBaseViewData<VS extends ViewState, VD> implements IDataSource {

  private listeners: DataChangeListener[] = []
  /**
   * view state
   */
  private state: VS;
  /**
   * view live date list
   */
  private liveData: ObservedArray<VD> = new ObservedArray<VD>();

  /**
   * 构造函数
   */
  protected constructor() {
    this.state = this.initViewState();
  }

  totalCount(): number {
    return this.liveData.length
  }

  registerDataChangeListener(listener: DataChangeListener) {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1)
    }
  }

  public getData(index: number): VD {
    return this.liveData[index]
  }

  private initViewState(): VS {
    return this.createViewState();
  }

  protected abstract createViewState(): VS;

  public getState(): VS {
    return this.state;
  }

  /**
   * start loading
   */
  public loading(): void {
    if (this.isEmpty()) {
      this.state?.setViewState(BaseState.LOADING);
    }
  }

  public normal(newData: ObservedArray<VD>): void {
    this.clear()
    this.liveData.push(...newData);
    this.notifyDataReload()
    this.state.setViewState(BaseState.NORMAL);
  }

  /**
   * finish loading without data
   */
  public normalState(): void {
    this.state?.setViewState(BaseState.NORMAL);
  }

  /**
   * clear livedata
   */
  public clear(): void {
    this.liveData.splice(0, this.liveData?.length)
  }

  /**
   * 获取列表数据，不可变
   *
   * @return 不可变列表数据，运行时放通，问题在开发阶段发现问题
   */
  public getDataList(): ObservedArray<VD> {
    return this.liveData;
  }

  /**
   * 针对分页的数据，不要使用normal，直接使用append
   *
   * @param appendData 需要追加的数据
   */
  public append(appendData: VD[]): void {
    this.liveData.push(...appendData);
    this.notifyDataReload()
    this.state.setViewState(BaseState.NORMAL);
  }

  /**
   * 针对分页的数据，不要使用normal，直接使用append
   * @param index index
   * @param appendData 需要追加的数据
   */
  public appendByIndex(index: number, appendData: VD[]): void {
    this.liveData.splice(index, 0, ...appendData);
    this.notifyDataAdd(index);
    this.notifyDataReload()
    this.state.setViewState(BaseState.NORMAL);
  }

  /**
   * finish loading without data (only one data)
   *
   * @param newData newData
   */
  public appendSingle(newData: VD): void {
    this.liveData.push(newData);
    this.state.setViewState(BaseState.NORMAL);
  }

  /**
   * 移除
   *
   * @param index 位置
   */
  public remove(index: number): void {
    this.liveData.splice(index, 1)
    this.notifyDataDelete(index)
    this.notifyDataReload()
  }

  /**
   * 设置数据是否为空，涉及nodata页面展示
   *
   * @return 数据是否为空
   */
  public isEmpty(): boolean {
    return this.liveData.length === 0;
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded()
    })
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index)
    })
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index)
    })
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index)
    })
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to)
    })
  }
}