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
import { describe, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import { FileInfo, GlobalHolder, HiLog, QueryFileParam, VirtualUri, ERROR_CODE,
  Constant } from '@ohos/common';
import lazy { PhotoAccessUtil } from '@ohos/common/indexLazyLoad';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { common } from '@kit.AbilityKit';

const TAG: string = 'PhotoAccessUtilTest';

export default function PhotoAccessUtilTest() {

  describe('PhotoAccessUtilTest', () => {

    it('getNewUserAlbumByName_photosLock_true', 0, async (done: Function ) => {
      let data: QueryFileParam = new QueryFileParam();
      const result: FileInfo = await PhotoAccessUtil.getNewUserAlbumByName(data, '', true);
      expect(result.fileName).assertEqual('');
      done();
    });

    it('getFileIsExist_isTrashFile', 0, async (done: Function ) => {
      let context: common.Context = GlobalHolder.getInstance().getCommonContext();;
      const result: boolean = await PhotoAccessUtil.getFileIsExist('test', context, true);
      expect(result).assertFalse();
      done();
    });

    it('getFileIsExist_notTrashFile', 0, async (done: Function ) => {
      let context: common.Context = GlobalHolder.getInstance().getCommonContext();;
      const result: boolean = await PhotoAccessUtil.getFileIsExist('test', context, false);
      expect(result).assertFalse();
      done();
    });

    it('getPhotoInSourceAlbum_normal', 0, async (done: Function ) => {
      let context: common.Context = GlobalHolder.getInstance().getMainAbilityContext() ||
        GlobalHolder.getInstance().getUIExtensionContext() || GlobalHolder.getInstance().getExtensionContext();
      const result: FileInfo[] = await PhotoAccessUtil.getPhotoInSourceAlbum(context, '');
      expect(result.length).assertEqual(0);
      done();
    });

    it('getPhotoByUri_normal', 0, async (done: Function ) => {
      let context: common.Context = GlobalHolder.getInstance().getMainAbilityContext() ||
      GlobalHolder.getInstance().getUIExtensionContext() || GlobalHolder.getInstance().getExtensionContext();
      const result: FileInfo[] = await PhotoAccessUtil.getPhotoByUri(context, '', 0, 0, 0);
      expect(result.length).assertEqual(0);
      done();
    });

    it('movePhotoAssetsToAlbum_length_zero', 0, async (done: Function ) => {
      let context: common.Context = GlobalHolder.getInstance().getMainAbilityContext() ||
      GlobalHolder.getInstance().getUIExtensionContext() || GlobalHolder.getInstance().getExtensionContext();
      let srcAlbum: photoAccessHelper.Album | undefined =
        await PhotoAccessUtil.getAlbumByUri(context, '');
      if (!srcAlbum) {
        srcAlbum = {} as photoAccessHelper.Album;
      }
      const result: boolean = await PhotoAccessUtil.movePhotoAssetsToAlbum(context, [], srcAlbum, srcAlbum);
      expect(result).assertTrue();
      done();
    });

    it('movePhotoAssetsToAlbum_same_album', 0, async (done: Function ) => {
      let context: common.Context = GlobalHolder.getInstance().getMainAbilityContext() ||
      GlobalHolder.getInstance().getUIExtensionContext() || GlobalHolder.getInstance().getExtensionContext();
      let srcAlbum: photoAccessHelper.Album | undefined =
        await PhotoAccessUtil.getAlbumByUri(context, '');
      if (!srcAlbum) {
        srcAlbum = {} as photoAccessHelper.Album;
      }
      const result: boolean = await PhotoAccessUtil.movePhotoAssetsToAlbum(context,
        [{} as photoAccessHelper.PhotoAsset], srcAlbum, srcAlbum);
      expect(result).assertTrue();
      done();
    });

    it('getAlbumSize_normal', 0, async (done: Function ) => {
      let context: common.Context = GlobalHolder.getInstance().getMainAbilityContext() ||
      GlobalHolder.getInstance().getUIExtensionContext() || GlobalHolder.getInstance().getExtensionContext();
      const result: number = await PhotoAccessUtil.getAlbumSize(context, new FileInfo());
      expect(result).assertEqual(0);
      done();
    });

    it('getSysAlbums_dirUri_error', 0, async (done: Function ) => {
      const results: FileInfo[] = await PhotoAccessUtil.getSysAlbums({} as QueryFileParam, 'test', false);
      expect(results.length).assertEqual(0);
      done();
    });

    it('getSysAlbums_normal', 0, async (done: Function ) => {
      let params: QueryFileParam = new QueryFileParam();
      params.context = GlobalHolder.getInstance().getMainAbilityContext() ||
        GlobalHolder.getInstance().getUIExtensionContext() || GlobalHolder.getInstance().getExtensionContext();
      const results: FileInfo[] = await PhotoAccessUtil.getSysAlbums(params, VirtualUri.IMAGE, false);
      expect(results).not().assertUndefined();
      done();
    });

    it('getPhotoAlbums_dirUri_error', 0, async (done: Function ) => {
      let params: QueryFileParam = new QueryFileParam();
      params.context = GlobalHolder.getInstance().getMainAbilityContext() ||
      GlobalHolder.getInstance().getUIExtensionContext() || GlobalHolder.getInstance().getExtensionContext();
      const mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.error);
      await PhotoAccessUtil.getPhotoAlbums(params, '', false, false);
      mocker.verify('error', ['PhotoAccessUtil', 'getPhotoAlbums invalid dirUri']).once();
      mocker.clear(HiLog);
      done();
    });

    it('getNewUserAlbumByName_context_undefined', 0, async (done: Function ) => {
      let data: QueryFileParam = new QueryFileParam();
      const result: FileInfo = await PhotoAccessUtil.getNewUserAlbumByName(data, '');
      expect(result.fileName).assertEqual('');
      done();
    });

    it('getNewUserAlbumByName_fetchResult_empty', 0, async (done: Function ) => {
      let data: QueryFileParam = new QueryFileParam();
      data.context = GlobalHolder.getInstance().getMainAbilityContext() ||
      GlobalHolder.getInstance().getUIExtensionContext() || GlobalHolder.getInstance().getExtensionContext();
      const result: FileInfo = await PhotoAccessUtil.getNewUserAlbumByName(data, '');
      expect(result.fileName).assertEqual('');
      done();
    });

    it('getSysResourceParentAlbumName_not_has', 0, () => {
      let lPath = PhotoAccessUtil.getSysResourceParentAlbumName('');
      expect(lPath).assertEqual('');
    });

    it('getAllPhotoAlbums_dirUri_empty', 0, async (done: Function ) => {
      let params: QueryFileParam = new QueryFileParam();
      params.context = GlobalHolder.getInstance().getMainAbilityContext() ||
      GlobalHolder.getInstance().getUIExtensionContext() || GlobalHolder.getInstance().getExtensionContext();
      let fileList = await PhotoAccessUtil.getAllPhotoAlbums(params, '', false);
      expect(fileList.length === 0).assertTrue()
      done();
    });

    it('getAllPhotoAlbums_context_undefined', 0, async (done: Function ) => {
      let params: QueryFileParam = new QueryFileParam();
      let fileList = await PhotoAccessUtil.getAllPhotoAlbums(params, VirtualUri.GALLERY, false);
      expect(fileList.length === 0).assertTrue()
      done();
    });

    it('getPhotoIncremental_invalid_input', 0, async (done: Function ) => {
      let data: QueryFileParam = new QueryFileParam();
      const mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.error);
      await PhotoAccessUtil.getPhotoIncremental(data);
      mocker.verify('error', ['PhotoAccessUtil', 'invalid args']).once();
      mocker.clear(HiLog);
      done();
    });

    it('getSysResourceAlbumName_photoAlbum_null', 0, () => {
      let albums: photoAccessHelper.Album[] = [];
      albums.length = 1;
      expect(PhotoAccessUtil.getSysResourceAlbumName(albums[0], '', undefined)).assertEqual('');
    });

    it('getSysResourceAlbumName_photoAlbum_system', 0, () => {
      const album = {
        albumUri: '',
        albumType: photoAccessHelper.AlbumType.SYSTEM
      } as photoAccessHelper.Album;
      expect(PhotoAccessUtil.getSysResourceAlbumName(album, '', undefined)).assertEqual('');
    });

    it('getSysResourceAlbumName_photoAlbum_source_generic', 0, () => {
      const album = {
        albumUri: '',
        albumSubtype: photoAccessHelper.AlbumSubtype.SOURCE_GENERIC,
        lpath: Constant.PHOTO_ALBUM_LPATH.LPATH_CAMERA
      } as photoAccessHelper.Album;
      expect(PhotoAccessUtil.getSysResourceAlbumName(album, '', undefined)).assertEqual('');
    });

    it('renameAlbum_not_exist', 0, async (done: Function) => {
      const context = GlobalHolder.getInstance().getCommonContext();
      const timestamp: string = Date.now().toString();
      const albumUri: string = VirtualUri.GALLERY_URI + '/' + timestamp;
      let result: string = await PhotoAccessUtil.renameAlbum(context, albumUri, 'test');
      expect(result).assertEqual('');
      done();
    });

    it('renameAlbum_albumType_not_user', 0, async (done: Function) => {
      const context = GlobalHolder.getInstance().getCommonContext();
      const tempAlbumUri: string = 'file://media/PhotoAlbum/111';
      const mocker = new MockKit();
      const mockFunction = mocker.mockFunc(PhotoAccessUtil, PhotoAccessUtil.getAllAlbums);
      const album = {
        albumUri: tempAlbumUri,
        albumType: photoAccessHelper.AlbumType.SYSTEM
      } as photoAccessHelper.Album;
      let albumList: photoAccessHelper.Album[] = [album];
      when(mockFunction)(ArgumentMatchers.any).afterReturn(albumList);
      let result: string = await PhotoAccessUtil.renameAlbum(context, tempAlbumUri, 'test');
      expect(result).assertEqual('');
      mocker.clear(PhotoAccessUtil);
      done();
    });

    it('renameAlbum_albumName_already_exist', 0, async (done: Function) => {
      const context = GlobalHolder.getInstance().getCommonContext();
      const tempAlbumUri: string = 'file://media/PhotoAlbum/111';
      const mocker = new MockKit();
      const mockFunction = mocker.mockFunc(PhotoAccessUtil, PhotoAccessUtil.getAllAlbums);
      const album = {
        albumName: 'test',
        albumUri: tempAlbumUri,
        albumType: photoAccessHelper.AlbumType.USER
      } as photoAccessHelper.Album;
      let albumList: photoAccessHelper.Album[] = [album];
      when(mockFunction)(ArgumentMatchers.any).afterReturn(albumList);
      try {
        await PhotoAccessUtil.renameAlbum(context, tempAlbumUri, 'test');
      } catch (e) {
        expect(e?.code).assertEqual(ERROR_CODE.FILE_ACCESS.FILE_EXISTS);
      } finally {
        mocker.clear(PhotoAccessUtil);
      }
      done();
    });

    it('renameAlbum_phAccessHelper_undefined', 0, async (done: Function) => {
      const context = GlobalHolder.getInstance().getCommonContext();
      const tempAlbumUri: string = 'file://media/PhotoAlbum/111';
      const mocker = new MockKit();
      const mockFunction = mocker.mockFunc(PhotoAccessUtil, PhotoAccessUtil.getAllAlbums);
      const album = {
        albumName: 'test_album',
        albumUri: tempAlbumUri,
        albumType: photoAccessHelper.AlbumType.USER
      } as photoAccessHelper.Album;
      let albumList: photoAccessHelper.Album[] = [album];
      when(mockFunction)(ArgumentMatchers.any).afterReturn(albumList);
      const mockFunction2 = mocker.mockFunc(PhotoAccessUtil, PhotoAccessUtil.getAccessHelper);
      when(mockFunction2)(ArgumentMatchers.any).afterReturn(undefined);
      const result = await PhotoAccessUtil.renameAlbum(context, tempAlbumUri, 'test');
      expect(result).assertEqual('');
      mocker.clear(PhotoAccessUtil);
      done();
    });
  });
}
