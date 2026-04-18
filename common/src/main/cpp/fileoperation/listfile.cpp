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

#include "listfile.h"
#include "../napi/n_func_arg.h"
#include "../napi/n_val.h"
#include "../utils/log.h"
#include "../utils/file_manager_operation_struct.h"

namespace OHOS {
namespace FileManagerCommon {

namespace {
constexpr int FILTER_MATCH = 1;
constexpr int FILTER_DISMATCH = 0;
constexpr int ERRNO_NOERR = 0;
}  // namespace

static int32_t FilterFunc(const struct dirent *filename)
{
    if (std::string_view(filename->d_name) == "." || std::string_view(filename->d_name) == "..") {
        return FILTER_DISMATCH;
    }

    if (filename->d_type == DT_DIR) {
        return FILTER_MATCH;
    }
    return FILTER_DISMATCH;
}

static void Deleter(struct NameListArg *arg)
{
    for (int i = 0; i < arg->direntNum; i++) {
        if ((arg->namelist)[i] != nullptr) {
            free((arg->namelist)[i]);
            (arg->namelist)[i] = nullptr;
        }
    }
    if (arg->namelist != nullptr) {
        free(arg->namelist);
        arg->namelist = nullptr;
    }
}

static int32_t FilterFileFunc(const struct dirent *filename)
{
    if (std::string_view(filename->d_name) == "." || std::string_view(filename->d_name) == "..") {
        return FILTER_DISMATCH;
    }

    if (filename->d_type != DT_DIR) {
        return FILTER_MATCH;
    }
    return FILTER_DISMATCH;
}

static napi_value DoListSubFileVector2NV(napi_env env, std::vector<std::string> &dirents)
{
    return NVal::CreateArrayString(env, dirents).val_;
}

static int FilterSubFileRes(const std::string &path, const bool isFilterFile, std::vector<std::string> &dirents)
{
    std::unique_ptr<struct NameListArg, decltype(Deleter) *> pNameList = {
        new (std::nothrow) struct NameListArg, Deleter};
    if (!pNameList) {
        HILOGE("Failed to request heap memory.");
        return ENOMEM;
    }

    int num = scandir(path.c_str(), &(pNameList->namelist), isFilterFile ? FilterFileFunc : FilterFunc, nullptr);
    if (num < 0) {
        HILOGE("Failed to scan dir");
        return errno;
    }
    pNameList->direntNum = num;
    HILOGI("direntNum %{public}d", num);
    for (int i = 0; i < num; i++) {
        std::string fileName = std::string((*(pNameList->namelist[i])).d_name);
        dirents.push_back(fileName);
    }
    return ERRNO_NOERR;
}

napi_value ListFile::SubFileSync(napi_env env, napi_callback_info info)
{
    NFuncArg funcArg(env, info);
    if (!funcArg.InitArgs(NARG_CNT::ONE, NARG_CNT::TWO)) {
        HILOGE("Number of arguments unmatched");
        return nullptr;
    }
    std::string path = NVal(env, funcArg[NARG_POS::FIRST]).GetStringParam();
    if (path.empty()) {
        HILOGE("path is null.");
        return nullptr;
    }

    bool isFilterFile = true;
    if (funcArg.GetArgc() >= NARG_CNT::ONE) {
        auto option = NVal(env, funcArg[NARG_POS::SECOND]);
        if (option.TypeIs(napi_boolean)) {
            HILOGW("Filter Folder.");
            isFilterFile = false;
        }
    }

    std::vector<std::string> direntsRes;
    int ret = FilterSubFileRes(path, isFilterFile, direntsRes);
    if (ret) {
        HILOGE("FilterSubFileRes error, ret : %{public}d", ret);
        return nullptr;
    }
    auto res = DoListSubFileVector2NV(env, direntsRes);
    return res;
}
}  // namespace FileManagerCommon
}  // namespace OHOS