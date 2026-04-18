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

#include "filemanager_rdb_trash.h"

#include  <database/rdb/relational_store_error_code.h>
#include "utils/log.h"
namespace OHOS {
namespace FileManager {
namespace {
    const std::string TABLE_TRASH = "trash";
    const std::string FIELD_SRC_PATH = "src_path";
    const std::string FIELD_TRASH_PATH = "trash_path";
    const std::string FIELD_DELETE_TIME = "delete_time";
    const std::string FIELD_STATUS = "status";
}

FileManagerRdbTrash::FileManagerRdbTrash(const std::string &userId)
{
    rdbInstance_ = FileManagerDbManager::GetInstance().GetRdbInstance(userId);
}

FileManagerRdbTrash::FileManagerRdbTrash()
{
    std::string userId = FileManagerUtils::GetVerifyUserId();
    rdbInstance_ = FileManagerDbManager::GetInstance().GetRdbInstance(userId);
}

std::vector<TrashInfo> FileManagerRdbTrash::GetTrashes()
{
    HILOGD("GetTrashes begin");
    std::vector<TrashInfo> trashInfos;
    CHECK_AND_RETURN_RET_LOG(rdbInstance_ == nullptr, trashInfos, "db connect is null");
    auto rdbStore = rdbInstance_->GetRdbStore();
    CHECK_AND_RETURN_RET_LOG(rdbStore == nullptr, trashInfos, "db connect is null");
    std::string sql = "select src_path, trash_path, delete_time from trash where status = " +
        std::to_string(static_cast<int32_t>(TrashStatus::COMPLETE));
    auto resultSet = OH_Rdb_ExecuteQuery(rdbStore.get(), sql.data());
    if (resultSet == nullptr) {
        HILOGE("GetTrashes failed, resultSet is nullptr");
        return trashInfos;
    }
    
    while (resultSet->goToNextRow(resultSet) == OH_Rdb_ErrCode::RDB_OK) {
        TrashInfo trashInfo;
        trashInfo.srcPath = FileManagerRdbUtils::GetStringColumn(resultSet, FIELD_SRC_PATH);
        trashInfo.trashPath = FileManagerRdbUtils::GetStringColumn(resultSet, FIELD_TRASH_PATH);
        trashInfo.deleteTime = FileManagerRdbUtils::GetLongColumn(resultSet, FIELD_DELETE_TIME);
        trashInfos.push_back(trashInfo);
    }
    resultSet->destroy(resultSet);
    HILOGD("GetTrashes end");
    return trashInfos;
}

int32_t FileManagerRdbTrash::AddToTrash(const TrashInfo &trashInfo)
{
    HILOGD("AddToTrash begin.trashPath=%{private}s", trashInfo.trashPath.c_str());
    CHECK_AND_RETURN_RET_LOG(rdbInstance_ == nullptr, E_FILEMGR_ERR, "db connect is null");
    std::shared_ptr<OH_Rdb_Store> rdbStore;
    auto errcode = rdbInstance_->GetRdbStore(rdbStore);
    CHECK_AND_RETURN_RET_LOG(rdbStore == nullptr, errcode, "db connect is null");

    OH_VBucket *values = OH_Rdb_CreateValuesBucket();
    values->putText(values, FIELD_SRC_PATH.data(), trashInfo.srcPath.data());
    values->putText(values, FIELD_TRASH_PATH.data(), trashInfo.trashPath.data());
    values->putInt64(values, FIELD_DELETE_TIME.data(), trashInfo.deleteTime);
    values->putInt64(values, FIELD_STATUS.data(), static_cast<int32_t>(TrashStatus::COMPLETE));

    int64_t rowId = 0;
    int32_t ret = OH_Rdb_Insert(rdbStore.get(), TABLE_TRASH.data(), values);
    values->destroy(values);
    if (ret < 0) {
        HILOGE("Insert failed, ret = %{public}d", ret);
    }
    HILOGD("AddToTrash end.");
    return ret;
}

bool FileManagerRdbTrash::UpdateStatus(const std::vector<std::string> &trashPaths, TrashStatus status)
{
    HILOGD("UpdateStatus begin");
    CHECK_AND_RETURN_RET_LOG(rdbInstance_ == nullptr, false, "db connect is null");
    auto rdbStore = rdbInstance_->GetRdbStore();
    CHECK_AND_RETURN_RET_LOG(rdbStore == nullptr, false, "db connect is null");

    std::string sql = "update trash set status = " + std::to_string(static_cast<int32_t>(status)) +
        " where trash_path in (";

    size_t size = trashPaths.size();
    for (size_t i = 0; i < size; i++) {
        sql.append("?");
        if (i + 1 < size) {
            sql.append(",");
        }
    }
    sql.append(")");
    int ret = OH_Rdb_Execute(rdbStore.get(), sql.data());
    if (ret != OH_Rdb_ErrCode::RDB_OK) {
        return false;
    }
    HILOGD("UpdateStatus end");
    return true;
}

bool FileManagerRdbTrash::DeleteFromTrash(const std::string &trashPath)
{
    HILOGD("DeleteFromTrash begin");
    CHECK_AND_RETURN_RET_LOG(trashPath.empty(), false, "trashPath is empty");
    CHECK_AND_RETURN_RET_LOG(rdbInstance_ == nullptr, false, "db connect is null");
    auto rdbStore = rdbInstance_->GetRdbStore();
    CHECK_AND_RETURN_RET_LOG(rdbStore == nullptr, false, "db connect is null");
    
    OH_Predicates *predicates = OH_Rdb_CreatePredicates(TABLE_TRASH.data());
    OH_VObject *valueObject = OH_Rdb_CreateValueObject();
    valueObject->putText(valueObject, trashPath.data());
    predicates->equalTo(predicates, FIELD_TRASH_PATH.data(), valueObject);
    int32_t ret = OH_Rdb_Delete(rdbStore.get(), predicates);
    valueObject->destroy(valueObject);
    predicates->destroy(predicates);
    if (ret < 0) {
        HILOGE("DeleteFromTrash failed, ret = %{public}d", ret);
        return false;
    }
    HILOGD("DeleteFromTrash end");
    return true;
}

std::vector<TrashInfo> FileManagerRdbTrash::GetTrashInfoByTrashPath(const std::vector<std::string> &trashPaths)
{
    HILOGD("GetTrashInfoBySrcPath start.");
    std::vector<TrashInfo> trashInfos;
    CHECK_AND_RETURN_RET_LOG(trashPaths.empty(), trashInfos, "trashPaths is empty");
    CHECK_AND_RETURN_RET_LOG(rdbInstance_ == nullptr, trashInfos, "db connect is null");
    auto rdbStore = rdbInstance_->GetRdbStore();
    return GetTrashInfoFromRdb(trashPaths, rdbStore);
}

std::vector<TrashInfo> FileManagerRdbTrash::GetTrashInfoFromRdb(
    const std::vector<std::string> &trashPaths, std::shared_ptr<OH_Rdb_Store> rdbStore)
{
    std::vector<TrashInfo> trashInfos;
    CHECK_AND_RETURN_RET_LOG(rdbStore == nullptr, trashInfos, "rdb is null");
    CHECK_AND_RETURN_RET_LOG(trashPaths.empty(), trashInfos, "trashPaths is empty");

    std::string sql = "select src_path, trash_path, delete_time from trash where trash_path in (";
    size_t size = trashPaths.size();
    OH_Data_Values *values = OH_Values_Create();
    for (size_t i = 0; i < size; i++) {
        sql.append("?");
        if (i + 1 < size) {
            sql.append(",");
        }
        OH_Values_PutText(values, trashPaths[i].c_str());
    }
    sql.append(")");
    auto resultSet = OH_Rdb_ExecuteQueryV2(rdbStore.get(), sql.data(), values);
    if (resultSet == nullptr) {
        HILOGE("GetTrashes failed, resultSet is nullptr");
        return trashInfos;
    }
    while (resultSet->goToNextRow(resultSet) == OH_Rdb_ErrCode::RDB_OK) {
        TrashInfo trashInfo;
        trashInfo.srcPath = FileManagerRdbUtils::GetStringColumn(resultSet, FIELD_SRC_PATH);
        trashInfo.trashPath = FileManagerRdbUtils::GetStringColumn(resultSet, FIELD_TRASH_PATH);
        trashInfo.deleteTime = FileManagerRdbUtils::GetLongColumn(resultSet, FIELD_DELETE_TIME);
        trashInfos.push_back(trashInfo);
    }
    resultSet->destroy(resultSet);
    HILOGD("GetTrashInfoBySrcPath end.");
    return trashInfos;
}

bool FileManagerRdbTrash::UpdateTrashByTrashPath(const TrashInfo &trashInfo)
{
    HILOGD("UpdateTrashByTrashPath begin.");
    CHECK_AND_RETURN_RET_LOG(rdbInstance_ == nullptr, false, "rdbInstance is null");
    std::shared_ptr<OH_Rdb_Store> rdbStore;
    int32_t errorCode = rdbInstance_->GetRdbStore(rdbStore);
    CHECK_AND_RETURN_RET_LOG(rdbStore == nullptr, false, "db connect is null");
    CHECK_AND_RETURN_RET_LOG(errorCode != OH_Rdb_ErrCode::RDB_OK, false, "GetRdbStore fail:%{public}d", errorCode);

    OH_VBucket *values = OH_Rdb_CreateValuesBucket();
    values->putText(values, FIELD_SRC_PATH.data(), trashInfo.srcPath.data());
    values->putInt64(values, FIELD_DELETE_TIME.data(), trashInfo.deleteTime);
    values->putInt64(values, FIELD_STATUS.data(), static_cast<int32_t>(TrashStatus::COMPLETE));
    
    OH_Predicates *predicates = OH_Rdb_CreatePredicates(TABLE_TRASH.data());
    OH_VObject *valueObject = OH_Rdb_CreateValueObject();
    valueObject->putText(valueObject, trashInfo.trashPath.data());
    predicates->equalTo(predicates, FIELD_TRASH_PATH.data(), valueObject)->andOperate(predicates);
    int changedRows = OH_Rdb_Update(rdbStore.get(), values, predicates);
    values->destroy(values);
    predicates->destroy(predicates);
    CHECK_AND_PRINT_LOG(changedRows == 0, "no rows has be changed.");
    HILOGD("UpdateTrashByTrashPath end.");
    return true;
}

}  // namespace FileManager
}  // namespace OHOS
