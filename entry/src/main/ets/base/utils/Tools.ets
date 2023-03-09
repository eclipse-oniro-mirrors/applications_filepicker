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

import { BYTE } from '../constants/Constant'
import LanguageUtil from './LanguageUtil'
import { FileMimeTypeUtil } from './FileMimeTypeUtil'
import { MimeType } from '../../databases/model/MimeType'
import Logger from '../log/Logger'

const TAG = 'Tools'

/**
 *  格式化显示大小
 */
export const renderSize = (value, carry = BYTE.ONE_KB) => {
  if (!value) {
    return '0 B'
  }
  let unitArr = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
  const srcSize = parseFloat(value)
  let index = Math.floor(Math.log(srcSize) / Math.log(BYTE.ONE_KB))
  let size = srcSize / Math.pow(BYTE.ONE_KB, index)
  if (size >= carry) {
    size = size / BYTE.ONE_KB
    index++
  }
  //  保留的小数位数
  return size.toFixed(2) + ' ' + unitArr[index]
}

/**
 * @description 截取文件名后缀 文件格式
 * @param fileName 文件名带后缀
 */
export const formatSuffix = (fileName: string) => {
  if (!fileName) {
    return ''
  }
  let newValue = fileName.split('.')
  if (newValue[newValue.length - 1].toUpperCase() === FileMimeTypeUtil.SUFFIX_DLP) {
    newValue.pop()
  }
  return newValue.pop().toUpperCase()
}

/**
 * @description 多选框选中状态
 * @param flag 是否选中
 */
export const getRightIcon = (flag) => {
  return flag ? $r("app.media.checkbox_b") : $r("app.media.checkbox_g")
}

/**
 * @description 生成随机id
 * @param
 */
export const randomId = (): string => {
  let str: string = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
  let res: string = ''
  for (let i = 0; i < 6; i++) {
    // 随机产生字符串的下标
    let n = parseInt(Math.random() * str.length + '')
    res += str[n]
  }
  return res
}

/**
 * @description 获取指定资源ID对应的字符串
 * @param resource: 指定资源
 * @return
 */
export function getResourceString(resource: Resource, ...args): string {
  let isString = /%s/ // 字符串类型
  let isNum = /%d/ // 数字类型
  let resStr = ''
  try {
    resStr = globalThis.abilityContext.resourceManager.getStringSync(resource.id)
  } catch (error) {
    Logger.e(TAG, `getResourceString bundleName: ${globalThis.abilityContext.abilityInfo.bundleName}, abilityName: ${globalThis.abilityContext.abilityInfo.name}`)
    Logger.e(TAG, `getResourceString error，message: ${error}, Resource:${JSON.stringify(resource)}`)
    return resStr
  }

  if (args.length) {
    args.forEach(item => {
      if (typeof item === 'string') {
        resStr = resStr.replace(isString, item)
      } else if (typeof item === 'number') {
        resStr = resStr.replace(isNum, item.toString())
      }
    })
  }
  return resStr
}

/**
 * @description 获取文件夹/文件图标
 * @param Object<FilesData> 文件对象
 */
export const getFileIcon = (fileName: string, isFolder: boolean = false): MimeType => {
  if (isFolder) {
    return new MimeType(
      null,
    MimeType.FILE_CATEGORY_UNKNOW,
    FileMimeTypeUtil.FILE_TYPE_UNKNOW,
    $r('app.media.hidisk_icon_folder'),
    $r('app.media.hidisk_icon_folder_grid'),
    $r('app.media.hidisk_icon_folder_grid'),
      null
    )
  }
  return FileMimeTypeUtil.getFileMimeType(fileName)
}

/**
 * @description 实现文件排序，时间倒序
 * @param dataList: 待排序的文件列表
 */
export const sortDataByTime = (dataList) => {
  // 按照时间排序
  // 规避@State修饰的数组变量执行sort方法不生效问题
  const fileList = dataList.filter(item => item)
  return fileList.sort((a, b) => {
    if (b.mtime !== a.mtime) {
      return b.mtime - a.mtime
    } else {
      return compareStr(a.fileName, b.fileName)
    }
  })
}

function compareStr(str1: string, str2: string) {
  const language = LanguageUtil.getSystemLanguage()
  return str2.localeCompare(str1, language)
}

/**
 * @description 文件夹名/文件名自动+1
 * @param fileItems: 当前列表/目标列表
 * @param filename: 需要+1的字符串
 * @param name: filename如果有后缀
 */
export const createName = (fileItems: any[], filename: string, name?: string): string => {
  try {
    const fileNameList = fileItems.map(({ fileName }) => fileName)
    name = name ?? ''
    let copyReg = /[()]*/g // 复制文件重名时格式化文件名
    let lastNum = /([0-9]*)$/ // 获取末尾数字
    while (fileNameList.includes(name ? filename + ' ' + name : filename)) {
      if (name) {
        filename = filename.replace(copyReg, '').replace(lastNum, res => {
          res = res < '1' ? '1' : res
          const len = res.length
          const num = '(' + (+res + 1) + ')'
          return num.padStart(len, '0')
        })
      } else {
        filename = filename.replace(lastNum, res => {
          const len = res.length
          const num = +res + 1 + ''
          return num.padStart(len, '0')
        })
      }
    }
    return filename
  } catch (err) {
    return filename
  }
}

export const gridName = (fileName) => {
  // 文件名超长是中间部分'...'显示
  const MAX_LENGTH = 11
  if (fileName.length > MAX_LENGTH) {
    return fileName.slice(0, 6) + '...' + fileName.slice(-5)
  } else {
    return fileName
  }
}

/**
 * @description 获取当前文件是否是DLP文件
 * @param value: 文件名
 * @result true/false
 */
export const isDlpFile = (value): boolean => {
  let newValue = value.split('.')
  if (newValue.pop().toUpperCase() === 'DLP') {
    return true
  }
  return false
}