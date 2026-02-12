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

export namespace CompatibleConst {
  /**
   * 壳应用兼容版本号
   */
  export const SHELL_APP_COMPATIBLE_VER = 'HmFiles.shellAppCompatibleVer';

  /**
   * 是否同意隐私声明
   */
  export const HAS_AGREE_PRIVACY = 'HmFiles.privacy.has_agree_privacy';

  /**
   * 同意隐私时间戳
   */
  export const AGREE_TIME_STAMP = 'HmFiles.privacy.agreeTimeStamp';

  /**
   * 同意时间
   */
  export const AGREE_FORMAT_TIME = 'HmFiles.privacy.agreeFormatTime';

  /**
   * 隐私版本
   */
  export const PRIVACY_VERSION = 'HmFiles.privacy.privacyVersion';

  /**
   * 同意隐私的APP版本
   */
  export const APP_VERSION = 'HmFiles.privacy.appVersion';

  /**
   * 是否查看过app引导页
   */
  export const APP_GUIDANCE_PASS = 'HmFiles.guidance.isPass';

  /**
   * 同意的APP引导页版本
   */
  export const APP_GUIDANCE_VERSION = 'HmFiles.guidance.version';
}

/**
 * 壳应用的兼容性版本号
 */
export enum ShellAppCompatibleVersion {
  DEFAULT_VER = 0,
  VERSION_ONE = 1, // 去掉APP引导页，隐私页，迁移至HmFilemanager
}