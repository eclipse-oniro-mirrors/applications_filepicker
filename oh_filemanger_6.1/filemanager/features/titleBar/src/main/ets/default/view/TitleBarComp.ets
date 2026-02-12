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
  Constant,
  DeviceInfoUtil,
  UserState,
  FilePickerUtil,
  StartModeOptions,
  DisplayUtil,
  CompId,
  LocalStorageConst,
  PreferenceConst,
  StandardAnimation,
  FolderOperationType,
  TransitionAnimationController,
  EventBus,
  HiLog,
  FileInfo,
  AccessibilityManager,
} from '@ohos/common';
import { TitleAnimation } from '../constant/MenuConstant';
import { TitleBarAnimation } from '../model/TitleBarAnimation';
import { TitleMenuItem } from '../model/TitleMenuItem';
import { TopMenuItem } from '../model/TopMenuItem';
import { LeftIconComp } from './LeftIconComp';
import { RightMenuComp } from './RightMenuComp';
import { TitleComp } from './TitleComp';
import lazy { LengthMetrics } from '@ohos/common/indexLazyLoad';
import { curves, promptAction } from '@kit.ArkUI';

const TAG = 'TitleBarComp';

@Component
export struct TitleBarComp {
  @Consume('isExpand') isExpand: boolean;
  @Consume('isPreviewMode') isPreviewMode: boolean;
  @BuilderParam customRightButton?: Function;
  @StorageLink('isAnimationShow') isAnimationShow: boolean = false;
  @LocalStorageProp(LocalStorageConst.IS_SINGLE_SCREEN) isSingleScreen: boolean = false;
  @StorageProp(PreferenceConst.KEY.DEFAULT_TAB_INDEX) tab: number = 0;
  @Prop geometryId: string = '';
  @Prop title: ResourceStr = '';
  @Prop subTitle: ResourceStr = '';
  @Link iconArr: Array<TitleMenuItem>;
  // 左侧icon
  @Link leftIcon: TitleMenuItem;
  @Link topMenu: Array<TopMenuItem>;
  @Prop previewFile: FileInfo = new FileInfo();
  private previewPageFrom: string = '';
  @Prop userState: UserState;
  @Prop fileCount: number;
  @State isCanGetFocus: boolean = true;
  // 判断当前输入值是否处于预上屏状态
  private isPreviewTextWorking: boolean = false;
  private startModeOptions: StartModeOptions = FilePickerUtil.getStartOptionsFromStorage();
  private isPickerFlag: boolean = FilePickerUtil.getStartOptionsFromStorage().pickerFlag;
  private isEmulator: boolean = DeviceInfoUtil.isEmulator();
  initMenu: Function = () => {};

  @StorageLink('deviceFoldStatus') @Watch('onDeviceFoldStatus') deviceFoldStatus: number = DisplayUtil.getFoldStatus();
  private isBigFold: boolean = DisplayUtil.isBigFold();
  @Prop isLevelOneTitle: boolean =
    !this.isPickerFlag && DisplayUtil.isBigFoldDeviceExpanded(this.isBigFold, this.deviceFoldStatus);
  @Prop titleCompId: string = CompId.TOP_TITLE;
  @Prop isBigTitleAnnounce: boolean = false;
  @Prop isHorizontal: boolean = false;
  @Prop folderOperateType: FolderOperationType | undefined = undefined;
  @Prop animationController: TransitionAnimationController | undefined = undefined;
  @Prop @Watch('onPageClose') isClosePage: boolean = false;
  @State isTitleBarMoved: boolean = false;
  @State isLeftIconDisappear: boolean = false;
  @State isTitleDisappear: boolean = false;

  aboutToAppear(): void {
    this.initMenu();

    EventBus.on(Constant.EVENTS.STOP_EDITING, this.stopEditingHandler);
  }

  aboutToDisappear(): void {
    EventBus.off(Constant.EVENTS.STOP_EDITING, this.stopEditingHandler);
  }

  private stopEditingHandler = () => {
    HiLog.info(TAG, 'stopEditingHandler');
  }

  isShowExpand(): boolean {
    return this.tab === Constant.TAB_ID.TAB_BROWSE && this.isExpand && !this.isSingleScreen &&
      !this.isPreviewMode;
  }

