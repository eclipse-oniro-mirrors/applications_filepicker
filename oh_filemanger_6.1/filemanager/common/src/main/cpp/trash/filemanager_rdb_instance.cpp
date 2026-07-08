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

#include "filemanager_rdb_instance.h"
#include <unistd.h>
#include <thread>

#include "utils/log.h"
#include "trash_data_struct.h"
#include "trash_utils.h"
#include "filemanager_db_manager.h"
namespace OHOS {
namespace FileManager {

namespace {
    static const int64_t BACKUP_INTERVAL = 14400; // 4 * 3600 s
    static const int64_t EXIT_BACKUP_INTERVAL = 1800; // 30 * 60 s
}

bool FileManagerRdbInstance::serviceFlag_ = false;

FileManagerRdbInstance::FileManagerRdbInstance(const std::string &userId, const bool isCrossUser)
{
    userId_ = userId;
    isCrossUser_ = isCrossUser;
}

FileManagerRdbInstance::~FileManagerRdbInstance()
{
    CloseRdbStore();
}

std::shared_ptr<OH_Rdb_Store> FileManagerRdbInstance::GetRdbStore()
{
    std::shared_ptr<OH_Rdb_Store> rdbStore;
    GetRdbStore(rdbStore);
    return rdbStore;
}

int32_t FileManagerRdbInstance::GetRdbStore(std::shared_ptr<OH_Rdb_Store> &rdbStore)
{
    std::lock_guard<std::recursive_mutex> lockGuard(dbMutex_);
    int32_t errorCode = E_FILEMGR_OK;
    if (!rdbStore_) {
        errorCode = Init();
    }
    rdbStore = rdbStore_;
    return errorCode;
}

void FileManagerRdbInstance::SetServiceFlag()
{
    serviceFlag_ = true;
}

int FileManagerRdbInstance::Init()
{
    HILOGI("DB Init begin");
    CHECK_AND_RETURN_RET_LOG(userId_.empty(), E_FILEMGR_ERR, "user is empty");
    std::lock_guard<std::recursive_mutex> lockGuard(dbMutex_);
    if (rdbStore_) {
        return OH_Rdb_ErrCode::RDB_OK;
    }

    int result = OH_Rdb_ErrCode::RDB_OK;
    dbPathDir_ = isCrossUser_ ? FileConsts::CROSS_USER_CLIENT_DB_DIR :
        FileConsts::DB_STORE_CLIENT_DIR;

    HILOGI("DB Init dir");
    if (access(dbPathDir_.c_str(), 0) != 0) {
        bool isDirCreated = FileManagerUtils::Mkdir(dbPathDir_);
        CHECK_AND_RETURN_RET_LOG(!isDirCreated, E_MKDIR_FAILED, "create dir failed");
    }

    bool isNeedRestore = IsNeedRestoreRdb(dbPathDir_); // 数据库还原，需要先开库成功，再通过rdbStore句柄还原
    std::string dbPath = dbPathDir_ + FileConsts::RDB_FILE_NAME;
    result = CreateRdb(dbPath); // 首次开库
    if (rdbStore_ == nullptr) {
        return result;
    }

    if (isNeedRestore) {
        result = RdbRestore();
        HILOGI("rdb restore result : %{public}d", result);
        return result;
    }
    HILOGI("DB Init end, result : %{public}d", result);
    return result;
}

int FileManagerRdbInstance::CreateRdb(const std::string& dbPath)
{
    HILOGI("CreateRdb begin");
    CHECK_AND_RETURN_RET_LOG(dbPath.empty(), E_FILEMGR_ERR, "dbPath is empty");
    OH_Rdb_ConfigV2 *rdbConfig_ = OH_Rdb_CreateConfig();
    OH_Rdb_SetDatabaseDir(rdbConfig_, "/data/storage/el2/database");
    OH_Rdb_SetArea(rdbConfig_, RDB_SECURITY_AREA_EL2);
    OH_Rdb_SetStoreName(rdbConfig_, "Rdbfilemanager.db");
    OH_Rdb_SetBundleName(rdbConfig_, "com.ohos.filemanager");
    OH_Rdb_SetSecurityLevel(rdbConfig_,   OH_Rdb_SecurityLevel::S2);
    int32_t errCode = OH_Rdb_ErrCode::RDB_OK;
    OH_Rdb_Store *rdbStore = OH_Rdb_CreateOrOpen(rdbConfig_, &errCode);
    rdbStore_.reset(rdbStore);
    if (errCode != OH_Rdb_ErrCode::RDB_OK || rdbStore_ == nullptr) {
        HILOGE("Failed to create db store, errCode = %{public}d", errCode);
    }
    OH_Rdb_Execute(rdbStore_.get(), CREATE_TRASH_TABLE);
    OH_Rdb_Execute(rdbStore_.get(), CREATE_TRASH_INFO_INDEX_INODE);
    HILOGI("CreateRdb table end");
    return errCode;
}

int FileManagerRdbInstance::RdbRestore()
{
    int32_t errCode = OH_Rdb_ErrCode::RDB_ERR;
    std::lock_guard<std::recursive_mutex> lockGuard(dbMutex_);
    if (rdbStore_ == nullptr) {
        HILOGI("rdb rsetore is null.");
        return errCode;
    }
    std::string dbBackUpPath = dbPathDir_ + FileConsts::RDB_BACK_UP_FILE_NAME;
    // 存在备份数据库，从备份数据库还原
    if (access(dbBackUpPath.c_str(), 0) == 0) {
        errCode = OH_Rdb_Restore(rdbStore_.get(), dbBackUpPath.data());
    }
    if (errCode == OH_Rdb_ErrCode::RDB_OK) {
        HILOGI("rdb rsetore success");
        return errCode;
    }

    HILOGI("rdb rsetore fail");
    // 如果还原失败，尝试删除原数据库，重新建库，重新还原
    rdbStore_ = nullptr;
    std::string dbPath = dbPathDir_ + FileConsts::RDB_FILE_NAME;
    errCode = OH_Rdb_DeleteStoreV2(rdbConfig_.get());
    if (errCode != OH_Rdb_ErrCode::RDB_OK) {
        HILOGI("rdb Delete fail, error code : %{public}d", errCode);
        return errCode;
    }
    errCode = CreateRdb(dbPath);
    if (errCode != OH_Rdb_ErrCode::RDB_OK || rdbStore_ == nullptr) {
        HILOGI("CreateRdb fail, error code : %{public}d", errCode);
        return errCode;
    }

    // 重试还原
    errCode = OH_Rdb_Restore(rdbStore_.get(), dbPath.data());
    HILOGI("rdb restore retry results : %{public}d", errCode);
    return errCode;
}

bool FileManagerRdbInstance::IsNeedRestoreRdb(const std::string& dbPathDir)
{
    std::string dbPath = dbPathDir + FileConsts::RDB_FILE_NAME;
    std::string dbWalPath = dbPathDir + FileConsts::RDB_WAL_FILE_NAME;
    std::string dbShmPath = dbPathDir + FileConsts::RDB_SHM_FILE_NAME;
    // 数据库中三个文件，其中一个不存在，需要进行还原操作
    bool dbExist = ((access(dbPath.c_str(), 0) != 0) || (access(dbWalPath.c_str(), 0) != 0) ||
        (access(dbShmPath.c_str(), 0) != 0));
    std::string dbBackUpPath = dbPathDir + FileConsts::RDB_BACK_UP_FILE_NAME;
    int dbBackUpExist = (access(dbBackUpPath.c_str(), 0) != 0);
    // 数据库不存在，备份数据库存在，需要走备份流程
    if (dbExist && !dbBackUpExist) {
        HILOGI("rdb needs to be restored");
        return true;
    }
    return false;
}

void FileManagerRdbInstance::BackupDb(const bool isExit)
{
    std::string dbPath = dbPathDir_;
    auto rdbStore = rdbStore_;
    std::string userId = userId_;
    std::thread([userId, dbPath, rdbStore]() {
        BackupTask(userId, dbPath, rdbStore);
    }).detach();
}

void BackupTask(const std::string userId, const std::string dbPathDir,
    std::shared_ptr<OH_Rdb_Store> rdbStore)
{
    CHECK_AND_RETURN_LOG(rdbStore == nullptr, "rdb store is null");
    std::string dbBackUpPath = dbPathDir + FileConsts::RDB_BACK_UP_FILE_NAME;
    int result = OH_Rdb_Backup(rdbStore.get(), dbBackUpPath.data());
    HILOGW("rdb back up end, ret : %{public}d", result);
    FileManagerDbManager::GetInstance().SetBackupFinish(userId);
}

bool FileManagerRdbInstance::CheckBackUpConditions(const bool isExit)
{
    struct stat dbFileStat;
    std::string dbPath = dbPathDir_ + FileConsts::RDB_SHM_FILE_NAME;
    int result = stat(dbPath.c_str(), &dbFileStat);
    if (result != E_FILEMGR_OK) {
        HILOGI("dbPath is not exist.");
        return false; // 原数据库文件不存在，不进行备份
    }

    struct stat dbBackUpFileStat;
    std::string dbBackUpPath = dbPathDir_ + FileConsts::RDB_BACK_UP_FILE_NAME;
    result = stat(dbBackUpPath.c_str(), &dbBackUpFileStat);
    if (result != E_FILEMGR_OK) {
        HILOGI("dbBackUpPath is not exist.");
        return true; // 备份文件不存在，进行备份
    }

    int64_t rdbMtime = static_cast<int64_t>(dbFileStat.st_mtime);
    int64_t backupRdbMtime = static_cast<int64_t>(dbBackUpFileStat.st_mtime);
    HILOGI("rdb mtime : %{public}ld, backup rdb mtime : %{public}ld", rdbMtime, backupRdbMtime);

    int64_t backUpTime = isExit ? EXIT_BACKUP_INTERVAL : BACKUP_INTERVAL;
    int64_t currentTime = FileManagerUtils::GetTimeStamp();
    // 防止备份后，把当前日期改小
    if (backupRdbMtime > currentTime && abs(rdbMtime - backupRdbMtime) > backUpTime) {
        HILOGW("Time anomaly");
        return true;
    }
    // 数据库原文件修改日期大于备份文件，且日期相差超过4小时，进行备份
    if (rdbMtime > backupRdbMtime && rdbMtime - backupRdbMtime >= backUpTime) {
        return true;
    }
    return false;
}

void FileManagerRdbInstance::CloseRdbStore()
{
    HILOGI("CloseRdbStore enter");
    OH_Rdb_DestroyConfig(rdbConfig_.get());
    OH_Rdb_CloseStore(rdbStore_.get());
    rdbStore_ = nullptr;
}
}  // namespace FileManager
}  // namespace OHOS
