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
import {
  afterAll,
  ArgumentMatchers,
  beforeAll,
  describe,
  expect,
  it,
  MockKit,
  when
} from '@ohos/hypium';
import fs from '@ohos.file.fs';
import { TestUtil } from '../../../test/utils/TestUtil';
import { image } from '@kit.ImageKit';
import {
  MediaThumbnailUtil,
  MediaThumbnailCacheUtil,
  HiLog, FileUtil, MediaMetaData
} from '@ohos/common';
import { media } from '@kit.MediaKit';
import { PixelMapMock } from '../../../utils/MediaMock';

const ROOT_PATH = '/storage/Users/currentUser/';
const filePath = '/storage/Users/currentUser/RecentUtilTest.jpg';
const filePathMp4 = '/storage/Users/currentUser/VideoTest.Mp4';
const FOLDER_NAME = 'test';
let folderPath = ROOT_PATH + FOLDER_NAME;
const TAG: string = 'MediaThumbnailUtilTest';

export default function MediaThumbnailUtilTest() {
  describe('MediaThumbnailUtilTest', () => {

    beforeAll(() => {
      beforeTest();
    })

    afterAll(() => {
      afterTest();
    })

    it('getThumbnailCacheFilePathTest', 0, async (done: Function) => {
      let result = await MediaThumbnailUtil.getThumbnailCacheFilePath('test', 10086);
      expect(result.length).not().assertEqual(0);
      done();
    })

    it('getThumbnailCacheFilePathTest_folderPath_isEmpty', 0, async (done: Function) => {
      const mocker: MockKit = new MockKit();
      const func = mocker.mockFunc(MediaThumbnailCacheUtil, MediaThumbnailCacheUtil.getCacheFolderPath);
      when(func)(ArgumentMatchers.any).afterReturn('');
      let result = await MediaThumbnailUtil.getThumbnailCacheFilePath('', 0);
      mocker.clear(MediaThumbnailCacheUtil);
      expect(result).assertEqual('');
      done();
    })

    it('getImageThumbnailTest', 0, async (done: Function) => {
      const imageSourceApi: image.ImageSource = image.createImageSource(filePath);
      let result = await MediaThumbnailUtil.getImageThumbnail(imageSourceApi, '/test')
      expect(result.length === 0).assertTrue();
      let mocker = new MockKit();
      let cacheThumbnail = mocker.mockFunc(MediaThumbnailCacheUtil, MediaThumbnailCacheUtil.cacheThumbnail);
      when(cacheThumbnail)(ArgumentMatchers.any).afterReturn(new Promise<boolean>((resolve) => resolve(true)));
      let mockFunc =
        mocker.mockFunc(MediaThumbnailUtil, TestUtil.getPrivateAttribute(MediaThumbnailUtil, 'processPixelMap'));
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<string>((resolve) => resolve('undefined')));
      let result1 = await MediaThumbnailUtil.getImageThumbnail(imageSourceApi, '/test')

      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<undefined>((resolve) => resolve(undefined)));
      let result2 = await MediaThumbnailUtil.getImageThumbnail(imageSourceApi, '/test')

      MediaThumbnailUtil.releaseSource(imageSourceApi);
      mocker.clear(MediaThumbnailCacheUtil);
      mocker.clear(MediaThumbnailUtil);
      expect(result1.length === 0).assertFalse();
      expect(result2.length === 0).assertFalse();
      done();
    })

    it('getImageThumbnailTest_1_test', 0, async (done: Function) => {
      const imageSourceApi: image.ImageSource = image.createImageSource(filePath);
      let result = await MediaThumbnailUtil.getImageThumbnail(imageSourceApi, '/test');
      MediaThumbnailUtil.releaseSource(imageSourceApi);
      expect(result.length === 0).assertTrue();
      done();
    })

    it('getImageThumbnailTest_2_test', 0, async (done: Function) => {
      const imageSourceApi: image.ImageSource = image.createImageSource(filePath);
      let mocker = new MockKit();
      let cacheThumbnail = mocker.mockFunc(MediaThumbnailCacheUtil, MediaThumbnailCacheUtil.cacheThumbnail);
      when(cacheThumbnail)(ArgumentMatchers.any).afterReturn(new Promise<boolean>((resolve) => resolve(true)));
      let mockFunc =
        mocker.mockFunc(MediaThumbnailUtil, TestUtil.getPrivateAttribute(MediaThumbnailUtil, 'processPixelMap'));
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<string>((resolve) => resolve('undefined')));
      let result1 = await MediaThumbnailUtil.getImageThumbnail(imageSourceApi, '/test')

      MediaThumbnailUtil.releaseSource(imageSourceApi);
      mocker.clear(MediaThumbnailCacheUtil);
      mocker.clear(MediaThumbnailUtil);
      expect(result1.length === 0).assertFalse();
      done();
    })

    it('getImageThumbnailTest_3_test', 0, async (done: Function) => {
      const imageSourceApi: image.ImageSource = image.createImageSource(filePath);
      let mocker = new MockKit();
      let cacheThumbnail = mocker.mockFunc(MediaThumbnailCacheUtil, MediaThumbnailCacheUtil.cacheThumbnail);
      when(cacheThumbnail)(ArgumentMatchers.any).afterReturn(new Promise<boolean>((resolve) => resolve(true)));
      let mockFunc =
        mocker.mockFunc(MediaThumbnailUtil, TestUtil.getPrivateAttribute(MediaThumbnailUtil, 'processPixelMap'));

      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<undefined>((resolve) => resolve(undefined)));
      let result2 = await MediaThumbnailUtil.getImageThumbnail(imageSourceApi, '/test')

      MediaThumbnailUtil.releaseSource(imageSourceApi);
      mocker.clear(MediaThumbnailCacheUtil);
      mocker.clear(MediaThumbnailUtil);
      expect(result2.length === 0).assertFalse();
      done();
    })

    it('getFullThumbnailCachePathTest', 0, async (done: Function) => {
      let result = MediaThumbnailUtil.getFullThumbnailCachePath('/test');
      expect(result.length !== 0).assertTrue();
      result = MediaThumbnailUtil.getFullThumbnailCachePath('');
      expect(result.length === 0).assertTrue();
      done();
    })

    it('getAudioCoverThumbnailTest_cacheResult_is_false', 0, async (done: Function) => {
      const mocker: MockKit = new MockKit();
      const func = mocker.mockFunc(MediaThumbnailCacheUtil, MediaThumbnailCacheUtil.cacheThumbnail);
      when(func)(ArgumentMatchers.any).afterReturn(false);
      const avMetadataExtractor: media.AVMetadataExtractor = initAVMetadataExtractor();
      const func2 = TestUtil.getPrivateMockFunction(mocker, MediaThumbnailUtil, 'convertPixelMap2ImageSource');
      when(func2)(ArgumentMatchers.any).afterReturn({} as image.ImageSource);
      const func3 = TestUtil.getPrivateMockFunction(mocker, MediaThumbnailUtil, 'processPixelMap');
      when(func3)(ArgumentMatchers.any).afterReturn({} as image.PixelMap);
      const result = await MediaThumbnailUtil.getAudioCoverThumbnail(avMetadataExtractor, 'test');
      mocker.clear(MediaThumbnailCacheUtil);
      mocker.clear(MediaThumbnailUtil);
      expect(result).assertEqual('');
      done();
    })

    it('getAudioCoverThumbnailTest_cacheResult_is_true', 0, async (done: Function) => {
      const mocker: MockKit = new MockKit();
      const func = mocker.mockFunc(MediaThumbnailCacheUtil, MediaThumbnailCacheUtil.cacheThumbnail);
      when(func)(ArgumentMatchers.any).afterReturn(true);
      const avMetadataExtractor: media.AVMetadataExtractor = initAVMetadataExtractor();
      const func2 = TestUtil.getPrivateMockFunction(mocker, MediaThumbnailUtil, 'convertPixelMap2ImageSource');
      when(func2)(ArgumentMatchers.any).afterReturn({} as image.ImageSource);
      const func3 = TestUtil.getPrivateMockFunction(mocker, MediaThumbnailUtil, 'processPixelMap');
      when(func3)(ArgumentMatchers.any).afterReturn({} as image.PixelMap);
      const result = await MediaThumbnailUtil.getAudioCoverThumbnail(avMetadataExtractor, 'test');
      mocker.clear(MediaThumbnailCacheUtil);
      mocker.clear(MediaThumbnailUtil);
      expect(result).assertEqual('test');
      done();
    })

    it('getVideoCoverThumbnail_cacheResult_is_true', 0, async (done: Function) => {
      const fileFd = FileUtil.openFile(filePathMp4);
      const fdSrc: media.AVFileDescriptor = {
        fd: fileFd,
      };
      const mocker: MockKit = new MockKit();
      const func = mocker.mockFunc(MediaThumbnailCacheUtil, MediaThumbnailCacheUtil.cacheThumbnail);
      when(func)(ArgumentMatchers.any).afterReturn(false);
      const func2 = TestUtil.getPrivateMockFunction(mocker, MediaThumbnailUtil, 'convertPixelMap2ImageSource');
      when(func2)(ArgumentMatchers.any).afterReturn({} as image.ImageSource);
      const func3 = TestUtil.getPrivateMockFunction(mocker, MediaThumbnailUtil, 'processPixelMap');
      when(func3)(ArgumentMatchers.any).afterReturn({} as image.PixelMap);

      const result = await MediaThumbnailUtil.getVideoCoverThumbnail(fdSrc, new MediaMetaData(), 'test');
      mocker.clear(MediaThumbnailCacheUtil);
      mocker.clear(MediaThumbnailUtil);
      expect(result).assertEqual('');
      done();
    })

    it('cacheThumbnailTest_pixelMap_null', 0, ()=>{
      const res: Promise<boolean> = MediaThumbnailCacheUtil.cacheThumbnail({} as PixelMap, '');
      expect(res).assertPromiseIsPending();
    })

    it('cacheThumbnailTest_pixelMap_valid', 0, async ()=>{
      let pixMapMock = new PixelMapMock();
      const res = await MediaThumbnailCacheUtil.cacheThumbnail(pixMapMock, filePath);
      expect(res).assertFalse();
    })
  })
}

