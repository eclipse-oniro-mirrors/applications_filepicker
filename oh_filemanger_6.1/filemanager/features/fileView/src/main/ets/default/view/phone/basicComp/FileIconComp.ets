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
  BundleResourceUtil,
  HiLog,
  FileMimeTypeUtil,
  MyPhoneConstant,
  ExternalStorageUtil,
  FileSourceType,
  Constant,
  VirtualUri,
  ThumbnailLoad,
  FileUtil,
  ThumbnailUtil,
  StringUtil,
  CompId,
  EventBus,
  UiUtil,
  ParseUtil,
  FileInfo,
  FormatListItem,
  GlobalHolder,
} from '@ohos/common';
import { PhoneItemViewModel } from '../../../viewModel/PhoneItemViewModel';
import { CachedImageModifier, ColumnModifier, ImageModifier } from '../../../viewModel/CustomedModifier';

const TAG: string = 'FileIconComp';

enum IconType {
  NONE,
  FOLDER,
  CACHE_IMAGE
}

@Component
export struct FileIconComp {
  @Prop isFileSourceView: boolean = false;
  private itemViewModel: PhoneItemViewModel = new PhoneItemViewModel(new FileInfo());
  private useCachedImage: boolean = false;
  @Consume isOutsideFolded: boolean;
  @Link isCachedImageLoad: boolean;
  @Prop isFromLongPress: boolean = false;
  @Prop isShowFolderSubCount: boolean;
  private isShowBorder: boolean = false;
  private isShowAlbumCover: boolean = false;
  @Prop gridCompactLayout: boolean;
  @Prop isListView: boolean;

  @Consume @Watch('onPreviewFileUriChange') previewFileUri: string;
  @Consume @Watch('onIsPageShowAllChange') isPageShowAll: boolean;

  @StorageProp('isDarkMode') isDarkMode: boolean = false;
  @State iconType: IconType = IconType.NONE
  private cachedImageModifier: CachedImageModifier = new CachedImageModifier();
  private columnModifier: ColumnModifier = new ColumnModifier();
  private imageModifier: ImageModifier = new ImageModifier();

  private geometryTransitionId: string = '';

  aboutToAppear(): void {
    this.initStates();
  }

  aboutToReuse(params: Record<string, Object>): void {
    this.itemViewModel = params?.itemViewModel as PhoneItemViewModel;
    this.initStates();
    if (this.iconType === IconType.CACHE_IMAGE) {
      this.updateCacheImage();
    }
    this.columnModifier.attribute?.geometryTransition(this.geometryTransitionId);
  }

  // 组件首次和复用的时候的共同初始化逻辑
  initStates(): void {
    this.isShowAlbumCover = !StringUtil.isEmpty(this.itemViewModel?.fileInfo.coverUri);
    this.useCachedImage = this.isShowAlbumCover ? true : this.itemViewModel.fileInfo.useCacheImage;
    this.setIconType();
    this.geometryTransitionId = this.getGeometryTransitionId();
  }

  aboutToRecycle(): void {
    this.columnModifier.attribute?.geometryTransition('');
    this.isShowBorder = false;
  }

  onUseCachedImageChange(useCachedImage: boolean): void {
    this.useCachedImage = useCachedImage;
    this.updateCacheImage();
  }

  onPreviewFileUriChange() {
    this.setIconType();
    this.updateAttributeGeometryTransition();
  }

  onIsPageShowAllChange() {
    this.setIconType();
    this.updateAttributeGeometryTransition();
  }

  updateCachedImageBorderWidth(): void {
    this.cachedImageModifier.attribute?.borderWidth(this.getBorderWidth());
  }

  updateAttributeGeometryTransition(): void {
    if (this.geometryTransitionId !== this.getGeometryTransitionId()) {
      this.geometryTransitionId = this.getGeometryTransitionId();
      this.columnModifier.attribute?.geometryTransition(this.geometryTransitionId);
    }
  }

  private setIconType(): void {
    if (this.itemViewModel.fileInfo.uri !== this.previewFileUri || this.isPageShowAll) {
      if (this.itemViewModel.fileInfo.isFolder && !this.isShowAlbumCover) {
        this.iconType = IconType.FOLDER;
      } else {
        this.iconType = IconType.CACHE_IMAGE;
      }
    } else {
      this.iconType = IconType.NONE;
    }
  }

