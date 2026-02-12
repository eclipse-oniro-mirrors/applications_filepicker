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

#ifndef OHOS_FILEMANAGER_DB_MANAGER_H
#define OHOS_FILEMANAGER_DB_MANAGER_H

#include <mutex>
#include <memory>
#include <map>
#include <set>
#include "file_manager_utils.h"
#include "filemanager_rdb_instance.h"

namespace OHOS {
namespace FileManager {
class FileManagerDbManager {
public:
    static FileManagerDbManager& GetInstance()
    {
        static FileManagerDbManager instance;
        return instance;
    }
    bool Initialize(const std::string &userId, const bool isCrossUser);
    std::shared_ptr<FileManagerRdbInstance> GetRdbInstance(const std::string &userId,
        const bool isCrossUser = false);
    void BackupAllRdb(const bool isExit);
    void SetBackupFinish(const std::string &userId);
    void CloseAllRdbStore();
    ~FileManagerDbManager()
    {
        std::lock_guard<std::mutex> lock(rdbMutex_);
        rdbInstances_.clear();
    }
private:
    std::map<std::string, std::shared_ptr<FileManagerRdbInstance>> rdbInstances_;
    std::set<std::string> backupingInstances_;
    std::mutex rdbMutex_;
    std::mutex backupMutex_;
    FileManagerDbManager() {}
};
}
}
#endif