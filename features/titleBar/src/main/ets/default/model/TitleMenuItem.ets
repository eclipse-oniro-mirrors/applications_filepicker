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
import { MENU_ICONS } from '../constant/MenuConstant';

export class TitleMenuItem {
  public icon: Resource;
  public name?: Resource;
  public action: (param?: boolean) => void;
  public clickable: boolean;
  public isMenu?: boolean;
  public isShown?: boolean;
  public isText?: boolean;
  // 播报控件类型
  public accessibilityRoleType: AccessibilityRoleType;
  /**
   * 是否响应拖入事件
   */
  public dragEnable: boolean;
  public bindPopupKey: string;

  public constructor(icon: Resource = MENU_ICONS.back, name: Resource | undefined = undefined,
    action: () => void = () => {}, clickable: boolean = true, isMenu: boolean = false, isShown: boolean = true,
    dragEnable: boolean = false, isText: boolean = false, bindPopupKey: string = '',
    accessibilityRoleType: AccessibilityRoleType = AccessibilityRoleType.BUTTON) {
    this.icon = icon;
    this.name = name;
    this.action = action;
    this.clickable = clickable;
    this.isMenu = isMenu;
    this.isShown = isShown;
    this.dragEnable = dragEnable;
    this.isText = isText;
    this.bindPopupKey = bindPopupKey;
    this.accessibilityRoleType = accessibilityRoleType;
  }

  public setBindPopupKey(bindPopupKey: string) {
    this.bindPopupKey = bindPopupKey;
  }
}