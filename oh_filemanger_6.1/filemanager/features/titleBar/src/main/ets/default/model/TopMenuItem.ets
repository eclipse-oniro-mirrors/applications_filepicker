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
import { TopMenuDivider } from '@ohos/common/src/main/ets/const/Constant';

export class TopMenuItem {
  public icon?: Resource;
  public action?: Function;
  public type?: string;
  public name?: Resource;
  public dividerType?: TopMenuDivider;

  public constructor(icon?: Resource, action?: Function, name?: Resource, type?: string, dividerType?: TopMenuDivider) {
    this.icon = icon;
    this.action = action;
    this.name = name;
    this.type = type;
    this.dividerType = dividerType
  }
}