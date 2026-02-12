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
import { HiLog, GlobalHolder, ResourceUtil } from '@ohos/common';
import { NotificationConst } from './NotificationConst';
import { NotificationUtil } from './NotificationUtil';
import { notificationManager } from '@kit.NotificationKit';
import {
  CopyCutCompleteData,
  CopyCutExceptionData,
  CopyCutProgressData,
  CopyCutProgressType
} from '../extension/model/SendDataModel';
import { OpenFolderParam, StartAbilityFrom } from './NotificationConst';
import { image } from '@kit.ImageKit';
import { CopyCutManager } from '../manager/CopyCutManager';

const TAG = 'CopyCutNotificationUtil';

/**
 * 复制移动时的通知栏消息
 */
export class CopyCutNotificationUtil {
  // 实况胶囊button功能名称
  private static readonly CANCEL_COPY_CUT: string = 'cancel_copy_cut';
  // 实况胶囊图标大小24vp
  private static readonly CAPSULE_ICON_SIZE: number = 24;
  // 进度最大值
  private static readonly MAX_PROGRESS_VALUE: number = 100;
  // 实况胶囊样式模板，8 表示上传下载模板
  private static readonly LIVE_VIEW_TYPE_CODE: number = 8;
  // 实况胶囊样式模板，16 表示普通模板
  private static readonly NORMAL_TYPE_CODE: number = 16;
  private static isSubscribe: boolean = false;
  // capsule 图标
  private static capsuleIcon: image.PixelMap | undefined = undefined;
  // capsule 背景色
  private static capsuleBackgroundColor: string | undefined = undefined;
  // 保存上一次发送的进度值，防止进度回退
  private static lastProgress: number = -1;
  // 发送锁，确保通知按顺序发送
  private static sendLock: boolean = false;
  // 是否禁止发送进度通知
  private static disableProgressNotification: boolean = false;

  public static resetState(): void {
    CopyCutNotificationUtil.lastProgress = -1;
    CopyCutNotificationUtil.sendLock = false;
    CopyCutNotificationUtil.disableProgressNotification = false;
  }
  
  public static disableProgressNotifications(): void {
    CopyCutNotificationUtil.disableProgressNotification = true;
  }

  private static initCapsuleIconAndBackgroundColor(): void {
    if (CopyCutNotificationUtil.capsuleIcon && CopyCutNotificationUtil.capsuleBackgroundColor) {
      return;
    }
    try {
      HiLog.warn(TAG, `init capsule icon and background color begin!`);
      CopyCutNotificationUtil.capsuleIcon = GlobalHolder.getInstance()
        .getAppContext()
        .resourceManager
        .getDrawableDescriptor($r('app.media.app_icon'))
        .getPixelMap();
      CopyCutNotificationUtil.capsuleBackgroundColor = GlobalHolder.getInstance()
        .getAppContext()
        .resourceManager
        .getColorSync($r('sys.color.background_emphasize'))
        .toString();
      const iconWidth: number = CopyCutNotificationUtil.capsuleIcon.getImageInfoSync().size.width;
      const iconHeight: number = CopyCutNotificationUtil.capsuleIcon.getImageInfoSync().size.height;
      if (!iconWidth || !iconHeight) {
        HiLog.error(TAG, `The capsule icon size is error!`);
        return;
      }
      const scaleX: number = CopyCutNotificationUtil.CAPSULE_ICON_SIZE / px2vp(iconWidth);
      const scaleY: number = CopyCutNotificationUtil.CAPSULE_ICON_SIZE / px2vp(iconHeight);
      // 缩放到24*24vp 这样实况窗会自动裁切图标为圆形
      CopyCutNotificationUtil.capsuleIcon.scaleSync(scaleX, scaleY);
    } catch (error) {
      HiLog.error(TAG, `The capsule icon scale failed! error: ${JSON.stringify(error)}`);
    } finally {
      HiLog.warn(TAG, `init capsule icon and background color end!`);
    }
  }

  // 按钮回调(用户点击按钮，会返回这个回调，业务自己决定如何处理) 系统实况窗订阅者对象，处理处于点击通知按钮的回调，点击取消时调用
  private static systemLiveViewSubscriber: notificationManager.SystemLiveViewSubscriber = {
    onResponse: (id: number, option: notificationManager.ButtonOptions) => {
      HiLog.info(TAG, `response callback: ${option.buttonName}, notificationId: ${id}`);
      switch (option.buttonName) {
        case CopyCutNotificationUtil.CANCEL_COPY_CUT:
          CopyCutManager.getInstance()?.cancelWorker();
          break;
        default:
          break;
      }
    }
  };

