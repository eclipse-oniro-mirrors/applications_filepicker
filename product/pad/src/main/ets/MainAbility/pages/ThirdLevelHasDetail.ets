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

import { FileInfo } from '../../../../../../../feature/FileInfo.ets'
import { LogInfo } from '../../../../../../../common/LogUtils.ets'
import { getShowIconBySuffix, updateTopPathInfo } from '../module/Utils.ets'
import { media_type, pad_size } from '../module/Constants.ets'
import { ChooseDialog } from '../module/DialogUtils.ets'
import { DisplayInfo } from '../module/DisplayInfo.ets'
import { getListFile } from '../module/FileManagerServiceUtils.ets'

@Component
export struct ThirdLevelHasDetail {
  private TAG: string = 'ThirdLevelHasDetail'
  private mWorker
  private displayInfo: DisplayInfo = new DisplayInfo()

  @Link mFileInfo: Array<FileInfo>
  @Link @Watch('refreshFiles') mCurrentPath: string
  @Link mMenuLevel: number
  @Link mType: string

  private aboutToAppear(): void{
    LogInfo(this.TAG, 'aboutToAppear')
    this.displayInfo = AppStorage.Get('displayInfo')

    if (globalThis.debugMode) {
      this.mFileInfo = getListFile('local', this.mType, this.mCurrentPath)
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

  private aboutToDisappear() {
    LogInfo(this.TAG, 'aboutToDisappear')
    AppStorage.Set('choseFiles', [])
  }

  refreshFiles() {
    LogInfo(this.TAG, 'refreshFiles')
    AppStorage.Set('choseFiles', [])

    if (!globalThis.debugMode) {
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
      List() {
        ForEach(this.mFileInfo, (item: FileInfo) => {
          ListItem() {
            DetailRowView({
              item: item,
              mMenuLevel: $mMenuLevel,
              mCurrentPath: $mCurrentPath
            })
          }
        }, (item: FileInfo) => item.name)
      }.align(Alignment.Top)
    }
    .height(pad_size.TWO_HUNDRED_AND_SIXTY)
    .alignItems(HorizontalAlign.Start)
    .opacity(0.9)
    .backgroundColor(Color.White)
    .border({ radius: pad_size.TWENTY_FOUR })
    .margin({ top: pad_size.SIXTEEN })
  }
}

@Component
struct DetailRowView {
  private TAG: string = 'DetailRowView'
  private displayInfo: DisplayInfo = AppStorage.Get('displayInfo')
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: ChooseDialog(),
    cancel: () => {},
    autoCancel: true
  })

  @State item: FileInfo = new FileInfo('')
  @Link mCurrentPath: string
  @Link mMenuLevel: number
  @StorageLink('choseFiles') tmpChoseFiles: Array<FileInfo> = []

  build() {
    Row() {
      if (this.item.type == media_type.MEDIA_TYPE_ALBUM) {
        Image($r("app.media.ic_file_fold"))
          .width(pad_size.FORTY)
          .height(pad_size.FORTY)
          .margin({ left: pad_size.TWELVE })
        Text(this.item.name)
          .fontSize(pad_size.SIXTEEN)
          .fontColor('#182431')
          .fontWeight(FontWeight.Medium)
          .margin({ left: pad_size.SIXTEEN })
          .maxLines(pad_size.ONE)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Blank()
        Image($r("app.media.ic_right"))
          .width(pad_size.TWELVE)
          .height(pad_size.TWENTY_FOUR)
          .margin({ right: pad_size.TWENTY_FOUR })
      } else {
        Image(getShowIconBySuffix(this.item.name.substring(this.item.name.lastIndexOf('.'))))
          .width(pad_size.FORTY)
          .height(pad_size.FORTY)
          .margin({ left: pad_size.EIGHT })
        Column() {
          Text(this.item.name)
            .height(pad_size.TWENTY_TWO)
            .fontSize(pad_size.SIXTEEN)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.item.font_color)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: pad_size.TEN })
          Row() {
            Text('' + this.item.modified_time)
              .fontSize(pad_size.FOURTEEN)
              .fontWeight(FontWeight.Regular)
              .fontColor(this.item.font_color)
              .maxLines(pad_size.ONE)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text('-')
              .fontSize(pad_size.FOURTEEN)
              .fontColor(this.item.font_color)
              .margin({ left: pad_size.EIGHT })
            Text('' + this.item.size)
              .fontSize(pad_size.FOURTEEN)
              .fontWeight(FontWeight.Regular)
              .fontColor(this.item.font_color)
              .margin({ left: pad_size.EIGHT })
              .maxLines(pad_size.ONE)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .opacity(0.6)
          .height(pad_size.NINETEEN)
          .margin({ top: pad_size.TWO, bottom: pad_size.ELEVEN })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: pad_size.SIXTEEN })
      }
    }
    .width(pad_size.FIVE_HUNDRED_AND_FOUR) // TODO
    .height(pad_size.SIXTY_FOUR)
    .margin({ left: pad_size.SIXTEEN, right: pad_size.TWENTY_FOUR, bottom: pad_size.TWO })
    .border({ radius: pad_size.TWENTY })
    .backgroundColor(this.item.list_background)
    .onClick(() => {
      if (this.item.type == media_type.MEDIA_TYPE_ALBUM) {
        this.mCurrentPath = this.item.path
        updateTopPathInfo(AppStorage.Get('topPathInfo'), this.item.name, this.item.path)
      } else {
        var index = this.tmpChoseFiles.indexOf(this.item)
        if (index == -1) {
          this.item.opacity = 0.1
          this.item.font_color = Color.White
          this.item.list_background = '#0A59F7'
          this.tmpChoseFiles.push(this.item)
        } else {
          this.item.opacity = 1
          this.item.font_color = Color.Black
          this.item.list_background = ''
          this.tmpChoseFiles.splice(index, 1)
        }
      }
    })
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction((event: GestureEvent) => {
          if (this.item.type != media_type.MEDIA_TYPE_ALBUM) {
            AppStorage.SetOrCreate<FileInfo>('selectedFileInfo', this.item)
            this.dialogController.open()
          }
        })
    )
  }
}