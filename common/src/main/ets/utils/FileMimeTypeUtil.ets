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
import { HiLog } from '../dfx/HiLog';
import { MimeType } from '../model/MimeType';

import { StringUtil } from './StringUtil';

const TAG = 'FileMimeTypeUtil';

/**
 * 文件媒体类型
 */
export class FileMimeTypeUtil {
  /**
   * word文档
   */
  public static FILE_TYPE_WORD: number = 1;
  /**
   * PPT演示文稿
   */
  public static FILE_TYPE_PPT: number = 2;
  /**
   * Excel表格
   */
  public static FILE_TYPE_EXCEL: number = 3;
  /**
   * PDF文档
   */
  public static FILE_TYPE_PDF: number = 4;
  /**
   * TXT文档
   */
  public static FILE_TYPE_TXT: number = 5;
  /**
   * 所有文档的类型值的集合
   */
  public static FILE_TYPE_DOC_LIST: number[] =
    [FileMimeTypeUtil.FILE_TYPE_WORD, FileMimeTypeUtil.FILE_TYPE_PPT, FileMimeTypeUtil.FILE_TYPE_EXCEL,
      FileMimeTypeUtil.FILE_TYPE_PDF, FileMimeTypeUtil.FILE_TYPE_TXT];
  /**
   * 图片
   */
  public static FILE_TYPE_IMAGE: number = 6;
  /**
   * 视频
   */
  public static FILE_TYPE_VIDEO: number = 7;
  /**
   * 音频
   */
  public static FILE_TYPE_AUDIO: number = 8;
  /**
   * 压缩包
   */
  public static FILE_TYPE_COMPRESS: number = 9;
  /**
   * 其他
   */
  public static FILE_TYPE_OTHER: number = 10;
  public static ICON_UN_KNOW_KEY: string = 'icon_un_know';
  public static ICON_PICTURE_KEY: string = 'icon_picture';
  public static ICON_VIDEO_KEY: string = 'icon_video';
  public static ICON_DOC_KEY: string = 'icon_doc';
  public static ICON_XML_KEY: string = 'icon_xml';
  public static ICON_CHM_KEY: string = 'icon_chm';
  public static ICON_XLS_KEY: string = 'icon_xls';
  public static ICON_PPT_KEY: string = 'icon_ppt';
  public static ICON_FILE_KEY: string = 'icon_file';
  public static ICON_CALENDAR_KEY: string = 'icon_calendar';
  public static ICON_PDF_KEY: string = 'icon_pdf';
  public static ICON_HTML_KEY: string = 'icon_html';
  public static ICON_LOG_KEY: string = 'icon_log';
  public static ICON_TEXT_KEY: string = 'icon_text';
  public static ICON_VCARD_KEY: string = 'icon_vcard';
  public static ICON_AUDIO_KEY: string = 'icon_audio';
  public static ICON_AUDIO_AMR_KEY: string = 'icon_audio_amr';
  public static ICON_AUDIO_WAV_KEY: string = 'icon_audio_wav';
  public static ICON_AUDIO_WMA_KEY: string = 'icon_audio_wma';
  public static ICON_AUDIO_M4A_KEY: string = 'icon_audio_m4a';
  public static ICON_AUDIO_MP3_KEY: string = 'icon_audio_mp3';
  public static ICON_AUDIO_FLAC_KEY: string = 'icon_audio_flac';
  public static ICON_AUDIO_APE_KEY: string = 'icon_audio_ape';
  public static ICON_COMPRESS_KEY: string = 'icon_compress';
  public static ICON_ZIP_KEY: string = 'icon_zip';
  public static ICON_RAR_KEY: string = 'icon_rar';
  public static ICON_7Z_KEY: string = 'icon_7z';
  public static ICON_GZ_KEY: string = 'icon_gz';
  public static ICON_GZIP_KEY: string = 'icon_gzip';
  public static ICON_TAR_KEY: string = 'icon_tar';
  public static ICON_APP_KEY: string = 'icon_app';
  public static ICON_FOLDER_KEY: string = 'icon_folder';
  public static ICON_FOLDER_EMPTY_KEY: string = 'icon_folder_empty';
  public static UNKNOWN_MIMETYPE: MimeType = new MimeType(
    '',
    MimeType.FILE_CATEGORY_UNKNOWN,
    FileMimeTypeUtil.FILE_TYPE_OTHER,
    FileMimeTypeUtil.ICON_UN_KNOW_KEY,
    'application/octet-stream'
  );
  private static fileMimeTypeMap: Map<string, MimeType> = new Map<string, MimeType>();

