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

import {
  AccessibilityManager,
  CompId,
  FilePickerUtil,
  HiLog,
  LocalStorageConst,
  ResourceUtil,
  StartModeOptions,
  ToolBarStyle,
  UEUtil
} from '@ohos/common';
import data_preferences from '@ohos.data.preferences';

@Styles
function pressedStyles() {
  .backgroundColor($r('sys.color.ohos_id_color_hover'))
}

@Styles
function normalStyles() {
  .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
}

const TAG: string = 'FileTypeFilterDialog';
const OPTION_FOCUS_DELAY = 50;
const FILTER_TYPE_ALL: string = 'ALL';
const FILTER_TYPE_OTHER: string = 'OTHER';

class FileTypeOption {
  public index: number = 0;
  public fileTypeName: string | Resource = '';
  public selectStatus: boolean = false;
}

@Component
export struct FileTypeFilterDialog {
  public filePickerViewFlag: boolean = false;
  private selectedIndexArr: number[] = [];
  private dialogTitle: Resource | string = '';
  @State fileTypeArr: FileTypeOption[] = [];
  private isBlackSuffix: boolean = false;
  private suffixArr: string[] = [];
  @Consume suffixSheetType: SheetType;
  confirm: Function = () => {
  };
  close: Function = () => {
  };
  @LocalStorageProp(LocalStorageConst.BOTTOM_NAV_BAR_HEIGHT) bottomNavBarHeight: number = 0;
  private customTheme: CustomTheme = FilePickerUtil.getStartOptionsFromStorage().customTheme;

  aboutToAppear(): void {
    HiLog.info(TAG, 'FileTypeFilterDialog appear');
    this.initData();
  }

  initData(): void {
    this.dialogTitle = $r('app.string.unknown');
    HiLog.info(TAG, 'init suffix options finish');
  }

  private initOptions(typeNameArr: ResourceStr[]): FileTypeOption[] {
    let optionArr: FileTypeOption[] = [];
    if (!typeNameArr || typeNameArr.length === 0) {
      return optionArr;
    }
    for (let i = 0; i < typeNameArr.length; i++) {
      optionArr.push({
        index: i,
        fileTypeName: typeNameArr[i],
        selectStatus: false
      })
    }
    let selectExisted: boolean = false;
    for (let element of this.selectedIndexArr) {
      if (element >= 0 && element < optionArr.length) {
        optionArr[element].selectStatus = true;
        selectExisted = true;
      }
    }
    if (!selectExisted) {
      optionArr[0].selectStatus = true;
    }
    return optionArr;
  }

  // 重置选项
  private resetOption(): void {
    this.fileTypeArr.forEach(item => {
      item.selectStatus = false;
    })
    this.fileTypeArr[0].selectStatus = true;
    this.fileTypeArr = [...this.fileTypeArr];
    AccessibilityManager.getInstance().sendTextAnnouncedForAccessibility(
        ResourceUtil.getStringByResource($r('app.string.reset_succeeded')));
  }

