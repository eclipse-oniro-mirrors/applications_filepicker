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
 * 打点相关常量类
 */
export class ReportConst {
  /**
   * 管控平台录入的自定义事件Id
   */
  public static readonly EVENT_ID: string = 'FileManager';

  /**
   * 打点上报相关常量
   */
  public static reportKey = class {
    /**
     * 返回码，对应report实例的packageName
     */
    public static readonly KEY_PACKAGE_NAME: string = 'pn';
    /**
     * 返回码，对应report实例的code
     */
    public static readonly KEY_RETURN_CODE: string = 'returnCode';

    /**
     * 返回描述，对应report实例的msg
     */
    public static readonly KEY_ERROR_REASON: string = 'errorReason';

    /**
     * 请求操作类型，对应report实例的operationType
     */
    public static readonly KEY_OPERATION_TYPE: string = 'operationType';
    /**
     * 业务Id,对应report实例的cmd
     */
    public static readonly KEY_BUSINESS_ID: string = 'business_id';
    /**
     * 流水号,对应report实例的cmd
     */
    public static readonly KEY_TRACE_ID: string = 'traceID';
  };

  /**
   * 运维打点--端测return_code统一定义，统一含义
   */
  public static returnCode = class {
    /**
     * 操作成功
     */
    public static readonly SUCCESS: number = 0;

    /**
     * 网络未连接
     */
    public static readonly NETWORK_DISCONNECTED: number = 1;

    /**
     * ST失效
     */
    public static readonly ST_INVALID: number = 2;

    /**
     * 服务器异常
     */
    public static readonly SERVER_ERROR: number = 3;

    /**
     * 各种参数错误、比如说服务器返回某某字段字段值不符合预期等
     */
    public static readonly PARAM_ERROR: number = 4;

    /**
     * 本地错误
     */
    public static readonly LOCAL_ERROR: number = 5;

    /**
     * 用户取消
     */
    public static readonly USER_CANCEL: number = 6;

    /**
     * 下载文件时，文件不存在
     */
    public static readonly CONTENT_NOT_FOUND: number = 404;
  };

  /**
   * 运维打点--通用事件描述
   */
  public static returnMsg = class {
    /**
     * 操作成功
     */
    public static readonly SUCCESS: string = 'success';

    /**
     * 操作失败
     */
    public static readonly FAILED: string = 'fail';

    /**
     * 参数错误
     */
    public static readonly PARAM_ERROR: string = 'parameter_error';

    /**
     * ST失效
     */
    public static readonly ST_INVALID: string = 'st_invalid';
  };


  public static reportPackage = class {
    /**
     * 打点文件管理唯一标识
     */
    public static readonly PACKAGENAME_FILEMANAGER: string = 'filemanager';

    /**
     * 打点数据公共唯一标识
     */
    public static readonly PACKAGENAME_COMMON: string = 'common';

  };

  public static businessId = class {

    /**
     * 文管
     */
    public static filemanager = class {

      /**
       * 进入文管页面
       */
      public static readonly ENTER_FILEMANAGER: string = 'enterFileManager';
    };
  };

  public static operationType = class {
    /**
     * 以下是文件管理需要打点的场景及列表
     */
    public static filemanager = class {

      /**
       * 文件管理器敏感操作--删除
       */
      public static readonly SENSITIVE_OPER_DELETE = '10001';

      /**
       * 文件管理，彻底删除过程详情
       */
      public static readonly FILE_DELETE_OPER_FAILED = '10002';

      /**
       * 文件管理，软删除过程详情
       */
      public static readonly FILE_SOFT_DELETE_FAILED = '10003';

      /**
       * 文件管理，还原过程详情
       */
      public static readonly FILE_RESTORE_OPER_FAILED = '10004';

      /**
       * 文件管理，在线编辑调用Drive files.get接口查询onLineViewLink为空
       */
      public static readonly ONLINE_VIEW_LINK_QUERY_EMPTY = '10007';

      /**
       * 文件管理，分类数据获取
       */
      public static readonly FILE_CATEGORY_GET_DATA_MODE = '10009';

      /**
       * 文件管理筛选
       */
      public static readonly FILE_CATEGORY_FILTER = '10010';

      /**
       * 文件管理重命名失败
       */
      public static readonly FILE_RENAME_FAILED = '10011';

      /**
       * 文件管理移动复制失败
       */
      public static readonly FILE_CUT_OR_COPY_FAILED = '10012';

      /**
       * 文件管理目标目录获取异常
       */
      public static readonly FILE_CUT_OR_COPY_DEST_FOLDER_EXCEPTION = '10013';

      /**
       * 文件管理粘贴过程中异常
       */
      public static readonly FILE_PASTING_EXCEPTION = '10014';

      /**
       * 文件管理移动完成删除源文件失败
       */
      public static readonly FILE_DELETE_SRC_FILE_RESULT = '10015';

      /**
       * 文件管理，分享文件发送数据
       */
      public static readonly FILE_SHARE_DATA = '10016';

      /**
       * 文件管理，U盘及SD卡创建文件夹是否成功
       */
      public static readonly FILE_DIR_CREATE_IN_EXTERNAL_MOUNTED = '100019';

      /**
       * 文件管理，查询白名单路径
       */
      public static readonly FILE_WHITE_FILE_PATH_NO_EXISTS = '100020';

      /**
       * 文件管理，查询白名单文件数量
       */
      public static readonly FILE_WHITE_FILE_PKG_AND_FILE_NUM = '100021';

      /**
       * 文件管理，分类统计数量
       */
      public static readonly FILE_CATEGORY_COUNTS = '100023';


      /**
       * 最近页面查询异常
       */
      public static readonly RECENT_QUERY_DB_ERROR = '100025';

      /**
       * 进入文管页面
       */
      public static readonly ENTER_FILEMANAGER_PAGE: string = '100026';
    };
  };
}