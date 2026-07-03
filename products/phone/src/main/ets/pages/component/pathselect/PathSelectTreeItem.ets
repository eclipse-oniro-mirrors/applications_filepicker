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

import { TREE_LAYER } from '@ohos/common/src/main/ets/const/UiConstant';
import fileExtensionInfo from '@ohos.file.fileExtensionInfo';
import { 
  AccessibilityManager,
  AccessibilityStorageKey,
  ArrayUtil,
  Constant,
  FilePickerUtil,
  FileUtil,
  HiLog,
  MyPhoneConstant,
  ResourceUtil,
  StartModeOptions,
  VirtualUri } from '@ohos/common';
import { FolderData } from '@ohos/common/src/main/ets/fileoperate/FolderData';
import { UiUtil } from '@ohos/common/src/main/ets/utils/UiUtil';
import { LengthMetrics } from '@kit.ArkUI';
import { i18n } from '@kit.LocalizationKit';

const TAG = 'TreeItem';

@Component
export struct PathSelectTreeItem {
  private folderItem: FolderData = new FolderData();
  @Prop selectUri: string = '';
  @Prop isLastFolder: boolean = false;
  @StorageProp('isDarkMode') isDarkMode: boolean = false;
  private onItemClick: Function = () => {};
  private startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();
  private customTheme: CustomTheme = this.startModeOptions.customTheme;
  private compBackgroundEmphasize: ResourceColor = $r('app.color.path_pick_selected_bg');
  private fontEmphasize: ResourceColor = '';
  @State isNeedToAnnounceSelected: boolean = true;

  aboutToAppear() {
    // 如果是三方拉起saver，判断是否需要应用色生效
    if (this.startModeOptions.isCreateFileMode() && this.customTheme.colors) {
      if (this.customTheme.colors.compBackgroundEmphasize) {
        this.compBackgroundEmphasize = this.customTheme.colors.compBackgroundEmphasize;
        // 如果传入的背景色没有传透明度，添加10%不透明度
        const rgbStringLen: number = 7;
        if (typeof this.compBackgroundEmphasize === 'string' && this.compBackgroundEmphasize.length === rgbStringLen) {
          const argbPreFix: string = '#1A';
          this.compBackgroundEmphasize = argbPreFix.concat(this.compBackgroundEmphasize.slice(1, rgbStringLen));
        }
        HiLog.info(TAG, `pathpicker final compBackgroundEmphasize color: ${this.compBackgroundEmphasize}`);
      }
      if (this.customTheme.colors.fontEmphasize) {
        this.fontEmphasize = this.customTheme.colors.fontEmphasize;
      }
    }
    HiLog.debugPrivate(TAG,
      `aboutToAppear, ${this.folderItem.level}, ${this.folderItem.isLoading}, ${this.folderItem.isExpend}, ${this.folderItem.subFolderList.length}`,
      `${this.folderItem.uri}-${this.folderItem.fileName}`);
  }

  private getFolderLevelAndExpandStatusString(): string {
    let level: number = this.folderItem.level;
    let levelStr: string = '';
    const isShowArrow = this.isShowArrow();
    if (!isShowArrow) {
      levelStr = ResourceUtil.getStringByOneParamResource($r('app.string.path_picker_folder_level'), level);
    } else if (this.folderItem.isExpend) {
      levelStr = ResourceUtil.getStringByOneParamResource($r('app.string.path_picker_folder_level_and_expand'), level);
    } else {
      levelStr = ResourceUtil.getStringByOneParamResource($r('app.string.path_picker_folder_level_and_unexpand'), level);
    }
    const accessibilityDescription: string =
      isShowArrow ? ResourceUtil.getStringByResource($r('app.string.click_accessibility')) : '';
    return `${levelStr}, ${accessibilityDescription}`;
  }

