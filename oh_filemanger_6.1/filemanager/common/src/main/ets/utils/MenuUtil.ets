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
// import lazy { ringtone } from '../../../../indexLazyLoadTs';
import { UEUtil } from '../dfx/UEUtil';
import { DFX } from '../dfx/const/DFXConst';
import { FileInfo } from '../fileoperate/FileInfo';
import { BottomCallParams } from '../fileoperate/FileOperation';
import { MimeType } from '../model/MimeType';
import { FileSourceType } from '../const/Constant';
import { FileUtil } from '../fileoperate/FileUtil';
import { DeviceConfig } from '../data/DeviceConfig';

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
  public static setRingtone(fileInfo: FileInfo,
    backCallback: () => void): void {
    const context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
    // ringtone.startRingtoneSetting(context, fileInfo.relativePath, fileInfo.fileName, (err, data) => {
    //   backCallback();
    //   HiLog.info(TAG, 'setFlag : ' + JSON.stringify(data) + ' , ' +
    //   JSON.stringify(err === undefined ? 'Set the ringtone successfully.' : 'Failed to set the ringhtone, ' + err));
    //   UEUtil.reportSetRingtone(err === undefined, data);
    // });
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