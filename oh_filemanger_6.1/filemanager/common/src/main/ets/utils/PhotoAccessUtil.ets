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

import { HiLog } from '../dfx/HiLog';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import type common from '@ohos.app.ability.common';
import { FileInfo } from '../fileoperate/FileInfo';
import { Constant, FileSourceType, SortOrder } from '../const/Constant';
import lazy { photoAccessHelper } from '../../../../indexLazyLoadTs';
import { PhotoAlbumSubType, PhotoAlbumType } from '../media/AlbumType';
import { VirtualUri } from '../const/FolderRecord';
import { ObjectUtil } from './ObjectUtil';
import FileMimeTypeUtil from './FileMimeTypeUtil';
import { MimeType } from '../model/MimeType';
import { FileUtil } from '../fileoperate/FileUtil';
import lazy { userFileManager } from '../../../../indexLazyLoad';
import { AuditLogUtils } from './AuditLogUtils';
import { maskString, StringUtil } from './StringUtil';
import { TimeUtil } from './TimeUtil';
import { ResourceUtil } from './ResourceUtil';
import { QueryFileParam } from '../taskpool/queryparam/QueryFileParam';
import { JSON, taskpool } from '@kit.ArkTS';
import { TaskStatus } from '../taskpool/const/TaskConst';
import { FormatListItem } from '../const/BarItems';
import { FavoriteDbManager } from '../favorite/FavoriteDbManager';
import { AppInfo } from '../gallery/AppInfo';
import { ResultErrorParams, SaveFilesResult } from '../gallery/SaveFilesResult';
import lazy { PhotoFileSourceType, PhotoUtil } from '../gallery/PhotoUtil';
import { PhotoCondition } from '../taskpool/queryparam/PhotoCondition';
import { FilesQueryUtil } from '../fileoperate/FilesQueryUtil';
import { FileAccessError } from '../error/Error';
import { ERROR_CODE } from '../const/ErrorCode';
import { Context } from '@kit.AbilityKit';
import { MyPhoneConstant } from '../const/MyPhoneConstant';
import { AppConfig } from '../config/AppConfig';
import { GlobalKey } from '../global/GlobalKey';
import { GlobalHolder } from '../global/GlobalHolder';
import { PAGE_ROUTE_CONST } from '../const/PageRouteConst';
import { FsUtil } from './FsUtil';
import fs from '@ohos.file.fs';

/* instrument ignore file */

const TAG = 'PhotoAccessUtil';

interface AlbumType {
  type: number;
  subtype: number;
}

interface AlbumInfo {
  cnt: number;
  coverUri: string;
  coverTime: number;
}

type PhotoAlbum = photoAccessHelper.Album;

type PhotoAsset = photoAccessHelper.PhotoAsset;

const ALBUM_MAP = new Map<string, AlbumType[]>([
  [VirtualUri.GALLERY, [
    { type: PhotoAlbumType.SOURCE, subtype: PhotoAlbumSubType.SOURCE_GENERIC },
    { type: PhotoAlbumType.USER, subtype: PhotoAlbumSubType.USER_GENERIC }]],
  [VirtualUri.IMAGE, [
    { type: PhotoAlbumType.SOURCE, subtype: PhotoAlbumSubType.SOURCE_GENERIC },
    { type: PhotoAlbumType.USER, subtype: PhotoAlbumSubType.USER_GENERIC }]],
  [VirtualUri.VIDEO, [
    { type: PhotoAlbumType.SOURCE, subtype: PhotoAlbumSubType.SOURCE_GENERIC },
    { type: PhotoAlbumType.USER, subtype: PhotoAlbumSubType.USER_GENERIC }]]
]);

const SYS_ALBUM_MAP = new Map<string, AlbumType[]>([
  [VirtualUri.IMAGE, [
    { type: PhotoAlbumType.SYSTEM, subtype: PhotoAlbumSubType.IMAGE }]],
  [VirtualUri.VIDEO, [
    { type: PhotoAlbumType.SYSTEM, subtype: PhotoAlbumSubType.VIDEO }]]
]);

const PHOTO_URI_MAP: Map<photoAccessHelper.AlbumSubtype, Resource> = new Map([
  [photoAccessHelper.AlbumSubtype.IMAGE, $r('app.string.all_images')],
  [photoAccessHelper.AlbumSubtype.VIDEO, $r('app.string.all_videos')]]);

const MEDIA_TYPE_MAP: Map<string, number> = new Map([
  [VirtualUri.IMAGE, photoAccessHelper.PhotoType.IMAGE],
  [VirtualUri.VIDEO, photoAccessHelper.PhotoType.VIDEO],
  [VirtualUri.GALLERY, -1]]);

const TIME_RECENT: number = 30; // 展示30天内的数据
const TIME_ONE_SECOND: number = 1000; // 1s = 1000ms
const MIN_PIC_SIZE: number = 30000; // 最小的图片大小
const FILE_COPY_LIMIT: number = 100;
const FILE_BATCH_DEL_LIMIT: number = 200;

const SORT_ORDER_MAP: Map<string, string> = new Map<string, string>([
  [SortOrder.SIZE, photoAccessHelper.PhotoKeys.SIZE],
  [SortOrder.NAME, photoAccessHelper.PhotoKeys.DISPLAY_NAME],
  [SortOrder.TYPE, 'media_suffix'],
  [SortOrder.TIME, photoAccessHelper.PhotoKeys.DATE_MODIFIED],
]);

export class PhotoAccessUtil {
  private static imageSupportFormats: Set<string> = new Set<string>();
  private static videoSupportFormats: Set<string> = new Set<string>();
  private static phAccessHelper: photoAccessHelper.PhotoAccessHelper | undefined;

  public static readonly PHOTO_LPATH_MAP: Map<string, Resource> = new Map([
    [Constant.PHOTO_ALBUM_LPATH.LPATH_CAMERA, $r('app.string.source_camera')],
    [Constant.PHOTO_ALBUM_LPATH.LPATH_SCREEN_SHOT, $r('app.string.source_screenshot')],
    [Constant.PHOTO_ALBUM_LPATH.LPATH_SCREEN_RECORDING, $r('app.string.source_screen_recording')]
  ]);

  // 用于保存图库所有相册
  private static albumList: photoAccessHelper.Album[] = [];

  public static async getPhotoInSourceAlbum(context: common.Context, bundleName: string, orderBy?: string,
    isOrderDesc?: boolean): Promise<FileInfo[]> {
    HiLog.info(TAG, 'getPhotoInSourceAlbum begin.');
    let fileList: FileInfo[] = [];
    if (!context) {
      HiLog.error(TAG, 'getPhotoInSourceAlbum error. context null');
      return fileList;
    }
    // 通过bundlename查询所在相册的照片
    const albumType = PhotoAlbumType.SOURCE;
    const albumSubType = PhotoAlbumSubType.SOURCE_GENERIC;
    fileList =
      await PhotoAccessUtil.getPhotoByBundleName(context, bundleName, 0, albumType, albumSubType, orderBy,
        isOrderDesc);

    HiLog.info(TAG, `getPhotoInSourceAlbum end. len:${fileList.length}`);
    return fileList;
  }

  public static async getPhotoByUri(context: common.Context, dirUri: string, mediaSearchType: number, albumType: number,
    albumSubType: number, orderBy?: string, isOrderDesc?: boolean,
    photoCondition?: PhotoCondition, filterSize: number = 0): Promise<FileInfo[]> {
    HiLog.info(TAG, 'getPhotoByUri');
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    predicates.equalTo('uri', dirUri);

    return await PhotoAccessUtil.getPhoto(context, predicates, mediaSearchType, albumType, albumSubType, orderBy,
      isOrderDesc, photoCondition, filterSize);
  }

  /**
   * 子线程增量获取媒体库图片文件
   */
  public static async getPhotoIncremental(data: QueryFileParam) {
    if (!data || !data.context || data.albumType === undefined || data.albumSubType === undefined) {
      HiLog.error(TAG, 'invalid args');
      return;
    }

    let mediaFileArray: FileInfo[] = [];
    let accessHelper: photoAccessHelper.PhotoAccessHelper | undefined = undefined;
    let fetchResult: photoAccessHelper.FetchResult<PhotoAlbum> | undefined = undefined;
    try {
      accessHelper = photoAccessHelper.getPhotoAccessHelper(data.context);
      if (!accessHelper) {
        HiLog.error(TAG, 'getPhoto can not get phAccessHelper')
        taskpool.Task.sendData([], TaskStatus.END, data.queryId);
        return;
      }
      let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      predicates.equalTo('uri', data.dirUri);
      let fetchOptions: photoAccessHelper.FetchOptions = {
        fetchColumns: [],
        predicates: predicates
      };
      fetchResult = await accessHelper.getAlbums(data.albumType, data.albumSubType, fetchOptions);
      let photoAlbum: Array<PhotoAlbum> = await fetchResult.getAllObjects();

      let albumMap = new Map<number, PhotoAlbum>();
      if (data.albumType === PhotoAlbumType.SYSTEM) {
        albumMap = await PhotoAccessUtil.getAlbumInfoByAllAlbums(data.context);
      }
      HiLog.warn(TAG, `getPhoto get album:${photoAlbum.length}`)
      let suffixSet: Set<string> =
        new Set<string>(data.suffixList.map((suffix: string) => suffix.toLowerCase()));
      for (let album of photoAlbum) {
        let hasMoreData = true;
        const PAGE_SIZE = 2000; // 每页数据条数
        let offset = 0;
        while (hasMoreData) {
          const filterSizeMin = 0;
          let photoAssetArray: PhotoAsset[] = await PhotoAccessUtil.getPhotoAsset(album, 0,
            PhotoUtil.FETCH_COLUMNS, data.orderBy, data.isDesc, filterSizeMin, offset,
            PAGE_SIZE) as PhotoAsset[];
          for (let photoAsset of photoAssetArray) {
            // 文件后缀过滤
            if (suffixSet.size > 0) {
              let fileSuffix: string = FileMimeTypeUtil.getFileSuffix(photoAsset.displayName).toLowerCase();
              // 如果黑名单中有后缀，或者白名单无该后缀，则去除该文件
              if (suffixSet.has(fileSuffix) === data.isBlackSuffix) {
                continue;
              }
            }
            let fileInfo = PhotoAccessUtil.fromPhotoAsset(photoAsset);
            if (data.albumType === PhotoAlbumType.SYSTEM) {
              PhotoAccessUtil.addAlbumInfoToPhoto(fileInfo, albumMap.get(fileInfo.ownerAlbumId));
            } else {
              PhotoAccessUtil.addAlbumInfoToPhoto(fileInfo, album);
            }
            mediaFileArray.push(fileInfo);
          }
          // 判断是否还有下一页（是否继续循环）
          hasMoreData = photoAssetArray.length === PAGE_SIZE;
          offset += PAGE_SIZE;
          taskpool.Task.sendData(mediaFileArray, TaskStatus.RUNNING, data.queryId);
          mediaFileArray = [];
        }
      }
    } catch (error) {
      HiLog.error(TAG, 'list GALLERY error: ' + JSON.stringify(error));
    } finally {
      fetchResult?.close();
      accessHelper?.release();
    }
    HiLog.info(TAG, `getPhoto end`);
    taskpool.Task.sendData([], TaskStatus.END, data.queryId);
  }

  /**
   * 获取媒体库支持图片、视频类型
   * return 返回true，表示媒体库正常，返回false，表示媒体库异常
   */
  public static async initPhotoSupportedFormats(context: common.Context): Promise<boolean> {
    if (PhotoAccessUtil.imageSupportFormats.size !== 0 && PhotoAccessUtil.videoSupportFormats.size !== 0) {
      return true;
    }
    let accessHelper: photoAccessHelper.PhotoAccessHelper | undefined = PhotoAccessUtil.getAccessHelper(context);
    if (!accessHelper) {
      HiLog.error(TAG, 'PhotoAccessHelper is null.')
      return false;
    }
    let initSuccess: boolean = true;
    try {
      let imageFormat = await PhotoUtil.getSupportedPhotoFormats(accessHelper, photoAccessHelper.PhotoType.IMAGE);
      PhotoAccessUtil.imageSupportFormats = new Set(imageFormat);
      let videoFormat = await PhotoUtil.getSupportedPhotoFormats(accessHelper, photoAccessHelper.PhotoType.VIDEO);
      PhotoAccessUtil.videoSupportFormats = new Set(videoFormat);
      HiLog.info(TAG, `imageFormat: ${JSON.stringify(imageFormat)} video: ${JSON.stringify(videoFormat)}`);
    } catch (err) {
      initSuccess = false; // 获取失败，表示不支持
      HiLog.error(TAG, 'getSupportedPhotoFormats fail.')
    }
    return initSuccess;
  }

  /**
   * 获取是否是媒体库支持类型
   * return 第一个表示是否为支持图片类型，第二个返回值表示是否为支持视频类型
   */
  public static async getPhotoSupportedFormats(context: common.Context, fileName: string): Promise<boolean[]> {
    if (PhotoAccessUtil.imageSupportFormats.size == 0 || PhotoAccessUtil.videoSupportFormats.size === 0) {
      await PhotoAccessUtil.initPhotoSupportedFormats(context);
    }
    let supportFormats: boolean[] = [false, false];
    const fileSuffix: string = fileName.slice(fileName.lastIndexOf('.') + 1).toLowerCase();
    supportFormats[0] = PhotoAccessUtil.imageSupportFormats.has(fileSuffix);
    supportFormats[1] = PhotoAccessUtil.videoSupportFormats.has(fileSuffix);
    HiLog.info(TAG, `file suffix ${fileSuffix}`);
    return supportFormats;
  }

