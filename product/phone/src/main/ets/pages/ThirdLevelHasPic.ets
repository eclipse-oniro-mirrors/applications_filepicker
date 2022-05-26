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
import { LogInfo, LogDebug } from '../module/LogUtils'
import { getListFile } from '../module/FileManagerServiceUtils'
import { ChooseDialog } from '../module/DialogUtils'
import { displayChange } from '../module/DisplayInfo'

let TAG: string = 'ThirdLevelHasPic'

@Component
export struct ThirdLevelHasPic {
  private mColumnTemplate: string
  private mCurrentMode: string
  private mCurrentIndex: number
  private mWorker
  @Link mFileList: Array<FileInfo>
  @Link mMenuLevel: number
  @Link mType: string
  @Link mCurrentPath: string
  @StorageLink('choseFiles') tmpFiles: Array<FileInfo> = []

  aboutToAppear() {
    if (globalThis.debugMode) {
      this.mFileList = getListFile('local', this.mType, this.mCurrentPath)
      LogDebug(TAG, 'mFileList length = ' + this.mFileList.length)
    } else {
      this.mWorker.postMessage({
        request_data: 'listFile',
        device_name: 'local',
        menu_level: this.mMenuLevel,
        media_type: this.mType,
        path: this.mCurrentPath,
        offset: 0,
        count: 100
      })
    }
  }

  private aboutToDisappear() {
    LogInfo(TAG, 'aboutToDisappear')
    AppStorage.Set('choseFiles', [])
  }

  build() {
    if (globalThis.startMode == 'choose') {
      Column() {
        Flex({
          direction: FlexDirection.Row,
          wrap: FlexWrap.Wrap,
          justifyContent: FlexAlign.Start,
          alignItems: ItemAlign.Start
        }) {
          ForEach(this.mFileList, (item: FileInfo) => {
            GridItemView({ gridItem: item })
          }, item => item.name)
        }
        .margin({ top: 8 })
      }
      .alignItems(HorizontalAlign.Start)
      .border({ radius: 24 })
      .opacity(0.9)
      .backgroundColor(Color.White)
    }

  }
}

@Component
struct GridItemView {
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: ChooseDialog(),
    cancel: () => {
    },
    autoCancel: true
  })
  @State gridItem: FileInfo = new FileInfo('')

  build() {
    Flex({
      direction: FlexDirection.Column,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.Center
    }) {
      Image(`${this.gridItem.path}/thumbnail/160/160`)
        .borderRadius(12)
        .objectFit(ImageFit.Contain)
        .width(displayChange(80))
        .height(displayChange(80))
        .margin({
          left: displayChange(8),
          right: displayChange(8),
          top: displayChange(4)
        })
      Row() {
        Text(this.gridItem.name)
          .width(displayChange(82))
          .fontSize(displayChange(12))
          .fontColor(this.gridItem.list_background == 'rgba(46,136,255,0.1)' ? Color.White : Color.Black)
          .fontWeight(FontWeight.Regular)
          .opacity(0.9)
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: displayChange(2) })
          .padding({ right: displayChange(4), left: displayChange(4) })
      }
      .borderRadius(12)
      .backgroundColor(this.gridItem.list_background == 'rgba(46,136,255,0.1)' ? 0x2E8BFF : '')
      .alignItems(VerticalAlign.Top)
      .width(displayChange(82))
      .height(displayChange(36))
      .margin({ top: displayChange(4) })
    }
    .padding({ bottom: displayChange(8) })
    .width(displayChange(96))
    .height(displayChange(126))
    .margin({ bottom: displayChange(12), left: displayChange(12) })
    .border({ radius: 20 })
    .backgroundColor(this.gridItem.list_background)
    .gesture(
    LongPressGesture({ repeat: false })
      .onAction((event: GestureEvent) => {
        AppStorage.SetOrCreate('selectedFileInfo', this.gridItem)
        this.dialogController.open()
      })
    )
    .onClick(() => {
      let choseFiles: Array<FileInfo> = AppStorage.Get('choseFiles')
      let index: number = choseFiles.indexOf(this.gridItem)
      if (index == -1) {
        this.gridItem.opacity = 0.1
        this.gridItem.font_color = '#FFFFFF'
        this.gridItem.list_background = 'rgba(46,136,255,0.1)'
        choseFiles.push(this.gridItem)
      } else {
        choseFiles.splice(index)
        this.gridItem.opacity = 1
        this.gridItem.font_color = '#000000'
        this.gridItem.list_background = ''
      }
    })

  }
}