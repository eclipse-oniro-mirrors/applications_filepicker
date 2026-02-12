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

import UIAbility from '@ohos.app.ability.UIAbility';
import {
  Constant,
  EventBus,
  GlobalHolder,
  GlobalKey,
  HiLog,
  PAGE_ROUTE_CONST,
  StringUtil,
  AssertExtUtil,
  AbilityCommonUtil,
  BundleResourceUtil,
  AccessibilityManager,
  AbilityManagerUtil,
  AbilityName,
  PasteBoardManager,
  DFX,
  UEUtil,
  CheckIsForbiddenUriTask,
  TaskManager,
  toast,
  CommonPreferenceUtil,
} from '@ohos/common';
import type AbilityConstant from '@ohos.app.ability.AbilityConstant';
import type Want from '@ohos.app.ability.Want';
import { BusinessError } from '@kit.BasicServicesKit';
import window from '@ohos.window';
import { display } from '@kit.ArkUI';
import { Configuration, ConfigurationConstant } from '@kit.AbilityKit';
import { NotificationUtil } from '../../base/notification/NotificationUtil';

const TAG = 'MainAbility';
const KEY_FILE_URI = 'fileUri';

export default class MainAbility extends UIAbility {
  private want?: Want;
  private abilityKey?: string;
  private storage: LocalStorage = new LocalStorage();

