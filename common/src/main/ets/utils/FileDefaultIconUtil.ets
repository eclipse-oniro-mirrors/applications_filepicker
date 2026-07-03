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

import FileMimeTypeUtil from './FileMimeTypeUtil';

export class FileDefaultIcon {
  private light: Resource;
  private dark: Resource;

  constructor(light: Resource, dark: Resource) {
    this.light = light;
    this.dark = dark;
  }

  getLight(): Resource {
    return this.light;
  }

  getDark(): Resource {
    return this.dark;
  }
}

/**
 * 文件媒体类型
 */
export class FileDefaultIconUtil {
  private static fileDefaultIconMap: Map<string, FileDefaultIcon> = new Map<string, FileDefaultIcon>();

  static initFileDefaultIconMap(): Map<string, FileDefaultIcon> {
    let defaultIconMap = new Map<string, FileDefaultIcon>();
    // 图片
    defaultIconMap.set(FileMimeTypeUtil.ICON_PICTURE_KEY,
      new FileDefaultIcon($r('app.media.ic_light_picture'), $r('app.media.ic_light_picture')));
    // 视频
    defaultIconMap.set(FileMimeTypeUtil.ICON_VIDEO_KEY,
      new FileDefaultIcon($r('app.media.ic_light_video'), $r('app.media.ic_light_video')));

    // 文档
    defaultIconMap.set(FileMimeTypeUtil.ICON_DOC_KEY,
      new FileDefaultIcon($r('app.media.ic_light_word'), $r('app.media.ic_light_word')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_XLS_KEY,
      new FileDefaultIcon($r('app.media.ic_light_excel'), $r('app.media.ic_light_excel')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_PPT_KEY,
      new FileDefaultIcon($r('app.media.ic_light_ppt'), $r('app.media.ic_light_ppt')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_FILE_KEY,
      new FileDefaultIcon($r('app.media.ic_light_text'), $r('app.media.ic_light_text')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_CALENDAR_KEY,
      new FileDefaultIcon($r('app.media.ic_light_calendar'), $r('app.media.ic_light_calendar')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_PDF_KEY,
      new FileDefaultIcon($r('app.media.ic_light_pdf'), $r('app.media.ic_light_pdf')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_XML_KEY,
      new FileDefaultIcon($r('app.media.ic_light_xml'), $r('app.media.ic_light_xml')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_HTML_KEY,
      new FileDefaultIcon($r('app.media.ic_light_html'), $r('app.media.ic_light_html')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_TEXT_KEY,
      new FileDefaultIcon($r('app.media.ic_light_text'), $r('app.media.ic_light_text')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_VCARD_KEY,
      new FileDefaultIcon($r('app.media.ic_light_connect'), $r('app.media.ic_light_connect')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_LOG_KEY,
      new FileDefaultIcon($r('app.media.ic_light_log'), $r('app.media.ic_light_log')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_HTML_KEY,
      new FileDefaultIcon($r('app.media.ic_light_html'), $r('app.media.ic_light_html')));

    // 音频
    defaultIconMap.set(FileMimeTypeUtil.ICON_AUDIO_KEY,
      new FileDefaultIcon($r('app.media.ic_light_music'), $r('app.media.ic_light_music')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_AUDIO_AMR_KEY,
      new FileDefaultIcon($r('app.media.ic_light_amr'), $r('app.media.ic_light_amr')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_AUDIO_WAV_KEY,
      new FileDefaultIcon($r('app.media.ic_light_wav'), $r('app.media.ic_light_wav')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_AUDIO_WMA_KEY,
      new FileDefaultIcon($r('app.media.ic_light_wma'), $r('app.media.ic_light_wma')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_AUDIO_M4A_KEY,
      new FileDefaultIcon($r('app.media.ic_light_m4a'), $r('app.media.ic_light_m4a')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_AUDIO_MP3_KEY,
      new FileDefaultIcon($r('app.media.ic_light_mp3'), $r('app.media.ic_light_mp3')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_AUDIO_FLAC_KEY,
      new FileDefaultIcon($r('app.media.ic_light_flac'), $r('app.media.ic_light_flac')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_AUDIO_APE_KEY,
      new FileDefaultIcon($r('app.media.ic_light_ape'), $r('app.media.ic_light_ape')));

    // 压缩包
    defaultIconMap.set(FileMimeTypeUtil.ICON_COMPRESS_KEY,
      new FileDefaultIcon($r('app.media.ic_light_zip_1'), $r('app.media.ic_light_zip_1')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_RAR_KEY,
      new FileDefaultIcon($r('app.media.ic_light_rar'), $r('app.media.ic_light_rar')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_ZIP_KEY,
      new FileDefaultIcon($r('app.media.ic_light_zip'), $r('app.media.ic_light_zip')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_7Z_KEY,
      new FileDefaultIcon($r('app.media.ic_light_7z'), $r('app.media.ic_light_7z')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_GZIP_KEY,
      new FileDefaultIcon($r('app.media.ic_light_gz'), $r('app.media.ic_light_gz')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_TAR_KEY,
      new FileDefaultIcon($r('app.media.ic_light_tar'), $r('app.media.ic_light_gz')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_APP_KEY,
      new FileDefaultIcon($r('app.media.ic_light_app'), $r('app.media.ic_light_app')));

    // 未知
    defaultIconMap.set(FileMimeTypeUtil.ICON_UN_KNOW_KEY,
      new FileDefaultIcon($r('app.media.ic_light_unknow'), $r('app.media.ic_light_unknow')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_CHM_KEY,
      new FileDefaultIcon($r('app.media.ic_light_chm'), $r('app.media.ic_light_chm')));

    // 文件夹
    defaultIconMap.set(FileMimeTypeUtil.ICON_FOLDER_EMPTY_KEY,
      new FileDefaultIcon($r('app.media.hidisk_icon_folder_grid'), $r('app.media.hidisk_icon_folder_grid_dark')));
    defaultIconMap.set(FileMimeTypeUtil.ICON_FOLDER_KEY,
      new FileDefaultIcon($r('app.media.hidisk_icon_folder_grid_has_file'),
        $r('app.media.hidisk_icon_folder_grid_has_file_dark')));

    return defaultIconMap
  }

  /**
   * 根据文件名等其他信息获取文件对象
   * @param fileName 文件名
   * @param isFolder 是否为文件夹
   * @param subFileCount 文件夹里子文件项数
   * @returns
   */
  public static getFileDefaultIconObj(fileName: string, isFolder: boolean = false,
                                      subFileCount: number = 0): FileDefaultIcon {
    if (FileDefaultIconUtil.fileDefaultIconMap.size === 0) {
      FileDefaultIconUtil.fileDefaultIconMap = FileDefaultIconUtil.initFileDefaultIconMap();
    }
    const fileResType = FileMimeTypeUtil.getFileIcon(fileName, isFolder, subFileCount)
    let fileDefaultIconObj = FileDefaultIconUtil.fileDefaultIconMap.get(fileResType);
    if (!fileDefaultIconObj) {
      fileDefaultIconObj =
        new FileDefaultIcon($r('app.media.ic_light_unknow'), $r('app.media.ic_light_unknow'))
    }
    return fileDefaultIconObj
  }
}

export default FileDefaultIconUtil


