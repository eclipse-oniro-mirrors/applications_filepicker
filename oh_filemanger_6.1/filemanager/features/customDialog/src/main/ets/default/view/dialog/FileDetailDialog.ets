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
  AppDataPathUtil,
  ArrayUtil,
  BundleResourceUtil,
  Constant,
  DateUtil,
  DFX,
  EventBus,
  FileInfo,
  FileMimeTypeUtil,
  FileSourceType,
  FileUtil,
  getResourceString,
  GlobalHolder,
  HiLog,
  LocalStorageConst,
  ObjectUtil,
  PAGE_ROUTE_CONST,
  PageFinishType,
  renderSize,
  TaskManager,
  UEUtil,
  UiUtil,
  VirtualUri,
  StorageDeviceManager,
  MediaMetaDataUtil,
  MediaMetaData,
  GlobalKey,
  OpenMediaUtil,
  StringUtil,
  DeviceConfig
} from '@ohos/common';
import lazy {
  QueryGalleryFolderSizeTask,
  QueryMediaSizeAndDurationTask,
  QueryLocalFolderSizeTask
} from '@ohos/common/indexLazyLoad';
import { DialogButton } from './DialogComponent';
import lazy { PhotoAccessUtil } from '@ohos/common/indexLazyLoad';
import { FileDeleteDialog } from './FileDeleteDialog';

const TAG = 'FileDetailDialog';
const MULTIPLE = 'x';
const ENCRYPTION = '***';
const ERROR_SIZE = '-1 x -1';

@Component
export struct FileDetailDialog {
  @LocalStorageProp(LocalStorageConst.BOTTOM_NAV_BAR_HEIGHT) bottomNavBarHeight: number = 0;
  private fileInfo: FileInfo = new FileInfo();
  private isMyPhonePage: boolean = false;
  private fromPage?: string;
  private isRecentDeletePage: Boolean = false;
  private isPreviewForbidJump: boolean = false;
  private queryMediaSizeAndDurationTask?: QueryMediaSizeAndDurationTask;
  @State isFolder: boolean = false;
  @State fileSize: string = '';
  @State createTime: number = 0;
  @Consume('pageInfos') pageInfos: NavPathStack;
  @Consume('navMode') navMode: NavigationMode;
  @Consume('currentNavItem') currentNavItem: string;
  private animationTime: number = 300;
  private scroller = new Scroller();
  /**
   * 判断是否是深色模式
   */
  @StorageProp('isDarkMode') isDarkMode: boolean = false;
  @State detailInfoList: DetailInfo[] = [];
  @State fileSizeChange: boolean = false;
  @State fileCTimeChange: boolean = false;
  @Prop isOutsideFolded: boolean = false;
  @Link @Watch('OnPageShowChange') isOnPageShow: boolean;
  @State bigFontAutoHalfSpace: ResourceStr = $r('app.float.common_padding12');
  private isJumpFromSettings: boolean = false; // 是否从设置页面跳转

  private OnPageShowChange() {
    if (this.isOnPageShow) {
      this.setBigFontAutoHalfSpace();
    }
  }

  aboutToAppear() {
    if (this.fileInfo) {
      this.isFolder = this.fileInfo.isFolder;
    }
    HiLog.infoPrivate(TAG, `aboutToAppear mtime = ${this.fileInfo?.mtime}`, `, fileName = ${this.fileInfo?.fileName}`);
    this.getFileCreateTime();
    this.getFileSize();
    this.initDetailInfoList();
    this.initMoreDetailInfoList();
  }

