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

import { WindowType, SelectMode, UnityStartMode } from '../const/FilePickerItems';
import { StringUtil } from '../utils/StringUtil';
import { common, UIExtensionContentSession } from '@kit.AbilityKit';
import { CustomTheme } from '@ohos.arkui.theme';
import { ApplicationThemeColor } from './ApplicationThemeColor';

const TAG: string = 'startModeOptions';

export class StartModeOptions {
  /****************************    picker  *********************************/
  /**************    common  *******************/
  /**
   * picker场景下，界面模式
   */
  public windowType = WindowType.ABILITY;

  public session: UIExtensionContentSession;

  /**
   * want对应的action
   */
  public action: string = '';

  /**
   * 拉起picker的应用ability名
   */
  public callerAbilityName: string = '';

  /**
   * 拉起picker的包名
   */
  public callerBundleName: string = '';

  /**
   * 选择器callerId
   */
  public callerUid: number = 0;

  /**
   * 应用分身id，0表示主应用
   */
  public appCloneIndex: number = 0;

  /**
   * 拉起picker的默认文件或者指定目录
   */
  public defaultFilePathUri: string = '';

  /**
   * 代表拉起sysPicker/filePicker类型的ExtensionAbility
   */
  public extType: string = '';

  /**
   * UIAbilityContext
   */
  public uiContext: common.UIAbilityContext;

  /**
   * UIExtensionContext
   */
  public uiExtContext: common.UIExtensionContext;

  /**
   * ServiceExtensionContext
   */
  public serviceContext: common.ServiceExtensionContext;

  public context: common.UIExtensionContext | common.UIAbilityContext | common.ServiceExtensionContext;

  /**
   * 是否是picker模式
   */
  public pickerFlag: boolean = false;

  /**
   * 是否支持文件加密，参数选填；DEFAULT:false
   * false:不支持文件加密；true:支持文件加密
   */
  public isEncryptionSupported: boolean = false;

  /**
   * 用来区分选择，保存还是下载模式
   * 当pickerType设置为downloadAuth时，用户配置的参数newFileNames、defaultFilePathUri和fileSuffixChoices将不会生效
   */
  public pickerType: string = 'DEFAULT';

  /**
   * 后缀描述
   */
  public suffixesDescriptions: string[] = [];

  /**************    select  *******************/
  /**
   * 选择文件的后缀类型
   */
  public fileSuffixFilters: string[] = [];

  /**
   * 选择文件最大个数，上限500, 默认为1
   */
  public maxSelectNumber: number = 1;

  /**
   * 支持选择的资源类型，比如：文件、文件夹和二者混合
   */
  public selectMode: SelectMode = SelectMode.FILE;

  /**
   * 当为授权模式，defaultFilePathUri必填，表明待授权uri
   */
  public isAuthMode: boolean = false;

  /**
   * 调用方传入文件类型（兼容双框架action）
   */
  public phonePickerType: string = '';

  /**
   * 调用方传入文件类型列表
   */
  public phonePickerTypeList: string[] = [];


  /**************    save  *******************/
  /**
   * 进行保存的文件名列表
   */
  public newFileNames: string[] = [];

  /**
   * 保存文件的后缀类型
   */
  public fileSuffixChoices: string[] = [];

  /**
   * 手机保存文件的后缀类型
   */
  public PhoneFileSuffixChoices: string = '';

  /**
   * 是否增量授权模式
   * 该模式会隐藏已持久化授权的文件
   */
  public isPersistPermission: boolean = false;

  public tokenID: number = 0;

  /****************************    主界面模式  *********************************/
  /**
   * 文管启动模式，只允许初始化过程修改一次，默认为主界面模式
   */
  public startMode: UnityStartMode = UnityStartMode.NORMAL;

  public currentCreateTimeStamp : number = new Date().getTime();

  /*
   * 是否是批量授权模式
   * */
  public isBatchAuthMode: boolean = false;

  /*
   * 批量授权接收的uri列表
   * */
  public batchAuthUris: string[] = [];

  /**
   * 拉起picker方的pid，用于传递给星盾动效组件
   * */
  public callerPid: string = '';

  /**
   * 应用传入自定义主题色
   * */
  public customTheme: CustomTheme = ApplicationThemeColor.defaultTheme();

  public udkey: string = '';

