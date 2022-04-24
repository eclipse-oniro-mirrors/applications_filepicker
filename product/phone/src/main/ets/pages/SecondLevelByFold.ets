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
      ForEach(this.mFileList, (item: FileInfo) => {
        SecondRowView({
          item: item,
          mMenuLevel: $mMenuLevel,
          mCurrentPath: $mCurrentPath
        })

        Divider().color('#000000').opacity(0.05)
          .margin({ left: 50 * 2, right: 12 * 2 })
      }, item => item.name.toString())
    }
    .alignItems(HorizontalAlign.Start)
    .border({ radius: 24 * 2 })
    .margin({ left: 12 * 2, right: 12 * 2 })
    .opacity(0.9)
    .backgroundColor(Color.White)
  }
}

@Component
struct SecondRowView {
  private item: FileInfo = new FileInfo('')
  @Link mMenuLevel: number
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
    .width(globalThis.mainDialogWidth - (24 * 2)) // TODO
    .backgroundColor(this.item.list_background)
    .onClick(() => {
      LogInfo(TAG, 'onClick this.mCurrentPath = ' + this.mCurrentPath)
      this.mCurrentPath = this.item.path
      updateTopPathInfo(AppStorage.Get('topPathInfo'), this.item.name, this.mCurrentPath)

      if (this.item.path.includes('dataability:///album') == false) {
        if (this.item.mediaType != 'file') {
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