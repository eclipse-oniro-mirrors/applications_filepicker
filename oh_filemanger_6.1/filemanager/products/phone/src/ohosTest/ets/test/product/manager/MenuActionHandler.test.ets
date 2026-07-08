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
import { FileInfo, HiLog, MenuInfo, MenuItemName, PAGE_ROUTE_CONST } from '@ohos/common';
import { describe, expect, it, MockKit } from '@ohos/hypium';
import { MenuActionHandler } from '../../../../../main/ets/base/manager/MenuActionHandler';
import { TestUtil } from '../../utils/TestUtil';

const TAG = 'MenuActionHandlerTest'

export default function MenuActionHandlerTest() {

  describe('MenuActionHandlerTest', () => {
    it('refreshFromPage', 0, () => {
      let actionHandler: MenuActionHandler = new MenuActionHandler(PAGE_ROUTE_CONST.MY_PHONE);
      actionHandler.refreshFromPage(PAGE_ROUTE_CONST.RECENT_DELETE);
      const fromPage: string =
        TestUtil.getPrivateAttribute<string>(actionHandler, 'fromPage');
      expect(fromPage).assertEqual(PAGE_ROUTE_CONST.RECENT_DELETE);
    })

    it('registerMenuEvent', 0, () => {
      let actionHandler: MenuActionHandler = new MenuActionHandler(PAGE_ROUTE_CONST.MY_PHONE);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.info);
      actionHandler.registerMenuEvent([MenuItemName.SET_RINGTONE], (menuInfo: MenuInfo)=>{
        HiLog.info(TAG, 'callback');
      })
      mocker.ignoreMock(HiLog, HiLog.info);
      mocker.verify('info', ['MenuActionHandler', 'registerMenuEvent']).once();
    })

    it('registerMenuEventTwice', 0, () => {
      let actionHandler: MenuActionHandler = new MenuActionHandler(PAGE_ROUTE_CONST.MY_PHONE);
      actionHandler.registerMenuEvent([MenuItemName.SET_RINGTONE], (menuInfo: MenuInfo)=>{
        HiLog.info(TAG, 'callback');
      })
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.warn);
      actionHandler.registerMenuEvent([MenuItemName.SET_RINGTONE], (menuInfo: MenuInfo)=>{
        HiLog.info(TAG, 'callback');
      })
      mocker.ignoreMock(HiLog, HiLog.warn);
      mocker.verify('warn', ['MenuActionHandler', 'already registered']).once();
    })

    it('registerMenuEventWithUndefinedCallback', 0, () => {
      let actionHandler: MenuActionHandler = new MenuActionHandler(PAGE_ROUTE_CONST.MY_PHONE);
      actionHandler.registerMenuEvent([MenuItemName.SET_RINGTONE], undefined)
      const menuActionCallback: undefined =
        TestUtil.getPrivateAttribute<undefined>(actionHandler, 'menuActionCallback');
      expect(menuActionCallback).assertEqual(undefined);
    })

    it('unregisterMenuEvent', 0, () => {
      let actionHandler: MenuActionHandler = new MenuActionHandler(PAGE_ROUTE_CONST.MY_PHONE);
      actionHandler.unregisterMenuEvent()
      const menuNames: Set<MenuItemName> =
        TestUtil.getPrivateAttribute<Set<MenuItemName>>(actionHandler, 'menuNames');
      expect(menuNames.size).assertEqual(0);
    })

    it('handleMenuActionWithUndefined', 0, () => {
      let actionHandler: MenuActionHandler = new MenuActionHandler(PAGE_ROUTE_CONST.MY_PHONE);
      let menuInfos: MenuInfo[] = [];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.error);
      actionHandler.handleMenuAction(menuInfos[0])
      mocker.ignoreMock(HiLog, HiLog.error);
      mocker.verify('error', ['MenuActionHandler', 'undefined menu info']).once();
    })

    it('handleMenuActionWithMenuInfo', 0, () => {
      let actionHandler: MenuActionHandler = new MenuActionHandler(PAGE_ROUTE_CONST.MY_PHONE);
      let menuInfo: MenuInfo = new MenuInfo(MenuItemName.SET_RINGTONE, [], new FileInfo(), false);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.info);
      actionHandler.handleMenuAction(menuInfo)
      mocker.ignoreMock(HiLog, HiLog.info);
      const outLog: string = `menu name ${menuInfo.menuName}`;
      mocker.verify('info', ['MenuActionHandler', outLog]).once();
    })

    it('handleMenuActionWithUnregisteredMenuName', 0, () => {
      let actionHandler: MenuActionHandler = new MenuActionHandler(PAGE_ROUTE_CONST.MY_PHONE);
      let menuInfo: MenuInfo = new MenuInfo(MenuItemName.SET_RINGTONE, [], new FileInfo(), false);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.warn);
      actionHandler.handleMenuAction(menuInfo)
      mocker.ignoreMock(HiLog, HiLog.warn);
      mocker.verify('warn', ['MenuActionHandler', 'not registered menu']).once();
    })

    it('handleMenuActionWithoutHandler', 0, () => {
      let actionHandler: MenuActionHandler = new MenuActionHandler(PAGE_ROUTE_CONST.MY_PHONE);
      actionHandler.registerMenuEvent([MenuItemName.CLEAR_RECENT_RECORD]);
      let menuInfo: MenuInfo = new MenuInfo(MenuItemName.CLEAR_RECENT_RECORD, [], new FileInfo(), false);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.warn);
      actionHandler.handleMenuAction(menuInfo)
      mocker.ignoreMock(HiLog, HiLog.warn);
      mocker.verify('warn', ['MenuActionHandler', 'no handler']).once();
    })

    it('handleMenuActionWithHandler', 0, () => {
      let actionHandler: MenuActionHandler = new MenuActionHandler(PAGE_ROUTE_CONST.MY_PHONE);
      actionHandler.registerMenuEvent([MenuItemName.SET_RINGTONE]);
      let menuInfo: MenuInfo = new MenuInfo(MenuItemName.SET_RINGTONE, [], new FileInfo(), false);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.warn);
      actionHandler.handleMenuAction(menuInfo)
      mocker.ignoreMock(HiLog, HiLog.warn);
      mocker.verify('warn', ['MenuActionHandler', 'no handler']).never();
    })
  })
}