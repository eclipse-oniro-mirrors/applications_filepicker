/*
 * Copyright (c) 2021-2023 Huawei Device Co., Ltd.
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

import { MimeType } from '../../databases/model/MimeType';
import StringUtil from '../../base/utils/StringUtil';

/**
 * 文件媒体类型
 */
export class FileMimeTypeUtil {
  /**
   * Image file types
   */
  public static FILE_TYPE_PNG: number = 1;
  public static FILE_TYPE_JPG: number = 2;
  public static FILE_TYPE_JPEG: number = 3;
  public static FILE_TYPE_GIF: number = 4;
  public static FILE_TYPE_BMP: number = 5;
  public static FILE_TYPE_ICO: number = 6;
  public static FILE_TYPE_RAW: number = 7;
  public static FILE_TYPE_TIF: number = 8;
  public static FILE_TYPE_WEBP: number = 9;
  public static FILE_TYPE_HEIC: number = 10;
  public static FILE_TYPE_WBMP: number = 12;
  public static FILE_TYPE_CR2: number = 13;
  public static FILE_TYPE_PSD: number = 14;
  private static FIRST_IMAGE_FILE_TYPE: number = FileMimeTypeUtil.FILE_TYPE_PNG;
  private static LAST_IMAGE_FILE_TYPE: number = FileMimeTypeUtil.FILE_TYPE_PSD;
  /**
   * Video file types
   */
  public static FILE_TYPE_MP4: number = 21;
  public static FILE_TYPE_AVI: number = 22;
  public static FILE_TYPE_MP2TS: number = 23;
  public static FILE_TYPE_MOV: number = 24;
  public static FILE_TYPE_RM: number = 25;
  public static FILE_TYPE_RMVB: number = 26;
  public static FILE_TYPE_FLV: number = 27;
  public static FILE_TYPE_MKV: number = 28;
  public static FILE_TYPE_M4U: number = 29;
  public static FILE_TYPE_WMV: number = 30;
  public static FILE_TYPE_ASF: number = 31;
  public static FILE_TYPE_RV: number = 32;
  public static FILE_TYPE_DIVX: number = 33;
  public static FILE_TYPE_3GPP: number = 34;
  public static FILE_TYPE_M4V: number = 35;
  public static FILE_TYPE_F4V: number = 36;
  public static FILE_TYPE_WEBM: number = 37;
  public static FILE_TYPE_3GPP2: number = 38;
  public static FILE_TYPE_MP2PS: number = 39;
  private static FIRST_VIDEO_FILE_TYPE: number = FileMimeTypeUtil.FILE_TYPE_MP4;
  private static LAST_VIDEO_FILE_TYPE: number = FileMimeTypeUtil.FILE_TYPE_MP2PS;
  /**
   * document file types
   */
  public static FILE_TYPE_MS_WORD: number = 50;
  public static FILE_TYPE_MS_POWERPOINT: number = 52;
  public static FILE_TYPE_MS_EXCEL: number = 53;
  public static FILE_TYPE_PDF: number = 54;
  public static FILE_TYPE_HTML: number = 55;
  public static FILE_TYPE_XML: number = 56;
  public static FILE_TYPE_TEXT: number = 57;
  public static FILE_TYPE_MORE_TEXT: number = 58;
  private static FIRST_DOC_FILE_TYPE: number = FileMimeTypeUtil.FILE_TYPE_MS_WORD;
  private static LAST_DOC_FILE_TYPE: number = FileMimeTypeUtil.FILE_TYPE_MORE_TEXT;
  /**
   * Audio file types
   */
  public static FILE_TYPE_MP3: number = 70;
  public static FILE_TYPE_WAV: number = 71;
  public static FILE_TYPE_AAC: number = 72;
  public static FILE_TYPE_RAM: number = 73;
  public static FILE_TYPE_APE: number = 74;
  public static FILE_TYPE_WMA: number = 75;
  public static FILE_TYPE_AU: number = 76;
  public static FILE_TYPE_FLAC: number = 77;
  public static FILE_TYPE_MP2: number = 78;
  public static FILE_TYPE_RA: number = 79;
  public static FILE_TYPE_AC3: number = 80;
  public static FILE_TYPE_OGG: number = 81;
  public static FILE_TYPE_AMR: number = 82;
  public static FILE_TYPE_M4A: number = 83;
  public static FILE_TYPE_MP4A: number = 84;
  public static FILE_TYPE_AIFF: number = 85;
  public static FILE_TYPE_MMF: number = 86;
  public static FILE_TYPE_AWB: number = 87;
  public static FILE_TYPE_MKA: number = 88;
  public static FILE_TYPE_QCP: number = 89;
  public static FILE_TYPE_MPGA: number = 90;
  public static FILE_TYPE_MXMF: number = 91;
  public static FILE_TYPE_MID: number = 92;
  public static FILE_TYPE_SMF: number = 93;
  public static FILE_TYPE_IMY: number = 94;
  public static FILE_TYPE_M3U: number = 95;
  public static FILE_TYPE_PLS: number = 96;
  public static FILE_TYPE_WPL: number = 97;
  public static FILE_TYPE_RM_AUDIO: number = 98;
  public static FILE_TYPE_MP4_AUDIO: number = 99;
  public static FILE_TYPE_3GPP_AUDIO: number = 100;
  private static FIRST_AUDIO_FILE_TYPE: number = FileMimeTypeUtil.FILE_TYPE_MP3;
  private static LAST_AUDIO_FILE_TYPE: number = FileMimeTypeUtil.FILE_TYPE_3GPP_AUDIO;
  /**
   * compressed file types
   */
  public static FILE_TYPE_ZIP: number = 110;
  public static FILE_TYPE_RAR: number = 111;
  public static FILE_TYPE_JAR: number = 112;
  public static FILE_TYPE_GZ: number = 113;
  public static FILE_TYPE_TAR: number = 114;
  public static FILE_TYPE_Z: number = 115;
  public static FILE_TYPE_7Z: number = 116;
  public static FILE_TYPE_BZ: number = 117;
  public static FILE_TYPE_BZ2: number = 118;
  public static FILE_TYPE_TGZ: number = 119;
  private static FIRST_COMPRESS_FILE_TYPE: number = FileMimeTypeUtil.FILE_TYPE_ZIP;
  private static LAST_COMPRESS_FILE_TYPE: number = FileMimeTypeUtil.FILE_TYPE_TGZ;
  /**
   * apk file types
   */
  public static FILE_TYPE_APK: number = 130;
  public static FILE_TYPE_HAP: number = 131;
  /**
   * vcf file types
   */
  public static FILE_TYPE_VCF: number = 135;
  /**
   * 未知类型
   */
  public static FILE_TYPE_UNKNOW: number = 200;
  public static SUFFIX_DLP = 'DLP';
  private static UNKNOW_MIMETYPE: MimeType = new MimeType(
    '',
    MimeType.FILE_CATEGORY_UNKNOW,
    FileMimeTypeUtil.FILE_TYPE_UNKNOW,
    $r('app.media.hidisk_icon_unknown'),
    $r('app.media.hidisk_icon_unknown_grid'),
    $r('app.media.hidisk_icon_unknown_grid_local'),
    ''
  );
  private static fileMimeTypeMap: Map<string, MimeType> = new Map<string, MimeType>();

