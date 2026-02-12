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

#ifndef FILE_MANAGER_COMMON_LIST_FILE_H
#define FILE_MANAGER_COMMON_LIST_FILE_H

#include <dirent.h>
#include "napi/native_api.h"

namespace OHOS {
namespace FileManagerCommon {

struct NameListArg {
    struct dirent **namelist = {nullptr};
    int direntNum = 0;
};

class ListFile {
public:
    static napi_value SubFileSync(napi_env env, napi_callback_info info);
};
}  // namespace FileManagerCommon
}  // namespace OHOS
#endif  // FILE_MANAGER_COMMON_LIST_FILE_H