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

import FileMimeTypeUtil from './FileMimeTypeUtil';
import type { FileInfo } from '../fileoperate/FileInfo';

export class FileDataUtil {
  public static setFileName(fileData: FileInfo, fileName: string): void {
    if (!fileData) {
      return;
    }
    if (fileData.isFolder) {
      fileData.fileName = fileName;
      return;
    }
    const oldFileName = fileData.fileName;
    fileData.fileName = fileName;
    const oldFileSuffix = FileMimeTypeUtil.getFileSuffix(oldFileName);
    const newFileSuffix = FileMimeTypeUtil.getFileSuffix(fileName);
    if (oldFileSuffix === newFileSuffix) {
      return;
    }
    fileData.mimeTypeObj = FileMimeTypeUtil.getMimeType(fileName, fileData.isFolder);
    if (FileMimeTypeUtil.isImage(fileData.mimeTypeObj)) {
      fileData.thumbUri = fileData.uri;
    } else {
      fileData.thumbUri = '';
    }
  }
}