  /**
   * 发送复制移动的进度通知
   * @param folderUri 点通知栏后需要打开的目标目录
   * @param progress 复制移动的进度百分比
   * @param deliveryTime 开始发送进度通知的时间
   * @param folderName 正在进行操作的文件名
   * @returns 是否发送成功
   */
  public static async publishProgressNotification(progressData: CopyCutProgressData, title: string): Promise<boolean> {
    // 检查是否禁止发送进度通知
    if (CopyCutNotificationUtil.disableProgressNotification) {
      HiLog.info(TAG, 'Progress notifications are disabled, skipping');
      return false;
    }
    
    // 等待锁释放，使用异步让出控制权
    let waitCount = 0;
    while (CopyCutNotificationUtil.sendLock && waitCount < 100) {
      // 让出控制权，允许其他异步任务执行
      await new Promise<void>((resolve) => {
        // 使用setInterval实现异步延迟
        let intervalId = setInterval(() => {
          clearInterval(intervalId);
          resolve();
        }, 1);
      });
      waitCount++;
    }
    
    // 再次检查是否禁止发送进度通知
    if (CopyCutNotificationUtil.disableProgressNotification) {
      HiLog.info(TAG, 'Progress notifications are disabled, skipping');
      return false;
    }
    
    // 如果锁仍然被持有，跳过这次通知
    if (CopyCutNotificationUtil.sendLock) {
      HiLog.warn(TAG, 'Send lock is still held, skipping notification');
      return false;
    }
    
    // 获取锁
    CopyCutNotificationUtil.sendLock = true;
    
    try {
      // 再次检查是否禁止发送进度通知
      if (CopyCutNotificationUtil.disableProgressNotification) {
        HiLog.info(TAG, 'Progress notifications are disabled, skipping');
        return false;
      }
      
      // 检查进度是否回退，如果回退则不发送通知
      if (progressData.progress < CopyCutNotificationUtil.lastProgress) {
        HiLog.error(TAG, `Progress backtrack detected, lastProgress: ${CopyCutNotificationUtil.lastProgress}, currentProgress: ${progressData.progress}`);
        return false;
      }
      
      HiLog.info(TAG, 'sendProgressNotification start');
      // 发布通知,确认UX后可替换为 getLiveViewProgressNotificationRequest
      const notificationRequest: notificationManager.NotificationRequest =
        await CopyCutNotificationUtil.getLiveViewProgressNotificationRequest(progressData, title);
      
      // 再次检查是否禁止发送进度通知
      if (CopyCutNotificationUtil.disableProgressNotification) {
        HiLog.info(TAG, 'Progress notifications are disabled, skipping');
        return false;
      }
      
      const result = await NotificationUtil.publish(notificationRequest);
      
      // 更新上一次发送的进度值
      if (result) {
        CopyCutNotificationUtil.lastProgress = progressData.progress;
      }
      
      HiLog.info(TAG, 'sendProgressNotification end : ' + result);
      return result;
    } catch (error) {
      HiLog.error(TAG, 'sendProgressNotification fail, error:' + JSON.stringify(error) + error);
      return false;
    } finally {
      // 释放锁
      CopyCutNotificationUtil.sendLock = false;
    }
  }

  // 构建进度通知请求对象
  private static async getLiveViewProgressNotificationRequest(progressData: CopyCutProgressData,
    title: string): Promise<notificationManager.NotificationRequest> {
    const param = new OpenFolderParam(progressData.folderUri, [], StartAbilityFrom.COPY_CUT_NOTIFICATION);
    const wantAgentObj = await NotificationUtil.createStartAbilityWantAgent(param);

    CopyCutNotificationUtil.initCapsuleIconAndBackgroundColor();
    const liveViewNotificationRequest: notificationManager.NotificationRequest = {
      notificationSlotType: notificationManager.SlotType.LIVE_VIEW,
      groupName: NotificationConst.NotificationGroup.FILE_OPERATE,
      wantAgent: wantAgentObj,
      deliveryTime: progressData.deliveryTime,
      id: NotificationConst.NotificationId.COPY_CUT_RUNNING,
      isUnremovable: false,  // 允许移除，以便完成时可以取消
      isRemoveAllowed: true,  // 允许移除
      tapDismissed: false,
      extraInfo: {
        // 应用在前台时显示实况胶囊
        hw_capsule_sticky: true
      },
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_SYSTEM_LIVE_VIEW,
        systemLiveView: {
          title: title,
          text: progressData.operatingFileName,
          typeCode: CopyCutNotificationUtil.LIVE_VIEW_TYPE_CODE,
          button: {
            names: [CopyCutNotificationUtil.CANCEL_COPY_CUT],
            iconsResource: [$r('app.media.notification_cross')]
          },
          capsule: {
            title: title,
            icon: CopyCutNotificationUtil.capsuleIcon,
            backgroundColor: CopyCutNotificationUtil.capsuleBackgroundColor,
          },
          progress: {
            maxValue: CopyCutNotificationUtil.MAX_PROGRESS_VALUE,
            currentValue: Number(progressData.progress.toFixed(2)),
            isPercentage: true
          }
        }
      }
    };

