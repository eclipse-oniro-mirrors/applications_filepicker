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
 * Preferences文件和字段常量
 */
export class PreferenceConst {
  /**
   * 持久化储存文件名常量
   */
  public static FILE = class {
    /**
     * 公共storage文件
     */
    public static readonly COMMON: string = 'common';

    /**
     * 备份的HmFiles的Common文件
     */
    public static readonly HM_FILES_COMMON: string = 'filesCommon';


    /**
     * 使用习惯持久化存储文件名(请勿使用，已弃用 可以使用NEW_USAGE_HABITS)
     */
    public static readonly USAGE_HABITS: string = 'usageHabits';

    /**
     * 新版本使用习惯持久化存储文件名
     */
    public static readonly NEW_USAGE_HABITS: string = 'newUsageHabits';

    /**
     * GRS服务器域名持久化存储文件名
     */
    public static readonly GRS_URLS: string = 'grsRoutes';

    /**
     * picker上次打开位置持久化存储文件名
     */
    public static readonly PICKER_LAST_OPENED_DIR = 'pickerLastOpenedDir';

    /**
     * 文件大小过滤持久化文件名
     */
    public static readonly SETTING_IMAGE_SIZE_FILTER: string = 'settingImageSizeFilter';
  };

  /**
   * 持久化储存文件里的Key常量
   */
  public static KEY = class {
    /**
     * 上次处理剪切板数据的时间戳
     */
    public static readonly LAST_RESOLVE_PASTEBOARD_TIMESTAMP: string = 'lastResolvePasteboardTimestamp';

    /**
     * 上次清理内部存储缓存在沙箱下的缩略图的时间
     */
    public static readonly LAST_CLEAN_THUMBNAIL_CACHE_TIMESTAMP: string = 'lastCleanThumbnailCacheTimeStamp';

    /**
     * 上次清理外部存储设备缓存在沙箱下的缩略图的时间
     */
    public static readonly LAST_CLEAN_USB_THUMBNAIL_CACHE_TIMESTAMP: string = 'lastCleanUsbThumbnailCacheTimeStamp';

    /**
     * 进入文管默认展示的tab
     */
    public static readonly DEFAULT_TAB_INDEX: string = 'defaultTabIndex';

    /**
     * 进入FILEPICKER默认展示的tab
     */
    public static readonly FILE_PICKER_DEFAULT_TAB_INDEX: string = 'filePickerDefaultTabIndex';


    /**
     * 上次在文管内进行复制移动等操作时拉起路径选择的文件夹uri
     */
    public static readonly LAST_SELECT_FOLDER_URI: string = 'lastSelectFolderUri';

    /**
     * 其他页面的宫格列表展示模式（内部存储、外部存储、最近删除）
     */
    public static readonly OTHER_PAGE_VIEW_MODE: string = 'otherPageViewMode';

    /**
     * 其他页面的排序规则（内部存储、外部存储、最近删除）
     */
    public static readonly OTHER_PAGE_SORT_ORDER: string = 'otherPageSortOrder';

    /**
     * 是否展开收藏列表
     */
    public static readonly FAVORITE_LIST_EXPAND: string = 'favoriteListExpend';

    /**
     * 双升单后进入聚合视图第一层的toast提示次数
     */
    public static readonly FILE_REFRESH_PAGE_TIPS_TIMES: string = 'fileRefreshPageTipsTimes';

    /**
     * 存储空间持久化数据
     */
    public static readonly DEVICE_STORAGE_SPACE: string = 'deviceStorageSpace';

    /**
     * 存储空间持久化数据
     */
    public static readonly POWER_HINT_CONFIRMED: string = 'powerConsumptionHintConfirmed';

    /**
     *  沙箱缓存提示语版本key
     */
    public static readonly REMOVE_CACHE_DATA_TIP_CLOSED_VERSION: string = 'cacheDataRemoveTipClosedVersion';

    /**
     * 关闭卸载应用会删除缓存数据提示
     */
    public static readonly REMOVE_CACHE_DATA_TIP_CLOSED: string = 'cacheDataRemoveTipClosed';

    /**
     * 是否通过应用指导
     */
    public static readonly APP_GUIDANCE_PASS: string = 'appGuidancePass';

    /**
     * 引导页版本key
     */
    public static readonly APP_GUIDANCE_PASS_VERSION: string = 'appGuidancePassVersion';

    /**
     *  新特性引导版本key
     */
    public static readonly NEW_FEATURE_GUIDE_VERSION: string = 'newFeatureGuideVersion';

    /**
     * 是否显示最近页新特性引导
     */
    public static readonly RECENT_NEW_FEATURE_CARD_SHOW: string = 'recentNewFeatureCardShow';

    /**
     * 是否显示最近红点提醒
     */
    public static readonly RECENT_BAR_RED_DOT_SHOW: string = 'recentBarRedDotShow';

    /**
     * 同意时间
     */
    public static readonly AGREE_TIME_STAMP: string = 'agreeTimeStamp';
    /**
     * 同意规范化时间
     */
    public static readonly AGREE_FORMAT_TIME: string = 'agreeFormatTime';
    /**
     * 应用版本
     */
    public static readonly APP_VERSION: string = 'appVersion';
    /**
     * 录音机文件迁移完成持久化标志位
     */
    public static readonly RECORDER_MIGRATION: string = 'soundsRecordMigration';
    /**
     * 图片大小过滤持久化数据过滤选择分类
     */
    public static readonly IMAGE_SIZE_FILTER: string = 'imageSizeFilter';
    /**
     * 图片大小过滤持久化数据过滤选择数值
     */
    public static readonly IMAGE_SIZE_FILTER_CUSTOM: string = 'imageSizeFilterCustom';
    /**
     * 图库相册提示
     */
    public static readonly ALBUM_GUIDE_TIP: string = 'albumGuideTip';
    /**
     * 通知栏授权
     */
    public static readonly NOTIFICATION_PERMISSION: string = 'notificationPermission';
  };

  /**
   * 系统常量
   */
  public static SYSTEM = class {
    /**
     * 是否首次启动应用
     */
    public static readonly FIRST_LAUNCH: string = 'firstLaunch';
  }
}
