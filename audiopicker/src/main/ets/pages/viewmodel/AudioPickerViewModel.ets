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

import { Logger } from '../../common/util/HiLogger'
import { ObservedArray } from '../../data/ObservedArray'
import { AbsBaseViewModel } from '../../basemvvm/AbsBaseViewModel'
import { BaseState, ViewState } from '../../basemvvm/ViewState'
import { AudioPickerViewData } from '../model/AudioPickerViewData'
import { LocalResourceManager } from '../../localresource/LocalResourceManager'
import { Constants } from '../../constant/Constants'
import { LocalAudioFile } from '../../localresource/localaudio/LocalAudioFile'

const logger: Logger = new Logger('AudioPickerViewModel')

/**
 * [audioPicker页面 viewmodel]
 */
export class AudioPickerViewModel extends AbsBaseViewModel<LocalAudioFile> {
  // 页面待观察的数据
  private audioPickerViewData: AudioPickerViewData = new AudioPickerViewData()
  private localResourceManager: LocalResourceManager = new LocalResourceManager();
  public audioTotal: number = 0

  constructor() {
    super()
  }

  /**
   * 获取当前页面的可见性
   * @returns
   */
  public getState(): ViewState {
    return this.audioPickerViewData.getState()
  }


  /**
   * 获取当前页面的音频列表
   * @returns
   */
  protected getData(): ObservedArray<LocalAudioFile> {
    return this.audioPickerViewData.getDataList()
  }

  /**
   * 获取列表中音频总数
   * @returns
   */
  public getAudioTotal(): number {
    return this.audioPickerViewData.totalCount()
  }

  /**
   * 查询音频详情基类，子类需要重载
   * @returns
   */
  public queryAudioPickerList(pageNo: number, context: Context): Promise<boolean> {
    return new Promise<boolean>((resolve) => {
      try {
        this.localResourceManager.getLocalAudioResource(pageNo * Constants.PICKER_PAGE_SIZE,
          Constants.PICKER_PAGE_SIZE, context).then((value) => {
          this.audioPickerViewData.append(value)
          this.audioTotal = value.length
          logger.info(`queryAudioPickerList: ${JSON.stringify(value.length)}`)
          resolve(true)
        })
      } catch (err) {
        logger.error(`localAudioFile error: ${JSON.stringify(err)}`)
        this.getState().setViewState(BaseState.ERROR)
        resolve(false)
      }
    })
  }

  /**
   * 加载更多
   */
  public loadMore(pageNo: number, context: Context): Promise<boolean> {
    return new Promise((resolve) => {
      logger.info('loadMoreAudioPicker')
      if (!this.audioPickerViewData.hasMoreData) {
        resolve(false)
        return
      }
      let pageNum = pageNo + 1
      this.queryAudioPickerList(pageNum, context).then((isSuccess: boolean) => {
        logger.info(`loadMoreMusic: ${isSuccess}`)
        if (isSuccess) {
          resolve(true)
        } else {
          resolve(false)
        }
      })
    })
  }

  /**
   * 获取lazyforeach的数据源
   * @returns
   */
  public getDataSource(): AudioPickerViewData {
    return this.audioPickerViewData
  }
}