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
import display from '@ohos.display';
import { Callback, systemParameterEnhance } from '@kit.BasicServicesKit';
import {
  describe,
  beforeEach,
  afterEach,
  it,
  expect,
  MockKit,
  when
} from '@ohos/hypium';
import { DisplayUtil } from '@ohos/common';
import { FoldPhoneTypeValue } from '@ohos/common/src/main/ets/const/Constant';

export default function DisplayUtilTest() {
  describe('DisplayUtilTest', () => {

    beforeEach(() => {

    });
    afterEach(() => {

    });

    it('should_return_PORTRAIT_when_displayClass_is_null', 0, () => {
      const mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getDefaultDisplaySync);
      when(mockFunc)().afterReturn(undefined);
      const result = DisplayUtil.getOrientationStatus();
      mocker.ignoreMock(DisplayUtil, DisplayUtil.getDefaultDisplaySync);
      expect(result).assertEqual(display.Orientation.PORTRAIT);
    });

    it('should_return_LANDSCAPE_when_displayClass_is_not_null', 0, () => {
      let mockDisplay: display.Display = {
        orientation: display.Orientation.LANDSCAPE,
        id: 0,
        name: '',
        alive: false,
        state: display.DisplayState.STATE_UNKNOWN,
        refreshRate: 0,
        rotation: 0,
        width: 0,
        height: 0,
        availableWidth: 0,
        availableHeight: 0,
        densityDPI: 0,
        densityPixels: 0,
        scaledDensity: 0,
        xDPI: 0,
        yDPI: 0,
        colorSpaces: [],
        hdrFormats: [],
        getCutoutInfo: () => {
          throw new Error('Function not implemented.');
        },
        hasImmersiveWindow: () => {
          throw new Error('Function not implemented.');
        },
        getAvailableArea: (): Promise<display.Rect> => {
          throw new Error('Function not implemented.');
        },
        on: (type: 'availableAreaChange', callback: Callback<display.Rect>): void => {
          throw new Error('Function not implemented.');
        },
        off: (type: 'availableAreaChange', callback?: Callback<display.Rect> | undefined): void => {
          throw new Error('Function not implemented.');
        },
        getDisplayCapability: (): string => {
          throw new Error('Function not implemented.');
        },
        getLiveCreaseRegion: (): display.FoldCreaseRegion => {
          throw new Error('Function not implemented.');
        }
      };
      const mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getDefaultDisplaySync);
      when(mockFunc)().afterReturn(mockDisplay);
      const result = DisplayUtil.getOrientationStatus();
      mocker.ignoreMock(DisplayUtil, DisplayUtil.getDefaultDisplaySync);
      expect(result).assertEqual(display.Orientation.LANDSCAPE);
    });

    it('should_return_PORTRAIT_when_displayClass_is_not_null', 0, () => {
      let mockDisplay: display.Display = {
        orientation: display.Orientation.PORTRAIT,
        id: 0,
        name: '',
        alive: false,
        state: display.DisplayState.STATE_UNKNOWN,
        refreshRate: 0,
        rotation: 0,
        width: 0,
        height: 0,
        availableWidth: 0,
        availableHeight: 0,
        densityDPI: 0,
        densityPixels: 0,
        scaledDensity: 0,
        xDPI: 0,
        yDPI: 0,
        colorSpaces: [],
        hdrFormats: [],
        getCutoutInfo: () => {
          throw new Error('Function not implemented.');
        },
        hasImmersiveWindow: () => {
          throw new Error('Function not implemented.');
        },
        getAvailableArea: (): Promise<display.Rect> => {
          throw new Error('Function not implemented.');
        },
        on: (type: 'availableAreaChange', callback: Callback<display.Rect>): void => {
          throw new Error('Function not implemented.');
        },
        off: (type: 'availableAreaChange', callback?: Callback<display.Rect> | undefined): void => {
          throw new Error('Function not implemented.');
        },
        getDisplayCapability: (): string => {
          throw new Error('Function not implemented.');
        },
        getLiveCreaseRegion: (): display.FoldCreaseRegion => {
          throw new Error('Function not implemented.');
        }
      };
      const mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getDefaultDisplaySync);
      when(mockFunc)().afterReturn(mockDisplay);
      const result = DisplayUtil.getOrientationStatus();
      mocker.ignoreMock(DisplayUtil, DisplayUtil.getDefaultDisplaySync);
      expect(result).assertEqual(display.Orientation.PORTRAIT);
    });

    it('should_return_PORTRAIT_INVERTED_when_displayClass_is_not_null', 0, () => {
      let mockDisplay: display.Display = {
        orientation: display.Orientation.PORTRAIT_INVERTED,
        id: 0,
        name: '',
        alive: false,
        state: display.DisplayState.STATE_UNKNOWN,
        refreshRate: 0,
        rotation: 0,
        width: 0,
        height: 0,
        availableWidth: 0,
        availableHeight: 0,
        densityDPI: 0,
        densityPixels: 0,
        scaledDensity: 0,
        xDPI: 0,
        yDPI: 0,
        colorSpaces: [],
        hdrFormats: [],
        getCutoutInfo: () => {
          throw new Error('Function not implemented.');
        },
        hasImmersiveWindow: () => {
          throw new Error('Function not implemented.');
        },
        getAvailableArea: (): Promise<display.Rect> => {
          throw new Error('Function not implemented.');
        },
        on: (type: 'availableAreaChange', callback: Callback<display.Rect>): void => {
          throw new Error('Function not implemented.');
        },
        off: (type: 'availableAreaChange', callback?: Callback<display.Rect> | undefined): void => {
          throw new Error('Function not implemented.');
        },
        getDisplayCapability: (): string => {
          throw new Error('Function not implemented.');
        },
        getLiveCreaseRegion: (): display.FoldCreaseRegion => {
          throw new Error('Function not implemented.');
        }
      };
      const mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getDefaultDisplaySync);
      when(mockFunc)().afterReturn(mockDisplay);
      const result = DisplayUtil.getOrientationStatus();
      mocker.ignoreMock(DisplayUtil, DisplayUtil.getDefaultDisplaySync);
      expect(result).assertEqual(display.Orientation.PORTRAIT_INVERTED);
    });

    it('should_return_LANDSCAPE_INVERTED_when_displayClass_is_not_null', 0, () => {
      let mockDisplay: display.Display = {
        orientation: display.Orientation.LANDSCAPE_INVERTED,
        id: 0,
        name: '',
        alive: false,
        state: display.DisplayState.STATE_UNKNOWN,
        refreshRate: 0,
        rotation: 0,
        width: 0,
        height: 0,
        availableWidth: 0,
        availableHeight: 0,
        densityDPI: 0,
        densityPixels: 0,
        scaledDensity: 0,
        xDPI: 0,
        yDPI: 0,
        colorSpaces: [],
        hdrFormats: [],
        getCutoutInfo: () => {
          throw new Error('Function not implemented.');
        },
        hasImmersiveWindow: () => {
          throw new Error('Function not implemented.');
        },
        getAvailableArea: (): Promise<display.Rect> => {
          throw new Error('Function not implemented.');
        },
        on: (type: 'availableAreaChange', callback: Callback<display.Rect>): void => {
          throw new Error('Function not implemented.');
        },
        off: (type: 'availableAreaChange', callback?: Callback<display.Rect> | undefined): void => {
          throw new Error('Function not implemented.');
        },
        getDisplayCapability: (): string => {
          throw new Error('Function not implemented.');
        },
        getLiveCreaseRegion: (): display.FoldCreaseRegion => {
          throw new Error('Function not implemented.');
        }
      };
      const mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getDefaultDisplaySync);
      when(mockFunc)().afterReturn(mockDisplay);
      const result = DisplayUtil.getOrientationStatus();
      mocker.ignoreMock(DisplayUtil, DisplayUtil.getDefaultDisplaySync);
      expect(result).assertEqual(display.Orientation.LANDSCAPE_INVERTED);
    });

    it('getDefaultDisplaySync_should_return_hot_area_length_when_displayClass_is_not_null_and_PORTRAIT', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockDisplay: display.Display = {
        densityDPI: 320,
        densityPixels: 160,
        width: 1080,
        height: 1920,
        id: 0,
        name: '',
        alive: false,
        state: display.DisplayState.STATE_UNKNOWN,
        refreshRate: 0,
        rotation: 0,
        availableWidth: 0,
        availableHeight: 0,
        orientation: display.Orientation.PORTRAIT,
        scaledDensity: 0,
        xDPI: 0,
        yDPI: 0,
        colorSpaces: [],
        hdrFormats: [],
        getCutoutInfo: () => {
          throw new Error('Function not implemented.');
        },
        hasImmersiveWindow: () => {
          throw new Error('Function not implemented.');
        },
        getAvailableArea: (): Promise<display.Rect> => {
          throw new Error('Function not implemented.');
        },
        on: (type: 'availableAreaChange', callback: Callback<display.Rect>): void => {
          throw new Error('Function not implemented.');
        },
        off: (type: 'availableAreaChange', callback?: Callback<display.Rect> | undefined): void => {
          throw new Error('Function not implemented.');
        },
        getDisplayCapability: (): string => {
          throw new Error('Function not implemented.');
        },
        getLiveCreaseRegion: (): display.FoldCreaseRegion => {
          throw new Error('Function not implemented.');
        }
      };
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getDefaultDisplaySync);
      when(mockFunc)().afterReturn(mockDisplay);
      const result = DisplayUtil.getHotAreaLength();
      mocker.ignoreMock(DisplayUtil, DisplayUtil.getDefaultDisplaySync);
      expect(result).assertLarger(0);
    });

    it('getDefaultDisplaySync_should_return_hot_area_length_when_displayClass_is_not_null_and_LANDSCAPE', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockDisplay: display.Display = {
        densityDPI: 320,
        densityPixels: 160,
        width: 1920,
        height: 1080,
        id: 0,
        name: '',
        alive: false,
        state: display.DisplayState.STATE_UNKNOWN,
        refreshRate: 0,
        rotation: 0,
        availableWidth: 0,
        availableHeight: 0,
        orientation: display.Orientation.LANDSCAPE,
        scaledDensity: 0,
        xDPI: 0,
        yDPI: 0,
        colorSpaces: [],
        hdrFormats: [],
        getCutoutInfo: () => {
          throw new Error('Function not implemented.');
        },
        hasImmersiveWindow: () => {
          throw new Error('Function not implemented.');
        },
        getAvailableArea: (): Promise<display.Rect> => {
          throw new Error('Function not implemented.');
        },
        on: (type: 'availableAreaChange', callback: Callback<display.Rect>): void => {
          throw new Error('Function not implemented.');
        },
        off: (type: 'availableAreaChange', callback?: Callback<display.Rect> | undefined): void => {
          throw new Error('Function not implemented.');
        },
        getDisplayCapability: (): string => {
          throw new Error('Function not implemented.');
        },
        getLiveCreaseRegion: (): display.FoldCreaseRegion => {
          throw new Error('Function not implemented.');
        }
      };
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getDefaultDisplaySync);
      when(mockFunc)().afterReturn(mockDisplay);
      const result = DisplayUtil.getHotAreaLength();
      mocker.ignoreMock(DisplayUtil, DisplayUtil.getDefaultDisplaySync);
      expect(result).assertLarger(0);
    });

    it('getDefaultDisplaySync_should_return_undefined_when_displayClass_is_null', 0, () => {
      const mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getDefaultDisplaySync);
      when(mockFunc)().afterReturn(undefined);
      const result = DisplayUtil.getHotAreaLength();
      mocker.ignoreMock(DisplayUtil, DisplayUtil.getDefaultDisplaySync);
      expect(result).assertUndefined();
    });

    it('getAutoScrollMaxSpeed_should_return_undefined_when_densityPixels_is_null', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockDisplay: display.Display = {
        densityDPI: 320,
        densityPixels: 0,
        width: 1080,
        height: 1920,
        id: 0,
        name: '',
        alive: false,
        state: display.DisplayState.STATE_UNKNOWN,
        refreshRate: 0,
        rotation: 0,
        availableWidth: 0,
        availableHeight: 0,
        orientation: display.Orientation.PORTRAIT,
        scaledDensity: 0,
        xDPI: 0,
        yDPI: 0,
        colorSpaces: [],
        hdrFormats: [],
        getCutoutInfo: () => {
          throw new Error('Function not implemented.');
        },
        hasImmersiveWindow: () => {
          throw new Error('Function not implemented.');
        },
        getAvailableArea: (): Promise<display.Rect> => {
          throw new Error('Function not implemented.');
        },
        on: (type: 'availableAreaChange', callback: Callback<display.Rect>): void => {
          throw new Error('Function not implemented.');
        },
        off: (type: 'availableAreaChange', callback?: Callback<display.Rect> | undefined): void => {
          throw new Error('Function not implemented.');
        },
        getDisplayCapability: (): string => {
          throw new Error('Function not implemented.');
        },
        getLiveCreaseRegion: (): display.FoldCreaseRegion => {
          throw new Error('Function not implemented.');
        }
      };
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getDefaultDisplaySync);
      when(mockFunc)().afterReturn(mockDisplay);
      const result = DisplayUtil.getAutoScrollMaxSpeed();
      mocker.ignoreMock(DisplayUtil, DisplayUtil.getDefaultDisplaySync);
      expect(result).assertEqual(undefined);
    });

    it('should_return_autoScrollMaxSpeed_when_densityPixels_is_not_null', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockDisplay: display.Display = {
        densityDPI: 320,
        densityPixels: 160,
        width: 1080,
        height: 1920,
        id: 0,
        name: '',
        alive: false,
        state: display.DisplayState.STATE_UNKNOWN,
        refreshRate: 0,
        rotation: 0,
        availableWidth: 0,
        availableHeight: 0,
        orientation: display.Orientation.PORTRAIT,
        scaledDensity: 0,
        xDPI: 0,
        yDPI: 0,
        colorSpaces: [],
        hdrFormats: [],
        getCutoutInfo: () => {
          throw new Error('Function not implemented.');
        },
        hasImmersiveWindow: () => {
          throw new Error('Function not implemented.');
        },
        getAvailableArea: (): Promise<display.Rect> => {
          throw new Error('Function not implemented.');
        },
        on: (type: 'availableAreaChange', callback: Callback<display.Rect>): void => {
          throw new Error('Function not implemented.');
        },
        off: (type: 'availableAreaChange', callback?: Callback<display.Rect> | undefined): void => {
          throw new Error('Function not implemented.');
        },
        getDisplayCapability: (): string => {
          throw new Error('Function not implemented.');
        },
        getLiveCreaseRegion: (): display.FoldCreaseRegion => {
          throw new Error('Function not implemented.');
        }
      };
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getDefaultDisplaySync);
      when(mockFunc)().afterReturn(mockDisplay);
      const result = DisplayUtil.getAutoScrollMaxSpeed();
      mocker.ignoreMock(DisplayUtil, DisplayUtil.getDefaultDisplaySync);
      expect(result).assertEqual(Math.round(DisplayUtil.CURVE_MAX_SPEED / 160));
    });

    it('atc_should_return_true_when_display_is_foldable', 0, async () => {
      const result: ESObject = DisplayUtil.isFoldable();
      const isFoldable = display.isFoldable();
      expect(result).assertEqual(isFoldable);
    });

    it('get_fold_status_atc_should_return_fold_status', 0, async () => {
      const result: ESObject = DisplayUtil.getFoldStatus();
      const foldStatus = display.getFoldStatus();
      expect(result).assertEqual(foldStatus);
    });

    it('get_fold_product__atc_should_return_fold_phone_type_value', 0, async () => {
      const productValue = systemParameterEnhance.getSync(DisplayUtil.FOLD_PRODUCT_TYPE,
        DisplayUtil.DEFAULTS_FOLD_TYPE);
      const productType = productValue.split(',');
      const result: ESObject = DisplayUtil.getFoldProductType();
      expect(result).assertEqual(parseInt(productType[0]));
    });

    it('should_return_true_when_product_type_is_large_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.LARGE_FOLD);
      const result = DisplayUtil.isBigFold();
      expect(result).assertEqual(true);
      mocker.clear(DisplayUtil);
    });

    it('should_return_true_when_product_type_is_external_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXTERNAL_FOLD);
      const result = DisplayUtil.isBigFold();
      expect(result).assertEqual(true);
      mocker.clear(DisplayUtil);
    });

    it('should_return_true_when_product_type_is_triple_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.TRIPLE_FOLD);
      const result = DisplayUtil.isBigFold();
      expect(result).assertEqual(true);
      mocker.clear(DisplayUtil);
    });

    it('should_return_false_when_product_type_is_invalid_value', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.INVALID_VALUE);
      const result = DisplayUtil.isBigFold();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('should_return_false_when_product_type_is_straight', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.STRAIGHT);
      const result = DisplayUtil.isBigFold();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('should_return_false_when_product_type_is_small_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.SMALL_FOLD);
      const result = DisplayUtil.isBigFold();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('should_return_false_when_product_type_is_expanding_new_forms', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXPANDING_NEX_FORMS);
      const result = DisplayUtil.isBigFold();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_xt_device_should_return_false_when_product_type_is_large_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.LARGE_FOLD);
      const result = DisplayUtil.isXtDevice();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_xt_device_should_return_false_when_product_type_is_external_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXTERNAL_FOLD);
      const result = DisplayUtil.isXtDevice();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_xt_device_should_return_true_when_product_type_is_triple_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.TRIPLE_FOLD);
      const result = DisplayUtil.isXtDevice();
      expect(result).assertEqual(true);
      mocker.clear(DisplayUtil);
    });

    it('is_xt_device_should_return_false_when_product_type_is_invalid_value', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.INVALID_VALUE);
      const result = DisplayUtil.isXtDevice();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_xt_device_should_return_false_when_product_type_is_straight', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.STRAIGHT);
      const result = DisplayUtil.isXtDevice();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_xt_device_should_return_false_when_product_type_is_small_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.SMALL_FOLD);
      const result = DisplayUtil.isXtDevice();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_xt_device_should_return_false_when_product_type_is_expanding_new_forms', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXPANDING_NEX_FORMS);
      const result = DisplayUtil.isXtDevice();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_big_fold_device_expanded_when_isBigFold_is_false_and_foldstatus_equals_expanded', 0, () => {
      const result = DisplayUtil.isBigFoldDeviceExpanded(false, DisplayUtil.FOLD_STATUS_EXPANDED);
      expect(result).assertEqual(false);
    });

    it('is_big_fold_device_expanded_when_isBigFold_is_false_and_foldstatus_equals_half_folded', 0, () => {
      const result = DisplayUtil.isBigFoldDeviceExpanded(false, DisplayUtil.FOLD_STATUS_HALF_FOLDED);
      expect(result).assertEqual(false);
    });

    it('is_big_fold_device_expanded_when_isBigFold_is_false_and_foldstatus_equals_others', 0, () => {
      const result = DisplayUtil.isBigFoldDeviceExpanded(false, 999);
      expect(result).assertEqual(false);
    });

    it('is_big_fold_device_expanded_when_isBigFold_is_true_and_foldstatus_equals_expanded', 0, () => {
      const result = DisplayUtil.isBigFoldDeviceExpanded(true, DisplayUtil.FOLD_STATUS_EXPANDED);
      expect(result).assertEqual(true);
    });

    it('is_big_fold_device_expanded_when_isBigFold_is_true_and_foldstatus_equals_half_folded', 0, () => {
      const result = DisplayUtil.isBigFoldDeviceExpanded(true, DisplayUtil.FOLD_STATUS_HALF_FOLDED);
      expect(result).assertEqual(true);
    });

    it('is_big_fold_device_expanded_when_isBigFold_is_true_and_foldstatus_equals_others', 0, () => {
      const result = DisplayUtil.isBigFoldDeviceExpanded(true, 999);
      expect(result).assertEqual(false);
    });

    it('is_outside_expanded_when_product_type_is_invalid_value_and_foldStatus_is_expanded', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.INVALID_VALUE);
      const result = DisplayUtil.isOutsideExpanded(DisplayUtil.FOLD_STATUS_EXPANDED);
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_expanded_when_product_type_is_invalid_value_and_foldStatus_is_half_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.INVALID_VALUE);
      const result = DisplayUtil.isOutsideExpanded(DisplayUtil.FOLD_STATUS_HALF_FOLDED);
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_expanded_when_product_type_is_invalid_value_and_foldStatus_is_others', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.INVALID_VALUE);
      const result = DisplayUtil.isOutsideExpanded(999);
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_expanded_when_product_type_is_straight_and_foldStatus_is_expanded', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.STRAIGHT);
      const result = DisplayUtil.isOutsideExpanded(DisplayUtil.FOLD_STATUS_EXPANDED);
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_expanded_when_product_type_is_straight_and_foldStatus_is_half_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.STRAIGHT);
      const result = DisplayUtil.isOutsideExpanded(DisplayUtil.FOLD_STATUS_HALF_FOLDED);
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_expanded_when_product_type_is_straight_and_foldStatus_is_others', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.STRAIGHT);
      const result = DisplayUtil.isOutsideExpanded(999);
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_expanded_when_product_type_is_large_fold_and_foldStatus_is_expanded', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.LARGE_FOLD);
      const result = DisplayUtil.isOutsideExpanded(DisplayUtil.FOLD_STATUS_EXPANDED);
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_expanded_when_product_type_is_large_fold_and_foldStatus_is_half_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.LARGE_FOLD);
      const result = DisplayUtil.isOutsideExpanded(DisplayUtil.FOLD_STATUS_HALF_FOLDED);
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_expanded_when_product_type_is_large_fold_and_foldStatus_is_others', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.LARGE_FOLD);
      const result = DisplayUtil.isOutsideExpanded(999);
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_expanded_when_product_type_is_small_fold_and_foldStatus_is_expanded', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.SMALL_FOLD);
      const result = DisplayUtil.isOutsideExpanded(DisplayUtil.FOLD_STATUS_EXPANDED);
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_expanded_when_product_type_is_small_fold_and_foldStatus_is_half_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.SMALL_FOLD);
      const result = DisplayUtil.isOutsideExpanded(DisplayUtil.FOLD_STATUS_HALF_FOLDED);
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_expanded_when_product_type_is_small_fold_and_foldStatus_is_others', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.SMALL_FOLD);
      const result = DisplayUtil.isOutsideExpanded(999);
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_expanded_when_product_type_is_external_fold_and_foldStatus_is_expanded', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXTERNAL_FOLD);
      const result = DisplayUtil.isOutsideExpanded(DisplayUtil.FOLD_STATUS_EXPANDED);
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_expanded_when_product_type_is_external_fold_and_foldStatus_is_half_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXTERNAL_FOLD);
      const result = DisplayUtil.isOutsideExpanded(DisplayUtil.FOLD_STATUS_HALF_FOLDED);
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_expanded_when_product_type_is_external_fold_and_foldStatus_is_others', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXTERNAL_FOLD);
      const result = DisplayUtil.isOutsideExpanded(999);
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_expanded_when_product_type_is_expand_nex_forms_and_foldStatus_is_expanded', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXPANDING_NEX_FORMS);
      const result = DisplayUtil.isOutsideExpanded(DisplayUtil.FOLD_STATUS_EXPANDED);
      expect(result).assertEqual(true);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_expanded_when_product_type_is_expand_nex_forms_and_foldStatus_is_half_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXPANDING_NEX_FORMS);
      const result = DisplayUtil.isOutsideExpanded(DisplayUtil.FOLD_STATUS_HALF_FOLDED);
      expect(result).assertEqual(true);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_expanded_when_product_type_is_expand_nex_forms_and_foldStatus_is_others', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXPANDING_NEX_FORMS);
      const result = DisplayUtil.isOutsideExpanded(999);
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_expanded_when_product_type_is_triple_fold_and_foldStatus_is_expanded', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.TRIPLE_FOLD);
      const result = DisplayUtil.isOutsideExpanded(DisplayUtil.FOLD_STATUS_EXPANDED);
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_expanded_when_product_type_is_triple_fold_and_foldStatus_is_half_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.TRIPLE_FOLD);
      const result = DisplayUtil.isOutsideExpanded(DisplayUtil.FOLD_STATUS_HALF_FOLDED);
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_expanded_when_product_type_is_triple_fold_and_foldStatus_is_others', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.TRIPLE_FOLD);
      const result = DisplayUtil.isOutsideExpanded(999);
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_device_when_product_type_is_invalid_value', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.INVALID_VALUE);
      const result = DisplayUtil.isOutsideScreenDevice();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_device_when_product_type_is_straight', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.STRAIGHT);
      const result = DisplayUtil.isOutsideScreenDevice();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_device_when_product_type_is_large_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.LARGE_FOLD);
      const result = DisplayUtil.isOutsideScreenDevice();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_device_when_product_type_is_small_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.SMALL_FOLD);
      const result = DisplayUtil.isOutsideScreenDevice();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_device_when_product_type_is_external_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXTERNAL_FOLD);
      const result = DisplayUtil.isOutsideScreenDevice();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_device_when_product_type_is_expand_nex_forms', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXPANDING_NEX_FORMS);
      const result = DisplayUtil.isOutsideScreenDevice();
      expect(result).assertEqual(true);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_device_when_product_type_is_triple_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.TRIPLE_FOLD);
      const result = DisplayUtil.isOutsideScreenDevice();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_folded_when_product_type_is_invalid_value_and_fold_status_is_status_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.INVALID_VALUE);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATUS_FOLDED);
      const result = DisplayUtil.isOutsideFolded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_folded_when_product_type_is_invalid_value_and_fold_status_is_half_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.INVALID_VALUE);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATUS_HALF_FOLDED);
      const result = DisplayUtil.isOutsideFolded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_folded_when_product_type_is_invalid_value_and_fold_status_is_unknown', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.INVALID_VALUE);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATUS_UNKNOWN);
      const result = DisplayUtil.isOutsideFolded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_folded_when_product_type_is_straight_and_fold_status_is_status_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.STRAIGHT);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATUS_FOLDED);
      const result = DisplayUtil.isOutsideFolded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_folded_when_product_type_is_straight_and_fold_status_is_half_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.STRAIGHT);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATUS_HALF_FOLDED);
      const result = DisplayUtil.isOutsideFolded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_folded_when_product_type_is_straight_and_fold_status_is_unknown', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.STRAIGHT);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATUS_UNKNOWN);
      const result = DisplayUtil.isOutsideFolded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_folded_when_product_type_is_large_fold_and_fold_status_is_status_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.LARGE_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATUS_FOLDED);
      const result = DisplayUtil.isOutsideFolded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_folded_when_product_type_is_large_fold_and_fold_status_is_half_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.LARGE_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATUS_HALF_FOLDED);
      const result = DisplayUtil.isOutsideFolded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_folded_when_product_type_is_large_fold_and_fold_status_is_unknown', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.LARGE_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATUS_UNKNOWN);
      const result = DisplayUtil.isOutsideFolded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_folded_when_product_type_is_small_fold_and_fold_status_is_status_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.SMALL_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATUS_FOLDED);
      const result = DisplayUtil.isOutsideFolded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_folded_when_product_type_is_small_fold_and_fold_status_is_half_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.SMALL_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATUS_HALF_FOLDED);
      const result = DisplayUtil.isOutsideFolded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_folded_when_product_type_is_small_fold_and_fold_status_is_unknown', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.SMALL_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATUS_UNKNOWN);
      const result = DisplayUtil.isOutsideFolded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_folded_when_product_type_is_external_fold_and_fold_status_is_status_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXTERNAL_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATUS_FOLDED);
      const result = DisplayUtil.isOutsideFolded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_folded_when_product_type_is_external_fold_and_fold_status_is_half_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXTERNAL_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATUS_HALF_FOLDED);
      const result = DisplayUtil.isOutsideFolded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_folded_when_product_type_is_external_fold_and_fold_status_is_unknown', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXTERNAL_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATUS_UNKNOWN);
      const result = DisplayUtil.isOutsideFolded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_folded_when_product_type_is_expand_nex_forms_and_fold_status_is_status_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXPANDING_NEX_FORMS);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATUS_FOLDED);
      const result = DisplayUtil.isOutsideFolded();
      expect(result).assertEqual(true);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_folded_when_product_type_is_expand_nex_forms_and_fold_status_is_half_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXPANDING_NEX_FORMS);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATUS_HALF_FOLDED);
      const result = DisplayUtil.isOutsideFolded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_folded_when_product_type_is_expand_nex_forms_and_fold_status_is_unknown', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXPANDING_NEX_FORMS);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATUS_UNKNOWN);
      const result = DisplayUtil.isOutsideFolded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_folded_when_product_type_is_triple_fold_and_fold_status_is_status_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.TRIPLE_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATUS_FOLDED);
      const result = DisplayUtil.isOutsideFolded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_folded_when_product_type_is_triple_fold_and_fold_status_is_half_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.TRIPLE_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATUS_HALF_FOLDED);
      const result = DisplayUtil.isOutsideFolded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_outside_folded_when_product_type_is_triple_fold_and_fold_status_is_unknown', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.TRIPLE_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATUS_UNKNOWN);
      const result = DisplayUtil.isOutsideFolded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_triple_fold_and_fold_status_is_half_fold_second_half', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.TRIPLE_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_HALF_FOLDED_WITH_SECOND_HALF_FOLDED);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(true);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_triple_fold_and_fold_status_is_expand_half_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.TRIPLE_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_EXPAND_WITH_SECOND_HALF_FOLDED);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(true);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_triple_fold_and_fold_status_is_half_fold_second_expand', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.TRIPLE_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_HALF_FOLDED_WITH_SECOND_EXPAND);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(true);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_triple_fold_and_fold_status_is_second_expand', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.TRIPLE_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_EXPAND_WITH_SECOND_EXPAND);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(true);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_expand_forms_and_fold_status_is_half_fold_second_half', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXPANDING_NEX_FORMS);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_HALF_FOLDED_WITH_SECOND_HALF_FOLDED);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_expand_forms_and_fold_status_is_expand_half_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXPANDING_NEX_FORMS);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_EXPAND_WITH_SECOND_HALF_FOLDED);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_expand_forms_and_fold_status_is_half_fold_second_expand', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXPANDING_NEX_FORMS);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_HALF_FOLDED_WITH_SECOND_EXPAND);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_expand_forms_and_fold_status_is_second_expand', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXPANDING_NEX_FORMS);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_EXPAND_WITH_SECOND_EXPAND);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_external_fold_and_fold_status_is_half_fold_second_half', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXTERNAL_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_HALF_FOLDED_WITH_SECOND_HALF_FOLDED);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_external_fold_and_fold_status_is_expand_half_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXTERNAL_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_EXPAND_WITH_SECOND_HALF_FOLDED);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_external_fold_and_fold_status_is_half_fold_second_expand', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXTERNAL_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_HALF_FOLDED_WITH_SECOND_EXPAND);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_external_fold_and_fold_status_is_second_expand', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.EXTERNAL_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_EXPAND_WITH_SECOND_EXPAND);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_small_fold_and_fold_status_is_half_fold_second_half', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.SMALL_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_HALF_FOLDED_WITH_SECOND_HALF_FOLDED);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_small_fold_and_fold_status_is_expand_half_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.SMALL_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_EXPAND_WITH_SECOND_HALF_FOLDED);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_small_fold_and_fold_status_is_half_fold_second_expand', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.SMALL_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_HALF_FOLDED_WITH_SECOND_EXPAND);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_small_fold_and_fold_status_is_second_expand', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.SMALL_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_EXPAND_WITH_SECOND_EXPAND);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_large_fold_and_fold_status_is_half_fold_second_half', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.LARGE_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_HALF_FOLDED_WITH_SECOND_HALF_FOLDED);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_large_fold_and_fold_status_is_expand_half_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.LARGE_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_EXPAND_WITH_SECOND_HALF_FOLDED);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_large_fold_and_fold_status_is_half_fold_second_expand', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.LARGE_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_HALF_FOLDED_WITH_SECOND_EXPAND);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_large_fold_and_fold_status_is_second_expand', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.LARGE_FOLD);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_EXPAND_WITH_SECOND_EXPAND);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_straight_and_fold_status_is_half_fold_second_half', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.STRAIGHT);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_HALF_FOLDED_WITH_SECOND_HALF_FOLDED);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_straight_and_fold_status_is_expand_half_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.STRAIGHT);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_EXPAND_WITH_SECOND_HALF_FOLDED);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_straight_and_fold_status_is_half_fold_second_expand', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.STRAIGHT);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_HALF_FOLDED_WITH_SECOND_EXPAND);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_straight_and_fold_status_is_second_expand', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.STRAIGHT);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_EXPAND_WITH_SECOND_EXPAND);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_invalid_and_fold_status_is_half_fold_second_half', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.INVALID_VALUE);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_HALF_FOLDED_WITH_SECOND_HALF_FOLDED);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_invalid_and_fold_status_is_expand_half_fold', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.INVALID_VALUE);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_EXPAND_WITH_SECOND_HALF_FOLDED);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_invalid_fold_and_fold_status_is_half_fold_second_expand', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.INVALID_VALUE);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_HALF_FOLDED_WITH_SECOND_EXPAND);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });

    it('is_triple_expanded_when_product_type_is_invalid_and_fold_status_is_second_expand', 0, () => {
      let mocker: MockKit = new MockKit();
      const mockFunc = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldProductType);
      const mockStatus = mocker.mockFunc(DisplayUtil, DisplayUtil.getFoldStatus);
      when(mockFunc)().afterReturn(FoldPhoneTypeValue.INVALID_VALUE);
      when(mockStatus)().afterReturn(DisplayUtil.FOLD_STATE_EXPAND_WITH_SECOND_EXPAND);
      const result = DisplayUtil.isTripleFoldExpanded();
      expect(result).assertEqual(false);
      mocker.clear(DisplayUtil);
    });
  });
}