  /**
   * @param 获取所有相册，然后通过uri，查找对应相册资产
   */
  public static async getAlbumByUri(context: common.Context, folderUri: string):
    Promise<photoAccessHelper.Album | undefined> {
    if (PhotoAccessUtil.albumList.length === 0) {
      PhotoAccessUtil.albumList = await PhotoAccessUtil.getAllAlbums(context, VirtualUri.GALLERY);
    }
    return PhotoAccessUtil.albumList.find(item => item.albumUri === folderUri);
  }

  /**
   * @param 获取所有相册，然后通过Name，查找对应相册资产
   */
  public static async getAlbumByName(context: common.Context, folderName: string):
    Promise<photoAccessHelper.Album | undefined> {
    if (PhotoAccessUtil.albumList.length === 0) {
      PhotoAccessUtil.albumList = await PhotoAccessUtil.getAllAlbums(context, VirtualUri.GALLERY);
    }
    return PhotoAccessUtil.albumList.find(item => item.albumName === folderName &&
      item.albumType === photoAccessHelper.AlbumType.USER);
  }

  /**
   * 通过媒体库move接口，批量将文件move到另一个相册
   * 成功返回true
   */
  public static async movePhotoAssetsToAlbum(context: common.Context, photoAssetsList: PhotoAsset[],
    srcAlbum: photoAccessHelper.Album, destAlbum: photoAccessHelper.Album): Promise<boolean> {
    HiLog.info(TAG, `movePhotoAssetsToAlbum start, length is ${photoAssetsList.length}`);
    let phAccessHelper: photoAccessHelper.PhotoAccessHelper | undefined = PhotoAccessUtil.getAccessHelper(context);
    if (!phAccessHelper) {
      HiLog.error(TAG, 'can not get phAccessHelper.');
      return false;
    }
    if (photoAssetsList.length === 0) {
      HiLog.warn(TAG, 'photoAssetsList length is null.')
      return true;
    }
    // 移动时源相册和目的相册相同，不做处理
    if (srcAlbum.albumUri === destAlbum.albumUri) {
      HiLog.warn(TAG, 'The source album is the same as the destination album.')
      return true;
    }

    try {
      let albumChangeRequest: photoAccessHelper.MediaAlbumChangeRequest =
        new photoAccessHelper.MediaAlbumChangeRequest(srcAlbum);
      if (albumChangeRequest) {
        albumChangeRequest.moveAssets(photoAssetsList, destAlbum);
        await phAccessHelper.applyChanges(albumChangeRequest);
      }
    } catch (e) {
      HiLog.error(TAG, `move file error, ${JSON.stringify(e)}.`);
      return false;
    }
    HiLog.info(TAG, 'movePhotoAssetsToAlbum end.');
    return true;
  }

  /**
   * 通过album获取指定相册类型中的图片的大小
   */
  public static async getAlbumSize(ctx: common.Context, fileInfo: FileInfo): Promise<number> {
    let totalSize: number = 0;
    HiLog.info(TAG, `getAlbumSize start with album type:${fileInfo.albumType}_${fileInfo.albumSubType}`);
    let accessHelper: photoAccessHelper.PhotoAccessHelper | undefined = undefined;
    let fetchResult: photoAccessHelper.FetchResult<PhotoAlbum> | undefined = undefined;
    try {
      accessHelper = photoAccessHelper.getPhotoAccessHelper(ctx);
      if (!accessHelper) {
        HiLog.error(TAG, 'getAlbumSize can not get phAccessHelper')
        return totalSize;
      }
      let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      predicates.equalTo('uri', fileInfo.uri);
      let fetchOptions: photoAccessHelper.FetchOptions = {
        fetchColumns: [],
        predicates: predicates
      };
      const albumType = fileInfo.albumType as number;
      const albumSubType = fileInfo.albumSubType as number;
      fetchResult = await accessHelper.getAlbums(albumType, albumSubType, fetchOptions);
      let photoAlbum: Array<PhotoAlbum> = await fetchResult.getAllObjects();
      let album = photoAlbum[0];
      let photoAssetArray: PhotoAsset[] = await PhotoAccessUtil.getPhotoAsset(album, -1, PhotoUtil.FETCH_COPY_COLUMNS);
      for (let photoAsset of photoAssetArray) {
        totalSize += photoAsset.get(photoAccessHelper.PhotoKeys.SIZE) as number;
      }
    } catch (error) {
      HiLog.error(TAG, 'getAlbumSize: ' + JSON.stringify(error));
    } finally {
      fetchResult?.close();
      accessHelper?.release();
    }
    return totalSize;
  }

  /**
   * 通过album获取指定相册类型中的图片列表
   */
  public static async getPhotoAssetNum(album: PhotoAlbum, media_type: number,
    filterSize: number = 0): Promise<AlbumInfo> {
    let info: AlbumInfo = { cnt: 0, coverUri: '', coverTime: 0 };
    HiLog.info(TAG, 'getPhotoAssetNum albumSubtype : ' + album.albumSubtype + ', media_type = ' + media_type);
    let predicates = new dataSharePredicates.DataSharePredicates();
    if (media_type !== -1) {
      predicates.equalTo('media_type', media_type).and();
    }
    // 不获取云图
    predicates.notEqualTo('position', 2);

    predicates.orderByDesc(photoAccessHelper.PhotoKeys.DATE_MODIFIED);
    predicates.orderByDesc(photoAccessHelper.PhotoKeys.DISPLAY_NAME);
    predicates.greaterThanOrEqualTo(photoAccessHelper.PhotoKeys.SIZE, filterSize);
    let fetchOption: photoAccessHelper.FetchOptions = {
      fetchColumns: PhotoUtil.FETCH_COLUMNS,
      predicates: predicates
    };
    let fetchResult: photoAccessHelper.FetchResult<PhotoAsset> | undefined = undefined;
    try {
      fetchResult = await album.getAssets(fetchOption);
      info.cnt = fetchResult.getCount();
      if (info.cnt !== 0 && media_type !== -1) {
        let photoAsset = await fetchResult.getFirstObject();
        info.coverUri = photoAsset.uri;
        info.coverTime = photoAsset.get(photoAccessHelper.PhotoKeys.DATE_MODIFIED) as number;
        info.coverTime = info.coverTime * Constant.TIME.ONE_SECOND;
      }
      HiLog.infoPrivate(TAG, `getPhotoAsset success, len: ${info.cnt}, coverUri = `, info.coverUri);
    } catch (err) {
      HiLog.warn(TAG, 'getPhotoAssetNum failed with error: ' + JSON.stringify(err));
    } finally {
      fetchResult?.close();
    }
    return info;
  }

  /**
   * 获取系统相册
   * @param data
   * @param dirUri
   * @param filePickerViewFlag
   * @returns
   */
  public static async getSysAlbums(data: QueryFileParam, dirUri: string,
    filePickerViewFlag: boolean): Promise<FileInfo[]> {
    HiLog.warn(TAG, 'getSysAlbums start');
    let fileList: FileInfo[] = [];
    let fetchTypes: AlbumType[] | undefined = SYS_ALBUM_MAP.get(dirUri);
    if (!fetchTypes) {
      HiLog.error(TAG, 'getSysAlbums invalid dirUri');
      return fileList;
    }

    let accessHelper: photoAccessHelper.PhotoAccessHelper | undefined = undefined;
    try {
      accessHelper = photoAccessHelper.getPhotoAccessHelper(data.context);
      if (!accessHelper) {
        HiLog.error(TAG, 'getSysAlbums can not get phAccessHelper')
        return fileList;
      }
    } catch (err) {
      HiLog.error(TAG, 'getSysAlbums getPhotoAccessHelper failed with error: ' + JSON.stringify(err));
      return fileList;
    }

    let fetchType = fetchTypes[0]
    let fetchResult: photoAccessHelper.FetchResult<PhotoAlbum> | undefined = undefined;
    try {
      HiLog.info(TAG, `getSysAlbums fetch album type:${fetchType.type} subtype:${fetchType.subtype}`);
      let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      //聚合视图中图库的聚合没有就是没有
      predicates.notEqualTo('count', 0);

      let fetchOptions: photoAccessHelper.FetchOptions = {
        fetchColumns: [],
        predicates: predicates
      };

      fetchResult = await accessHelper.getAlbums(fetchType.type, fetchType.subtype, fetchOptions);
      HiLog.info(TAG, `getSysAlbums getPhotoAsset count` + fetchResult.getCount());
      let photoAlbumList: Array<PhotoAlbum> = await fetchResult.getAllObjects();
      if (photoAlbumList.length < 1) {
        HiLog.info(TAG, `getSysAlbums getPhotoAsset count zero`);
        return fileList
      }
      const photoAlbum = photoAlbumList[0];
      if ((dirUri === VirtualUri.IMAGE && photoAlbum.imageCount === 0) ||
        (dirUri === VirtualUri.VIDEO && photoAlbum.videoCount === 0)) {
        HiLog.info(TAG, `getSysAlbums getPhotoAsset return due to file count is zero`);
        return fileList
      }
      let type = MEDIA_TYPE_MAP.get(dirUri) as number;
      if (!type) {
        HiLog.info(TAG, `getSysAlbums getPhotoAsset type undefined`);
        return fileList
      }
      const filterSizeMin = 0;
      const info = await PhotoAccessUtil.getPhotoAssetNum(photoAlbum, type, filterSizeMin);
      if (info.cnt === 0) {
        HiLog.info(TAG, `getSysAlbums getPhotoAssetNum 0`);
        return fileList
      }

      let fileInfo: FileInfo = new FileInfo();
      let tempName: string = fetchType.type === PhotoAlbumType.SYSTEM ?
      ResourceUtil.getStringByResource(PHOTO_URI_MAP.get(photoAlbum.albumSubtype), data.context) :
      photoAlbum.albumName;
      fileInfo.fileName = PhotoAccessUtil.getSysResourceAlbumName(photoAlbum, tempName, data.context);
      fileInfo.uri = '';
      FileInfo.getThumbnailType(fileInfo);
      fileInfo.coverUri = info.coverUri;
      fileInfo.mtime = info.coverTime;
      fileInfo.subFileCount = info.cnt;
      fileInfo.isFolder = true;
      fileInfo.parentPathForDetail = VirtualUri.GALLERY;
      fileInfo.isMultiEnable = filePickerViewFlag;
      fileList.push(fileInfo);
    } catch (err) {
      HiLog.error(TAG, 'getSysAlbums failed with error: ' + JSON.stringify(err));
    } finally {
      fetchResult?.close();
    }

    accessHelper?.release();
    HiLog.warn(TAG, 'getSysAlbums end：' + fileList.length);
    return fileList;
  }

  public static async getPhotoAlbums(data: QueryFileParam, dirUri: string, filePickerViewFlag: boolean,
    photosLock: boolean = false): Promise<void> {
    HiLog.info(TAG, 'getPhotoAlbums start');
    let fetchTypes: AlbumType[] | undefined = ALBUM_MAP.get(dirUri);
    if (!fetchTypes) {
      HiLog.error(TAG, 'getPhotoAlbums invalid dirUri');
      return;
    }
    let accessHelper: photoAccessHelper.PhotoAccessHelper | undefined = undefined;
    try {
      accessHelper = photoAccessHelper.getPhotoAccessHelper(data.context);
      if (!accessHelper) {
        HiLog.error(TAG, 'getPhotoAlbums can not get phAccessHelper')
        return;
      }
    } catch (err) {
      HiLog.error(TAG, 'getPhotoAlbums getPhotoAccessHelper failed with error: ' + JSON.stringify(err));
      return;
    }
    const virtualGalleryFolder = PhotoAccessUtil.getVirtualGalleryFolder(filePickerViewFlag, data.context);
    for (let fetchType of fetchTypes) {
      let fetchResult: photoAccessHelper.FetchResult<PhotoAlbum> | undefined = undefined;
      try {
        HiLog.info(TAG, `fetch album type:${fetchType.type} subtype:${fetchType.subtype}`);
        let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
        const isUsrAlbum: boolean = dirUri === VirtualUri.GALLERY && fetchType.type === photoAccessHelper.AlbumType.USER;
        // 用户相册，在图库路径下，空相册要同样显示
        if (!isUsrAlbum) {
          predicates.notEqualTo('count', 0);
        }
        let fetchOptions: photoAccessHelper.FetchOptions = {
          fetchColumns: [],
          predicates: predicates
        };

        fetchResult = await accessHelper.getAlbums(fetchType.type, fetchType.subtype, fetchOptions);
        let photoAlbumList: Array<PhotoAlbum> = await fetchResult.getAllObjects();
        for (let photoAlbum of photoAlbumList) {
          if (taskpool.Task.isCanceled()) {
            HiLog.warn(TAG, 'getPhotoAlbums task cancel');
            taskpool.Task.sendData([], TaskStatus.CANCEL, data.queryId);
            return;
          }
          let fileList: FileInfo[] = [];
          if ((dirUri === VirtualUri.IMAGE && photoAlbum.imageCount === 0) ||
            (dirUri === VirtualUri.VIDEO && photoAlbum.videoCount === 0)) {
            continue;
          }
          let type = MEDIA_TYPE_MAP.get(dirUri) as number;
          if (type === undefined) {
            HiLog.info(TAG, `getPhotoAsset type undefined`);
            type = -1;
          }
          const filterSizeMin = 0;
          const info = await PhotoAccessUtil.getPhotoAssetNum(photoAlbum, type, filterSizeMin);
          // 图库路径且是用户相册不过滤数量，来源数量为空的不显示
          if (info.cnt === 0 && !(dirUri === VirtualUri.GALLERY && fetchType.type === PhotoAlbumType.USER)) {
            continue;
          }

          if (photosLock) {
            virtualGalleryFolder.subFileCount++;
            continue;
          }
          let fileInfo: FileInfo = new FileInfo();
          let tempName: string = fetchType.type === PhotoAlbumType.SYSTEM ?
          ResourceUtil.getStringByResource(PHOTO_URI_MAP.get(photoAlbum.albumSubtype), data.context) :
          photoAlbum.albumName;
          fileInfo.fileName = PhotoAccessUtil.getSysResourceAlbumName(photoAlbum, tempName, data.context);
          fileInfo.uri = photoAlbum.albumUri;
          FileInfo.getThumbnailType(fileInfo);
          fileInfo.subFileCount = info.cnt;
          fileInfo.isFolder = true;
          fileInfo.parentPathForDetail = VirtualUri.GALLERY;
          fileInfo.albumType = photoAlbum.albumType;
          fileInfo.albumSubType = photoAlbum.albumSubtype;
          fileInfo.isMultiEnable = filePickerViewFlag ||
            !PhotoAccessUtil.isSystemAlbum(photoAlbum.albumType, photoAlbum.albumSubtype);
          fileList.push(fileInfo);
          taskpool.Task.sendData(fileList, TaskStatus.RUNNING, data.queryId);
        }
      } catch (err) {
        HiLog.error(TAG, 'getPhotoAlbums failed with error: ' + JSON.stringify(err));
      } finally {
        fetchResult?.close();
      }
    }
    if (photosLock && virtualGalleryFolder.subFileCount > 0) {
      taskpool.Task.sendData([virtualGalleryFolder], TaskStatus.RUNNING, data.queryId);
    }
    accessHelper?.release();
    HiLog.info(TAG, 'getPhotoAlbums end');
  }

