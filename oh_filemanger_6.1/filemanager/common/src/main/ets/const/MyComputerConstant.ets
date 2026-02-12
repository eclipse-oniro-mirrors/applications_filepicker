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
import { ResourceUtil } from '../utils/ResourceUtil';
import type context from '@ohos.app.ability.common';
import { VirtualUri } from './FolderRecord';

export class MyComputerConstant {
  public static readonly MY_PC_IMAGES: string = 'Images';
  public static readonly MY_PC_DOCUMENTS: string = 'Documents';
  public static readonly MY_PC_DOWNLOADS: string = 'Download';
  public static readonly MY_PC_DESKTOP: string = 'Desktop';
  public static readonly MY_PC_APPDATA: string = 'appdata';
  public static readonly QUICK_ACCESS_RECENT: string = 'Recent';
  public static readonly QUICK_ACCESS_RECENT_DELETE: string = 'Recycle Bin';
  public static readonly QUICK_ACCESS_MYPC: string = 'My computer';
  public static readonly QUICK_ACCESS_MYPAD: string = 'My pad';
  public static readonly MY_PC_IMAGES_CN: string = '图片';
  public static readonly MY_PC_DOCUMENTS_CN: string = '文档';
  public static readonly MY_PC_DOWNLOADS_CN: string = '下载';
  public static readonly MY_PC_DESKTOP_CN: string = '桌面';
  public static readonly MY_PC_APPDATA_CN: string = '应用数据';
  public static readonly QUICK_ACCESS_RECENT_CN: string = '最近';
  public static readonly QUICK_ACCESS_RECENT_DELETE_CN: string = '回收站';
  public static readonly QUICK_ACCESS_MYPC_CN: string = '我的电脑';
  public static readonly QUICK_ACCESS_MYPAD_CN: string = '我的平板';

  /**
   * name of the my computer directory
   */
  public static getMyComputerNameMap(context?: context.Context): Map<string, string> {
    let myComputerNameMap: Map<string, string> = new Map([
      [MyComputerConstant.MY_PC_IMAGES.toLowerCase(), ResourceUtil.getStringByResource($r('app.string.pc_images'), context)],
      [MyComputerConstant.MY_PC_DOCUMENTS.toLowerCase(), ResourceUtil.getStringByResource($r('app.string.pc_documents'), context)],
      [MyComputerConstant.MY_PC_DOWNLOADS.toLowerCase(), ResourceUtil.getStringByResource($r('app.string.pc_downloads'), context)],
      [MyComputerConstant.MY_PC_DESKTOP.toLowerCase(), ResourceUtil.getStringByResource($r('app.string.pc_desktop'), context)],
      [MyComputerConstant.MY_PC_APPDATA.toLowerCase(), ResourceUtil.getStringByResource($r('app.string.pc_appdata'), context)],
      [MyComputerConstant.QUICK_ACCESS_RECENT.toLowerCase(), ResourceUtil.getStringByResource($r('app.string.recent'), context)],
      [MyComputerConstant.QUICK_ACCESS_RECENT_DELETE.toLowerCase().split(' ').join(''),
        ResourceUtil.getStringByResource($r('app.string.recent_delete'), context)]
    ]);
    return myComputerNameMap;
  }

  /**
   * uri of the my computer directory
   */
  public static readonly MY_COMPUTER_NAME_LIST =
    [MyComputerConstant.MY_PC_IMAGES,
      MyComputerConstant.MY_PC_DOCUMENTS,
      MyComputerConstant.MY_PC_DOWNLOADS,
      MyComputerConstant.MY_PC_DESKTOP,
      MyComputerConstant.MY_PC_APPDATA.toLowerCase(),
    ];

  public static readonly MY_COMPUTER_FOLDER_TYPE: Map<string, string> = new Map([
    [MyComputerConstant.MY_PC_IMAGES, 'pictures'],
    [MyComputerConstant.MY_PC_DOCUMENTS, 'documents'],
    [MyComputerConstant.MY_PC_DOWNLOADS, 'download'],
    [MyComputerConstant.MY_PC_DESKTOP, 'desktop'],
    [MyComputerConstant.MY_PC_APPDATA.toLowerCase(), 'appdata'],
  ]);

  /**
   * uri of the my computer directory
   */
  public static readonly MY_COMPUTER_NAME =
    ['images', 'documents', 'download', 'desktop', 'appdata'];

  public static readonly myComputerChinese2UriMap: string[][] = [
    ['图片', 'file://docs/storage/Users/currentUser/Images'],
    ['文档', 'file://docs/storage/Users/currentUser/Documents'],
    ['下载', 'file://docs/storage/Users/currentUser/Download'],
    ['应用数据', 'file://docs/storage/Users/currentUser/appdata'],
    ['桌面', 'file://docs/storage/Users/currentUser/Desktop'],
  ];
}

