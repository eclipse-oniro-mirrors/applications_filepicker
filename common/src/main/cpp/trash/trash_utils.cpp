/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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
#include "trash_utils.h"

#include <cstring>
#include <dirent.h>
#include <iostream>
#include <memory>
#include <sstream>
#include <string_view>
#include <sys/stat.h>
#include <unistd.h>
#include <deque>
#include <vector>
#include <filesystem>
#include <sys/types.h>
#include <utime.h>
#include <codecvt>
#include <charconv>

#include "utils/log.h"
#include "trash_data_struct.h"
#include "filemanager_rdb_trash.h"
#include "file_manager_errno.h"
#include "file_manager_utils.h"

namespace OHOS {
namespace FileManager {

void TrashUtils::Deleter(struct NameListArg *arg)
{
    CHECK_AND_RETURN_LOG(arg == nullptr, "arg is nullptr.");
    for (int i = 0; i < arg->direntNum; i++) {
        free((arg->namelist)[i]);
        (arg->namelist)[i] = nullptr;
    }
    free(arg->namelist);
}

int32_t TrashUtils::FilterFunc(const struct dirent *filename)
{
    CHECK_AND_RETURN_RET_LOG(filename == nullptr, FILTER_DISMATCH, "filename is null");
    if ((std::string_view(filename->d_name) == ".") || (std::string_view(filename->d_name) == "..")) {
        return FILTER_DISMATCH;
    }
    return FILTER_MATCH;
}

bool TrashUtils::GetStat(const std::string &path, StatEntity &statEntity)
{
    struct stat fileStat;
    int result = stat(path.c_str(), &fileStat);
    if (result == E_FILEMGR_OK) {
        statEntity = StatEntity{ fileStat };
        return true;
    }

    return false;
}

bool TrashUtils::CheckDir(const std::string &path)
{
    struct stat fileInformation;
    if (stat(path.c_str(), &fileInformation) == 0 && (fileInformation.st_mode & S_IFDIR)) {
        return true;
    }
    return false;
}

std::tuple<bool, int> TrashUtils::Access(const std::string &path)
{
    int ret = access(path.c_str(), F_OK);
    if (ret == 0) {
        return { true, E_FILEMGR_OK };
    }

    if (errno == ENOENT) {
        HILOGD("File does not exist.");
        return { false, E_FILEMGR_OK };
    }

    HILOGE("Failed to access errno : %{public}d, errnoinfo : %{public}s", errno, strerror(errno));
    return { false, errno };
}

int TrashUtils::CopyAndDeleteFile(const std::string &src, const std::string &dest)
{
    // 获取源文件时间
    StatEntity statEntity;
    if (!GetStat(src, statEntity)) {
        HILOGE("Failed to get file stat.");
        return EINVAL;
    }

    utimbuf new_times;
    new_times.actime = statEntity.stat_.st_atime;
    new_times.modtime = statEntity.stat_.st_mtime;

    auto copyOptions = std::__fs::filesystem::copy_options::overwrite_existing
                    | std::__fs::filesystem::copy_options::recursive;
    std::error_code errCode;
    std::__fs::filesystem::copy(src.c_str(), dest.c_str(), copyOptions, errCode);
    if (errCode.value() != E_FILEMGR_OK) {
        HILOGE("Failed to move file using copyfile interface.");
        return errCode.value();
    }

    if (!FileManagerUtils::StartsWith(dest, SANDBOX_DIR_EL1_BASE_PATH) &&
        !FileManagerUtils::StartsWith(dest, SANDBOX_DIR_EL2_BASE_PATH) &&
        !FileManagerUtils::StartsWith(dest, EXTERNAL_STORAGE_PATH)) {
        // 设置目标文件时间
        if (utime(dest.c_str(), &new_times) == -1) {
            HILOGE("Failed to set file time errno : %{public}d errnoinfo : %{public}s", errno, strerror(errno));
            std::__fs::filesystem::remove_all(dest.c_str(), errCode);
            if (errCode.value() != 0) {
                int errRes = errCode.value();
                HILOGE("Failed to remove file, error code : %{public}d error : %{public}s", errRes, strerror(errno));
                return errRes;
            }
            return errno;
        }
    }

    std::__fs::filesystem::remove_all(src.c_str(), errCode);
    if (errCode.value() != 0) {
        int errRes = errCode.value();
        HILOGE("Failed to remove file, error code: %{public}d", errRes);
        auto [exists, _] = Access(dest);
        if (exists) {
            std::__fs::filesystem::remove_all(src.c_str(), errCode);
            HILOGI("Delete file that was just created, res code: %{public}d", errCode.value());
        }
        return errRes;
    }

    return E_FILEMGR_OK;
}

int TrashUtils::RenameFile(const std::string &src, const std::string &dest)
{
    std::__fs::filesystem::path srcPath(src);
    std::__fs::filesystem::path dstPath(dest);
    std::error_code errCode;
    std::__fs::filesystem::rename(srcPath, dstPath, errCode);
    if (errCode.value() == EXDEV) {
        HILOGW("Failed to rename file due to EXDEV");
        return CopyAndDeleteFile(src, dest);
    }
    return errCode.value();
}

int TrashUtils::ScanDir(const std::string &path)
{
    std::unique_ptr<struct NameListArg, decltype(Deleter) *> pNameList
        = { new (std::nothrow) struct NameListArg, Deleter };
    CHECK_AND_RETURN_RET_LOG(!pNameList, ENOMEM, "Failed to request heap memory.");
    return scandir(path.c_str(), &(pNameList->namelist), FilterFunc, alphasort);
}

bool TrashUtils::GetRealPath(std::string &path)
{
    std::unique_ptr<char[]> absPath = std::make_unique<char[]>(PATH_MAX + 1);
    if (realpath(path.c_str(), absPath.get()) == nullptr) {
        return false;
    }
    path = absPath.get();
    return true;
}

int TrashUtils::RmDirectory(const std::string &path)
{
    std::__fs::filesystem::path pathName(path);
    std::error_code errCode;
    bool isExists = std::__fs::filesystem::exists(pathName, errCode);
    CHECK_AND_RETURN_RET_LOG(
        errCode.value() != 0, errCode.value(), "Failed to check exists, error code: %{public}d", errCode.value());

    if (isExists) {
        (void)std::__fs::filesystem::remove_all(pathName, errCode);
        CHECK_AND_RETURN_RET_LOG(errCode.value() != 0,
            errCode.value(),
            "Failed to remove directory, error code: %{public}d",
            errCode.value());
    }
    return E_FILEMGR_OK;
}

int TrashUtils::RenameFile(const std::string &src,
    const std::string &dest, const int mode, std::deque<struct ErrFiles> &errfiles)
{
    std::__fs::filesystem::path dstPath(dest);
    std::error_code errCode;
    bool isExists = std::__fs::filesystem::exists(dstPath, errCode);
    CHECK_AND_RETURN_RET_LOG(
        errCode.value() != 0, errCode.value(), "Failed to check exists, error code: %{public}d", errCode.value());

    if (isExists) {
        errCode.clear();
        bool isDirectory = std::__fs::filesystem::is_directory(dstPath, errCode);
        if (errCode.value() != 0 || isDirectory) {
            errfiles.emplace_front(src, dest);
            return E_FILEMGR_OK;
        }
        if (mode == DIRMODE_FILE_THROW_ERR) {
            errfiles.emplace_back(src, dest);
            return E_FILEMGR_OK;
        }
    }
    std::__fs::filesystem::path srcPath(src);
    std::__fs::filesystem::rename(srcPath, dstPath, errCode);
    if (errCode.value() == EXDEV) {
        HILOGW("Failed to rename file due to EXDEV");
        return CopyAndDeleteFile(src, dest);
    }
    return errCode.value();
}

int TrashUtils::RenameDir(const std::string &src,
    const std::string &dest, const int mode, std::deque<struct ErrFiles> &errfiles)
{
    std::__fs::filesystem::path destPath(dest);
    std::error_code errCode;
    bool isExists = std::__fs::filesystem::exists(destPath, errCode);
    CHECK_AND_RETURN_RET_LOG(
        errCode.value() != 0, errCode.value(), "Failed to check exists, error code: %{public}d", errCode.value());

    if (isExists) {
        return RecurMoveDir(src, dest, mode, errfiles);
    }
    std::__fs::filesystem::path srcPath(src);
    isExists = std::__fs::filesystem::exists(srcPath, errCode);
    CHECK_AND_RETURN_RET_LOG(
        errCode.value() != 0, errCode.value(), "Failed to check exists, error code: %{public}d", errCode.value());

    std::__fs::filesystem::rename(srcPath, destPath, errCode);
    if (errCode.value() == EXDEV) {
        HILOGI("Failed to rename file due to EXDEV");
        if (!std::__fs::filesystem::create_directory(destPath, errCode)) {
            HILOGE("Failed to create directory, error code: %{public}d", errCode.value());
            return errCode.value();
        }
        return RecurMoveDir(src, dest, mode, errfiles);
    }
    if (errCode.value() != 0) {
        HILOGE("Failed to rename file, error code: %{public}d", errCode.value());
        return errCode.value();
    }
    return E_FILEMGR_OK;
}

int TrashUtils::RecurMoveDir(const std::string &srcPath, const std::string &destPath, const int mode,
    std::deque<struct ErrFiles> &errfiles)
{
    std::__fs::filesystem::path dpath(destPath);
    if (!std::__fs::filesystem::is_directory(dpath)) {
        errfiles.emplace_front(srcPath, destPath);
        return E_FILEMGR_OK;
    }

    std::unique_ptr<struct NameListArg, decltype(Deleter) *> ptr = {new struct NameListArg, Deleter};
    CHECK_AND_RETURN_RET_LOG(!ptr, ENOMEM, "Failed to request heap memory.");

    int num = scandir(srcPath.c_str(), &(ptr->namelist), FilterFunc, alphasort);
    ptr->direntNum = num;

    for (int i = 0; i < num; i++) {
        if ((ptr->namelist[i])->d_type == DT_DIR) {
            std::string srcTemp = srcPath + '/' + std::string((ptr->namelist[i])->d_name);
            std::string destTemp = destPath + '/' + std::string((ptr->namelist[i])->d_name);
            size_t size = errfiles.size();
            int res = RenameDir(srcTemp, destTemp, mode, errfiles);
            CHECK_AND_RETURN_RET(res != E_FILEMGR_OK, res);
            if (size != errfiles.size()) {
                continue;
            }
            res = FileManagerUtils::RemovePath(srcTemp);
            CHECK_AND_RETURN_RET(res != E_FILEMGR_OK, res);
        } else {
            std::string src = srcPath + '/' + std::string((ptr->namelist[i])->d_name);
            std::string dest = destPath + '/' + std::string((ptr->namelist[i])->d_name);
            auto [exists, _] = Access(dest);
            if (exists) {
                GenerateNewPathOfRecover(dest, GENERATE_NEW_NAME_START_NUMBER);
            }
            int res = RenameFile(src, dest, mode, errfiles);
            CHECK_AND_RETURN_RET_LOG(res != E_FILEMGR_OK, res, "Failed to rename file for error %{public}d", res);
        }
    }
    return E_FILEMGR_OK;
}

int32_t TrashUtils::MoveDir(const std::string &src, const std::string &dest,
    const int mode, std::deque<struct ErrFiles> &errfiles)
{
    HILOGD("MoveDir enter");
    size_t pos = src.rfind('/');
    if (pos == std::string::npos) {
        return EINVAL;
    }
    if (access(src.c_str(), W_OK) != 0) {
        HILOGE("Failed to move directory: %{public}s", strerror(errno));
        return errno;
    }

    int32_t res = RenameDir(src, dest, mode, errfiles);
    if (res == E_FILEMGR_OK) {
        CHECK_AND_RETURN_RET_LOG(!errfiles.empty(), EEXIST, "Failed to movedir with some conflicted files");
        int32_t removeRes = RmDirectory(src);
        CHECK_AND_RETURN_RET_LOG(removeRes, removeRes, "Failed to remove src directory");
    }
    return res;
}

static int32_t CutString(std::string &str, size_t len)
{
    std::wstring_convert<std::codecvt_utf8<wchar_t>> converter("", L"");
    std::wstring wideStr = converter.from_bytes(str);
    if (wideStr.length() > len) {
        wideStr.erase(wideStr.length() - len, len);
        str = converter.to_bytes(wideStr);
        return E_FILEMGR_OK;
    }
    HILOGE("wideStr convert error.");
    return E_FILEMGR_ERR;
}

static std::tuple<bool, uint32_t> GetWstringLength(const std::string &path)
{
    std::wstring_convert<std::codecvt_utf8<wchar_t>> converter("", L"");
    std::wstring wideStr = converter.from_bytes(path);
    if (wideStr.empty()) {
        return {false, 0};
    }
    return {true, wideStr.length()};
}

int32_t TrashUtils::GenerateNewPath(std::string &filePath)
{
    auto [isExist, accessRet] = Access(filePath);
    if (accessRet == E_FILEMGR_OK && !isExist) {
        return E_FILEMGR_OK;
    }

    size_t lastSlashPosition = filePath.find_last_of("/");
    if (lastSlashPosition == std::string::npos) {
        return accessRet;
    }

    std::string basePath = filePath.substr(0, lastSlashPosition + 1);
    std::string fileName = filePath.substr(lastSlashPosition + 1);
    size_t suffixPos = fileName.find_last_of(".");
    bool isDLP = suffixPos != std::string::npos && suffixPos > 0 && fileName.substr(suffixPos + 1) == DLP;
    if (isDLP) {
        size_t secondDotPos = fileName.find_last_of(".", suffixPos - 1);
        if (secondDotPos != std::string::npos) {
            suffixPos = secondDotPos;
        }
    }
    std::string prefix = fileName;
    std::string suffix = "";
    if (suffixPos != std::string::npos) {
        prefix = fileName.substr(0, suffixPos);
        suffix = fileName.substr(suffixPos);
    }

    if (accessRet == ENAMETOOLONG) {
        HILOGI("file name too long, cut it.");
        std::string newFileName = fileName;
        auto [succ, length] = GetWstringLength(prefix);
        if (succ && length > CUT_FILE_NAME_LENGTH) {
            int32_t res = CutString(prefix, CUT_FILE_NAME_LENGTH);
            CHECK_AND_RETURN_RET_LOG(res != E_FILEMGR_OK, accessRet, "Failed to cut prefix.");
            newFileName = prefix + suffix;
        } else {
            int32_t res = CutString(newFileName, CUT_FILE_NAME_LENGTH);
            CHECK_AND_RETURN_RET_LOG(res != E_FILEMGR_OK, accessRet, "Failed to cut newFileName.");
        }

        filePath = basePath + newFileName;
        return GenerateNewPath(filePath);
    }

    if (isExist) {
        auto deleteTime = std::chrono::duration_cast<std::chrono::milliseconds>(
        std::chrono::system_clock::now().time_since_epoch()).count();
        std::string path = basePath + prefix + "_" + std::to_string(deleteTime) + suffix;
        filePath = path;
        accessRet = GenerateNewPath(filePath);
    }
    return accessRet;
}

static void HandleFileNameTooLong(std::string &filePath, uint32_t index, size_t suffixPos, size_t lastSlashPosition)
{
    HILOGI("file name too long, cut it.");
    std::string fileName = "";
    std::string suffix = "";
    if (suffixPos != std::string::npos) {
        fileName = filePath.substr(lastSlashPosition + 1, suffixPos - lastSlashPosition - 1);
        suffix = filePath.substr(suffixPos);
    } else {
        fileName = filePath.substr(lastSlashPosition + 1);
    }

    std::wstring_convert<std::codecvt_utf8<wchar_t>> converter("", L"");
    std::wstring wideStr = converter.from_bytes(fileName);
    if (wideStr.length() > CUT_FILE_NAME_LENGTH) {
        wideStr.erase(wideStr.length() - CUT_FILE_NAME_LENGTH, CUT_FILE_NAME_LENGTH);
        fileName = converter.to_bytes(wideStr);
        filePath = filePath.substr(0, lastSlashPosition + 1) + fileName + suffix;
    } else {
        wideStr = converter.from_bytes(filePath.substr(lastSlashPosition + 1));
        if (wideStr.length() > CUT_FILE_NAME_LENGTH) {
            wideStr.erase(wideStr.length() - CUT_FILE_NAME_LENGTH, CUT_FILE_NAME_LENGTH);
            fileName = converter.to_bytes(wideStr);
        } else {
            HILOGE("wideStr convert error.");
            return;
        }
        filePath = filePath.substr(0, lastSlashPosition + 1) + fileName;
    }
}

int32_t TrashUtils::GenerateNewPathOfRecover(std::string &filePath, uint32_t index)
{
    HILOGI("GenerateNewPathOfRecover.");
    std::string path = filePath;
    size_t suffixPos = filePath.find_last_of(".");
    size_t lastSlashPosition = filePath.find_last_of("/");
    if (lastSlashPosition > suffixPos) {
        suffixPos = std::string::npos;
    }
    // 适配dlp
    bool isDLP = suffixPos != std::string::npos && suffixPos > 0 && !TrashUtils::CheckDir(filePath) &&
                 filePath.substr(suffixPos + 1) == DLP;
    if (isDLP) {
        size_t secondDotPos = filePath.find_last_of(".", suffixPos - 1);
        if (secondDotPos != std::string::npos && secondDotPos > lastSlashPosition) {
            suffixPos = secondDotPos;
        }
    }

    if (suffixPos == std::string::npos) {
        path += " (" + std::to_string(index) + ")";
    } else {
        path = filePath.substr(0, suffixPos) + " (" + std::to_string(index) + ")" + filePath.substr(suffixPos);
    }
    auto [isExist, accessRet] = Access(path);
    if (accessRet == ENAMETOOLONG) {
        std::string filePathCopy = filePath;
        HandleFileNameTooLong(filePath, index, suffixPos, lastSlashPosition);
        if (filePath == filePathCopy) {
            HILOGE("Cut fileName error.");
            return ENAMETOOLONG;
        }
        return GenerateNewPathOfRecover(filePath, GENERATE_NEW_NAME_START_NUMBER);
    }

    if (isExist) {
        accessRet = GenerateNewPathOfRecover(filePath, index + 1);
    } else {
        if (accessRet == E_FILEMGR_OK) {
            filePath = path;
            return accessRet;
        }
    }
    return accessRet;
}

std::string TrashUtils::GetUriByPath(const std::string &path)
{
    if (path.size() == 0) {
        return path;
    }
    std::string prefixStr = "file://docs";
    return prefixStr + FileManagerUtils::Encode(path);
}

std::string TrashUtils::GetTimeSlotFromPath(const std::string &userId, const std::string &path)
{
    size_t slashSize = 1;
    // 获取时间戳
    size_t trashPathPrefixPos = path.find(GetTrashServerPath(userId));
    size_t expectTimeSlotStartPos = trashPathPrefixPos + GetTrashServerPath(userId).length() + slashSize;
    if (expectTimeSlotStartPos >= path.length()) {
        return "";
    }
    std::string realFilePathWithTime =
        path.substr(trashPathPrefixPos + GetTrashServerPath(userId).length() + slashSize);
    // 获取时间戳目录位置
    size_t trashPathWithTimePrefixPos = realFilePathWithTime.find_first_of("/");
    if (trashPathWithTimePrefixPos == std::string::npos) {
        return "";
    }
    std::string timeSlot = realFilePathWithTime.substr(0, trashPathWithTimePrefixPos);
    HILOGI("GetTimeSlotFromPath: timeSlot = %{public}s", timeSlot.c_str());
    return timeSlot;
}

int TrashUtils::RecursiveFunc(const std::string &userId, const std::string &path,
    std::vector<std::string> &dirents)
{
    std::unique_ptr<struct NameListArg, decltype(Deleter)*> pNameList
        = { new (std::nothrow) struct NameListArg, Deleter };
    CHECK_AND_RETURN_RET_LOG(!pNameList, ENOMEM, "Failed to request heap memory.");
    int num = scandir(path.c_str(), &(pNameList->namelist), FilterFunc, alphasort);
    if (num < 0) {
        HILOGE("RecursiveFunc: Failed to scan dir");
        return errno;
    }
    pNameList->direntNum = num;
    std::string pathInRecur = path;
    for (int i = 0; i < num; i++) {
        if ((*(pNameList->namelist[i])).d_type == DT_REG) {
            dirents.emplace_back(path + '/' + pNameList->namelist[i]->d_name);
        } else if ((*(pNameList->namelist[i])).d_type == DT_DIR) {
            std::string pathTemp = pathInRecur;
            pathInRecur += '/' + std::string((*(pNameList->namelist[i])).d_name);
            // check if path include TRASH_SUB_DIR + "/", need to add it into dirents
            std::string timeSlot = GetTimeSlotFromPath(userId, pathTemp);
            bool isOnly = !timeSlot.empty() && pathInRecur.rfind(TRASH_SUB_DIR + timeSlot + "/") != std::string::npos;
            if (isOnly) {
                // Only filter previous dir is TRASH_SUB_DIR
                dirents.emplace_back(pathInRecur);
            }
            int ret = RecursiveFunc(userId, pathInRecur, dirents);
            CHECK_AND_RETURN_RET_LOG(ret != E_FILEMGR_OK,
                ret,
                "RecursiveFunc: Failed to recursive get all dirents for %{public}d", ret);
            pathInRecur = pathTemp;
        }
    }
    return E_FILEMGR_OK;
}

int TrashUtils::GetFilesInCurrentDir(std::string currentDir, std::vector<std::string> &dirents)
{
    std::unique_ptr<struct NameListArg, decltype(Deleter)*> pNameList
        = { new (std::nothrow) struct NameListArg, Deleter };
    CHECK_AND_RETURN_RET_LOG(!pNameList, ENOMEM, "Failed to request heap memory.");
    int num = scandir(currentDir.c_str(), &(pNameList->namelist), FilterFunc, alphasort);
    if (num < 0) {
        HILOGE("Failed to scan dir");
        return errno;
    }

    for (int i = 0; i < num; i++) {
        dirents.emplace_back(currentDir + '/' + pNameList->namelist[i]->d_name);
    }
    return E_FILEMGR_OK;
}

std::string TrashUtils::FindSourceFilePath(const std::string &userId, const std::string &path)
{
    size_t slashSize = 1;
    // 获取/trash目录位置
    size_t trashPathPrefixPos = path.find(GetTrashServerPath(userId));
    if (trashPathPrefixPos == std::string::npos) {
        HILOGE("FindSourceFilePath: Invalid Path No Trash Path");
        return "";
    }
    size_t timeSLotStartPos = trashPathPrefixPos + GetTrashServerPath(userId).length() + slashSize;
    std::string realFilePathWithTime = path.substr(timeSLotStartPos);
    // 获取时间戳目录位置
    size_t trashPathWithTimePrefixPos = realFilePathWithTime.find_first_of("/");
    if (trashPathWithTimePrefixPos == std::string::npos) {
        HILOGE("FindSourceFilePath: : Invalid Path No timestamp");
        return "";
    }
    // 获取时间戳
    std::string timeSlot = realFilePathWithTime.substr(0, trashPathWithTimePrefixPos);
    std::string realFilePath = realFilePathWithTime.substr(trashPathWithTimePrefixPos + slashSize);
    size_t pos = realFilePath.rfind(TRASH_SUB_DIR + timeSlot + "/");
    if (pos == std::string::npos) {
        HILOGE("FindSourceFilePath: : Invalid Path No Trash Sub Path");
        return "";
    }
    std::string realFilePathPrefix = realFilePath.substr(0, pos);
    std::string realFileName = realFilePath.substr(pos + TRASH_SUB_DIR.length() +
        timeSlot.length() + slashSize);
    realFilePath = "/" + realFilePathPrefix + realFileName;
    return realFilePath;
}

static bool TimeSlotStr2ll(const std::string &timeSlotStr, int64_t &timeSlot)
{
    if (timeSlotStr.empty() || timeSlotStr.length() > TIME_SLOT_LENGTH) {
        HILOGE("Invalid timeSlotStr %{public}s", timeSlotStr.c_str());
        return false;
    }

    auto res = std::from_chars(timeSlotStr.data(), timeSlotStr.data() + timeSlotStr.size(), timeSlot);
    if (res.ec != std::errc()) {
        HILOGE("Failed to convert string to number");
        return false;
    }
    return true;
}

void TrashUtils::ConvertOldFiles(const std::string &userId, std::vector<std::string> &dirents)
{
    for (size_t i = 0; i < dirents.size(); i++) {
        std::string dirent = dirents[i];
        if (!std::__fs::filesystem::exists(dirent)) {
            continue;
        }

        std::string timeSlot = GetTimeSlotFromPath(userId, dirent);
        if (timeSlot.empty()) {
            continue;
        }

        std::string srcPath = FindSourceFilePath(userId, dirent);
        if (srcPath.empty()) {
            continue;
        }

        auto pos = srcPath.find_last_of("/");
        std::string fileName = srcPath.substr(pos + 1);
        std::string moveToFile = GetTrashServerPath(userId) + "/" + fileName;
        std::__fs::filesystem::path destPath(moveToFile);
        if (std::__fs::filesystem::exists(destPath)) {
            GenerateNewPath(moveToFile);
        }
        std::string moveToFileForDB = moveToFile;
        moveToFileForDB.replace(0, GetTrashServerPath(userId).length(), TRASH_PATH);
        std::vector<std::string> trashPaths;
        TrashInfo info;
        info.srcPath = srcPath;
        info.trashPath = moveToFileForDB;
        int64_t deleteTime = 0;
        if (TimeSlotStr2ll(timeSlot, deleteTime)) {
            info.deleteTime = deleteTime / MILLISECOND_TO_SECOND;
        }
        trashPaths.push_back(moveToFileForDB);
        FileManagerRdbTrash rdbTrash(userId);
        rdbTrash.AddToTrash(info);

        std::__fs::filesystem::path direntPath(dirent);
        std::__fs::filesystem::path destPathFinal(moveToFile);

        std::error_code errCode;
        std::__fs::filesystem::rename(direntPath, destPathFinal, errCode);
        CHECK_AND_PRINT_LOG(
            errCode.value() != E_FILEMGR_OK, "Failed to rename file. errCode : %{public}d", errCode.value());
        // 4、执行成功后，执行数据库第二阶段
        rdbTrash.UpdateStatus(trashPaths, TrashStatus::COMPLETE);
    }
}

void TrashUtils::ProcessOldFileInTrash(const std::string &userId)
{
    HILOGI("ProcessOldFileInTrash.");
    std::vector<std::string> trashRootDirents;
    int trashRet = GetFilesInCurrentDir(GetTrashServerPath(userId), trashRootDirents);
    CHECK_AND_RETURN_LOG(trashRet != E_FILEMGR_OK, "ProcessOldFileInTrash error.");

    if (trashRootDirents.size() == 0) {
        HILOGI("Has no files in trash directory.");
        return;
    }

    std::vector<std::string> dirents;
    int ret = RecursiveFunc(userId, GetTrashServerPath(userId), dirents);
    CHECK_AND_PRINT_LOG(ret != E_FILEMGR_OK, "Get dirents error. ret : %{public}d", ret);
    ConvertOldFiles(userId, dirents);

    for (size_t i = 0; i < trashRootDirents.size(); i++) {
        std::__fs::filesystem::remove_all(trashRootDirents[i]);
    }
}

std::string TrashUtils::GetTrashServerPath(const std::string &userId)
{
    return TRASH_SERVER_PATH_FIRST_PART + userId + TRASH_SERVER_PATH_LAST_PART;
}

int TrashUtils::MoveFile(const std::string &srcFile, const std::string &destFile, bool isRecover)
{
    auto [isExist, ret] = TrashUtils::Access(destFile);
    if (isExist) {
        std::string newDestFile = destFile;
        if (isRecover) {
            TrashUtils::GenerateNewPathOfRecover(newDestFile, GENERATE_NEW_NAME_START_NUMBER);
        } else {
            TrashUtils::GenerateNewPath(newDestFile);
        }
        return TrashUtils::RenameFile(srcFile, newDestFile);
    } else if (ret == E_FILEMGR_OK) {
        return TrashUtils::RenameFile(srcFile, destFile);
    }
    HILOGE("Invalid Path");
    return ret;
}

int32_t TrashUtils::DeleteFileToTrash(const DeleteTrashParam &deleteTrashParam, std::string &destPath, bool isRetried)
{
    std::string selectFileOnly = deleteTrashParam.path.substr(deleteTrashParam.posLastSlash);
    std::string trashPath = deleteTrashParam.isClient ? TRASH_PATH : GetTrashServerPath(deleteTrashParam.userId);
    std::string newFileName = trashPath + selectFileOnly;
    auto [isExist, moveRet] = Access(newFileName);
    if (isExist) {
        GenerateNewPath(newFileName);
    }

    TrashInfo info;
    std::string tempPath = newFileName;
    info.srcPath = deleteTrashParam.path;
    info.trashPath = deleteTrashParam.isClient ?
        tempPath : tempPath.replace(0, GetTrashServerPath(deleteTrashParam.userId).size(), TRASH_PATH);
    info.deleteTime = FileManagerUtils::GetTimeStamp();
    FileManagerRdbTrash rdbTrash(deleteTrashParam.userId);
    int32_t ret = rdbTrash.AddToTrash(info);
    if (ret < 0) {
        HILOGE("AddToTrash file error.");
        return E_INNER_ERROR;
    }
    moveRet = MoveFile(deleteTrashParam.path, newFileName, false);
    if (moveRet != E_FILEMGR_OK) {
        HILOGE("MoveFile failed: %{public}d", moveRet);
        rdbTrash.DeleteFromTrash(info.trashPath);
        return E_INNER_ERROR;
    }
    destPath = info.trashPath;
    return moveRet;
}

bool TrashUtils::IsSameSrcPathByTrashPath(
    const std::string &userId, const std::string &trashPath, const std::string &srcPath)
{
    // 根据回收站路径去数据库查询原路径
    std::vector<TrashInfo> trashInfos = FileManagerRdbTrash(userId).GetTrashInfoByTrashPath({ trashPath });
    if (trashInfos.empty()) {
        HILOGE("trashInfos size:%{public}zu,trashPath=%{private}s", trashInfos.size(), trashPath.c_str());
        return false;
    }
    for (const auto &trashInfo : trashInfos) {
        if (trashInfo.srcPath == srcPath) {
            return true;
        }
    }
    return false;
}

int32_t TrashUtils::DeleteDirToTrash(const DeleteTrashParam &deleteTrashParam, std::string &destPath, bool isRetried)
{
    std::string moveFromDir = deleteTrashParam.path;
    std::string trashPath = deleteTrashParam.isClient ? TRASH_PATH : GetTrashServerPath(deleteTrashParam.userId);
    std::string moveToDir = trashPath + deleteTrashParam.path.substr(deleteTrashParam.posLastSlash);
    auto [isExist, moveRet] = Access(moveToDir);
    if (isExist) {
        GenerateNewPath(moveToDir);
    }

    TrashInfo info;
    std::string tempPath = moveToDir;
    info.srcPath = moveFromDir;
    info.trashPath = deleteTrashParam.isClient ?
        tempPath : tempPath.replace(0, GetTrashServerPath(deleteTrashParam.userId).size(), TRASH_PATH);
    info.deleteTime = FileManagerUtils::GetTimeStamp();
    FileManagerRdbTrash rdbTrash(deleteTrashParam.userId);
    int32_t ret = rdbTrash.AddToTrash(info);
    if (ret < 0) {
        HILOGE("AddToTrash dir error.");
        return E_INNER_ERROR;
    }
    std::deque<struct ErrFiles> errfiles;
    moveRet = MoveDir(moveFromDir, moveToDir, DIRMODE_DIRECTORY_REPLACE, errfiles);
    if (moveRet != E_FILEMGR_OK) {
        HILOGE("MoveDir failed: %{public}d", moveRet);
        rdbTrash.DeleteFromTrash(moveToDir);
        return E_INNER_ERROR;
    }
    destPath = info.trashPath;
    return moveRet;
}
int32_t TrashUtils::DeleteToTrash(const std::string &userId, const std::string &inUri,
    std::string &destPath, bool isClient)
{
    HILOGI("TrashUtils::DeleteToTrash enter");
    if (inUri.empty()) {
        HILOGE("inUri empty");
        return E_PARAM;
    }
    std::string uri = inUri;
    size_t len = uri.size();
    if (uri[len - 1] == '/') {
        uri = uri.substr(0, len - 1);
    }
    std::string path;
    if (isClient) {
        path = uri;
        path.replace(0, FileConsts::TRANSFORM_DELETE.length(),"");
    } else {
        path = uri;
        path.replace(0, FileConsts::FAF_URI_BASE.length(),
            FileConsts::FAT_PATH_BEFORE_UID + userId + FileConsts::FAT_PATH_AFTER_UID);
    }
    if (access(path.c_str(), F_OK) != 0) {
        HILOGE("Delete failed: %{public}s", strerror(errno));
        return E_NOENT;
    }

    if (isClient && !FileManagerUtils::Mkdir(TRASH_PATH)) {
        HILOGE("Mkdir failed");
        return E_INNER_ERROR;
    }
    auto posLastSlash = path.find_last_of('/');
    if (posLastSlash == std::string::npos) {
        return E_PARAM;
    }
    if (CheckDir(path)) {
        return DeleteDirToTrash({userId, path, static_cast<int32_t>(posLastSlash), isClient}, destPath);
    }
    return DeleteFileToTrash({userId, path, static_cast<int32_t>(posLastSlash), isClient}, destPath);
}
}  // namespace FileManager
}  // namespace OHOS