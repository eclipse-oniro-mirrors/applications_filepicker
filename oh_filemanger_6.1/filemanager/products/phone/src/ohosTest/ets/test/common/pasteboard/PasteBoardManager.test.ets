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
import { FileInfo, PAGE_ROUTE_CONST, PasteboardDataModel, StartModeOptions } from '@ohos/common';
import { PasteFlag } from '@ohos/common/indexDT';
import { PasteBoardManager, PasteBoardUtil } from '@ohos/common'
import { ArgumentMatchers, beforeAll, describe, expect, it, MockKit, when } from '@ohos/hypium';
import TaskPool from '@ohos.taskpool';
import { pasteboard } from '@kit.BasicServicesKit';
import { TestUtil } from '../../utils/TestUtil';

const TAG = 'PasteBoardManagerTest';

export default function PasteBoardManagerTest() {

  beforeAll(async () => {
    PasteBoardUtil.setUriToPasteboard(['test'], PasteFlag.COPY, false);
  })

  describe('PasteBoardManagerTest', () => {
    let mocker: MockKit = new MockKit();

    beforeAll(async () => {
    });

    it('PasteBoardManagerTest_getInstance', 0, async (done: Function) => {
      const instanceTest = PasteBoardManager.getInstance();
      expect(instanceTest instanceof PasteBoardManager).assertTrue();
      done();
    })

    it('checkNeedReadPasteBoard', 0, async (done: Function) => {
      const instance = PasteBoardManager.getInstance();
      const checkResult0 = instance.checkNeedReadPasteBoard();
      expect(checkResult0).assertTrue();
      done();
    })

    it('startSetPasteBoardTask_emptyFileList', 0, async (done: Function) => {
      const instance = PasteBoardManager.getInstance();
      let options: StartModeOptions = new StartModeOptions();
      let result0 = await instance.startSetPasteBoardTask([], options);
      expect(result0).assertEqual(false);
      done();
    });

    it('checkNeedReadPasteBoard_MainEntry', 0, async (done: Function) => {
      const instance = PasteBoardManager.getInstance();
      createPageStack(PAGE_ROUTE_CONST.MAIN_ENTRY);
      const checkResult = instance.checkNeedReadPasteBoard();
      expect(checkResult).assertTrue();
      done();
    })

    it('checkNeedReadPasteBoard_other', 0, async (done: Function) => {
      const instance = PasteBoardManager.getInstance();
      createPageStack('test3');
      const checkResult = instance.checkNeedReadPasteBoard();
      expect(checkResult).assertFalse();
      done();
    })

    it('checkNeedReadPasteBoard_Empty', 0, async (done: Function) => {
      const instance = PasteBoardManager.getInstance();
      createPageStack('');
      const checkResult = instance.checkNeedReadPasteBoard();
      expect(checkResult).assertFalse();
      done();
    })

    it("startReadPasteboardTask_Is_Picker", 0, async (done: Function) => {
      const instance = PasteBoardManager.getInstance();
      instance.setWhetherToReadPasteBoard(true);
      let options: StartModeOptions = new StartModeOptions();
      options.pickerFlag = true;
      let result: PasteboardDataModel = await instance.startReadPasteboardTask(false, options);
      expect(result.timestamp).assertEqual(-1);
      done();
    })

    it("startReadPasteboardTask_No_Read", 0, async (done: Function) => {
      const instance = PasteBoardManager.getInstance();
      instance.setWhetherToReadPasteBoard(true);
      let options: StartModeOptions = new StartModeOptions();

      let checkNeedReadPasteBoard = mocker.mockFunc(instance, instance.checkNeedReadPasteBoard);
      when(checkNeedReadPasteBoard)(ArgumentMatchers.any).afterReturn(false);
      options.pickerFlag = false;
      mocker.clear(instance);
      let result: PasteboardDataModel = await instance.startReadPasteboardTask(false, options);
      expect(result.timestamp).assertEqual(-1);
      done();
    })

    it("startReadPasteboardTask_IsReadPasteBoardExecuting", 0, async (done: Function) => {
      const instance = PasteBoardManager.getInstance();
      instance.setWhetherToReadPasteBoard(true);
      let options: StartModeOptions = new StartModeOptions();
      options.pickerFlag = false;
      let checkNeedReadPasteBoard = mocker.mockFunc(instance, instance.checkNeedReadPasteBoard);
      when(checkNeedReadPasteBoard)(ArgumentMatchers.any).afterReturn(true);

      TestUtil.setPrivateAttribute(instance, 'isReadPasteBoardExecuting', true);
      mocker.clear(instance);
      let result: PasteboardDataModel = await instance.startReadPasteboardTask(false, options);
      expect(result.timestamp).assertEqual(-1);
      done();
    })

    it("startReadPasteboardTask_TemPasteboardData_Is_Null", 0, async (done: Function) => {
      const instance = PasteBoardManager.getInstance();
      instance.setWhetherToReadPasteBoard(true);
      let options: StartModeOptions = new StartModeOptions();
      options.pickerFlag = false;
      let checkNeedReadPasteBoard = mocker.mockFunc(instance, instance.checkNeedReadPasteBoard);
      when(checkNeedReadPasteBoard)(ArgumentMatchers.any).afterReturn(true);

      TestUtil.setPrivateAttribute(instance, 'isReadPasteBoardExecuting', false);
      mocker.clear(instance);

      let result: PasteboardDataModel = await instance.startReadPasteboardTask(false, options);
      expect(result.timestamp).assertEqual(-1);
      done();
    })

    it('startSetPasteBoardTask_notEmptyFileList', 0, async (done: Function) => {
      const instance = PasteBoardManager.getInstance();
      let options: StartModeOptions = new StartModeOptions();
      let result0 = await instance.startSetPasteBoardTask([new FileInfo()], options);
      expect(result0).assertEqual(true);
      done();
    });

    it("startReadPasteboardTask", 0, async (done: Function) => {
      const instance = PasteBoardManager.getInstance();
      instance.setWhetherToReadPasteBoard(false);
      let options: StartModeOptions = new StartModeOptions();
      options.pickerFlag = true;
      let result1: PasteboardDataModel = await instance.startReadPasteboardTask(false, options);
      expect(result1.timestamp).assertEqual(-1);
      done();
    })
  })
}


function createPageStack(pathName: string): void {
  const pathStack = new NavPathStack();
  pathStack.pushPath(new NavPathInfo(pathName, null));
  AppStorage.setOrCreate<NavPathStack>('pageStack', pathStack);
  return;
}