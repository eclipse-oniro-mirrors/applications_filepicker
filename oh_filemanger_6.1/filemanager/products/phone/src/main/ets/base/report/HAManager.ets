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

import { AppConfig, DeviceInfoUtil, HiLog, ObjectUtil } from '@ohos/common';

const TAG = 'HAManager';

/**
 * 事件上报类型
 */
export class EventType {

  /**
   * 运营事件
   */
  public static readonly OPERATION: number = 0;

  /**
   * 运维事件
   */
  public static readonly MAINTENANCE: number = 1;

}

class HaCommonProperty {
  /**
   * 用户id key值
   */
  public static readonly KEY_USERID: string = 'userID';

  /**
   * 设备ID key值
   */
  public static readonly KEY_DEVICE_ID: string = 'deviceID';

  /**
   * 设备UUID key值
   */
  public static readonly KEY_DEVICE_UUID: string = 'deviceUUID';

  /**
   * rom版本 key值
   */
  public static readonly KEY_ROM_VERSION: string = 'romVersion';

  /**
   * app版本 key值
   */
  public static readonly KEY_APP_VERSION: string = 'appVersion';

  /**
   * osBrand key值
   */
  public static readonly KEY_OS_BRAND: string = 'osBrand';

  /**
   * appBrandId key值
   */
  public static readonly KEY_APP_BRAND_ID: string = 'APP_BRAND_ID';
}

/**
 * 打点管理类
 */
export class HaManager {
  /**
   * 当前应用初始化分析配置时的唯一Tag名称
   * 业务自行定义，建议携带业务名称相关元素，便于识别
   */
  private readonly instanceTag = 'FileManagerHA';

  /**
   * 业务在云侧的appId，不填则默认为bundleName
   */
  private readonly appId = AppConfig.APP_PACKAGE_NAME;

  /**
   * 表示需要上报的channel名称
   */
  private readonly channelId = 'systemHap';

  /**
   * 初始化结果 标志
   */
  private isInit: boolean = false;

  private static instance: HaManager = new HaManager();

  private constructor() {

  }

  static getInstance(): HaManager {
    if (!HaManager.instance) {
      HaManager.instance = new HaManager();
    }
    return HaManager.instance;
  }

  /**
   * 运营打点
   * @param eventId 打点Id
   * @param param 附加参数
   * @returns 打点SDK调用结果
   */
  public async biReport(eventId: string, param: Record<string, string>): Promise<void> {
    this.onReport(EventType.OPERATION, eventId, param);
  }

  /**
   * 运维打点
   * @param eventId 打点Id
   * @param param 附加参数
   * @returns 打点SDK调用结果
   */
  public async omReport(eventId: string, param: Record<string, string>): Promise<void> {
    return this.onReport(EventType.MAINTENANCE, eventId, param);
  }

  /**
   * 通用打点上报接口
   * @param eventType 事件类型
   * @param eventId 事件id
   * @param param  事件参数
   * @returns HASDK 调用结果
   */
  private async onReport(eventType: number, eventId: string, param?: Record<string, string>): Promise<void> {
    let isReport = await this.isReport();
    if (!isReport) { //是否需要存储数据，等可以上报后完成后提交，但需要对公共信息的时间戳等做特殊处理
      HiLog.warn(TAG, `report  err eventType =${eventType} isReport = ${isReport} `);
      return;
    }
    if (ObjectUtil.isNullOrUndefined(eventId)) {
      HiLog.warn(TAG, 'report  report.eventId isNullOrUndefined ');
      return;
    }
    param = param ?? {};
  }

  /**
   * 是否可以打点
   * 目前判断是否初始化,方便加入是否用户登录，协议是否同意等条件
   */
  private async isReport(): Promise<boolean> {
    return this.isInit;
  }

  /**
   * 用于指定清空缓存数据的tag归属
   * 0008000 Invalid input parameter 接口入参错误，请结合上述接口参数说明排查
   * 10008001  No config found please call setConfigOptions function first.onEvent()或clearCachedData()接口调用前，
   * 未调用或错误调用setConfigOptions()接口
   * 10008002 System internal error.系统内部错误，调测阶段可能会发生
   * 10008004  SQL executed failed. 数据库操作错误，调测期间可能会出现，初始化数据库或读写数据异常，
   * 10008005  No permission to call hianalytics system api.
   */
  public async clearCachedData(): Promise<boolean> {
    if (!this.isInit) {
      HiLog.warn(TAG, 'clearCachedData  err this.isInit ' + this.isInit);
      return false;
    }
    return false;
  }

  /**
   * 对于SA已经采集的公共属性，强烈建议业务不再采集！！！
   * "eventtime":1691831304489,  打点时间戳(毫秒级)
   * "_package_name":"com.example.hademo_hmos10", 业务应用包名(bundleName
   * "_app_ver":"1.0.0", 业务应用版本号
   * "_device_type":"phone", 设备类型
   *  "_model":"NOH-AN00", 设备型号
   * "_net_type":"WIFI", 当前网络类型
   * "_os_ver":"OpenHarmony-4.0.10.2(Beta2)", 系统版本号
   */
  generateCommonProperty(): Record<string, string> | undefined {
    let reqObject = new Map<string, string>();
    try {
      // deviceId 设备ID
      reqObject[HaCommonProperty.KEY_DEVICE_ID] = DeviceInfoUtil.getDeviceId();
      // romVersion 当前设备的版本号
      reqObject[HaCommonProperty.KEY_ROM_VERSION] = DeviceInfoUtil.getRomVersion();
      reqObject[HaCommonProperty.KEY_APP_VERSION] = AppConfig.APP_VERSION;

    } catch (err) {
      HiLog.error(TAG, `generateCommonProperty err: ${err}`);
      return undefined;
    }
    const resultRecord: Record<string, string> = {} as Record<string, string>;
    reqObject.forEach((value, key) => {
      resultRecord[key] = value;
    })
    return resultRecord;
  }
}
