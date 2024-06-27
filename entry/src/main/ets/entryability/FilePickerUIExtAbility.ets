/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023. All rights reserved.
 */

import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import { BusinessError } from '@kit.BasicServicesKit';
import type Want from '@ohos.app.ability.Want';
import dataPreferences from '@ohos.data.preferences';
import Logger from '../base/log/Logger';
import { StartModeOptions } from '../base/model/StartModeOptions';
import { PickerWindowType } from '../base/constants/FilePickerItems';
import { UIExtensionContentSession } from '@kit.AbilityKit';
import AbilityCommonUtil from '../base/utils/AbilityCommonUtil';
import { FilePickerUtil } from '../base/utils/FilePickerUtil';
import bundleResourceManager from '@ohos.bundle.bundleResourceManager';

const TRANSPARENT_COLOR = '#00000000';

const TAG: string = 'FilePickerUIExtAbility';

export default class FilePickerUIExtAbility extends UIExtensionAbility {
  private abilityKey: string = '';
  private securityPreferences?: dataPreferences.Preferences;
  private storage: LocalStorage = new LocalStorage();

  onCreate(): void {
    Logger.i(TAG, 'FilePickerUIExtAbility onCreate');
  }

  async onSessionCreate(want: Want, session: UIExtensionContentSession): Promise<void> {
    Logger.i(TAG, 'FilePickerUIExtAbility onSessionCreate, want: ' + JSON.stringify(want));
    globalThis.abilityContext = this.context;
    let options = this.initParam(want, session);
    this.getAppResourceInfo(options.callerBundleName, this.storage);
    if (options.isDownloadMode()) {
      this.initSessionDownloadAuth(session);
      return;
    }

    this.abilityKey = `${TAG}+${Date.now()}`;
    if (options.isOpenFileMode()) {
      this.initSessionFilePicker(session);
      return;
    }

    if (options.isCreateFileMode()) {
      this.initSessionPathPicker(session);
      return;
    }
  }

  onSessionDestroy(session: UIExtensionContentSession): void {
    Logger.i(TAG, 'FilePickerUIExtAbility onSessionDestroy');
  }

  onDestroy(): void {
    Logger.i(TAG, 'FilePickerUIExtAbility onDestroy');
  }

  private getAppResourceInfo(bundleName: string, storage: LocalStorage): void {
    Logger.i(TAG, `getAppResourceInfo start`)
    const bundleFlags = bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_ALL;
    try {
      const resourceInfo = bundleResourceManager.getBundleResourceInfo(bundleName, bundleFlags);
      storage.setOrCreate<string>('appName', resourceInfo.label);
      storage.setOrCreate<string>('appIcon', resourceInfo.icon);
    } catch (err) {
      const message = (err as BusinessError).message;
      Logger.e(TAG, 'getBundleResourceInfo failed: %{public}s' + message);
    }
  }

  initParam(want: Want, session: UIExtensionContentSession): StartModeOptions {
    let options: StartModeOptions = FilePickerUtil.getStartModeOptions(want);
    options.windowType = PickerWindowType.UI;
    options.setUiExtContext(this.context);
    options.context = this.context;
    options.session = session;
    options.fileSuffixFilters = AbilityCommonUtil.getKeyFileSuffixFilter(options.fileSuffixFilters);
    if (options.isOpenFileMode()) {
      options.fileSuffixFilters = AbilityCommonUtil.getKeyFileSuffixFilter(options.fileSuffixFilters);
      options.phonePickerType = (want.parameters?.key_pick_type as string) || '';
      options.phonePickerTypeList = AbilityCommonUtil.getKeyPickTypeList(want.parameters?.key_picker_type as object,
        want.parameters?.key_picker_type_list as object)
    }
    if (options.isCreateFileMode()) {
      options.PhoneFileSuffixChoices = AbilityCommonUtil.getKeyFileSuffixChoices(options.fileSuffixChoices);
    }
    this.storage.setOrCreate<StartModeOptions>('startModeOptions', options);
    return options;
  }

  private initSessionDownloadAuth(session: UIExtensionContentSession) {
    Logger.i(TAG, `initSessionDownloadAuth start`)
    session.loadContent('pages/DownloadAuth', this.storage);
    session.setWindowBackgroundColor(TRANSPARENT_COLOR);
  }

  private initSessionFilePicker(session: UIExtensionContentSession) {
    Logger.i(TAG, `initSessionFilePicker start`)
    try {
      const promise = dataPreferences.getPreferences(this.context, 'securityWarning');
      promise.then(async (object) => {
        this.securityPreferences = object;
        Logger.i(TAG, 'Succeeded in getting preferences.');
        const hasSecurityWarning = this.securityPreferences.hasSync('securityWarning');
        if (!hasSecurityWarning) {
          await this.securityPreferences.put('securityWarning', '1');
          await this.securityPreferences.flush();
          this.storage?.setOrCreate('securityWarning', '1');
          Logger.i(TAG, 'dataPreferences.flush');
        }
      }).catch((err: BusinessError) => {
        console.error('Failed to get preferences. code =' + err.code + ', message =' + err.message);
      })
    } catch (err) {
      console.error('Failed to get preferences. code =' + err.code + ', message =' + err.message);
    }
    AbilityCommonUtil.init().then(() => {
      session.loadContent('pages/browser/storage/MyPhone', this.storage);
      session.setWindowBackgroundColor(TRANSPARENT_COLOR);
    });
  }

  private initSessionPathPicker(session: UIExtensionContentSession) {
    Logger.i(TAG, `initSessionPathPicker start`)
    AbilityCommonUtil.init().then(() => {
      session.loadContent('pages/PathPicker', this.storage);
      session.setWindowBackgroundColor(TRANSPARENT_COLOR);
    });
  }
};