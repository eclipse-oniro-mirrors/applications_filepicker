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
import { CopyCutConst, CopyCutManager, FileInfo, GlobalHolder, PasteUtil, WorkerConst } from '@ohos/common';
import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { CopyCutSendParam } from '@ohos/common/src/main/ets/workermanager/copycutmanager/CopyCutSendParam'
import { CopyCutResultParam } from '@ohos/common/src/main/ets/workermanager/copycutmanager/CopyCutResultParam'
import { TestUtil } from '../../utils/TestUtil';

export default function PasteUtilTest() {
  describe('PasteUtilTest', () => {

    it('startCopyCutTask', 0, () => {
      let context = GlobalHolder.getInstance().getCommonContext();
      let toPastFiles: FileInfo[] = [];
      let workName = 'startCopyCutTask';
      let copyCutSendParam = new CopyCutSendParam(context,
        WorkerConst.OperateType.COPY_FILE, workName, toPastFiles, '', CopyCutConst.SendMsgCode.START,
        CopyCutConst.ChooseType.DEFAULT, true, '', '');
      PasteUtil.startCopyCutTask(copyCutSendParam, (result: CopyCutResultParam) => {});
      let result: CopyCutManager | undefined = AppStorage.get<CopyCutManager>(workName);
      expect(result === undefined).assertFalse();
    })

    it('sendConflictChooseMessage', 0, () => {
      let copyCutManager = new CopyCutManager();
      let mocker = new MockKit();
      let sendMsgToWorker = TestUtil.getPrivateMockFunction(mocker, copyCutManager, 'sendMsgToWorker')
      when(sendMsgToWorker)(ArgumentMatchers.any).afterReturnNothing();
      let workName = 'sendConflictChooseMessage';
      PasteUtil.sendConflictChooseMessage(workName, CopyCutConst.ChooseType.DEFAULT, true,
        WorkerConst.OperateType.COPY_FILE);
      mocker.verify('sendMsgToWorker',
        [workName, CopyCutConst.ChooseType.DEFAULT, CopyCutConst.SendMsgCode.CONFLICT,
          WorkerConst.OperateType.COPY_FILE, true])
        .never();
      AppStorage.setOrCreate(workName, copyCutManager);
      PasteUtil.sendConflictChooseMessage(workName, CopyCutConst.ChooseType.DEFAULT, true,
        WorkerConst.OperateType.COPY_FILE);
      mocker.verify('sendMsgToWorker',
        [workName, CopyCutConst.ChooseType.DEFAULT, CopyCutConst.SendMsgCode.CONFLICT,
          WorkerConst.OperateType.COPY_FILE, true])
        .once();
      mocker.clear(copyCutManager);
    })

    it('sendMsg', 0, () => {
      let copyCutManager = new CopyCutManager();
      let mocker = new MockKit();
      let sendMsgToWorker = TestUtil.getPrivateMockFunction(mocker, copyCutManager, 'sendMsgToWorker')
      when(sendMsgToWorker)(ArgumentMatchers.any).afterReturnNothing();
      let workName = 'sendMsg';
      PasteUtil.sendMsg(workName, CopyCutConst.SendMsgCode.START, WorkerConst.OperateType.COPY_FILE);
      mocker.verify('sendMsgToWorker',
        [workName, undefined, CopyCutConst.SendMsgCode.START, WorkerConst.OperateType.COPY_FILE, false])
        .never();
      AppStorage.setOrCreate(workName, copyCutManager);
      PasteUtil.sendMsg(workName, CopyCutConst.SendMsgCode.START, WorkerConst.OperateType.COPY_FILE);
      mocker.verify('sendMsgToWorker',
        [workName, undefined, CopyCutConst.SendMsgCode.START, WorkerConst.OperateType.COPY_FILE, false])
        .once();
      mocker.clear(copyCutManager);
    })

    it('PasteUtil_cancelWorker', 0, () => {
      let copyCutManager = new CopyCutManager();
      let mocker = new MockKit();
      let sendMsgToWorker = TestUtil.getPrivateMockFunction(mocker, copyCutManager, 'sendMsgToWorker')
      when(sendMsgToWorker)(ArgumentMatchers.any).afterReturnNothing();
      let workName = 'cancelWorker';
      PasteUtil.cancelWorker(workName, WorkerConst.OperateType.CANCEL);
      mocker.verify('sendMsgToWorker',
        [workName, CopyCutConst.ChooseType.STOP, CopyCutConst.SendMsgCode.CANCEL, WorkerConst.OperateType.CANCEL])
        .never();
      AppStorage.setOrCreate(workName, copyCutManager);
      PasteUtil.cancelWorker(workName, WorkerConst.OperateType.CANCEL);
      mocker.verify('sendMsgToWorker',
        [workName, CopyCutConst.ChooseType.STOP, CopyCutConst.SendMsgCode.CANCEL, WorkerConst.OperateType.CANCEL])
        .once();
      mocker.clear(copyCutManager);
    })

    it('continueToRunWorker', 0, () => {
      let copyCutManager = new CopyCutManager();
      let mocker = new MockKit();
      let sendMsgToWorker = TestUtil.getPrivateMockFunction(mocker, copyCutManager, 'sendMsgToWorker')
      when(sendMsgToWorker)(ArgumentMatchers.any).afterReturnNothing();
      let workName = 'continueToRunWorker';
      PasteUtil.continueToRunWorker(workName, WorkerConst.OperateType.COPY_FILE);
      mocker.verify('sendMsgToWorker',
        [workName, CopyCutConst.ChooseType.CONTINUE_TO_RUN, CopyCutConst.SendMsgCode.EXCEPTION_CONTINUE_TO_RUN,
          WorkerConst.OperateType.COPY_FILE])
        .never();
      AppStorage.setOrCreate(workName, copyCutManager);
      PasteUtil.continueToRunWorker(workName, WorkerConst.OperateType.COPY_FILE);
      mocker.verify('sendMsgToWorker',
        [workName, CopyCutConst.ChooseType.CONTINUE_TO_RUN, CopyCutConst.SendMsgCode.EXCEPTION_CONTINUE_TO_RUN,
          WorkerConst.OperateType.COPY_FILE])
        .once();
      mocker.clear(copyCutManager);
    })
  })
}