  build() {
    Column() {
      Row() {
        this.buildIcon();
        Text(this.folderItem.fileNameResource ??
        UiUtil.translateFileNameByUri(this.folderItem.uri, this.folderItem.fileName, true))
          .fontSize($r('app.float.common_font_size16'))
          .layoutWeight(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor(this.selectUri === this.folderItem.uri ? this.fontEmphasize : '')
          .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Rtl : Direction.Ltr)
          .maxLines(2)

        if (this.folderItem.isLoading) {
          LoadingProgress()
            .width($r('app.float.common_size24'))
            .height($r('app.float.common_size24'))
            .color($r('sys.color.ohos_id_color_progress'))
        } else {
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontColor([$r('sys.color.ohos_id_color_fourth')])
            .margin({ start: LengthMetrics.resource($r('sys.float.ohos_id_text_paragraph_margin_xs')) })
            .fontSize($r('app.float.common_size24'))
            .width($r('app.float.common_size12'))
            .height($r('app.float.common_size24'))
            .rotate({ z: 90, angle: this.folderItem.isExpend ? 90 : 0 })
            .visibility(this.isShowArrow() ? Visibility.Visible : Visibility.None)
            .draggable(false)
        }
      }
      .accessibilitySelected(this.isNeedToAnnounceSelected && this.selectUri === this.folderItem.uri)
      .accessibilityDescription(this.getFolderLevelAndExpandStatusString())
      .onAccessibilityFocus((isFocus: boolean) => {
        if (isFocus) {
          this.isNeedToAnnounceSelected = true;
        }
      })
      .id(this.folderItem.uri)
      .width('100%')
      .padding({
        top: LengthMetrics.resource($r('app.float.common_padding16')),
        bottom: LengthMetrics.resource($r('app.float.common_padding16')),
        end: LengthMetrics.resource($r('app.float.common_padding24')),
        start: LengthMetrics.vp(24 + (this.folderItem.level - 1) * TREE_LAYER)
      })
      .onClick(() => {
        // 无障碍模式下，点击新的选项时，不播报冗余的已选中播报
        if (AccessibilityManager.getInstance().getIsAccessibilityMode()) {
          this.isNeedToAnnounceSelected = false;
          if (!this.isShowArrow()) {
            AccessibilityManager.getInstance().sendCustomIdFocusForAccessibility(this.folderItem.uri);
          }
        }
        this.onItemClick(this.folderItem);
      })
      .onAttach(() => {
        if (AccessibilityManager.getInstance().getIsAccessibilityMode() && this.selectUri === this.folderItem.uri &&
          this.folderItem.isLoading === false) {
          // 首次进入无需主动聚焦
          if (AppStorage.has(AccessibilityStorageKey.PATH_SELECT_INIT_KEY)) {
            AppStorage.delete(AccessibilityStorageKey.PATH_SELECT_INIT_KEY);
            return;
          }
          AccessibilityManager.getInstance().sendCustomIdFocusForAccessibility(this.folderItem.uri);
        }
      })
      if (!this.isLastFolder) {
        Divider()
          .vertical(false)
          .height($r('app.float.divider_strokeWidth1'))
          .color($r('sys.color.ohos_id_color_list_separator'))
          .margin({
            end: LengthMetrics.resource($r('app.float.common_padding24')),
            start: LengthMetrics.vp(64 + (this.folderItem.level - 1) * TREE_LAYER)
          })
      }
    }
    .backgroundColor(this.selectUri === this.folderItem.uri ? this.compBackgroundEmphasize : '')
  }

  @Builder
  buildIcon() {
    if (this.folderItem.uri == VirtualUri.GALLERY) {
      Stack({ alignContent: Alignment.Bottom }) {
        Image(this.getFolderIcon())
          .objectFit(ImageFit.Contain)
          .interpolation(ImageInterpolation.High)
          .renderMode(ImageRenderMode.Original)
          .aspectRatio(1)
          .width($r('app.float.common_size24'))
          .alignSelf(ItemAlign.Center)
          .margin({ end: LengthMetrics.resource($r('app.float.common_margin16')) })
          .draggable(false)
          .syncLoad(true)
          .zIndex(0)

        Image(FileUtil.getApplicationIconOrLabel(Constant.GALLERY_BUNDLE_NAME))
          .objectFit(ImageFit.Contain)
          .width($r('app.float.common_size8'))
          .height($r('app.float.common_size8'))
          .draggable(false)
          .margin({ end: LengthMetrics.resource($r('app.float.common_margin16')), bottom: LengthMetrics.vp(5) })
          .zIndex(5)
      }
    } else {
      Image(this.getFolderIcon())
        .objectFit(ImageFit.Contain)
        .interpolation(ImageInterpolation.High)
        .renderMode(ImageRenderMode.Original)
        .aspectRatio(1)
        .width($r('app.float.common_size24'))
        .alignSelf(ItemAlign.Center)
        .margin({ end: LengthMetrics.resource($r('app.float.common_margin16')) })
        .draggable(false)
        .syncLoad(true)
    }
  }

  private getFolderIcon(): ResourceStr {
    if (this.folderItem.isRootFolder) {
      if (this.folderItem.deviceType === fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK) {
        return $r('app.media.storage_phone_icon');
      }
      return $r('app.media.ic_classify_usb');
    }

    if (MyPhoneConstant.isSystemFolder(FileUtil.getParentUri(this.folderItem.uri), this.folderItem.fileName, true)) {
      return MyPhoneConstant.getFolderImage(this.isDarkMode, this.folderItem.fileName,
        !ArrayUtil.isEmpty(FileUtil.getSubFileListByUri(this.folderItem.uri)));
    } else {
      return !ArrayUtil.isEmpty(FileUtil.getSubFileListByUri(this.folderItem.uri)) ? $r('app.media.ic_normal_folder') :
        $r('app.media.ic_normal_folder_empty');
    }
  }

  private isShowArrow(): boolean {
    return !this.folderItem.isExpend || !this.folderItem.isEmptyFolder();
  }
}