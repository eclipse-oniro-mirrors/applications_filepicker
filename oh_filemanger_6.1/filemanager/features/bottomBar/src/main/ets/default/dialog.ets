/*
 * Copyright (c) 2023-2024 Huawei Device Co., Ltd.
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

import { BusinessError, Callback } from '@ohos.base';
import display from '@ohos.display';
import hilog from '@ohos.hilog';
import resourceManager from '@ohos.resourceManager';
import { CompId, DisplayUtil, HiLog } from '@ohos/common';

// 'sys.float.alert_container_max_width'
const MAX_DIALOG_WIDTH: number = getNumberByResourceId(125831042, 400);
// 'sys.float.alert_right_padding_horizontal'
const BUTTON_HORIZONTAL_MARGIN: number = getNumberByResourceId(125831054, 16);

/**
 * get resource size
 *
 * @param resourceId resource id
 * @param defaultValue default value
 * @returns resource size
 */
function getNumberByResourceId(resourceId: number, defaultValue: number, allowZero?: boolean): number {
  try {
    let sourceValue: number = resourceManager.getSystemResourceManager().getNumber(resourceId);
    if (sourceValue > 0 || allowZero) {
      return sourceValue;
    } else {
      return defaultValue;
    }
  } catch (error) {
    let code: number = (error as BusinessError).code;
    let message: string = (error as BusinessError).message;
    hilog.error(0x3900, 'Ace', `CustomContentDialog getNumberByResourceId error, code: ${code}, message: ${message}`);
    return defaultValue;
  }
}

const TAG: string = 'PopoverDialog';

// TODO 待更换API14后删除文件
@Component
export struct PopoverDialog {
  @Link visible: boolean;
  @Prop popover: PopoverOptions;
  @BuilderParam targetBuilder: Callback<void>;
  @State dialogWidth: Dimension | undefined = this.popover?.width;

  @Builder
  emptyBuilder() {
  }

  aboutToAppear(): void {
    if (this.targetBuilder === undefined || this.targetBuilder === null) {
      this.targetBuilder = this.emptyBuilder;
    }
  }

  build() {
    Column() {
      this.targetBuilder();
    }
    .id(CompId.POPOVER_DIALOG)
    .onClick(() => {
      let screenSize: display.Display | undefined = DisplayUtil.getDefaultDisplaySync();
      if (!screenSize) {
        HiLog.warn(TAG, 'screenSize is undefined');
        return;
      }
      let screenWidth: number = px2vp(screenSize.width);
      if (screenWidth - BUTTON_HORIZONTAL_MARGIN - BUTTON_HORIZONTAL_MARGIN > MAX_DIALOG_WIDTH) {
        this.popover.width = this.popover?.width ?? MAX_DIALOG_WIDTH;
      } else {
        this.popover.width = this.dialogWidth;
      }
      this.visible = !this.visible;
    })
    .bindPopup(this.visible, {
      builder: this.popover?.builder,
      placement: this.popover?.placement ?? Placement.Bottom,
      popupColor: this.popover?.popupColor,
      enableArrow: this.popover?.enableArrow ?? true,
      autoCancel: this.popover?.autoCancel,
      onStateChange: this.popover?.onStateChange ?? ((e) => {
        if (!e.isVisible) {
          this.visible = false
        }
      }),
      arrowOffset: this.popover?.arrowOffset,
      showInSubWindow: this.popover?.showInSubWindow,
      mask: this.popover?.mask,
      targetSpace: this.popover?.targetSpace,
      offset: this.popover?.offset,
      width: this.popover?.width,
      arrowPointPosition: this.popover?.arrowPointPosition,
      arrowWidth: this.popover?.arrowWidth,
      arrowHeight: this.popover?.arrowHeight,
      radius: this.popover?.radius ?? $r('sys.float.corner_radius_level16'),
      shadow: this.popover?.shadow ?? ShadowStyle.OUTER_DEFAULT_MD,
      backgroundBlurStyle: this.popover?.backgroundBlurStyle ?? BlurStyle.COMPONENT_ULTRA_THICK,
      focusable: this.popover?.focusable,
      transition: this.popover?.transition,
      onWillDismiss: this.popover?.onWillDismiss
    })
  }
}

export declare interface PopoverOptions extends CustomPopupOptions {}