  private static addFileMimeType(extension: string, fileCategory: number, fileTypeSort: number, resID: Resource,
                                 gridResID: Resource, localGridResID: Resource, mimeType: string): void {
    const mType: MimeType = new MimeType(extension, fileCategory,
      fileTypeSort, resID, gridResID, localGridResID, mimeType)
    FileMimeTypeUtil.fileMimeTypeMap.set(extension, mType);
  }



  static setFileMimeTypeMap() {
    // 图片
    FileMimeTypeUtil.addFileMimeType('PNG', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_PNG,
      $r('app.media.hidisk_icon_picture'), $r('app.media.hidisk_icon_picture_grid'),
      $r('app.media.hidisk_icon_picture_grid_local'), 'image/png');
    FileMimeTypeUtil.addFileMimeType('WBMP', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_WBMP,
      $r('app.media.hidisk_icon_picture'), $r('app.media.hidisk_icon_picture_grid'),
      $r('app.media.hidisk_icon_picture_grid_local'), 'image/vnd.wap.wbmp');
    FileMimeTypeUtil.addFileMimeType('BMP', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_BMP,
      $r('app.media.hidisk_icon_picture'), $r('app.media.hidisk_icon_picture_grid'),
      $r('app.media.hidisk_icon_picture_grid_local'), 'image/bmp');
    FileMimeTypeUtil.addFileMimeType('GIF', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_GIF,
      $r('app.media.hidisk_icon_picture'), $r('app.media.hidisk_icon_picture_grid'),
      $r('app.media.hidisk_icon_picture_grid_local'), 'image/gif');
    FileMimeTypeUtil.addFileMimeType('JPEG', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_JPEG,
      $r('app.media.hidisk_icon_picture'), $r('app.media.hidisk_icon_picture_grid'),
      $r('app.media.hidisk_icon_picture_grid_local'), 'image/jpeg');
    FileMimeTypeUtil.addFileMimeType('JPG', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_JPG,
      $r('app.media.hidisk_icon_picture'), $r('app.media.hidisk_icon_picture_grid'),
      $r('app.media.hidisk_icon_picture_grid_local'), 'image/jpeg');
    FileMimeTypeUtil.addFileMimeType('JPE', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_JPEG,
      $r('app.media.hidisk_icon_picture'), $r('app.media.hidisk_icon_picture_grid'),
      $r('app.media.hidisk_icon_picture_grid_local'), 'image/jpeg');
    FileMimeTypeUtil.addFileMimeType('CR2', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_CR2,
      $r('app.media.hidisk_icon_picture'), $r('app.media.hidisk_icon_picture_grid'),
      $r('app.media.hidisk_icon_picture_grid_local'), 'image/cr2');
    FileMimeTypeUtil.addFileMimeType('PSD', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_PSD,
      $r('app.media.hidisk_icon_picture'), $r('app.media.hidisk_icon_picture_grid'),
      $r('app.media.hidisk_icon_picture_grid_local'), 'image/psd');
    FileMimeTypeUtil.addFileMimeType('HEIC', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_HEIC,
      $r('app.media.hidisk_icon_picture'), $r('app.media.hidisk_icon_picture_grid'),
      $r('app.media.hidisk_icon_picture_grid_local'), 'image/heif');
    FileMimeTypeUtil.addFileMimeType('HEIF', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_HEIC,
      $r('app.media.hidisk_icon_picture'), $r('app.media.hidisk_icon_picture_grid'),
      $r('app.media.hidisk_icon_picture_grid_local'), 'image/heif');
    FileMimeTypeUtil.addFileMimeType('DNG', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_RAW,
      $r('app.media.hidisk_icon_picture'), $r('app.media.hidisk_icon_picture_grid'),
      $r('app.media.hidisk_icon_picture_grid_local'), 'image/x-adobe-dng');
    FileMimeTypeUtil.addFileMimeType('WEBP', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_WEBP,
      $r('app.media.hidisk_icon_picture'), $r('app.media.hidisk_icon_picture_grid'),
      $r('app.media.hidisk_icon_picture_grid_local'), 'image/webp');
    FileMimeTypeUtil.addFileMimeType('TIF', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_TIF,
      $r('app.media.hidisk_icon_picture'), $r('app.media.hidisk_icon_picture_grid'),
      $r('app.media.hidisk_icon_picture_grid_local'), 'image/tiff');
    FileMimeTypeUtil.addFileMimeType('ICO', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_ICO,
      $r('app.media.hidisk_icon_picture'), $r('app.media.hidisk_icon_picture_grid'),
      $r('app.media.hidisk_icon_picture_grid_local'), 'image/x-icon');
    FileMimeTypeUtil.addFileMimeType('ARW', MimeType.FILE_CATEGORY_IMAGE, FileMimeTypeUtil.FILE_TYPE_RAW,
      $r('app.media.hidisk_icon_picture'), $r('app.media.hidisk_icon_picture_grid'),
      $r('app.media.hidisk_icon_picture_grid_local'), 'image/x-sony-arw');

    // 视频
    FileMimeTypeUtil.addFileMimeType('RMVB', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_RMVB,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/x-pn-realvideo');
    FileMimeTypeUtil.addFileMimeType('M4U', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_M4U,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/vnd.mpegurl');
    FileMimeTypeUtil.addFileMimeType('M4V', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_M4V,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/x-m4v');
    FileMimeTypeUtil.addFileMimeType('MOV', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_MOV,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/quicktime');
    FileMimeTypeUtil.addFileMimeType('MP4', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_MP4,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/mp4');
    FileMimeTypeUtil.addFileMimeType('MPE', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_MP4,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/mpeg');
    FileMimeTypeUtil.addFileMimeType('MPEG', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_MP2PS,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/mpeg');
    FileMimeTypeUtil.addFileMimeType('MPG4', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_MP4,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/mpeg');
    FileMimeTypeUtil.addFileMimeType('MKV', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_MKV,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/x-matroska');
    FileMimeTypeUtil.addFileMimeType('WEBM', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_WEBM,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/x-matroska');
    FileMimeTypeUtil.addFileMimeType('3GPP', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_3GPP,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/3gpp');
    FileMimeTypeUtil.addFileMimeType('ASF', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_ASF,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/x-ms-asf');
    FileMimeTypeUtil.addFileMimeType('ASX', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_ASF,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/x-ms-asf');
    FileMimeTypeUtil.addFileMimeType('AVI', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_AVI,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/x-msvideo');
    FileMimeTypeUtil.addFileMimeType('FLV', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_FLV,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/x-flv');
    FileMimeTypeUtil.addFileMimeType('M2TS', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_MP2PS,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/mpeg');
    FileMimeTypeUtil.addFileMimeType('3G2', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_3GPP2,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/3gpp2');
    FileMimeTypeUtil.addFileMimeType('WMV', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_WMV,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/x-ms-wmv');
    FileMimeTypeUtil.addFileMimeType('MPG', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_MP4,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/video/mp2p');
    FileMimeTypeUtil.addFileMimeType('3GP', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_3GPP,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/video/3gpp');
    FileMimeTypeUtil.addFileMimeType('RV', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_RV,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/x-pn-realvideo');
    FileMimeTypeUtil.addFileMimeType('TS', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_MP2TS,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/mp2ts');
    FileMimeTypeUtil.addFileMimeType('DIVX', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_DIVX,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/divx');
    FileMimeTypeUtil.addFileMimeType('F4V', MimeType.FILE_CATEGORY_VIDEO, FileMimeTypeUtil.FILE_TYPE_F4V,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'video/x-f4v');

    // 文档
    FileMimeTypeUtil.addFileMimeType('DOCX', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_WORD,
      $r('app.media.hidisk_icon_doc'), $r('app.media.hidisk_icon_doc_grid'),
      $r('app.media.hidisk_icon_doc_grid_local'),
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
    FileMimeTypeUtil.addFileMimeType('DOC', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_WORD,
      $r('app.media.hidisk_icon_doc'), $r('app.media.hidisk_icon_doc_grid'),
      $r('app.media.hidisk_icon_doc_grid_local'), 'application/msword');
    FileMimeTypeUtil.addFileMimeType('DOCM', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_WORD,
      $r('app.media.hidisk_icon_doc'), $r('app.media.hidisk_icon_doc_grid'),
      $r('app.media.hidisk_icon_doc_grid_local'),
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
    FileMimeTypeUtil.addFileMimeType('DOTM', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_WORD,
      $r('app.media.hidisk_icon_doc'), $r('app.media.hidisk_icon_doc_grid'),
      $r('app.media.hidisk_icon_doc_grid_local'),
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
    FileMimeTypeUtil.addFileMimeType('WPT', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_WORD,
      $r('app.media.hidisk_icon_doc'), $r('app.media.hidisk_icon_doc_grid'),
      $r('app.media.hidisk_icon_doc_grid_local'), 'application/wpt');
    FileMimeTypeUtil.addFileMimeType('XLS', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_EXCEL,
      $r('app.media.hidisk_icon_xls'), $r('app.media.hidisk_icon_xls_grid'),
      $r('app.media.hidisk_icon_xls_grid_local'), 'application/vnd.ms-excel');
    FileMimeTypeUtil.addFileMimeType('XLSX', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_EXCEL,
      $r('app.media.hidisk_icon_xls'), $r('app.media.hidisk_icon_xls_grid'),
      $r('app.media.hidisk_icon_xls_grid_local'), 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    FileMimeTypeUtil.addFileMimeType('XLSM', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_EXCEL,
      $r('app.media.hidisk_icon_xls'), $r('app.media.hidisk_icon_xls_grid'),
      $r('app.media.hidisk_icon_xls_grid_local'), 'application/vnd.ms-excel.sheet.macroEnabled.12');
    FileMimeTypeUtil.addFileMimeType('XLTM', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_EXCEL,
      $r('app.media.hidisk_icon_xls'), $r('app.media.hidisk_icon_xls_grid'),
      $r('app.media.hidisk_icon_xls_grid_local'), 'application/vnd.ms-excel.template.macroEnabled.12');
    FileMimeTypeUtil.addFileMimeType('ET', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_EXCEL,
      $r('app.media.hidisk_icon_xls'), $r('app.media.hidisk_icon_xls_grid'),
      $r('app.media.hidisk_icon_xls_grid_local'), 'application/et');
    FileMimeTypeUtil.addFileMimeType('PPS', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_POWERPOINT,
      $r('app.media.hidisk_icon_ppt'), $r('app.media.hidisk_icon_ppt_grid'),
      $r('app.media.hidisk_icon_ppt_grid_local'), 'application/vnd.ms-powerpoint');
    FileMimeTypeUtil.addFileMimeType('PPT', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_POWERPOINT,
      $r('app.media.hidisk_icon_ppt'), $r('app.media.hidisk_icon_ppt_grid'),
      $r('app.media.hidisk_icon_ppt_grid_local'), 'application/vnd.ms-powerpoint');
    FileMimeTypeUtil.addFileMimeType('PPTX', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_POWERPOINT,
      $r('app.media.hidisk_icon_ppt'), $r('app.media.hidisk_icon_ppt_grid'),
      $r('app.media.hidisk_icon_ppt_grid_local'),
      'application/vnd.openxmlformats-officedocument.presentationml.presentation');
    FileMimeTypeUtil.addFileMimeType('PPTM', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_POWERPOINT,
      $r('app.media.hidisk_icon_ppt'), $r('app.media.hidisk_icon_ppt_grid'),
      $r('app.media.hidisk_icon_ppt_grid_local'), 'application/vnd.ms-powerpoint.presentation.macroEnabled.12');
    FileMimeTypeUtil.addFileMimeType('PPSM', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_POWERPOINT,
      $r('app.media.hidisk_icon_ppt'), $r('app.media.hidisk_icon_ppt_grid'),
      $r('app.media.hidisk_icon_ppt_grid_local'), 'application/vnd.ms-powerpoint.slideshow.macroEnabled.12');
    FileMimeTypeUtil.addFileMimeType('POTM', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_POWERPOINT,
      $r('app.media.hidisk_icon_ppt'), $r('app.media.hidisk_icon_ppt_grid'),
      $r('app.media.hidisk_icon_ppt_grid_local'), 'application/vnd.ms-powerpoint.presentation.macroEnabled.12');
    FileMimeTypeUtil.addFileMimeType('DPS', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_POWERPOINT,
      $r('app.media.hidisk_icon_ppt'), $r('app.media.hidisk_icon_ppt_grid'),
      $r('app.media.hidisk_icon_ppt_grid_local'), 'application/dps');
    FileMimeTypeUtil.addFileMimeType('DPT', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_POWERPOINT,
      $r('app.media.hidisk_icon_ppt'), $r('app.media.hidisk_icon_ppt_grid'),
      $r('app.media.hidisk_icon_ppt_grid_local'), 'application/dpt');
    FileMimeTypeUtil.addFileMimeType('MSG', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_UNKNOW,
      $r('app.media.hidisk_icon_file'), $r('app.media.hidisk_icon_file_grid'),
      $r('app.media.hidisk_icon_file_grid_local'), 'application/vnd.ms-outlook');
    FileMimeTypeUtil.addFileMimeType('PDF', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_PDF,
      $r('app.media.hidisk_icon_pdf'), $r('app.media.hidisk_icon_pdf_grid'),
      $r('app.media.hidisk_icon_pdf_grid_local'), 'application/pdf');
    FileMimeTypeUtil.addFileMimeType('RTF', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_WORD,
      $r('app.media.hidisk_icon_doc'), $r('app.media.hidisk_icon_doc_grid'),
      $r('app.media.hidisk_icon_doc_grid_local'), 'application/rtf');
    FileMimeTypeUtil.addFileMimeType('WPS', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_WORD,
      $r('app.media.hidisk_icon_doc'), $r('app.media.hidisk_icon_doc_grid'),
      $r('app.media.hidisk_icon_doc_grid_local'), 'application/vnd.ms-works');
    FileMimeTypeUtil.addFileMimeType('XHTML', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MORE_TEXT,
      $r('app.media.hidisk_icon_xml'), $r('app.media.hidisk_icon_xml_grid'),
      $r('app.media.hidisk_icon_xml_grid_local'), 'application/xhtml+xml');
    FileMimeTypeUtil.addFileMimeType('MPC', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_UNKNOW,
      $r('app.media.hidisk_icon_unknown'), $r('app.media.hidisk_icon_unknown_grid'),
      $r('app.media.hidisk_icon_unknown_grid_local'), 'application/vnd.mpohun.certificate');
    FileMimeTypeUtil.addFileMimeType('JS', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MORE_TEXT,
      $r('app.media.hidisk_icon_file'), $r('app.media.hidisk_icon_file_grid'),
      $r('app.media.hidisk_icon_file_grid_local'), 'application/x-javascript');
    FileMimeTypeUtil.addFileMimeType('C', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MORE_TEXT,
      $r('app.media.hidisk_icon_file'), $r('app.media.hidisk_icon_file_grid'),
      $r('app.media.hidisk_icon_file_grid_local'), 'text/plain');
    FileMimeTypeUtil.addFileMimeType('CONF', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MORE_TEXT,
      $r('app.media.hidisk_icon_file'), $r('app.media.hidisk_icon_file_grid'),
      $r('app.media.hidisk_icon_file_grid_local'), 'text/plain');
    FileMimeTypeUtil.addFileMimeType('CPP', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MORE_TEXT,
      $r('app.media.hidisk_icon_file'), $r('app.media.hidisk_icon_file_grid'),
      $r('app.media.hidisk_icon_file_grid_local'), 'text/plain');
    FileMimeTypeUtil.addFileMimeType('H', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MORE_TEXT,
      $r('app.media.hidisk_icon_file'), $r('app.media.hidisk_icon_file_grid'),
      $r('app.media.hidisk_icon_file_grid_local'), 'text/plain');
    FileMimeTypeUtil.addFileMimeType('HTM', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_HTML,
      $r('app.media.hidisk_icon_html'), $r('app.media.hidisk_icon_html_grid'),
      $r('app.media.hidisk_icon_html_grid_local'), 'text/html');
    FileMimeTypeUtil.addFileMimeType('HTML', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_HTML,
      $r('app.media.hidisk_icon_html'), $r('app.media.hidisk_icon_html_grid'),
      $r('app.media.hidisk_icon_html_grid_local'), 'text/html');
    FileMimeTypeUtil.addFileMimeType('JAVA', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MORE_TEXT,
      $r('app.media.hidisk_icon_file'), $r('app.media.hidisk_icon_file_grid'),
      $r('app.media.hidisk_icon_file_grid_local'), 'text/plain');
    FileMimeTypeUtil.addFileMimeType('LOG', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MORE_TEXT,
      $r('app.media.hidisk_icon_log'), $r('app.media.hidisk_icon_log_grid'),
      $r('app.media.hidisk_icon_log_grid_local'), 'text/plain');
    FileMimeTypeUtil.addFileMimeType('PROP', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MORE_TEXT,
      $r('app.media.hidisk_icon_file'), $r('app.media.hidisk_icon_file_grid'),
      $r('app.media.hidisk_icon_file_grid_local'), 'text/plain');
    FileMimeTypeUtil.addFileMimeType('RC', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MORE_TEXT,
      $r('app.media.hidisk_icon_file'), $r('app.media.hidisk_icon_file_grid'),
      $r('app.media.hidisk_icon_file_grid_local'), 'text/plain');
    FileMimeTypeUtil.addFileMimeType('SH', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MORE_TEXT,
      $r('app.media.hidisk_icon_file'), $r('app.media.hidisk_icon_file_grid'),
      $r('app.media.hidisk_icon_file_grid_local'), 'text/plain');
    FileMimeTypeUtil.addFileMimeType('TXT', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TEXT,
      $r('app.media.hidisk_icon_text'), $r('app.media.hidisk_icon_text_grid'),
      $r('app.media.hidisk_icon_text_grid_local'), 'text/plain');
    FileMimeTypeUtil.addFileMimeType('XML', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_XML,
      $r('app.media.hidisk_icon_xml'), $r('app.media.hidisk_icon_xml_grid'),
      $r('app.media.hidisk_icon_xml_grid_local'), 'text/plain');
    FileMimeTypeUtil.addFileMimeType('SUB', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MORE_TEXT,
      $r('app.media.hidisk_icon_file'), $r('app.media.hidisk_icon_file_grid'),
      $r('app.media.hidisk_icon_file_grid_local'), 'text/x-subviewer');
    FileMimeTypeUtil.addFileMimeType('ASS', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MORE_TEXT,
      $r('app.media.hidisk_icon_file'), $r('app.media.hidisk_icon_file_grid'),
      $r('app.media.hidisk_icon_file_grid_local'), 'text/x-ssa');
    FileMimeTypeUtil.addFileMimeType('SSA', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MORE_TEXT,
      $r('app.media.hidisk_icon_file'), $r('app.media.hidisk_icon_file_grid'),
      $r('app.media.hidisk_icon_file_grid_local'), 'text/x-ssa');
    FileMimeTypeUtil.addFileMimeType('DHTML', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_HTML,
      $r('app.media.hidisk_icon_html'), $r('app.media.hidisk_icon_html_grid'),
      $r('app.media.hidisk_icon_html_grid_local'), 'text/html');
    FileMimeTypeUtil.addFileMimeType('SHTML', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_HTML,
      $r('app.media.hidisk_icon_html'), $r('app.media.hidisk_icon_html_grid'),
      $r('app.media.hidisk_icon_html_grid_local'), 'text/html');
    FileMimeTypeUtil.addFileMimeType('TEXT', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_TEXT,
      $r('app.media.hidisk_icon_text'), $r('app.media.hidisk_icon_text_grid'),
      $r('app.media.hidisk_icon_text_grid_local'), 'text/plain');
    FileMimeTypeUtil.addFileMimeType('INI', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MORE_TEXT,
      $r('app.media.hidisk_icon_file'), $r('app.media.hidisk_icon_file_grid'),
      $r('app.media.hidisk_icon_file_grid_local'), 'text/plain');
    FileMimeTypeUtil.addFileMimeType('VCS', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MORE_TEXT,
      $r('app.media.hidisk_icon_file'), $r('app.media.hidisk_icon_file_grid'),
      $r('app.media.hidisk_icon_file_grid_local'), 'text/x-vcalendar');
    FileMimeTypeUtil.addFileMimeType('ICS', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MORE_TEXT,
      $r('app.media.hidisk_icon_file'), $r('app.media.hidisk_icon_file_grid'),
      $r('app.media.hidisk_icon_file_grid_local'), 'text/calendar');
    FileMimeTypeUtil.addFileMimeType('JSP', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MORE_TEXT,
      $r('app.media.hidisk_icon_file'), $r('app.media.hidisk_icon_file_grid'),
      $r('app.media.hidisk_icon_file_grid_local'), 'text/html');
    FileMimeTypeUtil.addFileMimeType('ASP', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MORE_TEXT,
      $r('app.media.hidisk_icon_file'), $r('app.media.hidisk_icon_file_grid'),
      $r('app.media.hidisk_icon_file_grid_local'), 'text/html');
    FileMimeTypeUtil.addFileMimeType('PHP', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MORE_TEXT,
      $r('app.media.hidisk_icon_file'), $r('app.media.hidisk_icon_file_grid'),
      $r('app.media.hidisk_icon_file_grid_local'), 'text/html');
    FileMimeTypeUtil.addFileMimeType('DOTX', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_WORD,
      $r('app.media.hidisk_icon_doc'), $r('app.media.hidisk_icon_doc_grid'),
      $r('app.media.hidisk_icon_doc_grid_local'),
      'application/vnd.openxmlformats-officedocument.wordprocessingml.template');
    FileMimeTypeUtil.addFileMimeType('DOT', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_WORD,
      $r('app.media.hidisk_icon_doc'), $r('app.media.hidisk_icon_doc_grid'),
      $r('app.media.hidisk_icon_doc_grid_local'), 'application/msword');
    FileMimeTypeUtil.addFileMimeType('XLT', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_EXCEL,
      $r('app.media.hidisk_icon_xls'), $r('app.media.hidisk_icon_xls_grid'),
      $r('app.media.hidisk_icon_xls_grid_local'), 'application/vnd.ms-excel');
    FileMimeTypeUtil.addFileMimeType('XLTX', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_EXCEL,
      $r('app.media.hidisk_icon_xls'), $r('app.media.hidisk_icon_xls_grid'),
      $r('app.media.hidisk_icon_xls_grid_local'),
      'application/vnd.openxmlformats-officedocument.spreadsheetml.template');
    FileMimeTypeUtil.addFileMimeType('CSV', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_EXCEL,
      $r('app.media.hidisk_icon_xls'), $r('app.media.hidisk_icon_xls_grid'),
      $r('app.media.hidisk_icon_xls_grid_local'), 'text/comma-separated-values');
    FileMimeTypeUtil.addFileMimeType('POT', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_POWERPOINT,
      $r('app.media.hidisk_icon_ppt'), $r('app.media.hidisk_icon_ppt_grid'),
      $r('app.media.hidisk_icon_ppt_grid_local'), 'application/vnd.ms-powerpoint');
    FileMimeTypeUtil.addFileMimeType('POTX', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_POWERPOINT,
      $r('app.media.hidisk_icon_ppt'), $r('app.media.hidisk_icon_ppt_grid'),
      $r('app.media.hidisk_icon_ppt_grid_local'),
      'application/vnd.openxmlformats-officedocument.presentationml.template');
    FileMimeTypeUtil.addFileMimeType('PPSX', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_MS_POWERPOINT,
      $r('app.media.hidisk_icon_ppt'), $r('app.media.hidisk_icon_ppt_grid'),
      $r('app.media.hidisk_icon_ppt_grid_local'),
      'application/vnd.openxmlformats-officedocument.presentationml.slideshow');
    FileMimeTypeUtil.addFileMimeType('VCF', MimeType.FILE_CATEGORY_TXT, FileMimeTypeUtil.FILE_TYPE_VCF,
      $r('app.media.hidisk_icon_vcard'), $r('app.media.hidisk_icon_vcard_grid'),
      $r('app.media.hidisk_icon_vcard_grid_local'), 'text/x-vcard');

    // 音频
    FileMimeTypeUtil.addFileMimeType('3GPP2', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_3GPP2,
      $r('app.media.hidisk_icon_video'), $r('app.media.hidisk_icon_video_grid'),
      $r('app.media.hidisk_icon_video_grid_local'), 'audio/3gpp2');
    FileMimeTypeUtil.addFileMimeType('IMY', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_IMY,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/imelody');
    FileMimeTypeUtil.addFileMimeType('AAC', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AAC,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/aac');
    FileMimeTypeUtil.addFileMimeType('AMR', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AMR,
      $r('app.media.hidisk_icon_music_amr'), $r('app.media.hidisk_icon_audio_amr_grid'),
      $r('app.media.hidisk_icon_audio_amr_grid_local'), 'audio/amr');
    FileMimeTypeUtil.addFileMimeType('MID', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_MID,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/midi');
    FileMimeTypeUtil.addFileMimeType('MPGA', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_MPGA,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/mpeg');
    FileMimeTypeUtil.addFileMimeType('MXMF', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_MXMF,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/mobile-xmf');
    FileMimeTypeUtil.addFileMimeType('RTTTL', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_MID,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/midi');
    FileMimeTypeUtil.addFileMimeType('RTX', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_MID,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/midi');
    FileMimeTypeUtil.addFileMimeType('SMF', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_SMF,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/sp-midi');
    FileMimeTypeUtil.addFileMimeType('WAV', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_WAV,
      $r('app.media.hidisk_icon_music_wav'), $r('app.media.hidisk_icon_audio_wav_grid'),
      $r('app.media.hidisk_icon_audio_wav_grid_local'), 'audio/x-wav');
    FileMimeTypeUtil.addFileMimeType('WMA', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_WMA,
      $r('app.media.hidisk_icon_music_wma'), $r('app.media.hidisk_icon_audio_wma_grid'),
      $r('app.media.hidisk_icon_audio_wma_grid_local'), 'audio/x-ms-wma');
    FileMimeTypeUtil.addFileMimeType('OTA', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_MID,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/midi');
    FileMimeTypeUtil.addFileMimeType('XMF', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_MID,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/midi');
    FileMimeTypeUtil.addFileMimeType('OGG', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_OGG,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/ogg');
    FileMimeTypeUtil.addFileMimeType('PLS', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_PLS,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/x-scpls');
    FileMimeTypeUtil.addFileMimeType('RA', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_RA,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/x-pn-realaudio');
    FileMimeTypeUtil.addFileMimeType('RAM', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_RAM,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/x-pn-realaudio');
    FileMimeTypeUtil.addFileMimeType('MIDI', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_MID,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/midi');
    FileMimeTypeUtil.addFileMimeType('M3U', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_M3U,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/x-mpegurl');
    FileMimeTypeUtil.addFileMimeType('M4A', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_M4A,
      $r('app.media.hidisk_icon_music_m4a'), $r('app.media.hidisk_icon_audio_m4a_grid'),
      $r('app.media.hidisk_icon_audio_m4a_grid_local'), 'audio/mp4a-latm');
    FileMimeTypeUtil.addFileMimeType('M4B', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_MP4A,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/mp4a-latm');
    FileMimeTypeUtil.addFileMimeType('M4P', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_MP4A,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/mp4a-latm');
    FileMimeTypeUtil.addFileMimeType('AWB', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AWB,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/amr-wb');
    FileMimeTypeUtil.addFileMimeType('MP2', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_MP2,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/x-mpeg');
    FileMimeTypeUtil.addFileMimeType('MP3', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_MP3,
      $r('app.media.hidisk_icon_music_mp3'), $r('app.media.hidisk_icon_audio_mp3_grid'),
      $r('app.media.hidisk_icon_audio_mp3_grid_local'), 'audio/x-mpeg');
    FileMimeTypeUtil.addFileMimeType('AU', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AU,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/basic');
    FileMimeTypeUtil.addFileMimeType('OGA', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_OGG,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'application/ogg');
    FileMimeTypeUtil.addFileMimeType('WPL', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_WPL,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'application/vnd.ms-wpl');
    FileMimeTypeUtil.addFileMimeType('AC3', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AC3,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/ac3');
    FileMimeTypeUtil.addFileMimeType('MKA', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_MKA,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/x-matroska');
    FileMimeTypeUtil.addFileMimeType('FLAC', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_FLAC,
      $r('app.media.hidisk_icon_music_flac'), $r('app.media.hidisk_icon_audio_flac_grid'),
      $r('app.media.hidisk_icon_audio_flac_grid_local'), 'audio/flac');
    FileMimeTypeUtil.addFileMimeType('AIF', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AIFF,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/x-aiff');
    FileMimeTypeUtil.addFileMimeType('AIFF', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AIFF,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/x-aiff');
    FileMimeTypeUtil.addFileMimeType('AIFC', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_AIFF,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/x-aiff');
    FileMimeTypeUtil.addFileMimeType('APE', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_APE,
      $r('app.media.hidisk_icon_music_ape'), $r('app.media.hidisk_icon_audio_ape_grid'),
      $r('app.media.hidisk_icon_audio_ape_grid_local'), 'audio/x-ape');
    FileMimeTypeUtil.addFileMimeType('RM', MimeType.FILE_CATEGORY_AUDIO, FileMimeTypeUtil.FILE_TYPE_RM_AUDIO,
      $r('app.media.hidisk_icon_music'), $r('app.media.hidisk_icon_audio_grid'),
      $r('app.media.hidisk_icon_audio_grid_local'), 'audio/x-pn-realaudio');

    // 压缩包
    FileMimeTypeUtil.addFileMimeType('GTAR', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_ZIP,
      $r('app.media.hidisk_icon_compressed_files'), $r('app.media.hidisk_icon_compress_grid'),
      $r('app.media.hidisk_icon_compress_grid_local'), 'application/x-gtar');
    FileMimeTypeUtil.addFileMimeType('RAR', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_RAR,
      $r('app.media.hidisk_icon_rar'), $r('app.media.hidisk_icon_rar_grid'),
      $r('app.media.hidisk_icon_rar_grid_local'), 'application/x-rar-compressed');
    FileMimeTypeUtil.addFileMimeType('TAR', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_TAR,
      $r('app.media.hidisk_icon_compressed_files'), $r('app.media.hidisk_icon_compress_grid'),
      $r('app.media.hidisk_icon_compress_grid_local'), 'application/x-tar');
    FileMimeTypeUtil.addFileMimeType('TGZ', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_TGZ,
      $r('app.media.hidisk_icon_compressed_files'), $r('app.media.hidisk_icon_compress_grid'),
      $r('app.media.hidisk_icon_compress_grid_local'), 'application/x-compressed');
    FileMimeTypeUtil.addFileMimeType('Z', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_Z,
      $r('app.media.hidisk_icon_compressed_files'), $r('app.media.hidisk_icon_compress_grid'),
      $r('app.media.hidisk_icon_compress_grid_local'), 'application/x-compressed');
    FileMimeTypeUtil.addFileMimeType('ZIP', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_ZIP,
      $r('app.media.hidisk_icon_zip'), $r('app.media.hidisk_icon_zip_grid'),
      $r('app.media.hidisk_icon_zip_grid_local'), 'application/zip');
    FileMimeTypeUtil.addFileMimeType('JAR', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_JAR,
      $r('app.media.hidisk_icon_compressed_files'), $r('app.media.hidisk_icon_compress_grid'),
      $r('app.media.hidisk_icon_compress_grid_local'), 'text/vnd.sun.j2me.app-descriptor');
    FileMimeTypeUtil.addFileMimeType('GZ', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_GZ,
      $r('app.media.hidisk_icon_compressed_files'), $r('app.media.hidisk_icon_compress_grid'),
      $r('app.media.hidisk_icon_compress_grid_local'), 'application/x-gzip');
    FileMimeTypeUtil.addFileMimeType('BZ', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_BZ,
      $r('app.media.hidisk_icon_compressed_files'), $r('app.media.hidisk_icon_compress_grid'),
      $r('app.media.hidisk_icon_compress_grid_local'), 'application/x-bzip');
    FileMimeTypeUtil.addFileMimeType('BZ2', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_BZ2,
      $r('app.media.hidisk_icon_compressed_files'), $r('app.media.hidisk_icon_compress_grid'),
      $r('app.media.hidisk_icon_compress_grid_local'), 'application/x-bzip2');
    FileMimeTypeUtil.addFileMimeType('7Z', MimeType.FILE_CATEGORY_ZIP, FileMimeTypeUtil.FILE_TYPE_7Z,
      $r('app.media.hidisk_icon_7z'), $r('app.media.hidisk_icon_7z_grid'),
      $r('app.media.hidisk_icon_7z_grid_local'), 'application/x-7z-compressed');

    // 安装包
    FileMimeTypeUtil.addFileMimeType('HAP', MimeType.FILE_CATEGORY_PKG, FileMimeTypeUtil.FILE_TYPE_HAP,
      $r('app.media.hidisk_icon_application'), $r('app.media.hidisk_icon_application_grid'),
      $r('app.media.hidisk_icon_application_grid_local'), 'file/*');

    // 未知
    FileMimeTypeUtil.addFileMimeType('EXE', MimeType.FILE_CATEGORY_UNKNOW, FileMimeTypeUtil.FILE_TYPE_UNKNOW,
      $r('app.media.hidisk_icon_unknown'), $r('app.media.hidisk_icon_unknown_grid'),
      $r('app.media.hidisk_icon_unknown_grid_local'), 'application/octet-stream');
    FileMimeTypeUtil.addFileMimeType('BIN', MimeType.FILE_CATEGORY_UNKNOW, FileMimeTypeUtil.FILE_TYPE_UNKNOW,
      $r('app.media.hidisk_icon_unknown'), $r('app.media.hidisk_icon_unknown_grid'),
      $r('app.media.hidisk_icon_unknown_grid_local'), 'application/octet-stream');
    FileMimeTypeUtil.addFileMimeType('CLASS', MimeType.FILE_CATEGORY_UNKNOW, FileMimeTypeUtil.FILE_TYPE_UNKNOW,
      $r('app.media.hidisk_icon_unknown'), $r('app.media.hidisk_icon_unknown_grid'),
      $r('app.media.hidisk_icon_unknown_grid_local'), 'application/octet-stream');
    FileMimeTypeUtil.addFileMimeType('RAW', MimeType.FILE_CATEGORY_UNKNOW, FileMimeTypeUtil.FILE_TYPE_UNKNOW,
      $r('app.media.hidisk_icon_unknown'), $r('app.media.hidisk_icon_unknown_grid'),
      $r('app.media.hidisk_icon_unknown_grid_local'), 'application/octet-stream');
    FileMimeTypeUtil.addFileMimeType('EPUB', MimeType.FILE_CATEGORY_UNKNOW, FileMimeTypeUtil.FILE_TYPE_UNKNOW,
      $r('app.media.hidisk_icon_unknown'), $r('app.media.hidisk_icon_unknown_grid'),
      $r('app.media.hidisk_icon_unknown_grid_local'), 'application/epub+zip');
    FileMimeTypeUtil.addFileMimeType('EBK3', MimeType.FILE_CATEGORY_UNKNOW, FileMimeTypeUtil.FILE_TYPE_UNKNOW,
      $r('app.media.hidisk_icon_unknown'), $r('app.media.hidisk_icon_unknown_grid'),
      $r('app.media.hidisk_icon_unknown_grid_local'), 'application/x-expandedbook');
    FileMimeTypeUtil.addFileMimeType('SAMI', MimeType.FILE_CATEGORY_UNKNOW, FileMimeTypeUtil.FILE_TYPE_UNKNOW,
      $r('app.media.hidisk_icon_unknown'), $r('app.media.hidisk_icon_unknown_grid'),
      $r('app.media.hidisk_icon_unknown_grid_local'), 'application/x-sami');
    FileMimeTypeUtil.addFileMimeType('SMI', MimeType.FILE_CATEGORY_UNKNOW, FileMimeTypeUtil.FILE_TYPE_UNKNOW,
      $r('app.media.hidisk_icon_unknown'), $r('app.media.hidisk_icon_unknown_grid'),
      $r('app.media.hidisk_icon_unknown_grid_local'), 'application/x-sami');
    FileMimeTypeUtil.addFileMimeType('STR', MimeType.FILE_CATEGORY_UNKNOW, FileMimeTypeUtil.FILE_TYPE_UNKNOW,
      $r('app.media.hidisk_icon_unknown'), $r('app.media.hidisk_icon_unknown_grid'),
      $r('app.media.hidisk_icon_unknown_grid_local'), 'application/x-subrip');
    FileMimeTypeUtil.addFileMimeType('SWF', MimeType.FILE_CATEGORY_UNKNOW, FileMimeTypeUtil.FILE_TYPE_UNKNOW,
      $r('app.media.hidisk_icon_unknown'), $r('app.media.hidisk_icon_unknown_grid'),
      $r('app.media.hidisk_icon_unknown_grid_local'), 'application/x-shockwave-flash');
    FileMimeTypeUtil.addFileMimeType('CAB', MimeType.FILE_CATEGORY_UNKNOW, FileMimeTypeUtil.FILE_TYPE_UNKNOW,
      $r('app.media.hidisk_icon_unknown'), $r('app.media.hidisk_icon_unknown_grid'),
      $r('app.media.hidisk_icon_unknown_grid_local'), 'application/x-shockwave-flash');
    FileMimeTypeUtil.addFileMimeType('CHM', MimeType.FILE_CATEGORY_UNKNOW, FileMimeTypeUtil.FILE_TYPE_UNKNOW,
      $r('app.media.hidisk_icon_chm'), $r('app.media.hidisk_icon_chm_grid'),
      $r('app.media.hidisk_icon_chm_grid_local'), 'application/x-chm');
    FileMimeTypeUtil.addFileMimeType('UMD', MimeType.FILE_CATEGORY_UNKNOW, FileMimeTypeUtil.FILE_TYPE_UNKNOW,
      $r('app.media.hidisk_icon_unknown'), $r('app.media.hidisk_icon_unknown_grid'),
      $r('app.media.hidisk_icon_unknown_grid_local'), 'application/umd');
    FileMimeTypeUtil.addFileMimeType('PDB', MimeType.FILE_CATEGORY_UNKNOW, FileMimeTypeUtil.FILE_TYPE_UNKNOW,
      $r('app.media.hidisk_icon_unknown'), $r('app.media.hidisk_icon_unknown_grid'),
      $r('app.media.hidisk_icon_unknown_grid_local'), 'application/ebook');
    FileMimeTypeUtil.addFileMimeType('DCF', MimeType.FILE_CATEGORY_UNKNOW, FileMimeTypeUtil.FILE_TYPE_UNKNOW,
      $r('app.media.hidisk_icon_unknown'), $r('app.media.hidisk_icon_unknown_grid'),
      $r('app.media.hidisk_icon_unknown_grid_local'), 'application/vnd.oma.drm.content');
    FileMimeTypeUtil.addFileMimeType('K3G', MimeType.FILE_CATEGORY_UNKNOW, FileMimeTypeUtil.FILE_TYPE_UNKNOW,
      $r('app.media.hidisk_icon_unknown'), $r('app.media.hidisk_icon_unknown_grid'),
      $r('app.media.hidisk_icon_unknown_grid_local'), 'application/octet-stream');
    FileMimeTypeUtil.addFileMimeType('MPO', MimeType.FILE_CATEGORY_UNKNOW, FileMimeTypeUtil.FILE_TYPE_UNKNOW,
      $r('app.media.hidisk_icon_unknown'), $r('app.media.hidisk_icon_unknown_grid'),
      $r('app.media.hidisk_icon_unknown_grid_local'), 'application/octet-stream');
    FileMimeTypeUtil.addFileMimeType('MMF', MimeType.FILE_CATEGORY_UNKNOW, FileMimeTypeUtil.FILE_TYPE_MMF,
      $r('app.media.hidisk_icon_unknown'), $r('app.media.hidisk_icon_unknown_grid'),
      $r('app.media.hidisk_icon_unknown_grid_local'), 'application/vnd.smaf');
    FileMimeTypeUtil.addFileMimeType('QCP', MimeType.FILE_CATEGORY_UNKNOW, FileMimeTypeUtil.FILE_TYPE_QCP,
      $r('app.media.hidisk_icon_unknown'), $r('app.media.hidisk_icon_unknown_grid'),
      $r('app.media.hidisk_icon_unknown_grid_local'), 'application/octet-stream');
  }

  private static getFileMiMeTypeMap(): Map<string, MimeType> {
    if (FileMimeTypeUtil.fileMimeTypeMap.size === 0) {
      FileMimeTypeUtil.setFileMimeTypeMap();
    }
    return FileMimeTypeUtil.fileMimeTypeMap;
  }

  public  static getFileMimeType(fileName: string): MimeType {
    if (StringUtil.isEmpty(fileName)) {
      return FileMimeTypeUtil.UNKNOW_MIMETYPE;
    }

    const splitList = fileName.split('.');
    if (splitList.length < 2) {
      return FileMimeTypeUtil.UNKNOW_MIMETYPE;
    }

    let suffix = splitList[splitList.length-1].toUpperCase();
    // 判断DLP加密文件
    if (suffix === FileMimeTypeUtil.SUFFIX_DLP) {
      if (splitList.length === 2) {
        return FileMimeTypeUtil.UNKNOW_MIMETYPE;
      }
      suffix = splitList[splitList.length-2].toUpperCase();
    }
    const fileMiMeTypeMap = FileMimeTypeUtil.getFileMiMeTypeMap();
    const mimeType: MimeType | undefined = fileMiMeTypeMap.get(suffix);
    if (!mimeType) {
      return FileMimeTypeUtil.UNKNOW_MIMETYPE;
    }
    return mimeType;
  }

  public  static getFileSuffix(fileName: string): String {
    const unKnown: string = '';
    if (StringUtil.isEmpty(fileName)) {
      return unKnown;
    }

    const splitList = fileName.split('.');
    if (splitList.length < 2) {
      return unKnown;
    }

    let suffix = splitList[splitList.length-1].toUpperCase();
    // 判断DLP加密文件
    if (suffix === FileMimeTypeUtil.SUFFIX_DLP) {
      if (splitList.length === 2) {
        return unKnown;
      }
      suffix = splitList[splitList.length-2].toUpperCase();
    }
    return suffix;
  }

  public static getFileTypeOrder(fileName: string): number {
    const mimeType = FileMimeTypeUtil.getFileMimeType(fileName);
    return mimeType.getFileTypeSort();
  }
}

export default FileMimeTypeUtil;


