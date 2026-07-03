/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "napi_util.h"
#include "../utils/log.h"

#undef LOG_TAG
#define LOG_TAG "NapiUtilCPP"  // 全局tag宏，标识模块日志tag

// Js String转C++ string：str->转换结果
bool NapiUtil::parseJsStringProperty(napi_env env, napi_value arg, std::string &str)
{
    size_t bufferLength = 0;
    napi_status status = napi_get_value_string_utf8(env, arg, nullptr, 0, &bufferLength);
    if (status == napi_ok && bufferLength == 0) {
        str = "";
        return true;
    }
    if (!(status == napi_ok && bufferLength > 0)) {
        OH_LOG_ERROR(LOG_APP, "parseJsStringProperty get length failed");
        return false;
    }

    std::unique_ptr<char[]> buffer = std::make_unique<char[]>((bufferLength + 1) * sizeof(char));
    status = napi_get_value_string_utf8(env, arg, buffer.get(), bufferLength + 1, &bufferLength);
    if (status != napi_ok) {
        OH_LOG_ERROR(LOG_APP, "parseJsStringProperty failed");
        return false;
    }
    std::string strTmp(buffer.get());
    str = strTmp;
    return true;
}