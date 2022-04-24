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

import resourceManager from '@ohos.resourceManager';
import { TopPathInfo } from '../module/FileInfo'
import { LogInfo } from '../../../../../../common/LogUtils'
import { mediaName } from './Constants'

var TAG: string = 'Utils'

export function getRootPath(): Array<TopPathInfo> {
  var root_path: Array<TopPathInfo> = []
  root_path.push(new TopPathInfo('文件类型', ''))
  return root_path
}

var strTypeArr = [
  ['image', '图片'],
  ['video', '视频'],
  ['audio', '音频'],
  ['file', '文档'],
]

export function changeTypeToString(type: string): string {
  LogInfo(TAG, 'changeTypeToString type = ' + type)
  for (var i = 0; i < strTypeArr.length; i++) {
    if (strTypeArr[i][0] == type) {
      return strTypeArr[i][1]
    }
  }
  return ''
}

export function changeStringToType(type: string): string {
  LogInfo(TAG, 'changeStringToType type = ' + type)
  for (var i = 0; i < strTypeArr.length; i++) {
    if (strTypeArr[i][1] == type) {
      return strTypeArr[i][0]
    }
  }
  return ''
}

export function getItemNumberInGrid(itemWidth: number, itemGap: number, parentWidth: number): string {
  LogInfo(TAG, 'getItemNumberInGrid')
  let columnTemples: string = ''
  let remainderWidth: number = parentWidth - itemWidth
  columnTemples += '1fr'
  while (itemWidth + itemGap < remainderWidth) {
    remainderWidth = remainderWidth - (itemWidth + itemGap)
    columnTemples += ' 1fr'
  }
  LogInfo(TAG, 'columnTemples = ' + columnTemples)
  return columnTemples
}

var fileSuffixAndType = [
  ['.doc', $r("app.media.ic_file_doc"), $r("app.string.file_docx")],
  ['.html', $r("app.media.ic_file_html"), $r("app.string.file_html")],
  ['.pdf', $r("app.media.ic_file_pdf"), $r("app.string.file_pdf")],
  ['.pptx', $r("app.media.ic_file_pptx"), $r("app.string.file_pptx")],
  ['.ppt', $r("app.media.ic_file_pptx"), $r("app.string.file_pptx")],
  ['.rar', $r("app.media.ic_file_rar"), $r("app.string.file_rar")],
  ['.txt', $r("app.media.ic_file_txt"), $r("app.string.file_txt")],
  ['.xls', $r("app.media.ic_file_xls"), $r("app.string.file_xls")],
  ['.xml', $r("app.media.ic_file_xml"), $r("app.string.file_xml")],
  ['.zip', $r("app.media.ic_file_zip"), $r("app.string.file_zip")],
]

export function getShowIconBySuffix(suffix: string): string | Resource {
  LogInfo(TAG, 'getShowIconBySuffix suffix = ' + suffix)
  for (var i = 0; i < fileSuffixAndType.length; i++) {
    if (isTwoStringEqual(fileSuffixAndType[i][0].toString(),suffix)) {
      return fileSuffixAndType[i][1]
    }
  }
  return $r("app.media.ic_file_unknown")
}

export function getShowTextBySuffix(suffix: string): string | Resource {
  LogInfo(TAG, 'getShowTextBySuffix suffix = ' + suffix)
  for (var i = 0; i < fileSuffixAndType.length; i++) {
    if (fileSuffixAndType[i][0] == suffix) {
      return fileSuffixAndType[i][2]
    }
  }
  return $r("app.string.file_unknown")
}

export function getWarningDialogMessage(code: number): string | Resource {
  switch (code) {
    case 1:
      return $r("app.string.save_file_has_same_file")
    case 2:
      return $r("app.string.save_file_no_media_permission")
    default:
      return $r("app.string.save_file_unknown_reason")
  }
}

export function isTwoStringEqual(src: string, tar: string) {
  if (src.indexOf(tar) == 0 && tar.indexOf(src) == 0) {
    return true;
  }
  return false;
}

export function updateTopPathInfo(currentPathInfo: Array<TopPathInfo>, name: string, path: string) {
  currentPathInfo.forEach((item: TopPathInfo) => {
    item.opacity = 0.4
  })

  currentPathInfo.push(new TopPathInfo(name, path))
  AppStorage.Set('topPathInfo', currentPathInfo)
  return currentPathInfo
}