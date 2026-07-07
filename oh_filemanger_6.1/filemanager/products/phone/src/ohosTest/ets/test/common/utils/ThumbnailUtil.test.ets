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
import { FileInfo, ThumbnailUtil, VirtualUri, FsUtil, Constant, FormatListItem } from '@ohos/common';
import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';

const TAG = 'ThumbnailUtilTest';

export default function ThumbnailUtilTest() {
  describe("ThumbnailUtilTest", () => {
    it("getThumbnailType_folder", 0, (done: Function) => {
      const mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(FsUtil, FsUtil.isFolderEmpty);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(false);

      let fileInfo = new FileInfo();
      fileInfo.isFolder = true;
      fileInfo.uri = VirtualUri.MY_PHONE;
      let fileThumbnailType = ThumbnailUtil.getThumbnailType(fileInfo);
      expect(fileThumbnailType).assertEqual(ThumbnailUtil.FOLDER_TYPE);
      done();
    })

    it("getThumbnailType_pdf", 0, (done: Function) => {
      let fileInfo = new FileInfo();
      fileInfo.isFolder = false;
      fileInfo.fileName = 'test.pdf';
      fileInfo.uri = VirtualUri.MY_PHONE + '/' + fileInfo.fileName;
      let fileThumbnailType = ThumbnailUtil.getThumbnailType(fileInfo);
      expect(fileThumbnailType).assertEqual(ThumbnailUtil.PDF_TYPE);
      done();
    })

    it("getThumbnailTypeBySuffix_empty", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('');
      expect(thumbnail_type).assertEqual('');
      done();
    })

    it("getThumbnailTypeBySuffix_unknown", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.xxxx');
      expect(thumbnail_type).assertEqual(ThumbnailUtil.UNKNOWN_TYPE);
      done();
    })

    it("getThumbnailTypeBySuffix_cpp_unknown", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.cpp');
      expect(thumbnail_type).assertEqual(FormatListItem.TXT);
      done();
    })

    it("getThumbnailTypeBySuffix_amr", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.amr');
      expect(thumbnail_type).assertEqual('amr');
      done();
    })

    it("getThumbnailTypeBySuffix_ape", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.ape');
      expect(thumbnail_type).assertEqual('ape');
      done();
    })

    it("getThumbnailTypeBySuffix_caj", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.caj');
      expect(thumbnail_type).assertEqual('caj');
      done();
    })

    it("getThumbnailTypeBySuffix_eddx", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.eddx');
      expect(thumbnail_type).assertEqual('eddx');
      done();
    })

    it("getThumbnailTypeBySuffix_flac", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.flac');
      expect(thumbnail_type).assertEqual('flac');
      done();
    })

    it("getThumbnailTypeBySuffix_nh", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.nh');
      expect(thumbnail_type).assertEqual('nh');
      done();
    })

    it("getThumbnailTypeBySuffix_m4a", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.m4a');
      expect(thumbnail_type).assertEqual('m4a');
      done();
    })

    it("getThumbnailTypeBySuffix_wav", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.wav');
      expect(thumbnail_type).assertEqual('wav');
      done();
    })

    it("getThumbnailTypeBySuffix_pdf", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.pdf');
      expect(thumbnail_type).assertEqual('pdf');
      done();
    })

    it("getThumbnailTypeBySuffix_app", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.app');
      expect(thumbnail_type).assertEqual('app');
      done();
    })

    it("getThumbnailTypeBySuffix_calender", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.calender');
      expect(thumbnail_type).assertEqual('calender');
      done();
    })

    it("getThumbnailTypeBySuffix_text", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.text');
      expect(thumbnail_type).assertEqual('txt');
      done();
    })

    it("getThumbnailTypeBySuffix_contacts", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.contacts');
      expect(thumbnail_type).assertEqual('contacts');
      done();
    })

    it("getThumbnailTypeBySuffix_mp3", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.mp3');
      expect(thumbnail_type).assertEqual(FormatListItem.MP3);
      done();
    })

    it("getThumbnailTypeBySuffix_tar_compressed", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.tar');
      expect(thumbnail_type).assertEqual(FormatListItem.TAR);
      done();
    })

    it("getThumbnailTypeBySuffix_png", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.png');
      expect(thumbnail_type).assertEqual('image');
      done();
    })

    it("getThumbnailTypeBySuffix_mp4", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.mp4');
      expect(thumbnail_type).assertEqual('video');
      done();
    })

    it("getThumbnailTypeBySuffix_xls", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.xls');
      expect(thumbnail_type).assertEqual('xls');
      done();
    })

    it("getThumbnailTypeBySuffix_doc", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.doc');
      expect(thumbnail_type).assertEqual('doc');
      done();
    })

    it("getThumbnailTypeBySuffix_ppt", 0, (done: Function) => {
      let thumbnail_type = ThumbnailUtil.getThumbnailTypeBySuffix('.ppt');
      expect(thumbnail_type).assertEqual('ppt');
      done();
    })

    it("getThumbnailUri_undefined", 0, (done: Function) => {
      let fileInfo = undefined;
      let uriSrc = ThumbnailUtil.getThumbnailUri(fileInfo!);
      expect(uriSrc).assertEqual('');
      done();
    })

    it("getThumbnailUri_media", 0, (done: Function) => {
      let fileInfo = new FileInfo();
      fileInfo.uri = Constant.MediaLibrary_URI_HEAD + '/test.png';
      let uriSrc = ThumbnailUtil.getThumbnailUri(fileInfo);
      expect(uriSrc).assertContain(fileInfo.uri + `?timestampApp=`);
      done();
    })

    it("getSmallThumbnailUri_media", 0, (done: Function) => {
      let fileInfo = new FileInfo();
      fileInfo.uri = Constant.MediaLibrary_URI_HEAD + '/test.png';
      let uriSrc = ThumbnailUtil.getSmallThumbnailUri(fileInfo);
      expect(uriSrc).assertContain(fileInfo.uri + `?timestampApp=`);
      done();
    })

    it("getSmallThumbnailUri_notMedia", 0, (done: Function) => {
      let fileInfo = new FileInfo();
      fileInfo.uri = VirtualUri.MY_PHONE + '/test.png';
      let uriSrc = ThumbnailUtil.getSmallThumbnailUri(fileInfo);
      expect(uriSrc).assertContain(fileInfo.uri + `?filemanager?`);
      done();
    })

    it("getFileIconCompThumbnailUri_undefined", 0, (done: Function) => {
      let fileInfo = undefined;
      let uriSrc = ThumbnailUtil.getFileIconCompThumbnailUri(fileInfo!);
      expect(uriSrc).assertEqual('');
      done();
    })

    it("getFileIconCompThumbnailUri_media", 0, (done: Function) => {
      let fileInfo = new FileInfo();
      fileInfo.uri = Constant.MediaLibrary_URI_HEAD + '/test.png';
      let uriSrc = ThumbnailUtil.getFileIconCompThumbnailUri(fileInfo);
      expect(uriSrc).assertContain(fileInfo.uri + `?timestampApp=`);
      done();
    })

    it("getDefaultIconByType_image", 0, (done: Function) => {
      let defaultIcon = ThumbnailUtil.getDefaultIconByType(FormatListItem.IMAGE);
      expect(defaultIcon).assertEqual(ThumbnailUtil.thumbnailMap.get(FormatListItem.DEFAULT_IMAGE));
      done();
    })

    it("getDefaultIconByType_video", 0, (done: Function) => {
      let defaultIcon = ThumbnailUtil.getDefaultIconByType(FormatListItem.MP4);
      expect(defaultIcon).assertEqual(ThumbnailUtil.thumbnailMap.get(FormatListItem.DEFAULT_VIDEO));
      done();
    })

    it("getDefaultIconByType_empty", 0, (done: Function) => {
      let defaultIcon = ThumbnailUtil.getDefaultIconByType('');
      expect(defaultIcon.id).assertEqual($r('app.media.ic_normal_unknown').id);
      done();
    })

    it("getDefaultIconByType_z7", 0, (done: Function) => {
      let defaultIcon = ThumbnailUtil.getDefaultIconByType(FormatListItem.Z7);
      expect(defaultIcon.id).assertEqual($r('app.media.ic_light_7z').id);
      done();
    })

    it("getDefaultIconByType_amr", 0, (done: Function) => {
      let defaultIcon = ThumbnailUtil.getDefaultIconByType(FormatListItem.AMR);
      expect(defaultIcon.id).assertEqual($r('app.media.ic_light_amr').id);
      done();
    })

    it("getDefaultIconByType_ape", 0, (done: Function) => {
      let defaultIcon = ThumbnailUtil.getDefaultIconByType(FormatListItem.APE);
      expect(defaultIcon.id).assertEqual($r('app.media.ic_light_ape').id);
      done();
    })

    it("getDefaultIconByType_flac", 0, (done: Function) => {
      let defaultIcon = ThumbnailUtil.getDefaultIconByType(FormatListItem.FLAC);
      expect(defaultIcon.id).assertEqual($r('app.media.ic_light_flac').id);
      done();
    })

    it("getDefaultIconByType_m4a", 0, (done: Function) => {
      let defaultIcon = ThumbnailUtil.getDefaultIconByType(FormatListItem.M4A);
      expect(defaultIcon.id).assertEqual($r('app.media.ic_light_m4a').id);
      done();
    })

    it("getDefaultIconByType_mp3", 0, (done: Function) => {
      let defaultIcon = ThumbnailUtil.getDefaultIconByType(FormatListItem.MP3);
      expect(defaultIcon.id).assertEqual($r('app.media.ic_light_mp3').id);
      done();
    })

    it("getDefaultIconByType_wav", 0, (done: Function) => {
      let defaultIcon = ThumbnailUtil.getDefaultIconByType(FormatListItem.WAV);
      expect(defaultIcon.id).assertEqual($r('app.media.ic_light_wav').id);
      done();
    })

    it("getDefaultIconByType_app", 0, (done: Function) => {
      let defaultIcon = ThumbnailUtil.getDefaultIconByType(FormatListItem.APP);
      expect(defaultIcon.id).assertEqual($r('app.media.ic_light_app').id);
      done();
    })

    it("getDefaultIconByType_calender", 0, (done: Function) => {
      let defaultIcon = ThumbnailUtil.getDefaultIconByType(FormatListItem.CALENDER);
      expect(defaultIcon.id).assertEqual($r('app.media.ic_light_calendar').id);
      done();
    })

    it("getDefaultIconByType_chm", 0, (done: Function) => {
      let defaultIcon = ThumbnailUtil.getDefaultIconByType(FormatListItem.CHM);
      expect(defaultIcon.id).assertEqual($r('app.media.ic_light_chm').id);
      done();
    })

    it("getDefaultIconByType_rar", 0, (done: Function) => {
      let defaultIcon = ThumbnailUtil.getDefaultIconByType(FormatListItem.RAR);
      expect(defaultIcon.id).assertEqual($r('app.media.ic_light_rar').id);
      done();
    })
  })
}