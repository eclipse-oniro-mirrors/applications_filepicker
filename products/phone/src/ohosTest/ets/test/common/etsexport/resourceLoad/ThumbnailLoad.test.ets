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
  ArgumentMatchers,
  describe,
  expect,
  it,
  MockKit,
  when
} from '@ohos/hypium';
import image from '@ohos.multimedia.image';
import { ThumbnailLoad, ThumbnailUtil } from '@ohos/common';

export default function ThumbnailLoadTest() {
  describe("ThumbnailLoadTest", () => {
    it("initPixelMapResource1_Test", 0, (done: Function) => {
      let testParam: image.PixelMap = image.createPixelMapSync(null, null);
      ThumbnailLoad.resourcePixelMap.set('test', testParam);
      expect((ThumbnailLoad as object)['isInited'] as boolean).assertFalse();
      done();
    })

    it("initPixelMapResource2_Test", 0, (done: Function) => {
      ThumbnailLoad.resourcePixelMap.delete('test');
      ThumbnailLoad.initPixelMapResource();
      expect((ThumbnailLoad as object)['isInited'] as boolean).assertTrue();
      done();
    })

    it("initPixelMapResource3_Test", 0, (done: Function) => {
      let testParam: image.PixelMap = image.createPixelMapSync(null, null);
      ThumbnailLoad.resourcePixelMap.set('test', testParam);
      ThumbnailLoad.initPixelMapResource();
      // 测试重复初始化分支
      ThumbnailLoad.initPixelMapResource();
      expect((ThumbnailLoad as object)['isInited'] as boolean).assertTrue();
      done();
    })

    it("getImageThumbnailByType1_Test", 0, (done: Function) => {
      let tempMap: Map<string, image.PixelMap> = ThumbnailLoad.resourcePixelMap;
      ThumbnailLoad.resourcePixelMap = new Map<string, image.PixelMap>();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ThumbnailUtil.thumbnailMap, ThumbnailUtil.thumbnailMap.has);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(true);
      const result: Resource | image.PixelMap = ThumbnailLoad.getImageThumbnailByType('test');
      mocker.clear(ThumbnailUtil.thumbnailMap);
      expect(result).assertDeepEquals(ThumbnailUtil.thumbnailMap.get('test'));
      ThumbnailLoad.resourcePixelMap = tempMap;
      done();
    })

    it("getImageThumbnailByType2_Test", 0, (done: Function) => {
      let tempMap: Map<string, image.PixelMap> = ThumbnailLoad.resourcePixelMap;
      ThumbnailLoad.resourcePixelMap = new Map<string, image.PixelMap>();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(ThumbnailUtil.thumbnailMap, ThumbnailUtil.thumbnailMap.has);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(false);
      const result1: Resource | image.PixelMap = ThumbnailLoad.getImageThumbnailByType('test');
      mocker.clear(ThumbnailUtil.thumbnailMap);
      expect(result1).assertDeepEquals($r('app.media.ic_normal_unknown'))
      ThumbnailLoad.resourcePixelMap = tempMap;
      done();
    })

    it("getImageThumbnailByType3_Test", 0, (done: Function) => {
      let tempMap: Map<string, image.PixelMap> = ThumbnailLoad.resourcePixelMap;
      let testParam: image.PixelMap = image.createPixelMapSync(null, null);
      ThumbnailLoad.resourcePixelMap.set('key', testParam);
      let mocker: MockKit = new MockKit();
      let mockFunc1: Function = mocker.mockFunc(ThumbnailLoad.resourcePixelMap, ThumbnailLoad.resourcePixelMap.has);

      when(mockFunc1)(ArgumentMatchers.any).afterReturn(true);
      const result2: image.PixelMap | Resource = ThumbnailLoad.getImageThumbnailByType('test');
      mocker.ignoreMock(ThumbnailLoad.resourcePixelMap, ThumbnailLoad.resourcePixelMap.has);
      expect(result2).assertDeepEquals(ThumbnailLoad.resourcePixelMap.get('test'));
      ThumbnailLoad.resourcePixelMap = tempMap;
      done();
    })

    it("getImageThumbnailByType4_Test", 0, (done: Function) => {
      let tempMap: Map<string, image.PixelMap> = ThumbnailLoad.resourcePixelMap;
      let testParam: image.PixelMap = image.createPixelMapSync(null, null);
      ThumbnailLoad.resourcePixelMap.set('key', testParam);
      let mocker: MockKit = new MockKit();
      let mockFunc1: Function = mocker.mockFunc(ThumbnailLoad.resourcePixelMap, ThumbnailLoad.resourcePixelMap.has);
      let mockFunc2: Function = mocker.mockFunc(ThumbnailLoad.resourcePixelMap, ThumbnailLoad.resourcePixelMap.get);
      when(mockFunc1)('test').afterReturn(false);
      when(mockFunc2)(ThumbnailUtil.UNKNOWN_TYPE).afterReturn(null);

      const result4: image.PixelMap | Resource = ThumbnailLoad.getImageThumbnailByType('test');
      mocker.ignoreMock(ThumbnailLoad.resourcePixelMap, ThumbnailLoad.resourcePixelMap.has);
      mocker.ignoreMock(ThumbnailLoad.resourcePixelMap, ThumbnailLoad.resourcePixelMap.get);
      expect(result4).assertDeepEquals($r('app.media.ic_normal_unknown'));
      ThumbnailLoad.resourcePixelMap = tempMap;
      done();
    })
  })
}