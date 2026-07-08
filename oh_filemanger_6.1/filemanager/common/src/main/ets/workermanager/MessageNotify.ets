/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import { CheckedFileObj } from './CheckedFileObj';
import type { ProgressInfo } from './ProgressInfo';
import { TransferringModel } from '../fileoperate/TransferringModel';
import WorkerConst from '../worker/WorkerConst';
import type { PasteResult } from './copycutmanager/PasteResult';
import { GlobalHolder } from '../global/GlobalHolder';
import type ctx from '@ohos.app.ability.common';
import Base, { BusinessError } from '@ohos.base';
import CommonEventManager from '@ohos.commonEventManager';
import { Constant } from '../const/Constant';
import { FavoriteDbManager } from '../favorite/FavoriteDbManager';
import { EventBus } from '../utils/EventBus';
import { TraceUtils } from '../dfx/TraceUtils';
import { HiTraceConst } from '../const/HiTraceConst';
import { PasteBoardUtil } from '../pasteboard/PasteBoardUtil';
import { ThreadCommonUtil } from '../workeroperate/fs/ThreadCommonUtil';
import { GlobalKey } from '../global/GlobalKey';
import { FavoriteModel } from '../model/FavoriteModel';
import { ObjectUtil } from '../utils/ObjectUtil';

const TAG = 'MessageNotify';

export class MessageNotify {

  public static padUpdateProgress(progressInfo: ProgressInfo): void {
    const storage: LocalStorage = LocalStorage.getShared();
    if (ObjectUtil.isNullOrUndefined(storage)) {
      HiLog.info(TAG, 'padUpdateProgress local storage undefined');
      return;
    }
    if (storage.has('progressInfos')) {
      HiLog.info(TAG, 'update progressInfos');
      let progressInfos: ProgressInfo[] = storage.get<ProgressInfo[]>('progressInfos') ?? [];
      let isAddNewProgressBar: boolean = MessageNotify.ifNeedAddProgressBar(progressInfo, progressInfos);
      if (isAddNewProgressBar) {
        HiLog.info(TAG, 'add new progressInfo: ' + progressInfo.workerName);
        progressInfos.push(progressInfo);
        storage.setOrCreate<number>('progressNewTipIndex', progressInfos.length - 1);
      }
      storage.setOrCreate<ProgressInfo[]>('progressInfos', progressInfos);
    } else {
      HiLog.info(TAG, 'create new progressInfos');
      storage.setOrCreate<ProgressInfo[]>('progressInfos', [progressInfo]);
    }
  }

  public static ifNeedAddProgressBar(progressInfo: ProgressInfo, progressInfos: ProgressInfo[]): boolean {
    let storage: LocalStorage = LocalStorage.getShared();
    let workerName = progressInfo.workerName;
    let isShowTip = progressInfo.isShowTip;
    // 更新已有进度条或增加新进度条
    let isAddNewProgressBar: boolean = true;
    for (let i = 0; i < progressInfos.length; i++) {
      if (progressInfos[i].workerName === workerName) {
        // 出现异常弹框
        if ((!progressInfos[i].isShowTip) && isShowTip) {
          storage.setOrCreate<number>('progressNewTipIndex', i);
        }
        progressInfos[i] = progressInfo;
        isAddNewProgressBar = false;
        break;
      }
    }
    return isAddNewProgressBar;
  }

