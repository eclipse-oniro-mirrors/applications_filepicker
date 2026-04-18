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

import { renderSize } from '@ohos/common/src/main/ets/utils/Tools';
import {
  Constant,
  DiskInfo,
  DisplayUtil,
  EventBus,
  GlobalHolder,
  GlobalKey,
  HiLog,
  LocalStorageConst,
  ObjectUtil,
  PREVIEW_TYPE,
  StringUtil,
  AbilityOrRouterParams,
  DateUtil,
  FileDefaultIconUtil,
  FileInfo,
  FileOperation,
  FileUtil,
  MimeType,
  StorageDeviceManager,
  UiUtil,
  ThumbnailUtil
} from '@ohos/common';
import lazy { PreviewUtil } from '@ohos/common/src/main/ets/utils/PreviewUtil';
import { OtherAppsOpenDialog } from '@ohos/customDialog/indexPhoneOnly';

const TAG = 'FilePreview';

@Component
export struct FilePreview {
  @LocalStorageProp(LocalStorageConst.STATUS_BAR_HEIGHT) statusBarHeight: number = 0;
  @LocalStorageProp(LocalStorageConst.BOTTOM_NAV_BAR_HEIGHT) bottomNavBarHeight: number = 0;
  @State fileData: FileInfo = new FileInfo();
  @State fileName: string = '';
  private isFileExist: boolean = true;
  @State needLoadThumbnail: boolean = true;
  private sdUsbChangeBind: Function = (uriArray: string[]) => this.sdUsbChange(uriArray);
  private onCheckExistBind: Function = (): void => this.onCheckExist();
  private onRenameBind: Function = (newName: string, newUri: string): void => this.onRename(newName, newUri);
  @Consume('pageInfos') pageInfos: NavPathStack;
  @Consume('navMode') navMode: NavigationMode;
  @Consume('currentNavItem') currentNavItem: string;
  private pageParams: Object = ObjectUtil.empty();
  private otherAppsOpenDialog: CustomDialogController = new CustomDialogController({
    builder: OtherAppsOpenDialog({
      confirm: (openType: string): void => this.otherAppsOpenConfirm(openType),
    }),
    autoCancel: true,
    customStyle: true,
    alignment: DialogAlignment.Bottom,
    offset: { dx: $r('app.float.dialog_offset_0'), dy: $r('app.float.dialog_offset_0') }
  })
  // 获取当前横竖屏状态
  @StorageLink(GlobalKey.DISPLAY_INFO) @Watch('getOrientation') display: string = '';
  // 获取当前横竖屏状态
  @State @Watch('describePositionChange') orientation: boolean = false;
  @State heightPercent :string = '80%';
  @State heightCount: Resource = $r('app.float.common_size492');
  @StorageLink('deviceFoldStatus') @Watch('describePositionChange') deviceFoldStatus: number = DisplayUtil.getFoldStatus();

  async sdUsbChange(uriArray: string[]): Promise<void> {
    try {
      const storageDeviceList: DiskInfo[] = await StorageDeviceManager.getInstance().getStorageDeviceList();
      const storageDevice =
        storageDeviceList.find((deviceItem: DiskInfo) => this.fileData.uri.startsWith(deviceItem.uri));
      // U盘或SD卡移除时返回最近页
      if ((!storageDevice) || (storageDevice && uriArray.indexOf(storageDevice?.uri) === -1)) {
        this.currentNavItem = '';
        this.pageInfos.pop();
      }
    } catch (e) {
      HiLog.info(TAG, 'preview back error : ' + JSON.stringify(e));
    }
  }

  aboutToAppear() {
    let params = this.pageParams as AbilityOrRouterParams;
    this.fileData = params.fileData;
    this.fileName = this.fileData.fileName;
    let heic = !StringUtil.isEmpty(this.fileName) && this.fileName.toLowerCase().endsWith('.heic') &&
    this.fileData.isLoadThumbnailError;
    this.needLoadThumbnail = !heic && !StringUtil.isEmpty(this.fileData.thumbUri);
    EventBus.on(Constant.EVENTS.SD_USB_CHANGE, this.sdUsbChangeBind);
    EventBus.on(Constant.EVENTS.FILE_VIEW_CHECK, this.onCheckExistBind);
    this.describePositionChange();
  }

  onPageShow() {
    HiLog.info(TAG, 'FilePreview onPageShow');
    this.checkFileExist();
  }

  otherAppsOpenConfirm(openType: string) {
    HiLog.info(TAG, 'otherAppsOpenConfirm: ' + JSON.stringify(openType));
    if (!this.fileData) {
      return;
    }
    FileOperation.openFileByOtherApp(this.fileData.uri, this.fileData.fileName);
  }

  onCheckExist() {
    this.checkFileExist();
  }

  onRename(newName: string, newUri: string) {
    this.fileName = newName;
    this.fileData.fileName = newName;
    EventBus.off(this.fileData.uri, this.onRenameBind);
    this.fileData.uri = newUri;
    EventBus.on(newUri, this.onRenameBind);
  }

  checkFileExist(): void {
    if (this.fileData.isGallery) {
      return;
    }
    this.isFileExist = FileUtil.isExistByUriWithFs(this.fileData.uri);
    if (!this.isFileExist) {
      // 文件不存在就退出页面
      this.pageInfos.pop();
    }
  }

