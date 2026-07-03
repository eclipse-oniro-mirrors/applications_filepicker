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
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { HiLog, ObjectUtil } from '@ohos/common';
import { EventConst } from './const/EventConst';
import { CopyCutCompleteData, CopyCutProgressData, ImmersiveData, JumpPageData, SendData } from './model/SendDataModel';
import { ReceiveEventUtil } from './ReceiveEventUtil';

const TAG = 'UIExtSessionManager';
// 与设置约定好的事件
const EVENT: string = 'pop';

export class UIExtSessionManager {
  private static instance: UIExtSessionManager;
  private session?: UIExtensionContentSession;
  private settingsSession?: UIExtensionContentSession;

  public static getInstance(): UIExtSessionManager {
    if (ObjectUtil.isNullOrUndefined(UIExtSessionManager.instance)) {
      UIExtSessionManager.instance = new UIExtSessionManager();
    }
    return UIExtSessionManager.instance;
  }

  /**
   * 通过session判断是否为通过UIExtension拉起
   */
  isLoadFromUIExtension(): boolean {
    return !ObjectUtil.isNullOrUndefined(this.session);
  }

  /**
   * 记录UIExtension的session用于消息传递等
   * @param session
   */
  public setSession(session: UIExtensionContentSession): void {
    this.session = session;
    if (!this.session) {
      HiLog.error(TAG, 'session is null');
      return;
    }
    this.session.setReceiveDataCallback(ReceiveEventUtil.receiveEventFromHostApp);
  }

  /**
   * 记录来自设置页面UIExtension的session用于消息传递等
   * @param session
   */
  public setSettingsSession(settingsSession: UIExtensionContentSession): void {
    if (!settingsSession) {
      HiLog.warn(TAG, 'session from settings is null');
      return;
    }
    this.settingsSession = settingsSession;
  }

  /**
   * 向宿主应用发消息
   */
  private sendDataToHost(data: SendData): void {
    if (!this.session) {
      HiLog.warn(TAG, 'session is null');
      return;
    }
    HiLog.infoPrivate(TAG, 'sendDataToHost data: ', JSON.stringify(data));
    try {
      this.session.sendData({
        data: data
      });
    } catch (e) {
      HiLog.error(TAG, `sendDataToHost error: ${JSON.stringify(e)}`);
    }
  }

  /**
   * 向宿主应用发送跳转页面事件
   */
  public jumpPage(data: JumpPageData): void {
    this.sendDataToHost({
      event: EventConst.JUMP_PAGE,
      data: data
    });
  }

  /**
   * 通过宿主应用发布复制移动进度的通知栏消息
   */
  public publishCopyCutProgressNotification(data: CopyCutProgressData): void {
    this.sendDataToHost({
      event: EventConst.PUBLISH_COPY_CUT_PROGRESS_NOTIFICATION,
      data: data
    });
  }

  /**
   * 通过宿主应用发布复制移动完成的通知栏消息
   */
  public publishCopyCutCompleteNotification(data: CopyCutCompleteData): void {
    this.sendDataToHost({
      event: EventConst.PUBLISH_COPY_CUT_COMPLETE_NOTIFICATION,
      data: data
    });
  }

  /**
   * 宿主应用收到此消息后会释放UIExtension
   */
  public releaseSettingsUIExt(event: string): void {
    try {
      if (!this.settingsSession) {
        HiLog.warn(TAG, 'releaseSettingsUIExt settingsSession is null.');
        return;
      }
      this.settingsSession.sendData({ 'action': event });
    } catch (err) {
      HiLog.error(TAG, `sendData error: ${err?.message}, code: ${err?.code}`);
    }
  }

  /**
   * 通过宿主应用取消复制移动进度的通知栏消息
   */
  public cancelCopyCutProgressNotification(): void {
    this.sendDataToHost({
      event: EventConst.CANCEL_COPY_CUT_PROGRESS_NOTIFICATION,
      data: null
    });
  }

