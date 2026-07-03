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

import { systemShare } from '@kit.ShareKit';
import common from '@ohos.app.ability.common';
import lazy { UTD } from '../../../../indexLazyLoadTs';
import { HiLog } from '../dfx/HiLog';

const TAG = 'ShowShareDialog';

export async function showShareDialogFun(context: common.UIAbilityContext | common.UIExtensionContext,
  controller: systemShare.ShareController, shareOptions: systemShare.ShareControllerOptions): Promise<void> {
  // @ts-ignore
  await controller.show(context, shareOptions);
}

/**
 * 通过后缀名获取utd，先通过ts-ignore屏蔽编译报错
 * @param fileExtension
 * @returns
 */
export function getUtdByExtension(fileExtension: string): string[] {
  try {
    // @ts-ignore
    return UTD.getUniformDataTypesByFilenameExtension(fileExtension);
  } catch (err) {
    HiLog.error(TAG, 'failed to get utd by fileExtention');
  }
  return [];
}