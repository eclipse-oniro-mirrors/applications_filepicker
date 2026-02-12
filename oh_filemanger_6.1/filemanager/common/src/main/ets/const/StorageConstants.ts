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
/*
 * LocalStorage Key
 * */
export class LocalStorageConstants {
  static readonly NO_SPACE_LEFT: string = 'isNoSpaceLeft';
  static readonly IS_BUILD_NEW_FOLDER_FAILED: string = 'isShowBuildNewFolderFailed';
  static readonly REFRESH_LOCAL_DATA_AND_UI: string = 'refreshLocalDataAndUI';
  // FilePicker
  static readonly PICKER_INPUT_FILE_NAME: string = 'pickerInputFileName';
  static readonly PICKER_SELECTED_FILE_TYPE: string = 'selectedFileType';
  static readonly AUTO_REFRESH_DATA_AND_UI: string = 'autoRefreshDataAndUI';
}

/*
 * AppStorage Key
 * */
export class AppStorageConstants {
  static readonly DEVICE_TYPE: string = 'deviceType';
  static readonly REFRESH_APP_DATA_AND_UI: string = 'refreshAppDataAndUI';
}