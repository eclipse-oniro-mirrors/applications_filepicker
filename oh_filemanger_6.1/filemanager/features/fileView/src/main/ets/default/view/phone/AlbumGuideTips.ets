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
  AbilityCommonUtil,
  AbilityOrRouterParams,
  CommonPreferenceUtil,
  Constant,
  FileDataSource,
  HiLog,
  LanguageUtil,
  ObjectUtil,
  PAGE_ROUTE_CONST,
  PreferenceConst,
  ResourceUtil,
  UserState
} from '@ohos/common';
import { i18n, intl } from '@kit.LocalizationKit';

const TAG = 'AlbumGuideTips';

@Component
export struct AlbumGuideTips {
  public popupContextOneCtr: TextController = new TextController();
  public popupContextTwoCtr: TextController = new TextController();
  @State isExistFusionAlbum: boolean = false;
  @State hoDataPathname: string = '';
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State isAlreadyCloseAlbumGuideTip: boolean = false;
  @State fusionFolderUri: string = '';
  @Consume('currLocalFolder') currLocalFolder: string;
  @StorageLink('systemLanguage') @Watch('updatePopupContext') systemLanguage: string = '';
  @Link @Watch('updatePopupContext') fileListSource: FileDataSource;
  @Link userState: UserState;
  pageFrom: string = '';
  @State hoDataGuideString: StyledString = new StyledString('');
  isPicker: boolean = false;
  private preferenceKey: string = '';
  private hoPathGestureStyle: GestureStyle = new GestureStyle({
    onClick: () => {
      HiLog.info(TAG, `StyledString onClick`);
      const params = {
        uriPath: this.fusionFolderUri,
        pageFrom: this.pageFrom
      } as AbilityOrRouterParams;
      this.currLocalFolder = '';
      this.userState = UserState.BROWSER;
      this.pageInfos.pushPath(new NavPathInfo(PAGE_ROUTE_CONST.MY_PHONE, params), true);
    }
  })
  private tipTextStyle: TextStyle = new TextStyle({ fontColor: $r('sys.color.ohos_id_color_text_primary_activated') });

  private updatePopupContext(): void {
    this.fusionFolderUri = this.fileListSource.getFusionAlbumUri();
    this.isExistFusionAlbum = this.fileListSource.isExistFusionAlbum();
    HiLog.infoPrivate(TAG, `updatePopupContext isExistFusionAlbum: ${this.isExistFusionAlbum}`,
      `fusionFolderUri: ${this.fusionFolderUri}`);
  }

  onPageShow(): void {
    HiLog.warn(TAG, 'onPageShow');
    this.updatePopupContext();
  }

  aboutToAppear() {
    HiLog.warn(TAG, 'aboutToAppear');
    this.preferenceKey = PreferenceConst.KEY.ALBUM_GUIDE_TIP + this.isPicker + this.currLocalFolder;
    CommonPreferenceUtil.getTipsAlreadyShowSwitch(this.preferenceKey)
      .then((res: boolean) => {
        this.isAlreadyCloseAlbumGuideTip = res;
      })
  }

  build() {
    if (!this.isAlreadyCloseAlbumGuideTip) {
      Column() {
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Start }) {
          Text($r('app.string.tip_popup_title'))
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyHeiTi')
            .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)

          SymbolGlyph($r('sys.symbol.xmark'))
            .draggable(false)
            .fontColor([$r('sys.color.icon_secondary')])
            .fontSize($r('app.float.common_size18'))
            .onClick(() => {
              HiLog.info(TAG, `AlbumGuideTips closed.`);
              this.isAlreadyCloseAlbumGuideTip = true;
              CommonPreferenceUtil.setTipsAlreadyShowSwitch(this.preferenceKey, true);
            })
            .padding(2)
            .borderRadius($r('sys.float.corner_radius_level10'))
            .accessibilityRole(AccessibilityRoleType.BUTTON)
            .accessibilityText(ResourceUtil.getStringByResource($r('app.string.close')))
        }
        .margin({
          bottom: $r('app.float.common_margin6')
        })

        if (this.isExistFusionAlbum) {
          this.buildTipContext(this.popupContextOneCtr)
        }

