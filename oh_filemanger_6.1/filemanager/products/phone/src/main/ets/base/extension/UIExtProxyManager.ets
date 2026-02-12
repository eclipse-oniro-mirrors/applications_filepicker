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
import { SendData } from './model/SendDataModel';
import { EventConst } from './const/EventConst';
import { HiLog, ObjectUtil } from '@ohos/common';

const TAG = 'UIExtProxyManager'

export class UIExtProxyManager {
  private static instance: UIExtProxyManager
  private proxy?: UIExtensionProxy

  public static getInstance(): UIExtProxyManager {
    if (ObjectUtil.isNullOrUndefined(UIExtProxyManager.instance)) {
      UIExtProxyManager.instance = new UIExtProxyManager();
    }
    return UIExtProxyManager.instance
  }

  /**
   * 保存加载UIExtension的Proxy实例
   */
  public setProxy(proxy: UIExtensionProxy): void {
    this.proxy = proxy
  }

  /**
   * 向UIExtension发消息
   */
  private sendData(data: SendData): void {
    if (!this.proxy) {
      HiLog.warn(TAG, 'proxy is null')
      return;
    }
    this.proxy.send({
      data: data
    })
  }

  /**
   * 向UIExtension发送宿主应用的navMode变更事件
   */
  public navModeChange(navMode: NavigationMode): void {
    if (ObjectUtil.isNullOrUndefined(navMode)) {
      return
    }
    this.sendData({
      event: EventConst.NAV_MODE_CHANGE,
      data: navMode
    })
  }
}