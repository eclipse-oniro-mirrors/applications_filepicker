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
import {
  Constant,
  EventBus,
  HiLog,
  StringUtil,
  GlobalHolder,
  GlobalKey,
  CheckIsForbiddenUriTask,
  TaskManager,
  toast
} from '@ohos/common';
import lazy { PasteBoardManager } from '@ohos/common';
import { EventConst } from './const/EventConst';
import { JumpPageData, OpenFolderData, SendData } from './model/SendDataModel';
import { display } from '@kit.ArkUI';
import { CopyCutManager } from '../manager/CopyCutManager';

const TAG = 'ReceiveEventUtil';

export class ReceiveEventUtil {
  /**
   * 接受并处理来自宿主应用的事件
   * @param receiveData 接收到的事件信息
   */
  public static receiveEventFromHostApp(receiveData: Record<string, Object>): void {
    const sendData = receiveData.data as SendData;
    HiLog.info(TAG, `receiveEventFromHostApp event: ${sendData?.event}`);
    switch (sendData.event) {
    // 页面跳转
      case EventConst.JUMP_PAGE:
        const pageData = sendData.data as JumpPageData;
        if (StringUtil.isEmpty(pageData.pageName)) {
          HiLog.warn(TAG, 'JumpPage fail, pageName is empty');
          return;
        }
        // 进行页面跳转，暂无场景，后续需要时再追加处理逻辑
        break;
      // 打开指定目录
      case EventConst.OPEN_FOLDER:
        const param = sendData.data as OpenFolderData;
        // 非通知中心拉起文管情况下，打开文管所在文件夹，不读剪贴板
        if (param.from !== Constant.FROM_TYPE.COPY_CUT_NOTIFICATION) {
          PasteBoardManager.getInstance().setWhetherToReadPasteBoard(false);
        }
        let task: CheckIsForbiddenUriTask =
          new CheckIsForbiddenUriTask(param.folderUri, true, (isForbiddenUri: boolean) => {
            HiLog.info(TAG, `CheckIsForbiddenUriTask result: ${isForbiddenUri}`);
            let fileUri: string = Constant.MY_PHONE_URI;
            if (isForbiddenUri) {
              // toast提示路径不存在，加延时避免文管冷启动提示空白
              let timeoutBox = setTimeout(() => {
                toast($r('app.string.path_not_exist'));
                clearTimeout(timeoutBox);
              }, Constant.TIMER_TIME.TIMER_100);
            } else {
              fileUri = param.folderUri;
            }
            HiLog.infoPrivate(TAG, 'start set target uri: ', `${fileUri}`);
            GlobalHolder.getInstance().setObject<string>(GlobalKey.FROM, param.from);
            GlobalHolder.getInstance().setObject<string>(GlobalKey.URI_PATH, fileUri);
            // 接收用与多文件跳转和高亮的文件uri列表
            GlobalHolder.getInstance().setObject<string[]>(GlobalKey.FILE_URI_ARRAY, param.fileUriArray ?? []);
            EventBus.emit(Constant.EVENTS.FILE_MANAGER_ON_NEW_WANT);
          });
        TaskManager.getInstance().execute<number>(task, 1, false, 30);
        HiLog.info(TAG, 'CheckIsForbiddenUriTask start');
        break;
      case EventConst.KEYBOARD_HEIGHT_CHANGE:
        const keyboardHeight = sendData.data as number;
        AppStorage.setOrCreate<number>('keyBoardHeight', keyboardHeight);
        break;
      case EventConst.WINDOW_STATUS_CHANGE:
        const windowStatusChange = sendData.data as number;
        AppStorage.setOrCreate<number>('windowStatus', windowStatusChange);
        break;
      case EventConst.CAMERA_AVOID_AREA:
        const cameraAvoidArea = JSON.parse(sendData.data as string) as display.CutoutInfo;
        HiLog.info(TAG, `CAMERA_AVOID_AREA cameraAvoidArea ${JSON.stringify(cameraAvoidArea.boundingRects[0])}`)
        AppStorage.setOrCreate<display.CutoutInfo>('cameraArea', cameraAvoidArea);
        break;
      case EventConst.FOLD_DEVICE_STATUS:
        const status = JSON.parse(sendData.data as string) as object;
        AppStorage.setOrCreate<number>(EventConst.FOLD_DEVICE_STATUS, status['status']);
        break;
      case EventConst.DISPLAY_INFO:
        const displayInfo = JSON.parse(sendData.data as string) as object;
        AppStorage.setOrCreate<string>(EventConst.DISPLAY_INFO, JSON.stringify(displayInfo['status']));
        break;
      case EventConst.WINDOW_STAGE_EVENT:
        const data = sendData.data as number;
        EventBus.emit(Constant.EVENTS.WINDOW_STAGE_EVENT, data);
        break;
      case EventConst.CANCEL_COPY_CUT:
        CopyCutManager.getInstance()?.cancelWorker();
        break;
      default:
        HiLog.warn(TAG, 'unknown event:' + sendData.event);
        break;
    }
    HiLog.info(TAG, `receiveEventFromHostApp success`);
  }
}