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

#ifndef HMFILEMANAGER_COMMON_H
#define HMFILEMANAGER_COMMON_H

#define BATCH_SIZE_1W 10000  // 文件查询批次数量，1W
#define PARAM_ONE 1          // 参数数量1
#define PARAM_TWO 2          // 参数数量2
#define PARAM_THREE 3        // 参数数量3
#define PARAM_FOUR 4         // 参数数量4
#define PARAM_FIVE 5         // 参数数量5

#define BUFFER_256KB 262144  // buffer大小256KB
#define BUFFER_64 64         // buffer大小64

// 定义批量napi属性转换
#define DECLARE_NAPI_PROPERTY(name, val)                                       \
    {                                                                          \
        (name), nullptr, nullptr, nullptr, nullptr, val, napi_default, nullptr \
    }
#endif  // COMMON_H