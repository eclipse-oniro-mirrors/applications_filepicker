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

import connection from '@ohos.net.connection';
import { HiLog } from '../dfx/HiLog';

const TAG = 'NetworkUtil';

/**
 * 网络相关工具
 */
export class NetworkUtil {
  /**
   * 检查网路连接情况
   * @return 网络是否连接
   */
  public static async checkNetworkConnect(): Promise<boolean> {
    let isConnect = false;
    try {
      isConnect = await connection.hasDefaultNet();
    } catch (error) {
      HiLog.error(TAG, 'checkNetworkConnect fail, error:' + JSON.stringify(error));
    }
    HiLog.info(TAG, 'checkNetworkConnect, hasDefaultNet:' + isConnect);
    return isConnect;
  }

  /**
   * 检查网络连接情况，包括是否是移动网络
   */
  public static async checkNetworkConnectAndCellular(): Promise<void> {
    let isNetwork: boolean = false;
    let isCellular: boolean = false;
    try {
      isNetwork = await connection.hasDefaultNet();
      if (isNetwork) {
        let netCap: connection.NetCapabilities = await connection.getNetCapabilities(connection.getDefaultNetSync());
        if (netCap.bearerTypes.length > 0) {
          isCellular = (netCap.bearerTypes[0] === connection.NetBearType.BEARER_CELLULAR);
        }
      }
    } catch (error) {
      HiLog.error(TAG, 'checkNetworkConnect fail, error:' + JSON.stringify(error));
    }
    AppStorage.setOrCreate<boolean>('isCellular', isCellular);
    AppStorage.setOrCreate<boolean>('isNetwork', isNetwork);
    HiLog.info(TAG, `checkNetworkConnect, hasDefaultNet: ${isNetwork}, isCellular: ${isCellular}`);
  }

  /**
   * 检查网络是不是通的，是否可以发起请求
   *
   * @returns boolean
   */
  public static checkHasNet(): boolean {
    try {
      let netHandle = connection.getDefaultNetSync();
      if (!netHandle || netHandle.netId === 0) {
        return false;
      }
      let netCapability = connection.getNetCapabilitiesSync(netHandle);
      let cap = netCapability.networkCap || [];
      // connection.NetCap.NET_CAPABILITY_VALIDATED，该值代表网络是通的，能够发起HTTP和HTTPS的请求。
      if (cap.includes(connection.NetCap.NET_CAPABILITY_VALIDATED)) {
        return true;
      }
      return false;
    } catch (error) {
      HiLog.error(TAG, `checkHasNet error : ${JSON.stringify(error)}`);
    }
    return false;
  }
}