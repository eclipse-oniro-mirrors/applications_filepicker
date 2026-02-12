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
  BottomCallParams,
  Constant,
  DisplayUtil,
  EventBus,
  FileInfo,
  FileMimeTypeUtil,
  FileOperation,
  FileUtil,
  GlobalHolder,
  HiLog,
  MediaMetaDataUtil,
  NetworkUtil,
  ObjectUtil,
  PAGE_ROUTE_CONST,
  RenameItem,
  StringUtil,
  toast,
  FileSourceType,
  PageFinishType,
  HiSysEventUtil,
  OperateName,
  OperateResult,
  StartModeOptions,
  FilePickerUtil,
  StorageDeviceManager,
  VirtualUri,
  DFX,
  UEUtil,
  EnumTransferUtil,
  LocalStorageConst,
  GlobalKey,
  BundleResourceUtil,
  MenuInfo,
  MenuItemName,
  ToolBarStyle,
  StandardAnimation,
} from '@ohos/common';
import { BottomOptions } from '../model/UiModelData';
import { MoreItems } from './MoreItems';
import lazy { FileDeleteDialog, FileRenameDialog } from '@ohos/customDialog/indexPhoneOnly';
import lazy { PhotoAccessUtil } from '@ohos/common/indexLazyLoad';
import { curves, display, window } from '@kit.ArkUI';
import { BaseItem } from './BaseItem'
import { LongPressFileMenu } from '@ohos/fileView/src/main/ets/default/view/phone/LongPressFileMenu';

const TAG = 'BottomBar';
const FILE_DELETE_DIALOG_WIDTH: number = 375;

