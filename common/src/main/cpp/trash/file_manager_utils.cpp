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

#include "file_manager_utils.h"

#include <chrono>
#include <regex>
#include <unistd.h>
#include <unordered_set>
#include <iomanip>
#include <fcntl.h>
#include <sstream>
#include <cstdlib>
#include <sys/stat.h>
#include <filesystem>
#include <charconv>
#include <cerrno>

#include "file_manager_errno.h"
#include "utils/log.h"
namespace OHOS {
namespace FileManager {
const mode_t CHOWN_RWX_USR_GRP = 0771;
constexpr int32_t ENCODE_LEN = 2;
constexpr int32_t USERID_MASK = 200000;
constexpr int32_t DECIMAL_BASE = 10;

const std::string URI_HEAD = "file://";
const std::string APPDATA = "/appdata";

const std::vector<std::string> ADMITTABLE_DIRS = {FileConsts::FAF_URI_BASE,
                                                  FileConsts::EXTERNAL_URI_BASE};

std::string FileManagerUtils::GetFileNameFromUri(const std::string &path)
{
    CHECK_AND_RETURN_RET_LOG(path.empty(), "", "GetFileNameFromUri failed, path is empty");

    size_t lastSlashPosition = path.rfind("/");
    CHECK_AND_RETURN_RET(
        lastSlashPosition != std::string::npos && path.size() > lastSlashPosition, path.substr(lastSlashPosition + 1));
    HILOGE("GetFileNameFromUri failed, path is invalid");
    return "";
}

std::string FileManagerUtils::GetParentPath(const std::string &path)
{
    CHECK_AND_RETURN_RET_LOG(path.empty(), "", "GetParentPath failed, path is empty.");

    const size_t lastSlashPosition = path.rfind("/");
    CHECK_AND_RETURN_RET(
        lastSlashPosition != std::string::npos && path.size() > lastSlashPosition, path.substr(0, lastSlashPosition));

    HILOGE("GetParentPath failed, path is invalid");
    return "";
}

bool FileManagerUtils::StartsWith(const std::string &str, const std::string prefix)
{
    return (str.rfind(prefix, 0) == 0);
}

std::string FileManagerUtils::Encode(const std::string &uri)
{
    const std::unordered_set<char> uriCompentsSet = {'/', '-', '_', '.', '!', '~', '*', '(', ')', '\'', ':'};
    std::ostringstream outPutStream;
    outPutStream.fill('0');
    outPutStream << std::hex;

    for (unsigned char tmpChar : uri) {
        if (std::isalnum(tmpChar) || uriCompentsSet.find(tmpChar) != uriCompentsSet.end()) {
            outPutStream << tmpChar;
        } else {
            outPutStream << std::uppercase;
            outPutStream << '%' << std::setw(ENCODE_LEN) << static_cast<unsigned int>(tmpChar);
            outPutStream << std::nouppercase;
        }
    }

    return outPutStream.str();
}

std::string FileManagerUtils::Decode(const std::string &uri)
{
    std::ostringstream outPutStream;
    size_t index = 0;
    while (index < uri.length()) {
        if (uri[index] == '%') {
            int hex = 0;
            std::istringstream inputStream(uri.substr(index + 1, ENCODE_LEN));
            inputStream >> std::hex >> hex;
            outPutStream << static_cast<char>(hex);
            index += ENCODE_LEN + 1;
        } else {
            outPutStream << uri[index];
            index++;
        }
    }

    return outPutStream.str();
}

bool FileManagerUtils::Mkdir(std::string path)
{
    CHECK_AND_RETURN_RET_LOG(path.length() <= 0, false, "Mkdir Error: path is empty");
    if (path.size() >= 1 && path[path.size() - 1] != '/') {
        path += "/";
    }
    mode_t mask = umask(0);
    for (size_t i = 1; i < path.length(); ++i) {
        if (path[i] == '/') {
            path[i] = '\0';
            if (access(path.c_str(), 0) != 0 && mkdir(path.c_str(), CHOWN_RWX_USR_GRP) == E_FILEMGR_ERR) {
                HILOGE("Mkdir Error: %{public}d:%{public}s", errno, std::strerror(errno));
                umask(mask);
                return false;
            }
            path[i] = '/';
        }
    }
    umask(mask);
    return true;
}

int64_t FileManagerUtils::GetTimeStamp()
{
    std::chrono::system_clock::time_point now = std::chrono::system_clock::now();
    int64_t currentTime = std::chrono::duration_cast<std::chrono::seconds>(now.time_since_epoch()).count();
    return currentTime;
}

bool FileManagerUtils::ConvertStrToInt32(const std::string &str, int32_t &ret)
{
    std::string tmpStr = str;
    if (tmpStr.empty()) {
        HILOGE("str = %{public}s", tmpStr.c_str());
        return false;
    }
    // 处理+符号,转换前需要去除+符号
    if (tmpStr[0] == '+') {
        const static int32_t idxAfterSign = 1;
        if (tmpStr.length() <= idxAfterSign) {
            HILOGE("length invalid:str=%{public}s", tmpStr.c_str());
            return false;
        }
        tmpStr = tmpStr.substr(idxAfterSign);
    }
    auto res = std::from_chars(tmpStr.data(), tmpStr.data() + tmpStr.size(), ret);
    if (res.ec != std::errc()) {
        HILOGE("Failed to convert string to number:%{public}d,%{public}d,%{public}s", res.ec, ret, tmpStr.c_str());
        return false;
    }
    return true;
}

std::string FileManagerUtils::GetVerifyUserId()
{
    return "100";
}

int FileManagerUtils::RemovePath(const std::string &pathStr)
{
    std::__fs::filesystem::path pathTarget(pathStr);
    std::error_code errCode;
    if (!std::__fs::filesystem::remove(pathTarget, errCode)) {
        HILOGE("Failed to remove file or directory, error code: %{public}d,%{private}s",
            errCode.value(), pathStr.c_str());
        return errCode.value();
    }
    return E_FILEMGR_OK;
}

}  // namespace FileManager
}  // namespace OHOS
