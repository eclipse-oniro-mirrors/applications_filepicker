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

export enum menuLevel {
  MENU_FIRST_LEVEL_BY_TYPE = 1,
  MENU_SECOND_LEVEL_BY_FOLD = 2,
  MENU_THIRD_LEVEL_HAS_PIC = 3,
  MENU_THIRD_LEVEL_HAS_DETAIL = 4,
}

export enum mediaType {
  MEDIA_TYPE_FILE = 1,
  MEDIA_TYPE_IMAGE = 3,
  MEDIA_TYPE_VIDEO = 4,
  MEDIA_TYPE_AUDIO = 5,
  MEDIA_TYPE_ALBUM = 8
}

export enum terminateReason {
  SUCCESS = 0,
  NO_ACTION = -1,
}