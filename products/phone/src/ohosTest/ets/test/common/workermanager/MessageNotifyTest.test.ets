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
import { HiLog, ProgressInfo, WorkerConst } from "@ohos/common";
import { PasteResult } from "@ohos/common/src/main/ets/workermanager/copycutmanager/PasteResult";
import { MessageNotify } from "@ohos/common/src/main/ets/workermanager/MessageNotify";
import { ArgumentMatchers, describe, expect, it, MockKit, when } from "@ohos/hypium";
import { TestUtil } from "../../../test/utils/TestUtil";
import { ProgressBarInfo } from "@ohos/common/src/main/ets/workermanager/ProgressBarInfo";

export default function MessageNotifyTest() {
  describe('MessageNotifyTest', () => {

    it('updateProgress_AppStorageHasNoProgressInfos', 0, () => {
      let progressInfo: ProgressInfo =
        new ProgressInfo('worker1', "", new ProgressBarInfo(WorkerConst.OperateType.CANCEL, 1), true);
      AppStorage.clear();
      MessageNotify.updateProgress(progressInfo);
      const progressInfos: ProgressInfo[] | undefined = AppStorage.get('progressInfos')
      expect(progressInfos?.pop()).assertDeepEquals(progressInfo);
    });

    it('updateProgress_isShowTipNotSame', 0, () => {
      AppStorage.clear();
      let progressInfo: ProgressInfo =
        new ProgressInfo('worker1', "", new ProgressBarInfo(WorkerConst.OperateType.CANCEL, 1), true);
      let progressInfo1: ProgressInfo =
        new ProgressInfo('worker2', "", new ProgressBarInfo(WorkerConst.OperateType.CANCEL, 1), false);
      let progressInfo2: ProgressInfo =
        new ProgressInfo('worker1', "", new ProgressBarInfo(WorkerConst.OperateType.CANCEL, 1), false);
      AppStorage.setOrCreate<ProgressInfo[]>('progressInfos', [progressInfo2, progressInfo1]);
      MessageNotify.updateProgress(progressInfo);
      expect(AppStorage.get('progressNewTipIndex')).assertEqual(0);
    });

    it('updateProgress_isShowTipSame', 0, () => {
      AppStorage.clear();
      let progressInfo: ProgressInfo =
        new ProgressInfo('worker1', "", new ProgressBarInfo(WorkerConst.OperateType.COPY_FILE, 3), true);
      let progressInfo1: ProgressInfo =
        new ProgressInfo('worker2', "", new ProgressBarInfo(WorkerConst.OperateType.CANCEL, 1), false);
      let progressInfo2: ProgressInfo =
        new ProgressInfo('worker1', "", new ProgressBarInfo(WorkerConst.OperateType.CANCEL, 1), true);
      AppStorage.setOrCreate<ProgressInfo[]>('progressInfos', [progressInfo2, progressInfo1]);
      MessageNotify.updateProgress(progressInfo);
      expect(AppStorage.get('progressInfos')).assertDeepEquals([progressInfo, progressInfo1]);
    });

    it('updateProgress_addNew', 0, () => {
      AppStorage.clear();
      let progressInfo: ProgressInfo =
        new ProgressInfo('worker3', "", new ProgressBarInfo(WorkerConst.OperateType.CANCEL, 1), true);
      let progressInfo1: ProgressInfo =
        new ProgressInfo('worker2', "", new ProgressBarInfo(WorkerConst.OperateType.CANCEL, 1), false);
      let progressInfo2: ProgressInfo =
        new ProgressInfo('worker1', "", new ProgressBarInfo(WorkerConst.OperateType.CANCEL, 1), true);
      AppStorage.setOrCreate<ProgressInfo[]>('progressInfos', [progressInfo2, progressInfo1]);
      MessageNotify.updateProgress(progressInfo);
      expect(AppStorage.get('progressInfos')).assertDeepEquals([progressInfo2, progressInfo1, progressInfo]);
    });

    it('updateProgressOnStop_AppStorageHasNoProgressInfos', 0, () => {
      const func = TestUtil.getPrivateFunction(MessageNotify, 'updateProgressOnStop') as Function;
      AppStorage.delete('progressInfos');
      const mocker = new MockKit();
      let funcMocked = mocker.mockFunc(HiLog, HiLog['error']);
      when(funcMocked)(ArgumentMatchers.any).afterReturn(null);
      func('work1');
      mocker.verify('error', ['MessageNotify', 'Progress Infos is null.']).times(1);
      mocker.clear(HiLog);
    });

    it('updateProgressOnStop_AppStorageProgressInfos', 0, () => {
      const func = TestUtil.getPrivateFunction(MessageNotify, 'updateProgressOnStop') as Function;
      AppStorage.clear();
      const progressInfo1: ProgressInfo =
        new ProgressInfo('worker2', "", new ProgressBarInfo(WorkerConst.OperateType.CANCEL, 1), false);
      const progressInfo2: ProgressInfo =
        new ProgressInfo('worker1', "", new ProgressBarInfo(WorkerConst.OperateType.CANCEL, 1), true);
      AppStorage.setOrCreate<ProgressInfo[]>('progressInfos', [progressInfo2, progressInfo1]);
      const mocker = new MockKit();
      let funcMocked = mocker.mockFunc(HiLog, HiLog['error']);
      when(funcMocked)(ArgumentMatchers.any).afterReturn(null);
      func('worker1');
      mocker.verify('error', ['MessageNotify', 'Progress Infos is null.']).times(0);
      mocker.clear(HiLog);
    });

    it('updateProgressOnStop_AppStorageProgressInfos2', 0, () => {
      const func = TestUtil.getPrivateFunction(MessageNotify, 'updateProgressOnStop') as Function;
      AppStorage.clear();
      const progressInfo2: ProgressInfo =
        new ProgressInfo('worker1', "", new ProgressBarInfo(WorkerConst.OperateType.CANCEL, 1), true);
      AppStorage.setOrCreate<ProgressInfo[]>('progressInfos', [progressInfo2]);
      const mocker = new MockKit();
      let funcMocked = mocker.mockFunc(HiLog, HiLog['error']);
      when(funcMocked)(ArgumentMatchers.any).afterReturn(null);
      func('worker1');
      mocker.verify('error', ['MessageNotify', 'Progress Infos is null.']).times(0);
      mocker.clear(HiLog);
    });

  })
}