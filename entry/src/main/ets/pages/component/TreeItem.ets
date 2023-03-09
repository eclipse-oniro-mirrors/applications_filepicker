/*
 * Copyright (c) 2021-2023 Huawei Device Co., Ltd.
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

import { FilesData } from '../../databases/model/FileData'
import { on } from '../../base/utils/EventBus'
import FileAccessExec from '../../base/utils/FileAccessExec'
import { TREE_LAYER } from '../../base/constants/UiConstant'

@Styles function pressedStyles() {
  .borderRadius($r('app.float.common_borderRadius8'))
  .backgroundColor($r('app.color.hicloud_hmos_bg'))
}

@Component
export struct TreeItem {
  fileItem: FilesData = new FilesData({})
  @State iconRotate: boolean = false
  @State subFolderList: Array<FilesData> = new Array<FilesData>()
  @Link chooseItem: FilesData
  @Link selectUri: string
  @Link selectName: string
  @Link fileList: Array<FilesData>
  @Link folderList: Array<FilesData>
  @State isShowArrow: boolean = true
  @Prop layer: number

  getSelectItem(path: string): Array<FilesData> {
    let folderList = new Array<FilesData>()
    let fileList = new Array<FilesData>()
    let allFileList = FileAccessExec.getFileByCurIterator(this.fileItem.fileIterator)
    allFileList.forEach((item) => {
      if (item.isFolder) {
        item.path = `${path}/${item.fileName}`
        folderList.push(new FilesData({
          ...item
        }))
      } else {
        fileList.push(new FilesData({
          ...item
        }))
      }
    })
    this.fileList = fileList
    return folderList

  }

  aboutToAppear() {
    on('fileMkdir', (e) => {
      if (this.selectUri === this.fileItem.uri) {
        // 获取当前选中文件夹下的所有子文件
        this.subFolderList = this.getSelectItem(this.fileItem.path)
        // 查找刚刚新建的文件夹index
        const index = this.subFolderList.findIndex(item => item.fileName === e.mkdirName)
        if (index !== -1) {
          // 默认选中刚刚新建的文件夹
          this.chooseItem = this.subFolderList[index]
          this.selectUri = this.subFolderList[index].uri
          this.selectName = this.subFolderList[index].fileName
          this.iconRotate = true
          this.folderList = []
          this.fileList = []
        } else {
          this.folderList = this.subFolderList
        }
      }
    })
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.hidisk_ic_list_empty_folder'))
          .objectFit(ImageFit.Contain)
          .renderMode(ImageRenderMode.Original)
          .aspectRatio(1)
          .width($r('app.float.common_size24'))
          .alignSelf(ItemAlign.Center)
          .margin({ right: $r('app.float.common_margin16') })
        Text(this.fileItem.fileName)
          .fontSize($r('app.float.common_font_size16'))
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Image($r('app.media.ic_arrow_right'))
          .objectFit(ImageFit.Contain)
          .renderMode(ImageRenderMode.Original)
          .aspectRatio(1)
          .width($r('app.float.common_size15'))
          .rotate({ z: 90, angle: this.iconRotate ? 90 : 0 })
          .visibility(this.isShowArrow ? Visibility.Visible : Visibility.None)
      }
      .width('100%')
      .padding({
        top: $r('app.float.common_padding16'),
        bottom: $r('app.float.common_padding16'),
        right: $r('app.float.common_padding24'),
        left: this.layer * TREE_LAYER + 'vp'
      })
      .backgroundColor(this.selectUri === this.fileItem.uri ? $r('app.color.move_dialog_background') : '')
      .stateStyles({
        pressed: pressedStyles
      })
      .onClick(() => {
        this.iconRotate = !this.iconRotate
        this.selectUri = this.fileItem.uri
        this.selectName = this.fileItem.fileName
        this.chooseItem = this.fileItem
        this.subFolderList = this.getSelectItem(this.fileItem.path)
        this.folderList = this.subFolderList
        this.isShowArrow = this.subFolderList.length !== 0
      })

      if (this.subFolderList.length && this.iconRotate) {
        ForEach(this.subFolderList, (item) => {
          TreeItem({
            fileItem: item,
            chooseItem: $chooseItem,
            selectUri: $selectUri,
            selectName: $selectName,
            layer: this.layer + 1,
            folderList: $folderList,
            fileList: $fileList
          })
        })
      }
    }
  }
}