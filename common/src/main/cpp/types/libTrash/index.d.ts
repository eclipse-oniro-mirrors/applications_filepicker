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

export interface FileInfo{
  uri: string;
  size: number;
  ctime: number;
  srcPath: string;
  mtime: number;
  fileName: string;
  deleteTime: number;
  mode: number;
}

declare function recoverFile(trashFileUri: string): string;

declare function recoverFileToSpecifiedDir(recoverUri: string, specifiedDir: string): string;

declare function deleteFile(uri: string): string;

declare function deleteToTrash(uri: string): string;

declare function listTrashFile(): Array<FileInfo>;

declare function deleteCompletely(uri: string): void;

declare function processOldRecycleBinFiles(): void;