/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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

import common from '@ohos.app.ability.common';
import { HiLog } from '../../dfx/HiLog';
import image from '@ohos.multimedia.image';
import { ThumbnailUtil } from '../../utils/ThumbnailUtil';
import { TraceUtils } from '../../dfx/TraceUtils';
import { HiTraceConst } from '../../const/HiTraceConst';

const TAG: string = 'ResourceCached';
const CACHED_IMAGE_WIDTH: number = 320;
const CACHED_IMAGE_HEIGHT: number = 320;

export class ResourceCacheUtil {
  public static async CreateCacheResource(context: common.Context): Promise<Map<string, image.PixelMap>> {
    HiLog.info(TAG, 'CreateCacheResource start');
    TraceUtils.startTrace(HiTraceConst.CREATE_CACHE_RESOURCE);
    let resourceMap: Map<string, image.PixelMap> = new Map();
    for (let key of ThumbnailUtil.thumbnailMap.keys()) {
      let resourceValue = ThumbnailUtil.thumbnailMap.get(key) as Resource;
      let resourcePixel = await ResourceCacheUtil.getResourceCached(resourceValue, context);
      if (resourcePixel === undefined) {
        continue;
      }
      resourceMap.set(key, resourcePixel);
    }
    TraceUtils.finishTrace(HiTraceConst.CREATE_CACHE_RESOURCE);
    HiLog.info(TAG, 'CreateCacheResource end');
    return resourceMap;
  }

  private static async getResourceCached(resourceValue: Resource, context: common.Context):
    Promise<image.PixelMap | undefined> {
    let imageSource: image.ImageSource | undefined = undefined;
    try {
      let data = context.resourceManager.getMediaContentSync(resourceValue.id);
      const arrayBuffer = data.buffer.slice(data.byteOffset, data.byteLength + data.byteOffset);
      imageSource = image.createImageSource(arrayBuffer);
      let imageInfo = imageSource?.getImageInfoSync(0);
      const bigSizeSide = Math.max(imageInfo.size.height, imageInfo.size.width);
      let scale = 1.0;
      let height = CACHED_IMAGE_HEIGHT;
      let width = CACHED_IMAGE_WIDTH;
      if (imageInfo.size.height === 0 || imageInfo.size.width === 0) {
        return undefined;
      }
      if (imageInfo.size.height > imageInfo.size.width) {
        scale = CACHED_IMAGE_WIDTH / bigSizeSide
        width = imageInfo.size.width * scale;
      } else if (imageInfo.size.height < imageInfo.size.width) {
        scale = CACHED_IMAGE_HEIGHT / bigSizeSide
        height = imageInfo.size.height * scale;
      }

      let opts: image.DecodingOptions = {
        editable: true,
        desiredSize: {
          height: height,
          width: width
        }
      };
      const imagePixelMap = await imageSource?.createPixelMap(opts);
      return imagePixelMap;
    } catch (error) {
      HiLog.error(TAG, `getResourceCached error ${JSON.stringify(error)}`);
    } finally {
      imageSource?.release();
    }
    return undefined;
  }
}


