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
 * 文件删除还原操作需要使用的数据模型
 */
export class PasteboardDataModel {
  /**
   * 剪切板上文件的uri数组
   */
  fileUriList: string[] = [];

  /**
   *  剪切板上数据的时间戳
   */
  timestamp: number = -1;

  /**
   * 剪切板上数据的来源
   */
  source: string = '';

  /**
   * 剪切板上数据的标签，PC文管用于标记剪切还是复制
   */
  tag: string = '';
}