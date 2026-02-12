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

import hiSysEvent from '@ohos.hiSysEvent';
import type { BusinessError } from '@ohos.base';
import { BottomTabNumber, SELECT_MODE } from '../const/Constant';
import { HiLog } from './HiLog';
import { StartModeOptions } from '../model/StartModeOptions';
import type { GroupAndSortParam } from '../filesort/GroupAndSortParam';
import {
  AbilityName,
  FileBackupOperateType,
  FileBackupScenario,
  FileSize,
  HiSysEventName,
  InterfaceName,
  ModificationDate,
  OperateFrom,
  OperateName,
  OperateResult,
  OperateType,
  PathLocation,
} from '../const/HiSysEventConst';
import { FileView } from '../const/FolderRecord';
import { DFX } from './const/DFXConst';

const TAG = 'HiSysEventUtil';

export class HiSysEventUtil {
  /**
   * 上报故障事件
   * @param eventName 事件名称
   * @param interfaceName 接口/方法名称
   * @param errorCode 错误码
   */
  public static reportFailureEvent(eventName: HiSysEventName, interfaceName: InterfaceName, errorCode: number): void {
    const params: object = {
      INTERFACE_NAME: interfaceName,
      ERROR_CODE: errorCode
    };
    HiSysEventUtil.reportEvent(eventName, params, hiSysEvent.EventType.FAULT);
  }

  /**
   * 上报文件分组排序方式改变
   * @param oldGroupAndSortParam 旧分组排序参数
   * @param newGroupAndSortParam 新分组排序参数
   * @param abilityName 实例名称
   */
  public static reportFileGroupAndSortParamChange(oldGroupAndSortParam: GroupAndSortParam,
    newGroupAndSortParam: GroupAndSortParam, abilityName: AbilityName): void {
    let params: object = {
      OLD_GROUP_TYPE: oldGroupAndSortParam.fileGroupType,
      OLD_GROUP_ORDER: oldGroupAndSortParam.fileGroupOrder,
      OLD_SORT_TYPE: oldGroupAndSortParam.fileSortType,
      OLD_SORT_ORDER: oldGroupAndSortParam.fileSortOrder,
      NEW_GROUP_TYPE: newGroupAndSortParam.fileGroupType,
      NEW_GROUP_ORDER: newGroupAndSortParam.fileGroupOrder,
      NEW_SORT_TYPE: newGroupAndSortParam.fileSortType,
      NEW_SORT_ORDER: newGroupAndSortParam.fileSortOrder,
      ABILITY_NAME: abilityName
    };
    HiSysEventUtil.reportEvent(HiSysEventName.FILE_GROUP_SORT_TYPE_CHANGE, params);
  }

  /**
   * 上报文件视图改变
   * @param current 当前视图
   * @param switchTo 新切换的视图
   * @param abilityName
   */
  public static reportFileViewChange(current: FileView | string, switchTo: FileView | string,
    abilityName: AbilityName): void {
    let params: object = {
      CURRENT: current,
      SWITCH_TO: switchTo,
      ABILITY_NAME: abilityName
    };
    HiSysEventUtil.reportEvent(HiSysEventName.FILE_VIEW_CHANGE, params);
  }

  /**
   * 上报主页Tab点击事件
   * @param position 点击位置
   */
  public static reportBottomTabClick(position: BottomTabNumber): void {
    let params: object = {
      POSITION: position
    };
    HiSysEventUtil.reportEvent(HiSysEventName.BOTTOM_TAB_CLICK, params);
  }

  /**
   * 上报拉起file_picker窗口文件统计信息
   * @param abilityName 实例名称
   * @param instancesNum 实例数量
   * @param callSource 实例拉起来源,拉起方包名
   */
  public static reportCreateAbility(abilityName: AbilityName, instancesNum: number, callSource: string = ''): void {
    let params: object = {
      ABILITY_NAME: abilityName,
      INSTANCES_NUM: instancesNum,
      CALL_SOURCE: callSource
    };
    HiSysEventUtil.reportEvent(HiSysEventName.CREATE_ABILITY, params);
  }

  /**
   * 选择picker记录选中文件数
   * @param mode 选择模式
   * @param instancesNum 实例数量
   * @param callSource 实例拉起来源,拉起方包名
   */
  public static reportFilePickerSelectAbility(selectedMode: SELECT_MODE, selectedNum: number,
    callSource: string = ''): void {
    let params: object = {
      SELECT_MODE: selectedMode,
      SELECTED_NUM: selectedNum,
      CALL_SOURCE: callSource
    };
    HiSysEventUtil.reportEvent(HiSysEventName.OPEN_FILE_PICKER, params);
  }

