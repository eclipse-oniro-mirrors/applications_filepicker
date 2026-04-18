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

#include "n_val.h"
#include <string>

namespace OHOS {
namespace FileManagerCommon {

NVal::NVal(napi_env nEnv, napi_value nVal = nullptr) : env_(nEnv), val_(nVal)
{}

NVal::operator bool() const
{
    return env_ && val_;
}

bool NVal::TypeIs(napi_valuetype expType) const
{
    if (!*this) {
        return false;
    }

    napi_valuetype valueType;
    napi_typeof(env_, val_, &valueType);
    if (expType != valueType) {
        return false;
    }

    return true;
}

bool NVal::TypeIsError(bool /* checkErrno*/) const
{
    if (!*this) {
        return false;
    }

    bool res = false;
    napi_is_error(env_, val_, &res);

    return res;
}

std::tuple<bool, std::unique_ptr<char[]>, size_t> NVal::ToUTF8String() const
{
    size_t strLen = 0;
    napi_status status = napi_get_value_string_utf8(env_, val_, nullptr, -1, &strLen);
    if (status != napi_ok) {
        return {false, nullptr, 0};
    }

    size_t bufLen = strLen + 1;
    std::unique_ptr<char[]> str = std::make_unique<char[]>(bufLen);
    status = napi_get_value_string_utf8(env_, val_, str.get(), bufLen, &strLen);
    return std::make_tuple(status == napi_ok, std::move(str), strLen);
}

std::string NVal::GetStringParam() const
{
    std::string result;
    auto [resResultArg, arg, unused] = NVal(env_, val_).ToUTF8String();
    if (!resResultArg) {
        return result;
    }
    result = arg.get();
    return result;
}

bool NVal::HasProp(std::string propName) const
{
    bool res = false;

    if ((!env_) || (!val_) || (!TypeIs(napi_object))) {
        return false;
    }
    napi_status status = napi_has_named_property(env_, val_, propName.c_str(), &res);
    return (status == napi_ok) && res;
}

bool NVal::AddProp(std::string propName, napi_value val) const
{
    if ((!TypeIs(napi_valuetype::napi_object)) || HasProp(propName)) {
        return false;
    }

    napi_status status = napi_set_named_property(env_, val_, propName.c_str(), val);
    if (status != napi_ok) {
        return false;
    }

    return true;
}

NVal NVal::CreateBool(napi_env env, bool val)
{
    napi_value res = nullptr;
    napi_get_boolean(env, val, &res);
    return {env, res};
}

NVal NVal::CreateUTF8String(napi_env env, std::string str)
{
    napi_value res = nullptr;
    napi_create_string_utf8(env, str.c_str(), str.length(), &res);
    return {env, res};
}

NVal NVal::CreateUndefined(napi_env env)
{
    napi_value res = nullptr;
    napi_get_undefined(env, &res);
    return {env, res};
}

NVal NVal::CreateInt32(napi_env env, int32_t val)
{
    napi_value res = nullptr;
    napi_create_int32(env, val, &res);
    return {env, res};
}

NVal NVal::CreateArrayString(napi_env env, std::vector<std::string> strs)
{
    napi_value res = nullptr;
    napi_create_array(env, &res);
    for (size_t i = 0; i < strs.size(); i++) {
        napi_value filename;
        napi_create_string_utf8(env, strs[i].c_str(), strs[i].length(), &filename);
        napi_set_element(env, res, i, filename);
    }
    return {env, res};
}
}  // namespace FileManagerCommon
}  // namespace OHOS