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

import { HashUtil, StringUtil } from "@ohos/common";
import { ArgumentMatchers, describe, expect, it, MockKit, when } from "@ohos/hypium";
import { TestUtil } from "../../utils/TestUtil";

const SHA256_TEST_STRING = 'test';
const SHA256_TEST_ENCRYPT_STRING = '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08';
const SHA256_128_STRING = '测试';
const SHA256_128_ENCRYPT_STRING = '6aa8f49cc992dfd75a114269ed26de0ad6d4e7d7a70d9c8afb3d7a57a88a73ed';
const SHA256_2048_STRING = '±';
const SHA256_2048_ENCRYPT_STRING = '8d3591e55fa8745793d9519955740ddad45bb94dfc191b36c744139c6184c442';


export default function HashUtilTest() {
  describe('HashUtilTest', () => {
    it('getSHA256_testString', 0, async (done: Function) => {
      const result: string = await HashUtil.getSHA256(SHA256_TEST_STRING);
      expect(result).assertEqual(SHA256_TEST_ENCRYPT_STRING);

      done();
    });

    it('getSHA256_undefined', 0, async (done: Function) => {
      const result1: string = await HashUtil.getSHA256(undefined);
      expect(result1).assertEqual('');

      done();
    });

    it('getSHA256_with_hello_world', 0, async () => {
      let input: string = "Hello, World!";
      let expectedSHA256: string = "dffd6021bb2bd5b0af676290809ec3a53191dd81c7f70a4b28688a362182986f";
      let result: string = await HashUtil.getSHA256(input);
      expect(result).assertEqual(expectedSHA256);
    });

    it('getSHA256_with_empty', 0, async () => {
      let input: string = "";
      let expectedSHA256: string = "";
      let result: string = await HashUtil.getSHA256(input);
      expect(result).assertEqual(expectedSHA256);
    });

    it('getSHA256_with_chinese', 0, async () => {
      let input: string = "你好, 世界!";
      let expectedSHA256: string = "12477654131605bfc19ba5a3862ac54f18f9140509fcb3c1faad687c75ff64d1";
      let result: string = await HashUtil.getSHA256(input);
      expect(result).assertEqual(expectedSHA256);
    });

    it('getSHA256_with_error', 0, async () => {
      let input: string = "Hello, World!";
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(StringUtil, StringUtil.stringToHexString);
      when(mockfunc)(ArgumentMatchers.any).afterThrow("AegSha256 error");
      let result: string = await HashUtil.getSHA256(input);
      mocker.ignoreMock(StringUtil, StringUtil.stringToHexString);
      expect(result).assertEqual('');
    });

    it('addSecurity', 0, () => {
      let value1 = 10;
      let value2 = 20;
      let result = 30;
      let func = TestUtil.getPrivateFunction(HashUtil, 'addSecurity') as Function;
      expect(func(value1, value2)).assertEqual(result);
    });

    it('sigAlg', 0, () => {
      let value1 = 10;
      let value2 = 20;
      let result = 40960;
      let func = TestUtil.getPrivateFunction(HashUtil, 'sigAlg') as Function;
      expect(func(value1, value2)).assertEqual(result);
    });

    it('rightMoveAlg', 0, () => {
      let value1 = 10;
      let value2 = 20;
      let result = 0;
      let func = TestUtil.getPrivateFunction(HashUtil, 'rightMoveAlg') as Function;
      expect(func(value1, value2)).assertEqual(result);
    });

    it('chAlg', 0, () => {
      let value1 = 10;
      let value2 = 20;
      let result = 0;
      let func = TestUtil.getPrivateFunction(HashUtil, 'chAlg') as Function;
      expect(func(value1, value2)).assertEqual(result);
    });

    it('majAlg', 0, () => {
      let value1 = 10;
      let value2 = 20;
      let result = 0;
      let func = TestUtil.getPrivateFunction(HashUtil, 'majAlg') as Function;
      expect(func(value1, value2)).assertEqual(result);
    });

    it('sigmaAlg256', 0, () => {
      let value = 10;
      let result = -2142230526;
      let func = TestUtil.getPrivateFunction(HashUtil, 'sigmaAlg256') as Function;
      expect(func(value)).assertEqual(result);
    });

    it('SigmaAlg1256', 0, () => {
      let value = 10;
      let result = 692061440;
      let func = TestUtil.getPrivateFunction(HashUtil, 'SigmaAlg1256') as Function;
      expect(func(value)).assertEqual(result);
    });

    it('gammaAlg256', 0, () => {
      let value = 10;
      let result = 335708161;
      let func = TestUtil.getPrivateFunction(HashUtil, 'gammaAlg256') as Function;
      expect(func(value)).assertEqual(result);
    });

    it('gammaAlg1256', 0, () => {
      let value = 10;
      let result = 278528;
      let func = TestUtil.getPrivateFunction(HashUtil, 'gammaAlg1256') as Function;
      expect(func(value)).assertEqual(result);
    });

    it('coreAlgSHA256', 0, () => {
      let value1 = [10];
      let value2 = [20];
      let result = '-1678165062,-1637980152,124057746,1545825823,-1813843676,-424511629,1243983038,813741337';
      let func = TestUtil.getPrivateFunction(HashUtil, 'coreAlgSHA256') as Function;
      expect(func(value1, value2).join()).assertEqual(result);
    });

    it('assignHashArray', 0, () => {
      let value1 = 10;
      let value2 = 20;
      let value3 = 30;
      let value4 = 40;
      let value5 = 50;
      let value6 = 60;
      let value7 = 70;
      let value8 = 80;
      let hashArray = [1, 2, 3, 4, 5, 6, 7, 8]
      let func = TestUtil.getPrivateFunction(HashUtil, 'assignHashArray') as Function;
      func(hashArray, value1, value2, value3, value4, value5, value6, value7, value8)
      expect(hashArray.join()).assertEqual('11,22,33,44,55,66,77,88');
    });

    it('getKeyArray', 0, () => {
      let func = TestUtil.getPrivateFunction(HashUtil, 'getKeyArray') as Function;
      expect(func().length).assertEqual(64);
    });

    it('stringToArray', 0, () => {
      let value = 'abcedef';
      let result = '1633837925,1684366848';
      let func = TestUtil.getPrivateFunction(HashUtil, 'stringToArray') as Function;
      expect(func(value).join()).assertEqual(result);
    });

    it('arrayToString', 0, () => {
      let value = [10];
      let func = TestUtil.getPrivateFunction(HashUtil, 'arrayToString') as Function;
      expect(func(value)).assertEqual('0000000a');
    });
  });
}