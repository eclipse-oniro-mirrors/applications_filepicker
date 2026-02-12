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
 * 结果码
 */
export namespace ResultCode {
  export enum Exception {
    /**
     * 无异常
     */
    EXCEPTION_OK = -1,
    /**
     * 任务取消
     */
    EXCEPTION_TASK_CANCEL,
    /**
     * 存在同名文件
     */
    EXIST_DUPLICATE_FILE,
    /**
     * 存在同名文件夹
     */
    EXIST_DUPLICATE_FOLDER,
    /**
     * 粘贴到子文件夹
     */
    CANNOT_PASTE_TO_SUB_FOLDER,
    /**
     * 还原路径存在同名文件
     */
    RECOVER_EXIST_SAME_NAME_FILE,
    /**
     * 文件名非法
     */
    FILE_NAME_INVALID,

    /**
     * 往图库根路径粘贴内容中包含文件
     */
    EXCEPTION_PASTE_CONTENT_INCLUDE_FILE,

    /**
     * 往图库路径粘贴，存在非视频图片类型文件
     */
    EXCEPTION_EXIST_UNSUPPORTED_TYPE,

    /**
     * 往图库粘贴，存在非视频图片类型文件，粘贴的都是文件
     */
    EXCEPTION_FILE_INIT_FAIL,

    /**
     * 图库根路径粘贴单个文件夹
     */
    EXCEPTION_GALLERY_ROOT_PASTER_FOLDER,

    /**
     * 图库根路径粘贴多个文件夹
     */
    EXCEPTION_GALLERY_ROOT_PASTER_FOLDERS,

    /**
     * 图库相册路径粘贴多个文件夹
     */
    EXCEPTION_GALLERY_ALBUM_PASTER_FOLDER,

    /**
     * 截图路径粘贴不支持类型
     */
    EXCEPTION_SCREENSHOT_ALBUM_PASTER_UNSUPPORT_FOLDER,

    /**
     * 录屏路径粘贴不支持类型
     */
    EXCEPTION_SCREENRECORD_ALBUM_PASTER_UNSUPPORT_FOLDER,

    /**
     * 图库文件名非法
     */
    EXCEPTION_GALLERY_FILE_NAME_INVALID,
  }

  export enum Error {
    /**
     * 源文件不存在
     */
    SRC_FILE_NOT_EXIST,

    /**
     * 磁盘空间不足
     */
    NO_SPACE_LEFT,

    /**
     * 复制同名子文件夹到同名父文件夹所在的路径下
     */
    OPERATE_DUP_FOLDER_FROM_CHILD_TO_PARENT,

    /**
     * 权限管控-只读系统
     */
    READONLY_FILE_SYSTEM,

    /**
     * 权限管控-操作无权限
     */
    FILE_OPERATE_NOT_PERMITTED,

    /**
     * 未知错误
     */
    UNKNOWN_ERROR,

    /**
     * 任务数量受限
     */
    TASK_LIMIT,

    /**
     * 返回桌面
     */
    BACK_TO_DESK,

    /**
     * 文件名非法
     */
    FILE_NAME_INVALID,

    /**
     * 图库跟路径下带有文件
     */
    ERROR_GALLERY_ROOT_PASTER,

    /**
     * 图库文件名非法
     */
    ERROR_GALLERY_FILE_NAME_INVALID,
  }
}
