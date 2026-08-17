/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
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
import { HiLog } from '../dfx/HiLog';
import { common } from '@kit.AbilityKit';
import { UEUtil } from '../dfx/UEUtil';
import { DFX } from '../dfx/const/DFXConst';
import { FileInfo } from '../fileoperate/FileInfo';
import { BottomCallParams } from '../fileoperate/FileOperation';
import { MimeType } from '../model/MimeType';
import { FileSourceType } from '../const/Constant';
import { FileUtil } from '../fileoperate/FileUtil';
import { DeviceConfig } from '../data/DeviceConfig';
import { systemSoundManager } from '@kit.AudioKit';
import { toast } from './Tools';
import fs from '@ohos.file.fs'

const TAG = 'MenuUtil';

/**
 * 菜单工具类
 */
export class MenuUtil {
  /**
   * 弹出设置铃声弹窗
   * @param fileInfo 文件信息
   * @param backCallback 回调函数
   */

  public static setRingtone(fileInfo: FileInfo, backCallback: () => void): void {
    HiLog.info(TAG, `setRingtone ${JSON.stringify(fileInfo)}`)
    const context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
    HiLog.info(TAG, `文件路径: ${fileInfo.uri}`)
    const systemSoundManagerInstance: systemSoundManager.SystemSoundManager =
      systemSoundManager.getSystemSoundManager();
    const type: systemSoundManager.RingtoneType = systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0
    const toneAttrs = systemSoundManager.createCustomizedToneAttrs()
    toneAttrs.setTitle(fileInfo.fileName)
    toneAttrs.setFileName(fileInfo.fileName)
    toneAttrs.setCategory(systemSoundManager.TONE_CATEGORY_RINGTONE)

    const file = fs.openSync(fileInfo.uri, fs.OpenMode.READ_ONLY)
    const fd = file.fd; // 获取文件描述符
    HiLog.info(TAG, `文件描述符: ${fd}`)
    try {
      systemSoundManagerInstance.addCustomizedTone(context, toneAttrs, fd, 0).then((value: string) => {
        HiLog.info(TAG, `Succeeded in doing addCustomizedTone. value=${value}`);
        systemSoundManagerInstance.setRingtoneUri(context, value, type).then(() => {
          HiLog.info(TAG, 'Succeeded in doing setRingtoneUri')
          toast('铃声设置成功')
          fs.closeSync(file)
        }).catch((err: BusinessError) => {
          HiLog.error(TAG, `Failed to setRingtoneUri. Code: ${err.code}, message: ${err.message}`);
          fs.closeSync(file)
        })
      }).catch((err: BusinessError) => {
        HiLog.error(TAG, `Failed to addCustomizedTone. Code: ${err.code}, message: ${err.message}`);
        fs.closeSync(file)
      })
    } catch (error) {
      HiLog.error(TAG, `setRingtone error ${JSON.stringify(error)}`)
      fs.closeSync(file)
    }
  }

  /**
   * 判断是否需要显示设置为壁纸的按钮
   * @param fileInfo
   * @returns
   */
  public static canSetAsWallpaper(fileInfo: FileInfo): boolean {
    return fileInfo.mimeTypeObj.fileCategory === MimeType.FILE_CATEGORY_IMAGE;
  }
}