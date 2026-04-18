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

#include "filemanager_rdb_utils.h"
#include "filemanager_rdb_instance.h"
#include "file_manager_utils.h"

namespace OHOS {
namespace FileManager {
std::string FileManagerRdbUtils::GetStringColumn(
    OH_Cursor *resultSet, const std::string columnId)
{
    int columnIndex = 0;
    size_t dataLength = 0;
    resultSet->getColumnIndex(resultSet, columnId.data(), &columnIndex);
    resultSet->getSize(resultSet, columnIndex, &dataLength);
    char *value = (char*)malloc((dataLength + 1) * sizeof(char));
    resultSet->getText(resultSet, columnIndex, value, dataLength + 1);
    std::string columnValue = value;
    return columnValue;
}

int64_t FileManagerRdbUtils::GetLongColumn(
    OH_Cursor *resultSet, const std::string columnId)
{
    int columnIndex = 0;
    int64_t columnValue = 0;
    resultSet->getColumnIndex(resultSet, columnId.data(), &columnIndex);
    resultSet->getInt64(resultSet, columnIndex, &columnValue);
    return columnValue;
}
}  // namespace FileManager
}  // namespace OHOS
