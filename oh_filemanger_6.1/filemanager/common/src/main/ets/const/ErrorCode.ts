/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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


export enum OperateFileResult {
  NORMAL_RESULT,
  IS_RENAMING,
  CONTAIN_SPECIAL_CHARACTER,
  DUPLICATE_FILENAME,
  SAVE_FILE_FAILED,
  FILE_EXTENSION_CHANGE,
  OPERATE_FAILED,
  EXIT_RENAME,
  ALL_IS_SPACE,
  FILE_EXISTS
}

export enum OperateTagResult {
  NORMAL_RESULT,
  CONTAIN_SPECIAL_CHARACTER,
  DUPLICATE_TAG_NAME,
  INVALID_PARAMETER
}

export enum RdbErrCode {
  RdbErr = 14800011
}

/**
 * 错误码
 */
export namespace ERROR_CODE {

  /**
   * 网络相关错误码
   */
  export enum NETWORK {
    /**
     * 网络异常
     */
    NETWORK_ERROR = 1009400003
  }


  /**
   * 文件系统相关错误码
   */
  export enum FILE_ACCESS {

    /**
     * 以下为基础文件IO错误码
     *
     * 操作不允许
     */
    FILE_OPERATE_NOT_PERMITTED = 13900001,

    /**
     * 没有这个文件或目录
     */
    FILE_NOT_EXIST = 13900002,

    /**
    * 没有这个文件或目录（文管服务返回的错误码）
    */
    FILE_NOT_EXIST_SERVER = 19900021,

    /**
     * 资源被阻塞
     */
    TRY_AGAIN = 13900010,

    /**
     * 拒绝许可
     */
    PERMISSION_DENIED = 13900012,

    /**
     * 文件存在
     */
    FILE_EXISTS = 13900015,

    /**
     * 非文件夹路径
     */
    NON_FOLDER = 13900018,

    /**
     * Invalid argument
     */
    INVALID_ARGUMENT = 13900020,

    /**
     * 设备上没有空间
     */
    NO_SPACE_LEFT_ON_DEVICE = 13900025,

    /**
     * 只读文件系统
     */
    READONLY_FILE_SYSTEM = 13900027,

    /**
     * 超出磁盘配额
     */
    QUOTA_EXCEEDED = 13900041,

    /**
     * 未知错误
     */
    UNKOWN_ERROR = 13900042,


    /**
     * 取消拷贝后，fs.copy 报错
     */
    OPERATION_CANCELED = 13900049,


    /**
     * 以下为用户数据管理错误码
     *
     * 文件名非法
     */
    FILE_NAME_INVALID = 14000001,

    /**
     * 非法URI
     */
    FILE_URI_INVALID = 14000002
  }

  /**
   * 选择器相关错误码
   */
  export enum PICKER {
    /**
     * 文件保存成功
     */
    SAVE_SUCCESS = 1000
  }

  export enum VOLUME {
    /**
     * 不支持的文件系统
     */
    NOT_SUPPORTED_FILESYSTEM = 13600002
  }
}
