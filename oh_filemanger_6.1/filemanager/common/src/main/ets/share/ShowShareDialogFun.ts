/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

// import { systemShare } from '@kit.ShareKit';
import common from '@ohos.app.ability.common';
import lazy { UTD } from '../../../../indexLazyLoadTs';
import { HiLog } from '../dfx/HiLog';

const TAG = 'ShowShareDialog';

// export async function showShareDialogFun(context: common.UIAbilityContext | common.UIExtensionContext,
//   controller: systemShare.ShareController, shareOptions: systemShare.ShareControllerOptions): Promise<void> {
//   // @ts-ignore
//   await controller.show(context, shareOptions);
// }

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