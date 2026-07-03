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
import deviceInfo from '@ohos.deviceInfo';

/**
 * 获取当前设备相关信息工具类
 */
export class DeviceInfoUtil {
  /**
   * 设备类型：手机
   */
  public static readonly DEVICE_TYPE_PHONE: string = 'phone';

  /**
   * 设备类型：平板
   */
  public static readonly DEVICE_TYPE_TABLET: string = 'tablet';

  /**
   * 设备类型：PC
   */
  public static readonly DEVICE_TYPE_PC: string = 'pc';

  /**
   * 设备类型：新PC ROM会返回2in1
   */
  public static readonly DEVICE_TYPE_PC_NEW: string = '2in1';

  /**
   * 设备类型：模拟器
   */
  private static readonly DEVICE_TYPE_EMULATOR: string = 'emulator';

  /**
   * 当前设备是否为手机
   */
  public static isPhone(): boolean {
    return this.getDeviceType() === this.DEVICE_TYPE_PHONE;
  }

  /**
   * 当前设备是否为平板
   */
  public static isPad(): boolean {
    return this.getDeviceType() === this.DEVICE_TYPE_TABLET;
  }

  /**
   * 当前设备是否为PC
   */
  public static isPC(): boolean {
    return this.getDeviceType() === this.DEVICE_TYPE_PC || this.getDeviceType() === this.DEVICE_TYPE_PC_NEW;
  }

  /**
   * 当前设备是否为模拟器
   */
  public static isEmulator(): boolean {
    return this.getProductModel() === this.DEVICE_TYPE_EMULATOR;
  }

  /**
   * 获取设备ID
   * @return string
   */
  public static getDeviceId(): string {
    return deviceInfo.udid;
  }

  /**
   * 获取设备类型
   * @return string
   */
  public static getDeviceType(): string {
    return deviceInfo.deviceType;
  }

  /**
   * 获取设备品牌
   * @return string
   */
  public static getDeviceBrand(): string {
    return deviceInfo.brand;
  }

  /**
   * 获取设备制造商
   * @return string
   */
  public static getDeviceManufacturer(): string {
    return deviceInfo.manufacture;
  }

  /**
   * 获取当前设备的版本号，如 NOH-AN00 4.0.0.41(C00E30R1P4DEVlog)
   *
   * @return displayVersion
   */
  public static getRomVersion(): string {
    return deviceInfo.displayVersion;
  }

  /**
   * 获取设备productModel, 如 NOH-AN00
   */
  public static getProductModel(): string {
    return deviceInfo.productModel;
  }
}