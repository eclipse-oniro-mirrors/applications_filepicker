/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import { CommonUtil } from './CommonUtil';
import { FormatListItem } from '../const/BarItems';
import type { FileInfo } from '../fileoperate/FileInfo';
import { FsUtil } from './FsUtil';
import { VirtualUri } from '../const/FolderRecord';
import { MyComputerConstant } from '../const/MyComputerConstant';
import { FileUtil } from '../fileoperate/FileUtil';
import { Constant } from '../const/Constant';
import { StringUtil } from './StringUtil';
import { ObjectUtil } from './ObjectUtil';
import { HiLog } from '../dfx/HiLog';

const TAG = 'ThumbnailUtil';

/*
   * File Display Type
   */
export enum FileThumbnailType {
  'amr' = 'amr',
  'ape' = 'ape',
  'caj' = 'caj',
  'eddx' = 'eddx',
  'flac' = 'flac',
  'nh' = 'nh',
  'm4a' = 'm4a',
  'wav' = 'wav',

  'pdf' = 'pdf',
  '7z' = '7z',
  'teb' = 'teb',

  'app' = 'app',
  'zip' = 'zip',
  'kdh' = 'kdh',

  'calender' = 'calender',

  'chm' = 'chm',

  'rar' = 'rar',
  'wma' = 'wma',

  'text' = 'txt',
  'txt' = 'txt',
  'html' = 'html',
  'log' = 'log',
  'xml' = 'xml',

  'contacts' = 'contacts',

  'imy' = 'music',
  'aac' = 'music',
  'mid' = 'music',
  'mpga' = 'music',
  'mxmf' = 'music',
  'rtttl' = 'music',
  'rtx' = 'music',
  'smf' = 'music',
  'ota' = 'music',
  'xmf' = 'music',
  'ogg' = 'music',
  'pls' = 'music',
  'qcp' = 'music',
  'mmf' = 'music',
  'ra' = 'music',
  'ram' = 'music',
  'midi' = 'music',
  'm3u' = 'music',
  'm4b' = 'music',
  'm4p' = 'music',
  'awb' = 'music',
  'mp2' = 'music',
  'mp3' = 'mp3',
  'au' = 'music',
  'ac3' = 'music',
  'mka' = 'music',
  'aif' = 'music',
  'aiff' = 'music',
  'aifc' = 'music',
  'oga' = 'music',
  'wpl' = 'music',
  'mgg' = 'music',
  'mflac' = 'music',
  '3ga' = 'music',
  'a52' = 'music',
  'f4a' = 'music',
  'f4b' = 'music',
  'f4p' = 'music',
  'adts' = 'music',
  'adt' = 'music',
  'snd' = 'music',
  'mp1' = 'music',
  'mpa' = 'music',
  'm4r' = 'music',

  'gtar' = 'compressed',
  'tar' = 'tar',
  'tgz' = 'compressed',
  'z' = 'compressed',
  'jar' = 'compressed',
  'gz' = 'gz',
  'gzip' = 'gzip',
  'bz' = 'compressed',
  'bz2' = 'compressed',

  'arw' = 'image',
  'avif' = 'image',
  'bm' = 'image',
  'bmp' = 'image',
  'cr2' = 'image',
  'cur' = 'image',
  'dng' = 'image',
  'gif' = 'image',
  'heic' = 'image',
  'heif' = 'image',
  'heics' = 'image',
  'hif' = 'image',
  'ico' = 'image',
  'jpe' = 'image',
  'jpeg' = 'image',
  'jpg' = 'image',
  'mpo' = 'image',
  'nrw' = 'image',
  'pef' = 'image',
  'png' = 'image',
  'psd' = 'image',
  'raw' = 'image',
  'rw2' = 'image',
  'srw' = 'image',
  'svg' = 'image',
  'tif' = 'image',
  'webp' = 'image',
  'raf' = 'image',
  'wbmp' = 'image',
  'heifs' = 'image',
  'm4u' = 'video',
  'm4v' = 'video',
  'mov' = 'video',
  'mp4' = 'video',
  'mpe' = 'video',
  'mpeg' = 'video',
  'mpg4' = 'video',
  'mkv' = 'video',
  'webm' = 'video',
  '3gpp' = 'video',
  'asf' = 'video',
  'asx' = 'video',
  'avi' = 'video',
  'flv' = 'video',
  'm2ts' = 'video',
  '3g2' = 'video',
  'wmv' = 'video',
  '3gp' = 'video',
  'mpg' = 'video',
  'rv' = 'video',
  'ts' = 'video',
  'divx' = 'video',
  'f4v' = 'video',
  '3gpp2' = 'video',
  'rmvb' = 'video',
  'movie' = 'video',
  'rm' = 'video',
  'mp4v' = 'video',
  'mpeg4' = 'video',
  'vt' = 'video',
  '3gp2' = 'video',
  'mpeg2' = 'video',
  'mpv2' = 'video',
  'mp2v' = 'video',
  'm2v' = 'video',
  'm2t' = 'video',
  'wrf' = 'video',
  'mpeg1' = 'video',
  'mpv1' = 'video',
  'mp1v' = 'video',
  'm1v' = 'video',
  'h264' = 'video',

