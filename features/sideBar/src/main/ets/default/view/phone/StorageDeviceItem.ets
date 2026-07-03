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
  ResourceUtil,
  Constant,
  EventBus,
  HiLog,
  PAGE_ROUTE_CONST,
  StringUtil,
  AbilityOrRouterParams,
  DragManager,
  ExternalStorageUtil,
  renderSize,
  PageUtil,
  UiUtil,
  DiskChangeInfo,
  GlobalHolder,
  GlobalKey,
  StartModeOptions,
  FilePickerUtil,
  CommonPreferenceUtil,
  StorageSpaceInfo,
  toast,
  DFX,
  EnumTransferUtil,
  UEUtil,
  HoverPopupStyle,
  DataPreferenceUtil,
  ACCESSIBILITY_LEVEL,
  LocationItemName,
  PopupTips,
  DeviceConfig,
  HiSysEventUtil,
  MENU_ICONS
} from '@ohos/common';
import fileExtensionInfo from '@ohos.file.fileExtensionInfo';
import { SideBarItemModel } from '../../model/SideBarItemModel';
import { componentUtils, display, LengthMetrics, SymbolGlyphModifier, window } from '@kit.ArkUI';
import lazy { StorageDeviceItemMenu } from './StorageDeviceItemMenu'
import { StorageDevicePreviewItem } from '../phone/StorageDevItemPreView';
import data_preferences from '@ohos.data.preferences';
import { ItemLongPressMenu, LongPressMenuItem } from './ItemLongPressMenu';

const TAG = 'StorageDeviceItem';
const CAN_HIDE_ITEM: LocationItemName[] = [];

@Component
export default struct StorageDeviceItem {
  public info: SideBarItemModel = {} as SideBarItemModel;
  private context = GlobalHolder.getInstance().getAppContext();
  @StorageLink('trashFileCount') recentDeleteCount: number = 0;
  @Consume('pageInfos') pageInfos: NavPathStack;
  @Consume('navMode') @Watch('onCurrentNavItemChange') navMode: NavigationMode;
  @Consume('currentNavItem') @Watch('onCurrentNavItemChange') currentNavItem: string;
  @State itemBackColor: Resource = $r('app.color.transparent_color');
  private totalSize: number = 0;
  private useSize: number = 0;
  @State spaceSizeText: ResourceStr = '';
  @State useSpaceSizeProgress: number = 0;
  @State isRemoving: boolean = false;
  @Consume systemMultiple: number;
  @StorageLink('DiskStatusChange') @Watch('usbUnmountCallback') diskStatusChange: DiskChangeInfo =
    new DiskChangeInfo(false);
  private refreshUsbSpaceSizeBind: Function = () => this.refreshUsbSpaceSize();
  private refreshPhoneSpaceSizeBind: Function = () => this.getStorageDetail();
  private refreshDeviceItemBind: Function = (uuid: string): void => this.refreshDeviceItem(uuid);
  private onBackGroundBind: Function = (): void => this.onBackGround();
  private isOnTouch: boolean = false;
  @Consume isEdit: boolean;
  public startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();
  @Consume isOutsideFolded: boolean;
  @State isImageVisible: boolean = true;
  @State isItemShow: boolean = true;
  @Prop parentId: string;
  public onDragJumpCallback: Function = () => {};
  @Prop windowStatus: number;
  @Prop orientation: number;
  @State itemWidth: number = 0;
  private refreshStorageDeviceItem: Function = (item: SideBarItemModel) => {};

