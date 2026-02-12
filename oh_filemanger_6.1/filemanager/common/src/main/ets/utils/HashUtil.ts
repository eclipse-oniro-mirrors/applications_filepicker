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

// import { AegSha256 } from '@hms-security/agoh-crypto';
import { HiLog } from '../dfx/HiLog';
import { StringUtil } from './StringUtil';

const TAG = 'HashUtil';

const CHAR_LENGTH = 8;
const HALF_INT_LENGTH = 16;
const INT_LENGTH = 32;
/**
 * hash运算相关工具类
 */
export class HashUtil {

  /**
   * 获取sha256
   * @param value 普通string
   * @returns
   */
  public static async getSHA256(value: string): Promise<string> {
    let result = '';
    try {
      // result = await AegSha256.ohAegSha256Hex(StringUtil.stringToHexString(value));
    } catch (error) {
      HiLog.error(TAG, `getSHA256 fail, error: ${JSON.stringify(error)}`);
    }
    return result;
  }

  private static addSecurity(value1: number, value2: number): number {
    const lsw = (value1 & 0xFFFF) + (value2 & 0xFFFF);
    const msw = (value1 >> HALF_INT_LENGTH) + (value2 >> HALF_INT_LENGTH) + (lsw >> HALF_INT_LENGTH);
    return (msw << HALF_INT_LENGTH) | (lsw & 0xFFFF);
  }

  private static sigAlg(src: number, step: number): number {
    return (src >>> step) | (src << (INT_LENGTH - step));
  }

  private static rightMoveAlg(src: number, step: number): number {
    return (src >>> step);
  }

  private static chAlg(value1: number, value2: number, value3: number): number {
    return ((value1 & value2) ^ ((~value1) & value3));
  }

  private static majAlg(value1: number, value2: number, value3: number): number {
    return ((value1 & value2) ^ (value1 & value3) ^ (value2 & value3));
  }

  private static sigmaAlg256(value: number): number {
    return (HashUtil.sigAlg(value, 2) ^ HashUtil.sigAlg(value, 13) ^ HashUtil.sigAlg(value, 22));
  }

  private static SigmaAlg1256(value: number): number {
    return (HashUtil.sigAlg(value, 6) ^ HashUtil.sigAlg(value, 11) ^ HashUtil.sigAlg(value, 25));
  }

  private static gammaAlg256(value: number): number {
    return (HashUtil.sigAlg(value, 7) ^ HashUtil.sigAlg(value, 18) ^ HashUtil.rightMoveAlg(value, 3));
  }

  private static gammaAlg1256(value: number): number {
    return (HashUtil.sigAlg(value, 17) ^ HashUtil.sigAlg(value, 19) ^ HashUtil.rightMoveAlg(value, 10));
  }

  private static coreAlgSHA256(m: number[], l: number): number[] {
    const key: number[] = HashUtil.getKeyArray();
    const hashArray = [0x6A09E667, 0xBB67AE85, 0x3C6EF372, 0xA54FF53A, 0x510E527F, 0x9B05688C, 0x1F83D9AB, 0x5BE0CD19];
    const weight = new Array(64);
    let value1: number;
    let value2: number;
    let value3: number;
    let value4: number;
    let value5: number;
    let value6: number;
    let value7: number;
    let value8: number;
    let index: number;
    let index2: number;
    let sum1: number;
    let sum2: number;
    m[l >> 5] |= 0x80 << (24 - l % 32);
    m[((l + 64 >> 9) << 4) + 15] = l;
    for (index = 0; index < m.length; index += 16) {
      value1 = hashArray[0];
      value2 = hashArray[1];
      value3 = hashArray[2];
      value4 = hashArray[3];
      value5 = hashArray[4];
      value6 = hashArray[5];
      value7 = hashArray[6];
      value8 = hashArray[7];
      for (index2 = 0; index2 < 64; index2++) {
        if (index2 < 16) {
          weight[index2] = m[index2 + index];
        } else {
          weight[index2] = HashUtil.addSecurity(HashUtil.addSecurity(HashUtil.addSecurity(HashUtil.gammaAlg1256(
            weight[index2 - 2]), weight[index2 - 7]), HashUtil.gammaAlg256(weight[index2 - 15])), weight[index2 - 16]);
        }
        sum1 = HashUtil.addSecurity(HashUtil.addSecurity(HashUtil.addSecurity(HashUtil.addSecurity(value8,
          HashUtil.SigmaAlg1256(value5)), HashUtil.chAlg(value5, value6, value7)), key[index2]), weight[index2]);
        sum2 = HashUtil.addSecurity(HashUtil.sigmaAlg256(value1), HashUtil.majAlg(value1, value2, value3));
        value8 = value7;
        value7 = value6;
        value6 = value5;
        value5 = HashUtil.addSecurity(value4, sum1);
        value4 = value3;
        value3 = value2;
        value2 = value1;
        value1 = HashUtil.addSecurity(sum1, sum2);
      }
      HashUtil.assignHashArray(hashArray, value1, value2, value3, value4, value5, value6, value7, value8);
    }
    return hashArray;
  }