  'xlt' = 'xls',
  'xltx' = 'xls',
  'csv' = 'xls',
  'xlsm' = 'xls',
  'ods' = 'xls',
  'xls' = 'xls',
  'xlsx' = 'xlsx',
  'xltm' = 'xls',
  'et' = 'xls',

  'dot' = 'doc',
  'dotx' = 'doc',
  'lst' = 'doc',
  'ltx' = 'doc',
  'md' = 'doc',
  'mobi' = 'doc',
  'docx' = 'doc',
  'doc' = 'doc',
  'docm' = 'doc',
  'dotm' = 'doc',
  'odt' = 'doc',
  'ott' = 'doc',
  'tex' = 'doc',
  'wps' = 'doc',
  'rtf' = 'doc',
  'wpt' = 'doc',

  'pot' = 'ppt',
  'potx' = 'ppt',
  'ppsx' = 'ppt',
  'odp' = 'ppt',
  'pptm' = 'ppt',
  'pps' = 'ppt',
  'ppt' = 'ppt',
  'pptx' = 'pptx',
  'ppsm' = 'ppt',
  'potm' = 'ppt',
  'dps' = 'ppt',
  'dpt' = 'ppt',

  'epub' = 'unknown',
  'ebk3' = 'unknown',
  'sub' = 'txt',
  'ass' = 'txt',
  'ssa' = 'txt',
  'sami' = 'unknown',
  'smi' = 'unknown',
  'srt' = 'unknown',
  'swf' = 'unknown',
  'cab' = 'unknown',
  'umd' = 'unknown',
  'pdb' = 'unknown',
  'jad' = 'txt',
  'dhtml' = 'html',
  'shtml' = 'html',
  'vcf' = 'contacts',
  'dcf' = 'unknown',
  'k3g' = 'unknown',
  'ini' = 'txt',
  'vcs' = 'calender',
  'ics' = 'calender',
  'jsp' = 'txt',
  'asp' = 'txt',
  'php' = 'txt',
  'c' = 'txt',
  'conf' = 'txt',
  'cpp' = 'txt',
  'h' = 'txt',
  'htm' = 'htm',
  'java' = 'txt',
  'prop' = 'txt',
  'rc' = 'txt',
  'sh' = 'txt',
  'exe' = 'unknown',
  'apk' = 'unknown',
  'bin' = 'unknown',
  'class' = 'unknown',
  'mpc' = 'unknown',
  'js' = 'txt',
  'xhtml' = 'xml',
  'msg' = 'txt',
  'unknown' = 'unknown',
  'empty_folder' = 'empty_folder',
  'folder' = 'folder',
  'mts' = 'video',
  'tiff' = 'image',
  'hap' = 'app'
}

export class ThumbnailUtil {

  public static readonly THUMBNAIL_SUPPORT_TYPE: Set<string> =
    new Set(['image', 'video', 'default_image', 'default_video']);

  public static readonly UNKNOWN_TYPE: string = 'unknown';
  public static readonly VIDEO_TYPE: string = 'video';
  public static readonly PDF_TYPE: string = 'pdf';
  public static readonly IMAGE_TYPE: string = 'image';
  public static readonly LOCAL_CLOUD_IMAGE_TYPE: string = 'local_cloud_image';
  public static readonly FOLDER_TYPE: string = 'folder';

  public static readonly BIG_THUMBNAIL_VALUE = 1;
  public static isBigThumbnail: boolean | undefined = undefined;

