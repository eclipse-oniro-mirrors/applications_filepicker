/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import { HiLog } from '../dfx/HiLog';
import { FileInfo } from '../fileoperate/FileInfo';
import { FileUtil } from '../fileoperate/FileUtil';
import { StringUtil } from '../utils/StringUtil';
import { getResourceString } from '../utils/Tools';
import { Constant, FileSourceUri } from './Constant';
import { FileUriUtil } from '../fileoperate/FileUriUtil';
import { MyComputerConstant } from './MyComputerConstant';
import { DeviceConfig } from '../data/DeviceConfig';
import { ArrayUtil } from '../utils/ArrayUtil';

const TAG: string = 'MyPhoneConstant';
const REG: RegExp = new RegExp('/+$');

export class MyPhoneConstant {
  public static readonly MY_PHONE: string = 'currentUser';
  public static readonly MY_PHONE_DOCUMENTS: string = 'Documents';
  public static readonly MY_PHONE_DOWNLOADS: string = 'Download';
  public static readonly ROOT_URI: string = 'file://docs/storage/Users';
  public static readonly SYSTEM_URI: string = 'file://docs/storage/Users/currentUser';
  public static readonly MY_PHONE_IMAGES: string = '<VirtualImages>';
  public static readonly MY_PHONE_VIDEOS: string = '<VirtualVideos>';
  public static readonly MY_PHONE_GALLERY: string = '<VirtualGallery>';
  public static readonly MY_PHONE_SOUND_RECORDER: string = '<VirtualSoundRecorder>';
  // 用于适配聚合视图中自研应用和三方应用uri为com.开头的文件夹,
  public static readonly SYSTEM_HEAD: string = 'com.';
  public static readonly URI_HEAD: string = 'file://';

  private static systemFolder: Set<string> = new Set<string>([
    MyPhoneConstant.MY_PHONE_DOCUMENTS.toLowerCase(),
    MyPhoneConstant.MY_PHONE_DOWNLOADS.toLowerCase(),
    MyPhoneConstant.MY_PHONE_IMAGES.toLowerCase(),
    MyPhoneConstant.MY_PHONE_VIDEOS.toLowerCase(),
    MyPhoneConstant.MY_PHONE_GALLERY.toLowerCase(),
    MyPhoneConstant.MY_PHONE_SOUND_RECORDER.toLowerCase(),
    MyComputerConstant.MY_PC_DESKTOP.toLowerCase()]);

  // 使用前确认是否为系统文件夹
  public static getMyPhoneNameLanguageValue(fileName: string): string {
    const temp = fileName.toLowerCase();
    switch (temp) {
      case MyPhoneConstant.MY_PHONE.toLowerCase():
        return getResourceString(DeviceConfig.getInstance().config.myDevice);
      case MyPhoneConstant.MY_PHONE_GALLERY.toLowerCase():
        return FileUtil.getApplicationIconOrLabel(Constant.GALLERY_BUNDLE_NAME, false);
      case MyPhoneConstant.MY_PHONE_SOUND_RECORDER.toLowerCase():
        const tempFileName = FileUtil.getApplicationIconOrLabel(Constant.SOUND_RECORD_BUNDLE_NAME, false);
        return StringUtil.isEmpty(tempFileName) ? getResourceString($r('app.string.pc_sound_recorder')) : tempFileName;
      default:
        return fileName;
    }
  }

  public static isSystemFolder(parentUri: string, fileName: string, isFolder: boolean): boolean {
    if (StringUtil.isEmpty(parentUri) || StringUtil.isEmpty(fileName) || !isFolder) {
      return false;
    }
    const lowerParentUri: string = parentUri.toLowerCase();
    if (lowerParentUri === MyPhoneConstant.ROOT_URI.toLocaleLowerCase()) {
      return true;
    }
    const lowFileName = fileName.toLowerCase();
    // minipad录音文件夹 Music/SoundRecorder路径不支持删除
    if (DeviceConfig.getInstance().config.soundName === Constant.PAD_FOLDER_SOUNDS &&
      `${lowerParentUri}/${lowFileName}` === Constant.PAD_SOUNDS_URI.toLowerCase()) {
      return true;
    }
    if (lowerParentUri !== MyPhoneConstant.SYSTEM_URI.toLowerCase()) {
      return false;
    }
    return MyPhoneConstant.systemFolder.has(lowFileName);
  }

  public static getFolderImage(isDarkMode: boolean, fileName: string, isEmpty: boolean): Resource | string {
    return isDarkMode ?
    MyPhoneConstant.getFolderDarkImage(fileName, isEmpty) :
    MyPhoneConstant.getFolderLightImage(fileName, isEmpty);
  }

