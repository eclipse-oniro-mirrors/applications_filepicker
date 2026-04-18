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

#ifndef OHOS_FILEMANAGER_RDB_TRASH_H
#define OHOS_FILEMANAGER_RDB_TRASH_H

#include "filemanager_rdb_instance.h"
#include "trash_data_struct.h"
#include "filemanager_db_manager.h"
#include "filemanager_rdb_utils.h"
#include <database/rdb/relational_store.h>
#include <database/rdb/oh_value_object.h>
#include <database/rdb/oh_cursor.h>
#include "file_manager_utils.h"
namespace OHOS {
namespace FileManager {

enum class TrashStatus {
    DELETING,
    COMPLETE,
    RECOVERING
};

class FileManagerRdbTrash {
public:
    FileManagerRdbTrash(const std::string &userId);
    FileManagerRdbTrash();
    ~FileManagerRdbTrash() {}
    std::vector<TrashInfo> GetTrashes();
    int32_t AddToTrash(const TrashInfo &trashInfo);
    bool DeleteFromTrash(const std::string &trashPath);
    std::vector<TrashInfo> GetTrashInfoByTrashPath(const std::vector<std::string> &trashPaths);
    std::vector<TrashInfo> GetTrashInfoFromRdb(const std::vector<std::string> &trashPaths,
        std::shared_ptr<OH_Rdb_Store> rdbStore);
    bool UpdateStatus(const std::vector<std::string> &trashPaths, TrashStatus status);
    bool UpdateTrashByTrashPath(const TrashInfo &trashInfo);

private:
    std::shared_ptr<FileManagerRdbInstance> rdbInstance_ = nullptr;
};
}  // namespace FileManager
}  // namespace OHOS

#endif