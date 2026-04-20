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

import {
  AbilityCommonUtil,
  AbilityManagerUtil,
  AbilityName,
  AccessibilityManager,
  AssertExtUtil,
  FilePickerUtil,
  FileUtil,
  GlobalHolder,
  GlobalKey,
  HiLog,
  LocalStorageConst,
  PAGE_ROUTE_CONST,
  PickerWindowType,
  StartModeOptions,
  VirtualUri,
  SecurityData,
  SecurityWarning,
  StringUtil,
  ObjectUtil,
  HiSysEventUtil,
  DFX,
  UEUtil,
  Constant,
  SettingsSaveObject,
  SettingsUtil,
  EventBus,
  DisplayUtil,
  FileAccessUtil,
  ParseUtil,
  UsageHabitsPreferenceUtil
} from '@ohos/common';
import { ability, bundleResourceManager, UIExtensionContentSession } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import type Want from '@ohos.app.ability.Want';
import dataPreferences from '@ohos.data.preferences';
import fs from '@ohos.file.fs';
import { uiExtensionHost, window } from '@kit.ArkUI';
import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import { UiExtensionHostUtilTemp } from '../../base/utils/UiExtensionHostUtilTemp';
const TRANSPARENT_COLOR: string = '#00000000';

const TAG: string = 'FilePickerUIExtAbility';

export default class FilePickerUIExtAbility extends UIExtensionAbility {
  private abilityKey: string = '';
  private abilityName: AbilityName = AbilityName.FILE_PICKER;
  private storage: LocalStorage = new LocalStorage();
  private windowProxy?: uiExtensionHost.UIExtensionHostWindowProxy;

  onCreate(): void {
    HiLog.info(TAG, 'FilePickerUIExtAbility onCreate');
    let applicationContext = this.context.getApplicationContext();
    try {
      applicationContext.setSupportedProcessCache(true);
    } catch (error) {
      HiLog.error(TAG, 'setSupportedProcessCache fail, error: ' + JSON.stringify(error));
    }
    HiLog.info(TAG, 'FilePickerUIExtAbility onCreate finish');
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    if (!want || !want.parameters) {
      HiLog.info(TAG, 'onSessionCreate failed, error param');
      return;
    }
    HiLog.infoPrivate(TAG, 'FilePickerUIExtAbility onSessionCreate, want: ', JSON.stringify(want));
    const options = this.initParam(want, session);
    AccessibilityManager.getInstance().initAccessibilityModeListener();
    this.getAppResourceInfo(options.callerBundleName, this.storage);
    if (options.isDownloadMode()) {
      this.abilityName = AbilityName.DOWNLOAD_AUTH;
      this.createDownloadFolderForApp(options, session);
      AbilityManagerUtil.getInstance().addAbility(this.abilityName, options.callerBundleName);
      return;
    }
    // 保存一个值用于确保picker星盾动效只执行一次
    this.storage.setOrCreate('isFirstPickerShield', true);
    this.abilityKey = `${TAG}+${Date.now()}`;
    if (options.isOpenFileMode()) {
      GlobalHolder.getInstance().setObject<UIExtensionContentSession>(GlobalKey.WINDOW_CLASS_EXT, session);
      this.initSessionFilePicker(session, options);
      this.abilityName = AbilityName.FILE_PICKER;
      AbilityManagerUtil.getInstance().addAbility(this.abilityName, options.callerBundleName);
      UEUtil.reportCreateAbility(DFX.AbilityName.FILE_PICKER_EXT, options.callerBundleName);
      return;
    }

    if (options.isCreateFileMode()) {
      this.initSessionPathPicker(session, options);
      this.abilityName = AbilityName.PATH_PICKER;
      AbilityManagerUtil.getInstance().addAbility(this.abilityName, options.callerBundleName);
      UEUtil.reportCreateAbility(DFX.AbilityName.PATH_PICKER_EXT, options.callerBundleName);
      return;
    }
  }

  onSessionDestroy(session: UIExtensionContentSession): void {
    HiLog.info(TAG, 'FilePickerUIExtAbility onSessionDestroy');
  }

  onDestroy(): void {
    HiLog.warn(TAG, 'FilePickerUIExtAbility onDestroy');
    AppStorage.delete('storageDeviceList');
    FileAccessUtil.setStorageRefreshStatus(true);
    AbilityManagerUtil.getInstance().reduceAbility(this.abilityName);
    // filepicker进程保活，应用锁认证需要在每次拉起picker后重新判断
    HiLog.info(TAG, 'setFileManagerCertified false');
    HiLog.warn(TAG, 'FilePickerUIExtAbility onDestroy finish');
  }

  private getAppResourceInfo(bundleName: string, storage: LocalStorage): void {
    HiLog.info(TAG, `getAppResourceInfo start`);
    const bundleFlags = bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_ALL;
    try {
      const resourceInfo = bundleResourceManager.getBundleResourceInfo(bundleName, bundleFlags);
      HiLog.info(TAG, `getBundleResourceInfo successfully. Data label: ${resourceInfo.label}`);
      storage.setOrCreate<string>('appName', resourceInfo.label);
      storage.setOrCreate<string>('appIcon', resourceInfo.icon);
    } catch (err) {
      const message = (err as BusinessError).message;
      HiLog.error(TAG, `getBundleResourceInfo failed:${message}`);
    }
  }

