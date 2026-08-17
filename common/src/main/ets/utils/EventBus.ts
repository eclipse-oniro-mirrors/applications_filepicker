/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
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

import { HiLog } from '../dfx/HiLog';
import { ArrayUtil } from './ArrayUtil';
import { ObjectUtil } from './ObjectUtil';

const TAG = 'EventBus';

class CallBackObj {
  fun: Function = () => {};
  isOnce: boolean = false;
}

class EventObj {
  funList: Array<CallBackObj> = [];
  isOnlyRunLastFun: boolean = false;

  constructor() {
    this.funList = [];
    this.isOnlyRunLastFun = false;
  }
}

/***
 * 事件监听和派发工具
 */
export class EventBus {
  private static eventMap = new Map<string, EventObj>();
  private static emitDelayTimerMap = new Map<string, number>();

  /**
   * 派发事件
   * @param event 事件名
   * @param argument 需要传给回调函数的参数
   */
  public static emit(event: string, ...argument): void {
    HiLog.info(TAG, 'emit event:' + event);
    const eventObj = this.eventMap.get(event);
    if (ObjectUtil.isNullOrUndefined(eventObj) || ArrayUtil.isEmpty(eventObj.funList)) {
      HiLog.error(TAG, 'emit event failed, obj is null or funList is empty, event is ' + event);
      return;
    }
    let onceCallbackIndexList: Array<number> = [];
    if (eventObj.isOnlyRunLastFun) {
      const lastIndex = eventObj.funList.length - 1;
      const callBackObj = eventObj.funList[lastIndex];
      callBackObj.fun.apply(this, argument);
      if (callBackObj.isOnce) {
        onceCallbackIndexList.push(lastIndex);
      }
    } else {
      HiLog.info(TAG, 'emit event :' + event + ', funList len = ' + eventObj.funList.length);
      eventObj.funList.forEach((callBackObj: CallBackObj, index: number) => {
        callBackObj.fun.apply(this, argument);
        if (callBackObj.isOnce) {
          onceCallbackIndexList.push(index);
        }
      });
    }
    if (ArrayUtil.isEmpty(onceCallbackIndexList)) {
      return;
    }
    // 移除只需触发一次的回调
    onceCallbackIndexList.forEach((index: number) => {
      eventObj.funList.splice(index, 1);
    });
    this.eventMap.set(event, eventObj);
  }

  /**
   * 监听事件
   * @param event 事件名
   * @param callback 回调函数
   * @param isOnlyRunLastFun 标记该事件只需触发最后一个回调
   */
  public static on(event: string, callback: Function, isOnlyRunLastFun: boolean = false): void {
    HiLog.info(TAG, 'on event:' + event);
    let eventObj = this.eventMap.get(event);
    if (ObjectUtil.isNullOrUndefined(eventObj)) {
      eventObj = new EventObj();
    } else {
      let callbackIndex = eventObj.funList.findIndex((value) => value.fun === callback);
      HiLog.info(TAG, `on event: ${event} callback findIndex:${callbackIndex} len:${eventObj.funList.length}`);
      if (callbackIndex >= 0) {
        if (isOnlyRunLastFun) {
          eventObj.funList.splice(callbackIndex, 1);
        } else {
          return;
        }
      }
    }
    // 标记该事件只需触发最后一个回调
    eventObj.isOnlyRunLastFun = isOnlyRunLastFun;
    const callBackObj = new CallBackObj();
    callBackObj.fun = callback;
    eventObj.funList.push(callBackObj);
    this.eventMap.set(event, eventObj);
  }

  /**
   * 仅监听一次事件
   * @param event
   * @param callback
   */
  public static once(event: string, callback: Function): void {
    HiLog.info(TAG, 'once event:' + event);
    let eventObj = this.eventMap.get(event);
    if (ObjectUtil.isNullOrUndefined(eventObj)) {
      eventObj = new EventObj();
    }
    const callBackObj = new CallBackObj();
    callBackObj.fun = callback;
    // 标记该回调只需触发一次
    callBackObj.isOnce = true;
    eventObj.funList.push(callBackObj);
    this.eventMap.set(event, eventObj);
  }

  /**
   * 取消事件监听
   * @param event 事件名
   * @param callback 回调函数
   */
  public static off(event: string, callback: Function = undefined): void {
    HiLog.info(TAG, 'off event:' + event);
    let eventObj = this.eventMap.get(event);
    if (ObjectUtil.isNullOrUndefined(eventObj) || ArrayUtil.isEmpty(eventObj.funList)) {
      return;
    }
    // 如果没有指定要取消哪个回调，则全部取消
    if (ObjectUtil.isNullOrUndefined(callback)) {
      this.eventMap.delete(event);
      return;
    }
    const index = eventObj.funList.findIndex((item: CallBackObj) => item.fun === callback);
    if (index === -1) {
      return;
    }
    if (eventObj.funList.length === 1) {
      this.eventMap.delete(event);
    } else {
      eventObj.funList.splice(index, 1);
      this.eventMap.set(event, eventObj);
    }
  }

  /**
   * 延迟派发事件
   */
  public static emitDelay(timeout: number, event: string, ...argument): void {
    const timerId = setTimeout(() => {
      this.emit(event, argument);
    }, timeout);
    this.emitDelayTimerMap.set(event, timerId);
  }

  /**
   * 移出某个事件的分发；和延迟事件分发配套使用，防止延迟事件堆积
   */
  public static removeEmit(event: string): void {
    const timerId = this.emitDelayTimerMap.get(event);
    if (!ObjectUtil.isNullOrUndefined(timerId)) {
      clearTimeout(timerId);
    }
    this.emitDelayTimerMap.delete(event);
  }

  /**
   * 是否存在某事件
   */
  public static hasEvent(eventName: string): boolean {
    return this.eventMap.has(eventName);
  }
}
