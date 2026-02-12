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
import HashMap from '@ohos.util.HashMap';

// 节流防抖函数
export class ThrottlingUtil {
  private static runningMap: HashMap<string, number> = new HashMap(); // 防抖tag表
  private static delay: number = 300; // 默认防抖节流延迟时间

  /**
   * 防抖,将执行放在delay时间后触发,delay时间内再次执行则取消之前的执行重新设置delay时间后触发最新的执行
   *
   * @param tag 使用页面的TAG，作为该防抖功能在HashMap的id,方便后续清除重置
   * @param task 要限制调用的方法
   * @param delay 防抖间隔时间，默认300ms
   */
  public static debounce(tag: string, task: Function, delay: number = this.delay): void {
    if (ThrottlingUtil.runningMap.get(tag)) {
      clearTimeout(ThrottlingUtil.runningMap.get(tag));
      ThrottlingUtil.runningMap.remove(tag);
    }
    const timerId = setTimeout((): void => {
      task();
    }, delay);
    ThrottlingUtil.runningMap.set(tag, timerId);
  }
}