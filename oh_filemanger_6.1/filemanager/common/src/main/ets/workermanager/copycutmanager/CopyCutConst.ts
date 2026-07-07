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
 * 本地移动复制常量
 */
export namespace CopyCutConst {
  export class SendMsgCode {
    /**
     * 消息码：开始
     */
    static readonly START: number = 1;

    /**
     * 消息码：取消
     */
    static readonly CANCEL: number = 2;

    /**
     * 消息码：冲突
     */
    static readonly CONFLICT: number = 3;

    /**
     * 消息码：查询状态
     */
    static readonly QUERY_TASK_STATUS = 4;

    /**
     * 消息码：外卡变化
     */
    static readonly EXTERNAL_DISK_CHANGE = 5;

    /**
     * 消息码：异常处理后继续运行
     */
    static readonly EXCEPTION_CONTINUE_TO_RUN = 6;
  }

  /**
   * 冲突类型
   */
  export class ConflictType {
    /**
     * 正常
     */
    static readonly FILE_DEFAULT = 0;

    /**
     * 文件冲突
     */
    static readonly FILE_CONFLICT = 1;

    /**
     * 文件夹冲突
     */
    static readonly FOLDER_CONFLICT = 2;

    /**
     * 路径异常冲突
     */
    static readonly PATH_CONFLICT = 3;

    /**
     * 其他异常
     */
    static readonly OTHER_ERROR = 4;

    /**
     * 是目标目录父目录
     */
    static readonly DEST_PARENT_ERROR = 5;

    /**
     * 任务正在运行
     */
    static readonly TASK_RUNNING = 6;

    static readonly EXCEPTION_CONTINUE_RUN = 7;
  }

  /**
   * 用户冲突弹框选择结果
   */
  export enum ChooseType {
    /**
     * 默认
     */
    DEFAULT,

    /**
     * 停止
     */
    STOP,

    /**
     * 替换文件
     */
    REPLACE_FILE,

    /**
     * 保留两者（文件）
     */
    KEEP_BOTH_FILE,

    /**
     * 替换文件夹
     */
    REPLACE_FOLDER,

    /**
     * 合并文件夹
     */
    MERGE_FOLDER,

    /**
     * 其它类型跳过
     */
    SKIP,

    /**
     * 文件重名跳过
     */
    SKIP_FILE,

    /**
     * 文件夹重名跳过
     */
    SKIP_FOLDER,

    /**
     * 继续运行
     */
    CONTINUE_TO_RUN,
  }

  /**
   * 复制粘贴来源
   */
  export class OperateFrom {
    /**
     * 粘贴板
     */
    static readonly PASTE_BOARD = 'pasteBoard';

    /**
     * 最近页
     */
    static readonly RECENT_VIEW = 'recentView';

    /**
     * 从最近页进的查看器
     */
    static readonly MEDIA_RECENT_PRE_VIEW = 'mediaRecentPreview';
  }
}

export default CopyCutConst;