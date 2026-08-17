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
import { CommonPreferenceUtil, Constant, HiLog } from '@ohos/common';
import { PromptAction } from '@kit.ArkUI';

const TAG: string = 'PopupItem';
@ObservedV2
export class PopupItem {
  public text: Resource;
  @Trace
  public isShowPopup: boolean;
  public linkText?: Resource;
  public popupKey: string;
  // 气泡Option
  public options: PopupCommonOptions | null = null;
  private promptAction: PromptAction | null = null;
  private contentNode: ComponentContent<PopupItem> | null = null;


  public constructor(text: Resource, isShowPopup: boolean = false, popupKey: string = '',
    linkText: Resource | undefined = undefined) {
    this.text = text;
    this.isShowPopup = isShowPopup;
    this.linkText = linkText;
    this.popupKey = popupKey;
  }

  public async changePopupShowStatus(): Promise<void> {
    AppStorage.setOrCreate(this.popupKey, true);
    await CommonPreferenceUtil.setTipsAlreadyShowSwitch(this.popupKey, true);
    try {
      this.promptAction?.closePopup(this.contentNode);
    } catch (e) {
      HiLog.error(TAG, `closePopup error, code:${e?.code}, message: ${e?.message}`);
    }
  }

  public setPromptAction(promptAction: PromptAction): void {
    this.promptAction = promptAction;
  }

  public setContentNode(contentNode: ComponentContent<PopupItem>): void {
    this.contentNode = contentNode;
  }
}