  /**
   * 更新进度条
   * @param progressBarInfo 进度条实例
   */
  public static updateProgress(progressInfo: ProgressInfo): void {
    HiLog.infoPrivate(TAG, 'updateProgress: ', JSON.stringify(progressInfo));
    if (AppStorage.has('progressInfos')) {
      HiLog.info(TAG, 'update progressInfos');
      let workerName = progressInfo.workerName;
      let isShowTip = progressInfo.isShowTip;
      let progressInfos: ProgressInfo[] = AppStorage.get<ProgressInfo[]>('progressInfos') ?? [];
      // 更新已有进度条或增加新进度条
      let isAddNewProgressBar: boolean = true;
      for (let i = 0; i < progressInfos.length; i++) {
        if (progressInfos[i].workerName === workerName) {
          // 出现异常弹框
          if ((!progressInfos[i].isShowTip) && isShowTip) {
            AppStorage.setOrCreate<number>('progressNewTipIndex', i);
          }
          progressInfos[i] = progressInfo;
          isAddNewProgressBar = false;
          break;
        }
      }
      if (isAddNewProgressBar) {
        HiLog.info(TAG, 'add new progressInfo: ' + progressInfo.workerName);
        progressInfos.push(progressInfo);
        AppStorage.setOrCreate<number>('progressNewTipIndex', progressInfos.length - 1);
      }
      AppStorage.setOrCreate<ProgressInfo[]>('progressInfos', progressInfos);
    } else {
      HiLog.info(TAG, 'create new progressInfos');
      AppStorage.setOrCreate<ProgressInfo[]>('progressInfos', [progressInfo]);
    }
  }

  public static getTraceTaskType(operateType: WorkerConst.OperateType): HiTraceConst {
    let traceTaskType: HiTraceConst = HiTraceConst.COPY_FILE;
    if (operateType === WorkerConst.OperateType.CUT_FILE) {
      traceTaskType = HiTraceConst.CUT_FILE;
    } else if (operateType === WorkerConst.OperateType.DELETE_FILE) {
      traceTaskType = HiTraceConst.FORCE_DELETE;
    }
    return traceTaskType;
  }

  // 发送粘贴成功的文件到桌面
  public static sendCommonEventToDesktop(workerName: string, pasteSuccessFiles: string[] = []): void {
    if ((!workerName.includes(Constant.DESKTOP_TAG)) || (pasteSuccessFiles.length === 0)) {
      return;
    }

    HiLog.info(TAG, 'sendCommonEventToDesktop start');
    //公共事件相关信息
    let options: CommonEventManager.CommonEventPublishData = {
      bundleName: 'com.ohos.sceneboard',
      code: 0, // 公共事件的初始代码
      data: 'DeskTopPasteFileUri', // 公共事件的初始数据
      isOrdered: false, // 无序公共事件
      parameters: { pasteFileUri: pasteSuccessFiles }
    };

    CommonEventManager.publish('DeskTopPasteFileUri', options, (error: Base.BusinessError) => {
      if (error) {
        HiLog.error(TAG, `publish failed, code is ${error.code}, message is ${error.message}`);
        return;
      }
      HiLog.info(TAG, 'sendCommonEventToDesktop done.');
    });
  }

  private static updateProgressOnStop(workerName: string): void {
    if (!AppStorage.has('progressInfos')) {
      HiLog.error(TAG, 'Progress Infos is null.');
      return;
    }
    let progressInfos: ProgressInfo[] = AppStorage.get<ProgressInfo[]>('progressInfos') ?? [];
    let tempIndex = 0;

    for (let i = 0; i < progressInfos.length; i++) {
      if (progressInfos[i].workerName !== workerName) {
        progressInfos[tempIndex++] = progressInfos[i];
      }
    }
    HiLog.info(TAG, 'progressBarInfos Len: ' + progressInfos.length);
    progressInfos.length = tempIndex;
    if (progressInfos.length === 0) {
      AppStorage.delete('progressInfos');
      if (GlobalHolder.getInstance().hasObject(GlobalKey.DESKTOP_OPT_CONTEXT)) {
        // 不存在多线程文件操作任务时，关闭桌面文件操作服务
        let context =
          GlobalHolder.getInstance().getObject(GlobalKey.DESKTOP_OPT_CONTEXT) as ctx.ServiceExtensionContext;
        GlobalHolder.getInstance().deleteObject(GlobalKey.DESKTOP_OPT_CONTEXT);
        context.terminateSelf().then(() => {
          HiLog.warn(TAG, 'terminateSelf success');
        }).catch((err: BusinessError) => {
          HiLog.error(TAG, 'terminateSelf failed, err:' + err);
        });
      }
    } else {
      AppStorage.setOrCreate<ProgressInfo[]>('progressInfos', progressInfos);
    }
  }
}