        this.buildTipContext(this.popupContextTwoCtr)
      }
      .onAppear(()=>{
        this.onPageShow()
      })
      .alignItems(HorizontalAlign.Start)
      .borderRadius($r('sys.float.corner_radius_level8'))
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .padding({
        left: $r('sys.float.padding_level6'),
        right: $r('sys.float.padding_level6'),
        top: $r('sys.float.padding_level6'),
        bottom: $r('sys.float.padding_level6')
      })
      .margin({
        right: $r('sys.float.padding_level8'),
        left: $r('sys.float.padding_level8'),
        top: $r('sys.float.padding_level4')
      })
      .flexShrink(0) // 让tip不被压缩
    }
  }

  // 构建气泡窗口下的提示
  @Builder
  buildTipContext(controller: TextController) {
    Text(undefined, { controller: controller })
      .fontSize($r('sys.float.Body_M'))
      .fontColor($r('sys.color.font_secondary'))
      .maxFontScale(Constant.BIG_MODE.BIG_MODE_2x)
  }

  // 构建MutableStyledString，将template中的%s占位符替换为values中的值，并为其设置style与绑定事件
  private buildMutableStyledString(template: string, values: string[], styles: (TextStyle | null)[],
    gestureStyles: (GestureStyle | null)[]): StyledString {
    const placeholder = /%(\d+)\$s/g;
    let replacedStrPosArray: number[] = new Array(values.length);
    let resultStr: string = '';
    let templateCursor: number = 0;
    let matchRes: RegExpExecArray | null;
    while (true) {
      matchRes = placeholder.exec(template);
      if (!matchRes) {
        break;
      }
      const n = Number(matchRes[1]);
      const replaceStr: string = (values === null || n <= 0 || n - 1 >= values.length) ? '' : values[n - 1] ?? '';
      resultStr += template.slice(templateCursor, matchRes.index);
      replacedStrPosArray[n - 1] = resultStr.length;
      resultStr += replaceStr;
      templateCursor = matchRes.index + matchRes[0].length;
    }
    resultStr += template.slice(templateCursor);

    let mutableStr: MutableStyledString = new MutableStyledString(resultStr);
    let arrayIdx: number = 0;
    while (arrayIdx < values.length) {
      if (arrayIdx < styles.length && !ObjectUtil.isNullOrUndefined(styles[arrayIdx])) {
        mutableStr.setStyle({
          start: replacedStrPosArray[arrayIdx],
          length: values[arrayIdx].length,
          styledKey: StyledStringKey.FONT,
          styledValue: styles[arrayIdx]
        });
      }
      if (arrayIdx < gestureStyles.length && !ObjectUtil.isNullOrUndefined(gestureStyles[arrayIdx])) {
        mutableStr.setStyle({
          start: replacedStrPosArray[arrayIdx],
          length: values[arrayIdx].length,
          styledKey: StyledStringKey.GESTURE,
          styledValue: gestureStyles[arrayIdx]
        });
      }
      ++arrayIdx;
    }
    return mutableStr;
  }

  // 构建路径
  private buildFolderPath(folderPathList: string[]): string {
    let resultStr: string = '';
    let isFirstItem: boolean = true;
    folderPathList.forEach((item: string) => {
      if (isFirstItem) {
        resultStr += item;
        isFirstItem = false;
      } else {
        resultStr = ResourceUtil.getStringByResource($r('app.string.two_placeholders', resultStr, item));
      }
    });
    return resultStr;
  }

  // 数字格式化
  private getFormatNumber(num: number, skeleton: string): string {
    let formattedNumber: string = '';
    try {
      const language: string = LanguageUtil.getSystemLanguage();
      let locale: intl.Locale = new intl.Locale(language);
      let formatter: i18n.SimpleNumberFormat = i18n.getSimpleNumberFormatBySkeleton(skeleton, locale);
      formattedNumber = formatter.format(num);
    } catch (err) {
      HiLog.error(TAG, `getFormatNumber fail, error code: ${err?.code}, msg: ${err?.message}`);
    }
    return formattedNumber;
  }
}