/*
 * Copyright (c) 2021-2024 Huawei Device Co., Ltd.
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
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import userFileManager from '@ohos.filemanagement.userFileManager';
import image from '@ohos.multimedia.image';

import { Logger } from '../../common/util/HiLogger'
import { LocalAudioFile } from './LocalAudioFile'

const logger: Logger = new Logger('LocalAudioManager')

/**
 * 对接媒体库/文件系统，提供本地音频查询能力，本地音频分页查询能力
 */
export class LocalAudioManager {
  private fileAssets: Array<userFileManager.FileAsset> = []

  /**
   * 获取FetchResult<FileAsset>
   */
  getLocalAudio(offset: number, limit: number, context: Context): Promise<Array<LocalAudioFile>> {
    logger.info('getAudioAssets');
    let mgr = userFileManager.getUserFileMgr(context);
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    let fetchOptions: userFileManager.FetchOptions = {
      fetchColumns: [
        userFileManager.AudioKey.TITLE.toString(),
        userFileManager.AudioKey.ARTIST.toString(),
        userFileManager.AudioKey.AUDIOALBUM.toString()
      ],
      predicates: predicates.limit(limit, offset)
    };

    return new Promise(async (resolve) => {
      try {
        let fetchResult: userFileManager.FetchResult<userFileManager.FileAsset> = await mgr
          .getAudioAssets(fetchOptions);
        if (fetchResult) {
          logger.info('fetchFileResult success' + JSON.stringify(fetchResult));
          this.fileAssets = await fetchResult.getAllObject();
          if (this.fileAssets && this.fileAssets.length > 0) {
            let localAudioFile = await this.transferFileAssetsToLocalAudioFiles()
            logger.info('localAudioFile length: ' + (await localAudioFile).length)
            resolve(localAudioFile)
          } else {
            logger.error('fileAssets is null')
            resolve([])
          }
        }
      } catch (err) {
        logger.error('getAudioAssets failed, message = ' + err);
        resolve([])
      }
    })
  }

  /**
   * 将FileAsset转换为LocalAudioFile
   */
  transferFileAssetsToLocalAudioFiles(): Promise<Array<LocalAudioFile>> {
    let localAudioFile: LocalAudioFile[] = []
    return new Promise(async (resolve) => {
      if (this.fileAssets) {
        logger.info('fileAsset.length :' + this.fileAssets.length);
        for (let fileAsset of this.fileAssets) {
          let uri = fileAsset.uri || ''
          let name = fileAsset.get(userFileManager.AudioKey.TITLE.toString()).toString() || fileAsset.displayName
          let artist = fileAsset.get(userFileManager.AudioKey.ARTIST.toString()).toString() || ''
          let album = fileAsset.get(userFileManager.AudioKey.AUDIOALBUM.toString()).toString() || ''
          let displayName = fileAsset.displayName
          let getThumbnail: image.PixelMap | Resource
          try {
            getThumbnail = await fileAsset.getThumbnail()
          } catch (err) {
            getThumbnail = $r('app.media.default')
            logger.error('transferGetThumbnail failed: ' + err)
          }
          if (uri) {
            let localAudioFileItem: LocalAudioFile = new LocalAudioFile(uri, name, artist, album,
              displayName, getThumbnail)
            localAudioFile.push(localAudioFileItem)
            logger.info(`localAudioFileItem: uri: ${uri}, name: ${name}, artist: ${artist}, album: ${album}, getThumbnail: ${JSON.stringify(getThumbnail)}}`)
          } else {
            logger.error('transferFileAssetsToLocalAudioFiles failed!')
          }
        }
      }
      resolve(localAudioFile)
    })
  }
}