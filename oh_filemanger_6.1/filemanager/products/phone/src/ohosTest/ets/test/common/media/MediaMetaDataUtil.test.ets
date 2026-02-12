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
  afterEach,
  ArgumentMatchers,
  beforeAll,
  describe,
  expect,
  it,
  MockKit,
  when
} from '@ohos/hypium';
import { MediaMetaData, HashUtil, FsUtil, Constant, FileInfo } from '@ohos/common';
import {
  FileMimeTypeUtil,
  FileUtil,
  MediaMetaDataUtil,
  MediaThumbnailCacheUtil,
  MediaThumbnailUtil,
  MimeType
} from '@ohos/common';
import { image } from '@kit.ImageKit';
import { media } from '@kit.MediaKit';

let DOC_PATH: string = '/storage/Users/currentUser/Documents';
let textFile: string = DOC_PATH + '/MediaMetaDataUtilTest.txt';
let videoFile: string = DOC_PATH + '/MediaMetaDataUtilTest.mp3';
let avMetadataExtractor: media.AVMetadataExtractor;
let imageSource: image.ImageSource;
let fdSrc: media.AVFileDescriptor;
let mediaMetaData: MediaMetaData;
let fileCategory: number;
let mocker: MockKit;

export default function MediaMetaDataUtilTest() {
  describe('MediaMetaDataUtilTest', () => {
    beforeAll(() => {
      mocker = new MockKit();
    })

    afterEach(() => {
      mocker.clear(HashUtil);
      mocker.clear(MediaMetaDataUtil);
      mocker.clear(MediaThumbnailUtil);
      mocker.clear(MediaThumbnailCacheUtil);
      mocker.clear(FileUtil);
      mocker.clear(FileMimeTypeUtil);
      mocker.clear(FsUtil);
    })

    it('getMeteData_fileUri_null', 0, async () => {
      expect((await MediaMetaDataUtil.getMetaData('', 1, '', 0, '')).height).assertEqual(0);
    })

    it('getMeteData_fileName_null', 0, async () => {
      let mockGetSHA256: Function = mocker.mockFunc(HashUtil, HashUtil.getSHA256);
      when(mockGetSHA256)('test').afterReturn(new Promise<string>((resolve) => resolve('')));
      let res = (await MediaMetaDataUtil.getMetaData('test', 1, 'test', 0, '')).height;
      mocker.clear(HashUtil);
      expect(res).assertEqual(0);
    })

    it('getMeteData_fileCategory_default', 0, async (done: Function) => {
      let mockGetSHA256: Function = mocker.mockFunc(HashUtil, HashUtil.getSHA256);
      when(mockGetSHA256)('test').afterReturn(new Promise<string>((resolve) => resolve('test')));
      let mockGTCFP: Function = mocker.mockFunc(MediaThumbnailUtil, MediaThumbnailUtil.getThumbnailCacheFilePath);
      when(mockGTCFP)(['test', 'test']).afterReturn(new Promise<string>((resolve) => resolve('test')));
      const res: number = (await MediaMetaDataUtil.getMetaData('test', 1, 'test', 0, 'test')).height;
      mocker.clear(HashUtil);
      mocker.clear(MediaThumbnailUtil);
      expect(res).assertEqual(0);
      done();
    })

    it('getMeteData_fileCategory_FILE_CATEGORY_IMAGE', 0, async () => {
      fileCategory = MimeType.FILE_CATEGORY_IMAGE;
      mediaMetaData = new MediaMetaData();
      mediaMetaData.thumbnailPath = 'test';
      let mockGetSHA256: Function = mocker.mockFunc(HashUtil, HashUtil.getSHA256);
      when(mockGetSHA256)('test').afterReturn(new Promise<string>((resolve) => resolve('test')));
      let mockGTCFP: Function = mocker.mockFunc(MediaThumbnailUtil, MediaThumbnailUtil.getThumbnailCacheFilePath);
      when(mockGTCFP)(['test', 'test']).afterReturn(new Promise<string>((resolve) => resolve('test')));

      let mockGIMD: Function = mocker.mockFunc(MediaMetaDataUtil, MediaMetaDataUtil.getImageMetaData);
      when(mockGIMD)(ArgumentMatchers.any).afterReturn(new Promise<MediaMetaData>((resolve) => resolve(mediaMetaData)));

      let mockGFTCP: Function = mocker.mockFunc(MediaThumbnailUtil, MediaThumbnailUtil.getFullThumbnailCachePath);
      when(mockGFTCP)('test').afterReturn(new Promise<MediaMetaData>((resolve) => resolve(mediaMetaData)));
      const res: MediaMetaData = await MediaMetaDataUtil.getMetaData('test', 1, 'test', fileCategory, '')
      mocker.clear(HashUtil);
      mocker.clear(MediaMetaDataUtil);
      mocker.clear(MediaThumbnailUtil);
      expect(res).assertDeepEquals(mediaMetaData);
    })

    it('getMeteData_fileCategory_FILE_CATEGORY_VIDEO', 0, async () => {
      fileCategory = MimeType.FILE_CATEGORY_VIDEO;
      mediaMetaData = new MediaMetaData();
      let mockGetSHA256: Function = mocker.mockFunc(HashUtil, HashUtil.getSHA256);
      when(mockGetSHA256)('test').afterReturn(new Promise<string>((resolve) => resolve('test')));
      let mockGTCFP: Function = mocker.mockFunc(MediaThumbnailUtil, MediaThumbnailUtil.getThumbnailCacheFilePath);
      when(mockGTCFP)(['test', 'test']).afterReturn(new Promise<string>((resolve) => resolve('test')));

      let mockGFNFU: Function = mocker.mockFunc(FileUtil, FileUtil.getFileNameFromUri);
      let mockGFS: Function = mocker.mockFunc(FileMimeTypeUtil, FileMimeTypeUtil.getFileSuffix);
      when(mockGFNFU)(ArgumentMatchers.any).afterReturn('test');
      when(mockGFS)(ArgumentMatchers.any).afterReturn('MP3');
      let mockGAVMD: Function = mocker.mockFunc(MediaMetaDataUtil, MediaMetaDataUtil.getAVMetaData);
      when(mockGAVMD)(ArgumentMatchers.any)
        .afterReturn(new Promise<MediaMetaData>((resolve) => resolve(mediaMetaData)));
      expect(await MediaMetaDataUtil.getMetaData('test', 1, 'test', fileCategory, '')).assertDeepEquals(mediaMetaData);
      when(mockGFS)(ArgumentMatchers.any).afterReturn('MP4');
      when(mockGAVMD)(ArgumentMatchers.any)
        .afterReturn(new Promise<MediaMetaData>((resolve) => resolve(mediaMetaData)));
      const res: MediaMetaData = await MediaMetaDataUtil.getMetaData('test', 1, 'test', fileCategory, '');
      mocker.clear(HashUtil);
      mocker.clear(MediaThumbnailUtil);
      mocker.clear(FileUtil);
      mocker.clear(FileMimeTypeUtil);
      mocker.clear(MediaMetaDataUtil);
      expect(res).assertDeepEquals(mediaMetaData);
    })

    it('getMeteData_fileCategory_FILE_CATEGORY_AUDIO', 0, async () => {
      fileCategory = MimeType.FILE_CATEGORY_AUDIO;
      let mockGetSHA256: Function = mocker.mockFunc(HashUtil, HashUtil.getSHA256);
      when(mockGetSHA256)('test').afterReturn(new Promise<string>((resolve) => resolve('test')));
      let mockGTCFP: Function = mocker.mockFunc(MediaThumbnailUtil, MediaThumbnailUtil.getThumbnailCacheFilePath);
      when(mockGTCFP)(['test', 'test']).afterReturn(new Promise<string>((resolve) => resolve('test')));

      let mockGFNFU: Function = mocker.mockFunc(FileUtil, FileUtil.getFileNameFromUri);
      let mockGFS: Function = mocker.mockFunc(FileMimeTypeUtil, FileMimeTypeUtil.getFileSuffix);

      fileCategory = MimeType.FILE_CATEGORY_AUDIO;
      when(mockGFNFU)(ArgumentMatchers.any).afterReturn('test');
      when(mockGFS)(ArgumentMatchers.any).afterReturn('test');
      const res: number = (await MediaMetaDataUtil.getMetaData('test', 1, 'test', fileCategory, 'test')).height;
      mocker.clear(HashUtil);
      mocker.clear(MediaThumbnailUtil);
      mocker.clear(FileUtil);
      mocker.clear(FileMimeTypeUtil);
      expect(res).assertEqual(0);
    })

    it('getImageMetaData', 0, async () => {
      let mockGTP: Function = mocker.mockFunc(MediaMetaDataUtil, MediaMetaDataUtil.getThumbnailPath);
      when(mockGTP)([ArgumentMatchers.any, ArgumentMatchers.any, ArgumentMatchers.any, undefined, undefined, undefined,
        ArgumentMatchers.any]).afterReturn(new Promise<string>((resolve => (resolve('test')))));
      let result = (await MediaMetaDataUtil.getImageMetaData(textFile, 1, 'test', 0)).thumbnailPath;
      mocker.clear(MediaMetaDataUtil);
      expect(result).assertEqual('');

    })

    it('getImageSizeData', 0, async () => {
      let mockGTP: Function = mocker.mockFunc(MediaMetaDataUtil, MediaMetaDataUtil.getThumbnailPath);
      when(mockGTP)([ArgumentMatchers.any, ArgumentMatchers.any, ArgumentMatchers.any, undefined, undefined, undefined,
        ArgumentMatchers.any]).afterReturn(new Promise<string>((resolve => (resolve('test')))));
      let result = (await MediaMetaDataUtil.getImageSizeData(textFile, 1)).thumbnailPath;
      mocker.clear(MediaMetaDataUtil);
      expect(result).assertEqual('');
    })

    it('getAVMetaData', 0, async (done: Function) => {
      let mockGTP: Function = mocker.mockFunc(MediaMetaDataUtil, MediaMetaDataUtil.getThumbnailPath);
      when(mockGTP)([ArgumentMatchers.any, ArgumentMatchers.any, undefined, ArgumentMatchers.any, ArgumentMatchers.any,
        ArgumentMatchers.any, ArgumentMatchers.any]).afterReturn(new Promise<string>((resolve => (resolve('test')))));
      let result = (await MediaMetaDataUtil.getAVMetaData(textFile, 'test', 0)).thumbnailPath;
      mocker.clear(MediaMetaDataUtil);
      expect(result).assertEqual('');
      done();
    })

    it('getThumbnailPath_hasCache_true', 0, async () => {
      let mockHasCache: Function = mocker.mockFunc(MediaThumbnailCacheUtil, MediaThumbnailCacheUtil.hasCache);
      when(mockHasCache)(ArgumentMatchers.any).afterReturn(new Promise<boolean>((resolve) => resolve(true)));
      MediaMetaDataUtil.getThumbnailPath('test', 'test', imageSource, fdSrc, mediaMetaData, avMetadataExtractor, 0);
      mocker.clear(MediaThumbnailCacheUtil);
      mocker.verify('hasCache', ['test']).atLeast(0);
    })

    it('getThumbnailPath_FILE_CATEGORY_IMAGE', 0, async () => {
      let mockHasCache: Function = mocker.mockFunc(MediaThumbnailCacheUtil, MediaThumbnailCacheUtil.hasCache);
      when(mockHasCache)(ArgumentMatchers.any).afterReturn(new Promise<boolean>((resolve) => resolve(false)));
      let mockGIT: Function = mocker.mockFunc(MediaThumbnailUtil, MediaThumbnailUtil.getImageThumbnail);
      when(mockGIT)(ArgumentMatchers.any).afterReturn(new Promise<string>((resolve) => resolve('test')));
      await MediaMetaDataUtil.getThumbnailPath('test', 'test', imageSource, fdSrc, mediaMetaData, avMetadataExtractor,
        MimeType.FILE_CATEGORY_IMAGE)
      mocker.clear(MediaThumbnailCacheUtil);
      mocker.clear(MediaThumbnailUtil);
      mocker.verify('getImageThumbnail', [imageSource!!, 'test']).atLeast(0);
    })

    it('getThumbnailPath_FILE_CATEGORY_VIDEO', 0, async () => {
      fileCategory = MimeType.FILE_CATEGORY_VIDEO;
      mediaMetaData = new MediaMetaData();
      let mockHasCache: Function = mocker.mockFunc(MediaThumbnailCacheUtil, MediaThumbnailCacheUtil.hasCache);
      when(mockHasCache)(ArgumentMatchers.any).afterReturn(new Promise<boolean>((resolve) => resolve(false)));

      let mockGVCT: Function = mocker.mockFunc(MediaThumbnailUtil, MediaThumbnailUtil.getVideoCoverThumbnail);
      await MediaMetaDataUtil.getThumbnailPath('test', 'test', imageSource, fdSrc, mediaMetaData, avMetadataExtractor,
        fileCategory)
      mocker.verify('getVideoCoverThumbnail', [fdSrc!!, mediaMetaData, 'test']).never();

      await MediaMetaDataUtil.getThumbnailPath('test', 'test', imageSource, fdSrc, undefined, avMetadataExtractor,
        fileCategory)
      mocker.verify('getVideoCoverThumbnail', [fdSrc!!, mediaMetaData, 'test']).never();

      mediaMetaData.height = 100;
      when(mockGVCT)(ArgumentMatchers.any).afterReturn(new Promise<string>((resolve) => resolve('test')));
      await MediaMetaDataUtil.getThumbnailPath('test', 'test', imageSource, fdSrc, mediaMetaData, avMetadataExtractor,
        fileCategory)
      mocker.verify('getVideoCoverThumbnail', [fdSrc!!, mediaMetaData, 'test']).atLeast(0);

      mocker.clear(MediaThumbnailCacheUtil);
      mocker.clear(MediaThumbnailUtil);
    })

    it('getThumbnailPath_FILE_CATEGORY_VIDEO_1_test', 0, async () => {
      fileCategory = MimeType.FILE_CATEGORY_VIDEO;
      mediaMetaData = new MediaMetaData();
      let mockHasCache: Function = mocker.mockFunc(MediaThumbnailCacheUtil, MediaThumbnailCacheUtil.hasCache);
      when(mockHasCache)(ArgumentMatchers.any).afterReturn(new Promise<boolean>((resolve) => resolve(false)));
      let mockGVCT: Function = mocker.mockFunc(MediaThumbnailUtil, MediaThumbnailUtil.getVideoCoverThumbnail);
      await MediaMetaDataUtil.getThumbnailPath('test', 'test', imageSource, fdSrc, mediaMetaData, avMetadataExtractor,
        fileCategory)
      mocker.clear(MediaThumbnailCacheUtil);
      mocker.clear(MediaThumbnailUtil);
      mocker.verify('getVideoCoverThumbnail', [fdSrc!!, mediaMetaData, 'test']).never();
    })

    it('getThumbnailPath_FILE_CATEGORY_VIDEO_2_test', 0, async () => {
      fileCategory = MimeType.FILE_CATEGORY_VIDEO;
      mediaMetaData = new MediaMetaData();
      let mockHasCache: Function = mocker.mockFunc(MediaThumbnailCacheUtil, MediaThumbnailCacheUtil.hasCache);
      when(mockHasCache)(ArgumentMatchers.any).afterReturn(new Promise<boolean>((resolve) => resolve(false)));
      let mockGVCT: Function = mocker.mockFunc(MediaThumbnailUtil, MediaThumbnailUtil.getVideoCoverThumbnail);
      await MediaMetaDataUtil.getThumbnailPath('test', 'test', imageSource, fdSrc, undefined, avMetadataExtractor,
        fileCategory)
      mocker.clear(MediaThumbnailCacheUtil);
      mocker.clear(MediaThumbnailUtil);
      mocker.verify('getVideoCoverThumbnail', [fdSrc!!, mediaMetaData, 'test']).never();
    })

    it('getThumbnailPath_FILE_CATEGORY_VIDEO_3_test', 0, async () => {
      fileCategory = MimeType.FILE_CATEGORY_VIDEO;
      mediaMetaData = new MediaMetaData();
      let mockHasCache: Function = mocker.mockFunc(MediaThumbnailCacheUtil, MediaThumbnailCacheUtil.hasCache);
      when(mockHasCache)(ArgumentMatchers.any).afterReturn(new Promise<boolean>((resolve) => resolve(false)));

      let mockGVCT: Function = mocker.mockFunc(MediaThumbnailUtil, MediaThumbnailUtil.getVideoCoverThumbnail);
      mediaMetaData.height = 100;
      when(mockGVCT)(ArgumentMatchers.any).afterReturn(new Promise<string>((resolve) => resolve('test')));
      await MediaMetaDataUtil.getThumbnailPath('test', 'test', imageSource, fdSrc, mediaMetaData, avMetadataExtractor,
        fileCategory)
      mocker.clear(MediaThumbnailCacheUtil);
      mocker.clear(MediaThumbnailUtil);
      mocker.verify('getVideoCoverThumbnail', [fdSrc!!, mediaMetaData, 'test']).atLeast(0);
    })

    it('getThumbnailPath_FILE_CATEGORY_AUDIO', 0, async () => {
      let mockHasCache: Function = mocker.mockFunc(MediaThumbnailCacheUtil, MediaThumbnailCacheUtil.hasCache);
      when(mockHasCache)(ArgumentMatchers.any).afterReturn(new Promise<boolean>((resolve) => resolve(false)));

      let mockGACT: Function = mocker.mockFunc(MediaThumbnailUtil, MediaThumbnailUtil.getAudioCoverThumbnail);
      when(mockGACT)(ArgumentMatchers.any).afterReturn(new Promise<string>((resolve) => resolve('test')));
      await MediaMetaDataUtil.getThumbnailPath('test', 'test', imageSource, fdSrc, mediaMetaData, avMetadataExtractor,
        MimeType.FILE_CATEGORY_AUDIO);
      mocker.verify('getAudioCoverThumbnail', [avMetadataExtractor!!, 'test']).atLeast(0);

      mocker.clear(MediaThumbnailCacheUtil);
      mocker.clear(MediaThumbnailUtil);
    })

    it('getImageMetaData_default', 0, async () => {
      let mockHasCache: Function = mocker.mockFunc(MediaThumbnailCacheUtil, MediaThumbnailCacheUtil.hasCache);
      when(mockHasCache)(ArgumentMatchers.any).afterReturn(new Promise<boolean>((resolve) => resolve(false)));
      MediaMetaDataUtil.getThumbnailPath('test', 'test', imageSource, fdSrc, mediaMetaData, avMetadataExtractor, 0);
      mocker.clear(MediaThumbnailCacheUtil);
      mocker.verify('hasCache', ['test']).atLeast(0);
    })

    it('releaseSource', 0, async () => {
      let mockRelease: Function = mocker.mockFunc(imageSource, imageSource?.release);
      let mockClose: Function = mocker.mockFunc(FsUtil, FsUtil.close);
      when(mockRelease)().afterReturnNothing();
      when(mockClose)(10).afterReturnNothing();
      await MediaMetaDataUtil.releaseSource(imageSource, 10);
      mocker.verify('release', []).atLeast(0);
      mocker.verify('close', [10]).atLeast(0);

      await MediaMetaDataUtil.releaseSource(imageSource, 0);
      mocker.verify('release', []).atLeast(0);
      mocker.verify('close', [10]).atLeast(0);

      await MediaMetaDataUtil.releaseSource(undefined, 0);
      mocker.verify('release', []).atLeast(0);
      mocker.verify('close', [10]).atLeast(0);

      when(mockRelease)().afterThrow('test error');
      await MediaMetaDataUtil.releaseSource(imageSource, 10)
      mocker.verify('release', []).atLeast(0);
      mocker.verify('close', [10]).atLeast(0);
      mocker.clear(FsUtil);
    })

    it('releaseSource_1_test', 0, async () => {
      let mockRelease: Function = mocker.mockFunc(imageSource, imageSource?.release);
      let mockClose: Function = mocker.mockFunc(FsUtil, FsUtil.close);
      when(mockRelease)().afterReturnNothing();
      when(mockClose)(10).afterReturnNothing();
      await MediaMetaDataUtil.releaseSource(imageSource, 10);
      mocker.clear(FsUtil);
      mocker.verify('release', []).atLeast(0);
      mocker.verify('close', [10]).atLeast(0);
    })

    it('releaseSource_2_test', 0, async () => {
      let mockRelease: Function = mocker.mockFunc(imageSource, imageSource?.release);
      let mockClose: Function = mocker.mockFunc(FsUtil, FsUtil.close);
      when(mockRelease)().afterReturnNothing();
      when(mockClose)(10).afterReturnNothing();
      await MediaMetaDataUtil.releaseSource(imageSource, 0);
      mocker.clear(FsUtil);
      mocker.verify('release', []).atLeast(0);
      mocker.verify('close', [10]).atLeast(0);
    })

    it('releaseSource_3_test', 0, async () => {
      let mockRelease: Function = mocker.mockFunc(imageSource, imageSource?.release);
      let mockClose: Function = mocker.mockFunc(FsUtil, FsUtil.close);
      when(mockRelease)().afterReturnNothing();
      when(mockClose)(10).afterReturnNothing();
      await MediaMetaDataUtil.releaseSource(undefined, 0);
      mocker.clear(FsUtil);
      mocker.verify('release', []).atLeast(0);
      mocker.verify('close', [10]).atLeast(0);
    })

    it('releaseSource_4_test', 0, async () => {
      let mockRelease: Function = mocker.mockFunc(imageSource, imageSource?.release);
      let mockClose: Function = mocker.mockFunc(FsUtil, FsUtil.close);
      when(mockClose)(10).afterReturnNothing();
      when(mockRelease)().afterThrow('test error');
      await MediaMetaDataUtil.releaseSource(imageSource, 10)
      mocker.clear(FsUtil);
      mocker.verify('release', []).atLeast(0);
      mocker.verify('close', [10]).atLeast(0);
    })

    it('checkImageByteSize', 0, () => {
      expect(MediaMetaDataUtil.checkImageByteSize(0, 0)).assertTrue();
      expect(MediaMetaDataUtil.checkImageByteSize(Constant.BYTE.ONE_MB, 10)).assertFalse();
    })

    it('setMetaDataForFileInfo', 0, () => {
      let fileInfo1 = new FileInfo();
      fileInfo1.mimeTypeObj.fileCategory = MimeType.FILE_CATEGORY_IMAGE;
      let metaData = new MediaMetaData();
      MediaMetaDataUtil.setMetaDataForFileInfo(fileInfo1, metaData);
      expect(fileInfo1.picWidth).assertEqual(metaData.width);
      expect(fileInfo1.picHeight).assertEqual(metaData.height);
      fileInfo1.mimeTypeObj.fileCategory = MimeType.FILE_CATEGORY_VIDEO;
      MediaMetaDataUtil.setMetaDataForFileInfo(fileInfo1, metaData);
      expect(fileInfo1.duration).assertEqual(metaData.duration);
      expect(fileInfo1.picWidth).assertEqual(metaData.width);
      expect(fileInfo1.picHeight).assertEqual(metaData.height);
      fileInfo1.mimeTypeObj.fileCategory = MimeType.FILE_CATEGORY_ZIP;
      MediaMetaDataUtil.setMetaDataForFileInfo(fileInfo1, metaData);
      expect(fileInfo1.duration).assertEqual(metaData.duration);
    })

    it('setMetaDataForFileInfo_1_test', 0, () => {
      let fileInfo1 = new FileInfo();
      fileInfo1.mimeTypeObj.fileCategory = MimeType.FILE_CATEGORY_IMAGE;
      let metaData = new MediaMetaData();
      MediaMetaDataUtil.setMetaDataForFileInfo(fileInfo1, metaData);
      expect(fileInfo1.picWidth).assertEqual(metaData.width);
      expect(fileInfo1.picHeight).assertEqual(metaData.height);
    })

    it('setMetaDataForFileInfo_2_test', 0, () => {
      let fileInfo1 = new FileInfo();
      let metaData = new MediaMetaData();
      fileInfo1.mimeTypeObj.fileCategory = MimeType.FILE_CATEGORY_VIDEO;
      MediaMetaDataUtil.setMetaDataForFileInfo(fileInfo1, metaData);
      expect(fileInfo1.duration).assertEqual(metaData.duration);
      expect(fileInfo1.picWidth).assertEqual(metaData.width);
      expect(fileInfo1.picHeight).assertEqual(metaData.height);
    })

    it('setMetaDataForFileInfo_3_test', 0, () => {
      let fileInfo1 = new FileInfo();
      let metaData = new MediaMetaData();
      fileInfo1.mimeTypeObj.fileCategory = MimeType.FILE_CATEGORY_ZIP;
      MediaMetaDataUtil.setMetaDataForFileInfo(fileInfo1, metaData);
      expect(fileInfo1.duration).assertEqual(metaData.duration);
    })
  })
}
