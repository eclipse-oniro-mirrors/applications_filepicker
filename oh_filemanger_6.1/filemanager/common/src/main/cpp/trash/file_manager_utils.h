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

#ifndef OHOS_FILE_MANAGER_UTILS_H
#define OHOS_FILE_MANAGER_UTILS_H

#include <vector>
#include <string>

namespace OHOS {
namespace FileManager {
namespace FileConsts {
const std::string TRANSFORM_DELETE = "file://docs";
const std::string FAF_URI_BASE = "file://docs/storage/Users/currentUser";
const std::string FAF_FOLDER_BASE = "/storage/Users/currentUser";
const std::string FAT_PATH_BEFORE_UID = "/storage/media/";
const std::string FAT_PATH_AFTER_UID = "/local/files/Docs";
const std::string DB_STORE_CLIENT_DIR = "/storage/Users/currentUser/.thumbs/db";
const std::string EXTERNAL_URI_BASE = "file://docs/storage/External";
const std::string URL_BASE = "/storage/Users/currentUser";
const std::string DB_DIR = "/.thumbs/db";
const std::string RDB_SHM_FILE_NAME = "/filemgr_sqlite.db-shm";
const std::string RDB_WAL_FILE_NAME = "/filemgr_sqlite.db-wal";
const std::string RDB_BACK_UP_FILE_NAME = "/filemgr_sqlite_backup.db";
const std::string RDB_FILE_NAME = "/filemgr_sqlite.db";
const std::string CROSS_USER_CLIENT_DB_DIR = "/storage/Users/mainUserForPrivate/.thumbs/db";
}  // namespace FileConsts

using MimeTypeMap = std::unordered_map<std::string, std::vector<std::string>>;
class FileManagerUtils {
public:
    static std::string GetFileNameFromUri(const std::string &path);
    static std::string GetParentPath(const std::string &path);
    static bool StartsWith(const std::string &str, const std::string prefix);
    static std::string Encode(const std::string &uri);
    static std::string Decode(const std::string &uri);
    static bool Mkdir(std::string path);
    static int64_t GetTimeStamp();

    static bool ConvertStrToInt32(const std::string &str, int32_t &ret);
    static int RemovePath(const std::string &pathStr);
    static std::string GetVerifyUserId();
};

}  // namespace FileManager
}  // namespace OHOS

#endif  // OHOS_FILE_MANAGER_UTILS_H