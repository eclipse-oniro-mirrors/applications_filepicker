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

import {
  Constant,
  DeviceTypeConstants,
  EventBus,
  AccountManager,
  LanguageUtil
} from '@ohos/common';
import type CommonEventManager from '@ohos.commonEventManager';
import { describe, expect, it, MockKit, when } from '@ohos/hypium';
import { TestUtil } from '../../../test/utils/TestUtil';
import CommonEvent from '@ohos.commonEvent';

const accountManager = AccountManager.getInstance();

export default function AccountManagerTest() {
  describe('AccountManager', () => {
    it('subscribeAccountChangeEvent_when_subscriber_is_null', 0, async () => {
      TestUtil.setPrivateAttribute(accountManager, 'isSubscribed', true);
      TestUtil.setPrivateAttribute(accountManager, 'subscriber', null);
      await accountManager.subscribeAccountChangeEvent();
      expect(TestUtil.getPrivateAttribute(accountManager, 'subscriber')).assertNull();
    })

    it('subscribeAccountChangeEvent_when_subscriber_is_true_and_isSubscribed_is_false', 0, async () => {
      TestUtil.setPrivateAttribute(accountManager, 'isSubscribed', false);
      TestUtil.setPrivateAttribute(accountManager, 'subscriber', true);
      await accountManager.subscribeAccountChangeEvent();
      expect(TestUtil.getPrivateAttribute(accountManager, 'isSubscribed')).assertTrue();
    })

    it('subscribeAccountChangeEvent__when_subscriber_and_isSubscribed_both_are_false', 0, async () => {
      TestUtil.setPrivateAttribute(accountManager, 'isSubscribed', false);
      TestUtil.setPrivateAttribute(accountManager, 'subscriber', false);
      await accountManager.subscribeAccountChangeEvent();
      expect(TestUtil.getPrivateAttribute(accountManager, 'isSubscribed')).assertTrue();
    })

    it('accountChangeCallBack_should_return_ACCOUNT_LOGIN', 0, () => {
      const accountChangeCallBack = TestUtil.getPrivateFunction(accountManager, 'accountChangeCallBack');
      if (accountChangeCallBack) {
        let event = '';
        const mocker = new MockKit();
        const emit = mocker.mockFunc(EventBus, EventBus.emit);
        when(emit)(Constant.EVENTS.ACCOUNT_LOGIN).afterAction(() => event = Constant.EVENTS.ACCOUNT_LOGIN);
        when(emit)(Constant.EVENTS.ACCOUNT_LOGOUT).afterAction(() => event = Constant.EVENTS.ACCOUNT_LOGOUT);

        let errorData: CommonEventManager.CommonEventData = {
          event: CommonEvent.Support.COMMON_EVENT_HWID_LOGIN
        };
        TestUtil.setPrivateAttribute(accountManager, 'deviceType', DeviceTypeConstants.PHONE);
        event = '';
        accountChangeCallBack({
          code: 0
        }, errorData);
        mocker.ignoreMock(EventBus, EventBus.emit);
        expect(event).assertEqual(Constant.EVENTS.ACCOUNT_LOGIN);
      } else {
        expect().assertFail();
      }
    })

    it('accountChangeCallBack_should_return_ACCOUNT_LOGOUT', 0, () => {
      const accountChangeCallBack = TestUtil.getPrivateFunction(accountManager, 'accountChangeCallBack');
      if (accountChangeCallBack) {
        let event = '';
        const mocker = new MockKit();
        const emit = mocker.mockFunc(EventBus, EventBus.emit);
        when(emit)(Constant.EVENTS.ACCOUNT_LOGIN).afterAction(() => event = Constant.EVENTS.ACCOUNT_LOGIN);
        when(emit)(Constant.EVENTS.ACCOUNT_LOGOUT).afterAction(() => event = Constant.EVENTS.ACCOUNT_LOGOUT);

        let errorData: CommonEventManager.CommonEventData = {
          event: CommonEvent.Support.COMMON_EVENT_HWID_LOGOUT
        };
        TestUtil.setPrivateAttribute(accountManager, 'deviceType', DeviceTypeConstants.PHONE);
        event = '';

        accountChangeCallBack({
          code: 0
        }, errorData);

        mocker.ignoreMock(EventBus, EventBus.emit);
        expect(event).assertEqual(Constant.EVENTS.ACCOUNT_LOGOUT);
      } else {
        expect().assertFail();
      }
    })

    it('accountChangeCallBack_when_errorData_is_null', 0, () => {
      const accountChangeCallBack = TestUtil.getPrivateFunction(accountManager, 'accountChangeCallBack');
      if (accountChangeCallBack) {
        let event = '';
        const mocker = new MockKit();
        const emit = mocker.mockFunc(EventBus, EventBus.emit);
        when(emit)(Constant.EVENTS.ACCOUNT_LOGIN).afterAction(() => event = Constant.EVENTS.ACCOUNT_LOGIN);
        when(emit)(Constant.EVENTS.ACCOUNT_LOGOUT).afterAction(() => event = Constant.EVENTS.ACCOUNT_LOGOUT);

        let errorData: CommonEventManager.CommonEventData = {
          event: ''
        };
        TestUtil.setPrivateAttribute(accountManager, 'deviceType', DeviceTypeConstants.PHONE);
        event = '';
        accountChangeCallBack({ code: 0 }, errorData);
        mocker.ignoreMock(EventBus, EventBus.emit);
        mocker.verify('emit', [Constant.EVENTS.ACCOUNT_LOGIN]).never();
      } else {
        expect().assertFail();
      }
    })

    it('accountChangeCallBack_when_errorData_is_COMMON_EVENT_LOCALE_CHANGED', 0, () => {
      const accountChangeCallBack = TestUtil.getPrivateFunction(accountManager, 'accountChangeCallBack');
      if (accountChangeCallBack) {
        const mocker = new MockKit();

        let errorData: CommonEventManager.CommonEventData = {
          event: CommonEvent.Support.COMMON_EVENT_LOCALE_CHANGED
        };
        TestUtil.setPrivateAttribute(accountManager, 'deviceType', DeviceTypeConstants.PHONE);

        mocker.mockFunc(LanguageUtil, LanguageUtil.updateSystemLanguage);
        accountChangeCallBack({
          code: 0
        }, errorData);
        mocker.clear(LanguageUtil);
        mocker.verify('updateSystemLanguage', []).once();
      } else {
        expect().assertFail();
      }
    })

    it('createSubscriber', 0, async () => {
      const createSubscriber = TestUtil.getPrivateFunction(accountManager, 'createSubscriber');
      if (createSubscriber) {
        const oldVal: object = TestUtil.getPrivateAttribute(accountManager, 'subscriber');
        await createSubscriber();
        const newValue: object = TestUtil.getPrivateAttribute(accountManager, 'subscriber');
        const result = newValue !== oldVal;
        expect(result).assertTrue();
      } else {
        expect().assertFail();
      }
    })
  })
}