  build() {
    Flex({ direction: FlexDirection.Column }) {
      List({ scroller: this.scroller }) {
        ForEach(this.detailInfoList, (item: DetailInfo, index: number) => {
          ListItem() {
            Column() {
              DetailItem({
                detailInfo: item,
                fileSize: this.fileSize,
                fileSizeChange: this.fileSizeChange,
                createTime: this.createTime,
                fileCTimeChange: this.fileCTimeChange,
                isLastItem: index === this.detailInfoList.length - 1,
                bigFontAutoHalfSpace: this.bigFontAutoHalfSpace,
                isJumpFromSettings: this.isJumpFromSettings
              })
            }
          }
        }, (item: DetailInfo, index: number) => '' + item.itemKey.id + item.itemValue)
      }
      .divider({
        strokeWidth: $r('app.float.divider_strokeWidth_point_five'),
        color: $r('sys.color.ohos_id_color_list_separator')
      })
      .padding({
        left: $r('app.float.common_margin16'),
        right: $r('app.float.common_padding15'),
      })
      .flexGrow(1)
      .scrollBar(BarState.Auto)

      if (this.isRecentDeletePage) {
        Row() {
          DialogButton({
            text: $r('app.string.restore'),
            bgColor: $r('sys.color.ohos_id_color_button_normal'),
            isDisabled: false,
            click: () => {
              this.restoreFile();
              UEUtil.reportRestoreFile(DFX.OperateSource.DETAIL_DIALOG, 1);
              EventBus.emit(Constant.EVENTS.SHOW_RECENT_DELETED_FILE_DETAIL_DIALOG, undefined, false);
            }
          })
          Divider()
            .vertical(true)
            .height($r('app.float.common_size24'))
          DialogButton({
            text: $r('app.string.delete_permanent'),
            color: $r('app.color.delete_confirm_text_color'),
            bgColor: $r('sys.color.ohos_id_color_button_normal'),
            isDisabled: false,
            click: () => {
              HiLog.info(TAG, `click hardDeleteFileButton`);
              UEUtil.reportDeleteFile(DFX.PageName.RECENT_DELETE, DFX.DeleteType.DELETE,
                DFX.OperateSource.DETAIL_DIALOG, 1);
              this.fileDeleteDialog.open();
              EventBus.emit(Constant.EVENTS.SHOW_RECENT_DELETED_FILE_DETAIL_DIALOG, undefined, false);
            }
          })
        }
        .margin({ top: $r('app.float.common_padding12') })
        .padding({ bottom: this.bottomNavBarHeight > 0 ? this.bottomNavBarHeight : $r('app.float.common_padding28') })
        .flexShrink(0)
      }
    }
    .padding({
      bottom: this.bottomNavBarHeight
    })
    .margin({
      bottom: $r('app.float.common_margin8')
    })
    .borderRadius({
      topLeft: $r('sys.float.ohos_id_corner_radius_dialog'),
      topRight: $r('sys.float.ohos_id_corner_radius_dialog')
    })
    .height(this.isOutsideFolded ? '100%' : undefined)
  }

  aboutToDisappear() {
    this.queryMediaSizeAndDurationTask?.cancelTask();
  }

  private restoreFile() {
    EventBus.emit(Constant.EVENTS.START_DELETE_RESTORE_FILE_TASK, [this.fileInfo], Constant.OPERATION_TYPE.RESTORE);
  }