  build() {
    if (this.iconType !== IconType.NONE) {
      Column() {
        if (this.iconType === IconType.FOLDER) {
          FolderIcon({
            itemViewModel: this.itemViewModel,
            isShowFolderSubCount: this.isShowFolderSubCount,
            isFileSourceView: this.isFileSourceView
          })
        } else {
          Image(this.getThumbnail())
            .objectFit(this.getCacheImageObjectFit())
            .borderRadius(this.getBorderRadius())
            .alt(this.getThumbnailAlt())
            .borderColor($r('sys.color.ohos_id_color_fourth'))
            .sourceSize({
              width: Constant.CACHED_IMAGE_CACHE_SOURCE_SIZE,
              height: Constant.CACHED_IMAGE_CACHE_SOURCE_SIZE
            })
            .attributeModifier(this.cachedImageModifier)
            .borderWidth(this.getBorderWidth())
            .interpolation(ImageInterpolation.High)
            .width(this.getCacheImageWidth())
            .height('100%')
            .aspectRatio(this.getCacheImageAspectRatio())
            .draggable(false)
            .onError((e: ImageError) => {
              HiLog.warn(TAG, `load thumbnail on error`);
              if (this.isShowAlbumCover || this.isShowDefaultMediaIcon()) {
                HiLog.warn(TAG, `load thumbnail width default cover`);
                return;
              }
              this.isShowBorder = false;
              this.onUseCachedImageChange(false);
            })
            .onComplete((event) => {
              HiLog.warn(TAG, `load thumbnail on complete`);
              if (this.isShowDefaultMediaIcon()) {
                return;
              }
              if (!event) {
                return;
              }
              if (event.width === 0 || event.height === 0 || this.isShowAlbumCover) {
                return;
              }
              this.isShowBorder = true;
              this.updateCachedImageBorderWidth();
              this.setCacheImageLoaded();
            })
        }
      }
      .geometryTransition(this.geometryTransitionId)
      .transition(TransitionEffect.IDENTITY)
      .attributeModifier(this.columnModifier)
    } else {
      Blank()
    }
  }

  // 组件复用时，如果子组件修改了父组件的状态变量，会导致父组件后续状态不会再刷新，暂时通过setTimeout规避
  setCacheImageLoaded() {
    let cacheImageLoadTimeout = setTimeout(() => {
      this.isCachedImageLoad = true;
      clearTimeout(cacheImageLoadTimeout);
    }, 1);
  }

  getGeometryTransitionId(): string {
    return this.previewFileUri === this.itemViewModel.fileInfo.uri ?
      UiUtil.getGeometryIdStr(this.itemViewModel.fileInfo.uri) : '';
  }

  getCacheImageWidth() {
    if (this.isShowDefaultMediaIcon()) {
      return this.isListView ? '100%' : '88%'
    }
    return '100%';
  }

  getCacheImageObjectFit() {
    if (this.isShowDefaultMediaIcon()) {
      return ImageFit.Contain;
    }
    return ImageFit.Cover;
  }

  updateCacheImage() {
    this.cachedImageModifier.updateConstructorParams(this.getThumbnail());
    this.cachedImageModifier.attribute?.objectFit(this.getCacheImageObjectFit());
    this.cachedImageModifier.attribute?.alt(this.getThumbnailAlt());
    this.cachedImageModifier.attribute?.borderWidth(this.getBorderWidth());
    this.cachedImageModifier.attribute?.borderRadius(this.getBorderRadius());
    this.cachedImageModifier.attribute?.width(this.getCacheImageWidth());
    this.cachedImageModifier.attribute?.aspectRatio(this.getCacheImageAspectRatio());
  }

  getCacheImageAspectRatio() {
    if (this.isShowDefaultMediaIcon()) {
      return 1;
    }
    return 0;
  }

  getBorderWidth() {
    if (this.isShowDefaultMediaIcon()) {
      return this.gridCompactLayout ? $r('app.float.common_size05') : 0;
    }
    return this.isShowBorder ||
      this.isShowAlbumCover ? $r('app.float.common_size05') : $r('app.float.common_size0');
  }

