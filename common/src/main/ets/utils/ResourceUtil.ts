/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import type context from '@ohos.app.ability.common';
import { HiLog } from '../dfx/HiLog';
import { GlobalHolder } from '../global/GlobalHolder';
import type { BusinessError } from '@ohos.base';
import { ObjectUtil } from './ObjectUtil';
import common from '@ohos.app.ability.common';
import { VirtualUri } from '../const/FolderRecord';
import { fileUri } from '@kit.CoreFileKit';
import { FsUtil } from './FsUtil';
import fs from '@ohos.file.fs';

const TAG: string = 'ResourceUtil';

export class ResourceUtil {
  private static context: context.ApplicationContext;

  public static getContext(): context.ApplicationContext {
    if (ObjectUtil.isNullOrUndefined(ResourceUtil.context)) {
      ResourceUtil.context = GlobalHolder.getInstance().getAppContext();
    }
    return ResourceUtil.context;
  }

  public static updateContext(context: context.ApplicationContext): void {
    ResourceUtil.context = context;
  }

  // @ts-ignore
  public static getStringByResource(resource: Resource, context?: context.Context): string {
    if (!resource) {
      HiLog.error(TAG, 'getStringByResource err: resource is undefined or null');
      return '';
    }
    if (resource.params && (resource.params.length > 0)) {
      return ResourceUtil.getFormatStringByResource(resource, context);
    }
    try {
      if (!context) {
        return ResourceUtil.getContext().resourceManager.getStringSync(resource.id);
      } else {
        return context.resourceManager.getStringSync(resource.id);
      }
    } catch (err) {
      const message = (err as BusinessError).message;
      HiLog.error(TAG, 'getStringByResource err: ' + message);
    }
    return '';
  }

  public static getResourceNumberById(resourceId: number): number {
    try {
      return ResourceUtil.getContext().resourceManager.getNumber(resourceId);
    } catch (e) {
      HiLog.error(TAG, `getResourceNumberById: error ${e?.code}, ${e?.message}`);
      return 0;
    }
  }

  private static getFormatStringByResource(resource: Resource, context?: context.Context): string {
    try {
      if (!context) {
        return ResourceUtil.getContext().resourceManager.getStringSync(resource.id, ...resource.params);
      } else {
        return context.resourceManager.getStringSync(resource.id, ...resource.params);
      }
    } catch (err) {
      const message = (err as BusinessError).message;
      HiLog.error(TAG, 'getFormatStringByResource err: ' + message);
    }
    return '';
  }

  // @ts-ignore
  public static getColorByResource(resource: Resource, context?: context.Context): number {
    try {
      if (!context) {
        return ResourceUtil.getContext().resourceManager.getColorSync(resource.id);
      } else {
        return context.resourceManager.getColorSync(resource.id);
      }
    } catch (err) {
      HiLog.error(TAG, `getColorByResource err:  + ${err?.message}`);
    }
    return 0;
  }

  /*
   * 根据传入的一个参数获取指定ID字符串表示的格式化字符串
   * */
  //@ts-ignore
  public static getStringByOneParamResource(resource: Resource, param: string | number): string {
    try {
      return ResourceUtil.getContext().resourceManager.getStringSync(resource.id, param);
    } catch (err) {
      let message = (err as BusinessError).message;
      HiLog.error(TAG, 'getStringByOneParamResource err: ' + message);
    }
    return '';
  }

  /*
   * 根据传入的两个参数获取指定ID字符串表示的格式化字符串
   * */
  //@ts-ignore
  public static getStringByDoubleParamResource(resource: Resource, param1: string, param2: string): string {
    try {
      return ResourceUtil.getContext().resourceManager.getStringSync(resource.id, param1, param2);
    } catch (err) {
      let message = (err as BusinessError).message;
      HiLog.error(TAG, 'getStringByDoubleParamResource err: ' + message);
    }
    return '';
  }

  /**
   * 根据传入的三个参数获取指定ID字符串表示的格式化字符串
   */
  // @ts-ignore
  public static getStringByThreeParamResource(resource: Resource, param1: string, param2: string, param3: string): string {
    try {
      return ResourceUtil.getContext().resourceManager.getStringSync(resource.id, param1, param2, param3);
    } catch (err) {
      let message = (err as BusinessError).message;
      HiLog.error(TAG, 'getStringByThreeParamResource err: ' + message);
    }
    return '';
  }

  /*
   * 根据指定数量获取指定ID字符串表示的单复数字符串
   * */
  //@ts-ignore
  public static async getStringByPluralParamResource(resource: Resource, param: number): Promise<string> {
    try {
      return await ResourceUtil.getContext().resourceManager.getPluralStringValue(resource.id, param);
    } catch (err) {
      let message = (err as BusinessError).message;
      HiLog.error(TAG, 'getStringByPluralParamResource err: ' + message);
    }
    return '';
  }

  /*
   * 同步根据指定数量获取指定ID字符串表示的单复数字符串
   * */
  // @ts-ignore
  public static getStringByPluralParamResourceSync(resource: Resource, param: number): string {
    try {
      return ResourceUtil.getContext().resourceManager.getPluralStringValueSync(resource.id, param);
    } catch (err) {
      let message = (err as BusinessError).message;
      HiLog.error(TAG, 'getStringByPluralParamResourceSync err: ' + message);
    }
    return '';
  }

  //@ts-ignore
  public static getStringByResourceOrString(item: Resource | string): string {
    let res: string = '';
    if (typeof item !== 'string') {
      res = ResourceUtil.getStringByResource(item);
    } else {
      res = item;
    }
    return res;
  }

  /**
   * 通过资源名称获取字符串
   * @param name 资源名称
   * @returns 字符串
   */
  public static getStringByName(name: string, context?: common.UIAbilityContext): string {
    let result = '';
    try {
      if (!context) {
        result = ResourceUtil.getContext().resourceManager.getStringByNameSync(name);
      } else {
        result = context.resourceManager.getStringByNameSync(name);
      }
    } catch (err) {
      HiLog.error(TAG, 'getStringByName error: ' + err);
    }
    return result;
  }

  /**
   * 将Resource转成复数字符串
   * */
  //@ts-ignore
  public static getPluralStringValue(resource: Resource, num: number, ...args: Array<string | number>): string {
    try {
      return ResourceUtil.getContext().resourceManager.getIntPluralStringValueSync(resource.id, num, ...args);
    } catch (error) {
      HiLog.error(TAG, `getPluralStringValue fail, error.code ${error?.code} error.message: ${error?.message}`);
    }
    return '';
  }
}