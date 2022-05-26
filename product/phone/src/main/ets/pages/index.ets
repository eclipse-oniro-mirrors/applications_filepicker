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

import worker from '@ohos.worker'
import { FirstLevelByType } from './FirstLevelByType'
import { SecondLevelByFold } from './SecondLevelByFold'
import { ThirdLevelHasDetail } from '../pages/ThirdLevelHasDetail'
import { ThirdLevelHasPic } from '../pages/ThirdLevelHasPic'
import { FileInfo, TopPathInfo } from '../module/FileInfo'
import { menuLevel, terminate_reason, media_type } from '../module/Constants'
import { LogInfo, LogDebug } from '../module/LogUtils'
import { changeStringToType, updateTopPathInfo } from '../module/Utils'
import { terminateSelfWithResult } from '../module/AbilityUtils'
import { WarningDialog } from '../module/DialogUtils'
import { getFirstMenu } from '../module/FileManagerServiceUtils'
import { displayChange } from '../module/DisplayInfo'

@Entry
@Component
struct allIndex {
  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.End, justifyContent: FlexAlign.SpaceBetween }) {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
        }
        .onClick(() => {
          globalThis.context.terminateSelf((err, data) => {
            console.log('terminateSelf success')
          })
        })
        .width('100%')
        .height('100%')

        Index()
      }
      .width('100%')
      .height('100%')
    }
    .backgroundColor('rgba(0,0,0,0.1)')
    .position({ x: 0, y: 0 })
    .width('100%')
    .height('100%')
  }
}

@Component
struct Index {
  private TAG: string= 'Main'
  private mWorker
  private customDialogController: CustomDialogController = new CustomDialogController({
    builder: WarningDialog({ code: $code })
  })
  @State mFirstMenuData: FileInfo[] = []
  @State mSecondMenuData: FileInfo[] = []
  @State mThirdMenuPicData: FileInfo[]= []
  @State mThirdMenuDetailData: FileInfo[]= []
  @State mType: string = ''
  @State mMenuLevel: number = menuLevel.MENU_FIRST_LEVEL_BY_TYPE
  @State mCurrentPath: string= ''
  @State code: number = 2;
  @StorageLink('startMode') mCurrentMode: string = 'choose'
  @StorageLink('topPathInfo') topPathInfo: Array<TopPathInfo> = updateTopPathInfo([], '文件类型', '')
  scroller: Scroller = new Scroller()

  aboutToAppear() {
    LogInfo(this.TAG, 'aboutToAppear')
    if (globalThis.debugMode) {
      this.mFirstMenuData = getFirstMenu('')
      LogDebug(this.TAG, 'mFirstMenuData length = ' + this.mFirstMenuData.length)
    } else {
      this.initWork()
      LogInfo(this.TAG, 'send message to worker')
      this.mWorker.postMessage({
        request_data: 'getRoot',
        device_name: 'local',
        menu_level: this.mMenuLevel,
        media_type: this.mType,
        path: this.mCurrentPath
      })
    }
  }

  private initWork() {
    if (this.mWorker == undefined) {
      LogInfo(this.TAG, 'initWorker')
      this.mWorker = new worker.Worker('workers/DataWorker.js', { type: 'classic', name: 'filePicker' })
      this.mWorker.onerror = this.onError.bind(this)
      this.mWorker.onmessageerror = this.onMessageError.bind(this)
      this.mWorker.onexit = this.onExit.bind(this)
      this.mWorker.onmessage = this.onMessage.bind(this)
    }
  }

  private onError(e): void{
    LogInfo(this.TAG, 'onError = ' + JSON.stringify(e))
  }

  private onMessageError(e): void{
    LogInfo(this.TAG, 'onMessageError = ' + JSON.stringify(e))
  }

  private onExit(): void{
    LogInfo(this.TAG, 'onExit')
    this.mWorker = undefined
  }

