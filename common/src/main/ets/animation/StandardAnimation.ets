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
import { curves } from '@kit.ArkUI';
import { ObjectUtil } from '../utils/ObjectUtil';
import { HiLog } from '../dfx/HiLog';

const TAG: string = 'StandardAnimation';

/**
 * 标准动画模块，提供符合动效规范的动画效果。
 */
export namespace StandardAnimation {
  /**
   * 转场类型
   */
  export enum TransitionAnimationType {
    FOLDER_OPEN_AND_EXIT, // 文件夹打开和退出
    OTHER // 其他
  }
  /**
   * 动画延迟枚举，定义了不同延迟时间的常量，单位为毫秒。
   */
  enum AnimationDelay {
    DELAY_0 = 0,
    DELAY_16_67 = 16.67,
    DELAY_33_34 = 33.34,
    DELAY_50 = 50,
    DELAY_150 = 150,
  }

  /**
   * 动画持续时间枚举，定义了不同动画持续时间的常量，单位为毫秒。
   */
  enum AnimationDuration {
    DURATION_66_67 = 66.67,
    DURATION_100 = 100,
    DURATION_150 = 150,
    DURATION_200 = 200,
    DURATION_250 = 250,
    DURATION_500 = 500,
  }

  /**
   * 执行动画的通用函数，负责配置动画并执行。
   * @param config 动画配置参数。
   * @param startCallback 动画开始时调用的回调函数。
   * @param endCallback 动画结束时调用的回调函数。
   * @param onFinish 动画完成时调用的回调函数。
   */
  function executeAnimation(
    context: UIContext,
    animateParam: AnimateParam,
    startCallback: () => void,
    endCallback: () => void
  ): void {
    startCallback();
    if (ObjectUtil.isNullOrUndefined(context)) {
      HiLog.error(TAG, 'context is null or undefined!');
      return;
    }
    context.animateTo(animateParam, () => {
      endCallback();
    });
  }

  /**
   * 动画常量类，定义了各种过渡效果的常量。
   */
  export class AnimationConstants {
    /**
     * 一镜到底动画移动常量，定义了一个特定的动画移动值，单位为vp。
     */
    private static readonly LONG_TAKE_ANIMATION_MOVE_DISTANCE: number = 56;
    // 转场延迟动画参数
    public static readonly SHOW_ANIMATE_STIFFNESS: number = 342;
    public static readonly SHOW_ANIMATE_DAMPING: number = 37;
    /**
     * 标准标题过渡效果常量。
     * 定义了一个不对称的过渡效果，结合了平移和透明度的动画。
     * 出现动画：标题从右侧（x: '50%'）平移进入，并伴随透明度变化。
     * 消失动画：标题向左侧（x: '-50%'）平移退出，并伴随透明度变化。
     */
    public static readonly STANDARD_TITLE_TRANSITION: TransitionEffect = TransitionEffect.asymmetric(
      // 出现动画配置
      TransitionEffect.translate({ x: '50%' }).animation({
        curve: curves.interpolatingSpring(0, 1, AnimationConstants.SHOW_ANIMATE_STIFFNESS,
          AnimationConstants.SHOW_ANIMATE_DAMPING),
      }).combine(TransitionEffect.OPACITY.animation({
        delay: AnimationDelay.DELAY_33_34, // 动画延迟时间（毫秒）
        duration: AnimationDuration.DURATION_150, // 动画持续时间（毫秒）
        curve: Curve.Sharp // 动画曲线类型
      })),
      // 消失动画配置
      TransitionEffect.translate({ x: '-50%' }).animation({
        curve: curves.interpolatingSpring(0, 1, AnimationConstants.SHOW_ANIMATE_STIFFNESS,
          AnimationConstants.SHOW_ANIMATE_DAMPING),
      }).combine(TransitionEffect.OPACITY.animation({
        delay: AnimationDelay.DELAY_16_67, // 动画延迟时间（毫秒）
        duration: AnimationDuration.DURATION_150, // 动画持续时间（毫秒）
        curve: Curve.Sharp // 动画曲线类型
      }))
    );
    /**
     * 左箭头过渡效果常量。
     * 定义了一个不对称的过渡效果，仅涉及透明度的变化。
     * 出现动画：左箭头从透明到不透明。
     * 消失动画：左箭头从不透明到透明。
     */
    public static readonly LEFT_ARROW_TRANSITION: TransitionEffect = TransitionEffect.asymmetric(
      // 出现动画配置
      TransitionEffect.OPACITY.animation({
        delay: AnimationDelay.DELAY_150, // 动画延迟时间（毫秒）
        duration: AnimationDuration.DURATION_200, // 动画持续时间（毫秒）
        curve: Curve.Sharp // 动画曲线类型
      }),
      // 消失动画配置
      TransitionEffect.OPACITY.animation({
        delay: AnimationDelay.DELAY_0, // 动画延迟时间（毫秒）
        duration: AnimationDuration.DURATION_66_67, // 动画持续时间（毫秒）
        curve: Curve.Sharp // 动画曲线类型
      })
    );

    public static readonly SCROLL_TRANSITION: TransitionEffect = TransitionEffect.translate({ y: -100 }).animation({
      curve: Curve.EaseIn, duration: 400 });

    public static readonly BUTTON_TRANSITION: TransitionEffect = TransitionEffect.translate({ y: 100 }).animation({
      curve: Curve.EaseIn, duration: 400 });
  }
}