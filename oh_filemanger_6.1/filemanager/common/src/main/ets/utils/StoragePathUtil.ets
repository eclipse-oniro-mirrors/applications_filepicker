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

/**
 * 右键详情中的位置工具类
 */
const TAG = 'StoragePathUtil';
export class StoragePathUtil {
  private static rootInfoMap: Map<string, string> = new Map<string, string>([
    ['LOCAL', '/storage/Users/currentUser'],
    ['EXTERNAL_DISK', '/storage/External']
  ]);

  /**
   * 通过相对路径获取存储位置
   * @param relativePath 相对路径
   * @returns 存储位置
   */
  public static getDiskNameByRelativePath(relativePath: string): string {
    if (!relativePath) {
      return '';
    }
    for (const entry of StoragePathUtil.rootInfoMap) {
      const key = entry[0];
      const value = entry[1];
      if (relativePath.includes(value)) {
        return key;
      }
    }
    return '';
  }

  public static getRelativeSubPath(relativePath: string): string {
    const deviceId: string = StoragePathUtil.getDiskNameByRelativePath(relativePath);
    const rootRelativePath: string | undefined = StoragePathUtil.rootInfoMap.get(deviceId) as string;
    if (rootRelativePath === undefined) {
      return '';
    }
    let subPath: string = relativePath.substring(rootRelativePath.length + 1);
    return subPath;
  }
}