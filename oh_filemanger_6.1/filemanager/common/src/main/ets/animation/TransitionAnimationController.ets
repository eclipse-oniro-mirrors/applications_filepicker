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
import { FolderOperationType } from '../const/Constant'
import { curves } from '@kit.ArkUI';
import { StandardAnimation } from './StandardAnimation';
import { Z_INDEX } from '../const/UiConstant';
import { HiLog } from '../dfx/HiLog';

const TAG: string = 'TransitionAnimationController';

/**
 * 转场动效控制器
 */
@Observed
export class TransitionAnimationController {
  // 页面平移
  public translateX: string | number = 0;
  // 标题平移
  public titleTranslateX: string | number = 0;
  // 标题透明度
  public titleOpacity: number = 1;
  // 标题栏左箭头透明度
  public leftIconOpacity: number = 1;
  // 页面层级
  public zIndexNumber: number = 0;
  // 当前页面是否存活，被替换就会失活
  private isActive: boolean = true;
  // 蒙层透明度
  public maskOpacity: number = 0;
  // 最新的动效ID
  public latestAnimationId: string = '';
  // 页面动效是否执行中
  public isAnimationRunning: boolean = false;
  // 动效结束回调
  public finishCallback: Function = () => {
  };
  // 页面透明度
  public pageOpacity: number = 1;

  constructor(translateX: string | number, titleOpacity: number, zIndexNumber: number, pageOpacity: number,
    finishCallBack?: Function) {
    this.translateX = translateX;
    this.titleOpacity = titleOpacity;
    this.zIndexNumber = zIndexNumber;
    this.pageOpacity = pageOpacity;
    if (finishCallBack) {
      this.finishCallback = finishCallBack;
    }
  }

  // 执行文件夹操作的页面动效
  public executeFolderAnimation(folderOperateType: FolderOperationType, isReplaced: boolean,
    transitionProxy: NavigationTransitionProxy): void {
    this.isActive = !isReplaced;
    if (folderOperateType === FolderOperationType.OPEN_FOLDER) {
      if (isReplaced) {
        this.enterFolderParent(transitionProxy);
      } else {
        this.enterFolderChildren(transitionProxy);
      }
    } else if (folderOperateType === FolderOperationType.EXIT_FOLDER) {
      if (isReplaced) {
        this.exitFolderChildren(transitionProxy);
      } else {
        this.exitFolderParent(transitionProxy);
      }
    }
  }

  // 打开文件夹-子页面动效
  public enterFolderChildren(transitionProxy: NavigationTransitionProxy) {
    this.translateX = '100%';
    this.zIndexNumber = Z_INDEX.LEVEL100;
    this.titleTranslateX = '50%';
    this.titleOpacity = 0;
    this.leftIconOpacity = 0;
    const currentAnimationId: string = this.generateNewAnimationId();
    // 子页面偏移
    animateTo({
      duration: 500,
      curve: curves.interpolatingSpring(0, 1, 342, 37),
      onFinish: () => {
        if (this.isActive) {
          this.zIndexNumber = 0;
        }
        transitionProxy.finishTransition();
        this.updateAnimationStatus(currentAnimationId);
      }
    }, () => {
      this.translateX = 0;
      this.titleTranslateX = 0;
    });
    // 子页面标题透明度
    animateTo({
      duration: 150,
      curve: Curve.Sharp,
      onFinish: () => {
      }
    }, () => {
      this.titleOpacity = 1;
    });
    // 子页面返回按钮透明度
    animateTo({
      delay: 150,
      duration: 200,
      curve: Curve.Sharp,
      onFinish: () => {
      }
    }, () => {
      this.leftIconOpacity = 1;
    });
  }

  // 打开文件夹-父页面动效
  public enterFolderParent(transitionProxy: NavigationTransitionProxy) {
    this.translateX = 0;
    this.zIndexNumber = Z_INDEX.MIDDLE;
    const currentAnimationId: string = this.generateNewAnimationId();
    // 父页面偏移
    animateTo({
      duration: 500,
      curve: curves.interpolatingSpring(0, 1, 342, 37),
      onFinish: () => {
        transitionProxy.finishTransition();
        this.translateX = '-100%';
        this.updateAnimationStatus(currentAnimationId);
      }
    }, () => {
      this.translateX = '-50%';
    });
    // 父页面蒙黑
    this.maskOpacity = 0;
    animateTo({
      duration: 350,
      curve: Curve.Friction,
      onFinish: () => {
      }
    }, () => {
      this.maskOpacity = 0.1;
    });

  }

  // 退出文件夹-子页面动效
  public exitFolderChildren(transitionProxy: NavigationTransitionProxy) {
    this.zIndexNumber = Z_INDEX.LEVEL100;
    this.translateX = 0;
    this.titleTranslateX = 0;
    this.titleOpacity = 1;
    this.leftIconOpacity = 1;
    const currentAnimationId: string = this.generateNewAnimationId();
    // 子页面平移
    animateTo({
      duration: 500,
      curve: curves.interpolatingSpring(0, 1, 342, 37),
      onFinish: () => {
        transitionProxy.finishTransition();
        this.updateAnimationStatus(currentAnimationId);
      }
    }, () => {
      this.translateX = '100%';
      this.titleTranslateX = '50%';
    });
    // 子页面标题透明度
    animateTo({
      duration: 150,
      curve: Curve.Sharp,
      onFinish: () => {}
    }, () => {
      this.titleOpacity = 0;
    });
    // 子页面返回按钮透明度
    animateTo({
      duration: 50,
      curve: Curve.Sharp,
      onFinish: () => {}
    }, () => {
      this.leftIconOpacity = 0;
    });
  }

  // 退出文件夹-父页面动效
  public exitFolderParent(transitionProxy: NavigationTransitionProxy) {
    this.translateX = '-20%';
    this.zIndexNumber = Z_INDEX.MIDDLE;
    const currentAnimationId: string = this.generateNewAnimationId();
    // 父页面偏移
    animateTo({
      duration: 500,
      curve: curves.interpolatingSpring(0, 1, 342, 37),
      onFinish: () => {
        if (this.isActive) {
          this.zIndexNumber = 0;
        }
        transitionProxy.finishTransition();
        this.updateAnimationStatus(currentAnimationId);
      },
    }, () => {
      this.translateX = 0;
    });
    // 父页面蒙黑
    this.maskOpacity = 0.1;
    animateTo({
      duration: 350,
      curve: Curve.Friction,
      onFinish: () => {
      }
    }, () => {
      this.maskOpacity = 0;
    });
  }

  // 生成动画id，更新页面动画执行状态
  private generateNewAnimationId(): string {
    const newAnimationId = 'FOLDER_ANIMATION_' + Date.now();
    this.latestAnimationId = newAnimationId;
    this.isAnimationRunning = true;
    return newAnimationId;
  }

  // 更新动画状态
  private updateAnimationStatus(finishAnimationId: string) {
    // 最后一个动画结束时更新页面动画状态
    if (this.isAnimationRunning && this.latestAnimationId === finishAnimationId) {
      this.isAnimationRunning = false;
      this.finishCallback();
    }
  }
}