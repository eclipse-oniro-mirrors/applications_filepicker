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

export enum PreferenceMode {
  FOLDER = 'FolderPreference',
  FILE_PICKER = 'FilePickerFolderPreference'
}

export enum UnityStartMode {
  NORMAL,
  FILE_PICKER_OPEN_FILE,
  FILE_PICKER_OPEN_FOLDER,
  FILE_PICKER_OPEN_MIXED,
  FILE_PICKER_CREATE,
  DESKTOP_FILE_START,
  GRANT_PERMISSION
}

export enum SelectMode {
  FILE,
  FOLDER,
  MIXED
}

export enum WindowType {
  ABILITY = 'Ability',
  SERVICE = 'ServiceExtensionAbility',
  UI = 'UIExtensionAbility'
}