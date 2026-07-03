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


export class TitleBarAnimation {
  /**
   * 左侧图标动画
   */
  public leftIcon: TransitionEffect;
  /**
   * 标题动画
   */
  public title: TransitionEffect;
  /**
   * 菜单动画
   */
  public moreIcon: TransitionEffect;
  /**
   * 整体进场动画
   */
  public allIn: TransitionEffect;
  /**
   * 整体出场动画
   */
  public allOut: TransitionEffect;
  /**
   * 动画开启的条件
   */
  public isOpen: Function;

  public constructor(leftIcon: TransitionEffect = TransitionEffect.IDENTITY,
                     title: TransitionEffect = TransitionEffect.IDENTITY,
                     allIn: TransitionEffect = TransitionEffect.IDENTITY,
                     allOut: TransitionEffect = TransitionEffect.IDENTITY,
                     isOpen: Function = () => false,
                     moreIcon: TransitionEffect = TransitionEffect.IDENTITY) {
    this.leftIcon = leftIcon;
    this.title = title;
    this.moreIcon = moreIcon;
    this.allIn = allIn;
    this.allOut = allOut;
    this.isOpen = isOpen;
  }

  openAnimation(effect: TransitionEffect): TransitionEffect {
    if (this.isOpen()) {
      return effect;
    } else {
      return TransitionEffect.IDENTITY;
    }
  }
}
