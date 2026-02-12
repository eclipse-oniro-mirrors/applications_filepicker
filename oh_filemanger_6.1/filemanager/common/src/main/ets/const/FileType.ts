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
import HashSet from '@ohos.util.HashSet';

export enum MediaTypeString {
  FILE = 'file',
  IMAGE = 'image',
  VIDEO = 'video',
  AUDIO = 'audio',
  FOLDER = 'folder'
}

export class MimeTypeMap {
  private static imageMimeTypeSet: HashSet<string> = new HashSet();

  public static getImageMimeTypeSet(): HashSet<string> {
    if (this.imageMimeTypeSet.length === 0) {
      this.createImageMimetypeSet();
    }
    return this.imageMimeTypeSet;
  }

  public static createImageMimetypeSet(): void {
    this.imageMimeTypeSet.add('gif');
    this.imageMimeTypeSet.add('heic');
    this.imageMimeTypeSet.add('heics');
    this.imageMimeTypeSet.add('heifs');
    this.imageMimeTypeSet.add('bmp');
    this.imageMimeTypeSet.add('bm');
    this.imageMimeTypeSet.add('heif');
    this.imageMimeTypeSet.add('hif');
    this.imageMimeTypeSet.add('avif');
    this.imageMimeTypeSet.add('cur');
    this.imageMimeTypeSet.add('webp');
    this.imageMimeTypeSet.add('dng');
    this.imageMimeTypeSet.add('raf');
    this.imageMimeTypeSet.add('ico');
    this.imageMimeTypeSet.add('nrw');
    this.imageMimeTypeSet.add('rw2');
    this.imageMimeTypeSet.add('pef');
    this.imageMimeTypeSet.add('srw');
    this.imageMimeTypeSet.add('arw');
    this.imageMimeTypeSet.add('jpg');
    this.imageMimeTypeSet.add('jpeg');
    this.imageMimeTypeSet.add('jpe');
    this.imageMimeTypeSet.add('png');
    this.imageMimeTypeSet.add('svg');
    this.imageMimeTypeSet.add('raw');
    this.imageMimeTypeSet.add('tif');
  }
}