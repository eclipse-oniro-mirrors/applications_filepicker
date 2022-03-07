/*
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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

import { FileInfo, TopPathInfo } from '../module/FileInfo.ets'
import { DisplayInfo } from '../module/DisplayInfo.ets'
import { LogInfo } from '../module/LogUtils.ets'
import { menuLevel } from '../module/Constants.ets'

@Component
export struct FirstLevelByType {
  private TAG: string = 'FirstLevelByType'
  private mWorker
  private mFileList: FileInfo[]
  private displayInfo: DisplayInfo = new DisplayInfo()

  @Link mType: string
  @Link mMenuLevel: number
  @Link mCurrentPath: string

  private aboutToAppear() {
    LogInfo(this.TAG, 'aboutToAppear mType = ' + this.mType)
    LogInfo(this.TAG, 'aboutToAppear mCurrentPath = ' + this.mCurrentPath)
    this.displayInfo = AppStorage.Get('displayInfo')
  }

  build() {
    Column() {
      ForEach(this.mFileList, (item: FileInfo) => {
        RowView({
          item: item,
          mMenuLevel: $mMenuLevel,
          mType: $mType,
          mCurrentPath: $mCurrentPath
        })

        Divider().color('#000000').opacity(0.05)
          .margin({ left: 50 * 2, right: 12 * 2 })
      }, item => item.name.toString())
    }
    .alignItems(HorizontalAlign.Start) // 导致圆角消失
    .border({ radius: 24 * 2 })
    .margin({ left: 12 * 2, right: 12 * 2 })
    .opacity(0.9)
    .backgroundColor('#FFFFFF')
  }
}

@Component
struct RowView {
  private item: FileInfo = new FileInfo('')
  private displayInfo: DisplayInfo = AppStorage.Get('displayInfo')

  @Link mMenuLevel: number
  @Link mType: string
  @Link mCurrentPath: string

  build() {
    Row() {
      Image($r("app.media.ic_file_manager"))
        .width(22 * 2)
        .height(19 * 2)
        .margin({ left: 12 * 2 })
      Text(this.item.name)
        .fontSize(16 * 2)
        .fontColor('#182431')
        .fontWeight(FontWeight.Medium)
        .margin({ left: 16 * 2 })
      Blank()
      Image($r("app.media.ic_right"))
        .width(12 * 2)
        .height(24 * 2)
        .margin({ right: 12 * 2 })
    }
    .height(56 * 2)
    .width(this.displayInfo.mainDialogWidth - (24 * 2)) // TODO
    .backgroundColor(this.item.list_background)
    .onClick(() => {
      this.mType = this.item.mediaType
      this.mCurrentPath = this.item.path
      this.mMenuLevel = menuLevel.MENU_SECOND_LEVEL_BY_FOLD
    })
  }
}