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
import { DFX } from './const/DFXConst';
import { Constant, LocationItemName, SortOrder } from '../const/Constant';
import { HiLog } from './HiLog';
import { PAGE_ROUTE_CONST } from '../const/PageRouteConst';
import { PhotoAlbumSubType, PhotoAlbumType } from '../media/AlbumType';
import { HashSet } from '@kit.ArkTS';
import { VirtualUri } from '../const/FolderRecord';

const TAG: string = 'EnumTransferUtil';

export class EnumTransferUtil {
  private static readonly FILE_VIEW_LIST: string = 'list';
  private static readonly URI_GALLERY = 'file://media/PhotoAlbum';

  /**
   * 将移动网络提示选择由数字转化为UE打点所需枚举值
   * @param networkOption 移动网络提示选择项
   * @returns UE打点枚举值
   */
  public static transferToCellularTip(networkOption: number): DFX.CellularTipMode {
    let tipMode: DFX.CellularTipMode;
    switch (networkOption) {
      case Constant.NETWORK_OPTION.ALWAYS_NOTICE:
        tipMode = DFX.CellularTipMode.ALWAYS_NOTICE;
        break;
      case Constant.NETWORK_OPTION.NOTICE_WHEN_OVER_100MB:
        tipMode = DFX.CellularTipMode.OVER_100MB_NOTICE;
        break;
      case Constant.NETWORK_OPTION.ALWAYS_ALLOW:
        tipMode = DFX.CellularTipMode.ALWAYS_ALLOW;
        break;
      default:
        HiLog.warn(TAG, `transferToCellularTip fail, networkOption:${networkOption}`);
        tipMode = DFX.CellularTipMode.UNKNOWN;
        break;
    }
    return tipMode;
  }

  /**
   * 将页面路由常量由字符串转化为UE打点所需枚举值
   * @param pageRoute 页面路由常量
   * @returns UE打点枚举值
   */
  public static transferToPageName(pageRoute: string): DFX.PageName {
    let pageName: DFX.PageName;
    switch (pageRoute) {
      case PAGE_ROUTE_CONST.GALLERY:
        pageName = DFX.PageName.GALLERY;
        break;
      case PAGE_ROUTE_CONST.RECENT_DELETE:
        pageName = DFX.PageName.RECENT_DELETE;
        break;
      case PAGE_ROUTE_CONST.MY_PHONE:
      case Constant.FROM_TYPE.MY_PHONE:
        pageName = DFX.PageName.MY_PHONE;
        break;
      default:
        HiLog.warn(TAG, `transferToPageName fail, pageRoute:${pageRoute}`);
        pageName = DFX.PageName.UNKNOWN;
        break;
    }
    return pageName;
  }

  /**
   * 将文件视图模式由字符串转化为UE打点所需枚举值
   * @param viewMode 文件视图模式
   * @returns UE打点所需枚举值
   */
  public static transferToViewMode(viewMode: string): DFX.ViewType {
    return viewMode === this.FILE_VIEW_LIST ? DFX.ViewType.LIST : DFX.ViewType.GRID;
  }

  /**
   * 将文件排序方式由字符串转化为UE打点所需枚举值
   * @param sortOrder 文件排序方式
   * @returns UE打点所需枚举值
   */
  public static transferToSortType(sortOrder: string): DFX.SortType {
    let sortType: DFX.SortType;
    switch (sortOrder) {
      case SortOrder.DEFAULT:
        sortType = DFX.SortType.DEFAULT;
        break;
      case SortOrder.NAME:
        sortType = DFX.SortType.NAME;
        break;
      case SortOrder.TIME:
        sortType = DFX.SortType.TIME;
        break;
      case SortOrder.SIZE:
        sortType = DFX.SortType.SIZE;
        break;
      case SortOrder.TYPE:
        sortType = DFX.SortType.TYPE;
        break;
      default:
        HiLog.warn(TAG, `transferToSortType fail, unknown input sortOrder`);
        sortType = DFX.SortType.UNKNOWN;
        break;
    }
    return sortType;
  }

