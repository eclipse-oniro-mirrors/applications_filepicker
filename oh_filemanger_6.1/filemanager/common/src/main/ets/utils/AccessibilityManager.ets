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
import accessibility from '@ohos.accessibility';
import { BusinessError } from '@ohos.base';
import { FileInfo } from '../fileoperate/FileInfo';
import { DisplayTimeUtil } from './DisplayTimeUtil';
import { ObjectUtil } from './ObjectUtil';
import FileMimeTypeUtil from './FileMimeTypeUtil';
import { ResourceUtil } from './ResourceUtil';
import { DateUtil } from './DateUtil';
import { FileSourceType } from '../const/Constant';
import { StringUtil } from './StringUtil';
import {AccessibilityStorageKey} from '../const/Constant'

const TAG: string = 'AccessibilityManager';

export class AccessibilityManager {
  private static instance: AccessibilityManager;
  // 是否启用了辅助功能
  private isOpenAccessibility: boolean = false;
  // 是否开启了触摸浏览模式
  private isOpenTouchGuide: boolean = false;
  private readonly FOCUS_DELAY_TIME = 200; // 延迟200毫秒
  private timeoutId: number = -1;

  public static getInstance(): AccessibilityManager {
    if (!AccessibilityManager.instance) {
      AccessibilityManager.instance = new AccessibilityManager();
    }
    return AccessibilityManager.instance;
  }

  private accessibilityStateChange(state: boolean): void {
    HiLog.info(TAG, `accessibilityState: ${state}`);
    AccessibilityManager.getInstance().isOpenAccessibility = state;
    AccessibilityManager.getInstance().updateAccessibilityMode();
  }

  private touchGuideStateChange(state: boolean): void {
    HiLog.info(TAG, `touchGuideState: ${state}`);
    AccessibilityManager.getInstance().isOpenTouchGuide = state;
    AccessibilityManager.getInstance().updateAccessibilityMode();
  }

  private updateAccessibilityMode(): void {
    AppStorage.setOrCreate('isAccessibilityMode', this.isOpenAccessibility && this.isOpenTouchGuide);
  }

  /**
   * 获取无障碍模式状态
   *
   */
  public getIsAccessibilityMode(): boolean {
    return this.isOpenAccessibility && this.isOpenTouchGuide;
  }

  /**
   * 注册无障碍模式变化监听
   *
   */
  public initAccessibilityModeListener(): void {
    try {
      this.isOpenAccessibility = accessibility.isOpenAccessibilitySync();
      this.isOpenTouchGuide = accessibility.isOpenTouchGuideSync();
      this.updateAccessibilityMode();
      accessibility.on('accessibilityStateChange', this.accessibilityStateChange);
      accessibility.on('touchGuideStateChange', this.touchGuideStateChange);
    } catch (err) {
      HiLog.error(TAG, `initAccessibilityModeListener error ${err?.message}`);
    }
  }

  /**
   * 注销无障碍模式变化监听
   *
   */
  public unregisterAccessibilityModeListener(): void {
    try {
      accessibility.off('accessibilityStateChange', this.accessibilityStateChange);
      accessibility.off('touchGuideStateChange', this.touchGuideStateChange);
    } catch (err) {
      HiLog.error(TAG, `unregisterAccessibilityModeListener error ${err?.message}`);
    }
  }


  /**
   * 无障碍模式下主动播报信息
   *
   * @param textAnnouncedForAccessibility 主动播报信息 string
   * @param from string
   *
   */
  public sendTextAnnouncedForAccessibility(textAnnouncedForAccessibility: string, from: string = ''): void {
    let accessEventInfo: accessibility.EventInfo = ({
      type: 'announceForAccessibility',
      bundleName: 'com.ohos.filemanager',
      triggerAction: 'common',
      textAnnouncedForAccessibility,
    });
    HiLog.info(TAG, `textAnnouncedForAccessibility:${textAnnouncedForAccessibility}`);
    try {
      accessibility.sendAccessibilityEvent(accessEventInfo, (err: BusinessError) => {
        if (err) {
          HiLog.error(TAG, `${from} announceForAccessibility failed, errMsg: ${err.message}`);
          return;
        }
        HiLog.error(TAG, `${from} announceForAccessibility success`);
      });
    } catch (error) {
      HiLog.error(TAG, 'announceForAccessibility error');
    }
  }

  /**
   * 无障碍模式下主动播报信息,不打断前面的播报
   *
   * @param textAnnouncedForAccessibility 主动播报信息 string
   * @param from string
   */
  public sendTextAnnouncedForAccessibilityNoInterrupt(textAnnouncedForAccessibility: string, from: string = ''): void {
    let accessEventInfo: accessibility.EventInfo = ({
      type: 'announceForAccessibilityNotInterrupt',
      bundleName: 'com.ohos.filemanager',
      triggerAction: 'common',
      textAnnouncedForAccessibility,
    });
    HiLog.info(TAG, `textAnnouncedForAccessibilityNoInterrupt:${textAnnouncedForAccessibility}`);
    try {
      accessibility.sendAccessibilityEvent(accessEventInfo, (err: BusinessError) => {
        if (err) {
          HiLog.error(TAG, `${from} sendTextAnnouncedForAccessibilityNoInterrupt failed, errMsg: ${err.message}`);
          return;
        }
        HiLog.info(TAG, `${from} sendTextAnnouncedForAccessibilityNoInterrupt success`);
      });
    } catch (error) {
      HiLog.error(TAG, 'sendTextAnnouncedForAccessibilityNoInterrupt error');
    }
  }

