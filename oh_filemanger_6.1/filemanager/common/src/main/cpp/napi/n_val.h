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

#ifndef FILE_MANAGER_COMMON_N_VAL_H
#define FILE_MANAGER_COMMON_N_VAL_H

#include <string_view>

#include "sys/types.h"
#include <node_api.h>
#include "napi/native_api.h"
#include <vector>

namespace OHOS {
namespace FileManagerCommon {

class NVal final {
public:
    NVal() = default;
    NVal(napi_env nEnv, napi_value nVal);
    NVal(const NVal &) = default;
    NVal &operator=(const NVal &) = default;
    virtual ~NVal() = default;

    // NOTE! env_ and val_ is LIKELY to be null
    napi_env env_ = nullptr;
    napi_value val_ = nullptr;

    explicit operator bool() const;
    bool TypeIs(napi_valuetype expType) const;
    bool TypeIsError(bool checkErrno = false) const;
    /* SHOULD ONLY BE USED FOR EXPECTED TYPE */
    std::tuple<bool, std::unique_ptr<char[]>, size_t> ToUTF8String() const;
    std::string GetStringParam() const;

    static NVal CreateBool(napi_env env, bool val);
    static NVal CreateUTF8String(napi_env env, std::string str);
    static NVal CreateInt32(napi_env env, int32_t val);
    static NVal CreateUndefined(napi_env env);
    static NVal CreateArrayString(napi_env env, std::vector<std::string> strs);
    /* SHOULD ONLY BE USED FOR OBJECT */
    bool HasProp(std::string propName) const;

    bool AddProp(std::string propName, napi_value nVal) const;
};

}  // namespace FileManagerCommon
}  // namespace OHOS
#endif  // FILE_MANAGER_COMMON_N_VAL_H