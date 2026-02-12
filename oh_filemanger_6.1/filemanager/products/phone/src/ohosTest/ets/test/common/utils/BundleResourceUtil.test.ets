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
import { BundleResourceUtil, FileUtil, HiLog, ParseUtil, ResourceUtil, } from '@ohos/common';
import { ArgumentMatchers, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { TestUtil } from '../../utils/TestUtil';
import { commonEventManager } from '@kit.BasicServicesKit';

export default function BundleResourceUtilTest() {
  beforeEach(() => {
    BundleResourceUtil.downloadUriShowNameMap.clear();
    BundleResourceUtil.fileSourceShowIconMap.clear();
  })
  describe('BundleResourceUtilTest', () => {
    let mocker: MockKit = new MockKit();

    it('createDownloadUriShowMap', 0, (done: Function) => {
      let fileNameArray = ['a/com.ohos.email', 'c/d', 'h/a.svg'];
      let getSubFoldersSync = mocker.mockFunc(FileUtil, FileUtil.getSubFoldersSync);
      when(getSubFoldersSync)(ArgumentMatchers.any).afterReturn(fileNameArray);
      BundleResourceUtil.createDownloadUriShowMap();
      mocker.clear(FileUtil);
      expect(BundleResourceUtil.downloadUriShowNameMap.length).assertEqual(1);
      done();
    })

    it('getDownloadNameMap_nameMap_is_null', 0, (done: Function) => {
      BundleResourceUtil.downloadUriShowNameMap.set('com.ohos.email', '电子邮件');
      let fileNameArray = ['a/com.ohos.email', 'c/d', 'h/a.svg'];
      let getSubFoldersSync = mocker.mockFunc(FileUtil, FileUtil.getSubFoldersSync);
      when(getSubFoldersSync)(ArgumentMatchers.any).afterReturn(fileNameArray);
      BundleResourceUtil.getDownloadNameMap();
      mocker.clear(FileUtil);
      expect(BundleResourceUtil.downloadUriShowNameMap.length).assertEqual(1);
      done();
    })

    it('addAppSandBoxBundleName', 0, (done: Function) => {
      BundleResourceUtil.addAppSandBoxBundleName('email');
      expect(BundleResourceUtil.downloadUriShowNameMap.length).assertEqual(1);
      done();
    })

    it('addAppSandBoxBundleName_has_key', 0, (done: Function) => {
      BundleResourceUtil.downloadUriShowNameMap.set('com.ohos.email', '电子邮件');
      BundleResourceUtil.addAppSandBoxBundleName('com.ohos.email');
      expect(BundleResourceUtil.downloadUriShowNameMap.length).assertEqual(1);
      done();
    })


    it('isSandboxBundleName_empty', 0, (done: Function) => {
      let res = BundleResourceUtil.isSandboxBundleName('');
      expect(res).assertFalse();
      done();
    })

    it('isSandboxBundleName_Return_true', 0, (done: Function) => {
      let res = BundleResourceUtil.isSandboxBundleName('test_sandbox');
      expect(res).assertTrue();
      done();
    })

    it('getSandBoxRealBundleName_IsSandbox', 0, (done: Function) => {
      let res = BundleResourceUtil.getSandBoxRealBundleName('test_sandbox');
      expect(res).assertEqual('test');
      done();
    })

    it('getSandBoxRealBundleName_Non_Sandbox', 0, (done: Function) => {
      let res = BundleResourceUtil.getSandBoxRealBundleName('test');
      expect(res).assertEqual('test');
      done();
    })

    it('getBundleLabelByBundleName_Non_Sandbox', 0, (done: Function) => {
      let res = BundleResourceUtil.getSandBoxRealBundleName('test');
      expect(res).assertEqual('test');
      done();
    })

    it('getBundleLabelByBundleName_IsCloneBundleName', 0, (done: Function) => {
      let isCloneBundleName = mocker.mockFunc(ParseUtil, ParseUtil.isCloneBundleName);
      when(isCloneBundleName)(ArgumentMatchers.any).afterReturn(true);

      let result = BundleResourceUtil.getBundleLabelByBundleName('com.ohos.email');
      mocker.clear(ParseUtil);
      expect(result).assertEqual('电子邮件');
      done();
    })

    it('getBundleLabelByBundleName_IsSandboxBundleName', 0, (done: Function) => {
      let isSandboxBundleName = mocker.mockFunc(BundleResourceUtil, BundleResourceUtil.isSandboxBundleName);
      when(isSandboxBundleName)(ArgumentMatchers.any).afterReturn(true);

      let getStringByOneParamResource = mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByOneParamResource);
      when(getStringByOneParamResource)(ArgumentMatchers.any).afterReturn('test');
      let result = BundleResourceUtil.getBundleLabelByBundleName('com.ohos.email_sandbox');
      mocker.clear(BundleResourceUtil);
      mocker.clear(ResourceUtil);
      expect(result).assertEqual('test');
      done();
    })

    it('getBundleLabelByBundleName_Non_SandboxBundleName', 0, (done: Function) => {
      let result = BundleResourceUtil.getBundleLabelByBundleName('com.ohos.email');
      expect(result).assertEqual('电子邮件');
      done();
    })

    it('getBundleLabelByBundleName_Throw_Error', 0, (done: Function) => {
      let result = BundleResourceUtil.getBundleLabelByBundleName('email');
      expect(result).assertEqual('email');
      done();
    })

    it('getDownLoadBundleName_undefined', 0, (done: Function) => {
      let result = BundleResourceUtil.getDownLoadBundleName('');
      expect(result).assertEqual('');
      done();
    })

    it('getDownLoadBundleName_Has_Key', 0, (done: Function) => {
      BundleResourceUtil.downloadUriShowNameMap.set('email', '电子邮件');
      let result = BundleResourceUtil.getDownLoadBundleName('email');
      expect(result).assertEqual('电子邮件');
      done();
    })

    it('getDownLoadBundleName_Non_Key', 0, (done: Function) => {
      let result1 = BundleResourceUtil.getDownLoadBundleName('emails');
      expect(result1).assertEqual('emails');
      done();
    })

    it('onSystemLanguageChange', 0, (done: Function) => {
      BundleResourceUtil.downloadUriShowNameMap.set('email', 'emails');
      BundleResourceUtil.onSystemLanguageChange();
      let label = BundleResourceUtil.downloadUriShowNameMap.get('email');
      expect(label).assertEqual('emails');
      done();
    })

    it('isPhoneSandBoxExist', 0, (done: Function) => {
      const uri = 'file://com.ohos.email';
      let result = BundleResourceUtil.isPhoneSandBoxExist(uri);
      expect(result).assertFalse();
      done();
    })

    it('createDownloadRecvUriShowMap', 0, (done: Function) => {
      let createShowDownload = TestUtil.getPrivateFunction(BundleResourceUtil, 'createDownloadRecvUriShowMap');
      createShowDownload?.();
      expect(BundleResourceUtil.fileSourceShowIconMap.length).assertEqual(3);
      done();
    })

    it('subscribeBundleResourcesChangedEvent', 0, async (done: Function) => {
      TestUtil.setPrivateAttribute(BundleResourceUtil, 'subscriber', null);
      await BundleResourceUtil.subscribeBundleResourcesChangedEvent();
      let subscriber: commonEventManager.CommonEventSubscriber | null =
        TestUtil.getPrivateAttribute(BundleResourceUtil, 'subscriber');
      expect(subscriber).not().assertNull();
      await BundleResourceUtil.unsubscribeBundleResourcesChangedEvent();
      done();
    })

    it('unsubscribeBundleResourcesChangedEvent', 0, async (done: Function) => {
      const subscribers = await commonEventManager.createSubscriber({
        events: [commonEventManager.Support.COMMON_EVENT_BUNDLE_REMOVED],
      } as commonEventManager.CommonEventSubscribeInfo);
      TestUtil.setPrivateAttribute(BundleResourceUtil, 'subscriber', subscribers);
      await BundleResourceUtil.unsubscribeBundleResourcesChangedEvent();
      await sleep();
      let subscriber: commonEventManager.CommonEventSubscriber | null =
        TestUtil.getPrivateAttribute(BundleResourceUtil, 'subscriber');
      expect(subscriber).assertNull();
      done();
    })

    it('getDownloadNameMap_nameMap_is_Photos', 0, (done: Function) => {
      BundleResourceUtil.downloadUriShowNameMap.set('com.ohos.photos', '图库');
      let fileNameArray = ['a/com.ohos.email', 'c/d', 'h/a.svg'];
      let getSubFoldersSync = mocker.mockFunc(FileUtil, FileUtil.getSubFoldersSync);
      when(getSubFoldersSync)(ArgumentMatchers.any).afterReturn(fileNameArray);
      BundleResourceUtil.getDownloadNameMap();
      mocker.clear(FileUtil);
      expect(BundleResourceUtil.downloadUriShowNameMap.length > 0).assertTrue();
      done();
    })

    it('getDownloadNameMap_nameMap_is_settings', 0, (done: Function) => {
      BundleResourceUtil.downloadUriShowNameMap.set('com.ohos.settings', '设置');
      let fileNameArray = ['a/com.ohos.email', 'c/d', 'h/a.svg'];
      let getSubFoldersSync = mocker.mockFunc(FileUtil, FileUtil.getSubFoldersSync);
      when(getSubFoldersSync)(ArgumentMatchers.any).afterReturn(fileNameArray);
      BundleResourceUtil.getDownloadNameMap();
      mocker.clear(FileUtil);
      expect(BundleResourceUtil.downloadUriShowNameMap.length > 0).assertTrue();
      done();
    })

    it('getDownloadNameMap_nameMap_is_wechat', 0, (done: Function) => {
      BundleResourceUtil.downloadUriShowNameMap.set('com.tencent.wechat', '微信');
      let fileNameArray = ['a/com.ohos.email', 'c/d', 'h/a.svg'];
      let getSubFoldersSync = mocker.mockFunc(FileUtil, FileUtil.getSubFoldersSync);
      when(getSubFoldersSync)(ArgumentMatchers.any).afterReturn(fileNameArray);
      BundleResourceUtil.getDownloadNameMap();
      mocker.clear(FileUtil);
      expect(BundleResourceUtil.downloadUriShowNameMap.length > 0).assertTrue();
      done();
    })

    it('getDownloadNameMap_nameMap_is_vmall', 0, (done: Function) => {
      BundleResourceUtil.downloadUriShowNameMap.set('com.ohos.vmall', '应用市场');
      let fileNameArray = ['a/com.ohos.email', 'c/d', 'h/a.svg'];
      let getSubFoldersSync = mocker.mockFunc(FileUtil, FileUtil.getSubFoldersSync);
      when(getSubFoldersSync)(ArgumentMatchers.any).afterReturn(fileNameArray);
      BundleResourceUtil.getDownloadNameMap();
      mocker.clear(FileUtil);
      expect(BundleResourceUtil.downloadUriShowNameMap.length > 0).assertTrue();
      done();
    })

    it('getDownloadNameMap_nameMap_is_browser', 0, (done: Function) => {
      BundleResourceUtil.downloadUriShowNameMap.set('com.ohos.browser', '浏览器');
      let fileNameArray = ['a/com.ohos.email', 'c/d', 'h/a.svg'];
      let getSubFoldersSync = mocker.mockFunc(FileUtil, FileUtil.getSubFoldersSync);
      when(getSubFoldersSync)(ArgumentMatchers.any).afterReturn(fileNameArray);
      BundleResourceUtil.getDownloadNameMap();
      mocker.clear(FileUtil);
      expect(BundleResourceUtil.downloadUriShowNameMap.length > 0).assertTrue();
      done();
    })

    it('getDownloadNameMap_nameMap_is_QQ', 0, (done: Function) => {
      BundleResourceUtil.downloadUriShowNameMap.set('com.tencent.mqq', 'QQ');
      let fileNameArray = ['a/com.ohos.email', 'c/d', 'h/a.svg'];
      let getSubFoldersSync = mocker.mockFunc(FileUtil, FileUtil.getSubFoldersSync);
      when(getSubFoldersSync)(ArgumentMatchers.any).afterReturn(fileNameArray);
      BundleResourceUtil.getDownloadNameMap();
      mocker.clear(FileUtil);
      expect(BundleResourceUtil.downloadUriShowNameMap.length > 0).assertTrue();
      done();
    })

    it('getDownloadNameMap_nameMap_is_xunlei', 0, (done: Function) => {
      BundleResourceUtil.downloadUriShowNameMap.set('com.xunlei.thunder', '迅雷');
      let fileNameArray = ['a/com.ohos.email', 'c/d', 'h/a.svg'];
      let getSubFoldersSync = mocker.mockFunc(FileUtil, FileUtil.getSubFoldersSync);
      when(getSubFoldersSync)(ArgumentMatchers.any).afterReturn(fileNameArray);
      BundleResourceUtil.getDownloadNameMap();
      mocker.clear(FileUtil);
      expect(BundleResourceUtil.downloadUriShowNameMap.length > 0).assertTrue();
      done();
    })

    it('getDownloadNameMap_nameMap_is_meetime', 0, (done: Function) => {
      BundleResourceUtil.downloadUriShowNameMap.set('com.tencent.meetime', '畅联');
      let fileNameArray = ['a/com.ohos.email', 'c/d', 'h/a.svg'];
      let getSubFoldersSync = mocker.mockFunc(FileUtil, FileUtil.getSubFoldersSync);
      when(getSubFoldersSync)(ArgumentMatchers.any).afterReturn(fileNameArray);
      BundleResourceUtil.getDownloadNameMap();
      mocker.clear(FileUtil);
      expect(BundleResourceUtil.downloadUriShowNameMap.length > 0).assertTrue();
      done();
    })

    it('getDownloadNameMap_nameMap_is_baidu', 0, (done: Function) => {
      BundleResourceUtil.downloadUriShowNameMap.set('com.baidu.baiduapp', '百度');
      let fileNameArray = ['a/com.ohos.email', 'c/d', 'h/a.svg'];
      let getSubFoldersSync = mocker.mockFunc(FileUtil, FileUtil.getSubFoldersSync);
      when(getSubFoldersSync)(ArgumentMatchers.any).afterReturn(fileNameArray);
      BundleResourceUtil.getDownloadNameMap();
      mocker.clear(FileUtil);
      expect(BundleResourceUtil.downloadUriShowNameMap.length > 0).assertTrue();
      done();
    })

    it('getDownloadNameMap_nameMap_is_uc', 0, (done: Function) => {
      BundleResourceUtil.downloadUriShowNameMap.set('com.uc.mobile', 'uc');
      let fileNameArray = ['a/com.ohos.email', 'c/d', 'h/a.svg'];
      let getSubFoldersSync = mocker.mockFunc(FileUtil, FileUtil.getSubFoldersSync);
      when(getSubFoldersSync)(ArgumentMatchers.any).afterReturn(fileNameArray);
      BundleResourceUtil.getDownloadNameMap();
      mocker.clear(FileUtil);
      expect(BundleResourceUtil.downloadUriShowNameMap.length > 0).assertTrue();
      done();
    })

    it('getDownloadNameMap_nameMap_is_QQ_music', 0, (done: Function) => {
      BundleResourceUtil.downloadUriShowNameMap.set('com.tencent.hm.qqmusic', 'QQ音乐');
      let fileNameArray = ['a/com.ohos.email', 'c/d', 'h/a.svg'];
      let getSubFoldersSync = mocker.mockFunc(FileUtil, FileUtil.getSubFoldersSync);
      when(getSubFoldersSync)(ArgumentMatchers.any).afterReturn(fileNameArray);
      BundleResourceUtil.getDownloadNameMap();
      mocker.clear(FileUtil);
      expect(BundleResourceUtil.downloadUriShowNameMap.length > 0).assertTrue();
      done();
    })

    it('getDownloadNameMap_nameMap_is_feishu', 0, (done: Function) => {
      BundleResourceUtil.downloadUriShowNameMap.set('com.ss.feishu', '飞书');
      let fileNameArray = ['a/com.ohos.email', 'c/d', 'h/a.svg'];
      let getSubFoldersSync = mocker.mockFunc(FileUtil, FileUtil.getSubFoldersSync);
      when(getSubFoldersSync)(ArgumentMatchers.any).afterReturn(fileNameArray);
      BundleResourceUtil.getDownloadNameMap();
      mocker.clear(FileUtil);
      expect(BundleResourceUtil.downloadUriShowNameMap.length > 0).assertTrue();
      done();
    })


    it('getDownloadNameMap_nameMap_is_Sounds', 0, (done: Function) => {
      BundleResourceUtil.downloadUriShowNameMap.set('com.ohos.soundrecorder', '录音机');
      let fileNameArray = ['a/com.ohos.email', 'c/d', 'h/a.svg'];
      let getSubFoldersSync = mocker.mockFunc(FileUtil, FileUtil.getSubFoldersSync);
      when(getSubFoldersSync)(ArgumentMatchers.any).afterReturn(fileNameArray);
      BundleResourceUtil.getDownloadNameMap();
      mocker.clear(FileUtil);
      expect(BundleResourceUtil.downloadUriShowNameMap.length > 0).assertTrue();
      done();
    })
  })
}

async function sleep(duration: number = 100): Promise<void> {
  return new Promise((resolve, reject) => {
    try {
      let t = setTimeout(() => {
        clearTimeout(t);
        resolve();
      }, duration)
    } catch (e) {
      reject(e)
    }
  })
}