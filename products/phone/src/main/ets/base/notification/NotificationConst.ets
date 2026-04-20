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

export namespace NotificationConst {
  /**
   * 发送通知栏消息时的消息id
   */
  export enum NotificationId {
    COPY_CUT_RUNNING = 1,
    COPY_CUT_END = 2
  }

  /**
   * 通知消息的组
   */
  export enum NotificationGroup {
    FILE_OPERATE = 'fileOperation'
  }
}


export enum OperationType {
  /**
   * 打开指定目录
   * */
  OPEN_FOLDER = 'openFolder'
}
/**
 * 拉起应用并执行指定操作时需传的基础参数
 * */
export class BaseParam {
  public operationType: OperationType;

  constructor(operationType: OperationType) {
    this.operationType = operationType;
  }
}

/**
 * 拉起应用并打开指定目录时需传的参数
 * */
export class OpenFolderParam extends BaseParam {
  folderUri: string;
  fileUriArray: string[];
  from: StartAbilityFrom;

  constructor(folderUri: string, fileUriArray: string[], from: StartAbilityFrom) {
    super(OperationType.OPEN_FOLDER);
    this.folderUri = folderUri;
    this.fileUriArray = fileUriArray;
    this.from = from;
  }
}

export enum StartAbilityFrom {
  /**
   * 通知栏消息
   */
  COPY_CUT_NOTIFICATION = 'copyCutNotification',
  /**
   * 第三方app
   */
  THIRD_APP = 'thirdApp'
}

