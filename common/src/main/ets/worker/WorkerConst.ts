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
 * worker常量
 */
export namespace WorkerConst {
  /**
   * worker最大数量(7), 由于FAF接口多线程访问会导致crash，当前先规避最大1个线程执行，待FAF支持多线程后再放开
   */
  export const WORKER_LIMIT_SIZE = 7;

  // 只用五个操作，复制粘贴、剪切粘贴、删除、还原、获取文件，Worker里面只操作FS，其他接口在主线程通过FAF操作
  export enum OperateType {
    /**
     * 取消
     */
    CANCEL,

    /**
     * 复制文件
     */
    COPY_FILE,

    /**
     * 剪切文件
     */
    CUT_FILE,

    /**
     * 拖拽文件
     */
    DRAG_FILE,

    /**
     * 删除文件
     */
    DELETE_FILE,

    /**
     * 还原文件
     */
    RESTORE_FILE,

    /**
     * 软删文件
     */
    SOFT_DELETE_FILE,

    /**
     * 还原移动
     */
    UNDO_MOVE,
  }

  export class ResultType {
    /**
     * 操作成功
     */
    public static readonly SUCCESS = 0;

    /**
     * 操作出现错误
     */
    public static readonly ERROR = 1;

    /**
     * 操作出现异常
     */
    public static readonly EXCEPTION = 2;

    /**
     * 展示进度条（pad适配pc文件管理）
     */
    public static readonly SHOW_PROGRESS = 3;

    /**
     * 更新操作进度
     */
    public static readonly PROGRESS = 4;

    /**
     * 操作正在进行中
     */
    public static readonly RUNNING = 5;

    /**
     * 操作被取消
     */
    public static readonly CANCEL = 6;
  }

  export class DeleteRestoreResultType {
    /**
     *软删除更新收藏表
     */
    public static readonly SOFT_DELETE_UPDATE_FAVORITE = 1001;

    /**
     *硬删除更新收藏表
     */
    public static readonly HARD_DELETE_UPDATE_FAVORITE = 1002;

    /**
     * 还原更新搜藏
     */
    public static readonly RESTORE_UPDATE_FAVORITE = 1003;

    /**
     * 还原失败
     */
    public static readonly RESTORE_FAIL = 1004;
  }

  export class CopyCutResultType {
    /**
     *软删除更新收藏表
     */
    public static readonly UPDATE_FAVORITE_LIST = 1001;

    /**
     * 查询状态
     */
    public static readonly QUERY_WORKER_STATUS = 1002;
  }

  export enum DialogType {
    /**
     * 源文件不存在
     */
    SRC_FILE_NOT_EXIST,

    /**
     * 存在同名文件
     */
    PASTE_EXIST_DUPLICATE_FILE,

    /**
     * 存在同名文件夹
     */
    PASTE_EXIST_DUPLICATE_FOLDER,

    /**
     * 磁盘空间不足
     */
    NO_SPACE_LEFT,

    /**
     * 复制同名子文件夹到同名父文件夹所在的路径下
     */
    OPERATE_DUP_FOLDER_FROM_CHILD_TO_PARENT,

    /**
     * 粘贴到子文件夹
     */
    CANNOT_PASTE_TO_SUB_FOLDER,

    /**
     * 权限管控-只读系统
     */
    READONLY_FILE_SYSTEM,

    /**
     * 还原同名文件
     */
    RECOVER_SAME_NAME_FILE,

    /**
     * 权限管控-操作无权限
     */
    FILE_OPERATE_NOT_PERMITTED,

    /**
     * 未知错误
     */
    UNKNOWN_ERROR,

    /**
     * 文件名含不支持的特殊字符
     */
    RECOVER_FILE_NAME_INVALID,
  }

  export enum WorkerStatus {
    /**
     * 成功
     */
    SUCCESS = 1,

    /**
     * 失败
     */
    FAIL = 0,

    /**
     * 取消
     */
    CANCEL = -1,

    /**
     * 运行中
     */
    RUNNING = -2
  }

  export enum WorkerState {
    /**
     * 待执行
     */
    IDLE = 0,

    /**
     * 执行中
     */
    RUNNING = 1,

    /**
     * 执行结束
     */
    FINISH = 2,

    /**
     * 取消
     */
    CANCEL = 3
  }
}

export default WorkerConst;