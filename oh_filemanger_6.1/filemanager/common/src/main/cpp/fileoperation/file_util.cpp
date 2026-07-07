/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <sys/stat.h>
#include <unistd.h>

#include "file_util.h"
#include "utils/log.h"

#undef LOG_TAG
#define LOG_TAG "FileUtilsCpp"  // 全局tag宏，标识模块日志tag

// 判断是否是以prefix起始字符
bool FileUtil::startsWith(const std::string &str, const std::string &prefix)
{
    if (str.length() < prefix.length()) {
        return false;
    }
    return str.compare(0, prefix.length(), prefix) == 0;
}

bool FileUtil::isValidFolder(const std::string &folderPath)
{
    if (access(folderPath.c_str(), F_OK) == 0) {  // 检查路径是否存在
        // 再次检查是否为目录
        struct stat statBuf;
        if (lstat(folderPath.c_str(), &statBuf) == 0 && S_ISDIR(statBuf.st_mode)) {
            return true;
        }
    }
    OH_LOG_WARN(LOG_APP, "isValidFolder false, errno: %{public}d", errno);
    return false;
}

std::string FileUtil::getPathWithTrailingSlash(const std::string &path)
{
    if (path.empty()) {
        return "/";
    }
    if (path.back() != '/') {
        return path + "/";
    }
    return path;
}

FileIO_FileLocation FileUtil::getCloudFileLocation(char *uri)
{
    FileIO_FileLocation location = FileIO_FileLocation::CLOUD;
    if (uri != nullptr) {
        OH_FileIO_GetFileLocation(uri, strlen(uri), &location);
    }
    return location;
}

bool FileUtil::GetRealPath(std::string &path)
{
    std::unique_ptr<char[]> absPath = std::make_unique<char[]>(PATH_MAX + 1);
    if (realpath(path.c_str(), absPath.get()) == nullptr) {
        return false;
    }
    path = absPath.get();
    return true;
}