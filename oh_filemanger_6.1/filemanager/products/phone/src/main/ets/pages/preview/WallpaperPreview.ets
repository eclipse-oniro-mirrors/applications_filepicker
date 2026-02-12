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
  AbilityOrRouterParams,
  Constant,
  DisplayUtil,
  FileInfo,
  GlobalKey,
  HiLog,
  ObjectUtil,
  StringUtil,
  ThumbnailUtil
} from '@ohos/common';
import { ImmersiveData, SendData } from '../../base/extension/model/SendDataModel';
import { UIExtSessionManager } from '../../base/extension/UIExtSessionManager';
import { JSON } from '@kit.ArkTS';
import { wantConstant } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import uriPermissionManager from '@ohos.application.uriPermissionManager';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = 'WallpaperPreview';
const IMAGE_COMPLETE_EVENT: string = 'imageComplete';
const BACK_EVENT: string = 'back';
const SCREEN_BOARD_NAME = 'com.ohos.sceneboard';

@Component
export struct WallpaperPreview {
  private pageParams: AbilityOrRouterParams | Object = {} as AbilityOrRouterParams;
  @Consume('pageInfos') pageInfos: NavPathStack;
  @StorageLink('windowStatus') @Watch('onWindowStatusChange') windowStatus: number =
    window.WindowStatusType.FULL_SCREEN;
  @StorageLink('deviceFoldStatus') @Watch('onFoldStatusChange') deviceFoldStatus: number = DisplayUtil.getFoldStatus();
  @StorageLink(GlobalKey.DISPLAY_INFO) @Watch('onDisplayChange') display: string = '';
  private uri: string = '';
  private fileInfo: FileInfo = new FileInfo();
  /**
   * 缩略图路径
   **/
  private thumbnailUri: string = '';
  /**
   * 判断是否正在加载
   */
  @State isLoading: boolean = true;
  /**
   * 判断是否是深色模式
   */
  @StorageProp('isDarkMode') isDarkMode: boolean = false;
  private hasGrantPermission: boolean = false;
  @Consume @Watch('isOutsideFoldedChange') isOutsideFolded: boolean;
  @Consume isPreviewMode: boolean;
  private isFromPreviewPage: boolean = false;
  @State isLcdComplete: boolean = false;

  aboutToAppear(): void {
    // 若进入壁纸编辑时，已进入预览模式，则判断是从预览页面进入壁纸编辑
    if (this.isPreviewMode) {
      this.isFromPreviewPage = true;
    } else {
      this.isPreviewMode = true;
    }
    this.switchWallPaperLockMode();
    const params = this.pageParams as AbilityOrRouterParams;
    HiLog.infoPrivate(TAG, 'aboutToAppear:', JSON.stringify(params));
    if (ObjectUtil.isNullOrUndefined(params) || ObjectUtil.isNullOrUndefined(params.fileData)) {
      HiLog.warn(TAG, 'params or params.fileData is null.');
      return;
    }
    this.fileInfo = params.fileData;
    this.thumbnailUri = ThumbnailUtil.getThumbnailUri(this.fileInfo);
    this.uri = params.fileData.uri;
    HiLog.infoPrivate(TAG, 'fileDataURL:', this.uri);
  }

  aboutToDisappear(): void {
    HiLog.info(TAG, 'aboutToDisappear');
    // 退出方向锁定模式
    UIExtSessionManager.getInstance().sendSwitchWallPaperMode(false);
    // 撤销文件授权
    if (this.hasGrantPermission) {
      uriPermissionManager.revokeUriPermission(this.uri, SCREEN_BOARD_NAME);
    }
  }

  onDisplayChange(): void {
    // 旋转后再配置一次沉浸式
    this.sendEntryImmersiveModeEvent(true);
  }

  onWindowStatusChange(): void {
    // 离开全屏时，退出编辑页面
    if (this.windowStatus === window.WindowStatusType.FLOATING ||
      this.windowStatus === window.WindowStatusType.SPLIT_SCREEN) {
      this.onBackPress();
    }
  }

  onFoldStatusChange(): void {
    this.switchWallPaperLockMode();
  }

  // 直板机、Verde内屏、折叠机折叠态进入壁纸编辑页面后进竖屏并锁定方向
  switchWallPaperLockMode(): void {
    HiLog.info(TAG, `switchWallPaperLockMode deviceFoldStatus: ${this.deviceFoldStatus}`);
    if (DisplayUtil.isOutsideScreenDevice() || this.deviceFoldStatus === DisplayUtil.FOLD_STATUS_FOLDED ||
      !DisplayUtil.isFoldable()) {
      UIExtSessionManager.getInstance().sendSwitchWallPaperMode(true);
    } else {
      UIExtSessionManager.getInstance().sendSwitchWallPaperMode(false);
    }
  }

  isOutsideFoldedChange(): void {
    if (this.isOutsideFolded) {
      this.onBackPress();
    }
  }

