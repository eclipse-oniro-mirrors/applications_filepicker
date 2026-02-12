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
import window from '@ohos.window';
import { HiLog } from '../dfx/HiLog';
import { ObjectUtil } from '../utils/ObjectUtil';
import { GlobalHolder } from '../global/GlobalHolder';
import { GlobalKey } from '../global/GlobalKey';
import display from '@ohos.display';
import { SafePadding } from '../model/Common';
import { WindowModelData } from '../model/WindowModelData';
import { BusinessError, Callback } from '@ohos.base';
import { Constant, UserState } from '../const/Constant';
import { getResourceString } from './Tools';
import { MyPhoneConstant } from '../const/MyPhoneConstant';
import { UIExtensionContentSession } from '@kit.AbilityKit';
import { ExternalStorageUtil } from '../externel/ExternalStorageUtil';
import { VibrateType } from '../const/CompId';
import { vibrator } from '@kit.SensorServiceKit';
import { VirtualUri } from '../const/FolderRecord';
import { systemParameterEnhance } from '@kit.BasicServicesKit';
import { FileUtil } from '../fileoperate/FileUtil';
import { TabBarStyle } from '../const/LayoutStyle';
import { StringUtil } from './StringUtil';

const TAG = 'UiUtil';

export class UiUtil {
  private static readonly FILE_SPLIT: string = '/';
  /**
   * 未选择文件
   * 选择器和文件管理页面未选择文件时标题一样
   */
  public static readonly SELECT_NONE: number = 0;
  /**
   * 文件管理页面，选择1个文件，英文单数
   */
  public static readonly SELECT_ONE: number = 1;

  public static getTitleTextInMulti(checkedNum: number): string {
    let resourceManager = GlobalHolder.getInstance().getAppContext().resourceManager;
    // 未选择文件时不区分picker和文管
    if (checkedNum === UiUtil.SELECT_NONE) {
      return resourceManager.getStringSync($r('app.string.selected_none').id);
    }
    return resourceManager.getPluralStringValueSync($r('app.plural.selectedItem', checkedNum), checkedNum);
  }

  public static getCopyMoveSelectTitleSync(checkedNum: number, isCopy: boolean): string {
    let resourceManager = GlobalHolder.getInstance().getAppContext().resourceManager
    if (isCopy) {
      return resourceManager.getPluralStringValueSync($r('app.plural.copy_select_title', checkedNum), checkedNum);
    }
    return resourceManager.getPluralStringValueSync($r('app.plural.move_select_title', checkedNum), checkedNum);
  }

  public static getTitleBarCompTitle(title: string | Resource, userState: UserState, checkedNum: number = 0,
    operationType: string = '', isFilePicker: boolean = false): string {
    if (userState === UserState.BROWSER || isFilePicker) {
      if (typeof (title) === 'string') {
        return FileUtil.replaceFileName(title);
      }
      return getResourceString(title as Resource);
    }
    if (userState === UserState.MULTI_START) {
      return UiUtil.getTitleTextInMulti(checkedNum);
    }
    if ( userState === UserState.SELECT_PATH) {
      if (operationType === Constant.OPERATION_TYPE.COPY) {
        return UiUtil.getCopyMoveSelectTitleSync(checkedNum, true);
      } else if (operationType === Constant.OPERATION_TYPE.MOVE) {
        return UiUtil.getCopyMoveSelectTitleSync(checkedNum, false);
      }
      return UiUtil.getTitleTextInMulti(checkedNum);
    }
    if (userState === UserState.COPY) {
      return UiUtil.getCopyMoveSelectTitleSync(checkedNum, true);
    }
    return UiUtil.getCopyMoveSelectTitleSync(checkedNum, false);
  }

  /*
  * 文件名多语言转换
  * */
  public static translateFileName(fileName: string): string {
    return MyPhoneConstant.getMyPhoneNameLanguageValue(fileName);
  }

  /*
  * 通过文件信息进行文件名多语言转换
  * */
  public static translateFileNameByUri(fileUri: string, fileName: string, isFolder: boolean): string {
    const parentUri: string = ExternalStorageUtil.getParentUri(fileUri);
    if (MyPhoneConstant.isSystemFolder(parentUri, fileName, isFolder) ||
      fileUri.toLowerCase() === MyPhoneConstant.SYSTEM_URI.toLowerCase() ||
      ExternalStorageUtil.getParentUri(fileUri).toLowerCase() === VirtualUri.GALLERY) {
      return MyPhoneConstant.getMyPhoneNameLanguageValue(fileName);
    } else {
      return parentUri === Constant.MY_PHONE_URI ? FileUtil.replaceFileName(fileName) : fileName;
    }
  }

