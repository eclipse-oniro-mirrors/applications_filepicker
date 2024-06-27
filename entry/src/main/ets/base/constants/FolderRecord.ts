/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
 * uri of the virtual directory
 */
export enum VirtualUri {
  // Quick Access
  RECENT = 'recent',
  DESKTOP = 'file://docs/storage/Users/currentUser/Desktop',
  DOWNLOAD = 'file://docs/storage/Users/currentUser/Download',
  RECYCLE_BIN = 'recycleBin',
  // Storage Location
  MY_PC = 'file://docs/storage/Users/currentUser',
  DOCUMENT = 'file://docs/storage/Users/currentUser/Documents',
  CLOUD_DRIVE = 'file://com.huawei.hmos.filemanager/data/storage/el2/cloud',
  SAFE_BOX_URI = 'file://com.huawei.hmos.filemanager/data/storage/el2/base/files/File_SafeBox',
  EXTERNAL_DISK = 'file://docs/storage/External',
  PCENGINE = 'file://docs/storage/Users/currentUser/PCEngine',
  // gallery
  GALLERY = 'gallery',
  // fileTag
  FILE_TAG = 'fileTag',
  // SafeBox
  SAFE_BOX = 'file://com.huawei.hmos.filemanager/data/storage/el2/base/files/File_SafeBox'
}