  // 缩略图map
  public static readonly thumbnailMap: Map<string, Resource> = new Map([
    [FormatListItem.Z7, $r('app.media.ic_light_7z')],
    [FormatListItem.AMR, $r('app.media.ic_light_amr')],
    [FormatListItem.APE, $r('app.media.ic_light_ape')],
    [FormatListItem.FLAC, $r('app.media.ic_light_flac')],
    [FormatListItem.M4A, $r('app.media.ic_light_m4a')],
    [FormatListItem.MP3, $r('app.media.ic_light_mp3')],
    [FormatListItem.WAV, $r('app.media.ic_light_wav')],
    [FormatListItem.APP, $r('app.media.ic_light_app')],
    [FormatListItem.CALENDER, $r('app.media.ic_light_calendar')],
    [FormatListItem.CHM, $r('app.media.ic_light_chm')],
    [FormatListItem.RAR, $r('app.media.ic_light_rar')],
    [FormatListItem.CONTACTS, $r('app.media.ic_light_connect')],
    [FormatListItem.DOC, $r('app.media.ic_light_word')],
    [FormatListItem.DOCX, $r('app.media.ic_light_word')],
    [FormatListItem.TXT, $r('app.media.ic_light_text')],
    [FormatListItem.HTM, $r('app.media.ic_light_htm')],
    [FormatListItem.HTML, $r('app.media.ic_light_html')],
    [FormatListItem.PDF, $r('app.media.ic_light_pdf')],
    [FormatListItem.DEFAULT_PDF, $r('app.media.ic_light_pdf')],
    [FormatListItem.PPT, $r('app.media.ic_light_ppt')],
    [FormatListItem.PPTX, $r('app.media.ic_light_ppt')],
    [FormatListItem.XLS, $r('app.media.ic_light_excel')],
    [FormatListItem.XLSX, $r('app.media.ic_light_excel')],
    [FormatListItem.ZIP, $r('app.media.ic_light_zip')],
    [FormatListItem.GZ, $r('app.media.ic_light_gz')],
    [FormatListItem.GZIP, $r('app.media.ic_light_gz')],
    [FormatListItem.TAR, $r('app.media.ic_light_tar')],
    [FormatListItem.MP4, $r('app.media.ic_video_default')],
    [FormatListItem.DEFAULT_VIDEO, $r('app.media.ic_light_video')],
    [FormatListItem.LOG, $r('app.media.ic_light_log')],
    [FormatListItem.XML, $r('app.media.ic_light_xml')],
    [FormatListItem.WMA, $r('app.media.ic_light_wma')],
    [FormatListItem.CAJ, $r('app.media.ic_light_caj')],
    [FormatListItem.EDDX, $r('app.media.ic_light_eddx')],
    [FormatListItem.KDH, $r('app.media.ic_light_kdh')],
    [FormatListItem.NH, $r('app.media.ic_light_nh')],
    [FormatListItem.TEB, $r('app.media.ic_light_teb')],
    [FormatListItem.IMAGE, $r('app.media.ic_picture_default')],
    [FormatListItem.DEFAULT_IMAGE, $r('app.media.ic_light_picture')],
    [FormatListItem.UNKNOWN, $r('app.media.ic_light_unknow')],
    [FormatListItem.EMPTY_FOLDER, $r('app.media.ic_normal_folder_empty')],
    [FormatListItem.FOLDER, $r('app.media.ic_normal_folder')],
    [FormatListItem.EMPTY_DESKTOP, $r('app.media.ic_pc_desktop_empty')],
    [FormatListItem.DESKTOP, $r('app.media.ic_pc_desktop')],
    [FormatListItem.EMPTY_PICTURE, $r('app.media.ic_pc_picture_empty')],
    [FormatListItem.PICTURE, $r('app.media.ic_pc_picture')],
    [FormatListItem.EMPTY_DOCUMENTS, $r('app.media.ic_pc_document_empty')],
    [FormatListItem.DOCUMENTS, $r('app.media.ic_pc_document')],
    [FormatListItem.EMPTY_DOWNLOAD, $r('app.media.ic_pc_download_empty')],
    [FormatListItem.DOWNLOAD, $r('app.media.ic_pc_download')],
    [FormatListItem.EMPTY_APPDATA, $r('app.media.ic_pc_appdata_empty')],
    [FormatListItem.APPDATA, $r('app.media.ic_pc_appdata')],
    [FormatListItem.ALBUM_IMAGE_COVER, $r('app.media.ic_picture_default')],
    [FormatListItem.ALBUM_VIDEO_COVER, $r('app.media.ic_video_default')],
    [FormatListItem.PLACE_HOLDER, $r('app.media.ic_alt_image')],
    [FormatListItem.music, $r('app.media.ic_light_music')],
    [FormatListItem.COMPRESSED, $r('app.media.ic_light_zip_1')]
  ]);

