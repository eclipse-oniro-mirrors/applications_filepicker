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

#ifndef OHOS_N_ERROR_H
#define OHOS_N_ERROR_H

#include <functional>
#include <string>
#include <tuple>
#include <unordered_map>
#include "napi/native_api.h"
#include "napi/n_error.h"
#include "n_val.h"
#include "utils/log.h"

namespace OHOS {
namespace FileManager {
constexpr int UNKROWN_ERR = -1;
constexpr int ERRNO_NOERR = 0;
const std::string FILEIO_TAG_ERR_CODE = "code";
const std::string FILEIO_TAG_ERR_DATA = "data";


class NError {
public:
    NError();
    NError(int ePosix);
    NError(std::function<std::tuple<uint32_t, std::string>()> errGen);
    ~NError() = default;
    explicit operator bool() const;
    napi_value GetNapiErr(napi_env env);
    napi_value GetNapiErr(napi_env env, int errCode);
    napi_value GetNapiErrAddData(napi_env env, int errCode, napi_value data);
    void ThrowErr(napi_env env);
    void ThrowErr(napi_env env, int errCode);
    void ThrowErr(napi_env env, std::string errMsg);
    void ThrowErrAddData(napi_env env, int errCode, napi_value data);
    int GetErrrCode();

private:
    int errno_ = ERRNO_NOERR;
    std::string errMsg_;
};
}  // namespace FileManager
}  // namespace OHOS

#endif  // OHOS_N_ERROR_H