  private initParam(want: Want, session: UIExtensionContentSession): StartModeOptions {
    let options: StartModeOptions = FilePickerUtil.getStartModeOptions(want);
    options.windowType = PickerWindowType.UI;
    options.pickerFlag = true;
    options.setUiExtContext(this.context);
    options.context = this.context;
    options.session = session;
    options.fileSuffixFilters = AbilityCommonUtil.getKeyFileSuffixFilter(options.fileSuffixFilters);
    this.windowProxy = session.getUIExtensionHostWindowProxy();
    UiExtensionHostUtilTemp.hidePrivacyContentForHost(this.windowProxy);
    this.getWindowAvoidArea();
    this.onWindowAvoidAreaChange();
    if (options.isOpenFileMode()) {
      UEUtil.reportPickerSelectParamsRecord(want);
      options.fileSuffixFilters = AbilityCommonUtil.getKeyFileSuffixFilter(options.fileSuffixFilters);
      options.phonePickerType = (AssertExtUtil.coverToString(want.parameters?.key_pick_type, 'key_pick_type'));
      options.phonePickerTypeList = AbilityCommonUtil.getKeyPickTypeList(want.parameters?.key_picker_type as object,
        want.parameters?.key_picker_type_list as object);
      if (this.isFileDefaultFileUri(options.defaultFilePathUri)) {
        options.fileSuffixFilters = [];
      }
      //增量授权模式
      let multiAuthMode = want.parameters?.key_mult_auth_mode as boolean ?? false;
      options.isPersistPermission = false;
      options.tokenID = want.parameters ? want.parameters[AbilityCommonUtil.CALLER_TOKEN] as number ?? 0 : 0;
      if (DisplayUtil.isOutsideFolded()) {
        AppStorage.setOrCreate<boolean>(GlobalKey.SHOW_PERMISSION_SECURITY_PICKER_POPUP, true);
      }
    }
    if (options.isCreateFileMode()) {
      UEUtil.reportPickerSaveParamsRecord(want);
      options.PhoneFileSuffixChoices = AbilityCommonUtil.getKeyFileSuffixChoices(options.fileSuffixChoices);
    }
    this.storage.setOrCreate<StartModeOptions>('startModeOptions', options);
    const holder: GlobalHolder = GlobalHolder.getInstance();
    holder.setObject<Want>(GlobalKey.ABILITY_WANT, want);
    holder.setObject<string>(GlobalKey.ABILITY_KEY, this.abilityKey);
    holder.setUIExtensionContext(this.context);
    holder.setAppContext(this.context.getApplicationContext());
    holder.setObject<number>(GlobalKey.PICKER_TOKEN,
      want.parameters ? want.parameters[AbilityCommonUtil.CALLER_TOKEN] as number : 0);
    if (options.callerBundleName === Constant.FILE_MANAGER_BUNDLE_NAME) {
      let object: SettingsSaveObject = SettingsUtil.getSettingsFromFilePath(SettingsUtil.SETTINGS_SAVE_FILE_URI);
      AppStorage.setOrCreate<boolean>('isUploadPicker', object.isUploadPicker);
      HiLog.info(TAG, `setFileManagerCertified start, ability: ${options.callerAbilityName}`);
    }
    return options;
  }

  private initSessionFilePicker(session: UIExtensionContentSession, startModeOptions: StartModeOptions): void {
    HiLog.info(TAG, `initSessionFilePicker start`);
    try {
      const promise = dataPreferences.getPreferences(this.context, SecurityData.SecurityWarning);
      promise.then(async (obj) => {
        if (ObjectUtil.isNullOrUndefined(obj)) {
          HiLog.error(TAG, 'Failed to get preferences obj is null');
          return;
        }
        let securityWarning = SecurityWarning.DISAGREE;
        if (!obj.hasSync(SecurityData.SecurityWarning)) {
          HiLog.info(TAG, 'preferences not has this key');
          securityWarning = SecurityWarning.DISAGREE;
        } else {
          securityWarning = await obj.get(SecurityData.SecurityWarning, SecurityWarning.DISAGREE) as SecurityWarning;
        }
        this.storage?.setOrCreate(SecurityData.SecurityWarning, securityWarning);
        HiLog.info(TAG, 'Succeeded in getting preferences ' + securityWarning);
      }).catch((err: BusinessError) => {
        HiLog.error(TAG, `Failed to getSync errcode = ${err.code} , errmessage = ${err.message}`);
      })
    } catch (err) {
      HiLog.error(TAG, `Failed to get preferences. code = ${err.code} , message = ${err.message}`);
    }
    AbilityCommonUtil.init(startModeOptions).finally(() => {
      session.loadContent(PAGE_ROUTE_CONST.MAIN_ENTRY, this.storage);
      session.setWindowBackgroundColor(TRANSPARENT_COLOR);
    });
  }