  build() {
    NavDestination() {
      Stack() {
        UIExtensionComponent({
          bundleName: SCREEN_BOARD_NAME,
          abilityName: 'ThemeComponentExtAbility',
          parameters: {
            'ability.want.params.uiExtensionType': 'sys/commonUI',
            'nav': 'wallpaperEditor',
            'source': 'com.ohos.filemanager', // 类似 com.hmos.photo,图库
            'imageUrl': this.uri, // 图片url位置，目前支持预置资源目录/共享目录/媒体库/沙箱共享
            'thumbnailUrl': this.thumbnailUri, // 缩略图url位置，目前支持预置资源目录/共享目录/媒体库/沙箱共享
            'imageAesthetic': true, //是否需要美学构图,
            'ability.params.stream': [this.uri],
            'needResetClock': true, //是否需要重置时钟样式至默认值
          },
          flags: wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION,
        })
          .defaultFocus(true)
          .width('100%')
          .height('100%')
          .onError((error) => {
            HiLog.error(TAG, `UIExtensionComponent onError ${JSON.stringify(error)}`);
          })
          .onReceive((receiveData: Record<string, Object>) => {
            this.dealReceiveEvent(receiveData);
          })
          .onRemoteReady(() => {
            this.sendEntryImmersiveModeEvent(true);
          })

        if (this.isLoading) {
          // 先显示小缩略图，再显示清晰LCD，为后续显示更清晰的图片做过渡
          this.buildCacheImage(this.thumbnailUri)
        }
      }
    }
    .backgroundColor(Color.Black)
    .hideToolBar(true)
    .hideTitleBar(true)
    .onShown(() => this.onPageShow())
    .onHidden(() => this.onPageHide())
    .onBackPressed(() => this.onBackPress())
    .onWillDisappear(() => {
      this.sendEntryImmersiveModeEvent(false)
    })
    .width('100%')
    .height('100%')
  }

  onPageShow() {
    HiLog.info(TAG, 'onPageshow');
  }

  onPageHide() {
    HiLog.info(TAG, 'onPageHide');
  }

  onBackPress(): boolean {
    // 若是从预览页面进入的壁纸编辑则不需要退出预览模式
    if (!this.isFromPreviewPage) {
      this.isPreviewMode = false;
    }
    this.pageInfos.pop({});
    return true;
  }

  sendEntryImmersiveModeEvent(immersiveModeFlag: boolean): void {
    let data: ImmersiveData = {
      isPreviewMode: immersiveModeFlag,
      isFullScreen: immersiveModeFlag
    };
    UIExtSessionManager.getInstance().sendEntryImmersiveModeEvent(data);
  }

  dealImageCompleteEvent(flag: boolean): void {
    // 非媒体库文件此时直接显示壁纸编辑页面
    if (flag) {
      this.isLoading = false;
    }
  }

  dealBackEvent(backFlag: boolean): void {
    if (backFlag) {
      // 退出壁纸编辑模式时，页面回退
      this.onBackPress();
    }
  }

  dealReceiveEvent(receiveData: Record<string, Object>): void {
    if (ObjectUtil.isNullOrUndefined(receiveData)) {
      HiLog.warn(TAG, `onReceive: sendData is null.`);
      return;
    }
    HiLog.infoPrivate(TAG, `UIExtensionComponent onReceive:`, `${JSON.stringify(receiveData)}`);
    Object.keys(receiveData).forEach(key => {
      switch (key) {
        case IMAGE_COMPLETE_EVENT:
          if (!ObjectUtil.isNullOrUndefined(receiveData[key])) {
            HiLog.warn(TAG, `onReceive: Deal imageCompleteEvent: ${receiveData[key]}.`);
            this.dealImageCompleteEvent(receiveData[key] as boolean);
          }
          break;
        case BACK_EVENT:
          if (!ObjectUtil.isNullOrUndefined(receiveData[key])) {
            HiLog.warn(TAG, `onReceive: Deal backEvent: ${receiveData[key]}.`);
            this.dealBackEvent(receiveData[key] as boolean);
          }
          break;
      }
    })
  }

  @Builder buildCacheImage(thumbUri: string) {
    Stack() {
      // 先显示缩略图，为后续显示更清晰的图片做过渡
      MediaCachedImage(thumbUri)
        .fitOriginalSize(true)
        .objectFit(ImageFit.Cover)
        .sourceSize(
          { width: Constant.CACHED_IMAGE_CACHE_SOURCE_SIZE, height: Constant.CACHED_IMAGE_CACHE_SOURCE_SIZE }
        )
        .width('100%')
        .height('100%')
        .scale({ x: 1.1, y: 1.1 })
        .onComplete((): void => {
          this.isLcdComplete = true;
        })
        .onError((): void => {
          HiLog.warn(TAG, 'big lcd load error.');
        })

      if (!this.isLcdComplete) {
        MediaCachedImage(ThumbnailUtil.getSmallThumbnailUri(this.fileInfo))
          .fitOriginalSize(true)
          .objectFit(ImageFit.Cover)
          .sourceSize(
            { width: Constant.CACHED_IMAGE_CACHE_SOURCE_SIZE, height: Constant.CACHED_IMAGE_CACHE_SOURCE_SIZE }
          )
          .width('100%')
          .height('100%')
          .scale({ x: 1.1, y: 1.1 })
          .onError((): void => {
            HiLog.warn(TAG, 'small lcd load error.');
          })
      }
    }
    .width('100%')
    .height('100%')
  }
}