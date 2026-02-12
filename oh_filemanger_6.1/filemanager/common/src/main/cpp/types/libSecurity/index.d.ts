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

export const setDeleteControlFlag: (fd: number) => number;

// 获取文件路径下的子文件，isFilterFile为true，获取子文件，false，获取子文件夹
declare function listSubFile(path: string, isFilterFile: boolean): string[];

// 获取文件路径下的子文件，获取子文件
declare function listSubFile(path: string): string[];

// 查询文件,回调返回FileInfoBasic
export const queryFiles: (folderPath: string, batchCount: number,
  fileQueryCallback: Function) => boolean;

interface FolderInfo {
  fileName: string;
  hasSubFolder: boolean;
}
