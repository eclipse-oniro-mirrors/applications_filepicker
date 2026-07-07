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

#include "filemanager_db_manager.h"
#include  <database/rdb/relational_store_error_code.h>
#include "utils/log.h"

namespace OHOS {
namespace FileManager {
bool FileManagerDbManager::Initialize(const std::string &userId, bool isCrossUser)
{
    if (rdbInstances_.find(userId) != rdbInstances_.end()) {
        return true;
    }
    auto rdbInstance = std::make_shared<FileManagerRdbInstance>(userId, isCrossUser);
    if (rdbInstance->Init() != OH_Rdb_ErrCode::RDB_OK) {
        HILOGE("OpenDatabase fail");
        return false;
    }
    rdbInstances_[userId] = rdbInstance;
    return true;
}

std::shared_ptr<FileManagerRdbInstance> FileManagerDbManager::GetRdbInstance(const std::string &userId,
    bool isCrossUser)
{
    std::lock_guard<std::mutex> lock(rdbMutex_);
    std::string targetUserId = userId;
    if (userId.empty()) {
        targetUserId = FileManagerUtils::GetVerifyUserId();
    }
    if (!Initialize(targetUserId, isCrossUser)) {
        return nullptr; // 返回空指针表示初始化失败
    }
    auto it = rdbInstances_.find(targetUserId);
    if (it != rdbInstances_.end()) {
        return it->second; // 返回对应的 shared_ptr<FileManagerRdbInstance>
    } else {
        return nullptr; // 如果键不存在，返回空指针
    }
}

void FileManagerDbManager::SetBackupFinish(const std::string &userId)
{
    std::lock_guard<std::mutex> lock(backupMutex_);
    backupingInstances_.erase(userId);
}

void FileManagerDbManager::BackupAllRdb(const bool isExit)
{
    HILOGI("start backup all rdb");
    std::lock_guard<std::mutex> rdbLock(rdbMutex_);
    std::lock_guard<std::mutex> backupLock(backupMutex_);
    for (auto& [userId, rdbInstance] : rdbInstances_) {
        CHECK_AND_RETURN_LOG(rdbInstance == nullptr, "rdbInstance is null");
        if (backupingInstances_.find(userId) != backupingInstances_.end() ||
            !rdbInstance->CheckBackUpConditions(isExit)) {
            continue;
        }
        backupingInstances_.insert(userId);
        rdbInstance->BackupDb(isExit);
    }
    return;
}

void FileManagerDbManager::CloseAllRdbStore()
{
    std::lock_guard<std::mutex> lock(rdbMutex_);
    rdbInstances_.clear();
    HILOGI("Finish closing rdb store");
}
}  // namespace FileManager
}  // namespace OHOS
