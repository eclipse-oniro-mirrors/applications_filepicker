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

#include "napi/native_api.h"
#include <cstdlib>
#include <sys/ioctl.h>

#include "./fileoperation/listfile.h"

#include "filequery/file_producer.h"
#define HMFS_MONITOR_FL 0x00000002
#define HMFS_IOCTL_HW_GET_FLAGS _IOR(0xf5, 70, unsigned int)
#define HMFS_IOCTL_HW_SET_FLAGS _IOR(0xf5, 71, unsigned int)

typedef unsigned char u8;

/**
 * 设置删除维测标记（文件删除和重命名操作可通过内核日志追溯）
 * @param fd file descriptors 文件描述符
 * @return int
 */
static int setDeleteControlFlag(int fd)
{
    // 查询已有标记
    unsigned int flags = 0;
    int ret = ioctl(fd, HMFS_IOCTL_HW_GET_FLAGS, &flags);
    if (ret < 0) {
        return ret;
    }
    // 判断若已存在标记，则无需再次设置
    if (flags & HMFS_MONITOR_FL) {
        return 0;
    }
    // 设置标记
    flags |= HMFS_MONITOR_FL;
    ret = ioctl(fd, HMFS_IOCTL_HW_SET_FLAGS, &flags);
    if (ret < 0) {
        return ret;
    }
    return 0;
}

static napi_value NAPI_setDeleteControlFlag(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    napi_valuetype valuetype0;
    napi_typeof(env, args[0], &valuetype0);

    int64_t value0;
    napi_get_value_int64(env, args[0], &value0);

    int res = setDeleteControlFlag(value0);
    napi_value returnValue = nullptr;
    napi_create_int64(env, res, &returnValue);

    return returnValue;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        {"setDeleteControlFlag", nullptr, NAPI_setDeleteControlFlag, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"listSubFile",
            nullptr,
            OHOS::FileManagerCommon::ListFile::SubFileSync,
            nullptr,
            nullptr,
            nullptr,
            napi_default,
            nullptr},
        {"queryFiles", nullptr, NAPI_queryFiles, nullptr, nullptr, nullptr, napi_default, nullptr}
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "Security",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void)
{
    napi_module_register(&demoModule);
}