  private onMessage(result) {
    LogInfo(this.TAG, 'main thread onMessage')
    var params = result.data.params
    var file = JSON.parse(String.fromCharCode.apply(null, new Uint16Array(result.data.data)))
    if (params.request_data == 'createFile') {
      if (file.code == undefined) {
        terminateSelfWithResult(terminate_reason.SUCCESS, file)
      } else {
        if (params.path == 'dataability:///album') {
          this.code = 2;
          this.customDialogController.open()
        } else {
          this.code = file.code
          this.customDialogController.open()
        }
      }
      return
    }
    if (Array.isArray(file)) {
      let listData: Array<FileInfo> = []
      for (var index = 0;index < file.length; index++) {
        var info = file[index]
        let item = new FileInfo(info.name)
        item.path = info.path
        item.type = info.type
        item.size = info.size
        item.dataAdded_time = info.added_time
        item.modified_time = info.modified_time
        if (params.menu_level == menuLevel.MENU_FIRST_LEVEL_BY_TYPE) {
          if (item.name == 'image_album') {
            item.name = '图片'
            item.mediaType = 'image'
            item.thumbnail = $r("app.media.ic_type_image")
          } else if (item.name == 'video_album') {
            item.name = '视频'
            item.mediaType = 'video'
            item.thumbnail = $r("app.media.ic_type_video")
          } else if (item.name == 'audio_album') {
            item.name = '音乐'
            item.mediaType = 'audio'
            item.thumbnail = $r("app.media.ic_type_audio")
          } else if (item.name == 'file_folder') {
            item.name = '文档'
            item.mediaType = 'file'
            item.thumbnail = $r("app.media.ic_type_file")
          }
        }

        if (params.menu_level == menuLevel.MENU_THIRD_LEVEL_HAS_DETAIL) {
          if (this.mCurrentMode == 'save' && item.type != media_type.MEDIA_TYPE_ALBUM) {
            break
          }
        }
        listData.push(item)
      }
      if (params.menu_level == menuLevel.MENU_FIRST_LEVEL_BY_TYPE && params.request_data == 'getRoot') {
        LogDebug(this.TAG, 'mFirstMenuData length = ' + listData.length)
        this.mFirstMenuData = listData
      } else if (params.menu_level == menuLevel.MENU_SECOND_LEVEL_BY_FOLD) {
        LogDebug(this.TAG, 'mSecondMenuData length = ' + listData.length)
        this.mSecondMenuData = listData
      } else if (params.menu_level == menuLevel.MENU_THIRD_LEVEL_HAS_PIC) {
        LogDebug(this.TAG, 'mThirdMenuPicData length = ' + listData.length)
        this.mThirdMenuPicData = listData
      } else if (params.menu_level == menuLevel.MENU_THIRD_LEVEL_HAS_DETAIL) {
        LogDebug(this.TAG, 'mThirdMenuDetailData length = ' + listData.length)
        if (listData.length > 0) {
          this.mThirdMenuDetailData = listData
        } else {
          this.mThirdMenuDetailData = []
        }
      }
    }
  }

