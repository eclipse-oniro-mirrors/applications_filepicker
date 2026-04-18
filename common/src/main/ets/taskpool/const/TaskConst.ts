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

export class TaskConst {
  public static TAG: string = 'FileQueryTask';

  /**
   * 线程执行模式
   */
  public static readonly taskExecuteMode = {
    reject: 0, // 当前线程池已满，拒绝执行
    waitToExecute: 1, // 添加到等待执行队列里
    executeNow: 2 // 立刻执行, 如果当前线程池已满，会取消其中的一个任务
  };
}

export enum TaskStatus {
  /**
   * 待执行
   */
  IDLE = 0,
  /**
   * 正在运行
   */
  RUNNING,
  /**
   * 取消
   */
  CANCEL,
  /**
   * 异常
   */
  ERROR,
  /**
   * 结束
   */
  END
}

/**
 * 线程池名称
 */
export class TaskPoolName {
  /**
   * 单线程任务默认线程池
   */
  static readonly SINGLE_DEFAULT: string = 'singleDefault';

  /**
   * 查询文件项数线程池
   */
  static readonly QUERY_FOLDER_SUB_COUNT: string = 'queryFolderSub';

  /**
   * 文件操作线程池
   */
  static readonly FILE_OPERATE: string = 'fileOperate';

  /**
   * 文件查询线程池
   */
  static readonly FILE_QUERY: string = 'fileQuery';

  /**
   * 媒体文件元数据获取线程池
   */
  static readonly MEDIA_META_DATA_QUERY: string = 'mediaMetaDataQuery';

  /**
   * 媒体文件大小与时长数据获取线程池
   */
  static readonly MEDIA_SIZE_AND_DURATION_QUERY: string = 'mediaSizeAndDurationQuery';

  /**
   * 图片文件尺寸数据获取线程池
   */
  static readonly IMAGE_SIZE_DATA_QUERY: string = 'imageSizeDataQuery';

  /**
   * 查询路径选择器目录的线程池
   */
  static readonly QUERY_PICK_PATH: string = 'queryPickPath';

  /**
   * 计算文件夹大小
   */
  static readonly COUNT_FOLDER_SIZE: string = 'countDetailFolderSize';

  /**
   * 资源图片缓存为PixelMap
   */
  static readonly RESOURCE_CACHED_PIXELMAP: string = 'resourceCachedPixelMap';

  /**
   * 软删除
   */
  static readonly SOFT_DELETE: string = 'softDelete';

  /**
   * 处理双升单回收站文件
   */
  static readonly PROCESS_FILE_RECYCLE_TASK: string = 'processFileRecycleTask';

  /**
   * 恢复
   */
  static readonly RECOVER: string = 'recover';

  /**
   * 文件服务操作接口
   */
  static readonly FILE_MANAGER_SERVICE_OPERATION: string = 'fileManagerServiceOperationTask';

  /**
   * 查询文件项数线程池
   */
  static readonly QUERY_GALLERY_FOLDER_SIZE: string = 'queryGalleryFolderSizeTask';

  /**
   * 计算文件列表总大小
   */
  static readonly CALCULATE_FILE_LIST_SIZE_TASK: string = 'calculateFileListSizeTask';

  /**
   * 计算文件夹列表总大小
   */
  static readonly CALCULATE_FOLDER_LIST_SIZE_TASK: string = 'calculateFolderListSizeTask';

  /**
   * 初始化来源数据库信息
   */
  static readonly INIT_SOURCE_TASK: string = 'initSourceTask';

  /**
   * 查询系统垃圾文件
   */
  static readonly QUERY_SYSTEM_TRASH_FILES: string = 'querySystemTrashFiles';

  /**
   * 查询重复文件
   */
  static readonly QUERY_DUPLICATE_FILES: string = 'queryDuplicateFilesTask';

  /**
   * 查询选中文件/目录的总大小
   */
  static readonly QUERY_CHECKED_FILE_SIZE: string = 'queryCheckedFilesSizeTask';

  /**
   * 添加至最近访问
   */
  static readonly QUERY_FILES_RECURSIVELY: string = 'queryFilesRecursively';

  /**
   * 过滤不允许访问的uri
   */
  static readonly FILTER_URIS: string = 'filterUrisTask';

  /**
   * 创建下载目录uri展示map
   */
  static readonly CREATE_DOWNLOAD_URI_SHOW_MAP: string = 'createDownloadUriShowMapTask';

  /**
   * 查询文件的LocationType
   */
  static readonly GET_LOCATION_TYPE: string = 'getLocationTypeTask';

  static readonly BATCH_GRANT_URI_PERMISSION_TASK: string = 'batchGrantUriPermissionTask';

  /**
   * 检查uri是否禁止跳转
   */
  static readonly CHECK_IS_FORBIDDEN_URI: string = 'checkIsForbiddenUriTask';
}


