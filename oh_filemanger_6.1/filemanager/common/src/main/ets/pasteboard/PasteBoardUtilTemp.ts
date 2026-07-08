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
import { pasteboard } from '@kit.BasicServicesKit';
import { HiLog } from '../dfx/HiLog';

const TAG: string = 'PasteBoardUtilTemp';

// todo 底座的修改还未更新归档到最新sdk，在ts文件中使用ts-ignore暂时屏蔽
export class PasteBoardUtilTemp {
  // 发起关闭p2p通道请求
  public static pasteComplete(pasteData: pasteboard.PasteData): void {
    if (!pasteData) {
      HiLog.info(TAG, 'pasteData is null or undefined');
      return;
    }
    try {
      // @ts-ignore
      pasteData.pasteComplete();
    } catch (error) {
      HiLog.warn(TAG, 'pasteComplete error ' + JSON.stringify(error));
    }
  }

}