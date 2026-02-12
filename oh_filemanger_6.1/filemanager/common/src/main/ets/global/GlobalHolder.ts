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
import lazy { ObjectUtil } from '../utils/ObjectUtil';
import type common from '@ohos.app.ability.common';
import { uiExtensionHost } from '@kit.ArkUI';

/**
 * 获取全局缓存
 */
export class GlobalHolder {

  private static instance: GlobalHolder = null;

  private commonContext: common.Context = null;

  private appContext: common.ApplicationContext = null;

  private mainAbilityContext: common.UIAbilityContext = null;

  private extensionContext: common.ServiceExtensionContext = null;

  private uiExtensionContext: common.UIExtensionContext = null;

  private _windowProxy: uiExtensionHost.UIExtensionHostWindowProxy = null;

  private _shareExtensionContext: common.ExtensionContext = null;

  private _abilityStageContext: common.AbilityStageContext = null;

  public set abilityStageContext(value: common.AbilityStageContext) {
    this._abilityStageContext = value;
  }

  public get abilityStageContext(): common.AbilityStageContext {
    return this._abilityStageContext;
  }

  public setShareExtensionContext(value: common.ExtensionContext): void {
    this._shareExtensionContext = value;
  }

  public getShareExtensionContext(): common.ExtensionContext {
    return this._shareExtensionContext;
  }

  public set windowProxy(value: uiExtensionHost.UIExtensionHostWindowProxy) {
    this._windowProxy = value;
  }

  public get windowProxy(): uiExtensionHost.UIExtensionHostWindowProxy {
    return this._windowProxy;
  }

  private globalObjects = new Map<string, unknown>();

  private constructor() {

  }

  public static getInstance(): GlobalHolder {
    if (ObjectUtil.isNullOrUndefined(this.instance)) {
      GlobalHolder.instance = new GlobalHolder();
    }
    return GlobalHolder.instance;
  }

  public setCommonContext(context: common.Context): void {
    this.commonContext = context;
  }

  public getCommonContext(): common.Context {
    return this.commonContext;
  }

  public setAppContext(context: common.ApplicationContext): void {
    this.appContext = context;
  }

  public getAppContext(): common.ApplicationContext {
    return this.appContext;
  }

  public setMainAbilityContext(context: common.UIAbilityContext): void {
    this.mainAbilityContext = context;
  }

  public getMainAbilityContext(): common.UIAbilityContext {
    return this.mainAbilityContext;
  }

  public setExtensionContext(context: common.ServiceExtensionContext): void {
    this.extensionContext = context;
  }

  public getExtensionContext(): common.ServiceExtensionContext {
    return this.extensionContext;
  }

  public setUIExtensionContext(context: common.UIExtensionContext): void {
    this.uiExtensionContext = context;
  }

  public getUIExtensionContext(): common.UIExtensionContext {
    return this.uiExtensionContext;
  }

  public getObject<T>(key: string): T {
    return this.globalObjects.get(key) as T;
  }

  public setObject<T>(key: string, objectClass: T): void {
    this.globalObjects.set(key, objectClass);
  }

  public deleteObject(key: string): void {
    this.globalObjects.delete(key);
  }

  public hasObject(key: string): boolean {
    return this.globalObjects.has(key);
  }
}