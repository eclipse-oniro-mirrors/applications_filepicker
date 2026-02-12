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

import { ListItemModifier } from '../model/AttributeModifier';
import curves from '@ohos.curves';
import { HiLog } from '@ohos/common';

const ITEM_HEIGHT: number = 56; // 行高
const ANIMATE_DURATION: number = 300; // 动画时间
const TAG = 'ListExchangeCtrl';

// 操作状态枚举
enum OperationStatus {
  IDLE,
  PRESSING,
  MOVING,
  DROPPING,
  DELETE
}

enum Direction {
  UP = -1,
  DOWN = 1
}

export enum DragStatus {
  DRAGGING = 0,
  DRAG_END = 1
}

/**
 * 列表项切换控制
 */
@Observed
export class ListExchangeCtrl<T> {
  private deductionData: Array<T>; // 列表数据
  private modifier: Array<ListItemModifier>; // 属性数据
  private dragRefOffset: number = 0;
  public offsetY: number = 0;
  public state: OperationStatus = OperationStatus.IDLE;
  // 列表切换无障碍播报方法
  public accessibilityBroadcastFunc?: Function = undefined;
  private targetSource: T | undefined = undefined; // 保存拖拽中的target
  private isDown: boolean = false; // 是否向下拖拽

  constructor(deductionData: Array<T> = [], accessibilityBroadcastFunc: Function | undefined = undefined) {
    this.deductionData = deductionData || [];
    this.modifier = [];
    if (accessibilityBroadcastFunc) {
      this.accessibilityBroadcastFunc = accessibilityBroadcastFunc;
    }
    deductionData.forEach(() => {
      this.modifier.push(new ListItemModifier());
    })
  }

  /**
   * 获取ListItem的属性
   * @param item
   * @returns 返回自定义属性对象
   */
  getModifier(item: T): ListItemModifier {
    const index: number = this.deductionData.indexOf(item);
    if (index === -1) { // 如果没找到，返回
      return new ListItemModifier();
    }
    return this.modifier[index];
  }

  /**
   * ListItem长按函数
   */
  onLongPress(item: T): void {
    this.dragRefOffset = 0;
    const index: number = this.deductionData.indexOf(item);
    if (index === -1) { // 如果没找到，返回
      return;
    }
    // 长按触发放大效果，放大1.05倍
    this.modifier[index].scale = 1.05;
  }

  /**
   * ListItem移动函数
   * @param item
   * @param offsetY
   */
  onMove(item: T, offsetY: number): void {
    const index: number = this.deductionData.indexOf(item);
    if (index === -1) { // 如果没找到，返回
      return;
    }
    this.offsetY = offsetY - this.dragRefOffset;
    const direction: number = this.offsetY > 0 ? Direction.DOWN : Direction.UP;
    if ((index === 0 && direction === Direction.UP) ||
      (index === this.deductionData.length - 1 && direction === Direction.DOWN)) {
      this.modifier[index].offsetY = 0;
      return;
    }
    this.modifier[index].offsetY = this.offsetY;
    // 触发拖动时，被覆盖子组件缩小与恢复的动画
    if (Math.abs(this.offsetY) > ITEM_HEIGHT / 2) {
      animateTo({ curve: Curve.Friction, duration: ANIMATE_DURATION }, () => {
        this.offsetY -= direction * ITEM_HEIGHT;
        this.dragRefOffset += direction * ITEM_HEIGHT;
        this.modifier[index].offsetY = this.offsetY;
        const target = index + direction // 目标位置索引
        if (target !== -1 && target <= this.modifier.length) {
          this.changeItem(index, target, direction);
        }
      })
    }
  }

  /**
   * ListItem放置函数
   * @param item
   */
  onDrop(item: T): void {
    const index: number = this.deductionData.indexOf(item);
    this.dragRefOffset = 0;
    this.offsetY = 0;
    if (index === -1) { // 如果没找到，返回
      return;
    }
    /**
     * 恢复拖动中，被缩小的子组件，并提供动画。
     * 通过interpolatingSpring(0, 1, 400, 38)构造插值器弹簧曲线对象初始速度为0，质量为1，刚度为400，阻尼为38
     */
    animateTo({ curve: curves.interpolatingSpring(0, 1, 400, 38) }, () => {
      this.state = OperationStatus.DROPPING;
    })
    /**
     * 恢复被拖拽子组件的放大与阴影效果，并提供动画。
     * 通过interpolatingSpring(0, 1, 400, 38)构造插值器弹簧曲线对象初始速度为14，质量为1，刚度为170，阻尼为17
     */
    animateTo({ curve: curves.interpolatingSpring(14, 1, 170, 17) }, () => {
      this.state = OperationStatus.IDLE;
      this.modifier[index].offsetY = 0; // 初始化偏移量
      // 停止拖动，缩放值还原成倍数1
      this.modifier[index].scale = 1;
    })
  }

  /**
   * Item交换位置
   * @param index
   * @param newIndex
   */
  changeItem(index: number, newIndex: number, direction: Direction): void {
    const target: T = this.deductionData[newIndex];
    const tmp: T[] = this.deductionData.splice(index, 1);
    this.deductionData.splice(newIndex, 0, tmp[0]);
    const tmp2: ListItemModifier[] = this.modifier.splice(index, 1);
    this.modifier.splice(newIndex, 0, tmp2[0]);
    this.isDown = direction === Direction.DOWN;
    this.targetSource = target;
    if (!this.accessibilityBroadcastFunc) {
      HiLog.warn(TAG, 'changeItem accessibilityBroadcastFunc is undefined');
      return;
    }
    this.accessibilityBroadcastFunc(target, this.isDown, DragStatus.DRAGGING);
  }

  // 拖拽结束后无障碍播报
  dragEndAccessibilityBroadcast() {
    if (!this.accessibilityBroadcastFunc) {
      HiLog.warn(TAG, 'dragEndAccessibilityBroadcast accessibilityBroadcastFunc is undefined');
      return;
    }
    this.accessibilityBroadcastFunc(this.targetSource, this.isDown, DragStatus.DRAG_END);
    this.targetSource = undefined;
  }
}