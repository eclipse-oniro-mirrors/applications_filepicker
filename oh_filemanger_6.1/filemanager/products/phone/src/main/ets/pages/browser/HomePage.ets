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
  AccessibilityManager,
  ACCESSIBILITY_LEVEL,
  CommonPreferenceUtil,
  CommonUtil,
  CompId,
  Constant,
  CustomTransition,
  DeviceConfig,
  DeviceInfoUtil,
  DFX,
  EventBus,
  ExternalStorageUtil,
  FilePickerUtil,
  GlobalHolder,
  GlobalKey,
  HdsMenuItemParam,
  HdsUIConfig,
  HiLog,
  HiTraceConst,
  HoverPopupStyle,
  LocalStorageConst,
  ObjectUtil,
  PAGE_ROUTE_CONST,
  PopupTips,
  ResourceUtil,
  SortOrder,
  StandardAnimation,
  StartModeOptions,
  TabBarStyle,
  TopMenuDivider,
  TraceUtils,
  TransitionAnimationController,
  UEUtil,
  UiUtil,
  VIEW_MODE,
  ThrottlingUtil,
  toast
} from '@ohos/common';
import lazy {
  FavoriteList, FavouriteDataSource, StorageDeviceList,
} from '@ohos/sideBar/indexPhoneOnly';
import context from '@ohos.app.ability.common';
import common from '@ohos.app.ability.common';
import { MENU_ICONS, MENU_NAME, PopupItem, RightMenuComp, TitleMenuItem, TopMenu, TopMenuItem } from '@ohos/titleBar';
import { isFastClick } from '../../base/utils/Lodash';
import curves from '@ohos.curves';
import { UIExtSessionManager } from '../../base/extension/UIExtSessionManager';
import {
  ComponentContent,
  display,
  LengthMetrics,
  promptAction,
  PromptAction,
  SubHeader,
  TextModifier,
  window
} from '@kit.ArkUI';
import { CopyCutManager } from '../../base/manager/CopyCutManager';
import { UiPickerButtonTips } from '../picker/UiPickerButtonTips';
import { PickerSecurityTips } from '@ohos/fileView/src/main/ets/default/view/phone/filePickerUi/PickerSecurityTips';
// import lazy {
//   EnterPageTitleEnum,
//   InitParams,
//   WiseSupportPageContext,
//   WiseSupportService,
//   WiseSupportSheet
// } from '@hms-wisesupport/wisesupport';
// import {
//   HdsNavigation,
//   HdsNavigationAttribute,
//   HdsNavigationTitleMode,
//   HdsNavigationMenuContentOptions,
// } from '@kit.UIDesignKit';
// import { Region } from '@hms-paf/ui-widget-base-v2';
import { UIExtensionContentSession } from '@kit.AbilityKit';

const TAG: string = 'HomePage';
const HOME_PAGE_SCROLL_ID = 'HomePageScroll';
const FOCUS_TITLE_DELAY: number = 700;
const POPUP_REFRESH_DELAY: number = 50;
let storage = LocalStorage.getShared();

//搜索页相关的参数
const PADDING_TOP: number = 6;
// scroller里面内容的下边距
const MARGIN_BOTTOM: number = 16;

@Styles
function pressedStyles() {
  .borderRadius($r('app.float.common_borderRadius20'))
  .backgroundColor($r('app.color.buttonBar_pressStyles'))
}

@Styles
function normalStyles() {
  .borderRadius($r('app.float.common_borderRadius20'))
  .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
}

