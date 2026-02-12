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

#ifndef OHOS_N_ASYNC_WORK_FACTORY_H
#define OHOS_N_ASYNC_WORK_FACTORY_H

#include "n_async_context.h"
#include "napi/n_val.h"

namespace OHOS {
namespace FileManager {
class NAsyncWorkFactory {
public:
    explicit NAsyncWorkFactory(napi_env env) : env_(env) {}
    virtual ~NAsyncWorkFactory() = default;
    virtual FileManagerCommon::NVal Schedule(std::string procedureName, NContextCBExec cbExec, NContextCBComplete cbComplete) = 0;

    napi_env env_ = nullptr;
};
}  // namespace FileManager
}  // namespace OHOS
#endif  // OHOS_N_ASYNC_WORK_FACTORY_H