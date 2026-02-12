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

import { osAccount } from '@kit.BasicServicesKit';
import lazy { UTD } from '../../../../indexLazyLoadTs';
import { window } from '@kit.ArkUI';

/**
 * 通用常量
 */
export class Constant {
  /**
   * 图标缩放宽度
   */
  static readonly APP_ICON_STANDARD_WIDTH: number = 192;

  // 客服电话
  public static readonly SERVICE_PHONE = '950800';
  // 文管应用包名
  public static readonly FILE_MANAGER_BUNDLE_NAME = 'com.ohos.filemanager';
  // 图库包名
  public static readonly GALLERY_BUNDLE_NAME = 'com.ohos.photos';
  // 图库目录中截图相册
  public static readonly SCREEN_SHOT_BUNDLE_NAME = 'com.ohos.screenshot';
  // 图库目录中屏幕录制相册
  public static readonly SCREEN_RECORDER_BUNDLE_NAME = 'com.ohos.screenrecorder';
  // 设置包名
  public static readonly SETTING_BUNDLE_NAME = 'com.ohos.settings';
  // 文件APP的包名
  public static readonly FILE_APP_PACKAGE_NAME = 'com.ohos.files';
  // 文件APP的包名
  public static readonly FILE_APP_UI_EXTENSION_ABILITY_NAME = 'UIExtAbility';

  public static readonly NO_MEDIA = '.nomedia';
  // 录音机
  public static readonly SOUND_RECORD_BUNDLE_NAME = 'com.ohos.soundrecorder';
  // 畅连
  public static readonly MEETIME = 'com.ohos.meetime';
  // 畅联服务
  public static readonly MEETIME_SERVICE = 'com.ohos.meetimeservice';

  public static readonly SOUND_RECORD_APPDATA_PATH: string =
    '/storage/Users/currentUser/appdata/el2/base/com.ohos.soundrecorder/haps/phone/files/';
  public static readonly SOUND_RECORD_MIGRATION_COMPLETE_FILE: string = 'migration-completed';

