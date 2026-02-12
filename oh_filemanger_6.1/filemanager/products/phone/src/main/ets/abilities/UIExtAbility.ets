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

import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import Want from '@ohos.app.ability.Want';
import { Configuration } from '@ohos.app.ability.Configuration';
import {
  AbilityManagerUtil,
  AssertExtUtil,
  DFX,
  UEUtil,
  GlobalKey,
  AbilityName,
  EventBus,
  LocalStorageConst,
  PAGE_ROUTE_CONST,
  Constant,
  GlobalHolder,
  HiLog,
  PasteBoardManager,
  AbilityCommonUtil,
  FileUtil,
  PreferenceFactory,
  BasePreference,
  PreferenceConst,
  CommonPreferenceUtil,
  ObjectUtil,
  CheckIsForbiddenUriTask,
  TaskManager,
  toast
} from '@ohos/common';
import { UIExtSessionManager } from '../base/extension/UIExtSessionManager';
import { display, uiExtensionHost, window } from '@kit.ArkUI';
import { ConfigurationConstant } from '@kit.AbilityKit';
import lazy { appManager, BundleResourceUtil } from '@ohos/common/indexLazyLoad';
import { UiExtensionHostUtilTemp } from '../base/utils/UiExtensionHostUtilTemp';
import { CompatibleConst, ShellAppCompatibleVersion } from '../base/const/CommonConst';

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
const TAG = 'UIExtAbility';
const DRAG_FLAG = 'phoneFile';

/**
 * 用于嵌入文件App里的文件管理页面
 */
export default class UIExtAbility extends UIExtensionAbility {
  private storage: LocalStorage = new LocalStorage(initProperties);
  private windowProxy?: uiExtensionHost.UIExtensionHostWindowProxy;
  private abilityKey?: string;
  private session?: UIExtensionContentSession;
  private appVersion?: string;

