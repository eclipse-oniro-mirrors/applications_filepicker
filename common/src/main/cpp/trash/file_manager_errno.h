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

#ifndef OHOS_FILE_MANAGER_ERRNO_H
#define OHOS_FILE_MANAGER_ERRNO_H
#include <unordered_map>
#include <string>
namespace OHOS {
namespace FileManager {

constexpr int USERFILESERVICE_SYS_CAP_TAG = 19900000;
// 进程消亡ipc错误码
const int32_t REMOTE_DIED_ERROR_CODE = 29189;
const int32_t REMOTE_DIED_ERROR_CODE_KERNEL = 32;

enum ErrCodeSuffix {
    E_FILEMGR_OK = 0,
    E_FILEMGR_ERR = -1,

    E_PARAM_IS_EMPTY = 19900002,             /* The parameter is empty. */

    E_FILE_FILE_NOT_EXIST = 19900021,           /* The file does not exist. */
    E_MKDIR_FAILED = 19900024,
    E_INVALID_PATH = 19900025,            /* Invalid path. */

    E_DB_INSERT_FAILED = 19900041,
    E_DB_QUERY_FAILED = 19900045,

    E_PARAM = 401,
    E_NOENT = 1014000002,
    E_INNER_ERROR = 1014000004,

    E_UNKNOWN = 1014000999,
};

const std::unordered_map<int, std::string> CommonErrCodeTable {
    {E_FILEMGR_OK, "Successful."},
    {E_FILEMGR_ERR, "Unknown error."},

    {E_PARAM_IS_EMPTY, "The parameter is empty."},

    {E_FILE_FILE_NOT_EXIST, "The file does not exist."},
    {E_MKDIR_FAILED, "Failed to create the directory."},
    {E_INVALID_PATH, "Invalid path."},

    {E_DB_INSERT_FAILED, "Database operation failure: Failed to add data."},
    {E_DB_QUERY_FAILED, "Database operation failure: Failed to query data."},

    {E_PARAM, "Parameter error"},
    {E_NOENT, "No such file or directory"},
    {E_INNER_ERROR, "System inner fail"},
    {E_UNKNOWN, "Unknown error"}
};

}  // namespace FileManager
}  // namespace OHOS
#endif  // OHOS_FILE_MANAGER_ERRNO_H
