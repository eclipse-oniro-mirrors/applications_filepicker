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

import { getItemNumberInGrid } from '../module/Utils.ets'
import { FileInfo } from '../module/FileInfo.ets'
import { LogInfo, LogDebug } from '../module/LogUtils.ets'
import { GridItemSize, pad_size } from '../module/Constants.ets'
import { getListFile } from '../module/FileManagerServiceUtils.ets'
import { ChooseDialog } from '../module/DialogUtils.ets'
import { DisplayInfo } from '../module/DisplayInfo.ets'

let TAG: string = 'ThirdLevelHasPic'

@Component
export struct ThirdLevelHasPic {
  private mWorker
  private mColumnTemplate: string
  private mCurrentIndex: number
  private displayInfo: DisplayInfo = new DisplayInfo()

  @Link mFileList: Array<FileInfo>
  @Link mMenuLevel: number
  @Link mType: string
  @Link mCurrentPath: string
  @StorageLink('choseFiles') tmpFiles: Array<FileInfo> = []

  private aboutToAppear() {
    this.displayInfo = AppStorage.Get('displayInfo')
//    let gridWidth = px2vp(this.displayInfo.mainDialogWidth) - 24 * 2
//    this.mColumnTemplate = getItemNumberInGrid(GridItemSize.GRID_ITEM_WIDTH,
//      GridItemSize.GRID_ITEM_COLUMNS_GAP,gridWidth)

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
        Grid() {
          ForEach(this.mFileList, (item: FileInfo) => {
            GridItem() {
              GridItemView({ gridItem: item })
            }
          }, item => item.name)
        }
        //.height(300)
        //.height(this.displayInfo.mainDialogHeight - (48 * 2))
        .columnsTemplate('1fr 1fr 1fr 1fr')
        //            .height(px2vp(this.displayInfo.mainDialogHeight)) // 必须参数
        //            .columnsTemplate(this.mColumnTemplate)

      }
      .alignItems(HorizontalAlign.Start)
      .border({ radius: pad_size.TWENTY_FOUR })
      .opacity(0.9)
      .backgroundColor(Color.White)
      .margin({ top: pad_size.SIXTEEN })
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
      Image($r("app.media.old_icon"))
        .objectFit(ImageFit.Contain)
        .width(pad_size.EIGHTY_TWO)
        .height(pad_size.EIGHTY_TWO)
        .margin({
          left: pad_size.ELEVEN,
          right: pad_size.ELEVEN,
          top: pad_size.FOUR,
          bottom: pad_size.TWO
        })

      Row() {
        Text(this.gridItem.name)
          .width(pad_size.EIGHTY_EIGHT)
          .fontSize(pad_size.FOURTEEN)
          .fontColor(this.gridItem.font_color)
          .fontWeight(FontWeight.Regular)
          .maxLines(2)
          .opacity(0.9)
          .textAlign(TextAlign.Center)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: pad_size.FOUR })
      }
      .alignItems(VerticalAlign.Top)
      .width(pad_size.NINETY_SIX)
      .height(pad_size.FORTY_SIX)
      .margin({ left: pad_size.FOUR, right: pad_size.FOUR, bottom: pad_size.FOUR })
    }
    .width(pad_size.ONE_HUNDRED_AND_FOUR)
    .height(pad_size.ONE_HUNDRED_AND_THIRTY_FOUR)
    .margin({ bottom: pad_size.SIXTEEN })
    .border({ radius: pad_size.TWELVE })
    .opacity(this.gridItem.opacity)
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
        this.gridItem.opacity = 1
        this.gridItem.font_color = Color.White
        this.gridItem.list_background = '#2E88FF'
        choseFiles.push(this.gridItem)
      } else {
        choseFiles.splice(index)
        this.gridItem.opacity = 1
        this.gridItem.font_color = Color.Black
        this.gridItem.list_background = ''
      }
    })

  }
}