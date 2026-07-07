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

#ifndef OHOS_FILE_MANAGER_COMMON_LOG_H
#define OHOS_FILE_MANAGER_COMMON_LOG_H

#include "hilog/log.h"

namespace OHOS {
namespace FileManagerCommon {

#ifdef HILOGF
#undef HILOGF
#endif
#ifdef HILOGE
#undef HILOGE
#endif
#ifdef HILOGW
#undef HILOGW
#endif
#ifdef HILOGI
#undef HILOGI
#endif
#ifdef HILOGD
#undef HILOGD
#endif

#undef LOG_DOMAIN
#define LOG_DOMAIN 0xf666

#undef LOG_TAG
#define LOG_TAG "FileMgr"

#define FILENAME_ (__builtin_strrchr(__FILE__, '/') ? __builtin_strrchr(__FILE__, '/') + 1 : __FILE__)

#ifndef HILOGF
#define HILOGF(fmt, ...) \
    OH_LOG_FATAL(LOG_APP, "[%{public}s:%{public}d->%{public}s] " fmt, FILENAME_, __LINE__, __FUNCTION__, ##__VA_ARGS__)
#endif

#ifndef HILOGE
#define HILOGE(fmt, ...) \
    OH_LOG_ERROR(LOG_APP, "[%{public}s:%{public}d->%{public}s] " fmt, FILENAME_, __LINE__, __FUNCTION__, ##__VA_ARGS__)
#endif

#ifndef HILOGW
#define HILOGW(fmt, ...) \
    OH_LOG_WARN(LOG_APP, "[%{public}s:%{public}d->%{public}s] " fmt, FILENAME_, __LINE__, __FUNCTION__, ##__VA_ARGS__)
#endif

#ifndef HILOGI
#define HILOGI(fmt, ...) \
    OH_LOG_INFO(LOG_APP, "[%{public}s:%{public}d->%{public}s] " fmt, FILENAME_, __LINE__, __FUNCTION__, ##__VA_ARGS__)
#endif

#ifndef HILOGD
#define HILOGD(fmt, ...) \
    OH_LOG_DEBUG(LOG_APP, "[%{public}s:%{public}d->%{public}s] " fmt, FILENAME_, __LINE__, __FUNCTION__, ##__VA_ARGS__)
#endif

#define CHECK_AND_RETURN_RET_LOG(cond, ret, fmt, ...) \
    if (cond) {                                       \
        HILOGE(fmt, ##__VA_ARGS__);                   \
        return ret;                                   \
    }

#define CHECK_AND_RETURN_LOG(cond, fmt, ...) \
    if (cond) {                              \
        HILOGE(fmt, ##__VA_ARGS__);          \
        return;                              \
    }

#define CHECK_AND_PRINT_LOG(cond, fmt, ...) \
    if (cond) {                             \
        HILOGW(fmt, ##__VA_ARGS__);         \
    }

#define CHECK_AND_RETURN_RET(cond, ret) \
    if (cond) {                         \
        return ret;                     \
    }
}  // namespace FileManagerCommon
}  // namespace OHOS

#endif  // OHOS_FILE_MANAGER_COMMON_LOG_H
