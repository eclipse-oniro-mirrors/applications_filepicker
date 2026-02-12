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
  GlobalHolder,
  GlobalKey,
  UserState,
  Constant,
  MyPhoneConstant,
  SYSTEM_BAR_COLOR,
  UiUtil,
  VibrateType,
  getResourceString,
  HiLog,
  VirtualUri,
  TabBarStyle
} from '@ohos/common';
import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { UIExtensionContentSession } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import { window } from '@kit.ArkUI';
import { AsyncCallback, BusinessError, systemParameterEnhance } from '@kit.BasicServicesKit';

export default function UiUtilTest() {
  describe("UiUtilTest", () => {
    const TAG: string = 'UiUtil';

    it('getTitleTextInMulti', 0, () => {
      // 构造自定义Context和resourceManager
      const myResourceManager: resourceManager.ResourceManager = {
        getStringSync: (resId: number) => {
          return '未选择';
        }
      } as resourceManager.ResourceManager;
      const myContext: Context = { resourceManager: myResourceManager } as Context;
      const globalHolder = GlobalHolder.getInstance();
      // mock context
      const mocker: MockKit = new MockKit();
      let mockFunction = mocker.mockFunc(globalHolder, globalHolder.getAppContext);
      when(mockFunction)().afterReturn(myContext);
      let result: string = UiUtil.getTitleTextInMulti(UiUtil.SELECT_NONE);
      mocker.clear(globalHolder);
      expect(result).assertEqual('未选择');
    })

    it("getCopyMoveSelectTitleSync_CopiesOneItemTo", 0, (done: Function) => {
      let result: string = UiUtil.getCopyMoveSelectTitleSync(1, true);
      expect(result).assertEqual('复制 1 项到');
      done();
    });

    it("getCopyMoveSelectTitleSync_MovesOneItemTo", 0, (done: Function) => {
      let result1: string = UiUtil.getCopyMoveSelectTitleSync(1, false);
      expect(result1).assertEqual('移动 1 项到');
      done();
    });

    it("getTitleBarCompTitle_SelectedOneItem", 0, (done: Function) => {
      let resource = $r('app.string.selected');
      GlobalHolder.getInstance().setObject<number>(GlobalKey.PICK_NUM_LIMIT, 2);
      let result: string = UiUtil.getTitleBarCompTitle(resource, UserState.MULTI_START, 1);
      expect(result).assertEqual('已选择 1 项');
      done();
    });

    it("getTitleBarCompTitle_CopyOneItem", 0, (done: Function) => {
      let resource = $r('app.string.selected');
      GlobalHolder.getInstance().setObject<number>(GlobalKey.PICK_NUM_LIMIT, 2);
      let result: string = UiUtil.getTitleBarCompTitle(resource, UserState.COPY, 1);
      expect(result).assertEqual('复制 1 项到');
      done();
    });

    it("getTitleBarCompTitle_MoveOneItem", 0, (done: Function) => {
      let resource = $r('app.string.selected');
      GlobalHolder.getInstance().setObject<number>(GlobalKey.PICK_NUM_LIMIT, 2);
      let result: string = UiUtil.getTitleBarCompTitle(resource, UserState.MOVE, 1);
      expect(result).assertEqual('移动 1 项到');
      done();
    });

    it("getTitleBarCompTitle_UsesCustomTitle", 0, (done: Function) => {
      let title = 'str';
      let result: string = UiUtil.getTitleBarCompTitle(title, UserState.BROWSER, 1);
      expect(result).assertEqual('str');
      done();
    });

    it("getTitleBarCompTitle_UsesExternalDiskTitle", 0, (done: Function) => {
      let resource = $r('app.string.externalDisk');
      let result = UiUtil.getTitleBarCompTitle(resource, UserState.BROWSER, 1);
      expect(result).assertEqual(getResourceString(resource));
      done();
    });

    it("getTitleBarCompTitle_UsesCustomStringTitle", 0, (done: Function) => {
      let resource = $r('app.string.selected');
      GlobalHolder.getInstance().setObject<number>(GlobalKey.PICK_NUM_LIMIT, 2);
      let resourceStr = 'test';
      let result = UiUtil.getTitleBarCompTitle(resourceStr, UserState.BROWSER, 1);
      expect(result).assertEqual(resourceStr);
      done();
    });

    it("getTitleBarCompTitle_UsesCopyOperationTitle", 0, (done: Function) => {
      let resource = $r('app.string.selected');
      let result = UiUtil.getTitleBarCompTitle(resource, UserState.SELECT_PATH, 1, Constant.OPERATION_TYPE.COPY);
      expect(result).assertEqual(UiUtil.getCopyMoveSelectTitleSync(1, true));
      done();
    });

    it("getTitleBarCompTitle_UsesMoveOperationTitle", 0, (done: Function) => {
      let resource = $r('app.string.selected');
      let result = UiUtil.getTitleBarCompTitle(resource, UserState.SELECT_PATH, 1, Constant.OPERATION_TYPE.MOVE);
      expect(result).assertEqual(UiUtil.getCopyMoveSelectTitleSync(1, false));
      done();
    });

    it("getTitleBarCompTitle_UsesDefaultTitle", 0, (done: Function) => {
      let resource = $r('app.string.selected');
      let result = UiUtil.getTitleBarCompTitle(resource, UserState.SELECT_PATH, 1);
      expect(result).assertEqual(UiUtil.getTitleTextInMulti(1));
      done();
    });


    it("translateFileName", 0, (done: Function) => {
      let fileName: string = 'Documents';
      let result: string = UiUtil.translateFileName(fileName);
      expect(result).assertEqual('Documents');
      done();
    })

    it("translateFilePath", 0, (done: Function) => {
      let path: string = '/Documents/';
      let result: string = UiUtil.translateFilePath(path);
      expect(result).assertEqual('/Documents');
      done();
    })

    it('translateFilePath_gallery', 0, () => {
      let path: string = VirtualUri.GALLERY;
      let result: string = UiUtil.translateFilePath(path);
      expect(result).assertEqual('/');
    })

    it("translateFilePathNotEndWithSplit", 0, (done: Function) => {
      let path: string = '/Documents';
      let result: string = UiUtil.translateFilePath(path);
      expect(result).assertEqual('/Documents');
      done();
    })

    it("translateFilePathNotStartWithSplit", 0, (done: Function) => {
      let path: string = 'Documents/';
      let result: string = UiUtil.translateFilePath(path);
      expect(result).assertEqual('/Documents');
      done();
    })

    it("translateFilePathNotStartAndWithSplit", 0, (done: Function) => {
      let path: string = 'Documents';
      let result: string = UiUtil.translateFilePath(path);
      expect(result).assertEqual('/Documents');
      done();
    })

    it('translateFileNameByUri', 0, (done: Function) => {
      let result: string = UiUtil.translateFileNameByUri(MyPhoneConstant.SYSTEM_URI.toLowerCase(), 'test', false);
      expect(result).assertEqual('test');
      done();
    })

    it('translateFileNameByUriWithRootUri', 0, (done: Function) => {
      let fileUri = MyPhoneConstant.ROOT_URI + '/a.txt';
      let fileName = 'a.txt';
      let result: string = UiUtil.translateFileNameByUri(fileUri, fileName, false);
      expect(result).assertEqual(fileName);
      done();
    })

    it('translateFileNameByUriWithGallery', 0, (done: Function) => {
      let fileUri = VirtualUri.GALLERY + '/a.txt';
      let fileName = 'a.txt';
      let result: string = UiUtil.translateFileNameByUri(fileUri, fileName, false);
      expect(result).assertEqual(fileName);
      done();
    })

    it('translateFileNameByUriWithOther', 0, (done: Function) => {
      let fileUri = 'a/b/c.txt';
      let fileName = 'c.txt';
      let result: string = UiUtil.translateFileNameByUri(fileUri, fileName, false);
      expect(result).assertEqual(fileName);
      done();
    })

    it('translateMediaUriName', 0, () => {
      let albumName = '';
      let result: string = UiUtil.translateMediaUriName(albumName);
      expect(result).assertEqual('');
      albumName = '123';
      result = UiUtil.translateMediaUriName(albumName);
      expect(result).assertEqual('/123');
    })

    it("setWindowBackground_WithUndefinedWindowClass", 0, (done: Function) => {
      let windowClassKey = 'test';
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(GlobalHolder.getInstance(), GlobalHolder.getInstance().getObject);
      when(mockFunc)(windowClassKey).afterReturn(undefined);

      let windowClass: UIExtensionContentSession =
        GlobalHolder.getInstance().getObject<UIExtensionContentSession>(windowClassKey);
      UiUtil.setWindowBackground(SYSTEM_BAR_COLOR.PATH_PICK_DARK, windowClassKey);
      mocker.clear(GlobalHolder.getInstance());
      expect(windowClass).assertUndefined();
      done();
    });

    it('setWindowBackground_windowClass_exist', 0, () => {
      const windowClassKey = 'test';
      let mocker: MockKit = new MockKit();
      let mockFunction: Function = mocker.mockFunc(GlobalHolder.getInstance(), GlobalHolder.getInstance().getObject);
      const myWindowClass: window.Window = buildWindowClass();
      when(mockFunction)(windowClassKey).afterReturn(myWindowClass);
      mockFunction = mocker.mockFunc(UiUtil, UiUtil.getColorString);
      const color: string = '#666666';
      when(mockFunction)(ArgumentMatchers.any).afterReturn(color);
      mocker.mockFunc(HiLog, HiLog.info);
      UiUtil.setWindowBackground(SYSTEM_BAR_COLOR.PATH_PICK_DARK, windowClassKey);
      mocker.clear(GlobalHolder.getInstance());
      mocker.clear(UiUtil);
      mocker.clear(HiLog);
      mocker.verify('info', [TAG, 'setWindowBackground color:' + color]).once();
    })

    it('setWindowBackgroundWithWindowClassExtNotExist', 0, () => {
      const windowClassKey = GlobalKey.WINDOW_CLASS_EXT;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(GlobalHolder.getInstance(), GlobalHolder.getInstance().getObject);
      when(mockFunc)(windowClassKey).afterReturn(undefined);

      let windowClass: UIExtensionContentSession =
        GlobalHolder.getInstance().getObject<UIExtensionContentSession>(windowClassKey);
      UiUtil.setWindowBackground(SYSTEM_BAR_COLOR.PATH_PICK_DARK, windowClassKey);
      mocker.clear(GlobalHolder.getInstance());
      expect(windowClass).assertUndefined();
    })

    it("isDarkColorMode_ReturnsTrueWhenDarkModeEnabled", 0, (done: Function) => {
      let mocker: MockKit = new MockKit();
      const key = 'isDarkMode';
      let mockFunc: Function = mocker.mockFunc(AppStorage, AppStorage.get);
      when(mockFunc)(key).afterReturn(true);
      const result = UiUtil.isDarkColorMode();
      mocker.ignoreMock(AppStorage, AppStorage.get);
      expect(result).assertEqual(true);
      done();
    });

    it("isDarkColorMode_ReturnsFalseWhenDarkModeDisabled", 0, (done: Function) => {
      let mocker: MockKit = new MockKit();
      const key = 'isDarkMode';
      let mockFunc: Function = mocker.mockFunc(AppStorage, AppStorage.get);
      when(mockFunc)(key).afterReturn(false);
      const result = UiUtil.isDarkColorMode();
      mocker.ignoreMock(AppStorage, AppStorage.get);
      expect(result).assertEqual(false);
      done();
    });

    it("showSwitchAnimation_ReturnsTrueForStackMode", 0, (done: Function) => {
      let result = UiUtil.showSwitchAnimation(NavigationMode.Stack);
      expect(result).assertEqual(true);
      done();
    });

    it("showSwitchAnimation_ReturnsFalseForSplitMode", 0, (done: Function) => {
      let result1 = UiUtil.showSwitchAnimation(NavigationMode.Split);
      expect(result1).assertEqual(false);
      done();
    });

    it("touchVibrate", 0, (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(HiLog, HiLog.info);
      when(mockFunc)(ArgumentMatchers.anyString).afterReturnNothing();
      UiUtil.touchVibrate(VibrateType.LONG_PRESS);
      mocker.verify('info', ['UiUtil', 'vibrate effectId param haptic.long_press_medium']).once();
      mocker.ignoreMock(HiLog, HiLog.info);
      done();
    })

    it("touchVibrateWithDragUp", 0, (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(HiLog, HiLog.info);
      when(mockFunc)(ArgumentMatchers.anyString).afterReturnNothing();
      UiUtil.touchVibrate(VibrateType.DRAG_UP);
      mocker.ignoreMock(HiLog, HiLog.info);
      mocker.verify('info', ['UiUtil', 'vibrate effectId param haptic.drag']).once();
      done();
    })

    it("getOrientationStatus_ReturnsFalseForEmptyInput", 0, (done: Function) => {
      let result: boolean = UiUtil.getOrientationStatus('');
      expect(result).assertFalse();
      done();
    });

    it("getOrientationStatus_ReturnsTrueForValidJson", 0, (done: Function) => {
      let jsonStr = '{ "width":"113", "height":"112" }';
      let result: boolean = UiUtil.getOrientationStatus(jsonStr);
      expect(result).assertTrue();
      done();
    });

    it("getWidth_fail", 0, () => {
      const globalHolder = GlobalHolder.getInstance();
      const mocker: MockKit = new MockKit();
      let mockFunction = mocker.mockFunc(globalHolder, globalHolder.getObject);
      when(mockFunction)().afterReturnNothing;
      let result: number = UiUtil.getWidth();
      expect(result).assertEqual(0);
    });

    it("getWidth_success", 0, () => {
      let result: number = UiUtil.getWidth();
      expect(result).assertInstanceOf('Number');
    });

    it("getGeometryIdStr_true_true_true_false", 0, () => {
      let fileUri = 'a/b/c';
      let result: string = UiUtil.getGeometryIdStr(fileUri);
      expect(result).assertEqual('a/b/c_Recent_SourceView_Search#');
    });

    it("getGeometryIdStr_true_true_false_false", 0, () => {
      let fileUri = 'a/b/c';
      let result: string = UiUtil.getGeometryIdStr(fileUri);
      expect(result).assertEqual('a/b/c_Recent_SourceView##');
    });

    it("getGeometryIdStr_true_false_false_false", 0, () => {
      let fileUri = 'a/b/c';
      let result: string = UiUtil.getGeometryIdStr(fileUri);
      expect(result).assertEqual('a/b/c_Recent###');
    });

    it("getGeometryIdStr_false_false_false_false", 0, () => {
      let fileUri = 'a/b/c';
      let result: string = UiUtil.getGeometryIdStr(fileUri);
      expect(result).assertEqual('a/b/c####');
    });

    it("getTabBarPadding_true", 0, () => {
      let result: number = UiUtil.getTabBarPadding(true, 0);
      expect(result).assertEqual(TabBarStyle.SINGLE_SCREEN_HEIGHT);
    });

    it("getTabBarPadding_false", 0, () => {
      let result: number = UiUtil.getTabBarPadding(false, 0);
      expect(result).assertEqual(TabBarStyle.FOLD_EXPANDED_HEIGHT);
    });
  })
}

function buildWindowClass(): window.Window {
  const myWindow: window.Window = {
    setWindowBackgroundColor: (color: string) => {
    },
    setWindowSystemBarEnable: (names: Array<'status' | 'navigation'>) => {
    },
    setWindowSystemBarProperties: (systemBarProperties: window.SystemBarProperties,
      callback: AsyncCallback<void, void>) => {
      callback({code: 123} as BusinessError);
    }
  } as window.Window;
  return myWindow;
}
