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
import { FileMimeTypeUtil, MimeType } from '@ohos/common';
import { describe, expect, it } from '@ohos/hypium';

export default function FileMimeTypeUtilTest() {
  describe('FileMimeTypeUtilTest', () => {

    it('getFileMimeTypeWithEmptyString', 0, () => {
      let result = FileMimeTypeUtil.getFileMimeType('');
      expect(result).assertDeepEquals(FileMimeTypeUtil.UNKNOWN_MIMETYPE);
    });

    it('getFileMimeTypeWithNoDotExtension', 0, () => {
      let result = FileMimeTypeUtil.getFileMimeType('testFile');
      expect(result).assertDeepEquals(FileMimeTypeUtil.UNKNOWN_MIMETYPE);
    });

    it('getFileMimeTypeWithExtensionOnlyOneCharacter', 0, () => {
      let result = FileMimeTypeUtil.getFileMimeType('testFile.');
      expect(result).assertDeepEquals(FileMimeTypeUtil.UNKNOWN_MIMETYPE);
    });

    it('getRecentFileMimeTypeWithEmptyString', 0, () => {
      let result = FileMimeTypeUtil.getRecentFileMimeType('');
      expect(result).assertDeepEquals(FileMimeTypeUtil.UNKNOWN_MIMETYPE);
    });

    it('getRecentFileMimeTypeWithNoDotExtension', 0, () => {
      let result = FileMimeTypeUtil.getRecentFileMimeType('testFile');
      expect(result).assertDeepEquals(FileMimeTypeUtil.UNKNOWN_MIMETYPE);
    });

    it('getRecentFileMimeTypeWithExtensionOnlyOneCharacter', 0, () => {
      let result = FileMimeTypeUtil.getRecentFileMimeType('testFile.');
      expect(result).assertDeepEquals(FileMimeTypeUtil.UNKNOWN_MIMETYPE);
    });

    it('getFileSuffixWithEmptyString', 0, () => {
      let result = FileMimeTypeUtil.getFileSuffix('');
      expect(result).assertEqual('');
    });

    it('getFileSuffixWithNoDotExtension', 0, () => {
      let result = FileMimeTypeUtil.getFileSuffix('testFile');
      expect(result).assertEqual('');
    });

    it('getFileSuffixWithExtensionOnlyOneCharacter', 0, () => {
      let result = FileMimeTypeUtil.getFileSuffix('testFile.');
      expect(result).assertEqual('');
    });

    it('getLastSuffixWithEmptyString', 0, () => {
      let result = FileMimeTypeUtil.getLastSuffix('');
      expect(result).assertEqual('');
    });

    it('getLastSuffixWithNoDotExtension', 0, () => {
      let result = FileMimeTypeUtil.getLastSuffix('testFile');
      expect(result).assertEqual('');
    });

    it('getLastSuffixWithExtensionOnlyOneCharacter', 0, () => {
      let result = FileMimeTypeUtil.getLastSuffix('testFile.');
      expect(result).assertEqual('');
    });

    it('getFileIconWithoutSubCount', 0, () => {
      let result = FileMimeTypeUtil.getFileIcon('testFolder', true, 0);
      expect(result).assertEqual(FileMimeTypeUtil.ICON_FOLDER_EMPTY_KEY);
    });

    it('getFileIconWithSubCount', 0, () => {
      let result = FileMimeTypeUtil.getFileIcon('testFolder', true, 1);
      expect(result).assertEqual(FileMimeTypeUtil.ICON_FOLDER_KEY);
    });

    it('isMediaWithImageMimeType', 0, () => {
      const mimeType = new MimeType('', MimeType.FILE_CATEGORY_IMAGE, 0, '', '');
      let result = FileMimeTypeUtil.isMedia(mimeType);
      expect(result).assertTrue();
    });

    it('isMediaWithVideoMimeType', 0, () => {
      const mimeType = new MimeType('', MimeType.FILE_CATEGORY_VIDEO, 0, '', '');
      let result = FileMimeTypeUtil.isMedia(mimeType);
      expect(result).assertTrue();
    });

    it('isMediaWithAudioMimeType', 0, () => {
      const mimeType = new MimeType('', MimeType.FILE_CATEGORY_AUDIO, 0, '', '');
      let result = FileMimeTypeUtil.isMedia(mimeType);
      expect(result).assertTrue();
    });

    it('isMediaWithNonMediaMimeType', 0, () => {
      const mimeType = new MimeType('', MimeType.FILE_CATEGORY_TXT, 0, '', '');
      let result = FileMimeTypeUtil.isMedia(mimeType);
      expect(result).assertFalse();
    });

    it('isAudioOrVideoWhenCategoryIsVideo', 0, () => {
      const mimeType = new MimeType('', MimeType.FILE_CATEGORY_VIDEO, 0, '', '');
      let result = FileMimeTypeUtil.isAudioOrVideo(mimeType);
      expect(result).assertTrue();
    });

    it('isAudioOrVideoWhenCategoryIsAudio', 0, () => {
      const mimeType = new MimeType('', MimeType.FILE_CATEGORY_AUDIO, 0, '', '');
      let result = FileMimeTypeUtil.isAudioOrVideo(mimeType);
      expect(result).assertTrue();
    });

    it('isAudioOrVideoWhenCategoryIsTxt', 0, () => {
      const mimeType = new MimeType('', MimeType.FILE_CATEGORY_TXT, 0, '', '');
      let result = FileMimeTypeUtil.isAudioOrVideo(mimeType);
      expect(result).assertFalse();
    });

    it('isDocWhenCategoryIsTxt', 0, () => {
      const mimeType = new MimeType('', MimeType.FILE_CATEGORY_TXT, 0, '', '');
      let result = FileMimeTypeUtil.isDoc(mimeType);
      expect(result).assertTrue();
    });

    it('isDocWhenCategoryIsImage', 0, () => {
      const mimeType = new MimeType('', MimeType.FILE_CATEGORY_IMAGE, 0, '', '');
      let result = FileMimeTypeUtil.isDoc(mimeType);
      expect(result).assertFalse();
    });

    it('isAudioWhenCategoryIsAudio', 0, () => {
      const mimeType = new MimeType('', MimeType.FILE_CATEGORY_AUDIO, 0, '', '');
      let result = FileMimeTypeUtil.isAudio(mimeType);
      expect(result).assertTrue();
    });

    it('isAudioWhenCategoryIsNotAudio', 0, () => {
      const mimeType = new MimeType('', MimeType.FILE_CATEGORY_TXT, 0, '', '');
      let result = FileMimeTypeUtil.isAudio(mimeType);
      expect(result).assertFalse();
    });

    it('isVideoWhenCategoryIsVideo', 0, () => {
      const mimeType = new MimeType('', MimeType.FILE_CATEGORY_VIDEO, 0, '', '');
      let result = FileMimeTypeUtil.isVideo(mimeType);
      expect(result).assertTrue();
    });

    it('isVideoWhenCategoryIsNotVideo', 0, () => {
      const mimeType = new MimeType('', MimeType.FILE_CATEGORY_VIDEO, 0, '', '');
      mimeType.fileCategory = MimeType.FILE_CATEGORY_TXT;
      let result = FileMimeTypeUtil.isVideo(mimeType);
      expect(result).assertFalse();
    });

    it('isImageWhenCategoryIsImage', 0, () => {
      const mimeType = new MimeType('', MimeType.FILE_CATEGORY_IMAGE, 0, '', '');
      let result = FileMimeTypeUtil.isImage(mimeType);
      expect(result).assertTrue();
    });

    it('isImageWhenCategoryIsNotImage', 0, () => {
      const mimeType = new MimeType('', MimeType.FILE_CATEGORY_IMAGE, 0, '', '');
      mimeType.fileCategory = MimeType.FILE_CATEGORY_TXT;
      let result = FileMimeTypeUtil.isImage(mimeType);
      expect(result).assertFalse();
    });

    it('isZipWhenCategoryIsZip', 0, () => {
      const mimeType = new MimeType('', MimeType.FILE_CATEGORY_ZIP, 0, '', '');
      let result = FileMimeTypeUtil.isZip(mimeType);
      expect(result).assertTrue();
    });

    it('isZipWhenCategoryIsNotZip', 0, () => {
      const mimeType = new MimeType('', MimeType.FILE_CATEGORY_TXT, 0, '', '');
      let result = FileMimeTypeUtil.isZip(mimeType);
      expect(result).assertFalse();
    });

    it('isPKGWhenCategoryIsPKG', 0, () => {
      const mimeType = new MimeType('', MimeType.FILE_CATEGORY_PKG, 0, '', '');
      let result = FileMimeTypeUtil.isPKG(mimeType);
      expect(result).assertTrue();
    });

    it('isPKGWhenCategoryIsNotPKG', 0, () => {
      const mimeType = new MimeType('', MimeType.FILE_CATEGORY_TXT, 0, '', '');
      let result = FileMimeTypeUtil.isPKG(mimeType);
      expect(result).assertFalse();
    });

    it('boxFileHasThumbWithImageMimeType', 0, () => {
      const mimeType = new MimeType('', MimeType.FILE_CATEGORY_IMAGE, 0, '', '');
      let result = FileMimeTypeUtil.boxFileHasThumb(mimeType);
      expect(result).assertTrue();
    });

    it('boxFileHasThumbWithVideoMimeType', 0, () => {
      const mimeType = new MimeType('', MimeType.FILE_CATEGORY_VIDEO, 0, '', '');
      let result = FileMimeTypeUtil.boxFileHasThumb(mimeType);
      expect(result).assertTrue();
    });
  })
}