  private initSessionPathPicker(session: UIExtensionContentSession, startModeOptions: StartModeOptions): void {
    HiLog.info(TAG, `initSessionPathPicker start`);
    AbilityCommonUtil.init(startModeOptions).finally(() => {
      session.loadContent(PAGE_ROUTE_CONST.PATH_PICKER, this.storage);
      session.setWindowBackgroundColor(TRANSPARENT_COLOR);
      // 获取新的排序方式需要清除缓存下次从磁盘获取
      UsageHabitsPreferenceUtil.clearUsageHabitCache();
    });
  }

  /**
   * 获取窗口的避让区域的高度
   */
  private getWindowAvoidArea(): void {
    if (!this.windowProxy) {
      return
    }
    try {
      // 获取并保存底部导航条的高度
      const navBarAvoidArea = this.windowProxy.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
      AppStorage.setOrCreate<number>(LocalStorageConst.DEFAULT_BOTTOM_NAV_BAR_HEIGHT_ON_PICKER,
        px2vp(navBarAvoidArea.bottomRect.height));
      HiLog.info(TAG, 'bottomNavBarHeight:' + px2vp(navBarAvoidArea.bottomRect.height))
    } catch (error) {
      HiLog.error(TAG, `getWindowAvoidArea fail, error.code:${error?.code}, error.message:${error?.message}`);
    }
  }

  /**
   * 监听避让区域变化事件，重新设置避让区域的高度
   */
  private onWindowAvoidAreaChange(): void {
    if (!this.windowProxy) {
      return
    }
    try {
      this.windowProxy.on('avoidAreaChange', (data) => {
        if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          AppStorage.setOrCreate<number>(LocalStorageConst.DEFAULT_BOTTOM_NAV_BAR_HEIGHT_ON_PICKER,
            px2vp(data.area.bottomRect.height));
        }
        if (data.type === window.AvoidAreaType.TYPE_KEYBOARD) {
          AppStorage.setOrCreate<number>('keyBoardHeight',
            px2vp(data.area.bottomRect.height));
        }
        return;
      })
    } catch (error) {
      HiLog.error(TAG, 'windowProxy avoidAreaChange fail, error:' + JSON.stringify(error))
    }
  }

  /**
   * 为三方应用创建下载文件夹，返回创建uri给三方应用
   */
  private createDownloadFolderForApp(options: StartModeOptions, session: UIExtensionContentSession): void {
    HiLog.info(TAG, 'begin to create download folder for app ' + options.appCloneIndex);
    const bundleName: string = options.callerBundleName;
    let appDownloadUri: string = `${VirtualUri.DOWNLOAD}/${bundleName}`;

    if (options.appCloneIndex > 0) {
      const dataDir = ParseUtil.getSandboxDataDir(bundleName, options.appCloneIndex);
      appDownloadUri = `${VirtualUri.DOWNLOAD}/${dataDir}`;
    }
    const appDownloadPath: string = FileUtil.getPathFromUri(appDownloadUri);
    let resultCode: number = 0; // 成功为0, 失败为-1
    try {
      const isExist = fs.accessSync(appDownloadPath);
      if (!isExist) {
        fs.mkdirSync(appDownloadPath);
      }
    } catch (error) {
      resultCode = -1;
      HiLog.error(TAG, 'createDownloadUriForApp fail, error:' + JSON.stringify(error));
    }

    let abilityResult: ability.AbilityResult = {
      resultCode: resultCode,
      want: {
        parameters: {
          'ability.params.stream': [appDownloadUri]
        }
      }
    };
    session.terminateSelfWithResult(abilityResult, (error) => {
      HiLog.error(TAG, `terminateSelfWithResult is called = ${error?.code}`);
    });
    HiSysEventUtil.reportCreateDownloadFolder(bundleName);
    UEUtil.reportCreateDownloadFolder(bundleName);
  }

  private isFileDefaultFileUri(defaultUri: string): boolean {
    return !StringUtil.isEmpty(defaultUri) && FileUtil.getFileNameByUri(defaultUri)?.lastIndexOf('.') > -1;
  }

  onForeground(): void {
    HiLog.warn(TAG, 'onForeground.');
    let globalHolder: GlobalHolder = GlobalHolder.getInstance();
    globalHolder.setAppContext(this.context.getApplicationContext());
    globalHolder.setCommonContext(this.context);
    if (this.abilityName === AbilityName.DOWNLOAD_AUTH) {
      HiLog.warn(TAG, 'DOWNLOAD_AUTH onForeground.');
      return;
    }
    EventBus.emit(Constant.EVENTS.ON_VIEW_FOREGROUND_EVENT);
  }

  onBackground(): void {
    HiLog.warn(TAG, 'onBackground.');
    EventBus.emit(Constant.EVENTS.ON_VIEW_BACKGROUND_EVENT);
  }
};