  build() {
    Column() {
      this.builderHeaderButton();
      Column() {
        Text(this.dialogTitle)
          .fontSize($r('sys.float.Subtitle_S'))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
          .fontFamily('HarmonyHeiTi')
          .alignSelf(ItemAlign.Start)
          .lineHeight(20)
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .constraintSize({
        minHeight: this.suffixSheetType === SheetType.BOTTOM ? $r('app.float.common_size24') :
          $r('app.float.common_size48')
      })
      .padding({
        left: $r('app.float.common_padding8'),
        right: $r('app.float.common_padding8')
      })
      .margin({
        top: $r('app.float.common_margin8')
      })

      this.listTypeFilter();
      if (this.suffixSheetType === SheetType.CENTER) {
        Blank().layoutWeight(1)
      }
      this.controlButtons();
    }
    .padding({
      top: $r('app.float.common_padding16'),
      bottom: this.suffixSheetType === SheetType.CENTER ? 0 : this.bottomNavBarHeight,
      left: $r('app.float.common_padding8'),
      right: $r('app.float.common_padding8')
    })
    // ArkUI半模态弹窗居中时最小高度320
    .constraintSize({
      minHeight: this.suffixSheetType === SheetType.CENTER ? 320 : undefined
    })
  }

  @Builder
  listTypeFilter() {
    Flex({
      wrap: FlexWrap.Wrap,
      direction: FlexDirection.Row,
      alignItems: ItemAlign.Start
    }) {
      ForEach(this.fileTypeArr, (item: FileTypeOption, index) => {
        Text(item.fileTypeName)
          .textAlign(TextAlign.Center)
          .borderRadius($r('app.float.common_size18'))
          .fontSize($r('sys.float.Body_M'))
          .fontColor(item.selectStatus ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .backgroundColor(item.selectStatus ? this.customTheme.colors?.compBackgroundEmphasize :
          $r('sys.color.ohos_id_color_button_normal'))
          .constraintSize({
            minWidth: $r('app.float.common_size62'),
            minHeight: $r('app.float.common_size28')
          })
          .padding($r('app.float.common_size8'))
          .margin($r('app.float.common_margin4'))
          .onClick(() => {
            HiLog.info(TAG, 'complete suffix selecting');
            this.changeSelectedType(index);
            this.fileTypeArr = [...this.fileTypeArr];
            // 无障碍模式下主动获焦
            let timer = setTimeout(()=>{
              AccessibilityManager.getInstance().sendCustomIdFocusForAccessibility(CompId.FILE_ITEM + index, TAG);
              clearTimeout(timer);
            }, OPTION_FOCUS_DELAY);
          })
          .id(CompId.FILE_ITEM + index)
          .accessibilityChecked(item.selectStatus)
      })
    }
    .padding($r('app.float.common_margin4'))
    .width('100%')
  }

  private changeSelectedType(index: number): void {
    if (index < 0 || index >= this.fileTypeArr.length) {
      HiLog.warn(TAG, `invalid index:${index}}`);
      return;
    }
    this.fileTypeArr[index].selectStatus = !this.fileTypeArr[index].selectStatus;
    if (index === 0 && this.fileTypeArr[index].selectStatus) {
      // 从第一个有效后缀选项开始
      for (let i = 1; i < this.fileTypeArr.length; i++) {
        this.fileTypeArr[i].selectStatus = false;
      }
      return;
    }
    if (this.existSelectedType()) {
      // 取消全选
      this.fileTypeArr[0].selectStatus = false;
    } else {
      // 全选兜底
      this.fileTypeArr[0].selectStatus = true;
    }
  }

  existSelectedType(): boolean {
    // 从第一个有效后缀选项开始
    for (let i = 1; i < this.fileTypeArr.length; i++) {
      if (this.fileTypeArr[i].selectStatus) {
        return true;
      }
    }
    return false;
  }

  @Builder
  controlButtons() {
    Row() {
      Button($r('app.string.finish'))
        .onClick(() => {
          HiLog.info(TAG, 'click button: suffix select finish');
          let selectedOptions: string[] = this.getSelectedSuffix();
          this.getSelectedSuffix();
          // 是否全部，全部则显示不过滤
          let isFilter = !this.fileTypeArr[0].selectStatus;
          this.confirm(isFilter, this.isBlackSuffix, this.suffixArr);
        })
        .type(ButtonType.Normal)
        .layoutWeight(1)
        .fontColor(this.customTheme.colors?.fontPrimary)
        .borderRadius($r('sys.float.corner_radius_level10'))
        .fontSize($r('sys.float.Body_L'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
    }
    .constraintSize({
      minHeight: $r('app.float.common_size40')
    })
    .margin({
      top: $r('app.float.common_margin8'),
      left: $r('app.float.common_margin8'),
      right: $r('app.float.common_margin8'),
      bottom: $r('app.float.common_margin16')
    })
  }

  getSelectedSuffix(): string[] {
    let selectedOptions: string[] = [];
    for (let item of this.fileTypeArr) {
      if (!item.selectStatus) {
        continue;
      }
      selectedOptions.push(this.getOptionName(item.fileTypeName));
    }
    return selectedOptions;
  }

  getOptionName(fileTypeName: string | Resource): string {
    return fileTypeName.toString();
  }

  @Builder
  builderHeaderButton() {
    Row() {
      Column() {
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontColor([$r('sys.color.ohos_id_color_primary')])
          .fontSize($r('app.float.common_size18'))
          .draggable(false)
          .focusable(true)
          .id(CompId.LEFT_ICON)
      }
      .accessibilityText(ResourceUtil.getStringByResource($r('app.string.cancel')))
      .accessibilityRole(AccessibilityRoleType.BUTTON)
      .width($r('app.float.common_size40'))
      .height($r('app.float.common_size40'))
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .borderRadius(ToolBarStyle.ITEM_BORDER_RADIUS)
      .stateStyles({
        pressed: pressedStyles,
        normal: normalStyles
      })
      .onClick(() => {
        HiLog.info(TAG, 'cancel suffix select');
        this.close();
      })

      Text($r('app.string.filter'))
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .fontFamily('HarmonyHeiTi')
        .margin({ left: $r('app.float.common_margin8'), right: $r('app.float.common_margin8') })
        .layoutWeight(1)
        .maxFontScale(1.75)

      Column() {
        Image($r('app.media.arrow_clockwise'))
          .fillColor($r('sys.color.ohos_id_color_primary'))
          .width($r('app.float.common_size18'))
          .height($r('app.float.common_size18'))
          .draggable(false)
          .focusable(true)
      }
      .accessibilityText(ResourceUtil.getStringByResource($r('app.string.select_reset')))
      .accessibilityRole(AccessibilityRoleType.BUTTON)
      .width($r('app.float.common_size40'))
      .height($r('app.float.common_size40'))
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .borderRadius(ToolBarStyle.ITEM_BORDER_RADIUS)
      .stateStyles({
        pressed: pressedStyles,
        normal: normalStyles
      })
      .margin({ left: $r('app.float.common_margin8') })
      .onClick(() => {
        HiLog.info(TAG, 'reset suffix select');
        this.resetOption();
      })
    }
    .padding({
      left: $r('app.float.common_padding8'),
      right: $r('app.float.common_padding8')
    })
    .width('100%')
  }
}


