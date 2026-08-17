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
 * 要发送的数据
 */
export interface SendData {
  event: string
  data: unknown
}

/**
 * 发送跳转页面事件时需要传递的数据
 */
export class JumpPageData {
  pageName: string = '';
  params?: unknown = null;
  animated?: boolean = true;
}

/**
 * 发送复制移动进度通知时需要的数据
 */
export class CopyCutProgressData {
  folderUri: string = '';
  progress: number = 0;
  deliveryTime: number = 0;
  operatingFileName: string = '';
  operateType?: CopyCutProgressType;
  selectCount?: number = 0;
  destFolderName?: string = '';
}

/**
 * 复制移动进度类型
 */
export enum CopyCutProgressType {
  COPY,
  MOVE
}

/**
 * 发送复制移动完成通知时需要的数据
 */
export class CopyCutCompleteData {
  folderUri: string = '';
  title: string = '';
  text: string = '';
  isCancel: boolean = false;
  operateType?: CopyCutProgressType;
  destFolderName?: string = '';
  selectCount?: number = 0;
}

export class CopyCutExceptionData {
  folderUri: string;
  deliveryTime: number = 0;
}

/**
 * 发送打开指定目录时需传的数据
 */
export class OpenFolderData {
  folderUri: string;
  fileUriArray: string[];
  from: string;
}

/**
 * 发送进入沉浸式时需传的数据
 */
export class ImmersiveData {
  isPreviewMode: boolean;
  isFullScreen: boolean;
}