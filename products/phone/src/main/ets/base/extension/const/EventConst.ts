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
 * 文件app和文件管理app之间交互时的事件常量
 */
export class EventConst {
  /**
   * 跳转页面
   */
  public static readonly JUMP_PAGE: string = 'jumpPage';
  /**
   * 关闭关于页
   */
  public static readonly CLOSE_ABOUT_PAGE: string = 'closeAboutPage';
  /**
   * 导航模式变更，分栏或堆叠
   */
  public static readonly NAV_MODE_CHANGE: string = 'navModeChange';
  /**
   * 打开指定目录
   */
  public static readonly OPEN_FOLDER: string = 'openFolder';
  /**
   * 是否可以处理打开指定目录事件（用于冷启动时跳转指定目录）
   */
  public static readonly SET_CAN_RESOLVE_OPEN_FOLDER = 'setCanResolveOpenFolder';
  /**
   * 发布复制移动进度的通知栏消息
   */
  public static readonly PUBLISH_COPY_CUT_PROGRESS_NOTIFICATION: string = 'publishCopyCutProgressNotification';
  /**
   * 发布复制移动完成的通知栏消息
   */
  public static readonly PUBLISH_COPY_CUT_COMPLETE_NOTIFICATION: string = 'publishCopyCutCompleteNotification';
  /**
   * 取消复制移动进度的通知栏消息
   */
  public static readonly CANCEL_COPY_CUT_PROGRESS_NOTIFICATION: string = 'cancelCopyCutProgressNotification';
  /**
   * 取消复制移动完成的通知栏消息
   */
  public static readonly CANCEL_COPY_CUT_COMPLETE_NOTIFICATION: string = 'cancelCopyCutCompleteNotification';

  // 键盘高度变化
  public static readonly KEYBOARD_HEIGHT_CHANGE: string = 'keyboardHeightChange';

  // 窗口状态变化
  public static readonly WINDOW_STATUS_CHANGE: string = 'windowStatusChange';

  // 摄像头避免区域
  public static readonly CAMERA_AVOID_AREA: string = 'cameraAvoidArea';

  // 折叠机状态
  public static readonly FOLD_DEVICE_STATUS: string = 'deviceFoldStatus';

  // 显示屏相关信息
  public static readonly DISPLAY_INFO: string = 'displayInfo';
  /**
   * 检查通知栏状态
   */
  public static readonly CHECK_NOTIFICATION_STATUS: string = 'checkNotificationStatus';

  public static readonly WINDOW_STAGE_EVENT: string = 'windowStageEvent';

  // 设置屏幕旋转
  public static readonly SET_ORIENTATION: string = 'setOrientation';

  // 进入沉浸式模式
  public static readonly ENTRY_IMMERSIVE_MODE: string = 'entryImmersiveMode';

  // 保持屏幕常亮
  public static readonly WINDOW_KEEP_SCREEN_ON: string = 'windowKeepScreenOn';

  // 预览调用横竖屏
  public static readonly SWITCH_SCREEN_STATUS: string = 'switchScreenStatus';

  // 预览设置屏幕亮度
  public static readonly SET_BRIGHTNESS_VALUE: string = 'setBrightnessValue';

  // 恢复复状态栏颜色
  public static readonly RESET_SYSTEM_BAR_COLOR: string = 'resetSystemBarColor';

  // 外部通过UIExtensionAbility拉起聚合页的场景下，在退出文管页面时给宿主应用发的消息，方便宿主应用处理回退逻辑
  public static readonly OPEN_MEDIA_FINISH: string = 'openMediaFinish';

  // 进入壁纸编辑模式
  public static readonly SWITCH_WALLPAPER_LOCK_MODE: string = 'switchWallPaperLockMode';

  // 在实况通知栏取消复制移动
  public static readonly CANCEL_COPY_CUT: string = 'cancelCopyCut';

  // 同意隐私状态同步
  public static readonly AGREE_PRIVACY_STATE_SYNC: string = 'agreePrivacyStateSync';

  // APP引导页确认状态同步
  public static readonly APP_GUIDANCE_STATE_SYNC: string = 'appGuidanceStateSync';

  // filemanager兼容性版本号同步
  public static readonly APP_COMPATIBLE_VERSION: string = 'appCompatibleVersion';
}