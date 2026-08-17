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
import { MediaThumbnailCacheUtil, FileUtil, FsUtil } from '@ohos/common';
import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { TestUtil } from '../../../test/utils/TestUtil';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { PixelMapMock } from '../../../utils/MediaMock';

export default function MediaThumbnailCacheUtilTest() {
  describe('MediaThumbnailCacheUtilTest', () => {

    it('getCacheRootFolderPathTest', 0, () => {
      let getCacheRootFolderPath = TestUtil.getPrivateFunction(MediaThumbnailCacheUtil,'getCacheRootFolderPath')
      if (getCacheRootFolderPath === null) {
        expect(getCacheRootFolderPath).not().assertNull();
      } else {
        let result: string = getCacheRootFolderPath();
        expect(result.length === 0).assertFalse();
      }
    })

    it('getCacheFolderPathTest', 0, () => {
      let mocker = new MockKit();
      let mockFunc = TestUtil.getPrivateMockFunction(mocker, MediaThumbnailCacheUtil, 'checkCachePath');

      when(mockFunc)(ArgumentMatchers.any).afterReturn(false)
      let result1: string = MediaThumbnailCacheUtil.getCacheFolderPath('test');
      when(mockFunc)(ArgumentMatchers.any).afterReturn(true)
      let result2: string = MediaThumbnailCacheUtil.getCacheFolderPath('test');

      mocker.clear(MediaThumbnailCacheUtil);
      expect(result1.length !== 0).assertFalse();
      expect(result2.length !== 0).assertTrue();
    })

    it('hasCacheTest', 0, async () => {
      let result = await MediaThumbnailCacheUtil.hasCache('test');
      expect(result).assertFalse();

      let mocker = new MockKit();
      let mockFunc = mocker.mockFunc(FileUtil, FileUtil.isExistByPathWithFs);
      when(mockFunc)('test').afterReturn(new Promise<boolean> ( (resolve)=> resolve(true)) );

      result = await MediaThumbnailCacheUtil.hasCache('test');
      mocker.clear(FileUtil);
      expect(result).assertTrue();
    })

    it('checkCacheFileSizeTest', 0, async (done: Function) => {
      let checkCacheFileSize = TestUtil.getPrivateFunction(MediaThumbnailCacheUtil,'checkCacheFileSize')
      if (checkCacheFileSize) {
        let result: boolean = await checkCacheFileSize(10086, '/test');
        expect(result).assertFalse();
      } else {
        expect(checkCacheFileSize).not().assertNull();
      }
      done();
    })

    it('cleanCacheFolderTest', 0, async () => {
      let result = await MediaThumbnailCacheUtil.cleanCacheFolder('');
      expect(result).assertFalse();
      let mocker = new MockKit();
      let mockFunc = mocker.mockFunc(MediaThumbnailCacheUtil, MediaThumbnailCacheUtil.getCacheFolderPath);
      when(mockFunc)('').afterReturn('');
      let result1 = await MediaThumbnailCacheUtil.cleanCacheFolder('');
      when(mockFunc)('test').afterReturn('/test');
      result = await MediaThumbnailCacheUtil.cleanCacheFolder('test');

      mocker.clear(MediaThumbnailCacheUtil);
      expect(result1).assertFalse();
      expect(result).assertTrue();
    })

    it('cleanTest', 0, async () => {
      let result = await MediaThumbnailCacheUtil.clean(true, true, new Array);
      expect(result).assertTrue();
    })

    it('cleanAllStorageDeviceTest', 0, async () => {
      let cleanAllStorageDevice = TestUtil.getPrivateFunction(MediaThumbnailCacheUtil, 'cleanAllStorageDevice')
      if (cleanAllStorageDevice) {
        let result: boolean = await cleanAllStorageDevice('/test', true);
        expect(result).assertTrue();
      } else {
        expect().assertFail();
      }
    })

    it('releaseSourceTest', 0, async (done: Function) => {
      const mocker: MockKit = new MockKit();
      mocker.mockFunc(FsUtil, FsUtil.closeSync);
      await MediaThumbnailCacheUtil.releaseSource();
      mocker.clear(FsUtil);
      mocker.verify('closeSync', [ArgumentMatchers.any]).never();
      done();
    });

    it('releaseSource_closeSync', 0, async (done: Function) => {
      const mocker: MockKit = new MockKit();
      mocker.mockFunc(FsUtil, FsUtil.closeSync);
      let fileMock: fileIo.File = {
        fd: 123,
        path: '11',
        name: '111',
        getParent: (): string => {
          throw new Error('Function not implemented.');
        },
        tryLock: (exclusive?: boolean | undefined): void => {
          throw new Error('Function not implemented.');
        },
        unlock: (): void => {
          throw new Error('Function not implemented.');
        },
        lock: (): Promise<void> => {
          throw new Error('Function not implemented.');
        }
      };
      await MediaThumbnailCacheUtil.releaseSource(fileMock);
      mocker.clear(FsUtil);
      mocker.verify('closeSync', [123]).once();
      done();
    });

    it('releaseSourceTest_pixelMap_release', 0, async (done: Function) => {
      const mocker: MockKit = new MockKit();
      let pixelMapMock: PixelMapMock = new PixelMapMock();
      mocker.mockFunc(pixelMapMock, pixelMapMock.release);
      await MediaThumbnailCacheUtil.releaseSource(undefined, pixelMapMock);
      mocker.clear(pixelMapMock);
      mocker.verify('release', []).once();
      done();
    })

    it('releaseSourceTest_imagePacker_release', 0, async (done: Function) => {
      const mocker: MockKit = new MockKit();
      mocker.mockFunc(FsUtil, FsUtil.closeSync);
      let pixelMapMock: PixelMapMock = new PixelMapMock();
      mocker.mockFunc(pixelMapMock, pixelMapMock.release);
      await MediaThumbnailCacheUtil.releaseSource(undefined, undefined, {} as image.ImagePacker);
      mocker.clear(pixelMapMock);
      mocker.clear(FsUtil);
      mocker.verify('closeSync', [ArgumentMatchers.any]).never();
      mocker.verify('release', []).never();
      done();
    })
  })
}