  public static translateFilePath(path: string): string {
    let tempPath = path;
    let lastPath: string = '';
    if (path === VirtualUri.GALLERY) {
      return UiUtil.FILE_SPLIT + getResourceString($r('app.string.pc_gallery'));
    }
    if (tempPath.startsWith(UiUtil.FILE_SPLIT)) {
      tempPath = tempPath.substring(tempPath.indexOf(UiUtil.FILE_SPLIT) + 1);
    }
    let index = tempPath.indexOf(UiUtil.FILE_SPLIT);
    if (index !== -1) {
      lastPath = tempPath.substring(index);
      tempPath = tempPath.substring(0, index);
    }
    let firstPath: string = UiUtil.translateFileName(tempPath);
    tempPath = `${UiUtil.FILE_SPLIT}${firstPath}${lastPath}`;
    return tempPath.endsWith('/') ? tempPath.substring(0, tempPath.lastIndexOf('/')) : tempPath;
  }

  public static translateMediaUriName(albumName: string): string {
    if (albumName !== '') {
      return UiUtil.FILE_SPLIT + albumName;
    }

    return '';
  }

  public static setWindowBackground(windowModeData: WindowModelData,
    windowClassKey: string = GlobalKey.WINDOW_CLASS_EXT): void {
    if (windowClassKey === GlobalKey.WINDOW_CLASS_EXT) {
      const windowClass: UIExtensionContentSession =
        GlobalHolder.getInstance().getObject<UIExtensionContentSession>(windowClassKey);
      if (!windowClass) {
        return;
      }
      try {
        let color = UiUtil.getColorString(windowModeData.barColor);
        HiLog.debug(TAG, 'setWindowBackground color:' + color);
        windowClass.setWindowBackgroundColor(color);
      } catch (err) {
        HiLog.error(TAG, 'setWindowBackgroundColor error: ' + JSON.stringify(err));
      }
      return;
    }
    const windowClass: window.Window = GlobalHolder.getInstance().getObject<window.Window>(windowClassKey);
    if (ObjectUtil.isNullOrUndefined(windowClass)) {
      return;
    }
    try {
      let color = UiUtil.getColorString(windowModeData.barColor);
      HiLog.info(TAG, 'setWindowBackground color:' + color);
      windowClass.setWindowBackgroundColor(color);
      windowClass.setWindowSystemBarEnable(['status']);
      const systemBarProperties: window.SystemBarProperties = {
        statusBarContentColor: UiUtil.getColorString($r('sys.color.ohos_id_color_foreground'))
      };
      // 更新状态栏内容的颜色
      windowClass.setWindowSystemBarProperties(systemBarProperties, (err: BusinessError) => {
        if (err.code) {
          HiLog.error(TAG, 'setWindowSystemBarProperties err=' + JSON.stringify(err));
          return;
        }
        HiLog.info(TAG, 'setWindowSystemBarProperties success');
      })
    } catch (err) {
      HiLog.error(TAG, 'setWindowBackgroundColor error: ' + JSON.stringify(err));
    }
  }

  /**
   * 获取并通过AppStorage存储屏幕上可用于操作的矩形区域的边距
   * 主要涉及曲面屏
   */
  public static async getSafePadding(): Promise<void> {
    try {
      const displayInfo: string = AppStorage.get(GlobalKey.DISPLAY_INFO) as string;
      const displayClass: display.Display = JSON.parse(displayInfo) as display.Display;
      const cutoutInfo: display.CutoutInfo = await displayClass.getCutoutInfo();
      const waterfallDisplayAreaRect = cutoutInfo.waterfallDisplayAreaRects;
      const safePadding: SafePadding = {
        left: waterfallDisplayAreaRect.left.width,
        right: waterfallDisplayAreaRect.right.width,
        top: waterfallDisplayAreaRect.top.height,
        bottom: waterfallDisplayAreaRect.bottom.height
      }
      HiLog.info(TAG, 'getSafePadding success, safePadding:' + JSON.stringify(safePadding));
      AppStorage.setOrCreate<SafePadding>('safePadding', safePadding);
    } catch (error) {
      HiLog.error(TAG, 'getSafePadding fail, error:' + JSON.stringify(error));
    }
  }

  /**
   * 颜色资源形态转为String
   * @returns #color
   */
  public static getColorString(color: Resource): string {
    const context = GlobalHolder.getInstance().getAppContext().resourceManager
    return '#' + context.getColorSync(color).toString(16)
  }