  aboutToAppear() {
    HiLog.info(TAG, 'StorageDeviceItem aboutToAppear');
    this.initBackColor();
    // 界面启动时，先从持久化读取空间信息，用于界面显示，未读到不处理
    if (!StringUtil.isEmpty(this.info.uuid) &&
      (this.info.deviceType === fileExtensionInfo.DeviceType.DEVICE_EXTERNAL_USB ||
        this.info.deviceType === fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK)) {
      let spaceInfo =
        CommonPreferenceUtil.getDeviceStorageSpace(this.info.uuid as string);
      if (spaceInfo) {
        this.totalSize = spaceInfo.totalSpaceSize;
        const myPhoneFreeSize = spaceInfo.freeSpaceSize;
        this.setStorageDeviceSize(myPhoneFreeSize);
      }
    }
    if (this.info.deviceType === fileExtensionInfo.DeviceType.DEVICE_EXTERNAL_USB) {
      EventBus.on(Constant.EVENTS.REFRESH_SD_USB_SPACE_SIZE, this.refreshUsbSpaceSizeBind);
      this.refreshUsbSpaceSizeBind();
    }
    if (this.info.deviceType === fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK) {
      EventBus.on(Constant.EVENTS.REFRESH_PHONE_SPACE_SIZE, this.refreshPhoneSpaceSizeBind);
      this.getStorageDetail();
    }
    EventBus.on(Constant.EVENTS.REFRESH_DEVICE_ITEM, this.refreshDeviceItemBind);
    EventBus.on(Constant.EVENTS.ON_BACKGROUND, this.onBackGroundBind);
  }

  aboutToDisappear() {
    EventBus.off(Constant.EVENTS.REFRESH_SD_USB_SPACE_SIZE, this.refreshUsbSpaceSizeBind);
    EventBus.off(Constant.EVENTS.REFRESH_DEVICE_ITEM, this.refreshDeviceItemBind);
    EventBus.off(Constant.EVENTS.ON_BACKGROUND, this.onBackGroundBind);
    EventBus.off(Constant.EVENTS.REFRESH_PHONE_SPACE_SIZE, this.refreshPhoneSpaceSizeBind);
    if (this.currentNavItem === this.getItemPageTag()) {
      this.currentNavItem = '';
    }
  }

  setStorageDeviceSize(freeSpaceBytes: number, isSetPersistent: boolean = false) {
    this.useSize = this.totalSize - freeSpaceBytes;
    // 如果可用空间计算后出现异常小于0，显示为0
    if (this.useSize < 0) {
      this.useSize = 0;
    }
    HiLog.warn(TAG, `old storage space, total: ${this.totalSize}, useSize: ${this.useSize}`);
    // 存储空间
    this.spaceSizeText = $r('app.string.device_space_usage',
      renderSize(this.useSize, Constant.BYTE.STORAGE_KB, true),
      renderSize(this.totalSize, Constant.BYTE.STORAGE_KB, true));
    this.useSpaceSizeProgress = this.useSize / this.totalSize * 100;

    if (isSetPersistent) {
      const spaceInfo: StorageSpaceInfo = new StorageSpaceInfo(this.info.uuid!!, this.totalSize, freeSpaceBytes);
      CommonPreferenceUtil.setDeviceStorageSpace(this.info.uuid!!, spaceInfo);
    }
  }

  onBackGround() {
    if (this.isOnTouch) {
      this.initBackColor();
    }
  }

  initBackColor() {
    this.itemBackColor =
      this.currentNavItem === this.getItemPageTag() && this.navMode === NavigationMode.Split
        ? $r('sys.color.comp_emphasize_tertiary') : $r('app.color.transparent_color');
  }

  onCurrentNavItemChange() {
    this.initBackColor();
  }

  async refreshUsbSpaceSize(): Promise<void> {
    if (StringUtil.isEmpty(this.info.uuid)) {
      return;
    }
    this.totalSize = await ExternalStorageUtil.getTotalSizeOfVolume(this.info.uuid!!);
    const usbFreeBytes = await ExternalStorageUtil.getFreeSizeOfVolume(this.info.uuid!!);
    this.setStorageDeviceSize(usbFreeBytes, true);
  }

  getUsbSpaceSizeProcess() {
    if (this.totalSize === 0) {
      return 0;
    }
    return this.useSize / this.totalSize * 100;
  }

  usbUnmountCallback(): void {
    if (this.info.uuid === this.diskStatusChange.uuid) {
      HiLog.info(TAG, 'usbUnmountCallback');
      this.isRemoving = true;
    }
  }