  /**
   * 上报文件操作信息
   * @param operateName 操作名称
   * @param operateObject 操作对象
   * @param operateResult 操作结果
   */
  public static reportFileOperation(operateName: OperateName, operateObject: string, result: OperateResult): void {
    let storage: LocalStorage | undefined;
    try {
      storage = LocalStorage.getShared();
    } catch (err) {
      HiLog.error(TAG, 'LocalStorage getShared error: ' + JSON.stringify(err.message));
    }
    if (!storage) {
      return;
    }
    let params: object = {
      OPERATE_NAME: operateName,
      OPERATE_FROM: storage.has('InputDevice') ? storage.get<OperateFrom>('InputDevice') : OperateFrom.OTHER,
      OPERATE_OBJECT: operateObject,
      ABILITY_NAME: storage.has('startModeOption') &&
      storage.get<StartModeOptions>('startModeOptions')?.isFilePickerMode() ? AbilityName.FILE_PICKER :
      AbilityName.FILE_MANAGER,
      OPERATE_RESULT: result
    };
    HiSysEventUtil.reportEvent(HiSysEventName.FILE_OPERATION, params);
  }

  /**
   * 上报外接存储设备获取文件时延
   * @param timeCost 时延
   * @param fileCount 文件数量
   */
  public static reportExternalGetFileCost(timeCost: number, fileCount: number): void {
    let params: object = {
      GET_TIME: timeCost,
      FILE_COUNT: fileCount
    };
    HiSysEventUtil.reportEvent(HiSysEventName.EXTERNAL_GET_FILE_COST, params, hiSysEvent.EventType.STATISTIC);
  }

  /**
   * 上报文件备份恢复操作
   * @param scenario 场景
   * @param operateType 操作类型
   * @param result 操作结果
   * @param costTime 操作耗时
   */
  public static reportFileBackupOperation(scenario: FileBackupScenario, operateType: FileBackupOperateType,
    result: OperateResult, costTime: number = 0): void {
    const params: object = {
      OPERATE_SCENARIO: scenario,
      OPERATE_TYPE: operateType,
      OPERATE_RESULT: result,
      COST_TIME: costTime
    };
    HiSysEventUtil.reportEvent(HiSysEventName.FILE_BACKUP, params, hiSysEvent.EventType.BEHAVIOR);
  }

  /**
   * 上报文件备份恢复耗时
   * @param scenario 场景
   * @param operateType 操作类型
   * @param costTime 操作耗时
   */

  /**
   * 上报拉起其他应用
   *
   * @param appName 应用名称
   * @param sourcePath 用户拉起路径
   * @param targetPath 用户目的路径
   * @param isSuccess  是否正常拉起
   * @param errorCode  错误码
   */
  public static reportOpenOtherApp(
    appName: string, sourcePath: string, targetPath: string, isSuccess: boolean, errorCode: number = -1): void {
    const params = {
      APP_NAME: appName,
      OPEN_SOURCE_PATH: sourcePath,
      OPEN_TYPE: '',
      SHOW_TYPE: '',
      OPEN_TARGET_PATH: targetPath,
      IS_SUCCESS: isSuccess,
      ERROR_CODE: errorCode
    };
    HiSysEventUtil.reportEvent(HiSysEventName.OPEN_OTHER_APP, params, hiSysEvent.EventType.BEHAVIOR);
  }

  /**
   * 创建下载目录
   * @param bundleName
   */
  public static reportCreateDownloadFolder(bundleName: string): void {
    let params: object = { BUNDLE_NAME: bundleName };
    HiSysEventUtil.reportEvent(HiSysEventName.CREATE_DOWNLOAD_FOLDER, params, hiSysEvent.EventType.STATISTIC);
  }

  public static reportEvent(name: string, params: object, eventType?: hiSysEvent.EventType,
    domain: string = DFX.DOMAIN_DFT): void {
    HiLog.info(TAG, `reportEvent name: ${name}, params: ${JSON.stringify(params)}, eventType: ${eventType}`);
    hiSysEvent.write({
      domain,
      name,
      eventType: eventType ? eventType : hiSysEvent.EventType.BEHAVIOR,
      params
    })
      .then((val) => {
        HiLog.info(TAG, `name: ${name} sucess`);
      })
      .catch((err: BusinessError) => {
        HiLog.info(TAG, `reportEvent failed, name: ${name}, error:${err}`);
      });
  }
}