  public static async getPhotoAlbumsForPath(context: Context, dirUri: string): Promise<Array<PhotoAlbum>> {
    HiLog.info(TAG, 'getPhotoAlbums start');
    let fetchTypes: AlbumType[] | undefined = ALBUM_MAP.get(dirUri);
    let photoAlbumList: Array<PhotoAlbum> = [];
    if (!fetchTypes) {
      HiLog.error(TAG, 'getPhotoAlbums invalid dirUri');
      return photoAlbumList;
    }
    let accessHelper: photoAccessHelper.PhotoAccessHelper | undefined = undefined;
    try {
      accessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      if (!accessHelper) {
        HiLog.error(TAG, 'getPhotoAlbums can not get phAccessHelper')
        return photoAlbumList;
      }
    } catch (err) {
      HiLog.error(TAG, 'getPhotoAlbums getPhotoAccessHelper failed with error: ' + JSON.stringify(err));
      return photoAlbumList;
    }
    for (let fetchType of fetchTypes) {
      let fetchResult: photoAccessHelper.FetchResult<PhotoAlbum> | undefined = undefined;
      try {
        HiLog.info(TAG, `fetch album type:${fetchType.type} subtype:${fetchType.subtype}`);
        let predicates: dataSharePredicates.DataSharePredicates =
          new dataSharePredicates.DataSharePredicates();
        if (fetchType.type === PhotoAlbumType.SOURCE) {
          HiLog.info(TAG, 'getPhotoAlbumsForPath for source');
          predicates.notEqualTo('count', 0);
        }
        let fetchOptions: photoAccessHelper.FetchOptions = {
          fetchColumns: [],
          predicates: predicates
        };

        fetchResult = await accessHelper.getAlbums(fetchType.type, fetchType.subtype, fetchOptions);
        let albums = await fetchResult.getAllObjects();
        for (let photoAlbum of albums) {
          if ((dirUri === VirtualUri.IMAGE && photoAlbum.imageCount === 0) ||
            (dirUri === VirtualUri.VIDEO && photoAlbum.videoCount === 0)) {
            continue;
          }
          let type = MEDIA_TYPE_MAP.get(dirUri) as number;
          if (type === undefined) {
            HiLog.info(TAG, `getPhotoAsset type undefined`);
            type = -1;
          }

          // pathPicker获取相册
          const info = await PhotoAccessUtil.getPhotoAssetNum(photoAlbum, type);
          //用户创建的相册即使里面没有文件也展示
          if (info.cnt === 0 && fetchType.type === PhotoAlbumType.SOURCE) {
            continue;
          }
          photoAlbumList.push(photoAlbum);
        }
      } catch (err) {
        HiLog.error(TAG, 'getPhotoAlbums failed with error: ' + JSON.stringify(err));
      } finally {
        fetchResult?.close();
      }
    }
    accessHelper?.release();
    HiLog.info(TAG, 'getPhotoAlbums end');
    return photoAlbumList;
  }

  public static async getAlbumUriByBundleName(context: Context, bundleName: string): Promise<string | undefined> {
    let accessHelper: photoAccessHelper.PhotoAccessHelper | undefined = undefined;
    try {
      accessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      if (!accessHelper) {
        HiLog.error(TAG, 'isScreenShotAlbum can not get phAccessHelper')
        return undefined;
      }
    } catch (err) {
      HiLog.error(TAG, 'isScreenShotAlbum getPhotoAccessHelper failed with error: ' + JSON.stringify(err));
      return undefined;
    }
    let fetchResult: photoAccessHelper.FetchResult<PhotoAlbum> | undefined = undefined;
    try {
      let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      predicates.equalTo('bundle_name', bundleName)
      let fetchOptions: photoAccessHelper.FetchOptions = {
        fetchColumns: [],
        predicates: predicates
      };
      let albumType: number = PhotoAlbumType.SOURCE;
      fetchResult =
        await accessHelper.getAlbums(albumType, photoAccessHelper.AlbumSubtype.SOURCE_GENERIC, fetchOptions);
      let album: PhotoAlbum = await fetchResult?.getFirstObject();
      return album?.albumUri;
    } catch (err) {
      HiLog.error(TAG, 'isScreenShotAlbum failed with error: ' + JSON.stringify(err));
    } finally {
      fetchResult?.close();
    }
    return undefined;
  }

  // 获取所有来源及用户相册，包含0文件的相册
  public static async getAllAlbums(context: common.Context, queryAlbumType: string): Promise<PhotoAlbum[]> {
    HiLog.info(TAG, 'getPhotoAlbum start');
    let albumList: PhotoAlbum[] = [];
    let fetchTypes: AlbumType[] | undefined = ALBUM_MAP.get(queryAlbumType);
    if (!fetchTypes) {
      HiLog.error(TAG, 'invalid dirUri');
      return albumList;
    }
    let accessHelper: photoAccessHelper.PhotoAccessHelper | undefined = PhotoAccessUtil.getAccessHelper(context);
    if (!accessHelper) {
      HiLog.error(TAG, 'can not get phAccessHelper');
      return albumList;
    }
    for (let fetchType of fetchTypes) {
      let fetchResult: photoAccessHelper.FetchResult<PhotoAlbum> | undefined = undefined;
      try {
        HiLog.info(TAG, `fetch album type:${fetchType.type} subtype:${fetchType.subtype}`);
        let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
        let fetchOptions: photoAccessHelper.FetchOptions = {
          fetchColumns: [],
          predicates: predicates
        };

        fetchResult = await accessHelper.getAlbums(fetchType.type, fetchType.subtype, fetchOptions);
        albumList = albumList.concat(await fetchResult.getAllObjects());
      } catch (err) {
        HiLog.error(TAG, 'getPhotoAlbums failed with error: ' + JSON.stringify(err));
      } finally {
        fetchResult?.close();
      }
    }
    HiLog.info(TAG, `getPhotoAlbums end, album length: ${albumList.length}`);
    return albumList;
  }

  public static async createAlbum(context: common.Context,
    albumName: string): Promise<photoAccessHelper.Album | undefined> {
    HiLog.info(TAG, 'create album start.');
    let changeRequestAlbum: photoAccessHelper.Album | undefined;
    try {
      let phAccessHelper: photoAccessHelper.PhotoAccessHelper | undefined = PhotoAccessUtil.getAccessHelper(context);
      if (!phAccessHelper) {
        HiLog.error(TAG, 'can not get phAccessHelper')
        return changeRequestAlbum;
      }
      let albumChangeRequest: photoAccessHelper.MediaAlbumChangeRequest =
        photoAccessHelper.MediaAlbumChangeRequest.createAlbumRequest(context, albumName);
      await phAccessHelper.applyChanges(albumChangeRequest);
      changeRequestAlbum = albumChangeRequest.getAlbum();
      if (changeRequestAlbum) { // 文件创建成功，将创建的相册更近到相册list
        PhotoAccessUtil.albumList.push(changeRequestAlbum);
      }
      HiLog.info(TAG, 'apply createAlbumRequest successfully.');
    } catch (err) {
      HiLog.error(TAG, `createAlbumRequestDemo failed with error: ${JSON.stringify(err)}`);
    }
    return changeRequestAlbum;
  }

  public static async createFileToAlbum(context: common.Context, fileName: string,
    albumUri: string): Promise<string[]> {
    HiLog.info(TAG, 'create file to album.');
    let srcPrefixAndSuffix: string[] = ['', ''];
    srcPrefixAndSuffix = FileUtil.getPreFixAndSuffixByUri(fileName);
    if (srcPrefixAndSuffix[1] === '') {
      HiLog.error(TAG, 'No suffix file.');
      return [];
    }
    let fileType: photoAccessHelper.PhotoType =
      PhotoAccessUtil.videoSupportFormats.has(srcPrefixAndSuffix[1].toLowerCase()) ?
      photoAccessHelper.PhotoType.VIDEO : photoAccessHelper.PhotoType.IMAGE;

    let phAccessHelper: photoAccessHelper.PhotoAccessHelper | undefined = PhotoAccessUtil.getAccessHelper(context);
    if (!phAccessHelper) {
      HiLog.error(TAG, 'can not get phAccessHelper')
      return [];
    }
    let photoCreationConfigs: Array<photoAccessHelper.PhotoCreationConfig> = [
      {
        title: srcPrefixAndSuffix[0],
        fileNameExtension: srcPrefixAndSuffix[1],
        photoType: fileType
      }
    ];
    return await PhotoUtil.createAssetsForAppWithAlbum(phAccessHelper, false, albumUri, photoCreationConfigs);
  }

  // 只处理来源下获取图库文件
  public static async getGalleryFiles(data: QueryFileParam): Promise<void> {
    HiLog.info(TAG, `getGalleryFiles start`);
    let result: FileInfo[] = [];
    let fetchResult: photoAccessHelper.FetchResult<PhotoAsset> | undefined = undefined;
    let helper: photoAccessHelper.PhotoAccessHelper | undefined = undefined;
    const rootName = ResourceUtil.getStringByResource($r('app.string.pc_gallery'), data.context);
    const rootNameMyPhone: string = ResourceUtil.getStringByResource($r('app.string.myPhone'), data.context);
    try {
      helper = photoAccessHelper.getPhotoAccessHelper(data.context);
      let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      predicates.notEqualTo('position', 2);
      // 来源图库文件排序只按文件修改时间降序排序
      predicates.orderByDesc(photoAccessHelper.PhotoKeys.DATE_MODIFIED);

      let fetchColumns = [...PhotoUtil.FETCH_COLUMNS];
      fetchColumns.push(PhotoUtil.FILE_SOURCE_TYPE);
      fetchColumns.push(PhotoUtil.STORAGE_PATH);

      let fetchOption: photoAccessHelper.FetchOptions = {
        fetchColumns: fetchColumns,
        predicates: predicates
      };
      fetchResult = await helper.getAssets(fetchOption);
      if (fetchResult.getCount() === 0) {
        taskpool.Task.sendData([], TaskStatus.END, data.queryId);
        HiLog.info(TAG, 'getGalleryFiles end');
        return;
      }

      let albumMap = await PhotoAccessUtil.getAlbumInfoByAllAlbums(data.context);

      // 此处会有相关性能问题建议使用分批，避免卡顿
      let photoAssets: Array<PhotoAsset> = await fetchResult.getAllObjects();
      HiLog.info(TAG, `getGalleryFiles photoAssets length ${photoAssets.length}`);
      for (let photoAssetItem of photoAssets) {
        let file: FileInfo = PhotoAccessUtil.fromPhotoAsset(photoAssetItem);
        PhotoAccessUtil.addAlbumInfoToPhoto(file, albumMap.get(file.ownerAlbumId));
        file.rootName = rootName;
        file.sourceType = FileSourceType.GALLERY_APP;
        result.push(file);
      }
    } catch (err) {
      HiLog.error(TAG, `getGalleryFiles failed. error: ${err.code}, ${err.message}`);
    } finally {
      fetchResult?.close();
    }
    const maxCount = 10000;
    if (result.length > 0) {
      FilesQueryUtil.batchSendDataTask(result, data, 'getGalleryFiles cancel', maxCount);
    } else {
      taskpool.Task.sendData([], TaskStatus.END, data.queryId);
    }
    HiLog.info(TAG, 'getGalleryFiles end');
  }

  public static getSysResourceParentAlbumName(lPath: string) {
    return PhotoAccessUtil.PHOTO_LPATH_MAP.has(lPath ?? '') ?
    ResourceUtil.getStringByResource(PhotoAccessUtil.PHOTO_LPATH_MAP.get(lPath ?? '')) : lPath;
  }

  /*
   * 通过uri获取文件资产，从all中进行查询
   * */
  public static async getPhotoAssetByUri(context: common.Context,
    uri: string, fetchColumns: string[] = PhotoUtil.FETCH_COPY_COLUMNS): Promise<PhotoAsset | undefined> {
    let photoAsset: photoAccessHelper.PhotoAsset | undefined = undefined;
    let phAccessHelper = PhotoAccessUtil.getAccessHelper(context);
    if (!phAccessHelper) {
      HiLog.warn(TAG, 'getPhotoAssetByUri, phAccessHelper is null.');
      return photoAsset;
    }
    let fetchResult: photoAccessHelper.FetchResult<PhotoAsset> | undefined = undefined;
    try {
      let predicates = new dataSharePredicates.DataSharePredicates();
      predicates.equalTo(photoAccessHelper.PhotoKeys.URI, uri);

      let fetchOptions: photoAccessHelper.FetchOptions = {
        fetchColumns: fetchColumns,
        predicates: predicates
      };
      fetchResult = await phAccessHelper.getAssets(fetchOptions);
      photoAsset = await fetchResult.getFirstObject();
    } catch (error) {
      HiLog.error(TAG, 'getPhotoAssetByUri, getAssets error: ' + JSON.stringify(error));
    } finally {
      fetchResult?.close();
    }
    return photoAsset;
  }

