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

import type { Reporter } from './Reporter';
import { HiLog } from '@ohos/common';
import { ReportConst } from '../const/ReportCont';
import { HaManager } from './HAManager';

const TAG = 'ReportUtils';

/**
 * 打点工具类，调用HAManager单例实现打点
 */
export class ReportUtils {
  private static readonly CLIENT_TYPE: string = '01';

  /**
   * 运维上报打点
   * @param report 上报实例
   * @param param 上报参数
   * @returns
   */
  public static async omReport(report: Reporter, param?: Record<string, string>): Promise<void> {
    param = ReportUtils.assignParam(report, param);
    HaManager.getInstance().omReport(report.eventId, param);
  }

  /**
   * 运营上报打点
   * @param report 上报实例
   * @param param 上报参数
   * @returns
   */
  public static async biReport(report: Reporter, param?: Record<string, string>): Promise<void> {
    param = ReportUtils.assignParam(report, param);
    HaManager.getInstance().biReport(report.eventId, param);
  }


  /**
   * 清除打点上报
   */
  public static async clearReport(): Promise<boolean> {
    return HaManager.getInstance().clearCachedData();
  }

  /**
   * 生成上报的额外信息
   * @param param 上报携带信息
   * @param report 上报实例
   * @returns 返回上报信息参数
   */
  private static assignParam(report: Reporter, param?: Record<string, string>): Record<string, string> {
    param = param ?? {};
    try {
      param[ReportConst.reportKey.KEY_PACKAGE_NAME] = report.packageName ?? '';
      param[ReportConst.reportKey.KEY_RETURN_CODE] = report.code ?? '';
      param[ReportConst.reportKey.KEY_ERROR_REASON] = report.msg ?? '';
      param[ReportConst.reportKey.KEY_OPERATION_TYPE] = report.operation ?? '';
      param[ReportConst.reportKey.KEY_BUSINESS_ID] = report.cmd ?? '';
      param[ReportConst.reportKey.KEY_TRACE_ID] = report.transID ?? '';
    } catch (err) {
      HiLog.warn(TAG, `onReport err: ${err}`);
    }
    return param;
  }

  /**
   * 根据打点场景获取对应的traceId
   * <功能详细描述>
   * @param cmd 命令字
   * @return TraceID
   */
  public static createTraceID(cmd?: string): string {
    cmd = cmd ?? '00000';
    cmd =
      cmd.concat(`_${ReportUtils.CLIENT_TYPE}_${Date.parse(new Date().toString()) / 1000}_${Math.floor(Math.random() *
        (99999999 - 10000000 + 1) + 10000000)}`);
    return cmd;
  }
}