  getBorderRadius() {
    if (this.isShowDefaultMediaIcon()) {
      return 0;
    }
    return this.isShowAlbumCover ? $r('sys.float.corner_radius_level8') :
      (this.gridCompactLayout ? 0 :
        (this.isListView ? $r('app.float.album_borderRadius_4') : $r('sys.float.corner_radius_level8')));
  }

  private isShowDefaultMediaIcon() {
    return !this.useCachedImage;
  }

  getThumbnail() {
    if (this.isShowDefaultMediaIcon()) {
      let thumbnailType = this.itemViewModel.fileInfo?.thumbnailType ?? '';
      if (this.gridCompactLayout) {
        thumbnailType = FormatListItem.PLACE_HOLDER;
      }
      if (thumbnailType === FormatListItem.IMAGE) {
        thumbnailType = FormatListItem.DEFAULT_IMAGE;
      } else if (thumbnailType === FormatListItem.MP4) {
        thumbnailType = FormatListItem.DEFAULT_VIDEO;
      }
      if (ThumbnailLoad.resourcePixelMap.size === 0) {
        try {
          return GlobalHolder.getInstance()
            .getCommonContext()?.resourceManager?.getDrawableDescriptor(ThumbnailUtil.thumbnailMap.get(thumbnailType));
        } catch (error) {
          HiLog.error(TAG, `get drawable failed ${error?.code}, error.message: ${error?.message}`);
        }
        return;
      }
      return ThumbnailLoad.getImageThumbnailByType(thumbnailType);
    } else {
      return ThumbnailUtil.getFileIconCompThumbnailUri(this.itemViewModel?.fileInfo);
    }
  }

  getThumbnailAlt() {
    if (this.isShowDefaultMediaIcon()) {
      // ALT的默认值是null
      return null;
    } else {
      return ThumbnailLoad.getImageThumbnailByType(this.itemViewModel.fileInfo?.thumbnailType ?? '');
    }
  }

  private isImageOrVideo(): boolean {
    return FileMimeTypeUtil.isImage(this.itemViewModel.fileInfo.mimeTypeObj) ||
      FileMimeTypeUtil.isVideo(this.itemViewModel.fileInfo.mimeTypeObj);
  }
}

@Component
struct FolderIcon {
  private itemViewModel: PhoneItemViewModel = new PhoneItemViewModel(new FileInfo());
  @State isEmptyFolder: boolean = this.itemViewModel.fileInfo.subFileCount < 1;
  @StorageProp('isDarkMode') @Watch('onIsDarkModeChange') isDarkMode: boolean = false;
  @State isFileSourceView: boolean = false;
  @Consume isListView: boolean;
  @Consume @Watch('onIsOutsideFoldedChange') isOutsideFolded: boolean;
  @State folderIcon: string | Resource = '';
  @State appIcon: ResourceStr = '';
  @State appIconSize: Length = 0;
  @State appIconMargin: Margin | Length = 0;
  @Prop @Watch('updateFolderIcon') isShowFolderSubCount: boolean;
  @State appCloneTextSize: Length = 0;
  @State appCloneOffSet: Position = { x: 0, y: 0 };
  private cloneIndex: number = -1;

  aboutToAppear(): void {
    // 注意组件复用是否也要修改
    this.initStates();
  }

  aboutToReuse(params: Record<string, Object>): void {
    this.itemViewModel = params?.itemViewModel as PhoneItemViewModel;
    this.initStates();
  }

  // 组件首次和复用的时候的共同初始化逻辑
  initStates(): void {
    // 小于0先按照非空处理
    this.isEmptyFolder = this.itemViewModel.fileInfo.subFileCount === 0;
    this.folderIcon = this.getFolderIcon();
    this.appIcon = this.getAppIcon();
    this.updateAppIconInfo();
  }

  onIsOutsideFoldedChange() {
    this.updateAppIconInfo();
  }