  build() {
    Column() {
      TopBarArea()

      Column() {
        Column() {
          Row() {
            List() {
              ForEach(this.topPathInfo, (item: TopPathInfo) => {
                ListItem() {
                  Row() {
                    if (item.name != '文件类型') {
                      Image($r("app.media.ic_public_right"))
                        .width(displayChange(12))
                        .height(displayChange(24))
                        .margin({
                          left: displayChange(4),
                          right: displayChange(4)
                        })
                    }

                    Text(item.name)
                      .height(displayChange(24))
                      .fontColor('#000000')
                      .fontSize(displayChange(16))
                      .fontWeight(FontWeight.Medium)
                      .opacity(item.opacity)
                      .onClick(() => {
                        LogInfo(this.TAG, item.name + ' onClick')
                        if (item.name == '文件类型') {
                          updateTopPathInfo([], '文件类型', '')
                          this.mMenuLevel = menuLevel.MENU_FIRST_LEVEL_BY_TYPE
                          this.mType = ''
                        } else if (this.mMenuLevel == menuLevel.MENU_THIRD_LEVEL_HAS_DETAIL) {
                          this.mCurrentPath = item.path
                          LogInfo(this.TAG, 'item.path' + item.path)
                          let topPathInfo: Array<TopPathInfo> = AppStorage.Get('topPathInfo')
                          let index: number = topPathInfo.indexOf(item)
                          if (index != -1) {
                            var deleteNum = topPathInfo.length - index + 1
                            topPathInfo.splice(index + 1, deleteNum)
                            topPathInfo[topPathInfo.length - 1].opacity = 1
                            AppStorage.Set('topPathInfo', topPathInfo)
                          }
                        } else if (this.mMenuLevel == menuLevel.MENU_THIRD_LEVEL_HAS_PIC) {
                          this.mMenuLevel = menuLevel.MENU_SECOND_LEVEL_BY_FOLD
                          this.mType = changeStringToType(item.name)
                          LogInfo(this.TAG, 'item.path 2 ' + item.path)
                          this.mCurrentPath = item.path
                        }
                      })
                  }
                }
              }, item => item.name.toString())
            }
            .padding({ right: displayChange(24) })
            .listDirection(Axis.Horizontal)
          }
          .alignItems(VerticalAlign.Center)
          .width('100%')
          .height(displayChange(48))
          .margin({ left: displayChange(12), top: displayChange(4) })
          .padding({ top: displayChange(13), bottom: displayChange(13) })

          Scroll(this.scroller) {
            Column() {
              if (this.mMenuLevel == menuLevel.MENU_FIRST_LEVEL_BY_TYPE) {
                FirstLevelByType({
                  mFileList: this.mFirstMenuData,
                  mType: $mType,
                  mMenuLevel: $mMenuLevel,
                  mCurrentPath: $mCurrentPath,
                  mWorker: this.mWorker,
                })
              } else if (this.mMenuLevel == menuLevel.MENU_SECOND_LEVEL_BY_FOLD) {
                SecondLevelByFold({
                  mType: $mType,
                  mMenuLevel: $mMenuLevel,
                  mCurrentPath: $mCurrentPath,
                  mWorker: this.mWorker,
                  mFileList: $mSecondMenuData
                })
              } else if (this.mMenuLevel == menuLevel.MENU_THIRD_LEVEL_HAS_PIC) {
                ThirdLevelHasPic({
                  mType: $mType,
                  mMenuLevel: $mMenuLevel,
                  mCurrentPath: $mCurrentPath,
                  mWorker: this.mWorker,
                  mFileList: $mThirdMenuPicData
                })
              } else if (this.mMenuLevel == menuLevel.MENU_THIRD_LEVEL_HAS_DETAIL) {
                ThirdLevelHasDetail({
                  mType: $mType,
                  mMenuLevel: $mMenuLevel,
                  mCurrentPath: $mCurrentPath,
                  mWorker: this.mWorker,
                  mFileInfo: $mThirdMenuDetailData
                })
              }
              Row() {
              }.width('100%').height(displayChange(53))
            }
            .alignItems(HorizontalAlign.Start)
          }
          .scrollBar(BarState.Off)
          .scrollable(ScrollDirection.Vertical)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .alignItems(HorizontalAlign.Start)
      .height(globalThis.scrollHeight)

      BottomBar({
        mCurrentPath: $mCurrentPath,
        mMenuLevel: $mMenuLevel,
        mType: $mType,
        mWorker: this.mWorker
      })
    }
    .padding({ left: displayChange(12), right: displayChange(12) })
    .width('100%')
    .height(globalThis.mainDialogHeight)
    .border({ radius: 24 })
    .backgroundColor('#F1F3F5')
  }
}

@Component
struct TopBarArea {
  build() {
    Row() {
      Text('文件类型')
        .width(displayChange(98))
        .height(displayChange(33))
        .fontSize(displayChange(24))
        .fontColor('#182431')
        .fontWeight(FontWeight.Medium)
        .margin({ left: displayChange(12) })
    }
    .height(displayChange(64))
    .width('100%')
    .border({ radius: 24 })
    .padding({ top: displayChange(8) })
  }
}

@Component
struct BottomBar {
  private TAG: string = 'BottomBar'
  private mWorker
  @State currentChoseFiles: Array<string> = []
  @Link mType: string
  @Link mMenuLevel: number
  @Link mCurrentPath: string
  @StorageLink('choseFiles') @Watch('choseFileChange') choseFiles: Array<FileInfo> = []

  aboutToAppear() {
    LogInfo(this.TAG, 'current choose file number = ' + this.currentChoseFiles.length)
  }

  private choseFileChange() {
    this.currentChoseFiles = []
    let files: Array<FileInfo> = AppStorage.Get('choseFiles')
    files.forEach((item: FileInfo) => {
      this.currentChoseFiles.push(item.name)
    })
    LogInfo(this.TAG, 'current choose file number = ' + this.currentChoseFiles.length)
  }

  build() {
    Row() {
      Button() {
        Text('取消')
          .width(displayChange(110))
          .height(displayChange(22))
          .fontSize(displayChange(16))
          .fontWeight(FontWeight.Medium)
          .fontColor('#007DFF')
          .textAlign(TextAlign.Center)
      }
      .width(displayChange(150))
      .height(displayChange(40))
      .margin({ left: displayChange(12), top: displayChange(12), bottom: displayChange(24) })
      .backgroundColor('#E5E8EA')
      .onClick((event: ClickEvent) => {
        terminateSelfWithResult(terminate_reason.NO_ACTION, '')
        AppStorage.Set('choseFiles', [])
      })

      if (globalThis.startMode == 'save') {
        Button() {
          Text($r("app.string.btn_upload"))
            .width(displayChange(110))
            .height(displayChange(22))
            .fontSize(displayChange(16))
            .fontWeight(FontWeight.Medium)
            .fontColor('#007DFF')
            .textAlign(TextAlign.Center)
            .opacity(this.choseFiles.length != 0 ? 1 : 0.4)
        }
        .backgroundColor(this.choseFiles.length != 0 ? '#E5E8EA' : '#ECEEF0')
        .margin({
          left: displayChange(12),
          top: displayChange(12),
          bottom: displayChange(24)
        })
        .height(displayChange(40))
        .width(displayChange(150))
        .stateEffect(this.mMenuLevel == menuLevel.MENU_FIRST_LEVEL_BY_TYPE ? false : true)
        .onClick((event: ClickEvent) => {
          this.mWorker.postMessage({
            request_data: 'createFile',
            device_name: 'local',
            menu_level: this.mMenuLevel,
            media_type: this.mType,
            path: this.mCurrentPath,
            save_name: globalThis.saveFile,
          })
        })
      } else {
        Button() {
          Text($r("app.string.btn_upload"))
            .width(displayChange(110))
            .height(displayChange(22))
            .fontSize(displayChange(16))
            .fontWeight(FontWeight.Medium)
            .fontColor('#007DFF')
            .textAlign(TextAlign.Center)
            .opacity(this.choseFiles.length != 0 ? 1 : 0.4)
        }
        .backgroundColor(this.choseFiles.length != 0 ? '#E5E8EA' : '#ECEEF0')
        .stateEffect(this.choseFiles.length != 0)
        .margin({
          left: displayChange(12),
          top: displayChange(12),
          bottom: displayChange(24)
        })
        .height(displayChange(40))
        .width(displayChange(150))
        .onClick(() => {
          let result: string = ''
          this.choseFiles.forEach((item: FileInfo) => {
            result += item.path + ';'
          })
          terminateSelfWithResult(terminate_reason.SUCCESS, result)
          AppStorage.Set('choseFiles', [])
        })
      }
    }
    .height(displayChange(76))
    .width('100%')
    .backgroundColor('#F1F3F5')
  }
}