  getNameMaxWidth(): string {
    if ((this.info.num === Constant.LOCATION_LIST.RECENT_DELETE || this.info.num === Constant.LOCATION_LIST.MY_PHONE) &&
      this.systemMultiple < Constant.BIG_MODE.BIG_MODE_1_45x) {
      return '50%';
    } else {
      return '75%';
    }
  }

  build() {
    Row() {
      Row() {
        if (this.info.icon) {
          Image(this.info.icon as Resource)
            .draggable(false)
            .height($r('app.float.common_size24'))
            .width($r('app.float.common_size24'))
            .margin({ end: LengthMetrics.vp(16) })
            .onAreaChange((oldVal: Area, currentVal: Area) => {
            })
            .onVisibleAreaChange([0.0], (isExpanded: boolean, currentRatio: number) => {
              // 更新当前组件是否可见
              this.updateIsImageVisible(isExpanded, currentRatio)
            })
        }
        Column() {
          Text(this.info.name)
            .fontSize($r('app.float.common_font_size16'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Regular)
            .fontFamily('HarmonyHeiTi')
            .constraintSize({
              minHeight: $r('app.float.common_size22'),
              maxWidth: this.getNameMaxWidth()
            })
          if (this.info.deviceType === fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK) {
            Progress({ value: this.useSpaceSizeProgress, total: 100, type: ProgressType.Linear })
              .color($r('sys.color.comp_background_emphasize'))
              .value(this.useSpaceSizeProgress)
              .style({ enableScanEffect: false, enableSmoothEffect: false })
              .size({
                width: $r('app.float.common_size80'),
                height: $r('app.float.common_size12')
              })
              .padding({ top: $r('app.float.common_padding2') })
              .accessibilityLevel(ACCESSIBILITY_LEVEL.NO)
          }
          Column() {
            this.storageDescription(false)
          }
          .constraintSize({
            maxWidth: this.getNameMaxWidth()
          })
          .visibility(this.systemMultiple >= Constant.BIG_MODE.BIG_MODE_1_45x ?
          Visibility.Visible : Visibility.None)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
        .padding({
          // 适老化适配，设置文本框高度在字体变大时将Column组件高度撑高
          top: this.getBigModePadding(),
          bottom: this.getBigModePadding()
        })

        // （设备容量、最近删除文件数目）
        Row() {
          if (this.systemMultiple < Constant.BIG_MODE.BIG_MODE_1_45x) {
            this.storageDescription(true)
          }
        }
        .padding({ left: $r('app.float.common_padding10') })
        .layoutWeight(1)
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Center)

        // 内部存储--位置项目编辑时控制是否显示的开关
        if (this.isEdit && this.info.itemName && CAN_HIDE_ITEM.includes(this.info.itemName)) {
          Toggle({ type: ToggleType.Switch, isOn: this.isItemShow })
            .onChange((isOn: boolean) => {
              HiLog.info(TAG, `Toggle clicked，isOn:${isOn}`);
              if (!this.info.itemName) {
                HiLog.warn(TAG, `Toggle clicked，null itemName`);
                return;
              }
              CommonPreferenceUtil.setLocationItemShowStatus(this.info.itemName, isOn);
            })
        }

        if (this.isRemoving) {
          Text($r('app.string.removing'))
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('app.float.common_font_size14'))
            .maxLines(1)
            .constraintSize({ maxWidth: 100 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          LoadingProgress()
            .size({ width: $r('app.float.common_size20'), height: $r('app.float.common_size20') })
            .color($r('sys.color.ohos_id_color_progress'))
        } else {
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .draggable(false)
            .fontSize('24vp')
            .fontColor([$r('sys.color.icon_fourth')])
            .margin({ left: $r('sys.float.ohos_id_text_paragraph_margin_xs') })
            .visibility(this.isEdit ? Visibility.None : Visibility.Visible)
        }
      }
      .constraintSize(
        {
          minHeight: $r('app.float.common_size56')
        })
      .backgroundColor(this.itemBackColor)
      .borderRadius($r('app.float.common_borderRadius16'))
      .padding({
        left: $r('app.float.common_padding8'),
        right: $r('app.float.common_padding8')
      })
      .onClick(() => {
        this.clickEvent();
      })
      .accessibilityDescription(this.broadcastClickContent(this.info.itemName))
    }
    .width('100%')
    .padding({
      left: $r('app.float.common_padding4'),
      right: $r('app.float.common_padding4')
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.setSelectItemBackGround();
        this.isOnTouch = true;
      } else if ((event.type === TouchType.Up) || (event.type === TouchType.Cancel)) {
        if ((this.navMode !== NavigationMode.Split) || (this.currentNavItem !== this.getItemPageTag())) {
          this.itemBackColor = $r('app.color.transparent_color');
        } else {
          this.itemBackColor = $r('sys.color.comp_emphasize_tertiary');
        }
        this.isOnTouch = false;
      }
    })
    .borderRadius($r('app.float.common_borderRadius16'))
    .enabled(!this.isRemoving)
    .opacity(this.isRemoving ? 0.4 : 1)
    .bindContextMenu(this.longPressMenu(),
      ResponseType.LongPress,
      this.isEdit || this.info.uri === PAGE_ROUTE_CONST.RECENT_DELETE ? {} :
        {
          preview: this.previewModel(),
          placement: Placement.BottomLeft,
          previewAnimationOptions: { scale: [0.8, 1.0] },
          layoutRegionMargin: {
            left: $r('sys.float.padding_level8')
          },
          hapticFeedbackMode: HapticFeedbackMode.ENABLED
        }
    )
    .onDrop((event: DragEvent, extraParams: string | undefined) => {
      HiLog.info(TAG, 'onDrop')
      DragManager.getInstance().onDrop();
      DragManager.getInstance().leaveSelectItem(() => {
        this.currentNavItem = DragManager.getInstance().selectItemTag;
      });
      this.itemBackColor = $r('app.color.transparent_color');
      this.onDragJumpCallback(event, extraParams);
    })
    .onDragEnter((event: DragEvent, extraParams?: string) => {
      HiLog.info(TAG, 'onDragEnter');
      DragManager.getInstance().enterSelectItem(this.currentNavItem);
      this.setSelectItemBackGround();
      this.currentNavItem = '';
      if (this.info.dragEnable && this.isCanClick() && DragManager.getInstance()
        .storageItemCanDrop(this.info.uri as string)) {
        DragManager.getInstance().onDropEnterAnimation((isSelect: boolean) => {
          if (isSelect) {
            this.setSelectItemBackGround();
          } else {
            this.itemBackColor = $r('app.color.transparent_color');
          }
        }, () => {
          this.clickEvent();
          // 点击执行完成后，设置背景
          if (this.navMode === NavigationMode.Split) {
            this.itemBackColor = $r('app.color.split_item_onFocus');
          }
        }, this.navMode === NavigationMode.Split)
      }
    })
    .onDragMove((event?: DragEvent, extraParams?: string) => {
      if (event) {
        let dragStatus = AppStorage.get<boolean>('dragStatus');
        if (!dragStatus) {
          event.setResult(DragResult.DROP_ENABLED);
        } else {
          event.setResult(DragResult.DROP_DISABLED);
        }
      }
    })
    .onDragLeave((event?: DragEvent, extraParams?: string) => {
      HiLog.info(TAG, 'onDragLeave');

      DragManager.getInstance().leaveSelectItem(() => {
        this.currentNavItem = DragManager.getInstance().selectItemTag;
      });
      DragManager.getInstance().onDropLeaveAnimation((isSelect: boolean) => {
        if ((this.navMode !== NavigationMode.Split) || this.isCanClick()) {
          this.itemBackColor = $r('app.color.transparent_color');
        }
      })
    })
    .onSizeChange((_, newVal) => {
      this.itemWidth = Number(newVal.width);
    })
  }

  // 无障碍模式播报内容,' '不播报单指双击即可执行，''播报默认内容
  broadcastClickContent(itemName?: LocationItemName): string | undefined {
    if (!itemName) {
      HiLog.warn(TAG, 'isNotBroadcastClickEvent itemName is undefined');
      return '';
    }
    if (this.isEdit) {
      return ' ';
    }
    return '';
  }

  @Builder
  storageDescription(isAlignEnd: boolean = false) {
    if ((this.info.deviceType === fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK) ||
      this.info.deviceType === fileExtensionInfo.DeviceType.DEVICE_EXTERNAL_USB) {
      Text(this.spaceSizeText)
        .fontSize($r('sys.float.Subtitle_S'))
        .fontColor($r('sys.color.font_secondary'))
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .constraintSize({
          minHeight: $r('app.float.common_line_height19')
        })
        .textAlign(isAlignEnd ? TextAlign.End : TextAlign.Start)
    } else if (this.info.num === Constant.LOCATION_LIST.RECENT_DELETE) {
      Text($r('app.plural.item', this.recentDeleteCount, this.recentDeleteCount))
        .fontColor($r('sys.color.font_secondary'))
        .margin({ right: $r('app.float.common_margin2') })
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .constraintSize({
          minHeight: $r('app.float.common_line_height19')
        })
        .fontSize($r('sys.float.Body_M'))
        .textAlign(isAlignEnd ? TextAlign.End : TextAlign.Start)
        .maxLines(1)
    }
  }

  @Builder
  usbUnMountFileMenu() {
    StorageDeviceItemMenu({
      uuid: this.info.uuid
    })
  }

  removeItemAction() {
    HiLog.info(TAG, `removeItemAction, isOn:${false}`);
    if (!this.info.itemName) {
      HiLog.warn(TAG, `Toggle clicked, null itemName`);
      return;
    }
    CommonPreferenceUtil.setLocationItemShowStatus(this.info.itemName, false);
    this.refreshStorageDeviceItem(this.info);
  }

  @Builder
  longPressMenu() {
    if (!this.isEdit && this.info.uri !== PAGE_ROUTE_CONST.RECENT_DELETE) {
      ItemLongPressMenu({ menuItems: this.getLongPressMenus() })
    }
  }

  @Builder
  previewModel() {
    StorageDevicePreviewItem({
      info: this.info,
      usbTotalBytes: this.totalSize,
      usbUseBytes: this.useSize
    })
      .width(this.itemWidth)
  }

  updateIsImageVisible(isExpanded: boolean, currentRatio: number) {
    if (!isExpanded && currentRatio <= 0.0) {
      this.isImageVisible = false;
      return;
    }
    this.isImageVisible = true;
  }

  refreshDeviceItem(uuid: string) {
    // 没有设备类型： 最近删除
    if (!this.info.deviceType) {
      return;
    }
    if (this.isLocalDisk(uuid) || this.isUsbDisk(uuid) || this.isDriveDisk(uuid)) {
      this.currentNavItem = this.getItemPageTag();
    }
  }

  isLocalDisk(uuid: string) {
    return StringUtil.isEmpty(uuid) && this.info.deviceType === fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK;
  }

  isUsbDisk(uuid: string) {
    return !StringUtil.isEmpty(this.info.uuid) && this.info.uuid === uuid;
  }

  isDriveDisk(uuid: string) {
    return !StringUtil.isEmpty(uuid) && uuid === this.info.uri;
  }

  setSelectItemBackGround() {
    if (this.navMode !== NavigationMode.Split) {
      this.itemBackColor = $r('sys.color.interactive_pressed');
    } else {
      this.itemBackColor = $r('sys.color.comp_emphasize_tertiary');
    }
  }

  async clickEvent() {
    if (this.isCanClick()) {
      const pageName = this.info.isTfCard || ExternalStorageUtil.isExternalStorageUri(this.info.rootUri ?? '') ?
      DFX.PageName.EXTERNAL : EnumTransferUtil.transferToPageName(this.info.uri);
      this.currentNavItem = this.getItemPageTag();
      let hasMyPhone: boolean = this.hasMyPhone();
      AppStorage.setOrCreate<DFX.PageName>(DFX.StorageKey.OPERATE_PAGE, pageName);
      // 首页触发的，分栏场景下需要清理栈内页面
      this.pageInfos.clear(false);

      let params: AbilityOrRouterParams = {
        rootUri: this.info.rootUri,
        title: this.info.name,
        uuid: this.info.uuid,
        startModeOptions: this.startModeOptions
      } as AbilityOrRouterParams;
      EventBus.emit(Constant.EVENTS.RESET_LOCAL_CLOUD_FOLDER, this.info.uri);
      if (!hasMyPhone) {
        this.pageInfos.pushPath(new NavPathInfo(this.info.uri, params), UiUtil.showSwitchAnimation(this.navMode));
        UEUtil.reportEnterPage(pageName);
        return;
      }
      this.pageInfos.pushPath(new NavPathInfo(this.info.uri, params), UiUtil.showSwitchAnimation(this.navMode));
      UEUtil.reportEnterPage(pageName);
    }
  }

  isCanClick() {
    return !this.isEdit && this.info.uri &&
      (this.navMode === NavigationMode.Stack || this.currentNavItem !== this.getItemPageTag());
  }

  hasMyPhone(): boolean {
    if (this.pageInfos.size() === 0) {
      return false;
    }
    let pageNames: string[] = this.pageInfos.getAllPathName();
    for (let i = pageNames.length - 1; i >= 0; i--) {
      if (pageNames[i] === PAGE_ROUTE_CONST.MY_PHONE) {
        return true;
      }
    }
    return false;
  }

  getItemPageTag(): string {
    if (!this.info.uuid) {
      return this.info.uri + '';
    }
    return this.info.uri + this.info.uuid;
  }

  // 获取本地存储空间信息
  async getStorageDetail(): Promise<void> {
    // 获取本地内存情况
    this.totalSize = await PageUtil.getLocalTotalSpace();
    const myPhoneFreeSize = await PageUtil.getLocalFreeSpace();
    this.setStorageDeviceSize(myPhoneFreeSize, true);
  }

  getBigModePadding(): Resource {
    let padding: Resource = $r('app.float.common_margin8');
    if (this.systemMultiple >= Constant.BIG_MODE.BIG_MODE_3_2x) {
      padding = $r('app.float.common_padding24');
    } else if (this.systemMultiple >= Constant.BIG_MODE.BIG_MODE_2x) {
      padding = $r('app.float.common_padding20');
    } else if (this.systemMultiple >= Constant.BIG_MODE.BIG_MODE_1_75x) {
      padding = $r('app.float.common_padding16');
    }
    return padding;
  }

  private getLongPressMenus(): LongPressMenuItem[] {
    if (StringUtil.isEmpty(this.info.uri)) {
      return [];
    }
    const uri = this.info.uri;
    let longPressItems: LongPressMenuItem[] = [];
    if (uri === PAGE_ROUTE_CONST.MY_PHONE) {
      if (this.info.deviceType === fileExtensionInfo.DeviceType.DEVICE_LOCAL_DISK) {
        // 我的手机
        longPressItems.push({
          itemName: $r('app.string.space_cleanup'),
          clickCallBack: () => {
          },
          symbolEndIcon: new SymbolGlyphModifier(MENU_ICONS.clean)
        })
      } else if (this.info.deviceType === fileExtensionInfo.DeviceType.DEVICE_EXTERNAL_USB) {
        longPressItems.push({
          itemName: $r('app.string.securely_remove'),
          clickCallBack: async () => {
            if (this.info.uuid === '') {
              HiLog.warn(TAG, 'uuid is null');
              return;
            }
            EventBus.emit(Constant.EVENTS.STORAGE_DEVICE_UNMOUNT, this.info.uuid);
            UEUtil.reportExternalOper(DFX.ExternalOperType.PRESS_REMOVE);
          },
          symbolEndIcon: new SymbolGlyphModifier(MENU_ICONS.remove)
        })
      } else {
        HiLog.error(TAG, 'error unknown device.')
      }
    } else {
      HiLog.error(TAG, 'unknown what menu to bind.');
    }
    return longPressItems;
  }
}