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

/**
 * FileAccessManager删除、复制、移动、重命名等操作
 */
import Logger from '../log/Logger'
import { FilesData } from '../../databases/model/FileData'
import { DOCUMENTS_FOLDER } from '../constants/Constant'
import { sortDataByTime, randomId } from './Tools'
import fileAccess from '@ohos.file.fileAccess'
import fileExtensionInfo from '@ohos.file.fileExtensionInfo'

const TAG = 'FileAccessExec'

namespace FileAccessExec {

  // 创建文件夹
  export function createFolder(sourceUri: string, folderName: string): any {
    return new Promise((resolve, reject) => {
      try {
        globalThis.fileAcsHelper.mkDir(sourceUri, folderName, (ret, data) => {
          if (ret && ret.code !== '0') {
            reject(ret)
            Logger.e(TAG, 'createFolder fail:' + JSON.stringify(ret))
          } else {
            resolve(data)
          }
        })
      } catch (error) {
        reject(error)
        Logger.e(TAG, 'createFolder error occurred:' + error)
      }
    })
  }

  // 创建文件
  export function createFile(sourceUri: string, fileName: string): any {
    return new Promise((resolve, reject) => {
      try {
        globalThis.fileAcsHelper.createFile(sourceUri, fileName, (ret, data) => {
          if (ret && ret.code !== '0') {
            reject(ret)
            Logger.e(TAG, 'createFile fail:' + JSON.stringify(ret))
          } else {
            resolve(data)
          }
        })
      } catch (error) {
        reject(error)
        Logger.e(TAG, 'createFile error occurred:' + error)
      }
    })
  }

  // 打开文件
  export function openFile(sourceUri: string): any {
    return new Promise((resolve, reject) => {
      try {
        //  - 0o0：只读打开 0o1：只写打开  0o2：读写打开
        globalThis.fileAcsHelper.openFile(sourceUri, 0o2, (ret, data) => {
          if (ret && ret.code !== '0') {
            reject(ret)
            Logger.e(TAG, 'openFile fail:' + JSON.stringify(ret))
          } else {
            resolve(data)
          }
        })
      } catch (error) {
        reject(error)
        Logger.e(TAG, 'openFile error occurred:' + error)
      }
    })
  }

  export function getFileData(): any {
    let folderList = new Array<FilesData>()
    let fileList = new Array<FilesData>()
    const allData = getRootFolder()
    allData.forEach((item) => {
      if (item.isFolder) {
        folderList.push(new FilesData({
          ...item
        }))
      } else {
        fileList.push(new FilesData({
          ...item
        }))
      }
    })
    return { folderList, fileList }
  }

  export function getFileByCurIterator(fileInfo: fileAccess.FileInfo, isRoot: boolean = false): Array<FilesData> {
    let fileArr = []
    let fileIterator = fileInfo.listFile()
    let documentsFolder: fileAccess.FileInfo = null
    if (!fileIterator) {
      return
    }
    let result = fileIterator.next()
    let isDone = result.done
    while (!isDone) {
      try {
        const {fileName, uri, mode, size, mtime, mimeType} = result.value
        let tempFile = new FilesData({
          id: randomId(),
          fileName,
          uri,
          mode,
          size,
          mtime,
          mimeType,
          fileIterator: result.value
        })
        // 根目录下不显示Documents文件夹
        if (isRoot && result.value.fileName === DOCUMENTS_FOLDER) {
          globalThis.documentInfo = tempFile
          documentsFolder = result.value
        } else {
          fileArr.push(tempFile)
        }
        result = fileIterator.next()
        isDone = result.done
      } catch (e) {
        Logger.e(TAG, 'getFileByCurIterator error: ' + e.toString())
        isDone = true
      }
    }
    // 处理Documents目录
    if (documentsFolder) {
      // 获取Documents目录下的文件列表
      const documentFileList = getFileByCurIterator(documentsFolder)
      // 将Documents目录下的文件合并入根目录
      fileArr = fileArr.concat(documentFileList)
    } else if (isRoot) {
      Logger.e(TAG, 'not found Documents folder in root path')
    }

    fileArr = sortDataByTime(fileArr)
    return fileArr
  }


  export function getRootFolder(): Array<FilesData> {
    if (!globalThis.rootInfoArr) {
      Logger.e(TAG, 'globalThis.rootInfoArr is null ')
      return []
    }
    // 过滤本地磁盘
    const rootInfo: fileAccess.RootInfo = globalThis.rootInfoArr.find(item => item.deviceType === fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK)

    if (!rootInfo) {
      Logger.e(TAG, 'getRootFolder rootInfo is null ')
      return []
    }
    const fileIterator: fileAccess.FileIterator = rootInfo.listFile()
    if (!fileIterator) {
      Logger.e(TAG, 'getRootFolder fileIterator is null ')
      return []
    }
    let isDone = false
    let tempFileIterator = null
    while (!isDone) {
      const nextFileRes: {
        value: fileAccess.FileInfo,
        done: boolean
      } = fileIterator.next()
      const nextFileName = nextFileRes.value.fileName
      if (nextFileName.indexOf('FILE') !== -1) {
        tempFileIterator = nextFileRes.value
        isDone = true
      } else {
        isDone = nextFileRes.done
      }
    }
    if (!tempFileIterator) {
      Logger.e(TAG, 'getRootFolder tempFileIterator is null ')
      return []
    }
    return getFileByCurIterator(tempFileIterator, true)
  }
}


export default FileAccessExec