  onCreate(): void {
    HiLog.info(TAG, 'UIExtAbility onCreate');
    this.abilityKey = `${TAG}+${Date.now()}`;
    this.initParams();
    AppStorage.setOrCreate<boolean>('isDarkMode',
      this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    AppStorage.setOrCreate<ConfigurationConstant.ColorMode>('paf.currentColorMode', this.context.config.colorMode);
    AppStorage.setOrCreate<string>('systemLanguage', this.context.config.language);
    AppStorage.setOrCreate<number>('fontSizeScale', this.context.config.fontSizeScale);
  }

  private initParams(): void {
    let globalHolder: GlobalHolder = GlobalHolder.getInstance();
    globalHolder.setObject<string>(GlobalKey.ABILITY_KEY, this.abilityKey);
  }

  private initAppVersion(): void {
    let globalHolder: GlobalHolder = GlobalHolder.getInstance();
    globalHolder.setObject<string>(GlobalKey.APP_VERSION, this.appVersion);
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    HiLog.info(TAG, 'UIExtAbility onSessionCreate');
    if (!want || !want.parameters) {
      HiLog.error(TAG, 'UIExtAbility fail, want.parameters is null');
      return;
    }
    let callBundleName: string = AssertExtUtil.coverToString(want.parameters?.[AbilityCommonUtil.CALLER_BUNDLE_NAME],
      'callerBundleName');
    AbilityManagerUtil.getInstance().addAbility(AbilityName.FILE_MANAGER, callBundleName);
    UEUtil.reportCreateAbility(DFX.AbilityName.FILE_MANAGER_EXT, callBundleName);
    this.initParameters(want, session);
    this.session = session;
    this.appVersion = want.parameters[AbilityCommonUtil.HMFILES_APP_VERSION] as string
    this.initAppVersion()
    HiLog.info(TAG, 'UIExtAbility caller is: ' + callBundleName);
    if (Constant.FILE_APP_PACKAGE_NAME !== callBundleName && Constant.SETTING_BUNDLE_NAME !== callBundleName) {
      HiLog.info(TAG, 'UIExtAbility Loading forbidden');
      return;
    }
    GlobalHolder.getInstance().setUIExtensionContext(this.context);
    GlobalHolder.getInstance().setAppContext(this.context.getApplicationContext());
    UIExtSessionManager.getInstance().setSession(session);
    this.windowProxy = session.getUIExtensionHostWindowProxy();
    UiExtensionHostUtilTemp.hidePrivacyContentForHost(this.windowProxy);
    this.getWindowAvoidArea();
    this.onWindowAvoidAreaChange();
    this.onWindowSizeChange();
    GlobalHolder.getInstance().windowProxy = this.windowProxy;

    this.initCompatibleParams(callBundleName, want).finally(() => {
      AbilityCommonUtil.init().finally(() => {
        session.loadContent(PAGE_ROUTE_CONST.MAIN_ENTRY, this.storage);
      });
    });
  }

  /**
   * Ability has brought to foreground
   */
  onForeground(): void {
    HiLog.info(TAG, 'UIExtAbility onForeground');
    let globalHolder: GlobalHolder = GlobalHolder.getInstance();
    globalHolder.setAppContext(this.context.getApplicationContext());
    globalHolder.setCommonContext(this.context);
    GlobalHolder.getInstance().setUIExtensionContext(this.context);
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
    HiLog.info(TAG, 'UIExtAbility onBackground');
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
    HiLog.info(TAG, 'UIExtAbility onDestroy');
    AbilityManagerUtil.getInstance().reduceAbility(AbilityName.FILE_MANAGER)
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    HiLog.info(TAG, 'UIExtAbility onConfigurationUpdate');
    AppStorage.setOrCreate<boolean>('isDarkMode',
      newConfig.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    let systemLanguage = AppStorage.get<string>('systemLanguage');
    if (systemLanguage !== newConfig.language) {
      BundleResourceUtil.onSystemLanguageChange();
      AppStorage.setOrCreate<string>('systemLanguage', newConfig.language);
    }
    let fontSizeScale = AppStorage.get<number>('fontSizeScale');
    if (fontSizeScale !== newConfig.fontSizeScale) {
      AppStorage.setOrCreate<number>('fontSizeScale', newConfig.fontSizeScale);
    }
    let isDarkMode = AppStorage.get<boolean>('isDarkMode');
    let currIsDarkMode = newConfig.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    if (isDarkMode !== currIsDarkMode) {
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
      HiLog.error(TAG, 'getWindowAvoidArea fail, error:' + JSON.stringify(error))
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
            break
          case window.AvoidAreaType.TYPE_CUTOUT:
            AppStorage.setOrCreate<window.AvoidArea>('windowAvoidArea', data.area);
            break
          default:
            break
        }
      })
    } catch (error) {
      HiLog.error(TAG, 'getWindowAvoidArea fail, error:' + JSON.stringify(error))
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

  private initParameters(want: Want, session: UIExtensionContentSession): void {
    const globalHolder: GlobalHolder = GlobalHolder.getInstance();
    globalHolder.setObject<string>(GlobalKey.SAND_BOX_PATH, this.context.filesDir);
    globalHolder.setObject<UIExtensionContentSession>(GlobalKey.WINDOW_CLASS_EXT, session);
    if (want.parameters?.['HmFiles.agreeTimeStamp']) {
      globalHolder.setObject<string>(GlobalKey.DRAG_INFO_TIME,
        want.parameters?.['HmFiles.agreeTimeStamp'].toString() + DRAG_FLAG);
    } else {
      globalHolder.setObject<string>(GlobalKey.DRAG_INFO_TIME, new Date().getTime().toString() + DRAG_FLAG);
    }
    if (want.parameters?.['HmFiles.displayInfo']) {
      HiLog.info(TAG, `initParameters displayInfo ${want.parameters?.['HmFiles.displayInfo']}`);
      AppStorage.setOrCreate<string>(GlobalKey.DISPLAY_INFO, want.parameters?.['HmFiles.displayInfo'] as string);
    } else {
      AppStorage.setOrCreate<string>(GlobalKey.DISPLAY_INFO, '');
      HiLog.info(TAG, `initParameters displayInfo []`);
    }
    if (want.parameters?.['HmFiles.isJumpToFolder']) {
      PasteBoardManager.getInstance().setWhetherToReadPasteBoard(false);
      globalHolder.setObject<string>(GlobalKey.OPEN_PAGE, Constant.PAGE_TYPE.MY_PHONE);
      globalHolder.setObject<string>(GlobalKey.FROM, want.parameters?.['HmFiles.umpToFolderFrom']?.toString() ?? '');
      const targetFolderUri = want.parameters?.['HmFiles.jumpToFolderUri']?.toString() ?? '';
      let task: CheckIsForbiddenUriTask =
        new CheckIsForbiddenUriTask(targetFolderUri, true, (isForbiddenUri: boolean) => {
          HiLog.info(TAG, `CheckIsForbiddenUriTask result: ${isForbiddenUri}`);
          let fileUri: string = Constant.MY_PHONE_URI;
          if (isForbiddenUri) {
            // toast提示路径不存在，加延时避免文管冷启动提示空白
            let timeoutBox = setTimeout(() => {
              toast($r('app.string.path_not_exist'));
              clearTimeout(timeoutBox);
            }, Constant.TIMER_TIME.TIMER_100);
          } else {
            fileUri = targetFolderUri;
          }
          globalHolder.setObject<string>(GlobalKey.URI_PATH, fileUri);
          EventBus.emit(Constant.EVENTS.FILE_MANAGER_ON_NEW_WANT);
        });
      TaskManager.getInstance().execute<number>(task, 1, false, 30);
    }

    /*
     * 接受参数，传递fileUriArray。此处为文管初次启动时调用。
     * 文管已启动的情况下，会走receiveEventFromHostApp()。
     */
    const fileUriArrayJSON: Object | undefined = want.parameters?.['HmFiles.jumpToFolderFileUriArray'];
    if (fileUriArrayJSON) {
      const fileUriArray: string[] = Object.values(fileUriArrayJSON).slice(0, -1); // 去除掉最后一个length值
      globalHolder.setObject<string[]>(GlobalKey.FILE_URI_ARRAY, fileUriArray);
    } else {
      globalHolder.setObject<string[]>(GlobalKey.FILE_URI_ARRAY, []);
    }
  }

  private async initCompatibleParams(caller: string, want: Want) : Promise<void> {
    // 只处理 com.ohos.files 拉起时的兼容性适配
    if (caller !== Constant.FILE_APP_PACKAGE_NAME) {
      HiLog.info(TAG, `initCompatibleParams caller:${caller}`);
      return;
    }

    HiLog.info(TAG, 'start init compatible');
    let ver = want.parameters?.[CompatibleConst.SHELL_APP_COMPATIBLE_VER] as number;
    const globalHolder: GlobalHolder = GlobalHolder.getInstance();
    globalHolder.setObject<number>(GlobalKey.SHELL_APP_COMPATIBLE_VERSION, ver ?? ShellAppCompatibleVersion.DEFAULT_VER);

    if (ObjectUtil.isNullOrUndefined(ver)) {
      HiLog.info(TAG, 'ver is null. skip init compatible');
      return;
    }

    // 壳应用为初始版本，无兼容性数据需要处理
    if (ver <= ShellAppCompatibleVersion.DEFAULT_VER) {
      return;
    }

    const preference: BasePreference = PreferenceFactory.getPreference(PreferenceConst.FILE.COMMON);
    if (!preference) {
      HiLog.warn(TAG, 'initCompatibleParams PreferenceManager get failed');
      return;
    }

    // app引导页兼容性处理
    await this.initAppGuidanceInfo(want, preference);
    return;
  }

  private async initAppGuidanceInfo(want: Want, preference: BasePreference) {
    const appGuidancePass = want.parameters?.[CompatibleConst.APP_GUIDANCE_PASS];

    // 壳应用未通过引导页，需要在filemanager中再弹一次引导页
    if (!appGuidancePass) {
      HiLog.info(TAG, 'usr need to confirm app guidance.');
      await preference.put(PreferenceConst.KEY.APP_GUIDANCE_PASS, false);
      return;
    }

    // 壳应用已通过引导页，但filemanager未记录时，刷新filemanager的同意状态，记录壳应用同意的引导页版本号
    const localAppGuidancePass = await preference.get<boolean>(PreferenceConst.KEY.APP_GUIDANCE_PASS, false);
    if (!localAppGuidancePass) {
      const appGuidanceVer = want.parameters?.[CompatibleConst.APP_GUIDANCE_VERSION] as number;
      HiLog.info(TAG, `usr has confirmed app guidance. init guidance Info. ver: ${appGuidanceVer}`);

      await preference.put(PreferenceConst.KEY.APP_GUIDANCE_PASS, true);
      await preference.put(PreferenceConst.KEY.APP_GUIDANCE_PASS_VERSION, appGuidanceVer);
      return;
    }
  }
}