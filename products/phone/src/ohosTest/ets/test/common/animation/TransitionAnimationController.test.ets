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

import { FolderOperationType, TransitionAnimationController } from '@ohos/common';
import {
  describe,
  it,
  MockKit,
  when,
  ArgumentMatchers
} from '@ohos/hypium';
import { UIContext } from '@kit.ArkUI';

class NavigationTransitionProxyMock implements NavigationTransitionProxy {
  from: NavContentInfo = {
    index: 0
  };
  to: NavContentInfo = {
    index: 0
  };
  isInteractive?: boolean | undefined;

  finishTransition(): void {
    throw new Error('Method not implemented.');
  }

  cancelTransition?(): void {
    throw new Error('Method not implemented.');
  }

  updateTransition?(progress: number): void {
    throw new Error('Method not implemented.');
  }
}

export default function TransitionAnimationControllerTest() {
  describe('TransitionAnimationControllerTest', () => {
    it('executeFolderAnimation_should_set_isActive_to_false_when_folderOperateType_is_OPEN_FOLDER_and_isReplaced_is_false',
      0, () => {
        let folderOperateType: FolderOperationType = FolderOperationType.OPEN_FOLDER;
        let isReplaced: boolean = false;
        let transitionProxy: NavigationTransitionProxy = new NavigationTransitionProxyMock();
        let transitionAnimationController: TransitionAnimationController =
          new TransitionAnimationController(0, 1, 0, 1);
        let mocker: MockKit = new MockKit();
        let func = mocker.mockFunc(transitionAnimationController, transitionAnimationController.enterFolderChildren);
        when(func)(ArgumentMatchers.any).afterReturn(undefined);
        transitionAnimationController.executeFolderAnimation(folderOperateType, isReplaced, transitionProxy);
        mocker.ignoreMock(transitionAnimationController, transitionAnimationController.enterFolderChildren);
        mocker.verify('enterFolderChildren', [transitionProxy]).once();
      });

    it('executeFolderAnimation_should_set_isActive_to_true_when_folderOperateType_is_OPEN_FOLDER_and_isReplaced_is_true',
      0, () => {
        let folderOperateType: FolderOperationType = FolderOperationType.OPEN_FOLDER;
        let isReplaced: boolean = true;
        let transitionProxy: NavigationTransitionProxy = new NavigationTransitionProxyMock();
        let transitionAnimationController: TransitionAnimationController =
          new TransitionAnimationController(0, 1, 0, 1);
        let mocker: MockKit = new MockKit();
        let func = mocker.mockFunc(transitionAnimationController, transitionAnimationController.enterFolderParent);
        when(func)(ArgumentMatchers.any).afterReturn(undefined);
        transitionAnimationController.executeFolderAnimation(folderOperateType, isReplaced, transitionProxy);
        mocker.ignoreMock(transitionAnimationController, transitionAnimationController.enterFolderParent);
        mocker.verify('enterFolderParent', [transitionProxy]).once();
      });

    it('executeFolderAnimation_should_set_isActive_to_false_when_folderOperateType_is_EXIT_FOLDER_and_isReplaced_is_false',
      0, () => {
        let folderOperateType: FolderOperationType = FolderOperationType.EXIT_FOLDER;
        let isReplaced: boolean = false;
        let transitionProxy: NavigationTransitionProxy = new NavigationTransitionProxyMock();
        let transitionAnimationController: TransitionAnimationController =
          new TransitionAnimationController(0, 1, 0, 1);
        let mocker: MockKit = new MockKit();
        let func = mocker.mockFunc(transitionAnimationController, transitionAnimationController.exitFolderParent);
        when(func)(ArgumentMatchers.any).afterReturn(undefined);
        transitionAnimationController.executeFolderAnimation(folderOperateType, isReplaced, transitionProxy);
        mocker.ignoreMock(transitionAnimationController, transitionAnimationController.exitFolderParent);
        mocker.verify('exitFolderParent', [transitionProxy]).once();
      });

    it('executeFolderAnimation_should_set_isActive_to_true_when_folderOperateType_is_EXIT_FOLDER_and_isReplaced_is_true',
      0, () => {
        let folderOperateType: FolderOperationType = FolderOperationType.EXIT_FOLDER;
        let isReplaced: boolean = true;
        let transitionProxy: NavigationTransitionProxy = new NavigationTransitionProxyMock();
        let transitionAnimationController: TransitionAnimationController =
          new TransitionAnimationController(0, 1, 0, 1);
        let mocker: MockKit = new MockKit();
        let func = mocker.mockFunc(transitionAnimationController, transitionAnimationController.exitFolderChildren);
        when(func)(ArgumentMatchers.any).afterReturn(undefined);
        transitionAnimationController.executeFolderAnimation(folderOperateType, isReplaced, transitionProxy);
        mocker.ignoreMock(transitionAnimationController, transitionAnimationController.exitFolderChildren);
        mocker.verify('exitFolderChildren', [transitionProxy]).once();
      });
  });
}