  build() {
    Row() {
      Row() {
        Row() {
          // 左侧按钮
          LeftIconComp({
            leftIcon: $leftIcon,
            userState: this.userState,
            isPickerFlag: this.startModeOptions.pickerFlag,
            fontColor: this.isHorizontal ? $r('app.color.horizontal_title_font_color') :
            $r('sys.color.ohos_id_color_primary'),
            isHorizontal: this.isHorizontal
          })
            .padding({ end: this.leftIcon.isShown ? LengthMetrics.vp(8) : LengthMetrics.vp(0) })
            .opacity(this.folderOperateType ? this.animationController?.leftIconOpacity :
              (this.isLeftIconDisappear ? 0 : undefined))
            // 转场动效
            .transition(this.folderOperateType ||
            this.isPreviewMode ? undefined : StandardAnimation.AnimationConstants.LEFT_ARROW_TRANSITION)
            .margin({ start: this.isShowExpand() ? LengthMetrics.vp(48) : LengthMetrics.vp(0) })
          // 标题
          this.NavTitle()
        }
        .layoutWeight(1)

        // 操作菜单
        if (this.customRightButton) {
          this.customRightButton()
        } else {
          RightMenuComp({
            iconArr: this.iconArr,
            topMenu: this.topMenu,
            fileCount: this.fileCount,
            previewFile: this.previewFile,
            previewPageFrom: this.previewPageFrom,
            fontColor: this.isHorizontal ? $r('app.color.horizontal_title_font_color') :
            $r('sys.color.ohos_id_color_primary'),
            isHorizontal: this.isHorizontal
          })
            .opacity(this.isTitleDisappear ? 0 : undefined)
        }
      }
      .width('100%')
      .padding({
        left: $r('app.float.common_padding16'),
        right: $r('app.float.common_padding16')
      })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .constraintSize({
      minHeight: $r('app.float.common_size56')
    })
    .height($r('app.float.common_size56'))
    .margin({
      bottom: this.isPickerFlag ? LengthMetrics.resource($r('sys.float.padding_level4')) : LengthMetrics.vp(0)
    })
    .translate({
      x: this.folderOperateType ? this.animationController?.titleTranslateX : (this.isTitleBarMoved ? '50%' : 0)
    })
  }

  @Builder
  NavTitle() {
    Column() {
      // 标题
      TitleComp({
        title: this.title,
        subTitle: this.subTitle,
        isLevelOneTitle: this.isLevelOneTitle,
        titleCompId: this.titleCompId,
        isBigTitleAnnounce: this.isBigTitleAnnounce,
        fontColor: this.isHorizontal ? $r('app.color.horizontal_title_font_color') : $r('sys.color.ohos_id_color_primary')
      })
        .opacity(this.isTitleDisappear ? 0 : undefined)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  animationInit(): TitleBarAnimation {
    let backButtonIn: TransitionEffect = TransitionEffect.OPACITY.animation({
      delay: TitleAnimation.BACK_BUTTON_IN_DELAY,
      duration: TitleAnimation.BACK_BUTTON_IN_DURATION,
      curve: Curve.Smooth
    });
    let backButtonOut: TransitionEffect = TransitionEffect.OPACITY.animation({
      duration: TitleAnimation.BACK_BUTTON_OUT_DURATION,
      curve: Curve.Smooth
    });
    let titleIn: TransitionEffect = TransitionEffect.OPACITY.animation({
      delay: TitleAnimation.TITLE_IN_DELAY,
      duration: TitleAnimation.TITLE_IN_DURATION,
      curve: Curve.Smooth
    });

    let barIn: TransitionEffect = TransitionEffect.translate({ x: TitleAnimation.TITLE_IN_TRANSLATE })
      .animation({ duration: TitleAnimation.TITLE_OUT_DURATION, curve: Curve.Smooth });
    let barOut: TransitionEffect = TransitionEffect.OPACITY.animation({ curve: Curve.LinearOutSlowIn })
      .combine(TransitionEffect.translate({ x: TitleAnimation.TITLE_OUT_TRANSLATE }).animation({ curve: Curve.Ease }));
    return new TitleBarAnimation(
      TransitionEffect.asymmetric(backButtonIn, backButtonOut),
      titleIn,
      barIn,
      barOut,
      () => DeviceInfoUtil.isPhone())
  }

  // 监听页面关闭
  onPageClose(): void {
    if (!this.isClosePage || this.isPreviewMode) {
      return;
    }
    this.executeTitleCloseAnimation();
  }

  // 执行页面关闭时标题栏动效
  private executeTitleCloseAnimation() {
    // 标题栏位置变化
    this.getUIContext()?.animateTo({
      delay: 0,
      curve: curves.interpolatingSpring(0, 1, StandardAnimation.AnimationConstants.SHOW_ANIMATE_STIFFNESS,
        StandardAnimation.AnimationConstants.SHOW_ANIMATE_DAMPING)
    }, () => {
      this.isTitleBarMoved = true;
    })
    // 左箭头透明度变化
    this.getUIContext()?.animateTo({
      delay: 0,
      duration: 66.67,
      curve: Curve.Sharp,
    }, () => {
      this.isLeftIconDisappear = true;
    })
    // 标题和按钮透明度变化
    this.getUIContext()?.animateTo({
      delay: 16.67, // 动画延迟时间（毫秒）
      duration: 150, // 动画持续时间（毫秒）
      curve: Curve.Sharp // 动画曲线类型
    }, () => {
      this.isTitleDisappear = true;
    })
  }

  onDeviceFoldStatus(): void {
    this.isLevelOneTitle = !this.isPickerFlag &&
      DisplayUtil.isBigFoldDeviceExpanded(this.isBigFold, this.deviceFoldStatus) && !this.subTitle;
  }
}

@Styles
function pressedStyles() {
  .backgroundColor($r('sys.color.ohos_id_color_hover'))
}

@Styles
function normalStyles() {
  .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
}