  /**
   * 是否是深色模式
   *
   * @returns true: 深色 false: 浅色
   */
  public static isDarkColorMode(): boolean {
    return AppStorage.get<boolean>('isDarkMode') || false;
  }

  public static onWindowSizeChange(callBack: Callback<window.Size>): void {
    let windowClass: UIExtensionContentSession =
      GlobalHolder.getInstance().getObject<UIExtensionContentSession>(GlobalKey.WINDOW_CLASS_EXT);
    try {
      windowClass.getUIExtensionHostWindowProxy().on('windowSizeChange', callBack);
    } catch (e) {
      HiLog.error(TAG, 'onWindowSizeChange error: ' + JSON.stringify(e));
    }
  }

  public static offWindowSizeChange(): void {
    let windowClass: UIExtensionContentSession =
      GlobalHolder.getInstance().getObject<UIExtensionContentSession>(GlobalKey.WINDOW_CLASS_EXT);
    try {
      windowClass.getUIExtensionHostWindowProxy().off('windowSizeChange');
    } catch (e) {
      HiLog.error(TAG, 'offWindowSizeChange error: ' + JSON.stringify(e));
    }
  }

  // 是否展示页面切换动效
  public static showSwitchAnimation(navMode: NavigationMode) {
    return navMode !== NavigationMode.Split;
  }

  // 长按震动反馈（拖拽、长按菜单）
  public static touchVibrate(type: VibrateType) {
    try {
      let vibrateParam: string = '';
      if (type === VibrateType.LONG_PRESS) {
        vibrateParam = 'haptic.long_press_medium';
      } else if (type === VibrateType.DRAG_UP) {
        vibrateParam = 'haptic.drag';
      } else {
        HiLog.error(TAG, 'unexpected vibrate type');
      }
      HiLog.info(TAG, `vibrate effectId param ${vibrateParam}`);
      vibrator.startVibration({
        type: 'preset',
        effectId: vibrateParam,
        count: 1
      }, {
        id: 0,
        usage: 'touch'
      }, (error: BusinessError) => {
        if (error) {
          HiLog.error(TAG, `Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
          return;
        }
        HiLog.info(TAG, 'Succeed in starting vibration.');
      })
    } catch (err) {
      HiLog.error(TAG, `touchVibrate error: ${err}`);
    }
  }


  // 获取屏幕横竖屏变化（phone的接口整改，适配多设备）
  public static getOrientationStatus(display?: string): boolean {
    try {
      if (display) {
        const width: number = JSON.parse(display).width as number;
        const height: number = JSON.parse(display).height as number;
        return width > height;
      }
    } catch (err) {
      HiLog.error(TAG, 'UiUtil getOrientation');
    }
    return false;
  }

  // 获取窗口宽度
  public static getWidth(): number {
    let windowClass: UIExtensionContentSession =
      GlobalHolder.getInstance().getObject<UIExtensionContentSession>(GlobalKey.WINDOW_CLASS_EXT);
    try {
      let win = windowClass.getUIExtensionWindowProxy();
      let width = win.properties.uiExtensionHostWindowProxyRect.width;
      HiLog.info(TAG, `UiUtil getWidth:${width}`);
      return width;
    } catch (err) {
      HiLog.error(TAG, 'UiUtil getWidth fail');
    }
    return 0;
  }

  public static getFontSize(): number {
    let bigMode: number = Constant.BIG_MODE.BIG_MODE_1x;
    try {
      let tmpMode: string = systemParameterEnhance.getSync('persist.sys.font_scale_for_user0',
        Constant.BIG_MODE_DEFAULT_MULTIPLE_VALUE);
      if (StringUtil.isEmpty(tmpMode)) {
        HiLog.error(TAG, 'big mode string is empty.');
        return bigMode;
      }
      let tmpNum: number = Number(tmpMode);
      if (isNaN(tmpNum)) {
        HiLog.error(TAG, 'big mode string contains non-numeric characters');
        return bigMode;
      }
      bigMode = tmpNum;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      HiLog.error(TAG, `getSync unexpected error code：${err?.code}, message: ${err?.message}`);
    }
    return bigMode;
  }

  public static getGeometryIdStr(fileUri: string) {
    let geometryIdStr = fileUri + '#' + '#' +
      '#' + '#';
    return geometryIdStr;
  }

  public static getTabBarPadding(isVerticalTabBar: boolean, bottomNavBarHeight: number): number {
    let padding: number = 0;
    if (isVerticalTabBar) {
      padding = TabBarStyle.SINGLE_SCREEN_HEIGHT;
    } else {
      padding = TabBarStyle.FOLD_EXPANDED_HEIGHT;
    }
    return padding + bottomNavBarHeight;
  }
}