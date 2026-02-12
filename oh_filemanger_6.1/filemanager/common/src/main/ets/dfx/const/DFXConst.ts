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
export namespace DFX {
  // UE打点上报的domain信息
  export const DOMAIN_UE: string = 'FILEMANAGER_UE';

  // DFT打点上报的domain信息
  export const DOMAIN_DFT: string = 'FILEMANAGERPHONE';

  /**
   * 排序类型
   */
  export enum SortType {
    // 名称
    NAME = 'NAME',
    // 类型
    TYPE = 'TYPE',
    // 时间
    TIME = 'TIME',
    // 大小
    SIZE = 'SIZE',
    // 未知
    UNKNOWN = 'UNKNOWN',
    // 默认排序
    DEFAULT = 'DEFAULT'
  }

  /**
   * 视图类型
   */
  export enum ViewType {
    // 宫格
    GRID = 'GRID',
    // 列表
    LIST = 'LIST'
  }

  /**
   * 浏览页编辑状态
   */
  export enum EditStatus {
    // 进入编辑态
    OPEN = 'OPEN',
    // 完成编辑
    DONE = 'DONE'
  }

  /**
   * 来源项操作类型
   */
  export enum SourceItemOperType {
    // 打开来源
    OPEN = 'OPEN',
    // 关闭来源
    CLOSE = 'CLOSE',
    // 改变顺序
    CHANGE_ORDER = 'CHANGE_ORDER'
  }

  /**
   * 移动网络提示类型
   */
  export enum CellularTipMode {
    // 未知
    UNKNOWN = 'UNKNOWN',
    // 始终提示
    ALWAYS_NOTICE = 'ALWAYS_NOTICE',
    // 超过100MB提示
    OVER_100MB_NOTICE = 'OVER_100MB_NOTICE',
    // 始终允许
    ALWAYS_ALLOW = 'ALWAYS_ALLOW'
  }

  /**
   * 小图片过滤尺寸
   */
  export enum ImageFilterSize {
    // 不过滤
    NOT_FILTER = 0,
    // 过滤30KB以下图片
    THIRTY_KB = 30,
    // 过滤100KB以下图片
    ONE_HUNDRED_KB = 100,
    // 过滤500KB以下图片
    FIVE_HUNDRED_KB = 500,
    // 过滤1MB以下图片
    ONE_MB = 1024
  }

  /**
   * 文件打开方式
   */
  export enum FileOpenMode {
    // 默认点击打开
    DEFAULT_CLICK = 'DEFAULT_CLICK',
    // 通过其他应用打开
    OPEN_BY_OTHER_APP = 'OPEN_BY_OTHER_APP'
  }

  /**
   * 收藏操作类型
   */
  export enum FavoriteOperType {
    // 收藏
    ADD_TO_FAVORITE = 'ADD_TO_FAVORITE',
    // 取消收藏
    CANCEL_FROM_FAVORITE = 'CANCEL_FROM_FAVORITE'
  }

  /**
   * 操作来源
   */
  export enum OperateSource {
    // 长按菜单
    PRESS_MENU = 'PRESS_MENU',
    // 收藏项长按菜单
    FAVORITE_PRESS_MENU = 'FAVORITE_PRESS_MENU',
    // 多选按钮
    MULTI_SELECT_BUTTON = 'MULTI_SELECT_BUTTON',
    // 底部操作菜单
    BOTTOM_MENU = 'BOTTOM_MENU',
    // 浏览页编辑
    EDIT = 'EDIT',
    // 文件列表左滑
    LEFT_SLIDE = 'LEFT_SLIDE',
    // 回收站清空按钮
    CLEAR_BUTTON = 'CLEAR_BUTTON',
    // 详情弹窗
    DETAIL_DIALOG = 'DETAIL_DIALOG',
  }

  /**
   * 复制移动类型
   */
  export enum CopyMoveType {
    // 复制
    COPY = 'COPY',
    // 移动
    MOVE = 'MOVE'
  }

  /**
   * 粘贴类型
   */
  export enum PasteType {
    // 跨应用粘贴弹窗
    CROSS_APP_DIALOG = 'CROSS_APP_DIALOG',
    // 空白处长按菜单
    BLANK_PRESS_MENU = 'BLANK_PRESS_MENU'
  }

  /**
   * 删除类型
   */
  export enum DeleteType {
    // 软删除（删除进最近删除）
    SOFT_DELETE = 'SOFT_DELETE',
    // 删除（彻底删除）
    DELETE = 'DELETE'
  }