  /**
   * 将媒体库相册枚举转化为UE打点所需枚举值
   * @param albumType 媒体库相册枚举
   * @returns UE打点所需枚举值
   */
  public static transferToAlbumType(albumType: PhotoAlbumType): DFX.AlbumType {
    let resType: DFX.AlbumType;
    switch (albumType) {
      case PhotoAlbumType.USER:
        resType = DFX.AlbumType.USER;
        break;
      case PhotoAlbumType.SYSTEM:
        resType = DFX.AlbumType.SYSTEM;
        break;
      case PhotoAlbumType.SOURCE:
        resType = DFX.AlbumType.SOURCE;
        break;
      case PhotoAlbumType.SMART:
        resType = DFX.AlbumType.SMART;
        break;
      default:
        resType = DFX.AlbumType.UNKNOWN;
        HiLog.warn(TAG, `transferToAlbumType fail, unknown input albumType`);
        break;
    }
    return resType;
  }

  /**
   * 将媒体库子相册枚举转化为UE打点所需枚举值
   * @param subAlbumType 媒体库子相册枚举
   * @returns UE打点所需枚举值
   */
  public static transferToSubAlbumType(subAlbumType: PhotoAlbumSubType): DFX.SubAlbumType {
    let resType: DFX.SubAlbumType;
    switch (subAlbumType) {
      case PhotoAlbumSubType.USER_GENERIC:
        resType = DFX.SubAlbumType.COMMON;
        break;
      case PhotoAlbumSubType.VIDEO:
        resType = DFX.SubAlbumType.VIDEO;
        break;
      case PhotoAlbumSubType.IMAGE:
        resType = DFX.SubAlbumType.IMAGE;
        break;
      case PhotoAlbumSubType.SOURCE_GENERIC:
        resType = DFX.SubAlbumType.SOURCE_COMMON;
        break;
      default:
        resType = DFX.SubAlbumType.UNKNOWN;
        HiLog.warn(TAG, `transferToSubAlbumType fail, unknown input subAlbumType`);
        break;
    }
    return resType;
  }

  /**
   * 将string set中的内容转化为字符串输出
   * @param set set信息
   * @returns 转化结果
   */
  public static transferSetToString(set: HashSet<string>): string {
    const separator: string = ',';
    if (set.length <= 0) {
      HiLog.warn(TAG, 'transferSetToString, invalid input set');
      return '';
    }
    let stringRes: string = '';
    set.forEach((suffix: string) => {
      stringRes = stringRes.concat(suffix + separator);
    });
    stringRes = stringRes.substring(0, stringRes.length - separator.length);
    return stringRes;
  }

  /**
   * 将uri信息转化为页面信息
   * @param uri uri信息
   * @returns 页面信息
   */
  public static transferUriToPageName(uri: string): DFX.PageName {
    const externalUriHead: string = 'file://docs/storage/External/';

    if (uri === VirtualUri.GALLERY || uri.startsWith(EnumTransferUtil.URI_GALLERY) ||
      uri === PAGE_ROUTE_CONST.IMAGE || uri === PAGE_ROUTE_CONST.VIDEO) {
      return DFX.PageName.GALLERY;
    }
    if (uri.startsWith(externalUriHead)) {
      return DFX.PageName.EXTERNAL;
    }
    if (uri.startsWith(VirtualUri.MY_PC)) {
      return DFX.PageName.MY_PHONE;
    }
    return DFX.PageName.UNKNOWN;
  }
  /**
   * 将位置项目名称转化为打点用的页面名称
   * @param locationName 位置项目名称
   * @returns 页面名称
   */
  public static transferLocationNameToPageName(locationName: LocationItemName): DFX.PageName {
    let pageName: DFX.PageName = DFX.PageName.UNKNOWN;
    switch (locationName) {
      default:
        HiLog.warn(TAG, `transferLocationNameToPageName fail, unknown input locationName`);
        break;
    }
    return pageName;
  }
}