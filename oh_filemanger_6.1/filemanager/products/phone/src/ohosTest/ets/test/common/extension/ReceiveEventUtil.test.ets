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
import { EventConst } from '../../../../../main/ets/base/extension/const/EventConst';
import { OpenFolderData } from '../../../../../main/ets/base/extension/model/SendDataModel';
import { ReceiveEventUtil } from '../../../../../main/ets/base/extension/ReceiveEventUtil';
import { describe, it, MockKit } from '@ohos/hypium';
import { Constant, EventBus, HiLog } from '@ohos/common';

interface GeneratedObjectLiteralInterface_1 {
  pageName: string;
}

interface GeneratedObjectLiteralInterface_2 {
  event: string;
  data: GeneratedObjectLiteralInterface_1 | OpenFolderData | number | string;
}

interface GeneratedObjectLiteralInterface_3 {
  top: number;
  bottom: number;
  left: number;
  right: number;
}

export default function ReceiveEventUtilTest() {
  describe('ReceiveEventUtilTest', () => {
    it('receiveEventFromHostAppForJumpPageOne', 0, () => {
      let receiveData: Record<string, Object> = {
        'data': ({
          event: EventConst.JUMP_PAGE,
          data: ({
            pageName: ''
          } as GeneratedObjectLiteralInterface_1)
        } as GeneratedObjectLiteralInterface_2)
      };

      const mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.warn);
      ReceiveEventUtil.receiveEventFromHostApp(receiveData);
      mocker.ignoreMock(HiLog, HiLog.warn);
      mocker.verify('warn', ['ReceiveEventUtil', 'JumpPage fail, pageName is empty']).once();
    });

    it('receiveEventFromHostAppForJumpPageTwo', 0, () => {
      let receiveData: Record<string, Object> = {
        'data': ({
          event: EventConst.JUMP_PAGE,
          data: ({
            pageName: 'test'
          } as GeneratedObjectLiteralInterface_1)
        } as GeneratedObjectLiteralInterface_2)
      };
      const mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.warn);
      ReceiveEventUtil.receiveEventFromHostApp(receiveData);
      mocker.ignoreMock(HiLog, HiLog.warn);
      mocker.verify('warn', ['ReceiveEventUtil', 'JumpPage fail, pageName is empty']).never();
    });

    it('receiveEventFromHostAppForOpenFolderOne', 0, () => {
      let receiveData: Record<string, Object> = {
        'data': ({
          event: EventConst.OPEN_FOLDER,
          data: ({
            folderUri: 'testFolder',
            fileUriArray: ['testFolder1', 'testFolder2'],
            from: 'parentsFolder'
          } as OpenFolderData)
        } as GeneratedObjectLiteralInterface_2)
      };
      const mocker: MockKit = new MockKit();
      mocker.mockFunc(EventBus, EventBus.emit);
      ReceiveEventUtil.receiveEventFromHostApp(receiveData);
      mocker.ignoreMock(EventBus, EventBus.emit);
      mocker.verify('emit', [Constant.EVENTS.FILE_MANAGER_ON_NEW_WANT]).never();
      mocker.verify('emit', [Constant.EVENTS.CLOSE_COPY_CUT_DIALOG]).never();
    });

    it('receiveEventFromHostAppForOpenFolderTwo', 0, () => {
      let receiveData: Record<string, Object> = {
        'data': ({
          event: EventConst.OPEN_FOLDER,
          data: ({
            folderUri: 'testFolder',
            fileUriArray: ['testFolder1', 'testFolder2'],
            from: 'copyCutNotification'
          } as OpenFolderData)
        } as GeneratedObjectLiteralInterface_2)
      };
      const mocker: MockKit = new MockKit();
      mocker.mockFunc(EventBus, EventBus.emit);
      ReceiveEventUtil.receiveEventFromHostApp(receiveData);
      mocker.ignoreMock(EventBus, EventBus.emit);
      mocker.verify('emit', [Constant.EVENTS.FILE_MANAGER_ON_NEW_WANT]).never();
    });

    it('receiveEventFromHostAppForKeyboardHeightChange', 0, () => {
      let receiveData: Record<string, Object> = {
        'data': ({
          event: EventConst.KEYBOARD_HEIGHT_CHANGE,
          data: 10
        } as GeneratedObjectLiteralInterface_2)
      };
      const mocker: MockKit = new MockKit();
      mocker.mockFunc(AppStorage, AppStorage.setOrCreate);
      ReceiveEventUtil.receiveEventFromHostApp(receiveData);
      mocker.ignoreMock(AppStorage, AppStorage.setOrCreate);
      mocker.verify('setOrCreate', ['keyBoardHeight', 10]).once();
    });

    it('receiveEventFromHostAppForWindowStatusChange', 0, () => {
      let receiveData: Record<string, Object> = {
        'data': ({
          event: EventConst.WINDOW_STATUS_CHANGE,
          data: 10
        } as GeneratedObjectLiteralInterface_2)
      };
      const mocker: MockKit = new MockKit();
      mocker.mockFunc(AppStorage, AppStorage.setOrCreate);
      ReceiveEventUtil.receiveEventFromHostApp(receiveData);
      mocker.ignoreMock(AppStorage, AppStorage.setOrCreate);
      mocker.verify('setOrCreate', ['windowStatus', 10]).once();
    });

    it('receiveEventFromHostAppForCameraAvoidArea', 0, () => {
      let receiveData: Record<string, Object> = {
        'data': ({
          event: EventConst.CAMERA_AVOID_AREA,
          data: JSON.stringify({
            boundingRects: [({
              top: 10,
              bottom: 20,
              left: 10,
              right: 20
            } as GeneratedObjectLiteralInterface_3)]
          })
        } as GeneratedObjectLiteralInterface_2)
      };
      const mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.info);
      ReceiveEventUtil.receiveEventFromHostApp(receiveData);
      mocker.ignoreMock(HiLog, HiLog.info);
      mocker.verify('setOrCreate', ['windowStatus', 10]).never();
    });

    it('receiveEventFromHostAppForDeviceFoldStatus', 0, () => {
      let receiveData: Record<string, Object> = {
        'data': ({
          event: EventConst.FOLD_DEVICE_STATUS,
          data: JSON.stringify({
            status: 1
          })
        } as GeneratedObjectLiteralInterface_2)
      };
      const mocker: MockKit = new MockKit();
      mocker.mockFunc(AppStorage, AppStorage.setOrCreate);
      ReceiveEventUtil.receiveEventFromHostApp(receiveData);
      mocker.ignoreMock(AppStorage, AppStorage.setOrCreate);
      interface SendData {
        event: string
        data: string
      }
      const sendData = receiveData.data as SendData;
      const status = JSON.parse(sendData.data as string) as object;
      mocker.verify('setOrCreate', [EventConst.FOLD_DEVICE_STATUS, status['status']]).once();
    });

    it('receiveEventFromHostAppForDisplayInfo', 0, () => {
      let receiveData: Record<string, Object> = {
        'data': ({
          event: EventConst.DISPLAY_INFO,
          data: JSON.stringify({
            status: 'active'
          })
        } as GeneratedObjectLiteralInterface_2)
      };
      const mocker: MockKit = new MockKit();
      mocker.mockFunc(AppStorage, AppStorage.setOrCreate);
      ReceiveEventUtil.receiveEventFromHostApp(receiveData);
      mocker.ignoreMock(AppStorage, AppStorage.setOrCreate);
      interface SendData {
        event: string
        data: string
      }
      const sendData = receiveData.data as SendData;
      const displayInfo = JSON.parse(sendData.data as string) as object;
      mocker.verify('setOrCreate', [EventConst.DISPLAY_INFO, JSON.stringify(displayInfo['status'])]).once();
    });

    it('receiveEventFromHostAppForDefault', 0, () => {
      let receiveData: Record<string, Object> = {
        'data': ({
          event: 'Default',
          data: JSON.stringify({
            status: 'active'
          })
        } as GeneratedObjectLiteralInterface_2)
      };
      const mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.warn);
      ReceiveEventUtil.receiveEventFromHostApp(receiveData);
      mocker.ignoreMock(HiLog, HiLog.warn);
      mocker.verify('warn', ['ReceiveEventUtil', 'unknown event:Default']).once();
    });
  });
}