/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

export enum HiSysEventName {
  /*故障事件*/
  // 文件初始化接口失败
  FILE_FAF_FAIL = 'FILE_FAF_FAIL',
  // 文件操作接口失败
  FILE_OPERATE_FAIL = 'FILE_OPERATE_FAIL',
  // 临时解密文件生成失败
  TEMP_FILE_CREATE_FAIL = 'TEMP_FILE_CREATE_FAIL',
  // 文管通用故障事件
  FILE_MANAGER_COMMON_FAIL = 'FILE_MANAGER_COMMON_FAIL',
  /*行为事件*/
  // 拉起文管、picker窗口统计
  CREATE_ABILITY = 'CREATE_ABILITY',
  // 点击侧边栏
  LEFT_BAR_ITEM_CLICK = 'LEFT_BAR_ITEM_CLICK',
  // 点击底部栏
  BOTTOM_TAB_CLICK = 'BOTTOM_TAB_CLICK',
  // 文件视图信息切换
  FILE_VIEW_CHANGE = 'FILE_VIEW_CHANGE',
  // 文管排序方式切换
  FILE_GROUP_SORT_TYPE_CHANGE = 'FILE_GROUP_SORT_TYPE_CHANGE',
  /*统计事件*/
  // 记录文管U盘路径获取文件时延
  EXTERNAL_GET_FILE_COST = 'EXTERNAL_GET_FILE_COST',
  // 文件操作打点
  FILE_OPERATION = 'FILE_OPERATION',
  // 文档备份操作
  DOCUMENT_BACKUP = 'DOCUMENT_BACKUP',
  // 拉起picker窗口统计
  OPEN_FILE_PICKER = 'OPEN_FILE_PICKER',
  // 文件备份恢复打点
  FILE_BACKUP = 'FILE_BACKUP',
  // 打开其他应用
  OPEN_OTHER_APP = 'OPEN_OTHER_APP',
  // 创建下载目录
  CREATE_DOWNLOAD_FOLDER = 'CREATE_DOWNLOAD_FOLDER',
  // 常规通用操作打点
  USER_GENERAL_OPERATION = 'USER_GENERAL_OPERATION'
}

export enum InterfaceName {
  CREATE_FAF_HELPER = 'createFileAccessHelper',
  FS_RMDIR_SYNC = 'fsRmdirSync',
  FS_UNLINK_SYNC = 'fsUnlinkSync',
  FS_MKDIR_SYNC = 'fsMkdirSync',
  FS_LIST_FILE_SYNC = 'fsListFileSync',
  FS_CLOSE_SYNC = 'fsCloseSync',
  FS_FILE_SYNC = 'fsFsync',
  FS_RENAME_SYNC = 'fsRenameSync',
  FAF_DELETE = 'fafDelete',
  TRASH_COMPLETELY_DELETE = 'trashCompletelyDelete',
  TRASH_RECOVER = 'trashRecover',
  COPY_FILE_CONTENT_BY_FD = 'copyFileContentByFd',
  MOVE_FOLDER = 'moveFolder',
  MOVE_FILE = 'moveFile',
  DO_PASTE = 'doPaste',
  GET_RIGHT_FILES_FROM_EXTERNAL_DISK = 'getRightFilesFromExternalDisk',
  GET_DEVICE_CONNECT_TOAST = 'getDeviceConnectToast',
  START_OPEN_FILE = 'startOpenFile',
}

export enum OperateName {
  CREATE,
  DELETE,
  OPEN,
  RENAME,
  DRAG,
  COPY,
  PASTE,
  CUT,
  MOVE,
  RECOVER
}

export enum OperateFileType {
  FILES = 'files',
  FOLDER = 'folder'
}

export enum OperateFrom {
  RIGHTMENU,
  KEYBOARD,
  TOOLBAR,
  OTHER
}

export enum OperateResult {
  SUCCESS,
  FAIL,
  MOVE_DB_FILE_FILED = -1, // 移动数据库文件失败
  MOVE_SOFEBOX_FILE_FILED = -2, // 移动文件失败
  LOCAL_AND_DB_NUMBER_DIFF = -4, // 数据库与本地文件数量不一致.
  MKDIR_TEMP_FAILED = -5, // 创建temp目录失败
  FILE_NOT_EXIST = 13900002, // 文件不存在
  RESTORE_BEGIN = 3, // 开始标识
  RESTORE_HMOS_SPECIAL_DIR_SUCCESS = 4 // 恢复双框架特殊文件夹成功
}

export enum PathLocation {
  LOCAL,
  EXTERNAL
}

export enum ModificationDate {
  ALL,
  TODAY = 20,
  YESTERDAY,
  THIS_WEEK,
  LAST_WEEK,
  THIS_MONTH,
  LAST_MONTH,
  THIS_YEAR,
  LONG_AGO
}

export enum FileSize {
  ALL,
  ZERO = 35,
  TINY,
  SMALL,
  MEDIUM,
  BIG,
  OVERSIZE
}

export enum OperateType {
  CLICK,
  DOUBLE_CLICK,
  PREVIEW
}

export enum AbilityName {
  FILE_MANAGER = 'fileManager',
  FILE_PICKER = 'filePicker',
  FILE_PICKER_ABILITY = 'FilePickerAbility',
  PATH_PICKER_ABILITY = 'PathPickerAbility',
  PATH_PICKER = 'pathPicker',
  DOWNLOAD_AUTH = 'DownloadAuth',
  OPEN_MEDIA = 'openMedia' // 提供给外部拉起聚合页的UIExtensionAbility
}

export enum FileBackupScenario {
  UPGRADE_HMOS_UP_NEXT,
  CLONE_HMOS_TO_NEXT,
  CLONE_NEXT_TO_NEXT,
  CLONE_WIN_TO_NEXT,
  MIGRATE_HMOS_TO_NEXT,
  RESTORE
}

export enum FileBackupOperateType {
  DOCUMENTS_BACKUP
}

export class Constant {
  // 固定HASH长度1
  public static readonly HASH_LEN = 64;
  // 固定HASH长度2
  public static readonly HASH_LEN2 = 120;
}