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

import { fileTree } from './component/dialog/FileMoveDialog'
import FileAccessExec from '../base/utils/FileAccessExec'
import Logger from '../base/log/Logger'
import ErrorCodeConst from '../base//constants/ErrorCodeConst'
import { toast, setSystemBar, setImmersion } from '../base/utils/Common'
import AbilityCommonUtil from '../base/utils/AbilityCommonUtil'
import { SYSTEM_BAR_COLOR } from '../base/constants/UiConstant'

const TAG = 'PathSelector'

@Entry
@Component
struct PathSelector {

  aboutToAppear(){
    setImmersion(false)
    setSystemBar(SYSTEM_BAR_COLOR.WHITE, SYSTEM_BAR_COLOR.WHITE, SYSTEM_BAR_COLOR.BLACK, SYSTEM_BAR_COLOR.BLACK)
  }

  async saveFileCallback(res): Promise<void> {
    if (res?.cancel) {
      globalThis.pathAbilityContext.terminateSelf()
      return
    } else {
      let fileNameList = globalThis.keyPickFileName
      // 保存单个文件时文件名可修改，需使用修改后的文件名来创建文件
      if (fileNameList.length <= 1) {
        fileNameList = [res.fileName]
      }
      this.createFile(res.selectUri, fileNameList).then((createdFileList) => {
        AbilityCommonUtil.terminatePathPicker(createdFileList)
      }).catch((err) => {
        let errorMessage = ''
        let errorCode = 0
        if (err.code) {
          if (err.code === ErrorCodeConst.FILE_ACCESS.FILE_NAME_EXIST) {
            errorMessage = 'Same name file already exists'
            errorCode = ErrorCodeConst.PICKER.FILE_NAME_EXIST
          } else if (err.code === ErrorCodeConst.FILE_ACCESS.FILE_NAME_INVALID) {
            errorMessage = 'Invalid display name'
            errorCode = ErrorCodeConst.PICKER.FILE_NAME_INVALID
          } else {
            errorMessage = 'File create failed'
            errorCode = ErrorCodeConst.PICKER.OTHER_ERROR
          }
        } else {
          errorMessage = err.message ? err.message : err
          errorCode = ErrorCodeConst.PICKER.OTHER_ERROR
        }
        AbilityCommonUtil.terminatePathPicker([], errorCode, errorMessage)
        toast($r('app.string.save_file_fail'))
        Logger.e(TAG, `path select error, errorCode: ${errorCode}, errorMessage: ${errorMessage}`)
      })
    }
  }

  async createFile(folderUri: string, fileNameList: Array<string>): Promise<Array<string>> {
    let createdFileUriList = []
    return new Promise(async (resolve, reject) => {
      let resolveFileName = ''
      try {
        for (let i = 0; i < fileNameList.length; i++) {
          resolveFileName = fileNameList[i]
          const newFileUri = await FileAccessExec.createFile(folderUri, resolveFileName)
          createdFileUriList.push(newFileUri)
        }
        resolve(createdFileUriList)
      } catch (err) {
        reject(err)
        Logger.e(TAG, `createFile error, fileName: ${resolveFileName}, massage: ${err.message ? err.message : err}`)
      }
    })
  }

  build() {
    Row() {
      fileTree({
        moveCallback: (e) => {
          this.saveFileCallback(e)
        }
      })
    }
  }
}