  static setFileMimeTypeMap(): void {

    // Word
    FileMimeTypeUtil.addWordType();

    // PPT
    FileMimeTypeUtil.addPPTType();

    // Excel
    FileMimeTypeUtil.addExcelType();

    // PDF
    FileMimeTypeUtil.addFileMimeType('PDF', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_PDF,
      FileMimeTypeUtil.ICON_PDF_KEY, 'application/pdf');

    // txt
    FileMimeTypeUtil.addTxtType();
    FileMimeTypeUtil.addTxtType2();

    // 图片
    FileMimeTypeUtil.addImageType();
    FileMimeTypeUtil.addImageType2();

    // 视频
    FileMimeTypeUtil.addVideoType();
    FileMimeTypeUtil.addVideoType2();

    // 音频
    FileMimeTypeUtil.addAudioType();
    FileMimeTypeUtil.addAudioType2();

    // 压缩包
    FileMimeTypeUtil.addZipType();

    // 未知
    FileMimeTypeUtil.addUnkownType();
  }

  public static getRecentFileMimeType(fileName: string): MimeType {
    if (StringUtil.isEmpty(fileName)) {
      HiLog.warn(TAG, 'fileName is empty');
      return FileMimeTypeUtil.UNKNOWN_MIMETYPE;
    }

    const splitList = fileName.split('.');
    if (splitList.length < 2) {
      HiLog.warn(TAG, 'fileName length is less than 2');
      return FileMimeTypeUtil.UNKNOWN_MIMETYPE;
    }

    let suffix = splitList[splitList.length - 1].toUpperCase();

    const fileMiMeTypeMap = FileMimeTypeUtil.getFileMiMeTypeMap();
    const mimeType: MimeType | undefined = fileMiMeTypeMap.get(suffix);
    if (!mimeType) {
      HiLog.warn(TAG, 'mimeType is undefined');
      return FileMimeTypeUtil.UNKNOWN_MIMETYPE;
    }
    return mimeType;
  }

  public static getFileMimeType(fileName: string): MimeType {
    if (StringUtil.isEmpty(fileName)) {
      return FileMimeTypeUtil.UNKNOWN_MIMETYPE;
    }

    const splitList = fileName.split('.')
    if (splitList.length < 2) {
      return FileMimeTypeUtil.UNKNOWN_MIMETYPE;
    }

    let suffix = splitList[splitList.length - 1].toUpperCase();

    const fileMiMeTypeMap = FileMimeTypeUtil.getFileMiMeTypeMap();
    const mimeType: MimeType | undefined = fileMiMeTypeMap.get(suffix);
    if (!mimeType) {
      return FileMimeTypeUtil.UNKNOWN_MIMETYPE;
    }
    return mimeType;
  }

  public static getFileSuffix(fileName: string): string {
    const unKnown: string = '';
    if (StringUtil.isEmpty(fileName)) {
      return unKnown;
    }

    const splitList = fileName.split('.')
    if (splitList.length < 2) {
      return unKnown;
    }

    let suffix = splitList[splitList.length - 1].toUpperCase();
    return suffix;
  }

  // 获取文件后缀
  public static getLastSuffix(fileName: string): string {
    const unKnown: string = '';
    if (StringUtil.isEmpty(fileName)) {
      return unKnown;
    }
    const splitList = fileName.split('.');
    if (splitList.length < 2) {
      return unKnown;
    }
    return splitList[splitList.length - 1].toUpperCase();
  }

  public static getFileTypeOrder(fileName: string): number {
    const mimeType = FileMimeTypeUtil.getFileMimeType(fileName);
    // 当文件类型为文本时，其按照类型排序时需要插入到视屏7和音频8之间，所以进行排序时其排序值需要从新计算
    const textTypeList = FileMimeTypeUtil.FILE_TYPE_DOC_LIST;
    if (textTypeList.includes(mimeType.fileTypeSort)) {
      return FileMimeTypeUtil.FILE_TYPE_VIDEO + mimeType.fileTypeSort / 10
    }
    return mimeType.fileTypeSort;
  }

  /**
   * @description 获取文件夹/文件图标
   * @param Object<FileData> 文件对象
   */
  public static getMimeType(fileName: string, isFolder: boolean = false, subCount: number = 0): MimeType {
    if (isFolder) {
      let hasSub = subCount > 0;
      return new MimeType(
        '',
        MimeType.FILE_CATEGORY_UNKNOWN,
        FileMimeTypeUtil.FILE_TYPE_OTHER,
        hasSub ? FileMimeTypeUtil.ICON_FOLDER_KEY : FileMimeTypeUtil.ICON_FOLDER_EMPTY_KEY,
        ''
      );
    }
    return FileMimeTypeUtil.getFileMimeType(fileName);
  }

  public static getFileIcon(fileName: string, isFolder: boolean = false, subCount: number = 0): string {
    return FileMimeTypeUtil.getMimeType(fileName, isFolder, subCount).fileResType;
  }

  public static isMedia(data: MimeType): boolean {
    return data.fileCategory === MimeType.FILE_CATEGORY_IMAGE || data.fileCategory === MimeType.FILE_CATEGORY_VIDEO ||
      data.fileCategory === MimeType.FILE_CATEGORY_AUDIO;
  }