@Component
export struct HomePage {
  @LocalStorageProp(LocalStorageConst.STATUS_BAR_HEIGHT) statusBarHeight: number = 0;
  @LocalStorageProp(LocalStorageConst.BOTTOM_NAV_BAR_HEIGHT) bottomNavBarHeight: number = 0;
  private startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();
  @Consume('navMode') navMode: NavigationMode;
  @Consume isEdit: boolean
  @Consume('pageInfos') @Watch('pageInfoChange') pageInfos: NavPathStack;
  @Consume isSorted: boolean;
  private animateToTime: number = 100;
  @State menuAnimation: TransitionEffect = TransitionEffect.IDENTITY;
  // 是否在编辑来源列表
  @Provide favouriteDataSource: FavouriteDataSource = new FavouriteDataSource();
  /**
   * 是否是降序排序
   */
  @Provide isDesc: boolean = true;
  @Provide order: string = SortOrder.TIME;
  @Provide viewMode: string = VIEW_MODE.LIST;
  // 右上角菜单
  @State topMenu: Array<TopMenuItem> = [];
  @Consume('currentNavItem') @Watch('resetIconPopup') currentNavItem: string;
  // 标题栏右侧icons
  @State rightIcons: Array<TitleMenuItem> = [];
  // 搜索转场动效
  @State isAnimationEnter: boolean = false;
  @StorageLink('isLeftShowMotion') isLeftShowMotion: boolean = false;
  @StorageLink('isRightShowMotion') isRightShowMotion: boolean = false;
  private menuType: string = ResourceUtil.getStringByResource($r('app.string.more'));
  @Consume isShowPickerTips: boolean;
  @Consume showEntryBottomBarFlag: boolean;
  /**
   * 是否显示设置半模态
   */
  @StorageLink('showAboutPage') @Watch('resetIconPopup') showAboutPage: boolean = false;
  /**
   * 按钮显示Tip标识
   */
  @StorageLink(PopupTips.MORE_POPUP_TIP) @Watch('resetIconPopup') isAlreadyShowMoreButtonTip: boolean = false;
  @StorageLink(PopupTips.SEARCH_POPUP_TIP) @Watch('resetIconPopup') isAlreadyShowSearchButtonTip: boolean = false;
  @Prop pickerCurrentIndex: number = 1;
  @Consume isVerticalTabBar: boolean;
  @Consume @Watch('onIsOutsideFoldedChange') isOutsideFolded: boolean;
  @Consume isDownScrolling: boolean;
  private scrollerStatusChangeTimeOut?: number = undefined;
  @Require homeScroller: Scroller = new Scroller();
  @StorageProp('orientation') orientation: number = display.Orientation.PORTRAIT;
  @StorageLink('windowStatus') windowStatus: number = window.WindowStatusType.FULL_SCREEN;
  @Consume isOpenMedia: boolean;
  @Consume('expandAnimationStatus') @Watch('changeExpandAnimationStatus') expandAnimationStatus: number;
  @Consume('isExpand') isExpand: number;
  // menu 透明度
  @State menuOpacity: number = 1;
  @State animationController: TransitionAnimationController = new TransitionAnimationController(0, 1, 0, 1);
  @Link showLongTakeAnimation: boolean;
  private isShowMoreMenu: boolean = false;
  // @Consume('isSearchState') @Watch('resetIconPopup') isSearchState: boolean;
  @Consume @Watch('resetIconPopup') currentTabIndex: number;
  private onDragJumpCallback: Function = async (event: DragEvent, extraParams?: string): Promise<void> =>
  CopyCutManager.getInstance().onDragJumpCallback(event, extraParams)
  private groupTitleModifier: TextModifier = new TextModifier()
    .fontSize($r('sys.float.Subtitle_S'))
    .fontColor($r('sys.color.font_secondary'))
    .fontWeight(FontWeight.Medium)
    .margin({ left: $r('app.float.common_margin12'), right: $r('app.float.common_margin12') })
  @State @Watch('resetIconPopup') showWiseSupportHelp: boolean = false;
  private wiseSupportHelpParams: ESObject = {
    appId: DeviceConfig.getInstance().config?.helpAndSupportAppId ?? CommonUtil.phoneAppId, // 帮助与客服分配的接入渠道ID
    region: 'CN', // 国家码
    windowProxy: GlobalHolder.getInstance().windowProxy,
    context: getContext(this) as ESObject,
    isBindSheet: true,
    logServerPath: [HiLog.logPath],
    logRecursive: true,
    // enterPage: EnterPageTitleEnum.LIVECHAT,
  }
  private accessToken: string = '';
  private atExpireTime: number = Number.NaN;
  private hdsMoreMenuArray: HdsMenuItemParam[] = [
    { label: MENU_NAME.edit, clickFunc: () => this.editClick() },
    {
      label: MENU_NAME.mineHelp, clickFunc: () => {
      this.showWiseSupportHelp = false;
      UEUtil.reportShowWiseSupportHelp();
    }
    },
  ]

