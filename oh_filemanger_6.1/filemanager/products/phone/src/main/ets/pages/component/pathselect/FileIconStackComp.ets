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

import { ArrayUtil, ThumbnailUtil, FileDefaultIconUtil, FileInfo, HiLog } from '@ohos/common';

const TAG: string = 'FileIconStackComp';

@Component
export struct FileIconStackComp {
  @Prop selectFilesList: FileInfo[] = [];
  @Prop isSaveFile: boolean = false;
  @StorageProp('isDarkMode') isDarkMode: boolean = false;
  @Prop @Watch('onIsOutsideFoldedChange') isOutsideFolded: boolean = false;
  @State firstImageSize: Resource = $r('app.float.common_size52');
  @State secondImageSize: Resource = $r('app.float.common_size44');
  @State firstUseCachedImage: boolean = false;
  @State secondUseCachedImage: boolean = false;

  aboutToAppear() {
    this.initData();
  }

  initIconSize() {
    if (this.isOutsideFolded) {
      this.firstImageSize = $r('app.float.common_size35');
      this.secondImageSize = $r('app.float.common_size30');
    } else {
      this.firstImageSize = $r('app.float.common_size52');
      this.secondImageSize = $r('app.float.common_size44');
    }
  }

  onIsOutsideFoldedChange() {
    this.initIconSize();
  }

  initData(): void {
    this.firstUseCachedImage = this.selectFilesList[0]?.useCacheImage ?? false;
    this.secondUseCachedImage = this.selectFilesList[1]?.useCacheImage ?? false;
    // 拉起路径选择器保存文件场景只展示默认图标
    if (this.isSaveFile) {
      return;
    }
    if (ArrayUtil.isEmpty(this.selectFilesList)) {
      return;
    }
    this.initIconSize();
  }

  /**
   * 获取文件默认图标
   * @param fileInfo 文件信息
   * @returns 文件图标
   */
  getDefaultIcon(fileInfo: FileInfo): Resource {
    if (!fileInfo.isFolder) {
      return ThumbnailUtil.getDefaultIconByType(fileInfo.thumbnailType);
    }
    // 文件夹暂时从这里取, 文件夹有深色模式区分
    const fileDefaultIconObj = FileDefaultIconUtil.getFileDefaultIconObj(
      fileInfo.fileName, fileInfo.isFolder, fileInfo.subFileCount)
    return this.isDarkMode ? fileDefaultIconObj.getDark() : fileDefaultIconObj.getLight()
  }

  getMarginBottom(): Resource {
    if (this.isOutsideFolded) {
      return $r('app.float.common_size0');
    }
    return (this.selectFilesList[1].isFolder && !this.selectFilesList[0].isFolder) ? $r('app.float.common_margin30') :
      $r('app.float.common_margin16');
  }

  build() {
    Stack() {
      if (this.selectFilesList.length > 1) {
        if (this.secondUseCachedImage) {
          MediaCachedImage(ThumbnailUtil.getFileIconCompThumbnailUri(this.selectFilesList[1]))
            .objectFit(ImageFit.Cover)
            .alt(this.getDefaultIcon(this.selectFilesList[1]))
            .interpolation(ImageInterpolation.High)
            .width(this.secondImageSize)
            .height(this.secondImageSize)
            .margin({
              bottom: this.getMarginBottom()
            })
            .opacity($r('app.float.common_opacity7'))
            .borderRadius($r('app.float.common_borderRadius4'))
            .draggable(false)
            .onError((error) => {
              HiLog.errorPrivate(TAG, `MediaCachedImage fail, error: ${error?.message}`,
                `uri:${this.selectFilesList[1]?.uri}`);
              this.secondUseCachedImage = false;
            })
        } else {
          Image('')
            .objectFit(ImageFit.Contain)
            .alt(this.getDefaultIcon(this.selectFilesList[1]))
            .interpolation(ImageInterpolation.High)
            .renderMode(ImageRenderMode.Original)
            .width(this.secondImageSize)
            .height(this.secondImageSize)
            .margin({
              bottom: this.getMarginBottom()
            })
            .opacity($r('app.float.common_opacity7'))
            .borderRadius($r('app.float.common_borderRadius4'))
            .draggable(false)
        }
      }

      if (this.selectFilesList.length) {
        if (this.firstUseCachedImage) {
          MediaCachedImage(ThumbnailUtil.getFileIconCompThumbnailUri(this.selectFilesList[0]))
            .objectFit(ImageFit.Cover)
            .alt(this.getDefaultIcon(this.selectFilesList[0]))
            .interpolation(ImageInterpolation.High)
            .renderMode(ImageRenderMode.Original)
            .width(this.firstImageSize)
            .height(this.firstImageSize)
            .draggable(false)
            .borderRadius($r('app.float.common_borderRadius4'))
            .onError((error) => {
              HiLog.errorPrivate(TAG, `MediaCachedImage fail, error: ${error?.message}`,
                `uri:${this.selectFilesList[0]?.uri}`);
              this.firstUseCachedImage = false;
            })
        } else {
          Image('')
            .objectFit(ImageFit.Contain)
            .alt(this.getDefaultIcon(this.selectFilesList[0]))
            .interpolation(ImageInterpolation.High)
            .renderMode(ImageRenderMode.Original)
            .width(this.firstImageSize)
            .height(this.firstImageSize)
            .draggable(false)
            .borderRadius($r('app.float.common_borderRadius4'))
        }
      }
    }
  }
}