  public static isAudioOrVideo(data: MimeType): boolean {
    return data.fileCategory === MimeType.FILE_CATEGORY_VIDEO || data.fileCategory === MimeType.FILE_CATEGORY_AUDIO;
  }

  public static isImageOrVideo(data: MimeType): boolean {
    return data.fileCategory === MimeType.FILE_CATEGORY_VIDEO || data.fileCategory === MimeType.FILE_CATEGORY_IMAGE;
  }

  public static isDoc(data: MimeType): boolean {
    return data.fileCategory === MimeType.FILE_CATEGORY_TXT;
  }

  public static isAudio(data: MimeType): boolean {
    return data.fileCategory === MimeType.FILE_CATEGORY_AUDIO;
  }

  public static isVideo(data: MimeType): boolean {
    return data.fileCategory === MimeType.FILE_CATEGORY_VIDEO;
  }

  public static isImage(data: MimeType): boolean {
    return data.fileCategory === MimeType.FILE_CATEGORY_IMAGE;
  }

  public static isZip(data: MimeType): boolean {
    return data.fileCategory === MimeType.FILE_CATEGORY_ZIP;
  }

  public static isPKG(data: MimeType): boolean {
    return data.fileCategory === MimeType.FILE_CATEGORY_PKG;
  }

  private static addFileMimeType(extension: string, fileCategory: number, fileTypeSort: number, fileResType: string,
    mimeType: string): void {
    const mType: MimeType = new MimeType(extension, fileCategory, fileTypeSort, fileResType, mimeType);
    FileMimeTypeUtil.fileMimeTypeMap.set(extension, mType);
  }

  private static addUnkownType() {
    FileMimeTypeUtil.addFileMimeType('HAP', MimeType.FILE_CATEGORY_PKG, FileMimeTypeUtil.FILE_TYPE_OTHER,
      FileMimeTypeUtil.ICON_APP_KEY, 'application/octet-stream');
    FileMimeTypeUtil.addFileMimeType('EXE', MimeType.FILE_CATEGORY_UNKNOWN, FileMimeTypeUtil.FILE_TYPE_OTHER,
      FileMimeTypeUtil.ICON_UN_KNOW_KEY, 'application/octet-stream');
    FileMimeTypeUtil.addFileMimeType('BIN', MimeType.FILE_CATEGORY_UNKNOWN, FileMimeTypeUtil.FILE_TYPE_OTHER,
      FileMimeTypeUtil.ICON_UN_KNOW_KEY, 'application/octet-stream');
    FileMimeTypeUtil.addFileMimeType('CLASS', MimeType.FILE_CATEGORY_UNKNOWN, FileMimeTypeUtil.FILE_TYPE_OTHER,
      FileMimeTypeUtil.ICON_UN_KNOW_KEY, 'application/octet-stream');
    FileMimeTypeUtil.addFileMimeType('EPUB', MimeType.FILE_CATEGORY_UNKNOWN, FileMimeTypeUtil.FILE_TYPE_OTHER,
      FileMimeTypeUtil.ICON_UN_KNOW_KEY, 'application/epub+zip');
    FileMimeTypeUtil.addFileMimeType('EBK3', MimeType.FILE_CATEGORY_UNKNOWN, FileMimeTypeUtil.FILE_TYPE_OTHER,
      FileMimeTypeUtil.ICON_UN_KNOW_KEY, 'application/x-expandedbook');
    FileMimeTypeUtil.addFileMimeType('SAMI', MimeType.FILE_CATEGORY_UNKNOWN, FileMimeTypeUtil.FILE_TYPE_OTHER,
      FileMimeTypeUtil.ICON_UN_KNOW_KEY, 'application/x-sami');
    FileMimeTypeUtil.addFileMimeType('SMI', MimeType.FILE_CATEGORY_UNKNOWN, FileMimeTypeUtil.FILE_TYPE_OTHER,
      FileMimeTypeUtil.ICON_UN_KNOW_KEY, 'application/x-sami');
    FileMimeTypeUtil.addFileMimeType('STR', MimeType.FILE_CATEGORY_UNKNOWN, FileMimeTypeUtil.FILE_TYPE_OTHER,
      FileMimeTypeUtil.ICON_UN_KNOW_KEY, 'application/x-subrip');
    FileMimeTypeUtil.addFileMimeType('SWF', MimeType.FILE_CATEGORY_UNKNOWN, FileMimeTypeUtil.FILE_TYPE_OTHER,
      FileMimeTypeUtil.ICON_UN_KNOW_KEY, 'application/x-shockwave-flash');
    FileMimeTypeUtil.addFileMimeType('CAB', MimeType.FILE_CATEGORY_UNKNOWN, FileMimeTypeUtil.FILE_TYPE_OTHER,
      FileMimeTypeUtil.ICON_UN_KNOW_KEY, 'application/x-shockwave-flash');
    FileMimeTypeUtil.addFileMimeType('CHM', MimeType.FILE_CATEGORY_UNKNOWN, FileMimeTypeUtil.FILE_TYPE_OTHER,
      FileMimeTypeUtil.ICON_CHM_KEY, 'application/x-chm');
    FileMimeTypeUtil.addFileMimeType('UMD', MimeType.FILE_CATEGORY_UNKNOWN, FileMimeTypeUtil.FILE_TYPE_OTHER,
      FileMimeTypeUtil.ICON_UN_KNOW_KEY, 'application/umd');
    FileMimeTypeUtil.addFileMimeType('PDB', MimeType.FILE_CATEGORY_UNKNOWN, FileMimeTypeUtil.FILE_TYPE_OTHER,
      FileMimeTypeUtil.ICON_UN_KNOW_KEY, 'application/ebook');
    FileMimeTypeUtil.addFileMimeType('DCF', MimeType.FILE_CATEGORY_UNKNOWN, FileMimeTypeUtil.FILE_TYPE_OTHER,
      FileMimeTypeUtil.ICON_UN_KNOW_KEY, 'application/vnd.oma.drm.content');
    FileMimeTypeUtil.addFileMimeType('K3G', MimeType.FILE_CATEGORY_UNKNOWN, FileMimeTypeUtil.FILE_TYPE_OTHER,
      FileMimeTypeUtil.ICON_UN_KNOW_KEY, 'application/octet-stream');
  }