  aboutToDisappear() {
    EventBus.off(Constant.EVENTS.SD_USB_CHANGE, this.sdUsbChangeBind);
    EventBus.off(Constant.EVENTS.FILE_VIEW_CHECK, this.onCheckExistBind);
    EventBus.off(this.fileData.uri, this.onRenameBind);
    if (this.navMode === NavigationMode.Stack) {
      this.currentNavItem = '';
    }
  }

  onBackPress() {
    return false;
  }

  // 大于20M图片分栏场景的右侧预览页只展示缩略图
  checkBigImage(): boolean {
    return this.fileData.size > (20 * Constant.BYTE.ONE_MB);
  }

  build() {
    NavDestination() {
      Column() {
        this.buildContent();
        this.showButton();
      }
    }
    .onDrop(() => {
      HiLog.info(TAG, 'FilePreview onDrop');
    })
    .onDragMove((event: DragEvent) => {
      event.setResult(DragResult.DROP_DISABLED);
    })
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .title(this.buildTitle())
    .onShown(() => this.onPageShow())
    .onBackPressed(() => this.onBackPress())
    .expandSafeArea([SafeAreaType.KEYBOARD])
    .padding({ top: this.statusBarHeight, bottom: this.bottomNavBarHeight })
  }

  @Builder
  buildTitle() {
    Column() {
      Text(this.fileName)
        .fontSize($r('sys.float.ohos_id_text_size_headline8'))
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .padding({
          left: this.navMode === NavigationMode.Split ? $r('app.float.common_margin16') : $r('app.float.common_size8'),
          right: $r('app.float.common_margin16')
        })
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .height('100%')
        .width('100%')
        .alignSelf(ItemAlign.Center)
    }
  }

  @Builder
  buildContent() {
    Scroll() {
      Column() {
        if (this.needLoadThumbnail) {
          Column() {
            Image(this.checkBigImage() ? this.fileData.thumbUri : this.fileData.uri)
              .alt(this.fileData.thumbUri)
              .objectFit(ImageFit.Contain)
              .width('100%')
              .draggable(false)
              .interpolation(ImageInterpolation.High)
              .margin({ left: $r('app.float.common_size24'), right: $r('app.float.common_size24') })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          Column() {
            Image(ThumbnailUtil.getDefaultIconByType(this.fileData.thumbnailType))
              .objectFit(ImageFit.Contain)
              .width($r('app.float.common_size80'))
              .height($r('app.float.common_size80'))
              .draggable(false)
              .interpolation(ImageInterpolation.High)
              .margin({ bottom: $r('app.float.common_margin20') })
            Text(this.fileName)
              .textAlign(TextAlign.Start)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ left: $r('app.float.common_padding24'), right: $r('app.float.common_padding24') })
            Row() {
              Text(DateUtil.getPhoneDateText(this.fileData.mtime))
                .fontSize($r('app.float.common_font_size12'))
                .opacity($r('app.float.common_opacity6'))
                .margin({ top: $r('app.float.common_margin5') })
              Text(`${this.fileData.size ? ' - ' + renderSize(this.fileData.size) : ''}`)
                .fontSize($r('app.float.common_font_size12'))
                .opacity($r('app.float.common_opacity6'))
                .margin({ top: $r('app.float.common_margin5') })
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
      }
    }
    .scrollBar(BarState.Off)
    .layoutWeight(1)
  }

  @Builder
  showButton() {
    Column() {
      Button($r('app.string.preview'))
        .width($r('app.float.common_size224'))
        .height($r('app.float.common_size40'))
        .fontSize($r('sys.float.ohos_id_text_size_button1'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .onClick(() => {
          HiLog.infoPrivate(TAG, 'FilePreview click: ', this.fileData.uri);
          PreviewUtil.filePreview(this.fileData);
        })

      Button($r('app.string.otherApp'))
        .width($r('app.float.common_size224'))
        .height($r('app.float.common_size40'))
        .fontSize($r('sys.float.ohos_id_text_size_button1'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
        .margin({ top: $r('app.float.common_margin16') })
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .onClick(() => {
          if (this.fileData.mimeTypeObj.fileCategory === MimeType.FILE_CATEGORY_UNKNOWN) {
            this.otherAppsOpenDialog.open();
          } else {
            PreviewUtil.filePreview(this.fileData, PREVIEW_TYPE.PREVIEW_BY_APP);
          }
        })
    }
    .padding({ top: $r('sys.float.padding_level8'), bottom: $r('sys.float.padding_level8') })
  }

  private describePositionChange() {
    const isLandScape: boolean = (GlobalHolder.getInstance().getObject<boolean>(GlobalKey.IS_DIRECT_PHONE) &&
      this.orientation) || (DisplayUtil.isFoldable() && this.deviceFoldStatus === DisplayUtil.FOLD_STATUS_FOLDED &&
        this.orientation);
    this.heightPercent = isLandScape ? '60%' : '80%';
    this.heightCount = isLandScape ? $r('app.float.common_margin150') : $r('app.float.common_size492');
  }

  // 屏幕横竖屏变化
  getOrientation(): void {
    this.orientation = UiUtil.getOrientationStatus(this.display);
  }
}
