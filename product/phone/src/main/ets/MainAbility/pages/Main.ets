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
import { FirstLevelByType } from './FirstLevelByType.ets'
import { SecondLevelByFold } from './SecondLevelByFold.ets'
import { ThirdLevelHasDetail } from '../pages/ThirdLevelHasDetail.ets'
import { ThirdLevelHasPic } from '../pages/ThirdLevelHasPic.ets'
import { FileInfo, TopPathInfo } from '../module/FileInfo.ets'
import { DisplayInfo } from '../module/DisplayInfo.ets'
import { menuLevel, terminate_reason, media_type } from '../module/Constants.ets'
import { LogInfo, LogDebug } from '../module/LogUtils.ets'
import { changeStringToType, updateTopPathInfo } from '../module/Utils.ets'
import { terminateSelfWithResult } from '../module/AbilityUtils.ets'
import { WarningDialog } from '../module/DialogUtils.ets'

import { getFirstMenu } from '../module/FileManagerServiceUtils.ets'

@Entry
@Component
struct Index {
  private TAG: string= 'Main'
  private mWorker
  private displayInfo: DisplayInfo = new DisplayInfo()
  private customDialogController: CustomDialogController = new CustomDialogController({
    builder: WarningDialog({code: $code})
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
  //@StorageLink('topPathInfo') topPathInfo: Array<TopPathInfo> = getRootPath()
  @StorageLink('topPathInfo') topPathInfo: Array<TopPathInfo> = updateTopPathInfo([], '文件类型', '')


  private aboutToAppear() {
    this.displayInfo = AppStorage.Get('displayInfo')
    this.mFirstMenuData = getFirstMenu('')
    LogDebug(this.TAG, 'mFirstMenuData length = ' + this.mFirstMenuData.length)

    LogDebug(this.TAG, 'aboutToAppear 1')
//    this.initWork()
    LogDebug(this.TAG, 'aboutToAppear 2')
//    this.mWorker.postMessage({
//      request_data: 'getRoot',
//      device_name: 'local',
//      menu_level: this.mMenuLevel,
//      media_type: this.mType,
//      path: this.mCurrentPath
//    })
    LogDebug(this.TAG, 'aboutToAppear 3')
  }

  private initWork() {
    if (this.mWorker == undefined) {
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
    LogInfo(this.TAG, 'onMessage')
    var params = result.data.params
    var file = JSON.parse(String.fromCharCode.apply(null, new Uint16Array(result.data.data)))
    if (params.request_data == 'createFile') {
      if (file.code == undefined) {
        terminateSelfWithResult(terminate_reason.SUCCESS, file)
      } else {
        if (params.path == 'dataability:///album') {
          this.code = 2;
          this.customDialogController.open()
          // showWarningDialog(getWarningDialogMessage(2))
        } else {
          this.code = file.code
          this.customDialogController.open()
          // showWarningDialog(getWarningDialogMessage(file.code))
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
      if (params.menu_level == menuLevel.MENU_FIRST_LEVEL_BY_TYPE) {
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
        Scroll() {
          Column() {
            Row() {
              List() {
                ForEach(this.topPathInfo, (item: TopPathInfo) => {
                  ListItem() {
                    Row() {
                      if (item.name != '文件类型') {
                        Image($r("app.media.ic_public_right"))
                          .width(12 * 2)
                          .height(24 * 2)
                          .margin({
                            left: 4 * 2,
                            right: 4 * 2
                          })
                      }

                      Text(item.name)
                        .height(24 * 2)
                        .fontColor('#000000')
                        .fontSize(16 * 2)
                        .fontWeight(FontWeight.Medium)
                        .opacity(item.opacity)
                        .onClick(() => {
                          LogInfo(this.TAG, item.name + ' onClick')
                          if (item.name == '文件类型') {
                            updateTopPathInfo([], '文件类型', '')
                            this.mMenuLevel = menuLevel.MENU_FIRST_LEVEL_BY_TYPE
                            this.mType = ''
                            //this.topPathInfo = getRootPath()
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
              .listDirection(Axis.Horizontal)
            }
            .alignItems(VerticalAlign.Center)
            .height(48 * 2)
            .margin({ left: 24 * 2, top: 4 * 2 })
            .padding({ top: 13 * 2, bottom: 13 * 2 })

            Row() {
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
            }
          }
          .alignItems(HorizontalAlign.Start)
        }
      }
      .height(this.displayInfo.mainDialogHeight - (48 * 2))

      BottomBar({
        mCurrentPath: $mCurrentPath,
        mMenuLevel: $mMenuLevel,
        mType: $mType,
        mWorker: this.mWorker
      })
    }
    .width('100%')
    .height(this.displayInfo.height)
    .border({ radius: 24 * 2 })
    .backgroundColor('#F1F3F5')
  }
}

@Component
struct TopBarArea {

  build() {
    Row() {
      Text('文件类型')
        .width(98 * 2)
        .height(33 * 2)
        .fontSize(24 * 2)
        .fontColor('#182431')
    }
    .height(56  * 2)
    .width('100%')
    .border({ radius: '24px' })
    .margin({ left: 24 * 2 })
    .padding({ top: 8 * 2, bottom: 11 * 2 })
  }
}

@Component
struct BottomBar {
  private TAG: string = 'BottomBar'
  private mWorker
  private mSaveFileName: string

  @Link mCurrentPath: string
  @Link mMenuLevel: number
  @Link mType: string
  @StorageLink('choseFiles') @Watch('choseFileChange') choseFiles: Array<FileInfo> = []

  private aboutToAppear() {
    this.mSaveFileName = AppStorage.Get<string>('saveName')
    LogInfo(this.TAG, 'choseFiles number = ' + this.choseFiles.length)
    LogInfo(this.TAG, 'current mode = ' + globalThis.startMode)
  }

  private choseFileChange() {
    LogInfo(this.TAG, 'choseFiles number = ' + this.choseFiles.length)
  }

  build() {
    Row() {
      Button() {
        Text('取消')
          .width(110 * 2)
          .height(22 * 2)
          .fontSize(16 * 2)
          .fontWeight(FontWeight.Medium)
          .fontColor('#007DFF')
          .textAlign(TextAlign.Center)
      }
      .width(150 * 2)
      .height(40 * 2)
      .margin({ left: 24 })
      .backgroundColor('#E5E8EA')
      .onClick((event: ClickEvent) => {
        terminateSelfWithResult(terminate_reason.NO_ACTION, '')
        AppStorage.Set('choseFiles', [])
      })

      if (globalThis.startMode == 'save') {
        Button() {
          Text($r("app.string.btn_upload"))
            .width(110 * 2)
            .height(22 * 2)
            .fontSize(16 * 2)
            .fontWeight(FontWeight.Medium)
            .fontColor('#007DFF')
            .textAlign(TextAlign.Center)
        }
        .backgroundColor(this.mMenuLevel == menuLevel.MENU_FIRST_LEVEL_BY_TYPE ? '#ECEEF0' : '#E5E8EA')
        .margin({ left: 12 * 2 })
        .height(40 * 2)
        .width(150 * 2)
        .stateEffect(this.mMenuLevel == menuLevel.MENU_FIRST_LEVEL_BY_TYPE ? false : true)
        .onClick((event: ClickEvent) => {
          this.mWorker.postMessage({
            request_data: 'createFile',
            device_name: 'local',
            menu_level: this.mMenuLevel,
            media_type: this.mType,
            path: this.mCurrentPath,
            save_name: this.mSaveFileName,
          })
        })
      } else {
        Button() {
          Text($r("app.string.btn_upload"))
            .width(110 * 2)
            .height(22 * 2)
            .fontSize(16 * 2)
            .fontWeight(FontWeight.Medium)
            .fontColor('#007DFF')
            .textAlign(TextAlign.Center)
        }
        .backgroundColor(this.choseFiles.length != 0 ? '#E5E8EA' : '#ECEEF0')
        .stateEffect(this.choseFiles.length != 0 )
        .margin({ left: 12 * 2 })
        .height(40 * 2)
        .width(150 * 2)
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
    .height(76)
    .width('100%')
    .margin({
      left: 24 * 2,
      top: 12 * 2,
      bottom: 24 * 2
    })
  }
}