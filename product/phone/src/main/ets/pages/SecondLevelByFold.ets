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
import { changeTypeToString, updateTopPathInfo } from '../module/Utils'
import { LogInfo, LogDebug } from '../module/LogUtils'
import { menuLevel } from '../module/Constants'
import { getListFile } from '../module/FileManagerServiceUtils'
import { displayChange } from '../module/DisplayInfo'

let TAG: string = 'SecondLevelByFold'

@Component
export struct SecondLevelByFold {
  private mWorker
  @Link mFileList: FileInfo[]
  @Link @Watch('fileTypeChange') mType: string
  @Link mMenuLevel: number
  @Link mCurrentPath: string

  aboutToAppear(): void{
    LogInfo(TAG, 'aboutToAppear')
    if (globalThis.debugMode) {
      this.mFileList = getListFile('local', this.mType, this.mCurrentPath)
      LogDebug(TAG, 'mFileList length = ' + this.mFileList.length)
    } else {
      this.mWorker.postMessage({
        request_data: 'listFile',
        device_name: 'local',
        menu_level: this.mMenuLevel,
        media_type: this.mType,
        path: this.mCurrentPath
      })
    }

    updateTopPathInfo([], '文件类型', '')
    updateTopPathInfo(AppStorage.Get('topPathInfo'), changeTypeToString(this.mType), this.mCurrentPath)
  }

  fileTypeChange() {
    LogInfo(TAG, 'fileTypeChange ' + this.mType)
    if (globalThis.debugMode) {
      this.mFileList = getListFile('local', this.mType, this.mCurrentPath)
    } else {
      this.mWorker.postMessage({
        request_data: 'listFile',
        device_name: 'local',
        menu_level: this.mMenuLevel,
        media_type: this.mType,
        path: this.mCurrentPath
      })
    }
  }

  build() {
    Column() {
      ForEach(this.mFileList, (item: FileInfo, index: number) => {
        Column() {
          SecondRowView({
            item: item,
            mMenuLevel: $mMenuLevel,
            mCurrentPath: $mCurrentPath,
            isType: $mType
          })

          Divider()
            .color('#000000')
            .opacity(0.05)
            .visibility(this.mFileList.length == index + 1 ? Visibility.Hidden : Visibility.Visible)
            .margin({ left: displayChange(40) })
        }
        .width('100%')
        .height(displayChange(56))
      }, item => item.name.toString())
    }
    .padding({ top: displayChange(4), bottom: displayChange(4), left: displayChange(12), right: displayChange(12) })
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .border({ radius: displayChange(24) })
    .opacity(0.9)
    .backgroundColor(Color.White)
  }
}

@Component
struct SecondRowView {
  private item: FileInfo = new FileInfo('')
  @Link mMenuLevel: number
  @Link mCurrentPath: string
  @Link isType: string

  build() {
    Row() {
      Image($r("app.media.ic_type_smallfile"))
        .width(displayChange(24))
        .height(displayChange(24))
      Text(this.item.name)
        .fontSize(16)
        .fontColor('#182431')
        .fontWeight(FontWeight.Medium)
        .margin({ left: displayChange(17) })
      Blank()
      Image($r("app.media.ic_right"))
        .width(displayChange(12))
        .height(displayChange(24))
    }
    .height(displayChange(56))
    .width('100%') // TODO
    .backgroundColor(this.item.list_background)
    .onClick(() => {
      LogInfo(TAG, 'onClick this.mCurrentPath = ' + this.mCurrentPath)
      this.mCurrentPath = this.item.path
      updateTopPathInfo(AppStorage.Get('topPathInfo'), this.item.name, this.mCurrentPath)

      if (this.item.path.includes('dataability:///album') == false) {
        if (this.isType != 'file') {
          LogInfo(TAG, 'MENU_THIRD_LEVEL_HAS_PIC - onClick')
          this.mMenuLevel = menuLevel.MENU_THIRD_LEVEL_HAS_PIC
        } else {
          this.mMenuLevel = menuLevel.MENU_THIRD_LEVEL_HAS_DETAIL
          LogInfo(TAG, 'MENU_THIRD_LEVEL_HAS_DETAIL - onClick')
        }
      }
    })
  }
}