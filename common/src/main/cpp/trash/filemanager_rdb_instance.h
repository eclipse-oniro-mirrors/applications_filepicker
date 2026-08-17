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

#ifndef OHOS_FILEMANAGER_RDB_HELPER_H
#define OHOS_FILEMANAGER_RDB_HELPER_H

#include <mutex>
#include <database/rdb/relational_store.h>
#include "file_manager_utils.h"
#include "file_manager_errno.h"
#include  <database/rdb/relational_store_error_code.h>
namespace OHOS {
namespace FileManager {
constexpr int32_t DATABASE_TRASH_VERSION = 3;
constexpr int32_t DATABASE_TRASH_ADD_INDEX_VERSION = 6;

constexpr const char *CREATE_TRASH_TABLE =
    "CREATE TABLE IF NOT EXISTS [trash]("
    "[id] INTEGER PRIMARY KEY AUTOINCREMENT,"
    "[src_path] TEXT NOT NULL,"
    "[trash_path] TEXT NOT NULL,"
    "[delete_time] INTEGER,"
    "[status] INTEGER DEFAULT 1);";

constexpr const char *CREATE_TRASH_INFO_INDEX_INODE =
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_trash_path ON trash (trash_path);";

using RdbUpdateCallback = std::function<void(std::string, int32_t)>;

void BackupTask(const std::string userId, const std::string dbPathDir,
    std::shared_ptr<OH_Rdb_Store> rdbStore);

class FileManagerRdbInstance {
public:
    static void SetServiceFlag();
    FileManagerRdbInstance(const std::string &userId, const bool isCrossUser = false);
    ~FileManagerRdbInstance();
    int Init();
    std::shared_ptr<OH_Rdb_Store> GetRdbStore();
    int32_t GetRdbStore(std::shared_ptr<OH_Rdb_Store> &rdbStore);
    int RdbRestore();
    void CloseRdbStore();
    void BackupDb(const bool isExit);
    bool CheckBackUpConditions(const bool isExit);

private:
    int CreateRdb(const std::string& dbPath);
    bool IsNeedRestoreRdb(const std::string& dbPathDir);
private:
    static bool serviceFlag_;

    std::shared_ptr<OH_Rdb_Store> rdbStore_;
    std::shared_ptr<OH_Rdb_ConfigV2> rdbConfig_;
    std::recursive_mutex dbMutex_;
    std::string dbPathDir_ = "";
    std::string userId_ = "";
    bool isCrossUser_ = false;
};

}  // namespace FileManager
}  // namespace OHOS

#endif