  /**
   * 通过宿主应用取消复制移动完成的通知栏消息
   */
  public cancelCopyCutCompleteNotification(): void {
    this.sendDataToHost({
      event: EventConst.CANCEL_COPY_CUT_COMPLETE_NOTIFICATION,
      data: null
    });
  }

  /**
   * 通知宿主应用UIExtension已经监听了打开指定目录的事件
   */
  public sendHasOnOpenFolderEvent(): void {
    this.sendDataToHost({
      event: EventConst.SET_CAN_RESOLVE_OPEN_FOLDER,
      data: null
    });
  }

  /**
   * 向宿主应用发送检查通知栏状态事件
   */
  public sendCheckNotificationEvent(): void {
    this.sendDataToHost({
      event: EventConst.CHECK_NOTIFICATION_STATUS,
      data: null
    })
  }

  /**
   * 向宿主应用发送设置屏幕旋转
   */
  public sendSetOrientation(isPreviewMode: boolean): void {
    this.sendDataToHost({
      event: EventConst.SET_ORIENTATION,
      data: isPreviewMode
    })
  }

  /**
   * 向宿主应用发送设置状态栏颜色
   */
  setSystemBarContentColor(isDark: boolean | null = null) {
    HiLog.warn(TAG, 'setSystemBarContentColor: ' + EventConst.RESET_SYSTEM_BAR_COLOR);
    this.sendDataToHost({
      event: EventConst.RESET_SYSTEM_BAR_COLOR,
      data: isDark
    })
  }

  /**
   * 向宿主应用发送设置屏幕旋转指令
   */
  public sendSetOrientationByButton(): void {
    HiLog.warn(TAG, 'sendSetOrientationByButton: ' + EventConst.SWITCH_SCREEN_STATUS);
    this.sendDataToHost({
      event: EventConst.SWITCH_SCREEN_STATUS,
      data: null
    })
  }

  /**
   * 向宿主应用发送设置屏幕亮度指令
   */
  public sendSetBrightness(brightness: number): void {
    HiLog.warn(TAG, 'sendSetBrightness: ' + EventConst.SET_BRIGHTNESS_VALUE);

    this.sendDataToHost({
      event: EventConst.SET_BRIGHTNESS_VALUE,
      data: brightness
    })
  }

  /**
   * 向宿主应用发送进入沉浸式通知
   */
  public sendEntryImmersiveModeEvent(data: ImmersiveData): void {
    this.sendDataToHost({
      event: EventConst.ENTRY_IMMERSIVE_MODE,
      data: data
    })
  }

  /**
   * 向宿主应用发送屏幕常亮通知
   */
  public sendWindowKeepScreenOnEvent(isKeepOn: boolean): void {
    this.sendDataToHost({
      event: EventConst.WINDOW_KEEP_SCREEN_ON,
      data: isKeepOn
    })
  }

  /**
   * 向宿主应用发送结束事件
   */
  public sendOpenMediaFinishEvent(): void {
    this.sendDataToHost({
      event: EventConst.OPEN_MEDIA_FINISH,
      data: null
    })
  }

  /**
   * 向宿主应用发送进入、退出壁纸编辑界面
   */
  public sendSwitchWallPaperMode(switchFlag: boolean): void {
    this.sendDataToHost({
      event: EventConst.SWITCH_WALLPAPER_LOCK_MODE,
      data: switchFlag
    })
  }

  /**
   * 向宿主应用发送是否同意隐私声明状态
   */
  public sendAppPrivacyState(hasAgree: boolean): void {
    this.sendDataToHost({
      event: EventConst.AGREE_PRIVACY_STATE_SYNC,
      data: hasAgree
    })
  }

  /**
   * 向宿主应用发送是否确认过APP引导页状态
   */
  public sendAppGuidanceState(passed: boolean): void {
    this.sendDataToHost({
      event: EventConst.APP_GUIDANCE_STATE_SYNC,
      data: passed
    })
  }

  /**
   * 向壳应用发送兼容性版本号
   */
  public sendAppCompatibleVersion(version: number): void {
    this.sendDataToHost({
      event: EventConst.APP_COMPATIBLE_VERSION,
      data: version
    })
  }
}