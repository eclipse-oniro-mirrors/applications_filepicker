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

/**
 * 存放原来挂载到GlobalThis的对象的Key
 * 注意：
 * 1. 预期挂载到GlobalThis的对象的Key，统一在该类中注册
 * 2. 调用方法详见GlobalThisHolder
 */
export class GlobalKey {
  static readonly WINDOW_CLASS_EXT: string = 'UIExtensionContentSession';

  static readonly WINDOW_PATH_PICKER_CLASS: string = 'windowPathPickerClass';

  static readonly WINDOW_FILE_PICKER_CLASS: string = 'windowFILEPickerClass';

  // 获取want，用于业务跳转
  static readonly ABILITY_WANT: string = 'abilityWant';

  // 获取ability级别的context，用于获取resourceManager等接口
  static readonly ABILITY_CONTEXT: string = 'abilityContext';

  // pathAbilityWant
  static readonly PATH_ABILITY_WANT: string = 'pathAbilityWant';

  // abilitykey，标识对应ability名
  static readonly ABILITY_KEY: string = 'abilityKey';

  // 选择器标识
  static readonly PICKER_FLAG: string = 'filePickerViewFlag';

  // Picker调用方token
  static readonly PICKER_TOKEN: string = 'filePickerToken';

  // 来源
  static readonly FROM: string = 'from';

  // 需要跳转的页面
  static readonly OPEN_PAGE: string = 'openPage';

  // uri路径
  static readonly URI_PATH: string = 'uriPath';

  // 缓存目录
  static readonly SAND_BOX_PATH: string = 'sandboxPath';

  // 选择器选择类型
  static readonly PICK_TYPE_LIST: string = 'keyPickTypeList';

  // 选择文件个数上限
  static readonly PICK_NUM_LIMIT: string = 'filePickNum';

  // 选择文件区域
  static readonly PICK_LOCATION: string = 'filePickLocation';

  // 选择器默认跳转路径
  static readonly PICK_DEFAULT_DIR: string = 'keyFileDefaultPickPath';

  // 选择器选择模式
  static readonly PICK_SELECT_MODE: string = 'keySelectMode';

  // 选择器选择文件后缀
  static readonly PICK_SUFFIX: string = 'keyFileSuffixFilter';

  // 选择器callerId
  static readonly PICK_CALLER_UID: string = 'pickerCallerUid';

  // 选择器caller包名
  static readonly PICK_CALLER_BUNDLE_NAME: string = 'pickerCallerBundleName';

  // 路径选择器context
  static readonly PATH_ABILITY_CONTEXT: string = 'pathAbilityContext';

  // 保存文件的名称
  static readonly SAVE_FILE_NAME: string = 'keyPickFileName';

  static readonly SAVE_FILE_PATHS: string = 'keyPickFilePaths';

  // 路径选择器默认路径
  static readonly SAVE_DEFAULT_DIR: string = 'keyPathDefaultPickDir';

  // 路径选择器文件后缀
  static readonly SAVE_FILE_SUFFIX: string = 'keyFileSuffixChoices';

  // 路径选择器callerUid
  static readonly SAVE_CALLER_UID: string = 'pathCallerUid';

  // 路径选择器calller bundleName
  static readonly SAVE_CALLER_BUNDLE_NAME = 'pathCallerBundleName';

  // 路径选择器区域
  static readonly SAVE_LOCATION = 'keyPickFileLocation';

  // 模态窗口标识
  static readonly PICKER_EXTENSION = 'serviceExtension';

  // 模态窗口销毁函数
  static readonly PICKER_ON_DESTROY = 'onDestroyWindow';

  // 手机存储根目录uri
  static readonly LOCAL_ROOT_URI = 'localRootUri';

  // 我的手机是否在展示
  static readonly MY_PHONE_IS_SHOW = 'myPhoneIsShow';

  // 是否已经设置缩略图缓存大小
  static readonly IS_SET_IMAGE_CACHE = 'IsSetImageRawDataCacheSize';

  // 移动标识
  static readonly MOVE_TYPE = 'moveType';

  // 是否是直板机（即除了平板、折叠屏之外的手机）
  static readonly IS_DIRECT_PHONE = 'isDirectPhone';

  // 桌面操作上下文信息
  static readonly DESKTOP_OPT_CONTEXT = 'DesktopOptContext';

  //第二次拉起FilePicker的标记位
  static readonly OPEN_FILE_PICKER_AGAIN = 'openFilePickerAgain';

  // abilitykey，标识对应ability名
  static readonly APP_VERSION: string = 'appVersionKey';

  // 拖拽唯一标识，识别来源
  static readonly DRAG_INFO_TIME = 'dragInfoTime';

  // 文件服务接口上下文信息
  static readonly FILE_MANAGER_SERVICE_CONTEXT = 'fileManagerServiceContext';

  // 跳转并高亮的文件uri列表
  static readonly FILE_URI_ARRAY: string = 'fileUriArray';

  // 手机文管启动时，初始化固定的Local rootInfo 并通过volume获取的挂载信息
  static readonly INIT_ROOT_INFO_ON_PHONE_FIRST_LOAD = 'initRootInfoOnPhoneFirstLoad';

  // 显示屏相关信息
  static readonly DISPLAY_INFO: string = 'displayInfo';

  // 跳转的页面
  static readonly JUMP_PAGE: string = 'jumpPage';

  // 外屏FilePicker是否显示权限安全提示
  static readonly SHOW_PERMISSION_SECURITY_PICKER_POPUP = 'showPermissionSecurityPickerPopup';

  // 开放媒体能力类型
  static readonly OPEN_MEDIA_TYPE: string = 'openMediaType';

  // 开放媒体类型调用者包名
  static readonly OPEN_MEDIA_CALLER_BUNDLE_NAME: string = 'openMediaCallerBundleName';

  // 壳应用兼容性版本, ShellAppCompatibleVersion
  static readonly SHELL_APP_COMPATIBLE_VERSION = 'shellAppCompatibleVersion';

  // 是否为无障碍模式
  static readonly IS_ACCESSIBILITY_MODE: string = 'isAccessibilityMode';

  // 是否进入预览 dialog 页面
  static readonly IS_PREVIEW_DIALOG: string = 'isPreviewDialog';
}