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
import { Configuration } from '@ohos.app.ability.Configuration';
import Want from '@ohos.app.ability.Want';
import {
  AbilityCommonUtil,
  AbilityManagerUtil,
  AbilityName,
  AssertExtUtil,
  Constant,
  DFX,
  EventBus,
  FileType,
  GlobalHolder,
  GlobalKey,
  HiLog,
  LocalStorageConst,
  PAGE_ROUTE_CONST,
  StringUtil,
  UEUtil
} from '@ohos/common';
import { UIExtSessionManager } from '../base/extension/UIExtSessionManager';
import { HashMap, HashSet } from '@kit.ArkTS';
import { display, uiExtensionHost, window } from '@kit.ArkUI';
import { ConfigurationConstant, UIExtensionAbility } from '@kit.AbilityKit';

/**
 * LocalStorage里储存数据的兜底配置
 */
const initProperties: Record<string, number | string> = {
  'statusBarHeight': LocalStorageConst.DEFAULT_STATUS_BAR_HEIGHT,
  'bottomNavBarHeight': LocalStorageConst.DEFAULT_BOTTOM_NAV_BAR_HEIGHT
}

/**
 * 日志TAG
 */
const TAG = 'OpenMediaUIExtAbility';
const DRAG_FLAG = 'phoneFile';

/**
 * 用于供外部拉起媒体视图的UIExtensionAbility
 */
export default class OpenMediaUIExtAbility extends UIExtensionAbility {
  // 权限表，应用 + 开放的权限
  private callerPermissionMap: HashMap<string, HashSet<string>> = new HashMap();
  private storage: LocalStorage = new LocalStorage(initProperties);
  private windowProxy?: uiExtensionHost.UIExtensionHostWindowProxy;
  private abilityKey?: string;
  private session?: UIExtensionContentSession;

