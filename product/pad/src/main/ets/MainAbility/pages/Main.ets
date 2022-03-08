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
import { menuLevel, terminate_reason, media_type, pad_size, mediaName } from '../module/Constants.ets'
import { LogInfo, LogDebug } from '../module/LogUtils.ets'
import { getRootPath, changeStringToType, changeTypeToString, updateTopPathInfo } from '../module/Utils.ets'
import { terminateSelfWithResult } from '../module/AbilityUtils.ets'
import { WarningDialog } from '../module/DialogUtils.ets'

import { getFirstMenu, getListFile } from '../module/FileManagerServiceUtils.ets'

@Entry
@Component
struct Index {
  private TAG: string= 'Main'
  private mWorker
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
  //@StorageLink('topPathInfo') topPathInfo: Array<TopPathInfo> = getRootPath()
  @StorageLink('topPathInfo') topPathInfo: Array<TopPathInfo> = updateTopPathInfo([], '文件类型', '')

  private aboutToAppear() {
    LogInfo(this.TAG, 'aboutToAppear')
    if (globalThis.debugMode) {
      this.mFirstMenuData = getFirstMenu('')
      LogDebug(this.TAG, 'mFirstMenuData length = ' + this.mFirstMenuData.length)
    } else {
      this.initWorker()
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

  private initWorker() {
    if (this.mWorker == undefined) {
      LogInfo(this.TAG, 'initWorker')
      this.mWorker = new worker.Worker('workers/DataWorker.js', { type: 'classic', name: 'filePicker' })
      this.mWorker.onerror = this.onError.bind(this)
      this.mWorker.onmessageerror = this.onMessageError.bind(this)
      this.mWorker.onexit = this.onExit.bind(this)
      this.mWorker.onmessage = this.onMessage.bind(this)
    }
  }

  private onError(e): void {
    LogInfo(this.TAG, 'onError = ' + JSON.stringify(e))
  }

  private onMessageError(e): void {
    LogInfo(this.TAG, 'onMessageError = ' + JSON.stringify(e))
  }

  private onExit(): void{
    LogInfo(this.TAG, 'onExit worker')
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
      for (var index = 0; index < file.length; index++) {
        var info = file[index]
        let item = new FileInfo(info.name)
        item.path = info.path
        item.type = info.type
        item.size = info.size
        item.dataAdded_time = info.added_time
        item.modified_time = info.modified_time
        if (params.menu_level == menuLevel.MENU_FIRST_LEVEL_BY_TYPE) {
          if (item.name == 'image_album') {
            item.name = mediaName.IMAGE
            item.mediaType = 'image'
            item.thumbnail = $r("app.media.ic_type_image")
          } else if (item.name == 'video_album') {
            item.name = mediaName.VIDEO
            item.mediaType = 'video'
            item.thumbnail = $r("app.media.ic_type_video")
          } else if (item.name == 'audio_album') {
            item.name = mediaName.AUDIO
            item.mediaType = 'audio'
            item.thumbnail = $r("app.media.ic_type_audio")
          } else if (item.name == 'file_folder') {
            item.name = mediaName.DOCUMENT
            item.mediaType = 'file'
            item.thumbnail = $r("app.media.ic_public_file")
          }
        }

        if (params.menu_level == menuLevel.MENU_THIRD_LEVEL_HAS_DETAIL) {
          if (globalThis.startMode == 'save' && item.type != media_type.MEDIA_TYPE_ALBUM) {
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
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
      Row() {
        LeftDialogComponent({
          mType: $mType,
          mMenuLevel: $mMenuLevel,
          mCurrentPath: $mCurrentPath,
          mFirstMenuData: $mFirstMenuData
        })

        Column() {
          Row() {
            Row() {
              Image($r("app.media.ic_public_back"))
                .width(pad_size.TWENTY_FOUR)
                .height(pad_size.TWENTY_FOUR)
                .margin({ left: pad_size.TWENTY_FOUR })
                .onClick(() => {
                  if (this.mMenuLevel == menuLevel.MENU_SECOND_LEVEL_BY_FOLD) {
                    updateTopPathInfo([], '文件类型', '')
                    this.mMenuLevel = menuLevel.MENU_FIRST_LEVEL_BY_TYPE
                    this.mType = ''
                    //this.topPathInfo = getRootPath()
                  } else if (this.mMenuLevel == menuLevel.MENU_THIRD_LEVEL_HAS_PIC || (this.mMenuLevel == menuLevel.MENU_THIRD_LEVEL_HAS_DETAIL)) {
                    this.topPathInfo.pop()
                    this.topPathInfo[this.topPathInfo.length - 1].opacity = 1
                    if (this.topPathInfo.length > 1) {
                      var index = this.topPathInfo.length - 1
                      this.mCurrentPath = this.topPathInfo[index].path
                      this.mMenuLevel = menuLevel.MENU_SECOND_LEVEL_BY_FOLD
                    } else {
                      this.mMenuLevel = menuLevel.MENU_FIRST_LEVEL_BY_TYPE
                      this.mType = ''
                    }
                  }
                })

              Image($r("app.media.ic_public_next"))
                .width(pad_size.TWENTY_FOUR)
                .height(pad_size.TWENTY_FOUR)
                .margin({ left: pad_size.TWENTY_FOUR, right: pad_size.TWENTY_FOUR })
            }

            Row() {
              List() {
                ForEach(this.topPathInfo, (item: TopPathInfo) => {
                  ListItem() {
                    Row() {
                      if (item.name != mediaName.FILE_TYPE) {
                        Image($r("app.media.ic_public_right"))
                          .width(pad_size.TWELVE)
                          .height(pad_size.TWENTY_FOUR)
                          .margin({ left: pad_size.TWELVE, right: pad_size.TWELVE })
                      }
                      Text(item.name)
                        .height(pad_size.TWENTY_FOUR)
                        .fontSize(pad_size.SIXTEEN)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#182431')
                        .opacity(item.opacity)
                        .onClick(() => {
                          if (item.name == mediaName.FILE_TYPE) {
                            updateTopPathInfo([], '文件类型', '')
                            //this.topPathInfo = getRootPath()
                            this.mMenuLevel = menuLevel.MENU_FIRST_LEVEL_BY_TYPE
                            this.mType = ''
                          } else if (this.mMenuLevel == menuLevel.MENU_THIRD_LEVEL_HAS_DETAIL) {
                            this.mCurrentPath = item.path
                            LogInfo(this.TAG, 'item.path ' + item.path)
                            let topPathInfo: Array<TopPathInfo> = AppStorage.Get('topPathInfo')
                            let index: number = topPathInfo.indexOf(item)
                            if (index != -1) {
                              var deleteNum = topPathInfo.length - index + 1
                              topPathInfo.splice(index + 1, deleteNum)
                              topPathInfo[topPathInfo.length - 1].opacity = 1
                              AppStorage.Set('topPathInfo', topPathInfo)
                            }
                          } else if (this.mMenuLevel == menuLevel.MENU_THIRD_LEVEL_HAS_PIC) {
                            let topPathInfo: Array<TopPathInfo> = AppStorage.Get('topPathInfo')
                            let index: number = topPathInfo.indexOf(item)
                            if (index != -1) {
                              this.mMenuLevel = menuLevel.MENU_SECOND_LEVEL_BY_FOLD
                              this.mType = changeStringToType(item.name)
                              this.mCurrentPath = item.path
                            }
                          }
                        })
                    }
                  }
                }, item => item.name)
              }
              .listDirection(Axis.Horizontal)
              .margin({ left: pad_size.TWELVE, top: pad_size.SEVENTEEN })
            }
            .width(pad_size.FOUR_HUNDRED)
            .height(pad_size.FIFTY_SIX)
            .backdropBlur(pad_size.TWENTY)
            .backgroundColor(Color.White)
            .border({ radius: pad_size.TWENTY_FOUR, width: 0.1, style: BorderStyle.Solid })
          }
          .width(pad_size.RIGHT_DIALOG_WIDTH)
          .height(pad_size.FIFTY_SIX)
          .margin({ top: pad_size.SIXTEEN })

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
          .width(pad_size.RIGHT_DIALOG_WIDTH)
          .height(pad_size.TWO_HUNDRED_AND_SIXTY)
        }
        .width(pad_size.RIGHT_DIALOG_WIDTH)
        .height(pad_size.RIGHT_DIALOG_HEIGHT)
      }
      .width(pad_size.BOTTOM_WIDTH)

      Divider().color('#D8D8D8').opacity(1)
        .strokeWidth(1)


      BottomArea({
        mWorker: this.mWorker,
        mType: $mType,
        mMenuLevel: $mMenuLevel,
        mCurrentPath: $mCurrentPath
      })

    }
    .width(pad_size.MAIN_DIALOG_WIDTH)
    .height(pad_size.MAIN_DIALOG_HEIGHT)
    .border({ radius: pad_size.TWENTY_FOUR })
  }
}

@Component
struct LeftDialogComponent {
  private TAG: string = 'LeftDialogComponent'
  @Link mFirstMenuData: FileInfo[]
  @Link @Watch('typeStatusChange') mType: string
  @Link mMenuLevel: number
  @Link mCurrentPath: string

  //@StorageLink('topPathInfo') topPathInfo: Array<TopPathInfo> = getRootPath()
  @StorageLink('topPathInfo') topPathInfo: Array<TopPathInfo> = updateTopPathInfo([], '文件类型', '')

  typeStatusChange() {
    LogInfo(this.TAG, 'typeStatusChange level = ' + this.mMenuLevel + ';mType = ' + this.mType)
    this.mFirstMenuData.forEach(item => {
      if (item.mediaType == this.mType) {
        item.list_background = '#1A000000'
      } else {
        item.list_background = ''
      }
    });
  }

  build() {
    Column() {
      Row() {
        Image($r("app.media.ic_public_folder"))
          .width(pad_size.IC_PUBLIC_FOLDER_WIDTH)
          .height(pad_size.IC_PUBLIC_FOLDER_HEIGHT)
          .margin({ left: pad_size.TWELVE })
        Text($r("app.string.file_type"))
          .fontSize(pad_size.SIXTEEN)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')
          .margin({ left: pad_size.SIXTEEN })
        Blank()
        Image($r("app.media.ic_public_down"))
          .width(pad_size.TWENTY_FOUR)
          .height(pad_size.TWENTY_FOUR)
          .margin({ right: pad_size.TWENTY })
      }
      .width(pad_size.ONE_HUNDRED_AND_SEVENTY_SIX)
      .height(pad_size.FIFTY_SIX)
      .margin({ left: pad_size.TWELVE, top: pad_size.SIXTEEN, right: pad_size.TWELVE })
      .border({ radius: pad_size.TWENTY })
      .backgroundColor('#DCEAF9')
      .onClick((event: ClickEvent) => {
        if (this.mMenuLevel != menuLevel.MENU_FIRST_LEVEL_BY_TYPE) {
          updateTopPathInfo([], '文件类型', '')
          //this.topPathInfo = getRootPath()
          this.mMenuLevel = menuLevel.MENU_FIRST_LEVEL_BY_TYPE
          this.mType = ''
          this.mCurrentPath = ''
        }
      })

      List() {
        ForEach(this.mFirstMenuData, (item, FileInfo) => {
          ListItem() {
            Row() {
              Image(item.thumbnail)
                .width(pad_size.TWENTY_FOUR)
                .height(pad_size.TWENTY_FOUR)
                .margin({ left: pad_size.TWENTY_FOUR })
              Text(item.name)
                .fontSize(pad_size.SIXTEEN)
                .fontWeight(FontWeight.Medium)
                .fontColor('#182431')
                .margin({ left: pad_size.SIXTEEN })
            }
            .width(pad_size.ONE_HUNDRED_AND_SEVENTY_SIX)
            .height(pad_size.FIFTY_SIX)
            .margin({ left: pad_size.TWELVE, right: pad_size.TWELVE })
            .backgroundColor(item.list_background)
            .border({ radius: pad_size.TWENTY })
            .onClick((event: ClickEvent) => {
              this.mCurrentPath = item.path
              this.mMenuLevel = menuLevel.MENU_SECOND_LEVEL_BY_FOLD
              this.mType = item.mediaType
//              let path: Array<TopPathInfo> = getRootPath()
//              path.push(new TopPathInfo(changeTypeToString(this.mType), this.mCurrentPath))
//              AppStorage.Set('topPathInfo', path)
              updateTopPathInfo([], '文件类型', '')
              updateTopPathInfo(AppStorage.Get('topPathInfo'), changeTypeToString(this.mType), this.mCurrentPath)

            })
          }
        }, item => item.name)
      }
    }
    .width(pad_size.LEFT_DIALOG_WIDTH)
    .height(pad_size.LEFT_DIALOG_HEIGHT)
    .backgroundColor("#F2F2F2")
  }
}

@Component
struct BottomArea {
  private TAG: string = 'BottomArea'
  private mWorker
  @State currentChoseFiles: Array<string> = []
  @Link mType: string
  @Link mMenuLevel: number
  @Link mCurrentPath: string
  @StorageLink('choseFiles') @Watch('choseFilesChange') choseFiles: Array<FileInfo> = []

  private aboutToAppear() {
    LogInfo(this.TAG, 'current choose file number = ' + this.currentChoseFiles.length)
  }

  private choseFilesChange() {
    this.currentChoseFiles = []
    let files: Array<FileInfo> = AppStorage.Get('choseFiles')
    files.forEach((item: FileInfo) => {
      this.currentChoseFiles.push(item.name)
    })
    LogInfo(this.TAG, 'current choose file number = ' + this.currentChoseFiles.length)
  }

  build() {
    Column() {
      Row() {
        Text($r("app.string.file_name"))
          .fontSize(pad_size.SIXTEEN)
          .fontWeight(FontWeight.Regular)
          .fontColor('#000000')
          .margin({ left: pad_size.EIGHT })
        Row() {
          Text(this.currentChoseFiles.toString())
            .height(pad_size.THIRTY)
            .maxLines(1)
            .margin({ left: pad_size.SIXTEEN })
        }
        .width(pad_size.SIX_HUNDRED_AND_NINE)
        .height(pad_size.THIRTY_TWO)
        .border({ width: pad_size.ONE, radius: pad_size.SIXTEEN })
        .margin({ left: pad_size.SIXTEEN, right: pad_size.TWENTY_FOUR })
        .opacity(0.2)
      }
      .width(pad_size.SEVEN_HUNDRED_AND_FOURTEEN)
      .height(pad_size.SIXTY_FOUR)
      .margin({ left: pad_size.TWENTY_ONE, right: pad_size.NINE })

      Row() {
        Button() {
          Text($r('app.string.btn_cancel'))
            .fontSize(pad_size.SIXTEEN)
            .fontWeight(FontWeight.Medium)
            .fontColor('#007DFF')
        }
        .width(pad_size.ONE_HUNDRED_AND_SEVENTY_EIGHT)
        .height(pad_size.FORTY)
        .backgroundColor('#d9e0dc')
        .border({ radius: pad_size.TWENTY })
        .margin({ left: pad_size.THREE_HUNDRED_AND_FORTY })
        .onClick(() => {
          terminateSelfWithResult(terminate_reason.NO_ACTION, '')
          AppStorage.Set('choseFiles', [])
        })

        if (globalThis.startMode == 'save') {
          Button() {
            Text($r('app.string.btn_save'))
              .fontSize(pad_size.SIXTEEN)
              .fontWeight(FontWeight.Medium)
              .fontColor('#007DFF')
          }
          .width(pad_size.ONE_HUNDRED_AND_SEVENTY_EIGHT)
          .height(pad_size.FORTY)
          .backgroundColor(this.mMenuLevel == menuLevel.MENU_FIRST_LEVEL_BY_TYPE ? '' : '#d9e0dc')
          .border({ radius: pad_size.TWENTY })
          .margin({ left: pad_size.TWENTY_FOUR, right: pad_size.TWENTY_FOUR })
          .stateEffect(this.mMenuLevel == menuLevel.MENU_FIRST_LEVEL_BY_TYPE ? false : true)
          .onClick(() => {
            this.mWorker.postMessage({
              request_data: 'createFile',
              device_name: 'local',
              media_type: this.mType,
              path: this.mCurrentPath,
              save_name: globalThis.saveFile
            })
          })
        } else {
          Button() {
            Text($r('app.string.btn_upload'))
              .fontSize(pad_size.SIXTEEN)
              .fontWeight(FontWeight.Medium)
              .fontColor('#007DFF')
          }
          .width(pad_size.ONE_HUNDRED_AND_SEVENTY_EIGHT)
          .height(pad_size.FORTY)
          .backgroundColor(this.currentChoseFiles.length != 0 ? '#d9e0dc' : '')
          .border({ radius: pad_size.TWENTY })
          .margin({ left: pad_size.TWENTY_FOUR, right: pad_size.TWENTY_FOUR })
          .stateEffect(this.currentChoseFiles.length != 0)
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
    }
    .width(pad_size.MAIN_DIALOG_WIDTH)
    .height(pad_size.BOTTOM_HEIGHT)
    .margin({ bottom: pad_size.FOUR })
    .backgroundColor('#F2F2F2')
  }

}
