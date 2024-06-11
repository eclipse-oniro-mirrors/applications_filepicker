/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import userFileManager from '@ohos.filemanagement.userFileManager';

import { Logger } from '../../common/util/HiLogger'
import { LocalAudioFile } from './LocalAudioFile'

const logger: Logger = new Logger('LocalAudioManager')

/**
 * 对接媒体库/文件系统，提供本地音频查询能力，本地音频分页查询能力
 */
export class LocalAudioManager {
  public fileAssets: Array<userFileManager.FileAsset> = []

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
    let localAudioFile: Array<LocalAudioFile> = []
    return new Promise(async (resolve) => {
      if (this.fileAssets) {
        logger.info('fileAsset.length :' + this.fileAssets.length);
        for (let fileAsset of this.fileAssets) {
          let uri = fileAsset.uri || ''
          let name = fileAsset.get(userFileManager.AudioKey.TITLE.toString()).toString() || fileAsset.displayName
          let artist = fileAsset.get(userFileManager.AudioKey.ARTIST.toString()).toString() || ''
          let album = fileAsset.get(userFileManager.AudioKey.AUDIOALBUM.toString()).toString() || ''
          if (uri) {
            let localAudioFileItem: LocalAudioFile = new LocalAudioFile(uri, name, artist, album)
            localAudioFile.push(localAudioFileItem)
          } else {
            logger.error('transferFileAssetsToLocalAudioFiles failed!')
          }
        }
      }
      resolve(localAudioFile)
    })
  }

  getFileAsset(index: number) {
    return this.fileAssets[index]
  }
}