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
import { describe, expect, it } from '@ohos/hypium';
import { StringUtil } from '@ohos/common';
import { maskString } from '@ohos/common/indexDT';
import { util } from '@kit.ArkTS';

export default function StringUtilTest() {
  describe("StringUtilTest", () => {
    it("convert2Uint8Array_EmptyInput", 0, (done: Function) => {
      let result1: Uint8Array = StringUtil.convert2Uint8Array('');
      expect(result1).assertInstanceOf('Uint8Array');
      done();
    });

    it("convert2Uint8Array_NonEmptyInput", 0, (done: Function) => {
      let result2: Uint8Array = StringUtil.convert2Uint8Array('test');
      expect(result2).assertInstanceOf('Uint8Array');
      done();
    });

    it('StringUtilTest_stringToUint8Array', 0, (done: Function) => {
      let str: string = '';
      let result: Uint8Array = StringUtil.stringToUint8Array(str);
      expect(result).assertUndefined();
      str = 'test';
      StringUtil.stringToUint8Array(str);
      done();
    });

    it('convert2Base64_emptyStr', 0, (done: Function) => {
      let str: string = '';
      let result = StringUtil.convert2Base64(str);
      expect(result).assertEqual('');
      done();
    });

    it('convert2Base64_notEmptyStr', 0, (done: Function) => {
      let str: string = 'test';
      let trueResult = 'dGVzdA==';
      let result = StringUtil.convert2Base64(str);
      expect(result).assertEqual(trueResult);
      done();
    });

    it('strSizeUTF8_undefinedStr', 0, (done: Function) => {
      let str: string | undefined = undefined;
      let result = StringUtil.strSizeUTF8(str!!);
      expect(result).assertEqual(0);
      done();
    });

    it('stringToArray_notEmptyString', 0, (done: Function) => {
      let str: string = 'test';
      let trueResult = '{"0":116,"1":101,"2":115,"3":116}';
      let result = StringUtil.stringToArray(str);
      expect(JSON.stringify(result)).assertEqual(trueResult);
      done();
    });

    it('hexStringToUint8Array_notEvenHexString', 0, (done: Function) => {
      let str: string = 'test1';
      let result = StringUtil.hexStringToUint8Array(str);
      expect(result).assertUndefined();
      done();
    });

    it("uint8ArrayToString_ReturnsEmptyStringWhenInputIsNull", 0, (done: Function) => {
      let param = null;
      let result: string = StringUtil.uint8ArrayToString(param);
      expect(result).assertEqual('');
      done();
    });

    it("uint8ArrayToString_ConvertsEncodedStringToCorrectText", 0, (done: Function) => {
      let str: string = 'test';
      let param1 = new util.TextEncoder().encodeInto(str);
      let result2: string = StringUtil.uint8ArrayToString(param1);
      expect(result2).assertEqual(str);
      done();
    });

    it("maskString_HandlesEmptyString", 0, (done: Function) => {
      let param: string = '';
      let result: string = maskString(param);
      expect(result).assertEqual('');
      done();
    });

    it("maskString_MasksSingleCharacter", 0, (done: Function) => {
      let param = '111';
      let result2: string = maskString(param);
      expect(result2).assertEqual(param.substring(0, 1) + '***' + param.substring(param.length - 1));
      done();
    });

    it("maskString_MasksShortNumber", 0, (done: Function) => {
      let param = '1111111';
      let result3: string = maskString(param);
      expect(result3).assertEqual(param.substring(0, 3) + '***' + param.substring(param.length - 2));
      done();
    });

    it("maskString_MasksLongNumber", 0, (done: Function) => {
      let param = '11111111111111';
      let result4: string = maskString(param);
      expect(result4).assertEqual(param.substring(0, 3) + '***' + param.substring(param.length - 3));
      done();
    });

    it("getOneCharByteLengthWhenCharIsEmpty", 0, () => {
      let char = '';
      let result: number = StringUtil.getOneCharByteLength(char);
      expect(result).assertEqual(0);
    });

    it("getOneCharByteLengthWhenCharLengthIsLagerThanOne", 0, () => {
      let char = '00';
      let result: number = StringUtil.getOneCharByteLength(char);
      expect(result).assertEqual(2);
    });

    it("getOneCharByteLengthWhenCharIsLessThan0x007f", 0, () => {
      let char = '0';
      let result: number = StringUtil.getOneCharByteLength(char);
      expect(result).assertEqual(1);
    });

    it("getOneCharByteLengthWhenCharIsLessThan0x07ff", 0, () => {
      let char = 'é';
      let result: number = StringUtil.getOneCharByteLength(char);
      expect(result).assertEqual(2);
    });

    it("getOneCharByteLengthWhenCharIsLessThan0xffff", 0, () => {
      let char = '你';
      let result: number = StringUtil.getOneCharByteLength(char);
      expect(result).assertEqual(3);
    });
  })
}