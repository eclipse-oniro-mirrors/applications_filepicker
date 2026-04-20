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
namespace CopyCutConst {
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
     * 消息码：usbChange
     */
    static readonly USB_CHANGE = 5;
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
    static readonly DESTINATION_PARENT_ERROR = 5;

    /**
     * 任务正在运行
     */
    static readonly TASK_RUNNING = 6;

    /**
     * 退出文管
     */
    static readonly TASK_BACK_DESK = 7;

    /**
     * 空间不足
     */
    static readonly OUT_SPACE_LIMIT = 8;
  }

  /**
   * 用户冲突弹框选择结果
   */
  export class ChooseType {
    
    /**
     * 默认
     */
    static readonly DEFAULT = 0;

    /**
     * 停止
     */
    static readonly STOP = 1;

    /**
     * 替换
     */
    static readonly REPLACE = 2;

    /**
     * 合并（文件夹）或者保留（文件）
     */
    static readonly MERGE_KEEP = 3;

    /**
     * 文件夹保留
     */
    static readonly FOLDER_KEEP = 4;

    /**
     * 路径异常：停止
     */
    static readonly PATH_ERROR_STOP = 5;

    /**
     * 路径异常：跳过
     */
    static readonly PATH_ERROR_SKIP = 6;

    /**
     * 其它异常：停止
     */
    static readonly OTHER_ERROR_STOP = 7;

    /**
     * 其它异常：跳过
     */
    static readonly OTHER_ERROR_SKIP = 8;
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
     * 拖拽
     */
    static readonly FROM_DRAG = 'drag';

    /**
     * 外部拖拽
     */
    static readonly FROM_DRAG_EXTERNAL = 'dragExternal';

    /**
     * 从最近页进的查看器
     */
    static readonly MEDIA_RECENT_PRE_VIEW = 'mediaRecentPreview';
  }

  /**
   * 任务类型
   */
  export class TaskType {
    /**
     * 移动
     */
    static readonly CUT = 'cut';
    /**
     * 复制
     */
    static readonly COPY = 'copy';
    /**
     * 拖拽
     */
    static readonly DRAG = 'drag';
  }
}

export default CopyCutConst;