  private fileDeleteDialog: CustomDialogController = new CustomDialogController({
    builder: FileDeleteDialog({
      title: $r('app.plural.delete_confirm_dialog_title', 1, 1),
      content: $r('app.string.delete_complete_tips'),
      confirmButtonText: $r('app.string.delete'),
      confirm: (): void => this.fileDelete()
    }),
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      if (GlobalHolder.getInstance().getObject(Constant.EVENTS.EXIT_MULTI_STATE)) {
        EventBus.emit(Constant.EVENTS.EXIT_MULTI_STATE);
        GlobalHolder.getInstance().deleteObject(Constant.EVENTS.EXIT_MULTI_STATE);
      }
      dismissDialogAction.dismiss();
    },
    autoCancel: false,
    offset: { dx: $r('app.float.dialog_offset_0'), dy: $r('app.float.dialog_offset_12') },
    alignment: DialogAlignment.Bottom,
  })

  private fileDelete() {
    EventBus.emit(
      Constant.EVENTS.START_DELETE_RESTORE_FILE_TASK, [this.fileInfo], Constant.OPERATION_TYPE.HARD_DELETE, true);
  }

  private clickFilePath(isNeedCloseDialog: boolean = false) {
    if (isNeedCloseDialog) {
      setTimeout(() => {
        this.closeFileDetailDialog();
      }, this.animationTime)
    }
    switch (this.fromPage) {
      case Constant.FROM_TYPE.MY_PHONE:
        EventBus.emit(Constant.EVENTS.MY_PHONE_CLICK, isNeedCloseDialog);
        break;
      default:
        HiLog.info(TAG, 'from page :' + this.fromPage);
        break;
    }
  }

  private getFileSize() {
    if (this.isFolder) {
      this.fileSize = getResourceString($r('app.string.get_folder_size_tips'));
      if (this.fileInfo) {
        if (FileUtil.isGalleryAddress(this.fileInfo.uri)) {
          const ctx = GlobalHolder.getInstance().getExtensionContext();
          let task: QueryGalleryFolderSizeTask = new QueryGalleryFolderSizeTask(ctx, this.fileInfo,
            (folderSize: number) => {
              this.fileSize = renderSize(folderSize);
              this.fileSizeChange = true;
              HiLog.infoPrivate(TAG, 'Gallery fileSize is', this.fileSize);
            });
          TaskManager.getInstance().execute<number>(task);
        } else {
          const task: QueryLocalFolderSizeTask = new QueryLocalFolderSizeTask(this.fileInfo.relativePath,
            this.fileInfo.uri,
            this.fromPage ?? '',
            (folderSize: number) => {
              if (this.fileInfo.relativePath === VirtualUri.LOCAL_PATH_HEAD) {
                this.fileSize = renderSize(folderSize, Constant.BYTE.ONE_KB);
              } else {
                this.fileSize = renderSize(folderSize);
              }
              this.fileSizeChange = true;
            });
          TaskManager.getInstance().execute<number>(task);
        }
      }
      return;
    }
    if (this.fileInfo) {
      this.fileSize = renderSize(this.fileInfo.size);
    }
  }

  private async getFileCreateTime() {
    const path = FileUtil.getPathFromUri(this.fileInfo?.uri!!);
    FileUtil.getFileStatByFs(path).then((fileStat) => {
      if (!!(fileStat)) {
        this.createTime = fileStat.atime * Constant.TIME.ONE_SECOND;
        HiLog.info(TAG, `getFileCreateTime createTime = ${this.createTime}`);
        this.fileCTimeChange = true;
      }
    });
  }

  private isPathItemEnable(): boolean {
    let ret = !(
      // 如果图库文件的父路径为空，则不支持跳转
      (this.fileInfo.uri === VirtualUri.GALLERY && this.fileInfo.parentPathForDetail === '') ||
      this.isPreviewForbidJump);
    return ret;
  }

  private getFilePathForDetail(): string {
    let path = '';
    let fileInfoData: FileInfo | undefined = this.fileInfo;
    if (!fileInfoData) {
      return path;
    }
    if (fileInfoData.isExternalStorageDeviceFile) {
      path += fileInfoData.rootName || getResourceString(DeviceConfig.getInstance().config.myDevice);
    } else {
      if (fileInfoData.isGallery) {
        path += getResourceString($r('app.string.pc_gallery'));
      } else if (FileUtil.isBundleNameInDownloadDir(fileInfoData.uri)) {
        path += getResourceString(DeviceConfig.getInstance().config.myDevice) + '/Download';
      } else {
        path += getResourceString(DeviceConfig.getInstance().config.myDevice);
      }
    }
    if (fileInfoData.uri !== Constant.MY_PHONE_URI) {
      const parentAlbumName = PhotoAccessUtil.getSysResourceParentAlbumName(this.fileInfo.parentAlbumName ?? '');
      path += FileUtil.isMediaUri(fileInfoData.parentPathForDetail) ?
        UiUtil.translateMediaUriName(parentAlbumName ?? '') :
        FileUtil.replaceFileName(UiUtil.translateFilePath(fileInfoData.parentPathForDetail));
    }
    return path;
  }

  private getFileOriginalPathForDetail() {
    if (!this.fileInfo) {
      return '';
    }
    let tempRelativePath = '';
    let startPosition = 0;
    for (let i = 0; i < 3; i++) {
      startPosition = this.fileInfo.srcPath.indexOf('/', startPosition);
      startPosition++;
    }
    startPosition = this.fileInfo.srcPath.indexOf('/', startPosition);
    tempRelativePath = this.fileInfo.srcPath.substring(startPosition);
    return this.getFilePathForDetail() + tempRelativePath;
  }

  private closeFileDetailDialog() {
    EventBus.emit(Constant.EVENTS.FILE_DETAIL_SHOW, false);
  }

  private initDetailInfoList() {
    if (!this.fileInfo) {
      HiLog.error(TAG, 'initDetailInfoList error, fileInfo is undefined');
      return;
    }

    this.detailInfoList.push({
      itemKey: this.isFolder ? $r('app.string.folder_name') : $r('app.string.file_name'),
      itemValue: this.fileInfo.relativePath === VirtualUri.LOCAL_PATH_HEAD ? '0' :
        UiUtil.translateFileNameByUri(this.fileInfo.uri, this.fileInfo.fileName, this.fileInfo.isFolder)
    })

    if (!this.isFolder && !this.isRecentDeletePage) {
      this.detailInfoList.push({
        itemKey: $r('app.string.file_type'),
        itemValue: this.fileInfo.mimeTypeObj.mimeType
      })
    }

    this.detailInfoList.push({
      itemKey: this.isFolder ? $r('app.string.folder_size') : $r('app.string.file_size'),
      itemValue: this.fileSize,
      isFolderSize: this.isFolder
    });

    if (this.isRecentDeletePage) {
      this.detailInfoList.push({
        itemKey: $r('app.string.detail_delete_time', ''),
        itemValue: DateUtil.get24HourClickDate(this.fileInfo.deleteTime, true)
      })
      return;
    }

    if (this.isFolder) {
      if (this.fileInfo.subFileCount !== Constant.FOLDER_SUB_DEFAULT) {
        this.detailInfoList.push({
          itemKey: $r('app.string.include'),
          itemValue: getResourceString($r('app.string.select_num'), this.fileInfo.subFileCount)
        })
      } else {
        this.detailInfoList.push({
          itemKey: $r('app.string.include'),
          itemValue: '--'
        })
      }
    }

    if (this.fileInfo.uri.startsWith(FileUtil.URI_INTERNAL)) {
      this.detailInfoList.push({
        itemKey: $r('app.string.created_time'),
        itemValue: this.createTime > 0 ? DateUtil.get24HourClickDate(this.createTime, true) : '',
        isCTime: true
      })
    }

    if (!this.fileInfo.uri.startsWith(FileUtil.URI_GALLERY)) {
      this.detailInfoList.push({
        itemKey: $r('app.string.modified_time'),
        itemValue: DateUtil.get24HourClickDate(this.fileInfo.mtime, true)
      })
    }
  }

  private initMoreDetailInfoList() {
    let needUpdateMetaData = false;

    if (this.isRecentDeletePage) {
      this.detailInfoList.push({
        itemKey: $r('app.string.original_location'),
        itemValue: this.getFileOriginalPathForDetail()
      })
      return;
    } else {
      // 外部拉起聚合视频页需要屏蔽详情的跳转功能
      if (!OpenMediaUtil.isOpenMedia()) {
        this.detailInfoList.push({
          itemKey: $r('app.string.where'),
          itemValue: this.getFilePathForDetail(),
          isPathItem: this.isPathItemEnable(),
          itemClickFun: (): void => this.isNotRecentDeletePageClickFun()
        })
      }
    }

    if (this.isShowDimension()) {
      this.detailInfoList.push({
        itemKey: $r('app.string.dimension'),
        itemValue: this.getItemSizeValue()
      })
    }

    if (this.isShowDuration()) {
      const needUpdateDuration = false;
      needUpdateMetaData = needUpdateDuration || needUpdateMetaData;
      this.detailInfoList.push({
        itemKey: $r('app.string.duration'),
        itemValue: needUpdateDuration ? $r('app.string.loading') : DateUtil.formatDuration(this.fileInfo.duration)
      })
    }
  }

  getItemSizeValue(): string {
    let sizeValue: string = this.fileInfo.picWidth + MULTIPLE + this.fileInfo.picHeight;
    if (this.fileInfo.size !== 0 && this.fileInfo.picHeight === 0 && this.fileInfo.picWidth === 0) {
      // 非空文件尺寸异常显示为-1 x -1
      return ERROR_SIZE;
    }
    return sizeValue;
  }

  private isShowDimension() {
    return this.fileInfo &&
      (FileMimeTypeUtil.isVideo(this.fileInfo.mimeTypeObj) || FileMimeTypeUtil.isImage(this.fileInfo.mimeTypeObj));
  }

  private isShowDuration() {
    return this.fileInfo &&
      (FileMimeTypeUtil.isVideo(this.fileInfo.mimeTypeObj) || FileMimeTypeUtil.isAudio(this.fileInfo.mimeTypeObj));
  }

  private isNotRecentDeletePageClickFun() {
    let isOnCurrentPage: boolean = this.isMyPhonePage;

    this.closeFileDetailDialog();
    if (isOnCurrentPage) {
      // 在当前页面上弹窗（内部存储）时，直接关闭弹窗即可
      HiLog.warn(TAG, 'isNotRecentDeletePageClickFun isMyPhonePage = ' + this.isMyPhonePage);
      return;
    }
    this.dealOpenFolder();
  }

  // 打开文件所在文件夹
  private dealOpenFolder() {
    let destination = PAGE_ROUTE_CONST.MY_PHONE;
    let sourceFlag = false;
    let title: string = "";
    let bundleName: string = "";
    let parentPath: string;
    if (FileUtil.isMediaUri(this.fileInfo.uri)) {
      parentPath = this.fileInfo.parentPathForDetail ?? VirtualUri.GALLERY;
    } else if (FileUtil.isBundleNameInDownloadDir(this.fileInfo.uri)) {
      parentPath = FileUtil.getDownloadPathByBundleName(this.fileInfo.uri);
    } else if (this.fileInfo.relativePath === VirtualUri.LOCAL_PATH_HEAD) {
      parentPath = this.fileInfo.uri;
    } else {
      parentPath = FileUtil.getParentRelativePath(this.fileInfo.relativePath);
    }

    EventBus.emit(Constant.EVENTS.RESET_LOCAL_CLOUD_FOLDER, PAGE_ROUTE_CONST.MY_PHONE);
    let tempParams: AbilityOrRouterParams;
    if (sourceFlag) {
      GlobalHolder.getInstance().setObject<string>(GlobalKey.URI_PATH, this.fileInfo.uri);
      GlobalHolder.getInstance().setObject<string>(GlobalKey.FROM, this.fromPage);
      tempParams = {
        rootUri: '',
        title: title,
        pageFrom: '',
        bundleName: bundleName,
      } as AbilityOrRouterParams;
    } else {
      tempParams = {
        path: parentPath,
        finishType: PageFinishType.DESTROY_PAGE,
        albumName: PhotoAccessUtil.getSysResourceParentAlbumName(this.fileInfo.parentAlbumName ?? ''),
        albumType: this.fileInfo.parentAlbumType,
        albumSubType: this.fileInfo.parentAlbumSubType
      } as AbilityOrRouterParams
    }
    const params: AbilityOrRouterParams = tempParams;
    this.pageInfos.pushPath(new NavPathInfo(destination, params));
  }

  private isMyPhoneInTop(): boolean {
    let pagePaths: string[] = this.pageInfos.getAllPathName();
    if (ArrayUtil.isEmpty(pagePaths)) {
      return false;
    }
    return pagePaths[pagePaths.length - 1] === PAGE_ROUTE_CONST.MY_PHONE;
  }

  private toTargetPage() {
    HiLog.info(TAG, 'toTargetPage begin.');
    if (!this.fileInfo) {
      HiLog.info(TAG, 'toTargetPage fileInfo null!');
      return;
    }
    let targetPath = this.getTargetPath(this.fileInfo);
    if (ObjectUtil.isUndefined(targetPath) || targetPath === '') {
      HiLog.info(TAG, 'toTargetPage targetPath null or empty');
      return;
    }
    EventBus.emit(Constant.EVENTS.RESET_LOCAL_CLOUD_FOLDER, PAGE_ROUTE_CONST.MY_PHONE);
    this.currentNavItem = '';
    this.pageInfos.pushPath(new NavPathInfo(
      PAGE_ROUTE_CONST.MY_PHONE,
      {
        path: targetPath,
        finishType: PageFinishType.DESTROY_PAGE,
        pageFrom: this.fromPage,
        albumName: PhotoAccessUtil.getSysResourceParentAlbumName(this.fileInfo.parentAlbumName ?? ''),
        albumType: this.fileInfo.parentAlbumType,
        albumSubType: this.fileInfo.parentAlbumSubType
      } as AbilityOrRouterParams));
  }

  private getTargetPath(fileInfo: FileInfo): string {
    let path: string = '';
    if (FileUtil.isMediaUri(fileInfo.uri)) {
      path = this.fileInfo.parentPathForDetail ?? VirtualUri.GALLERY;
      return path;
    }

    if (!this.fileInfo.relativePath) {
      return path;
    }

    path = this.fileInfo.relativePath;
    if (path !== Constant.INTERNAL_STORAGE_ROOT_PATH) {
      path = FileUtil.getParentRelativePath(this.fileInfo.relativePath);
    }
    return path;
  }

  // 获取不同大字体的段间距
  private setBigFontAutoHalfSpace() {
    let fontSize = UiUtil.getFontSize();
    if (fontSize >= Constant.BIG_MODE.BIG_MODE_3_2x) {
      this.bigFontAutoHalfSpace = $r('app.float.common_padding12');
    } else if (fontSize >= Constant.BIG_MODE.BIG_MODE_2x) {
      this.bigFontAutoHalfSpace = $r('app.float.common_padding10');
    } else {
      this.bigFontAutoHalfSpace = $r('app.float.common_padding8');
    }
  }
}