function beforeTest(): void {
  try {
    if (!fs.accessSync(folderPath)) {
      fs.mkdirSync(folderPath);
    }
    if (!fs.accessSync(filePath)) {
      let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.closeSync(file);
    }

    if (!fs.accessSync(filePathMp4)) {
      let file = fs.openSync(filePathMp4, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.closeSync(file);
    }
  } catch (error) {
    HiLog.error(TAG, `beforeTest error: ${JSON.stringify(error)}`);
  }
}

function afterTest(): void {
  try {
    if (fs.accessSync(filePath)) {
      fs.unlinkSync(filePath);
    }
    if (fs.accessSync(filePathMp4)) {
      fs.unlinkSync(filePathMp4);
    }
  } catch (error) {
    HiLog.error(TAG, `afterTest error: ${JSON.stringify(error)}`);
  }
}

function initAVMetadataExtractor(): media.AVMetadataExtractor {
  const avMetadataExtractor: media.AVMetadataExtractor = {
    fetchMetadata: (): Promise<media.AVMetadata> => {
      throw new Error('Function not implemented.');
    },
    fetchAlbumCover: (): Promise<image.PixelMap> => {
      return new Promise<image.PixelMap>((resolve, reject) => {
        resolve({} as image.PixelMap);
      })
    },
    getTimeByFrameIndex: (index: number): Promise<number> => {
      throw new Error('Function not implemented.');
    },
    getFrameIndexByTime: (timeUs: number): Promise<number> => {
      throw new Error('Function not implemented.');
    },
    release: (): Promise<void> => {
      throw new Error('Function not implemented.');
    },
    setUrlSource: (url: string, headers?: Record<string, string> | undefined): Promise<void> => {
      throw new Error('Function not implemented.');
    },
    fetchFrameByTime: (timeUs: number, options: media.AVImageQueryOptions,
      param: media.PixelMapParams): Promise<image.PixelMap> => {
      throw new Error('Function not implemented.');
    }
  };

  return avMetadataExtractor;
}


