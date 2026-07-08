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

import {
  Constant,
  DeviceConfig,
  GlobalHolder,
  GlobalKey,
  LocationItemName,
  PAGE_ROUTE_CONST,
  VirtualUri
} from '@ohos/common';
import { SideBarItemModel } from '../model/SideBarItemModel';
import fileExtensionInfo from '@ohos.file.fileExtensionInfo';

export class SideBarItem {
  /**
   * 常驻item-聚合视图-图片
   */
  public static phoneGallery: SideBarItemModel = {
    icon: $r('app.media.picture_fill'),
    name: $r('app.string.pc_images'),
    uri: PAGE_ROUTE_CONST.IMAGE,
    deviceType: fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK,
    rootUri: '',
    dragEnable: true
  }

  /**
   * 常驻item-聚合视图-视频
   */
  public static phoneVideo: SideBarItemModel = {
    icon: $r('app.media.video'),
    name: $r('app.string.video'),
    uri: PAGE_ROUTE_CONST.VIDEO,
    deviceType: fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK,
    rootUri: '',
    dragEnable: true
  }

  /**
   * 常驻item-聚合视图-文档
   */
  public static phoneDocuments: SideBarItemModel = {
    icon: $r('app.media.doc_text_fill'),
    name: $r('app.string.pc_documents'),
    uri: PAGE_ROUTE_CONST.MY_PHONE,
    deviceType: fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK,
    rootUri: GlobalHolder.getInstance().getObject<string>(GlobalKey.LOCAL_ROOT_URI),
    dragEnable: true
  }

  /**
   * 常驻item-聚合视图-音频
   */
  public static phoneMusic: SideBarItemModel = {
    icon: $r('app.media.music_note_circle_fill'),
    name: $r('app.string.music'),
    uri: PAGE_ROUTE_CONST.MY_PHONE,
    deviceType: fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK,
    rootUri: GlobalHolder.getInstance().getObject<string>(GlobalKey.LOCAL_ROOT_URI),
    dragEnable: true
  }

  public static downloadAndReceive: SideBarItemModel = {
    icon: $r('app.media.ic_page_download'),
    name: $r('app.string.download_receive'),
    uri: PAGE_ROUTE_CONST.MY_PHONE,
    deviceType: fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK,
    rootUri: VirtualUri.DOWNLOAD_RECEIVE,
    dragEnable: false
  }
  /**
   * 浏览-位置-我的手机
   */
  public static myPhoneItem: SideBarItemModel = {
    itemName: LocationItemName.MY_PHONE,
    icon: DeviceConfig.getInstance().config.deviceIcon,
    name: DeviceConfig.getInstance().config.myDevice,
    uri: PAGE_ROUTE_CONST.MY_PHONE,
    num: Constant.LOCATION_LIST.MY_PHONE,
    deviceType: fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK,
    rootUri: GlobalHolder.getInstance().getObject<string>(GlobalKey.LOCAL_ROOT_URI),
    dragEnable: true,
    uuid: 'LOCAL'
  }
  /**
   * 浏览-位置-最近删除
   */
  public static recentDeleteItem: SideBarItemModel = {
    itemName: LocationItemName.RECENT_DELETE,
    icon: $r('app.media.ic_delete'),
    name: $r('app.string.recentlyDeleted'),
    uri: PAGE_ROUTE_CONST.RECENT_DELETE,
    num: Constant.LOCATION_LIST.RECENT_DELETE,
    dragEnable: true
  }

  /**
   * Picker item-媒体库文件
   */
  public static mediaLibraryItem: SideBarItemModel = {
    icon: $r('app.media.ic_app_gallery_media'),
    name: $r('app.string.pc_gallery'),
    uri: VirtualUri.GALLERY,
    dragEnable: false,
    rootUri: VirtualUri.GALLERY,
    bundleName: Constant.GALLERY_BUNDLE_NAME
  }

}