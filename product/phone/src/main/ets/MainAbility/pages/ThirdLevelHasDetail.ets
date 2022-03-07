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
import { LogInfo } from '../module/LogUtils.ets'
import { changeTypeToString, getShowIconBySuffix, getRootPath, updateTopPathInfo } from '../module/Utils.ets'
import { media_type} from '../module/Constants.ets'
import { ChooseDialog } from '../module/DialogUtils.ets'
import { DisplayInfo } from '../module/DisplayInfo.ets'
import { getListFile } from '../module/FileManagerServiceUtils.ets'

let TAG: string = 'ThirdLevelHasDetail'

@Component
export struct ThirdLevelHasDetail {
  private mCurrentMode: string
  private mWorker
  private displayInfo: DisplayInfo = new DisplayInfo()

  @Link mFileInfo: Array<FileInfo>
  @Link @Watch('refreshFiles') mCurrentPath: string
  @Link mMenuLevel: number
  @Link mType: string

  private aboutToAppear(): void{
    LogInfo(TAG, 'aboutToAppear')
    this.displayInfo = AppStorage.Get('displayInfo')
    this.mCurrentMode = AppStorage.Get<string>('startMode')
    this.mFileInfo = getListFile('local', this.mType, this.mCurrentPath)

//    this.mWorker.postMessage({
//      request_data: 'listFile',
//      device_name: 'local',
//      menu_level: this.mMenuLevel,
//      media_type: this.mType,
//      path: this.mCurrentPath
//    })
  }

  private aboutToDisappear() {
    LogInfo(TAG, 'aboutToDisappear')
    AppStorage.Set('choseFiles', [])
  }

  refreshFiles() {
    LogInfo(TAG, 'refreshFiles')
    AppStorage.Set('choseFiles', [])

    this.mWorker.postMessage({
      request_data: 'listFile',
      device_name: 'local',
      menu_level: this.mMenuLevel,
      media_type: this.mType,
      path: this.mCurrentPath
    })
  }

  build() {
    Column() {
      ForEach(this.mFileInfo, (item: FileInfo) => {
        DetailRowView({
          item: item,
          mMenuLevel: $mMenuLevel,
          mCurrentPath: $mCurrentPath
        })

        Divider().color('#000000').opacity(0.05)
          .margin({ left: 50 * 2, right: 12 * 2 })
      }, (item: FileInfo) => item.name)
    }
    .alignItems(HorizontalAlign.Start)
    .border({ radius: 24 * 2 })
    .margin({ left: 12 * 2, right: 12 * 2 })
    .opacity(0.9)
    .backgroundColor(Color.White)
  }
}

@Component
struct DetailRowView {
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
          .width(22 * 2)
          .height(19 * 2)
          .margin({ left: 12 * 2 })
        Text(this.item.name)
          .fontSize(16 * 2)
          .fontColor('#182431')
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 * 2 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Blank()
        Image($r("app.media.ic_right"))
          .width(12 * 2)
          .height(24 * 2)
          .margin({ right: 12 * 2 })
      } else {
        Row() {
          Image(getShowIconBySuffix(this.item.name.substring(this.item.name.lastIndexOf('.'))))
            .width(40 * 2)
            .height(40 * 2)
            .margin({ left: 8 * 2 })
          Column() {
            Text(this.item.name)
              .height(22 * 2)
              .fontSize(16 * 2)
              .fontColor(this.item.font_color)
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ top: 10 * 2 })
            Row() {
              Text('' + this.item.modified_time)
                .fontSize(14 * 2)
                .fontColor(this.item.font_color)
                .fontWeight(FontWeight.Regular)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text('-')
                .fontSize(14 * 2)
                .fontColor(this.item.font_color)
                .margin({ left: '8vp' })
              Text('' + this.item.size)
                .fontSize(14 * 2)
                .fontColor(this.item.font_color)
                .fontWeight(FontWeight.Regular)
                .margin({ left: '8vp' })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }.opacity(0.6)
          }
          .height(64 * 2)
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16 * 2 })
        }
        .width(this.displayInfo.mainDialogWidth - (24 * 2 + 8 * 4))
        .margin({ left: 4 * 2, top: 4 * 2, right: 4 * 2 }) // TODO

      }
    }
    .height(56 * 2)
    .width(this.displayInfo.mainDialogWidth - (24 * 2)) // TODO
    .border({ radius: 20 * 2 })
    .backgroundColor(this.item.list_background)
    .onClick(() => {
      if (this.item.type == media_type.MEDIA_TYPE_ALBUM) {
        LogInfo(TAG, 'fold onClick')
        this.mCurrentPath = this.item.path

//        let path: Array<TopPathInfo> = AppStorage.Get('topPathInfo')
//        path.push(new TopPathInfo(this.item.name, this.item.path))
//        AppStorage.Set('topPathInfo', path)

        updateTopPathInfo(AppStorage.Get('topPathInfo'), this.item.name, this.item.path)
      } else {
        var index = this.tmpChoseFiles.indexOf(this.item)
        if (index == -1) {
          this.item.font_color = Color.White
          this.item.opacity = 0.1
          this.item.list_background = '#0A59F7'
          this.tmpChoseFiles.push(this.item)
        } else {
          this.item.font_color = Color.Black
          this.item.opacity = 1
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