  private static assignHashArray(hashArray: number[], value1: number, value2: number, value3: number, value4: number,
                                 value5: number, value6: number, value7: number, value8: number): void {
    hashArray[0] = HashUtil.addSecurity(value1, hashArray[0]);
    hashArray[1] = HashUtil.addSecurity(value2, hashArray[1]);
    hashArray[2] = HashUtil.addSecurity(value3, hashArray[2]);
    hashArray[3] = HashUtil.addSecurity(value4, hashArray[3]);
    hashArray[4] = HashUtil.addSecurity(value5, hashArray[4]);
    hashArray[5] = HashUtil.addSecurity(value6, hashArray[5]);
    hashArray[6] = HashUtil.addSecurity(value7, hashArray[6]);
    hashArray[7] = HashUtil.addSecurity(value8, hashArray[7]);
  }

  private static getKeyArray(): number[] {
    return [0x428A2F98, 0x71374491, 0xB5C0FBCF, 0xE9B5DBA5, 0x3956C25B, 0x59F111F1, 0x923F82A4, 0xAB1C5ED5,
      0xD807AA98, 0x12835B01, 0x243185BE, 0x550C7DC3, 0x72BE5D74, 0x80DEB1FE, 0x9BDC06A7, 0xC19BF174, 0xE49B69C1,
      0xEFBE4786, 0xFC19DC6, 0x240CA1CC, 0x2DE92C6F, 0x4A7484AA, 0x5CB0A9DC, 0x76F988DA, 0x983E5152, 0xA831C66D,
      0xB00327C8, 0xBF597FC7, 0xC6E00BF3, 0xD5A79147, 0x6CA6351, 0x14292967, 0x27B70A85, 0x2E1B2138, 0x4D2C6DFC,
      0x53380D13, 0x650A7354, 0x766A0ABB, 0x81C2C92E, 0x92722C85, 0xA2BFE8A1, 0xA81A664B, 0xC24B8B70, 0xC76C51A3,
      0xD192E819, 0xD6990624, 0xF40E3585, 0x106AA070, 0x19A4C116, 0x1E376C08, 0x2748774C, 0x34B0BCB5, 0x391C0CB3,
      0x4ED8AA4A, 0x5B9CCA4F, 0x682E6FF3, 0x748F82EE, 0x78A5636F, 0x84C87814, 0x8CC70208, 0x90BEFFFA, 0xA4506CEB,
      0xBEF9A3F7, 0xC67178F2];
  }

  private static stringToArray(str: string): number[] {
    const chrSize = 8;
    const result: number[] = [];
    const mask = (1 << chrSize) - 1;
    for (let i = 0; i < str.length * chrSize; i += chrSize) {
      result[i >> 5] |= (str.charCodeAt(i / chrSize) & mask) << (24 - i % 32);
    }
    return result;
  }

  private static arrayToString(srcArray: number[]): string {
    const hexDig = '0123456789abcdef';
    let result = '';
    for (let i = 0; i < srcArray.length * 4; i++) {
      result += hexDig.charAt((srcArray[i >> 2] >> ((3 - i % 4) * 8 + 4)) & 0xF) +
      hexDig.charAt((srcArray[i >> 2] >> ((3 - i % 4) * 8)) & 0xF);
    }
    return result;
  }

}