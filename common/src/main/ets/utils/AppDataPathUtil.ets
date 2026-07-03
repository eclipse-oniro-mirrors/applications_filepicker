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
import { FileUtil } from '../fileoperate/FileUtil';
import { BundleResourceUtil } from './BundleResourceUtil';
import { ObjectUtil } from './ObjectUtil';

const APPDATA_PATH = 'file://docs/storage/Users/currentUser/appdata';
const URI_LOCAL_START = 'file://docs/';
const URI_MEDIA_START = 'file://media/';
const TAG = 'AppDataPathUtil';

export class AppDataPathUtil {

  /**
   * 判断路径是否可写
   * @param uri 当前文件uri, isDevelopMode 是否为开发者模式
   */
  public static isPathWritable(uri: string, isDevelopMode: boolean): boolean {
    // 沙箱路径场景
    if (uri.includes(APPDATA_PATH) && (!isDevelopMode)) {
      return false;
    } else {
      return true;
    }
  }

}