  /**
   * 网络类型
   */
  export enum NetType {
    // WIFI网络
    WIFI = 'WIFI',
    // 蜂窝移动网络
    CELLULAR = 'CELLULAR'
  }

  /**
   * 拖拽类型
   */
  export enum DragType {
    // 拖拽开始
    DRAG_START = 'DRAG_START',
    // 拖拽结束
    DRAG_END = 'DRAG_END'
  }

  /**
   * 进入文件清理列表方式
   */
  export enum FileCleanListEnterType {
    // 点击清理按钮
    CLEAR_BUTTON = 'CLEAR_BUTTON',
    // 点击展示所有大文件
    SHOW_ALL_FILE = 'SHOW_ALL_FILE',
    // 点击释放空间按钮
    SPACE_RELEASE_BUTTON = 'SPACE_RELEASE_BUTTON'
  }

  /**
   * 主相册类型
   */
  export enum AlbumType {
    // 未知
    UNKNOWN = 'UNKNOWN',
    // 用户相册
    USER = 'USER',
    // 系统相册
    SYSTEM = 'SYSTEM',
    // 来源相册
    SOURCE = 'SOURCE',
    // 智慧相册
    SMART = 'SMART'
  }

  /**
   * 子相册类型
   */
  export enum SubAlbumType {
    // 未知
    UNKNOWN = 'UNKNOWN',
    // 通用相册
    COMMON = 'COMMON',
    // 视频相册
    VIDEO = 'VIDEO',
    // 图片相册
    IMAGE = 'IMAGE',
    // 来源通用相册
    SOURCE_COMMON = 'SOURCE_COMMON'
  }

  /**
   * 进入相册方式
   */
  export enum EnterAlbumType {
    // 图库图标
    GALLERY_FOLDER = 'GALLERY_FOLDER'
  }

  /**
   * 全选类型
   */
  export enum SelectAllType {
    // 全选
    SELECT_ALL = 'SELECT_ALL',
    // 取消全选
    DESELECT_ALL = 'DESELECT_ALL'
  }

  /**
   * 实例名称
   */
  export enum AbilityName {
    // 通过UIAbility的方式拉起文管应用
    FILE_MANAGER_UI = 'FILE_MANAGER_UI',
    // 通过UIExt的方式拉起文管应用
    FILE_MANAGER_EXT = 'FILE_MANAGER_EXT',
    // 通过UIAbility的方式拉起选择picker
    FILE_PICKER_UI = 'FILE_PICKER_UI',
    // 通过UIExt的方式拉起选择picker
    FILE_PICKER_EXT = 'FILE_PICKER_EXT',
    // 通过UIAbility的方式拉起保存picker
    PATH_PICKER_UI = 'PATH_PICKER_UI',
    // 通过UIExt的方式拉起保存picker
    PATH_PICKER_EXT = 'PATH_PICKER_EXT',
    // 下载控件
    DOWNLOAD_AUTH = 'DOWNLOAD_AUTH',
    // 提供给外部拉起聚合页的UIExtensionAbility
    OPEN_MEDIA_EXT = 'OPEN_MEDIA_EXT',
  }

  /**
   * 外接存储设备操作类型
   */
  export enum ExternalOperType {
    // 插入
    INSERT = 'INSERT',
    // 拔出
    DIRECTLY_REMOVE = 'DIRECTLY_REMOVE',
    // 长按移除
    PRESS_REMOVE = 'PRESS_REMOVE'
  }

  /**
   * 恢复操作类型
   */
  export enum RestoreOperType {
    // 文件恢复
    DOCS_RESTORE = 'DOCS_RESTORE'
  }

  /**
   * picker模式
   */
  export enum PickerMode {
    // 文件选择器
    FILE_PICKER = 'FILE_PICKER',
    // 路径选择器
    PATH_PICKER = 'PATH_PICKER'
  }

  /**
   * 底部Tab栏名称
   */
  export enum BottomTabName {
    // 最近
    RECENT = 'RECENT',
    // 浏览
    BROWSE = 'BROWSE'
  }

