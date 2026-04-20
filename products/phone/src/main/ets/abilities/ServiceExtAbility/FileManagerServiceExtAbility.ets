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
import { GlobalHolder, GlobalKey, HiLog, TaskManager, } from '@ohos/common';
import {
  FileManagerServiceOperationTask
} from '@ohos/common/src/main/ets/taskpool/task/FileManagerServiceOperationTask';
import ServiceExtensionAbility from '@ohos.app.ability.ServiceExtensionAbility';
import Want from '@ohos.app.ability.Want';
import { BusinessError } from '@ohos.base';
import rpc from '@ohos.rpc';

const TAG: string = 'FileManagerServiceExtAbility';
const REQUEST_TOKEN: string = 'com.ohos.filemanager.FileManagerServiceExtAbility';
const MAX_NUM: number = 2000;

export default class FileManagerServiceExtAbility extends ServiceExtensionAbility {
  onCreate(want: Want): void {
    if (!want || !want.parameters) {
      HiLog.warn(TAG, 'invalid want');
      this.terminate();
      return;
    }
    HiLog.info(TAG, `onCreate, want: ${want.abilityName}`);
  }

  async onConnect(want: Want): Promise<rpc.RemoteObject> {
    if (!want || !want.parameters) {
      HiLog.warn(TAG, 'invalid want');
      this.terminate();
    }
    HiLog.info(TAG, `onConnect, want: ${want.abilityName}`);
    let remoteObj: RemoteObjectHandler = new RemoteObjectHandler('FileManagerServiceExtAbility');
    this.saveContext();
    return remoteObj;
  }

  onRequest(want: Want, startId: number): void {
    if (!want || !want.parameters) {
      HiLog.warn(TAG, 'invalid want');
      this.terminate();
      return;
    }
    HiLog.info(TAG, `onRequest, want: ${want.abilityName}`);
    this.saveContext();
  }

  terminate(): void {
    this.context.terminateSelf().then(() => {
      HiLog.warn(TAG, 'terminateSelf success');
    }).catch((err: BusinessError) => {
      HiLog.error(TAG, `terminateSelf failed, err: ${err}`);
    })
  }

  onDisconnect(want: Want): void {
    if (!want || !want.parameters) {
      HiLog.warn(TAG, 'invalid want');
      this.terminate();
    }
    HiLog.info(TAG, `onDisconnect, want: ${want.abilityName}`);
  }

  onDestroy(): void {
    if (GlobalHolder.getInstance().hasObject(GlobalKey.FILE_MANAGER_SERVICE_CONTEXT)) {
      GlobalHolder.getInstance().deleteObject(GlobalKey.FILE_MANAGER_SERVICE_CONTEXT);
    }
    HiLog.info(TAG, `onDestroy`);
  }

  /**
   * 保存上下文信息
   */
  private saveContext(): void {
    GlobalHolder.getInstance().setObject(GlobalKey.FILE_MANAGER_SERVICE_CONTEXT, this.context);
    GlobalHolder.getInstance().setAppContext(this.context.getApplicationContext());
    GlobalHolder.getInstance().setCommonContext(this.context);
  }
}

class RemoteObjectHandler extends rpc.RemoteObject {
  constructor(des: string) {
    super(des);
  }

  // 接收客户端传递过来的消息处理，以及将处理的结果返回给客户端
  async onRemoteMessageRequest(code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence,
    option: rpc.MessageOption): Promise<boolean> {
    try {
      if (data.readInterfaceToken() !== REQUEST_TOKEN) {
        HiLog.warn(TAG, `token is invalid, onRemoteMessageRequest end`);
        return false;
      }
      let num: number = data.readInt();
      if (num < 0 || num > MAX_NUM) {
        HiLog.warn(TAG, `onRemoteMessageRequest num < 0 or num > 2000`);
        return false;
      }
      let argsArray: string[] = [];
      for (let i: number = 0; i < num; i++) {
        let args: string = data.readString();
        argsArray.push(args);
      }
      let task = new FileManagerServiceOperationTask(argsArray, () => {});
      TaskManager.getInstance().executeTask(task);
      return true;
    } catch (e) {
      HiLog.error(TAG, `onRemoteMessageRequest error: ${JSON.stringify(e)}`);
      return false;
    }
  }
}