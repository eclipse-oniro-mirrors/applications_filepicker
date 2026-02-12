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
import { Constant } from '../const/Constant';
import { PAGE_ROUTE_CONST } from '../const/PageRouteConst';
import { HiLog } from '../dfx/HiLog';
import { AbilityOrRouterParams } from '../model/AbilityOrRouterParams';
import { StandardAnimation } from './StandardAnimation';
import { FolderOperationType } from '../const/Constant'

const TAG: string = 'CustomNavigationUtil';

export interface AnimateCallback {
  timeout?: number;
  animation?: (transitionProxy: NavigationTransitionProxy, naviOperation: NavigationOperation) => void;
  animationType?: StandardAnimation.TransitionAnimationType;
}

// 文件夹进入退出转场
const customFolderTransitionMap: Map<string, AnimateCallback> = new Map();

export class CustomTransition {
  public static readonly REGISTER_TIME_OUT: number = 2000;
  private static delegate = new CustomTransition();
  public transitionAnimationType: StandardAnimation.TransitionAnimationType =
    StandardAnimation.TransitionAnimationType.OTHER;

  private constructor() {
  }

  public static getInstance() {
    return CustomTransition.delegate;
  }

  /**
   * Get the custom animation for navigation transition
   * @param from The source navigation content info.
   * @param to The destination navigation content info.
   * @param naviOperation The navigation operation type.
   * @param currentTabIndex The current tab index (optional).
   * @returns The custom animation or undefined if not applicable.
   */
  public static getCustomAnimation(
    from: NavContentInfo,
    to: NavContentInfo,
    naviOperation: NavigationOperation,
    currentTabIndex: number = 0
  ): NavigationAnimatedTransition | undefined {
    const toParam = to?.param as AbilityOrRouterParams;
    if (toParam && from.index === to.index && (toParam.folderOperateType === FolderOperationType.OPEN_FOLDER ||
      toParam.folderOperateType === FolderOperationType.EXIT_FOLDER)) {
      HiLog.info(TAG, 'Triggering folder transition');
      return CustomTransition.folderTransition(from, to, naviOperation);
    } else {
      HiLog.info(TAG, 'No custom animation applicable');
      return undefined;
    }
  }

  private static folderTransition(
    from: NavContentInfo,
    to: NavContentInfo,
    naviOperation: NavigationOperation
  ): NavigationAnimatedTransition | undefined {
    const fromParam: AnimateCallback | undefined = CustomTransition.getInstance()
      .getAnimateParam(from.navDestinationId || '', StandardAnimation.TransitionAnimationType.FOLDER_OPEN_AND_EXIT);
    const toParam: AnimateCallback | undefined = CustomTransition.getInstance()
      .getAnimateParam(to.navDestinationId || '', StandardAnimation.TransitionAnimationType.FOLDER_OPEN_AND_EXIT);

    if (!fromParam?.animation || !toParam?.animation) {
      HiLog.info(TAG, 'Missing animation functions for folder transition');
      return undefined;
    }

    const customAnimation: NavigationAnimatedTransition = {
      timeout: 1000,
      transition: (transitionProxy: NavigationTransitionProxy) => {
        fromParam.animation && fromParam.animation(transitionProxy, naviOperation);
        toParam.animation && toParam.animation(transitionProxy, naviOperation);
      }
    };

    return customAnimation;
  }

  /**
   * Register an animation callback for a page
   * @param name The unique id of the registration page.
   * @param timeout Timeout period at the end of the transition.
   * @param type The type of transition animation.
   * @param animation Used to set the state of the page when the animation starts.
   */
  public registerNavParam(
    name: string,
    timeout: number,
    type: StandardAnimation.TransitionAnimationType,
    animation: (transitionProxy: NavigationTransitionProxy, naviOperation: NavigationOperation) => void,
  ): void {
    if (!name) {
      HiLog.error(TAG, 'Invalid name provided for registration');
      return;
    }

    const params: AnimateCallback = {
      animation,
      timeout,
      animationType: type
    };

    switch (type) {
      case StandardAnimation.TransitionAnimationType.FOLDER_OPEN_AND_EXIT:
        customFolderTransitionMap.set(name, params);
        break;
      default:
        HiLog.warn(TAG, `Unsupported animation type: ${type}`);
        break;
    }
  }

  /**
   * Unregister an animation callback for a page
   * @param name The unique id of the registration page.
   */
  public unRegisterNavParam(name: string): void {
    if (!name) {
      HiLog.error(TAG, 'Invalid name provided for unregistration');
      return;
    }

    const folderRemoved = customFolderTransitionMap.delete(name);
    if (folderRemoved) {
      HiLog.info(TAG, 'Successfully unregistered animation');
    } else {
      HiLog.warn(TAG, 'No animation found');
    }
  }

  /**
   * Get animation parameters for a specific page and transition type
   * @param name The unique id of the page.
   * @param type The type of transition animation.
   * @returns The animation parameters or undefined if not found.
   */
  public getAnimateParam(name: string, type: StandardAnimation.TransitionAnimationType): AnimateCallback | undefined {
    if (!name) {
      HiLog.error(TAG, 'Invalid name provided for getting animation parameters');
      return undefined;
    }

    switch (type) {
      case StandardAnimation.TransitionAnimationType.FOLDER_OPEN_AND_EXIT:
        return customFolderTransitionMap.get(name);
      default:
        HiLog.warn(TAG, `Unsupported animation type: ${type}`);
        return undefined;
    }
  }
}