@Component
export struct BottomBar {
  @LocalStorageProp(LocalStorageConst.BOTTOM_NAV_BAR_HEIGHT) bottomNavBarHeight: number = 0;
  @Prop isExternalStorageDeviceFile: boolean = false;
  // 是否最近删除
  private isRecentDeletePage: boolean = false;
  @Consume('pageInfos') pageInfos: NavPathStack;
  @Consume isPreviewMode: boolean;
  @State isMore: boolean = false;
  @Link selectItem: string;
  @Prop checkedNum: number;
  @Link bottomOptions: BottomOptions[];
  @State moveAndCopy: boolean = false;
  @Link selectFilesList: FileInfo[];
  @State copy: boolean = true;
  @Prop moreOptions: string[] = [];
  onDownloadFinishBind: Function = () => {
  };
  public dialogCallback: Function = (e: BottomCallParams) => {
  };
  public checkCanClick: Function = () => {
  };
  public writePasteBoard: Function = (list: FileInfo[]) => {
  };
  public pullUpPickerCallBack: Function = () => {
  };
  @State fileRename: string = '';
  @State isFolder: boolean = false;
  @State renameFileUri: string = '';
  @State renameFilePath: string = '';
  @State adaptLongPress: boolean = true;
  private pageName: string = '';
  private geometryId: string | undefined = undefined;
  private isClickDisabled: boolean = false;
  public isShowCheckBox: boolean = false;
  private animationTime: number = 300;
  @Consume('isScrollReachEnd') isScrollReachEnd: boolean;
  private backgroundBlurStyleValue: BlurStyle = BlurStyle.NONE;
  /**
   * 外部存储的唯一标识
   */
  @State uuid: string = '';
  // 用于接收长按的文件
  @Prop fileInfo: FileInfo = new FileInfo();
  private curOpenByOtherAppFileItem: FileInfo = new FileInfo();
  private isMyPhonePage: boolean = false;
  private isPreviewForbidJump: boolean = false;
  private fromPage?: string;
  private isMixSelectSence: boolean = false;
  private sdUsbChangeBind: Function = (uriArray: string[]): void => this.sdUsbChange(uriArray);
  private startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();
  private filePickerViewFlag: boolean = this.startModeOptions.pickerFlag;
  private fileOperationCallBack: (message: ResourceStr) => boolean = () => false;
  private isBottomMenu: boolean = false;
  public isFromSource: boolean = false;
  public isFromExternal: boolean = false;
  @Consume('navMode') navMode: NavigationMode;
  /**
   * 点击某一个文件的回调
   */
  private onItemClick: Function = () => {
  };
  /**
   * 壁纸编辑页面退出的回调
   */
  private wallpaperPreviewPopCallBack: Function = (popInfo: PopInfo) => {
  };
  @Link @Watch('onLongPressChangeType') longPressChangeType: string;
  @Consume isOutsideFolded: boolean;
  @StorageLink('windowStatus') windowStatus: number = window.WindowStatusType.FULL_SCREEN;
  @Prop isShowBottomBar: boolean = false;
  private outsideDeviceFileRenameDialog: CustomDialogController = new CustomDialogController({
    builder: FileRenameDialog({
      confirm: (newFileName: string, newFileUri: string): void => this.renameAction(newFileName, newFileUri),
      oldFileName: this.fileRename,
      isFolder: this.isFolder,
      oldFileUri: this.renameFileUri,
      isOutsideFolded: this.isOutsideFolded
    }),
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      HiLog.info(TAG, 'FileRenameDialog onWillDismiss');
      if (GlobalHolder.getInstance().getObject(Constant.EVENTS.EXIT_MULTI_STATE)) {
        EventBus.emit(Constant.EVENTS.EXIT_MULTI_STATE);
        GlobalHolder.getInstance().deleteObject(Constant.EVENTS.EXIT_MULTI_STATE);
      }
      dismissDialogAction.dismiss();
    },
    autoCancel: false,
    alignment: DialogAlignment.Center,
    width: '100%',
    height: '100%',
    keyboardAvoidMode: KeyboardAvoidMode.NONE
  })
  private fileRenameDialog: CustomDialogController = new CustomDialogController({
    builder: FileRenameDialog({
      confirm: (newFileName: string, newFileUri: string): void => this.renameAction(newFileName, newFileUri),
      oldFileName: this.fileRename,
      isFolder: this.isFolder,
      oldFileUri: this.renameFileUri,
    }),
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      HiLog.info(TAG, 'FileRenameDialog onWillDismiss');
      if (GlobalHolder.getInstance().getObject(Constant.EVENTS.EXIT_MULTI_STATE)) {
        EventBus.emit(Constant.EVENTS.EXIT_MULTI_STATE);
        GlobalHolder.getInstance().deleteObject(Constant.EVENTS.EXIT_MULTI_STATE);
      }
      dismissDialogAction.dismiss();
    },
    autoCancel: false,
    alignment: DialogAlignment.Center,
  })
  // 折叠机状态改变回调
  private foldStatusChangeCallback: Callback<display.FoldStatus> = (curFoldStatus: display.FoldStatus) => {
    HiLog.info(TAG, 'listening curFoldStatus:' + curFoldStatus);
    // 如果跟手弹窗弹出，折叠机从展开态变为折叠态，则关闭跟手弹窗打开普通弹窗
    if (this.isShowPopoverDialog && curFoldStatus === DisplayUtil.FOLD_STATUS_FOLDED) {
      this.isBottomMenu = true;
      this.fileDeleteDialog.open();
    }
  }
  // 是否展示删除跟手弹窗
  @State isShowPopoverDialog: boolean = false;

  // 折叠屏跟手弹窗
  @Builder
  fileDeleteFollowHandDialog() {
    FileDeleteDialog({
      title: $r('app.plural.delete_confirm_dialog_title', this.checkedNum, this.checkedNum),
      content: this.getDeleteConfirmDialogContent(),
      confirmButtonText: $r('app.string.delete'),
      operationFileList: this.selectFilesList,
      confirm: (isHardDelete: boolean): void => {
        this.fileDelete(isHardDelete);
        this.isShowPopoverDialog = false;
        UEUtil.reportDeleteFile(this.getUEPageName(),
          this.isRecentDeletePage || isHardDelete ? DFX.DeleteType.DELETE : DFX.DeleteType.SOFT_DELETE,
          DFX.OperateSource.BOTTOM_MENU, this.selectFilesList.length);
      },
      cancel: () => {
        this.isShowPopoverDialog = false
      },
      isShowCheckBox: this.isShowCheckBox,
      fromPage: this.fromPage
    })
  }

  // 直板机删除确认弹窗
  private fileDeleteDialog: CustomDialogController = new CustomDialogController({
    builder: FileDeleteDialog({
      title: $r('app.plural.delete_confirm_dialog_title', this.checkedNum, this.checkedNum),
      content: this.getDeleteConfirmDialogContent(),
      confirmButtonText: $r('app.string.delete'),
      operationFileList: this.selectFilesList,
      confirm: (isHardDelete: boolean): void => {
        this.fileDelete(isHardDelete);
        const deleteType: DFX.DeleteType =
          this.isRecentDeletePage || isHardDelete ? DFX.DeleteType.DELETE : DFX.DeleteType.SOFT_DELETE;
        const operateSource: DFX.OperateSource = this.isBottomMenu ? DFX.OperateSource.BOTTOM_MENU :
        DFX.OperateSource.PRESS_MENU;
        UEUtil.reportDeleteFile(this.getUEPageName(), deleteType, operateSource, this.selectFilesList.length);
      },
      isShowCheckBox: this.isShowCheckBox,
      fromPage: this.fromPage
    }),
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      HiLog.info(TAG, 'FileDeleteDialog onWillDismiss');
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

  aboutToAppear() {
    HiLog.info(TAG, 'aboutToAppear');
    // 监听sd卡和U盘,关闭详情弹框
    EventBus.on(Constant.EVENTS.FINISH_DOWNLOAD_BY_PROGRESS_DIALOG, this.onDownloadFinishBind);
    EventBus.on(Constant.EVENTS.SD_USB_CHANGE, this.sdUsbChangeBind);
    this.addFoldModeChangedListener();
  }

  aboutToDisappear() {
    HiLog.info(TAG, 'aboutToDisAppear');
    EventBus.off(Constant.EVENTS.FINISH_DOWNLOAD_BY_PROGRESS_DIALOG, this.onDownloadFinishBind);
    EventBus.off(Constant.EVENTS.SD_USB_CHANGE, this.sdUsbChangeBind);
    this.removeFoldModeChangedListener();
  }

  /**
   * 获取UE页面名称
   * @returns UE页面信息
   */
  getUEPageName(): DFX.PageName {
    if (this.isRecentDeletePage) {
      return DFX.PageName.RECENT_DELETE;
    }
    if (this.isFromSource) {
      return DFX.PageName.SOURCE;
    }
    if (this.isFromExternal) {
      return DFX.PageName.EXTERNAL;
    }
    return EnumTransferUtil.transferToPageName(this.fromPage);
  }

  otherAppsOpenConfirm() {
    const file = this.selectFilesList.length > 0 ? this.selectFilesList[0] : undefined;
    if (!file) {
      HiLog.info(TAG, 'FileOperation.openFileByOtherApp in other app open confirm no file');
      return;
    }
    HiLog.info(TAG, 'FileOperation.openFileByOtherApp in other app open confirm');
    FileOperation.openFileByOtherApp(file.uri, file.fileName);
  }

  async openFileDetail(fileInfo: FileInfo): Promise<void> {
    if (this.isNeedRefreshMedia(fileInfo) && !fileInfo.isGallery) {
      await this.getMediaInfomation(fileInfo);
    }
    UEUtil.reportFileDetail(fileInfo.isFolder);
    let fromPage = this.fromPage;

    EventBus.emit(Constant.EVENTS.FILE_DETAIL, fileInfo, this.isRecentDeletePage, this.isMyPhonePage,
      false, this.isPreviewMode ? '' : fromPage, this.isPreviewForbidJump);
  }

  // 仅处理更多菜单特有操作： 旋转
  moreItemClick(moreItem: number | string) {
    HiLog.info(TAG, 'moreItemClick click :' + moreItem);
    // 防暴力点击，200ms后可再次点击
    if (this.isClickDisabled) {
      HiLog.warn(TAG, 'click too quickly, click moreItem:' + moreItem);
      return;
    }
    this.isClickDisabled = true;
    setTimeout(() => {
      this.isClickDisabled = false;
    }, 200);
    EventBus.emit(Constant.EVENTS.BOTTOM_BAR_ITEM_CLICK, moreItem);
    switch (moreItem) {
      case Constant.OPERATION_TYPE.FAVORITE:
        EventBus.emit(Constant.EVENTS.MENU_CLICK,
          new MenuInfo(MenuItemName.FAVORITE, this.selectFilesList, undefined, false));
        break
      case Constant.OPERATION_TYPE.UNFAVORITE:
        EventBus.emit(Constant.EVENTS.MENU_CLICK,
          new MenuInfo(MenuItemName.UN_FAVORITE, this.selectFilesList, undefined, false));
        break;
      case Constant.OPERATION_TYPE.MOVE:
        this.selectItem = Constant.OPERATION_TYPE.MOVE;
        this.moveCheck();
        AppStorage.setOrCreate<DFX.OperateSource>(DFX.StorageKey.OPERATE_SOURCE, DFX.OperateSource.BOTTOM_MENU);
        AppStorage.setOrCreate<DFX.PageName>(DFX.StorageKey.OPERATE_PAGE,
          EnumTransferUtil.transferToPageName(this.fromPage));
        break;
      case Constant.OPERATION_TYPE.DETAIL:
        let fileInfo = this.selectFilesList[0];
        this.openFileDetail(fileInfo);
        break;
      case Constant.OPERATION_TYPE.RENAME:
        this.renameCheck();
        break;
      case Constant.OPERATION_TYPE.ROTATE:
        this.selectItem = Constant.OPERATION_TYPE.ROTATE;
        break;
      case Constant.OPERATION_TYPE.OTHER_APP:
        this.openFileByOtherApp();
        break;
      case Constant.OPERATION_TYPE.OPEN_FOLDER:
        const item = this.selectFilesList[0];
        EventBus.emit(Constant.EVENTS.RESET_LOCAL_CLOUD_FOLDER, PAGE_ROUTE_CONST.MY_PHONE);
        const pathInfo = new NavPathInfo(PAGE_ROUTE_CONST.MY_PHONE, {
          path: FileUtil.getParentRelativePath(item.relativePath),
          finishType: PageFinishType.DESTROY_PAGE
        } as AbilityOrRouterParams);
        this.pageInfos.pushPath(pathInfo);
        break;
      case Constant.OPERATION_TYPE.CLEAR_RECENT_RECORD:
        if (this.selectFilesList && this.selectFilesList.length > 0) {
          EventBus.emit(Constant.EVENTS.LONG_PRESS_CLEAR_RECENT_RECORD, this.selectFilesList);
        }
        break;
      case Constant.OPERATION_TYPE.SET_AS_WALLPAPER:
        this.dealSetAsWallpaper(false);
        break;
      default:
        HiLog.error(TAG, `${moreItem} exec fail`);
    }
  }

  /**
   * 检查复制条件
   */
  async copyCheck() {
    this.copyReady();
  }

  /**
   * 检查移动条件
   */
  async moveCheck() {
    if (this.fileOperationCallBack($r('app.string.cannot_move_app_data'))) {
      return;
    }
    this.moveReady();
  }

  /**
   * 检查重命名条件
   */
  async renameCheck() {
    const fileInfo = this.selectFilesList[0];
    if (ObjectUtil.isNullOrUndefined(fileInfo)) {
      return;
    }
    this.renameReady();
  }

  /**
   * 重命名准备状态，文件无异常，拉起重命名dialog
   */
  renameReady() {
    if (this.checkCanClick()) {
      return;
    }
    const fileInfo = this.selectFilesList[0];
    this.fileRename = fileInfo.fileName;
    this.renameFileUri = fileInfo.uri;
    this.renameFilePath = fileInfo.relativePath || '';
    this.isFolder = fileInfo.isFolder;
    if (!DisplayUtil.isExistDuplicateBottomBar) {
      DisplayUtil.isExistDuplicateBottomBar = true;
      if (this.isOutsideFolded) {
        // 外屏重命名拉起
        this.outsideDeviceFileRenameDialog.open();
      } else {
        this.fileRenameDialog.open();
      }
    }
  }

  async openFileByOtherApp(): Promise<void> {
    this.curOpenByOtherAppFileItem = this.fileInfo.fileName ? this.fileInfo : this.selectFilesList[0];
    if (!this.curOpenByOtherAppFileItem) {
      return;
    }
    HiLog.infoPrivate(TAG, `preview file uri:`, this.curOpenByOtherAppFileItem.uri);
    FileOperation.openFileByOtherApp(this.curOpenByOtherAppFileItem.uri, this.curOpenByOtherAppFileItem.fileName);
    if (GlobalHolder.getInstance().getObject(Constant.EVENTS.EXIT_MULTI_STATE)) {
      EventBus.emit(Constant.EVENTS.EXIT_MULTI_STATE);
      GlobalHolder.getInstance().deleteObject(Constant.EVENTS.EXIT_MULTI_STATE);
    }
  }

  fileDelete(isHardDelete: boolean) {
    let data: RenameItem = {
      closeDialog: true,
      type: Constant.OPERATION_TYPE.DELETE,
      newUri: ''
    }
    if (isHardDelete) {
      data.type = Constant.OPERATION_TYPE.HARD_DELETE;
    }
    this.dialogCallback({ item: data } as BottomCallParams)
  }

  fileRemove() {
    let data: RenameItem = {
      closeDialog: true,
      type: Constant.OPERATION_TYPE.REMOVE,
      newUri: ''
    }
    this.dialogCallback({ item: data } as BottomCallParams)
  }

  clickFilePath(isNeedCloseDialog: boolean = false) {
    if (isNeedCloseDialog) {
      setTimeout(() => {
        EventBus.emit(Constant.EVENTS.FILE_DETAIL_SHOW, false);
      }, this.animationTime)
    }
    let data: RenameItem = {
      closeDialog: isNeedCloseDialog,
      type: Constant.OPERATION_TYPE.DETAIL,
      newUri: ''
    }
    this.dialogCallback({ item: data } as BottomCallParams)
  }

  build() {
    if (this.isShowBottomBar) {
      Column() {
        Divider()
          .opacity(0.25)
          .color($r('sys.color.ohos_id_color_subheading_separator'))
          .backgroundColor($r('sys.color.ohos_id_color_subheading_separator'))
          .visibility((this.backgroundBlurStyleValue == BlurStyle.NONE && !this.isScrollReachEnd) ?
          Visibility.Visible : Visibility.Hidden)
        Row() {
          if (this.filePickerViewFlag && this.bottomOptions.length > 0) {
            this.filePickerBuilder()
          } else {
            this.mainBottomBuilder()
          }
        }
        .width('100%')
        .constraintSize({
          minHeight: $r('app.float.common_size52')
        })
        .backgroundColor($r('sys.color.ohos_id_color_bottom_tab_sub_bg'))
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height(ToolBarStyle.BOTTOM_BAR_HEIGHT + this.bottomNavBarHeight)
      .backgroundColor($r('sys.color.ohos_id_color_bottom_tab_sub_bg'))
      .transition(TransitionEffect.translate(
        { x: 0, y: ToolBarStyle.BOTTOM_BAR_HEIGHT + this.bottomNavBarHeight }
      ).animation(
        {
          curve: curves.interpolatingSpring(0, 1,
            StandardAnimation.AnimationConstants.SHOW_ANIMATE_STIFFNESS,
            StandardAnimation.AnimationConstants.SHOW_ANIMATE_DAMPING)
        }
      )
      )
      .padding({ bottom: this.bottomNavBarHeight })
      .margin(this.filePickerViewFlag ?
        {
          left: $r('app.float.common_margin2'),
          right: $r('app.float.common_margin2'),
          bottom: $r('app.float.common_margin18')
        } :
        {
          left: $r('app.float.common_margin2'),
          right: $r('app.float.common_margin2')
        }
      )
    }
  }

  @Builder
  filePickerBuilder() {
    ForEach(this.bottomOptions.filter((item: BottomOptions) => item.display), (item: BottomOptions) => {
      if (item.type === Constant.OPERATION_TYPE.MORE) {
        BaseItem({
          barItem: item,
          filePickerViewFlag: this.filePickerViewFlag
        })
          .bindMenu(
            this.MoreMenuBuilder,
            {
              placement: Placement.TopRight,
              offset: { x: this.getOffset(), y: 8 },
              backgroundBlurStyle: BlurStyle.NONE,
              backgroundColor: $r('sys.color.ohos_id_color_dialog_bg')
            }
          )
          .accessibilityGroup(true)
          .enabled(!item.disabled)
      } else {
        BaseItem({
          barItem: item,
          filePickerViewFlag: this.filePickerViewFlag
        })
          .onClick(() => {
            this.onBottomItemClick(item);
          })
          .accessibilityGroup(true)
          .enabled(!item.disabled)
      }

    }, (item: BottomOptions) => JSON.stringify(item))
  }

  @Builder
  mainBottomBuilder() {
    ForEach(this.bottomOptions.filter((item: BottomOptions) => item.display), (item: BottomOptions) => {
      if (item.type === Constant.OPERATION_TYPE.MORE) {
        Column() {
          BaseItem({
            barItem: item
          })
        }
        .bindMenu(
          this.MoreMenuBuilder,
          {
            placement: Placement.TopRight,
            offset: { x: this.getOffset(), y: 8 },
            backgroundBlurStyle: BlurStyle.NONE,
            backgroundColor: $r('sys.color.ohos_id_color_dialog_bg')
          }
        )
        .layoutWeight(1)
        .enabled(!item.disabled)
        .accessibilityGroup(true)
        .accessibilityRole(AccessibilityRoleType.BUTTON)
      } else if (item.type === Constant.OPERATION_TYPE.DELETE) {
        Column() {
          BaseItem({
            barItem: item
          })
        }
        .id(item.type)
        .layoutWeight(1)
        .onClick(() => {
          this.onBottomItemClick(item);
        })
        .accessibilityGroup(true)
        .accessibilityRole(AccessibilityRoleType.BUTTON)
        .enabled(!item.disabled)
        .bindPopup(this.isShowPopoverDialog, {
          builder: () => {
            this.fileDeleteFollowHandDialog();
          },
          placement: Placement.Bottom,
          autoCancel: false,
          width: FILE_DELETE_DIALOG_WIDTH,
        })
      } else {
        Column() {
          BaseItem({
            barItem: item
          })
        }
        .id(item.type)
        .layoutWeight(1)
        .onClick(() => {
          this.onBottomItemClick(item);
        })
        .accessibilityGroup(true)
        .accessibilityRole(AccessibilityRoleType.BUTTON)
        .enabled(!item.disabled)
      }
    }, (item: BottomOptions) => JSON.stringify(item))
  }

  @Builder
  MoreMenuBuilder() {
    LongPressFileMenu({
      isOutsideFolded: this.isOutsideFolded,
      showContextMenu: this.adaptLongPress,
      onLongPressClick: (moreItem: string): void => {
        this.moreItemClick(moreItem);
      },
      pageName: this.pageName,
      // 防止selectFilesList为空时崩溃
      fileInfo: this.selectFilesList.length === 0 ? new FileInfo() : this.selectFilesList[0],
      checkedNum: this.checkedNum,
      isChecked: true,
      geometryId: this.geometryId,
      isMulti: true,
      toOperateFileList: this.selectFilesList,
      isMoreMenu: true,
    })
  }

  getOffset() {
    if (DisplayUtil.isFoldable()) {
      return -35;
    }
    return -28;
  }

  menuCanClick(item: BottomOptions): boolean {
    if (item) {
      if ((item.type === Constant.OPERATION_TYPE.SELECT_ALL) || (item.type === Constant.OPERATION_TYPE.DESELECT_ALL)) {
        return true;
      } else if (!this.checkedNum || item.disabled) {
        return false;
      }
    }
    return true;
  }

  onBottomItemClick(item: BottomOptions) {
    HiLog.info(TAG, 'onBottomItemClick selectItem = ' + this.selectItem + '; type =' + item.type);
    if (!this.menuCanClick(item)) {
      return;
    }

    // 防暴力点击，200ms后可再次点击
    if (this.isClickDisabled) {
      HiLog.warn(TAG, 'click too quickly, click BottomItem:' + item.type);
      return;
    }
    this.isClickDisabled = true;
    setTimeout(() => {
      this.isClickDisabled = false;
    }, 200);
    EventBus.emit(Constant.EVENTS.BOTTOM_BAR_ITEM_CLICK, item.type);
    if (item.type === Constant.OPERATION_TYPE.DETAIL) {
      this.openFileDetail(this.selectFilesList[0]);
    } else if (item.type === Constant.OPERATION_TYPE.DELETE) {
      if ((!this.isRecentDeletePage) && this.checkCanClick()) {
        return;
      }
      if (this.fileOperationCallBack($r('app.string.cannot_delete_app_data'))) {
        return;
      }
      if (DisplayUtil.isBigFoldDeviceExpanded(DisplayUtil.isBigFold(), DisplayUtil.getFoldStatus()) &&
        this.windowStatus !== window.WindowStatusType.FLOATING &&
        this.windowStatus !== window.WindowStatusType.SPLIT_SCREEN) {
        this.isShowPopoverDialog = true;
      } else {
        this.fileDeleteDialog.open();
      }
    } else if (item.type === Constant.OPERATION_TYPE.REMOVE) {
      this.fileRemove();
    } else if (item.type === Constant.OPERATION_TYPE.MOVE) {
      if (this.fileOperationCallBack($r('app.string.cannot_move_app_data'))) {
        return;
      }
      this.moveCheck();
      AppStorage.setOrCreate<DFX.OperateSource>(DFX.StorageKey.OPERATE_SOURCE, DFX.OperateSource.BOTTOM_MENU);
      AppStorage.setOrCreate<DFX.PageName>(DFX.StorageKey.OPERATE_PAGE,
        EnumTransferUtil.transferToPageName(this.fromPage));
    } else if (item.type === Constant.OPERATION_TYPE.COPY) {
      this.copyCheck();
      AppStorage.setOrCreate<DFX.OperateSource>(DFX.StorageKey.OPERATE_SOURCE, DFX.OperateSource.BOTTOM_MENU);
      AppStorage.setOrCreate<DFX.PageName>(DFX.StorageKey.OPERATE_PAGE,
        EnumTransferUtil.transferToPageName(this.fromPage));
      return;
    } else if (item.type === Constant.OPERATION_TYPE.OTHER_APP) {
      this.openFileByOtherApp();
    }
    // 点击按钮将修改值传递给父级
    this.selectItem = item.type;
  }

  /**
   * 添加折叠屏状态变化监听
   * @param callback
   */
  private async addFoldModeChangedListener(): Promise<void> {
    try {
      HiLog.info(TAG, 'Add foldStatusChange changed listener.');
      display.on('foldStatusChange', this.foldStatusChangeCallback);
    } catch (error) {
      HiLog.error(TAG, 'addFoldModeChangedListener err.');
    }
  }

  /**
   * 移除折叠屏状态变化监听
   * @param callback
   */
  private async removeFoldModeChangedListener(): Promise<void> {
    try {
      HiLog.info(TAG, 'remove FoldModeChanged changed listener.');
      display.off('foldStatusChange', this.foldStatusChangeCallback);
    } catch (error) {
      HiLog.error(TAG, 'removeFoldModeChangedListener err.');
    }
  }

  private onLongPressChangeType() {
    HiLog.info(TAG, 'onLongPressChangeType: ' + this.longPressChangeType)
    if (StringUtil.isEmpty(this.longPressChangeType)) {
      this.longPressChangeType = Constant.OPERATION_TYPE.PLAY;
      return;
    }
    this.isBottomMenu = false;
    if (this.longPressChangeType === Constant.OPERATION_TYPE.PLAY) {
      return;
    }
    if (this.longPressChangeType === Constant.OPERATION_TYPE.DELETE) {
      if (!this.isRecentDeletePage && this.checkCanClick()) {
        return;
      }
      if (this.fileOperationCallBack($r('app.string.cannot_delete_app_data'))) {
        return;
      }
      GlobalHolder.getInstance().setObject<boolean>(Constant.EVENTS.EXIT_MULTI_STATE, true);
      this.fileDeleteDialog.open();
    } else if (this.longPressChangeType === Constant.OPERATION_TYPE.REMOVE) {
      this.fileRemove();
    } else if (this.longPressChangeType === Constant.OPERATION_TYPE.OTHER_APP) {
      GlobalHolder.getInstance().setObject<boolean>(Constant.EVENTS.EXIT_MULTI_STATE, true);
      this.openFileByOtherApp();
    } else if (this.longPressChangeType === Constant.OPERATION_TYPE.RENAME) {
      GlobalHolder.getInstance().setObject<boolean>(Constant.EVENTS.EXIT_MULTI_STATE, true);
      this.renameCheck();
    } else if (this.longPressChangeType === Constant.OPERATION_TYPE.MOVE) {
      if (this.fileOperationCallBack($r('app.string.cannot_move_app_data'))) {
        return;
      }
      this.moveCheck();
      AppStorage.setOrCreate<DFX.OperateSource>(DFX.StorageKey.OPERATE_SOURCE, DFX.OperateSource.PRESS_MENU);
      AppStorage.setOrCreate<DFX.PageName>(DFX.StorageKey.OPERATE_PAGE,
        EnumTransferUtil.transferToPageName(this.fromPage));
    } else if (this.longPressChangeType === Constant.OPERATION_TYPE.COPY) {
      this.copyCheck();
      // 点击按钮将修改值传递给父级
      this.selectItem = this.longPressChangeType;
      AppStorage.setOrCreate<DFX.OperateSource>(DFX.StorageKey.OPERATE_SOURCE, DFX.OperateSource.PRESS_MENU);
      AppStorage.setOrCreate<DFX.PageName>(DFX.StorageKey.OPERATE_PAGE,
        EnumTransferUtil.transferToPageName(this.fromPage));
    } else if (this.longPressChangeType === Constant.OPERATION_TYPE.DETAIL) {
      let fileInfo = this.selectFilesList[0];
      GlobalHolder.getInstance().setObject<boolean>(Constant.EVENTS.EXIT_MULTI_STATE, true);
      this.openFileDetail(fileInfo);
    } else if (this.longPressChangeType === Constant.OPERATION_TYPE.OPEN_FOLDER) {
      this.dealOpenFolder();
    } else if (this.longPressChangeType === Constant.OPERATION_TYPE.SET_AS_WALLPAPER) {
      this.dealSetAsWallpaper(true);
    }
    this.longPressChangeType = Constant.OPERATION_TYPE.PLAY;
  }

  private getFileSource(fileInfo: FileInfo): DFX.FileSource {
    let fileSource: DFX.FileSource = DFX.FileSource.UNKNOWN;
    if (fileInfo.uri.startsWith(VirtualUri.EXTERNAL_DISK)) {
      fileSource = DFX.FileSource.EXTERNAL;
    } else if (fileInfo.uri.startsWith(Constant.MY_PHONE_URI)) {
      fileSource = DFX.FileSource.LOCAL;
    } else if (fileInfo.uri.startsWith(VirtualUri.GALLERY_PHOTO_URI)) {
      fileSource = DFX.FileSource.GALLERY;
    }
    return fileSource;
  }

  private dealSetAsWallpaper(isFromPressMenu: boolean = false): void {
    // 小屏模式下不支持拉起壁纸编辑
    if (this.windowStatus === window.WindowStatusType.FLOATING ||
      this.windowStatus === window.WindowStatusType.SPLIT_SCREEN || this.isOutsideFolded) {
      EventBus.emit(Constant.EVENTS.EXIT_MULTI_STATE);
      toast($r('app.string.set_wallpaper_not_support'));
      return;
    }
    let fileInfo: FileInfo = this.selectFilesList[0];
    if (ObjectUtil.isNullOrUndefined(fileInfo)) {
      HiLog.warn(TAG, `dealSetAsWallpaper: fileInfo is null`);
      return;
    }
    const fileSource: DFX.FileSource = this.getFileSource(fileInfo);
    let operateSource: DFX.OperateSource = isFromPressMenu ? DFX.OperateSource.PRESS_MENU
      : DFX.OperateSource.BOTTOM_MENU;
    UEUtil.reportSetWallpaper(operateSource, fileSource);
    let onPopped = (popInfo: PopInfo) => {
      this.wallpaperPreviewPopCallBack(popInfo);
    }
    this.pageInfos.pushPath(new NavPathInfo(PAGE_ROUTE_CONST.WALLPAPER_PREVIEW,
      { fileData: fileInfo } as AbilityOrRouterParams, onPopped), this.navMode === NavigationMode.Stack);
    EventBus.emit(Constant.EVENTS.EXIT_MULTI_STATE);
    return;
  }

  private dealOpenFolder() {
    // 当文件在第三方白名单沙箱时，跳往来源页
    let destination = PAGE_ROUTE_CONST.MY_PHONE;

    let parentPath: string;
    if (FileUtil.isMediaUri(this.fileInfo.uri)) {
      parentPath = this.fileInfo.parentPathForDetail ?? VirtualUri.GALLERY;
    } else {
      parentPath = FileUtil.getParentRelativePath(this.fileInfo.relativePath);
    }
    HiLog.info(TAG, `deal OpenFolder isFromSource = ${this.isFromSource}`);
    let sourceFlag = false;
    let title: string = "";
    let bundleName: string = "";



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

  private sdUsbChange(uriArray: string[]) {
    HiLog.infoPrivate(TAG, 'sdUsbChange uriArray is: ', JSON.stringify(uriArray));
    setTimeout(() => {
      EventBus.emit(Constant.EVENTS.FILE_DETAIL_SHOW, false);
    }, this.animationTime)
  }

  private getDeleteConfirmDialogContent() {
    if (this.isMixSelectSence) {
      if (this.selectFilesList.every((item: FileInfo) => !item.isExternalStorageDeviceFile)) {
        return $r('app.string.softDelete');
      }
      return this.selectFilesList.every((item: FileInfo) => item.isExternalStorageDeviceFile) ?
      $r('app.string.complete_delete_tips') :
      $r('app.string.part_external_file_delete_tips');
    }
    if (this.isRecentDeletePage) {
      return $r('app.string.delete_complete_tips');
    }
    return this.isExternalStorageDeviceFile ?
    $r('app.string.complete_delete_tips') :
    $r('app.string.softDelete');
  }

  private renameAction(newFileName: string, newFileUri: string): void {
    this.dialogCallback({
      item: StringUtil.isEmpty(newFileName) || StringUtil.isEmpty(newFileUri) ?
        {
          type: Constant.OPERATION_TYPE.RENAME,
        } :
        {
          oldUri: this.renameFileUri,
          newName: newFileName,
          type: Constant.OPERATION_TYPE.RENAME,
          newUri: newFileUri,
          newPath: FileUtil.getPathFromUri(newFileUri)
        }
    } as BottomCallParams);
    HiSysEventUtil.reportFileOperation(OperateName.RENAME, 'files', OperateResult.SUCCESS);
    UEUtil.reportRenameFile(this.getUEPageName());
  }

  private async getMediaInfomation(fileInfo: FileInfo) {
    const uri = fileInfo.uri;
    const thumbName = uri + fileInfo.mtime + fileInfo.size;
    const metaData =
      await MediaMetaDataUtil.getMediaSizeAndDuration(uri, fileInfo.size, fileInfo.mimeTypeObj.fileCategory);
    MediaMetaDataUtil.setMetaDataForFileInfo(fileInfo, metaData);
  }

  private isNeedRefreshMedia(fileInfo: FileInfo) {
    return (this.isShowDimension(fileInfo) && (fileInfo.picWidth === 0 || fileInfo.picHeight === 0)) ||
      (this.isShowDuration(fileInfo) && fileInfo.duration === 0);
  }

  private isShowDimension(fileInfo: FileInfo) {
    return fileInfo &&
      (FileMimeTypeUtil.isVideo(fileInfo.mimeTypeObj) || FileMimeTypeUtil.isImage(fileInfo.mimeTypeObj));
  }

  private isShowDuration(fileInfo: FileInfo) {
    return fileInfo &&
      (FileMimeTypeUtil.isVideo(fileInfo.mimeTypeObj) || FileMimeTypeUtil.isAudio(fileInfo.mimeTypeObj));
  }

  /**
   * 复制准备状态，文件无异常，拉起复制菜单
   */
  private copyReady() {
    if (this.checkCanClick()) {
      HiLog.info(TAG, 'task is running.');
      HiSysEventUtil.reportFileOperation(OperateName.COPY, 'files', OperateResult.FAIL);
      return;
    }
    this.writePasteBoard(this.selectFilesList);
    HiSysEventUtil.reportFileOperation(OperateName.COPY, 'files', OperateResult.SUCCESS);
    this.pullUpPickerCallBack();
  }

  /**
   * 移动准备状态，文件无异常，拉起移动菜单
   */
  private moveReady() {
    if (this.checkCanClick()) {
      HiLog.info(TAG, 'task is running.');
      HiSysEventUtil.reportFileOperation(OperateName.MOVE, 'files', OperateResult.FAIL);
      return;
    }
    HiSysEventUtil.reportFileOperation(OperateName.MOVE, 'files', OperateResult.SUCCESS);
  }
}
