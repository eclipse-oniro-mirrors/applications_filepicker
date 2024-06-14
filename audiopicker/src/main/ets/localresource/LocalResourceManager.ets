/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import wantConstant from '@ohos.app.ability.wantConstant';
import userFileManager from '@ohos.filemanagement.userFileManager';
import fileShare from '@ohos.fileshare';
import { BusinessError } from '@ohos.base';
import { Context } from '@kit.AbilityKit';

import { Logger } from '../common/util/HiLogger'
import { LocalAudioFile } from './localaudio/LocalAudioFile'
import { LocalAudioManager } from './localaudio/LocalAudioManager'
import { Constants } from '../constant/Constants';

const logger: Logger = new Logger('LocalResourceManager')

export class LocalResourceManager {

  /**
   * 本地歌曲资源管理类 todo 改全局注册
   */
  public localAudioManager: LocalAudioManager = new LocalAudioManager()

  public getLocalAudioResource(offset: number, limit: number, context: Context): Promise<Array<LocalAudioFile>> {
    return this.localAudioManager.getLocalAudio(offset, limit, context)
  }

  /**
   * 用户选择文件后，返回结果URI列表并赋予临时权限
   */
  public terminateSelfWithResult(localAudioFile: Array<LocalAudioFile>): Promise<Array<string>> {
    //赋予权限就放在audiopicker模块，直接调系统接口
    return new Promise(async (resolve) => {
      let uriList: string[] = []
      for(let item of localAudioFile) {
        try {
          await fileShare.grantUriPermission(item.uri, Constants.AUDIO_PICKER_BUNDLE, wantConstant
            .Flags.FLAG_AUTH_READ_URI_PERMISSION | wantConstant.Flags.FLAG_AUTH_WRITE_URI_PERMISSION)
          uriList.push(item.uri)
          logger.info('push uriList length: ' + uriList.length)
        } catch (err) {
          let error: BusinessError = err as BusinessError;
          logger.error('grantUriPermission failed with error:' + JSON.stringify(error));
          resolve([])
          return
        }
      }
      logger.info('Permission uriList length: ' + uriList.length)
      resolve(uriList)
    })
  }
}