  // 最近删除最长保存时间（天数）
  public static DEFAULT_SAVE_DAY: number = 30;
  // 最近删除最长保存时间（毫秒数）
  public static DEFAULT_SAVE_TIME: number = 30 * 24 * 60 * 60 * 1000;
  // userId
  public static USER_ID = 100;
  // 我的手机uri
  public static readonly MY_PHONE_URI = 'file://docs/storage/Users/currentUser';
  // 媒体库物理路径头部
  public static readonly STORAGE_MEDIA_PATH_HEAD: string = '/storage/media/local/files/Docs';
  // 图库文件uri的头部
  public static readonly GALLERY_URI_HEAD = 'file://media/Photo';
  // 媒体库文件uri的头部
  public static readonly MediaLibrary_URI_HEAD = 'file://media';
  // 浏览器文件uri的头部
  public static readonly BROWSER_URI_HEAD = 'file://com.ohos.browser';
  // 文管沙箱目录files层根路径
  public static readonly SANDBOX_FILES_ROOT = '/data/storage/el2/base/files';
  // 文管沙箱base路径
  public static readonly SANDBOX_EL2_BASE_PATH = '/data/storage/el2/base';
  // 文管沙箱目录el1路径，仅用于el1下文件夹名称处理
  public static readonly SANDBOX_EL1 = 'file://docs/storage/Users/currentUser/appdata/el1/base';
  // 文管沙箱目录el2路径，仅用于el2下文件夹名称处理
  public static readonly SANDBOX_EL2 = 'file://docs/storage/Users/currentUser/appdata/el2/base';
  public static readonly SANDBOX_APPDATA_PATH = '/storage/Users/currentUser/appdata';
  public static readonly SANDBOX_APPDATA = 'file://docs/storage/Users/currentUser/appdata';
  // 我的手机根路径
  public static readonly INTERNAL_STORAGE_ROOT_PATH = '/storage/Users/currentUser';
  public static readonly RECENT_DB_ROOT_PATH = '/storage/Users/currentUser/.Recent';
  public static readonly TRASH_DB_ROOT_PATH = '/storage/Users/currentUser/.Trash';
  public static readonly THUMBS_DB_ROOT_PATH = '/storage/Users/currentUser/.thumbs';
  public static readonly DESKTOP_ROOT_PATH = '/storage/Users/currentUser/DeskTop';
  public static readonly MEDIA_ROOT_PATH = '/data/storage/el2/media';
  public static readonly EXTERNAL_STORAGE_URI = 'file://docs/storage/External';
  public static readonly UPDATE_BACKUP_PATH = '/storage/Users/currentUser/UpdateBackup';
  public static readonly PAD_SOUNDS_URI = 'file://docs/storage/Users/currentUser/Music/SoundRecorder';
  public static readonly TRASH_FOLDER_NAME = '.trash';
  public static readonly FOLDER_DCIM = 'DCIM';
  public static readonly FOLDER_PICTURES = 'Pictures';
  public static readonly FOLDER_SHARE = 'Share';
  public static readonly MY_PHONE_SHARE_PATH = '/storage/Users/currentUser/Share';
  public static readonly FOLDER_SOUNDS = 'Sounds';
  public static readonly PHONE_ROOT_MUSIC = 'Sounds';
  public static readonly PAD_FOLDER_SOUNDS = 'Music/SoundRecorder';
  public static readonly PAD_ROOT_MUSIC = 'Music';
  public static readonly ANDROID_FOLDER_NAME = '.android';
  public static readonly SANDBOX_SUFFIX = '_sandbox';
  public static readonly PHOTO_PAGE_TYPE = {

    CAMERA_PAGE: 'camera_page',

    ALBUM_PAGE: 'album_page',

    HW_SHARE_PAGE: 'hw_share_page',

    VIDEO_PAGE: 'video_page'
  };
  public static readonly PHOTO_ALBUM_LPATH = {
    LPATH_CAMERA: '/DCIM/Camera',
    LPATH_SCREEN_SHOT: '/Pictures/Screenshots',
    LPATH_SCREEN_RECORDING: '/Pictures/Screenrecords',
  };
  public static readonly HIDDEN_ITEM_FILTER: string = '[^.]*';
  public static readonly THREE_BUTTON_NAVIGATION_HEIGHT: number = 40;
  // 壳应用Common preference 文件路径
  public static readonly HM_FILES_COMMON_PREFERENCE_URL: string =
    '/storage/Users/currentUser/appdata/el2/base/com.ohos.files/haps/entry/preferences/common';
  // 备份壳应用Common preference 的文件路径
  public static readonly HM_FILES_COMMON_PREFERENCE_BACKUP_URL: string =
    '/storage/Users/currentUser/appdata/el2/base/com.ohos.filemanager/haps/phone/preferences/filesCommon';
  // 壳应用preference 的文件路径
  public static readonly HM_FILES_PREFERENCE_URL: string =
    '/storage/Users/currentUser/appdata/el2/base/com.ohos.files/haps/entry/preferences/';
  // fileManager Preference的文件路径
  public static readonly FILE_MANAGER_PREFERENCE_URL: string =
    '/storage/Users/currentUser/appdata/el2/base/com.ohos.filemanager/haps/phone/preferences/';
  public static readonly SYSTEM_FONT_SCALE: string = 'persist.sys.font_scale_for_user0';
  public static readonly MEDIA_VIEW = {
    MIN_SCALE: 1,
    MAX_SCALE: 2,
    MAX_MOVE_X: 100,
    COM_MAX_MOVE_Y: 200,
    MAX_MOVE_Y: 90,
    DEFAULT_HEIGHT: 150,
    DEFAULT_FIN: 2,
    DEFAULT_PIN: 1,
    ROTATE_DIVISOR6: 6,
    ROTATE_DIVISOR18: 18
  };
  // 编码方式
  public static readonly DECODING_MODE = [
    'UTF-8/GBK',
    'Simplified Chinese (GBK)',
    'Unicode (UTF-8)',
    'Western Europe (ISO-8859-1)',
    'Western languages (Windows)',
    'Korean (EUC-KR)',
    'Japanese (EUC-JP)',
    'Japanese (Shift_JIS)',
    'Japanese (ISO-2022-JP)',
    'Traditional Chinese (BIG5)',
    'Cyrillic (Windows-1251)',
    'Cp866 (Russian DOS)',
    'ISO-8859-2',
    'ISO-8859-3',
    'ISO-8859-4',
    'Cyrillic alphabet (ISO-8859-6)',
    'Greek (ISO-8859-7)',
    'Hebrew (ISO-8859-8)',
    'ISO-8859-9',
    'ISO-8859-10',
    'Thai (ISO-8859-11)',
    'ISO-8859-13',
    'ISO-8859-14',
    'ISO-8859-15',
    'ISO-8859-16',
    'ANSI (ASCII)',
    'Unicode (UTP-16LE)',
    'Unicode (UTP-16BE)'
  ];
  /**
   * 可以通过开放媒体能力拉起聚合视图的APP
   */
  public static readonly OPEN_MEDIA_APP_NAME = {
  }
  /**
   * 开放媒体能力拉起支持的传参
   */
  public static readonly OPEN_MEDIA_PARAMETER = {
    TYPE: 'openMedia.type'
  }
  public static readonly WINDOW_DISPLAY_MODE = {
    FULL_SCREEN: 1, // 全屏
    SPLIT_PRIMARY: 100, // 分屏主屏
    SPLIT_SECONDARY: 101, // 分屏次屏
    FLOATING: 102, // 悬浮窗
  };
  public static readonly TIME = {
    ONE_MILLISECOND: 1,
    ONE_SECOND: 1000,
    ONE_MINUTE: 60 * 1000,
    ONE_HOUR: 60 * 60 * 1000,
    ONE_DAY: 24 * 60 * 60 * 1000,
    ONE_WEEK: 7 * 24 * 60 * 60 * 1000,
    ONE_MONTH: 30 * 24 * 60 * 60 * 1000,
    ONE_YEAR: 365 * 24 * 60 * 60 * 1000
  };
  public static readonly BYTE = {
    STORAGE_KB: 1000, // 内存大小按1000进行换算
    ONE_KB: 1000,
    ONE_MB: 1000 * 1000,
    ONE_GB: 1000 * 1000 * 1000,
    ONE_TB: 1000 * 1000 * 1000 * 1000
  };
  public static readonly BYTE_SIZE_900 = 900;
  // 模块标识
  public static readonly TAB_ID = {
    TAB_BROWSE: 1, // 浏览
    TAB_ME: 2// 我的
  };
  public static readonly OPERATION_TYPE = {
    REMOVE: 'remove',
    IMPORT: 'import',
    MOVE: 'move',
    DETAIL: 'detail',
    COPY: 'copy',
    SAVE: 'save',
    PASTING: 'pasting',
    RENAME: 'rename',
    MORE: 'more',
    ROTATE: 'rotate',
    DELETE: 'delete',
    OTHER_APP: 'otherApp',
    PRINT: 'print',
    RENAME_FAIL: 'renameFail',
    MOVE_TO_CURRENT_FOLDER: 'moveToCurrentFolder',
    MOVE_TO_OTHER_FOLDER: 'moveToOtherFolder',
    ADD_FOLDER: 'addFolder',
    APP_INFO: 'appInfo',
    PLAY: 'play',
    PAUSE: 'pause',
    FAVORITES: 'favorites',
    FAVORITE: 'favorite',
    UNFAVORITE: 'unfavorite',
    RESTORE: 'restore',
    HARD_DELETE: 'hardDelete',
    SELECT_ALL: 'selectAll',
    DESELECT_ALL: 'deselectAll',
    OPEN_FOLDER: 'openFolder',
    MULTIPLE_CHOICE: 'multipleChoice',
    ARCHIVE_PREVIEW: 'archivePreview',
    CLEAR_RECENT_RECORD: 'clearRecentRecord',
    SET_AS_WALLPAPER: 'setAsWallpaper'
  };
  public static readonly COLUMN_TEMPLATE = {
    PHONE: 'repeat(auto-fit, 98vp)',
    OUTSIDE_SCREEN_PHONE: 'repeat(auto-fit, 88vp)'
  };
  // 订阅事件名
  public static readonly EVENTS = {
    GET_RECENT_DATA_FINISH: 'getRecentDataFinished',
    CLOSE_INFO_DISPLAY_DIALOGS: 'closeInfoDisplayDialogs', // 关闭信息展示类弹窗，如详情，重命名、删除确认弹窗等，其他操作类弹窗不关闭，如复制、移动、删除、还原等
    FAVORITE_REFRESH: 'FAVORITE', // 点击收藏
    EXIT_MULTI_STATE: 'exitMultiState', // 退出多选
    CHANGE_STATE_BROSE: 'changeStateBrose', // 修改当前状态为BROWSER
    PREVENT_BACK_PRESS: 'preventBackPress', // 通知主页是否拦截手机按钮返回事件
    BACK_PRESS: 'backPress', // 通知其他组件其所在页面触发了返回事件
    CONFLICT_DIALOG: 'conflictDialog', // 复制移动conflictDialog
    ERROR_PASTE_DIALOG: 'errorPasteDialog', // 复制移动错误Dialog
    EXCEPTION_PASTE_DIALOG: 'exceptionPasteDialog', // 复制移动异常Dialog
    COPY_CUT_START: 'copyCutStart', // 复制移动开始
    COPY_CUT_END: 'copyCutEnd', // 复制移动结束,
    COPY_CUT_REFRESH: 'copyCutRefresh', // 复制移动刷新
    COPY_CUT_PROGRESS_VISIBLE: 'copyCutVisible', // 复制移动弹框隐现
    CLOSE_COPY_CUT_DIALOG: 'closeAllDialog', // 关闭复制移动所有弹框
    PASTEBOARD_REMAINDER_DIALOG: 'pasteboardReminderDialog', // 粘贴板提醒弹窗
    PATH_SELECT_END: 'pathSelectEnd', // 路径选择完成
    RECENTLY_REFRESH: 'recently_refresh', // 刷新最近
    SD_USB_CHANGE: 'sdUsbChange', // sd卡状态变化
    PATH_PICKER_FOLDER_REFRESH: 'pathPickerFolderRefresh', // 路径选择器目录刷新
    OPEN_TARGET_FOLDER: 'openTargetFolder', // 拉起本地页面并跳转到指定目录
    REFRESH_SD_USB_SPACE_SIZE: 'refresh_usb_sd_space_size', // 刷新外置存储设备的空间大小
    REFRESH_PHONE_SPACE_SIZE: 'refresh_phone_space_size', // 刷新我的手机空间大小
    REFRESH_FOLDER_SUB_FILE_COUNT: 'refreshFolderSubFileCount', // 刷新文件夹的子项个数
    REFRESH_RECENT_DELETE_PAGE: 'refreshRecentDeletePage', // 刷新最近删除页数据
    RECENTLY_TIME_REFRESH: 'recently_time_refresh', // 刷新最近页显示时间
    PATH_PICKER_FOLDER_MKDIR: 'pathPickerFolderMkdir', // 路径选择器创建文件夹
    QUERY_DISK_INFO_FINISH: 'queryDiskInfoFinish', // 查询挂载信息结束
    BACK_TO_PRIVACY_FROM_STATEMENT: 'backToPrivacyFromStatement',
    FILE_MANAGER_ON_NEW_WANT: 'FileManager_onNewWant',
    SHOW_WAITING_DIALOG: 'showWaitingDialog', // 显示请稍候...弹窗
    FINISH_DOWNLOAD_BY_PROGRESS_DIALOG: 'finishDownloadByProgressDialog', // 下载进度完成
    CLOSE_WAITING_DIALOG: 'closeWaitingDialog', // 手动关闭请稍候...弹窗
    CANCEL_WAITING_DIALOG: 'cancelWaitingDialog', // 取消请稍候...弹窗
    SHOW_DOWNLOAD_PROGRESS_DIALOG: 'showDownloadProgressDialog', // 显示准备文件弹窗
    CLOSE_DOWNLOAD_PROGRESS_DIALOG: 'closeDownloadProgressDialog', // 手动准备文件弹窗
    CANCEL_DOWNLOAD_PROGRESS_DIALOG: 'cancelDownloadProgressDialog', // 取消准备文件弹窗
    ABILITY_ON_FOREGROUND: 'ability_onForeground', // 应用的Ability进入前台后触发读取剪切板数据的场景下使用
    ON_BACKGROUND: 'onBackGround', // MainAbility进入后台
    MEDIAVIEW_OPERATE: 'viewOperate',
    ACCOUNT_LOGIN: 'accountLogin', // 账号登录
    ACCOUNT_LOGOUT: 'accountLogout', // 账号退出
    FILE_VIEW_CHECK: 'fileViewCheck',
    FILE_VIEW_RENAME: 'fileViewRename',
    DRAG_DROP: 'dragDrop', // 拖拽释放
    TAB_CHANGE: 'onTabChange', // tab切换消息
    REFRESH_DEVICE_ITEM: 'refreshDeviceItem', // 刷新设备列表
    TO_BROWSER_TAB: 'toBrowserTab', // 切换到浏览tab
    STOP_COPY_CUT_TASK: 'stopCopyCutTask', // 终止复制移动
    START_DELETE_RESTORE_FILE_TASK: 'startDeleteRestoreTask', // 开始删除或还原文件的任务
    DELETE_RESTORE_FILE_TASK_END: 'deleteRestoreTaskEnd', // 删除或还原文件的任务结束
    REMOVE_DELETED_RESTORED_FILE_FROM_LIST: 'removeDeletedRestoredFileFromList', // 从列表中移除删除和还原成功的文件
    SHOW_UNABLE_OPEN_DELETED_FILE_DIALOG: 'unableOpenDeletedFileDialog', // 点击文件提示无法打开弹窗
    SHOW_RECENT_DELETED_FILE_DETAIL_DIALOG: 'recentDeleteFileDetailDialog', // 点击最近删除的文件打开详情弹窗
    STOP_DOWNLOAD_FILES: 'stopDownloadFiles', // 取消全部下载
    TO_FOLDED_STATUS: 'toFoldedStatus', // 折叠屏折叠态,
    RESET_LOCAL_CLOUD_FOLDER: 'resetLocalOrCloudFolder',
    UPDATE_DELETED_RESTORED_FILE_COUNT: 'updateDeletedRestoredFileCount', // 更新已删除和还原文件的个数
    TAG_CHANGE_OF_FILE: 'tagChangeOfFile', // 文件上标签改变
    TRASH_FILE_CHANGE: 'trashFileChange', // 回收站文件变化
    TRASH_CHANGE: 'trashChange', // 回收站变化
    TAG_CHANGE: 'tagChange', // 标签自身属性改变
    FILE_CHANGE_OF_TAG: 'fileChangeOfTag', // 标签下的文件改变
    DIALOG_LOADED: 'dialog_loaded', // dialog进度
    LONG_PRESS_RINGTONE: 'longPressRingtone', //长按设置铃声操作
    LONG_PRESS_WALLPAPER: 'longPressWallpaper', // 长按设置为壁纸
    LONG_PRESS_SHARE: 'longPressShare', // 长按分享操作
    LONG_PRESS_COPY: 'longPressCopy', // 长按复制操作
    LONG_PRESS_MOVE: 'longPressMove', // 长按移动操作
    LONG_PRESS_DELETE: 'longPressDelete', // 长按删除操作
    LONG_PRESS_RENAME: 'longPressRname', // 长按重命名操作
    LONG_PRESS_RESTORE: 'longPressRestore', // 长按还原操作
    LONG_PRESS_CLEAR_RECENT_RECORD: 'longPressClearRecentRecord', // 删除最近访问记录
    FILE_RENAME: 'fileRename', // 重命名文件
    FILE_DELETE: 'fileDelete', // 删除文件
    FILE_DETAIL: 'file_detail', // 文管详情
    FILE_DETAIL_SHOW: 'file_detail_show', // 文管详情半模态
    MY_PHONE_CLICK: 'my_phone_click', // phone页面点击事件
    RECENT_CLICK: 'recent_click', // recent页面点击事件
    CUSTOMIZE_QUESTION: 'customizeQuestion', // 自定义密保问题
    SHOW_PATH_PICKER: 'showPathPicker', // 显示路径选择器
    CLOSE_PATH_PICKER: 'closePathPicker', // 关闭路径选择器
    CLOSE_UI_PATH_PICKER: 'closeUiPathPicker', // 关闭路径选择器
    CLOSE_UI_FILE_PICKER: 'closeUiFilePicker', // 关闭文件选择器
    LONG_PRESS_REMOVE: 'longPressRemove', // 长按移除操作
    LONG_PRESS_IMPORT: 'longPressImport', // 长按移入操作
    LONG_PRESS_FAVORITE: 'longPressFavorite', // 长按收藏操作
    LONG_PRESS_UNFAVORITE: 'longPressUnFavorite', // 长按收藏操作
    LONG_PRESS_DETAIL: 'longPressDetail', // 长按查看详情操作
    LONG_PRESS_OTHER_APP: 'longPressOtherApp', // 长按其他应用打开操作
    LONG_PRESS_PRINT: 'longPressPrint', // 长按打印操作
    LONG_PRESS_OPEN_FOLDER: 'longPressOpenFolder', // 打开文件所在文件夹
    LONG_PRESS_SELECT: 'longPressSelect', // 长按全选操作
    FILE_TAG_DRAG_FINISH: 'fileTagDragFinish', // 标签拖拽完成
    UI_EXTENSION_PICKER_INDEX_CHANGE: 'UiExtensionPickerIndexChange', // file_picker最近和浏览index切换
    REMOVE_IN_PASTE_STORAGE_DEVICE: 'removeInPasteStorageDevice', // 粘贴中，移除存储设备提示
    STORAGE_DEVICE_UNMOUNT: 'storageDeviceUnmount', // 点击设备移除
    ACCESSIBILITY_FOCUS_JUMP: 'accessibilityFocusJump', // 无障碍焦点跳转到标题栏
    LIST_OR_GRID_VIEW_CHANGE: 'listOrGridViewChange', // 列表或宫格视图改变
    SHOW_CELLULAR_TRANSMISSION_DIALOG: 'showCellularTransmissionDialog', //显示移动网络通知弹框

    SHOW_NEW_FOLDER_DIALOG: 'createFolder', // 新建文件夹
    SHOW_CLEAR_ALL_FILES_DIALOG: 'clearAllFiles', // 回收站清空
    BOTTOM_BAR_ITEM_CLICK: 'bottomBarItemClick', // 底部的按钮点击
    WINDOW_STAGE_EVENT: 'windowStageEvent', // 窗口状态发生变化
    ON_VIEW_FOREGROUND_EVENT: 'onViewForeground', // 界面切前台事件
    ON_VIEW_BACKGROUND_EVENT: 'onViewBackground', // 界面切后台事件
    PHOTO_PROTECTED_STATE_CHANGE: 'photoProtectedStateChange', // 图库外部已解锁
    FILE_PICKER_PHOTO_UNLOCK: 'filePickerPhotoUnlock', // 图库解锁，通知聚合图片/视频根目录界面重新刷新

    PREVIEW_OPERATION_EVENT: 'previewOperationEvent', // 预览界面操作事件
    EXIT_PREVIEW: 'exitPreview', // 退出预览界面
    UPDATE_FILE_ITEM_IN_GROUP: 'updateFileItemInGroup', // 原FileDataSource中file变化后通知分组
    SHOW_INSUFFICIENT_DISK_SPACE_DIALOG: 'showInsufficientDiskSpaceDialog', // 内存不足时发送事件
    DRAG_JUMP: 'dragJump', // 拖拽跳转

    MENU_CLICK: 'menuClick',
    ADD_NEW_FOLDER: 'addNewFolder', // 添加新文件夹

    DUPLICATE_FILE_SCAN_STATE: 'duplicateFileScanState',

    STOP_EDITING: 'stopEditing', // 搜索框停止，键盘收起
  };
  // 移动网络通知选项
  public static readonly NETWORK_OPTION = {
    ALWAYS_NOTICE: 0,
    NOTICE_WHEN_OVER_100MB: 1,
    ALWAYS_ALLOW: 2
  }
  public static readonly NETWORK_OPTION_NAME = 'networkOption';
  public static readonly APP_STORAGE_KEY_NETWORK_AVAILABLE = 'isNetWorkAvailable';
  public static readonly SHOW_HIDDEN_ITEM_OPTION_NAME = 'showHiddenItem';
  public static readonly REFRESH_PAGE = 'refreshPage';
  // 排序方式改变
  public static readonly SORT_CHANGE: string = 'sortChange';
  // 500M内存
  public static readonly MIN_REMAIN_SIZE: number = 500000000;
  // 图片大小过滤持久化相关数据
  public static readonly SETTING_IMAGE_SIZE_FILTER_NAME: string = 'settingImageSizeFilter';
  public static readonly IMAGE_SIZE_FILTER_CUSTOM: string = 'imageSizeFilterCustom';
  public static readonly IMAGE_SIZE_FILTER: string = 'imageSizeFilter';
  // 首页位置模块划分
  public static readonly LOCATION_LIST = {
    MY_PHONE: 1, // 手机存储
    INTERNET: 3, // 网上邻居
    RECENT_DELETE: 4 // 最近删除
  };
  // 外部储存类型
  public static readonly EXTERNAL_DEVICE_TYPE = {
    UNKNOWN: 0, // 未知
    TF_CARD: 1, // TF卡
    U_DISK: 2, // U盘
  }
  // 定时器时间
  public static readonly TIMER_TIME = {
    TIMER_100: 100,
    TIMER_200: 200,
    TIMER_300: 300,
    TIMER_500: 500,
    TIMER_1000: 1000,
    TIMER_5000: 5000,
  };
  /**
   * 本地内部存储uri格式开头
   */
  public static readonly LOCAL_URI_START = 'file://docs/storage/Users';
  /**
   * 我的电脑path路径头部信息
   */
  public static readonly MY_PC_PATH_HEAD = '/storage/Users/currentUser';
  /**
   * 特殊字符正则
   */
  public static readonly SPECIAL_CHARACTER_REGEXP = /[\\/:*?"<>|]/g;
  /**
   * 特殊字符替换字符
   */
  public static readonly SPECIAL_CHARACTER_REPLACE_CHARACTER = '_';
  public static readonly FILENAME_REGEXP = /^[^\\/:*?"<>|]+$/;
  public static readonly FILENAME_REGEXP_CONTENT = '\\ / : * ? " < > |';
  // 图库文件的特殊字符校验范围保持和图库应用一致
  public static readonly GALLERY_FILENAME_REGEXP = /[\\.\\\\/:*?"'`<>|\[\]{}]/;
  public static readonly GALLERY_FILENAME_REGEXP_CONTENT = '\' ` " . \\ / : * ? < > | [ ] { }';
  /**
   * 文件名的最大长度
   */
  public static readonly MAX_FILENAME_LENGTH = 255;
  /**
   * 支持直接重命名的文件名最大长度
   */
  public static readonly MAX_LENGTH_BEFORE_RENAME = 250;
  /**
   * 文件名超长重命名时要裁剪的长度
   */
  public static readonly FILENAME_CUT_LENGTH = 10;
  /**
   * 重命名连接符
   */
  public static readonly RENAME_CONNECT_CHARACTER = ' ';
  public static readonly DOCUMENTS_FOLDER = 'Documents';
  public static readonly DOWNLOAD_FOLDER = 'Download';
  public static readonly DESKTOP_FOLDER = 'Desktop';
  public static readonly APPDATA_FOLDER = 'appdata';
  public static readonly TRASH_FOLDER = '.Trash';
  public static readonly RECENT_FOLDER = '.Recent';
  public static readonly THUMBS_FOLDER = '.thumbs';
  public static readonly BACKUP_FOLDER = '.backup';
  public static readonly PC_ENGINE_FOLDER = 'PCEngine';
  public static readonly GRID_FILENAME_MAX_LENGTH = 11;
  public static readonly GRID_FILENAME_CONNECT_INDEX = 5;
  // 媒体库根目录
  public static readonly ROOT_DIRECTORY_MEDIA_LIBRARY = ['Documents', 'Download'];
  // 回收站的里文件夹的mediaType为7
  public static readonly TRASH_FOLDER_MEDIA_TYPE = 7;
  // uri路径
  public static readonly URI_PATH = 'uriPath';
  // 来源
  public static readonly FROM = 'from';
  // 打开页面
  public static readonly OPEN_PAGE = 'openPage';
  // 默认子文件夹数量
  public static readonly FOLDER_SUB_DEFAULT = -1;
  // 文件大小未知
  public static readonly FILE_SIZE_UNKNOWN = -1;
  // 拖拽进入响应延时
  public static readonly DRAG_ENTER_DELAY_TIME = 1500;
  // 拖拽进入响应闪烁延时
  public static readonly DRAG_ENTER_SHINE_DELAY_TIME = 100;
  // 长按延时规范
  public static readonly LONG_PRESS_DELAY_TIME = 500;
  // 多选长按延时
  public static readonly MUL_LONG_PRESS_DELAY_TIME = 800;
  // 多选状态子标题刷新延时
  public static readonly SUB_TITLE_REFRESH_DELAY = 150;
  /**
   * 标签名最大字符数
   */
  public static readonly MAX_TAG_NAME_SIZE = 127;
  /**
   * 输入框最大长度
   */
  public static readonly INPUT_MAX_LENGTH = 128;
  public static readonly GRID_VIEW_IMAGE_SIZE: number = 88;
  // 外屏宫格图标大小
  public static readonly OUTSIDE_SCREEN_GRID_VIEW_IMAGE_SIZE: number = 56;
  // 外屏来源图标大小
  public static readonly OUTSIDE_SCREEN_SOURCE_PAGE_GRID_IMAGE_SIZE: number = 68;
  public static readonly GRID_VIEW_ALBUM_IMAGE_SIZE: number = 96;
  public static readonly LIST_VIEW_IMAGE_SIZE: number = 36;
  public static readonly LIST_VIEW_LOCK_SIZE: number = 20;
  public static readonly LIST_VIEW_LOCK_OFFSET: number = 4;
  // 文件列表顶部栏避让区
  public static readonly TOP_BAR_AVOID_AREA_HEIGHT: number = 56;
  public static readonly CACHED_IMAGE_CACHE_SOURCE_SIZE: number = 256;
  public static readonly ASPECT_RATIO_THRESHOLD: number = 4 / 3; // 横竖屏比值
  /**
   * picker支持的文件选择模式
   */
  public static readonly SELECT_MODE = {
    FILE: 0,
    FOLDER: 1,
    MIX: 2
  };
  /**
   * 文件后缀相关常量定义
   */
  public static readonly FILE_SUFFIX = {
    SUFFIX_SPLIT: ',',
    SUFFIX_START: '.'
  };
  /**
   * 文本显示行数
   */
  public static readonly LINE_COUNT = {
    ONE: 1,
    TWO: 2
  }
  /**
   * 目录层级定义
   */
  public static readonly FOLDER_LEVEL = {
    MIN_LEVEL: 1,
    MAX_LEVEL: 22
  };
  /**
   * 页面类型
   */
  public static readonly PAGE_TYPE = {
    MY_PHONE: 'myPhone', // 我的手机
  };
  /**
   * 来源
   */
  public static readonly FROM_TYPE = {
    COPY_CUT_NOTIFICATION: 'copyCutNotification',
    FROM_MEDIA_VIEW: 'mediaView',
    THIRD_APP: 'thirdApp',
    MY_PHONE: 'myPhone',
    FROM_DOWNLOAD: 'download',
    FROM_PREVIEW: 'preview'
  };
  // 一次最多分享的文件个数
  public static readonly FILE_SHARE_LIMIT_NUM = 100;
  public static readonly NETWORK_ID_STRING = '?networkid=';
  // 保存界面布局信息文件名
  public static readonly UX_STORE_FILE: string = '.ux_store';
  // 收藏文件回收状态
  public static readonly FILE_RECYCLED = {
    // 正常状态，用户可以操作
    NORMAL: 0,
    // 已删除状态，用户不可以操作
    DELETED: 1,
    // 未知，默认查询所有数据
    UNKNOWN: 2
  };
  // RecycleBinServiceConstant
  static readonly RECYCLE_BIN_SERVICE_MODE_DELETE: string = 'delete';
  static readonly RECYCLE_BIN_SERVICE_MODE_CLEAR: string = 'clear';

  // Instance
  static readonly TRANSFERRING_MODEL = 'TransferringModelInstance';
  // 桌面启动的进度条线程，需要把粘贴成功的文件发送到桌面，用来标识桌面线程名
  static readonly DESKTOP_TAG: string = '?!DesktopOptService!?_';
  /**
   * 拖拽场景下允许Drop的文件类型
   */
  static readonly ALLOW_DROP = {
    NONE: [],
    ALL_FILE: [
      UTD.UniformDataType.FILE,
      UTD.UniformDataType.VIDEO,
      UTD.UniformDataType.IMAGE,
      UTD.UniformDataType.AUDIO,
      UTD.UniformDataType.FOLDER
    ],
    ALL_FILE_AND_PIXEL_MAP: [
      UTD.UniformDataType.FILE,
      UTD.UniformDataType.VIDEO,
      UTD.UniformDataType.IMAGE,
      UTD.UniformDataType.AUDIO,
      UTD.UniformDataType.FOLDER,
      UTD.UniformDataType.OPENHARMONY_PIXEL_MAP
    ],
    FOLDER: [UTD.UniformDataType.FOLDER],
    TAG: [UTD.UniformDataType.PLAIN_TEXT]
  };
  /**
   * 最近页文件信息
   */
  static readonly RECENT_FILES = 'recentFiles';
  public static readonly SYSTEM_FOLDER_NAME = [
    Constant.TRASH_FOLDER,
    Constant.RECENT_FOLDER,
    Constant.THUMBS_FOLDER,
    Constant.PC_ENGINE_FOLDER,
    Constant.TRASH_FOLDER_NAME,
    Constant.UX_STORE_FILE
  ];
  public static readonly PHONE_SYSTEM_FOLDER_NAME = [
    Constant.APPDATA_FOLDER,
    Constant.BACKUP_FOLDER,
    Constant.DESKTOP_FOLDER,
    Constant.TRASH_FOLDER,
    Constant.RECENT_FOLDER,
    Constant.THUMBS_FOLDER,
    Constant.PC_ENGINE_FOLDER,
    Constant.TRASH_FOLDER_NAME,
    Constant.UX_STORE_FILE
  ];
  public static readonly PHONE_SYSTEM_HIDE_FOLDER_NAME_LOWER_CASE = [
    Constant.APPDATA_FOLDER.toLowerCase(),
    Constant.BACKUP_FOLDER.toLowerCase(),
    Constant.DESKTOP_FOLDER.toLowerCase(),
    Constant.TRASH_FOLDER.toLowerCase(),
    Constant.RECENT_FOLDER.toLowerCase(),
    Constant.THUMBS_FOLDER.toLowerCase(),
  ];
  // 老大化的默认放大倍数 - '1倍'
  public static readonly BIG_MODE_DEFAULT_MULTIPLE_VALUE = '1';
  /**
   * 适配老大化的放大倍数 - '需要适配的倍数'
   */
  public static readonly BIG_MODE = {
    BIG_MODE_3_2x: 3.2,
    BIG_MODE_3x: 3,
    BIG_MODE_2x: 2,
    BIG_MODE_1_75x: 1.75,
    BIG_MODE_1_45x: 1.45,
    BIG_MODE_1_3x: 1.3,
    BIG_MODE_1_15x: 1.15,
    BIG_MODE_1x: 1,
  };
  /**
   * 适配字体放大后的间距
   */
  public static readonly BIG_FONT_SIZE_SPACE_MAP: Map<number, string> = new Map([
    [Constant.BIG_MODE.BIG_MODE_1_75x, '16vp'],
    [Constant.BIG_MODE.BIG_MODE_2x, '20vp'],
    [Constant.BIG_MODE.BIG_MODE_3_2x, '24vp']
  ])
  /**
   * 文件服务在系统云端生成的唯一标识，请勿打印
   */
  public static readonly FILE_MANAGER_SERVICE_APP_IDENTIFIER = '991106822800681664';
  /**
   * 外屏滚动位置记录标识
   */
  public static readonly OUTSIDE_SCREEN_SCROLL_KEY = 'outside_screen_scroll_key';
  /*
   * 需要监听回调的底部按钮点击类型(滑动多选）
   * */
  public static readonly BOTTOM_TYPE_LIST =
    [Constant.OPERATION_TYPE.DELETE, Constant.OPERATION_TYPE.SELECT_ALL,
      Constant.OPERATION_TYPE.MOVE, Constant.OPERATION_TYPE.COPY];
  /*
   * 需要判断的widowStage的状态(滑动多选)
   */
  public static readonly WINDOW_STAGE_LIST = [window.WindowStageEventType.PAUSED, window.WindowStageEventType.INACTIVE];

  // 拼接userId, 返回本地真实路径公共部分
  public static get REAL_LOCAL_COMMON_PATH() {
    return `/data/service/el2/${this.USER_ID}/hmdfs/account/files/Docs`;
  }

  // 更新userId, 适配隐私空间
  public static async updateUserId() {
    Constant.USER_ID = await osAccount.getAccountManager().getOsAccountLocalId();
  }
}

export enum SortOrder {
  DEFAULT = 'default',
  NAME = 'name',
  TIME = 'time',
  SIZE = 'size',
  TYPE = 'type',
  ADD = 'add',
  NETWORK = 'network',
  MINE_HELP = 'mine_help',
  CHECK_VERSION = 'check_version',
  ABOUT = 'about',
  SET_UP = 'set_up'
}

export enum TopMenuDivider {
  TYPE_NONE = 0,
  TYPE_ONE = 1,
  TYPE_TWO = 2
}

export enum FileType {
  IMAGE = 'image',
  PICTURE = 'picture',
  VIDEO = 'video',
  AUDIO = 'audio',
  DOCUMENT = 'document',
  FILE = 'file',
  RECENT_DELETE = 'recentDelete',
  RECENT = 'recent',
}

export enum PageFinishType {
  DEFAULT = 'default',
  FINISH_ABILITY = 'finishAbility',
  DESTROY_PAGE = 'destroyPage'
}


export enum Actions {
  VIEW_DATA = 'ohos.want.action.viewData',
  SETTING_APP_INFO = 'action.settings.app.info'
}

export enum DeviceType {
  PAD = 'pad',
  PHONE = 'phone',
  TABLET = 'tablet', // deviceInfo识别出的平板类型
}

export enum DataSourceDeviceType {
  DEVICE_UNKNOWN = 0,
  DEVICE_INTERNAL,
  DEVICE_EXTERNAL
}

export enum FileSourceType {
  UNKNOWN = 0, // 未知来源
  LOCAL_DISK = 1, // 内卡来源
  EXTERNAL_USB = 2, // 外卡来源
  RECENT_DELETE = 3, // 最近删除
  GALLERY_APP = 5, // 图库应用
  SANDBOX_APP = 6, // 沙箱应用
}

export enum FileSourceUri {
  BLUETOOTH = 'file://docs/storage/Users/currentUser/Download/com.ohos.locationdialog',
  SHARE = 'file://docs/storage/Users/currentUser/Share',
  DOWNLOAD_MANAGER = 'file://docs/storage/Users/currentUser/Download',
  WLAN = 'file://docs/storage/Users/currentUser/Wlan',

  SOUNDS = 'file://docs/storage/Users/currentUser/Sounds',
  DCIM = 'file://docs/storage/Users/currentUser/DCIM',
  PICTURES = 'file://docs/storage/Users/currentUser/Pictures',

  DOCUMENTS = 'file://docs/storage/Users/currentUser/Documents',
  UPDATE_BACK_UP = 'file://docs/storage/Users/currentUser/UpdateBackup',
  FILE_RESTORE = 'file://docs/storage/Users/currentUser/File_Restore', // 应用沙箱内文件还原目录
  GALLERY = 'gallery' // 我的手机根目录下的图库文件夹
}

export const enum LocationType {
  LOCAL = 1, // 本地文件
}

export enum FileHelperType {
  ALL_TYPE = 'allType', // faf返回的所有类型
  LOCAL_TYPE = 'FileExtensionAbility', // 本地fileHelper
}

// 由原PC文管Constants类合入
export enum DeviceTypeConstants {
  PC,
  PHONE
}

// 用于首页底部Tab点击打点
export enum BottomTabNumber {
  RECENT = 0,
  BROWSE
}

/**
 * 预览框架拉起方式
 */
export enum PREVIEW_TYPE {
  PREVIEW_BY_APP = 1,
  PREVIEW_BY_API = 2,
}

export enum COLOR_MODE {
  COLOR_MODE_DARK = 0,
  COLOR_MODE_LIGHT = 1
}

/**
 * 用户态，浏览、多选，复制移动等
 */
export enum UserState {
  BROWSER = 0,
  MULTI_START = 1,
  COPY = 2,
  MOVE = 3,
  SELECT_PATH = 4,
  SELECT_CARD = 5
}

/**
 * 更改列表视图枚举
 */
export enum VIEW_MODE {
  LIST = 'list',
  GRID = 'grid'
}

/**
 * 宫格列表视图枚举
 */
export enum SHOW_MODE {
  LIST = 0,
  GRID = 1
}

/**
 * filePicker文件选择模式
 */
export enum SELECT_MODE {
  File = 0,
  Folder,
  Mixed
}

/**
 * 手机列表滑动位置
 */
export enum ScrollPosition {
  start,
  center,
  end
}

/**
 * 使用fs创建文件流的模式
 */
export enum FS_STREAM_MODE {
  // 打开只读文件，该文件必须存在
  READ_ONLY = 'r',
  // 打开可读写的文件，该文件必须存在
  READ_WRITE = 'r+',
  // 打开只写文件，若文件存在则文件长度清0，即该文件内容会消失。若文件不存在则建立该文件
  WRITE_ONLY_CREATE = 'w',
  // 打开可读写文件，若文件存在则文件长度清0，即该文件内容会消失。若文件不存在则建立该文件。
  READ_WRITE_CREATE = 'w+',
  // 以附加的方式打开只写文件。若文件不存在，则会建立该文件，如果文件存在，写入的数据会被加到文件尾，即文件原先的内容会被保留
  WRITE_ONLY_CREATE_APPEND = 'a',
  // 以附加方式打开可读写的文件。若文件不存在则创建文件，如果文件存在，写入的数据会被加到文件尾后，即文件原先的内容会被保留
  READ_WRITE_CREATE_APPEND = 'a+'
}

export enum UUID_TYPE {
  LOCAL = 'LOCAL', // 本地
}

/**
 * 适老化盘屏幕朗读-是否进行获焦
 */
export enum ACCESSIBILITY_LEVEL {
  YES = 'yes',
  NO = 'no',
  AUTO = 'auto',
  NO_HIDE_DESCENDANTS = 'no-hide-descendants'
}
;

export enum FoldPhoneTypeValue {
  /**
   *无效值
   */
  INVALID_VALUE = -1,
  /**
   *直板机
   */
  STRAIGHT = 0,
  /**
   *大折（内折）X5
   */
  LARGE_FOLD = 1,
  /**
   *小折叠（只有内折）pocket
   */
  SMALL_FOLD = 2,
  /**
   *外折XS2
   */
  EXTERNAL_FOLD = 3,
  /**
   *扩展新形态
   */
  EXPANDING_NEX_FORMS = 4,
  /**
   * 三折叠 XT
   */
  TRIPLE_FOLD = 6
}

/**
 * 滑动的操作类型
 */
export enum SlideActionType {
  START,
  UPDATE,
  END
}

/**
 * 气泡提示标识Key
 */
export enum PopupTips {
  MORE_POPUP_TIP = 'more_popup_tip',
  SEARCH_POPUP_TIP = 'search_popup_tip',
}

/**
 * 存储位置项目名称
 */
export enum LocationItemName {
  // 我的手机
  MY_PHONE = 'myPhone',
  // 外接存储
  EXTERNAL = 'external',
  // 最近删除
  RECENT_DELETE = 'recentDelete'
}

/**
 * 文件夹操作类型
 */
export enum FolderOperationType {
  NONE, // 非文件夹操作
  OPEN_FOLDER, // 打开文件夹
  EXIT_FOLDER // 退出文件夹
}

export class AccessibilityStorageKey {
  // 无障碍模式下，路径选择器首次进入规避主动聚焦, 判断有这个key的时候不发起主动聚焦
  public static readonly PATH_SELECT_INIT_KEY = 'path_select_init_key';

  // 无障碍模式下，标题规避冗余播报, 判断有这个key的时候不发起主动播报
  public static readonly MULTIPLE_CHOICE_KEY = 'multiple_choice_key';
}