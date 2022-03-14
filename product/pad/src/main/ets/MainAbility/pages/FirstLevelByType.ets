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

import { DisplayInfo } from '../module/DisplayInfo.ets'
import { menuLevel, pad_size } from '../module/Constants.ets'
import { FileInfo } from '../../../../../../../feature/FileInfo.ets'
import { LogInfo } from '../../../../../../../common/LogUtils.ets'

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
    Grid() {
      ForEach(this.mFileList, (item: FileInfo) => {
        GridItem() {
          Column() {
            Image($r("app.media.ic_public_big_folder"))
              .width(pad_size.EIGHTY)
              .height(pad_size.EIGHTY)
              .margin({ left: pad_size.TWELVE, top: pad_size.FOUR, right: pad_size.TWELVE })
            Text(item.name)
              .width(pad_size.EIGHTY_EIGHT)
              .fontSize(pad_size.FOURTEEN)
              .fontWeight(FontWeight.Regular)
              .fontColor('#000000')
              .textAlign(TextAlign.Center)
              .margin({ top: pad_size.FOUR, bottom: pad_size.TWENTY_SEVEN })
          }
          .width(pad_size.ONE_HUNDRED_AND_FOUR)
          .height(pad_size.ONE_HUNDRED_AND_THIRTY_FOUR)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            this.mType = item.mediaType
            this.mCurrentPath = item.path
            this.mMenuLevel = menuLevel.MENU_SECOND_LEVEL_BY_FOLD
          })
        }
      }, item => item.name)
    }
    .columnsTemplate('1fr 1fr 1fr 1fr')
    .columnsGap(1)
    .rowsGap(1)
    .margin({ top: pad_size.SIXTEEN })
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
        .margin({ left: 12 })
      Text(this.item.name)
        .fontSize(16 * 2)
        .fontColor('#182431')
        .fontWeight(FontWeight.Medium)
        .margin({ left: 16 })
      Blank()
      Image($r("app.media.ic_right"))
        .width(12 * 2)
        .height(24 * 2)
        .margin({ right: 24 * 2 })
    }
    .height(56)
    .width(this.displayInfo.mainDialogWidth) // TODO
    .margin({ top: '16vp', bottom: '16vp' })
    .backgroundColor(this.item.list_background)
    .onClick(() => {
      this.mType = this.item.mediaType
      this.mCurrentPath = this.item.path
      this.mMenuLevel = menuLevel.MENU_SECOND_LEVEL_BY_FOLD
    })
  }
}