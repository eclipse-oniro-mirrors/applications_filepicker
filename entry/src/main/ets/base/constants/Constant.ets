/*
 * Copyright (c) 2021-2023 Huawei Device Co., Ltd.
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

export const MILLISECOND = {
  ONE_MILLISECOND: 1,
  ONE_SECOND: 1000,
  ONE_MINUTE: 60 * 1000,
  ONE_HOUR: 60 * 60 * 1000,
  ONE_DAY: 24 * 60 * 60 * 1000,
  ONE_MONTH: 30 * 24 * 60 * 60 * 1000
}

export const BYTE = {
  ONE_KB: 1024,
  ONE_MB: 1024 * 1024,
  ONE_GB: 1024 * 1024 * 1024,
  ONE_TB: 1024 * 1024 * 1024 * 1024
}

export const FILENAME_REGEXP = /^[^\\/:*?<>\"|]+$/

export const FILENAME_MAX_LENGTH = 250

export const DOCUMENTS_FOLDER = 'Documents'
