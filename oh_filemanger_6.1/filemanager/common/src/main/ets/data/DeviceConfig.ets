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
import { CommonUtil } from '../utils/CommonUtil';
import { deviceInfo } from '@kit.BasicServicesKit';
import { Constant } from '../const/Constant';

// 设备类型
export enum DeviceType {
  UNKNOWN = 0,
  PHONE,
  TABLET,
}

export interface Config {
  myDevice: Resource; // 我的设备资源
  dragTip: Resource; // 拖拽提示
  galleryChangeSuffixTip: Resource; // 图库改变后缀提示
  restoreToTip: Resource; // 已还原至提示
  deviceIcon: Resource; // 设备图标
  gridColumnsTemplate: string; // 宫格视图固定填充尺寸
  helpAndSupportAppId: string; // 是否应用展示MiniPad的帮助与客服
  isPortraitNavStack: boolean; // 是否竖屏单栏
  soundName: string; // 录音机路径名 phone: Sounds pad: Music/SoundRecorder
  musicRootName: string; // 跟录音标注music路径
}

const TAG = 'DeviceConfig'

export class DeviceConfig {
  private static instance: DeviceConfig;
  private configMap: Map<DeviceType, Config> = new Map<DeviceType, Config>([
    [DeviceType.PHONE, {
      myDevice: $r('app.string.myPhone'),
      dragTip: $r('app.string.not_support_drag_in_page'),
      galleryChangeSuffixTip: $r('app.string.gallery_change_suffix'),
      restoreToTip: $r('app.string.restore_to_backup_recover_phone'),
      deviceIcon: $r('app.media.ic_myphone'),
      gridColumnsTemplate: 'repeat(auto-fit, 120)',
      helpAndSupportAppId: CommonUtil.phoneAppId,
      isPortraitNavStack: false,
      soundName: Constant.FOLDER_SOUNDS,
      musicRootName: Constant.PHONE_ROOT_MUSIC
    }],
    [DeviceType.TABLET, {
      myDevice: $r('app.string.my_pad'),
      dragTip: $r('app.string.not_support_drag_in_page_with_pad'),
      galleryChangeSuffixTip: $r('app.string.gallery_change_suffix_with_pad'),
      restoreToTip: $r('app.string.restore_to_backup_recover_pad'),
      deviceIcon: $r('app.media.ic_mypad'),
      gridColumnsTemplate: 'repeat(auto-fit, 115)',
      helpAndSupportAppId: CommonUtil.miniPadAppId,
      isPortraitNavStack: true,
      soundName: Constant.PAD_FOLDER_SOUNDS,
      musicRootName: Constant.PAD_ROOT_MUSIC
    }]
  ]);

  private constructor() {
  }

  static getInstance(): DeviceConfig {
    if (!DeviceConfig.instance) {
      DeviceConfig.instance = new DeviceConfig();
    }
    return DeviceConfig.instance;
  }

  private _deviceType: DeviceType = DeviceType.UNKNOWN;
  private _config: Config | null = null;

  public get config(): Config {
    if (this._config) {
      return this._config;
    }
    if (this._deviceType === DeviceType.UNKNOWN) {
      this._deviceType = this.devTypeStr2Enum(deviceInfo.deviceType);
    }
    if (this.configMap.has(this._deviceType)) {
      this._config = this.configMap.get(this._deviceType) as Config;
    } else {
      HiLog.error(TAG, `deviceType ${this._deviceType} not config!! use phone config`);
      this._config = this.configMap.get(DeviceType.PHONE) as Config;
    }
    return this._config;
  }

  private devTypeStr2Enum(str: string): DeviceType {
    if (str === 'phone') {
      return DeviceType.PHONE;
    } else if (str === 'tablet') {
      return DeviceType.TABLET;
    }
    return DeviceType.UNKNOWN;
  }
}