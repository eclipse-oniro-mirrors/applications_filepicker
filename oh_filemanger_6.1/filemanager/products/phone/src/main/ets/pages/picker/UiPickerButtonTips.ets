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
import { Constant, DeviceInfoUtil, GlobalKey, isFastClick} from '@ohos/common';
import { FilePickerUtil, StartModeOptions } from '@ohos/common';
import { LoadingDialog } from '@kit.ArkUI';

const PERMISSION_SECURITY_POPUP_DURATION: number = 3000;

@Component
export struct UiPickerButtonTips {
  private isShowAll: boolean = false;
  @Prop checkedNum: number = 0;
  private terminate: Function = () => {};
  private encryptShare: Function = () => {};
  @Consume isOutsideFolded: boolean;
  // 在外折叠态下是否已经显示过气泡提示
  static isAlreadyShowPopup: boolean = false;
  @State isShowPopup: boolean = false;
  @StorageLink(GlobalKey.SHOW_PERMISSION_SECURITY_PICKER_POPUP) isShowPermissionSecurityPopup: boolean = false;
  private startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();
  private isSupportEncryptedSharing: boolean | undefined = this.startModeOptions.isEncryptionSupported;
  private customTheme: CustomTheme = this.startModeOptions.customTheme;
  @Prop showAnimate: boolean = true;
  @LocalStorageLink('isFirstPickerShield') isFirstPickerShield: boolean = true; // 默认动画执行完一次后后续切换不再执行动效
  private showDialogPermissionProgressNum: number = 800; // 选择超过800个文件，打开处理中的弹出框
  private dialogPermissionProgress: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      content: $r('app.string.processing'),
    }),
    autoCancel: false
  })

  aboutToAppear(): void {
    this.showPermissionSecurityPopup();
    // 只有第一次星盾组件需要动效，后续的组件不演示动画
    if (this.isFirstPickerShield) {
      this.isFirstPickerShield = false;
    } else {
      this.showAnimate = false;
    }
  }

  showPermissionSecurityPopup() {
    if (this.isShowPermissionSecurityPopup && this.isOutsideFolded) {
      this.isShowPermissionSecurityPopup = false;
      this.isShowPopup = true;
      setTimeout(() => {
        this.isShowPopup = false;
      }, PERMISSION_SECURITY_POPUP_DURATION);
    }
  }

  build() {
    Column() {
      if (this.isShowAll) {
        WithTheme({theme: this.customTheme}) {
          this.uiPickerMainButtonSelected()
        }
      }
      this.uiPickerMainButtonTip()
    }
    .bindPopup(this.isOutsideFolded && this.isShowPopup, {
      builder: this.buildPopup(),
      placement: Placement.Top,
      enableArrow: false,
      mask: false,
      radius: $r('sys.float.corner_radius_level2'),
      autoCancel: false,
      targetSpace: 12
    })
  }

  @Builder
  uiPickerMainButtonTip() {
  }

  @Builder
  uiPickerMainButtonSelected() {
    Row() {
      Row() {
        Text($r('app.plural.picker_selected', this.checkedNum, this.checkedNum))
          .fontFamily('HarmonyHeiTi')
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .constraintSize({
            minHeight: $r('app.float.common_line_height21')
          })
          .fontWeight(FontWeight.Medium)
          .maxFontScale(Constant.BIG_MODE.BIG_MODE_1x)
      }
      .justifyContent(FlexAlign.Start)
      .layoutWeight(1)

      if (this.isSupportEncryptedSharing) {
        Row() {
          Button({ type: ButtonType.Normal, stateEffect: false }) {
            Row() {
              Text($r('app.string.encrypted_share'))
                .maxFontScale(Constant.BIG_MODE.BIG_MODE_1x)
                .fontColor($r('sys.color.font_on_primary'))
                .fontFamily('HarmonyHeiTi')
                .fontSize($r('app.float.album_fontSize_12'))
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Center)
                .textOverflow({ overflow: TextOverflow.Ellipsis }) // 设置溢出时显示省略号
                .ellipsisMode(EllipsisMode.CENTER) // 设置显示模式为：显示头尾，中间省略
                .maxLines(Constant.LINE_COUNT.ONE) // 限制不换行
            }
            .alignItems(VerticalAlign.Center)
            .margin({
              left: $r('app.float.common_size8'),
              right: $r('app.float.common_size8'),
              top: $r('app.float.common_size4'),
              bottom: $r('app.float.common_size4')
            })
          }
          .fontColor($r('sys.color.font_on_primary'))
          .borderRadius(14)
          .constraintSize({
            minHeight: $r('app.float.common_size28'),
            minWidth: $r('app.float.common_size72')
          })
          .enabled(this.checkedNum > 0)
        }
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.encryptShare())
        .enabled(this.checkedNum > 0)
        .layoutWeight(1)
      }

      Row() {
        Button({ type: ButtonType.Normal, stateEffect: false }) {
          Row() {
            Text($r('app.string.finish'))
              .maxFontScale(Constant.BIG_MODE.BIG_MODE_1x)
              .fontColor($r('sys.color.font_on_primary'))
              .fontFamily('HarmonyHeiTi')
              .fontSize($r('app.float.album_fontSize_12'))
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
          }
          .alignItems(VerticalAlign.Center)
          .margin({
            left: $r('app.float.common_size8'),
            right: $r('app.float.common_size8'),
            top: $r('app.float.common_size4'),
            bottom: $r('app.float.common_size4')
          })
        }
        .fontColor($r('sys.color.font_on_primary'))
        .borderRadius(14)
        .constraintSize({
          minHeight: $r('app.float.common_size28'),
          minWidth: $r('app.float.common_size72')
        })
        .enabled(this.checkedNum > 0)
      }
      .accessibilityRole(AccessibilityRoleType.BUTTON)
      .justifyContent(FlexAlign.End)
      .height($r('app.float.common_size40'))
      .onClick(() => {
        if (isFastClick()) {
          return;
        }
        if (this.checkedNum >= this.showDialogPermissionProgressNum) {
          this.dialogPermissionProgress.open();
        }
        this.terminate();
      })
      .enabled(this.checkedNum > 0)
      .layoutWeight(1)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({
      top: this.isOutsideFolded ? $r('app.float.common_size12') : $r('sys.float.padding_level6'),
      bottom: this.isOutsideFolded ? $r('app.float.common_size12')
        : $r('sys.float.padding_level6'),
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8')
    })
    .constraintSize({
      minHeight: $r('app.float.common_size28')
    })
  }

  @Builder
  buildPopup() {
    Row() {
      SymbolGlyph($r('sys.symbol.person_shield_fill'))
        .draggable(false)
        .fontColor([$r('sys.color.black')])
        .fontSize($r('sys.float.Caption_L'))
        .fontWeight(FontWeight.Normal)

      Text($r('app.string.picker_security_tips'))
        .maxLines(1)
        .fontSize($r('sys.float.Caption_L'))
        .maxFontScale(2)
        .fontFamily('HarmonyHeiTi')
        .fontColor($r('sys.color.black'))
        .fontWeight(FontWeight.Normal)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .constraintSize({
          minHeight: $r('app.float.common_size16')
        })
        .margin({
          left: $r('sys.float.padding_level2')
        })
    }
    .backgroundColor($r('sys.color.white'))
    .padding({
      top: $r('sys.float.padding_level1'),
      bottom: $r('sys.float.padding_level1'),
      left: $r('sys.float.padding_level3'),
      right: $r('sys.float.padding_level3')
    })
  }
}