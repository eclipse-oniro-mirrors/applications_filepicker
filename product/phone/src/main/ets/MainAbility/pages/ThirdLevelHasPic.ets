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

import { getItemNumberInGrid, updateTopPathInfo } from '../module/Utils.ets'
import { FileInfo } from '../module/FileInfo.ets'
import { LogInfo, LogDebug } from '../module/LogUtils.ets'
import { GridItemSize } from '../module/Constants.ets'
import { getListFile } from '../module/FileManagerServiceUtils.ets'
import { ChooseDialog } from '../module/DialogUtils.ets'
import { DisplayInfo } from '../module/DisplayInfo.ets'

let TAG: string = 'ThirdLevelHasPic'

@Component
export struct ThirdLevelHasPic {
  private mColumnTemplate: string
  private mCurrentMode: string
  private mCurrentIndex: number
  private mWorker
  private displayInfo: DisplayInfo = new DisplayInfo()

  @Link mFileList: Array<FileInfo>
  @Link mMenuLevel: number
  @Link mType: string
  @Link mCurrentPath: string
  @StorageLink('choseFiles') tmpFiles: Array<FileInfo> = []

  private aboutToAppear() {
    this.displayInfo = AppStorage.Get('displayInfo')
    this.mCurrentMode = AppStorage.Get('startMode')
    //LogInfo(TAG, 'aboutToAppear mainDialogWidth = ' + this.displayInfo.mainDialogWidth)
    LogDebug(TAG, "mCurrentMode = " + this.mCurrentMode)
//    let gridWidth = px2vp(this.displayInfo.mainDialogWidth) - 24 * 2
//    this.mColumnTemplate = getItemNumberInGrid(GridItemSize.GRID_ITEM_WIDTH,
//      GridItemSize.GRID_ITEM_COLUMNS_GAP,gridWidth)

    this.mFileList = getListFile('local', this.mType, this.mCurrentPath) // TODO
    LogDebug(TAG, 'mFileList length = ' + this.mFileList.length)


//    this.mWorker.postMessage({
//      request_data: 'listFile',
//      device_name: 'local',
//      menu_level: this.mMenuLevel,
//      media_type: this.mType,
//      path: this.mCurrentPath,
//      offset: 0,
//      count: 100
//    })
  }

  private aboutToDisappear() {
    LogInfo(TAG, 'aboutToDisappear')
    AppStorage.Set('choseFiles', [])
  }



  build() {
    if (this.mCurrentMode == 'choose') {
      Column() {
        Grid() {
          ForEach(this.mFileList, (item: FileInfo) => {
            GridItem() {
              GridItemView({ gridItem: item })
            }
          }, item => item.name)
        }
        //.height(300)
        .height(this.displayInfo.mainDialogHeight - (48 * 2)) // TODO
        .columnsTemplate('1fr 1fr 1fr')
        .margin({ top: 8 * 2 })
        //            .height(px2vp(this.displayInfo.mainDialogHeight)) // 必须参数
        //            .columnsTemplate(this.mColumnTemplate)

      }
      .alignItems(HorizontalAlign.Start)
      .border({ radius: 24 * 2 })
      .margin({ left: 12 * 2, right: 12 * 2 })
      .opacity(0.9)
      .backgroundColor(Color.White)
    }

  }
}

@Component
struct GridItemView {
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: ChooseDialog(),
    cancel: () => {},
    autoCancel: true
  })
  @State gridItem: FileInfo = new FileInfo('')

  build() {
    Flex({
      direction: FlexDirection.Column,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.Center
    }) {
      Image($r("app.media.icon"))
        .objectFit(ImageFit.Contain)
        .width(80 * 2)
        .height(80 * 2)
        .margin({
          left: 8 * 2,
          right: 8 * 2,
          top: 4 * 2
        })
      Row() {
        Text(this.gridItem.name)
          .width(82 * 2)
          .fontSize(12 * 2)
          .fontColor(this.gridItem.font_color)
          .fontWeight(FontWeight.Regular)
          .opacity(0.9)
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 2 * 2 })
      }
      .alignItems(VerticalAlign.Top)
      .width(82 * 2)
      .height(36 * 2)
      .margin({ top: 2 * 2 })
    }
    .width(96 * 2)
    .height(126 * 2)
    .margin({ bottom: 12 * 2 })
    .border({ radius: 20 * 2 })
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
        this.gridItem.list_background = '#2E88FF'
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