  /**
   * 根据fileInfo,获取文件string类型，之后可以从thumbnailMap中查找对应资源
   * @param fileInfo
   * @returns 文件类型
   */
  public static getThumbnailType(fileInfo: FileInfo): string {
    if (fileInfo.isFolder) {
      let parentUri = FileUtil.getFileParentPathFromUri(fileInfo.uri);
      let fileThumbnailType: string = ThumbnailUtil.FOLDER_TYPE;
      if ((parentUri === VirtualUri.MY_PC) && MyComputerConstant.MY_COMPUTER_NAME_LIST.includes(fileInfo.fileName)) {
        fileThumbnailType = MyComputerConstant.MY_COMPUTER_FOLDER_TYPE.get(fileInfo.fileName)!!;
      }
      return fileThumbnailType;
    }

    let fileExtension = CommonUtil.getFileExtension(fileInfo.fileName);
    fileExtension = fileExtension.toLowerCase();
    let fileType: FileThumbnailType = FileThumbnailType[fileExtension];
    if (!fileType) {
      return ThumbnailUtil.UNKNOWN_TYPE;
    }
    return fileType;
  }

  /**
   * 根据thumbnailType获取文件默认图标Resource资源
   * @param thumbnailType 图标类型
   * @returns Resource类型资源
   */
  public static getDefaultIconByType(thumbnailType: string): Resource {
    // 图片视频获取默认图标，而非占位图图标
    if (thumbnailType === FormatListItem.IMAGE) {
      thumbnailType = FormatListItem.DEFAULT_IMAGE;
    } else if (thumbnailType === FormatListItem.MP4) {
      thumbnailType = FormatListItem.DEFAULT_VIDEO;
    }
    if (ThumbnailUtil.thumbnailMap.has(thumbnailType)) {
      return ThumbnailUtil.thumbnailMap.get(thumbnailType) as Resource;
    }
    return $r('app.media.ic_normal_unknown');
  }

  public static getThumbnailTypeBySuffix(suffix: string): string {
    if (!suffix) {
      return '';
    }
    suffix = suffix.replace('.', '');
    suffix = suffix.toLowerCase();
    const fileType: FileThumbnailType = FileThumbnailType[suffix];
    return fileType || ThumbnailUtil.UNKNOWN_TYPE;
  }

  public static getThumbnailUri(fileInfo: FileInfo): string {
    let uriSrc: string = '';
    if (ObjectUtil.isNullOrUndefined(fileInfo)) {
      HiLog.error(TAG, `getThumbnailUri fileInfo is null or undefined`);
      return uriSrc;
    }
    const uri: string = fileInfo.uri;
    // 判断是否为媒体库文件，若为媒体库文件，则使用媒体库文件LCD图片，否则使用MediaCachedImage
    if (uri.startsWith(Constant.MediaLibrary_URI_HEAD)) {
      HiLog.info(TAG, `getThumbnailUri media thumbnail uri`);
      uriSrc = uri +
        `?timestampApp=${fileInfo.timesStampApp}` +
        `&thumbnailModifiledMs=${fileInfo.thumbnailModifiledMs}` +
        `&oper=astc&width=-1&height=-1&path=${fileInfo.path}`;
    }
    return uriSrc;
  }

  public static getSmallThumbnailUri(fileInfo: FileInfo): string {
    return ThumbnailUtil.getFileIconCompThumbnailUri(fileInfo);
  }

  /*
   * 获取图片或视频图标缩略图
   * @param fileInfo 文件信息
   * @returns 缩略图uri
   */
  public static getFileIconCompThumbnailUri(fileInfo: FileInfo): string {
    let uriSrc: string = '';
    if (ObjectUtil.isNullOrUndefined(fileInfo)) {
      HiLog.error(TAG, `getFileIconCompThumbnailUri fileInfo is null or undefined`);
      return uriSrc;
    }
    const uri: string = fileInfo.coverUri || fileInfo.uri;
    if (uri.startsWith(Constant.MediaLibrary_URI_HEAD)) {
      HiLog.info(TAG, `getFileIconCompThumbnailUri media thumbnail uri`);
      uriSrc = uri +
        `?timestampApp=${fileInfo.timesStampApp}` +
        `&thumbnailModifiledMs=${fileInfo.thumbnailModifiledMs}` +
        `&oper=astc&width=0&height=0&path=${fileInfo.path}`;
    }
    return uriSrc;
  }
}