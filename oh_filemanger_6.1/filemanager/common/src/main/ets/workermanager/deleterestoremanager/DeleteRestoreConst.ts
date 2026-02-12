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
export namespace DeleteRestoreConst {
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

  export enum TaskType {
    /**
     * 永久删除
     */
    PERMANENT_DELETE,
    /**
     * 从回收站删除
     */
    DELETE_FILE_FROM_TRASH,
    /**
     * 还原文件
     */
    RECOVER,
    /**
     * 删除到回收站
     */
    SOFT_DELETE,
  }

  export enum ChooseType {
    /**
     * 跳过
     */
    SKIP,
    /**
     * 停止
     */
    STOP,
    /**
     * 保留两者
     */
    KEEP_BOTH_FILE,
    /**
     * 合并
     */
    MERGE_FOLDER
  }
}

export default DeleteRestoreConst;