  public getFileSuffixFilterList(): string[] {
    if (this.fileSuffixFilters.length === 0) {
      this.fileSuffixFilters.push('.*');
    }
    return this.fileSuffixFilters;
  }

  public initStartMode(): void {
    if (this.isCreateFileMode()) {
      this.startMode = UnityStartMode.FILE_PICKER_CREATE;
    } else if (this.isAuthMode) {
      this.startMode = UnityStartMode.GRANT_PERMISSION;
    } else {
      switch (this.selectMode) {
        case SelectMode.FILE:
          this.startMode = UnityStartMode.FILE_PICKER_OPEN_FILE;
          break;
        case SelectMode.FOLDER:
          this.startMode = UnityStartMode.FILE_PICKER_OPEN_FOLDER;
          break;
        case SelectMode.MIXED:
          this.startMode = UnityStartMode.FILE_PICKER_OPEN_MIXED;
          break;
        default:
          this.startMode = UnityStartMode.FILE_PICKER_CREATE;
          break;
      }
    }
  }

  public setSelectMode(mode: number | undefined): void {
    if (mode === undefined) {
      this.selectMode = SelectMode.FILE;
      return;
    }
    if ((mode < SelectMode.FILE) || (mode > SelectMode.MIXED)) {
      this.selectMode = SelectMode.FILE;
      return;
    }
    this.selectMode = mode;
  }

  public loadSuffixes(keySuffixes: string[]): void {
    if (!keySuffixes || keySuffixes.length === 0) {
      return;
    }
    let descriptions: string[] = [];
    let suffixes: string[] = [];
    keySuffixes.forEach((v) => {
      let arr = v.split('|');
      if (arr.length === 1) {
        descriptions.push(v);
        suffixes.push(v);
      } else if (arr.length >= 2) {
        descriptions.push(arr[0]);
        suffixes.push(arr[1]);
      }
    });
    this.suffixesDescriptions = descriptions;
    if (this.isOpenFileMode()) {
      this.fileSuffixFilters = suffixes;
    } else if (this.isCreateFileMode()) {
      this.fileSuffixChoices = suffixes;
    }
  }

  public setNewFileNames(names: string[] | undefined): void {
    if (names === undefined || names.length === 0) {
      this.newFileNames = [''];
      return;
    }
    this.newFileNames = names;
  }

  public isDownloadMode(): boolean {
    return this.pickerType === 'downloadAuth';
  }

  public isFilePickerMode(): boolean {
    if (this.pickerFlag) {
      return true;
    }
    return this.startMode !== UnityStartMode.NORMAL;
  }

  public isGrantPermissionMode(): boolean {
    return this.isAuthMode;
  }

  public isSelectFolderMode(): boolean {
    return this.startMode === UnityStartMode.FILE_PICKER_OPEN_FOLDER;
  }

  public isOpenFileMode(): boolean {
    // 新方案需要通过pickerType区分
    return this.action === 'ohos.want.action.OPEN_FILE_SERVICE' || this.action === 'ohos.want.action.OPEN_FILE' ||
      this.pickerType === 'select';
  }

  public isCreateFileMode(): boolean {
    // 新方案需要通过pickerType区分
    return this.action === 'ohos.want.action.CREATE_FILE_SERVICE' || this.action === 'ohos.want.action.CREATE_FILE' ||
      this.pickerType === 'save';
  }

  public isValidOpenOptions(): boolean {
    if (!this.isOpenFileMode()) {
      return false;
    }
    if (this.isAuthMode) {
      return !StringUtil.isEmpty(this.defaultFilePathUri);
    }
    if (this.fileSuffixFilters.length > 100) {
      return false;
    }
    if (this.maxSelectNumber < 1 || this.maxSelectNumber > 500) {
      return false;
    }
    return true;
  }

  public isValidSaveOptions(): boolean {
    if (!this.isCreateFileMode()) {
      return false;
    }
    if (this.fileSuffixChoices.length > 100) {
      return false;
    }
    return true;
  }

  public isValidOptions(): boolean {
    return this.isValidOpenOptions() || this.isValidSaveOptions() || this.isDownloadMode();
  }

  public isUxt(): boolean {
    return this.windowType === WindowType.UI;
  }

  public setUiExtContext(context: common.UIExtensionContext): void {
    this.uiExtContext = context;
  }
}