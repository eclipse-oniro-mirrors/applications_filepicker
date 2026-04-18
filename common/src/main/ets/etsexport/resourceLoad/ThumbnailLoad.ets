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

import image from '@ohos.multimedia.image';
import { HiLog } from '../../dfx/HiLog';
import { FileInfo } from '../../fileoperate/FileInfo';
import { TaskManager } from '../../taskpool/manager/TaskManager';
import { ResourceCachingTask } from '../../taskpool/task/ResourceLoadTask';
import { ThumbnailUtil } from '../../utils/ThumbnailUtil';

const TAG: string = 'ThumbnailLoad';

export class ThumbnailLoad {
  public static resourcePixelMap: Map<string, image.PixelMap> = new Map();
  private static isInited: boolean = false;

  public static initPixelMapResource(): void {
    HiLog.info(TAG, 'initPixelMap start');
    if (ThumbnailLoad.resourcePixelMap.size !== 0) {
      return;
    }

    if (ThumbnailLoad.isInited) {
      HiLog.info(TAG, 'The resource has been initialized.');
      return;
    }
    ThumbnailLoad.isInited = true;
    let taskResource: ResourceCachingTask = new ResourceCachingTask((resourcePixelMap: Map<string, image.PixelMap>) => {
      HiLog.info(TAG, `initPixelMap end, size : ${resourcePixelMap.size}`);
      ThumbnailLoad.resourcePixelMap = resourcePixelMap;
    });
    HiLog.info(TAG, 'initPixelMap ResourceCachingTask');
    TaskManager.getInstance().executeTask<Map<string, image.PixelMap>>(taskResource);
  }

  public static getImageThumbnailBySuffix(suffix: string): Resource | image.PixelMap {
    const thumbnailType: string = ThumbnailUtil.getThumbnailTypeBySuffix(suffix);
    return ThumbnailLoad.getImageThumbnailByType(thumbnailType);
  }

  public static getImageThumbnailByType(thumbnailType: string): Resource | image.PixelMap {
    // 如果未缓存，查询返回Resource
    if (ThumbnailLoad.resourcePixelMap.size === 0) {
      if (ThumbnailUtil.thumbnailMap.has(thumbnailType)) {
        return ThumbnailUtil.thumbnailMap.get(thumbnailType) as Resource;
      }
      return $r('app.media.ic_normal_unknown');
    }
    // 如果缓存中有对应类型，返回pixelMap
    if (ThumbnailLoad.resourcePixelMap.has(thumbnailType)) {
      return ThumbnailLoad.resourcePixelMap.get(thumbnailType) as image.PixelMap;
    }
    // 找不到的类型，返回unknown对应的pixelMap
    if (ThumbnailLoad.resourcePixelMap.get(ThumbnailUtil.UNKNOWN_TYPE)) {
      return ThumbnailLoad.resourcePixelMap.get(ThumbnailUtil.UNKNOWN_TYPE) as image.PixelMap;
    } else {
      return $r('app.media.ic_normal_unknown');
    }
  }
}