    await CopyCutNotificationUtil.subscribeSystemLiveView(CopyCutNotificationUtil.systemLiveViewSubscriber);

    return liveViewNotificationRequest;
  }

  // 订阅系统实况窗事件
  private static async subscribeSystemLiveView(subscriber: notificationManager.SystemLiveViewSubscriber) {
    if (CopyCutNotificationUtil.isSubscribe) {
      return;
    }
    try {
      HiLog.info(TAG, `subscribeSystemLiveView`);
      // 订阅系统实况窗(按钮)
      await notificationManager.subscribeSystemLiveView(subscriber);
      CopyCutNotificationUtil.isSubscribe = true;
    } catch (error) {
      HiLog.error(TAG, 'subscribeSystemLiveView fail, error:' + JSON.stringify(error));
    }
  }

  /**
   * 发送复制移动完成的通知
   * @param folderUri 点通知栏后需要打开的目标目录
   * @param title 通知栏消息的标题
   * @param text 通知栏消息的内容
   * @param isCancel 是否因为操作被取消结束的
   * @returns
   */
  public static async publishCompleteNotification(completeData: CopyCutCompleteData): Promise<boolean> {
    let result = false;
    try {
      HiLog.info(TAG, 'sendCompleteNotification start');
      const notificationRequest: notificationManager.NotificationRequest =
        await CopyCutNotificationUtil.getLiveViewCompleteNotificationRequest(completeData);
      result = await NotificationUtil.publish(notificationRequest);
      HiLog.info(TAG, 'sendCompleteNotification end');
    } catch (error) {
      HiLog.error(TAG, 'sendCompleteNotification fail, error:' + JSON.stringify(error) + error);
    }
    return result;
  }

  // 根据操作类型和结果生成通知标题
  private static getCompleteNotificationTitle(completeData: CopyCutCompleteData): string {
    let operateType: CopyCutProgressType | undefined = completeData.operateType;
    let titleResource: Resource = $r('app.string.EntryAbility_label');
    if (completeData.isCancel) {
      if (operateType === CopyCutProgressType.COPY) {
        titleResource = $r('app.plural.copying_notification_title');
      } else if (operateType === CopyCutProgressType.MOVE) {
        titleResource = $r('app.plural.moving_notification_title');
      }
    } else {
      if (operateType === CopyCutProgressType.COPY) {
        titleResource = $r('app.plural.copy_complete_notification_title');
      } else if (operateType === CopyCutProgressType.MOVE) {
        titleResource = $r('app.plural.move_complete_notification_title');
      }
    }
    return ResourceUtil.getPluralStringValue(titleResource, completeData.selectCount ?? 1,
      completeData.selectCount ?? 1, completeData.destFolderName ?? '');
  }

  // 构建完成通知请求对象
  private static async getLiveViewCompleteNotificationRequest(
    completeData: CopyCutCompleteData): Promise<notificationManager.NotificationRequest> {
    const param: OpenFolderParam =
      new OpenFolderParam(completeData.folderUri, [], StartAbilityFrom.COPY_CUT_NOTIFICATION);
    const wantAgentObj = await NotificationUtil.createStartAbilityWantAgent(param);

    const liveViewNotificationRequest: notificationManager.NotificationRequest = {
      notificationSlotType: notificationManager.SlotType.SERVICE_INFORMATION,
      groupName: NotificationConst.NotificationGroup.FILE_OPERATE,
      wantAgent: wantAgentObj,
      id: NotificationConst.NotificationId.COPY_CUT_END,
      isUnremovable: false,
      isRemoveAllowed: true,
      tapDismissed: true,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: CopyCutNotificationUtil.getCompleteNotificationTitle(completeData),
          text: completeData.isCancel ? ResourceUtil.getStringByResource($r('app.string.cancelled')) :
            completeData.text,
        }
      }
    };

    await CopyCutNotificationUtil.subscribeSystemLiveView(CopyCutNotificationUtil.systemLiveViewSubscriber);

    return liveViewNotificationRequest;
  }

  /**
   CopyCutNotificationUtil.isSubscribe = false;
   */
  public static async cancelProgressNotification(): Promise<void> {
    HiLog.info(TAG, 'cancelProgressNotification');
    // 只取消通知，不重置isSubscribe标志，确保下次发布通知时能重新订阅
    await NotificationUtil.cancel(NotificationConst.NotificationId.COPY_CUT_RUNNING);
  }

  /**
   * 取消复制移动完成的通知栏消息
   */
  public static async cancelCompleteNotification(): Promise<void> {
    HiLog.info(TAG, 'cancelCompleteNotification');
    CopyCutNotificationUtil.isSubscribe = false;
    await NotificationUtil.cancel(NotificationConst.NotificationId.COPY_CUT_END);
  }
}