  private favoriteTitleModifier: TextModifier = new TextModifier()
    .fontSize($r('sys.float.Subtitle_S'))
    .fontColor($r('sys.color.font_secondary'))
    .fontWeight(FontWeight.Medium)

  aboutToAppear(): void {
    TraceUtils.startTrace(HiTraceConst.HOME_PAGE_ABOUT_TO_APPEAR);
    HiLog.info(TAG, 'HomePage aboutToAppear enter');
    this.initMenu();
    this.initRightIcons();
    this.getIsAnimationEnter();
    if (this.startModeOptions.isUxt()) {
      this.isAnimationEnter = true;
    }
    EventBus.on(Constant.EVENTS.STORAGE_DEVICE_UNMOUNT, this.storageDeviceUnmount, true);
    HiLog.info(TAG, 'HomePage aboutToAppear end');
    TraceUtils.finishTrace(HiTraceConst.HOME_PAGE_ABOUT_TO_APPEAR);
  }

  aboutToDisappear(): void {
    this.isDownScrolling = false;
    EventBus.off(Constant.EVENTS.STORAGE_DEVICE_UNMOUNT, this.storageDeviceUnmount);
  }

  /**
   * 顶部菜单的动效
   */
  changeExpandAnimationStatus(): void {
    if (this.expandAnimationStatus === AnimationStatus.Initial) {
      this.getUIContext().animateTo({
        curve: this.isExpand ? Curve.EaseIn : Curve.EaseOut,
        duration: 100,
        delay: this.isExpand ? 100 : 0
      }, () => {
        this.menuOpacity = this.isExpand ? 1 : 0;
      })
    }
  }

  onIsOutsideFoldedChange(): void {
    // 刷新右侧按钮
    this.initRightIcons();
    // 初始化下滑标识
    this.isDownScrolling = false;
    // 初始化编辑模式标识
    this.isEdit = false;
  }

  pageInfoChange(): void {
    this.isEdit = false;
  }

  async storageDeviceUnmount(uuid: string): Promise<void> {
    HiLog.info(TAG, 'storageDeviceUnmount start');
    if (CopyCutManager.getInstance().storageDeviceTaskIsRun(uuid)) {
      EventBus.emit(Constant.EVENTS.REMOVE_IN_PASTE_STORAGE_DEVICE, uuid);
    } else {
      ExternalStorageUtil.unmountStorageDevice(uuid);
    }
  }

  build() {
    if (this.startModeOptions.isUxt()) {
      this.uiPickerMainContent();
    } else {
      Navigation() {
        Column() {
          this.settingIcon();
          this.mainContent();
        }
      }
      .mode(NavigationMode.Stack)
      .zIndex(1)
      .backgroundColor(Color.Transparent)
      // .titleBar({
      //   avoidLayoutSafeArea: true,
      //   content: {
      //     title: {
      //       mainTitle: getContext().resourceManager.getStringSync($r('app.string.browse').id),
      //       mainTitleId: CompId.HOME_PAGE_TITLE
      //     },
      //     menu: this.editMenu,
      //   }
      // })
      // .bindToScrollable([this.homeScroller])
      .hideTitleBar(this.isDownScrolling && this.isOutsideFolded, true)
      .navBarWidth('43%')
      // .titleMode(this.navMode === NavigationMode.Stack ? HdsNavigationTitleMode.MINI : HdsNavigationTitleMode.FULL)
      .opacity(this.animationController.pageOpacity)
      .hideBackButton(true)
      .onAppear(() => {
        if (!this.isAnimationEnter) {
          animateTo({
            curve: curves.interpolatingSpring(0, 1, 342, 38),
          }, () => {
            this.isAnimationEnter = true;
          })
        }
        let timeoutBox = setTimeout(() => {
          AccessibilityManager.getInstance()
            .sendCustomIdFocusForAccessibility(CompId.NAVIGATIONFIELD__TEXT__MAINTITLE, 'HomePage');
          clearTimeout(timeoutBox)
        }, FOCUS_TITLE_DELAY)
      })
      .onDisAppear(() => {
        CustomTransition.getInstance().unRegisterNavParam(PAGE_ROUTE_CONST.HOME_PAGE);
      })
      .onAreaChange(() => {
        // 解决ArkUi气泡在页面大小发生变化后消失的问题
        this.resetIconPopup('');
      })
    }
  }

