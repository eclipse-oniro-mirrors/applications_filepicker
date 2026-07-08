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
import { FileDefaultIconUtil, FileMimeTypeUtil } from '@ohos/common';
import { FileDefaultIcon } from '@ohos/common/src/main/ets/utils/FileDefaultIconUtil';
import { describe, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
export default function FileDefaultIconUtilTest() {
  describe('FileDefaultIconUtilTest', () => {

    it('initFileDefaultIconMap_resultSize', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.size).assertEqual(32);
    });

    // 测试 图片
    it('initFileDefaultIconMap_iconPicture', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_PICTURE_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    // 测试 视频
    it('initFileDefaultIconMap_iconVideo', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_VIDEO_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    // 测试 文档
    it('initFileDefaultIconMap_iconDoc', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_DOC_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconXls', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_XLS_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconPpt', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_PPT_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconFile', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_FILE_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconCalendar', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_CALENDAR_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconPdf', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_PDF_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconXml', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_XML_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconText', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_TEXT_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconVcard', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_VCARD_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconLog', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_LOG_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconHtml', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_HTML_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    // 测试 音频
    it('initFileDefaultIconMap_iconAudio', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_AUDIO_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconAudioAmr', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_AUDIO_AMR_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconAudioWav', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_AUDIO_WAV_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconAudioWma', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_AUDIO_WMA_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconAudioM4a', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_AUDIO_M4A_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconAudioMp3', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_AUDIO_MP3_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconAudioFlac', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_AUDIO_FLAC_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconAudioApe', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_AUDIO_APE_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    // 测试 压缩包
    it('initFileDefaultIconMap_iconCompress', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_COMPRESS_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconRAR', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_RAR_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconZip', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_ZIP_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_icon7z', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_7Z_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconGzip', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_GZIP_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconTar', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_TAR_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconApp', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_APP_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    // 测试 未知
    it('initFileDefaultIconMap_iconUnknow', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_UN_KNOW_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconChm', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_CHM_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    // 测试 文件夹
    it('initFileDefaultIconMap_iconFolderEmpty', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_FOLDER_EMPTY_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('initFileDefaultIconMap_iconFolder', 0, () => {
      let result = FileDefaultIconUtil.initFileDefaultIconMap();
      expect(result.get(FileMimeTypeUtil.ICON_FOLDER_KEY) instanceof FileDefaultIcon).assertTrue();
    });

    it('getFileDefaultIconObj_folder_empty', 0, async (done: Function) => {
      let fileName = 'test';
      let result = FileDefaultIconUtil.getFileDefaultIconObj(fileName, true, 0);
      expect(result.getLight().id).assertEqual($r('app.media.hidisk_icon_folder_grid').id);
      expect(result.getDark().id).assertEqual($r('app.media.hidisk_icon_folder_grid_dark').id);
      done();
    });

    it('getFileDefaultIconObj_folder_has_file', 0, async (done: Function) => {
      let fileName = 'test';
      let result = FileDefaultIconUtil.getFileDefaultIconObj(fileName, true, 1);
      expect(result.getLight().id).assertEqual($r('app.media.hidisk_icon_folder_grid_has_file').id);
      expect(result.getDark().id).assertEqual($r('app.media.hidisk_icon_folder_grid_has_file_dark').id);
      done();
    });

    it('getFileDefaultIconObj_picture', 0, async (done: Function) => {
      let fileName = 'test.jpg';
      let result = FileDefaultIconUtil.getFileDefaultIconObj(fileName);
      expect(result.getLight().id).assertEqual($r('app.media.ic_light_picture').id);
      expect(result.getDark().id).assertEqual($r('app.media.ic_light_picture').id);
      done();
    });

    it('getFileDefaultIconObj_video', 0, async (done: Function) => {
      let fileName = 'test.mp4';
      let result = FileDefaultIconUtil.getFileDefaultIconObj(fileName);
      expect(result.getLight().id).assertEqual($r('app.media.ic_light_video').id);
      expect(result.getDark().id).assertEqual($r('app.media.ic_light_video').id);
      done();
    });

    it('getFileDefaultIconObj_word', 0, async (done: Function) => {
      let fileName = 'test.doc';
      let result = FileDefaultIconUtil.getFileDefaultIconObj(fileName);
      expect(result.getLight().id).assertEqual($r('app.media.ic_light_word').id);
      expect(result.getDark().id).assertEqual($r('app.media.ic_light_word').id);
      done();
    });

    it('getFileDefaultIconObj_excel', 0, async (done: Function) => {
      let fileName = 'test.xlsx';
      let result = FileDefaultIconUtil.getFileDefaultIconObj(fileName);
      expect(result.getLight().id).assertEqual($r('app.media.ic_light_excel').id);
      expect(result.getDark().id).assertEqual($r('app.media.ic_light_excel').id);
      done();
    });

    it('getFileDefaultIconObj_ppt', 0, async (done: Function) => {
      let fileName = 'test.ppt';
      let result = FileDefaultIconUtil.getFileDefaultIconObj(fileName);
      expect(result.getLight().id).assertEqual($r('app.media.ic_light_ppt').id);
      expect(result.getDark().id).assertEqual($r('app.media.ic_light_ppt').id);
      done();
    });

    it('getFileDefaultIconObj_mp3', 0, async (done: Function) => {
      let fileName = 'test.mp3';
      let result = FileDefaultIconUtil.getFileDefaultIconObj(fileName);
      expect(result.getLight().id).assertEqual($r('app.media.ic_light_mp3').id);
      expect(result.getDark().id).assertEqual($r('app.media.ic_light_mp3').id);
      done();
    });

    it('getFileDefaultIconObj_amr', 0, async (done: Function) => {
      let fileName = 'test.amr';
      let result = FileDefaultIconUtil.getFileDefaultIconObj(fileName);
      expect(result.getLight().id).assertEqual($r('app.media.ic_light_amr').id);
      expect(result.getDark().id).assertEqual($r('app.media.ic_light_amr').id);
      done();
    });

    it('getFileDefaultIconObj_wma', 0, async (done: Function) => {
      let fileName = 'test.wma';
      let result = FileDefaultIconUtil.getFileDefaultIconObj(fileName);
      expect(result.getLight().id).assertEqual($r('app.media.ic_light_wma').id);
      expect(result.getDark().id).assertEqual($r('app.media.ic_light_wma').id);
      done();
    });

    it('getFileDefaultIconObj_m4a', 0, async (done: Function) => {
      let fileName = 'test.m4a';
      let result = FileDefaultIconUtil.getFileDefaultIconObj(fileName);
      expect(result.getLight().id).assertEqual($r('app.media.ic_light_m4a').id);
      expect(result.getDark().id).assertEqual($r('app.media.ic_light_m4a').id);
      done();
    });

    it('getFileDefaultIconObj_rar', 0, async (done: Function) => {
      let fileName = 'test.rar';
      let result = FileDefaultIconUtil.getFileDefaultIconObj(fileName);
      expect(result.getLight().id).assertEqual($r('app.media.ic_light_rar').id);
      expect(result.getDark().id).assertEqual($r('app.media.ic_light_rar').id);
      done();
    });

    it('getFileDefaultIconObj_zip', 0, async (done: Function) => {
      let fileName = 'test.zip';
      let result = FileDefaultIconUtil.getFileDefaultIconObj(fileName);
      expect(result.getLight().id).assertEqual($r('app.media.ic_light_zip').id);
      expect(result.getDark().id).assertEqual($r('app.media.ic_light_zip').id);
      done();
    });

    it('getFileDefaultIconObj_7z', 0, async (done: Function) => {
      let fileName = 'test.7z';
      let result = FileDefaultIconUtil.getFileDefaultIconObj(fileName);
      expect(result.getLight().id).assertEqual($r('app.media.ic_light_7z').id);
      expect(result.getDark().id).assertEqual($r('app.media.ic_light_7z').id);
      done();
    });

    it('getFileDefaultIconObj_gz', 0, async (done: Function) => {
      let fileName = 'test.gzip';
      let result = FileDefaultIconUtil.getFileDefaultIconObj(fileName);
      expect(result.getLight().id).assertEqual($r('app.media.ic_light_gz').id);
      expect(result.getDark().id).assertEqual($r('app.media.ic_light_gz').id);
      done();
    });

    it('getFileDefaultIconObj_tar', 0, async (done: Function) => {
      let fileName = 'test.tar';
      let result = FileDefaultIconUtil.getFileDefaultIconObj(fileName);
      expect(result.getLight().id).assertEqual($r('app.media.ic_light_tar').id);
      expect(result.getDark().id).assertEqual($r('app.media.ic_light_gz').id);
      done();
    });

    it('getFileDefaultIconObj_app', 0, async (done: Function) => {
      let fileName = 'test.hap';
      let result = FileDefaultIconUtil.getFileDefaultIconObj(fileName);
      expect(result.getLight().id).assertEqual($r('app.media.ic_light_app').id);
      expect(result.getDark().id).assertEqual($r('app.media.ic_light_app').id);
      done();
    });

    it('getFileDefaultIconObj_xxx', 0, async (done: Function) => {
      let fileName = 'test.xxx';
      let result = FileDefaultIconUtil.getFileDefaultIconObj(fileName);
      expect(result.getLight().id).assertEqual($r('app.media.ic_light_unknow').id);
      expect(result.getDark().id).assertEqual($r('app.media.ic_light_unknow').id);
      done();
    });

    it('getFileDefaultIconObj_chm', 0, async (done: Function) => {
      let fileName = 'test.chm';
      let result = FileDefaultIconUtil.getFileDefaultIconObj(fileName);
      expect(result.getLight().id).assertEqual($r('app.media.ic_light_chm').id);
      expect(result.getDark().id).assertEqual($r('app.media.ic_light_chm').id);
      done();
    });
  });
}