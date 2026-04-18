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

export interface ResultErrorParams {
  code: number;
  message: string;
}

/**
 * 保存文件返回类型
 */
export class SaveFilesResult {
  /**
   * 文件系统异常
   */
  err: ResultErrorParams;

  /**
   * data
   */
  dataArr: string[];

  constructor(dataArr: string[], err?: ResultErrorParams) {
    this.dataArr = dataArr;
    this.err = err;
  }
}

/**
 * 检查新建文件名是否与文件夹重名的返回结果
 */
export class CheckFileDupWithFolderResult {
  /**
   * 文件系统异常
   */
  err: ResultErrorParams | undefined;

  /**
   * 该uri对应的文件是否存在
   */
  isExist : boolean;

  /**
   * 该uri对应的重复文件是否是文件夹
   */
  isDupWithFolder : boolean;

  constructor(isExist: boolean, isDupWithFolder: boolean, err?: ResultErrorParams) {
    this.isExist = isExist;
    this.isDupWithFolder = isDupWithFolder;
    this.err = err;
  }
}