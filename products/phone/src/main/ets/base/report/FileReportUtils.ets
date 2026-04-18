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


import { ObjectUtil } from '@ohos/common';
import { ReportConst } from '../const/ReportCont';
import { Reporter } from './Reporter';
import { ReportUtils } from './ReportUtil';


const TAG: string = 'FileReportUtils';


/**
 * 文管运维打点
 */
export class FileReportUtils {

  /**
   * 生成文管打点reporter
   * @param operationType
   * @param businessId 业务Id
   * @param returnMsg 错误信息
   * @param transId 流水号
   * @param returnCode 错误码
   * @param taskType 任务类型
   * @returns
   */
  public static generateFileReport(operationType: string, businessId: string, returnCode ?: string, returnMsg?: string,
                                    transId?: string, taskType?: string): Reporter {
    if (ObjectUtil.isNullOrUndefined(transId)) {
      transId = ReportUtils.createTraceID(operationType);
    }
    return new Reporter(ReportConst.reportPackage.PACKAGENAME_FILEMANAGER,
      ReportConst.operationType.filemanager.ENTER_FILEMANAGER_PAGE, transId ?? '', businessId)
      .setCode(returnCode ?? ReportConst.returnCode.SUCCESS.toString())
      .setMsg(returnMsg ?? ReportConst.returnMsg.SUCCESS)
      .setTaskType(taskType);
  }

  /**
   * 上报内部页面打点
   * @param report 上报实例
   * @param param 上报参数
   * @returns
   */
  public static async reportPageEvent(page: string, param?: Record<string, string>): Promise<void> {
    param = param ?? {};
    param['page'] = page;
    let reporter = FileReportUtils.generateFileReport(
      ReportConst.operationType.filemanager.ENTER_FILEMANAGER_PAGE,
      ReportConst.businessId.filemanager.ENTER_FILEMANAGER);
    ReportUtils.omReport(reporter, param);
  }

}