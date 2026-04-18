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

import { describe, expect, it } from '@ohos/hypium';
import UTD from '@ohos.data.uniformTypeDescriptor';
import UDC from '@ohos.data.unifiedDataChannel';
import unifiedDataChannel from '@ohos.data.unifiedDataChannel';
import {
  FileInfo,
  UdmfUtils
} from '@ohos/common';

const Tag = 'UdmfUtilsTest';

export default function UdmfUtilsTest() {
  describe('UdmfUtilsTest', () => {
    it('GetUnifiedData_Folder_Test', 0, async () => {
      // check folder
      let fileInfo = new FileInfo();
      fileInfo.fileName = "test";
      fileInfo.uri = "file://test";
      fileInfo.relativePath = "/";
      fileInfo.isFolder = true;
      let recordFolder = UdmfUtils.setUnifiedData(fileInfo) as unifiedDataChannel.Folder;
      expect(recordFolder.folderUri).assertEqual('file://test');
      expect(UdmfUtils.getRecordData(recordFolder, UTD.UniformDataType.FOLDER).fileUri).assertEqual('file://test');
    })

    it('GetUnifiedData_Image_Test', 0, async () => {
      // check image
      let fileInfo = new FileInfo();
      fileInfo.fileName = "test.png";
      fileInfo.uri = "file://test.png";
      fileInfo.relativePath = "/";
      let recordImage = UdmfUtils.setUnifiedData(fileInfo) as unifiedDataChannel.Image;
      expect(recordImage.imageUri).assertEqual('file://test.png');
      expect(UdmfUtils.getRecordData(recordImage, UTD.UniformDataType.IMAGE).fileUri).assertEqual('file://test.png');
    })

    it('GetUnifiedData_Video_Test', 0, async () => {
      // check video
      let fileInfo = new FileInfo();
      fileInfo.fileName = "test.mp4";
      fileInfo.uri = "file://test.mp4";
      fileInfo.relativePath = "/";
      let recordVideo = UdmfUtils.setUnifiedData(fileInfo) as unifiedDataChannel.Video;
      expect(recordVideo.videoUri).assertEqual('file://test.mp4');
      expect(UdmfUtils.getRecordData(recordVideo, UTD.UniformDataType.VIDEO).fileUri).assertEqual('file://test.mp4');
    })

    it('GetUnifiedData_Audio_Test', 0, async () => {
      // check audio
      let fileInfo = new FileInfo();
      fileInfo.fileName = "test.mp3";
      fileInfo.uri = "file://test.mp3";
      fileInfo.relativePath = "/";
      let recordAudio = UdmfUtils.setUnifiedData(fileInfo) as unifiedDataChannel.Audio;
      expect(recordAudio.audioUri).assertEqual('file://test.mp3');
      expect(UdmfUtils.getRecordData(recordAudio, UTD.UniformDataType.AUDIO).fileUri).assertEqual('file://test.mp3');
    })

    it('GetUnifiedData_File_Test', 0, async () => {
      // check file
      let fileInfo = new FileInfo();
      fileInfo.fileName = "test.txt";
      fileInfo.uri = "file://test.txt";
      fileInfo.relativePath = "/";
      let recordFile = UdmfUtils.setUnifiedData(fileInfo) as unifiedDataChannel.File;
      expect(recordFile.uri).assertEqual('file://test.txt');
      expect(UdmfUtils.getRecordData(recordFile, UTD.UniformDataType.FILE).fileUri).assertEqual('file://test.txt');
    })

    it('getRecordData_File_Test', 0, async (done: Function) => {
      // check file
      const file: UDC.File = new UDC.File();
      file.uri = '/file';
      let result = UdmfUtils.getRecordData(file, UTD.UniformDataType.FILE);
      expect(result.fileUri).assertEqual(file.uri);
      done();
    });

    it('getRecordData_Image_Test', 0, async (done: Function) => {
      // check image
      const image: UDC.Image = new UDC.Image();
      image.imageUri = '/image';
      let result = UdmfUtils.getRecordData(image, UTD.UniformDataType.IMAGE);
      expect(result.fileUri).assertEqual(image.imageUri);
      done();
    });

    it('getRecordData_Video_Test', 0, async (done: Function) => {
      // check video
      const video: UDC.Video = new UDC.Video();
      video.videoUri = '/video';
      let result = UdmfUtils.getRecordData(video, UTD.UniformDataType.VIDEO);
      expect(result.fileUri).assertEqual(video.videoUri);
      done();
    });

    it('getRecordData_Audio_Test', 0, async (done: Function) => {
      // check audio
      const audio: UDC.Audio = new UDC.Audio();
      audio.audioUri = '/audio';
      let result = UdmfUtils.getRecordData(audio, UTD.UniformDataType.AUDIO);
      expect(result.fileUri).assertEqual(audio.audioUri);
      done();
    });

    it('getRecordData_Folder_Test', 0, async (done: Function) => {
      // check folder
      const folder: UDC.Folder = new UDC.Folder();
      folder.folderUri = '/folder';
      let result = UdmfUtils.getRecordData(folder, UTD.UniformDataType.FOLDER);
      expect(result.fileUri).assertEqual(folder.folderUri);
      done();
    });

    it('getRecordData_Resource_Test', 0, async (done: Function) => {
      // check resource
      const resource_file: UDC.File = new UDC.File();
      resource_file.uri = 'resource:///Test';
      let result = UdmfUtils.getRecordData(resource_file, UTD.UniformDataType.FILE);
      expect(result.fileUri).assertEqual('');
      done();
    });

    it('getExtra_Empty_Test', 0, async (done: Function) => {
      const result = UdmfUtils.getExtra();
      expect(result).assertEqual('');
      done();
    });

    it('getExtra_Test', 0, async (done: Function) => {
      const result1 = UdmfUtils.getExtra(JSON.stringify({ extraInfo: 'fhy Test'}));
      expect(result1).assertEqual('fhy Test');
      done();
    });
  })
}