  /*
   * 通过uri获取文件资产，从all中进行查询，然后将资产装换成fileInfo，粘贴取最小集，只要size、uri和name
   * */
  public static async getPhotoAssetInfoByUri(context: common.Context, uri: string): Promise<FileInfo | undefined> {
    let assetInfo: FileInfo | undefined;
    let phAccessHelper = PhotoAccessUtil.getAccessHelper(context);
    if (!phAccessHelper) {
      HiLog.warn(TAG, 'getPhotoAssetInfoByUri, phAccessHelper is null.');
      return assetInfo;
    }
    let asset: PhotoAsset | undefined = await PhotoAccessUtil.getPhotoAssetByUri(context, uri);
    if (!asset) {
      HiLog.warn(TAG, 'getPhotoAssetInfoByUri, asset is null.');
      return assetInfo;
    }
    try {
      assetInfo = new FileInfo();
      if (!assetInfo) {
        return assetInfo;
      }
      assetInfo.isFolder = false;
      assetInfo.uri = uri;
      assetInfo.isGallery = true;
      assetInfo.fileName = asset.displayName;
      assetInfo.size = asset.get(photoAccessHelper.PhotoKeys.SIZE) as number;
    } catch (e) {
      HiLog.error(TAG, `get asset info fail, ${JSON.stringify(e)}`);
    }
    return assetInfo;
  }

  /**
   * 通过album获取指定相册类型中的图片列表
   */
  public static async getPhotoAsset(album: PhotoAlbum, media_type: number, fetchColumns: string[],
    orderBy?: string, isOrderDesc?: boolean, filterSize: number = 0, offset?: number,
    total?: number, isSource?: boolean): Promise<PhotoAsset[]> {
    HiLog.info(TAG, 'getPhotoAsset albumSubtype : ' + album.albumSubtype + ', media_type = ' + media_type);
    let predicates = new dataSharePredicates.DataSharePredicates();
    // 不获取云图
    predicates.notEqualTo('position', 2);
    predicates.greaterThanOrEqualTo(photoAccessHelper.PhotoKeys.SIZE, filterSize);
    if (total && total > 0) {
      predicates.limit(total, offset);
    }

    // 如果需要，按规则排序，默认以时间升序排序
    if (orderBy) {
      let orderType: string = SORT_ORDER_MAP.get(orderBy) ?? photoAccessHelper.PhotoKeys.DATE_MODIFIED;
      if (isOrderDesc) {
        predicates.orderByDesc(orderType);
      } else {
        predicates.orderByAsc(orderType);
      }
    }

    let fetchColumnsWithHoDataMsg = [...fetchColumns];

    let fetchOption: photoAccessHelper.FetchOptions = {
      fetchColumns: fetchColumnsWithHoDataMsg,
      predicates: predicates
    };
    let fetchResult: photoAccessHelper.FetchResult<PhotoAsset> | undefined = undefined;
    let photoAssetList: PhotoAsset[] = [];
    try {
      fetchResult = await album.getAssets(fetchOption);
      photoAssetList = await fetchResult.getAllObjects();
      HiLog.info(TAG, 'getPhotoAsset success, len: ' + photoAssetList.length);
    } catch (err) {
      photoAssetList = [];
      HiLog.error(TAG, 'getPhotoAsset failed with error: ' + JSON.stringify(err));
    } finally {
      fetchResult?.close();
    }
    return photoAssetList;
  }

  // 获取图库文件相关属性信息
  public static async getFileInfoByFileInfoList(fileInfoList: FileInfo[],
    context: common.Context): Promise<FileInfo[]> {
    if (ObjectUtil.isNullOrUndefined(fileInfoList) || ObjectUtil.isNullOrUndefined(context) ||
      fileInfoList.length === 0) {
      HiLog.error(TAG, 'getFileInfoByFileInfoList failed fileInfoList or context is undefined or null');
      return [];
    }
    let result: FileInfo[] = [];
    const fileIdArr: Array<number> = [];
    fileInfoList.forEach((fileInfo) => {
      const uri: string = fileInfo.uri;
      if (!uri.startsWith(VirtualUri.GALLERY_PHOTO_URI)) {
        HiLog.errorPrivate(TAG, `getFileInfoByFileInfoList uri error`, `uri: ${uri}`);
        result;
      }
      const uriIdStrArr: string[] = uri.replace(VirtualUri.GALLERY_PHOTO_URI, '').split('/');
      if (!uriIdStrArr || uriIdStrArr.length === 0) {
        HiLog.infoPrivate(TAG, `!uriIdStrArr || uriIdStrArr.length === 0.`, ` uri: ${uri}`);
        return;
      }
      fileIdArr.push(Number(uriIdStrArr[0]));
    })
    return result;
  }

  // 获取图库文件相关属性信息
  public static async getFileInfoByUriList(uriList: string[], context: common.Context,
    isCalcSize = false): Promise<FileInfo[]> {
    if (ObjectUtil.isNullOrUndefined(context)) {
      HiLog.error(TAG, 'getFileInfoByUriList failed context is undefined ');
      return [];
    }

    let albumMap = new Map<number, photoAccessHelper.Album>();
    if (!isCalcSize) {
      albumMap = await PhotoAccessUtil.getAlbumInfoByAllAlbums(context);
    }
    let result: FileInfo[] = [];
    let fetchResult: photoAccessHelper.FetchResult<PhotoAsset> | undefined = undefined;
    let helper: photoAccessHelper.PhotoAccessHelper | undefined = undefined;
    try {
      helper = photoAccessHelper.getPhotoAccessHelper(context);
      let rootName = ResourceUtil.getStringByResource($r('app.string.pc_gallery'));
      for (let i = 0; i < uriList.length; i++) {
        let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
        predicates.equalTo('uri', uriList[i]).and().notEqualTo('position', 2);
        let fetchOption: photoAccessHelper.FetchOptions = {
          fetchColumns: PhotoUtil.FETCH_COLUMNS,
          predicates: predicates
        };
        fetchResult = await helper.getAssets(fetchOption);
        if (fetchResult.getCount() === 0) {
          continue;
        }
        let photoAsset: PhotoAsset = await fetchResult.getFirstObject();
        let file = PhotoAccessUtil.fromPhotoAsset(photoAsset);
        if (!isCalcSize) {
          PhotoAccessUtil.addAlbumInfoToPhoto(file, albumMap.get(file.ownerAlbumId));
        }
        file.rootName = rootName;
        file.sourceType = FileSourceType.GALLERY_APP;
        result.push(file);
      }
    } catch (err) {
      HiLog.error(TAG, `getFileInfoByUri failed. error: ${err.code}, ${err.message}`);
    } finally {
      fetchResult?.close();
    }
    helper?.release();
    HiLog.info(TAG, `get gallery fileInfo end, result length ${result.length}`);
    return result;
  }

  /**
   * 通过album删除指定相册
   */
  public static async deleteAlbum(context: common.Context, album: photoAccessHelper.Album): Promise<void> {
    HiLog.warn(TAG, 'delete Album start.');
    try {
      await photoAccessHelper.MediaAlbumChangeRequest.deleteAlbums(context, [album]);
    } catch (err) {
      HiLog.error(TAG, 'delete album fail.' + JSON.stringify(err));
    }
  }

  // 通过uri判断当前图库文件是否存在
  public static async getFileIsExist(uri: string, context: common.Context, isTrashFile: boolean): Promise<boolean> {
    if (ObjectUtil.isNullOrUndefined(context)) {
      HiLog.error(TAG, 'deleteAssets failed context is undefined ');
      return false;
    }
    let helper: photoAccessHelper.PhotoAccessHelper | undefined = undefined;
    let fetchResult: photoAccessHelper.FetchResult<PhotoAsset> | undefined = undefined;
    try {
      helper = photoAccessHelper.getPhotoAccessHelper(context);
      let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      predicates.equalTo('uri', uri)
      let fetchOption: photoAccessHelper.FetchOptions = {
        fetchColumns: [photoAccessHelper.PhotoKeys.TITLE],
        predicates: predicates
      };
      if (isTrashFile) {
        let trashAlbum: photoAccessHelper.FetchResult<photoAccessHelper.Album> =
          await helper.getAlbums(userFileManager.AlbumType.SYSTEM, photoAccessHelper.AlbumSubtype.TRASH);
        let trashAsset: photoAccessHelper.Album = await trashAlbum.getFirstObject();
        fetchResult = await trashAsset.getAssets(fetchOption);
      } else {
        fetchResult = await helper.getAssets(fetchOption);
      }
      if (ObjectUtil.isNullOrUndefined(fetchResult)) {
        HiLog.warn(TAG, `getFileIsExist fetchResult is null`);
        return false;
      }
      if (fetchResult.getCount() === 0) {
        return false;
      }
    } catch (err) {
      HiLog.error(TAG, `getFileIsExist failed. error: ${err.code}, ${err.message}`);
      return false;
    } finally {
      fetchResult?.close();
      helper?.release();
    }
    return true;
  }

  public static async renameAssets(context: Context, oldUri: string, newName: string): Promise<string> {
    if (ObjectUtil.isNullOrUndefined(context)) {
      HiLog.error(TAG, 'renameAssets failed context is undefined ');
      return '';
    }
    let index: number = newName.lastIndexOf('.');
    if (index === -1) {
      HiLog.error(TAG, 'renameAssets failed index is -1');
      return '';
    }
    // 图库文件仅支持改名前缀，不能直接带后缀修改文件名
    const prefix: string = newName.slice(0, index);
    const suffix: string = newName.slice(index);
    HiLog.infoPrivate(TAG, 'renameAssets prefix = ', `${prefix}, suffix : ${suffix}`);
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    predicates.equalTo(photoAccessHelper.PhotoKeys.URI, oldUri);
    let fetchOption: photoAccessHelper.FetchOptions = {
      fetchColumns: [photoAccessHelper.PhotoKeys.TITLE],
      predicates: predicates
    };
    let newUri: string = ''
    let fetchResult: photoAccessHelper.FetchResult<PhotoAsset> | undefined = undefined;
    let helper: photoAccessHelper.PhotoAccessHelper | undefined = undefined;
    try {
      helper = photoAccessHelper.getPhotoAccessHelper(context);
      fetchResult = await helper.getAssets(fetchOption);
      HiLog.info(TAG, 'renameAssets fetchResult count = ' + fetchResult.getCount());
      let photoAsset: PhotoAsset = await fetchResult.getFirstObject();
      let fileName: photoAccessHelper.MemberType = photoAsset.get(photoAccessHelper.PhotoKeys.TITLE);
      HiLog.infoPrivate(TAG, 'renameAssets old fileName = ', fileName as string);
      photoAsset.set(photoAccessHelper.PhotoKeys.TITLE, prefix);
      await photoAsset.commitModify();
      index = oldUri.lastIndexOf('/');
      if (index !== -1) {
        let firstName = photoAsset.uri.slice(0, index + 1);
        newUri = firstName + FileUtil.encodeURIForFileManager(newName);
      }
      HiLog.infoPrivate(TAG, `renameAssets new`, `uri = ${newUri}`);
      return newUri;
    } catch (err) {
      HiLog.error(TAG, `renameAssets failed. error: ${err.code}, ${err.message}`);
      throw err as Error;
    } finally {
      fetchResult?.close();
      helper?.release();
    }
  }

  /**
   * 获取回收站相册图片总数
   *
   * @param context context
   * @returns 回收站相册列表
   */
  public static async getTrashAlbumPictureSum(context: Context): Promise<number> {
    if (ObjectUtil.isNullOrUndefined(context)) {
      HiLog.error(TAG, 'getTrashAlbumPictureSum failed context is undefined');
      return 0;
    }

    let fetchResult: userFileManager.FetchResult<userFileManager.FileAsset> | undefined = undefined;
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    // 不获取云图
    predicates.notEqualTo('position', 2);
    let fetchOption: userFileManager.FetchOptions = {
      fetchColumns: PhotoUtil.FETCH_COLUMNS,
      predicates: predicates
    };
    let recentDeleteSum: number = 0;
    try {
      let mgr = userFileManager.getUserFileMgr(context);
      let trashResult = await mgr.getAlbums(userFileManager.AlbumType.SYSTEM, userFileManager.AlbumSubType.TRASH);
      const count = trashResult.getCount();
      HiLog.info(TAG, `getTrashAlbumPictureSum Albums count : ${count}`);
      const trashAsset = await trashResult.getFirstObject();
      fetchResult = await trashAsset.getPhotoAssets(fetchOption);
      recentDeleteSum = fetchResult.getCount();
      HiLog.info(TAG, `getTrashAlbumPictureSum recentDeleteSum count : ${recentDeleteSum}`);
      return recentDeleteSum;
    } catch (err) {
      HiLog.error(TAG, `getTrashAlbumPictureSum failed. error: ${err.code}, ${err.message}`);
      return 0;
    } finally {
      fetchResult?.close();
    }
  }

