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
import { HiLog } from '../dfx/HiLog';
import { FoldPhoneTypeValue } from '../const/Constant';
import { systemParameterEnhance } from '@kit.BasicServicesKit';

const TAG = 'DisplayUtil';

export class DisplayUtil {
  // 折叠屏半折叠
  public static readonly FOLD_STATUS_HALF_FOLDED: number = 3;

  // 折叠屏折叠
  public static readonly FOLD_STATUS_FOLDED: number = 2;

  // 折叠屏展开
  public static readonly FOLD_STATUS_EXPANDED: number = 1;

  // 未知状态
  public static readonly FOLD_STATUS_UNKNOWN: number = 0;

  // G态
  public static readonly FOLD_STATE_EXPAND_WITH_SECOND_EXPAND: number = 11;

  // 半折和展开（G态）
  public static readonly FOLD_STATE_HALF_FOLDED_WITH_SECOND_EXPAND: number = 13;

  // 展开和半折(G态)
  public static readonly FOLD_STATE_EXPAND_WITH_SECOND_HALF_FOLDED: number = 21;

  // 半折和半折（G态）
  public static readonly FOLD_STATE_HALF_FOLDED_WITH_SECOND_HALF_FOLDED: number = 23;

  // 折叠屏查询
  public static readonly FOLD_PRODUCT_TYPE = 'const.window.foldscreen.type';

  // 折叠屏查询兜底返回参数
  public static readonly DEFAULTS_FOLD_TYPE = '-1';

  // 折叠屏展开时，搜索框会拉起重复的底部工具栏，采用该参数控制
  public static isExistDuplicateBottomBar: boolean = false;

  public static readonly CURVE_MAX_SPEED: number = 1600;

  public static readonly TEN_MM_INCH: number = 10 / 25.4;

  public static getOrientationStatus(): number {
    let orientation: number = display.Orientation.PORTRAIT;
    let displayClass: display.Display | undefined = DisplayUtil.getDefaultDisplaySync();
    if (displayClass) {
      orientation = displayClass.orientation;
    } else {
      HiLog.error(TAG, `getOrientationStatus error.`);
    }
    return orientation;
  }

  // 获取热区数据
  public static getHotAreaLength(): number | undefined {
    const displayClass: display.Display | undefined = DisplayUtil.getDefaultDisplaySync();
    let hotAreaLen: number | undefined = undefined;
    if (displayClass) {
      const densityDPI: number = displayClass.densityDPI;
      const densityPixels: number = displayClass.densityPixels;
      hotAreaLen = Math.round(densityDPI * this.TEN_MM_INCH / densityPixels);
    } else {
      HiLog.error(TAG, `getHotAreaLength error.`);
    }
    return hotAreaLen;
  }

  // 获取最大滚动速度
  public static getAutoScrollMaxSpeed(): number | undefined {
    const densityPixels: number = DisplayUtil.getDefaultDisplaySync()?.densityPixels;
    let autoScrollMaxSpeed: number | undefined = undefined;
    if (densityPixels) {
      autoScrollMaxSpeed = Math.round(this.CURVE_MAX_SPEED / densityPixels);
    } else {
      HiLog.error(TAG, `getAutoScrollMaxSpeed error.`);
    }
    return autoScrollMaxSpeed;
  }

  // 获取DefaultDisplay
  public static getDefaultDisplaySync(): display.Display | undefined {
    try {
      return display.getDefaultDisplaySync();
    } catch (e) {
      HiLog.error(TAG, `getDefaultDisplaySync error, ${JSON.stringify(e)}`);
    }
    return undefined;
  }

  public static isFoldable(): boolean {
    let ret: boolean = false;
    try {
      ret = display.isFoldable();
    } catch (e) {
      HiLog.error(TAG, 'isFoldable error: ' + JSON.stringify(e));
    }
    if (ret) {
      return true;
    }
    return false;
  }

  public static getFoldStatus(): number {
    let foldStatus: number = 0;
    try {
      foldStatus = display.getFoldStatus();
    } catch (e) {
      HiLog.error(TAG, 'getFoldStatus error: ' + JSON.stringify(e));
    }
    HiLog.info(TAG, 'getFoldStatus: ' + foldStatus);
    return foldStatus;
  }

  public static getFoldProductType(): FoldPhoneTypeValue {
    try {
      let productValue: string = systemParameterEnhance.getSync(DisplayUtil.FOLD_PRODUCT_TYPE,
        DisplayUtil.DEFAULTS_FOLD_TYPE);
      HiLog.info(TAG, 'getFoldProductType status:' + productValue);
      const result: string[] = productValue?.split(',');
      if (result.length > 0) {
        let productType = Number.parseInt(result[0]);
        return productType;
      }
    } catch (e) {
      HiLog.error(TAG, 'Get fold product type value failed:', JSON.stringify(e));
    }
    return FoldPhoneTypeValue.INVALID_VALUE;
  }

  public static isBigFold(): boolean {
    let productType = DisplayUtil.getFoldProductType();
    return productType === FoldPhoneTypeValue.LARGE_FOLD || productType === FoldPhoneTypeValue.EXTERNAL_FOLD ||
      productType === FoldPhoneTypeValue.TRIPLE_FOLD;
  }

  public static isXtDevice(): boolean {
    let productType = DisplayUtil.getFoldProductType();
    return productType === FoldPhoneTypeValue.TRIPLE_FOLD;
  }

  public static isBigFoldDeviceExpanded(isBigFold: boolean, foldStatus: number): boolean {
    return isBigFold && (foldStatus === this.FOLD_STATUS_EXPANDED || foldStatus === this.FOLD_STATUS_HALF_FOLDED ||
      foldStatus === this.FOLD_STATE_EXPAND_WITH_SECOND_EXPAND ||
        foldStatus === this.FOLD_STATE_HALF_FOLDED_WITH_SECOND_EXPAND);
  }

  // 判断是否为外屏设备的展开态
  public static isOutsideExpanded(foldStatus: number): boolean {
    let productType = DisplayUtil.getFoldProductType();
    return productType === FoldPhoneTypeValue.EXPANDING_NEX_FORMS && (foldStatus === this.FOLD_STATUS_EXPANDED ||
      foldStatus === this.FOLD_STATUS_HALF_FOLDED);
  }

  // 判断是否为外屏设备
  public static isOutsideScreenDevice(): boolean {
    let productType = DisplayUtil.getFoldProductType();
    return productType === FoldPhoneTypeValue.EXPANDING_NEX_FORMS;
  }

  // 判断是否为外屏设备的折叠态
  public static isOutsideFolded(): boolean {
    const productType = DisplayUtil.getFoldProductType();
    const foldStatus = DisplayUtil.getFoldStatus();
    return productType === FoldPhoneTypeValue.EXPANDING_NEX_FORMS && foldStatus === DisplayUtil.FOLD_STATUS_FOLDED;
  }
  
    /**
   * 是否三折叠三屏显示状态
   */
  public static isTripleFoldExpanded(): boolean {
    const productType = DisplayUtil.getFoldProductType();
    const foldStatus = DisplayUtil.getFoldStatus();
    return productType === FoldPhoneTypeValue.TRIPLE_FOLD &&
      (foldStatus === this.FOLD_STATE_EXPAND_WITH_SECOND_EXPAND ||
      foldStatus === this.FOLD_STATE_HALF_FOLDED_WITH_SECOND_EXPAND ||
      foldStatus === this.FOLD_STATE_EXPAND_WITH_SECOND_HALF_FOLDED ||
      foldStatus === this.FOLD_STATE_HALF_FOLDED_WITH_SECOND_HALF_FOLDED);
  }
}