  private static addZipType() {
    FileMimeTypeUtil.addFileMimeType('GTAR', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_COMPRESS,
      FileMimeTypeUtil.ICON_COMPRESS_KEY, 'application/x-gtar');
    FileMimeTypeUtil.addFileMimeType('RAR', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_COMPRESS,
      FileMimeTypeUtil.ICON_RAR_KEY, 'application/rar');
    FileMimeTypeUtil.addFileMimeType('TAR', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_COMPRESS,
      FileMimeTypeUtil.ICON_TAR_KEY, 'application/x-tar');
    FileMimeTypeUtil.addFileMimeType('TGZ', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_COMPRESS,
      FileMimeTypeUtil.ICON_COMPRESS_KEY, 'application/x-gtar');
    FileMimeTypeUtil.addFileMimeType('Z', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_COMPRESS,
      FileMimeTypeUtil.ICON_COMPRESS_KEY, 'application/x-compressed');
    FileMimeTypeUtil.addFileMimeType('ZIP', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_COMPRESS,
      FileMimeTypeUtil.ICON_ZIP_KEY, 'application/zip');
    FileMimeTypeUtil.addFileMimeType('JAR', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_COMPRESS,
      FileMimeTypeUtil.ICON_COMPRESS_KEY, 'text/vnd.sun.j2me.app-descriptor');
    FileMimeTypeUtil.addFileMimeType('GZ', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_COMPRESS,
      FileMimeTypeUtil.ICON_GZ_KEY, 'application/x-gzip');
    FileMimeTypeUtil.addFileMimeType('GZIP', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_COMPRESS,
      FileMimeTypeUtil.ICON_GZIP_KEY, 'application/x-gzip');
    FileMimeTypeUtil.addFileMimeType('TGZ', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_COMPRESS,
      FileMimeTypeUtil.ICON_COMPRESS_KEY, 'application/x-gtar');
    FileMimeTypeUtil.addFileMimeType('BZ', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_COMPRESS,
      FileMimeTypeUtil.ICON_COMPRESS_KEY, 'application/x-bzip');
    FileMimeTypeUtil.addFileMimeType('BZ2', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_COMPRESS,
      FileMimeTypeUtil.ICON_COMPRESS_KEY, 'application/x-bzip2');
    FileMimeTypeUtil.addFileMimeType('7Z', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_COMPRESS,
      FileMimeTypeUtil.ICON_7Z_KEY, 'application/x-7z-compressed');
  }

