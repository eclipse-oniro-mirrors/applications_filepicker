/*
 * Copyright (c) 2021-2023 Huawei Device Co., Ltd.
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

import util from '@ohos.util'

/**
 * 字符串工具类
 */
namespace StringUtil {

/**
 * 字符串是否为空
 * @param str 字符串
 * @return 是否为空
 */
    export function isEmpty(str: string): boolean {
        return!str || str.length === 0
    }

    /**
     * 将字符串转换成Uint8Array类型
     * @param str 字符串
     * @return 无符号整型数组
     */
    export function convert2Uint8Array(str: string): Uint8Array {
        if (isEmpty(str)) {
            return new Uint8Array()
        }
        return new util.TextEncoder().encode(str)
    }

    /**
     * 将字符串做base64编码
     * @param str 字符串
     * @return Base64字符串
     */
    export function convert2Base64(str: string): string {
        if (isEmpty(str)) {
            return ''
        }
        const array = convert2Uint8Array(str)
        return new util.Base64().encodeToStringSync(array)
    }

    /**
     * 字符串头部补全
     * @param num 待补全字符串
     * @param maxLen 补全后字符串的最大长度
     * @param placeholder 占位符
     * @return 不全后的字符串，如：1=>01
     */
    export function padStart(num: number | string, maxLen = 2, placeholder = '0') {
        return num.toString().padStart(maxLen, placeholder)
    }
}

export default StringUtil
