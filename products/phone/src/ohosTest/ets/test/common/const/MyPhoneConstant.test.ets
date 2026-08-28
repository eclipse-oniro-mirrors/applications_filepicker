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
import { Constant, FileUtil, getResourceString, MyComputerConstant, MyPhoneConstant, StringUtil } from '@ohos/common';
import { describe, expect, it, MockKit } from '@ohos/hypium';
import { TestUtil } from '../../utils/TestUtil';

export default function MyPhoneConstantTest() {

  describe('MyPhoneConstantTest', () => {

    // MyPhoneConstant.getMyPhoneNameLanguageValue测试类

    it('getMyPhoneNameLanguageValue_MY_PHONE', 0, (done: Function) => {
      const myPhoneStr: string = MyPhoneConstant.getMyPhoneNameLanguageValue(MyPhoneConstant.MY_PHONE);
      const myPhoneResourceStr: string = getResourceString($r('app.string.myPhone'));
      expect(myPhoneStr).assertEqual(myPhoneResourceStr);
      done();
    })

    it('getMyPhoneNameLanguageValue_MY_PHONE_GALLERY', 0, (done: Function) => {
      const galleryStr: string = MyPhoneConstant.getMyPhoneNameLanguageValue(MyPhoneConstant.MY_PHONE_GALLERY);
      const galleryResourceStr: string = FileUtil.getApplicationIconOrLabel(Constant.GALLERY_BUNDLE_NAME, false);
      expect(galleryStr).assertEqual(galleryResourceStr);
      done();
    })

    it('getMyPhoneNameLanguageValue_MY_PHONE_SOUND_RECORDER', 0, (done: Function) => {
      const tempFileName = FileUtil.getApplicationIconOrLabel(Constant.SOUND_RECORD_BUNDLE_NAME, false);
      const soundRecorderStr: string =
        MyPhoneConstant.getMyPhoneNameLanguageValue(MyPhoneConstant.MY_PHONE_SOUND_RECORDER);
      const soundRecorderResourceStr: string = getResourceString($r('app.string.pc_sound_recorder'));
      if (StringUtil.isEmpty(tempFileName)) {
        expect(soundRecorderStr).assertEqual(soundRecorderResourceStr);
      } else {
        expect(soundRecorderStr).assertEqual(tempFileName);
      }
      done();
    })

    it('getMyPhoneNameLanguageValue_default_name', 0, (done: Function) => {
      const defaultName: string = 'defaultName';
      expect(MyPhoneConstant.getMyPhoneNameLanguageValue(defaultName)).assertEqual(defaultName);
      done();
    })

    // MyPhoneConstant.isSystemFolder测试类

    it('isSystemFolder_null_parentUri', 0, (done: Function) => {
      const parentUri: string = '';
      const tempFileName: string = 'tempFileName';
      const isFolder: boolean = false;
      expect(MyPhoneConstant.isSystemFolder(parentUri, tempFileName, isFolder)).assertFalse();
      done();
    })

    it('isSystemFolder_null_file_name', 0, (done: Function) => {
      const tempParentUri: string = 'tempParentUri';
      const fileName: string = '';
      const isFolder: boolean = true;
      expect(MyPhoneConstant.isSystemFolder(tempParentUri, fileName, isFolder)).assertFalse();
      done();
    })

    it('isSystemFolder_parentUri_equal_to_root_uri', 0, (done: Function) => {
      const parentUri: string = MyPhoneConstant.ROOT_URI;
      const tempFileName: string = 'tempFileName';
      const isFolder: boolean = false;
      expect(MyPhoneConstant.isSystemFolder(parentUri, tempFileName, isFolder)).assertFalse();
      done();
    })

    it('isSystemFolder_parentUri_equal_to_root_uri_toUpperCase', 0, (done: Function) => {
      const parentUri: string = MyPhoneConstant.ROOT_URI.toUpperCase();
      const tempFileName: string = 'tempFileName';
      const isFolder: boolean = true;
      expect(MyPhoneConstant.isSystemFolder(parentUri, tempFileName, isFolder)).assertTrue();
      done();
    })

    it('isSystemFolder_not_folder', 0, (done: Function) => {
      const tempParentUri: string = 'tempParentUri';
      const tempFileName: string = 'tempFileName';
      const isFolder: boolean = false;
      expect(MyPhoneConstant.isSystemFolder(tempParentUri, tempFileName, isFolder)).assertFalse();
      done();
    })

    it('isSystemFolder_parentUri_not_system_uri', 0, (done: Function) => {
      const tempParentUri: string = 'tempParentUri';
      const tempFileName: string = 'tempFileName';
      const isFolder: boolean = true;
      expect(MyPhoneConstant.isSystemFolder(tempParentUri, tempFileName, isFolder)).assertFalse();
      done();
    })

    it('isSystemFolder_documents_fileName', 0, (done: Function) => {
      const tempParentUri: string = MyPhoneConstant.SYSTEM_URI;
      const tempFileName: string = MyPhoneConstant.MY_PHONE_DOCUMENTS;
      const isFolder: boolean = true;
      expect(MyPhoneConstant.isSystemFolder(tempParentUri, tempFileName, isFolder)).assertTrue();
      done();
    })

    it('isSystemFolder_downloads_fileName', 0, (done: Function) => {
      const tempParentUri: string = MyPhoneConstant.SYSTEM_URI;
      const tempFileName: string = MyPhoneConstant.MY_PHONE_DOWNLOADS;
      const isFolder: boolean = true;
      expect(MyPhoneConstant.isSystemFolder(tempParentUri, tempFileName, isFolder)).assertTrue();
      done();
    })

    it('isSystemFolder_images_fileName', 0, (done: Function) => {
      const tempParentUri: string = MyPhoneConstant.SYSTEM_URI;
      const tempFileName: string = MyPhoneConstant.MY_PHONE_IMAGES;
      const isFolder: boolean = true;
      expect(MyPhoneConstant.isSystemFolder(tempParentUri, tempFileName, isFolder)).assertTrue();
      done();
    })

    it('isSystemFolder_videos_fileName', 0, (done: Function) => {
      const tempParentUri: string = MyPhoneConstant.SYSTEM_URI;
      const tempFileName: string = MyPhoneConstant.MY_PHONE_VIDEOS;
      const isFolder: boolean = true;
      expect(MyPhoneConstant.isSystemFolder(tempParentUri, tempFileName, isFolder)).assertTrue();
      done();
    })

    it('isSystemFolder_gallery_fileName', 0, (done: Function) => {
      const tempParentUri: string = MyPhoneConstant.SYSTEM_URI;
      const tempFileName: string = MyPhoneConstant.MY_PHONE_GALLERY;
      const isFolder: boolean = true;
      expect(MyPhoneConstant.isSystemFolder(tempParentUri, tempFileName, isFolder)).assertTrue();
      done();
    })

    it('isSystemFolder_sound_fileName', 0, (done: Function) => {
      const tempParentUri: string = MyPhoneConstant.SYSTEM_URI;
      const tempFileName: string = MyPhoneConstant.MY_PHONE_SOUND_RECORDER;
      const isFolder: boolean = true;
      expect(MyPhoneConstant.isSystemFolder(tempParentUri, tempFileName, isFolder)).assertTrue();
      done();
    })

    it('isSystemFolder_desktop_fileName', 0, (done: Function) => {
      const tempParentUri: string = MyPhoneConstant.SYSTEM_URI;
      const tempFileName: string = MyComputerConstant.MY_PC_DESKTOP;
      const isFolder: boolean = true;
      expect(MyPhoneConstant.isSystemFolder(tempParentUri, tempFileName, isFolder)).assertTrue();
      done();
    })

    it('isSystemFolder_documents_fileName_toUpperCase', 0, (done: Function) => {
      const tempParentUri: string = MyPhoneConstant.SYSTEM_URI;
      const tempFileName: string = MyPhoneConstant.MY_PHONE_DOCUMENTS.toUpperCase();
      const isFolder: boolean = true;
      expect(MyPhoneConstant.isSystemFolder(tempParentUri, tempFileName, isFolder)).assertTrue();
      done();
    })

    it('isSystemFolder_downloads_fileName_toUpperCase', 0, (done: Function) => {
      const tempParentUri: string = MyPhoneConstant.SYSTEM_URI;
      const tempFileName: string = MyPhoneConstant.MY_PHONE_DOWNLOADS.toUpperCase();
      const isFolder: boolean = true;
      expect(MyPhoneConstant.isSystemFolder(tempParentUri, tempFileName, isFolder)).assertTrue();
      done();
    })

    it('isSystemFolder_images_fileName_toUpperCase', 0, (done: Function) => {
      const tempParentUri: string = MyPhoneConstant.SYSTEM_URI;
      const tempFileName: string = MyPhoneConstant.MY_PHONE_IMAGES.toUpperCase();
      const isFolder: boolean = true;
      expect(MyPhoneConstant.isSystemFolder(tempParentUri, tempFileName, isFolder)).assertTrue();
      done();
    })

    it('isSystemFolder_videos_fileName_toUpperCase', 0, (done: Function) => {
      const tempParentUri: string = MyPhoneConstant.SYSTEM_URI;
      const tempFileName: string = MyPhoneConstant.MY_PHONE_VIDEOS.toUpperCase();
      const isFolder: boolean = true;
      expect(MyPhoneConstant.isSystemFolder(tempParentUri, tempFileName, isFolder)).assertTrue();
      done();
    })

    it('isSystemFolder_gallery_fileName_toUpperCase', 0, (done: Function) => {
      const tempParentUri: string = MyPhoneConstant.SYSTEM_URI;
      const tempFileName: string = MyPhoneConstant.MY_PHONE_GALLERY.toUpperCase();
      const isFolder: boolean = true;
      expect(MyPhoneConstant.isSystemFolder(tempParentUri, tempFileName, isFolder)).assertTrue();
      done();
    })

    it('isSystemFolder_sound_fileName_toUpperCase', 0, (done: Function) => {
      const tempParentUri: string = MyPhoneConstant.SYSTEM_URI;
      const tempFileName: string = MyPhoneConstant.MY_PHONE_SOUND_RECORDER.toUpperCase();
      const isFolder: boolean = true;
      expect(MyPhoneConstant.isSystemFolder(tempParentUri, tempFileName, isFolder)).assertTrue();
      done();
    })

    it('isSystemFolder_desktop_fileName_toUpperCase', 0, (done: Function) => {
      const tempParentUri: string = MyPhoneConstant.SYSTEM_URI;
      const tempFileName: string = MyComputerConstant.MY_PC_DESKTOP.toUpperCase();
      const isFolder: boolean = true;
      expect(MyPhoneConstant.isSystemFolder(tempParentUri, tempFileName, isFolder)).assertTrue();
      done();
    })

    it('isSystemFolder_not_system_folderName', 0, (done: Function) => {
      const tempParentUri: string = MyPhoneConstant.SYSTEM_URI;
      const tempFileName: string = 'tempFileName';
      const isFolder: boolean = true;
      expect(MyPhoneConstant.isSystemFolder(tempParentUri, tempFileName, isFolder)).assertFalse();
      done();
    })

    it('isSystemFolder_not_system_folderName_toUpperCase', 0, (done: Function) => {
      const tempParentUri: string = MyPhoneConstant.SYSTEM_URI;
      let tempFileName: string = 'tempFileName';
      tempFileName = tempFileName.toUpperCase();
      const isFolder: boolean = true;
      expect(MyPhoneConstant.isSystemFolder(tempParentUri, tempFileName, isFolder)).assertFalse();
      done();
    })

    // MyPhoneConstant.getFolderImage测试类

    it('getFolderImage_null_fileName_dark_empty', 0, (done: Function) => {
      const isDarkMode: boolean = true;
      const fileName: string = '';
      const isEmpty: boolean = true;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_dark_folder_empty');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_null_fileName_dark_not_empty', 0, (done: Function) => {
      const isDarkMode: boolean = true;
      const fileName: string = '';
      const isEmpty: boolean = false;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_dark_folder');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_dark_documents_empty', 0, (done: Function) => {
      const isDarkMode: boolean = true;
      const fileName: string = MyPhoneConstant.MY_PHONE_DOCUMENTS;
      const isEmpty: boolean = true;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_document_folder_empty_dark');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_dark_documents_not_empty', 0, (done: Function) => {
      const isDarkMode: boolean = true;
      const fileName: string = MyPhoneConstant.MY_PHONE_DOCUMENTS;
      const isEmpty: boolean = false;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_document_folder_dark');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_dark_downloads_empty', 0, (done: Function) => {
      const isDarkMode: boolean = true;
      const fileName: string = MyPhoneConstant.MY_PHONE_DOWNLOADS;
      const isEmpty: boolean = true;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_download_folder_empty_dark');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_dark_downloads_not_empty', 0, (done: Function) => {
      const isDarkMode: boolean = true;
      const fileName: string = MyPhoneConstant.MY_PHONE_DOWNLOADS;
      const isEmpty: boolean = false;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_download_folder_dark');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_dark_images_empty', 0, (done: Function) => {
      const isDarkMode: boolean = true;
      const fileName: string = MyPhoneConstant.MY_PHONE_IMAGES;
      const isEmpty: boolean = true;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_image_folder_empty_dark');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_dark_images_not_empty', 0, (done: Function) => {
      const isDarkMode: boolean = true;
      const fileName: string = MyPhoneConstant.MY_PHONE_IMAGES;
      const isEmpty: boolean = false;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_image_folder_dark');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_dark_videos_empty', 0, (done: Function) => {
      const isDarkMode: boolean = true;
      const fileName: string = MyPhoneConstant.MY_PHONE_VIDEOS;
      const isEmpty: boolean = true;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_video_folder_empty_dark');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_dark_videos_not_empty', 0, (done: Function) => {
      const isDarkMode: boolean = true;
      const fileName: string = MyPhoneConstant.MY_PHONE_VIDEOS;
      const isEmpty: boolean = false;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_video_folder_dark');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_dark_gallery_sound_empty', 0, (done: Function) => {
      const isDarkMode: boolean = true;
      const fileName: string = MyPhoneConstant.MY_PHONE_SOUND_RECORDER;
      const isEmpty: boolean = true;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_app_sound_recorder');
      const tempIcon = FileUtil.getApplicationIconOrLabel(Constant.SOUND_RECORD_BUNDLE_NAME);
      if (StringUtil.isEmpty(tempIcon)) {
        expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      } else {
        expect(folderImage).assertDeepEquals(tempIcon);
      }
      done();
    })

    it('getFolderImage_dark_gallery_sound_not_empty', 0, (done: Function) => {
      const isDarkMode: boolean = true;
      const fileName: string = MyPhoneConstant.MY_PHONE_SOUND_RECORDER;
      const isEmpty: boolean = false;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_app_sound_recorder');
      const tempIcon = FileUtil.getApplicationIconOrLabel(Constant.SOUND_RECORD_BUNDLE_NAME);
      if (StringUtil.isEmpty(tempIcon)) {
        expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      } else {
        expect(folderImage).assertDeepEquals(tempIcon);
      }
      done();
    })

    it('getFolderImage_dark_empty', 0, (done: Function) => {
      const isDarkMode: boolean = true;
      const fileName: string = 'testFileName';
      const isEmpty: boolean = true;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_dark_folder_empty');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_dark_not_empty', 0, (done: Function) => {
      const isDarkMode: boolean = true;
      const fileName: string = 'testFileName';
      const isEmpty: boolean = false;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_dark_folder');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_null_fileName_light_empty', 0, (done: Function) => {
      const isDarkMode: boolean = false;
      const fileName: string = '';
      const isEmpty: boolean = true;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_folder_empty');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_null_fileName_light_not_empty', 0, (done: Function) => {
      const isDarkMode: boolean = false;
      const fileName: string = '';
      const isEmpty: boolean = false;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_folder');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_light_documents_empty', 0, (done: Function) => {
      const isDarkMode: boolean = false;
      const fileName: string = MyPhoneConstant.MY_PHONE_DOCUMENTS;
      const isEmpty: boolean = true;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_document_folder_empty');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_light_documents_not_empty', 0, (done: Function) => {
      const isDarkMode: boolean = false;
      const fileName: string = MyPhoneConstant.MY_PHONE_DOCUMENTS;
      const isEmpty: boolean = false;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_document_folder');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_light_downloads_empty', 0, (done: Function) => {
      const isDarkMode: boolean = false;
      const fileName: string = MyPhoneConstant.MY_PHONE_DOWNLOADS;
      const isEmpty: boolean = true;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_download_folder_empty');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_light_downloads_not_empty', 0, (done: Function) => {
      const isDarkMode: boolean = false;
      const fileName: string = MyPhoneConstant.MY_PHONE_DOWNLOADS;
      const isEmpty: boolean = false;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_download_folder');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_light_images_empty', 0, (done: Function) => {
      const isDarkMode: boolean = false;
      const fileName: string = MyPhoneConstant.MY_PHONE_IMAGES;
      const isEmpty: boolean = true;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_image_folder_empty');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_light_images_not_empty', 0, (done: Function) => {
      const isDarkMode: boolean = false;
      const fileName: string = MyPhoneConstant.MY_PHONE_IMAGES;
      const isEmpty: boolean = false;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_image_folder');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_light_videos_empty', 0, (done: Function) => {
      const isDarkMode: boolean = false;
      const fileName: string = MyPhoneConstant.MY_PHONE_VIDEOS;
      const isEmpty: boolean = true;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_video_folder_empty');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_light_videos_not_empty', 0, (done: Function) => {
      const isDarkMode: boolean = false;
      const fileName: string = MyPhoneConstant.MY_PHONE_VIDEOS;
      const isEmpty: boolean = false;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_video_folder');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_light_gallery_sound_empty', 0, (done: Function) => {
      const isDarkMode: boolean = false;
      const fileName: string = MyPhoneConstant.MY_PHONE_SOUND_RECORDER;
      const isEmpty: boolean = true;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_app_sound_recorder');
      const tempIcon = FileUtil.getApplicationIconOrLabel(Constant.SOUND_RECORD_BUNDLE_NAME);
      if (StringUtil.isEmpty(tempIcon)) {
        expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      } else {
        expect(folderImage).assertDeepEquals(tempIcon);
      }
      done();
    })

    it('getFolderImage_light_gallery_sound_not_empty', 0, (done: Function) => {
      const isDarkMode: boolean = false;
      const fileName: string = MyPhoneConstant.MY_PHONE_SOUND_RECORDER;
      const isEmpty: boolean = false;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_app_sound_recorder');
      const tempIcon = FileUtil.getApplicationIconOrLabel(Constant.SOUND_RECORD_BUNDLE_NAME);
      if (StringUtil.isEmpty(tempIcon)) {
        expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      } else {
        expect(folderImage).assertDeepEquals(tempIcon);
      }
      done();
    })

    it('getFolderImage_light_empty', 0, (done: Function) => {
      const isDarkMode: boolean = false;
      const fileName: string = 'testFileName';
      const isEmpty: boolean = true;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_folder_empty');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('getFolderImage_light_not_empty', 0, (done: Function) => {
      const isDarkMode: boolean = false;
      const fileName: string = 'testFileName';
      const isEmpty: boolean = false;
      const folderImage: Resource | string = MyPhoneConstant.getFolderImage(isDarkMode, fileName, isEmpty);
      const emptyDarkFolderResource: Resource = $r('app.media.ic_normal_folder');
      expect(folderImage).assertDeepEquals(emptyDarkFolderResource);
      done();
    })

    it('isHoSystemFolder_undefined', 0, (done: Function) => {
      const fileInfo = undefined;
      const judgeRes: boolean = MyPhoneConstant.isHoSystemFolder(fileInfo!);
      expect(judgeRes).assertFalse();
      done();
    })

    it('isFromHOSystemDataFolder_undefined', 0, (done: Function) => {
      const fileInfo = undefined;
      const judgeRes: boolean = MyPhoneConstant.isFromHOSystemDataFolder(fileInfo!);
      expect(judgeRes).assertFalse();
      done();
    })

    it('getFolderDarkImage_MY_PHONE_GALLERY', 0, (done: Function) => {
      let mocker: MockKit = new MockKit();
      let getFolderDarkImage: Function =
        TestUtil.getPrivateMockFunction(mocker, MyComputerConstant, 'getFolderDarkImage');

      const fileName = MyPhoneConstant.MY_PHONE_GALLERY.toLowerCase();
      const judgeRes: ResourceStr = getFolderDarkImage(fileName, true);

      mocker.clear(MyComputerConstant);
      mocker.ignoreMock(MyComputerConstant, getFolderDarkImage);
      expect(judgeRes).not().assertNull();

      done();
    })

    it('getFolderLightImage_MY_PHONE_GALLERY', 0, (done: Function) => {
      let mocker: MockKit = new MockKit();
      let getFolderLightImage: Function =
        TestUtil.getPrivateMockFunction(mocker, MyComputerConstant, 'getFolderLightImage');

      const fileName = MyPhoneConstant.MY_PHONE_GALLERY.toLowerCase();
      const judgeRes: ResourceStr = getFolderLightImage(fileName, true);

      mocker.clear(MyComputerConstant);
      mocker.ignoreMock(MyComputerConstant, getFolderLightImage);
      expect(judgeRes).not().assertNull();

      done();
    })
  })
}