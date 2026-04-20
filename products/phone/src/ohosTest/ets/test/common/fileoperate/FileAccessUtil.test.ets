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
import { DiskInfo, FileAccessUtil, FileInfo, FileUtil, RootInfo } from '@ohos/common';
import { afterEach, ArgumentMatchers, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { fileAccess } from '@kit.CoreFileKit';
import { TestUtil } from '../../utils/TestUtil';

export default function FileAccessUtilTest() {
  describe('FileAccessUtilTest', () => {
    let localMocker: MockKit;

    beforeEach(() => {
      localMocker = new MockKit();
    })

    afterEach(() => {
      localMocker.clear(FileAccessUtil);
    })

    it('getDiskNameByUri_empty', 0, () => {
      const uri = '';
      const result = FileAccessUtil.getDiskNameByUri(uri);
      expect(result).assertEqual('');
    })

    it('getDiskNameByUri', 0, () => {
      const getStorageRootInfo = TestUtil.getPrivateMockFunction(localMocker, FileAccessUtil, 'getStorageRootInfo');
      const rootInfo = new Map<string, fileAccess.RootInfo>();
      rootInfo.set('test', new Object({
        uri: 'file://test'
      }) as fileAccess.RootInfo);
      rootInfo.set('test1', new Object({
        uri: 'file://test1'
      }) as fileAccess.RootInfo);
      when(getStorageRootInfo)().afterAction(() => rootInfo);
      const uri = 'file://test/test.txt';
      const result = FileAccessUtil.getDiskNameByUri(uri);
      expect(result).assertEqual('test');
    })

    it('getDiskNameByUri_external', 0, () => {
      const uri: string = 'file://docs/storage/External/test'
      const mocker: MockKit = new MockKit();
      let mockFunc = mocker.mockFunc(FileUtil, FileUtil.getPathFromUri);
      when(mockFunc)(uri).afterReturn('/data/storage/el2/external/test');
      const result = FileAccessUtil.getDiskNameByUri(uri);
      mocker.clear(FileUtil);
      expect(result).assertEqual('LOCAL');
    })

    it('getDiskRootInfo_uuid_LOCAL', 0, async (done: Function) => {
      let result: RootInfo | undefined = await FileAccessUtil.getDiskRootInfo('LOCAL');
      expect(result).not().assertUndefined();
      done();
    })

    it('getDiskRootInfo_uuid_ABCDEF', 0, async (done: Function) => {
      let result: RootInfo | undefined = await FileAccessUtil.getDiskRootInfo('ABCDEF');
      expect(result).assertUndefined();
      done();
    })

    it('refreshStorageRootInfo_LOCAL', 0, async (done: Function) => {
      await FileAccessUtil.refreshStorageRootInfo();
      let storageRootInfo: Map<string, RootInfo> = TestUtil.getPrivateAttribute(FileAccessUtil, 'storageRootInfo');
      expect(storageRootInfo.has('LOCAL')).assertTrue();
      done();
    })

    it('refreshStorageRootInfo_cloud', 0, async (done: Function) => {
      await FileAccessUtil.refreshStorageRootInfo();
      let storageRootInfo: Map<string, RootInfo> = TestUtil.getPrivateAttribute(FileAccessUtil, 'storageRootInfo');
      expect(storageRootInfo.has('cloud')).assertTrue();
      done();
    })

    it('refreshStorageRootInfo_shared_disk', 0, async (done: Function) => {
      await FileAccessUtil.refreshStorageRootInfo();
      let storageRootInfo: Map<string, RootInfo> = TestUtil.getPrivateAttribute(FileAccessUtil, 'storageRootInfo');
      expect(storageRootInfo.has('shared_disk')).assertTrue();
      done();
    })

    it('getFileInfoFromUri_success', 0, async (done: Function) => {
      const fileName: string = Date.now().toString() + '_txt';
      TestUtil.createTestFileOrFolder([fileName], false);
      let result: FileInfo | undefined = await FileAccessUtil.getFileInfoFromUri(TestUtil.TEST_FOLDER_URI + '/' + fileName);
      expect(result?.fileName).assertEqual(fileName);
      done();
    })

    it('getRootListWithFaf_RootInfo_ALL', 0, async (done: Function) => {
      let storageRootInfo: Map<string, RootInfo> = FileAccessUtil.getStorageRootInfo();
      storageRootInfo.clear();
      let result: DiskInfo[] = await FileAccessUtil.getRootListWithFaf();
      expect(result.length).assertLargerOrEqual(1);
      storageRootInfo.delete('LOCAL');
      result = await FileAccessUtil.getRootListWithFaf();
      expect(result.length).assertLargerOrEqual(1);
      storageRootInfo.set('NULL', {} as RootInfo);
      result = await FileAccessUtil.getRootListWithFaf();
      expect(result.length).assertLargerOrEqual(1);
      storageRootInfo.set('INVALID', new RootInfo());
      result = await FileAccessUtil.getRootListWithFaf();
      expect(result.length).assertLargerOrEqual(1);
      done();
    })

    it('getRootListWithFaf_RootInfo_LOCAL_absent', 0, async (done: Function) => {
      await FileAccessUtil.refreshRoots();
      let storageRootInfo: Map<string, RootInfo> = FileAccessUtil.getStorageRootInfo();
      storageRootInfo.delete('LOCAL');
      let result: DiskInfo[] = await FileAccessUtil.getRootListWithFaf();
      expect(result.length).assertLargerOrEqual(1);
      done();
    })

    it('getRootListWithFaf_add_RootInfo_NULL', 0, async (done: Function) => {
      await FileAccessUtil.refreshRoots();
      let storageRootInfo: Map<string, RootInfo> = FileAccessUtil.getStorageRootInfo();
      storageRootInfo.set('NULL', {} as RootInfo);
      let result: DiskInfo[] = await FileAccessUtil.getRootListWithFaf();
      expect(result.length).assertLargerOrEqual(1);
      done();
    })

    it('getRootListWithFaf_add_RootInfo_INVALID', 0, async (done: Function) => {
      await FileAccessUtil.refreshRoots();
      let storageRootInfo: Map<string, RootInfo> = FileAccessUtil.getStorageRootInfo();
      storageRootInfo.set('INVALID', new RootInfo());
      let result: DiskInfo[] = await FileAccessUtil.getRootListWithFaf();
      expect(result.length).assertLargerOrEqual(1);
      done();
    })

    it('setStorageRefreshStatus_test', 0, async (done: Function) => {
      FileAccessUtil.setStorageRefreshStatus(true);
      const result: boolean = TestUtil.getPrivateAttribute(FileAccessUtil, 'isRefreshingRoots');
      expect(result).assertTrue();
      done();
    })
  })
}