  async onCreate(want: Want, launchParam: Object) {
    this.want = want;
    HiLog.info(TAG, 'FileManager onCreate');
    this.abilityKey = `${TAG}+${Date.now()}`;
    this.initParams();
    this.initFromNotify(want);
    AppStorage.setOrCreate<boolean>('isDarkMode',
      this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    AppStorage.setOrCreate<string>('systemLanguage', this.context.config.language);
    AppStorage.setOrCreate<number>('fontSizeScale', this.context.config.fontSizeScale);
    AppStorage.setOrCreate<boolean>('isDarkMode',
      this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    AccessibilityManager.getInstance().initAccessibilityModeListener();
    HiLog.info(TAG, 'MainAbility onCreate');
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    HiLog.info(TAG, 'Main ability onConfigurationUpdate');
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

  private initParams(): void {
    let globalHolder: GlobalHolder = GlobalHolder.getInstance();
    globalHolder.setObject<Want>(GlobalKey.ABILITY_WANT, this.want);
    globalHolder.setObject<string>(GlobalKey.ABILITY_KEY, this.abilityKey);
    globalHolder.setMainAbilityContext(this.context);
    globalHolder.setAppContext(this.context.getApplicationContext());
    globalHolder.setObject<boolean>(GlobalKey.PICKER_FLAG, false);
    HiLog.info(TAG, 'initParams end');
  }

  private initFromNotify(want: Want): void {
    if ((!want) || (!want.parameters)) {
      return;
    }
    let parameters = want.parameters;
    let globalHolder: GlobalHolder = GlobalHolder.getInstance();
    let fileUri = parameters[KEY_FILE_URI];
    HiLog.infoPrivate(TAG, 'initFromNotify:' + JSON.stringify(parameters), fileUri + '');
    const bundleName = AssertExtUtil.coverToString(want.parameters!![AbilityCommonUtil.CALLER_BUNDLE_NAME],
      'CALLER_BUNDLE_NAME');
    AbilityManagerUtil.getInstance().addAbility(AbilityName.FILE_MANAGER, bundleName);
    UEUtil.reportCreateAbility(DFX.AbilityName.FILE_MANAGER_UI, bundleName);
    if (typeof fileUri === 'string') {
      let uri = fileUri as string;
      if (!StringUtil.isEmpty(uri)) {
        const errorStr = AssertExtUtil.checkUriTrusted(uri);
        if (AssertExtUtil.checkIsError(TAG, errorStr)) {
          return;
        }
        PasteBoardManager.getInstance().setWhetherToReadPasteBoard(false);
        let task: CheckIsForbiddenUriTask =
          new CheckIsForbiddenUriTask(uri, true, (isForbiddenUri: boolean) => {
            HiLog.info(TAG, `CheckIsForbiddenUriTask result: ${isForbiddenUri}`);
            let tempFileUri: string = Constant.MY_PHONE_URI;
            if (isForbiddenUri) {
              // toast提示路径不存在，加延时避免文管冷启动提示空白
              let timeoutBox = setTimeout(() => {
                toast($r('app.string.path_not_exist'));
                clearTimeout(timeoutBox);
              }, Constant.TIMER_TIME.TIMER_100);
            } else {
              tempFileUri = uri;
            }
            globalHolder.setObject<string>(GlobalKey.FROM, Constant.FROM_TYPE.THIRD_APP);
            globalHolder.setObject<string>(GlobalKey.OPEN_PAGE, Constant.PAGE_TYPE.MY_PHONE);
            globalHolder.setObject<string>(GlobalKey.URI_PATH, tempFileUri);
          });
        TaskManager.getInstance().execute<number>(task, 1, false, 30);
      }
    } else if (!!parameters.param) {
      let uriPath = AssertExtUtil.coverToString(parameters[Constant.URI_PATH], Constant.URI_PATH);
      let errorStr = AssertExtUtil.checkUriTrusted(uriPath); // 路径可信
      if (AssertExtUtil.checkIsError(TAG, errorStr)) {
        return;
      }
      PasteBoardManager.getInstance().setWhetherToReadPasteBoard(false);
      let task: CheckIsForbiddenUriTask =
        new CheckIsForbiddenUriTask(uriPath, true, (isForbiddenUri: boolean) => {
          HiLog.info(TAG, `CheckIsForbiddenUriTask result: ${isForbiddenUri}`);
          let tempFileUri: string = Constant.MY_PHONE_URI;
          if (isForbiddenUri) {
            // toast提示路径不存在，加延时避免文管冷启动提示空白
            let timeoutBox = setTimeout(() => {
              toast($r('app.string.path_not_exist'));
              clearTimeout(timeoutBox);
            }, Constant.TIMER_TIME.TIMER_100);
          } else {
            tempFileUri = uriPath;
          }
          globalHolder.setObject<string>(GlobalKey.URI_PATH, tempFileUri);
          globalHolder.setObject<string>(GlobalKey.FROM,
            AssertExtUtil.coverToString(parameters[Constant.FROM], Constant.FROM));
          globalHolder.setObject<string>(GlobalKey.OPEN_PAGE,
            AssertExtUtil.coverToString(parameters[Constant.OPEN_PAGE], Constant.OPEN_PAGE));
        });
      TaskManager.getInstance().execute<number>(task, 1, false, 30);
    }
    HiLog.info(TAG, 'initFromNotify end');
  }

  onNewWant(want: Want, launchParams: AbilityConstant.LaunchParam): void {
    HiLog.info(TAG, 'FileManager onNewWant');
    this.initFromNotify(want);
    EventBus.emit(Constant.EVENTS.FILE_MANAGER_ON_NEW_WANT);
  }

  onDestroy(): void {
    HiLog.info(TAG, 'onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    HiLog.info(TAG, 'onWindowStageCreate');
    const context = this.context;
    const globalHolder: GlobalHolder = GlobalHolder.getInstance();
    globalHolder.setObject<string>(GlobalKey.SAND_BOX_PATH, context.filesDir);
    AbilityCommonUtil.init().then(() => {
      windowStage.loadContent(PAGE_ROUTE_CONST.MAIN_ENTRY, this.storage, this.loadContentCallBack.bind(this));
    })
    try {
      windowStage.getMainWindow().then((windowObj) => {
        try {
          AppStorage.setOrCreate<window.Size>('windowSize', {
            width: windowObj.getWindowProperties().windowRect.width,
            height: windowObj.getWindowProperties().windowRect.height
          });
          this.initHeight(windowObj);
        } catch (err) {
          HiLog.error(TAG, 'Failed to get window width. Case:' + JSON.stringify(err));
        }
      })
    } catch (error) {
      HiLog.error(TAG, 'windowStage getMainWindow fail, error:' + JSON.stringify(error))
    }
    // 检查是否首次启动应用
    const isFirstLaunch = await CommonPreferenceUtil.getFirstLaunch();
    const status = await NotificationUtil.getNotificationStatus();
    HiLog.info(TAG, `isFirstLaunch=${JSON.stringify(isFirstLaunch)}`);
    HiLog.info(TAG, `notificationStatus=${JSON.stringify(status)}`);
    if (isFirstLaunch) {
      // 首次启动，申请通知权限
      NotificationUtil.requestEnableNotification();
      // 设置首次启动状态为 false
      await CommonPreferenceUtil.setFirstLaunch(false);
    }
  }

  // 监听相关高度
  initHeight(windowObj: window.Window): void {
    windowObj.on('windowSizeChange', (windowSize) => {
      AppStorage.setOrCreate<window.Size>('windowSize', windowSize);
      try {
        AppStorage.setOrCreate<number>('orientation', display.getDefaultDisplaySync().orientation);
      } catch (error) {
        HiLog.error(TAG, `getDefaultDisplaySync fail, error.code: ${error?.code}, error.message: ${error?.message}`);
      }
    });
    //获取分屏
    windowObj.on('windowStatusChange', (windowStatusChange: window.WindowStatusType) => {
      AppStorage.setOrCreate<number>('windowStatus', windowStatusChange);
    });
    // 小键盘规避
    windowObj.on('keyboardHeightChange', (data) => {
      const keyBoardHeightVp = px2vp(data);
      AppStorage.setOrCreate<number>('keyBoardHeight', keyBoardHeightVp);
    });

    // 规避区监听
    windowObj.on('avoidAreaChange', (data) => {
      if (window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR === data.type) { // 导航栏规避区
        const navigationHeight = Math.floor(px2vp(data.area.bottomRect.height));
        AppStorage.setOrCreate<number>('windowAvoidAreaNavigationRectHeight', navigationHeight);
        HiLog.info(TAG, 'windowAvoidAreaNavigationRectHeight change:' + navigationHeight);
      }
    });
  }

  loadContentCallBack(err: BusinessError, data: Object): void {
    if (err.code) {
      HiLog.error(TAG, 'Failed to load the content. Cause:' + JSON.stringify(err));
      return;
    }
    HiLog.info(TAG, 'Succeeded in loading the content. Data: ' + JSON.stringify(data));
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    HiLog.info(TAG, 'onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    let globalHolder: GlobalHolder = GlobalHolder.getInstance();
    globalHolder.setMainAbilityContext(this.context);
    globalHolder.setAppContext(this.context.getApplicationContext());
    globalHolder.setCommonContext(this.context);
    globalHolder.setObject<boolean>(GlobalKey.PICKER_FLAG, false);
    EventBus.emit(Constant.EVENTS.ABILITY_ON_FOREGROUND);
    EventBus.emit(Constant.EVENTS.ON_VIEW_FOREGROUND_EVENT);
    HiLog.info(TAG, 'MainAbility has brought to foreground');
  }

  onBackground(): void {
    // Ability has back to background
    HiLog.info(TAG, 'MainAbility has back to background');
    EventBus.emit(Constant.EVENTS.ON_BACKGROUND);
    EventBus.emit(Constant.EVENTS.ON_VIEW_BACKGROUND_EVENT);
  }
}