  /**
   * 设置公共操作类型
   */
  export enum SettingCommonOperType {
    // 进入收集个人信息清单页面
    ENTER_INFO_COLLECT_LIST = 'ENTER_INFO_COLLECT_LIST',
    // 进入关于页面
    ENTER_ABOUT_PAGE = 'ENTER_ABOUT_PAGE',
    // 进入服务协议与规则页面
    ENTER_SERVICE_AGREEMENT_RULES = 'ENTER_SERVICE_AGREEMENT_RULES',
    // 点击版本信息
    CLICK_VERSION_INFO = 'CLICK_VERSION_INFO',
    // 点击客服电话
    CLICK_CUSTOMER_SERVICE_PHONE = 'CLICK_CUSTOMER_SERVICE_PHONE',
    // 点击备案号
    CLICK_REGISTRATION_NUM = 'CLICK_REGISTRATION_NUM'
  }

  /**
   * 操作界面
   */
  export enum PageName {
    // 未知
    UNKNOWN = 'UNKNOWN',
    // 浏览页面
    BROWSE = 'BROWSE',
    // 我的手机页面
    MY_PHONE = 'MY_PHONE',
    // 最近删除页面
    RECENT_DELETE = 'RECENT_DELETE',
    // 来源
    SOURCE = 'SOURCE',
    // 外部存储
    EXTERNAL = 'EXTERNAL',
    // 收藏
    FAVORITE = 'FAVORITE',
    // 图库
    GALLERY = 'GALLERY'
  }

  /**
   * 操作模块
   */
  export enum OperateModule {
    RECENT_CARD = 'RECENT_CARD'
  }

  /**
   * 操作类型
   */
  export enum OperateType {
    JUMP_TO_SOURCE = 'JUMP_TO_SOURCE'
  }

