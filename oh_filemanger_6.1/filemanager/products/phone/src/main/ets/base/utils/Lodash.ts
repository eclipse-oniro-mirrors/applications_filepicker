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

/**
 *
 * @description 防抖
 * @param time 间隔时间
 *
 */
export function debounce(time: number = 500) {
  return (target: string, propertyKey: string, descriptor: PropertyDescriptor): PropertyDescriptor => {
    let fn = descriptor.value;
    let flag: number = 0;
    descriptor.value = function (): void {
      clearTimeout(flag);
      flag = setTimeout(() => {
        fn();
      }, time);
    };
    return descriptor;
  };
}

let lastClickTime: number = 0;

export function isFastClick(time: number = 500): boolean {
  let currentTime = Date.now();
  if ((currentTime - lastClickTime) < time) {
    lastClickTime = currentTime;
    return true;
  }
  lastClickTime = currentTime;
  return false;
}