  onIsDarkModeChange() {
    this.updateFolderIcon();
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Image(this.folderIcon)
        .objectFit(ImageFit.Contain)
        .autoResize(false)
        .width(this.isListView ? '100%' : '88%')
        .height('auto')
        .interpolation(ImageInterpolation.High)
        .draggable(false)
        .onError((error) => {
          HiLog.errorPrivate(TAG,
            'load FolderIcon fail' + ', error: ' + error.message, `fileUri:${this.itemViewModel.fileInfo.uri}`);
        })
        .onComplete(() => {
          HiLog.debugPrivate(TAG, `load FolderIcon success, fileUri:`, this.itemViewModel.fileInfo.uri);
        })
        .zIndex(0)
        .borderRadius(this.getBorderRadius())
        .id(CompId.FOLDER_ICON)

      if (this.appIcon) {
        Image(this.appIcon)
          .objectFit(ImageFit.Contain)
          .width(this.appIconSize)
          .height(this.appIconSize)
          .margin(this.appIconMargin)
          .draggable(false)
          .zIndex(5)
        if (this.cloneIndex > 0) {
          Row() {
            SymbolGlyph($r(`sys.symbol.spare_${this.cloneIndex}`))
              .fontWeight(FontWeight.Lighter)
              .fontSize(this.appCloneTextSize)
              .fontColor([$r('sys.color.icon_on_primary')])
          }
          .draggable(false)
          .padding(2)
          .backgroundColor($r('sys.color.background_emphasize'))
          .borderRadius('50%')
          .align(Alignment.Center)
          .offset(this.appCloneOffSet)
          .zIndex(5)
        }
      }
    }
  }

  private getBorderRadius(): number {
    return 0;
  }

  private getFolderIcon(): Resource | string {
    if (!MyPhoneConstant.isSystemFolder(ExternalStorageUtil.getParentUri(this.itemViewModel.fileInfo.uri),
      this.itemViewModel.fileInfo.fileName, this.itemViewModel.fileInfo.isFolder)) {
      if (this.isEmptyFolder) {
        return this.isDarkMode ? $r('app.media.ic_normal_dark_folder_empty') : $r('app.media.ic_normal_folder_empty');
      }
      return this.isDarkMode ? $r('app.media.ic_normal_dark_folder') : $r('app.media.ic_normal_folder');
    }
    return MyPhoneConstant.getFolderImage(this.isDarkMode, this.itemViewModel.fileInfo.fileName, this.isEmptyFolder);
  }

  private getAppIcon(): ResourceStr {
    if (this.isFileSourceView && BundleResourceUtil.fileSourceShowIconMap.hasKey(this.itemViewModel.fileInfo.uri)) {
      return BundleResourceUtil.fileSourceShowIconMap.get(this.itemViewModel.fileInfo.uri);
    }
    if (this.itemViewModel.fileInfo.fileName === MyPhoneConstant.MY_PHONE_GALLERY ||
      this.itemViewModel.fileInfo.uri === VirtualUri.GALLERY) {
      return FileUtil.getApplicationIconOrLabel(Constant.GALLERY_BUNDLE_NAME);
    }
    return '';
  }

  private updateFolderIcon() {
    this.isEmptyFolder = this.itemViewModel.fileInfo.subFileCount < 1;
    this.folderIcon = this.getFolderIcon();
  }

  private updateAppIconInfo() {
    if (this.itemViewModel?.fileInfo?.uri === VirtualUri.GALLERY && this.itemViewModel?.fileInfo.isVirtualGallery) {
      this.appIconSize = $r('app.float.common_size32');
      this.appIconMargin = { bottom: $r('app.float.common_size10') };
      return;
    }
    this.appIconSize = this.isListView ? $r('app.float.common_size15') :
      (this.isOutsideFolded ? $r('app.float.common_size20') : $r('app.float.common_size32'));
    this.appIconMargin = this.isListView ? { bottom: '3vp' } :
      (this.isOutsideFolded ? { bottom: $r('app.float.common_size6') } : { bottom: $r('app.float.common_size10') });

    this.appCloneTextSize = this.isListView ? $r('app.float.common_size4') : $r('app.float.common_size6');
    this.appCloneOffSet = this.isListView  ? { x: 7, y: -2 } : { x: 16, y: -10 };
  }
}