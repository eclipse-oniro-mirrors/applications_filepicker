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

import { FileInfo } from '../module/FileInfo'
import { LogInfo } from '../module/LogUtils'
import { menuLevel } from '../module/Constants'
import { displayChange } from '../module/DisplayInfo'

@Component
export struct FirstLevelByType {
  private TAG: string = 'FirstLevelByType'
  private mWorker
  private mFileList: FileInfo[]
  @Link mType: string
  @Link mMenuLevel: number
  @Link mCurrentPath: string

  build() {
    Column() {
      ForEach(this.mFileList, (item: FileInfo, index: number) => {
        Column() {
          RowView({
            item: item,
            mMenuLevel: $mMenuLevel,
            mType: $mType,
            mCurrentPath: $mCurrentPath
          })

          Divider()
            .color('#000000')
            .opacity(0.1)
            .visibility(this.mFileList.length == index + 1 ? Visibility.Hidden : Visibility.Visible)
            .margin({ left: displayChange(40) })
        }
        .width('100%')
        .height(displayChange(56))
      }, item => item.name.toString())
    }
    .padding({ top: displayChange(4), bottom: displayChange(4), right: displayChange(12), left: displayChange(12) })
    .alignItems(HorizontalAlign.Start) // 导致圆角消失
    .border({ radius: 24 })
    .opacity(0.9)
    .backgroundColor('#FFFFFF')
    .width('100%')
  }
}

@Component
struct RowView {
  private item: FileInfo = new FileInfo('')
  @Link mMenuLevel: number
  @Link mType: string
  @Link mCurrentPath: string

  build() {
    Row() {
      Image($r("app.media.ic_type_smallfile"))
        .width(displayChange(24))
        .height(displayChange(24))
      Text(this.item.name)
        .fontSize(displayChange(16))
        .fontColor('#182431')
        .fontWeight(FontWeight.Medium)
        .margin({ left: displayChange(16) })
      Blank()
      Image($r("app.media.ic_right"))
        .width(displayChange(12))
        .height(displayChange(24))
    }
    .height(displayChange(56))
    .width('100%') // TODO
    .backgroundColor(this.item.list_background)
    .onClick(() => {
      this.mType = this.item.mediaType
      this.mCurrentPath = this.item.path
      this.mMenuLevel = menuLevel.MENU_SECOND_LEVEL_BY_FOLD
    })
  }
}