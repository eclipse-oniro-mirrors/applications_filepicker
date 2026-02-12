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

import { HiLog, StartModeOptions, } from '@ohos/common';
import { UnityStartMode } from '@ohos/common/index';
import { SelectMode, WindowType } from '@ohos/common/indexDT';
import { afterAll, beforeAll, describe, expect, it } from '@ohos/hypium';

const TAG = 'StartModeOptionsTest';

export default function StartModeOptionsTest() {

  describe('StartModeOptionsTest', () => {
    beforeAll(() => {
        HiLog.info(TAG, 'StartModeOptionsTest beforeAll');
    })

    afterAll(() => {
        HiLog.info(TAG, 'StartModeOptionsTest afterAll');
    })

    it('getFileSuffixFilterList_empty', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      let list: string[] = options.getFileSuffixFilterList();
      expect(list.length).assertEqual(1);
    })

    it('getFileSuffixFilterList_length_one', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      let list: string[] = [];
      options.fileSuffixFilters = ['txt'];
      list = options.getFileSuffixFilterList();
      expect(list.length).assertEqual(1);
    })

    it('getFileSuffixFilterList_length_two', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      let list: string[] = [];
      options.fileSuffixFilters = ['txt', 'docx'];
      list = options.getFileSuffixFilterList();
      expect(list.length).assertEqual(2);
    })

    it('initStartMode_FILE_PICKER_CREATE', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.action = 'ohos.want.action.CREATE_FILE_SERVICE';
      options.initStartMode();
      expect(options.startMode === UnityStartMode.FILE_PICKER_CREATE).assertTrue();
    })

    it('initStartMode_GRANT_PERMISSION', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.action = '';
      options.isAuthMode = true;
      options.initStartMode();
      expect(options.startMode === UnityStartMode.GRANT_PERMISSION).assertTrue();
    })

    it('initStartMode_FILE_PICKER_OPEN_FILE', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.isAuthMode = false;
      options.action = 'ohos.want.action.OPEN_FILE_SERVICE';
      options.selectMode = SelectMode.FILE;
      options.initStartMode();
      expect(options.startMode === UnityStartMode.FILE_PICKER_OPEN_FILE).assertTrue();
    })

    it('initStartMode_FILE_PICKER_OPEN_FOLDER', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.isAuthMode = false;
      options.action = 'ohos.want.action.OPEN_FILE_SERVICE';
      options.selectMode = SelectMode.FOLDER;
      options.initStartMode();
      expect(options.startMode === UnityStartMode.FILE_PICKER_OPEN_FOLDER).assertTrue();
    })

    it('initStartMode_FILE_PICKER_OPEN_MIXED', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.isAuthMode = false;
      options.action = 'ohos.want.action.OPEN_FILE_SERVICE';
      options.selectMode = SelectMode.MIXED;
      options.initStartMode();
      expect(options.startMode === UnityStartMode.FILE_PICKER_OPEN_MIXED).assertTrue();
    })

    it('initStartMode_invalid', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.isAuthMode = false;
      options.action = 'ohos.want.action.OPEN_FILE_SERVICE';
      options.selectMode = 3;
      options.initStartMode();
      expect(options.startMode === UnityStartMode.FILE_PICKER_CREATE).assertTrue();
    })

    it('setSelectMode_undefined', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.setSelectMode(undefined)
      expect(options.selectMode === SelectMode.FILE).assertTrue();
    })

    it('setSelectMode_invalid_less', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.setSelectMode(-1)
      expect(options.selectMode === SelectMode.FILE).assertTrue();
    })

    it('setSelectMode_file', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.setSelectMode(0)
      expect(options.selectMode === SelectMode.FILE).assertTrue();
    })

    it('setSelectMode_folder', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.setSelectMode(1)
      expect(options.selectMode === SelectMode.FOLDER).assertTrue();
    })

    it('setSelectMode_mixed', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.setSelectMode(2)
      expect(options.selectMode === SelectMode.MIXED).assertTrue();
    })

    it('setSelectMode_invalid_large', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.setSelectMode(3)
      expect(options.selectMode === SelectMode.FILE).assertTrue();
    })

    it('setNewFileNames_undefined', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.setNewFileNames(undefined)
      expect(options.newFileNames.length).assertEqual(1);
    })

    it('setNewFileNames_emptyArray', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.setNewFileNames([])
      expect(options.newFileNames.length).assertEqual(1);
    })

    it('setNewFileNames_array', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.setNewFileNames(['1.txt', '2.docx'])
      expect(options.newFileNames.length).assertEqual(2);
    })

    it('isDownloadMode', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.pickerType = 'select'
      expect(options.isDownloadMode()).assertFalse();
    })

    it('isFilePickerMode', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      expect(options.isFilePickerMode()).assertFalse();
    })

    it('isGrantPermissionMode', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      expect(options.isGrantPermissionMode()).assertFalse();
    })

    it('isOpenFileMode_openFileService', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.action = 'ohos.want.action.OPEN_FILE_SERVICE';
      expect(options.isOpenFileMode()).assertTrue();
    })

    it('isOpenFileMode_openFile', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.action = 'ohos.want.action.OPEN_FILE';
      expect(options.isOpenFileMode()).assertTrue();
    })

    it('isOpenFileMode_pickerType', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.pickerType = 'select';
      expect(options.isOpenFileMode()).assertTrue();
    })

    it('isCreateFileMode_createFileService', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.action = 'ohos.want.action.CREATE_FILE_SERVICE';
      expect(options.isCreateFileMode()).assertTrue();
    })

    it('isCreateFileMode_createFile', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.action = 'ohos.want.action.CREATE_FILE';
      expect(options.isCreateFileMode()).assertTrue();
    })

    it('isCreateFileMode_pickerType', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.pickerType = 'save';
      expect(options.isCreateFileMode()).assertTrue();
    })

    it('isValidOpenOptions_action', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.action = 'ohos.want.action.CREATE_FILE_SERVICE';
      expect(options.isValidOpenOptions()).assertFalse();
    })

    it('isValidOpenOptions_authMode', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.action = 'ohos.want.action.OPEN_FILE_SERVICE';
      options.isAuthMode = true;
      options.defaultFilePathUri = '';
      expect(options.isValidOpenOptions()).assertFalse();
    })

    it('isValidOpenOptions_fileSuffixFilters_empty', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.action = 'ohos.want.action.OPEN_FILE_SERVICE';
      options.isAuthMode = false;
      options.maxSelectNumber = 0;
      options.fileSuffixFilters = [];
      expect(options.isValidOpenOptions()).assertFalse();
    })

    it('isValidOpenOptions_fileSuffixFilters', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.action = 'ohos.want.action.OPEN_FILE_SERVICE';
      options.isAuthMode = false;
      let str: string[] = [];
      for (let i = 0; i < 101; i++) {
        str.push('.txt');
      }
      options.fileSuffixFilters = str;
      expect(options.isValidOpenOptions()).assertFalse();
    })

    it('isValidOpenOptions_maxSelectNum_invalid', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.action = 'ohos.want.action.OPEN_FILE_SERVICE';
      options.isAuthMode = false;
      let str: string[] = [];
      for (let i = 0; i < 101; i++) {
        str.push('.txt');
      }
      options.fileSuffixFilters = str;
      options.maxSelectNumber = 501;
      expect(options.isValidOpenOptions()).assertFalse();
    })

    it('isValidOpenOptions_maxSelectNum_valid', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.action = 'ohos.want.action.OPEN_FILE_SERVICE';
      options.isAuthMode = false;
      options.fileSuffixFilters = [];
      options.maxSelectNumber = 100;
      expect(options.isValidOpenOptions()).assertTrue();
    })

    it('isValidSaveOptions_action', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.action = 'ohos.want.action.OPEN_FILE_SERVICE';
      expect(options.isValidSaveOptions()).assertFalse();
    })

    it('isValidSaveOptions_fileSuffixChoices_empty', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.action = 'ohos.want.action.CREATE_FILE_SERVICE';
      options.fileSuffixChoices = [];
      expect(options.isValidSaveOptions()).assertTrue();
    })

    it('isValidSaveOptions_fileSuffixChoices', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.action = 'ohos.want.action.CREATE_FILE_SERVICE';
      let str: string[] = [];
      for (let i = 0; i < 101; i++) {
        str.push('.txt');
      }
      options.fileSuffixChoices = str;
      expect(options.isValidSaveOptions()).assertFalse();
    })

    it('isValidOptions_openFileService', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.action = 'ohos.want.action.OPEN_FILE_SERVICE';
      expect(options.isValidOptions()).assertTrue();
    })

    it('isValidOptions_createFileService', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.action = 'ohos.want.action.CREATE_FILE_SERVICE';
      expect(options.isValidOptions()).assertTrue();
    })

    it('isUxt', 0, () => {
      let options: StartModeOptions = new StartModeOptions();
      options.windowType = WindowType.UI;
      expect(options.isUxt()).assertTrue();
    })
  })
}
