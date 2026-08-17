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

import CommonEvent from '@ohos.commonEvent';
import type { BusinessError } from '@ohos.base';
import type CommonEventManager from '@ohos.commonEventManager';
import { HiLog } from '../dfx/HiLog';
import { EventBus } from '../utils/EventBus';
import { Constant } from '../const/Constant';
import { LanguageUtil } from '../utils/LanguageUtil';
import { SortUtil } from '../utils/SortUtil';

const TAG = 'AccountManager';

/**
 * 账号管理工具类
 * 提供监听账号登录退出事件
 */
export class AccountManager {
  /**
   * 工具类实例
   */
  private static instance: AccountManager = new AccountManager();

  private readonly events = [
    CommonEvent.Support.COMMON_EVENT_HWID_LOGIN,
    CommonEvent.Support.COMMON_EVENT_HWID_LOGOUT,
    CommonEvent.Support.COMMON_EVENT_LOCALE_CHANGED
  ];

  /**
   * 是否已经注册账号状态变化监听
   */
  private isSubscribed: boolean = false;

  /**
   * 账号状态变化公共事件监听器
   */
  private subscriber?: CommonEventManager.CommonEventSubscriber;

  constructor() {
  }

  /**
   * 工具类实例
   * @returns
   */
  static getInstance(): AccountManager {
    return AccountManager.instance;
  }

  /**
   * 监听存储设备挂载和移除的公共事件
   */
  async subscribeAccountChangeEvent(): Promise<void> {
    HiLog.info(TAG, 'subscribeAccountChangeEvent start');
    try {
      if (this.isSubscribed) {
        HiLog.info(TAG, 'subscribeAccountChangeEvent has executed');
        return;
      }
      if (!this.subscriber) {
        HiLog.warn(TAG, 'subscriber is null');
        await this.createSubscriber();
      }
      let subscribeCallback = async (err: BusinessError, data: CommonEventManager.CommonEventData): Promise<void> => {
        HiLog.info(TAG, 'accountChangeCallBack eventData.event = ' + data.event);
        this.accountChangeCallBack(err, data);
      };
      // 订阅公共事件
      CommonEvent.subscribe(this.subscriber, subscribeCallback);
      this.isSubscribed = true;
      HiLog.info(TAG, 'subscribeAccountChangeEvent success');
    } catch (error) {
      HiLog.error(TAG, 'subscribeAccountChangeEvent fail, error: ' + JSON.stringify(error));
    }
  }

  /**
   * 账号登录状态变化回调
   */
  private accountChangeCallBack(error: BusinessError, eventData: CommonEventManager.CommonEventData): void {
    if (error.code) {
      HiLog.error(TAG, 'accountChangeCallBack fail: ' + JSON.stringify(error));
      return;
    }

    switch (eventData.event) {
      case CommonEvent.Support.COMMON_EVENT_HWID_LOGIN:
        HiLog.info(TAG, 'accountChangeCallBack account login');
        AppStorage.setOrCreate<boolean>('isAccountLogin', true);
        EventBus.emit(Constant.EVENTS.ACCOUNT_LOGIN);
        break;
      case CommonEvent.Support.COMMON_EVENT_HWID_LOGOUT:
        HiLog.info(TAG, 'accountChangeCallBack account logout');
        AppStorage.setOrCreate<boolean>('isAccountLogin', false);
        EventBus.emit(Constant.EVENTS.ACCOUNT_LOGOUT);
        break;
      case CommonEvent.Support.COMMON_EVENT_LOCALE_CHANGED:
        HiLog.info(TAG, 'accountChangeCallBack language changed');
        LanguageUtil.updateSystemLanguage();
        SortUtil.updateCollator();
        break;
      default:
        break;
    }
  }

  /**
   * 创建公共事件订阅者
   */
  private async createSubscriber(): Promise<void> {
    const subscribeInfo = new SubscribeInfo(this.events);
    try {
      this.subscriber = await CommonEvent.createSubscriber(subscribeInfo);
    } catch (error) {
      HiLog.error(TAG, 'createSubscriber error:' + JSON.stringify(error));
    }
  }
}

class SubscribeInfo {
  public events: CommonEvent.Support[]

  constructor(events: CommonEvent.Support[]) {
    this.events = events;
  }
}