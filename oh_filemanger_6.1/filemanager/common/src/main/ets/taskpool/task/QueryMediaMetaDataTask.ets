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

import TaskPool from '@ohos.taskpool';
import common from '@ohos.app.ability.common';
import { MediaMetaData } from '../../media/MediaMetaData';
import { MediaMetaDataUtil } from '../../media/MediaMetaDataUtil';
import { BaseTask } from '../base/BaseTask';
import { TaskPoolName } from '../const/TaskConst';
import { FileInfo } from '../../fileoperate/FileInfo';
import { GlobalHolder } from '../../global/GlobalHolder';
import FileMimeTypeUtil from '../../utils/FileMimeTypeUtil';
import { HiLog } from '../../dfx/HiLog';
import { JSON } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';

/* instrument ignore file */

const TAG = 'QueryMediaMetaDataTask';

/**
 * 查询媒体文件的信息
 */
export class QueryMediaSizeAndDurationTask extends BaseTask {
  constructor(callback: Function, fileData: FileInfo) {
    super(TaskPoolName.MEDIA_SIZE_AND_DURATION_QUERY);
    const uri = fileData.uri;
    this.task = new TaskPool.Task(
      queryMediaSizeAndDurationTask,
      uri,
      fileData.size,
      fileData.mimeTypeObj.fileCategory
    );
    this.callback = callback;
  }
}

/**
 * 查询媒体文件元数据
 * @param fileUri 文件uri
 * @param cacheFileNameStr 缩略图缓存的文件名
 * @param fileCategory
 * @returns
 */
@Concurrent
async function queryMediaSizeAndDurationTask(fileUri: string, fileSize: number, fileCategory: number,
  context: common.UIAbilityContext): Promise<MediaMetaData> {
  GlobalHolder.getInstance().setMainAbilityContext(context);
  return await MediaMetaDataUtil.getMediaSizeAndDuration(fileUri, fileSize, fileCategory);
}

/**
 * 查询图片文件尺寸数据
 */
export class QueryImageSizeTask extends BaseTask {
  constructor(callback: Function, fileData: FileInfo) {
    super(TaskPoolName.IMAGE_SIZE_DATA_QUERY);
    const uri = fileData.uri;
    this.task = new TaskPool.Task(
      queryImageSizeTask,
      uri,
      fileData.size
    );
    this.callback = callback;
  }
}

/**
 * 查询图片文件尺寸信息
 * @param fileUri 文件uri
 * @returns
 */
@Concurrent
async function queryImageSizeTask(fileUri: string, fileSize: number): Promise<MediaMetaData> {
  const metaData: MediaMetaData = await MediaMetaDataUtil.getImageSizeData(fileUri, fileSize);
  return metaData;
}