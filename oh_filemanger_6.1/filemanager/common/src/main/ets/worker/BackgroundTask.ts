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
import lazy { backgroundTaskManager } from '../../../../indexLazyLoadTs';
import { HiLog } from '../dfx/HiLog';

const TAG: string = 'BackgroundTaskManager';
/*
 * 用于长时任务的申请和取消
 * 用于文管在后台或锁屏，能够继续进行worker任务
 * */
export class BackgroundTaskManager {
  public static isApplied: boolean = false;
  public static applyTasks: Set<string> = new Set(); // 申请长时任务id

  public static applyBackgroundTask(taskName: string): void {
    BackgroundTaskManager.applyTasks.add(taskName);
    HiLog.infoPrivate(TAG, `afterApply currentTasks:`,
      `${JSON.stringify(Array.from(BackgroundTaskManager.applyTasks))}`);
    if (BackgroundTaskManager.isApplied) {
      HiLog.warn(TAG, 'applyEfficiencyResources has applied.');
      return;
    }
    HiLog.info(TAG, 'applyEfficiencyResources start.');
    let request: backgroundTaskManager.EfficiencyResourcesRequest = {
      resourceTypes: backgroundTaskManager.ResourceType.CPU,
      isApply: true,
      timeOut: 0,
      reason: 'apply',
      isPersist: true,
      isProcess: false,
    };
    try {
      backgroundTaskManager.applyEfficiencyResources(request);
      BackgroundTaskManager.isApplied = true;
      HiLog.warn(TAG, 'applyEfficiencyResources success.');
    } catch (error) {
      HiLog.error(TAG, `applyEfficiencyResources failed. error: ${JSON.stringify(error)}`);
    }
  }

  public static resetBackgroundTask(taskName: string): void {
    BackgroundTaskManager.applyTasks.delete(taskName);
    HiLog.info(TAG, `afterReset currentTasks:${JSON.stringify(Array.from(BackgroundTaskManager.applyTasks))}`);
    // 还有其他任务在使用
    if (BackgroundTaskManager.applyTasks.size > 0) {
      return;
    }
    BackgroundTaskManager.isApplied = false;
    HiLog.info(TAG, 'resetAllEfficiencyResources start.');
    try {
      backgroundTaskManager.resetAllEfficiencyResources();
      HiLog.warn(TAG, 'resetAllEfficiencyResources success.');
    } catch (error) {
      HiLog.error(TAG, `resetAllEfficiencyResources failed. error: ${JSON.stringify(error)}`);
    }
  }
}