  /**
   * UE事件名称
   */
  export enum UEEvent {
    // 切换排序规则
    SORT_RULE_CHANGE = 'SORT_RULE_CHANGE',
    // 切换宫格列表
    FILE_VIEW_CHANGE = 'FILE_VIEW_CHANGE',
    // 浏览页编辑态切换
    EDIT_MODE_CHANGE = 'EDIT_MODE_CHANGE',
    // 展示设置页面
    SHOW_SETTING = 'SHOW_SETTING',
    // 进入页面，如最近（折叠）/我的手机/外接存储/最近删除/收藏
    ENTER_PAGE = 'ENTER_PAGE',
    // 进入来源
    ENTER_SOURCE = 'ENTER_SOURCE',
    // 编辑状态下：打开来源，关闭来源，改变来源顺序
    SOURCE_ITEM_OPERATE = 'SOURCE_ITEM_OPERATE',
    // 选择使用移动网络上传/下载/播放的选项
    CELLULAR_TIP = 'CELLULAR_TIP',
    // 设置过滤图片大小的选项
    SMALL_IMAGE_FILTER = 'SMALL_IMAGE_FILTER',
    // 进入问题与建议页面
    QUESTIONS_AND_SUGGESTIONS = 'QUESTIONS_AND_SUGGESTIONS',
    // 是否显示隐藏文件
    SHOW_HIDDEN_FILE = 'SHOW_HIDDEN_FILE',
    // 新建文件夹
    CREATE_NEW_FOLDER = 'CREATE_NEW_FOLDER',
    // 打开文件（直接打开、用其他应用打开）
    OPEN_FILE = 'OPEN_FILE',
    // 文件收藏与取消收藏
    FILE_FAVORITE = 'FILE_FAVORITE',
    //设置为铃声
    SET_RINGTONE = 'SET_RINGTONE',
    // 分享
    SHOW_SHARE_DIALOG = 'SHOW_SHARE_DIALOG',
    // 复制、移动
    COPY_MOVE_FILE = 'COPY_MOVE_FILE',
    // 粘贴
    PASTE_FILE = 'PASTE_FILE',
    // 重命名
    RENAME_FILE = 'RENAME_FILE',
    // 删除
    DELETE_FILE = 'DELETE_FILE',
    // 还原
    RESTORE_FILE = 'RESTORE_FILE',
    // 查看详情
    FILE_DETAIL = 'FILE_DETAIL',
    // 打印
    PRINT_FILE = 'PRINT_FILE',
    // 拖拽
    DRAG_FILE = 'DRAG_FILE',
    // 进入大文件列表
    ENTER_BIG_FILE_LIST = 'ENTER_BIG_FILE_LIST',
    // 进入本地垃圾文件列表
    ENTER_LOCAL_TRASH_FILE_LIST = 'ENTER_LOCAL_TRASH_FILE_LIST',
    // 在本地垃圾清理页面点击删除
    DELETE_LOCAL_TRASH_FILE = 'DELETE_LOCAL_TRASH_FILE',
    // 重复文件扫描
    DUPLICATE_FILE_SCAN = 'DUPLICATE_FILE_SCAN',
    // 进入重复文件列表
    ENTER_DUPLICATE_FILE_LIST = 'ENTER_DUPLICATE_FILE_LIST',
    //在重复文件清理页面点击删除
    DELETE_DUPLICATE_FILE = 'DELETE_DUPLICATE_FILE',
    // 重复文件清理页面文件详情信息
    DUPLICATE_FILE_DETAILS = 'DUPLICATE_FILE_DETAILS',
    // 多选
    FILE_MULTI_SELECT = 'FILE_MULTI_SELECT',
    // 全选/取消全选
    SELECT_OR_DESELECT_ALL = 'SELECT_OR_DESELECT_ALL',
    // 滑动多选
    SLIDE_SELECT = 'SLIDE_SELECT',
    // 进入指定相册
    ENTER_ALBUM = 'ENTER_ALBUM',
    // 打开文管应用，拉起文管picker
    CREATE_ABILITY = 'CREATE_ABILITY',
    // 插入，拔出，长按移除
    EXTERNAL_STORAGE_OPERATION = 'EXTERNAL_STORAGE_OPERATION',
    // 文件恢复
    FILE_BACKUP_RESTORE = 'FILE_BACKUP_RESTORE',
    // 拉起picker保存文件、选择文件
    OPEN_PICKER = 'OPEN_PICKER',
    // 创建下载目录
    CREATE_DOWNLOAD_FOLDER = 'CREATE_DOWNLOAD_FOLDER',
    // 最近、浏览tab栏切换
    BOTTOM_TAB_CLICK = 'BOTTOM_TAB_CLICK',
    // 设置公共操作
    SETTING_COMMON_OPERATION = 'SETTING_COMMON_OPERATION',
    // 点击面包屑导航
    CLICK_ADDRESS_BAR = 'CLICK_ADDRESS_BAR',
    // 通用打点事件
    USER_GENERAL_OPERATION = 'USER_GENERAL_OPERATION',
    // 设置为壁纸
    SET_AS_WALLPAPER = 'SET_AS_WALLPAPER',
    // 弹框500M体验优化
    SHOW_LOW_MEMORY_DIALOG = 'SHOW_LOW_MEMORY_DIALOG',
    // 位置项操作
    LOCATION_ITEM_OPERATE = 'LOCATION_ITEM_OPERATE',
    // 点击抽屉按钮
    DRAWER_MODE_CHANGE = 'DRAWER_MODE_CHANGE',
    // 最近新版本运营卡片操作
    RECENT_NEW_VERSION_CARD_OPERATE = 'RECENT_NEW_VERSION_CARD_OPERATE',
    // 选择picker参数解析
    PARSE_PICKER_SELECT_PARAMS = 'PARSE_PICKER_SELECT_PARAMS',
    // 保存picker参数解析
    PARSE_PICKER_SAVE_PARAMS = 'PARSE_PICKER_SAVE_PARAMS'
  }

  export enum StorageKey {
    OPERATE_SOURCE = 'OPERATE_SOURCE',
    OPERATE_PAGE = 'OPERATE_PAGE',
    OPERATE_TYPE = 'OPERATE_TYPE'
  }

  // 操作文件来源
  export enum FileSource {
    UNKNOWN = 'UNKNOWN', // 未知
    GALLERY = 'GALLERY', // 图库
    LOCAL = 'LOCAL', // 我的手机-本地
    EXTERNAL = 'EXTERNAL' // 外接存储
  }

  // 触发引导弹框的操作
  export enum ReasonType {
    CREATE = 'CREATE', //新建
    COPY = 'COPY', //复制
    PASTE = 'PASTE', //粘贴
    MOVE = 'MOVE', //移动
    ERR_CODE = 'ERR_CODE' //触发磁盘空间满的错误码。
  }

  /**
   * 浏览页-位置中的项目操作类型
   */
  export enum LocationItemOperType {
    // 显示
    SHOW = 'SHOW',
    // 隐藏
    HIDE = 'HIDE'
  }

  // 折叠状态
  export enum DrawerMode {
    EXPAND = 'EXPAND',
    COLLAPSE = 'COLLAPSE'
  }

  // 铃声类型
  export const RingtoneList: string[] = ['CALL', 'MESSAGE', 'NOTIFICATION', 'ALARM'];
}