  /**
   * 分批获取回收站相册
   *
   * @param context context
   * @param total 获取图片数量
   * @param start 开始位置
   * @returns
   */
  public static async getTrashAlbumsBatch(context: Context, total: number, start: number): Promise<FileInfo[]> {
    if (ObjectUtil.isNullOrUndefined(context)) {
      HiLog.error(TAG, 'getTrashAlbumsBatch failed context is undefined');
      return [];
    }

    let fetchResult: userFileManager.FetchResult<userFileManager.FileAsset> | undefined = undefined;
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    // 不获取云图
    predicates.notEqualTo('position', 2);
    // 分批获取图片
    predicates.limit(total, start);
    let fetchOption: userFileManager.FetchOptions = {
      fetchColumns: PhotoUtil.FETCH_COLUMNS,
      predicates: predicates
    };

    try {
      let mgr = userFileManager.getUserFileMgr(context);
      let trashResult = await mgr.getAlbums(userFileManager.AlbumType.SYSTEM, userFileManager.AlbumSubType.TRASH);
      const count = trashResult.getCount();
      HiLog.info(TAG, `getTrashAlbumsBatch Albums count : ${count}`);
      let trashAsset = await trashResult.getFirstObject();
      fetchResult = await trashAsset.getPhotoAssets(fetchOption);
      let fileAssetList: userFileManager.FileAsset[] = await fetchResult.getAllObject();
      HiLog.info(TAG, `getTrashAlbumsBatch fileAssetList length: ${fileAssetList.length}`);
      let fileInfoList: FileInfo[] = [];
      let rootName = ResourceUtil.getStringByResource($r('app.string.pc_gallery'), context);
      for (const fileAsset of fileAssetList) {
        let fileInfo = PhotoAccessUtil.fromFileAsset(fileAsset);
        fileInfo.sourceType = FileSourceType.GALLERY_APP;
        fileInfo.rootName = rootName;
        fileInfoList.push(fileInfo);
      }
      HiLog.info(TAG, `getTrashAlbumsBatch fileInfoList length: ${fileInfoList.length}`);
      return fileInfoList;
    } catch (err) {
      HiLog.error(TAG, `getTrashAlbumsBatch failed. error: ${err.code}, ${err.message}`);
      return [];
    } finally {
      fetchResult?.close();
    }
  }

  /**
   * 获取回收站相册
   *
   * @param context context
   * @returns 回收站相册列表
   */
  public static async getTrashAlbums(context: Context): Promise<FileInfo[]> {
    if (ObjectUtil.isNullOrUndefined(context)) {
      HiLog.error(TAG, 'deleteAssets failed context is undefined ');
      return [];
    }

    let fetchResult: userFileManager.FetchResult<userFileManager.FileAsset> | undefined = undefined;
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    // 不获取云图
    predicates.notEqualTo('position', 2);
    let fetchOption: userFileManager.FetchOptions = {
      fetchColumns: PhotoUtil.FETCH_COLUMNS,
      predicates: predicates
    };

    try {
      let mgr = userFileManager.getUserFileMgr(context);
      let trashResult = await mgr.getAlbums(userFileManager.AlbumType.SYSTEM, userFileManager.AlbumSubType.TRASH);
      let count = trashResult.getCount();
      HiLog.info(TAG, 'getTrashAlbums Albums count : ' + count);
      let trashAsset = await trashResult.getFirstObject();
      fetchResult = await trashAsset.getPhotoAssets(fetchOption);
      let fileAssetList: userFileManager.FileAsset[] = await fetchResult.getAllObject();
      HiLog.info(TAG, 'getTrashAlbums fileAssetList length:', fileAssetList.length);
      let fileInfoList: FileInfo[] = [];
      let rootName = ResourceUtil.getStringByResource($r('app.string.pc_gallery'), context);
      for (const fileAsset of fileAssetList) {
        let fileInfo = PhotoAccessUtil.fromFileAsset(fileAsset);
        fileInfo.sourceType = FileSourceType.GALLERY_APP;
        fileInfo.rootName = rootName;
        fileInfoList.push(fileInfo);
      }
      return fileInfoList;
    } catch (err) {
      HiLog.error(TAG, `getTrashAlbums failed. error: ${err.code}, ${err.message}`);
      return [];
    } finally {
      fetchResult?.close();
    }
  }

  /**
   * 批量删除媒体库图片
   *
   * @param uris 批量图片的uri
   */
  public static async deleteAssetsList(context: Context, uris: string[]): Promise<void> {
    HiLog.warn(TAG, 'deleteAssetsList start uri size ' + uris.length);
    if (ObjectUtil.isNullOrUndefined(context)) {
      HiLog.error(TAG, 'deleteAssetsList failed context is undefined ');
      return;
    }
    try {
      await photoAccessHelper.MediaAssetChangeRequest.deleteAssets(context, uris);
      HiLog.warn(TAG, 'deleteAssetsList success');
    } catch (err) {
      HiLog.error(TAG, `deleteAssetsList failed. error: ${err.code}, ${err.message}`);
    }
  }

  /**
   * 删除媒体库回收站图片
   *
   * @param context 上下文
   * @param uri 图片路径
   */
  public static async deletePhotoAssets(context: Context, uri: string) {
    if (ObjectUtil.isNullOrUndefined(context)) {
      HiLog.error(TAG, 'deletePhotoAssets failed context is undefined ');
      return;
    }

    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    predicates.equalTo(photoAccessHelper.PhotoKeys.URI, uri);
    let fetchOption: userFileManager.FetchOptions = {
      fetchColumns: [],
      predicates: predicates
    };
    let fetchResult: userFileManager.FetchResult<userFileManager.FileAsset> | undefined = undefined;

    try {
      let mgr = userFileManager.getUserFileMgr(context);
      let albumFetchResult: userFileManager.FetchResult<userFileManager.Album> =
        await mgr.getAlbums(userFileManager.AlbumType.SYSTEM, userFileManager.AlbumSubType.TRASH);
      let album: userFileManager.Album = await albumFetchResult.getFirstObject();
      fetchResult = await album.getPhotoAssets(fetchOption);
      let asset: userFileManager.FileAsset = await fetchResult.getFirstObject();
      await album.deletePhotoAssets([asset]);
      HiLog.info(TAG, 'deletePhotoAssets success');
    } catch (err) {
      HiLog.error(TAG, `deletePhotoAssets failed. error: ${err?.code}, ${err?.message}`);
      throw err as Error;
    } finally {
      fetchResult?.close();
    }
  }

  /**
   * 批量还原媒体库图片
   *
   * @param uris 批量图片的uri
   */
  public static async recoverFromTrash(context: Context, uris: string[]): Promise<void> {
    HiLog.info(TAG, 'recoverFromTrash start');
    if (uris.length === 0) {
      HiLog.error(TAG, 'recoverFromTrash len is 0');
      return;
    }
    let helper: photoAccessHelper.PhotoAccessHelper | undefined = undefined;
    let fetchResult: photoAccessHelper.FetchResult<PhotoAsset> | undefined = undefined;
    let albumResult: photoAccessHelper.FetchResult<photoAccessHelper.Album> | undefined = undefined;
    let assets: PhotoAsset[] = [];
    try {
      helper = photoAccessHelper.getPhotoAccessHelper(context);
      albumResult = await helper.getAlbums(photoAccessHelper.AlbumType.SYSTEM, photoAccessHelper.AlbumSubtype.TRASH);
      let album: photoAccessHelper.Album = await albumResult.getFirstObject();
      for (let i = 0; i < uris.length; i++) {
        let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
        predicates.equalTo(photoAccessHelper.PhotoKeys.URI, uris[i]);
        let fetchOptions: photoAccessHelper.FetchOptions = {
          fetchColumns: [],
          predicates: predicates
        };
        fetchResult = await album.getAssets(fetchOptions);
        let asset: PhotoAsset = await fetchResult.getFirstObject();
        if (asset) {
          assets.push(asset);
        }
      }
      const len = assets.length;
      HiLog.warn(TAG, 'recoverFromTrash assets len ' + len);
      if (len !== 0) {
        let albumChangeRequest: photoAccessHelper.MediaAlbumChangeRequest = new photoAccessHelper
          .MediaAlbumChangeRequest(album);
        albumChangeRequest.recoverAssets(assets);
        await helper.applyChanges(albumChangeRequest);
      }
      HiLog.warn(TAG, 'recoverFromTrash end');
    } catch (err) {
      HiLog.error(TAG, `recoverFromTrash failed with error: ${err.code}, ${err.message}`);
    } finally {
      albumResult?.close();
      fetchResult?.close();
      helper?.release();
    }
  }

  /**
   * 从媒体库彻底删除: 先删除到回收站 再彻底删除。
   * @param context 上下文 必须使用 getContext(this)。
   * @param uri 图片uri
   */
  public static async deletePermanently(context?: Context, uri: string = ''): Promise<void> {
    HiLog.info(TAG, 'deletePermanently start');
    if (ObjectUtil.isNullOrUndefined(context)) {
      HiLog.warn(TAG, 'deletePermanently failed context is undefined');
      return;
    }
    if (!uri) {
      HiLog.warn(TAG, 'deletePermanently failed uri is null');
      return;
    }
    try {
      // 先删除到回收站
      if (!await PhotoAccessUtil.deleteIntoTrash(context, uri)) {
        HiLog.warn(TAG, 'deletePermanently failed for deleteIntoTrash fail!');
        return;
      }
      // 成功再将文件从回收站删除
      await PhotoAccessUtil.deleteFromTrash(context, uri);
      HiLog.info(TAG, 'deletePermanently end');
    } catch (err) {
      HiLog.error(TAG, `deletePermanently failed with error: ${err.code}, ${err.message}`);
    }
  }

  /**
   * 监听媒体库变化
   */
  public static registerChange(context: common.Context | undefined, callback: Function): void {
    if (!context) {
      HiLog.info(TAG, 'registerChange on fail, context is undefined');
      return;
    }
    HiLog.info(TAG, 'registerChange on');
    let onCallback = (changeData: photoAccessHelper.ChangeData) => {
      HiLog.infoPrivate(TAG, ' registerChange successfully, changData: ', JSON.stringify(changeData));
      callback();
    }
    let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
    phAccessHelper.registerChange(photoAccessHelper.DefaultChangeUri.DEFAULT_PHOTO_URI, true, onCallback);
  }

  /**
   * 判断是否是系统相册，即图片和视频相册
   */
  public static isSystemAlbum(type?: number, subtype?: number) {
    return type === PhotoAlbumType.SYSTEM &&
      (subtype === PhotoAlbumSubType.IMAGE || subtype === PhotoAlbumSubType.VIDEO);
  }

  /**
   * 获取录屏和截图相册uri用于注册监听
   * @param accessHelper
   * @returns
   */
  public static async getCaptureAlbums(accessHelper: photoAccessHelper.PhotoAccessHelper): Promise<string[]> {
    HiLog.info(TAG, 'getCaptureAlbums start');
    let uris: string[] = []
    let fetchResult: photoAccessHelper.FetchResult<PhotoAlbum> | undefined = undefined;
    try {
      let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      predicates.equalTo('bundle_name', Constant.SCREEN_SHOT_BUNDLE_NAME)
        .or()
        .equalTo('bundle_name', Constant.SCREEN_RECORDER_BUNDLE_NAME);
      let fetchOptions: photoAccessHelper.FetchOptions = {
        fetchColumns: [],
        predicates: predicates
      };
      let albumType: number = PhotoAlbumType.SOURCE;
      fetchResult =
        await accessHelper.getAlbums(albumType, photoAccessHelper.AlbumSubtype.SOURCE_GENERIC, fetchOptions);
      let photoAlbumList: Array<PhotoAlbum> = await fetchResult?.getAllObjects();
      for (let photoAlbum of photoAlbumList) {
        uris.push(photoAlbum.albumUri);
      }
      HiLog.error(TAG, 'getCaptureAlbums success: ' + uris.length);
    } catch (err) {
      HiLog.error(TAG, 'getCaptureAlbums failed with error: ' + JSON.stringify(err));
    } finally {
      fetchResult?.close();
    }
    return uris;
  }

  /**
   * 获取图库最近的文件
   * @param context
   * @param fetchLimit 获取图库最近资源的数量
   * @returns
   */
  public static async getRecentPhotoAsset(context: Context, fetchLimit: number): Promise<FileInfo[]> {
    HiLog.info(TAG, 'getRecentPhotoAsset start')
    let mediaList: FileInfo [] = [];
    const now = new Date();
    const thirtyDaysAgo = new Date(now);
    thirtyDaysAgo.setDate(now.getDate() - TIME_RECENT); // 设置今天往前30天的时间
    const time = thirtyDaysAgo.getTime() / TIME_ONE_SECOND;
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    //获取最近30天内fetchLimit数量内的图库资源，其中图片资源要大于30k才展示，纯图库文件不展示
    predicates.greaterThanOrEqualTo(photoAccessHelper.PhotoKeys.DATE_MODIFIED, time)
      .and()
      .limit(fetchLimit, 0)
      .and()
      .notEqualTo('position', 2)
      .and()
      .orderByDesc(photoAccessHelper.PhotoKeys.DATE_MODIFIED)
      .beginWrap()
      .equalTo(photoAccessHelper.PhotoKeys.PHOTO_TYPE, photoAccessHelper.PhotoType.IMAGE)
      .or()
      .equalTo(photoAccessHelper.PhotoKeys.PHOTO_TYPE, photoAccessHelper.PhotoType.VIDEO)
      .endWrap()

    // 查最近数据去重湖内媒体文件
      predicates.equalTo(PhotoUtil.FILE_SOURCE_TYPE, PhotoFileSourceType.MEDIA);

    let fetchOptions: photoAccessHelper.FetchOptions = {
      fetchColumns: PhotoUtil.FETCH_COLUMNS,
      predicates: predicates
    };

    let accessHelper: photoAccessHelper.PhotoAccessHelper | undefined = undefined;
    try {
      accessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      if (!accessHelper) {
        HiLog.error(TAG, 'getRecentPhotoAsset can not get accessHelper')
        return mediaList;
      }
    } catch (err) {
      HiLog.error(TAG, 'getRecentPhotoAsset getPhotoAccessHelper failed with error: ' + JSON.stringify(err));
      return mediaList;
    }

    let photoAssetList: PhotoAsset[] = [];
    try {
      let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
        await accessHelper.getAssets(fetchOptions);
      if (fetchResult !== undefined) {
        HiLog.info(TAG, 'getRecentPhotoAsset fetchResult success');
        photoAssetList = await fetchResult.getAllObjects();
      }
      HiLog.info(TAG, 'getRecentPhotoAsset get len :' + photoAssetList.length);
    } catch (err) {
      HiLog.error(TAG, `getRecentPhotoAsset photoAsset getAssets failed, error: ${err.code}, ${err.message}`);
    }

    const galleryUris: string[] = photoAssetList.map(photoAsset => {
      return photoAsset.uri;
    })
    let res: boolean[] = await FavoriteDbManager.getInstance().queryRecent(galleryUris);

    let photoAssetArray = photoAssetList.filter((item, index) => {
      return !res[index];
    })

    let albumMap = await PhotoAccessUtil.getAlbumInfoByAllAlbums(context);

    for (let photoAsset of photoAssetArray) {
      let fileInfo = PhotoAccessUtil.fromPhotoAsset(photoAsset);
      fileInfo.recentTime = fileInfo.mtime;

      PhotoAccessUtil.addAlbumInfoToPhoto(fileInfo, albumMap.get(fileInfo.ownerAlbumId), context);
      mediaList.push(fileInfo);
    }

    HiLog.info(TAG, 'getRecentPhotoAsset get mediaList len:' + mediaList.length);
    return mediaList;
  }

