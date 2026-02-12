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
  AbilityOrRouterParams,
  CustomTransition,
  FolderOperationType,
  HiLog,
  PAGE_ROUTE_CONST,
  StandardAnimation
} from '@ohos/common';
import {
  describe,
  it,
  expect,
  MockKit,
  when,
  ArgumentMatchers
} from '@ohos/hypium';
import { TestUtil } from '../../utils/TestUtil';

export default function CustomNavigationUtilTest() {
  describe('CustomNavigationUtilTest', () => {

    it('CustomNavigationUtilTest_getInstance_test', 0, () => {
      const instance = CustomTransition.getInstance();
      expect(instance !== undefined).assertTrue();
    });

    it('registerNavParam_should_log_error_when_name_is_invalid', 0, () => {
      let customTransition: CustomTransition = CustomTransition.getInstance();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(HiLog, HiLog.error);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(null);
      customTransition.registerNavParam('', 2000, StandardAnimation.TransitionAnimationType.FOLDER_OPEN_AND_EXIT,
        () => {
        });
      mocker.ignoreMock(HiLog, HiLog.error);
      mocker.verify('error', ['CustomNavigationUtil', 'Invalid name provided for registration']).once();
    });

    it('registerNavParam_should_register_folder_open_and_exit_animation', 0, () => {
      let customTransition: CustomTransition = CustomTransition.getInstance();
      customTransition.registerNavParam('test', 2000, StandardAnimation.TransitionAnimationType.FOLDER_OPEN_AND_EXIT,
        () => {
        });

      let result: ESObject =
        customTransition.getAnimateParam('test', StandardAnimation.TransitionAnimationType.FOLDER_OPEN_AND_EXIT);
      customTransition.unRegisterNavParam('test');
      expect(result.timeout).assertEqual(2000);
      expect(result.animationType).assertEqual(StandardAnimation.TransitionAnimationType.FOLDER_OPEN_AND_EXIT);
    });

    it('registerNavParam_should_log_warning_when_animation_type_is_unsupported', 0, () => {
      let customTransition: CustomTransition = CustomTransition.getInstance();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(HiLog, HiLog.warn);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(null);
      customTransition.registerNavParam('test', 2000, StandardAnimation.TransitionAnimationType.OTHER, () => {
      });
      mocker.ignoreMock(HiLog, HiLog.warn);
      mocker.verify('warn', ['CustomNavigationUtil', 'Unsupported animation type: 2']).once();
    });

    it('unRegisterNavParam_should_log_error_when_name_is_null', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(HiLog, HiLog.error);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(null);
      let customTransition: CustomTransition = CustomTransition.getInstance();
      customTransition.unRegisterNavParam('');
      mocker.ignoreMock(HiLog, HiLog.error);
      mocker.verify('error', ['CustomNavigationUtil', 'Invalid name provided for unregistration']).once();
    });

    it('unRegisterNavParam_should_log_warn_when_no_animation_found', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(HiLog, HiLog.warn);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(null);
      let customTransition: CustomTransition = CustomTransition.getInstance();
      customTransition.unRegisterNavParam('test');
      mocker.ignoreMock(HiLog, HiLog.warn);
      mocker.verify('warn', ['CustomNavigationUtil', 'No animation found']).once();
    });

    it('getAnimateParam_should_return_undefined_when_name_is_empty', 0, () => {
      let customTransition: CustomTransition = CustomTransition.getInstance();
      let result: ESObject =
        customTransition.getAnimateParam("", StandardAnimation.TransitionAnimationType.FOLDER_OPEN_AND_EXIT);
      expect(result).assertUndefined();
    });

    it('getAnimateParam_should_return_undefined_when_animation_type_is_not_supported', 0, () => {
      let customTransition: CustomTransition = CustomTransition.getInstance();
      let result: ESObject =
        customTransition.getAnimateParam("someName", StandardAnimation.TransitionAnimationType.OTHER);
      expect(result).assertUndefined();
    });

    it('getAnimateParam_should_return_folder_open_and_exit_animation_param_when_type_is_folder_open_and_exit', 0,
      () => {
        let customTransition: CustomTransition = CustomTransition.getInstance();
        customTransition.registerNavParam('test', 2000, StandardAnimation.TransitionAnimationType.FOLDER_OPEN_AND_EXIT,
          () => {
          });
        let result: ESObject =
          customTransition.getAnimateParam("test", StandardAnimation.TransitionAnimationType.FOLDER_OPEN_AND_EXIT);
        expect(result).not().assertUndefined();
      });

    it('folderTransition_should_return_undefined_when_fromParam_is_undefined', 0, async () => {
      let from: NavContentInfo = {
        index: 0,
        navDestinationId: 'testFrom'
      };
      let to: NavContentInfo = {
        index: 0
      };
      const folderTransition = TestUtil.getPrivateFunction(CustomTransition, 'folderTransition');
      if (folderTransition) {
        let result: ESObject = folderTransition(from, to, NavigationOperation.PUSH);
        expect(result).assertUndefined();
      } else {
        expect().assertFail();
      }
    });

    it('folderTransition_should_return_undefined_when_toParam_is_undefined', 0, async () => {
      let from: NavContentInfo = {
        index: 0,
      };
      let to: NavContentInfo = {
        index: 0,
        navDestinationId: 'testTo'
      };
      const folderTransition = TestUtil.getPrivateFunction(CustomTransition, 'folderTransition');
      if (folderTransition) {
        let result: ESObject = folderTransition(from, to, NavigationOperation.PUSH, 1);
        expect(result).assertUndefined();
      } else {
        expect().assertFail();
      }
    });

    it('folderTransition_should_return_animation_params', 0, async () => {
      let from: NavContentInfo = {
        index: 0,
        navDestinationId: 'testFrom'
      };
      let to: NavContentInfo = {
        index: 0,
        navDestinationId: 'testTo'
      };
      CustomTransition.getInstance()
        .registerNavParam('testFrom', 2000, StandardAnimation.TransitionAnimationType.FOLDER_OPEN_AND_EXIT, () => {
        });
      CustomTransition.getInstance()
        .registerNavParam('testTo', 2000, StandardAnimation.TransitionAnimationType.FOLDER_OPEN_AND_EXIT, () => {
        });
      const folderTransition = TestUtil.getPrivateFunction(CustomTransition, 'folderTransition');
      if (folderTransition) {
        let result: ESObject = folderTransition(from, to, NavigationOperation.PUSH, 1);
        expect(result).not().assertUndefined();
      } else {
        expect().assertFail();
      }
    });

    it('getCustomAnimation_should_call_folderTransition', 0, () => {
      const toParam = { folderOperateType: FolderOperationType.OPEN_FOLDER } as AbilityOrRouterParams;
      let from: NavContentInfo = {
        index: 0,
        navDestinationId: 'testFrom',
        name: PAGE_ROUTE_CONST.MY_PHONE
      };
      let to: NavContentInfo = {
        index: 0,
        name: PAGE_ROUTE_CONST.MY_PHONE,
        param: toParam
      };
      let mocker: MockKit = new MockKit();
      let func: Function = TestUtil.getPrivateMockFunction(mocker, CustomTransition, 'folderTransition');
      when(func)(ArgumentMatchers.any).afterReturnNothing();
      CustomTransition.getInstance().transitionAnimationType =
        StandardAnimation.TransitionAnimationType.FOLDER_OPEN_AND_EXIT;
      CustomTransition.getCustomAnimation(from, to, NavigationOperation.REPLACE, 1);
      mocker.clear(CustomTransition);
      mocker.verify('folderTransition', [from, to, NavigationOperation.REPLACE]).once();
    });

    it('getCustomAnimation_should_return_undefined', 0, () => {
      let from: NavContentInfo = {
        index: 0,
        navDestinationId: 'testFrom',
        name: PAGE_ROUTE_CONST.MY_PHONE
      };
      let to: NavContentInfo = {
        index: 0,
        name: PAGE_ROUTE_CONST.MY_PHONE
      };
      let mocker: MockKit = new MockKit();
      let func: Function = TestUtil.getPrivateMockFunction(mocker, CustomTransition, 'folderTransition');
      when(func)(ArgumentMatchers.any).afterReturnNothing();
      CustomTransition.getCustomAnimation(from, to, NavigationOperation.POP, 1);
      mocker.clear(CustomTransition);
      mocker.verify('folderTransition', [from, to, NavigationOperation.PUSH]).never();
    });
  });
}