  private static addAudioType() {
    FileMimeTypeUtil.addFileMimeType('IMY', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/imelody');
    FileMimeTypeUtil.addFileMimeType('AAC', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/aac');
    FileMimeTypeUtil.addFileMimeType('AMR', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_AMR_KEY, 'audio/amr');
    FileMimeTypeUtil.addFileMimeType('MID', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/midi');
    FileMimeTypeUtil.addFileMimeType('MPGA', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/mpeg');
    FileMimeTypeUtil.addFileMimeType('MXMF', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/mobile-xmf');
    FileMimeTypeUtil.addFileMimeType('RTTTL', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/midi');
    FileMimeTypeUtil.addFileMimeType('RTX', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'text/richtext');
    FileMimeTypeUtil.addFileMimeType('SMF', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'application/vnd.stardivision.math');
    FileMimeTypeUtil.addFileMimeType('WAV', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_WAV_KEY, 'audio/x-wav');
    FileMimeTypeUtil.addFileMimeType('WMA', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_WMA_KEY, 'audio/x-ms-wma');
    FileMimeTypeUtil.addFileMimeType('OTA', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/midi');
    FileMimeTypeUtil.addFileMimeType('XMF', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/midi');
    FileMimeTypeUtil.addFileMimeType('OGG', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'application/ogg');
    FileMimeTypeUtil.addFileMimeType('PLS', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/x-scpls');
    FileMimeTypeUtil.addFileMimeType('RA', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/x-pn-realaudio');
    FileMimeTypeUtil.addFileMimeType('RAM', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/x-pn-realaudio');
    FileMimeTypeUtil.addFileMimeType('MIDI', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/midi');
    FileMimeTypeUtil.addFileMimeType('M3U', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/x-mpegurl');
    FileMimeTypeUtil.addFileMimeType('M4A', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_M4A_KEY, 'audio/mpeg');
    FileMimeTypeUtil.addFileMimeType('M4B', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/mp4a-latm'); // 原PC代码中M4B对应的为audio/mp4
    FileMimeTypeUtil.addFileMimeType('M4P', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/mp4a-latm'); // 原PC代码中M4P对应的为audio/mp4
    FileMimeTypeUtil.addFileMimeType('AWB', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/amr-wb');
    FileMimeTypeUtil.addFileMimeType('MGG', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/x-*'); // QQ音乐私有加密音乐文件，无标准化MIME类型
    FileMimeTypeUtil.addFileMimeType('MFLAC', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/x-*'); // QQ音乐私有加密音乐文件，无标准化MIME类型
  }

  private static addAudioType2() {
    FileMimeTypeUtil.addFileMimeType('MP2', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/mpeg');
    FileMimeTypeUtil.addFileMimeType('MP3', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_MP3_KEY, 'audio/mpeg');
    FileMimeTypeUtil.addFileMimeType('AU', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/basic');
    FileMimeTypeUtil.addFileMimeType('OGA', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'application/ogg');
    FileMimeTypeUtil.addFileMimeType('WPL', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'application/vnd.ms-wpl');
    FileMimeTypeUtil.addFileMimeType('AC3', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/ac3');
    FileMimeTypeUtil.addFileMimeType('MKA', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/x-matroska');
    FileMimeTypeUtil.addFileMimeType('FLAC', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_FLAC_KEY, 'audio/flac');
    FileMimeTypeUtil.addFileMimeType('AIF', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/x-aiff');
    FileMimeTypeUtil.addFileMimeType('AIFF', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/x-aiff');
    FileMimeTypeUtil.addFileMimeType('AIFC', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/x-aiff');
    FileMimeTypeUtil.addFileMimeType('APE', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_APE_KEY, 'audio/x-ape');
    FileMimeTypeUtil.addFileMimeType('3GA', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/3gpp');
    FileMimeTypeUtil.addFileMimeType('A52', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/ac3');
    FileMimeTypeUtil.addFileMimeType('F4A', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/mp4');
    FileMimeTypeUtil.addFileMimeType('F4B', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/mp4');
    FileMimeTypeUtil.addFileMimeType('F4P', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/mp4');
    FileMimeTypeUtil.addFileMimeType('ADTS', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/aac');
    FileMimeTypeUtil.addFileMimeType('ADT', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/aac');
    FileMimeTypeUtil.addFileMimeType('SND', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/basic');
    FileMimeTypeUtil.addFileMimeType('MP1', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/mpeg');
    FileMimeTypeUtil.addFileMimeType('MPA', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/mpeg');
    FileMimeTypeUtil.addFileMimeType('M4R', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'audio/wav');
    FileMimeTypeUtil.addFileMimeType('MMF', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'application/vnd.smaf');
    FileMimeTypeUtil.addFileMimeType('QCP', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AUDIO,
      FileMimeTypeUtil.ICON_AUDIO_KEY, 'application/octet-stream');
  }

  private static addVideoType() {
    FileMimeTypeUtil.addFileMimeType('RMVB', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/x-pn-realvideo');
    FileMimeTypeUtil.addFileMimeType('M4U', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/vnd.mpegurl');
    FileMimeTypeUtil.addFileMimeType('M4V', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/m4v');
    FileMimeTypeUtil.addFileMimeType('MOV', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/quicktime');
    FileMimeTypeUtil.addFileMimeType('MOVIE', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/x-sgi-movie');
    FileMimeTypeUtil.addFileMimeType('MP4', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/mp4');
    FileMimeTypeUtil.addFileMimeType('MPE', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/mpeg');
    FileMimeTypeUtil.addFileMimeType('MPEG', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/mpeg');
    FileMimeTypeUtil.addFileMimeType('MPG4', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/mpeg');
    FileMimeTypeUtil.addFileMimeType('MKV', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/x-matroska');
    FileMimeTypeUtil.addFileMimeType('WEBM', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/webm');
    FileMimeTypeUtil.addFileMimeType('3GPP', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/3gpp');
    FileMimeTypeUtil.addFileMimeType('3GPP2', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/3gpp2');
    FileMimeTypeUtil.addFileMimeType('ASF', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/x-ms-asf');
    FileMimeTypeUtil.addFileMimeType('ASX', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/x-ms-asf');
    FileMimeTypeUtil.addFileMimeType('AVI', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/avi');
    FileMimeTypeUtil.addFileMimeType('FLV', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/x-flv');
    FileMimeTypeUtil.addFileMimeType('M2TS', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/mpeg'); // 原PC代码中M2TS对应的mimetype为video/avi
    FileMimeTypeUtil.addFileMimeType('3G2', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/3gpp2');
    FileMimeTypeUtil.addFileMimeType('WMV', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/x-ms-wmv');
    FileMimeTypeUtil.addFileMimeType('MPG', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/mpeg');
    FileMimeTypeUtil.addFileMimeType('3GP', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/3gpp');
    FileMimeTypeUtil.addFileMimeType('RV', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/x-pn-realvideo');
    FileMimeTypeUtil.addFileMimeType('RM', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'application/vnd.rn-realmedia');
  }

  private static addVideoType2() {
    FileMimeTypeUtil.addFileMimeType('TS', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/mp2ts');
    FileMimeTypeUtil.addFileMimeType('DIVX', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/divx');
    FileMimeTypeUtil.addFileMimeType('F4V', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/x-f4v'); // 原PC代码中F4V对应的mimetype为video/mp4
    FileMimeTypeUtil.addFileMimeType('MP4V', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/mp4');
    FileMimeTypeUtil.addFileMimeType('MPEG4', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/mp4');
    FileMimeTypeUtil.addFileMimeType('MTS', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/avi');
    FileMimeTypeUtil.addFileMimeType('VT', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/vnd.youtube.yt');
    FileMimeTypeUtil.addFileMimeType('3GP2', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/3gpp2');
    FileMimeTypeUtil.addFileMimeType('MPEG2', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/mpeg');
    FileMimeTypeUtil.addFileMimeType('MPV2', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/mpeg');
    FileMimeTypeUtil.addFileMimeType('MP2V', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/mpeg');
    FileMimeTypeUtil.addFileMimeType('M2V', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/mpeg');
    FileMimeTypeUtil.addFileMimeType('M2T', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/mpeg');
    FileMimeTypeUtil.addFileMimeType('WRF', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/x-webex');
    FileMimeTypeUtil.addFileMimeType('MPEG1', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/mpeg');
    FileMimeTypeUtil.addFileMimeType('MPV1', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/mpeg');
    FileMimeTypeUtil.addFileMimeType('MP1V', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/mpeg');
    FileMimeTypeUtil.addFileMimeType('M1V', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/mpeg');
    FileMimeTypeUtil.addFileMimeType('H264', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_VIDEO,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'video/H264');
  }

  private static addImageType() {
    FileMimeTypeUtil.addFileMimeType('PNG', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/png');
    FileMimeTypeUtil.addFileMimeType('WBMP', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/vnd.wap.wbmp');
    FileMimeTypeUtil.addFileMimeType('BMP', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/bmp');
    FileMimeTypeUtil.addFileMimeType('GIF', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/gif');
    FileMimeTypeUtil.addFileMimeType('JPEG', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/jpeg');
    FileMimeTypeUtil.addFileMimeType('JPG', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/jpeg');
    FileMimeTypeUtil.addFileMimeType('JPE', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/jpeg');
    FileMimeTypeUtil.addFileMimeType('CR2', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/cr2');
    FileMimeTypeUtil.addFileMimeType('PSD', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/x-photoshop');
  }

  private static addImageType2() {
    FileMimeTypeUtil.addFileMimeType('HEIC', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/heif');
    FileMimeTypeUtil.addFileMimeType('HEIF', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/heif');
    FileMimeTypeUtil.addFileMimeType('DNG', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/x-adobe-dng');
    FileMimeTypeUtil.addFileMimeType('WEBP', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/webp');
    FileMimeTypeUtil.addFileMimeType('TIF', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/tiff');
    FileMimeTypeUtil.addFileMimeType('TIFF', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/tiff');
    FileMimeTypeUtil.addFileMimeType('ICO', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/x-icon');
    FileMimeTypeUtil.addFileMimeType('ARW', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/x-sony-arw');
    FileMimeTypeUtil.addFileMimeType('SVG', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/svg+xml');
    FileMimeTypeUtil.addFileMimeType('HIF', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/heif');
    FileMimeTypeUtil.addFileMimeType('BM', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/bmp');
    FileMimeTypeUtil.addFileMimeType('HEICS', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/heic-sequence');
    FileMimeTypeUtil.addFileMimeType('HEIFS', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/heic-sequence');
    FileMimeTypeUtil.addFileMimeType('AVIF', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/avif');
    FileMimeTypeUtil.addFileMimeType('CUR', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/ico');
    FileMimeTypeUtil.addFileMimeType('MPO', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/mpo');
    FileMimeTypeUtil.addFileMimeType('RAW', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_PICTURE_KEY, 'image/raw');
    FileMimeTypeUtil.addFileMimeType('RAF', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'image/x-fuji-raf');
    FileMimeTypeUtil.addFileMimeType('NRW', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'image/x-nikon-nrw');
    FileMimeTypeUtil.addFileMimeType('RW2', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'image/x-panasonic-rw2');
    FileMimeTypeUtil.addFileMimeType('PEF', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_IMAGE,
      FileMimeTypeUtil.ICON_VIDEO_KEY, 'image/x-samsung-srw');
  }

  private static addTxtType() {
    FileMimeTypeUtil.addFileMimeType('TEXT', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_TEXT_KEY, 'text/plain');
    FileMimeTypeUtil.addFileMimeType('TXT', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_TEXT_KEY, 'text/plain');
    FileMimeTypeUtil.addFileMimeType('XHTML', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_XML_KEY, 'application/xhtml+xml');
    FileMimeTypeUtil.addFileMimeType('JS', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_FILE_KEY, 'application/x-javascript');
    FileMimeTypeUtil.addFileMimeType('C', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_FILE_KEY, 'text/x-csrc');
    FileMimeTypeUtil.addFileMimeType('CONF', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_FILE_KEY, 'text/plain');
    FileMimeTypeUtil.addFileMimeType('CPP', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_FILE_KEY, 'text/x-c++src');
    FileMimeTypeUtil.addFileMimeType('H', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_FILE_KEY, 'text/x-chdr');
    FileMimeTypeUtil.addFileMimeType('JAVA', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_FILE_KEY, 'text/x-java');
    FileMimeTypeUtil.addFileMimeType('LOG', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_LOG_KEY, 'text/plain');
    FileMimeTypeUtil.addFileMimeType('PROP', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_FILE_KEY, 'text/plain');
    FileMimeTypeUtil.addFileMimeType('RC', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_FILE_KEY, 'text/plain');
    FileMimeTypeUtil.addFileMimeType('SH', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_FILE_KEY, 'text/plain');
    FileMimeTypeUtil.addFileMimeType('SUB', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_FILE_KEY, 'text/x-subviewer');
    FileMimeTypeUtil.addFileMimeType('ASS', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_FILE_KEY, 'text/x-ssa');
    FileMimeTypeUtil.addFileMimeType('SSA', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_FILE_KEY, 'text/x-ssa');
    FileMimeTypeUtil.addFileMimeType('JAD', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_FILE_KEY, 'text/vnd.sun.j2me.app-descriptor');
    FileMimeTypeUtil.addFileMimeType('INI', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_FILE_KEY, 'text/plain');
  }

  private static addTxtType2() {
    FileMimeTypeUtil.addFileMimeType('VCS', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_CALENDAR_KEY, 'text/x-vcalendar');
    FileMimeTypeUtil.addFileMimeType('ICS', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_CALENDAR_KEY, 'text/calendar');
    FileMimeTypeUtil.addFileMimeType('JSP', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_FILE_KEY, 'text/html');
    FileMimeTypeUtil.addFileMimeType('ASP', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_FILE_KEY, 'text/html');
    FileMimeTypeUtil.addFileMimeType('PHP', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_FILE_KEY, 'text/html');
    FileMimeTypeUtil.addFileMimeType('MSG', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_FILE_KEY, 'application/vnd.ms-outlook');
    FileMimeTypeUtil.addFileMimeType('MPC', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_UN_KNOW_KEY, 'application/vnd.mpohun.certificate');
    FileMimeTypeUtil.addFileMimeType('HTM', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_HTML_KEY, 'text/html');
    FileMimeTypeUtil.addFileMimeType('HTML', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_HTML_KEY, 'text/html');
    FileMimeTypeUtil.addFileMimeType('XML', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_XML_KEY, 'text/xml');
    FileMimeTypeUtil.addFileMimeType('DHTML', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_HTML_KEY, 'text/html');
    FileMimeTypeUtil.addFileMimeType('SHTML', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_HTML_KEY, 'text/html');
    FileMimeTypeUtil.addFileMimeType('VCF', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TXT,
      FileMimeTypeUtil.ICON_VCARD_KEY, 'text/x-vcard');
  }

  private static addExcelType() {
    FileMimeTypeUtil.addFileMimeType('XLS', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_EXCEL,
      FileMimeTypeUtil.ICON_XLS_KEY, 'application/vnd.ms-excel');
    FileMimeTypeUtil.addFileMimeType('XLSX', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_EXCEL,
      FileMimeTypeUtil.ICON_XLS_KEY, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    FileMimeTypeUtil.addFileMimeType('XLSM', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_EXCEL,
      FileMimeTypeUtil.ICON_XLS_KEY, 'application/vnd.ms-excel.sheet.macroEnabled.12');
    FileMimeTypeUtil.addFileMimeType('XLTM', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_EXCEL,
      FileMimeTypeUtil.ICON_XLS_KEY, 'application/vnd.ms-excel.template.macroEnabled.12');
    FileMimeTypeUtil.addFileMimeType('ET', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_EXCEL,
      FileMimeTypeUtil.ICON_XLS_KEY, 'application/et');
    FileMimeTypeUtil.addFileMimeType('XLT', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_EXCEL,
      FileMimeTypeUtil.ICON_XLS_KEY, 'application/vnd.ms-excel');
    FileMimeTypeUtil.addFileMimeType('XLTX', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_EXCEL,
      FileMimeTypeUtil.ICON_XLS_KEY, 'application/vnd.openxmlformats-officedocument.spreadsheetml.template');
    FileMimeTypeUtil.addFileMimeType('CSV', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_EXCEL,
      FileMimeTypeUtil.ICON_XLS_KEY, 'text/comma-separated-values');
  }

  private static addPPTType() {
    FileMimeTypeUtil.addFileMimeType('PPS', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_PPT,
      FileMimeTypeUtil.ICON_PPT_KEY, 'application/vnd.ms-powerpoint');
    FileMimeTypeUtil.addFileMimeType('PPT', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_PPT,
      FileMimeTypeUtil.ICON_PPT_KEY, 'application/vnd.ms-powerpoint');
    FileMimeTypeUtil.addFileMimeType('PPTX', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_PPT,
      FileMimeTypeUtil.ICON_PPT_KEY, 'application/vnd.openxmlformats-officedocument.presentationml.presentation');
    FileMimeTypeUtil.addFileMimeType('PPTM', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_PPT,
      FileMimeTypeUtil.ICON_PPT_KEY, 'application/vnd.ms-powerpoint.presentation.macroEnabled.12');
    FileMimeTypeUtil.addFileMimeType('PPSM', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_PPT,
      FileMimeTypeUtil.ICON_PPT_KEY, 'application/vnd.ms-powerpoint.slideshow.macroEnabled.12');
    FileMimeTypeUtil.addFileMimeType('POTM', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_PPT,
      FileMimeTypeUtil.ICON_PPT_KEY, 'application/vnd.ms-powerpoint.template.macroEnabled.12');
    FileMimeTypeUtil.addFileMimeType('DPS', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_PPT,
      FileMimeTypeUtil.ICON_PPT_KEY, 'application/dps');
    FileMimeTypeUtil.addFileMimeType('DPT', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_PPT,
      FileMimeTypeUtil.ICON_PPT_KEY, 'application/dpt');
    FileMimeTypeUtil.addFileMimeType('POT', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_PPT,
      FileMimeTypeUtil.ICON_PPT_KEY, 'application/vnd.ms-powerpoint');
    FileMimeTypeUtil.addFileMimeType('POTX', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_PPT,
      FileMimeTypeUtil.ICON_PPT_KEY, 'application/vnd.openxmlformats-officedocument.presentationml.template');
    FileMimeTypeUtil.addFileMimeType('PPSX', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_PPT,
      FileMimeTypeUtil.ICON_PPT_KEY, 'application/vnd.openxmlformats-officedocument.presentationml.slideshow');
  }

  private static addWordType() {
    FileMimeTypeUtil.addFileMimeType('DOCX', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_WORD,
      FileMimeTypeUtil.ICON_DOC_KEY, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
    FileMimeTypeUtil.addFileMimeType('DOC', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_WORD,
      FileMimeTypeUtil.ICON_DOC_KEY, 'application/msword');
    FileMimeTypeUtil.addFileMimeType('DOCM', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_WORD,
      FileMimeTypeUtil.ICON_DOC_KEY, 'application/vnd.ms-word.document.macroEnabled.12');
    FileMimeTypeUtil.addFileMimeType('DOTM', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_WORD,
      FileMimeTypeUtil.ICON_DOC_KEY, 'application/vnd.ms-word.template.macroEnabled.12');
    FileMimeTypeUtil.addFileMimeType('WPT', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_WORD,
      FileMimeTypeUtil.ICON_DOC_KEY, 'application/wpt');
    FileMimeTypeUtil.addFileMimeType('RTF', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_WORD,
      FileMimeTypeUtil.ICON_DOC_KEY, 'text/rtf');
    FileMimeTypeUtil.addFileMimeType('WPS', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_WORD,
      FileMimeTypeUtil.ICON_DOC_KEY, 'application/vnd.ms-works');
    FileMimeTypeUtil.addFileMimeType('DOTX', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_WORD,
      FileMimeTypeUtil.ICON_DOC_KEY, 'application/vnd.openxmlformats-officedocument.wordprocessingml.template');
    FileMimeTypeUtil.addFileMimeType('DOT', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_WORD,
      FileMimeTypeUtil.ICON_DOC_KEY, 'application/msword');
  }

  private static getFileMiMeTypeMap(): Map<string, MimeType> {
    if (FileMimeTypeUtil.fileMimeTypeMap.size === 0) {
      FileMimeTypeUtil.setFileMimeTypeMap();
    }
    return FileMimeTypeUtil.fileMimeTypeMap;
  }
}

export default FileMimeTypeUtil;