  /**
   * 监听相册下内容变化变化
   */
  public static async registerAlbumChanges(context: common.Context | undefined, uri: string,
    callback: Callback<photoAccessHelper.ChangeData>): Promise<void> {
    if (!context || !uri) {
      HiLog.info(TAG, 'registerAlbumChanges on fail, Parameter error.');
      return;
    }
    let phAccessHelper = PhotoAccessUtil.getAccessHelper(context);
    if (!phAccessHelper) {
      return;
    }
    if (!uri.startsWith(VirtualUri.GALLERY_URI)) {
      return;
    }
    try {
      phAccessHelper.registerChange(uri, true, callback);
    } catch (err) {
      HiLog.error(TAG, 'registerAlbumChanges failed with error: ' + JSON.stringify(err));
    }
  }

  /**
   * 解除监听媒体库变化
   */
  public static unRegisterAlbumChange(context: common.Context | undefined, uri?: string,
    callback?: Callback<photoAccessHelper.ChangeData>): void {
    if (!context || !uri) {
      HiLog.info(TAG, 'registerChange off fail, Parameter error.');
      return;
    }
    let phAccessHelper = PhotoAccessUtil.getAccessHelper(context);
    if (!phAccessHelper) {
      HiLog.info(TAG, 'phAccessHelper is null.');
      return;
    }
    if (!uri.startsWith(VirtualUri.GALLERY_URI)) {
      return;
    }
    try {
      phAccessHelper.unRegisterChange(uri, callback);
    } catch (error) {
      HiLog.error(TAG, `unRegisterChange fail, error: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 监听截屏录屏媒体库变化
   */
  public static async registerCaptureChange(context: common.Context | undefined, callback: Function): Promise<void> {
    if (!context) {
      HiLog.error(TAG, 'registerCaptureChange on fail, context is undefined');
      return;
    }
    HiLog.info(TAG, 'registerCaptureChange on');
    let onCallback = (changeData: photoAccessHelper.ChangeData) => {
      HiLog.infoPrivate(TAG, ' registerChange successfully, changData: ', JSON.stringify(changeData));
      if (changeData.type === photoAccessHelper.NotifyType.NOTIFY_ALBUM_ADD_ASSET) {
        callback(changeData);
      }
    }
    let phAccessHelper: photoAccessHelper.PhotoAccessHelper | undefined = undefined;
    try {
      phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      if (!phAccessHelper) {
        HiLog.error(TAG, 'registerCaptureChange can not get accessHelper')
        return;
      }
      let uris: string[] = await PhotoAccessUtil.getCaptureAlbums(phAccessHelper)
      for (let uri of uris) {
        phAccessHelper.registerChange(uri, true, onCallback);
      }
    } catch (err) {
      HiLog.error(TAG, 'registerCaptureChange getPhotoAccessHelper failed with error: ' + JSON.stringify(err));
      return;
    }
  }

  /**
   * 解除截屏录屏媒体库监听
   */
  public static async unRegisterCaptureChange(context: common.Context | undefined, callback?: Function): Promise<void> {
    if (!context) {
      HiLog.error(TAG, 'unRegisterCaptureChange on fail, context is undefined');
      return;
    }
    HiLog.info(TAG, 'unRegisterCaptureChange on');
    let phAccessHelper = PhotoAccessUtil.getAccessHelper(context);
    if (!phAccessHelper) {
      return;
    }
    try {
      let uris: string[] = await PhotoAccessUtil.getCaptureAlbums(phAccessHelper);
      for (let uri of uris) {
        phAccessHelper.unRegisterChange(uri);
      }
    } catch (err) {
      HiLog.error(TAG, 'unRegisterCaptureChange getPhotoAccessHelper failed with error: ' + JSON.stringify(err));
    }
  }

  /**
   * 获取图库PhotoAccessHelper
   * @param context 上下文
   * @returns 图库PhotoAccessHelper
   */
  public static getAccessHelper(context: common.Context | undefined):
  photoAccessHelper.PhotoAccessHelper | undefined {
    if (!context) {
      HiLog.warn(TAG, 'context is null or undefined');
      return undefined;
    }
    if (PhotoAccessUtil.phAccessHelper) {
      return PhotoAccessUtil.phAccessHelper;
    }
    try {
      PhotoAccessUtil.phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      HiLog.info(TAG, `get photoAccess helper success`);
    } catch (err) {
      HiLog.error(TAG, `getPhotoAccessHelper failed, errorInfo: ${err.code}, ${err.message}`);
    }
    return PhotoAccessUtil.phAccessHelper;
  }

  /**
   * 三方拉起文管picker数据到图库
   * @param context
   * @param fileList 需要拷贝的文件名列表
   * @param destAlbumUri 应用选择的目的相册URI
   * @param appInfo 调用媒体库指定相册保存接口所需的参数
   * @returns
   */
  public static async copyThirdPhotoToGallery(context: Context, fileList: string[], destAlbumUri: string,
    appInfo: AppInfo): Promise<SaveFilesResult> {
    HiLog.error(TAG, 'copyThirdPhotoToGallery start:' + fileList.length)
    let result: string[] = [];
    let resultErr: undefined | ResultErrorParams;

    let phAccessHelper: photoAccessHelper.PhotoAccessHelper | undefined = undefined;
    try {
      phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      if (!phAccessHelper) {
        HiLog.error(TAG, 'copyThirdPhotoToGallery can not get accessHelper')
        resultErr = { code: -1, message: 'can not get accessHelper' };
        return new SaveFilesResult(result, resultErr);
      }
    } catch (err) {
      HiLog.error(TAG, 'copyThirdPhotoToGallery getPhotoAccessHelper failed with error: ' + JSON.stringify(err));
      resultErr = { code: -1, message: 'get accessHelper err' };
      return new SaveFilesResult(result, resultErr);
    }

    for (let i = 0; i < fileList.length; i += FILE_COPY_LIMIT) {
      const tmpNameList = fileList.slice(i, i + FILE_COPY_LIMIT);
      const configs = PhotoAccessUtil.genPhotoCreationConfigArray(tmpNameList);
      if (configs.length === 0) {
        HiLog.error(TAG, 'copyThirdPhotoToGallery error with 0 configs');
        //Todo 待补充删除已创建的文件的逻辑
        result = [];
        resultErr = { code: -1, message: 'error with 0 configs' };
        return new SaveFilesResult(result, resultErr);
      }

      HiLog.warn(TAG, 'start createAssetsForAppWithAlbum');
      let uris: string[] = [];
      try {
        uris =
          await PhotoUtil.createAssetsForAppWithAlbum(phAccessHelper, true, destAlbumUri, configs, appInfo.bundleName,
            appInfo.appName, appInfo.appId, appInfo.tokenId);
      } catch (e) {
        HiLog.error(TAG, 'createAssetsForAppWithAlbum error due to exception')
      }

      if (uris.length > 0 && uris[0].startsWith(VirtualUri.GALLERY_PHOTO_URI)) {
        HiLog.info(TAG, 'createAssetsForAppWithAlbum success:' + uris.length)
      } else {
        HiLog.error(TAG, 'createAssetsForAppWithAlbum error:' + uris)
        //Todo 待补充删除已创建的文件的逻辑
        result = [];
        resultErr = { code: -1, message: 'createAssetsForAppWithAlbum error' };
        return new SaveFilesResult(result, resultErr);
      }
      result.push(...uris);
      HiLog.warn(TAG, 'copyThirdPhotoToGallery ok: ' + result.length);
    }

    phAccessHelper.release()
    return new SaveFilesResult(result);
  }

  /**
   * 从文管图库->相册中选择媒体彻底删除
   * @param context
   * @param fileList
   * @returns
   */
  public static async deletePhotoForManager(context: common.Context, galleryUris: string[]): Promise<void> {
    HiLog.warn(TAG, 'deletePhotoForManager start for photos:' + galleryUris.length);
    for (let i = 0; i < galleryUris.length; i += FILE_BATCH_DEL_LIMIT) {
      const tmpGalleryUri = galleryUris.slice(i, i + FILE_BATCH_DEL_LIMIT);
      await PhotoAccessUtil.deleteAssetsList(context, tmpGalleryUri);
      //彻底删除文件
      await PhotoAccessUtil.deleteBatchPermanently(context, tmpGalleryUri);
    }
    HiLog.warn(TAG, `deletePhotoForManager end:${galleryUris.length}`);
  }

  /**
   * 从媒体库彻底删除: 从媒体库回收站 彻底删除。
   * @param context 上下文 必须使用 getContext(this)。
   * @param uri 图片uri
   */
  public static async deleteBatchPermanently(context: Context, uris: string[]): Promise<void> {
    HiLog.info(TAG, `deleteBatchPermanently start:${uris.length}`);
    if (ObjectUtil.isNullOrUndefined(context)) {
      HiLog.warn(TAG, 'deleteBatchPermanently failed context is undefined');
      return;
    }

    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    for (let i = 0; i < uris.length; i++) {
      if (i < uris.length - 1) {
        predicates.equalTo(photoAccessHelper.PhotoKeys.URI, uris[i]).or();
      } else {
        predicates.equalTo(photoAccessHelper.PhotoKeys.URI, uris[i]);
      }
    }
    let fetchOptions: photoAccessHelper.FetchOptions = {
      fetchColumns: [],
      predicates: predicates
    };
    let fetchResult: userFileManager.FetchResult<userFileManager.FileAsset> | undefined = undefined;
    try {
      let mgr = userFileManager.getUserFileMgr(context);
      let albumFetchResult: userFileManager.FetchResult<userFileManager.Album> =
        await mgr.getAlbums(userFileManager.AlbumType.SYSTEM, userFileManager.AlbumSubType.TRASH);
      HiLog.info(TAG, 'deleteBatchPermanently getAlbums end: get album' + albumFetchResult.getCount());
      let album: userFileManager.Album = await albumFetchResult.getFirstObject();
      fetchResult = await album.getPhotoAssets(fetchOptions);
      HiLog.info(TAG, 'deleteFromTrash deleteAssets start: get getPhotoAssets' + fetchResult.getCount());
      let asset: userFileManager.FileAsset[] = await fetchResult.getAllObject();
      await album.deletePhotoAssets(asset);
      HiLog.info(TAG, 'deletePhotoAssets success');
    } catch (err) {
      HiLog.error(TAG, `deletePhotoAssets failed. error: ${err?.code}, ${err?.message}`);
      throw err as Error;
    } finally {
      fetchResult?.close();
    }
  }

  /**
   * 获取新创建的用户相册
   */
  public static async getNewUserAlbumByName(data: QueryFileParam, folderName: string,
    photosLock: boolean = false): Promise<FileInfo> {
    HiLog.info(TAG, 'getCreatedAlbumByName start');
    let fileInfo: FileInfo = new FileInfo();
    if (photosLock) {
      return fileInfo;
    }
    const fetchType: AlbumType = {
      type: PhotoAlbumType.USER,
      subtype: PhotoAlbumSubType.USER_GENERIC
    };
    let accessHelper: photoAccessHelper.PhotoAccessHelper | undefined = undefined;
    try {
      accessHelper = photoAccessHelper.getPhotoAccessHelper(data.context);
      if (!accessHelper) {
        HiLog.error(TAG, 'getCreatedAlbumByName can not get phAccessHelper')
        return fileInfo;
      }
    } catch (err) {
      HiLog.error(TAG, 'getCreatedAlbumByName getPhotoAccessHelper failed with error: ' + JSON.stringify(err));
      return fileInfo;
    }
    let fetchResult: photoAccessHelper.FetchResult<PhotoAlbum> | undefined = undefined;
    try {
      let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      predicates.equalTo('album_name', folderName);
      let fetchOptions: photoAccessHelper.FetchOptions = {
        fetchColumns: [],
        predicates: predicates
      };
      fetchResult = await accessHelper.getAlbums(fetchType.type, fetchType.subtype, fetchOptions);
      let photoAlbumList: Array<PhotoAlbum> = await fetchResult.getAllObjects();
      const photoAlbum: PhotoAlbum | undefined =
        photoAlbumList.find((item: PhotoAlbum) => item.albumName === folderName);
      if (photoAlbum) {
        fileInfo.fileName = photoAlbum.albumName;
        fileInfo.uri = photoAlbum.albumUri;
        FileInfo.getThumbnailType(fileInfo);
        fileInfo.subFileCount = 0;
        fileInfo.isFolder = true;
        fileInfo.parentPathForDetail = VirtualUri.GALLERY;
        fileInfo.albumType = photoAlbum.albumType;
        fileInfo.albumSubType = photoAlbum.albumSubtype;
        fileInfo.isMultiEnable = true;
      }
    } catch (err) {
      HiLog.error(TAG, 'getCreatedAlbumByName failed with error: ' + JSON.stringify(err));
    } finally {
      fetchResult?.close();
      accessHelper?.release();
    }
    return fileInfo;
  }

  // 获取全部相册
  public static async getAllPhotoAlbums(data: QueryFileParam, dirUri: string, isPicker: boolean): Promise<FileInfo[]> {
    HiLog.info(TAG, 'getAllPhotoAlbums start');
    let fileList: FileInfo[] = [];
    let fetchTypes: AlbumType[] | undefined = ALBUM_MAP.get(dirUri);
    if (!fetchTypes) {
      HiLog.error(TAG, 'getAllPhotoAlbums invalid dirUri');
      return fileList;
    }
    let accessHelper: photoAccessHelper.PhotoAccessHelper | undefined = undefined;
    try {
      accessHelper = photoAccessHelper.getPhotoAccessHelper(data.context);
      if (!accessHelper) {
        HiLog.error(TAG, 'getAllPhotoAlbums can not get phAccessHelper')
        return fileList;
      }
    } catch (err) {
      HiLog.error(TAG, `getAllPhotoAlbums failed with error, code: ${err?.code}, msg: ${err?.message}`);
      return fileList;
    }

    for (let fetchType of fetchTypes) {
      let fetchResult: photoAccessHelper.FetchResult<PhotoAlbum> | undefined = undefined;
      try {
        HiLog.info(TAG, `getAllPhotoAlbums fetch album type:${fetchType.type} subtype:${fetchType.subtype}`);
        let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
        const isUsrAlbum: boolean = dirUri === VirtualUri.GALLERY && fetchType.type === PhotoAlbumType.USER;
        // 用户相册，在图库路径下，空相册要同样显示
        if (!isUsrAlbum) {
          predicates.notEqualTo('count', 0);
        }
        let fetchOptions: photoAccessHelper.FetchOptions = {
          fetchColumns: [],
          predicates: predicates
        };

        fetchResult = await accessHelper.getAlbums(fetchType.type, fetchType.subtype, fetchOptions);
        let photoAlbumList: Array<PhotoAlbum> = await fetchResult.getAllObjects();
        for (let photoAlbum of photoAlbumList) {
          const info = await PhotoAccessUtil.getPhotoAssetNum(photoAlbum, -1);
          // 图库路径且是用户相册不过滤数量，来源数量为空的不显示
          if ((info.cnt) === 0 && !isUsrAlbum) {
            continue;
          }

          let fileInfo: FileInfo = new FileInfo();
          let tempName: string = fetchType.type === PhotoAlbumType.SYSTEM ?
          ResourceUtil.getStringByResource(PHOTO_URI_MAP.get(photoAlbum.albumSubtype), data.context) :
          photoAlbum.albumName;
          fileInfo.fileName = PhotoAccessUtil.getSysResourceAlbumName(photoAlbum, tempName, data.context);
          fileInfo.uri = photoAlbum.albumUri;
          FileInfo.getThumbnailType(fileInfo);
          fileInfo.subFileCount = info.cnt;
          fileInfo.isFolder = true;
          fileInfo.parentPathForDetail = VirtualUri.GALLERY;
          fileInfo.albumType = photoAlbum.albumType;
          fileInfo.hasFusionAssets = false;
          fileInfo.albumSubType = photoAlbum.albumSubtype;
          fileInfo.isMultiEnable = isPicker ||
            !PhotoAccessUtil.isSystemAlbum(photoAlbum.albumType, photoAlbum.albumSubtype);
          fileList.push(fileInfo);
        }
      } catch (err) {
        HiLog.error(TAG, `getAllPhotoAlbums failed with error, code: ${err?.code}, msg: ${err?.message}`);
      } finally {
        fetchResult?.close();
      }
    }
    accessHelper?.release();
    HiLog.warn(TAG, 'getAllPhotoAlbums end ' + fileList.length);
    return fileList;
  }

  public static getSysResourceAlbumName(photoAlbum: photoAccessHelper.Album, name: string,
    context: Context | undefined) {
    if (!photoAlbum) {
      HiLog.warn(TAG, 'getSysResourceAlbumName fail, photoAlbum is null');
      return name;
    }
    if (photoAlbum.albumSubtype === photoAccessHelper.AlbumSubtype.SOURCE_GENERIC) {
      const lpath: string | undefined = photoAlbum.lpath;
      if (lpath && PhotoAccessUtil.PHOTO_LPATH_MAP.has(lpath)) {
        let resourceName = ResourceUtil.getStringByResource(PhotoAccessUtil.PHOTO_LPATH_MAP.get(lpath), context);
        return StringUtil.isEmpty(resourceName) ? name : resourceName;
      }
    }
    return name;
  }

  /**
   * 重命名图库相册
   */
  public static async renameAlbum(context: common.Context, oldUri: string, newName: string): Promise<string> {
    HiLog.infoPrivate(TAG, `renameAlbum start`, `oldUri is ${oldUri}, newName:${newName}`);
    if (!context) {
      HiLog.error(TAG, 'context is undefined');
      return '';
    }
    let albumList: PhotoAlbum[] = await PhotoAccessUtil.getAllAlbums(context, VirtualUri.GALLERY);
    const album: photoAccessHelper.Album | undefined = albumList.find(item => item.albumUri === oldUri);
    if (!album) {
      HiLog.warnPrivate(TAG, 'could not found album by uri ', `albumUri:${oldUri}`);
      return '';
    }
    if (album.albumType !== photoAccessHelper.AlbumType.USER) {
      HiLog.warnPrivate(TAG, 'only user album support rename ', `albumUri:${oldUri}`);
      return '';
    }
    albumList.forEach(item => {
      // 不支持重复文件名和大小写变更
      if (item.albumName.toUpperCase() === newName.toUpperCase()) {
        throw new FileAccessError(ERROR_CODE.FILE_ACCESS.FILE_EXISTS, 'File name exists ignoring case');
      }
    });
    let phAccessHelper: photoAccessHelper.PhotoAccessHelper | undefined = PhotoAccessUtil.getAccessHelper(context);
    if (!phAccessHelper) {
      HiLog.error(TAG, 'can not get phAccessHelper.');
      return '';
    }
    try {
      let albumChangeRequest: photoAccessHelper.MediaAlbumChangeRequest =
        new photoAccessHelper.MediaAlbumChangeRequest(album);
      // 相册重命名
      albumChangeRequest.setAlbumName(newName);
      await phAccessHelper.applyChanges(albumChangeRequest);
      albumList = await PhotoAccessUtil.getAllAlbums(context, VirtualUri.GALLERY);
      // 获取变更后的相册
      const changedAlbum: photoAccessHelper.Album | undefined = albumList.find(item => item.albumName === newName &&
        item.albumType === photoAccessHelper.AlbumType.USER);
      HiLog.infoPrivate(TAG, 'renameAlbum end. ', `changedAlbumName:${changedAlbum?.albumName}`);
      return changedAlbum?.albumUri || '';
    } catch (e) {
      HiLog.error(TAG, `renameAlbum error, ${JSON.stringify(e)}.`);
      throw e as Error;
    }
  }

  private static async getPhotoByBundleName(context: common.Context, bundleName: string, mediaSearchType: number,
    albumType: number,
    albumSubType: number, orderBy?: string, isOrderDesc?: boolean,
    photoCondition?: PhotoCondition): Promise<FileInfo[]> {
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    predicates.equalTo('bundle_name', bundleName);

    return await PhotoAccessUtil.getPhoto(context, predicates, mediaSearchType, albumType, albumSubType, orderBy,
      isOrderDesc, photoCondition, 0, true);
  }

  /**
   * 获取媒体库图片文件
   * @returns FileInfo[] : file info array
   */
  private static async getPhoto(context: common.Context, predicates: dataSharePredicates.DataSharePredicates,
    mediaSearchType: number, albumType: number, albumSubType: number, orderBy?: string, isOrderDesc?: boolean,
    photoCondition?: PhotoCondition, filterSize: number = 0,
    isSource?: boolean): Promise<FileInfo[]> {
    HiLog.info(TAG, `getPhoto start with album type:${mediaSearchType}_${albumType}_${albumSubType}`);
    let mediaFileArray: FileInfo[] = [];
    let accessHelper: photoAccessHelper.PhotoAccessHelper | undefined = undefined;
    let fetchResult: photoAccessHelper.FetchResult<PhotoAlbum> | undefined = undefined;
    const rootNameMyPhone: string = ResourceUtil.getStringByResource($r('app.string.myPhone'), context);
    try {
      accessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      if (!accessHelper) {
        HiLog.error(TAG, 'getPhoto can not get phAccessHelper')
        return mediaFileArray;
      }

      let fetchOptions: photoAccessHelper.FetchOptions = {
        fetchColumns: [],
        predicates: predicates
      };
      fetchResult = await accessHelper.getAlbums(albumType, albumSubType, fetchOptions);
      let photoAlbum: Array<PhotoAlbum> = await fetchResult.getAllObjects();
      let includeSuffixSet: Set<string> = new Set<string>();
      let excludeSuffixSet: Set<string> = new Set<string>();
      let isFilter: boolean = false;
      if (photoCondition) {
        includeSuffixSet = new Set<string>(photoCondition.includeSuffixes);
        excludeSuffixSet = new Set<string>(photoCondition.excludeSuffixes);
        isFilter = includeSuffixSet.size > 0 || excludeSuffixSet.size > 0;
      }

      let albumMap = new Map<number, PhotoAlbum>();
      if (albumType === PhotoAlbumType.SYSTEM) {
        albumMap = await PhotoAccessUtil.getAlbumInfoByAllAlbums(context);
      }
      HiLog.warn(TAG, `getPhoto get album:${photoAlbum.length}`)
      for (let album of photoAlbum) {
        let photoAssetArray: PhotoAsset[] = await PhotoAccessUtil.getPhotoAsset(album, 0,
          PhotoUtil.FETCH_COLUMNS, orderBy, isOrderDesc, filterSize, 0, 0, isSource) as PhotoAsset[];
        for (let photoAsset of photoAssetArray) {
          // 文件后缀过滤
          if (isFilter) {
            let fileSuffix: string = FileMimeTypeUtil.getFileSuffix(photoAsset.displayName).toLowerCase();
            if (includeSuffixSet.size > 0 && !includeSuffixSet.has(fileSuffix) ||
              excludeSuffixSet.size > 0 && excludeSuffixSet.has(fileSuffix)) {
              continue;
            }
          }
          let fileInfo = PhotoAccessUtil.fromPhotoAsset(photoAsset);
          if (albumType === PhotoAlbumType.SYSTEM) {
            PhotoAccessUtil.addAlbumInfoToPhoto(fileInfo, albumMap.get(fileInfo.ownerAlbumId));
          } else {
            PhotoAccessUtil.addAlbumInfoToPhoto(fileInfo, album);
          }
          mediaFileArray.push(fileInfo);
        }
      }
    } catch (error) {
      HiLog.error(TAG, 'list GALLERY error: ' + JSON.stringify(error));
    } finally {
      fetchResult?.close();
      accessHelper?.release();
    }
    HiLog.info(TAG, `getPhoto length is ${mediaFileArray.length}`);
    return mediaFileArray;
  }

  private static getVirtualGalleryFolder(filePickerViewFlag: boolean, context?: Context): FileInfo {
    const fileInfo: FileInfo = new FileInfo();
    fileInfo.isFolder = true;
    fileInfo.uri = VirtualUri.GALLERY;
    fileInfo.fileName = ResourceUtil.getStringByResource($r('app.string.pc_gallery'), context);
    fileInfo.subFileCount = 0;
    fileInfo.isMultiEnable = filePickerViewFlag;
    fileInfo.isGallery = true;
    fileInfo.isVirtualGallery = true;
    return fileInfo;
  }

  /*
   * create fileInfo by photoAsset
   * */
  private static fromPhotoAsset(photoAsset: PhotoAsset): FileInfo {
    let fileInfo = new FileInfo();
    fileInfo.uri = photoAsset.uri;
    fileInfo.fileName = photoAsset.displayName;
    fileInfo.isGallery = true;
    fileInfo.addedDate = photoAsset.get(photoAccessHelper.PhotoKeys.DATE_ADDED) as number;
    fileInfo.mtime = photoAsset.get(photoAccessHelper.PhotoKeys.DATE_MODIFIED) as number;
    fileInfo.mtime *= Constant.TIME.ONE_SECOND;
    fileInfo.size = photoAsset.get(photoAccessHelper.PhotoKeys.SIZE) as number;
    fileInfo.mimeTypeObj = FileMimeTypeUtil.getFileMimeType(photoAsset.displayName);
    if (fileInfo.mimeTypeObj.fileCategory === MimeType.FILE_CATEGORY_VIDEO) {
      fileInfo.duration = photoAsset.get(photoAccessHelper.PhotoKeys.DURATION) as number;
    }
    fileInfo.picWidth = photoAsset.get(photoAccessHelper.PhotoKeys.WIDTH) as number;
    fileInfo.picHeight = photoAsset.get(photoAccessHelper.PhotoKeys.HEIGHT) as number;
    fileInfo.path = photoAsset.get('data') as string; // 针对图库使用，图库拿缩略图需要此值
    fileInfo.timesStampApp = photoAsset.get(photoAccessHelper.PhotoKeys.DATE_MODIFIED_MS) as number;
    fileInfo.thumbnailModifiledMs = photoAsset.get('thumbnail_ready') as number;
    fileInfo.locationType = photoAsset.get(photoAccessHelper.PhotoKeys.POSITION) as number;
    FileInfo.getThumbnailType(fileInfo);
    if (!fileInfo.useCacheImage) {
      HiLog.info(TAG, 'fromPhotoAsset get thumbnailType not support cacheImage ' + fileInfo.thumbnailType);
    }
    fileInfo.ownerAlbumId = (photoAsset.get('owner_album_id') as number) ?? -1;
    return fileInfo;
  }

  private static addAlbumInfoToPhoto(fileInfo: FileInfo, album?: PhotoAlbum, context?: Context) {
    fileInfo.parentPathForDetail = album?.albumUri ?? '';
    if (album) {
      fileInfo.parentAlbumName = PhotoAccessUtil.PHOTO_LPATH_MAP.has(album.lpath ?? '') ? album.lpath : album.albumName;
    } else {
      fileInfo.parentAlbumName = '';
    }
    fileInfo.parentAlbumType = album?.albumType;
    fileInfo.parentAlbumSubType = album?.albumSubtype;
  }

  /**
   * 通过先获取所有相册，再根据相册的uri匹配photoAsset来获取album信息
   * @param photoAssetList
   */
  private static async getAlbumInfoByAllAlbums(context?: common.Context): Promise<Map<number, photoAccessHelper.Album>> {
    HiLog.info(TAG, 'getAlbumInfoByAllAlbums begin.');
    let albumMap = new Map<number, PhotoAlbum>();

    if (!context) {
      HiLog.error(TAG, 'getAlbumInfoByAllAlbums context null!');
      return albumMap;
    }

    let albumList = await PhotoAccessUtil.getAllAlbums(context as common.Context, VirtualUri.GALLERY);

    for (let album of albumList) {
      let uri = album.albumUri;
      if (!uri) {
        HiLog.error(TAG, 'error album uri!');
        continue;
      }

      let uriList = uri.split('/');
      if (uriList.length === 0) {
        HiLog.error(TAG, 'error album uri format!');
        continue;
      }

      let albumId = uriList[uriList.length - 1];
      if (!albumId || isNaN(Number(albumId))) {
        HiLog.error(TAG, 'error album id');
        continue;
      }

      albumMap.set(Number(albumId), album);
    }

    HiLog.info(TAG, `getAlbumInfoByAllAlbums end. album map len:${albumMap.size}`);
    return albumMap;
  }

  private static initPredicatesByMatchDisplayName(searchValue: string): dataSharePredicates.DataSharePredicates {
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    // 不获取云图
    predicates.notEqualTo(photoAccessHelper.PhotoKeys.POSITION, photoAccessHelper.PositionType.CLOUD)
      .like(photoAccessHelper.PhotoKeys.DISPLAY_NAME, '%' + searchValue + '%');
    // 名称、后缀搜索查媒体库去重
      predicates.equalTo(PhotoUtil.FILE_SOURCE_TYPE, PhotoFileSourceType.MEDIA);
    return predicates;
  }

  private static fromFileAsset(fileAsset: userFileManager.FileAsset) {
    let fileInfo = new FileInfo();
    fileInfo.uri = fileAsset.uri;
    fileInfo.fileName = fileAsset.displayName;
    fileInfo.isGallery = true;
    fileInfo.size = fileAsset.get('size') as number ?? 0;
    fileInfo.mimeTypeObj = FileMimeTypeUtil.getFileMimeType(fileAsset.displayName);
    if (fileInfo.mimeTypeObj.fileCategory === MimeType.FILE_CATEGORY_VIDEO) {
      fileInfo.duration = fileAsset.get(photoAccessHelper.PhotoKeys.DURATION) as number;
    }
    fileInfo.deleteTime = fileAsset.get(photoAccessHelper.PhotoKeys.DATE_TRASHED_MS) as number ?? 0;
    if (fileInfo.deleteTime <= 0) {
      HiLog.error(TAG, 'get photo delete time err');
      fileInfo.deleteTime = Date.now();
    }
    return fileInfo;
  }

  // 搜索图库回收站根据媒体库结果构造文件
  private static fromFileAssetBySearch(fileAsset: userFileManager.FileAsset) {
    let fileInfo = new FileInfo();
    fileInfo.uri = fileAsset.uri;
    fileInfo.fileName = fileAsset.displayName;
    fileInfo.isGallery = true;
    fileInfo.size = fileAsset.get('size') as number ?? 0;
    fileInfo.mimeTypeObj = FileMimeTypeUtil.getFileMimeType(fileAsset.displayName);
    if (fileInfo.mimeTypeObj.fileCategory === MimeType.FILE_CATEGORY_VIDEO) {
      fileInfo.duration = fileAsset.get(photoAccessHelper.PhotoKeys.DURATION) as number;
    }
    fileInfo.deleteTime = fileAsset.get(photoAccessHelper.PhotoKeys.DATE_TRASHED_MS) as number ?? 0;
    fileInfo.mtime = fileAsset.get(photoAccessHelper.PhotoKeys.DATE_MODIFIED_MS) as number ?? 0;
    return fileInfo;
  }

  // 将文件删除到回收站
  private static async deleteIntoTrash(context?: Context, uri: string = ''): Promise<boolean> {
    let phAccessHelper: photoAccessHelper.PhotoAccessHelper | undefined = undefined;
    let fetchResult: photoAccessHelper.FetchResult<PhotoAsset> | undefined = undefined;
    const MAX_TRY_TIMES = 3;
    let tryTimes: number = 0;
    while (tryTimes < MAX_TRY_TIMES) {
      try {
        HiLog.info(TAG, `deleteIntoTrash tryTimes: ${tryTimes}`);
        let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
        predicates.equalTo(photoAccessHelper.PhotoKeys.URI, uri);
        let fetchOptions: photoAccessHelper.FetchOptions = {
          fetchColumns: [],
          predicates: predicates
        };
        phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
        fetchResult = await phAccessHelper.getAssets(fetchOptions);
        let asset: PhotoAsset = await fetchResult.getFirstObject();
        if (!asset) {
          HiLog.warn(TAG, 'deleteIntoTrash fetch asset is undefined');
          return false;
        }
        if (asset.uri !== uri) {
          HiLog.warn(TAG, 'deleteIntoTrash uri is not exist!');
          return false;
        }
        HiLog.info(TAG, 'deleteIntoTrash deleteAssets start');
        await photoAccessHelper.MediaAssetChangeRequest.deleteAssets(context, [asset.uri]);
        HiLog.info(TAG, 'succeed to deleteIntoTrash');
        return true;
      } catch (err) {
        HiLog.error(TAG, `deleteIntoTrash failed with error: ${err.code}, ${err.message}`);
        tryTimes += 1;
        await TimeUtil.sleep(1000);
      } finally {
        fetchResult?.close();
        phAccessHelper?.release();
      }
    }
    return false;
  }

  // 将文件从回收站删除
  private static async deleteFromTrash(context?: Context, uri: string = ''): Promise<void> {
    let phAccessHelper: photoAccessHelper.PhotoAccessHelper | undefined = undefined;
    let fetchResult: photoAccessHelper.FetchResult<PhotoAsset> | undefined = undefined;
    const MAX_TRY_TIMES = 3;
    let tryTimes: number = 0;
    while (tryTimes < MAX_TRY_TIMES) {
      HiLog.info(TAG, `deleteFromTrash tryTimes: ${tryTimes}`);
      try {
        let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
        predicates.equalTo(photoAccessHelper.PhotoKeys.URI, uri);
        let fetchOptions: photoAccessHelper.FetchOptions = {
          fetchColumns: [],
          predicates: predicates
        };
        phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
        let albumFetchResult: photoAccessHelper.FetchResult<photoAccessHelper.Album> =
          await phAccessHelper.getAlbums(photoAccessHelper.AlbumType.SYSTEM, photoAccessHelper.AlbumSubtype.TRASH);
        let album: photoAccessHelper.Album = await albumFetchResult.getFirstObject();
        fetchResult = await album.getAssets(fetchOptions);
        let asset: PhotoAsset = await fetchResult.getFirstObject();
        if (!asset) {
          HiLog.warn(TAG, 'deleteFromTrash fetch asset is undefined');
          return;
        }
        if (asset.uri !== uri) {
          HiLog.warn(TAG, 'deleteFromTrash uri is not exist!');
          return;
        }
        HiLog.info(TAG, 'deleteFromTrash deleteAssets start');
        let albumChangeRequest: photoAccessHelper.MediaAlbumChangeRequest =
          new photoAccessHelper.MediaAlbumChangeRequest(album);
        albumChangeRequest.deleteAssets([asset]);
        await phAccessHelper.applyChanges(albumChangeRequest);
        // 彻底删除媒体库文件维测日志落盘
        HiLog.info(TAG, 'succeed to deleteFromTrash');
        return;
      } catch (err) {
        HiLog.error(TAG, `deleteFromTrash failed with error: ${err.code}, ${err.message}`);
        tryTimes += 1;
        await TimeUtil.sleep(1000);
      } finally {
        fetchResult?.close();
        phAccessHelper?.release();
      }
    }
  }

  /**
   * 生成媒要创建文件的配置信息
   * @param fileList
   * @returns
   */
  private static genPhotoCreationConfigArray(fileList: string[]): Array<photoAccessHelper.PhotoCreationConfig> {
    let configs: photoAccessHelper.PhotoCreationConfig[] = [];
    HiLog.warn(TAG, 'genPhotoCreationConfigArray start:' + fileList.length);
    if (fileList.length === 0) {
      HiLog.error(TAG, 'genPhotoCreationConfigArray fileList is null')
      return configs;
    }
    for (let fileName of fileList) {
      let isImage = FileMimeTypeUtil.isImage(FileMimeTypeUtil.getMimeType(fileName, false));
      const index = fileName.lastIndexOf('.')
      let name = '';
      let suffix = '';
      if (index !== -1) {
        suffix = fileName.substring(index + 1, fileName.length);
        name = fileName.substring(0, index);
      } else {
        HiLog.warn(TAG, 'genPhotoCreationConfigArray fileName do not have suffix');
        continue;
      }
      let photoCreationConfigs: photoAccessHelper.PhotoCreationConfig =
        {
          title: name,
          fileNameExtension: suffix,
          photoType: isImage ? photoAccessHelper.PhotoType.IMAGE : photoAccessHelper.PhotoType.VIDEO,
          subtype: photoAccessHelper.PhotoSubtype.DEFAULT,
        }
      configs.push(photoCreationConfigs)
    }
    HiLog.warn(TAG, 'genPhotoCreationConfigArray start:' + configs.length);
    return configs;
  }

  /**
   * @param 动图图库copy到图库，使用数据流的方式move
   * needCreateFile 媒体库需要用特定接口创建文件，本地在open时创建
   */
  public static async copyMovingImage(photoAsset: photoAccessHelper.PhotoAsset, destFileUri: string, context?: Context,
    needCreateFile: boolean = false): Promise<boolean> {
    if (!context) {
      HiLog.info(TAG, 'context is null.');
      return false;
    }
    return new Promise(async (resolve, reject) => {
      HiLog.infoPrivate(TAG, 'copyMovingImage start.', `dest file: ${destFileUri}`);
      const dataHandler: photoAccessHelper.MediaAssetDataHandler<photoAccessHelper.MovingPhoto> = {
        async onDataPrepared(movingPhoto: photoAccessHelper.MovingPhoto): Promise<void> {
          if (!movingPhoto) {
            HiLog.error(TAG, 'movingPhoto is null.');
            reject('movingPhoto is null.');
            return;
          }
          let destFile: fs.File | undefined;
          let isNeedDelete: boolean = false;
          try {
            let buffer: ArrayBuffer =
              await movingPhoto.requestContent(photoAccessHelper.ResourceType.PRIVATE_MOVING_PHOTO_RESOURCE);
            let mode: number = fs.OpenMode.READ_WRITE | fs.OpenMode.SYNC;
            if (needCreateFile) {
              mode |= fs.OpenMode.CREATE;
            }
            let destFilePath = FileUtil.getPathFromUri(destFileUri);
            HiLog.infoPrivate(TAG, 'getPathFromUri start.', `dest file: ${destFilePath}.`);
            destFile = fs.openSync(destFilePath, mode);
            isNeedDelete = true;
            let writeLen = fs.writeSync(destFile.fd, buffer, { length: buffer.byteLength });
            HiLog.info(TAG, `moving writeSync: ${writeLen}`);
            isNeedDelete = false;
          } catch (err) {
            HiLog.error(TAG, `failed to retrieve image content of moving photo,` +
              `error code is ${err?.code}, message is ${err?.message}`);
            reject(err);
            return;
          } finally {
            if (destFile) {
              FsUtil.closeSync(destFile);
            }
            // 如果是本地文件，异常时，删除copy一半的文件; 媒体不提供删除能力，产生的文件，媒体自身解决
            if (isNeedDelete && !destFileUri?.startsWith(VirtualUri.GALLERY_PHOTO_URI)) {
              HiLog.info(TAG, 'copy file, delete dest file.');
              FsUtil.forceDelete(destFileUri);
            }
          }
          resolve(true);
        }
      }
      try {
        let requestOptions: photoAccessHelper.RequestOptions = {
          deliveryMode: photoAccessHelper.DeliveryMode.FAST_MODE
        };

        let requestId: string = await photoAccessHelper.MediaAssetManager.requestMovingPhoto(context,
          photoAsset, requestOptions, dataHandler);
        HiLog.info(TAG, `moving photo requested successfully. request id: ${requestId}`);
      } catch (err) {
        HiLog.error(TAG, `failed to request moving photo, error code is ${err?.code}, message is ${err?.message}`);
        reject(err);
      }
    });
  }
}