  @Builder
  titleText() {
    Text(getContext().resourceManager.getStringSync($r('app.string.browse').id))
      .fontSize($r('app.float.common_font_size26'))
      .maxFontScale(Constant.BIG_MODE.BIG_MODE_1x)
      .fontWeight(FontWeight.Bold)
      .padding({ left: 16 })
      .height($r('app.float.common_size56'))
  }

  @Builder
  uiPickerMainContent() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        this.settingIcon()
        this.mainContent();
      }
      .padding({
        bottom: this.startModeOptions.isUxt() ? this.isOutsideFolded ?
          $r('app.float.common_padding30') : $r('app.float.common_padding60') : 0
      })

      if (!this.isOutsideFolded) {
        Column() {
          UiPickerButtonTips()
        }
        .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
        .padding({ bottom: $r('app.float.common_padding28') })
        .width('100%')
      }
    }
    .height('100%')
    .opacity(this.animationController.pageOpacity)
    .onDisAppear(() => {
      CustomTransition.getInstance().unRegisterNavParam(PAGE_ROUTE_CONST.HOME_PAGE);
    })
  }

  // 设置图标
  @Builder
  settingIcon() {
    Row() {
      Blank()
        .layoutWeight(1)

      Button() {
        SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
          .fontSize('24vp')
          .fontColor([$r('sys.color.icon_primary')])
          .renderingStrategy(SymbolRenderingStrategy.SINGLE)
          .focusable(true)
          .draggable(false)
      }
      .width(40)
      .height(40)
      .borderRadius(20)
      .focusOnTouch(true)
      .align(Alignment.Center)
      .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
      .bindMenu([
        {
          value: '设置',
          action: () => {
            // 跳转到设置页面
            this.pageInfos.pushPath({ name: 'Settings' })
          }
        }
      ])
    }
    .width('100%')
    .padding({ left: 24, right: 24 })
  }

  @Builder
  mainContent() {
    Scroll(this.homeScroller) {
      Column() {
        SubHeader({
          primaryTitle: $r('app.string.location'),
          primaryTitleModifier: this.favoriteTitleModifier,
        })
          .margin({ start: LengthMetrics.resource($r('sys.float.padding_level6')) })
        StorageDeviceList({
          startModeOptions: this.startModeOptions,
          parentId: HOME_PAGE_SCROLL_ID,
          onDragJumpCallback: this.onDragJumpCallback,
          windowStatus: this.windowStatus,
          orientation: this.orientation
        })
          .margin({ left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .borderRadius($r('sys.float.corner_radius_level10'))
        FavoriteList({ startModeOptions: this.startModeOptions, onDragJumpCallback: this.onDragJumpCallback })

        // 隐藏来源组件
        // SubHeader({
        //   primaryTitle: $r('app.string.source'),
        //   primaryTitleModifier: this.favoriteTitleModifier,
        // })
        //   .margin({ start: LengthMetrics.resource($r('sys.float.padding_level6')) })
          .margin({ start: LengthMetrics.resource($r('sys.float.padding_level6')) })
      }
      .margin({
        bottom: this.isOutsideFolded && this.isDownScrolling || this.startModeOptions.isUxt() ? 0 : MARGIN_BOTTOM
      })
      .margin({ top: this.isAnimationEnter ? 0 : -100 })
      .padding({
        bottom: this.isOutsideFolded && this.isDownScrolling || this.startModeOptions.isUxt() ? 0 :
          UiUtil.getTabBarPadding(this.isVerticalTabBar, this.bottomNavBarHeight)
      })
    }
    .transition(undefined)

    .scrollBarMargin({
      end: LengthMetrics.vp((this.isVerticalTabBar ? TabBarStyle.SINGLE_SCREEN_HEIGHT :
        TabBarStyle.FOLD_EXPANDED_HEIGHT) + this.bottomNavBarHeight)
    })
    .align(Alignment.Top)
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(this.isEdit ? BarState.Auto : BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .onDidScroll((xOffset: number, yOffset: number) => {
      this.onScrollFrameChange(yOffset);
    })
    .onScrollStop(() => {
      if (this.isOutsideFolded) {
        this.scrollerStatusChangeTimeOut = setTimeout(() => {
          this.isDownScrolling = false;
          this.scrollerStatusChangeTimeOut = undefined;
        }, 300);
      }
      HiLog.info(TAG, 'onScrollStop: updateHomeScrollerYOffset');
    })
    .id(HOME_PAGE_SCROLL_ID)

    if (this.showWiseSupportHelp) {
      // WiseSupportSheet({ showWiseSupportSheet: this.showWiseSupportHelp, params: this.wiseSupportHelpParams })
    }
  }

  @Builder
  navigationTitle() {
    Row() {
      if (this.isEdit) {
        this.editFavorites()
      } else {
        this.rightMenuComp()
      }
    }
    .justifyContent(FlexAlign.End)
    .width(this.navMode === NavigationMode.Stack ? 'auto' : '100%')
    .opacity(this.menuOpacity)
  }

  @Builder
  editFavorites() {
    Column() {
      Row() {
        Image($r('app.media.ic_ok'))
          .fillColor($r('sys.color.ohos_id_color_primary'))
          .objectFit(ImageFit.Contain)
          .width($r('app.float.common_size24'))
          .height($r('app.float.common_size24'))
          .interpolation(ImageInterpolation.High)
          .draggable(false)
      }
      .padding($r('app.float.common_padding8'))
      .stateStyles({
        pressed: pressedStyles,
        normal: normalStyles
      })
    }
    .padding({
      top: LengthMetrics.vp(8),
      end: LengthMetrics.vp(16)
    })
    .onClick(() => {
      // 按下时增加动画效果，防止页面第一次初始化也出现动画
      this.addAppearAnimate();
      this.disappearAnimate();
      UEUtil.reportEditModeChange(DFX.EditStatus.DONE);
    })
    .accessibilityText($r('app.string.confirm'))
    .accessibilityRole(AccessibilityRoleType.BUTTON)
    // 出现动画
    .transition(TransitionEffect.OPACITY.animation({ duration: this.animateToTime }))
  }

  @Builder
  rightMenuComp() {
    RightMenuComp({
      iconArr: this.rightIcons,
      topMenu: this.topMenu,
      menuAnimation: this.menuAnimation,
      menuType: this.menuType
    }).padding({
      top: LengthMetrics.vp(8),
      end: LengthMetrics.vp(16)
    })
  }

  onScrollFrameChange(yOffset: number) {
    if (this.isOutsideFolded) {
      // 清空定时
      if (this.scrollerStatusChangeTimeOut) {
        clearTimeout(this.scrollerStatusChangeTimeOut);
        this.scrollerStatusChangeTimeOut = undefined;
      }
      // 向下滚动,更新标识
      if (yOffset > 0 && this.homeScroller.currentOffset().yOffset > 0) {
        this.isDownScrolling = true;
      } else if (yOffset < 0) {
        this.isDownScrolling = false;
      }
    }
  }

  scrollBy(y: number) {
    HiLog.info(TAG, `start scroll by (0, ${y})`);
    this.homeScroller.scrollBy(0, y);
  }

  @Builder
  groupTitle(titleRes: Resource) {
    Row() {
      Text(titleRes)
        .fontSize($r('sys.float.Subtitle_S'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Start)
        .width('100%')
        .margin({ left: $r('app.float.common_size28'), right: $r('app.float.common_size28') })
    }
    .constraintSize({
      minHeight: $r('app.float.common_size48')
    })
    .alignItems(VerticalAlign.Bottom)
    .padding({ bottom: $r('sys.float.padding_level4') })
    .width('100%')
    .justifyContent(FlexAlign.Start)
  }

  resetIconPopup(propName: string) {
    HiLog.info(TAG, `resetIconPopup from: ${propName}`);
    ThrottlingUtil.debounce('bindGuidancePopup', () => {
      this.bindGuidancePopup();
    })
  }

  private addAppearAnimate() {
    this.menuAnimation = TransitionEffect.asymmetric(
      TransitionEffect.OPACITY.animation({
        // 动画时长
        duration: this.animateToTime,
        // 动画延时
        delay: this.animateToTime / 2,
      }),
      TransitionEffect.IDENTITY);
  }

  private disappearAnimate() {
    // 消失动画
    animateTo({
      // 动画时长
      duration: this.animateToTime,
      onFinish: () => {
        this.menuAnimation = TransitionEffect.IDENTITY;
      }
    }, () => {
      this.isEdit = false;
      this.isSorted = false;
    });
  }

  private initMenu() {
    if (UIExtSessionManager.getInstance().isLoadFromUIExtension()) {
      this.topMenu = [];
      this.topMenu.push(
        new TopMenuItem(undefined, () => this.editClick(), MENU_NAME.edit, SortOrder.ABOUT,
          TopMenuDivider.TYPE_TWO),
        new TopMenuItem(undefined, () => this.updatePageInfo(), undefined,
          SortOrder.SET_UP, TopMenuDivider.TYPE_TWO),
        new TopMenuItem(undefined, () => {
          this.showWiseSupportHelp = true;
          UEUtil.reportShowWiseSupportHelp();
        }, MENU_NAME.mineHelp, SortOrder.MINE_HELP, TopMenuDivider.TYPE_TWO)
      );
    }
  }

  // 进入关于页
  private async updatePageInfo(): Promise<void> {
    if (isFastClick()) {
      return;
    }
    AppStorage.setOrCreate<boolean>('showAboutPage', true);
    UEUtil.reportShowSetting();
  }

  private initRightIcons() {
    this.rightIcons = [];
    // 更多icon
    if (this.topMenu.length > 0) {
      // 外屏折叠不显示更多菜单
      if (!this.isOutsideFolded) {
        const moreButton = new TitleMenuItem(MENU_ICONS.more, MENU_NAME.more, () => {
          const uiExtContext: common.UIExtensionContext = GlobalHolder.getInstance().getUIExtensionContext();
          const session: UIExtensionContentSession =
            GlobalHolder.getInstance().getObject<UIExtensionContentSession>(GlobalKey.WINDOW_CLASS_EXT);
          if (ObjectUtil.isNullOrUndefined(uiExtContext) || ObjectUtil.isNullOrUndefined(session)) {
            HiLog.error(TAG, `windowProxy or uiExtContext or session is null!`)
            return;
          }
          // WiseSupportService.initWindowProxy(session, uiExtContext, {
          //   config: {
          //     region: Region.CN
          //   }
          // });
        }, true, true);
        moreButton.setBindPopupKey(PopupTips.MORE_POPUP_TIP);
        moreButton.accessibilityRoleType = AccessibilityRoleType.BUTTON;
        this.rightIcons.push(moreButton);
      }
    }
    if (this.startModeOptions.isUxt()) {
      // 取消icon
      this.rightIcons.push(new TitleMenuItem(MENU_ICONS.cancel, MENU_NAME.cancel, () => {
        let abilityContext = getContext(this) as context.UIAbilityContext;
        abilityContext.terminateSelf();
      }, true, false));
    }
  }

  // 规避折叠屏点击下方‘最近’和‘浏览’ 以及拉起文官时会有动效的问题
  private getIsAnimationEnter() {
    if (AppStorage.has('isAnimationEnter')) {
      this.isAnimationEnter = AppStorage.get('isAnimationEnter')!;
    } else {
      this.isAnimationEnter = true;
    }
    AppStorage.setOrCreate('isAnimationEnter', false);
  }

  private editClick(): void {
    if (isFastClick()) {
      return;
    }
    this.isEdit = true;
    AccessibilityManager.getInstance().sendCustomIdFocusForAccessibility(CompId.NAVIGATIONFIELD__TEXT__MAINTITLE);
    UEUtil.reportEditModeChange(DFX.EditStatus.OPEN);
  }

  private isNotShowPopup(): boolean {
    // Tab页不在浏览页， 非分栏模式不在HomePage页面（单屏模式在HomePage页面），进入搜索页面，显示关于半模态，显示帮助与客服半模态，进入编辑状态等场景下不显示气泡
    // return !(this.navMode === NavigationMode.Split || this.currentNavItem === '') || this.isShowMoreMenu ||
    // this.isSearchState || this.showAboutPage || this.showWiseSupportHelp || this.isEdit ||
    //   this.currentTabIndex !== Constant.TAB_ID.TAB_BROWSE
    return false
  }

  private bindGuidancePopup(): void {
    // 外部拉起的场景 或者 已经显示过相关气泡 或者 当前场景不需要显示气泡， 则不需要展示气泡提示
    if (this.isOpenMedia || (this.isAlreadyShowMoreButtonTip && this.isAlreadyShowSearchButtonTip) ||
    this.isNotShowPopup()) {
      HiLog.warn(TAG,
        `bindGuidancePopup: do not show guidance popup, isOpenMedia: ${this.isOpenMedia}, isAlreadyShowMoreButtonTip :
         ${this.isAlreadyShowMoreButtonTip}, isAlreadyShowSearchButtonTip: ${this.isAlreadyShowSearchButtonTip}`);
      return;
    }
    let popupItem = this.getPopupItem();
    if (!popupItem) {
      HiLog.warn(TAG, 'GuidancePopup is already show');
      return;
    }
    const uiContext = this.getUIContext();
    if (ObjectUtil.isNullOrUndefined(uiContext)) {
      HiLog.error(TAG, 'bindGuidancePopup: uiContext is null or undefined');
      return;
    }
    const promptAction = uiContext.getPromptAction();
    let contentNode = new ComponentContent<PopupItem>(uiContext, wrapBuilder<[PopupItem]>(popupBuild), popupItem);
    popupItem.setPromptAction(promptAction);
    popupItem.setContentNode(contentNode);
  }

  // 获取当前需要显示的气泡数据
  private getPopupItem(): PopupItem | undefined {
    let popupItem: PopupItem | undefined = undefined;
    if (!this.isAlreadyShowMoreButtonTip) {
      popupItem = new PopupItem($r('app.string.more_button_tip'), !this.isAlreadyShowMoreButtonTip,
        PopupTips.MORE_POPUP_TIP, $r('app.string.next_one'));
      popupItem.options = {
        autoCancel: true,
        mask: false,
        placement: Placement.Bottom,
        enableArrow: true,
        onWillDismiss: () => {
          popupItem?.changePopupShowStatus();
        }
      };
    }
    return popupItem;
  }
}

@Builder
function popupBuild(item: PopupItem) {
  Column() {
    Column() {
      Text(item.text)
        .fontSize($r('sys.float.Body_M'))
        .padding({
          top: $r('app.float.common_size12'),
          left: $r('app.float.common_size12'),
          right: $r('app.float.common_size12'),
        })
        .fontColor($r('sys.color.font_primary'))
        .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)
    }

    if (!ObjectUtil.isNullOrUndefined(item.linkText)) {
      Button() {
        Text(item.linkText)
          .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
          .fontSize($r('sys.float.Body_M'))
          .alignSelf(ItemAlign.Start)
          .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)
      }
      .padding($r('app.float.common_size6'))
      .margin($r('app.float.common_size6'))
      .buttonStyle(ButtonStyleMode.TEXTUAL)
      .type(ButtonType.Capsule)
      .onClick(() => {
        HiLog.info(TAG, 'Guidance popup linkText click,');
        item.isShowPopup = false;
        item.changePopupShowStatus();
      })
    } else {
      Column().height($r('app.float.common_size12'))
    }
  }
  .constraintSize({
    maxWidth: '90%'
  })
  .alignItems(HorizontalAlign.Start)
  .borderRadius(HoverPopupStyle.HOVER_MENU_BORDER_RADIUS)
}

@Builder
function TopMenuBuilder(paramArray: HdsMenuItemParam[]) {
  Menu() {
    ForEach(paramArray, (item: HdsMenuItemParam, index: number) => {
      MenuItem({ content: item.label })
        .onClick(() => item.clickFunc())
        .accessibilityText(item.label)
        .accessibilityGroup(true)
        .margin({ left: $r('sys.float.padding_level2'), right: $r('sys.float.padding_level2') })
      if (index !== (paramArray.length - 1)) {
        AddDivider()
      }
    });
  }
  .padding({ top: $r('sys.float.padding_level2'), bottom: $r('sys.float.padding_level2') })
  .width($r('app.float.common_size224'))
}

@Builder
function AddDivider() {
  Divider()
    .vertical(false)
    .strokeWidth('1px')
    .color($r('sys.color.comp_divider'))
    .width('100%')
    .padding({
      left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8')
    })
    .accessibilityLevel(ACCESSIBILITY_LEVEL.NO)
}