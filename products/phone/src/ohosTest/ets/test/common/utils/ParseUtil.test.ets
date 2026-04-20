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
import { ParseUtil } from '@ohos/common';
import { describe, it, expect } from '@ohos/hypium';

export default function ParseUtilTest() {
  describe('ParseUtilTest', () => {
    it('jsonParse', 0, async () => {
      let result = ParseUtil.jsonParse<Object>('{"key": "value"}');
      expect(result).assertDeepEquals({
        key: "value"
      });

      result = ParseUtil.jsonParse<Object>(undefined);
      expect(result).assertUndefined();
    });

    it('getCloneIndex_emptyName', 0, () => {
      let result = ParseUtil.getCloneIndex('');
      expect(result).assertEqual(0);
    });

    it('getCloneIndex_bundleName', 0, () => {
      let result = ParseUtil.getCloneIndex('bundleName');
      expect(result).assertEqual(0);
    });

    it('getCloneIndex_prefix', 0, () => {
      let result = ParseUtil.getCloneIndex('bundleName+prefix');
      expect(result).assertEqual(0);
    });

    it('getCloneIndex_CLONE_APP_PREFIX_ONE', 0, () => {
      let result = ParseUtil.getCloneIndex('bundleName+CLONE_APP_PREFIX1');
      expect(result).assertEqual(0);
    });

    it('getCloneIndex_CLONE_APP_PREFIX_TWO', 0, () => {
      let result = ParseUtil.getCloneIndex('bundleName+CLONE_APP_PREFIX1+CLONE_APP_PREFIX2');
      expect(result).assertEqual(0);
    });

    it('getCloneBundleName_empty', 0, () => {
      let result = ParseUtil.getCloneBundleName('');
      expect(result).assertEqual('');
    });

    it('getCloneBundleName_invalid', 0, () => {
      let result = ParseUtil.getCloneBundleName('invalidBundleName');
      expect(result).assertEqual('invalidBundleName');
    });

    it('isCloneBundleNameWhenBundleNameIsEmpty', 0, () => {
      let bundleName = '';
      let result = ParseUtil.isCloneBundleName(bundleName);
      expect(result).assertFalse();
    });

    it('isCloneBundleNameWhenBundleNameIsNotStartWithClone', 0, () => {
      let bundleName = 'hello';
      let result = ParseUtil.isCloneBundleName(bundleName);
      expect(result).assertFalse();
    });

    it('isCloneBundleNameWhenBundleNameIsStartWithClone', 0, () => {
      let bundleName = '+clone-hello';
      let result = ParseUtil.isCloneBundleName(bundleName);
      expect(result).assertTrue();
    });

    it('getAppCloneIdentityWhenBundleNameIsEmpty', 0, () => {
      let bundleName = '';
      let result = ParseUtil.getAppCloneIdentity(bundleName);
      expect(result).assertUndefined();
    });

    it('getSandboxDataDirWhenBundleNameIsEmpty', 0, () => {
      let bundleName = '';
      let appIndex = 0;
      let result = ParseUtil.getSandboxDataDir(bundleName, appIndex);
      expect(result).assertEqual('');
    });
  });
}