  /**
   * 无障碍模式下主动聚焦
   *
   * @param customId 聚焦组件Id string
   * @param from string
   *
   */
  public sendCustomIdFocusForAccessibility(customId: string, from: string = ''): void {
    if (!this.getIsAccessibilityMode()) {
      return
    }
    let accessEventInfo: accessibility.EventInfo = ({
      type: 'requestFocusForAccessibility',
      bundleName: 'com.ohos.filemanager',
      triggerAction: 'common',
      customId
    });
    HiLog.info(TAG, `customId:${customId}`);
    try {
      accessibility.sendAccessibilityEvent(accessEventInfo, (err: BusinessError) => {
        if (err) {
          HiLog.error(TAG, `${from} requestFocusForAccessibility failed,errMsg: ${err.message}`);
          return;
        }
        HiLog.info(TAG, `${from} requestFocusForAccessibility success`);
      });
    } catch (error) {
      HiLog.error(TAG, 'requestFocusForAccessibility error');
    }
  }

  /**
   * 无障碍模式下播报播报内容
   *
   */
  public async announcedString(content: string, form: string = ''): Promise<void> {
    const isAccessibilityMode: boolean = this.getIsAccessibilityMode();
    if (isAccessibilityMode) {
      const text: string = content;
      this.sendTextAnnouncedForAccessibility(text, form);
    }
  }

  /**
   * 无障碍模式下不打断前面的播报内容
   */
  public async announceForAccessibilityNotInterrupt(content: string, form: string = ''): Promise<void> {
    const isAccessibilityMode: boolean = this.getIsAccessibilityMode();
    if (isAccessibilityMode) {
      const text: string = content;
      this.sendTextAnnouncedForAccessibilityNoInterrupt(text, form);
    }
  }

  /**
   * 获取视频、图片的无障碍播报内容
   * @param fileInfo FileInfo
   * @param index number
   * */
  public static getMediaFileAccessibilityText(fileInfo: FileInfo, index: number, lang: string): string {
    if (ObjectUtil.isNullOrUndefined(fileInfo) || !FileMimeTypeUtil.isImageOrVideo(fileInfo.mimeTypeObj)) {
      return '';
    }
    const dateStr: string = DisplayTimeUtil.get12HourDateStr(lang, new Date(fileInfo.mtime));
    if (FileMimeTypeUtil.isVideo(fileInfo.mimeTypeObj)) {
      return ResourceUtil.getStringByResource($r('app.string.video_broadcast', (index + 1).toString(),
        DateUtil.formatFullDuration(fileInfo.duration) + ` , ${dateStr}`));
    } else if (FileMimeTypeUtil.isImage(fileInfo.mimeTypeObj)) {
      return ResourceUtil.getStringByResource($r('app.string.image')) + `${(index + 1).toString()} , ${dateStr}`;
    }
    return '';
  }

  /**
   * 播报并跳转焦点
   */
  public announcedStringAndFocusComponent(content: string, customId: string, form: string = ''): void {
    // 不是无障碍模式直接返回
    if (!this.getIsAccessibilityMode()) {
      return;
    }
    // 播报内容
    this.sendTextAnnouncedForAccessibility(content, form);
    if (StringUtil.isEmpty(customId)) {
      HiLog.warn(TAG, 'announcedStringAndFocusComponent: customId is empty.');
      return;
    }
    if (this.timeoutId !== -1) {
      clearTimeout(this.timeoutId);
    }
    // 增加200毫秒延时,200毫秒是无障碍那边的经验值
    this.timeoutId = setTimeout(() => {
      // 跳转焦点
      this.sendCustomIdFocusForAccessibility(customId, form);
      this.timeoutId = -1;
    }, this.FOCUS_DELAY_TIME);
  }

  /**
   * 不播报标题变化，并跳转焦点
   */
  public notAnnouncedTitleAndFocusComponent(customId: string): void {
    // 不是无障碍模式直接返回
    if (!this.getIsAccessibilityMode()) {
      return;
    }
    HiLog.info(TAG, `notAnnouncedTitleAndFocusComponent customId: ${customId}`);
    // 更新标识符，不响应播报标题
    AppStorage.setOrCreate(AccessibilityStorageKey.MULTIPLE_CHOICE_KEY, 1);
    if (!StringUtil.isEmpty(customId)) {
      this.sendCustomIdFocusForAccessibility(customId);
    }
  }
}