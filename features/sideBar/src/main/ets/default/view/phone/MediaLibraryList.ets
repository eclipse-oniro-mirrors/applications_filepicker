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

import { ArrayUtil, Constant, DiskInfo, GlobalHolder, GlobalKey, HiLog, PAGE_ROUTE_CONST } from '@ohos/common';
import { SideBarItemModel } from '../../model/SideBarItemModel';
import { SideBarItem } from '../../constant/SideBarItem';
import { MediaLibraryItem } from './MediaLibraryItem';
import { LengthMetrics } from '@kit.ArkUI';

const TAG = 'MediaLibraryList';

@Component
export struct MediaLibraryList {
  /**
   * 媒体库标题下所有入口
   */
  private mediaLibraryItemList: SideBarItemModel[] = [];

  aboutToAppear() {
    HiLog.info(TAG, 'MediaLibraryList aboutToAppear');
    this.mediaLibraryItemList.push(SideBarItem.mediaLibraryItem);
  }

  build() {
    Column() {
      List() {
        ForEach(this.mediaLibraryItemList, (info: SideBarItemModel, index) => {
          ListItem() {
            MediaLibraryItemComp({
              info: info,
              listLength: this.mediaLibraryItemList.length,
              index: index
            })
          }
        })
      }
      .borderRadius($r('app.float.common_borderRadius16'))
      .width('100%')
      .padding({
        top: $r('app.float.common_padding4'),
        bottom: $r('app.float.common_padding4')
      })
      .width('100%');
    }
    .margin({ bottom: $r('app.float.common_margin12') })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius($r('app.float.common_borderRadius20'))
  }
}

@Component
struct MediaLibraryItemComp {
  private info: SideBarItemModel = {} as SideBarItemModel;
  private listLength: number = 0;
  private index: number = 0;
  build() {
    Column() {
      MediaLibraryItem({ info: this.info });
      if (this.index < this.listLength - 1) {
        Divider()
          .color($r('sys.color.ohos_id_color_list_separator'))
          .margin({ start: LengthMetrics.vp(52), end: LengthMetrics.vp(12) })
      }
    }
  }
}