  onCreate(): void {
    HiLog.info(TAG, 'OpenMediaUIExtAbility onCreate');
    // 初始化权限配置
    let permissionSet = new HashSet<string>();
    permissionSet.add(FileType.VIDEO);

    this.abilityKey = `${TAG}+${Date.now()}`;
    GlobalHolder.getInstance().setUIExtensionContext(this.context);
    GlobalHolder.getInstance().setAppContext(this.context.getApplicationContext());
    GlobalHolder.getInstance().setObject<string>(GlobalKey.ABILITY_KEY, this.abilityKey);
    AppStorage.setOrCreate<boolean>('isDarkMode',
      this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    AppStorage.setOrCreate<ConfigurationConstant.ColorMode>('paf.currentColorMode', this.context.config.colorMode);
    AppStorage.setOrCreate<string>('systemLanguage', this.context.config.language);
    AppStorage.setOrCreate<number>('fontSizeScale', this.context.config.fontSizeScale);
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    HiLog.info(TAG, 'OpenMediaUIExtAbility onSessionCreate');
    if (!want || !want.parameters) {
      HiLog.error(TAG, 'OpenMediaUIExtAbility fail, want.parameters is null');
      return;
    }

    // 检查包名
    let callBundleName: string = AssertExtUtil.coverToString(want.parameters?.[AbilityCommonUtil.CALLER_BUNDLE_NAME],
      'callerBundleName');
    if (StringUtil.isEmpty(callBundleName)) {
      HiLog.error(TAG, 'OpenMediaUIExtAbility callerBundleName is null');
      return;
    }

    AbilityManagerUtil.getInstance().addAbility(AbilityName.OPEN_MEDIA, callBundleName);
    UEUtil.reportCreateAbility(DFX.AbilityName.OPEN_MEDIA_EXT, callBundleName);

    // 检查媒体类型
    HiLog.info(TAG, 'OpenMediaUIExtAbility caller is: ' + callBundleName);
    let mediaType = want.parameters?.[Constant.OPEN_MEDIA_PARAMETER.TYPE] as string;
    if (!mediaType) {
      HiLog.error(TAG, 'OpenMediaUIExtAbility media type is null');
      return;
    }

    // 检查权限
    if (!this.checkCallerPermission(callBundleName, mediaType)) {
      HiLog.error(TAG, 'OpenMediaUIExtAbility Caller has no permission: ' + callBundleName + ' ' + mediaType);
      return;
    }

    HiLog.warn(TAG, 'OpenMediaUIExtAbility run');
    this.initParameters(mediaType, session, callBundleName);
    this.session = session;
    UIExtSessionManager.getInstance().setSession(session);
    this.windowProxy = session.getUIExtensionHostWindowProxy();
    this.getWindowAvoidArea();
    this.onWindowAvoidAreaChange();
    this.onWindowSizeChange();
    GlobalHolder.getInstance().windowProxy = this.windowProxy;

    AbilityCommonUtil.init().finally(() => {
      session.loadContent(PAGE_ROUTE_CONST.MAIN_ENTRY, this.storage);
    })

    const isDark = AppStorage.get<boolean>('isDarkMode') || false;
    UIExtSessionManager.getInstance().setSystemBarContentColor(isDark);
  }

  /**
   * Ability has brought to foreground
   */
  onForeground(): void {
    HiLog.info(TAG, 'OpenMediaUIExtAbility onForeground');
    let globalHolder: GlobalHolder = GlobalHolder.getInstance();
    globalHolder.setAppContext(this.context.getApplicationContext());
    globalHolder.setCommonContext(this.context);
    GlobalHolder.getInstance().setUIExtensionContext(this.context)
    globalHolder.setObject<boolean>(GlobalKey.PICKER_FLAG, false);
    globalHolder.setObject<UIExtensionContentSession>(GlobalKey.WINDOW_CLASS_EXT, this.session);
    EventBus.emit(Constant.EVENTS.ABILITY_ON_FOREGROUND);
    EventBus.emit(Constant.EVENTS.REFRESH_PHONE_SPACE_SIZE);
    EventBus.emit(Constant.EVENTS.ON_VIEW_FOREGROUND_EVENT);
  }

  /**
   * Ability has brought to Background
   */
  onBackground(): void {
    HiLog.info(TAG, 'OpenMediaUIExtAbility onBackground');
    // 应用切换至后台时与融合搜断连, 并重置lastPrepareTime使得切换至前台后进入搜索页面会主动拉起搜索服务
    try {
      AppStorage.setOrCreate('lastPrepareTime', 0);
    } catch (error) {
      HiLog.error(TAG, 'endSearch error: ' + JSON.stringify(error));
    }
    EventBus.emit(Constant.EVENTS.ON_BACKGROUND);
    EventBus.emit(Constant.EVENTS.ON_VIEW_BACKGROUND_EVENT);
  }

  /**
   * Ability has brought to Destroy
   */
  onDestroy(): void | Promise<void> {
    HiLog.info(TAG, 'OpenMediaUIExtAbility onDestroy');
    AbilityManagerUtil.getInstance().reduceAbility(AbilityName.OPEN_MEDIA)
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    HiLog.info(TAG, 'OpenMediaUIExtAbility onConfigurationUpdate');
    let systemLanguage = AppStorage.get<string>('systemLanguage');
    if (systemLanguage !== newConfig.language) {
      AppStorage.setOrCreate<string>('systemLanguage', newConfig.language);
    }
    let fontSizeScale = AppStorage.get<number>('fontSizeScale');
    if (fontSizeScale !== newConfig.fontSizeScale) {
      AppStorage.setOrCreate<number>('fontSizeScale', newConfig.fontSizeScale);
    }
    let isDarkMode = AppStorage.get<boolean>('isDarkMode');
    let currIsDarkMode = newConfig.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    if (isDarkMode !== currIsDarkMode) {
      UIExtSessionManager.getInstance().setSystemBarContentColor(currIsDarkMode);
      AppStorage.setOrCreate<boolean>('isDarkMode', currIsDarkMode);
    }
  }

  /**
   * 获取窗口的避让区域的高度
   */
  getWindowAvoidArea(): void {
    if (!this.windowProxy) {
      return
    }
    try {
      // 获取并保存顶部状态栏的高度
      const systemAvoidArea = this.windowProxy.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
      this.storage.set(LocalStorageConst.STATUS_BAR_HEIGHT, px2vp(systemAvoidArea.topRect.height))
      HiLog.info(TAG, 'statusBarHeight:' + px2vp(systemAvoidArea.topRect.height))
      // 获取并保存底部导航条的高度
      const navBarAvoidArea = this.windowProxy.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
      this.storage.set(LocalStorageConst.BOTTOM_NAV_BAR_HEIGHT, px2vp(navBarAvoidArea.bottomRect.height))
      HiLog.info(TAG, 'bottomNavBarHeight:' + px2vp(navBarAvoidArea.bottomRect.height))
      // 获取并保存刘海屏避让区
      const cutoutAvoidArea = this.windowProxy.getWindowAvoidArea(window.AvoidAreaType.TYPE_CUTOUT);
      this.storage.set('windowAvoidArea', cutoutAvoidArea);
      HiLog.info(TAG, 'getWindowAvoidArea: cutoutAvoidArea' + JSON.stringify(cutoutAvoidArea));
    } catch (error) {
      HiLog.error(TAG, 'getWindowAvoidArea fail, error:' + JSON.stringify(error) + error)
    }
  }

  /**
   * 监听避让区域变化事件，重新设置避让区域的高度
   */
  onWindowAvoidAreaChange(): void {
    if (!this.windowProxy) {
      return
    }
    try {
      this.windowProxy.on('avoidAreaChange', (data) => {
        HiLog.info(TAG, 'avoidAreaChange data:' + JSON.stringify(data))
        switch (data.type) {
          case window.AvoidAreaType.TYPE_SYSTEM:
            this.storage.set(LocalStorageConst.STATUS_BAR_HEIGHT, px2vp(data.area.topRect.height))
            break;
          case window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR:
            this.storage.set(LocalStorageConst.BOTTOM_NAV_BAR_HEIGHT, px2vp(data.area.bottomRect.height))
            break;
          case window.AvoidAreaType.TYPE_CUTOUT:
            AppStorage.setOrCreate<window.AvoidArea>('windowAvoidArea', data.area);
            break;
          default:
            break
        }
      });
    } catch (error) {
      HiLog.error(TAG,
        `Register the callback of avoidAreaChange fail, error.code: ${error?.code}, error.message: ${error?.message}`);
    }
  }

  onWindowSizeChange(): void {
    if (!this.windowProxy) {
      HiLog.error(TAG, `onWindowSizeChange windowProxy is null`);
      return;
    }
    try {
      this.windowProxy.on('windowSizeChange', (windowSize) => {
        AppStorage.setOrCreate<window.Size>('windowSize', windowSize);
        try {
          AppStorage.setOrCreate<number>('orientation', display.getDefaultDisplaySync().orientation);
        } catch (error) {
          HiLog.error(TAG, `getDefaultDisplaySync fail, error.code: ${error?.code}, error.message: ${error?.message}`);
        }
      });
    } catch (error) {
      HiLog.error(TAG,
        `Register the callback of windowSizeChange fail, error.code: ${error?.code}, error.message: ${error?.message}`);
    }
  }

  private initParameters(mediaType: string, session: UIExtensionContentSession, callerBundleName: string): void {
    AppStorage.setOrCreate<string>(GlobalKey.DISPLAY_INFO, '');

    const globalHolder: GlobalHolder = GlobalHolder.getInstance();
    globalHolder.setObject<UIExtensionContentSession>(GlobalKey.WINDOW_CLASS_EXT, session);
    globalHolder.setObject<string>(GlobalKey.DRAG_INFO_TIME, new Date().getTime().toString() + DRAG_FLAG);
    globalHolder.setObject<string[]>(GlobalKey.FILE_URI_ARRAY, []);

    // 初始化媒体类型，供后续页面跳转使用
    globalHolder.setObject<string>(GlobalKey.OPEN_MEDIA_TYPE, mediaType);
    globalHolder.setObject<string>(GlobalKey.OPEN_MEDIA_CALLER_BUNDLE_NAME, callerBundleName);
  }

  /**
   * 校验调用者包名和可访问的媒体权限
   *
   * @param callerName 调用者包名
   * @param mediaType 媒体权限
   * @returns 是否有权限
   */
  private checkCallerPermission(callerName: string, mediaType: string): boolean {
    if (this.callerPermissionMap.hasKey(callerName)) {
      let mediaTypeSet = this.callerPermissionMap.get(callerName);
      if (mediaTypeSet.has(mediaType)) {
        return true;
      }
    }

    return false;
  }
}