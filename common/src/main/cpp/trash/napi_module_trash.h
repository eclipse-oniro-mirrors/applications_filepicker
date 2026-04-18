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

#ifndef OHOS_NAPI_MODULE_TRASH_H
#define OHOS_NAPI_MODULE_TRASH_H

#include "file_manager_utils.h"
#include "napi/native_api.h"
#include "napi/n_func_arg.h"
#include "napi/n_val.h"
#include "napi/n_error.h"
namespace OHOS {
namespace FileManager {
class TrashNapi {
public:
    static napi_value DeleteToTrash(napi_env env, napi_callback_info info);
    static napi_value Recover(napi_env env, napi_callback_info info);
    static napi_value ListTrashFile(napi_env env, napi_callback_info info);
    static napi_value DeleteCompletely(napi_env env, napi_callback_info info);
    static napi_value RecoverFileToSpecifiedDir(napi_env env, napi_callback_info info);
    static napi_value ProcessOldRecycleBinFiles(napi_env env, napi_callback_info info);
};
}  // namespace FileManager
}  // namespace OHOS
#endif  // OHOS_NAPI_MODULE_TRASH_H