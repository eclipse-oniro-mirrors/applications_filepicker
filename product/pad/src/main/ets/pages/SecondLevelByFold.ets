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

import { FileInfo, TopPathInfo } from '../../../../../../feature/FileInfo'
import { changeTypeToString, updateTopPathInfo } from '../module/Utils'
import { LogInfo, LogDebug } from '../../../../../../common/LogUtils'
import { menuLevel, pad_size } from '../module/Constants'
import { DisplayInfo } from '../module/DisplayInfo'
import { getListFile } from '../module/FileManagerServiceUtils'

let TAG: string = 'SecondLevelByFold'

@Component
export struct SecondLevelByFold {
  private mWorker
  private displayInfo: DisplayInfo = new DisplayInfo()

  @Link mFileList: FileInfo[]
  @Link @Watch('fileTypeChange') mType: string
  @Link mMenuLevel: number
  @Link mCurrentPath: string

  private aboutToAppear(): void{
    LogInfo(TAG, 'aboutToAppear')
    this.displayInfo = AppStorage.Get('displayInfo')

    if (globalThis.debugMode) {
      this.mFileList = getListFile('local', this.mType, this.mCurrentPath)
      LogDebug(TAG, 'mFileList length = ' + this.mFileList.length)
    } else {
      LogInfo(TAG, 'aboutToAppear send message to worker')
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
      LogInfo(TAG, 'fileTypeChange send message to worker')
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
    if (globalThis.startMode == 'choose') {
      Grid() {
        ForEach(this.mFileList, fileItem => {
          GridItem() {
            Column() {
              Image($r("app.media.ic_public_big_folder"))
                .width(pad_size.EIGHTY)
                .height(pad_size.EIGHTY)
                .margin({ left: pad_size.TWELVE, top: pad_size.FOUR, right: pad_size.TWELVE })
              Row() {
                Text(fileItem.name)
                  .width(pad_size.EIGHTY_EIGHT)
                  .fontSize(pad_size.FOURTEEN)
                  .fontWeight(FontWeight.Regular)
                  .fontColor('#000000')
                  .textAlign(TextAlign.Center)
                  .maxLines(pad_size.TWO)
                  .margin({ top: pad_size.FOUR, left: pad_size.FOUR, right: pad_size.FOUR })
              }
              .alignItems(VerticalAlign.Top)
              .width(pad_size.NINETY_SIX)
              .height(pad_size.FORTY_SIX)
            }
            .width(pad_size.ONE_HUNDRED_AND_FOUR)
            .height(pad_size.ONE_HUNDRED_AND_THIRTY_FOUR)
            .alignItems(HorizontalAlign.Center)
          }
          .onClick(() => {
            this.mCurrentPath = fileItem.path
            LogInfo(TAG, 'fileItem.mediaType = ' + fileItem.mediaType)
            if (fileItem.mediaType == 'file') {
              this.mMenuLevel = menuLevel.MENU_THIRD_LEVEL_HAS_DETAIL
            } else {
              this.mMenuLevel = menuLevel.MENU_THIRD_LEVEL_HAS_PIC
            }
            updateTopPathInfo(AppStorage.Get('topPathInfo'), fileItem.name, fileItem.mCurrentPath)
          })
        }, fileItem => fileItem.name)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(1)
      .rowsGap(1)
      .margin({ top: pad_size.SIXTEEN })
    }
  }
}

@Component
struct SecondRowView {
  private item: FileInfo = new FileInfo('')
  private displayInfo: DisplayInfo = AppStorage.Get('displayInfo')

  @Link mMenuLevel: number
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
    .width(px2vp(this.displayInfo.mainDialogWidth)) // TODO
    .margin({ top: '16vp', bottom: '16vp' })
    .backgroundColor(this.item.list_background)
    .onClick(() => {
      LogInfo(TAG, 'onClick this.mCurrentPath = ' + this.mCurrentPath)
      this.mCurrentPath = this.item.path
      let path: Array<TopPathInfo> = AppStorage.Get('topPathInfo')
      path.push(new TopPathInfo(this.item.name, this.mCurrentPath))
      AppStorage.Set('topPathInfo', path)

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