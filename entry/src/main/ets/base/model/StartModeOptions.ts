/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { common, Context, UIExtensionContentSession } from '@kit.AbilityKit';
import { PickerWindowType, SelectMode, UnityStartMode } from '../constants/FilePickerItems';

export class StartModeOptions {
  /****************************    picker  *********************************/
  /**************    common  *******************/
  /**
   * picker场景下，界面模式
   */
  public windowType = PickerWindowType.ABILITY;

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
   * 拉起picker的默认文件或者指定目录
   */
  public defaultFilePathUri: string = '';

  /**
   * 代表拉起sysPicker/filePicker类型的ExtensionAbility
   */
  public extType: string = '';

  /**
   * UIExtensionContext
   */
  public uiExtContext: common.UIExtensionContext;

  /**
   * UIExtensionContext
   */
  public uiContext: common.UIAbilityContext;

  /**
   * context
   */
  public context: Context;


  /**
   * 用来区分选择，保存还是下载模式
   * 当pickerType设置为downloadAuth时，用户配置的参数newFileNames、defaultFilePathUri和fileSuffixChoices将不会生效
   */
  public pickerType: string = 'DEFAULT';

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


  /****************************    主界面模式  *********************************/
  /**
   * 文管启动模式，只允许初始化过程修改一次，默认为主界面模式
   */
  public startMode: UnityStartMode = UnityStartMode.NORMAL;

  public getFileSuffixFilterList(): string[] {
    if (this.fileSuffixFilters.length === 0) {
      this.fileSuffixFilters.push('.*');
    }
    return this.fileSuffixFilters;
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

  public setNewFileNames(names: string[] | undefined): void {
    if (names === undefined) {
      this.newFileNames = [];
      return;
    }
    if (names.length === 0) {
      this.newFileNames = [''];
      return;
    }
    this.newFileNames = names;
  }

  public isDownloadMode(): boolean {
    return this.pickerType === 'downloadAuth';
  }

  public isGrantPermissionMode(): boolean {
    return this.isAuthMode;
  }

  public isSelectFolderMode(): boolean {
    return this.startMode === UnityStartMode.FILE_PICKER_OPEN_FOLDER;
  }

  public isOpenFileMode(): boolean {
    // 新方案需要通过pickerType区分
    return this.action === 'ohos.want.action.OPEN_FILE_SERVICE' || this.action === 'ohos.want.action.OPEN_FILE';
  }

  public isCreateFileMode(): boolean {
    // 新方案需要通过pickerType区分
    return this.action === 'ohos.want.action.CREATE_FILE_SERVICE' || this.action === 'ohos.want.action.CREATE_FILE';
  }

  public isUxt(): boolean {
    return this.windowType === PickerWindowType.UI;
  }

  public setUiExtContext(context: common.UIExtensionContext): void {
    this.uiExtContext = context;
  }
}