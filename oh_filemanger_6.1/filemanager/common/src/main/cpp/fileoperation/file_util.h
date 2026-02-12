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

#ifndef HMFILEMANAGER_FILEUTILS_H
#define HMFILEMANAGER_FILEUTILS_H
#include <filemanagement/fileio/oh_fileio.h>
#include <string>

class FileUtil {
public:
    static bool startsWith(const std::string &str, const std::string &prefix);
    static bool isValidFolder(const std::string &folderPath);
    static std::string getPathWithTrailingSlash(const std::string &path);
    static FileIO_FileLocation getCloudFileLocation(char *uri);
    static bool GetRealPath(std::string &path);
};

#endif  // HMFILEMANAGER_FILEUTILS_H