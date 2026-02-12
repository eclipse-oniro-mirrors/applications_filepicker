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

import { FileSourceType } from '../../const/Constant';
import { common, Context } from '@kit.AbilityKit';

/**
 * 文件查询参数
 */
export class QueryFileParam {
  /**
   * 文件夹url或相对路径
   */
  public dirUri: string = '';
  /**
   * 按某种类型排序
   */
  public orderBy: string = '';
  /**
   * 是否是降序
   */
  public isDesc: boolean = false;
  /**
   * 面包屑全路径
   */
  public currBreadFullPath: string = '';
  /**
   * 是否是外置存储
   */
  public isExternalStorageDevice: boolean = false;
  /**
   * 根目录或挂载名称
   */
  public rootName: string = '';
  /**
   * 存储设备的uid
   */
  public storageDeviceUid: string = '';
  /**
   * 文件来源
   */
  public sourceType: number = FileSourceType.UNKNOWN;
  /**
   * Context
   */
  public context: Context | undefined = undefined;
  /**
   * 查询的唯一ID, 用于聚合视图增量查询时的唯一标识
   */
  public queryId: number = 0;
  /**
   * 用于指定相册查询
   */
  public albumType?: number;
  public albumSubType?: number;
  //默认图片过滤的大小
  public sizeMin: number = 30;
  /**
   * 显示隐藏文件
   */
  public showHiddenItem: boolean = true;
  /**
   * 是否黑名单
   */
  public isBlackSuffix: boolean = false;
  /**
   * 文件后缀
   */
  public suffixList: string[] = [];
  /**
   * 文件夹路径
   */
  public folderUri: string = '';
  public folderUriPrefixList: string[] = [];
  /**
   * 页面来源
   */
  public pageFrom: string = '';

  /**
   * 是否持久化授权增量查询模式
   */
  public isPersistPermission: boolean = false;

  public tokenID: number = 0;

  /**
   * 搜索关键词
   */
  public keyword: string = ''

  /**
   * 是否递归
   */
  public recursive: boolean = false
}

export class QueryRecentFileParam {
  /**
   * 最近页面默认获取图库的500个资源
   */
  public static DEFAULT_RECENT_NUM: number = 500;

  /**
   * Context,用于图库数据库查询
   */
  public context: Context | undefined = undefined;

  /**
   * contextGlobal app context,用于子线程recent数据库操作
   */
  public contextGlobal: common.ApplicationContext | undefined = undefined;

  public fetchLimit: number = 500;

  constructor(galleryDataContext?: Context, appContext?: common.ApplicationContext, limit?: number) {
    this.context = galleryDataContext;
    this.contextGlobal = appContext;
    if (limit) {
      this.fetchLimit = limit;
    }
  }
}