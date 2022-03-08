/*
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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

import { media_type } from './Constants.ets'

export class FileInfo {
  name: string
  path: string
  type: number= media_type.MEDIA_TYPE_ALBUM
  size: string
  dataAdded_time: string
  modified_time: string
  mediaType: string
  thumbnail: Resource
  font_color: Color | string | Resource
  opacity: number
  list_background: string | Resource

  constructor(name: string) {
    this.name = name
  }
}

export class TopPathInfo {
  name: string
  path: string
  opacity: number = 1

  constructor(name: string, path: string) {
    this.name = name
    this.path = path
  }
}