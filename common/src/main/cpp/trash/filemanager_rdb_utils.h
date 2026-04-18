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

#ifndef OHOS_FILEMANAGER_RDB_UTILS_H
#define OHOS_FILEMANAGER_RDB_UTILS_H

#include <vector>
#include <database/rdb/oh_cursor.h>

namespace OHOS {
namespace FileManager {
class FileManagerRdbUtils {
public:
    static std::string GetStringColumn(
        OH_Cursor *resultSet, const std::string columnId);
    static int64_t GetLongColumn(
        OH_Cursor *resultSet, const std::string columnId);
};
}  // namespace FileManager
}  // namespace OHOS

#endif