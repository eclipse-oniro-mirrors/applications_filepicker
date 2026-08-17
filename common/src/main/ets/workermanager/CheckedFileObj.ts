/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
 * 用来刷新操作后的选中文件而构建的对象
 */
export class CheckedFileObj {
  /**
   * 目标文件夹uri
   */
  destFolderUri: string;

  /**
   * 粘贴成功的文件(pc专用)
   */
  pasteSuccessFiles: string[];

  constructor(destFolderUri: string, pasteSuccessFiles: string[]) {
    this.destFolderUri = destFolderUri;
    this.pasteSuccessFiles = pasteSuccessFiles;
  }
}