  private static getFolderDarkImage(fileName: string, isEmpty: boolean): Resource | string {
    if (StringUtil.isEmpty(fileName)) {
      return isEmpty ? $r('app.media.ic_normal_dark_folder_empty') : $r('app.media.ic_normal_dark_folder');
    }
    switch (fileName.toLowerCase()) {
      case MyPhoneConstant.MY_PHONE_DOCUMENTS.toLowerCase():
        return isEmpty ? $r('app.media.ic_normal_document_folder_empty_dark') :
        $r('app.media.ic_normal_document_folder_dark');
      case MyPhoneConstant.MY_PHONE_DOWNLOADS.toLowerCase():
        return isEmpty ? $r('app.media.ic_normal_download_folder_empty_dark') :
        $r('app.media.ic_normal_download_folder_dark');
      case MyPhoneConstant.MY_PHONE_IMAGES.toLowerCase():
        return isEmpty ? $r('app.media.ic_normal_image_folder_empty_dark') :
        $r('app.media.ic_normal_image_folder_dark');
      case MyPhoneConstant.MY_PHONE_VIDEOS.toLowerCase():
        return isEmpty ? $r('app.media.ic_normal_video_folder_empty_dark') :
        $r('app.media.ic_normal_video_folder_dark');
      case MyPhoneConstant.MY_PHONE_GALLERY.toLowerCase():
        return FileUtil.getApplicationIconOrLabel(Constant.SOUND_RECORD_BUNDLE_NAME);
      case MyPhoneConstant.MY_PHONE_SOUND_RECORDER.toLowerCase():
        const tempIcon = FileUtil.getApplicationIconOrLabel(Constant.SOUND_RECORD_BUNDLE_NAME);
        return StringUtil.isEmpty(tempIcon) ? $r('app.media.ic_app_sound_recorder') : tempIcon;
      default:
        return isEmpty ? $r('app.media.ic_normal_dark_folder_empty') : $r('app.media.ic_normal_dark_folder');
    }
  }

  private static getFolderLightImage(fileName: string, isEmpty: boolean): Resource | string {
    if (StringUtil.isEmpty(fileName)) {
      return isEmpty ? $r('app.media.ic_normal_folder_empty') : $r('app.media.ic_normal_folder');
    }
    switch (fileName.toLowerCase()) {
      case MyPhoneConstant.MY_PHONE_DOCUMENTS.toLowerCase():
        return isEmpty ? $r('app.media.ic_normal_document_folder_empty') : $r('app.media.ic_normal_document_folder');
      case MyPhoneConstant.MY_PHONE_DOWNLOADS.toLowerCase():
        return isEmpty ? $r('app.media.ic_normal_download_folder_empty') : $r('app.media.ic_normal_download_folder');
      case MyPhoneConstant.MY_PHONE_IMAGES.toLowerCase():
        return isEmpty ? $r('app.media.ic_normal_image_folder_empty') : $r('app.media.ic_normal_image_folder');
      case MyPhoneConstant.MY_PHONE_VIDEOS.toLowerCase():
        return isEmpty ? $r('app.media.ic_normal_video_folder_empty') : $r('app.media.ic_normal_video_folder');
      case MyPhoneConstant.MY_PHONE_GALLERY.toLowerCase():
        return FileUtil.getApplicationIconOrLabel(Constant.SOUND_RECORD_BUNDLE_NAME);
      case MyPhoneConstant.MY_PHONE_SOUND_RECORDER.toLowerCase():
        const tempIcon = FileUtil.getApplicationIconOrLabel(Constant.SOUND_RECORD_BUNDLE_NAME);
        return StringUtil.isEmpty(tempIcon) ? $r('app.media.ic_app_sound_recorder') : tempIcon;
      default:
        return isEmpty ? $r('app.media.ic_normal_folder_empty') : $r('app.media.ic_normal_folder');
    }
  }

  public static ROOT_FOLDER_INSTRUCTIONS_MAP: Map<string, Resource> = new Map([
    [FileSourceUri.DOCUMENTS, $r('app.string.root_path_documents_folder_instruction')],
    [FileSourceUri.DOWNLOAD_MANAGER, $r('app.string.root_path_download_folder_instruction')],
    [FileSourceUri.GALLERY, $r('app.string.root_path_gallery_folder_instruction')],
    [FileSourceUri.UPDATE_BACK_UP, $r('app.string.root_path_updatebackup_folder_instruction')],
    [FileSourceUri.FILE_RESTORE, $r('app.string.root_path_file_restore_folder_instruction')]
  ]);

  // 初始化的时候，路径需要根据设备路径，录音机路径特殊适配
  public static init(): void {
    MyPhoneConstant.systemFolder.add(DeviceConfig.getInstance().config.musicRootName.toLowerCase());
    MyPhoneConstant.ROOT_FOLDER_INSTRUCTIONS_MAP.set(
      `${MyPhoneConstant.SYSTEM_URI}/${DeviceConfig.getInstance().config.soundName}`,
      $r('app.string.root_path_sound_folder_instruction'))
  }
}