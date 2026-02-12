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
import notificationManager from '@ohos.notificationManager';
import { common } from '@kit.AbilityKit';
import wantAgent, { WantAgent } from '@ohos.app.ability.wantAgent';
import { HiLog, CommonPreferenceUtil, GlobalHolder, AppConfig } from '@ohos/common';
import { BaseParam } from './NotificationConst';

const TAG = 'NotificationUtil';

/**
 * 通知栏消息工具类
 */
export class NotificationUtil {
  /**
   * 获取系统设置中文管的通知栏状态
   */
  public static async getNotificationStatus(): Promise<boolean> {
    try {
      let isEnabled: boolean = await notificationManager.isNotificationEnabled();
      HiLog.info(TAG, 'checkNotificationStatus isEnable:' + isEnabled);
      return isEnabled;
    } catch (error) {
      HiLog.error(TAG, 'check notification status fail, error:' + JSON.stringify(error));
      return false;
    }
  }

  /**
   * 发送通知
   * @param notificationRequest 要发送通知的请求体
   * @returns 是否发送成功
   */
  public static async publish(notificationRequest: notificationManager.NotificationRequest): Promise<boolean> {
    try {
      await notificationManager.publish(notificationRequest);
    } catch (error) {
      HiLog.error(TAG, 'send notification fail, error:' + JSON.stringify(error));
      return false;
    }
    return true;
  }

  /**
   * 检查是否需要弹窗获取通知栏授权
   */
  public static async checkNotificationStatus(): Promise<void> {
    HiLog.info(TAG, 'check notification dialog record');
    // 读取本地设置
    const isNotificationSet: boolean | undefined = await CommonPreferenceUtil.getPreferenceNotifyStatus();
    if (isNotificationSet !== undefined) {
      return;
    }
    // 查询系统设置
    const isEnabled: boolean = await NotificationUtil.getNotificationStatus();
    if (isEnabled) {
      CommonPreferenceUtil.setNotifyStatus(true);
    } else {
      NotificationUtil.requestEnableNotification();
    }
  }

  /**
   * 取消指定事件的通知栏消息
   * @param notificationId 通知事件的id
   * @returns 是否取消成功
   */
  public static async cancel(notificationId: number): Promise<boolean> {
    try {
      await notificationManager.cancel(notificationId);
    } catch (error) {
      HiLog.info(TAG,
        'cancel notification fail, notificationId: ' + notificationId + ', error:' + JSON.stringify(error) + error);
      return false;
    }
    return true;
  }

  /**
   * 取消所有通知栏消息
   * @returns 是否取消成功
   */
  public static async cancelAll(): Promise<boolean> {
    try {
      await notificationManager.cancelAll();
    } catch (error) {
      HiLog.info(TAG, 'cancelAll notification fail, error:' + JSON.stringify(error) + error);
      return false;
    }
    return true;
  }

  /**
   * 创建点击通知栏里消息后拉起应用时需要的WantAgent实例
   * @param param 拉起应用时需要携带的参数
   * @returns
   */
  public static async createStartAbilityWantAgent(param: BaseParam): Promise<WantAgent | undefined> {
    let result: WantAgent | undefined = undefined;
    try {
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: AppConfig.APP_PACKAGE_NAME,
            abilityName: 'EntryAbility',
            parameters: {
              param: param
            }
          }
        ],
        actionType: wantAgent.OperationType.START_ABILITY,
        requestCode: 0,
        wantAgentFlags: [wantAgent.WantAgentFlags.CONSTANT_FLAG]
      };
      result = await wantAgent.getWantAgent(wantAgentInfo);
    } catch (error) {
      HiLog.error(TAG, 'getWantAgent fail, error:' + JSON.stringify(error) + error);
    }
    return result;
  }

  /**
   * 请求通知栏授权
   */
  public static requestEnableNotification(): void {
    const context: common.UIAbilityContext =
      GlobalHolder.getInstance().getMainAbilityContext() as common.UIAbilityContext;
    let requestEnableNotificationCallback = (err: BusinessError): void => {
      if (err) {
        HiLog.error(TAG, `requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
        // 不允许
        CommonPreferenceUtil.setNotifyStatus(false);
      } else {
        HiLog.info(TAG, `requestEnableNotification success`);
        // 允许
        CommonPreferenceUtil.setNotifyStatus(true);
      }
    };
    try {
      notificationManager.requestEnableNotification(context, requestEnableNotificationCallback);
    } catch (error) {
      HiLog.error(TAG, 'request enable notification fail, error:' + JSON.stringify(error));
    }
  }
}