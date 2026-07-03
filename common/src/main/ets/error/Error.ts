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
import { ERROR_CODE } from '../const/ErrorCode';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 文件访问错误类
 */
export class FileAccessError implements BusinessError<void> {
  public code: ERROR_CODE.FILE_ACCESS;
  public name: string = 'FileAccessError';
  public message: string;

  /**
   * 生产错误实例
   * @param code 错误码
   * @param message 错误信息
   */
  constructor(code: ERROR_CODE.FILE_ACCESS, message: string) {
    this.code = code;
    this.message = message;
  }
}
