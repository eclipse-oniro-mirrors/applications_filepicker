/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import type { UIContext } from '@kit.ArkUI';

export class UiContextUtil {

  private static uiContext: UIContext;

  /**
   * 设置当前窗口的UIContext
   * @param context
   */
  public static setUiContext(context: UIContext): void {
    this.uiContext = context;
  }

  /**
   * 解决底层storage串窗口问题
   * @param taskFn
   */
  public static runScopedTask(taskFn: () => void): void {
    this.uiContext.runScopedTask(() => taskFn());
  }
}