@Component
struct DetailItem {
  @State detailInfo: DetailInfo = {} as DetailInfo;
  @Prop fileSizeChange: boolean;
  @Prop fileSize: string;
  @Prop fileCTimeChange: boolean;
  @Prop createTime: number;
  private isLastItem: boolean = false;
  @Prop bigFontAutoHalfSpace: ResourceStr;
  private isJumpFromSettings: boolean = false;

  build() {
    if (this.showInOneLine()) {
      Flex({ wrap: FlexWrap.NoWrap, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        this.detailKey()
        this.detailValue()
      }
      .width('100%')
      .padding({
        top: this.bigFontAutoHalfSpace,
        bottom: this.isLastItem ? $r('app.float.common_padding16') : this.bigFontAutoHalfSpace
      })
    } else {
      Column({ space: $r('app.float.common_margin2') }) {
        this.detailKey()
        this.detailValue()
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding({
        top: this.bigFontAutoHalfSpace,
        bottom: this.isLastItem ? $r('app.float.common_padding16') : this.bigFontAutoHalfSpace
      })
    }
  }

  private showInOneLine(): boolean {
    return UiUtil.getFontSize() < Constant.BIG_MODE.BIG_MODE_1_75x;
  }

  @Builder
  detailKey() {
    Text(this.detailInfo.itemKey)
      .fontSize($r('app.float.common_font_size14'))
      .opacity($r('app.float.common_opacity6'))
      .fontColor($r('sys.color.font_secondary'))
      .fontWeight(FontWeight.Regular)
      .fontFamily('HarmonyHeiTi')
      .constraintSize({
        minHeight: $r('app.float.common_line_height21')
      })
      .flexShrink(0)
  }

  @Builder
  detailValue() {
    Row() {
      Text(this.getItemValue())
        .fontSize($r('app.float.common_font_size14'))
        .fontWeight(FontWeight.Regular)
        .fontColor(this.getItemFontColor())
        .fontFamily('HarmonyHeiTi')
        .constraintSize({
          minHeight: $r('app.float.common_line_height19')
        })
        .id(this.detailInfo.itemKey ? getResourceString(this.detailInfo.itemKey) : '')
        .accessibilityDescription(this.detailInfo.isPathItem ? '' : ' ')
        .onClick(() => {
          if (this.detailInfo.isPathItem && this.detailInfo.itemClickFun) {
            this.detailInfo.itemClickFun();
          }
        })
    }
    .constraintSize({
      maxWidth: this.showInOneLine() ? '70%' : '100%'
    })
    .justifyContent(this.showInOneLine() ? FlexAlign.End : FlexAlign.Start)
  }

  private getItemValue(): ResourceStr {
    if (this.fileSizeChange && this.detailInfo.isFolderSize) {
      return this.fileSize;
    }
    if (this.fileCTimeChange && this.detailInfo.isCTime) {
      return DateUtil.get24HourClickDate(this.createTime, true);
    }
    return this.detailInfo.itemValue ?? '';
  }

  private getItemFontColor(): Resource {
    if (!this.detailInfo.isPathItem) {
      return $r('sys.color.font_primary');
    }
    return $r('sys.color.ohos_id_color_text_hyperlink');
  }
}

interface DetailInfo {
  isPathItem?: boolean;
  itemKey: Resource;
  itemValue?: ResourceStr;
  itemClickFun?: Function;
  isFolderSize?: boolean;
  isCTime?: boolean;
}