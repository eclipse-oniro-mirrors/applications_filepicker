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
#ifndef OHOS_FILEMANAGER_TRASH_DATA_STRUCT_H
#define OHOS_FILEMANAGER_TRASH_DATA_STRUCT_H

#include <string>
#include "file_manager_utils.h"
namespace OHOS {
namespace FileManager {
struct TrashInfo {
    std::string srcPath;
    std::string trashPath;
    int64_t deleteTime;
};

struct FileInfo {
    std::string uri;
    std::string srcPath;
    std::string fileName;
    std::string trashFileName;
    int32_t mode{0};
    int64_t size{0};
    int64_t mtime{0};
    int64_t ctime{0};
    int64_t deleteTime{0};
};

struct ErrFiles {
    std::string srcFiles;
    std::string destFiles;
    ErrFiles(const std::string& src, const std::string& dest) : srcFiles(src), destFiles(dest) {}
};
}  // namespace FileManager
}  // namespace OHOS

#endif
